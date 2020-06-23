*&---------------------------------------------------------------------*
*& Include ZMM_OPEN_PO_CREATION_BAPITOP             - Report ZMM_OPEN_PO_CREATION_BAPI
*&---------------------------------------------------------------------*
REPORT ZMM_OPEN_PO_CREATION_BAPI.

TYPES :
  BEGIN OF TY_FILE,
    INDENT_NO(20),
    PDATE(8),
    SUP_SAL_NO(5),
    SUP_NAME(20),
    VENDOR(10),
*    VENDOR_LOCATION(40),
    DELIVERY_AT(4),
    LEAD_TIME(3),
    PUR_GROUP(18),
    ITEM(5),
    CATEGORY_CODE(9),
    STYLE(15),
    FROM_SIZE(18),
    TO_SIZE(18),
    COLOR(15),
    QUANTITY(13),
    PRICE               TYPE BPREI,
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
          EBELN  TYPE ekko-EBELN,
          ZINDENT TYPE ZINDENT,
        END OF TY_EKKO,

        BEGIN OF TY_LFA1,
          LIFNR         TYPE CHAR20,
          ZZTEMP_VENDOR TYPE CHAR20,
          REGIO         TYPE REGIO,
        END OF TY_LFA1,

        BEGIN OF TY_MARA,
          MATNR       TYPE MARA-MATNR,
          MATKL       TYPE MARA-MATKL,
          SIZE1       TYPE MARA-SIZE1,
          ZZPRICE_FRM TYPE MARA-ZZPRICE_FRM,
          ZZPRICE_TO  TYPE MARA-ZZPRICE_TO,
          MEINS       TYPE MARA-MEINS,
          BSTME       TYPE MARA-BSTME,
        END OF TY_MARA,

        BEGIN OF ty_ZPH_T_HDR,
          VENDOR               type  zph_t_hdr-VENDOR            ,
          PGROUP               type  zph_t_hdr-PGROUP            ,
          PUR_GROUP            type  zph_t_hdr-PUR_GROUP         ,
          INDENT_NO            type  zph_t_hdr-INDENT_NO         ,
          PDATE                type  zph_t_hdr-PDATE             ,
          SUP_SAL_NO           type  zph_t_hdr-SUP_SAL_NO        ,
          SUP_NAME             type  zph_t_hdr-SUP_NAME          ,
          VENDOR_NAME          type  zph_t_hdr-VENDOR_NAME       ,
          TRANSPORTER          type  zph_t_hdr-TRANSPORTER       ,
          VENDOR_LOCATION      type  zph_t_hdr-VENDOR_LOCATION   ,
          DELIVERY_AT          type  zph_t_hdr-DELIVERY_AT       ,
          LEAD_TIME            type  zph_t_hdr-LEAD_TIME         ,
          E_MSG                type  zph_t_hdr-E_MSG             ,
          S_MSG                type  zph_t_hdr-S_MSG             ,
          end of ty_zph_t_hdr,


        BEGIN OF TY_ZPH_T_ITEM,
          INDENT_NO     TYPE ZPH_T_ITEM-INDENT_NO,
          ITEM          TYPE ZPH_T_ITEM-ITEM,
          CATEGORY_CODE TYPE ZPH_T_ITEM-CATEGORY_CODE,
          STYLE         TYPE ZPH_T_ITEM-STYLE,
          FROM_SIZE     TYPE ZPH_T_ITEM-FROM_SIZE,
          TO_SIZE       TYPE ZPH_T_ITEM-TO_SIZE,
          COLOR         TYPE ZPH_T_ITEM-COLOR,
          QUANTITY      TYPE  ZPH_T_ITEM-QUANTITY,
          PRICE         TYPE ZPH_T_ITEM-PRICE,
          REMARKS       TYPE ZPH_T_ITEM-REMARKS,
          PGROUP        TYPE ZPH_T_ITEM-PGROUP,
        END OF TY_ZPH_T_ITEM.

*        BEGIN OF ty_ekko,
*          EBELN  TYPE ekko-EBELN,
*          ZINDENT TYPE ekko-ZINDENT,
*          END OF ty_ekko.




DATA : IT_MARP  TYPE TABLE OF TY_MARP,
       IT_COUNT TYPE TABLE OF TY_MARP,
       WA_MARP  TYPE TY_MARP,

       IT_EKKO  TYPE TABLE OF TY_EKKO,
       WA_EKKO  TYPE TY_EKKO,

       IT_LFA1  TYPE TABLE OF TY_LFA1,
       WA_LFA1  TYPE TY_LFA1,

       IT_MARA  TYPE TABLE OF TY_MARA,
       WA_MARA  TYPE TY_MARA,

       it_hddr TYPE TABLE OF ty_ZPH_T_ITEM,
       wa_hddr TYPE ty_ZPH_T_ITEM,

       IT_ITEM  TYPE TABLE OF TY_ZPH_T_ITEM,
       WA_ITEM  TYPE TY_ZPH_T_ITEM.


*       it_ekko TYPE TABLE OF ty_ekko,
*       wa_ekko TYPE ty_ekko.


*       DATA  : GT_FILE TYPE TABLE OF TY_FILE.
DATA  : GT_FILE TYPE TABLE OF TY_FILE,
        FNAME   TYPE LOCALFILE,
        ENAME   TYPE CHAR4.

DATA : LV_COUNT(03) TYPE  I .

DATA :  GV_SUBRC    TYPE SY-SUBRC. .
DATA: C_X(1)      VALUE 'X',
      C_M(1)      VALUE 'M',
      LS_LAYOUT   TYPE SLIS_LAYOUT_ALV,
      LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      WVARI       TYPE DISVARIANT,
      LT_SORT     TYPE SLIS_T_SORTINFO_ALV.
*       IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
*      WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.
DATA : LV_VENDOR TYPE LIFNR .
WVARI-REPORT    = SY-REPID.
WVARI-USERNAME  = SY-UNAME.

TYPES:BEGIN OF GTY_DISPLAY,
        INDENT     TYPE CHAR20,
        PO_NUM  TYPE CHAR10,
*        PO_ITEM TYPE CHAR10,
*        TYPE    TYPE BAPIRET2-TYPE,
         type TYPE BAPI_MTYPE,
        MESSAGE TYPE BAPIRET2-MESSAGE,
      END OF GTY_DISPLAY,
      GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.



*LS_LAYOUT-ZEBRA       = ABAP_TRUE.
*LS_LAYOUT-COLWIDTH_OPTIMIZE  = ABAP_TRUE.


**DATA:
**  CONTAINER    TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
**  CONTAINER1   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
**  GRID         TYPE REF TO CL_GUI_ALV_GRID,
**  GRID1        TYPE REF TO CL_GUI_ALV_GRID,
**  GT_EXCLUDE   TYPE UI_FUNCTIONS,
**  GS_LAYO      TYPE LVC_S_LAYO,
**  GS_LAYO1     TYPE LVC_S_LAYO,
**  GT_FIELDCAT  TYPE LVC_T_FCAT,
**  GT_ERRORCAT  TYPE LVC_T_FCAT,
**  GS_FIELDCATS TYPE LVC_S_FCAT,
**  GS_ERRORCAT  TYPE LVC_S_FCAT,
**  OK_9003      TYPE SY-UCOMM,
**  GV_QR        TYPE ZQR_CODE.
***  GV_SUBRC     TYPE SY-SUBRC.
**DATA: C_BACK   TYPE SYUCOMM    VALUE 'BACK1',
**      C_EXIT   TYPE SYUCOMM    VALUE 'EXIT',
**      C_CANCEL TYPE SYUCOMM  VALUE 'CANCEL'.


*  DATA(OK_CODE) = OK_9003.
*  CLEAR :OK_9003.
*DATA : OK_CODE TYPE SY-UCOMM .

DATA : EXTENSIONIN    TYPE TABLE OF BAPIPAREX,
       WA_EXTENSIONIN TYPE  BAPIPAREX.

DATA: BAPI_TE_PO   TYPE BAPI_TE_MEPOHEADER,
      IBAPI_TE_PO  TYPE BAPI_TE_MEPOHEADER,
      BAPI_TE_POX  TYPE BAPI_TE_MEPOHEADERX,
      IBAPI_TE_POX TYPE BAPI_TE_MEPOHEADERX.
*      NO_PRICE_FROM_PO TYPE BAPIFLAG-BAPIFLAG.       " added by likhitha
*        IT_NO_PRICE_FROM_PO  TYPE TABLE OF  BAPIFLAG-BAPIFLAG,
*        WA_NO_PRICE_FROM_PO  TYPE BAPIFLAG-BAPIFLAG.
DATA : LV_EBELN TYPE EBELN .
DATA: IT_CELLCOLOURS TYPE LVC_T_SCOL,
      WA_CELLCOLOR   TYPE LVC_S_SCOL.
DATA: GWA_DISPLAY TYPE GTY_DISPLAY,
      GIT_DISPLAY TYPE GTY_T_DISPLAY.

**DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .
**WA_LAYOUT-ZEBRA = 'X' .
**WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .
**WA_LAYOUT-COLTAB_FIELDNAME  = 'CELLCOLORS'.

*DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID. "new
DATA : WA_FCAT     TYPE SLIS_FIELDCAT_ALV.
*          LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

DATA : IT_ERROR      TYPE TABLE OF BAPIRET2,
       WA_ERROR      TYPE  BAPIRET2,
       C_SET(3)      VALUE 'SET' , " SET UOM
       C_VESSELS(10) VALUE 'VESSELS',
       C_KG(2)       VALUE 'KG'.
DATA : SL_ITEM(10) TYPE C VALUE '10',
       FLAG        TYPE C.
*   DATA : FNAME TYPE LOCALFILE,
*     DATA :     ENAME TYPE CHAR4.
