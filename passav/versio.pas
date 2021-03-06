$TITLE VERSION -- Program Version Identification from .JBVER

module version
  options special (coercions);

(*   +--------------------------------------------------------------+
     |                                                              |
     |                        V E R S I O N                         |
     |                        - - - - - - -                         |
     |                                                              |
     +--------------------------------------------------------------+
     
     ENTRY POINTS:
     
        version     This routine returns the DEC-10 standard  version
                    identification  for  a  program.  The  version is
                    taken from the  job  data  area  location  .JBVER
                    (absolute program location 137B).  It is returned
                    as  a  character  string  of  the  general   form
                    "3D(127)-2".
     
     USAGE:
     
        type VERSION_STRING = string [15];
     
        external function VERSION: VERSION_STRING;
     
     OUTPUT:
     
        VERSION     is the version identifier string described above.
                    If no version identification has been set for the
                    program,  then the returned string will simply be
                    '0'.
     
     INCLUDE FILES REQUIRED:
     
        VERSIO.INC
     
     ---------------------------------------------------------------- *)
$PAGE version

(*  Version returns a string containing the program version identifier.
    The version is taken from .JBVER, which is at absolute location 137B,
    and contains the fields:

	bits 0-2:    "last modified by"
	bits 3-11:   major version number
	bits 12-17:  minor version number
	bits 18-35:  edit number					*)

type version_string = string [15];

public function version: version_string;

type
    version_word = packed record
	mod_code: 0..7;
	major_version: 0..777b;
	minor_version: 0..77b;
	edit_number: 0..777777b
    end;

var
    version_ptr: ^ version_word;

type oct = 0 .. 100000b;

var step: oct;

function digit ( od: oct ): char;
begin
  digit := chr (ord ('0') + (od mod 10b));
end;

begin
  version_ptr := ptr (137b);
  with version_ptr^ do begin
    version := '';
    if major_version >= 100b then
      version := version || digit (major_version div 100b);
    if major_version >= 10b then
      version := version || digit (major_version div 10b);
    version := version || digit (major_version);
    if minor_version > 26 then
      version := version || chr (ord (pred ('A')) + (minor_version div 26));
    if minor_version <> 0 then
      version := version || chr (ord (pred ('A')) + (minor_version mod 26));
    if edit_number <> 0 then begin
      version := version || '(';
      step := 100000b;
      while step <> 0 do begin
	if edit_number >= step then
	  version := version || digit (edit_number div step);
	step := step div 10b;
      end;
      version := version || ')';
    end;
    if mod_code <> 0 then
      version := version || '-' || digit (mod_code);
  end;
end.
  