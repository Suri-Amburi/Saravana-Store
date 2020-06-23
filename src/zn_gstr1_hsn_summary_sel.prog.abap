*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_HSN_SUMMARY_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-011.

SELECT-OPTIONS:S_BUDAT  FOR  VBRK-FKDAT.
SELECT-OPTIONS:S_BUKRS  FOR  VBRK-BUKRS NO INTERVALS NO-EXTENSION DEFAULT '1000'.
SELECT-OPTIONS:S_HSN    FOR  MARC-STEUC.
select-OPTIONS:s_werks  for  vbrp-werks.

SELECTION-SCREEN END OF BLOCK B1.
