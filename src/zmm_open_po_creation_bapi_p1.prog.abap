*&---------------------------------------------------------------------*
*& Include          ZMM_OPEN_PO_CREATION_BAPI_P1
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM GET_DATA  CHANGING GT_FILE.
  PERFORM PROCESS_DATA USING GT_FILE.

   PERFORM FIELD_CATLOG ."CHANGING LT_FIELDCAT.
    PERFORM DISPLAY_OUTPUT.
