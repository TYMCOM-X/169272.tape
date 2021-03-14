10	REM integer k0; is the maximum number of points this works for
20	REM	(this can be changed, it is an Arg to Allocate)
30	REM	Unfortunately, this BASIC doesn't have dynamic arrays.
40	REM	Therefore, look at the REMs for where to change DIMs
50	 k0=36
60	 REM GOSUB allocate
70	 GOSUB 510
80	PRINT "How many data points: "
90	INPUT k2
100	IF k2 < 1 GOTO 9999
110	IF k2 > k0 GOTO 80
120	FOR i=1 TO k2
130	    PRINT "Point "; i
140	    INPUT p(i,0), p(i,1)
150	    NEXT i
160	REM GOSUB makespline
170	GOSUB 2250
180	PRINT "How many Curve points: "
190	INPUT i
191 if i <> -1 goto 200
192 for i=1 to k1
193  print i;" X:"; c(0,i*4+3); c(0,i*4+2); c(0,i*4+1); c(0,i*4+0)
194  print i;" Y:"; c(1,i*4+3); c(1,i*4+2); c(1,i*4+1); c(1,i*4+0)
195  next i
196 for i=0 to k3
197  print "  p"; i; ": ("; p(i,0); ","; p(i,1); ")"
198  next i
199 goto 180
200	IF i < 1 GOTO 80
210	REM GOSUB useSpline
220	GOSUB 1010
230	GOTO 180
240	
250	REM procedure plotXY( numeric x, y )
260	REM plotXY cannot use I, k1, t0, or t4, takes coordinates X,Y
270	REM plotXY is "draw with pen down from previous point to X,Y"
280	REM since I cannot draw lines (no plotter), I'll just print coords
290	REM debug:PRINT "seg "; i; ", piece "; t0, " ("; x; ", "; y; ")"
300	PRINT " ("; x; ", "; y; ")"
310	RETURN
320	
500	
510	REM procedure allocate;	! allocates storage for at most k0 points
520	
530	REM integer k1;! the number of "segments" in the approximation;
540	REM integer k2;! number of "points" in the approximation(=k1+1)
550	REM integer k3;! one more than the number of points (=k1+2)
560	
570	REM integer k4;! indicates whether on X or Y elements (0 = x)
580	REM integer i;  ! just generally an integer variable;
590	REM integer j;  ! as above (usually means a line of an array);
600	REM real X,Y; ! used both as floating point temps, and points.;
610	REM real t0; ! was "time": this is the controlling variable;
620	REM real t4; ! was called "timeInc": step size for variable t0;
630	REM real t1,t2,t3;! numeric temps: originally Mult1,mult2,mult3
640	
650	DIM c( 1, 147 )
660	REM really: DIM c( 1, k0 *4+ 3 ) 36*4+3= 144 + 3
670	REM ! This contains the cubic equations which approximate the curve.
680	REM ! Once it is constructed, the other arrays are not used.
690	REM ! It is a function of points and inv.
700	REM ! c(xy,s *4+ d): xy=0 for x-coord, 1 for y-coord
710	REM !		s=segment number (0 to points-1)
720	REM !		d=degree of coefficient (see funck3)
730	REM ! Cubic is constructed by "makeSpline".
740	
750	DIM w( 37 )
760	REM really: DIM w( k0+1 ) 36+1
770	REM workspace when making inv or cubic
780	
790	DIM v( 37, 37 )
800	REM really: DIM v( k0+1, k0+1 ) 36+1, 36+1
810	REM the "magic" matrix needed to make cubic from points.  This is a 
820	REM function of "k1" only (and may be kept around if you like)
830	
840	DIM p( 37, 1 )
850	REM really: DIM p( k0+1, 1 ) 36+1, 1
860	REM contains all the data points (knots) for the spline.
870	REM for N in [1 .. k2]: p(N,0) is the X-coordinate, 
880	REM 			 and p(N,1) is the Y-coordinate.
890	REM p(0,?) is the "slope" of the curve at the first point.
900	REM p(k3,?) is the "slope" of the curve at the last point.
910	REM this is entirely input data, and any values are allowed.
920	
930	RETURN
940	
950	
960	REM numeric procedure docubic( integer k4, i; numeric t0 );
970	x=((c(k4,i *4+3)*t0+ c(k4,i *4+2))*t0+ c(k4,i *4+1))*t0+ c(k4,i *4+0)
980	RETURN
990	
1000	
1010	REM procedure useSpline(integer numPoints, xxx;procedure plot);
1020	REM (to plot: call this with "I" set to number of plot points desired)
1030	REM begin	numeric t0, t4, x,y; 
1040	REM 	integer i;
1050	
1060	REM used to be:  t4= 1.0 / ((numPoints div k1) + 1)
1070	 t4= k1 / i
1080	REM just 1.0 / points.per.segment since segments are (0.0 : 1.0);
1090	
1100	REM for each segment of the curve;
1110	for i= 1 to k1
1120	  REM for each piece of the segment
1130	  for t0= 0.0 to 1.0 by t4
1140	REM first calculate the Y-coord since doCubic puts results in X
1150		k4= 1
1160		 REM GOSUB doCubic
1170		 GOSUB 960
1180		  y= x
1190	REM now calculate the X-coordinate, and go plot it.
1200		k4= 0
1210		 REM GOSUB doCubic
1220		 GOSUB 960
1230		REM GOSUB plotXY
1240		GOSUB 250
1250	      next t0
1260	  next i
1270	RETURN
1280	
1290	
1300	REM procedure nCoefficients( integer k4 );
1310	REM calculate all the cubic coefficients 
1320	REM	for either X-coordinates or Y-coordinates.
1330	REM begin	integer k3, j, i;
1340	REM	numeric x;! this X has nothing to do with X/Y, its a temporary 
1350	REM do a column-vector * matrix multiply.  results to row-vector;
1360	REM matrix equivalent: w := inv * p(?,k4)
1370	
1390	for j= 0 to k3
1400		x= 0
1410		for i= 0 to k3 
1420		   x= x + v(j,i) * p(i,k4)
1430		   next i
1440		w(j)= x
1450	      next j
1460	for j= 1 to k1
1470	    c(k4,j *4+3)= (- w(j-1) +3 * w(j) -3 * w(j+1) + w(j+2))/6
1480	    c(k4,j *4+2)= (3*w(j-1) -6 * w(j) +3 * w(j+1))/6
1490	    c(k4,j *4+1)=(-3*w(j-1)	      +3 * w(j+1))/6
1500	    c(k4,j *4+0)=(   w(j-1) +4 * w(j)  +   w(j+1))/6
1510	    next j
1520	RETURN
1530	
1540	
1550	REM procedure nMatrix;
1560	REM this creates the CUBIC B-SPLINE matrix for a "k1"+1 point set of
1570	REM points.  It does this by inverting a matrix which looks like:
1580	REM -n/2  0 n/2  0   0  ...	 0
1590	REM 1/6 2/3 1/6  0   0  ...	 0
1600	REM  0  1/6 2/3 1/6  0  ...	 0
1610	REM  0   0  1/6 2/3 1/6  0  ...	 0
1620	REM  0   0   0  1/6 2/3 1/6  0...0
1630	REM ...		... ... ... ...  0
1640	REM  0		... 1/6 2/3 1/6  0
1650	REM  0		...  0  1/6 2/3 1/6
1660	REM  0		...  0 -n/2  0  n/2
1670	REM (the matrix is not in fact written down, the algorithm just
1680	REM  mimics an "invert by relaxation" and only keeps around some
1690	REM  of the diagonal values in "w".  Instead the inverse
1700	REM  is just built up in the matrix "v")
1710	
1720	REM begin	integer i, k2, j;
1730	REM	numeric t1, t2, t3;
1740	
1760	REM initialize "inverse" matrix to 6 * indentity matrix
1770	for j= 0 to k3
1780	    for i= 0 to k3
1790		v(j,i)= 0
1800		next i
1810	    next j
1820	for i= 2 to k2
1830	    v(i,i)= 6
1840	    next i
1850	REM bottom two rows and top rows were hand-calculated
1860	REM as first few "relaxes": row 0: 2/points,0,0...
1870	REM row 1: 1/points,1/k1,0,0... top row: 0,0,...0,2/points
1880	v(0,0)= 2 / k1
1890	v(k3, k3)= 2 / k1
1900	v(1,1)= 3 
1910	v(1,0)= 1 / k1 
1920	w(1)= 2
1930	t1= 1 / 2
1940	REM propogate down the matrix (0..k3), but 0 and 1 already done
1950	for j= 2 to k2
1960	    for i=0 to k3
1970		v(j,i)= v(j,i) - t1 * v(j-1,i)
1980		next i
1990	    w(j)= 4 - t1
2000	    t1= 1 / w(j)
2010	    next j
2020	
2030	 j= k3
2040	t1= 1 / w(k1)
2050	t2= t1 / w(k2) 
2060	t3= 1 / (1 - t2)
2070	REM propogate up, first last row (special pass for it only)
2080	for i=0 to k3
2090	  v(j,i)= (v(j,i) + v(k1,i)*t1 - v(k2,i)*t2) * t3
2100	  next i
2110	REM propogate up other rows (k2...1) not 0, since 0 special too.
2120	for j= k2 to 1 by -1
2130	    t1= 1 / w(j)
2140	    for i= 0 to k3
2150		v(j,i)= (v(j,i) - v(j+1,i)) * t1
2160		next i
2170	    next j
2180	REM final propogate, to top row (row 0)
2190	for i= 0 to k3
2200	    v(0,i)= v(2,i) - v(0,i)
2210	    next i
2220	RETURN
2230	
2240	
2250	REM internal r!p(point) procedure makeSpline( integer k2;
2260	REM						r!p(point) pList );
2270	REM if k2 < 2 then usererr(0,1,"Oh my, too few points.") else
2280	REM begin	integer i;
2290	
2300	REM set up the number of segments in points;
2310	k1= k2-1
2315	k3= k2+1
2320	REM ! this just reads in the points into points[1:k2, 0:1];
2330	REM presume they are already read in
2340	REM for i= 1 to k2
2350	REM    do begin 	! write down the points we were given;
2360	REM	points[i,0 point:x[pList]; 
2370	REM	points[i,1 point:y[pList]; 
2380	REM	pLis point:link[pList];
2390	REM     end;
2400	
2410	REM now set slopes at start and end (since I dont input them);
2420	REM p(0,0) and p(0,1) are start slopes (w/ respect to time);
2430	REM p(k3,0 and 1) are end slopes (w/ respect to time);
2440	for i= 0 to 1 
2450	    p(0,i)= (p(2,i) - p(1,i)) / k1
2460	    p(k3,i)= (p(k2,i) - p(k1,i)) / k1
2470	    next i
2480	
2490	REM fill in the array "inv";
2500	REM GOSUB nMatrix
2510	GOSUB 1550
2520	REM this is a function of k1, so if same, may keep old;
2530	
2540	REM create X cubic equations (k1 of them);
2550	 k4=0
2560	  REM GOSUB nCoefficients
2570	  GOSUB 1300
2580	REM create Y cubic equations (k1 of them);
2590	 k4=1
2600	  REM GOSUB nCoefficients
2610	  GOSUB 1300
2620	
2630	RETURN
2640	
9999	END
 