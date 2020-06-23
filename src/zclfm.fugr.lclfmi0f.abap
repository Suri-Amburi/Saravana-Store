*§-----------------------------------------------------------------*
*       Module im STEP-LOOP                                        *
*------------------------------------------------------------------*
*       REFRESH_KLASTAB INPUT                                      *
*------------------------------------------------------------------*
*       Die leeren Eintraege der KLASTAB werden gelöscht           *
*------------------------------------------------------------------*
module refresh_klastab input.
  delete klastab where objek = space or index_tab = 0 .

endmodule.
