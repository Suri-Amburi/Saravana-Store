*&---------------------------------------------------------------------*
*& Report ZFI_CUSTOMER_DOWNPAYMENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_CUSTOMER_DOWNPAYMENT.

INCLUDE zfi_customer_downpayment_top.
INCLUDE zfi_customer_downpayment_scr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.

  INCLUDE zfi_customer_downpayment_sub.
  INCLUDE zfi_customer_downpayment_forms.
