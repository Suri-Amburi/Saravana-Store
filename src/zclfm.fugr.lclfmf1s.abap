*§-----------------------------------------------------------------*
*        SONSTIGES                                                 *
*------------------------------------------------------------------*
*        FORM BEENDEN                                              *
*------------------------------------------------------------------*
*        Beenden Klassifizierung                                   *
*------------------------------------------------------------------*
form beenden.

  data: l_save type c.

  if classif_status eq drei.
    set screen dy000.
    leave screen.
  endif.

* Prüfen, ob irgendwelche Änderungen zu sichern sind.
* D.h. Popup-Fenster öffnen ?
  loop at allausp where statu <> space.
    l_save = kreuz.
    exit.
  endloop.

  if l_save = space.
    loop at allkssk where vbkz ne space .          " neue Zuordnungen
*     Änderungen in Zuordnungen vorhanden.
      l_save = kreuz.
      exit.
    endloop.
    if l_save = space.
      loop at klastab where statuaen = kreuz.
*       Änderungen in Status vorhanden.
        l_save = kreuz.
        exit.
      endloop.
      if l_save is initial.
*-- Es gibt keine Änderungen! Verlassen möglich
        if sokcode = oknezu.
          leave to transaction syst-tcode.
        else.
          set screen dy000.
          leave screen.
        endif.
      endif.
    endif.
  endif.

* g_zuord = space: CLFM von anderer TA aufgerufen, in der dann
*                  Bestätigungs-Popup generiert wird.
  if ( g_zuord <> space  and  l_save  <> space )
                         or   syst-tcode = tcodeclw1.
    call function 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
              titel     = text-100
              textline1 = text-101
         IMPORTING
              answer    = antwort.
    case antwort.
      when ja.
        if g_cl_ta eq kreuz or
           syst-tcode = tcodeclw1.
          okcode  = oksave.
        else.
          okcode  = okweit.
        endif.
        sokcode = oksave.
      when nein.
        if syst-calld = kreuz.
          if g_cl_ta eq kreuz.
            export space to memory id tcodecl22.
            leave.
          endif.
        endif.
        perform beenden_ohne.
      when abbr.
    endcase.
  else.
*   transaction from object
    if sokcode = okabbr.
      if nof8 = kreuz.
        back_ok = sokcode.
        perform beenden_ohne.
      else.
        okcode  = okweit.
        back_ok = sokcode.
      endif.
    else.
      okcode  = okweit.
      back_ok = sokcode.
    endif.
  endif.

endform.
