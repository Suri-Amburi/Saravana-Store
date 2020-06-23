*&---------------------------------------------------------------------*
*& Report ZB1_S4_MAP_INSERT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zb1_s4_map_insert.

INCLUDE zb1_s4_map_insert_top.
INCLUDE zb1_s4_map_insert_sel.
INCLUDE zb1_s4_map_insert_sub.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.
START-OF-SELECTION.
  PERFORM get_data     CHANGING git_file.
  PERFORM process_data USING    git_file.
