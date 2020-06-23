*&---------------------------------------------------------------------*
*& Include          ZPHAPP_BACKGROUND_NEW_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_final,
        vendor          TYPE  lifnr,
        pgroup          TYPE  zcat,
        pur_group       TYPE  ekgrp,
        indent_no       TYPE  zindent,
        pdate           TYPE  budat,
        sup_sal_no      TYPE  zsal,
        sup_name        TYPE  zsup_name,
        vendor_name     TYPE name1,
        transporter     TYPE text30,
        vendor_location TYPE ad_city1,
        delivery_at   TYPE werks_d,
        lead_time     TYPE zlead,
       freight_charges TYPE zph_t_hdr-freight_charges,
       category_type   TYPE zph_t_hdr-category_type,
        item          TYPE ebelp,
        category_code TYPE matkl,
        style         TYPE zp_style,
      from_size       TYPE zsize_f,
      to_size         TYPE zsize_t,
      color           TYPE zp_color,
      quantity        TYPE bstmg,
      price           TYPE bprei,
      remarks         TYPE zp_remarks,
      e_msg           TYPE zemsg,
      s_msg           TYPE zsmsg,
      ztext100        TYPE ztext,
      discount2       TYPE zdis2,
      discount3       TYPE zdis3,
      matnr           TYPE matnr,
  END OF ty_final.



TYPES : BEGIN OF ty_cat_size,
          item  TYPE ebelp,
          matkl TYPE mara-matkl,
          size  TYPE mara-size1,
        END OF ty_cat_size.

DATA : lt_cat_size TYPE STANDARD TABLE OF ty_cat_size,
       r_range     TYPE RANGE OF wrf_atwrt,
       it_final    TYPE TABLE OF ty_final,
       wa_final    TYPE ty_final,
       it_final2    TYPE TABLE OF ty_final,
       wa_final2    TYPE ty_final,
       it_final3    TYPE TABLE OF ty_final,
       wa_final3    TYPE ty_final.
 DATA : lv_doc TYPE esart .

 DATA: wa_addf TYPE zphapp_msg.

 DATA : header  LIKE bapimepoheader,
        headerx LIKE bapimepoheaderx.
      DATA : item                TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
             poschedule          TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
             poschedulex         TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
             itemx               TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
             wa_itemx            TYPE bapimepoitemx,
             it_return           TYPE TABLE OF bapiret2,
             it_errorcat         TYPE TABLE OF slis_t_fieldcat_alv,
             wa_errorcat         TYPE  slis_t_fieldcat_alv,
             wa_return           TYPE  bapiret2,
             poservicestext      TYPE TABLE OF bapieslltx,
             potextitem          TYPE TABLE OF bapimepotext,
             wa_poservicestext   TYPE bapieslltx,
             wa_potextitem       TYPE bapimepotext,
             wa_no_price_from_po TYPE bapiflag-bapiflag.


      DATA : lv_tebeln(40) TYPE c.
      DATA : lv_tex(20) TYPE c.
      DATA : lv_error(50)  TYPE c,
             lv_error1(50) TYPE c.
      DATA : wa_po_item TYPE zph_t_item,
             wa_item    TYPE bapimepoitem,
             wa_theader TYPE thead,
             wa_t500w   TYPE t500w.

      DATA : wa_lines TYPE  tline,
             lines    TYPE TABLE OF tline,
             lv_text  TYPE tdobname,
             lv_matnr TYPE char40.
      DATA : lv_amnt TYPE bapicurext.
      DATA : ibapicondx TYPE TABLE OF bapimepocondx WITH HEADER LINE.
      DATA : ibapicond TYPE TABLE OF bapimepocond WITH HEADER LINE.
      DATA : im_header TYPE  ty_final.
      DATA : im_header_tt TYPE TABLE OF  zph_t_hdr,
*      DATA : LV_POITEM TYPE EBELP,
             lv_ername    TYPE ernam.
      DATA : lv_size1 TYPE p DECIMALS 0 .
      DATA : a(13) TYPE c,
             b(13) TYPE c,
             c(13) TYPE c.
      DATA : lv_mwsk1 .
      DATA:
        bapi_te_poitem  TYPE bapi_te_mepoitem,
        bapi_te_poitemx TYPE bapi_te_mepoitemx.
      DATA : lv_frm_size TYPE zsize_val-zsize,
             wa_s_size   TYPE zsize_val-zsize.
      DATA : lv_to_size TYPE zsize_val-zsize .
      DATA : pocond     TYPE TABLE OF bapimepocond WITH HEADER LINE,
             wa_pocond  TYPE bapimepocond,
             pocondx    TYPE TABLE OF bapimepocondx WITH HEADER LINE,
             wa_pocondx TYPE  bapimepocondx,
             wa_poaccount        TYPE bapimepoaccount,
             it_poaccount        TYPE TABLE OF bapimepoaccount,
             wa_poaccountx       TYPE bapimepoaccountx,
             it_poaccountx       TYPE TABLE OF bapimepoaccountx,
              pocondhdr  TYPE TABLE OF bapimepocondheader,
             pocondhdrx TYPE TABLE OF bapimepocondheaderx..
DATA : extensionin    TYPE TABLE OF bapiparex,
       wa_extensionin TYPE  bapiparex.
DATA: bapi_te_po   TYPE bapi_te_mepoheader,
      ibapi_te_po  TYPE bapi_te_mepoheader,
      bapi_te_pox  TYPE bapi_te_mepoheaderx,
      ibapi_te_pox TYPE bapi_te_mepoheaderx.
DATA : lv_count(03) TYPE  i .
DATA : sl_item(10) TYPE c VALUE '10'.
DATA: lv_ebeln TYPE ebeln.

CONSTANTS: c_zzgroup_margin(14) VALUE 'ZZGROUP_MARGIN'.
