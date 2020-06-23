*&---------------------------------------------------------------------*
*& Include          ZFI_IMBRS_R01_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.
TABLES: t012k.
TYPES: BEGIN OF type_seldata,
         sel      TYPE c,
         hkont    TYPE t012k-hkont,
         descr    TYPE char25,
         belnr    TYPE bsis-belnr,
         posdat   TYPE bsis-budat,
         gsber    TYPE bsis-gsber,
         name     TYPE kna1-name1,
         dmbtr    TYPE bsis-dmbtr,
         chect    TYPE payr-chect,
         bktxt    TYPE bkpf-bktxt,
         budat    TYPE bsis-budat,
         prctr    TYPE prctr,
         drcr(03) TYPE c,
         wrbtr    TYPE bsis-wrbtr,
         waers    TYPE bsis-waers,
       END OF type_seldata.

TYPES: BEGIN OF type_t012k,
         bukrs TYPE t012k-bukrs,
         hbkid TYPE t012k-hbkid,
         hktid TYPE t012k-hktid,
         bankn TYPE t012k-bankn,
         hkont TYPE t012k-hkont,
       END OF type_t012k.

TYPES: BEGIN OF type_bsis,
         bukrs TYPE bsis-bukrs,
         hkont TYPE bsis-hkont,
         gjahr TYPE bsis-gjahr,
         belnr TYPE bsis-belnr,
         budat TYPE bsis-budat,
         waers TYPE bsis-waers,
         shkzg TYPE bsis-shkzg,
         gsber TYPE bsis-gsber,
         dmbtr TYPE bsis-dmbtr,
         wrbtr TYPE bsis-wrbtr,
         prctr TYPE bsis-prctr,
       END OF type_bsis.

TYPES: BEGIN OF type_payr,
         zbukr TYPE payr-zbukr,
         chect TYPE payr-chect,
         vblnr TYPE payr-vblnr,
         gjahr TYPE payr-gjahr,
         zaldt TYPE payr-zaldt,
       END OF type_payr.

TYPES: BEGIN OF type_flext,
         ryear  TYPE faglflext-ryear,
         drcrk  TYPE faglflext-drcrk,
         rpmax  TYPE faglflext-rpmax,
         racct  TYPE faglflext-racct,
         rbukrs TYPE faglflext-rbukrs,
         prctr  TYPE faglflext-prctr,
         hslvt  TYPE faglflext-hslvt,
         hsl01  TYPE faglflext-hsl01,
         hsl02  TYPE faglflext-hsl02,
         hsl03  TYPE faglflext-hsl03,
         hsl04  TYPE faglflext-hsl04,
         hsl05  TYPE faglflext-hsl05,
         hsl06  TYPE faglflext-hsl06,
         hsl07  TYPE faglflext-hsl07,
         hsl08  TYPE faglflext-hsl08,
         hsl09  TYPE faglflext-hsl09,
         hsl10  TYPE faglflext-hsl10,
         hsl11  TYPE faglflext-hsl11,
         hsl12  TYPE faglflext-hsl12,
         hsl13  TYPE faglflext-hsl13,
         hsl14  TYPE faglflext-hsl14,
         hsl15  TYPE faglflext-hsl15,
         hsl16  TYPE faglflext-hsl16,
       END OF type_flext.

TYPES: BEGIN OF type_log,
         hkont TYPE bsis-hkont,
         belnr TYPE bsis-belnr,
         msg   TYPE string,
       END OF type_log.

TYPES: BEGIN OF type_bseg,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         gjahr TYPE bseg-gjahr,
         koart TYPE bseg-koart,
         shkzg TYPE bseg-shkzg,
         hkont TYPE bseg-hkont,
         kunnr TYPE bseg-kunnr,
         lifnr TYPE bseg-lifnr,
       END OF type_bseg.

TYPES: BEGIN OF type_final,
         belnr TYPE bseg-belnr,
         budat TYPE bsis-budat,
         name1 TYPE kna1-name1,
         chect TYPE payr-chect,
         cdate TYPE bkpf-bldat,
         dmbtr TYPE bsis-dmbtr,
       END OF type_final.

TYPES: BEGIN OF type_lfa1,
         lifnr TYPE lfa1-lifnr,
         name1 TYPE lfa1-name1,
       END OF type_lfa1.

TYPES: BEGIN OF type_kna1,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
       END OF type_kna1.

TYPES: BEGIN OF type_skat,
         ktopl TYPE skat-ktopl,
         saknr TYPE skat-saknr,
         txt50 TYPE skat-txt50,
       END OF type_skat.

TYPES: BEGIN OF type_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
         blart TYPE bkpf-blart,
         xblnr TYPE bkpf-xblnr,
         bktxt TYPE bkpf-bktxt,
         budat TYPE bkpf-budat,
         monat TYPE bkpf-monat,
       END OF type_bkpf.

TYPES: BEGIN OF type_bseg_sa,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         gjahr TYPE bseg-gjahr,
         hkont TYPE bseg-hkont,
       END OF type_bseg_sa.


DATA: it_seldata TYPE STANDARD TABLE OF type_seldata,
      wa_seldata TYPE type_seldata,
      it_seltemp TYPE STANDARD TABLE OF type_seldata,
      wa_seltemp TYPE type_seldata,
      wa_t012k   TYPE type_t012k,
      it_inbsis  TYPE STANDARD TABLE OF type_bsis,
      wa_bsis    TYPE type_bsis,
      it_oubsis  TYPE STANDARD TABLE OF type_bsis,
      it_in_out  TYPE STANDARD TABLE OF type_bsis,
      wa_in_out  TYPE type_bsis,
      it_temp    TYPE STANDARD TABLE OF type_bsis,
      it_payr    TYPE STANDARD TABLE OF type_payr,
      wa_payr    TYPE type_payr,
      it_flext   TYPE STANDARD TABLE OF type_flext,
      wa_flext   TYPE type_flext,
      it_log     TYPE STANDARD TABLE OF type_log,
      wa_log     TYPE type_log,
      it_bsegk   TYPE STANDARD TABLE OF type_bseg,
      it_bsegd   TYPE STANDARD TABLE OF type_bseg,
      wa_bseg    TYPE type_bseg,
      it_in      TYPE STANDARD TABLE OF type_final,
      wa_in      TYPE type_final,
      it_out     TYPE STANDARD TABLE OF type_final,
      wa_out     TYPE type_final,
      it_inbseg  TYPE STANDARD TABLE OF type_bseg,
      wa_inbseg  TYPE type_bseg,
      it_oubseg  TYPE STANDARD TABLE OF type_bseg,
      wa_oubseg  TYPE type_bseg,
      it_inbseg1 TYPE STANDARD TABLE OF type_bseg,
      wa_inbseg1 TYPE type_bseg,
      it_oubseg1 TYPE STANDARD TABLE OF type_bseg,
      wa_oubseg1 TYPE type_bseg,
      it_lfa1    TYPE STANDARD TABLE OF type_lfa1,
      wa_lfa1    TYPE type_lfa1,
      it_kna1    TYPE STANDARD TABLE OF type_kna1,
      wa_kna1    TYPE type_kna1,
      it_skat    TYPE STANDARD TABLE OF type_skat,
      wa_skat    TYPE type_skat,
      it_bkpf    TYPE STANDARD TABLE OF type_bkpf,
      wa_bkpf    TYPE type_bkpf,
      it_bseg_sa TYPE STANDARD TABLE OF type_bseg_sa,
      wa_bseg_sa TYPE type_bseg_sa.


DATA: it_save TYPE TABLE OF zmbrs,
      wa_save TYPE zmbrs.


DATA: it_fieldcat  TYPE TABLE OF slis_fieldcat_alv,
      it_fieldcat1 TYPE TABLE OF slis_fieldcat_alv,
      wa_fieldcat  TYPE slis_fieldcat_alv,
      wa_layout    TYPE slis_layout_alv,
      it_events    TYPE slis_t_event,
      wa_events    LIKE LINE OF it_events,
      it_bdcdata   TYPE STANDARD TABLE OF bdcdata,
      wa_bdcdata   TYPE bdcdata,
      it_mess      TYPE STANDARD TABLE OF bdcmsgcoll,
      wa_mess      TYPE bdcmsgcoll,
      it_sort      TYPE slis_t_sortinfo_alv,
      wa_sort      TYPE slis_sortinfo_alv.
*FOR RFC DECLARATION

DATA: query_table LIKE dd02l-tabname,
      options     LIKE rfc_db_opt,
      fields      LIKE rfc_db_fld,
      t_fields    TYPE STANDARD TABLE OF rfc_db_fld,
      t_options   TYPE STANDARD TABLE OF rfc_db_opt,
      data        LIKE tab512,
      t_data      TYPE STANDARD TABLE OF tab512.
DATA: g_fdate  TYPE bkpf-budat,
      g_tdate  TYPE bkpf-budat,
      g_text1  TYPE t012t-text1,
      g_rbank  TYPE t012k-hkont,
      g_inbank TYPE t012k-hkont,
      g_oubank TYPE t012k-hkont,
      g_poper  TYPE t009b-poper,
      g_obal   TYPE faglflexa-hsl,
      g_oubal  TYPE faglflexa-hsl,
      g_inbal  TYPE faglflexa-hsl,
      g_ktopl  TYPE t001-ktopl.
DATA: it_enq TYPE TABLE OF seqg7,
      wa_enq TYPE seqg7.
DATA : w_garg TYPE seqg3-garg.
DATA : temp TYPE gjahr.

DATA: s_query_table LIKE dd02l-tabname,
      sw_options    LIKE rfc_db_opt,
      sw_fields     LIKE rfc_db_fld,
      st_fields     TYPE STANDARD TABLE OF rfc_db_fld,
      st_options    TYPE STANDARD TABLE OF rfc_db_opt,
      sw_data       LIKE tab512,
      st_data       TYPE STANDARD TABLE OF tab512.

DATA: gt_t012k TYPE STANDARD TABLE OF type_t012k.

  data: lv_gl_credit TYPE bsis-dmbtr,
        lv_gl_debit  TYPE bsis-dmbtr,
        lv_tot_gl    TYPE bsis-dmbtr.

  data: lv_diff TYPE char20.
