*&---------------------------------------------------------------------*
*&      Module  ANZAHL_EINTRAEGE  INPUT
*&---------------------------------------------------------------------*
MODULE ANZAHL_EINTRAEGE INPUT.

* ------ Ermitteln Anzahl Verbrauchseinträge ------------------------
* ------ hier zur Auswertung der Blätter-FCodes benötigt
  IF KZVERB = 'U'.
    DESCRIBE TABLE UNG_VERBTAB LINES VW_LINES.
  ELSE.
    DESCRIBE TABLE GES_VERBTAB LINES VW_LINES.
  ENDIF.
*wk/4.0 switch to tc
  IF NOT FLG_TC IS INITIAL.
    TC_VERB-LINES = VW_LINES.
  ENDIF.
ENDMODULE.                             " ANZAHL_EINTRAEGE  INPUT
