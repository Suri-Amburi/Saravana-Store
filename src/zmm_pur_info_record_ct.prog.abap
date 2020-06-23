*&---------------------------------------------------------------------*
*& Report ZMM_PUR_INFO_RECORD_CT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_PUR_INFO_RECORD_CT.

INCLUDE zmm_purchase_info_record_top.

INCLUDE zmm_purchase_info_record_sel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
  PERFORM get_data     CHANGING git_file.
  PERFORM process_data USING git_file.
  PERFORM field_catlog.
  PERFORM display_alv.

INCLUDE zmm_purchase_info_record_form.
