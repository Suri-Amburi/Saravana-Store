*&---------------------------------------------------------------------*
*& Include          ZPO_STATUS_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_ekgrp FOR ekko-ekgrp,
                s_aedat FOR ekko-aedat,
                date FOR lv_date DEFAULT sy-datum NO-EXTENSION NO INTERVALS NO-DISPLAY.
*PARAMETERS: DATE LIKE SY-DATUM DEFAULT SY-DATUM NO-DISPLAY.
SELECTION-SCREEN: END OF BLOCK b1.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ekgrp-low.

*SELECT *
*FROM T024
*UP TO <MAX_LINES> ROWS
*INTO CORRESPONDING FIELDS OF TARGET < TARGET > BYPASSING BUFFER WHERE( EKGRP LIKE 'P%' ).
*BREAK MPATIL.
  SELECT ekgrp eknam FROM t024 INTO TABLE it_t024 WHERE ekgrp LIKE 'P%'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      retfield        = 'EKGRP'
*     PVALKEY         = ' '
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'S_EKGRP-low'
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      value_org       = 'S'
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*   IMPORTING
*     USER_RESET      =
    TABLES
      value_tab       = it_t024
*     FIELD_TAB       =
*     RETURN_TAB      =
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
