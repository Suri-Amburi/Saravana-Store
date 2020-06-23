*&---------------------------------------------------------------------*
*& Include SAPMZHUSTO_TOP                           - Module Pool      SAPMZHUSTO
*&---------------------------------------------------------------------*
PROGRAM sapmzhusto.


TYPES: BEGIN OF ty_hdr,
        werks  TYPE werks_d,
        twerks TYPE werks_d,
        exidv  TYPE char20,
        count  TYPE char4,
       END OF ty_hdr.

TYPES : BEGIN OF ty_mess,
          err   TYPE char1,
          mess1 TYPE char20,
          mess2 TYPE char20,
          mess3 TYPE char20,
          mess4 TYPE char20,
          mess5 TYPE char20,
        END OF ty_mess.

TYPES: BEGIN OF ty_final,
        venum TYPE venum,
        vemng TYPE vemng,
        matnr TYPE matnr,
        charg TYPE charg_d,
        werks TYPE werks_d,
        lgort TYPE lgort_d,
        exidv TYPE exidv,
      END OF ty_final.


DATA: wa_hdr  TYPE ty_hdr,
      gw_mess TYPE ty_mess,
      it_final TYPE TABLE OF ty_final,
      it_fin   TYPE TABLE OF ty_final,
      it_final1 TYPE TABLE OF ty_final.

DATA: ok_code1      TYPE sy-ucomm,
      ok_code2      TYPE sy-ucomm,
      gv_icon_name  TYPE char30,
      gv_icon_9999(132),
      gv_text       TYPE char10.

 DATA:
    header         LIKE bapimepoheader,
    header_no_pp   TYPE bapiflag,
    headerx        LIKE bapimepoheaderx,
    item           TYPE TABLE OF bapimepoitem ,
    wa_item        TYPE  bapimepoitem ,
    itemx          TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
    wa_itemx       TYPE  bapimepoitemx ,
    it_return      TYPE TABLE OF bapiret2,
    it_return1     TYPE TABLE OF bapiret2,
    lw_return      TYPE bapiret2,
    it_pocond      TYPE TABLE OF bapimepocond,
    wa_pocond      TYPE  bapimepocond,
    it_pocondx     TYPE TABLE OF bapimepocondx,
    wa_pocondx     TYPE bapimepocondx,
    lv_ebeln       TYPE ebeln.

 DATA: ls_sto_items   TYPE bapidlvreftosto,
       lt_sto_items   TYPE TABLE OF bapidlvreftosto,
       xsto_hdr_vbeln TYPE vbeln_vl.

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

 DATA : ls_error   TYPE xfeld,
        lt_hu      TYPE TABLE OF hum_rehang_hu,
        wa_hu      TYPE          hum_rehang_hu,
        created_hu TYPE TABLE OF vekpvb.

  DATA : lt_lips TYPE TABLE OF lips,
         wa_lips TYPE lips,
         lt_prot TYPE TABLE OF prott.

  DATA : ls_ef_error_any              TYPE xfeld,
         ls_ef_error_in_item_deletion TYPE xfeld,
         ls_ef_error_in_pod_update    TYPE xfeld,
         ls_ef_error_in_interface     TYPE xfeld,
         ls_ef_error_in_goods_issue   TYPE xfeld,
         ls_ef_error_in_final_check   TYPE xfeld,
         ls_ef_error_partner_update   TYPE xfeld,
         ls_ef_error_sernr_update     TYPE xfeld.
