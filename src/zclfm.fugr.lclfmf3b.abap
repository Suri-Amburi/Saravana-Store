*---------------------------------------------------------------------*
*       FORM REBUILD_OBJI.                                            *
*---------------------------------------------------------------------*
*       Neuaufbau Indextabelle g_obj_indx_tab
*       tabausw: Tabelle der selektierten Objekttypen (-kreuz = x).
*---------------------------------------------------------------------*
form rebuild_obji.

  data: cnt_obj  type i.
  data: cnt_obji type i.

  refresh g_obj_indx_tab.

  loop at klastab assigning <gf_klas>.
    cnt_obj = cnt_obj + 1.
    ssytabix = syst-tabix.
    read table tabausw with key <gf_klas>-objtype binary search.
    if syst-subrc = 0.
      if tabausw-kreuz = kreuz.
        cnt_obji = cnt_obji + 1.
        g_obj_indx_tab-index = ssytabix.
        read table redun with key <gf_klas>-obtab binary search.
        if redun-showo = kreuz.
          g_obj_indx_tab-showo = kreuz.
        else.
          clear g_obj_indx_tab-showo.
        endif.
        append g_obj_indx_tab.
      endif.
    else.
      cnt_obji = cnt_obji + 1.
      g_obj_indx_tab-index = ssytabix.
      read table redun with key <gf_klas>-obtab binary search.
      if redun-showo = kreuz.
        g_obj_indx_tab-showo = kreuz.
      else.
        clear g_obj_indx_tab-showo.
      endif.
      append g_obj_indx_tab.
    endif.
  endloop.

*  if cnt_obji < cnt_obj.
*    ex_pfstatus1-func = okmein.
*    append ex_pfstatus1.
*  else.
*    read table ex_pfstatus1 with key okmein.
*    if syst-subrc = 0.
*      delete ex_pfstatus1 index syst-tabix.
*    endif.
*  endif.

endform.                               " rebuild_obji
