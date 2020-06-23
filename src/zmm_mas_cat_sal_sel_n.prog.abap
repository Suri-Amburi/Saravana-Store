*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 .

SELECT-OPTIONS : s_matkl FOR lv_matkl .
*                   S_PLANT FOR LV_PLANT NO INTERVALS .

SELECTION-SCREEN : END OF BLOCK b1 .
