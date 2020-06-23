*&---------------------------------------------------------------------*
*& Report ZMM_BP_VEND_EXT_C
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_BP_VEND_EXT_C.

include zmm_bp_vend_ext_top.
include zmm_bp_vend_ext_sel.
include zmm_bp_vend_ext_form.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

start-of-selection.

  perform get_data.
  perform upload_vendor.
  perform display_data.
