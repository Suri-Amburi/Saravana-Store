*&---------------------------------------------------------------------*
*& Include          ZMM_CATEGORY_AGE_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
TABLES : MARA .
PARAMETERS : CATEGORY TYPE KLASSE_D . "OBLIGATORY .
SELECT-OPTIONS : PLANT  FOR LV_WERKS NO INTERVALS .
SELECT-OPTIONS : GROUP  FOR MARA-MATKL NO INTERVALS .
SELECTION-SCREEN : END OF BLOCK B1 .
*IF PLANT IS INITIAL.
*
*  MESSAGE 'Please enter the Plant' TYPE 'I' DISPLAY LIKE 'E'.      ""TYPE 'S' DISPLAY LIKE 'E'.
*
*ENDIF.
DATA: BEGIN OF IT_FIN OCCURS 0,
        CLASS TYPE KLAH-CLASS,
      END OF IT_FIN.
DATA: IT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR CATEGORY.
  SELECT CLASS FROM KLAH INTO TABLE IT_FIN WHERE
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
      VALUE_TAB       = IT_FIN
*     FIELD_TAB       =
      RETURN_TAB      = IT_RETURN
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.

  ENDIF.

*  IF IT_RETURN IS NOT INITIAL .
  WRITE IT_RETURN-FIELDVAL TO CATEGORY.
*  ELSE.
*    LEAVE TO LIST-PROCESSING .
*  ENDIF.
  REFRESH IT_FIN .