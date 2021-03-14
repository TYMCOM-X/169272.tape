$PAGE PASSY.TYP, last modified 3/27/84, zw
$IFNOT passytyp

TYPE

symbols =
  (badsymbol, ident, intconst, realconst, stringconst, nilsy, notsy, 
  powerop, mulop, addop, relop, lparent, rparent, lbracket, rbracket, 
  comma, period, arrow, colon, becomes, semicolon, elipsis, labelsy, 
  constsy, typesy, varsy, functionsy, proceduresy, exceptionsy, 
  externalsy, publicsy, staticsy, forwardsy, optionssy, packedsy, setsy, 
  arraysy, recordsy, stringsy, filesy, precsy, programsy, modulesy, 
  datamodsy, envmodsy, beginsy, ifsy, casesy, repeatsy, whilesy, forsy, 
  withsy, loopsy, gotosy, returnsy, stopsy, iosy, exitsy, endsy, thensy, 
  elsesy, untilsy, ofsy, dosy, tosy, downtosy, otherssy, allcondsy, 
  eofsy,
  nonterminal,program_id,module_id, datamod_id, envmod_id, subr_options, 
  null_stmt, simple_stmt, goto_stmt, io_stmt, return_stmt, stop_stmt, 
  if_stmt, for_stmt, while_stmt, case_stmt, with_stmt, exit_clause, 
  until_clause, exprtree, not_op, sign_op, paren_expr, set_expr, 
  array_qualifier, field_qualifier, ptr_qualifier, func_qualifier, 
  type_decl, packed_type,set_type, string_type, pointer_type, subr_type, 
  array_type, pk_array_type, record_type, file_type, parm_list, 
  var_parm_decl, value_parm_decl, const_id_decl, var_id_decl, 
  type_id_decl, id_list, field_id_decl, variant_part, tag_field, 
  variant_case, range_list, declaration, label_declaration, 
  const_declaration, var_declaration, type_declaration, cond_declaration, 
  subr_decl, starsy, io_arg  );

symbol_set = SET OF badsymbol .. nonterminal;

operator = ( mul, rdiv, idiv, expon, imod, andop, andifop, plus, minus,
  orop, orifop, catop, leop, ltop, gtop, geop, eqop, neop, inop, readsy,
  writesy, readlnsy, writelnsy, readrnsy, writernsy, getstrsy, putstrsy,
  noop );

$ENABLE passytyp
$ENDIF
  