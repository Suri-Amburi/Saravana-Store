*§-----------------------------------------------------------------*
*       MODULE OK_CODE2 INPUT                                      *
*------------------------------------------------------------------*
*       Sichern/Weiter Funktion                                    *
*------------------------------------------------------------------*
module ok_code2 input.
  if classif_status = drei.
    if sokcode = okwech.
      set screen dy000.
      leave screen.
    endif.
  endif.
  check classif_status ne drei.
  describe table klastab lines syst-tfill.
  if syst-tfill = 0.
    case g_zuord.
      when c_zuord_2.
        message s555.
      when c_zuord_4.
*+      hzaehl = 1000.
*+      szaehl = 0.
      when others.
        if g_zuord eq c_zuord_0 and tcd_stat eq kreuz.
          message s555.
        else.
          if okcode is initial.
            message s555.
          endif.
        endif.
    endcase.
  else.
    rmclf-pagpos = index_neu.
  endif.

  if g_cl_ta eq kreuz.
    if sokcode = okleav.
      perform beenden.
    endif.
  endif.

  check okcode = oksave or okcode = okweit or okcode = okvobi.
  clear okcode.
  if g_zuord eq c_zuord_2 and tcd_stat eq kreuz.
    IF NOT g_no_lock_klart IS INITIAL.                   "begin 1141804
*  -- Nur Shared-Sperre
      CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'
        EXPORTING
          iv_enqmode           = 'S'
          iv_klart             = rmclf-klart
        EXCEPTIONS
          FOREIGN_LOCK         = 1
          SYSTEM_FAILURE       = 2.
    ELSE.
      CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'
        EXPORTING
          iv_enqmode           = 'E'
          iv_klart             = rmclf-klart
        EXCEPTIONS
          FOREIGN_LOCK         = 1
          SYSTEM_FAILURE       = 2.
    ENDIF.                                                 "end 1141804
    case syst-subrc.
      when 1.
        message e549 with syst-msgv1.
      when 2.
        message e519.
    endcase.
    clear sretcode.
    loop at allkssk where vbkz = c_insert .
      perform rekursion_pruefen using allkssk-class rmclf-clasn
                                                   syst-subrc.
      if syst-subrc = 1.
        IF NOT g_no_lock_klart IS INITIAL.               "begin 1141804
*      -- Nur Shared-Sperre
          CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'
            EXPORTING
              iv_enqmode       = 'S'
              iv_klart         = rmclf-klart.
        ELSE.
          CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'
            EXPORTING
              iv_enqmode       = 'E'
              iv_klart         = rmclf-klart.
        ENDIF.                                             "end 1141804
        message s513 with rmclf-klart allkssk-class.
        sretcode = 1.
        exit.
      endif.
    endloop.
    if sretcode = 1.
      exit.
    endif.
  endif.

  if g_zuord eq c_zuord_4 and tcd_stat eq kreuz.
    clear g_first_rec.
    loop at allkssk where vbkz = c_insert
                      and mafid    = mafidk.
      if g_first_rec = space.
        g_first_rec = kreuz.
        IF NOT g_no_lock_klart IS INITIAL.               "begin 1141804
*      -- Nur Shared-Sperre
          CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'
            EXPORTING
              iv_enqmode           = 'S'
              iv_klart             = allkssk-klart
            EXCEPTIONS
              FOREIGN_LOCK         = 1
              SYSTEM_FAILURE       = 2.
        ELSE.
          CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'
            EXPORTING
              iv_enqmode           = 'E'
              iv_klart             = allkssk-klart
            EXCEPTIONS
              FOREIGN_LOCK         = 1
              SYSTEM_FAILURE       = 2.
        ENDIF.                                             "end 1141804
        case syst-subrc.
          when 1.
            message e549 with syst-msgv1.
          when 2.
            message e519.
        endcase.
      endif.
      pm_class = allkssk-objek.
      perform rekursion_pruefen using rmclf-clasn pm_class
                                                 syst-subrc.
      if syst-subrc = 1.
        IF NOT g_no_lock_klart IS INITIAL.               "begin 1141804
*      -- Nur Shared-Sperre
          CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'
            EXPORTING
              iv_enqmode       = 'S'
              iv_klart         = allkssk-klart.
        ELSE.
          CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'
            EXPORTING
              iv_enqmode       = 'E'
              iv_klart         = allkssk-klart.
        ENDIF.                                             "end 1141804
        message s513 with allkssk-klart allkssk-class.
        sretcode = 1.
        exit.
      endif.
    endloop.
    if sretcode = 1.
      exit.
    endif.
  endif.

  loop at allkssk where objek = space.
    delete allkssk.
  endloop.

  if g_zuord eq c_zuord_4.
    loop at allkssk where vbkz  eq c_delete.  "Tabellen ALLKSSK,
      delete allkssk.                  "ALLAUSP, VIEW
      if not allkssk-cuobj is initial.
        call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
             exporting
                  object_id = allkssk-cuobj.
      endif.
    endloop.                           "log. gelöschte
  else.
*>>> Sätze mit DELKZ <> SPACE sollten in der DELCL sein!!!
    loop at allkssk where objek = rmclf-objek "Tabellen ALLKSSK,
                      and klart = rmclf-klart
                      and vbkz  eq c_delete . "ALLAUSP, VIEW
      delete allkssk.                  "log. gelöschte
      if not allkssk-cuobj is initial.
        call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
             exporting
                  object_id = allkssk-cuobj.
      endif.
    endloop.                           "Sätze werden
    delete allausp where objek = rmclf-objek "entfernt
                     and klart = rmclf-klart
                     and delkz ne space.
  endif.


* Einträge in KLASTAB die noch keine Werte haben
  clear save_objek.
  clear save_clint.
  loop at klastab where index_tab gt 0 .
    read table allkssk index klastab-index_tab .
*>>> Achtung: Loop sollte nur über die ganz neuen gehen.
*>>> Braucht man den Loop überhaupt noch?????
    check sy-subrc is initial.
    g_clint = pm_clint.
    if allkssk-stdcl = kreuz.          "merke KLASTAB-Satz
      save_objek = rmclf-objek.        "der Standardflag
      save_clint = allkssk-clint.      "auf X hat.
*+    standardclass = allkssk-objek.
      standardclass = allkssk-class.
    endif.
    if allkssk-vbkz eq c_insert.       "wurde eine Zuordnung schon
      index_neu = 1.
      rmclf-pagpos = 1.
      zeile = syst-tabix.              "klassifiziert
      antwort = kreuz.
      perform auswahl using antwort zeile.
      if syst-subrc = 0.
        perform ohne_bewertung.
      endif.
    endif.
    pm_clint = g_clint .
  endloop.
*+endif.

  if not reorgflag is initial.
    perform sort_save.
  endif.


  if g_zuord eq c_zuord_4.
    loop at allausp.
      if allausp-updat is initial.
      else.
        allausp-updat = kreuz.
        modify allausp index syst-tabix.
      endif.
    endloop.
  else.
    loop at allausp where objek = rmclf-objek
                      and klart = rmclf-klart
                      and updat ne space.
      allausp-updat = kreuz.
      modify allausp index syst-tabix.
    endloop.
  endif.

* Update erforderlich ?
  if g_zuord eq c_zuord_4.
    loop at allausp where statu ne space.
      exit.
    endloop.
  else.
    loop at allausp where objek = rmclf-objek
                      and klart = rmclf-klart
                      and statu ne space.
      exit.
    endloop.
  endif.
  if syst-subrc = 0.
    anzzeilen = 1.
  else.
    clear anzzeilen.
  endif.
  if anzzeilen = 0.
    if g_cl_ta eq kreuz.
      describe table allkssk lines anzzeilen.
    else.
      loop at allkssk where objek = rmclf-objek
                        and klart = rmclf-klart.
        anzzeilen = anzzeilen + 1.
      endloop.
      if syst-subrc ne 0.
        clear anzzeilen.
      endif.
    endif.
*>>> UPDATE und DELETE noch bearbeiten
    describe table delcl lines sy-tfill.
    if sy-tfill gt 0 .
      kssk_update = kreuz.
      perform cust_exit_post USING ' '.                       "  2241496
      perform delete_classification on commit.
    endif.
  endif.
*-- Prüfen Gleiche Werte
  perform status_chk_insert using cl_statusf.
  perform cust_exit_post USING ' '.                           "  2241496
  perform insert_classification on commit.
  kssk_update = kreuz.
  set screen dy000.
  leave screen.
*+endif.                               " ok_code
endmodule.
