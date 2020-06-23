*&---------------------------------------------------------------------*
*& Include          ZSD_INVOICE_IDOC_U_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_file TYPE string.
PARAMETERS : p_bg RADIOBUTTON GROUP rb1.
PARAMETERS : p_fg RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.
