*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_P01
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM GET_DATA CHANGING GIT_FILE.
  PERFORM PROCESS_DATA USING GIT_FILE.
