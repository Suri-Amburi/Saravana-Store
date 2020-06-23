*------------------------------------------------------------------*
*       MODULE PAGPOS_OUT OUTPUT                                   *
*------------------------------------------------------------------*
*       Feld Einträge: Eingabe wegnehmen                           *
*------------------------------------------------------------------*
module pagpos_out output.
  if rmclf-pagpos = 0.
    loop at screen.
      if screen-name   = 'RMCLF-PAGPOS'.
        screen-input = off.
        modify screen.
        exit.
      endif.
    endloop.
  endif.
endmodule.
