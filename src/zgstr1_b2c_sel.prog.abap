*&---------------------------------------------------------------------*
*& Include          ZGSTR1_B2C_SEL
*&---------------------------------------------------------------------*
****************************Selection Screen designing

SELECTION-SCREEN: BEGIN OF BLOCK S1 WITH FRAME TITLE TEXT-001.

**PARAMETERS: PMONTH TYPE FCMNR .
**PARAMETERS: PFYEAR TYPE GJAHR.
PARAMETERS : P_MONTH TYPE CHAR2 as LISTBOX VISIBLE LENGTH 30 ,P_FYEAR TYPE CHAR4 .

PARAMETERS :TAXCODE RADIOBUTTON GROUP RB1.
PARAMETERS :HSN RADIOBUTTON GROUP RB1.

SELECTION-SCREEN:END OF BLOCK S1.

INITIALIZATION.
  DATA: IT_LIST  TYPE VRM_VALUES.
  DATA: WA_LIST  TYPE VRM_VALUE.
  REFRESH : IT_LIST.
  CLEAR : WA_LIST.
  WA_LIST-KEY = '01'.
  WA_LIST-TEXT = 'January'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '02'.
  WA_LIST-TEXT = 'February'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '03'.
  WA_LIST-TEXT = 'March'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '04'.
  WA_LIST-TEXT = 'April'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '05'.
  WA_LIST-TEXT = 'May'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '06'.
  WA_LIST-TEXT = 'June'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '07'.
  WA_LIST-TEXT = 'July'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '08'.
  WA_LIST-TEXT = 'August'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '09'.
  WA_LIST-TEXT = 'September'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '10'.
  WA_LIST-TEXT = 'October'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '11'.
  WA_LIST-TEXT = 'November'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '12'.
  WA_LIST-TEXT = 'December'.
  APPEND WA_LIST TO IT_LIST.

  SORT IT_LIST ASCENDING BY KEY.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'P_MONTH'
      VALUES          = IT_LIST
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

AT SELECTION-SCREEN ON P_MONTH.
  DATA :IT_VALUES TYPE TABLE OF DYNPREAD,
        WA_VALUES TYPE DYNPREAD.
  CLEAR: WA_VALUES, IT_VALUES.
  REFRESH IT_VALUES.
  WA_VALUES-FIELDNAME = 'P_MONTH'.
  APPEND WA_VALUES TO IT_VALUES.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = SY-REPID
      DYNUMB             = SY-DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = IT_VALUES.
