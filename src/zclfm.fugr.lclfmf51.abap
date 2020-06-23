*&---------------------------------------------------------------------*
*&      Form  ok_OBJA
*&---------------------------------------------------------------------*
*       Calls transaction to display the selected object.
*       Not used -> ok_obj_disp
*----------------------------------------------------------------------*
form ok_obja.

  data: l_idx like sy-stepl.

  check g_zuord <> c_zuord_2.

  if g_zuord = c_zuord_4.
    if cn_mark > 0.
*-- Bei CL24 können mehrere Objekte angekreuzt sein
      loop at klastab where markupd ne space and
                            mafid   eq mafido.
        rmclf-objek = klastab-objek.
        sobtab = klastab-obtab.
        call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
             EXPORTING
                  table          = sobtab
                  rmclfstru      = rmclf
                  set_param      = kreuz
             IMPORTING
                  tcode          = ssytcode
                  rmclfstru      = rmclf
             TABLES
                  lengthtab      = laengtab
             EXCEPTIONS
                  tclo_not_found = 1.
        check not ssytcode is initial.
        call transaction ssytcode with authority-check         "1909745
                                  and skip first screen.
      endloop.
    else.
*     selected line
      l_idx = index_neu + zeile - 1.
      perform auswahl using antwort l_idx.
      if antwort = kreuz or klastab-obtab is initial.
*       obtab empty: class !
        message s501.
        leave screen.
      endif.
      call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
           EXPORTING
                table          = sobtab
                rmclfstru      = rmclf
                set_param      = kreuz
           IMPORTING
                tcode          = ssytcode
                rmclfstru      = rmclf
           TABLES
                lengthtab      = laengtab
           EXCEPTIONS
                tclo_not_found = 1.
      check not ssytcode is initial.
      call transaction ssytcode with authority-check          "1909745
                                and skip first screen.
    endif.

  else.
*-- Nur ein Objekt!
    call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
         EXPORTING
              table          = sobtab
              rmclfstru      = rmclf
              set_param      = kreuz
         IMPORTING
              tcode          = ssytcode
              rmclfstru      = rmclf
         TABLES
              lengthtab      = laengtab
         EXCEPTIONS
              tclo_not_found = 1.
    check not ssytcode is initial.
    call transaction ssytcode with authority-check            "1909745
                              and skip first screen.
  endif.
endform.                               " ok_OBJA
