*&---------------------------------------------------------------------*
*& Include SAPMZRETPO_EAN_TOP                       - Module Pool      SAPMZRETPO_EAN
*&---------------------------------------------------------------------*
PROGRAM sapmzretpo_ean.


TYPES: BEGIN OF ty_final,
          werks TYPE werks_d,
          charg TYPE charg_d,
          lifnr TYPE lifnr,
          menge TYPE menge_d,
          verpr TYPE verpr,
          ekgrp TYPE ekgrp,
          matnr TYPE matnr,
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


DATA: lv_werks TYPE werks_d,
      lv_lifnr TYPE lifnr,
      lv_name1 TYPE name1,
      lv_ean   TYPE char20,
      lv_count TYPE char6,
      lv_ekgrp TYPE ekgrp,
      lv_lean  TYPE char20,
      lv_maktx TYPE maktx.


DATA: it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final,
      ok_code1 TYPE sy-ucomm,
      ok_code2 TYPE sy-ucomm,
      gw_mess  TYPE ty_mess,
      gv_icon_name    TYPE char30,
      gv_icon_9999(132),
      gv_text   TYPE char10,
      lv_poitem TYPE ebelp,
      lv_ebeln  TYPE ebeln.

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
