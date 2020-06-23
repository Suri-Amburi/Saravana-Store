*------------------------------------------------------------------*
*       MODULE INIT_D602 OUTPUT                                    *
*------------------------------------------------------------------*
*       Setzen Text im Dynpro 602.
*       CL24 Funktion Neue Zuordnung oder
*       CLFM_Os_CL (aendern).
*------------------------------------------------------------------*
module init_d602 output.
  read table redun index redun1-index.
  rmclf-texto = redun-obtxt.
  if redun-radio = punkt.
    rmclf-radio = kreuz.
  endif.
endmodule.
