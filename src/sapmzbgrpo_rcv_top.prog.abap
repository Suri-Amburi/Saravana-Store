*&---------------------------------------------------------------------*
*& Include SAPMZBGRPO_RCV_TOP                       - Module Pool      SAPMZBGRPO_RCV
*&---------------------------------------------------------------------*
PROGRAM sapmzbgrpo_rcv.

TYPES: BEGIN OF ty_hdr,
        ebeln   TYPE ebeln,
        werks   TYPE werks_d,
        budat   TYPE mkpf-budat,
    mblnr_541   TYPE mblnr,
    mblnr_101   TYPE mblnr,
    mblnr_542   TYPE mblnr,
    mblnr_201   TYPE mblnr,
       END OF ty_hdr.

TYPES: BEGIN OF ty_item,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        matnr TYPE matnr,
        maktx TYPE maktx,
        matkl TYPE matkl,
        ean11 TYPE mara-ean11,
       omenge TYPE menge_d,
       rmenge TYPE menge_d,
        meins TYPE meins,
       pur_amt TYPE bprei,
      netpr_s TYPE bprei,
      END OF ty_item.

*** MSEG Details
TYPES:  BEGIN OF ty_mseg,
        ebeln   TYPE ebeln,
        ebelp   TYPE ebelp,
        matnr   TYPE matnr,
        txz01   TYPE txz01,
        menge   TYPE menge_d,
        meins   TYPE meins,
        charg   TYPE charg_d,
        lifnr   TYPE lifnr,
        werks   TYPE werks_d,
        m_matnr TYPE matnr,
        m_maktx TYPE maktx,
        m_menge TYPE menge_d,
        m_meins TYPE meins,
*        kbetr   TYPE kbetr,
        matkl   TYPE matkl,
        ean11   TYPE ean11,
  END OF ty_mseg.

TYPES:BEGIN OF ty_log,
        type  TYPE msgty_co,
        id    TYPE arbgb,
        txtnr TYPE msgnr,
        msgv1 TYPE symsgv,
        msgv2 TYPE symsgv,
      END OF ty_log.

TYPES: BEGIN OF ty_ekbe,
        ebeln  TYPE ebeln,
        ebelp  TYPE ebelp,
        bwart  TYPE bwart,
        menge  TYPE menge_d,
       END OF ty_ekbe.

TYPES: BEGIN OF ty_con,
        matnr TYPE matnr,
        menge TYPE menge_d,
        meins TYPE meins,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
       END OF ty_con.


DATA: wa_hdr   TYPE ty_hdr,
      wa_item  TYPE ty_item,
      it_item  TYPE TABLE OF ty_item,
      gt_mseg  TYPE STANDARD TABLE OF ty_mseg ,
      it_log   TYPE TABLE OF ty_log,
      wa_log   TYPE ty_log,
      it_ekbe  TYPE TABLE OF ty_ekbe,
      it_ekbe1 TYPE TABLE OF ty_ekbe,
      it_con   TYPE TABLE OF ty_con,
      wa_con   TYPE ty_con.

*** Field Symbols
FIELD-SYMBOLS :
  <gs_item> TYPE ty_item.

 DATA:container1   TYPE REF TO cl_gui_custom_container,
      grid1        TYPE REF TO cl_gui_alv_grid,
      it_exclude   TYPE ui_functions,
      lw_layo1     TYPE lvc_s_layo,
      lt_fieldcat1 TYPE lvc_t_fcat,
      lv_cursor    TYPE char50,
      scrap        TYPE c.

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
