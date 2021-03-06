/* ROM.H
 * Header file for ROM processing programs
 */

#define ORG 01000		/* real data start address in .RMC file */
#define LABELSIZE 12		/* number of bytes for label - 12 ASCII chars
				   but limited to those in the RAD50 char set */
#define COMMENTSIZE 40		/* max number of chars for comment field */

struct header
  {char label[LABELSIZE];
   int romsize;
   int wordsize;
   int start;
   int stop;
   int version;
   char comment[COMMENTSIZE];
   int def;
   int filesize;};
       