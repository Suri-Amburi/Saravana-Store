*&---------------------------------------------------------------------*
*&      Form  OK_CLFM_DISP
*&---------------------------------------------------------------------*
*       Calls CLFM_OBJECT(S)_CLASSIFICATION in display mode
*       to start classsification in CL20N/22N/24N.
*----------------------------------------------------------------------*
form ok_clfm_disp.

  data: l_exit type sy-batch.

  perform authority_check_classify
          using    sokcode
                   kreuz
                   space                                       "1847519
          changing g_subrc.

  if g_subrc = 0.
    if classif_status = c_change.
*     mode changed: change -> display, restart transaction.
      perform leave_clfy changing l_exit.
      leave.                              " leave in call mode
*     'Transaction restartet.'
      message s177.
      leave to transaction sy-tcode.

    else.
      cl_status = c_display.
      clear g_sel_changed.
      clear g_only_new_entries.
      perform call_clfm_function
              using c_display.
    endif.
  endif.

endform.                               " ok_clfm_disp
