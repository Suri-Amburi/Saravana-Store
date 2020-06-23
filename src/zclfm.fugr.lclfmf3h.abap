*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK_CLASSIFY
*&---------------------------------------------------------------------*
*       Checks whether activity is allowed.
*       p_okcode determines the activity.
*----------------------------------------------------------------------*
form authority_check_classify
     using    value(p_okcode)
              p_message
              p_tables                                         "1847519
     changing p_subrc.

  data: l_actvt like tact-actvt,
        l_bgrkl type klah-bgrkl.                              "  2442333


  clear p_subrc.                                               "1697240

  case p_okcode.
    when ok_clfm_change.
      l_actvt = '02'.
    when okloes.
      l_actvt = '02'.
    when ok_clfm_display.
      l_actvt = '03'.
    when ok_all_disp.
      l_actvt = '03'.
    when okneuz or ok_al_create.
      l_actvt = '01'.
  endcase.

  CASE g_zuord.                                               "v 2442333

    WHEN c_zuord_4.        " CL24N
      l_bgrkl = klah-bgrkl.

    WHEN c_zuord_0 OR ' '.  " CL20N              see 1434640 1615336
      IF l_actvt <> '01'.                      " see 1541746
        l_bgrkl = iklah-bgrkl.
      ENDIF.

    WHEN c_zuord_2.         " CL22N              see 1847519
      IF NOT p_tables IS INITIAL.
        l_bgrkl = klah-bgrkl.
      ELSE.
*       no auth check
        CLEAR l_actvt.
      ENDIF.

  ENDCASE.

  IF l_bgrkl <> '' AND l_actvt <> ''.
    AUTHORITY-CHECK OBJECT 'C_KLAH_BKL' ID 'BGRKL' FIELD l_bgrkl
                                        ID 'ACTVT' FIELD l_actvt.
  ELSEIF l_actvt <> ''.
    AUTHORITY-CHECK OBJECT 'C_KLAH_BKL' ID 'BGRKL' DUMMY
                                        ID 'ACTVT' FIELD l_actvt.
  ENDIF.
  p_subrc = sy-subrc.                                         "^ 2442333

  if not p_subrc is initial and
     not p_message is initial.
    if sy-calld is initial.
      MESSAGE s068 WITH l_bgrkl l_actvt.                      "  2442333
*    'no authorization for the selected action'.
    else.
      message s075 with sy-tcode.
*     'no authorization for transaction ...'.
      leave.
    endif.
  endif.

endform.                               " AUTHORITY_CHECK_CLASSIFY

*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_CLASS_MAINT
*&---------------------------------------------------------------------*
*       Authority check:
*       to change (valuations !), delete, create allocations.
*
*       Checks class that an object (class,material, ..) is
*       allocated to. So in class/class allocs check superior class.
*----------------------------------------------------------------------*
*       --> P_TCD_STAT  activity mode
*----------------------------------------------------------------------*
form auth_check_class_maint
     using value(p_clint)
           value(p_class)
              value(p_tcd_stat)
              value(p_msgtype)
     changing p_subrc.

  data: l_mode   like sy-batch   value  mafidk.

  clear   iklah.
  refresh iklah.
  if not p_clint is initial.
    iklah-clint = p_clint.
  elseif not p_class is initial.
    iklah-klart = rmclf-klart.
    iklah-class = p_class.
  else.
    exit.
  endif.
  append iklah.

  call function 'CLSE_SELECT_KLAH'
       tables
            imp_exp_klah   = iklah
       exceptions
            no_entry_found = 1
            others         = 2.

  if sy-subrc is initial.
    read table iklah index 1.
    check sy-subrc is initial.
    call function 'CLMA_AUTHORITY_CHK'
         exporting
              i_mode       = l_mode
              i_bgrkl      = iklah-bgrkl
              i_cl_act     = p_tcd_stat
         exceptions
              no_authority = 1
              others       = 2.
    if not sy-subrc is initial.
      p_subrc = sy-subrc.
      message id 'CL' type p_msgtype number '532'
              with iklah-class.
    endif.
  endif.

endform.                               " AUTH_CHECK_CLASS_MAINT
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_CHANGE_MODE
*&---------------------------------------------------------------------*
*       Check authorization.
*       User pressed 'enter' in CL*, has no authorization to change:
*       then change mode 'change' to 'display'.
*----------------------------------------------------------------------*
form auth_check_change_mode.

* Begin of 1241012
* auth. to change ?
  if g_zuord = c_zuord_4 and
     klah-bgrkl is not initial.
    authority-check object 'C_KLAH_BKL'
                    id     'BGRKL' field klah-bgrkl
                    id     'ACTVT' field  '02'.
  else.
    authority-check object 'C_KLAH_BKL'
                    id     'BGRKL' dummy
                    id     'ACTVT' field  '02'.
  endif.
  if sy-subrc = 0.
    cl_status = c_change.
  else.
    if g_zuord = c_zuord_4 and
       klah-bgrkl is not initial.
      authority-check object 'C_KLAH_BKL'
                      id     'BGRKL' field klah-bgrkl
                      id     'ACTVT' field  '01'.
  else.
    authority-check object 'C_KLAH_BKL'
                    id     'BGRKL' dummy
                    id     'ACTVT' field  '01'.
    endif.
    if sy-subrc = 0.
      cl_status = c_change.
    else.
*     auth. to display ?
      if g_zuord = c_zuord_4 and
         klah-bgrkl is not initial.
        authority-check object 'C_KLAH_BKL'
                        id     'BGRKL' field klah-bgrkl
                        id     'ACTVT' field  '03'.
      else.
        authority-check object 'C_KLAH_BKL'
                        id     'BGRKL' dummy
                        id     'ACTVT' field  '03'.
      endif.
      if sy-subrc = 0.
        okcode    = ok_clfm_display.
        cl_status = c_display.
      else.
        message e262.
      endif.
    endif.
  endif.                               " change
* End of 1241012

endform.                               " auth_check_change_mode
