*&---------------------------------------------------------------------*
*& Include          ZMAS_CAT_STOCK_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_mseg,
         mblnr      TYPE mblnr,
         mjahr      TYPE mjahr,
         bwart      TYPE bwart,
         matnr      TYPE matnr,
         budat_mkpf TYPE budat,
         werks      TYPE werks_d,
       END OF ty_mseg.

*
*TYPES: BEGIN OF TY_MBVMBEW,
*       MATNR TYPE MATNR,
*       LBKUM TYPE LBKUM,     "Stock Qty
*       SALK3 TYPE SALK3,     "Stock Value
*       BWKEY TYPE BWKEY,     "Valuation Area
*       BKLAS TYPE BKLAS,     "Valuation Class
*       END OF TY_MBVMBEW.
TYPES: BEGIN OF ty_vbrp,
         matnr TYPE matnr,
         erdat TYPE erdat,
         matkl TYPE matkl,      "Category No.
         werks TYPE werks_d,
         fkimg TYPE fkimg,      "Qty
         netwr TYPE netwr_fp,   "Value
       END OF ty_vbrp.


TYPES: BEGIN OF ty_mara,
         matnr TYPE matnr,
         matkl TYPE matkl,     "Material Group
       END OF ty_mara.


TYPES: BEGIN OF ty_t001w,
         werks TYPE werks_d,
         name1 TYPE name1,
         bwkey TYPE bwkey,
         kunnr TYPE kunnr_wk,
         lifnr TYPE lifnr_wk,
       END OF ty_t001w.

DATA : it_mseg  TYPE STANDARD TABLE OF ty_mseg,
       wa_mseg  TYPE ty_mseg,
*       IT_MBVMBEW TYPE STANDARD TABLE OF TY_MBVMBEW,
*       WA_MBVMBEW TYPE TY_MBVMBEW,
*       IT_MBVMBEW1 TYPE STANDARD TABLE OF TY_MBVMBEW,
*       WA_MBVMBEW1 TYPE TY_MBVMBEW,
       it_vbrp  TYPE STANDARD TABLE OF ty_vbrp,
       wa_vbrp  TYPE ty_vbrp,
       it_mara  TYPE STANDARD TABLE OF ty_mara,
       wa_mara  TYPE ty_mara,
       it_t001w TYPE STANDARD TABLE OF ty_t001w,
       wa_t001w TYPE ty_t001w,
       it_item  TYPE STANDARD TABLE OF zmas_item1,
       it_item1 TYPE STANDARD TABLE OF zmas_item1,
       it_item2 TYPE STANDARD TABLE OF zmas_item1,
       wa_item  TYPE zmas_item1,
       wa_item1 TYPE zmas_item1,
       wa_item2 TYPE zmas_item1.

DATA: lv_budat TYPE budat,
      lv_val   TYPE netwr_fp,
      lv_qty   TYPE fkimg.
