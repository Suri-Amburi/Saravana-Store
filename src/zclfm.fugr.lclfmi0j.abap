*------------------------------------------------------------------*
*       Die Module sind geordnet nach                              *
*          1.) OK-CODE Modulen                                     *
*          2.) STEPL-LOOP Modulen                                  *
*          3.) Sonstiges                                           *
*------------------------------------------------------------------*
*       MODULE OK_BEENDEN INPUT                                    *
*------------------------------------------------------------------*
*       OK-Code AT EXIT-COMMAND                                    *
*------------------------------------------------------------------*
module ok_beenden input.
  sokcode = okcode.
  clear okcode.
  zeile = 0.
  if cn_mark > 0.
    loop at klastab where markupd = kreuz.
      clear klastab-markupd.
      modify klastab.
    endloop.
    clear cn_mark.
    clear markzeile1.
    leave screen.
  endif.
  perform beenden.
endmodule.
