*&---------------------------------------------------------------------*
*& Report ZMM_VK11_ZEAN_CREATE_NEW1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_VK11_ZEAN_CREATE_NEW1.

INCLUDE ZMM_VK11_ZEAN_CREATE_NEW1_top.
INCLUDE ZMM_VK11_ZEAN_CREATE_NEW1_sel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.


START-OF-SELECTION.

  PERFORM get_data CHANGING git_file.
  PERFORM process_data USING git_file.
  PERFORM field_catlog.
  PERFORM display_output.

  INCLUDE ZMM_VK11_ZEAN_CREATE_NEW1_form.
