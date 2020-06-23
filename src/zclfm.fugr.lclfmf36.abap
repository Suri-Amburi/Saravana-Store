*&---------------------------------------------------------------------*
*&      Form  SETUP_TABLE_TABAUSW
*&---------------------------------------------------------------------*
*       Sets up the table with selected object types
*       (objects of a class).
*----------------------------------------------------------------------*
form setup_table_tabausw
     changing p_lines.

  describe table tabausw lines p_lines.
  if p_lines = 0.
    loop at redun.
      tabausw-zaehl = syst-tabix.
      tabausw-obtyp = redun-objtype.
      tabausw-kreuz = kreuz.
      tabausw-texto = redun-obtxt.
      append tabausw.
    endloop.
    describe table tabausw lines p_lines.
  else.
    sort tabausw by zaehl.
  endif.

endform.                               " SETUP_TABLE_TABAUSW
