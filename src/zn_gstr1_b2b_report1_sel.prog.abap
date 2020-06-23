*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_B2B_REPORT1_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_date FOR  vbrk-fkdat,
                s_bukrs FOR vbrk-bukrs OBLIGATORY NO INTERVALS DEFAULT '1000',
                s_werks FOR vbrp-werks ,
                s_kunnr for kna1-kunnr.
SELECTION-SCREEN : END OF BLOCK b1.
