*&---------------------------------------------------------------------*
*& Report ZFI_AP_OPENITEM_C07
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_AP_OPENITEM_C07.

INCLUDE zfi_iap_openitem_c07_top.
INCLUDE zfi_iap_openitem_c07_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.

  INCLUDE zfi_iap_openitem_c07_sub.
  INCLUDE zfi_iap_openitem_c07_forms.
