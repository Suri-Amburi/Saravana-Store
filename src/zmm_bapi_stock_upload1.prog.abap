*&---------------------------------------------------------------------*
*& Report ZMM_BAPI_STOCK_UPLOAD1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_BAPI_STOCK_UPLOAD1.

INCLUDE ZMM_BAPI_STOCK_UPLOAD1_TOP.
INCLUDE ZMM_BAPI_STOCK_UPLOAD1_SEL.
INCLUDE ZMM_BAPI_STOCK_UPLOAD1_FORM.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.

  PERFORM GET_DATA CHANGING GIT_FILE.
  PERFORM PROCESS_DATA USING GIT_FILE.
