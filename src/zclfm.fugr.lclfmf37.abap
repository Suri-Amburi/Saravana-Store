*&---------------------------------------------------------------------*
*&      Form  SETUP_TABLE_REDUN
*&---------------------------------------------------------------------*
*       Sets up table REDUN.
*----------------------------------------------------------------------*
form setup_table_redun
     using    value(p_multi_class)
              value(p_multi_obj)
              value(p_table)
              value(p_change_subsc_act)
     changing p_title.

  data: l_varklart like tcla-varklart.


  refresh redun.
  refresh redun1.
  call function 'CLOB_SELECT_TABLE_FOR_CLASSTYP'
       exporting
            classtype      = rmclf-klart
            spras          = syst-langu
       importing
            variant_klart  = l_varklart
       tables
            itable         = redun
       exceptions
            no_table_found = 01.
  if syst-subrc ne 0.
    message e521 with p_table.
  endif.

* change mode: remove objects not allowed to change.
  if g_cl_ta = kreuz.
    if classif_status = c_change.
      delete redun where tracl <> space.
      read table redun index 1.
      if sy-subrc ne 0.
        message e502 with rmclf-klart.
      endif.
    endif.
  endif.

  read table redun index 1.
  if p_multi_obj is initial.
    if redun-dynnr2 is initial.
      d5xx_dynnr      = dynp0299.
    else.
      d5xx_dynnr      = redun-dynnr2.
    endif.
    if redun-dynnr3 is initial.
      redun-dynnr3    = dynp0399.
    endif.
    if redun-dynnr4 is initial.
      redun-dynnr4    = dynp0499.
    endif.
    if redun-obtxt is initial.
      message s548 with p_table syst-langu.
    else.
      strlaeng = strlen( redun-obtxt ).
      redun-objtype = redun-obtxt.
      p_title = redun-obtxt.
      modify redun index 1.
    endif.
  else.
    delete redun where obtab = 'KONDH'.
    read table redun index 1.
  endif.

* append 'class'
  clear redun.
  redun-obtxt   = text-500.
  redun-objtype = text-300.
  redun-mfkls   = p_multi_class.

  case p_change_subsc_act.
    when kreuz.
      redun-aediezuord = kreuz.
    when konst_y.
      clear redun-aediezuord.
      change_subsc_act = kreuz.
    when others.
      clear redun-aediezuord.
  endcase.
  append redun.

  sort redun by obtab.
  if g_zuord  eq c_zuord_4.
*   and tcd_stat eq kreuz.
    loop at redun.
      if redun-tracl = kreuz.
        redun-showo = kreuz.
        modify redun.
      else.
        redun1-index = syst-tabix.
        append redun1.
      endif.
    endloop.
  endif.

endform.                               " SETUP_TABLE_REDUN
