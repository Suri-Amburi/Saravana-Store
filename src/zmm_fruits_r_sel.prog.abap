*&---------------------------------------------------------------------*
*& Include          ZMM_FRUITS_R_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS : s_plant FOR gv_plant NO INTERVALS." OBLIGATORY.
  SELECT-OPTIONS :  S_DATE FOR LV_DATE DEFAULT sy-datum.."OBLIGATORY DEFAULT sy-datum..


  SELECTION-SCREEN : END OF BLOCK b1 .
