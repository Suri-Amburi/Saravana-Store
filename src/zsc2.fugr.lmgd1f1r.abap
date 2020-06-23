*-------------------------------------------------------------------
*    DATE_TO_FACTORYDATE_MINUS
* Zu einem Datum wird die Nummer des vorhergehenden Arbeitstages im
* Fabrikkalender bestimmt (d.h. Arbeitstag kleiner gleich Datum)
*-------------------------------------------------------------------
FORM DATE_TO_FACTORYDATE_MINUS USING D1.

CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
     EXPORTING
          CORRECT_OPTION = '-'
          DATE = D1
          FACTORY_CALENDAR_ID = T001W-FABKL
     IMPORTING
          DATE = SYFDATE
          FACTORYDATE = SYFDAYF
*         WORKINGDAY_INDICATOR = I03
     EXCEPTIONS
          CORRECT_OPTION_INVALID = 01
          DATE_AFTER_RANGE = 02
          DATE_BEFORE_RANGE = 03
          DATE_INVALID = 04
          FACTORY_CALENDAR_NOT_FOUND = 05.

IF SY-SUBRC NE 0.
   MESSAGE E298. " RAISING CALENDAR_NOT_COMPLETE.
ENDIF.

ENDFORM.
