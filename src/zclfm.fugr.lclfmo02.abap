*---------------------------------------------------------------------*
*       MODULE MODIFY_SCREEN_600 OUTPUT (REl. 4.6)
*---------------------------------------------------------------------*
*       ÄNDERUNGSNUMMER-POPUP                                         *
*---------------------------------------------------------------------*
module modify_screen_600 output.

  check classif_status = c_display  or  tcla-effe_act = kreuz.

  if tcla-effe_act = kreuz.
*   Button Param.gült. wird angezeigt:
*   wenn Parameterdaten in memory, Icon (Haken) als Kennung anzeigen.
    perform set_effe_icon.
  endif.

  perform modify_screen_600 .

endmodule.                             "  modify_screen_600
