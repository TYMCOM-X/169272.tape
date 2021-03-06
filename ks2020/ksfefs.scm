File 1)	DSK:KSFEFS.M02	created: 1222 31-JAN-86
File 2)	DSK:KSFEFS.M03	created: 0041 04-FEB-86

1)1	; is guarenteed to be written starting at FPFEFS+1; if it isn't,
1)	; the preboots program (BOTLOD) must be changed.
1)	;Accumulator names
****
2)1	; is guarenteed to be written starting at FBOOTB; if it isn't,
2)	; the preboots program (BOTLOD), MONBTS and REFSTR must be changed.
2)	;Accumulator names
**************
1)2	;The preboots program (BOTLOD) expects FPFEFS to be 10.
1)	fpfefs==10				;Start of front end file system
1)	lefefs==100				;Length of front end file system
1)	pag:	block	1000
****
2)2	;The preboots pro gram (BOTLOD) expects FBOOTB to be 3.
2)	fbootb==3				;Start of bootstrap program
2)	; fpfefs==<cyl*3>			;Start of front end file system
2)	fbootp==100				;Length of front end file system
2)	pag:	block	1000
**************
1)3		movei	a,fpfefs*4		; First page number * blocks/page
1)	;;;	hrli	a,100000	; TOPS-20 does this for some reason.
1)		movem	a,pag+200+101		; Store for 8080.
1)		call	lbtda
1)		movem	a,pag+200+103		; Store for 8080.
1)		movei	a,lefefs*4		; Last page number * blocks/page
1)		movem	a,pag+200+102		; Store for 8080.
****
2)3	;;;	movei	a,fpfefs*4		; First page number * blocks/page
2)		call	pgscyl			; get # pages per cylinder
2)		imuli	a,3*4			; use cyl #3, *4 convert to blocks
2)	;;;	hrli	a,100000	; TOPS-20 does this for some reason.
2)		movem	a,pag+200+101		; Store for PDP-10.
2)		call	lbtda
2)		movem	a,pag+200+103		; Store for 8080.
2)		movei	a,fbootp*4		; FE file length * blocks/page
2)		movem	a,pag+200+102		; Store for 8080.
**************
