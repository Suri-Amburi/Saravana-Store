*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_EOD_PO_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN : BEGIN OF  BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : S_DATE FOR GV_DATE.
SELECTION-SCREEN : END   OF  BLOCK B1.
