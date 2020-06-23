*&---------------------------------------------------------------------*
*& Report ZMM_VK12_CHANGE_MARGIN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_VK12_ZKP0_CREATE.


INCLUDE ZMM_VK12_ZKP0_CREATE_TOP.
INCLUDE ZMM_VK12_ZKP0_CREATE_SEL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

PERFORM GET_DATA CHANGING GIT_FILE.
PERFORM PROCESS_DATA USING GIT_FILE.
PERFORM FIELD_CATLOG.
PERFORM DISPLAY_OUTPUT.

INCLUDE ZMM_VK12_ZKP0_CREATE_FORM.
