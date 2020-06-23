*&---------------------------------------------------------------------*
*&      Module  SETZEN_CURSOR OUTPUT
*&---------------------------------------------------------------------*
MODULE SETZEN_CURSOR OUTPUT.
  CHECK KT_ZEILEN_NR NE SPACE.
  SET CURSOR FIELD 'SKTEXT-SPRAS' LINE KT_ZEILEN_NR.
  CLEAR KT_ZEILEN_NR.

ENDMODULE.                             " SETZEN_CURSOR OUTPUT
