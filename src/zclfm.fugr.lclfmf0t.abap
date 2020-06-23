*&---------------------------------------------------------------------*
*&      Form  OKB_KLAA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_klaa.

  loop at klastab where markupd ne space.
    authority-check object 'C_KLAH_BKP'
      id 'ACTVT' field '03'
      id 'BGRKP' dummy.
    if syst-subrc ne 0.
      message e075 with tcodecl03.
    endif.
    if g_zuord = c_zuord_4.
      read table g_obj_indx_tab index index_neu.
      read table klastab index g_obj_indx_tab-index.
    else.
    endif.
    check syst-subrc eq 0.
    if g_zuord = c_zuord_4.
      if klastab-mafid eq mafido.
        message s514 with <length>.
        leave screen.
      endif.
    endif.
    read table allkssk index klastab-index_tab .
    klah-class = allkssk-class.
    set parameter id c_param_kla field klah-class.
    set parameter id c_param_kar field rmclf-klart.     " neu in 4.5A
    set parameter id c_param_aen field rmclf-aennr1.
    call transaction tcodecl03 with authority-check          "1909745
                               and skip first screen.
  endloop.
endform.                               " OKB_KLAA
