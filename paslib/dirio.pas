$PAGE directory I/O interfaces
module dirio
  options special(word);

$include lib.typ
$include blkio.inc
$PAGE rd_dir
public procedure rd_dir ( var f: library;
                         dir_index: dir_idx;  (* directory pointer *)
                          var entry: directory_entry; (* entry record *)
                        var err: errcode );

(* This reads the indexed directory entry and returns it. Error
   if the index is past the last directory entry  *)

var addr : address;

begin
  if dir_index > f.last_dir then err := bad_diridx

  else begin
    addr := (dir_index-1) div dirs_per_blk + 1;  (* block address of entry *)

    if f.dir_buf_loc <> addr then rddirblk (f, addr, err);

    if err = lib_ok then
      entry := f.dir_buffer.entry[dir_index - (addr-1) * dirs_per_blk]
    end
end;  (* rd_dir *)
$PAGE wr_dir
public procedure wr_dir ( var f: library;
                       dir_index: dir_idx;  (* directory pointer *)
                          entry: directory_entry; (* entry to write *)
                          var err: errcode );

(* This procedure writes over the indexed directory entry and flushes
   the dir buffer. If index > f.last_dir then the last_dir is 
   updated    *)

var addr : address;

begin
  if dir_index > (num_dir_blks*dirs_per_blk) then err := bad_diridx 

  else begin
    addr := (dir_index-1) div dirs_per_blk + 1;

    if f.dir_buf_loc <> addr then rddirblk (f, addr, err);

    if err = lib_ok then begin
      f.dir_buffer.entry[dir_index - (addr-1) * dirs_per_blk] := entry;
      wrdirblk ( f, err);


      if ((dir_index > f.last_dir) and (err = lib_ok)) then
        f.last_dir := dir_index
    end
  end
end;  (* wr_dir *)
$PAGE find_dir
public function find_dir ( var f: library;
                    seg_name: name_type; (* entry to find *)
                      var dir_index: dir_idx  (* index of find *)
                                ): boolean; (* true if successful find *)

(* This searches for the segname directory entry and returns its index.
   The boolean function value is an indicator of the success of the
   search. The search begins at dir_index+1     *)


$PAGE equal function
  function equal ( name1,
               name2: name_type ): boolean;
  (* Returns TRUE if name1 matches name2. Name1 may use wildcarding. *)

function match (str1,str2: packed array[1..*] of char): boolean;

var i,j: word;

begin
  match := true;

  if index(str1, '*') = 0 then
    for i := 1 to upperbound (str1) do
      exit if not((str1[i]=str2[i]) orif (str1[i] = '?')) do match := false

  else if verify (str1, ['*','?',' ']) <> 0 then begin
    for i := 1 to (index(str1,'*')-1) do
      exit if not((str1[i]=str2[i]) orif (str1[i] = '?')) do match := false;

    j := index (str2,' ', upperbound(str2)+1) - 1;

    for i := (index(str1,' ',upperbound(str1)+1)-1) downto (index(str1,'*')+1) do begin
      exit if not((str1[i]=str2[j]) orif (str1[i] = '?')) do match := false;
      j := j-1
    end
  end
end;

begin
  equal := (match(name1.name, name2.name) and match(name1.ext, name2.ext))
end;
$PAGE findmainline

var idx : dir_idx;
    entry : directory_entry;
    err : errcode;

begin
  find_dir := false;
  idx := dir_index;
  err := lib_ok;

  while ((find_dir = false) and (idx < f.last_dir)) do begin
    idx := idx + 1;
    rd_dir ( f, idx, entry, err );

  exit if err <> lib_ok;

    find_dir := equal ( seg_name, entry.file_seg )
  end;

  if find_dir then dir_index := idx
end. (* find_dir *)
     