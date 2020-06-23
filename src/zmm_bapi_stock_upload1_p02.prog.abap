*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  IF SY-BATCH = SPACE.
    PERFORM GET_DATA CHANGING GT_FILE.
  ELSE.
    PERFORM BACKGROUND_JOB.
  ENDIF.
