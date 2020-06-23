*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_DRVPGM_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF TY_MSEG,
          MBLNR TYPE MBLNR,
          MJAHR TYPE MJAHR,
          ZEILE TYPE MBLPO,
          LIFNR TYPE ELIFN,
          WERKS TYPE WERKS_D,
          MATNR TYPE MATNR,
          MENGE TYPE MENGE_D,
          EBELN	TYPE BSTNR,
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

TYPES: BEGIN OF TY_EKPO,
         EBELN TYPE EBELN,
         EBELP TYPE EBELP,
         NETWR TYPE BWERT,
         NETPR TYPE BPREI,
       END OF  TY_EKPO.

TYPES : BEGIN OF TY_EKKO,
          EBELN TYPE EBELN,
          KNUMV TYPE KNUMV,
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
          EBELN	    TYPE EBELN,
          LIFNR	    TYPE ELIFN,
          QR_CODE	  TYPE ZQR_CODE,
          TRNS      TYPE ZTRANS  , "CHAR  40  0 Transporter Name
          LR_NO     TYPE ZLR , "CHAR  20  0 L.R.NO
          NO_BUD    TYPE ZNO_BUD, " INT2  5 0 No.of Bundle
          GRPO_NO	  TYPE ZGRPO_NO,
          GRPO_DATE	TYPE ZGRPO_DATE,
          DUE_DATE  TYPE ZDUE_DATE,
        END OF TY_ZINW_T_HDR .





TYPES : BEGIN OF TY_ZINW_T_ITEM ,
          QR_CODE TYPE ZQR_CODE,
          EBELN	  TYPE EBELN,
          EBELP	  TYPE EBELP,
          SNO	    TYPE INT2,
          MATNR	  TYPE MATNR,
          LGORT	  TYPE LGORT_D,
          WERKS	  TYPE EWERK,
          MENGE_P TYPE ZMENGE_P,
          MEINS	  TYPE BSTME,
          MAKTX	  TYPE MAKTX,
          NETPR_P	TYPE ZBPREI_P,
          NETWR_P	TYPE ZBPREI_PT,
        END OF TY_ZINW_T_ITEM .


DATA : IT_MSEG        TYPE TABLE OF TY_MSEG,
       WA_MSEG        TYPE TY_MSEG,
       IT_MKPF        TYPE TABLE OF TY_MKPF,
       WA_MKPF        TYPE TY_MKPF,
       IT_LFA1        TYPE TABLE OF TY_LFA1,
       WA_LFA1        TYPE TY_LFA1,
       IT_T001W       TYPE TABLE OF TY_T001W,
       WA_T001W       TYPE TY_T001W,
       IT_KONV        TYPE TABLE OF TY_KONV,
       WA_KONV        TYPE TY_KONV,
       IT_EKPO        TYPE TABLE OF TY_EKPO,
       WA_EKPO        TYPE TY_EKPO,
       IT_EKKO        TYPE TABLE OF TY_EKKO,
       WA_EKKO        TYPE TY_EKKO,
       IT_MAKT        TYPE TABLE OF TY_MAKT,
       WA_MAKT        TYPE TY_MAKT,
       WA_T005U       TYPE TY_T005U,
       WA_HEADER      TYPE ZGRPO_HEADER,
       IT_ZINW_T_HDR  TYPE TABLE OF TY_ZINW_T_HDR,
       WA_ZINW_T_HDR  TYPE TY_ZINW_T_HDR,
       IT_ZINW_T_ITEM TYPE TABLE OF TY_ZINW_T_ITEM,
       WA_ZINW_T_ITEM TYPE TY_ZINW_T_ITEM,
       IT_FINAL       TYPE TABLE OF ZGRPO_ITEM,
       WA_FINAL       TYPE ZGRPO_ITEM.

DATA :  LV_EBELN TYPE BSTNR.
