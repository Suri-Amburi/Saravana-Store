*&---------------------------------------------------------------------*
*& Include SAPMZGR_101_TOP                          - Module Pool      SAPMZGR_101
*&---------------------------------------------------------------------*
PROGRAM sapmzgr_101.

TYPES: BEGIN OF ty_item,
         sl(02) TYPE c,
         cc     TYPE matkl,
         matnr  TYPE matnr,
         ean    TYPE ean11,
         qty    TYPE menge_d,
         uom    TYPE meins,
         maktx  TYPE maktx,
         lgort  TYPE mseg-lgort,
         charg  TYPE mseg-charg,
       END OF ty_item.

DATA: it_item TYPE TABLE OF ty_item,
      wa_item TYPE ty_item.

DATA:container   TYPE REF TO cl_gui_custom_container,
     grid        TYPE REF TO cl_gui_alv_grid,
     it_exclude  TYPE ui_functions,
     lw_layo     TYPE lvc_s_layo,
     lt_fieldcat TYPE  lvc_t_fcat.

DATA: lv_gr   TYPE mseg-mblnr,
      lv_from TYPE werks_d,
      lv_to   TYPE werks_d.

DATA: gv_mblnr TYPE mseg-mblnr,
      gv_bwart TYPE mseg-bwart,
      gv_plant TYPE mseg-werks.

CONSTANTS: c_101(03) VALUE '101',
           c_303(03) VALUE '303',
           c_109(03) VALUE '109',
           c_305(03) VALUE '305'.

DATA: ls_goodsmvt_header TYPE bapi2017_gm_head_01,
      ls_goodsmvt_code   TYPE bapi2017_gm_code,
      lw_goodsmvt_item   TYPE bapi2017_gm_item_create,
      li_goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
      lw_return          TYPE bapiret2,
      li_return          TYPE STANDARD TABLE OF bapiret2,
      gv_matdoc303       TYPE bapi2017_gm_head_ret-mat_doc,
      gv_matdoc305       TYPE bapi2017_gm_head_ret-mat_doc,
      lv_msg             TYPE string,
      lv_msg1            TYPE string,
      lv_msg2            TYPE string,
      lv_msg3            TYPE string.

TYPES pict_line(256) TYPE c.
DATA : logo     TYPE REF TO cl_gui_custom_container,
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
      gv_subrc       TYPE sy-subrc,
      ok_code        TYPE sy-ucomm.

DATA: lv_matdoc TYPE matdoc-mblnr.
