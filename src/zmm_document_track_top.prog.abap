*&---------------------------------------------------------------------*
*& Include          ZMM_DOCUMENT_TRACK_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF TY_ZDOC_T_TRACK ,
          QR_CODE      TYPE ZQR_CODE,
          INWD_DOC     TYPE ZINWD_DOC,
          STATUS       TYPE ZDC_STATUS,
          CREATED_DATE TYPE ERDAT,
          SENDER       TYPE ZSENDER,
          RECEIVER     TYPE ZREC,
        END OF TY_ZDOC_T_TRACK .

TYPES : BEGIN OF TY_HDR,
          QR_CODE  TYPE ZQR_CODE,
          INWD_DOC type zINWD_DOC ,
          LIFNR    TYPE ELIFN,
          NAME1    type NAME1_GP ,
          BILL_NUM TYPE  ZBILL_NUM,
          ERDATE   type  ERDAT ,
        END OF TY_HDR .
TYPES : BEGIN OF TY_FINAL ,
          QR_CODE      TYPE ZQR_CODE,
          INWD_DOC     TYPE ZINWD_DOC,
          STATUS(20)   TYPE C,
          STATUS1      TYPE ZDC_STATUS,
          SENDER       TYPE ZSENDER,
          RECEIVER     TYPE ZREC,
          CREATED_DATE TYPE ERDAT,
          LIFNR        TYPE ELIFN,
          NAME1        TYPE NAME1_GP,
          BILL_NUM     TYPE ZBILL_NUM,
        END OF TY_FINAL .
TYPES : BEGIN OF TY_DATA ,
          QR_CODE      TYPE ZINW_T_HDR-QR_CODE,
          LIFNR        TYPE  ZINW_T_HDR-LIFNR,
          BILL_NUM     TYPE  ZINW_T_HDR-BILL_NUM,
          NAME1        TYPE  ZINW_T_HDR-NAME1,
          INWD_DOC     TYPE ZDOC_T_TRACK-INWD_DOC,
          STATUS       TYPE ZDOC_T_TRACK-STATUS,
          CREATED_DATE TYPE ZDOC_T_TRACK-CREATED_DATE,
          SENDER       TYPE  ZDOC_T_TRACK-SENDER,
          RECEIVER     TYPE ZDOC_T_TRACK-RECEIVER,

        END OF TY_DATA .


TYPES : BEGIN OF TY_ZINW_T_HDR ,
          QR_CODE      TYPE ZINW_T_HDR-QR_CODE,
          INWD_DOC     TYPE ZINW_T_HDR-INWD_DOC,
          LIFNR        TYPE ZINW_T_HDR-LIFNR,
          NAME1        TYPE ZINW_T_HDR-NAME1,
          BILL_NUM     TYPE ZINW_T_HDR-BILL_NUM,
          STATUS       TYPE ZDOC_T_TRACK-STATUS,
          CREATED_DATE TYPE ZDOC_T_TRACK-CREATED_DATE,
          SENDER       TYPE ZDOC_T_TRACK-SENDER,
          RECEIVER     TYPE ZDOC_T_TRACK-RECEIVER,
        END OF TY_ZINW_T_HDR .

DATA : IT_ZDOC_T_TRACK TYPE TABLE OF TY_ZDOC_T_TRACK,
       IT_ZINW_T_HDR   TYPE TABLE OF TY_HDR,
       IT_ZINW_T_HDR1   TYPE TABLE OF TY_ZINW_T_HDR,
       WA_ZDOC_T_TRACK TYPE TY_ZDOC_T_TRACK,
       IT_FINAL        TYPE TABLE OF TY_FINAL,
       WA_FINAL        TYPE TY_FINAL,
       GT_DATA         TYPE TABLE OF TY_DATA,
       GT_DATA1        TYPE TABLE OF TY_DATA,
       WA_DATA         TYPE  TY_DATA.
