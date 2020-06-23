*&---------------------------------------------------------------------*
*& Include          ZPP_BOM_CREATION_UPLOAD_SCREEN
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS : p_file TYPE string.

PARAMETERS:pv_front RADIOBUTTON GROUP grp TYPE char1 DEFAULT 'X',
           pv_bg    RADIOBUTTON GROUP grp TYPE char1.

SELECTION-SCREEN END OF BLOCK b1.
