*------------------------------------------------------------------*
*        FORM RENAME_CLASSIFICATION                                *
*------------------------------------------------------------------*
*        Schreiben der Protokollsätze für das Umbennen Objekt      *
*------------------------------------------------------------------*
form rename_classification.
  if not all_multi_obj is initial.
    call function 'CUOB_COMMIT_WORK'
         EXPORTING
              on_commit = space.
  endif.

  if g_no_upd_task is initial.
    call function 'CLVF_VB_RENAME_CLASSIFICATION' in update task
         EXPORTING
              change_service_number = rmclf-aennr1
              date_of_change        = rmclf-datuv1
         TABLES
              kssktab               = allkssk
              ausptab               = allausp.
  else.
*-- Nicht in Update Task
    call function 'CLVF_VB_RENAME_CLASSIFICATION'
         EXPORTING
              change_service_number = rmclf-aennr1
              date_of_change        = rmclf-datuv1
         TABLES
              kssktab               = allkssk
              ausptab               = allausp.
  endif.
  g_no_upd_task_chg  = kreuz.
endform.
