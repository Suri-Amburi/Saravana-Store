*------------------------------------------------------------------*
*        FORM PRUEFE_STATUS                                        *
*------------------------------------------------------------------*
*        Wenn der Status frei ist, prüfe den Status                *
*------------------------------------------------------------------*
form pruefe_status_and_rekursion.

  data: class       like klah-class.
  data: sobjek      like kssk-objek.
  data: sklart      like kssk-klart.
  data: l_status    like tclc-statu.
  data: l_subrc     like sy-subrc.
  data: l_flags     like g_val_flags.
  DATA: lv_enqmode  TYPE enqmode,                        "begin 1141804
        lv_uname    TYPE sy-msgv1.

*-- Nur sperren, wenn nicht ausdrücklich ausgeschlossen
  IF NOT g_no_lock_klart IS INITIAL.
*-- Nur Shared-Sperre
    lv_enqmode = 'S'.
  ELSE.
    lv_enqmode = 'E'.
  ENDIF.                                                   "end 1141804

  clear g_first_rec.
  l_flags-read_values        = kreuz.
  l_flags-langu              = g_language.
  l_flags-set_default_values = kreuz.

  loop at allkssk.
    check allkssk-vbkz  = c_insert.
    check allkssk-objek <> space.
    if allkssk-mafid = mafidk and allkssk-database is initial.
      CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'        "begin 1141804
        EXPORTING
          iv_enqmode           = lv_enqmode
          iv_klart             = allkssk-klart
        EXCEPTIONS
          FOREIGN_LOCK         = 1
          SYSTEM_FAILURE       = 2.
      case syst-subrc.
        when 1.
          lv_uname = sy-msgv1.
          message e518 with allkssk-klart
                            allkssk-objek
                            lv_uname
                       raising klart_locked.               "end 1141804
        when 2.
          message e519 raising system_failure.
      endcase.
      class = allkssk-objek.
      rmclf-klart = allkssk-klart.
      perform rekursion_pruefen using allkssk-class class l_subrc.
      CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'        "begin 1141804
        EXPORTING
          iv_enqmode       = lv_enqmode
          iv_klart         = allkssk-klart.                "end 1141804
      if l_subrc = 1.
        message e351 with allkssk-klart raising rekursiv.
      endif.
    endif.

    if allkssk-lock ne kreuz.
      read table xtclc with key mandt = sy-mandt
                                klart = allkssk-klart.
      if not sy-subrc is initial.
        perform lesen_tclc using allkssk-klart.
      endif.
      read table xtclc with key mandt = syst-mandt
                                klart = allkssk-klart
                                statu = allkssk-statu binary search.
      check sy-subrc is initial and
            xtclc-frei = kreuz.
      if sobjek ne allkssk-objek and sklart ne allkssk-klart.

        perform build_sel_api using allkssk
                                    iklart-mfkls
                                    aedi_aennr
                                    aedi_datuv
                                    l_flags.
        call function 'CTMS_DDB_CHECK'
          exceptions
            inconsistency  = 1
            incomplete     = 2
            verification   = 3
            not_assigned   = 4
            another_object = 5
            other_objects  = 6
            others         = 7.
        if syst-subrc = 2 or syst-subrc = 4.
          l_status      = cl_statusus.
          allkssk-statu = cl_statusus.
          modify allkssk.
        else.
          clear l_status.
        endif.
      else.
        if not l_status is initial.
          allkssk-statu = l_status.
          modify allkssk.
        endif.
      endif.
      sobjek = allkssk-objek.
      sklart = allkssk-klart.
    endif.
  endloop.
  clear syst-subrc.

endform.                    "pruefe_status_and_rekursion
