*&---------------------------------------------------------------------*
*& Report ZFI_ACCOUNTANT_DIARY_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_CFO_DIARY_REP.
INCLUDE ZFI_CFO_DIARY_TOP.
*INCLUDE ZFI_ACCOUNTANT_DIARY_TOP.
INCLUDE ZFI_CFO_DIARY_SEL.
*INCLUDE ZFI_ACCOUNTANT_DIARY_SEL.
INCLUDE ZFI_CFO_DIARY_FORM.
*INCLUDE ZFI_ACCOUNTANT_DIARY_FORM.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM DISPLAY.
  PERFORM FIELD_CAT .
