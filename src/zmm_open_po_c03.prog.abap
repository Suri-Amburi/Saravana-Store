*&---------------------------------------------------------------------*
*& Report ZMM_OPEN_PO_C03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_OPEN_PO_C03.

INCLUDE ZMM_IOPEN_PO_C03_TOP1.
INCLUDE ZMM_IOPEN_PO_C03_SEL_1.
INCLUDE ZMM_IOPEN_PO_C03_FORM1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.

  PERFORM GET_DATA CHANGING GIT_FILE.
  PERFORM PROCESS_DATA USING GIT_FILE.

  PERFORM FIELD_CATLOG.
  PERFORM DISPLAY_OUTPUT.
