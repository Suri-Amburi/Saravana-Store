*&---------------------------------------------------------------------*
*& Report ZBP_VENDOR_T
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBP_VENDOR_T.

INCLUDE zmm_ivendor_master_c01_top.
INCLUDE zmm_ivendor_master_c01_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
  INCLUDE zmm_ivendor_master_c01_sub.
  INCLUDE zmm_ivendor_master_c01_forms.
