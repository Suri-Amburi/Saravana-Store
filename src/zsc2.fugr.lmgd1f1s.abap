*-------------------------------------------------------------------
*    DATE_TO_FACTORYDATE_PLUS
* Zu einem Datum wird die Nummer des nächsten Arbeitstages im
* Fabrikkalender bestimmt.
*-------------------------------------------------------------------
FORM DATE_TO_FACTORYDATE_PLUS USING D1.
*ATA: FACDATE LIKE SCAL-FACDATE.

CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
     EXPORTING
          CORRECT_OPTION = '+'
          DATE = D1
          FACTORY_CALENDAR_ID = T001W-FABKL
     IMPORTING
          DATE = SYFDATE
          FACTORYDATE = SYFDAYF
*         WORKINGDAY_INDICATOR = I03
     EXCEPTIONS
          OTHERS = 01.
IF SY-SUBRC NE 0.
   MESSAGE E298. " RAISING CALENDAR_NOT_COMPLETE.
ENDIF.

*Y-FDAYF = FACDATE.

ENDFORM.
