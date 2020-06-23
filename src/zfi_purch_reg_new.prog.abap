*&---------------------------------------------------------------------*
*& Report ZFI_PURCH_REG_NEW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_PURCH_REG_NEW.
INCLUDE ZFI_PURCHASE_REG_NEW_TOP .
*INCLUDE ZFI_PURCHASE_REG_SEL .
START-OF-SELECTION .
INCLUDE ZFI_PURCHASE_REG_NEW_SUB .
INCLUDE ZFI_PURCHASE_REG_NEW_F01 .
