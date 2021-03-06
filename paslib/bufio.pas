MODULE bufio;
(*buffered INPUT and OUTPUT*)

$SYSTEM setup

$INCLUDE bufio.typ

PUBLIC PROCEDURE put_buf; FORWARD;
(*write buffer to OUTPUT file*)

PUBLIC PROCEDURE put_ch(ch: CHAR); FORWARD;
(*write character to OUTPUT file*)

PUBLIC PROCEDURE put_str(str: STRING[o_buf_siz]); FORWARD;
(*write string to OUTPUT file*)

PUBLIC PROCEDURE get_buf; FORWARD;
(*read buffer from INPUT file*)

PUBLIC PROCEDURE get_ch; FORWARD;
(*read character from INPUT file*)

PUBLIC VAR ch: CHAR := new_ch;
(*current character set by get_ch*)

PUBLIC VAR lin_pos, chr_pos: INTEGER;
(*line and character position numbers*)

VAR
i_buf: RECORD buf: STRING[i_buf_siz]; csr: 0 .. i_buf_siz + 2 END;
o_buf: RECORD buf: STRING[o_buf_siz] END;

PROCEDURE put_buf;
BEGIN (*write buffer to OUTPUT file*)
  WITH o_buf DO BEGIN
    WRITELN(OUTPUT, buf); BREAK(OUTPUT); buf := ''
  END
END;

PROCEDURE put_ch(ch: CHAR);
BEGIN (*write character to OUTPUT file*)
  IF LENGTH(o_buf.buf) + 1 > o_buf_siz THEN put_buf;
  o_buf.buf := o_buf.buf || ch
END;
  
PROCEDURE put_str(str: STRING[o_buf_siz]);
BEGIN (*write string to OUTPUT file*)
  IF LENGTH(o_buf.buf) + LENGTH(str) > o_buf_siz THEN put_buf;
  o_buf.buf := o_buf.buf || str
END;

PROCEDURE get_buf;
BEGIN (*read buffer from INPUT file*)
  WITH i_buf DO BEGIN
    rd_lin(buf); csr := 0; lin_pos := lin_pos + 1; chr_pos := 0
  END
END;

PROCEDURE get_ch;
BEGIN (*read character from INPUT file*)
  IF ch <> end_ch THEN BEGIN
    IF ch = new_ch THEN BEGIN lin_pos := 0; get_buf END
    ELSE IF SUCC(i_buf.csr) > (LENGTH(i_buf.buf) + 1) THEN get_buf;
    IF end_input THEN ch := end_ch
    ELSE WITH i_buf DO BEGIN
      csr := SUCC(csr); chr_pos := chr_pos + 1;
      IF csr > LENGTH(buf) THEN ch := ' ' ELSE ch := buf[csr]
    END
  END
END.
 