*&---------------------------------------------------------------------*
*& Report ZMM_VK11_ZKP0_CREATE_NEW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_vk11_zkp0_create_new.

INCLUDE zmm_vk12_zkp0_create_new_top.
INCLUDE zmm_vk12_zkp0_create_new_sel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.


START-OF-SELECTION.

  PERFORM get_data CHANGING git_file.
  PERFORM process_data USING git_file.
  PERFORM field_catlog.
  PERFORM display_output.

  INCLUDE zmm_vk12_zkp0_create_new_form.
