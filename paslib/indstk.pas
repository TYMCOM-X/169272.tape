$LENGTH 44
$TITLE INDSTK Stack manipulation routines for INDFOR
module INDSTK;
(*$Y20
$HEADER INDSTK.HDR
*)

(*$X10
$OPTIONS NOSOURCE
*)
$INCLUDE INDENT.TYP
(*$X10
$OPTIONS SOURCE
*)
(*$X10
$OPTIONS NOSOURCE
*)
$INCLUDE INDSTK.INC
(*$X10
$OPTIONS SOURCE
*)

static var
  STK_ARRAY: array [1..STK_MAX] of STK_REC;
  STK_PTR: 0..STK_MAX;



public procedure STK_INIT;

(* STK_INIT initializes the stack. Merely set the stack pointer to zero. *)

  begin
  STK_PTR := 0
  end (* procedure STK_INIT *);
$PAGE PUSHERS routines to push things onto stack
public procedure MARK (HOW: STK_FLAG);

(* MARK saves the current minimum indentation CUR_IND and the flag passed
   in HOW on the stack, without changing CUR_IND. *)

  begin
  STK_PTR := STK_PTR + 1;
  with STK_ARRAY[STK_PTR] do
    begin
    STK_MARK := HOW;
    STK_IND := CUR_IND
    end;
  TOP_FLAG := HOW			(* lets FORMAT know former context *)
  end (* procedure MARK *);

public procedure PUSH (HOW: STK_FLAG);

(* PUSH works just like mark, except CUR_IND is ticked a quantum. *)

  begin
  MARK (HOW);
  CUR_IND := CUR_IND + QUANTUM
  end (* procedure PUSH *);

public procedure NEW_LEVEL (HOW: STK_FLAG);

(* NEW_LEVEL also calls MARK, but sets CUR_IND to line up to THIS_TOKEN. *)

  begin
  MARK (HOW);
  CUR_IND := LIN_INDENT + TOK_IND
  end (* procedure NEW_LEVEL *);
$PAGE POPPERS routines to pop the stack
public procedure POP_WHILE (FLAGS: FLAG_SET);

(* POP_WHILE will pop items from the stack until the top of the stack is
   not in the set FLAGS. *)

  begin
  while (STK_PTR > 0) andif
    (STK_ARRAY[STK_PTR].STK_MARK in FLAGS) do
    begin
    CUR_IND := STK_ARRAY[STK_PTR].STK_IND;
    STK_PTR := STK_PTR - 1;
    if STK_PTR > 0 then
      TOP_FLAG := STK_ARRAY[STK_PTR].STK_MARK
    end
  end (* procedure POP_WHILE *);

public procedure POP_UNTIL (FLAGS: FLAG_SET);

(* POP_UNTIL pops items from the stack until an item has been popped
   whose STK_MARK field is in FLAGS. *)

  begin
  while STK_PTR > 0 do
    begin
    TOP_FLAG := STK_ARRAY[STK_PTR].STK_MARK;
    CUR_IND := STK_ARRAY[STK_PTR].STK_IND;
    STK_PTR := STK_PTR - 1;
    exit if TOP_FLAG in FLAGS
      do if STK_PTR > 0 then
	TOP_FLAG := STK_ARRAY[STK_PTR].STK_MARK
    end
  end (* procedure POP_UNTIL and module *).
  