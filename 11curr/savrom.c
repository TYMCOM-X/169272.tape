/* SAVROM program
 * This program translates ROM .SAV files into .ROM files.  The .SAV file
 * provides the ROM parameters in the first 1000 octal bytes.  The image
 * of the ROM itself starts at address 1000.
 *
 * The format of the .SAV file is:
 *	Bytes 0-13	Chip type and manufacturer, left justified in ASCII.
 *	Bytes 14-15	Number of ROM words (2**n).
 *	Bytes 16-17	Number of ROM data bits per word.
 *	Bytes 20-21	Starting address within ROM for ROM burner.
 *	Bytes 22-23	Last address within ROM for ROM burner.
 *	Bytes 24-25	Version number - max 8 bits.
 *	Bytes 26-75	40 character (decimal) comment field.
 *	Bytes 76-77	Default for ROM data word contents.  This value is
 *			not expected to be used by this program.
 *	Bytes 100-101	Size of .RMC file.  This value is not expected to be
 *			used by this program.
 *	Bytes starting at address 1000 octal contain ROM word data values
 *	in sequence from ROM address zero.  Data is right justified.
 *
 * The format of the .ROM file is a sequence of text lines.  The first line
 * contains up to seven fields, separated by commas.  The fields are:
 *	Field 1		Chip type and manufacturer.  Up to 12 characters,
 *			selected from the radix 50 character set (alpha
 *			characters must be upper case).  Trailing blanks
 *			should not be present.
 *	Field 2		Number of words in the ROM (2**n, n is number of
 *			address lines).  Decimal.
 *	Field 3		Number of data bits per ROM word.  Decimal.
 *	Field 4		Lowest address to burn.  Hexadecimal, upper case.
 *	Field 5		Highest ROM address to burn.  Hexadecimal, upper case.
 *	Field 6		Version number.  Unsigned decimal in the range 0-255.
 *	Field 7		Comment field.  40 (decimal) ASCII characters, copied
 *			from .SAV file verbatim.
 * Fields 4, 5, 6, and 7 may be omitted or left null.
 *
 * Lines after the first contain one or two hexadecimal upper case characters
 * (one for ROMs whose data words are 4 bits or less, two for ROMs whose data
 * words are 5 to 8 bits wide).  Each such line specifies data for one word in
 * the ROM, starting at the address specified in Field 4 of the first line.
 * There must be exactly (Field 5) - (Field 4) + 1 such lines.
 */

#include <std.h>
#include "rom.h#"

#define ADDRCHRS 5
#define WORDCHARS 16			/* Max chars in ROM word (hex) + 1 */

main()
  {FIO dot_SAV, dot_ROM;
   char c;
   struct header head;
   char *buffer;
   int i, j, n, nchars, errcode;
   char hexstart[ADDRCHRS], hexstop[ADDRCHRS];
   char data[WORDCHARS];

/*
 * Establis              ?        GJ
+g1%?	y%?                                    `            @                                     ?                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      m[  Trfmt("? Can't open output file: %p.\n", &name);}
   while (i == NULL);
   return;}


/* readerr procedure
 * This is the read error handler procedure.  Entered when you didn't get
 * as much as you expected.  If RSTS error, it will be output.  Otherwise,
 * 'file too short' will be issued.  In either case, program dies.
 */
readerr(n)
int n;
  {if (n < 0)
     {errfmt("%% RSTS error %i\n", -n);
      error("? Error reading .SAV file\n");}
   else
     {errfmt("%% Got %i bytes\n", n);
      error("? .SAV file too short\n");}}


/*
 * cvthex procedure
 * This routine converts an address (16 bits max) into upper-case hexadecimal.
 * Synopsis:
 *	cvthex(buf, addr)
 *	int addr;
 *	char *buf;
 * Buffer is assumed to be at least ADDRCHRS in length.
 */
cvthex(buf, addr)
int addr;
char *buf;
  {buf[decode(buf, ADDRCHRS-1, "%+03h\0", addr)] = '\0';
   while ((*buf = toupper(*buf)) != '\0')
      buf++;}
                                                                                 