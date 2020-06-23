*------------------------------------------------------------------*
*       MODULE SETZEN_KREUZ_D604 INPUT                             *
*------------------------------------------------------------------*
*       Markieren/Entmarkieren CL24 Tabelle für Filter             *
*------------------------------------------------------------------*
module setzen_kreuz_d604.
  read table tabausw index index_neu.
  check syst-subrc = 0.
  if rmclf-kreuz is initial.
    if tabausw-kreuz = kreuz.
      clear tabausw-kreuz.
      modify tabausw index index_neu.
    endif.
  else.
    if tabausw-kreuz is initial.
      tabausw-kreuz = kreuz.
      modify tabausw index index_neu.
    endif.
  endif.
endmodule.
