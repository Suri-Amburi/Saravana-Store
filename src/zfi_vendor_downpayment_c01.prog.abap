*&---------------------------------------------------------------------*
*& Report ZFI_VENDOR_DOWNPAYMENT_C01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_VENDOR_DOWNPAYMENT_C01.

INCLUDE zfi_vendor_downpayment_c01_top.
INCLUDE zfi_vendor_downpayment_c01_scr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.

  INCLUDE zfi_vendor_downpayment_c01_sub.
  INCLUDE zfi_vendor_downpayment_c01_frm.
