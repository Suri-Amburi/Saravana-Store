*---------------------------------------------------------------------*
*       FORM RESET_CLASS                                              *
*---------------------------------------------------------------------*
*       Wenn beim kopieren Klassifizierung eine Klasse mitgegeben wird*
*       so wird diese Klasse zugeordnet und die Merkmale mit den      *
*       Merkmalen der Referenzklasse abgemischt.                      *
*---------------------------------------------------------------------*
form reset_class using class like klah-class.

  data: sklart like kssk-klart.
  data: sobjek like kssk-objek.

*>>> VBKZ abfragen???
  loop at allkssk where mafid = mafido
                    and objek = rmclf-objek.
    if sklart = allkssk-klart.
      if sobjek = allkssk-objek.
        continue.
      endif.
    endif.
    sklart = allkssk-klart.
    sobjek = allkssk-objek.
    clear klah-clint.
    clear no_datum.
    clear no_status.
    clear no_classify.
    if rmclf-datuv1 is initial.
      klah-vondt = syst-datum.
    else.
      klah-vondt = rmclf-datuv1.
    endif.
    call function 'CLMA_CLASS_EXIST'
         EXPORTING
              classtype             = allkssk-klart
              class                 = class
              classify_activity     = tcd_stat
              classnumber           = klah-clint
              language              = syst-langu
              description_only      = space
              mode                  = mode
              date                  = klah-vondt
         IMPORTING
              class_description     = rmclf-ktext
              not_valid             = no_datum
              no_active_status      = no_status
              no_authority_classify = no_classify
              ret_code              = g_l_subrc
              xklah                 = klah
         EXCEPTIONS
              no_valid_sign         = 20.
    if syst-subrc = 20.
      continue.                        "keine gültige Zeichen
    endif.
    if no_classify = kreuz.
      continue.                        "keine Berechtigung zum
                                       "Klassifizieren
    endif.
    if no_status  = kreuz.
      continue.                        "Klasse hat keinen gültige
                                       "Status
    endif.
    if no_datum = kreuz.
      continue.                        "Klasse nicht gültig
    endif.
    if g_l_subrc eq 2.
      continue.
    endif.
    CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'          "begin 1141804
      EXPORTING
        iv_enqmode           = 'S'
        iv_klart             = klah-klart
        IV_CLASS             = klah-class
        IV_MAFID             = mafido
        IV_OBJEK             = rmclf-objek
      EXCEPTIONS
        FOREIGN_LOCK         = 1
        SYSTEM_FAILURE       = 2.
    case sy-subrc.                                         "end 1141804
      when 1.
        continue.
      when 2.
        continue.
    endcase.
    allkssk-kschl = rmclf-ktext.
    allkssk-class = klah-class.
    allkssk-clint = klah-clint.
    modify allkssk.
    clear   iksml.
    refresh iksml.
    iksml-clint = klah-clint.
    append iksml.
    if rmclf-datuv1 is initial.
      iksml-datuv = syst-datum.
    else.
      iksml-datuv = rmclf-datuv1.
    endif.
    call function 'CLSE_SELECT_KSML'
         EXPORTING
              key_date       = iksml-datuv
              i_aennr        = rmclf-aennr1
         TABLES
              imp_exp_ksml   = iksml
         EXCEPTIONS
              no_entry_found = 04.
    if syst-subrc = 0.
      sort iksml by mandt clint imerk.
      loop at allausp where mafid = mafido
                        and klart = allkssk-klart
                        and objek = rmclf-objek.
        read table iksml with key mandt = syst-mandt
                                  imerk = allausp-atinn binary search.
        if syst-subrc > 0.
          delete allausp.
        endif.
      endloop.
    else.
      delete allausp where mafid = mafido
                       and klart = allkssk-klart
                       and objek = rmclf-objek.
    endif.
  endloop.
endform.
