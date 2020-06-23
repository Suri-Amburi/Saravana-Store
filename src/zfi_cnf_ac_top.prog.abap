*&---------------------------------------------------------------------*
*& Include          ZFI_CNF_AC_TOP
*&---------------------------------------------------------------------*

DATA: lv_bukrs TYPE bukrs,
      lv_lifnr TYPE bseg-lifnr,
      lv_year  TYPE bseg-gjahr,
      lv_date  TYPE bseg-h_budat.
*** Header
TYPES: BEGIN OF ty_header,
         linfr   TYPE lifnr,
         name1   TYPE name1_gp,
         ope_bal TYPE dmbtr,
       END OF ty_header .

TYPES: BEGIN OF ty_item,
         belnr  TYPE belnr_d,
         bldat  TYPE bldat,
         budat  TYPE budat,
         xblnr  TYPE xblnr,
         gsber  TYPE gsber,
         gtext  TYPE gtext,
         debit  TYPE dmbtr,
         credit TYPE dmbtr,
         bal    TYPE dmbtr,
       END OF ty_item .

TYPES: BEGIN OF ty_final,
         budat  TYPE  budat,
         xblnr  TYPE  xblnr,
         debit  TYPE  dmbtr,
         budat1 TYPE  budat,
         xblnr1 TYPE  xblnr,
         credit TYPE  dmbtr,
       END OF ty_final.

DATA: it_final1 TYPE TABLE OF zcnf_item,
      wa_final1 TYPE zcnf_item.

DATA: wa_header  TYPE zconf_ac_h .
DATA: wa_header1 TYPE zconf_ac_h1 .
DATA: it_final  TYPE TABLE OF zconf_ac_i .
DATA: fm_name TYPE  rs38l_fnam.

CONSTANTS : c_x(1) VALUE 'X'.

DATA: lv_debit  TYPE i,
      lv_credit TYPE i.
