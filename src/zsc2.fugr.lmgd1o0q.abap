*&---------------------------------------------------------------------*
*&      Module  ME_EINTRAEGE_ERMITTELN  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Anzahl Einträge und Nummer des Eintrags in der          *
*       ersten Zeile (für Anzeige: Einträge ____ / ____ ).            *
*----------------------------------------------------------------------*
MODULE ME_EINTRAEGE_ERMITTELN OUTPUT.

  ME_EINTRAEGE_C   = ME_LINES.
  IF ME_LINES = 0.
    ME_ERSTE_ZEILE_C = 0.
  ELSE.
    ME_ERSTE_ZEILE_C = ME_ERSTE_ZEILE + 1.
  ENDIF.

  CLEAR SMEINH.    "cfo/20.9.96 weil nicht alle Felder immer auf
  "dem Subscreen sind und dann nach PAI-Transporten
                                       "noch der alte Wert drinsteht.
ENDMODULE.                             " ME_EINTRAEGE_ERMITTELN  OUTPUT
