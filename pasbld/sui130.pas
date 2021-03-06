
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 130*)
(*TEST 6.5.1-1, CLASS=CONFORMANCE*)
(* Here is included two examples from the Pascal Standard.
  The first is from section 6.4.7, and consists of legal type
  declarations. The second is from section 6.5.1, and consists
  of legal variable declarations.
  The compiler fails if the program does not compile. *)
program t6p5p1d1;
type
   count    = integer;
   range    = integer;
   colour   = (red,yellow,green,blue);
   sex      = (male,female);
   year     = 1900..1999;
   shape    = (triangle,rectangle,circle);
   card     = array[1..80] of char;
   str      = file of char;
   angle    = real;
   polar    = record
                  r : real;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

                  theta : angle
              end;
   person   = ^ persondetails;
   persondetails = record
            name, firstname : str;
            age : integer;
            married : boolean;
            father,child,sibling : person;
            case s:sex of
               male   : (enlisted,bearded : boolean);
               female : (pregnant : boolean)
            end;
   tape     = file of persondetails;
   intfile  = file of integer;
var
   x,y,z    : real;
   i,j      : integer;
   k        : 0..9;
   p,q,r    : boolean;
   operator : (plus,minus,times);

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   a        : array[0..63] of real;
   c        : colour;
   f        : file of char;
   hue1,hue2 : set of colour;
   p1,p2    : person;
   m,m1,m2  : polar;
   pooltape : array[1..4] of tape;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #130');
   writeln(' PASS...6.5.1-1')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   