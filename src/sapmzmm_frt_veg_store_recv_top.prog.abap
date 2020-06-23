*&---------------------------------------------------------------------*
*& Include SAPMZMM_FRT_VEG_STORE_RECV_TOP           - Module Pool      SAPMZMM_FRT_VEG_STORE_RECV
*&---------------------------------------------------------------------*
PROGRAM sapmzmm_frt_veg_store_recv.
*
TYPES: BEGIN OF ty_matlist,
         mblnr    TYPE mblnr,
         mjahr    TYPE mjahr,
         bldat    TYPE bldat,
         budat    TYPE budat,
         matnr    TYPE matnr,
         maktx    TYPE maktx,
         swerks   TYPE werks_d,
         slgort   TYPE lgort_d,
         rwerks   TYPE werks_d,
         rlgort   TYPE lgort_d,
         menge    TYPE menge_d,
         uom      TYPE meins,
         dmbtr    TYPE dmbtr,
         updprice TYPE dmbtr,
       END OF ty_matlist.

CONSTANTS: c_back(4) TYPE c VALUE 'BACK',
           c_exit(4) TYPE c VALUE 'EXIT',
           c_canc(4) TYPE c VALUE 'CANC',
           c_class   TYPE class VALUE 'FRUITSANDVEGETABLE'.
CONTROLS: tc_matlist TYPE TABLEVIEW USING SCREEN 9001.

DATA: ok_9001     TYPE sy-ucomm,

      gv_mblnr    TYPE mblnr,
      gv_mjahr    TYPE mjahr,
      gv_scan(20) TYPE c,
      gv_rstore   TYPE zrstore,

      gs_matlist  TYPE ty_matlist,
      gt_matlist  TYPE TABLE OF ty_matlist.
