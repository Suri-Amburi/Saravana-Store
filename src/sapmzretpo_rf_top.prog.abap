*&---------------------------------------------------------------------*
*& Include SAPMZRETPO_RF_TOP                        - Module Pool      SAPMZRETPO_RF
*&---------------------------------------------------------------------*
PROGRAM sapmzretpo_rf.


TYPES: BEGIN OF ty_hdr,
        werks  TYPE werks_d,
        lifnr  TYPE lifnr,
        name1  TYPE name1,
        lcharg TYPE char20,
        matnr  TYPE matnr,
        maktx  TYPE maktx,
        ekgrp  TYPE ekgrp,
        eknam  TYPE eknam,
      END OF ty_hdr.

TYPES: BEGIN OF ty_final,
        werks TYPE werks_d,
        charg TYPE charg_d,
        lifnr TYPE lifnr,
        menge TYPE menge_d,
        verpr TYPE verpr,
        ekgrp TYPE ekgrp,
        matnr TYPE matnr,
        maktx TYPE maktx,
        mwsk1 TYPE mwskz,
       END OF ty_final.

TYPES : BEGIN OF ty_mess,
          err   TYPE char1,
          mess1 TYPE char20,
          mess2 TYPE char20,
          mess3 TYPE char20,
          mess4 TYPE char20,
          mess5 TYPE char20,
        END OF ty_mess.

DATA: lv_charg  TYPE char20,
      lv_count  TYPE char6,
      wa_hdr    TYPE ty_hdr,
      wa_final  TYPE ty_final,
      it_final  TYPE TABLE OF ty_final,
       gw_mess  TYPE ty_mess.

DATA: ok_code1 TYPE sy-ucomm,
      ok_code2 TYPE sy-ucomm.

  DATA : lv_poitem    TYPE ebelp,
         lv_ebeln     TYPE ebeln,
      gv_icon_name    TYPE char30,
      gv_icon_9999(132),
      gv_text   TYPE char10.
  DATA:
    header       LIKE bapimepoheader,
    header_no_pp TYPE bapiflag,
    headerx      LIKE bapimepoheaderx,
    item         TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
    itemx        TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
    it_return    TYPE TABLE OF bapiret2,
    lw_return    TYPE bapiret2,
    it_pocond    TYPE TABLE OF bapimepocond,
    wa_pocond    TYPE  bapimepocond,
    it_pocondx   TYPE TABLE OF bapimepocondx,
    wa_pocondx   TYPE bapimepocondx.
