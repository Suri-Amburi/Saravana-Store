*&---------------------------------------------------------------------*
*&      Form  SETUP_TABLE_EXPFSTATUS1
*&---------------------------------------------------------------------*
*       Adjust menue depending on input status when
*       starting (!) application.
*       P_STATUS: mode change, display, ...
*----------------------------------------------------------------------*
form setup_table_expfstatus1
     using    p_status.

  refresh ex_pfstatus1.

  if g_zuord = c_zuord_0.
    ex_pfstatus1-func = ok_cls_stack.
    append ex_pfstatus1.
  endif.

  if p_status = c_display.

    ex_pfstatus1-func = okloes.
    append ex_pfstatus1.
    ex_pfstatus1-func = okneuz.
    append ex_pfstatus1.
    ex_pfstatus1-func = oksave.
    append ex_pfstatus1.
    ex_pfstatus1-func = okstat.
    append ex_pfstatus1.
    ex_pfstatus1-func = okstcl.
    append ex_pfstatus1.

  endif.

endform.                               " SETUP_TABLE_EXPFSTATUS1
