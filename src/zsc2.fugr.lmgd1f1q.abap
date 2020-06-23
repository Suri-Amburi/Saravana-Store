*-------------------------------------------------------------------
*    DATE_COMPUtE_DAY
* Zu einem Datum wird der zug. Kalendertag bestimmt
* ( 1=Mo, 2=Di.... 7=So )
*-------------------------------------------------------------------
FORM DATE_COMPUTE_DAY USING D1.

DATA: WOTAG LIKE SCAL-INDICATOR.

CALL FUNCTION 'DATE_COMPUTE_DAY_ENHANCED'              "note 1329727
     EXPORTING
          DATE = D1
     IMPORTING
          DAY = WOTAG.

SY-FDAYW = WOTAG.

ENDFORM.
