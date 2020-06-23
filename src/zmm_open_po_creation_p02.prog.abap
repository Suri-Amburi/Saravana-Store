*&---------------------------------------------------------------------*
*& Include          ZMM_OPEN_PO_CREATION_P02
*&---------------------------------------------------------------------*

START-OF-SELECTION.
    PERFORM GET_DATA CHANGING GT_FILE.
      PERFORM PROCESS_DATA.
