*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_EXPORTS_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-011.

SELECT-OPTIONS:S_BUDAT  FOR  VBRK-FKDAT.
SELECT-OPTIONS:S_BUKRS  FOR  VBRK-BUKRS NO INTERVALS NO-EXTENSION DEFAULT '1000'.
select-OPTIONS:S_WERKS  FOR  VBRP-WERKS,
               S_KUNAG  FOR  VBRK-KUNAG.

SELECTION-SCREEN END OF BLOCK B1.
