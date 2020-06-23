*----------------------------------------------------------------------*
*   INCLUDE LMGD1F2H                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  INIT_TC_LONGTEXT
*&---------------------------------------------------------------------*
*       Initialisieren des TAbleControls auf den Langtextbildern
*       TF 4.6A
*----------------------------------------------------------------------*
*  TF 4.6A
*  TableControl für Tabelle der gepflegten Sprachen initialisieren
*----------------------------------------------------------------------*
FORM INIT_TC_LONGTEXT.

  data: tcline like tc_longtext-top_line.

  describe table lang_tc_tab_tc lines tc_longtext-lines.

  CALL FUNCTION 'GET_TC_LONGTEXT_PARAMS'
       IMPORTING
            TC_LONGTEXT_TOP_LINE_OUT = tc_longtext-top_line.

  tc_longtext_top_line = tc_longtext-top_line.
  refresh control 'TC_LONGTEXT' from screen sy-dynnr.
  tc_longtext-top_line = tc_longtext_top_line.

  if actioncode = 'TEAN' or actioncode = 'TELO'.
*===Bei Text Anlegen oder Ändern========================================
    if tc_longtext-lines <= tc_longtext_height.
*     Es sind weniger Sprachen gepflegt als angezeigt werden können
      tc_longtext-top_line = 1.
    else.
*     Es sind mehr Sprachen gepflegt als angezeigt werden können
      tcline =  tc_longtext-top_line + tc_longtext_height - 1.
      if tc_longtext_markedline < tc_longtext-top_line.
        tc_longtext-top_line = tc_longtext_markedline.
      elseif tc_longtext_markedline > tcline.
        tc_longtext-top_line = tc_longtext_markedline
                             - tc_longtext_height
                             + 1.
      endif.
*      tcline = tc_longtext-top_line + tc_longtext_height - 1.
*      if tcline > tc_longtext-lines.
*        tc_longtext-top_line = tc_longtext-lines
*                             - tc_longtext_height
*                             + 1.
*      endif.
    endif.
  endif.

  if tc_longtext-top_line > tc_longtext-lines.
    tc_longtext-top_line = 1.
  endif.
  tc_longtext_top_line = tc_longtext-top_line.

ENDFORM.                               " INIT_TC_LONGTEXT
