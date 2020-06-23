*&---------------------------------------------------------------------*
*&      Form  OKB_AEDA
*       text
*----------------------------------------------------------------------*
form okb_aeda.
*+    if syst-dynnr = dy511.
  if g_zuord eq c_zuord_4 .
    zeile = zeile + index_neu - 1.
    read table g_obj_indx_tab index zeile.
    zeile = zeile - index_neu + 1.
    if syst-subrc ne 0.
      leave screen.
    endif.
    read table klastab index g_obj_indx_tab-index.
    check allkssk-vbkz ne c_insert.
    if syst-subrc ne 0.
      leave screen.
    endif.
    submit rcclcn02 and return
      with pm_objek = klastab-objek
      with pm_klart = rmclf-klart
      with pm_mafid = klastab-mafid
      with pm_obtab = klastab-obtab
      with pm_statu = kreuz.
  endif.
  if ( g_zuord eq c_zuord_0 or g_zuord eq space ).
    submit rcclcn02 and return
      with pm_objek = rmclf-objek
      with pm_klart = rmclf-klart
      with pm_mafid = mafido
      with pm_obtab = sobtab.
  endif.

endform.                               " OKB_AEDA
