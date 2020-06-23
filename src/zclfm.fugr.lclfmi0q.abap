*---------------------------------------------------------------------*
*       MODULE OK_CODE3                                               *
*---------------------------------------------------------------------*
*       Buchen bei CLW1;CLW3                                          *
*---------------------------------------------------------------------*
module ok_code3.
  check classif_status ne drei.
  if okcode = oksave.
    clear okcode.
    clear g_first_rec.
    clear sretcode.
    loop at allkssk where vbkz eq c_insert .
      if g_first_rec is initial.
        g_first_rec = kreuz.
        IF NOT g_no_lock_klart IS INITIAL.               "begin 1141804
*      -- Nur Shared-Sperre
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
        ENDIF.                                             "end 1141804
        case syst-subrc.
          when 1.
            message e549 with syst-msgv1.
          when 2.
            message e519.
        endcase.
      endif.
      perform rekursion_pruefen using rmclf-clasn allkssk-class
                                     g_l_subrc .
      if g_l_subrc = 1.
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
*>>> Coding unklar, daher ausgesternt
    delete allausp where statu eq space.
    describe table allausp lines anzzeilen.
    if anzzeilen = 0.
      loop at allkssk where vbkz ne space
                       and  vbkz ne c_delete .
        anzzeilen = anzzeilen + 1.
      endloop.
      describe table delcl   lines del_counter.
      if del_counter is initial.
        describe table delob   lines del_counter.
      endif.
      if not del_counter is initial.
        kssk_update = kreuz.
        perform cust_exit_post USING ' '.                     "  2241496
        perform delete_classification on commit.
        if anzzeilen eq 0 .
          set screen dy000.
          leave screen.
        endif.
      endif.
    endif.
    perform status_chk_insert using cl_statusf .
    perform cust_exit_post USING ' '.                         "  2241496
    perform insert_classification on commit.
    kssk_update = kreuz.
    set screen dy000.
    leave screen.
  endif.
endmodule.
