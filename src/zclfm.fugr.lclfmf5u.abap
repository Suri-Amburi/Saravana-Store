*&---------------------------------------------------------------------*
*&      Form  OK_AEDA
*       Show change mgmnt data for selected object/class.
*----------------------------------------------------------------------*
form ok_aeda.

  data: l_idx   like sy-stepl.

  if g_zuord = c_zuord_4 .

    if cn_mark > 0.
*     Es gibt Markierungen
      clear cn_mark.
      clear fname.
      clear markzeile1.
      loop at klastab where markupd = kreuz.
        clear klastab-markupd.
        modify klastab.
        l_idx = sy-tabix.
      endloop.
    else.
      l_idx = index_neu + zeile - 1.
    endif.
    check l_idx > 0.
    read table g_obj_indx_tab index l_idx.
    if sy-subrc = 0.
      read table klastab index g_obj_indx_tab-index .
      if sy-subrc = 0.
        read table allkssk index klastab-index_tab.
        if sy-subrc = 0.
          check allkssk-vbkz <> c_insert.
          l_idx = 0.
        endif.
      endif.
    endif.
    check l_idx = 0.

    submit rcclcn02 and return
      with pm_objek = klastab-objek
      with pm_klart = rmclf-klart
      with pm_mafid = klastab-mafid
      with pm_obtab = klastab-obtab
      with pm_statu = kreuz.
  endif.
  if ( g_zuord = c_zuord_0 or g_zuord = space ).
    submit rcclcn02 and return
      with pm_objek = rmclf-objek
      with pm_klart = rmclf-klart
      with pm_mafid = mafido
      with pm_obtab = sobtab.
  endif.

endform.                               " OK_AEDA
