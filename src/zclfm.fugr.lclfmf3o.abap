*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_600  (REl. 4.6)
*&---------------------------------------------------------------------*
*       Dynpro-Feld-Modifikation
*----------------------------------------------------------------------*
form modify_screen_600.

  loop at screen.
    case screen-group4.
*     Datum
      when 'EIN'.
        screen-input     = '1'.
        screen-output    = '1'.
        screen-invisible = '0'.
        modify screen.

*     Button Parametergültigkeit / Icon für Existenz Parameterdaten
      when 'PAR'.
        if classif_status  = c_display.
          if not g_effectivity_used is initial.
            screen-invisible = '0'.
            if screen-group2 = 'SET'.
              if not g_para_set is initial.
                screen-invisible = '0'.
              endif.
            endif.
            modify screen.
          endif.
        endif.
    endcase.
  endloop.

endform.                               " MODIFY_SCREEN_600
