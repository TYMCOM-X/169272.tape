(**************************************************************)
(*                                                            *)
(*         BBBBBBBBB     test routine      BBBBBBBBB          *)
(*                                                            *)
(**************************************************************)

module testmb options overlay ;

public procedure testb ;

begin

   rewrite( tty );

   writeln( tty, ' now in BBBBBBBBB ' ) ;

end .
  