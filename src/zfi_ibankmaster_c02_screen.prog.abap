*&---------------------------------------------------------------------*
*& Include          ZFI_IBANKMASTER_C02_SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_FILE  TYPE RLGRAP-FILENAME,
             P_TRANS TYPE CHAR4 OBLIGATORY DEFAULT 'FI01'.
SELECTION-SCREEN END OF BLOCK B1.
