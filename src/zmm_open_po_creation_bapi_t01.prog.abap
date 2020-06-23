*&---------------------------------------------------------------------*
*& Include          ZMM_OPEN_PO_CREATION_BAPI_T01
*&---------------------------------------------------------------------*
TYPES :
  BEGIN OF TY_FILE,
    INDENTNO(20),
    DATE(8),
    SUP_SAL_NO(5),
    SUP_NAME(20),
    VENDOR_CODE(10),
    DELIVERY_LOCATION(40),
    LEAD_TIME(3),
    PURCHASE_GROUP(3),
    ITEM_NO(5),
    CAT_CODE(9),
    STYLE(15),
    FROM_SIZE(18),
    TO_SIZE(18),
    COLOR(15),
    QUANTITY(13),
    PRICE(11),
    REMARKS(15),
  END OF TY_FILE.

TYPES : BEGIN OF TY_MARP ,
          MATNR      TYPE   MARA-MATNR,
          MATKL      TYPE   MARA-MATKL,
          SIZE1      TYPE    MARA-SIZE1,
          ZZPRICE_FR TYPE    MARA-ZZPRICE_FRM,
          ZZPRICE_TO TYPE    MARA-ZZPRICE_TO,
          MEINS      TYPE    MARA-MEINS,
        END OF TY_MARP .
TYPES : BEGIN OF TY_EKKO ,
          ZINDENT TYPE ZINDENT,
        END OF TY_EKKO,

        BEGIN OF TY_LFA1,
          LIFNR         TYPE CHAR20,
          ZZTEMP_VENDOR TYPE CHAR20,
          REGIO         TYPE REGIO,
        END OF TY_LFA1.


DATA  : GT_FILE TYPE TABLE OF TY_FILE.
*        FNAME   TYPE LOCALFILE,
*        ENAME   TYPE CHAR4.

DATA : IT_MARP TYPE TABLE OF TY_MARP,
       WA_MARP TYPE TY_MARP,

       IT_EKKO TYPE TABLE OF TY_EKKO,
       WA_EKKO TYPE TY_EKKO,

       IT_LFA1 TYPE TABLE OF TY_LFA1,
       WA_LFA1 TYPE TY_LFA1.

       DATA  : GT_FILE TYPE TABLE OF TY_FILE.
