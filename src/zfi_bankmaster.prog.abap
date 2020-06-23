*&---------------------------------------------------------------------*
*& Report ZFI_BANKMASTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_BANKMASTER.

INCLUDE ZFI_IBANKMASTER_C02_TOP.
INCLUDE ZFI_IBANKMASTER_C02_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.

  INCLUDE ZFI_IBANKMASTER_C02_ROUTINE.
  INCLUDE ZFI_IBANKMASTER_C02_FORMS.
