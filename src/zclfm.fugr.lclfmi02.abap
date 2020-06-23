*&---------------------------------------------------------------------*
*&      Module  MODIFY_ZAEHL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module modify_zaehl input.

  check rmclf-zaehl <> klastab-zaehl.
  check klastab-objek <> space.
* es werden auch gleiche Sortierpositionen akzeptiert!

  klastab-zaehl = rmclf-zaehl.
  modify klastab index index_neu
                 transporting zaehl.

  read table allkssk index klastab-index_tab.
  allkssk-zaehl = rmclf-zaehl.
  if allkssk-vbkz <> c_insert.
    allkssk-vbkz = c_update.
    aenderflag = kreuz .
  endif.
  modify allkssk index klastab-index_tab
                 transporting zaehl vbkz.

endmodule.                             " MODIFY_ZAEHL  INPUT
