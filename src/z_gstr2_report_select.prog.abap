*&---------------------------------------------------------------------*
*& Include          Z_GSTR2_REPORT_SELECT
*&---------------------------------------------------------------------*

"""""""""""""""""""""""" SELECTION SCREEN """"""""""""""""""""""""""
SELECTION-SCREEN : BEGIN OF BLOCK S1 WITH FRAME TITLE TEXT-001 .
PARAMETERS : P_MONTH TYPE CHAR2 as LISTBOX VISIBLE LENGTH 30 ,P_YEAR TYPE CHAR4 .
SELECTION-SCREEN : END OF BLOCK S1 .

"""""""""""""""""""" FOR DROPDOWN """"""""""""""""""""""""""""""""""""""
*at SELECTION-SCREEN OUTPUT .
*name = 'P_MONTH' .
**value-TEXT = 'January' .
**APPEND value-TEXT to list .
**value-TEXT = 'February'.
**APPEND value-TEXT to list .
**value-TEXT = 'March' .
**APPEND value-TEXT to list .
**value-TEXT = 'April' .
**APPEND value-TEXT to list .
**value-TEXT = 'May' .
**APPEND value-TEXT to list .
**value-TEXT = 'June' .
**APPEND value-TEXT to list .
**value-TEXT = 'July' .
**APPEND value-TEXT to list .
**value-TEXT = 'August' .
**APPEND value-TEXT to list .
**value-TEXT = 'September' .
**APPEND value-TEXT to list .
**value-TEXT = 'October' .
**APPEND value-TEXT to list .
**value-TEXT = 'November' .
**APPEND value-TEXT to list .
**value-TEXT = 'December' .
**APPEND value-TEXT to list .
*
*value-KEY = '01' .
*APPEND value-KEY  to list .
*value-KEY = '02' .
*APPEND value-KEY  to list .
*value-KEY = '03' .
*APPEND value-KEY  to list .
*value-KEY = '04' .
*APPEND value-KEY  to list .
*value-KEY = '05' .
*APPEND value-KEY  to list .
*value-KEY = '06' .
*APPEND value-KEY  to list .
*value-KEY = '07' .
*APPEND value-KEY  to list .
*value-KEY = '08' .
*APPEND value-KEY  to list .
*value-KEY = '09' .
*APPEND value-KEY  to list .
*value-KEY = '10' .
*APPEND value-KEY  to list .
*value-KEY = '11' .
*APPEND value-KEY  to list .
*value-KEY = '12' .
*APPEND value-KEY  to list .
*
*""""""""""""""""""""""""" FUNCTION MODULE FOR DROP DOWN """""""""""""""""""""""""""""""""""
*CALL FUNCTION 'VRM_SET_VALUES'
*  EXPORTING
*    ID                    = name
*    VALUES                = list .
** EXCEPTIONS
**   ID_ILLEGAL_NAME       = 1
**   OTHERS                = 2
*          .
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
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
      TRANSLATE_TO_UPPER = C_X
    TABLES
      DYNPFIELDS         = IT_VALUES.
