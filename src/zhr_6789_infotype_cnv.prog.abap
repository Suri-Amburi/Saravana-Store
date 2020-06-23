*&---------------------------------------------------------------------*
*& Report ZHR_6789_INFOTYPE_CNV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHR_6789_INFOTYPE_CNV.


INCLUDE zhr_i6789_infotype_cnv_top.
INCLUDE zhr_i6789_infotype_cnv_screen.
*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_0006.
  PERFORM get_filename CHANGING p_0006.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_0007.
  PERFORM get_filename CHANGING p_0007.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_0008.
  PERFORM get_filename CHANGING p_0008.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_0009.
  PERFORM get_filename CHANGING p_0009.

START-OF-SELECTION.
*
  INCLUDE zhr_i6789_infotype_cnv_rou.
  INCLUDE zhr_i6789_infotype_cnv_sub.
