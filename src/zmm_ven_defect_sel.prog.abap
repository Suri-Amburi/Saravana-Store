*&---------------------------------------------------------------------*
*& Include          ZMM_VEN_DEFECT_SEL
*&---------------------------------------------------------------------*
TABLES : ekko , klah .
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
SELECT-OPTIONS   : P_EBELN for ekko-EBELN NO INTERVALS NO-EXTENSION,
                 P_LIFNR for ekko-LIFNR NO INTERVALS NO-EXTENSION,
                 GROUP_ID for klah-class NO INTERVALS NO-EXTENSION.
SELECT-OPTIONS : S_DATE FOR LV_BUDAT .

PARAMETERS     : GOOD RADIOBUTTON GROUP R1,
                 BAD  RADIOBUTTON GROUP R1,
                 ALL  RADIOBUTTON GROUP R1.

SELECTION-SCREEN : END OF BLOCK B1 .

DATA: BEGIN OF IT_FIN1 OCCURS 0,
        CLASS TYPE KLAH-CLASS,
      END OF IT_FIN1.
DATA: IT_RETURN1 LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR GROUP_ID-low .
  SELECT CLASS FROM KLAH INTO TABLE IT_FIN1 WHERE
    WWSKZ = '0'
  AND KLART = '026'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'CLASS'
*     PVALKEY         = ' '
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
*     DYNPROFIELD     =
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      VALUE_ORG       = 'S'
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*     IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = IT_FIN1
*     FIELD_TAB       =
      RETURN_TAB      = IT_RETURN1
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.

  ENDIF.

*  IF IT_RETURN IS NOT INITIAL .
  WRITE IT_RETURN1-FIELDVAL TO GROUP_ID.
*  ELSE.
*    LEAVE TO LIST-PROCESSING .
*  ENDIF.
  REFRESH IT_FIN1 .
