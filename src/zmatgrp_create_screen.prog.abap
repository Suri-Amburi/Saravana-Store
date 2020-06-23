*&---------------------------------------------------------------------*
*& Include          ZPP_IBOM_CREATION_C02_SCREEN
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

PARAMETERS : P_FILE TYPE STRING.

PARAMETERS:PV_FRONT RADIOBUTTON GROUP GRP TYPE CHAR1 DEFAULT 'X',
           PV_BG    RADIOBUTTON GROUP GRP TYPE CHAR1,
           PV_BG1   RADIOBUTTON GROUP GRP TYPE CHAR1.
*           PV_BG2   RADIOBUTTON GROUP GRP TYPE CHAR1.

SELECTION-SCREEN END OF BLOCK B1.
