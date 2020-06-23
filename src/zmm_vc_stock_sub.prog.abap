*&---------------------------------------------------------------------*
*& Include          ZMM_VC_STOCK_SUB
*&---------------------------------------------------------------------*
START-OF-SELECTION .

  IF CATEGORY IS NOT INITIAL OR GROUP IS NOT INITIAL.
    PERFORM GETDATA.
    PERFORM DISPLAY.

  ELSE.
    MESSAGE 'Please enter value' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
