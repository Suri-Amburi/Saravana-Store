*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_PRO_DET_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_gt_data,
          rec_date   TYPE zdate,
          lifnr      TYPE elifn,
          lr_no      TYPE zlr,
          act_no_bud TYPE zno_bud,
          trns       TYPE ztrans,
          name1      TYPE name1_gp,
          bill_num   TYPE zbill_num,
          bill_date  TYPE zbill_dat,
          net_amt    TYPE bwert,
          lr_date    TYPE zlr_date,
          mblnr      TYPE mblnr,
          total      TYPE zinw_t_hdr-total,
          pur_total  TYPE zinw_t_hdr-pur_total,
          qr_code    TYPE zinw_t_hdr-qr_code,
          city1      TYPE ad_city1,
          budat      TYPE mkpf-budat,
        END OF ty_gt_data .


TYPES : BEGIN OF ty_final ,
          sl_no(03)    TYPE i,
          rec_date     TYPE zdate,
          lifnr        TYPE elifn,
          lr_no        TYPE zlr,
          act_no_bud   TYPE zno_bud,
          trns         TYPE ztrans,
          name1        TYPE name1_gp,
          bill_num     TYPE zbill_num,
          bill_date    TYPE zbill_dat,
          net_amt      TYPE bwert,
          lr_date      TYPE zlr_date,
          mblnr        TYPE mblnr,
          total        TYPE zsel_toatl,
          pur_total    TYPE zpur_total,
          qr_code      TYPE zqr_code,
          city1        TYPE ad_city1,
          created_date TYPE erdat,
          budat        TYPE budat,
          lv_gr_pr     TYPE bwert,
          lv_pr_per    TYPE bwert,
          net_pr       TYPE bwert,
          net_per      TYPE bwert,
        END OF ty_final.

TYPES: BEGIN OF ty_final1,
         rec_date     TYPE zinw_t_hdr-rec_date,
         lifnr        TYPE zinw_t_hdr-lifnr,
         lr_no        TYPE zinw_t_hdr-lr_no,
         act_no_bud   TYPE zinw_t_hdr-act_no_bud,
         trns         TYPE zinw_t_hdr-trns,
         name1        TYPE zinw_t_hdr-name1,
         bill_num     TYPE zinw_t_hdr-bill_num,
         bill_date    TYPE zinw_t_hdr-bill_date,
         net_amt      TYPE zinw_t_hdr-net_amt,
         lr_date      TYPE zinw_t_hdr-lr_date,
         mblnr        TYPE zinw_t_hdr-mblnr,
         total        TYPE zinw_t_hdr-total,
         pur_total    TYPE zinw_t_hdr-pur_total,
         qr_code      TYPE zinw_t_hdr-qr_code,
         city1        TYPE adrc-city1,
         budat        TYPE mkpf-budat,
         created_date TYPE zinw_t_status-created_date,
         status_value TYPE zinw_t_status-status_value,
       END OF ty_final1.


DATA : gt_data   TYPE TABLE OF ty_gt_data,
       it_final  TYPE TABLE OF ty_final,
       wa_final  TYPE ty_final,
       it_final1 TYPE TABLE OF ty_final1,
       wa_final1 TYPE ty_final1.

DATA: LV_DATE       TYPE MKPF-BUDAT.

DATA : mblnr TYPE mblnr .
*DATA : LV_GR_PR  TYPE BWERT,
*       LV_PR_PER TYPE BWERT,
*       NET_PR    TYPE BWERT,
*       NET_PER   TYPE BWERT.
