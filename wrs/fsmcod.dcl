forward external record!class fsm ( integer state0, state );

forward external record!pointer (fsm) procedure makFsm( 
			integer array equivs;
			reference record!pointer (any!class) find );

forward external record!pointer (any!class) procedure useFsm(
			record!pointer (fsm) state;
			reference integer count, bytepointer );

forward external record!pointer (any!class) procedure useFst(
			record!pointer (fsm) state;
			reference string scanOut );

 