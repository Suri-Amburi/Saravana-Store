*&---------------------------------------------------------------------*
*& Report ZFI_AP_OPENITEM_C05
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_AP_OPENITEM_C05.

INCLUDE zfi_iap_openitem_c05_top.
INCLUDE zfi_iap_openitem_c05_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.

  INCLUDE zfi_iap_openitem_c05_sub.
  INCLUDE zfi_iap_openitem_c05_forms.
