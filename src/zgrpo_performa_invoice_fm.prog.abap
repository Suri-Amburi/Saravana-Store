*&---------------------------------------------------------------------*
*& Include          ZGRPO_PERFORMA_INVOICE_FM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FORM_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FORM_DISPLAY .

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME                 = 'ZGRPO_PERFORMA_INVOICE'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 IMPORTING
   FM_NAME                  = FM_NAME
 EXCEPTIONS
   NO_FORM                  = 1
   NO_FUNCTION_MODULE       = 2
   OTHERS                   = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


CALL FUNCTION FM_NAME.


ENDFORM.
