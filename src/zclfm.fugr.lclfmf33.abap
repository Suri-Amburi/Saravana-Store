*&---------------------------------------------------------------------*
*&      Form  CHECK_AENNRF_SEL
*&---------------------------------------------------------------------*
*       Check change number.
*       Called from dynpros 11xx and 0600 (trx mm02)
*       after change number is entered.
*----------------------------------------------------------------------*
form check_aennrf_sel
     using value(p_status).

  data: l_display  like sy-batch,
        l_subrc    like sy-subrc.

  if not rmclf-aennr1 is initial.

    perform check_changeno using p_status
                                 rmclf-aennr1
                                 rmclf-datuv1
                                 rmclf-klart
                                 space                 "Note 1520557
                                 l_subrc.
    if l_subrc > 0.
      message id syst-msgid type syst-msgty number syst-msgno
              with syst-msgv1.
    endif.
  endif.

  set parameter id c_param_aen1 field rmclf-aennr1.

endform.                               " CHECK_AENNRF_SEL
