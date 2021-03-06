$TITLE TCRUTL.PAS, last modified 4/9/84, zw
MODULE TCRUTL;
(*TYM-Pascal temp-core utility*)

(*HEADER TCRUTL.HDR*)

$SYSTEM TYPUTL.TYP
$INCLUDE TCRUTL.TYP

(*This is defined in TCRMAC.MAC*)
EXTERNAL FUNCTION _tcrfunction
  (tcr_name; tcr_opcode; tcr_address; VAR tcr_length): BOOLEAN;

PUBLIC FUNCTION tcrfun
  (name: tcr_name; opcode: tcr_opcode; buffer_address: tcr_address;
  VAR buffer_length: tcr_length): yes_no;
BEGIN
  tcrfun := _tcrfunction(name, opcode, buffer_address, buffer_length)
END.
 