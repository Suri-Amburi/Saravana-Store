*&---------------------------------------------------------------------*
*& Report ZBP_VENDOR_T
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBP_VENDOR_T1.

INCLUDE ZMM_IVENDOR_MASTER_C01_TOP1.
*INCLUDE zmm_ivendor_master_c01_top.
INCLUDE ZMM_IVENDOR_MASTER_C01_SCREEN1.
*INCLUDE zmm_ivendor_master_c01_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
INCLUDE ZMM_IVENDOR_MASTER_C01_SUB1.
*  INCLUDE zmm_ivendor_master_c01_sub.
INCLUDE ZMM_IVENDOR_MASTER_C01_FORMS1.
*  INCLUDE zmm_ivendor_master_c01_forms.
