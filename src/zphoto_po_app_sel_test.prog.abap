*&---------------------------------------------------------------------*
*& Include          ZPHOTO_PO_APP_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
TABLES : ZPH_T_HDR , MARA,ZSIZE_VAL.
SELECT-OPTIONS : S_DATE FOR ZPH_T_HDR-PDATE .
SELECT-OPTIONS : S_SIZE FOR  ZSIZE_VAL-ZSIZE NO-DISPLAY.
SELECTION-SCREEN : END OF BLOCK B1 .
