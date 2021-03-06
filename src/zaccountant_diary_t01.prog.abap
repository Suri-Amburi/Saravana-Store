*&---------------------------------------------------------------------*
*& Include          ZACCOUNTANT_DIARY_T01
*&---------------------------------------------------------------------*

  DATA : LV_EDATE TYPE  SY-DATUM .
  DATA : LV_SDATE TYPE  SY-DATUM .
  DATA : LV_DAYS TYPE P .
  DATA : LV_DAY(10) TYPE C .
  DATA : D(10) TYPE C .

  TYPES :
    BEGIN OF TY_DATA,
      EBELN    TYPE EKBE-EBELN,
      EBELP    TYPE EKBE-EBELP,
      BEWTP    TYPE EKBE-BEWTP,
      BWART    TYPE EKBE-BWART,
      MENGE    TYPE EKBE-MENGE,
      BELNR    TYPE EKBE-BELNR,
      GJAHR    TYPE EKBE-GJAHR,
      BUDAT    TYPE EKBE-BUDAT,
      LFBNR    TYPE EKBE-LFBNR,
*      DMBTR    TYPE EKBE-DMBTR,
      BSART    TYPE EKKO-BSART,
      LOEKZ    TYPE EKKO-LOEKZ,
      AEDAT    TYPE EKKO-AEDAT,
      LIFNR    TYPE EKKO-LIFNR,
      WAERS    TYPE EKKO-WAERS,
      ZTERM    TYPE EKKO-ZTERM,
      ZBD1T    TYPE EKKO-ZBD1T,
*      MBLNR    TYPE MSEG-MBLNR,
      QR_CODE   TYPE ZINW_T_HDR-QR_CODE,
      NAME1     TYPE ZINW_T_HDR-NAME1,
      STATUS    TYPE ZINW_T_HDR-STATUS,
      SOE       TYPE ZINW_T_HDR-SOE,
      MBLNR_103 TYPE ZINW_T_HDR-MBLNR_103,
      MBLNR     TYPE ZINW_T_HDR-MBLNR,
      INWD_DOC  TYPE ZINW_T_HDR-INWD_DOC,
      MATNR     TYPE ZINW_T_ITEM-MATNR,
      MATKL     TYPE ZINW_T_ITEM-MATKL,
      NETPR_P   TYPE ZINW_T_ITEM-NETPR_P,
      NETWR_P   TYPE ZINW_T_ITEM-NETWR_P,
      NETPR_GP  TYPE ZINW_T_ITEM-NETPR_GP,
      MENGE_P   TYPE ZINW_T_ITEM-MENGE_P,
      DUE_DATE TYPE EKBE-BUDAT,
    END OF TY_DATA.

  TYPES :
    BEGIN OF TY_FINAL1,
      SLNO     TYPE INT4,
      DATE     TYPE CHAR10,
      AMOUNT   TYPE NETPR,
*      AMOUNT   TYPE DMBTR,
      CURRENCY TYPE WAERS,
    END OF TY_FINAL1 .

  TYPES :
    BEGIN OF TY_FINAL2,
      SLNO         TYPE INT4,
      DATE         TYPE SY-DATUM,
      AMOUNT       TYPE NETPR,
*      AMOUNT       TYPE DMBTR,
      CURRENCY     TYPE WAERS,
      EBELN        TYPE EKKO-EBELN,
      EBELP        TYPE EKPO-EBELP,
      WAERS        TYPE EKKO-WAERS,
      LIFNR        TYPE EKKO-LIFNR,
      NAME1        TYPE ZINW_T_HDR-NAME1,
*      NAME1        TYPE LFA1-NAME1,
      GRPO_NO      TYPE   ZINW_T_HDR-MBLNR,
      DUE_DATE     TYPE  SY-DATUM,
      CREATED_DATE TYPE SY-DATUM,
      MATKL        TYPE MATKL,
      AEDAT        TYPE EKKO-AEDAT,
      INWD_DOC     TYPE ZINW_T_HDR-INWD_DOC,
      QR_CODE      TYPE ZINW_T_HDR-QR_CODE,
      REC_DATE     TYPE ZINW_T_HDR-REC_DATE,
    END OF TY_FINAL2 .

*** Tables
  DATA :
    GT_DATA   TYPE STANDARD TABLE OF TY_DATA,
    GT_FINAL1 TYPE STANDARD TABLE OF TY_FINAL1,
    GS_FINAL1 TYPE TY_FINAL1,
    GT_FINAL2 TYPE STANDARD TABLE OF TY_FINAL2,
    GS_FINAL2 TYPE TY_FINAL2.

*** Constants
  CONSTANTS :
    C_X(1) VALUE 'X'.
