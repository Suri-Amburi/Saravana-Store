*&---------------------------------------------------------------------*
*& Include          ZFI_VACCOUNT_DP_TOP
*&---------------------------------------------------------------------*

TABLES : bseg,bkpf,lfa1,t001w,adrc.

TYPES : BEGIN OF ty_bseg,
          bukrs   TYPE bukrs,
          belnr   TYPE belnr_d,
          gjahr   TYPE gjahr,
          buzei   TYPE buzei,
          augdt   TYPE augdt,                                                          "CLEARING DATE
          koart   TYPE char20,                                                          "ACCOUNT TYPE
          lifnr   TYPE bseg-lifnr,                                                          "ACCOUNT TYPE
          bschl   TYPE bschl,                                                           "POSTING KEY
          shkzg   TYPE shkzg,                                                    "DEBIT/CREDIT
          dmbtr   TYPE dmbtr,                                                         "AMOUNT
          h_budat TYPE budat,                                                          "POSTING DATE
          zfbdt   TYPE dzfbdt,                                                         "BASELINE DATE
          sgtxt   TYPE sgtxt,
          gsber   TYPE gsber,
        END OF ty_bseg,

        BEGIN OF ty_bkpf,
          bukrs TYPE bukrs,
          belnr TYPE belnr_d,
          gjahr TYPE gjahr,
          bldat TYPE bldat,
          awkey TYPE awkey,    "OBJECT KEY
          bktxt TYPE bkpf-bktxt,
          xblnr TYPE xblnr,
        END OF ty_bkpf,

        BEGIN OF ty_lfa1,
          lifnr TYPE lifnr,
          werks TYPE werks_ext,
          adrnr TYPE adrnr,
          psohs TYPE psohs,
          name1 TYPE name1_gp,
          stras TYPE stras_gp,
          ort01 TYPE ort01_gp,
          pstlz TYPE pstlz,
        END OF ty_lfa1,

        BEGIN OF ty_t001,
          bukrs TYPE bukrs,
          butxt TYPE butxt,
          ort01 TYPE ort01,
          adrnr TYPE adrnr,
        END OF ty_t001,

*        BEGIN OF TY_T001W,
*        WERKS TYPE WERKS_D,
*        ADRNR TYPE ADRNR,
*        NAME1 TYPE NAME1,
*        STRAS TYPE STRAS,
*        ORT01 TYPE ORT01,
*        PSTLZ TYPE PSTLZ,
*        END OF TY_T001W,

        BEGIN OF ty_adrc,
          addrnumber TYPE ad_addrnum,
          name1      TYPE ad_name1,
          house_num1 TYPE ad_hsnm1,                                     "HOUSE NO
          street     TYPE ad_street,
          city1      TYPE ad_city1,
          post_code1 TYPE ad_pstcd1,
        END OF ty_adrc,

        BEGIN OF ty_inw_hdr,
          invoice    TYPE zinw_t_hdr-invoice,
          bill_num   TYPE zinw_t_hdr-bill_num,
          debit_note TYPE zinw_t_hdr-debit_note,
        END OF ty_inw_hdr.

DATA  : it_bseg     TYPE TABLE OF ty_bseg,
        wa_bseg     TYPE ty_bseg,
        it_bkpf     TYPE TABLE OF ty_bkpf,
        wa_bkpf     TYPE ty_bkpf,
        it_lfa1     TYPE TABLE OF ty_lfa1,
        wa_lfa1     TYPE ty_lfa1,
        it_t001     TYPE TABLE OF ty_t001,
        wa_t001     TYPE ty_t001,
*        IT_T001W TYPE TABLE OF TY_T001W,
*        WA_T001W TYPE TY_T001W,
        it_adrc     TYPE TABLE OF ty_adrc,
        wa_adrc     TYPE ty_adrc,
        it_adrc_p   TYPE TABLE OF ty_adrc,                                   "PLANT ADDRESS
        wa_adrc_p   TYPE ty_adrc,
        it_header   TYPE TABLE OF zhead,
        wa_header   TYPE zhead,
        it_item     TYPE TABLE OF zitem_data,
        wa_item     TYPE zitem_data,
        ls_item     TYPE zvend,
        credit_tot  TYPE dmbtr,
        debit_tot   TYPE dmbtr,
        bldat_m     TYPE bldat,
        zfbdt_m     TYPE dzfbdt,
        paid_amount TYPE dmbtr,
        total       TYPE dmbtr,
        total1      TYPE dmbtr,
        bldat_low   TYPE bldat,
        bldat_high  TYPE bldat,
        lt_inw_hdr  TYPE TABLE OF ty_inw_hdr.

DATA: f_name TYPE rs38l_fnam.

DATA: it_fieldcat  TYPE TABLE OF slis_fieldcat_alv,
      it_fieldcat1 TYPE TABLE OF slis_fieldcat_alv,
      wa_fieldcat  TYPE slis_fieldcat_alv,
      wa_layout    TYPE slis_layout_alv,
      it_events    TYPE slis_t_event,
      wa_events    LIKE LINE OF it_events,
      it_sort      TYPE slis_t_sortinfo_alv,
      wa_sort      TYPE slis_sortinfo_alv.
