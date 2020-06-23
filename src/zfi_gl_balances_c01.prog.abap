*&---------------------------------------------------------------------*
*& Report ZFI_GL_BALANCES_C01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_GL_BALANCES_C01.

INCLUDE zfi_igl_balances_c01_top.
INCLUDE zfi_igl_balances_c01_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
  INCLUDE zfi_igl_balances_c01_sub.
  INCLUDE zfi_igl_balances_c01_forms.
