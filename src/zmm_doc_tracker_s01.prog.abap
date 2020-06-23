*&---------------------------------------------------------------------*
*& Include          ZMM_DOC_TRACKER_S01
*&---------------------------------------------------------------------*
*SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
 TABLES : ZINW_T_HDR .
 PARAMETERS :

   P_LIFNR TYPE LIFNR.
 SELECT-OPTIONS :  P_BILL  FOR ZINW_T_HDR-BILL_NUM  NO INTERVALS .            ""ZBILL_NUM.
*SELECTION-SCREEN : END OF BLOCK B1 .
