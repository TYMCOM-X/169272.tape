program test5;

var a: 0..27;

external procedure extproc (boolean; char);

procedure fproc (s,f: char); forward;

procedure gproc (a,b: char); forward;

procedure proc (a: boolean; char);
 var b: char;

 function fact (x: integer): integer;
  begin
   if x <= 1 then fact := 1
     else fact := x * fact (x - 1)
  end;

 var c: char := 'a';
 static var c2: char := 'b';
 begin
  return
 end;

public function fun (var x: boolean): char;
 external var b: 0..2;
 begin
  return
 end;

procedure fproc (s,f: char);
 begin
  return
 end;

procedure gproc (a,c: char);
 begin
  stop
 end;

public procedure f2proc; forward;

procedure a;
 var this_is_a: (mon, tues, wed);
 begin
  stop
 end;

begin
  writeln (a)
end.
    