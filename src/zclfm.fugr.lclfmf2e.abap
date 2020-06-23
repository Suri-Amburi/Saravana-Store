*§-----------------------------------------------------------------*
*        LÖSCHEN                                                   *
*------------------------------------------------------------------*
*        FORM POPUP_LOESCHEN                                       *
*------------------------------------------------------------------*
*        Wollen Sie wirklich loeschen?                             *
*------------------------------------------------------------------*
form popup_loeschen.

*-- Objekt für Löschbestätigung
  data: l_objekt   like kssk-objek,
        l_text(50) .


  if g_zuord <> c_zuord_4.
*   authority check
*   cl24: check when starting transaction
    perform auth_check_class_maint
            using klastab-clint
                  pm_class
                     tcd_stat
                     'E'             " msg type
            changing g_subrc.
  endif.

  if g_appl eq konst_w.
    call function 'POPUP_TO_CONFIRM_STEP'
         exporting
              titel     = text-122
              textline1 = text-123
         importing
              answer    = antwort.
  else.
*   Textline2: Abh. von Klasse oder Objekt
    if g_zuord = c_zuord_4.
      call function 'CLCV_CONV_EXIT'
           exporting
                ex_object      = rmclf-objek
                table          = sobtab
           importing
                im_object      = l_objekt
           exceptions
                tclo_not_found = 1
                others         = 2.
    else.
      l_objekt = pm_class.
    endif.
    l_text = text-121.
    replace '$' with l_objekt into l_text .
    call function 'POPUP_TO_CONFIRM_STEP'
         exporting
              titel     = text-120
              textline1 = l_text
              textline2 = text-124
         importing
              answer    = antwort.
  endif.
  case antwort.
    when ja.
      if g_appl eq konst_w.
        perform loeschen_mark.
      else.
        perform loeschen.
        g_klastab_val_idx = 0.         " val. subscreen to be closed
      endif.
      if not rmclf-pagpos is initial.
        rmclf-pagpos = 1.
      endif.
      index_neu    = 1.
    when nein.
      if g_appl eq konst_w.
        loop at klastab where markupd = kreuz.
          clear klastab-markupd.
          modify klastab.
        endloop.
      endif.
*      zeile = zeile - index_neu + 1.
      leave screen.
    when abbr.
      if g_appl eq konst_w.
        loop at klastab where markupd = kreuz.
          clear klastab-markupd.
          modify klastab.
        endloop.
      endif.
*      zeile = zeile - index_neu + 1.
      leave screen.
  endcase.
endform.
