Received: from tymix.Tymnet by B39.Tymnet; Thu, 27 Aug 87 0:42:04 PDT
Received: by tymix.Tymnet (5.51/4.7) id AA11946; Thu, 27 Aug 87 00:47:24 PDT
Received: from tymix.Tymnet by hobbes.Tymnet.com (3.2/SMI-3.2) id AA23408; Thu,
	27 Aug 87 00:47:13 PDT
Received: by tymix.Tymnet (5.51/4.7) id AA11939; Thu, 27 Aug 87 00:47:17 PDT
Received: by billp.unet.uucp (3.2/SMI-3.0DEV3SLAVE1) id AA10747; Wed, 26 Aug 87
	20:22:05 PDT
Return-path: <unet!billp@tymix.Tymnet> 
From: unet!billp (Bill W. Putney) 
Date: Wed, 26 Aug 87 20:22:05 PDT 
To: :wrs@tymix 
Message-id: <8708270322.AA10747@billp.unet.uucp> 
Subject: "tone generator driver XTAL MATRIX"... 

/*
 * tone generator driver
 */

#define XTAL	(14.31818e6)
#define MATRIX	(XTAL/7.0)
#define SAMPLE	(MATRIX/256.0)
#define	MAXBUF	((long) (SAMPLE))

char	sin[] = {
	0	/* sine table */
};

char	buf[MAXBUF];

int				/* size of composite waveform */
tg_compile(buf, f1, f2)
char buf[];
int f1, f2;
{
	register unsigned short i1, i2, t1, t2;
	register char *b;
	i1 = f1 ? (f1 << 8) / MAXBUF : 0;
	t1 = 0;
	i2 = f2 ? (f2 << 8) / MAXBUF : 0;
	t2 = 0;
	for (b=buf; b<buf+MAXBUF; t1+=i1, t2+=i2)
		*b++ = sin[t1>>8] + sin[t2>>8];
	return MAXBUF;
}

main()
{
	int i;
	printf("\007start\n");
	for (i=1000; i; --i)
		tg_compile(buf, 641, 1633);
	printf("\007stop\n");
}
    