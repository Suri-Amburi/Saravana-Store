*&---------------------------------------------------------------------*
*& Include          ZSD_SHIPMENT_PACKING_REP_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

   SELECT-OPTIONS: S_VBELN FOR LV_VBELN NO-EXTENSION NO INTERVALS .

SELECTION-SCREEN : END OF BLOCK B1.
