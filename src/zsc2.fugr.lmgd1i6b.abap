*&---------------------------------------------------------------------*
*&      Module  ZEILE_ERMITTELN  INPUT
*&---------------------------------------------------------------------*
MODULE ZEILE_ERMITTELN INPUT.

  IF SY-STEPL = 1.                     " AHE: 13.02.96
    CLEAR EAN_FEHLERFLG.
  ENDIF.

*  Akt. Tabellenzeile ermitteln
  EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + SY-STEPL.

ENDMODULE.                             " ZEILE_ERMITTELN  INPUT
