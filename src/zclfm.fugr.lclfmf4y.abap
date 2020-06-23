*&---------------------------------------------------------------------*
*&      Form  ok_PARA
*&---------------------------------------------------------------------*
*       ECM initialisieren:
*----------------------------------------------------------------------*
form ok_para.

*     Bei der Klassifizierung keine Pflegebewertung
*    'nebenher' erlauben, wenn Änderungsnr. angegben wurde:
*     i_batch = x  -> unterdrückt Popup.
  g_flag = kreuz.
  if rmclf-datuv1 is initial.
    rmclf-datuv1 = sy-datum.
  endif.
  if classif_status = c_display and rmclf-aennr1 is initial.
    g_flag = space.
  endif.

  call function 'CLEF_ECM_PROCESSOR_INIT'
       exporting
            key_date            = rmclf-datuv1
            i_aennr             = rmclf-aennr1
            i_batch             = g_flag
            i_maintain_flag     = space
            i_free_memory       = 'X'
       exceptions
            ecm_init_error      = 1
            exit_from_dynpro    = 2
            no_maintenance_data = 3.
  if sy-subrc = 1.
    message e167.
*     'Fehler beim Initialisieren Parametergültigkeit'
  elseif sy-subrc = 3.
    message e173 with rmclf-aennr1.
*     'Zur Änderungsnummer & existiert noch keine Pflegebewertung'
  endif.

  g_effectivity_used = kreuz.

endform.                               " ok_PARA
