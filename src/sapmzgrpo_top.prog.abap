*&---------------------------------------------------------------------*
*& Include SAPMZGRPO_TOP                            - Module Pool      SAPMZBGRPO
*&---------------------------------------------------------------------*
PROGRAM sapmzbgrpo.


DATA: gw_mblnr TYPE mblnr.      "" GR PO Number
DATA: gw_ebeln TYPE ebeln.      "" PO Number
DATA: gw_budat TYPE mkpf-budat. "" Posting Date

TYPES: BEGIN OF ty_item1,      "" For container 1
        matnr   TYPE matnr,    "" Material
        maktx   TYPE maktx,    "" Material Desc
        charg   TYPE charg_d,  "" Batch
        menge   TYPE menge_d,  "" Batch Qty
        omenge  TYPE menge_d,  "" Open Qty
        cmenge  TYPE menge_d,  "" Consumption Qty
        meins   TYPE meins,    "" UOM
      END OF ty_item1.

TYPES: BEGIN OF ty_item2,     "" For container 2
         matnr   TYPE matnr,   "" Material
         maktx   TYPE maktx,   "" Mat Desc
         menge   TYPE menge_d, "" Enter qty
         meins   TYPE meins,   "" UOM
         rmenge  TYPE menge_d, "" Consumption QTy
         stlnr   TYPE stnum,    "" BOM
         sellp   TYPE verpr,    "" Selling price
         eanno   TYPE char18,  "" EAN NO
       END OF ty_item2.

TYPES: BEGIN OF ty_stpo,
        idnrk  TYPE idnrk,
        stlnr  TYPE stnum,
        menge  TYPE menge_d,
        meins  TYPE meins,
       END OF ty_stpo.

TYPES:BEGIN OF ty_log,
        type  TYPE msgty_co,
        id    TYPE arbgb,
        txtnr TYPE msgnr,
        msgv1 TYPE symsgv,
        msgv2 TYPE symsgv,
      END OF ty_log.


DATA: gt_item1 TYPE TABLE OF ty_item1,
      gw_item1 TYPE ty_item1,
      gt_item2 TYPE TABLE OF ty_item2,
      gt_item3 TYPE TABLE OF ty_item2,
      gw_item2 TYPE ty_item2,
      gt_stpo  TYPE TABLE OF ty_stpo,
      gt_stpo1 TYPE TABLE OF ty_stpo,
      it_log    TYPE TABLE OF ty_log,
      wa_log    TYPE ty_log.

 DATA:container1   TYPE REF TO cl_gui_custom_container,
     grid1         TYPE REF TO cl_gui_alv_grid,
     it_exclude    TYPE ui_functions,
     lw_layo1      TYPE lvc_s_layo,
     lt_fieldcat1  TYPE lvc_t_fcat.

DATA:container2   TYPE REF TO cl_gui_custom_container,
     grid2        TYPE REF TO cl_gui_alv_grid,
     lw_layo2     TYPE lvc_s_layo,
     lt_fieldcat2 TYPE lvc_t_fcat,
     ok_code      TYPE sy-ucomm,
     lv_cursor    TYPE char50,
    row_ind       TYPE  lvc_t_row.

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

DATA: gs_hdr-ebeln TYPE ebeln,
      gs_hdr-mblnr_541 TYPE mblnr.

CONSTANTS:  c_mvt_06(2)    VALUE '06'.
