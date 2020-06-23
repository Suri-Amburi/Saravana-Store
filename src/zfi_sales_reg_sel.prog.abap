*&---------------------------------------------------------------------*
*& Include          ZFI_SALES_REG_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-011.

SELECT-OPTIONS:S_FKDAT  FOR  VBRK-FKDAT .
SELECT-OPTIONS:S_FKART  FOR  VBRK-FKART .

SELECTION-SCREEN END OF BLOCK B1.
