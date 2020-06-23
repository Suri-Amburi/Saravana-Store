*&---------------------------------------------------------------------*
*& Include          ZPHOTO_PO_APP_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_hdr,
*          VENDOR          TYPE LIFNR,
          vendor          TYPE char20,    "  ADDED (6-2-20)
          pgroup          TYPE zgroup,
          pur_group       TYPE ekgrp,
          indent_no       TYPE zindent,
          pdate           TYPE zp_date,
          sup_sal_no      TYPE zsal,
          sup_name        TYPE zsup_name,
          vendor_name     TYPE name1,
          transporter     TYPE name1,
          vendor_location TYPE ad_city1,
          delivery_at     TYPE werks_d,
          lead_time       TYPE zlead,
          e_msg           TYPE zemsg,
          s_msg           TYPE zsmsg,
          freight_charges TYPE zph_t_hdr-freight_charges,
        END OF ty_hdr .

TYPES : BEGIN OF ty_item ,
          indent_no     TYPE zindent,
          vendor        TYPE zph_t_item-vendor,       " ADDED (6-2-20)
*          VENDOR        TYPE LIFNR,
          pgroup        TYPE zcat,
          item          TYPE ebelp,
          category_code TYPE matkl,
          style         TYPE zp_style,
          from_size     TYPE zsize_f,
          to_size       TYPE zsize_t,
          color         TYPE zp_color,
          quantity      TYPE bstmg,
          price         TYPE bprei,
          remarks       TYPE zp_remarks,
          e_msg         TYPE zemsg,
          s_msg         TYPE zsmsg,
          ztext100      TYPE ztext,
          discount2     TYPE zdis2,
          discount3     TYPE zdis3,
        END OF ty_item .

TYPES : BEGIN OF ty_final ,
          indent_no       TYPE zindent,
          vendor          TYPE char20,             " ADDED (6-2-20)
*          VENDOR          TYPE LIFNR,
          pgroup          TYPE zcat,
          pur_group       TYPE ekgrp,
          pdate           TYPE zp_date,
          sup_sal_no      TYPE zsal,
          sup_name        TYPE zsup_name,
          vendor_name     TYPE name1,
          transporter     TYPE name1,
          vendor_location TYPE ad_city1,
          delivery_at     TYPE werks_d,
          lead_time       TYPE zlead,
          e_msg           TYPE zemsg,
          s_msg           TYPE zsmsg,
          cellcolors      TYPE lvc_t_scol,
          freight_charges TYPE zph_t_hdr-freight_charges,
        END OF ty_final .

TYPES : BEGIN OF ty_final1,
          indent_no     TYPE zindent,
*          VENDOR        TYPE LIFNR,
          vendor(20)    TYPE c,      " added on (3-3-20)
          pgroup        TYPE zcat,
          item          TYPE ebelp,
          category_code TYPE matkl,
          style         TYPE zp_style,
          from_size     TYPE zsize_f,
          to_size       TYPE zsize_t,
          color         TYPE zp_color,
          quantity      TYPE bstmg,
          price         TYPE zpr_frm,
          remarks       TYPE zp_remarks,
          e_msg         TYPE zemsg,
          s_msg         TYPE zsmsg,
          ztext100      TYPE ztext,
          sup_name      TYPE zsup_name,
          user_name     TYPE zunam,
          discount2     TYPE zdis2,
          discount3     TYPE zdis3,
        END OF ty_final1 .

TYPES : BEGIN OF ty_marp ,
          matnr      TYPE   mara-matnr,
          matkl      TYPE   mara-matkl,
          size1      TYPE    mara-size1,
          zzprice_fr TYPE    mara-zzprice_frm,
          zzprice_to TYPE    mara-zzprice_to,
          meins      TYPE    mara-meins,
        END OF ty_marp .
TYPES : BEGIN OF ty_ekko ,
          zindent TYPE zindent,
        END OF ty_ekko,
************ ADDED (6-2-20)    ***********************
        BEGIN OF ty_lfa1,
          lifnr         TYPE char20,
          zztemp_vendor TYPE char20,
          regio         TYPE regio,
        END OF ty_lfa1.
*************        END      *************




DATA : it_hdr    TYPE TABLE OF ty_hdr,
       it_item   TYPE TABLE OF ty_item,
       wa_ekko   TYPE  ty_ekko,
       it_final  TYPE TABLE OF ty_final,
       it_fin    TYPE TABLE OF ty_final,
       wa_final  TYPE  ty_final,
       it_final1 TYPE TABLE OF ty_final,
       it_final2 TYPE TABLE OF ty_final1,
       lv_test   TYPE ty_hdr,                             " ADDED BY LIKHITHA
       it_final3 TYPE TABLE OF ty_final1,
       wa_final1 TYPE  ty_final,
       wa_final2 TYPE  ty_final1,
       it_marp   TYPE TABLE OF ty_marp,
       it_count  TYPE TABLE OF ty_marp,
**************       ADDED (6-2-20)      ***************
       it_lfa1   TYPE TABLE OF ty_lfa1,
       wa_lfa1   TYPE ty_lfa1.
*********************     END (6-2-20)      ***************
DATA : lv_count(03) TYPE  i .

DATA :  gv_subrc    TYPE sy-subrc. .
DATA: c_x(1)      VALUE 'X',
      c_m(1)      VALUE 'M',
      ls_layout   TYPE slis_layout_alv,
      lt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv,
      wvari       TYPE disvariant,
      lt_sort     TYPE slis_t_sortinfo_alv.
DATA : lv_vendor TYPE lifnr .
wvari-report    = sy-repid.
wvari-username  = sy-uname.

ls_layout-zebra       = abap_true.
ls_layout-colwidth_optimize  = abap_true.


DATA:
  container    TYPE REF TO cl_gui_custom_container,
  container1   TYPE REF TO cl_gui_custom_container,
  grid         TYPE REF TO cl_gui_alv_grid,
  grid1        TYPE REF TO cl_gui_alv_grid,
  gt_exclude   TYPE ui_functions,
  gs_layo      TYPE lvc_s_layo,
  gs_layo1     TYPE lvc_s_layo,
  gt_fieldcat  TYPE lvc_t_fcat,
  gt_errorcat  TYPE lvc_t_fcat,
  gs_fieldcats TYPE lvc_s_fcat,
  gs_errorcat  TYPE lvc_s_fcat,
  ok_9003      TYPE sy-ucomm,
  gv_qr        TYPE zqr_code.
*  GV_SUBRC     TYPE SY-SUBRC.
DATA: c_back   TYPE syucomm    VALUE 'BACK1',
      c_exit   TYPE syucomm    VALUE 'EXIT',
      c_cancel TYPE syucomm  VALUE 'CANCEL'.


*  DATA(OK_CODE) = OK_9003.
*  CLEAR :OK_9003.
DATA : ok_code TYPE sy-ucomm .

DATA : extensionin    TYPE TABLE OF bapiparex,
       wa_extensionin TYPE  bapiparex.

DATA: bapi_te_po   TYPE bapi_te_mepoheader,
      ibapi_te_po  TYPE bapi_te_mepoheader,
      bapi_te_pox  TYPE bapi_te_mepoheaderx,
      ibapi_te_pox TYPE bapi_te_mepoheaderx.
DATA : lv_ebeln TYPE ebeln .
DATA: it_cellcolours TYPE lvc_t_scol,
      wa_cellcolor   TYPE lvc_s_scol.

DATA : wa_layout TYPE slis_layout_alv .
wa_layout-zebra = 'X' .
wa_layout-colwidth_optimize = 'X' .
wa_layout-coltab_fieldname  = 'CELLCOLORS'.

DATA : ref_grid TYPE REF TO cl_gui_alv_grid. "new


DATA : it_error      TYPE TABLE OF bapiret2,
       wa_error      TYPE  bapiret2,
       c_set(3)      VALUE 'SET' , " SET UOM
       c_vessels(10) VALUE 'VESSELS',
       c_kg(2)       VALUE 'KG'.
DATA : sl_item(10) TYPE c VALUE '10',
       flag        TYPE c.
