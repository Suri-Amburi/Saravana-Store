*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_R_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

*SELECT-OPTIONS: s_matnr FOR lv_matnr,
*                s_charg FOR lv_charg,
*                s_werks FOR lv_werks,
SELECT-OPTIONS: s_date FOR edidc-credat.



SELECTION-SCREEN: END OF BLOCK b1.
