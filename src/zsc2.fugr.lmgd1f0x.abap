*&---------------------------------------------------------------------*
*&      Form  TEXT_ZUM_NUMMERNTYP
*&---------------------------------------------------------------------*
* Es wird der Text zum Nummerntyp ermittelt und auf 20 Zeichen reduziert
*----------------------------------------------------------------------*
FORM TEXT_ZUM_NUMMERNTYP.

  IF NOT MEINH-NUMTP IS INITIAL.
* Bezeichnung Nummerntyp immer neu lesen, da nicht in MEINH vorhanden
* cfo/19.05.95
*   IF MEINH-NTBEZ20 IS INITIAL.
    CLEAR RM03E-NTBEZ20.
    PERFORM LESEN_TNTPB USING SY-LANGU MARM-NUMTP.
    IF SY-SUBRC EQ 0.
*       MEINH-NTBEZ20 = TNTPB-NTBEZ.
*       MODIFY MEINH INDEX AKT_ZEILE.
*       RM03E-NTBEZ20 = MEINH-NTBEZ20.
      RM03E-NTBEZ20 = TNTPB-NTBEZ.
    ENDIF.
*   ELSE.
*     RM03E-NTBEZ20 = MEINH-NTBEZ20.
*   ENDIF.
  ELSE.
    CLEAR RM03E-NTBEZ20.
  ENDIF.

ENDFORM.                               " TEXT_ZUM_NUMMERNTYP
