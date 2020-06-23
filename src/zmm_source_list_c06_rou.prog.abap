*&---------------------------------------------------------------------*
*& Include          ZMM_SOURCE_LIST_C06_ROU
*&---------------------------------------------------------------------*
  perform get_data changing git_file.
  perform process_data using git_file.
  perform field_catlog.
  perform display_alv.
