*&---------------------------------------------------------------------*
*&      Module  EAN_EINTRAEGE_ERMITT  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Anzahl Einträge und Nummer des Eintrags in der          *
*       ersten Zeile (für Anzeige: Einträge ____ / ____ ).            *
*----------------------------------------------------------------------*
MODULE EAN_EINTRAEGE_ERMITT OUTPUT.

  EAN_EINTRAEGE_C   = EAN_LINES.
  IF EAN_LINES = 0.
    EAN_ERSTE_ZEILE_C = 0.
  ELSE.
    EAN_ERSTE_ZEILE_C = EAN_ERSTE_ZEILE + 1.
  ENDIF.

ENDMODULE.                             " EAN_EINTRAEGE_ERMITT  OUTPUT
