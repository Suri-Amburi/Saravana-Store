*&---------------------------------------------------------------------*
*& Report ZB1_S_PRICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zb1_s_price.

INCLUDE zb1_s_price_top.
INCLUDE zb1_s_price_sel.
INCLUDE zb1_s_price_sub.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.

  PERFORM get_data CHANGING git_file.
  PERFORM process_data USING git_file.
