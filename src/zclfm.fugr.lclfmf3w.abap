*&---------------------------------------------------------------------*
*&      Form  KSSK_FREIGABE
*&---------------------------------------------------------------------*
*       Diese Form prüft, ob eine Zuordnung freigegeben werden kann -
*       und führt die freigabe ggf. durch.
*       In P_KSSK wird die entsprechende Zuordnung (ALLKSSK) erwartet.
*----------------------------------------------------------------------*
*  -->  P_KSSK    Zuordnung, die freigegeben werden soll
*----------------------------------------------------------------------*
form kssk_freigabe using p_kssk structure rmclkssk.

*-- Vorbereiten des Aufrufs von STATUS_CHECK
  pm_objek  = p_kssk-objek.
  pm_class  = p_kssk-class.
  pm_inobj  = p_kssk-cuobj.
  pm_status = cl_statusf.              " try status free
  mafid     = p_kssk-mafid.
  sobtab    = p_kssk-obtab.
  if g_zuord <> c_zuord_4.
    klas_pruef = p_kssk-praus.
  endif.
  if klas_pruef is initial.
    klas_pruef = konst_w.
  endif.

  clear cl_status_neu.
  g_consistency_chk = kreuz.
  gv_no_message = 'X'.                                         "1436346
  perform status_check using p_kssk-klart.
  if cl_status_neu is initial.
*-- STATUS UMSETZEN
    p_kssk-statu = cl_statusf  .
    if p_kssk-vbkz ne c_insert .
      p_kssk-vbkz = c_update.
    endif.
  endif.

endform.                               " KSSK_FREIGABE
