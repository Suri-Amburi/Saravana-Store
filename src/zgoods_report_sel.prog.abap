*&---------------------------------------------------------------------*
*& Include          ZGOODS_REPORT_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN:BEGIN OF BLOCK S1 WITH FRAME TITLE TEXT-001.
      SELECT-OPTIONS : S_DOCN FOR LV_MATN.
      SELECT-OPTIONS : S_GRN FOR LV_GRN .
      SELECTION-SCREEN:END OF BLOCK S1.
