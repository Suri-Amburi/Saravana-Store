*&---------------------------------------------------------------------*
*& Include          ZMM_MAS_CAT_SAL_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .

  SELECT-OPTIONS : S_MATKL FOR LV_MATKL ,
                   S_PLANT FOR LV_PLANT NO INTERVALS .

SELECTION-SCREEN : END OF BLOCK B1 .
