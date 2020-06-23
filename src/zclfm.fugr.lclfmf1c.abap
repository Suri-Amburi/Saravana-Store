*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_FUNCTIONS_OBJS_CL
*&---------------------------------------------------------------------*
*       Set Menu in screens used in clfm-objects-classification.
*----------------------------------------------------------------------*
form exclude_functions_objs_cl
     changing l_menu.

  if g_46_ta <> space.
    refresh ex_pfstatus.
    refresh ex_pfstatus1.

    if tcd_stat = space.
      ex_pfstatus-func = okloes.
      append ex_pfstatus.
      ex_pfstatus-func = okneuz.
      append ex_pfstatus.
      ex_pfstatus-func = oksave.
      append ex_pfstatus.
      ex_pfstatus-func = okweit.
      append ex_pfstatus.
      ex_pfstatus-func = okstat.
      append ex_pfstatus.
      ex_pfstatus-func = okstcl.
      append ex_pfstatus.
      ex_pfstatus-func = okobwe.
      append ex_pfstatus.
      ex_pfstatus-func = okrele.
      append ex_pfstatus.
      ex_pfstatus-func = ok_al_create.
      append ex_pfstatus.
      if syst-calld = kreuz.
        ex_pfstatus-func = ok_all_chng.
        append ex_pfstatus.
        ex_pfstatus-func = ok_cls_stack.
        append ex_pfstatus.
      endif.
    else.
      if change_subsc_act is initial or
         not rmclf-aennr1 is initial.
        ex_pfstatus-func = okaedi.
        append ex_pfstatus.
      endif.
      if syst-calld = kreuz.
        ex_pfstatus-func = ok_all_disp.
        append ex_pfstatus.
        ex_pfstatus-func = ok_cls_stack.
        append ex_pfstatus.
      endif.
    endif.

    if g_only_class = kreuz.
      ex_pfstatus-func = okobwe.
      append ex_pfstatus.
      ex_pfstatus-func = okobja.
      append ex_pfstatus.
    endif.

    if claeblg is initial.
      ex_pfstatus-func  = okaebl.
      append ex_pfstatus.
    endif.

*   Tabelle mit Fcodes für Bewertung
    ex_pfstatusv[] = ex_pfstatus[].
    ex_pfstatusv-func = ok_acus.
    append ex_pfstatusv.
    ex_pfstatusv-func = ok_acmg.
    append ex_pfstatusv.
    ex_pfstatusv-func = ok_defv.
    append ex_pfstatusv.
    ex_pfstatusv-func = ok_vsch.
    append ex_pfstatusv.
    ex_pfstatusv-func = ok_view.
    append ex_pfstatusv.
    ex_pfstatusv-func = ok_trce.
    append ex_pfstatusv.
    ex_pfstatusv-func = ok_trac.
    append ex_pfstatusv.

  endif.

  check g_46_ta = space.
*
*-----------------------------------------------------------
*
  if g_zuord = c_zuord_4  and  tcd_stat = space.
    refresh ex_pfstatus.
    ex_pfstatus-func = okloes.
    append ex_pfstatus.
    ex_pfstatus-func = okneuz.
    append ex_pfstatus.
    ex_pfstatus-func = oksave.
    append ex_pfstatus.
    ex_pfstatus-func = okklas.
    append ex_pfstatus.
    ex_pfstatus-func = okweit.
    append ex_pfstatus.
    ex_pfstatus-func = okstat.
    append ex_pfstatus.
    ex_pfstatus-func = okstcl.
    append ex_pfstatus.
    ex_pfstatus-func = okobwe.
    append ex_pfstatus.
    ex_pfstatus-func = okaedi.
    append ex_pfstatus.
    refresh ex_pfstatus1.
    ex_pfstatus1-func = okmein.
    append ex_pfstatus1.
  else.
    if change_subsc_act is initial or not rmclf-aennr1 is initial.
      ex_pfstatus-func = okaedi.
      append ex_pfstatus.
    endif.
  endif.

  if syst-calld = kreuz.
    clear l_menu.
    import l_menu from memory id 'RCCLSTA1CALL'.
    if l_menu = kreuz.
*      clear   skssk.
*      refresh skssk.
*      export skssk to memory id 'RCCLSTA1KSSK'.
      ex_pfstatus-func = oknezu.
      append ex_pfstatus.
      ex_pfstatus-func = okneuz.
      append ex_pfstatus.
      ex_pfstatus-func = okloes.
      append ex_pfstatus.
      ex_pfstatus-func = okklaa.
      append ex_pfstatus.
      ex_pfstatus-func = okobja.
      append ex_pfstatus.
      ex_pfstatus-func = okobwe.
      append ex_pfstatus.
      ex_pfstatus-func = okaedi.
      append ex_pfstatus.
    endif.
  endif.

  if g_only_class = kreuz.
    ex_pfstatus-func = okobwe.
    append ex_pfstatus.
    ex_pfstatus-func = okobja.
    append ex_pfstatus.
  endif.
  if clhier is initial.
    ex_pfstatus-func = okhcla.
    append ex_pfstatus.
    ex_pfstatus-func = okhclg.
    append ex_pfstatus.
    ex_pfstatus-func = okucla.
    append ex_pfstatus.
    ex_pfstatus-func = okuclg.
    append ex_pfstatus.
    ex_pfstatus-func = okxcla.
    append ex_pfstatus.
    ex_pfstatus-func = okxclg.
    append ex_pfstatus.
  endif.
  if claeblg is initial.
    ex_pfstatus-func  = okaebl.
    append ex_pfstatus.
  endif.

endform.                               " EXCLUDE_FUNCTIONS_OBJS_CL
