*-------------------------------------------------------------------
* DATUMSAUFBEREITUNG
*Länderspezifische Datumsaufbereitung
*-------------------------------------------------------------------
FORM DATUMSAUFBEREITUNG USING D1 P1.

DATA: FLAGM(1)    TYPE C,
      FLAGW(1)    TYPE C,
      MDAT6       LIKE IVERB-PRIOD,
      WDAT6       LIKE IVERB-PRIOD,
      TDAT8       LIKE IVERB-PRIOD.

IF PERKZ = 'P'.
     CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
          EXPORTING
               EANZPR = 1
               EDATUM = D1
               EPERIV = PERIV
          TABLES
               PPERX = INT_PPER.
     READ TABLE INT_PPER INDEX 1.
     MOVE INT_PPER-PRPER+4(2)  TO TDAT8.
     MOVE '/'                  TO TDAT8+2.
     MOVE INT_PPER-PRPER(4)    TO TDAT8+3.
     MOVE TDAT8 TO P1.
     EXIT.
ENDIF.

CASE PERKZ.
     WHEN 'M'.
           CLEAR FLAGW.
           FLAGM = 'X'.
     WHEN 'W'.
           CLEAR FLAGM.
           FLAGW = 'X'.
     WHEN 'T'.
           CLEAR FLAGM.
           CLEAR FLAGW.
ENDCASE.

CALL FUNCTION 'DATUMSAUFBEREITUNG'
     EXPORTING
          FLAGM = FLAGM
          FLAGW = FLAGW
          IDATE = D1
     IMPORTING
          MDAT6 = MDAT6
          TDAT8 = TDAT8
          WDAT6 = WDAT6
     EXCEPTIONS
          DATFM_UNGUELTIG = 01
          DATUM_UNGUELTIG = 02.

IF SY-SUBRC = 1.
   MESSAGE E312.
ENDIF.
IF SY-SUBRC = 2.
   MESSAGE E298. " RAISING CALENDAR_NOT_COMPLETE.
ENDIF.

CASE PERKZ.
     WHEN 'M'.
           MOVE MDAT6 TO P1.
     WHEN 'W'.
           MOVE WDAT6 TO P1.
     WHEN 'T'.
           MOVE TDAT8 TO P1.
ENDCASE.

ENDFORM.
