*&---------------------------------------------------------------------*
*& Include          ZMM_PRICE_CHANGE_SEL
*&---------------------------------------------------------------------*

TABLES : T023 .

SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
SELECT-OPTIONS   : GROUP FOR T023-MATKL NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN : END OF BLOCK B1 .

DATA: BEGIN OF IT_FIN1 OCCURS 0,
        T023 TYPE T023-MATKL,
      END OF IT_FIN1.
DATA: IT_RETURN1 LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR GROUP-LOW .
  SELECT MATKL FROM T023 INTO TABLE IT_FIN1 .


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MATKL'
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
  WRITE IT_RETURN1-FIELDVAL TO GROUP.
*  ELSE.
*    LEAVE TO LIST-PROCESSING .
*  ENDIF.
  REFRESH IT_FIN1 .
