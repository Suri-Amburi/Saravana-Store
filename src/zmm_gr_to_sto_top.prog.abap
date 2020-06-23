*&---------------------------------------------------------------------*
*& Include          ZMM_GR_TO_STO_TOP
*&---------------------------------------------------------------------*


TYPES: BEGIN OF ty_final,
*        posnr TYPE posnr,
        matnr TYPE matnr,
        werks TYPE werks_d,
        lgort TYPE lgort_d,
        charg TYPE charg_d,
        lifnr TYPE lifnr,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        menge TYPE menge_d,
        meins TYPE meins,
      END OF ty_final.

TYPES:BEGIN OF ty_log,
        type  TYPE msgty_co,
        id    TYPE arbgb,
        txtnr TYPE msgnr,
        msgv1 TYPE char100,
        msgv2 TYPE symsgv,
      END OF ty_log.

DATA: it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final,
      it_log    TYPE TABLE OF ty_log,
      wa_log    TYPE ty_log,
      p_mblnr   TYPE mblnr.


DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      it_events    TYPE slis_t_event,
      wa_layout    TYPE slis_layout_alv,
      wa_events    LIKE LINE OF it_events.

  DATA:
    header    LIKE bapimepoheader,
    header_no_pp TYPE bapiflag,
    headerx   LIKE bapimepoheaderx,
    item      TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
    itemx     TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
    it_return TYPE TABLE OF bapiret2,
    lw_return TYPE bapiret2,
    it_pocond   TYPE TABLE OF bapimepocond,
    wa_pocond   TYPE  bapimepocond,
    it_pocondx  TYPE TABLE OF bapimepocondx,
    wa_pocondx  TYPE bapimepocondx,
    lv_ebeln    TYPE ebeln.
