*&---------------------------------------------------------------------*
*& Report ZFI_CASH_PAYMENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_CASH_PAYMENT.

INCLUDE ZFI_CASH_PAYMENT_F50_TOP.
INCLUDE ZFI_CASH_PAYMENT_F50_SCR.

START-OF-SELECTION.

  INCLUDE ZFI_CASH_PAYMENT_F50_ROU.
  INCLUDE ZFI_CASH_PAYMENT_F50_FRM.
