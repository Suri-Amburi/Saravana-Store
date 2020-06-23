*&---------------------------------------------------------------------*
*&      Module  ME_SETZEN_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Cursor auf ME_ZEILEN_NR.                                *
*----------------------------------------------------------------------*
MODULE ME_SETZEN_CURSOR OUTPUT.

  CHECK ME_ZEILEN_NR NE SPACE.
  SET CURSOR FIELD 'SMEINH-MEINH' LINE ME_ZEILEN_NR.
  CLEAR ME_ZEILEN_NR.

ENDMODULE.                             " ME_SETZEN_CURSOR  OUTPUT
