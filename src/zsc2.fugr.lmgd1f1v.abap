*-----------------------------------------------------------------------
*  Vorige_Periode
*Zum ersten Tag einer Periode wird der erste Tag der vorigen Periode
*bestimmt und dem gleichen Feld mitgegeben
*-----------------------------------------------------------------------
FORM VORIGE_PERIODE USING D1.

DATA:   BEGIN OF DATXX,                "Datum (Hilfsfeld)
              DATJJ(4) TYPE N,         "Jahr
              DATMM(2) TYPE N,         "Monat
              DATTT(2) TYPE N,         "Tag
        END OF DATXX.

CASE PERKZ.
  WHEN 'T'.                                " tageweise (nur Arbeitstage)
     PERFORM DATE_TO_FACTORYDATE_MINUS USING D1.
     SYFDAYF = SYFDAYF - 1.
     PERFORM FACTORYDATE_TO_DATE USING SYFDAYF.
     MOVE SYFDATE TO D1.
  WHEN 'W'.                                " wöchentlich
     D1    = D1    - 7.
  WHEN 'M'.                                " monatlich
     MOVE D1 TO DATXX.
     IF DATXX-DATMM = 1.
        DATXX-DATMM = 12.
        DATXX-DATJJ = DATXX-DATJJ - 1.
     ELSE.
        DATXX-DATMM = DATXX-DATMM - 1.
     ENDIF.
     MOVE DATXX TO D1.
  WHEN 'P'.
   D1 = D1 - 1.
   IF NO_T009B_ABEND = SPACE.
     CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
          EXPORTING
               EANZPR = 1
               EDATUM = D1
               EPERIV = PERIV
          TABLES
               PPERX = INT_PPER.
     READ TABLE INT_PPER INDEX 1.
     MOVE INT_PPER-VONTG TO D1.
   ELSE.
     CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
          EXPORTING
               EANZPR = 1
               EDATUM = D1
               EPERIV = PERIV
          TABLES
               PPERX = INT_PPER
          EXCEPTIONS
               T009B_FEHLERHAFT = 01.
     IF SY-SUBRC = 0.
       READ TABLE INT_PPER INDEX 1.
       MOVE INT_PPER-VONTG TO D1.
     ELSE.
       T009B_ERROR = X.
     ENDIF.
   ENDIF.
ENDCASE.

ENDFORM.
