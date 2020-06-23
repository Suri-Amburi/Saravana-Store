*§-----------------------------------------------------------------*
*        FORM DELETE_ALL_TABS                                      *
*------------------------------------------------------------------*
*        STATUS 1:Setzen Kennzeichen log. gelöscht in den          *
*                 Tabellen ALLKSSK,ALLAUSP,VIEW                    *
*------------------------------------------------------------------*
form delete_all_tabs using altklass like klah-class.

  CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'            "begin 1141804
    EXPORTING
      iv_enqmode = 'S'
      iv_klart   = rmclf-klart
      iv_class   = altklass
      iv_mafid   = mafido
      iv_objek   = rmclf-objek.                            "end 1141804

  loop at allkssk where objek = rmclf-objek
                    and klart = rmclf-klart
                    and mafid = mafido
                    and class = altklass.
    delete allkssk index syst-tabix.
    if not allkssk-cuobj is initial.
      call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
           EXPORTING
                object_id = allkssk-cuobj.
    endif.
    delete allausp where objek = rmclf-objek
                     and klart = rmclf-klart.
  endloop.
  if syst-subrc ne 0.
    raise classification_not_found.
  endif.
endform.
