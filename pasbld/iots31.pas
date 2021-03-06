program iots31;

type
  intfile = file of integer;
  vices = (yogurt, whippedcream, leather, tobacco, alcohol,
	   ribs, hoses, s_and_m, coffee, bondage, mirrors,
	   married, onion_dip, feta_cheese, animals, massage );
  viceset = set of vices;
  foobar = record
    name: string[40];
    phone: integer;
    kinks: viceset
    end;
  foofile = file of foobar;

const
  vice_name: array [vices] of string[40] :=
    ( 'Yogurt', 'Whipped cream', 'Leather', 'Tobacco', 'Alcohol',
      'Ribbed ones', 'Hoses', 'S & M', 'Coffee', 'Bondage', 'Mirrors',
      'Danger -- married', 'Onion dip', 'Feta cheese', 'Animals', 'Massage');

var
  fetishees: foofile;
  f, g: text;
  newname: string[40];
  newvice: vices;
  newsickie: viceset;
  newphone: integer;
  fname: string[50];

begin
  open (f, 'tty:');
  rewrite (g, 'tty:');
  write (g, 'Enter fetish file:'); break (g); readln (f);
  read (f, fname);
  if fname = '' then stop;
  reset (fetishees, fname);
  if eof (fetishees) then writeln (g, 'Can''t get it.')
  else begin
    write (g, 'File ', filename (fetishees), ' -- ');
    writeln (g, extent (fetishees):6, ' records processed.');
    while not eof (fetishees) do with fetishees^ do begin
      write (g, 'Name: ', name, '  Phone: ');
      if (phone div 10000000) > 0 then
	write (g, (phone div 10000000): 3, '-');
      writeln (g, ((phone mod 10000000) div 10000): 3, '-', (phone mod 10000):4);
      for newvice := minimum (vices) to maximum (vices) do
	if newvice in kinks then begin
	  write (g, '        ');
	  writeln (g, vice_name [newvice])
	  end;
      get (fetishees)
      end;
    close (fetishees);
    end;
  update (fetishees, fname, [randio,preserve]);
  if extent (fetishees) = 0 then writeln (g,'File empty.');
    seek (fetishees, extent (fetishees) + 1 );
    write (g, 'enter name:'); break (g); readln (f);
    read (f, newname);
    write (g, 'Phone:'); break (g); readln (f);
    read (f, newphone);
    newsickie := [];
    for newvice := minimum (vices) to maximum (vices) do begin
      write (g, vice_name [newvice], ' ?'); break (g); readln (f);
      if eoln (f) orif (uppercase (f^) = 'Y') then
	newsickie := newsickie + [newvice]
      end;
    with fetishees^ do begin
      name := newname;
      phone := newphone;
      kinks := newsickie
      end;
    put (fetishees);
    close
end.
    