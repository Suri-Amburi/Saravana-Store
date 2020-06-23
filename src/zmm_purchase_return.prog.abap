*&---------------------------------------------------------------------*
*& Report ZMM_PURCHASE_RETURN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_PURCHASE_RETURN.
SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_EBELN TYPE EKKO-EBELN.
SELECTION-SCREEN: END OF BLOCK B1.

CALL FUNCTION 'ZFM_PURCHASE_FORM'
  EXPORTING
    LV_EBELN       = P_EBELN
    RETURN_PO      = 'X'
    PRINT_PRIEVIEW = 'X'.
