*------------------------------------------------------------------*
*       MODULE SUPPRESS_DIALOG OUTPUT                              *
*------------------------------------------------------------------*
*       Klassifizierungsdynpros im Dunkeln                         *
*------------------------------------------------------------------*
module suppress_dialog output.
  if suppressd = kreuz.
    suppress dialog.
  endif.
endmodule.
