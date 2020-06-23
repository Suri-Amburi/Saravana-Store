*&---------------------------------------------------------------------*
*& Include          ZPO_STATUS_TOP
*&---------------------------------------------------------------------*

TABLES: ekko,ekpo,eket,lfa1,zinw_t_item,t024.

DATA: lv_date TYPE sy-datum.

TYPES: BEGIN OF ty_ekko,
         ebeln TYPE ebeln,
         bukrs TYPE bukrs,
         bsart TYPE esart,
         statu TYPE estak,
         aedat TYPE erdat,
         lifnr TYPE elifn,
         spras TYPE spras,
         ekgrp TYPE ekgrp,
       END OF ty_ekko,

       BEGIN OF ty_ekpo,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         statu TYPE astat,
         aedat TYPE padat,
         matnr TYPE matnr,
         bukrs TYPE bukrs,
         werks TYPE ewerk,
         menge TYPE bstmg,
       END OF ty_ekpo,

       BEGIN OF ty_eket,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         etenr TYPE eeten,
         eindt TYPE eindt,
         lpein TYPE lpein,
         uzeit TYPE lzeit,
       END OF ty_eket,

       BEGIN OF ty_lfa1,
         lifnr TYPE lifnr,
         name1 TYPE name1_gp,
         ort01 TYPE ort01_gp,
         pstlz TYPE pstlz,
         erdat TYPE erdat_rf,
       END OF ty_lfa1,

       BEGIN OF ty_zinw_t_item,
         ebeln   TYPE ebeln,
         ebelp   TYPE ebelp,
         matnr   TYPE matnr,
         menge   TYPE bstmg,
         menge_p TYPE zmenge_p,
       END OF ty_zinw_t_item,

       BEGIN OF ty_t024,
         ekgrp TYPE ekgrp,
         eknam TYPE eknam,
       END OF ty_t024,

       BEGIN OF ty_final,
         ebeln   TYPE ebeln,
         bukrs   TYPE bukrs,
         bsart   TYPE esart,
         statu   TYPE estak,
         aedat   TYPE erdat,
         lifnr   TYPE elifn,
         spras   TYPE spras,
         ekgrp   TYPE ekgrp,
         ebelp   TYPE ebelp,
         matnr   TYPE matnr,
         menge   TYPE bstmg,
         etenr   TYPE eeten,
         eindt   TYPE eindt,
         lpein   TYPE lpein,
         uzeit   TYPE lzeit,
         name1   TYPE name1_gp,
         ort01   TYPE ort01_gp,
         pstlz   TYPE pstlz,
         erdat   TYPE erdat_rf,
         menge_p TYPE zmenge_p,
         lv_bq   TYPE bstmg,
         eknam   TYPE eknam,
         werks   TYPE ewerk,
       END OF ty_final.

DATA: wa_ekko        TYPE ty_ekko,
      wa_ekpo        TYPE ty_ekpo,
      wa_eket        TYPE ty_eket,
      wa_lfa1        TYPE ty_lfa1,
      wa_zinw_t_item TYPE ty_zinw_t_item,
      wa_final       TYPE ty_final,
      wa_t024        TYPE ty_t024,
      it_ekko        TYPE STANDARD TABLE OF ty_ekko,
      it_ekpo        TYPE STANDARD TABLE OF ty_ekpo,
      it_eket        TYPE STANDARD TABLE OF ty_eket,
      it_lfa1        TYPE STANDARD TABLE OF ty_lfa1,
      it_zinw_t_item TYPE TABLE OF ty_zinw_t_item,
      it_final       TYPE TABLE OF ty_final,
      it_t024        TYPE TABLE OF ty_t024,
      lv_bq          TYPE bstmg,
      lv_grp         TYPE ekgrp.

DATA: it_fcat   TYPE slis_t_fieldcat_alv,
      wa_fcat   TYPE slis_fieldcat_alv,
      wa_layout TYPE slis_layout_alv.
