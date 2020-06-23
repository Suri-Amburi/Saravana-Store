*&---------------------------------------------------------------------*
*& Report ZHR_012_INFOTYPE_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT ZHR_012_INFOTYPE_UPDATE.

INCLUDE ZHR_012_INFOTYPE_UPDATE_TOP.
INCLUDE ZHR_012_INFOTYPE_UPDATE_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.

  INCLUDE ZHR_012_INFOTYPE_UPDATE_ROU.
  INCLUDE ZHR_012_INFOTYPE_UPDATE_SUB.
