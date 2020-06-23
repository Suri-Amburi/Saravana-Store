*&---------------------------------------------------------------------*
*&      Form  ok_user_parm
*&---------------------------------------------------------------------*
*       Set user related parameters for characteristics.
*----------------------------------------------------------------------*
form ok_user_parm.

  data: l_clprof like clprof .

  G_VIEW_BUP = g_sicht_akt .

  call function 'CLPR_USER_PARAM_MAINTAIN'
       EXPORTING
            i_foreground      = '1'
       IMPORTING
            e_clprof          = l_clprof
       EXCEPTIONS
            cancelled_by_user = 1
            others            = 2.
  if sy-subrc = 0.
    call function 'CTMS_SET_USER_PARAM'
         EXPORTING
              imp_user_param = l_clprof.

    g_language = l_clprof-langu.                               "2360038
  else.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  if not l_clprof-sicht is initial.
    set parameter id c_param_view field g_sicht_akt.
*-- g_sicht_akt anpassen
    g_sicht_akt    = l_clprof-sicht .
    rmclf-abtei = l_clprof-sicht.
  endif.
  if not l_clprof-klart is initial.
    set parameter id c_param_kar field l_clprof-klart.
  endif.

endform.                               " ok_user_parm
