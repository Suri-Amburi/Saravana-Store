*&---------------------------------------------------------------------*
*&      Module  MAX_SEITE_ERMITTELN  OUTPUT
*&---------------------------------------------------------------------*
*Setzen maximale Seitenanzahl.
* Aufbereitung für Eintragsanzeige : ' Einträge ___ / ___ '
*----------------------------------------------------------------------*
MODULE ZEILE_INT_TO_CHAR OUTPUT.

  KT_EINTRAEGE_C   = KT_LINES.
  IF KT_LINES = 0.
    KT_ERSTE_ZEILE_C = 0.
  ELSE.
    KT_ERSTE_ZEILE_C = KT_ERSTE_ZEILE + 1.
  ENDIF.


ENDMODULE.                             " ZEILE_INT_TO_CHAR OUTPUT
