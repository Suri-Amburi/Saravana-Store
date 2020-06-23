*&---------------------------------------------------------------------*
*& Include SAPMZRETPO_RF_2_TOP                      - Module Pool      SAPMZRETPO_RF_2
*&---------------------------------------------------------------------*
PROGRAM sapmzretpo_rf_2.

TYPES: BEGIN OF ty_final,
        check  TYPE c,
        ebelp  TYPE ebelp,
        matnr  TYPE matnr,
        maktx  TYPE maktx,
        lifnr  TYPE lifnr,
        name1  TYPE name1,
        charg  TYPE charg_d,
        menge  TYPE menge_d,
        verpr  TYPE verpr,       ""PURCHASE PRICE
        disc   TYPE menge_d,       ""DISCOUNT
        taxper TYPE verpr,       ""TAX %
        mrp    TYPE verpr,       ""MRP
        selp   TYPE verpr,       ""SELLING PRICE
        verpr_f TYPE verpr,
       END OF ty_final.

TYPES:BEGIN OF ty_log,
        type  TYPE msgty_co,
        id    TYPE arbgb,
        txtnr TYPE msgnr,
        msgv1 TYPE char100,
        msgv2 TYPE symsgv,
      END OF ty_log.

DATA: lv_ebeln   TYPE ebeln,
      lv_werks   TYPE werks_d,
      lv_debit_note TYPE re_belnr,
      ok_code1   TYPE sy-ucomm,
      ok_code2   TYPE sy-ucomm,
      gv_mblnr_n TYPE mblnr.

DATA: it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final,
      it_log   TYPE TABLE OF ty_log,
      wa_log   TYPE ty_log.

DATA:container    TYPE REF TO cl_gui_custom_container,
     grid         TYPE REF TO cl_gui_alv_grid,
     it_exclude   TYPE ui_functions,
     lw_layo      TYPE lvc_s_layo,
     lt_fieldcat  TYPE lvc_t_fcat.

TYPES pict_line(256) TYPE c.
DATA :  logo  TYPE REF TO cl_gui_custom_container,
        editor   TYPE REF TO cl_gui_textedit,
        picture  TYPE REF TO cl_gui_picture,
        pict_tab TYPE TABLE OF pict_line,
        url(255) TYPE c.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.
DATA: l_graphic_conv TYPE i.
DATA: l_graphic_offs TYPE i.
DATA: graphic_size TYPE i.
DATA: l_graphic_xstr TYPE xstring,
      gv_subrc     TYPE sy-subrc.
