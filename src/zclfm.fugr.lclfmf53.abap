*------------------------------------------------------------------*
*        FORM OK_NEZU
*------------------------------------------------------------------*
*        Start 'other allocation'.
*        -> start new classification transaction.
*------------------------------------------------------------------*
form ok_nezu.

  data: l_exit type sy-batch.

*  data lv_next_action VALUE 'X'.                 "2446147     "2688521

  if classif_status = c_display.
    l_exit = kreuz.
  else.
    perform leave_clfy changing l_exit.
  endif.

  if l_exit = kreuz.
*    export lv_next_action to MEMORY ID 'WWSCL24'."2446147     "2688521
    export sokcode to MEMORY ID 'WWSCL24'.                     "2688521
    leave.                             " leave in call mode
    leave to transaction sy-tcode.
  endif.

endform.                               " ok_nezu
