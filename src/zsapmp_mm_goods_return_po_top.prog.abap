*&---------------------------------------------------------------------*
*& Include ZSAPMP_MM_GOODS_RETURN_PO_TOP            - Module Pool      ZSAPMP_MM_GOODS_RETURN_PO
*&---------------------------------------------------------------------*
PROGRAM zsapmp_mm_goods_return_po.
DATA: ok_code LIKE sy-ucomm.
DATA : lv_ebeln      TYPE ebeln,
       gv_mblnr_n    TYPE mblnr,
       lv_debit_note TYPE re_belnr,
       lv_lifnr      TYPE lifnr,
       lv_name1      TYPE name1.
DATA: rad1 TYPE c,
      rad2 TYPE c.
TYPES : BEGIN OF ty_mseg,
          bwart TYPE bwart,
          matnr TYPE matnr,
          werks TYPE werks_d,
          charg TYPE charg_d,
          lifnr TYPE elifn,
          ebeln TYPE ebeln,
        END OF ty_mseg .

TYPES : BEGIN OF ty_mbew ,
          matnr TYPE matnr,
          bwkey TYPE bwkey,
          bwtar TYPE bwtar_d,
          verpr TYPE verpr,
        END OF ty_mbew .

TYPES : BEGIN OF ty_final ,
          matnr    TYPE matnr,
          werks    TYPE werks_d,
          lifnr    TYPE elifn,
          verpr    TYPE  verpr ,"bapicurext,
          charg    TYPE charg_d,
          quantity TYPE lbkum,
          ekgrp    TYPE ekgrp,
          value    TYPE verpr,
          name1    TYPE name1_gp,
          tax_per  TYPE netpr,
          tax_val  TYPE netpr,
          disc     TYPE netpr,
          dvalue   TYPE verpr,
          charg1   TYPE char20,
          mrp      TYPE verpr,
          selp     TYPE verpr,
          seltot   TYPE verpr,
        END OF ty_final.
***** added by krithika 27.12.2019

TYPES : BEGIN OF ty_bstck,
          b1_batch     TYPE char20,
          s4_batch     TYPE zb1_stock-batch     ,
          b1_vendor    TYPE zb1_stock-b1_vendor     ,
          plant        TYPE zb1_stock-plant    ,
          amount       TYPE dmbtr_cs    ,
*          quantity     TYPE zb1_stock-quantity    ,
          matnr        TYPE matnr,
        END OF ty_bstck,

        BEGIN OF ty_mara,
          matnr TYPE mara-matnr,
          matkl TYPE klah-class,
        END OF ty_mara,

        BEGIN OF ty_lfa1,
          lifnr TYPE lfa1-lifnr ,
          regio TYPE lfa1-regio ,
          adrnr TYPE lfa1-adrnr ,
        END OF ty_lfa1.
*** ended

TYPES:BEGIN OF ty_log,
        type  TYPE msgty_co,
        id    TYPE arbgb,
        txtnr TYPE msgnr,
        msgv1 TYPE char100,
        msgv2 TYPE symsgv,
      END OF ty_log.



DATA : it_mseg  TYPE TABLE OF ty_mseg,
       it_lif   TYPE TABLE OF ty_mseg,
       wa_mseg  TYPE ty_mseg,
       it_mbew  TYPE TABLE OF ty_mbew,
       it_mbew1  TYPE TABLE OF ty_mbew,
       wa_mbew  TYPE  ty_mbew,
       wa_mbew1  TYPE  ty_mbew,
       it_final TYPE TABLE OF ty_final,
       wa_final TYPE  ty_final,
      it_log    TYPE TABLE OF ty_log,
      wa_log    TYPE ty_log.

*** added by krithika

DATA : it_bstck TYPE TABLE OF ty_bstck,
       wa_bstck TYPE ty_bstck,
       it_mara1 TYPE TABLE OF ty_mara,
       it_mar2 TYPE TABLE OF ty_mara,
       wa_mara1 TYPE ty_mara,
       wa_lfa1 TYPE ty_lfa1.
*** ended

DATA : lv_batch TYPE  char20.   "CHARG_D .
DATA : lv_werks TYPE  werks_d.

DATA:container   TYPE REF TO cl_gui_custom_container,
     grid        TYPE REF TO cl_gui_alv_grid,
     it_exclude  TYPE ui_functions,
     lw_layo     TYPE lvc_s_layo,
     lt_fieldcat TYPE  lvc_t_fcat.
DATA: lt_exclude TYPE ui_functions.
DATA : ls_stable TYPE lvc_s_stbl.
DATA : ref_grid TYPE REF TO cl_gui_alv_grid.
