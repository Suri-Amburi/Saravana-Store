*------------------------------------------------------------------*
*       MODULE SETZEN_KREUZ INPUT                                  *
*------------------------------------------------------------------*
*       Dynpro 601, 602
*------------------------------------------------------------------*
module setzen_kreuz input.

  check rmclf-radio = kreuz.

  if syst-dynnr = dy601.
    loop at itclc where kreuz = kreuz.
      clear itclc-kreuz.
      modify itclc.
    endloop.
    read table itclc index index_neu1.
    itclc-kreuz = kreuz.
    modify itclc index syst-tabix.

  elseif sy-dynnr = dy602.
*   save marked object type temporarily in this trx
    read table redun with key radio = punkt.
    if sy-subrc = 0.
      clear redun-radio.
      modify redun index sy-tabix transporting radio.
    endif.
    read table redun index redun1-index.
    redun-radio = punkt.
    modify redun index redun1-index transporting radio.
    zeile1 = index_neu1.
  endif.

endmodule.
