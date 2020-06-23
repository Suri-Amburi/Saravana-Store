*----------------------------------------------------------------------*
*   INCLUDE LMGD1F06                                                   *
*----------------------------------------------------------------------*
*-----------------------------------------------------------------------
*  Erster_Tag_Periode
*Zu einem Datum wird der erste Tag in der zugehörigen Periode bestimmt.
*Das Ergebnis wird im gleichen Feld zurückgegeben.
*-----------------------------------------------------------------------
FORM ERSTER_TAG_PERIODE USING D1 OPT.

DATA:   BEGIN OF DATXX,                "Datum (Hilfsfeld)
              DATJJ(4) TYPE N,         "Jahr
              DATMM(2) TYPE N,         "Monat
              DATTT(2) TYPE N,         "Tag
        END OF DATXX.

CASE PERKZ.
  WHEN 'T'.                                " tageweise (nur Arbeitstage)
    IF OPT = '-'.
       PERFORM DATE_TO_FACTORYDATE_MINUS USING D1.
       MOVE SYFDATE TO D1.
    ELSE.
       PERFORM DATE_TO_FACTORYDATE_PLUS USING D1.
       MOVE SYFDATE TO D1.
    ENDIF.
  WHEN 'W'.                                " wöchentlich
    PERFORM DATE_COMPUTE_DAY USING D1.
    D1 = D1 + 1 - SY-FDAYW.
  WHEN 'M'.                                " monatlich
    MOVE D1 TO DATXX.
    DATXX-DATTT = '01'.
    MOVE DATXX TO D1.
  WHEN 'P'.                                "Buchungsperioden
    CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
         EXPORTING
              EANZPR = 1
              EDATUM = D1
              EPERIV = PERIV
         TABLES
              PPERX = INT_PPER
         EXCEPTIONS
               T009B_FEHLERHAFT     = 01
               T009_NICHT_GEFUNDEN  = 02.
    IF SY-SUBRC = 0.
      READ TABLE INT_PPER INDEX 1.
      MOVE INT_PPER-VONTG TO D1.
    ENDIF.

ENDCASE.

ENDFORM.
