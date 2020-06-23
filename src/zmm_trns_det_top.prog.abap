*&---------------------------------------------------------------------*
*& Include          ZMM_TRNS_DET_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_zinw_t_hdr ,
          ebeln      TYPE ebeln,
          lifnr      TYPE elifn,
          name1      TYPE name1_gp,
          lr_no      TYPE zlr,
          lr_date    TYPE zlr_date,
          inwd_doc   TYPE zinwd_doc,
          service_po TYPE ebeln,
        END OF ty_zinw_t_hdr .

TYPES : BEGIN OF ty_zinw_t_item ,
          ebeln   TYPE ebeln,
          ebelp   TYPE ebelp,
          netwr_p TYPE netwr_p,
          menge   TYPE bstmg,
          netpr_p TYPE zbprei_p,
        END OF ty_zinw_t_item .

TYPES : BEGIN OF ty_ekpo ,
          ebeln TYPE  ebeln,
          ebelp TYPE ebelp,
          matnr TYPE matnr,
          menge TYPE bstmg,
          mwskz TYPE mwskz,
          netpr TYPE bprei,
          netwr TYPE bwert,
        END OF ty_ekpo.

TYPES :BEGIN OF ty_ekko ,
         ebeln TYPE ekko-ebeln,
         aedat TYPE ekko-aedat,
         lifnr TYPE ekko-lifnr,
       END OF ty_ekko .


TYPES: BEGIN OF ty_item,
         ebeln      TYPE ekko-ebeln,
         aedat      TYPE ekko-aedat,
         lifnr      TYPE ekko-lifnr,
         name1      TYPE zinw_t_hdr-name1,
         lr_no      TYPE zinw_t_hdr-lr_no,
         lr_date    TYPE zinw_t_hdr-lr_date,
         inwd_doc   TYPE zinw_t_hdr-inwd_doc,
         service_po TYPE zinw_t_hdr-service_po,
         ebelp      TYPE ekpo-ebelp,
         matnr      TYPE ekpo-matnr,
         menge      TYPE ekpo-menge,
         mwskz      TYPE ekpo-mwskz,
         netpr      TYPE ekpo-netpr,
         netwr      TYPE ekpo-netwr,
       END OF ty_item.

TYPES : BEGIN OF ty_final ,
          sl_no(5)   TYPE i,
          ebeln      TYPE ebeln,
          lifnr      TYPE lifnr,
          name1      TYPE name1_gp,
          lr_no      TYPE zlr,
          lr_date    TYPE zlr_date,
          inwd_doc   TYPE zinwd_doc,
          service_po TYPE ebeln,
          ebelp      TYPE ebelp,
          matnr      TYPE matnr,
          mwskz      TYPE mwskz,
          netpr      TYPE bprei,
          netwr      TYPE bwert,
          aedat      TYPE ekko-aedat,
        END OF ty_final .

DATA : it_zinw_t_hdr  TYPE TABLE OF ty_zinw_t_hdr,
       wa_zinw_t_hdr  TYPE ty_zinw_t_hdr,
       it_zinw_t_item TYPE TABLE OF ty_zinw_t_item,
       wa_zinw_t_item TYPE  ty_zinw_t_item,
       it_ekpo        TYPE TABLE OF ty_ekpo,
       it_ekko        TYPE TABLE OF ty_ekko,
       wa_ekpo        TYPE ty_ekpo,
       wa_ekko        TYPE ty_ekko,
       it_final       TYPE TABLE OF ty_final,
       wa_final       TYPE ty_final,
       it_item        TYPE TABLE OF ty_item,
       wa_item        TYPE ty_item.

DATA: lv_ven TYPE lfa1-lifnr.
