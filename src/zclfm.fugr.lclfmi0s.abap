*---------------------------------------------------------------------*
*       MODULE READ_OBJECT INPUT                                      *
*---------------------------------------------------------------------*
*       Klasse: Existenzprüfung , Sperre
*---------------------------------------------------------------------*
module read_object input.

  check not g_sel_changed is initial.

  clear rmclf-ktext.
  clear klah-clint.
  clear no_datum.
  clear no_status.
  clear no_classify.
  get parameter id c_param_kla field sklasse.
  if rmclf-datuv1 is initial.
    rmcbc-datuv1 = syst-datum.
  else.
    rmcbc-datuv1 = rmclf-datuv1.
  endif.

  call function 'CLMA_CLASS_EXIST'
    exporting
      classtype             = rmclf-klart
      class                 = rmclf-clasn
      classnumber           = klah-clint
      language              = syst-langu
      description_only      = space
      mode                  = 'K'
      date                  = rmcbc-datuv1
    importing
      class_description     = rmclf-ktext
      not_valid             = no_datum
      no_active_status      = no_status
      no_authority_classify = no_classify
      ret_code              = g_subrc
      xklah                 = klah
    exceptions
      no_valid_sign         = 20.
  if syst-subrc = 20.
    message e013 with 'Klasse'(002).   "Klasse enhält falsche Zeichen
  endif.

  if not no_classify is initial.
    message e532 with rmclf-clasn.
  endif.


  if g_zuord  = c_zuord_4  or g_zuord  = c_zuord_2  or
     sy-tcode = tcodeclw1  or sy-tcode = tcodeclw2.

    if syst-tcode = tcodeclw1 or syst-tcode = tcodeclw2.
      if klah-wwskz ne 0.
        message e557.
      endif.
    endif.
    if g_zuord = c_zuord_4 or g_zuord = c_zuord_2 or
       sy-tcode = tcodeclw1.
      if no_status  = kreuz.
        message e531 with rmclf-klart rmclf-clasn.
*      "Klasse hat keinen gültigen Status" .
      endif.
      if no_datum = kreuz and
        rmclf-aennr1 is initial.                               "1460174
        message e530 with rmclf-klart rmclf-clasn.
*       Klasse nicht gültig
      endif.
    endif.
    if no_classify = kreuz.
      message e532 with rmclf-clasn.
*     "keine Berechtigung zum Klassifizieren"
    endif.
  endif.

  if g_subrc = 2.
*   Klasse existiert nicht
    message e503 with rmclf-klart rmclf-clasn.
  else.
    if g_zuord = c_zuord_4 or
       g_zuord = c_zuord_2.
      if cl_status = c_change or
         okcode    = space.
*       Combination okcode=space and g-sel_changed=x
*       is also a change mode.

*       Save entered class in stack.
        call function 'FUNCTION_EXISTS'
          exporting
            funcname           = 'CLEX_PDM_ADD_OBJECT_TO_STACK'
          exceptions
            function_not_exist = 1
            others             = 2.

        if sy-subrc = 0.
          call function 'CLEX_PDM_ADD_OBJECT_TO_STACK'      "#EC EXISTS
               exporting
                    p_class     = rmclf-clasn
                    p_klart     = rmclf-klart
                    p_objtyp    = c_objclass
               exceptions
                    stack_error = 1
                    others      = 2.
        endif.

        CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode           = 'E'
            iv_klart             = rmclf-klart
            IV_CLASS             = rmclf-clasn
          EXCEPTIONS
            FOREIGN_LOCK         = 1
            SYSTEM_FAILURE       = 2.
        case sy-subrc.                                     "end 1141804
          when 1.
            syst-msgv4 = syst-msgv1.
            message e518 with rmclf-klart rmclf-clasn syst-msgv4.
          when 2.
            message e519.
        endcase.
      endif.
    endif.
  endif.                               " if g_subrc

*-- Abfrage auf Klasse, die auf einen externen Katalog verweist
  if not klah-katalog is initial and g_zuord = c_zuord_4.
    message e574 with rmclf-clasn klah-katalog .
  endif.

endmodule.                             " read_object
