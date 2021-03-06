/* Program RMCSRT
 * This program converts .RMC files produced by ROMMAC source files into
 * .SAV files of the form demanded by the ROM burning programs.  The basic
 * job is to sort the contents of the ROM data words into ROM address order.
 *
 * The format of the .RMC file is:
 *	Bytes 0-13	Chip type and manufacturer, left justified in ASCII.
 *	Bytes 14-15	Number of ROM words (2**n).
 *	Bytes 16-17	Number of ROM data bits per word.
 *	Bytes 20-21	Starting address within ROM for ROM burner.
 *	Bytes 22-23	Last address within ROM for ROM burner.
 *	Bytes 24-25	Version number - max 8 bits.
 *	Bytes 26-75	40-character (decimal) comment field.
 *	Bytes 76-77	Default for ROM data word contents.  This value is
 *			initialized into all locations of the .SAV file
 *			before the .RMC file is read; the .RMC file contents
 *			supersede this default.
 *	Bytes 100-101	Size of .RMC file, in bytes.  Used because EOF
 *			cannot be accurately placed.  If zero, ROM size
 *			(above) times 4 plus 1000 (octal) is used.
 *	Words starting from byte address 1000 octal contain a sequence of
 *	word pairs.  The first word of each pair contains a ROM address;
 *	the second contains the ROM data value for that address.  Both
 *	addresses and data values are right justified in the word.
 *
 * The format of the .SAV file output is:
 *	Bytes 0-1000 octal same as input file.
 *	Bytes starting at address 1000 octal contain ROM word data values
 *	in sequence from ROM address zero.  Data is right justified.
 */

#include <std.h>
#include "rom.h#"

char *buffer = NULL;
int *rmcadr = NULL;
struct
  {int address;
   int data;} pair = {0, 0};

main()
  {struct header head;
   FIO dot_RMC, dot_SAV;
   int i, n, errcode;

/*
 * Establish input and output files.
 */
   openfiles(&dot_RMC, &dot_SAV);

/*
 * First, copy the header of the .RMC file and save it.  Then copy up to the
 * data section.
 */
   if ((errcode = bread(&dot_RMC, &head, sizeof(struct header)))
         < sizeof(struct header)) readerr(errcode);
   putfmt("Header: %.12p [%ix%i] (%h thru %h) Version: %i; %.40p\n",
      &head.label, head.romsize, head.wordsize,
      head.start, head.stop, head.version, head.comment);
   if ((errcode = bwrite(&dot_SAV, &head, sizeof(struct header))) < 0)
         writeerr(errcode);
   buffer = alloc((n = ORG - sizeof(struct header)), NULL);
   if ((errcode = bread(&dot_RMC, buffer, n)) < n) readerr(errcode);
   for ( i=0 ; i<n ; i++ ) buffer[i] = '\0';
   if ((errcode = bwrite(&dot_SAV, buffer, n)) < 0) writeerr(errcode);
   free(buffer, NULL);

/*
 * Now get enough memory for the ROM image, and also a buffer for the map.
 */
   buffer = alloc(head.romsize, NULL);
   rmcadr = alloc(head.romsize*sizeof(int), NULL);
   for ( i=0 ; i<head.romsize ; i++)
     {buffer[i] = head.def;
      rmcadr[i] = -1;}

/*
 * Read in the .RMC file one word pair at a time, and place the data in the
 * buffer at the proper point.
 */
   if (head.filesize == 0) head.filesize = head.romsize*2*sizeof(int) + ORG;
   for ( i=ORG ; i<head.filesize ; i += sizeof(pair) )
     {if ((errcode = bread(&dot_RMC, &pair, sizeof(pair))) != sizeof(pair))
         readerr(errcode);
      if (0 <= pair.address && pair.address <= head.romsize-1)
         if (rmcadr[pair.address] == -1)
           {buffer[pair.address] = pair.data;
            rmcadr[pair.address] = i;}
         else if (buffer[pair.address] == pair.data)
           {romerr(i);
            errfmt("%% ROM word doubly defined with same value\n");}
         else
           {romerr(i);
            error("? ROM word doubly defined with different value\n");}
      else
        {errfmt("%% Current .RMC file address %o (octal)\n", i);
         error("? ROM address greater than ROM size\n");}}

/*
 * Type out statistics
 */
   for ( i=0, n=0 ; i<head.romsize ; i++)
      if (rmcadr[i] != -1) n++;
   putfmt("%i entries specified, %i defaulted out of %i total\n", n, i-n, i);

/*
 * Write out buffer to .SAV file.
 */
   if ((errcode = bwrite(&dot_SAV, buffer, head.romsize)) < 0)
      writeerr(errcode);

/*
 * Done.
 */
   bclose(&dot_SAV);
   bclose(&dot_RMC);
   putfmt("All done.\n");}


/* openfiles procedure
 * This procedure asks the terminal operator for the names of the input
 * and output files, and opens them.
 */
openfiles(in, out)
FIO *in, *out;
  {TEXT name[81];			/* buffer for RSTS file names */
   int i;
   in->_fd = 14;			/* RSTS channel number for input */
   out->_fd = 13;			/* RSTS channel number for output */

   do
     {putfmt("Enter name of input (.RMC) file:\n");
      if (getfmt("%.81p", &name) == EOF) exit(YES);
      if ((i = bopen(in, &name)) < 0)
         errfmt("? Can't open input file: %p, error code %i.\n", &name, i);}
   while (i < 0);
   do
     {putfmt("Enter name of output (.SAV) file:\n");
      if (getfmt("%.81p", &name) == EOF) exit(YES);
      if ((i = bcreate(out, &name)) < 0)
         errfmt("? Can't open output file: %p, error code %i.\n", &name, i);}
   while (i < 0);
   return;}


/* romerr procedure
 * This procedure types out the ROM conflict error messages.
 */
romerr(curad)
int curad;
  {int i;
   errfmt("%% ROM conflict at address %h (hex)\n", curad, pair.address);
   errfmt("%% Original .RMC file address %o (octal), original data %h (hex)\n",
      rmcadr[pair.address], buffer[pair.address]);
   errfmt("%% Current .RMC file address %o (octal), current data %h (hex)\n",
      curad, pair.data);}


/* readerr procedure
 * This is the read error handler procedure.  Entered when you didn't get
 * as much as you expected.  If RSTS error, it will be output.  Otherwise,
 * 'file too short' will be issued.  In either case, program dies.
 */
readerr(n)
int n;
  {if (n < 0)
     {errfmt("%% RSTS error %i\n", -n);
      error("? Error reading .RMC file\n");}
   else
     {errfmt("%% Got %i bytes\n", n);
      error("? .RMC file too short\n");}}


/* writeerr procedure
 * This is the write error handler procedure.  Entered when you got non-zero
 * out of bwrite.  Program dies with an error message.
 */
writeerr(n)
int n;
  {errfmt("%% RSTS error %i\n", -n);
   error("? Error writing .SAV file\n");}
                                                                                                                                                                                                                                                                                                                                                     