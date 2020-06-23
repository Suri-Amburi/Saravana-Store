*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_SUMMARY_TOP
*&---------------------------------------------------------------------*


TYPES : BEGIN OF TY_MSEG,
          MBLNR      TYPE MBLNR,
          MJAHR      TYPE MJAHR,
          ZEILE      TYPE MBLPO,
          LIFNR      TYPE ELIFN,
          WERKS      TYPE WERKS_D,
          MATNR      TYPE MATNR,
          BWART      TYPE BWART,
          MENGE      TYPE MENGE_D,
          EBELN	     TYPE BSTNR,
          EBELP      TYPE EBELP,
          BUDAT_MKPF TYPE BUDAT,
        END OF TY_MSEG.

TYPES : BEGIN OF TY_MKPF ,
          MBLNR TYPE MBLNR,
          MJAHR TYPE MJAHR,
          BLDAT TYPE BLDAT,
        END OF TY_MKPF.

TYPES: BEGIN OF TY_LFA1,
         LIFNR TYPE LIFNR,
         LAND1 TYPE LAND1_GP,
         NAME1 TYPE NAME1_GP,
         STRAS TYPE STRAS_GP,
         ORT01 TYPE ORT01_GP,
         STCD3 TYPE STCD3,
         REGIO TYPE REGIO,
       END OF TY_LFA1.

TYPES : BEGIN OF TY_T001W,
          WERKS TYPE WERKS_D,
          NAME1 TYPE NAME1,
          STRAS TYPE STRAS,
          ORT01 TYPE ORT01,
          LAND1 TYPE LAND1,
        END OF TY_T001W.

TYPES: BEGIN OF TY_KONV,
         KNUMV TYPE KNUMV,
         KPOSN TYPE KPOSN,
         STUNR TYPE STUNR,
         ZAEHK TYPE DZAEHK,
         KSCHL TYPE KSCHA,
         KBETR TYPE KBETR,
       END OF TY_KONV.

*TYPES: BEGIN OF TY_EKPO,
*         EBELN TYPE EBELN,
*         EBELP TYPE EBELP,
*         NETWR TYPE BWERT,
*         NETPR TYPE BPREI,
*       END OF  TY_EKPO.

TYPES : BEGIN OF TY_MARA ,
          MATNR TYPE MARA-MATNR,
          EAN11 TYPE MARA-EAN11,
        END OF TY_MARA .

TYPES : BEGIN OF TY_EKKO,
          EBELN     TYPE EBELN,
          BSART     TYPE ESART,
          KNUMV     TYPE KNUMV,
          AEDAT     TYPE ERDAT,
          ZBD1T     TYPE DZBDET,
          ERNAM     TYPE ERNAM,
          EKGRP     TYPE EKGRP,
          USER_NAME TYPE ZUNAM,
        END OF TY_EKKO.

TYPES : BEGIN OF TY_T005U,
          SPRAS TYPE SPRAS,
          LAND1 TYPE LAND1,
          BLAND TYPE REGIO,
          BEZEI TYPE BEZEI20,
        END OF TY_T005U.

TYPES: BEGIN OF TY_MAKT,
         MATNR TYPE MATNR,
         SPRAS TYPE SPRAS,
         MAKTX TYPE MAKTX,
       END OF TY_MAKT.

TYPES : BEGIN OF TY_ZINW_T_HDR ,
          EBELN	     TYPE EBELN,
          LIFNR	     TYPE ELIFN,
          QR_CODE	   TYPE ZQR_CODE,
          TRNS       TYPE ZTRANS  , "CHAR  40  0 Transporter Name
          LR_NO      TYPE ZLR , "CHAR  20  0 L.R.NO
**          RCV_NO_BUD   TYPE ZRCV_NOB, " INT2  5 0 No.of Bundle
*          GRPO_NO    TYPE CHAR10,
*          GPRO_DATE  TYPE CHAR10,
*          GRPO_DATE  TYPE CHAR10,
          DUE_DATE   TYPE ZDUE_DATE,
*          GPRO_USER  TYPE CHAR10,
          MBLNR      TYPE MBLNR,
          MBLNR_103  TYPE MBLNR,
          BILL_NUM   TYPE ZBILL_NUM,
          BILL_DATE  TYPE ZBILL_DAT,
          ACT_NO_BUD TYPE ZNO_BUD,
          STATUS     TYPE ZSTATUS,
          INWD_DOC   TYPE ZINWD_DOC,
          LR_DATE    TYPE ZLR_DATE,
          TOTAL      TYPE BWERT,
          PUR_TOTAL  TYPE BWERT,
        END OF TY_ZINW_T_HDR .

TYPES : BEGIN OF TY_ZINW_T_ITEM ,
          QR_CODE  TYPE ZQR_CODE,
          EBELN	   TYPE EBELN,
          EBELP	   TYPE EBELP,
*          SNO      TYPE INT2,
          MATNR	   TYPE MATNR,
          LGORT	   TYPE LGORT_D,
          WERKS	   TYPE EWERK,
          MENGE_P  TYPE ZMENGE_P,
          MEINS	   TYPE BSTME,
          MAKTX	   TYPE MAKTX,
          NETPR_P	 TYPE ZBPREI_P,
          NETWR_P	 TYPE ZBPREI_PT,
          NETPR_GP TYPE ZBPREI_GP,
          NETPR_S  TYPE ZBPREI_S,
        END OF TY_ZINW_T_ITEM .
TYPES : BEGIN OF TY_ZINW_T_STATUS,
          INWD_DOC     TYPE ZINWD_DOC,
          QR_CODE      TYPE ZQR_CODE,
          STATUS_FIELD TYPE ZSTATUS_FIELD,
          STATUS_VALUE TYPE ZSTATUS_VALUE,
          DESCRIPTION  TYPE ZDESCRIPTION,
          CREATED_DATE TYPE ERDAT,
          CREATED_TIME TYPE ERZET,
          CREATED_BY   TYPE ERNAM,

        END OF  TY_ZINW_T_STATUS.
TYPES: BEGIN OF TY_EKPO,
         EBELN TYPE EBELN,   "Purchasing Document Number
         EBELP TYPE EBELP,   "Item Number of Purchasing Document
         WERKS TYPE EWERK,   "Plant
         MATNR TYPE MATNR,   "Material Number
         MWSKZ TYPE MWSKZ,   "Tax on Sales/Purchases Code
         MENGE TYPE BSTMG,   "Purchase Order Quantity
         NETPR TYPE BPREI,   "Net Price in Purchasing Document (CUR)
         PEINH TYPE EPEIN,   "Price unit
         NETWR TYPE BWERT,   "Net Order Value in PO Currency
         BUKRS TYPE BUKRS,
         RETPO TYPE RETPO,
       END OF TY_EKPO.

TYPES : BEGIN OF TY_T024,
          EKGRP TYPE EKGRP,
          EKNAM TYPE EKNAM,
        END OF TY_T024.

TYPES : BEGIN OF TY_MATDOC ,
          MBLNR TYPE MBLNR,
          BUDAT TYPE BUDAT,
        END OF TY_MATDOC .
DATA :IT_FINAL         TYPE TABLE OF ZGRPO_ITEM,
      WA_FINAL         TYPE  ZGRPO_ITEM,
      IT_MSEG          TYPE TABLE OF  TY_MSEG,
      WA_MSEG          TYPE  TY_MSEG,
      IT_MKPF          TYPE TABLE OF  TY_MKPF,
      WA_MKPF          TYPE  TY_MKPF,
      WA_MATDOC        TYPE  TY_MATDOC,
      IT_LFA1          TYPE TABLE OF  TY_LFA1,
      WA_LFA1          TYPE  TY_LFA1,
      IT_T001W         TYPE TABLE OF TY_T001W,
      WA_T001W         TYPE  TY_T001W,
      IT_KONV          TYPE TABLE OF  TY_KONV,
      IT_KONV1         TYPE TABLE OF  TY_KONV,
      WA_KONV          TYPE  TY_KONV,
      WA_KONV1         TYPE  TY_KONV,
      WA_EKPO          TYPE  TY_EKPO,
      IT_EKPO          TYPE TABLE OF  TY_EKPO,
      IT_EKPO1         TYPE TABLE OF  TY_EKPO,
      WA_EKPO1         TYPE   TY_EKPO,
      IT_EKKO          TYPE TABLE OF  TY_EKKO,
      IT_EKKO1         TYPE TABLE OF  TY_EKKO,
      IT_MAKT          TYPE TABLE OF  TY_MAKT,
      IT_MAKT1         TYPE TABLE OF  TY_MAKT,
      WA_MAKT1         TYPE  TY_MAKT,
      WA_MAKT          TYPE  TY_MAKT,
      WA_T005U         TYPE  TY_T005U,
      IT_ZINW_T_ITEM   TYPE TABLE OF TY_ZINW_T_ITEM,
      IT_ZINW_T_ITEM1  TYPE TABLE OF TY_ZINW_T_ITEM,
      WA_ZINW_T_ITEM   TYPE  TY_ZINW_T_ITEM,
      WA_ZINW_T_ITEM1  TYPE  TY_ZINW_T_ITEM,
      IT_ZINW_T_HDR    TYPE TABLE OF  TY_ZINW_T_HDR,
      WA_ZINW_T_HDR    TYPE  TY_ZINW_T_HDR,
      LV_SLNO          TYPE  I,
      LV1              TYPE  STRING,
      LV2              TYPE  STRING,
      LV3              TYPE  STRING,
      WA_HEADER        TYPE  ZGRPO_HEADER,
      WA_EKKO          TYPE  TY_EKKO,
      WA_EKKO1         TYPE  TY_EKKO,
      LV4              TYPE  STRING,
      LV5              TYPE  STRING,
      LV6              TYPE  STRING,
      WA_ZINW_T_STATUS TYPE  TY_ZINW_T_STATUS,
      IT_ZINW_T_STATUS TYPE  TY_ZINW_T_STATUS,
      LV_HEADING       TYPE  CHAR30,
      LV_HED           TYPE  CHAR15,
      LV_PER           TYPE  CHAR15,
      LV_TAX1          TYPE  CHAR15,
      LV_TAX           TYPE  CHAR15,
      LV_DUE           TYPE  CHAR10,
      LV_DATE          TYPE  DATUM,
      IT_T024          TYPE TABLE OF  TY_T024,
      IT_T0241         TYPE TABLE OF  TY_T024,
      IT_A003          TYPE TABLE OF  A003,
      IT_A0031         TYPE TABLE OF  A003,
      IT_KONP          TYPE TABLE OF  KONP,
      IT_KONP1         TYPE TABLE OF  KONP,
      WA_T0241         TYPE  TY_T024,
      WA_T024          TYPE  TY_T024.
DATA : IT_MARA  TYPE TABLE OF TY_MARA,
       IT_MARA1 TYPE TABLE OF TY_MARA,
       WA_MARA  TYPE TY_MARA,
       WA_MARA1 TYPE TY_MARA.
