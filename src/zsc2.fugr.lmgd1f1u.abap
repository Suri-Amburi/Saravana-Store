*-----------------------------------------------------------------------
*  Naechste_Periode
*Zum ersten Tag einer Periode wird der erste Tag der nächsten Periode
*bestimmt und dem gleichen Feld mitgegeben
*-----------------------------------------------------------------------
FORM NAECHSTE_PERIODE USING D1.

DATA:   BEGIN OF DATXX,                "Datum (Hilfsfeld)
              DATJJ(4) TYPE N,         "Jahr
              DATMM(2) TYPE N,         "Monat
              DATTT(2) TYPE N,         "Tag
        END OF DATXX.

CASE PERKZ.
  WHEN 'T'.                                " tageweise (nur Arbeitstage)
     PERFORM DATE_TO_FACTORYDATE_PLUS USING D1.
     SYFDAYF = SYFDAYF + 1.
     PERFORM FACTORYDATE_TO_DATE USING SYFDAYF.
     MOVE SYFDATE TO D1.
  WHEN 'W'.                                " wöchentlich
     D1    = D1    + 7.
  WHEN 'M'.                                " monatlich
     MOVE D1 TO DATXX.
     DATXX-DATMM = DATXX-DATMM + 1.
     IF DATXX-DATMM GT 12.
        DATXX-DATMM = 1.
        DATXX-DATJJ = DATXX-DATJJ + 1.
     ENDIF.
     MOVE DATXX TO D1.
  WHEN 'P'.                                " buchhaltungsper.
   IF NO_T009B_ABEND = SPACE.
     CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
          EXPORTING
               EANZPR = 2
               EDATUM = D1
               EPERIV = PERIV
          TABLES
               PPERX = INT_PPER.
     READ TABLE INT_PPER INDEX 2.
     MOVE INT_PPER-VONTG TO D1.
   ELSE.
     CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
          EXPORTING
               EANZPR = 2
               EDATUM = D1
               EPERIV = PERIV
          TABLES
               PPERX = INT_PPER
          EXCEPTIONS
               T009B_FEHLERHAFT = 01.
     IF SY-SUBRC = 0.
       READ TABLE INT_PPER INDEX 2.
       MOVE INT_PPER-VONTG TO D1.
     ELSE.
       T009B_ERROR = X.
     ENDIF.
   ENDIF.
ENDCASE.

ENDFORM.
