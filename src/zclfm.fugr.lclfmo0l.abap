*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_ECM  OUTPUT
*&---------------------------------------------------------------------*
*       Ein/Ausblenden Felder für Aenderungsnummer
*----------------------------------------------------------------------*
module modify_screen_ecm output.

  check not change_subsc_act is initial.      " Aend.nummer

  if rmclf-datuv1 is initial.
    rmclf-datuv1 = sy-datum.
  endif.

  if tcla-effe_act is initial.
*-- Effectivity nicht möglich
    loop at screen.
      check screen-group4 = 'EIN'.
      if cl_status = c_change.
        if screen-name = 'RMCLF-DATUV1'.
*          continue.
        endif.
      endif.
      if g_sel_changed = space.
        screen-input   = '0'.
      else.
        screen-input   = '1'.
      endif.
      screen-output    = '1'.
      screen-invisible = '0'.
      modify screen.
    endloop.

  else.
*-- Effectivity möglich: Feld für ÄNNR und Datum,
*--                      Button Parametergültigkeit nur im Anzeigemodus
    if classif_status = space  or
       classif_status = c_display.
*     Button wird angezeigt:
*     wenn Parameterdaten in memory, Icon (Haken) als Kennung anzeigen.
      perform set_effe_icon.
    endif.
    loop at screen.
      case screen-group4.
        when 'EIN'.
          if g_sel_changed = space.
            screen-input   = '0'.
          else.
            screen-input   = '1'.
          endif.
          screen-output    = '1'.
          screen-invisible = '0'.
          modify screen.
        when 'PAR'.
          if cl_status = c_display.
            screen-invisible = '0'.
          endif.
          if screen-group2 = 'SET'.
            if not g_para_set is initial.
              screen-invisible = '1'.
            endif.
          endif.
          modify screen.
      endcase.
    endloop.
  endif.

endmodule.                             " MODIFY_SCREEN_ECM  OUTPUT
