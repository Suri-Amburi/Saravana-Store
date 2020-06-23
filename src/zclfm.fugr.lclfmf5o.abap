*&---------------------------------------------------------------------*
*&      Form  OK_CLFM_CHNG
*&---------------------------------------------------------------------*
*       Calls CLFM_OBJECT_CLASSIFICATION in change mode
*       to start classsification.
*       Original ok-codes may be different from "clfm_chng"  (CL24 !)
*
*       If work mode is changed display <-> change transaction
*       has to be restarted. Necessary because allocations
*       have to be locked/delocked, change of global data settings
*       (sel !).
*----------------------------------------------------------------------*
form ok_clfm_chng.

  data: l_flag  like sy-batch,
        l_lines like sy-tabix.


  perform authority_check_classify
          using    ok_clfm_change
                   kreuz
                   kreuz                                       "1847519
          changing g_subrc.
  check g_subrc = 0.

  case g_zuord.

    when c_zuord_0.

      if classif_status = c_display.
*       mode changed: display -> change.
*       'Transaction restartet.'
        message s177.
        leave to transaction sy-tcode.
      else.
        cl_status = c_change.
        clear g_sel_changed.
        perform call_clfm_function
                using c_change.
      endif.


    when c_zuord_2.

      if classif_status = c_display.
*       mode changed: display -> change.
*       'Transaction restartet.'
        message s177.
        leave to transaction sy-tcode.
      else.
        cl_status = c_change.
        clear g_sel_changed.
        perform call_clfm_function
                using c_change.
      endif.


    when c_zuord_4.

*      if classif_status = c_display.                          "1772310
      if classif_status = c_display or                         "1772310
        ( g_change_item is initial and                         "1772310
          classif_status is not initial ).                     "1772310

*       1. mode changed: display -> change.
*       'Transaction restartet.'
        message s177.
        leave to transaction sy-tcode.

      else.
        cl_status = c_change.
        clear g_sel_changed.
        if g_only_new_entries = space.
*         2. start CLFM_objects_classif. with initialisations.
*         if exactly 1 allocation: show values too.
          if classif_status is initial.
*           authority to maintain class
            perform auth_check_class_maint
                    using space
                          rmclf-clasn
                             tcd_stat
                             'E'       " msg type
                    changing g_subrc.
            perform call_clfm_function
                    using c_change.
            describe table allkssk lines sy-tfill.
            if sy-tfill = 1.
              zeile = 1.
              perform ok_ausw.
            endif.
          endif.
        else.
*         3. CLFM_OBJECTS_CLASSIFATION already started:
*         just read kssk entries from database
          clear g_only_new_entries.    " before lesen_.. !
          clear g_flag .
          perform lesen_kssk_index using space g_flag.
          perform setup_klastab_index using multi_obj.
        endif.
      endif.
  endcase.

endform.                               " ok_clfm_chng.
