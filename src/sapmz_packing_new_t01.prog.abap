*&---------------------------------------------------------------------*
*& Include          SAPMZ_PACKING_T01
*&---------------------------------------------------------------------*

TYPES :
  BEGIN OF ty_del,
    slnum1 TYPE sy-tabix,    " 1st Row Serial Number
    vbeln1 TYPE vbeln,       " 1st Row Shipment Number
    signi1 TYPE signi,       " 1st Row Container ID
    slnum2 TYPE sy-tabix,    " 2nd Row Serial Number
    vbeln2 TYPE vbeln,       " 2nd Row Shipment Number
    signi2 TYPE signi,       " 2nd Row Container ID
    slnum3 TYPE sy-tabix,    " 3rd Row Serial Number
    vbeln3 TYPE vbeln,       " 3rd Row Shipment Number
    signi3 TYPE signi,       " 3rd Row Container ID
    slnum4 TYPE sy-tabix,    " 4th Row Serial Number
    vbeln4 TYPE vbeln,       " 4th Row Shipment Number
    signi4 TYPE signi,       " 4th Row Container ID
    slnum5 TYPE sy-tabix,    " 5th Row Serial Number
    vbeln5 TYPE vbeln,       " 5th Row Shipment Number
    signi5 TYPE signi,       " 5th Row Container ID
    slnum6 TYPE sy-tabix,    " 6th Row Serial Number
    vbeln6 TYPE vbeln,       " 6th Row Shipment Number
    signi6 TYPE signi,       " 6th Row Container ID
    slnum7 TYPE sy-tabix,    " 7th Row Serial Number
    vbeln7 TYPE vbeln,       " 7th Row Shipment Number
    signi7 TYPE signi,       " 7th Row Container ID
  END OF ty_del.

TYPES :
  BEGIN OF ty_lips,
    vbeln TYPE lips-vbeln,
  END OF ty_lips.

  DATA : svbeln TYPE vbeln_vl . "Delivery No.


DATA :
  gv_sel           TYPE char3 ,                    " Line Selection Field
  gv_line          TYPE sy-tabix,                  " Lines
  gv_count         TYPE sy-tabix,                  " Count for intial data fetch
  gv_from          TYPE sy-tabix,                  " Count From
  gv_to            TYPE sy-tabix,                  " Count To
  gv_del           TYPE lips-vbeln,                " Delivery
  gv_charg         TYPE char40,                    " Scanned Batch
  gv_charg_s4      TYPE charg_d,                   " S4 Batch
  gv_matnr         TYPE lips-matnr,                " Material
  gv_maktx         TYPE makt-maktx,                " Material Des
  gv_subrc         TYPE sy-subrc,
  gv_b_count       TYPE int2,
  gv_t_qty         TYPE int4,
  gv_p_qty         TYPE int4,
  gv_cur_field(20),
  gv_cur_value(20),
  gv_plant         TYPE werks_d.

DATA :
  gt_del  TYPE STANDARD TABLE OF ty_del,
  gt_lips TYPE STANDARD TABLE OF ty_lips,
  gs_del  TYPE ty_del.                      " Open delivery List Fields

DATA :
  ok_9000  TYPE sy-ucomm,
  ok_9001  TYPE sy-ucomm,
  r_tray,
  r_bundle.

CONSTANTS :
  c_exit(4)   VALUE 'EXIT',
  c_pdn(4)    VALUE 'P-',
  c_pup(4)    VALUE 'P+',
  c_ohu(4)    VALUE 'OHU',
  c_chu(4)    VALUE 'CHU',
  c_sel(4)    VALUE 'SEL',
  c_radio(5)  VALUE 'R1',
  c_enter(5)  VALUE 'ENTER',
  c_back(5)   VALUE 'BACK',
  c_tray(5)   VALUE 'TRAY',
  c_bundle(6) VALUE 'BUNDLE'.

DATA:
  wa_vbkok  TYPE vbkok,
  lt_vbpok  TYPE STANDARD TABLE OF vbpok,
  wa_vbpok  TYPE vbpok,
  lt_prott  TYPE STANDARD TABLE OF prott,
  lt_verko  TYPE STANDARD TABLE OF verko,
  wa_verko  TYPE verko,
  lt_verpo  TYPE STANDARD TABLE OF verpo,
  wa_verpo  TYPE verpo,
  lt_lips_m TYPE TABLE OF lips.

*** Fro Changing the delivery Qty
DATA:
  header_data     LIKE  bapiibdlvhdrchg,
  header_control  LIKE  bapiibdlvhdrctrlchg,
  delivery        LIKE  bapiibdlvhdrchg-deliv_numb,
  tec_ctrl        TYPE  bapidlvcontrol,
  ls_return       LIKE  bapiret2,

  item_data       TYPE TABLE OF  bapiibdlvitemchg,
  lt_item_data_f  TYPE TABLE OF  bapiibdlvitemchg,
  item_control    TYPE TABLE OF bapiibdlvitemctrlchg,
  ls_item_data    LIKE  bapiibdlvitemchg,
  ls_item_control LIKE  bapiibdlvitemctrlchg,
  return          TYPE TABLE OF bapiret2 WITH NON-UNIQUE KEY type.

*** HU CREATION
DATA :
  ls_headerproposal TYPE          bapihuhdrproposal,
  ls_huheader       TYPE          bapihuheader,
  gv_hukey          TYPE          bapihukey-hu_exid,
  it_ret1           TYPE TABLE OF bapiret2,
  wa_ret1           TYPE          bapiret2,
  ls_itemproposal   TYPE          bapihuitmproposal,
  it_itemproposal   TYPE TABLE OF bapihuitmproposal,
  it_item1          TYPE          bapihuitem,
  it_huheader1      TYPE          bapihuheader,
  it_ret3           TYPE TABLE OF bapiret2,
  itemsproposal     TYPE TABLE OF bapihuitmproposal,
  ls_itemsproposal  TYPE bapihuitmproposal,
  huitem            TYPE TABLE OF bapihuitem.
