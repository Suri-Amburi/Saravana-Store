*&---------------------------------------------------------------------*
*& Report ZFI_AS91_AB01_ABLDT_C10
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_AS91_AB01_ABLDT_C10.

INCLUDE ZFI_AS91_AB01_ABLDT_TOP.
INCLUDE ZFI_AS91_AB01_ABLDT_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.
  INCLUDE ZFI_AS91_AB01_ABLDT_SUB.
  INCLUDE ZFI_AS91_AB01_ABLDT_FORMS.
