$WIDTH=100
$LENGTH=55
$TITLE asm.pas, last modified 3/10/83, zw
PROGRAM Z80_assembler;

CONST
  null_file = NILF;
  null = '';
  carriage_return_line_feed = CHR(13) || CHR(10);
  succeed = TRUE;
  yes = TRUE;
  fail = FALSE;
  no = FALSE;

TYPE
  file_name = FILE_NAME;
  text_file = TEXT;
  succeed_or_fail = BOOLEAN;
  yes_or_no = BOOLEAN;
  parse_record = RECORD
    symbol : STRING [6]
    END;
  expression_record = RECORD
    next : ^expression_record
    END;
  expression = ^expression_record;

VAR
  terminal : text_file := null_file;

$PAGE open and close files, set up terminal
FUNCTION Open_file(VAR a_file : text_file; name : file_name; mode : STRING [*]) : succeed_or_fail;
  (*try to open a file for specified mode*)
  BEGIN
    Open_file := succeed;
    IF name = 'TTY' THEN a_file := TTY
    ELSE BEGIN
      IF mode = 'READ' THEN RESET(a_file, name)
      ELSE IF mode = 'WRITE' THEN REWRITE(a_file, name)
      ELSE IF mode = 'APPEND' THEN REWRITE(a_file, name, [PRESERVE])
      ELSE Open_file := fail
      END
    EXCEPTION
      IO_ERROR : Open_file := fail
    END;

PROCEDURE Close_file(VAR a_file : text_file);
  (*close a file*)
  BEGIN
    CLOSE(a_file);
    a_file := null_file
    EXCEPTION
      IO_ERROR : RETURN
    END;

PROCEDURE Set_up_terminal;
  (*set up terminal for input and output*)
  BEGIN
    OPEN(TTY);
    REWRITE(TTYOUTPUT);
    terminal := TTY
    EXCEPTION
      IO_ERROR : STOP
    END;

$PAGE basic text file input and output, check for end of file
FUNCTION End_of_file(VAR a_file : text_file) : yes_or_no;
  (*check if end of a file*)
  BEGIN
    End_of_file := EOF(a_file)
    END;

PROCEDURE Input_text(VAR input_file : text_file; VAR text : STRING [*]);
  (*input text from file*)
  BEGIN
    IF input_file = TTY THEN BEGIN
      BREAK(TTYOUTPUT);
      READLN(TTY);
      READ(TTY, text)
      END
    ELSE IF NOT End_of_file(input_file) THEN BEGIN
      READ(input_file, text);
      READLN(input_file)
      END
    EXCEPTION
      IO_ERROR : text := null
    END;

PROCEDURE Input_line(VAR input_file : text_file; VAR line : STRING [*]);
  (*input a line from file*)
  BEGIN
    Input_text(input_file, line)
    END;

PROCEDURE Output_text(VAR output_file : text_file; text : STRING [*]);
  (*output text to file*)
  BEGIN
    IF output_file = TTY THEN WRITE(TTYOUTPUT, text)
    ELSE WRITE(output_file, text)
    EXCEPTION
      IO_ERROR : RETURN
    END;

PROCEDURE Output_line(VAR output_file : text_file; line : STRING [*]);
  (*output a line to file*)
  BEGIN
    Output_text(output_file, line);
    Output_text(output_file, carriage_return_line_feed)
    END;

$PAGE general purpose sort
PROCEDURE Sort(sort_file : file_name);
  (*sort a file*)
  BEGIN
    END;

$PAGE line parser
PROCEDURE Parse_line(VAR line : STRING[*]; VAR result : parse_record);
  (*parse line to yield result*)
  BEGIN
    END;

$PAGE symbol definition
PROCEDURE Define_symbol(VAR symbol_list : text_file; symbol : STRING [*]; value : expression);
  (*define a symbolic value*)
  BEGIN
    END;

$PAGE third level, generate hexadecimal code
PROCEDURE Generate_hexadecimal_code(assembly_code, symbol_list, hexadecimal_code : file_name);
  (*generate hexadecimal code from assembly code using symbol list*)
  BEGIN
    END;

$PAGE third level, evaluate symbols in a symbol list
PROCEDURE Evaluate_symbols(symbol_list : file_name);
  (*evaluate all symbols in list*)
  BEGIN
    END;

$PAGE third level, generate symbol list
PROCEDURE Generate_symbol_list(assembly_code, symbol_list : file_name);
  (*generate a sorted symbol list from assembly code*)
  PROCEDURE Do_generate_symbol_list(VAR assembly_code, symbol_list : text_file);
    (*generate a symbol list file from assembly code file*)
    VAR line : STRING [80]; result : parse_record; address : expression;
    BEGIN (*do actual symbol list generation*)
      WHILE NOT End_of_file(assembly_code) DO BEGIN
        Input_line(assembly_code, line);
        Parse_line(line, result); Define_symbol(symbol_list, result.symbol, address)
        END
      END;
  VAR assembly_file, symbol_file : text_file;
  BEGIN (*open/close files, sort symbol list*)
    IF Open_file(assembly_file, assembly_code, 'READ') THEN BEGIN
      IF Open_file(symbol_file, symbol_list, 'WRITE') THEN BEGIN
        Do_generate_symbol_list(assembly_file, symbol_file);
        Close_file(symbol_file)
        END;
      Close_file(assembly_file)
      END;
    Sort(symbol_list)
    END;

$PAGE second level -- do actual assembly
PROCEDURE Assemble(program_name : STRING [6]);
  (*assemble a Z80 assembly code program*)
  PROCEDURE Do_assembly(assembly_code_file, symbol_list_file, hexadecimal_code_file : file_name);
    (*assemble assembly code using symbol list, output hexadecimal code*)
    BEGIN (*do actual assembly*)
      Generate_symbol_list(assembly_code_file, symbol_list_file);
      Evaluate_symbols(symbol_list_file);
      Generate_hexadecimal_code(assembly_code_file, symbol_list_file, hexadecimal_code_file)
      END;
  BEGIN (*assign file names for assembly*)
    Do_assembly(program_name || '.ASM', program_name || '.SYM', program_name || '.HEX')
    END;

$PAGE top level -- get program name then assemble program
VAR program_name : STRING [6];

BEGIN (*top level*)
  Set_up_terminal;
  Output_line(terminal, 'This is a Z80 assembler.');
  Output_text(terminal, 'Enter program name: ');
  Input_text(terminal, program_name);
  Assemble(program_name)
  END.
  