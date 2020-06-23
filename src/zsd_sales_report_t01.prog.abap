*&---------------------------------------------------------------------*
*& Include          ZSD_SALES_REPORT_T01
*&---------------------------------------------------------------------*

*** Type Declearations

TYPES :
  BEGIN OF ty_final,
    vbeln       TYPE vbeln_vf,  " invoice
    werks       TYPE werks_d,   " Plant
    group       TYPE klasse_d,  " Group
    matkl       TYPE matkl,     " Category Code
    matnr       TYPE matnr,     " Material
    maktx       TYPE maktx,     " Material Description
    zzprice_frm TYPE char20,    " From Price
    zzprice_to  TYPE char20,    " To Price
    menge       TYPE menge_d,   " Quantity
    meins       TYPE meins,     " UOM
    netwr       TYPE netwr_fp,  " Net Value
    mwsbp       TYPE mwsbp,     " Tax
    tot_amount  TYPE netwr_fp,  " Total Net Values
  END OF ty_final.

DATA :
  gt_final TYPE STANDARD TABLE OF ty_final,
  r_to     TYPE RANGE OF mara-zzprice_to,
  r_from   TYPE RANGE OF mara-zzprice_frm,
  r_size   TYPE RANGE OF mara-size1.

CONSTANTS :
  c_x(1)     VALUE 'X',
  c_space(1) VALUE ''.
