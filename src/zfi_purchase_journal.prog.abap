*&---------------------------------------------------------------------*
*& Report ZFI_PURCHASE_JOURNAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_PURCHASE_JOURNAL.

INCLUDE ZFI_PURCHASE_JOURNAL_R51_TOP.
INCLUDE ZFI_PURCHASE_JOURNAL_R51_SCR.

START-OF-SELECTION.

  INCLUDE ZFI_PURCHASE_JOURNAL_R51_ROU.
  INCLUDE ZFI_PURCHASE_JOURNAL_R51_FRM.
