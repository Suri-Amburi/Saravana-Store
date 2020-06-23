*&---------------------------------------------------------------------*
*& Report ZMM_VK12_CHANGE_MARGIN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_VK12_CHANGE_DISCOUNT.


INCLUDE ZMM_VK12_CHANGE_DISCOUNT_TOP.
INCLUDE ZMM_VK12_CHANGE_DISCOUNT_SEL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

PERFORM GET_DATA CHANGING GIT_FILE.
PERFORM PROCESS_DATA USING GIT_FILE.
PERFORM FIELD_CATLOG.
PERFORM DISPLAY_OUTPUT.

INCLUDE ZMM_VK12_CHANGE_DISCOUNT_FORM.
