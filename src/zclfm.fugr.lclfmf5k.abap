*------------------------------------------------------------------*
*        FORM OK_ENDE
*------------------------------------------------------------------*
*        Beenden Klassifizierung
*------------------------------------------------------------------*
form ok_ende.

  data: l_exit type sy-batch.
*  DATA lv_next_action VALUE 'X'.                    "2448166  "2688521

  if classif_status = c_display.
    l_exit = kreuz.
  else.
    perform leave_clfy changing l_exit.
  endif.

  if l_exit = kreuz.
*    if SOKCODE = okende.                            "2448166  "2688521
*      export lv_next_action to MEMORY ID 'WWSCL24'. "2448166  "2688521
*    endif.                                          "2448166  "2688521
    export sokcode to MEMORY ID 'WWSCL24'.                     "2688521
    set screen dy000.
    leave screen.
  endif.

endform.                               " ok_ende
