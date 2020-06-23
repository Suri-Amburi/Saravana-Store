*&---------------------------------------------------------------------*
*& Include          ZMM_BUN_TRANSIT_T01
*&---------------------------------------------------------------------*

TYPES :
  BEGIN OF TY_FINAL1,
    SNO        TYPE INT4,
    GRP        TYPE WWGHA,
    GRP_DES    TYPE WWGHB,
    ACT_NO_BUD TYPE ZNO_BUD,
    PUR_TOTAL  TYPE ZPUR_TOTAL,
    MENGE      TYPE ZMENGE_P,
    QR_CODE    TYPE ZQR_CODE,
  END OF TY_FINAL1,

  BEGIN OF TY_KLAH_H,
    CLINT TYPE KLAH-CLINT,
    KLART TYPE KLAH-KLART,
    CLASS TYPE KLAH-CLASS,
    OBJEK TYPE KSSK-OBJEK,
  END OF TY_KLAH_H,

*** Item Data
  BEGIN OF TY_KLAH_I,
    CLINT TYPE KLAH-CLINT,
    KLART TYPE KLAH-KLART,
    CLASS TYPE KLAH-CLASS,
  END OF TY_KLAH_I,

  BEGIN OF TY_ITEM,
    QR_CODE      TYPE ZINW_T_HDR-QR_CODE,
    INWD_DOC     TYPE ZINW_T_HDR-INWD_DOC,
    LIFNR        TYPE ZINW_T_HDR-LIFNR,
    NAME1        TYPE ZINW_T_HDR-NAME1,
    BILL_NUM     TYPE ZINW_T_HDR-BILL_NUM,
    BILL_DATE    TYPE ZINW_T_HDR-BILL_DATE,
    TRNS         TYPE ZINW_T_HDR-TRNS,
    TRNS_NAME    TYPE LFA1-NAME1,
    LR_NO        TYPE ZINW_T_HDR-LR_NO,
    LR_DATE      TYPE ZINW_T_HDR-LR_DATE,
    ACT_NO_BUD   TYPE ZINW_T_HDR-ACT_NO_BUD,
    PUR_TOTAL    TYPE ZINW_T_HDR-PUR_TOTAL,
    ERDATE       TYPE ZINW_T_HDR-ERDATE,
    EBELN        TYPE ZINW_T_ITEM-EBELN,
    EBELP        TYPE ZINW_T_ITEM-EBELP,
    MENGE_P      TYPE ZINW_T_ITEM-MENGE_P,
    NETPR_P      TYPE ZINW_T_ITEM-NETPR_P,
    NETWR_P      TYPE ZINW_T_ITEM-NETPR_P,
    MATNR        TYPE ZINW_T_ITEM-MATNR,
    MAKTX        TYPE ZINW_T_ITEM-MAKTX,
    MATKL        TYPE ZINW_T_ITEM-MATKL,
    WGBEZ        TYPE WGBEZ,
*    EINDT      TYPE EKET-EINDT,
*    AEDAT      TYPE EKKO-AEDAT,
    GRP          TYPE WWGHA,
    SEL(01)      TYPE C,
    STALE_DT(04) TYPE P,
  END OF TY_ITEM,

  BEGIN OF TY_TOTAL,
    GRP        TYPE WWGHA,
    QR_CODE    TYPE ZINW_T_HDR-QR_CODE,
    ACT_NO_BUD TYPE ZINW_T_HDR-ACT_NO_BUD,
    PUR_TOTAL  TYPE ZINW_T_HDR-PUR_TOTAL,
  END OF TY_TOTAL.

DATA :
  GT_FINAL1  TYPE STANDARD TABLE OF TY_FINAL1,
  GT_FINAL2  TYPE STANDARD TABLE OF TY_ITEM,
  GT_FINAL3  TYPE STANDARD TABLE OF TY_ITEM,
  GS_FINAL1  TYPE TY_FINAL1,
  GS_FINAL2  TYPE TY_ITEM,
  GS_FINAL3  TYPE TY_ITEM,
  GT_KLAH_H  TYPE STANDARD TABLE OF TY_KLAH_H,
  GT_KLAH_I  TYPE STANDARD TABLE OF TY_KLAH_I,
  GV_COUNT   TYPE SY-TABIX VALUE 1,
  GV_LIFNR   TYPE LIFNR,
  GT_ITEM    TYPE STANDARD TABLE OF TY_ITEM,
  GT_QR_MAIL TYPE TABLE OF ZQR_MAIL,
  GS_QR_MAIL TYPE ZQR_MAIL.

FIELD-SYMBOLS :
  <GS_KLAH_H> TYPE TY_KLAH_H,
  <GS_KLAH_I> TYPE TY_KLAH_I,
  <GS_ITEM>   TYPE TY_ITEM.

CONSTANTS :
  C_STATUS(2) VALUE '01', " " QR Generated
  C_X(1)      VALUE 'X',
  C_BACK      TYPE SYUCOMM    VALUE 'BACK',
  C_EXIT      TYPE SYUCOMM    VALUE 'EXIT',
  C_CANCEL    TYPE SYUCOMM  VALUE 'CANCEL'.

DATA:
  CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GRID        TYPE REF TO CL_GUI_ALV_GRID,
  GT_EXCLUDE  TYPE UI_FUNCTIONS,
  GS_LAYO     TYPE LVC_S_LAYO,
  GT_FIELDCAT TYPE LVC_T_FCAT,
  GS_FIELDCAT TYPE LVC_S_FCAT,
  OK_9003     TYPE SY-UCOMM,
  GV_QR       TYPE ZQR_CODE,
  GV_SUBRC    TYPE SY-SUBRC.

DATA : IT_MFIN TYPE TABLE OF ZTRANS_S,
       WA_MFIN TYPE ZTRANS_S.
DATA : LV_HED(30)  TYPE C,
       LV_HED1(30) TYPE C,
       LV_HED2(30) TYPE C.