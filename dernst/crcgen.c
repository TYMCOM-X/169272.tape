unsigned short crctbl [256];


crcgen (polybits){
  /* This program generates the CRC table for a polynomial for Tymshare engine.
	   SEG A.DATA		;by Mark Akselrod
  PLNM	   WC  18005		;CODE POLYNOMIAL HERE
  TABLE    HS  256
 
	   SEG A.CODE
 
  START    XR  R1,R1
  LOOP	   EXHR R2,R1
  LOOP1    JFFO R2,LOOP2
	   J	LOOP3
  LOOP2    LIS	R5,0F
	   SR	R5,R3
	   JLFS LOOP3
	   L	R4,PLNM
	   SLL	R4,0,R5
	   XR	R2,R4
	   JBS	LOOP1
  LOOP3    STH	R2,TABLE,R1,R1
	   AIS	R1,1
	   CHI	R1,0FF
	   JLE	LOOP
	   JAL	R10,CRASH
	   HC	0,0
  */

unsigned r2,r3;
int r1,r5;


for(r1 = 0; r1 <= 255; r1++){
	r2 = r1 << 16;
	while(r2 != 0){
		r3 = r2;
		for(r5 = 7 ;(r3 & 0x800000) == 0; r5--)
			r3 = r3 << 1;
		if (r5 < 0) break;
		r2 = r2 ^ (polybits << r5);
		};
	crctbl[r1] = r2;
};

}  /* crcgen function */
  