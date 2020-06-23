*&---------------------------------------------------------------------*
*& Report ZMM_VK11_ZMKP_CREATE_NEW1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_vk11_zmkp_create_new1.

INCLUDE zmm_vk11_zmkp_create_new1_top.
INCLUDE zmm_vk11_zmkp_create_new1_sel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.


START-OF-SELECTION.

  PERFORM get_data CHANGING git_file.
  PERFORM process_data USING git_file.
  PERFORM field_catlog.
  PERFORM display_output.

  INCLUDE zmm_vk11_zmkp_create_new1_form.
