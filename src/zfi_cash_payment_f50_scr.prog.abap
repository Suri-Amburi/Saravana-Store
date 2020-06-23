*&---------------------------------------------------------------------*
*& Include          ZFI_CASH_PAYMENT_F50_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_BELNR FOR GV_BELNR NO INTERVALS NO-EXTENSION." OBLIGATORY. " 1000149
PARAMETERS :    P_BUKRS LIKE BKPF-BUKRS OBLIGATORY,   " 1000
                P_GJAHR LIKE BKPF-GJAHR OBLIGATORY.   " 2017
SELECTION-SCREEN END OF BLOCK B1.
