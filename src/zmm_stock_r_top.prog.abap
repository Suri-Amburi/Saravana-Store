*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_R_TOP
*&---------------------------------------------------------------------*

TABLES : edidc.

DATA: lv_matnr TYPE mchb-matnr,
      lv_charg TYPE mchb-charg,
      lv_werks TYPE mchb-werks,
      lv_clabs TYPE mchb-clabs,
      lv_lgort TYPE mchb-lgort,
      lv_doc   TYPE edidc-docnum.

TYPES: BEGIN OF ty_final,
         matnr       TYPE mchb-matnr,
         charg       TYPE mchb-charg,
         qty         TYPE menge_d,
         uom         TYPE meins,
         matnr1      TYPE mchb-matnr,
         charg1      TYPE mchb-charg,
         lgort1      TYPE mchb-lgort,
         werks1      TYPE mchb-werks,
         qty1        TYPE menge_d,
         uom1        TYPE meins,
         docnum      TYPE edid4-docnum,
         remarks(25) TYPE c,


       END OF ty_final.

TYPES: BEGIN OF ty_item,
         docnum TYPE edidc-docnum,
         rcvprn TYPE edidc-rcvprn,
         status TYPE edidc-status,
         credat TYPE edidc-credat,
         segnam TYPE edid4-segnam,
         segnum type edid4-segnum,
         sdata  TYPE edid4-sdata,
       END OF ty_item.

DATA: it_edid4 TYPE TABLE OF ty_item,
      wa_edid4 TYPE ty_item.

DATA: it_final  TYPE TABLE OF ty_final,
      wa_final  TYPE ty_final,
      it_final3 TYPE TABLE OF ty_final,
      wa_final3 TYPE ty_final,
      it_final4 TYPE TABLE OF ty_final,
      wa_final4 TYPE ty_final,
      it_final5  TYPE TABLE OF ty_final,
      w_final5  TYPE ty_final.



DATA: lv_mat_mchb   TYPE mchb-matnr,
      lv_werks_mchb TYPE mchb-werks,
      lv_lgort_mchb TYPE mchb-lgort,
      lv_charg_mchb TYPE mchb-charg,
      lv_qty_mchb   TYPE mchb-clabs.

DATA: it_fcat   TYPE slis_t_fieldcat_alv, "WITH HEADER LINE,
      wa_fcat   TYPE slis_fieldcat_alv,
      wa_layout TYPE slis_layout_alv.

  DATA:CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GRID        TYPE REF TO CL_GUI_ALV_GRID,
       IT_EXCLUDE  TYPE UI_FUNCTIONS,
       LW_LAYO     TYPE LVC_S_LAYO,
       LT_FIELDCAT TYPE  LVC_T_FCAT.
  DATA: LT_EXCLUDE TYPE UI_FUNCTIONS.
