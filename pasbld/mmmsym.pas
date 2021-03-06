module mmmsym;

$SYSTEM MMSSYM.TYP
$SYSTEM MMSMDL.TYP

external var
  lastsym: symptr;
  lastmod: modptr;
  lastarea: areaptr;
  currid: mdlid;

public function find (t: namekind; p: ^pnode): boolean;

(* FIND does a name lookup.  The result is returned in one of the public
   pointers LASTAREA, LASTMOD, or LASTSYM.  We need a program pointer
   since USE uses the NEWMDL block, while others use the CURRMDL block. *)

var
  n: nameptr;

begin
n := p^.ntree;
while (n <> nil) andif (currid <> n^.text) do
  if n^.text < currid then n := n^.right
  else n := n^.left;

if n = nil then find := false
else begin				(* make sure kind is right *)
  while (n <> nil) andif (currid = n^.text) andif (t <> n^.kind) do
    if n^.kind < t then n := n^.right
    else n := n^.left;
  
  if (n = nil) orif (n^.text <> currid) then find := false
  else begin
    find := true;
    case t of
      areaname: lastarea := n^.aptr;
      modname: lastmod := n^.mptr;
      symname: lastsym := n^.sptr
      end
    end
  end
end (* function find *).
  