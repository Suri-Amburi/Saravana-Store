*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_REPORT_SUBROUTINE
*&---------------------------------------------------------------------*

*IF cat = 'X'.
*  PERFORM CATEGORY_WISE .
*  PERFORM DISPLAY_C.
*ELSEif ven = 'X'.
*  IF CATEGORY IS NOT INITIAL .

START-OF-SELECTION .
  IF CATEGORY IS NOT INITIAL OR GROUP IS NOT INITIAL.
  PERFORM VENDOR_WISE .
  PERFORM DISPLAY_V .

    ELSE.
    MESSAGE 'Please enter value' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
*  else .
*    MESSAGE 'Category should not be blank for vendor wise record' TYPE 'I' DISPLAY LIKE 'E' .
*  ENDIF.

*ENDIF.
