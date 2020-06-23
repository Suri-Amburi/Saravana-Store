*&---------------------------------------------------------------------*
*& Include          SAPMZ_RETURN_PO_T01
*&---------------------------------------------------------------------*

TYPES :
  BEGIN OF ty_hdr,
    qr_code TYPE zqr_code,
    mblnr   TYPE mblnr,
    ebeln   TYPE ebeln,
    charg   TYPE ean11,
*    charg   TYPE charg_d,
    lifnr   TYPE lifnr,
    name1   TYPE name1_gp,
  END OF ty_hdr,

  BEGIN OF ty_item,
    ebelp    TYPE ebelp,
    matnr    TYPE matnr,
    charg    TYPE charg_d,
    ean11    TYPE ean11,
    menge    TYPE menge_d,
    menge_s  TYPE menge_d,
    meins    TYPE lagme,
    netpr    TYPE bprei,
    waers    TYPE waers,
    netwr    TYPE bwert,
    bprei_gp TYPE bprei,
    bprei_t  TYPE bprei,
    lgort    TYPE lgort_d,
    werks    TYPE werks_d,
    mwskz    TYPE mwskz,
    disc     TYPE zdiscount,
    actprice TYPE bprei,
  END OF ty_item.

*** Internal Tables
DATA :
  gs_hdr     TYPE ty_hdr,
  gt_item    TYPE STANDARD TABLE OF ty_item,
  gt_item_t  TYPE STANDARD TABLE OF ty_item,
  gs_inw_hdr TYPE zinw_t_hdr.

DATA :
  container        TYPE REF TO cl_gui_custom_container,
  grid             TYPE REF TO cl_gui_alv_grid,
  mycontainer      TYPE scrfname VALUE 'MYCONTAINER',
  gt_exclude       TYPE ui_functions,
  gs_layo          TYPE lvc_s_layo,
  gt_fieldcat      TYPE lvc_t_fcat,
  ok_9000          TYPE sy-ucomm,
  ok_9001          TYPE sy-ucomm,
  gv_mblnr_103     TYPE mblnr,
  gv_subrc         TYPE sy-subrc,
  gv_cur_field(10),
  gv_cur_value(10),
  gv_ebeln         TYPE ebeln,
  gv_mod(1)        VALUE 'E',
  gv_po_create(1),
  gv_goods_mvt(1),
  gv_d_note(1),
  gv_vbeln         TYPE vbeln_vl,
  gv_mblnr_n       TYPE mblnr.

CONSTANTS :
  c_save         TYPE syucomm VALUE 'SAVE',
  c_enter        TYPE syucomm VALUE 'ENTER',
  c_space        TYPE syucomm VALUE space,
  c_back         TYPE syucomm VALUE 'BACK',
  c_exit         TYPE syucomm VALUE 'EXIT',
  c_cancel       TYPE syucomm VALUE 'CANCEL',
  c_refresh      TYPE syucomm VALUE 'REF',
  c_x(1)         VALUE 'X',
  c_e(1)         VALUE 'E',
  c_mvt_ind_b(1) VALUE 'B',
  c_mvt_01(2)    VALUE '01',
  c_101(3)       VALUE '101',
  c_02(2)        VALUE '02',
  c_04(2)        VALUE '04',
  c_d(2)         VALUE 'D',    " Display
  c_se_code(20)  VALUE 'SOE',
  c_se02(4)      VALUE 'SE02',
  c_se04(4)      VALUE 'SE04',
  c_bsart        TYPE bsart VALUE 'ZRET'.

*** PO Creation Data
DATA:
  header      LIKE bapimepoheader,
  headerx     LIKE bapimepoheaderx,
  item        TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
  poschedule  TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
  poschedulex TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
  itemx       TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
  return      TYPE TABLE OF bapiret2,
  it_pocond   TYPE TABLE OF bapimepocond,
  wa_pocond   TYPE  bapimepocond,
  it_pocondx  TYPE TABLE OF bapimepocondx,
  wa_pocondx  TYPE bapimepocondx.
DATA :   drop_down(15) TYPE c.   ""DROPDOWN

DATA : wa_header TYPE thead.
**** Event Class
*CLASS EVENT_CLASS DEFINITION DEFERRED.
*DATA: GR_EVENT TYPE REF TO EVENT_CLASS.
