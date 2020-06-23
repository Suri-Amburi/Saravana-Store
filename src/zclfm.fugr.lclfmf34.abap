*---------------------------------------------------------------------*
*       FORM CHECK_AENNRF                                             *
*---------------------------------------------------------------------*
*       Pürfe Änderungsnummer                                         *
*---------------------------------------------------------------------*
form check_aennrf using status type c
                        aennr  like rmclf-aennr1
                        datum  like rmclf-datuv1
                        syst_subrc like sy-subrc .

  data: display     like csdata-xfeld,
        l_class     like klah-class,
        l_flg_aepf  like csdata-xfeld,
        l_date_aepf like aepf-date_lo .
  data: begin of xccin.
          include structure ccin.
  data: end   of xccin.


  check not aennr is initial.
*-- Effectivity zur Änderungsnummer aktiv??
  if not tcla-klart is initial.
    call function 'CLEF_EFFECTIVITY_USED'
         exporting
              i_aennr          = aennr
              i_classtype      = tcla-klart
         importing
              e_effe_aennr     = g_effectivity_used
         exceptions
              klart_not_active = 3
              others           = 4.
    if not sy-subrc is initial.
      clear g_effectivity_used .
    endif.
  endif.

*-- Falls Effectivity nicht aktiv: Änderungsdatum übernehmen
  xccin-aennr = aennr.
  xccin-aeobj = '5'.
  xccin-aeclt = '3'.
  display = status.
  call function 'CC_CHANGE_NUMBER_CHECK'
       exporting
            eccin                  = xccin
            flg_display            = display
            flg_s163         = 'N'
       importing
            adatuv                 = datum
            aclass                 = l_class        " effectivity type
            flg_aepf               = l_flg_aepf
            a_date_lo              = l_date_aepf
       exceptions
            error_aenr             = 1
            error_class            = 2
            error_date_restriction = 3
            error_status           = 4
            others                 = 5.
  syst_subrc = sy-subrc .
  check  sy-subrc is initial.

  if g_effectivity_used is initial.
    if g_cl_ta = kreuz and
       sy-binpt is initial.
*     message: only in class system trx; not in object trx or API
      message w042(29) with datum.  "#EC *
    endif.

  else.
*-- Effectivity:  ECM initialisieren
    if not l_flg_aepf is initial.
      datum = l_date_aepf .
      if datum        is initial.
        datum = sy-datum.
      endif.
    else.
      if datum        is initial.
        datum = sy-datum.
      endif.
    endif.
*   ECM initialisieren:
*   Bei der Klassifizierung keine Pflegebewertung im Popup
*  'nebenher' erlauben: i_batch = x.
    call function 'CLEF_ECM_PROCESSOR_INIT'
         exporting
              key_date        = datum
              i_aennr         = aennr
              i_batch         = kreuz
              i_maintain_flag = kreuz
*              i_no_pop_up     = kreuz
         exceptions
              ecm_init_error       = 1
              exit_from_dynpro     = 2
              no_maintenance_data  = 3.
    if sy-subrc = 1.
      message e167.
*     'Fehler beim Initialisieren Parametergültigkeit'
    elseif sy-subrc = 3.
      message e173 with aennr.
*     'Zur Änderungsnummer & existiert noch keine Pflegebewertung'
    endif.

    if sy-binpt is initial.
      message w139(cl) with aennr space datum .
    endif.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM CHECK_CHANGENO                                           *
*---------------------------------------------------------------------*
*  Check change number:
*  New form of change_aennrf, but with additional interface parameter.
*  Get key date, check effectivity, etc.
*  If effectivity is activated for one class type, it should be
*  activated for all class types of that object type
*  (case: classifications are copied from different class types).
*---------------------------------------------------------------------*
form check_changeno
     using disp_mode         type c
           value(changeno)   like rmclf-aennr1
           p_date            like rmclf-datuv1
           value(class_type) like tcla-klart
           call_from_api     like rmclf-kreuz            "Note 1520557
           p_subrc           like sy-subrc.

  data:
    l_display     like csdata-xfeld,
    l_datum       like sy-datum,
    l_class       like klah-class,
    l_flg_aepf    like csdata-xfeld,
    l_date_aepf   like aepf-date_lo,
    xccin         like ccin.

  clear p_subrc.
  if changeno is initial.
    exit.
  else.
    xccin-aennr = changeno.
    xccin-aeobj = '5'.
    xccin-aeclt = '3'.
    if disp_mode = c_display or
       disp_mode = kreuz.
      l_display = kreuz.
    else.
      clear l_display.
    endif.
  endif.
  if not class_type is initial.
*   class type with effectivity ?
    call function 'CLEF_EFFECTIVITY_USED'
         exporting
              i_aennr          = changeno
              i_classtype      = class_type
         importing
              e_effe_datum     = g_effectivity_date
              e_effe_aennr     = g_effectivity_used
              e_effe_gltart    = l_class
         exceptions
              klart_not_active = 1
              others           = 4.
    if sy-subrc <> 0.
      clear g_effectivity_used .
    endif.
  endif.

* CALLED_FROM_API intends to control error processing          v 1701552
* misusing it to control change number checks allows changes
* that must not be allowed (e.g. by BAPIs)
* retrieve instead ALE flag set by IDoc processing, if available
  DATA l_ale_flg TYPE C.

  CALL FUNCTION 'CLCN_ALE_FLG'
    EXPORTING command = 'GET'
              old_flg = call_from_api
    IMPORTING ale_flg = l_ale_flg.                            "^ 1701552

* Falls Effectivity nicht aktiv: Änderungsdatum übernehmen
  call function 'CC_CHANGE_NUMBER_CHECK'
       exporting
            eccin                  = xccin
            flg_display            = l_display
            flg_s163               = 'N'
            flg_ale                = l_ale_flg       "  1520557  1701552
       importing
            adatuv                 = l_datum
            aclass                 = l_class  " effectivity type
            flg_aepf               = l_flg_aepf
            a_date_lo              = l_date_aepf
       exceptions
            error_aenr             = 1
            error_class            = 2
            error_date_restriction = 3
            error_status           = 4
            others                 = 10.

  p_subrc = sy-subrc.
  if sy-subrc is initial.
    if g_effectivity_used is initial.
*--   normal change number with key date
      p_date = l_datum.
      if g_cl_ta = kreuz and
         sy-binpt is initial.
*       message: displayed in CL transactions.
        message w042(29) with l_datum. "#EC *
      endif.

    else.
*--   Effectivity
      if not l_flg_aepf is initial.
        l_datum = l_date_aepf.
      endif.
      if l_datum is initial.
        l_datum = sy-datum.
      endif.
      p_date = l_datum.

*   ECM initialisieren:
*   Bei der Klassifizierung keine Pflegebewertung im Popup
*  'nebenher' erlauben: i_batch = x.
      call function 'CLEF_ECM_PROCESSOR_INIT'
           exporting
                key_date        = l_datum
                i_aennr         = changeno
                i_batch         = kreuz
                i_maintain_flag = kreuz
*               i_no_pop_up     = kreuz
           exceptions
                ecm_init_error       = 1
                exit_from_dynpro     = 2
                no_maintenance_data  = 3
                others               = 6.
      if sy-subrc = 1.
        message e167.
*       'Fehler beim Initialisieren Parametergültigkeit'
      elseif sy-subrc = 3.
        message e173 with changeno.
*       'Zur Änderungsnummer & existiert noch keine Pflegebewertung'
      endif.
      if sy-binpt is initial.
        message w139(cl) with changeno space l_datum.
      endif.
    endif.
  else.
  endif.

endform.                               " check_changeno
