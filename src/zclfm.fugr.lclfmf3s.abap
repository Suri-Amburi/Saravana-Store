*&---------------------------------------------------------------------*
*&      Form  RMCLF_ABTEI_SAVE
*&---------------------------------------------------------------------*
*       Ablegen in Parameter des Users
*----------------------------------------------------------------------*
form rmclf_abtei_save.
  data: l_paramids_tab  like usparam  occurs 5 with header line .

  set parameter id c_param_view field g_sicht_akt.
*-- UPDATE USER-Stamm
  call function 'SUSR_USER_PARAMETERS_GET'
       EXPORTING
            user_name           = sy-uname
       TABLES
            user_parameters     = l_paramids_tab
       EXCEPTIONS
            user_name_not_exist = 1
            others              = 2.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
*-- Übernahme Parameter VIEW in Parameterliste des Users
    read table l_paramids_tab with key parid = c_param_view.
    if sy-subrc is initial.
*-- ... überschreiben
      l_paramids_tab-parva = g_sicht_akt.
      modify l_paramids_tab index sy-tabix.
    else.
*-- ... neu eintragen
      l_paramids_tab-parid = c_param_view  .
      l_paramids_tab-parva = g_sicht_akt.
      append l_paramids_tab.
    endif.

    call function 'SUSR_USER_PARAMETERS_PUT'
         EXPORTING
              user_name           = sy-uname
         TABLES
              user_parameters     = l_paramids_tab
         EXCEPTIONS
              user_name_not_exist = 1
              others              = 2.

    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    call function 'SUSR_USER_BUFFERS_TO_DB'
*          TABLES
*               OFFICE_USERS              =
         exceptions
              no_logondata_for_new_user = 1
              no_init_password          = 2
              db_insert_usr02_failed    = 3
              db_update_usr02_failed    = 4
              db_insert_usr01_failed    = 5
              db_update_usr01_failed    = 6
              db_insert_usr05_failed    = 7
              db_update_usr05_failed    = 8
              db_insert_usr21_failed    = 9
              db_update_usr21_failed    = 10
              internal_error            = 11
              others                    = 12.

    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.
endform.                               " RMCLF_ABTEI_SAVE
