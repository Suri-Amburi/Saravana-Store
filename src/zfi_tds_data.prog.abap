*&---------------------------------------------------------------------*
*& Include          ZFI_TDS_DATA
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
TABLES: bsik,
        bseg,                                    " Accounting Document Segment
        t059z,
        j_1iewtnumgr.                                   " Withholding tax code (enhanced functions)

TYPES: BEGIN OF ty_t059z,
         witht     TYPE  witht,               " Indicator for withholding tax type
         wt_withcd TYPE  wt_withcd,           " Withholding tax code
         qscod     TYPE  wt_owtcd,            " Official Withholding Tax Key
       END OF   ty_t059z.

DATA : year TYPE bkpf-gjahr.
DATA :  wa_form_type TYPE char3.

TYPES: BEGIN OF ty_final,
         belnr         TYPE  belnr_d,             " Accounting Document
         xblnr         TYPE bkpf-xblnr,
         buzei         TYPE  buzei,               " Number of Line Item Within Accounting Document
         j_1ibuzei     TYPE  buzei,               " Number of Line Item Within Accounting Document
         ackn_number   TYPE  j_1iackn_number,     " Acknowledgement Number
         qscod         TYPE  wt_owtcd,            " Official tax key
         secco         TYPE  secco,               " Section code              "Note 1847679
         lifnr         TYPE  lifnr,               " Vendor
         kunnr         TYPE  kunnr,               " Customer
         name          TYPE  name,                " Customer or vendro name   "Note 1847679
         qsrec         TYPE  wt_qsrec,            " Receipent type            "Note 1847679
         witht         TYPE  witht,               " Withholding tax type
         wt_withcd     TYPE  wt_withcd,           " Withholding tax code
         qsatz         TYPE  dec8_2, "wt_qsatz,            " Withholding tax rate
         wt_qsshh      TYPE  wt_bs,               " Wtax Base Amount
         wt_qbshh      TYPE  wt_wt,               " Wtax document amount
         shkzg         TYPE  bseg-shkzg,          " Debit/credit indicator  "Note 1596609
         j_1iintchln   TYPE  j_1iintchln,         " Internal challan No
         j_1iintchdt   TYPE  j_1iintchdt,         " Internal Challan date
         j_1iextchln   TYPE  j_1iextchln,         " External Challan No
         j_1iextchdt   TYPE  j_1iextchdt,         " External Challan date
         ctnumber      TYPE  ctnumber,            " Certificate No
         j_1icertdt    TYPE  j_1icertdt,          " Certificate Date
         line_color(4) TYPE  c,
         j_1ipanno     TYPE  kna1-j_1ipanno,      " Pan number
         gsber         TYPE  gsber,               " Business Area
         budat         TYPE  budat,               " Posting Date
         blart         TYPE  blart,               " Document type
       END OF ty_final.

TYPES: BEGIN OF ty_month,
         mnth TYPE text12,
       END OF ty_month.

TYPES: BEGIN OF ty_quart,
         qrtr TYPE char2,
       END OF ty_quart.

TYPES: BEGIN OF ty_qscod,
         qscod  TYPE wt_owtcd,
         text40 TYPE text40,
       END OF ty_qscod.

TYPES: BEGIN OF ty_movend,
         lifnr     TYPE lifnr,
         j_1ipanno TYPE j_1ipanno,
       END OF ty_movend.

DATA: gt_bkpf         TYPE STANDARD TABLE OF bkpf         INITIAL SIZE 0,
      gt_bsik         TYPE STANDARD TABLE OF bsik         INITIAL SIZE 0,
      gt_bsid         TYPE STANDARD TABLE OF bsid         INITIAL SIZE 0,
      "gt_bseg         TYPE STANDARD TABLE OF bseg         INITIAL SIZE 0,     "Note 2175802
*      gt_witem        TYPE STANDARD TABLE OF with_item    INITIAL SIZE 0,
      gt_final        TYPE STANDARD TABLE OF ty_final     INITIAL SIZE 0,
      gt_t059z        TYPE STANDARD TABLE OF ty_t059z     INITIAL SIZE 0,
      gt_movend       TYPE STANDARD TABLE OF ty_movend    INITIAL SIZE 0,
      gt_j_1iewt_ackn TYPE STANDARD TABLE OF j_1iewt_ackn INITIAL SIZE 0,
      gt_month        TYPE STANDARD TABLE OF ty_month     INITIAL SIZE 0,
      gt_quart        TYPE STANDARD TABLE OF ty_quart     INITIAL SIZE 0,
      gt_ret_mn       LIKE STANDARD TABLE OF ddshretval   INITIAL SIZE 0,
      gt_ret_qt       LIKE STANDARD TABLE OF ddshretval   INITIAL SIZE 0,
      gt_j_1iewtchln  TYPE STANDARD TABLE OF j_1iewtchln  INITIAL SIZE 0,
      gt_qscod        TYPE STANDARD TABLE OF ty_qscod     INITIAL SIZE 0.
DATA : BEGIN OF gt_witem OCCURS  0.
         INCLUDE STRUCTURE with_item.
         DATA: qscod LIKE t059z-qscod,
       END OF gt_witem.
DATA: gt_callback TYPE TABLE OF ldbcb,
      gs_callback LIKE LINE OF gt_callback.

DATA: gt_seltab TYPE TABLE OF rsparams,
      gs_seltab LIKE LINE OF gt_seltab.

DATA: "gs_bseg         TYPE bseg,     "Note 2175802
  gs_bkpf         TYPE bkpf,
  gs_movend       TYPE ty_movend,
  gs_bsik         TYPE bsik,
  gs_bsid         TYPE bsid,
  gs_witem        LIKE LINE OF gt_witem,
  gs_final        TYPE ty_final,
  gs_t059z        TYPE ty_t059z,
  gs_j_1iewt_ackn TYPE j_1iewt_ackn,
  gs_month        TYPE ty_month,
  gs_quart        TYPE ty_quart,
  gs_qscod        TYPE ty_qscod,
  gs_j_1iewtchln  TYPE j_1iewtchln.

DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv .

DATA: gs_layout       TYPE slis_layout_alv,
      gs_fieldcatalog TYPE slis_fieldcat_alv,
      gv_period       TYPE j_1iperiod,
      gv_text_period  TYPE char50,
      gv_text_month   TYPE char50,
      gv_butxt        TYPE butxt,
      gv_sec_name(35) TYPE c,
      gv_cnt_recs     TYPE i,
      gv_cnt_flt_recs TYPE i,
      gv_secname      TYPE name1,
      gv_prev_mon     TYPE bumon,
      gv_periv        TYPE periv,
      gv_prev_poper   TYPE poper,
      gv_next_poper   TYPE poper,
      gv_next_year    TYPE bdatj,
      gv_next_mon     TYPE bumon,
      gv_date(8),
      gv_date_final   TYPE budat,
      gv_totdocs      TYPE i,
      gv_faultdocs    TYPE i,
      gv_coname       TYPE butxt,
      gv_tanno        TYPE j_1i_tanno,
      gv_repid        LIKE sy-repid.

DATA: name       TYPE vrm_id,
      list       TYPE vrm_values,
      startdate  TYPE budat,
      enddate    TYPE budat,
      gv_prevyr  TYPE gjahr,
      first_date TYPE budat,    "Note 1592267
      myear(5),
      qyear(5),
      value      LIKE LINE OF list.

CONSTANTS: c_jan         TYPE char7            VALUE 'JANUARY',
           c_feb         TYPE char8            VALUE 'FEBRUARY',
           c_mar         TYPE char5            VALUE 'MARCH',
           c_apr         TYPE char5            VALUE 'APRIL',
           c_may         TYPE char3            VALUE 'MAY',
           c_jun         TYPE char4            VALUE 'JUNE',
           c_jul         TYPE char4            VALUE 'JULY',
           c_aug         TYPE char6            VALUE 'AUGUST',
           c_sep         TYPE char9            VALUE 'SEPTEMBER',
           c_oct         TYPE char7            VALUE 'OCTOBER',
           c_nov         TYPE char8            VALUE 'NOVEMBER',
           c_dec         TYPE char8            VALUE 'DECEMBER',
           c_q1          TYPE char2            VALUE 'Q1',
           c_q2          TYPE char2            VALUE 'Q2',
           c_q3          TYPE char2            VALUE 'Q3',
           c_q4          TYPE char2            VALUE 'Q4',
           gc_x          TYPE c                VALUE 'X',
           gc_s          TYPE c                VALUE 'S',
           gc_h          TYPE c                VALUE 'H',
           c_e           TYPE c                VALUE 'E',
           c_w           TYPE c                VALUE 'W',
           gc_from       TYPE char4            VALUE 'From',
           gc_to         TYPE char2            VALUE 'to',
           gc_chdate     TYPE j_1iintchdt      VALUE '00000000',
           gc_lcolor     TYPE slis_fieldname   VALUE 'LINE_COLOR',
           c_dot         TYPE c                VALUE '.',
           c_01          TYPE char2            VALUE '01',
           c_02          TYPE char2            VALUE '02',
           c_03          TYPE char2            VALUE '03',
           c_04          TYPE char2            VALUE '04',
           c_05          TYPE char2            VALUE '05',
           c_06          TYPE char2            VALUE '06',
           c_07          TYPE char2            VALUE '07',
           c_08          TYPE char2            VALUE '08',
           c_09          TYPE char2            VALUE '09',
           c_10          TYPE char2            VALUE '10',
           c_11          TYPE char2            VALUE '11',
           c_12          TYPE char2            VALUE '12',
           c_30          TYPE char2            VALUE '30',
           c_31          TYPE char2            VALUE '31',
           c_belnr       TYPE slis_fieldname   VALUE 'BELNR',
           c_xblnr       TYPE slis_fieldname   VALUE 'XBLNR',
           c_qscod       TYPE slis_fieldname   VALUE 'QSCOD',
           c_secco       TYPE slis_fieldname   VALUE 'SECCO',     "Note 1847679
           c_lifnr       TYPE slis_fieldname   VALUE 'LIFNR',
           c_kunnr       TYPE slis_fieldname   VALUE 'KUNNR',
           c_name        TYPE slis_fieldname   VALUE 'NAME' ,     "Note 1847679
           c_qsrec       TYPE slis_fieldname   VALUE 'QSREC',     "Note 1847679
           c_witht       TYPE slis_fieldname   VALUE 'WITHT',
           c_wt_withcd   TYPE slis_fieldname   VALUE 'WT_WITHCD',
           c_qsatz       TYPE slis_fieldname   VALUE 'QSATZ',
           c_wt_qsshh    TYPE slis_fieldname   VALUE 'WT_QSSHH',
           c_wt_qbshh    TYPE slis_fieldname   VALUE 'WT_QBSHH',
           c_shkzg       TYPE slis_fieldname   VALUE 'SHKZG',     "Note 1596609
           c_ackn_number TYPE slis_fieldname   VALUE 'ACKN_NUMBER',
           c_j_1iintchln TYPE slis_fieldname   VALUE 'J_1IINTCHLN',
           c_j_1iintchdt TYPE slis_fieldname   VALUE 'J_1IINTCHDT',
           c_j_1iextchln TYPE slis_fieldname   VALUE 'J_1IEXTCHLN',
           c_j_1iextchdt TYPE slis_fieldname   VALUE 'J_1IEXTCHDT',
           c_ctnumber    TYPE slis_fieldname   VALUE 'CTNUMBER',
           c_j_1icertdt  TYPE slis_fieldname   VALUE 'J_1ICERTDT',
           c_j_1ipanno   TYPE slis_fieldname   VALUE 'J_1IPANNO',
***************************
           c_gsber       TYPE slis_fieldname   VALUE 'GSBER',
           c_budat       TYPE slis_fieldname   VALUE 'BUDAT',
           c_blart       TYPE slis_fieldname   VALUE 'BLART',
**************************
           c_lselect     TYPE slis_formname    VALUE 'LINE_SELECTION',
           c_color       TYPE char4            VALUE 'C610',
           c_wit         TYPE ktosl            VALUE 'WIT',
           c_top         TYPE slis_formname    VALUE 'TOP-OF-PAGE',
           c_ic1         TYPE sy-ucomm         VALUE '&IC1',
           c_fb03        TYPE sy-tcode         VALUE 'FB03',
           c_bln         TYPE memoryid         VALUE 'BLN',
           c_buk         TYPE memoryid         VALUE 'BUK',
           c_gjr         TYPE memoryid         VALUE 'GJR',
           c_bsik        TYPE ldbnode          VALUE 'BSIK',
           c_bkpf        TYPE ldbnode          VALUE 'BKPF',
           c_bseg        TYPE ldbnode          VALUE 'BSEG',
           c_with_item   TYPE ldbnode          VALUE 'WITH_ITEM',
           c_lfa1        TYPE ldbnode          VALUE 'LFA1',
           c_kna1        TYPE ldbnode          VALUE 'KNA1',
           c_bsid        TYPE ldbnode          VALUE 'BSID',
           c_kbukrs      TYPE rsscr_name       VALUE 'KD_BUKRS',
           c_kgjahr      TYPE rsscr_name       VALUE 'KD_GJAHR',
           c_kbudat      TYPE rsscr_name       VALUE 'KD_BUDAT',
           c_klifnr      TYPE rsscr_name       VALUE 'KD_LIFNR',
           c_dbukrs      TYPE rsscr_name       VALUE 'DD_BUKRS',
           c_dgjahr      TYPE rsscr_name       VALUE 'DD_GJAHR',
           c_dbudat      TYPE rsscr_name       VALUE 'DD_BUDAT',
           c_dkunnr      TYPE rsscr_name       VALUE 'DD_KUNNR',
           c_kdf         TYPE trdir-ldbname    VALUE 'KDF',
           c_ddf         TYPE trdir-ldbname    VALUE 'DDF',
           c_eq          TYPE tvarv_opti       VALUE 'EQ',
           c_i           TYPE tvarv_sign       VALUE 'I',
           c_bt          TYPE tvarv_opti       VALUE 'BT',
           c_cwith       TYPE rsdsform         VALUE 'CALLBACK_WITH',
           c_cbseg       TYPE rsdsform         VALUE 'CALLBACK_BSEG',
           c_cbkpf       TYPE rsdsform         VALUE 'CALLBACK_BKPF',
           c_cbsid       TYPE rsdsform         VALUE 'CALLBACK_BSID',
           c_cbsik       TYPE rsdsform         VALUE 'CALLBACK_BSIK',
           c_ckna1       TYPE rsdsform         VALUE 'CALLBACK_KNA1',
           c_clfa1       TYPE rsdsform         VALUE 'CALLBACK_LFA1'.
DATA:      gv_reversal    TYPE i. "Note 1615465
DATA:      gv_ledger      LIKE t881-rldnr ."Note 1615465

TYPES:BEGIN OF ty_seccode,                                  "2051116
        bukrs   TYPE bukrs,
        seccode TYPE secco,
      END OF ty_seccode.

TYPES: BEGIN OF ty_bseg ,      "Note 2175802
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         gjahr TYPE bseg-gjahr,
         buzei TYPE bseg-buzei,
         secco TYPE bseg-secco,
         koart TYPE bseg-koart,
         qsskz TYPE bseg-qsskz,
         ktosl TYPE bseg-ktosl,
         shkzg TYPE bseg-shkzg,
         gsber TYPE bseg-gsber,
         qsshb TYPE bseg-qsshb,
       END OF ty_bseg.

DATA: gt_bseg TYPE TABLE OF ty_bseg,
      gs_bseg TYPE ty_bseg.

TYPES: BEGIN OF t_kna1,
         kunnr     TYPE kna1-kunnr,
         j_1ipanno TYPE kna1-j_1ipanno,
       END OF t_kna1,

       BEGIN OF t_lfa1,
         lifnr     TYPE lfa1-lifnr,
         j_1ipanno TYPE lfa1-j_1ipanno,
       END OF t_lfa1.
DATA: gt_lfa1 TYPE TABLE OF t_lfa1,
      gt_kna1 TYPE TABLE OF t_kna1,
      gs_lfa1 TYPE t_lfa1,
      gs_kna1 TYPE t_kna1.
