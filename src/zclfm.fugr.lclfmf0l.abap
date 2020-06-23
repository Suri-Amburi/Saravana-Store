*&---------------------------------------------------------------------*
*&      Form  OKB_OBJA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_obja.

  check g_zuord ne c_zuord_2.
*-- Bei CL24 können mehrere Objekte angekreuzt sein
  if g_zuord eq c_zuord_4.
    loop at klastab where markupd ne space and
                          mafid   eq mafido.
      rmclf-objek = klastab-objek.
      sobtab = klastab-obtab.
      call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
           exporting
                table          = sobtab
                rmclfstru      = rmclf
                set_param      = kreuz
           importing
                tcode          = ssytcode
                rmclfstru      = rmclf
           tables
                lengthtab      = laengtab
           exceptions
                tclo_not_found = 1.
      check not ssytcode is initial.
      call transaction ssytcode with authority-check             "1909745
                                and skip first screen.
    endloop.
  else.
*-- Nur ein Objekt!
    call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
         exporting
              table          = sobtab
              rmclfstru      = rmclf
              set_param      = kreuz
         importing
              tcode          = ssytcode
              rmclfstru      = rmclf
         tables
              lengthtab      = laengtab
         exceptions
              tclo_not_found = 1.
    check not ssytcode is initial.
    call transaction ssytcode with authority-check               "1909745
                              and skip first screen.
  endif.
endform.                               " OKB_OBJA
