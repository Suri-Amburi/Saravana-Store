*&---------------------------------------------------------------------*
*&      Module  EAN_SETZEN_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Cursor auf EAN_ZEILEN_NR abhängig vom Fehler
*----------------------------------------------------------------------*
MODULE EAN_SETZEN_CURSOR OUTPUT.

  CHECK EAN_ZEILEN_NR NE SPACE.

  IF NOT EAN_FEHLERFLG_ME IS INITIAL.
    SET CURSOR FIELD 'SMEINH-MEINH' LINE EAN_ZEILEN_NR.
  ELSE.
* AHE: 23.08.96 - A
    IF NOT EAN_FEHLERFLG_LFEAN IS INITIAL.
      SET CURSOR FIELD 'MLEA-LFEAN' LINE EAN_ZEILEN_NR.
    ELSE.
* AHE: 23.08.96 - E
      SET CURSOR FIELD 'MEAN-HPEAN' LINE EAN_ZEILEN_NR.
    ENDIF.                             " AHE: 23.08.96
  ENDIF.

  CLEAR EAN_ZEILEN_NR.

ENDMODULE.                             " EAN_SETZEN_CURSOR  OUTPUT
