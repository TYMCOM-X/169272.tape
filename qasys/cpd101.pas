nnnnnnnnnnnnnn(*$E+*)
(*******************************************************************
: **                  PROPRIETARY INFORMATION                     **
: **                                                              **
: **  This  source code listing constitutes the proprietary pro-  **
: **  perty of TYMNET.  The recipient, by receiving this program  **
: **  listing, agrees that neither this listing nor the informa-  **
: **  tion disclosed herein nor any part thereof shall be repro-  **
: **  duced or transferred to other documents or used or dis-     **
: **  closed to others for manufacturing or for any other purpose **
: **  except as specifically authorized in writing by TYMNET.     **
: ******************************************************************
: **                   PROGRAM IDENTIFICATION                     **
: **                                                              **
: **  Version Number     : 01.02         Release Date : 12/15/86  **
: **                                                              **
: **  File Name          : cpd101.pas                             **
: **                                                              **
: **  File Description   :                                        **
: **                                                              **
: **     The routines in this file generate statistics dealing    **
: **     with the execution performance of the Concurrent Pascal  **
: **     compiler.  Printsummary is only called if option 's' has **
: **     been set.  The elapsed execution times are gathered      **
: **     irregardless of whether option 's' has been set or not.  **
: **                                                              **
: **  File Abstract      :                                        **
: **                                                              **
: ******************************************************************
: **                      MAINTENANCE HISTORY                     **
: **                                                              **
: **  Ver   Date    By   PIR/NSR         Reason for Change        **
: ** ----- -------- ---  -------- ------------------------------  **
: ** 01.02 12/15/86 PJH  1162     ADDITION OF PROPRIETARY BANNER  **
: **                                                              **
: ******************************************************************
: **                 SUBROUTINE IDENTIFICATION                    **
: **                                                              **
: **  Routine Abstract   :  Initpass                              **
: **                                                              **
: **     Initpass saves the current clock time in an array and    **
: **     generates a character to indicate the start of the       **
: **     current pass of the compiler.                            **
: **                                                              **
: **  Parameters         :                                        **
: **                                                              **
: **     Thispass - an integer indicating the current pass of     **
: **                the Concurrent Pascal compiler.               **
: **                                                              **
: ******************************************************************
: **                                                              **
: **  Routine Abstract   :  Nextpass                              **
: **                                                              **
: **     Nextpass calculates the elapsed execution time of the    **
: **     concurrent pascal compiler pass indicated by the         **
: **     parameter thispass.                                      **
: **                                                              **
: **  Parameters         :                                        **
: **                                                              **
: **     Thispass - an integer indicating the current pass of     **
: **                the concurrent pascal compiler.               **
: **                                                              **
: ******************************************************************
: **                                                              **
: **  Routine Abstract   :  Printsummary                          **
: **                                                              **
: **     Printsummary prints out a summary of the elapsed         **
: **     execution time for each pass of the Concurrent Pascal    **
: **     compiler.                                                **
: **                                                              **
: *****************************************************************)

(*$e+*)
program stats, initpass, nextpass, printsummary;
type
  pass_range = 0 .. 7;

var
  elapsed:      array[pass_range] of integer;
  pass_char:  n  array[pass_range] of char;
  pass_order:   array[pass_range] of pass_range;

initprocedure;
  begin
    pass_char[0] := 'x';
    pass_char[1] := '1';
    pass_char[2] := '2';
    pass_char[3] := '3';
    pass_char[4] := '4';
    pass_char[5] := '5';
    pass_char[6] := '6';
    pass_char[7] := '7';

    pass_order[0] := 1;
    pass_order[1] := 2;
    pass_order[2] := 3;
    pass_order[3] := 4;
    pass_order[4] := 5;
    pass_order[5] := 6;
    pass_order[6] := 0;
    pass_order[7] := 7
  end;

procedure initpass(this_pass: pass_range);
  begin
    elapsed[this_pass] := clock;
    write(tty, pass_char[this_pass]:2);  break
  end;

procedure nextpass(this_pass: pass_range);
  begin
    elapsed[this_pass] := clock - elapsed[this_pass]
  end;

procedure printsummary;
  var
    i, j: pass_range;
  begin
    writeln(tty);
    for i := 0 to 7 do
      begin
        j := pass_order[i];
        writeln(tty, 'pass ', pass_char[j], ':',
                     elapsed[j] / 1e4:7:2, ' trus')
      end
  end;

begin end.
   