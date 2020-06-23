*&---------------------------------------------------------------------*
*& Include          ZMM_CATEGORY_AGE_SUB
*&---------------------------------------------------------------------*
START-OF-SELECTION .

  IF PLANT IS NOT INITIAL .
    PERFORM GET_DATA.
    PERFORM DISPLAY.
  ELSE.
    MESSAGE 'Please enter the plant' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
