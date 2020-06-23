*&---------------------------------------------------------------------*
*& Report ZFI_AS91_ABLDT_OI_C04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_AS91_ABLDT_OI_C04.

INCLUDE zfi_as91_abldt_oi_c04_top.
INCLUDE zfi_as91_abldt_oi_c04_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
  INCLUDE zfi_as91_abldt_oi_c04_sub.
  INCLUDE zfi_as91_abldt_oi_c04_forms.
