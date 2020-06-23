*&---------------------------------------------------------------------*
*& Report ZMM_SOURCE_LIST_CT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_SOURCE_LIST_CT.

include zmm_source_list_c06_top.
include zmm_source_list_c06_sel.

at selection-screen on value-request for p_file.
  perform get_filename changing p_file.

start-of-selection.
  include zmm_source_list_c06_rou.
  include zmm_soSurce_list_c06_sub.
