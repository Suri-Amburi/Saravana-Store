*&---------------------------------------------------------------------*
*&      Form  ok_STAT
*&---------------------------------------------------------------------*
*       Change classification status.
*       call popup to get new status.
*       Consider:
*       This form is called indirectly when okcode has been bent
*       in pai module check_status !
*----------------------------------------------------------------------*
form ok_stat.

  perform change_clfy_status.

endform.                               " ok_stat
