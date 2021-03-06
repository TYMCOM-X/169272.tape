internal string procedure Daytim( Integer UseTime );
! ----------------------------------------------------------------------;
!									;
!	Daytim		Return the time of day in the form HH:MM:SS	;
!			using 24-hour time from 00:00:00 to 23:59:59.	;
!									;
! ----------------------------------------------------------------------;
begin
    Integer T,HH;
    T _ If UseTime > 0
	 then UseTime div 1000
	 else Calli(0,calli!timer) div 60;
    HH _ T Div 3600;	T  _ T Mod 3600;
    Return( CvS(100 + HH)[2 for 2] & ":" &
	    CvS(100 + (T Div 60))[2 for 2] & ":" &
	    Cvs(100 + (T Mod 60))[2 for 2]  );
end;



define ! = "comment", calli!date = '14;
Preset!with 0,3,3,6,1,4,6,2,5,0,3,5;
	    Own integer array MonthOffset[0:11];
Preset!with "-Jan-","-Feb-","-Mar-","-Apr-","-May-","-Jun-",
	    "-Jul-","-Aug-","-Sep-","-Oct-","-Nov-","-Dec-";
	    Own string array MonTab[0:11];
Preset!with "January","February","March","April","May","June","July",
	    "August","September","October","November","December";
	    Own string array Month!names[0:11];
Preset!with "Sunday","Monday","Tuesday","Wednesday",
	    "Thursday","Friday","Saturday";
	    Own string array Weekday[0:6];

simple string procedure DateString(Integer Type);
begin
    Own Integer array R[0:3];    Integer L,T;

    T _ Calli(0,Calli!Date);		! Read current date;
    R[0] _ T mod 31; T _ T Div 31;	! Day of month  0-30;
    R[1] _ T mod 12;			! Month of year 0-11;
    R[2] _ T div 12;			! Year less 1964;
    L _ If R[2] land '3 neq 0
	then 0
	else If R[1] < 2
	    then 0
	    else 1;
    R[3] _ (3 + R[0] + MonthOffset[ R[1] ] + L + R[2] + ((3+R[2]) lsh -2) )
	    mod 7;
    R[2] _ R[2] + 1964;			! Year expressed in 4 digits;
    Return( Case Type of (
	[0] Cvs(101+R[0])[2 for 2] & MonTab[ R[1] ] & Cvs(R[2])[3 for 2],
	[1] Cvs(101+R[0])[2 for 2],
	[2] Month!names[ R[1] ],
	[3] Cvs(R[2]),
	[4] Weekday[ R[3] ],
	[else] Null
	    )
	);
end;

    