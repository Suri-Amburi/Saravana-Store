*&---------------------------------------------------------------------*
*& Include          ZMM_DOCUMENT_TRACK_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
TABLES : ZDOC_T_TRACK , ZINW_T_HDR .
SELECT-OPTIONS : QR_CODE FOR ZDOC_T_TRACK-QR_CODE NO INTERVALS,
                 DATE    FOR ZDOC_T_TRACK-CREATED_DATE ,
                 VENDOR FOR ZINW_T_HDR-LIFNR NO INTERVALS,
                 BILL_NO FOR ZINW_T_HDR-BILL_NUM NO INTERVALS,
                 S_STATUS FOR ZDOC_T_TRACK-STATUS NO-DISPLAY.
PARAMETERS : SAP_ROOM AS CHECKBOX,
             WARH     AS CHECKBOX,
             ACCOUNTS AS CHECKBOX,
             AUDITOR  AS CHECKBOX.

SELECTION-SCREEN: END OF BLOCK B1 .
