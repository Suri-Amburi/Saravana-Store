*&---------------------------------------------------------------------*
*& Report ZB1_S4_MAP_S4BATCH_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zb1_s4_map_s4batch_update.

INCLUDE zb1_s4_map_s4batch_update_top.
INCLUDE zb1_s4_map_s4batch_update_sel.
INCLUDE zb1_s4_map_s4batch_update_sub.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.
START-OF-SELECTION.
  PERFORM get_data     CHANGING git_file.
  PERFORM process_data USING    git_file.
