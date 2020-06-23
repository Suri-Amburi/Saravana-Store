*&---------------------------------------------------------------------*
*& Include          ZEAN_POS_UPLOAD_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM get_data CHANGING p_file.
  PERFORM process_data.
  PERFORM display_data.
