*&---------------------------------------------------------------------*
*& Report ZFI_AR_OPENITEM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_AR_OPENITEM.
INCLUDE zfi_iar_openitem_c05_top.
INCLUDE zfi_iar_openitem_c05_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.

  INCLUDE zfi_iar_openitem_c05_sub.
  INCLUDE zfi_iar_openitem_c05_forms.
