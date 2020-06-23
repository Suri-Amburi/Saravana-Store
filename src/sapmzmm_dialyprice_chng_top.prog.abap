*&---------------------------------------------------------------------*
*& Include SAPMZMM_DIALYPRICE_CHNG_TOP
*& Module Pool      SAPMZMM_DIALYPRICE_CHNG
*&---------------------------------------------------------------------*
PROGRAM sapmzmm_dialyprice_chng.
****************************TYPES Declaration***************************
TYPES: BEGIN OF ty_matlist,
         sno       TYPE i,
         matnr     TYPE matnr,
         maktx     TYPE maktx,
         meins     TYPE meins,
         avlstck   TYPE bstmg,
         prchprice TYPE kbetr_kond,
         sellprice TYPE kbetr_kond,
         trnsqty   TYPE bstmg,
         ebeln     TYPE ebeln,
         ebelp     TYPE ebelp,
         splant    TYPE werks,
         sstloc    TYPE lgort_d,
         rstore    TYPE umwrk,
         rstloc    TYPE umlgo,
         matkl     TYPE matkl,  """ Material grp
       END OF ty_matlist.

*************************CONSTANTS Declarations*************************
CONSTANTS: c_back(4) TYPE c VALUE 'BACK',
           c_exit(4) TYPE c VALUE 'EXIT',
           c_canc(4) TYPE c VALUE 'CANC',
           c_class   TYPE klasse_d VALUE 'FRUITSANDVEGETABLE',
           c_mess(4) VALUE 'MESS',
           c_03(2)   VALUE '03',
           c_201(3)  VALUE '201'.

CONTROLS: tc_matlist TYPE TABLEVIEW USING SCREEN 9001 .
*************************Variables Declaration**************************
DATA: ok_9001    TYPE sy-ucomm,

      gv_splant  TYPE zsstore VALUE 'SSVG',
      gv_spdesc  TYPE name1,
      gv_rstore  TYPE zrstore,
      gv_rsdesc  TYPE werks_d,
      gv_clint   TYPE clint,

      gt_matlist TYPE TABLE OF ty_matlist,
      gs_matlist TYPE ty_matlist,
      bdcdata    TYPE TABLE OF bdcdata,
      messcoll   TYPE TABLE OF bdcmsgcoll.
