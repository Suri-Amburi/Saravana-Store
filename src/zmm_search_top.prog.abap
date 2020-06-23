*&---------------------------------------------------------------------*
*& Include          ZMM_SEARCH_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_mara ,
          matnr       TYPE matnr,
          matkl       TYPE matkl,
          zzprice_frm TYPE zpr_frm,
          zzprice_to  TYPE zpr_to,
          maktx       TYPE maktx,
        END OF ty_mara .

TYPES : BEGIN OF ty_ekpo ,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          matnr TYPE matnr,
          menge TYPE bstmg,
        END OF ty_ekpo .

TYPES : BEGIN OF ty_mard ,
          matnr TYPE matnr,
          werks TYPE werks_d,
          labst TYPE labst,
        END OF ty_mard .

TYPES : BEGIN OF ty_mbew ,
          matnr TYPE matnr,
          bwkey TYPE bwkey,
          lbkum TYPE lbkum,
        END OF ty_mbew .

TYPES : BEGIN OF ty_zinw_t_hdr ,
          qr_code    TYPE zqr_code,
          inwd_doc   TYPE zinwd_doc,
          ebeln      TYPE ebeln,
          lifnr      TYPE elifn,
          name1      TYPE name1_gp,
          bill_num   TYPE zbill_num,
          bill_date  TYPE zbill_dat,
          trns       TYPE ztrans,
          lr_no      TYPE zlr,
          act_no_bud TYPE zno_bud,
          status     TYPE zstatus,
          bay        TYPE zbay,
        END OF ty_zinw_t_hdr .

TYPES : BEGIN OF ty_zinw_t_item ,
          qr_code  TYPE zqr_code,
          ebeln    TYPE ebeln,
          ebelp    TYPE ebelp,
          matnr    TYPE matnr,
          menge_p  TYPE zmenge_p,
          open_qty TYPE zmenge_o,
          matkl    TYPE matkl,
        END OF ty_zinw_t_item .


TYPES : BEGIN OF ty_data ,
          matkl       TYPE mara-matkl,
          matnr       TYPE mara-matnr,
          zzprice_frm TYPE mara-zzprice_frm,
          zzprice_to  TYPE mara-zzprice_to,
          labst       TYPE mard-labst,                      ""Opened Warehouse Stock
          open_qty    TYPE zinw_t_item-open_qty,
          ebeln       TYPE zinw_t_item-ebeln,
          status      TYPE zinw_t_hdr-status,
*          INWH_BUN  TYPE EKPO-MENGE,
        END OF ty_data .



TYPES : BEGIN OF ty_final ,
          sl_no(05)    TYPE i,
          matkl        TYPE matkl,
          matnr        TYPE matnr,
          maktx        TYPE maktx,
          zzprice_frm  TYPE zpr_frm,
          zzprice_to   TYPE zpr_to,
          open_qty     TYPE labst,
          menge_wh     TYPE zmenge_o,
          menge_tr     TYPE zmenge_o,
          inwh_bun     TYPE bstmg,
          ebeln        TYPE ebeln,
          lifnr        TYPE elifn,
          name         TYPE name1_gp,
          ort01        TYPE ort01,
          bil_no       TYPE zbill_num,
          bil_date     TYPE zbill_dat,
          lr_no        TYPE zlr,
          act_no_bud   TYPE zno_bud,
          trns         TYPE ztrans,
          created_date TYPE erdat,
          bay          TYPE zbay,
        END OF ty_final .


DATA : it_mara         TYPE TABLE OF ty_mara,
       it_mard         TYPE TABLE OF ty_mard,
       it_zinw_t_hdr   TYPE TABLE OF ty_zinw_t_hdr,
       it_ekpo         TYPE TABLE OF ty_ekpo,
       it_zinw_t_item  TYPE TABLE OF ty_zinw_t_item,
       it_zinw_t_item1 TYPE TABLE OF ty_zinw_t_item,
       gt_data         TYPE TABLE OF ty_data,
       it_final        TYPE TABLE OF ty_final,
       it_final1       TYPE TABLE OF ty_final,
       wa_final        TYPE  ty_final,
       wa_final1       TYPE  ty_final.

DATA : gv_plant       TYPE werks_d,
       gv_zzprice_frm TYPE mara-zzprice_frm,
       gv_size        TYPE mara-size1,
       gv_matkl       TYPE mara-matkl,
       gv_heading(20).

DATA : r_to   TYPE RANGE OF mara-zzprice_to WITH HEADER LINE,
       r_from TYPE RANGE OF mara-zzprice_frm WITH HEADER LINE,
       r_size TYPE RANGE OF mara-size1 WITH HEADER LINE.
