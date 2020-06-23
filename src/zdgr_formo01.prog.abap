*&---------------------------------------------------------------------*
*& Include          ZDGR_FORMO01
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
SELECT-OPTIONS :  S_DATE FOR LV_DATE OBLIGATORY no INTERVALS no-EXTENSION DEFAULT sy-datum.
SELECT-OPTIONS :  S_PLANT  FOR LV_WERKS NO INTERVALS.
SELECTION-SCREEN : END OF BLOCK B1 .
