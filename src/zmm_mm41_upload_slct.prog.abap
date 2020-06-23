*&---------------------------------------------------------------------*
*& Include          ZMM_MM41_UPLOAD_SLCT
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS:p_file TYPE STRING."rlgrap-filename.
PARAMETERS:pv_front RADIOBUTTON GROUP grp TYPE char1 DEFAULT 'X',
           pv_bg    RADIOBUTTON GROUP grp TYPE char1.

SELECTION-SCREEN END OF BLOCK b1.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
   PERFORM get_filename CHANGING p_file.
