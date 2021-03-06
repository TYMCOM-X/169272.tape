$WIDTH=100
$LENGTH=55
$TITLE UTLMTH.PAS, last modified 11/29/83, zw
MODULE utlmth OPTIONS SPECIAL(WORD);
(*TYM-Pascal miscellaneous mathematical functions*)

$HEADER UTLMTH.HDR

$PAGE ngm, nlm, gcd, int_bits

PUBLIC FUNCTION ngm(a, b: MACHINE_WORD): MACHINE_WORD;
(*returns the "next greater multiple".  Ngm(a,b) is defined as the
  smallest n, such that n >= a and n | b (n is divisible by b)*)
BEGIN
  ngm := ((a + b - 1) DIV b) * b
END;

PUBLIC FUNCTION nlm(a, b: MACHINE_WORD): MACHINE_WORD;
(*returns the "next lower multiple".  Nlm(a,b) is defined as the
  smallest n, such that n <= a and n | b (n is divisible by b)*)
BEGIN
  nlm := (a DIV b) * b
END;

PUBLIC FUNCTION gcd(a, b: MACHINE_WORD): MACHINE_WORD;
(*GCD(a,b) is the greatest common divisor of A and B*)
VAR c: MACHINE_WORD;
BEGIN
  gcd := a; c := b;
  WHILE c <> gcd DO IF c > gcd THEN c := c - gcd ELSE gcd := gcd - c
END;

PUBLIC FUNCTION int_bits(x: MACHINE_WORD): INTEGER;
(*calculate the number of bits required to represent an integer
  in twos-complement notation.  The formula for this is
  int_bits(n) = ceil(log2(x + 1))     , if n > 0
	      = 1                     , if n = 0
	      = ceil(log2(abs(x))) + 1, if n < 0
  Note that we assume a machine word is the largest integer representation*)
VAR t: MACHINE_WORD;
BEGIN
  IF x >= 0 THEN BEGIN int_bits := 1; t := x END
  ELSE BEGIN int_bits := 2; t := - (x + 1) END;
  WHILE t > 1 DO BEGIN   t := t DIV 2; int_bits := int_bits + 1 END
END.
   