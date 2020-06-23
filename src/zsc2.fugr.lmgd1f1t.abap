*-------------------------------------------------------------------
*    FACTORYDATE_TO_DATE
* Zur Nummer eines Arbeitstages im Fabrikkalender wird das zugehörige
* Datum bestimmt.
*-------------------------------------------------------------------
FORM FACTORYDATE_TO_DATE USING F1.

CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
     EXPORTING
          FACTORYDATE = F1
          FACTORY_CALENDAR_ID = T001W-FABKL
     IMPORTING
          DATE = SYFDATE
     EXCEPTIONS
          FACTORYDATE_AFTER_RANGE = 01
          FACTORYDATE_BEFORE_RANGE = 02
          FACTORYDATE_INVALID = 03
          FACTORY_CALENDAR_ID_MISSING = 04
          FACTORY_CALENDAR_NOT_FOUND = 05.

IF SY-SUBRC NE 0.
   MESSAGE E298.  " RAISING CALENDAR_NOT_COMPLETE.
ENDIF.

ENDFORM.
