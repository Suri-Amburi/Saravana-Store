*&---------------------------------------------------------------------*
*& Include          ZFI_PURCHASE_JOURNAL_R51_SCR
*&---------------------------------------------------------------------*
DATA:GV_BELNR TYPE BKPF-BELNR.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_BELNR FOR GV_BELNR.
PARAMETERS : P_BUKRS LIKE BKPF-BUKRS DEFAULT '1000',
             P_GJAHR LIKE BKPF-GJAHR." DEFAULT '2016'.
SELECTION-SCREEN END OF BLOCK B1.
