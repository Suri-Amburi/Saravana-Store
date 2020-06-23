*&---------------------------------------------------------------------*
*& Report ZBP_VENDOR_EMP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBP_VENDOR_EMP.

INCLUDE ZMM_IVENDOR_MASTERR_C01_TOP.
INCLUDE ZMM_IVENDOR_MASTERR_C01_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.
  INCLUDE ZMM_IVENDOR_MASTERR_C01_SUB.
  INCLUDE ZMM_IVENDOR_MASTERR_C01_FORMS.
