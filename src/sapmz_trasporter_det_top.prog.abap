*&---------------------------------------------------------------------*
*& Include SAPMZ_TRASPORTER_DET_TOP                 - Module Pool      SAPMZ_TRASPORTER_DET
*&---------------------------------------------------------------------*
PROGRAM sapmz_trasporter_det.
DATA: ok_code LIKE sy-ucomm.
TYPES : BEGIN OF ty_zinw_t_hdr,
          qr_code    TYPE zqr_code,
          ebeln      TYPE ebeln,
          lifnr      TYPE elifn,
          service_po TYPE ebeln,
          mblnr      TYPE mblnr,
          lr_no      TYPE zlr,
          status     TYPE zstatus,

        END OF ty_zinw_t_hdr.
TYPES : BEGIN OF ty_ekbe,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          belnr TYPE mblnr,
          dmbtr TYPE dmbtr_cs,
          menge TYPE menge_d,
          bewtp TYPE bewtp,
        END OF ty_ekbe.

TYPES : BEGIN OF ty_ekpo,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          menge TYPE bstmg,
          netwr TYPE bwert,
          mwskz TYPE mwskz,
        END OF ty_ekpo.

TYPES : BEGIN OF ty_final ,
          service_po TYPE ebeln,
          amount     TYPE dmbtr_cs,
          lr_no      TYPE zlr,
          qr_code    TYPE zqr_code,
          tax        TYPE dmbtr_cs,
          tds        TYPE dmbtr_cs,
          bewtp     TYPE bewtp,
        END OF ty_final,

        BEGIN OF ty_whtax,
          witht     TYPE witht,
          wt_withcd TYPE wt_withcd,
          qsatz   TYPE qsatz,
        END OF ty_whtax.

DATA : it_final TYPE TABLE OF  ty_final,
       wa_final TYPE ty_final.
DATA : it_zinw_t_hdr TYPE TABLE OF ty_zinw_t_hdr,
       wa_zinw_t_hdr TYPE ty_zinw_t_hdr,
       it_ekbe       TYPE TABLE OF ty_ekbe,
       it_ekbe1      TYPE TABLE OF ty_ekbe,
       it_ekpo       TYPE TABLE OF ty_ekpo,
       wa_ekbe       TYPE ty_ekbe,
       wa_ekbe1      TYPE ty_ekbe,
       wa_ekpo       TYPE ty_ekpo.
DATA : lv_qr       TYPE zinw_t_hdr-qr_code,
       qr_code     TYPE zinw_t_hdr-qr_code,
       lv_lifnr    TYPE lifnr,
       lv_name     TYPE lfa1-name1,
       lv_bill(16) TYPE c,
       lv_Pmode     TYPE zqr_t_add-payment_mode.

DATA : lv_invoice_no(20) TYPE c.
DATA:container   TYPE REF TO cl_gui_custom_container,
     grid        TYPE REF TO cl_gui_alv_grid,
     it_exclude  TYPE ui_functions,
     lw_layo     TYPE lvc_s_layo,
     lt_fieldcat TYPE  lvc_t_fcat.
DATA: lt_exclude TYPE ui_functions.
DATA : ls_stable TYPE lvc_s_stbl.
DATA : lv_amt     TYPE dmbtr_cs.

***********FOR PAYMENT
DATA :
  gt_hdr TYPE TABLE OF zinw_t_hdr,
  gs_hdr TYPE zinw_t_hdr.
DATA : it_bkpf    TYPE TABLE OF bkpf,
       wa_bkpf    TYPE bkpf,
       it_bseg    TYPE TABLE OF bseg,
       wa_bseg    TYPE bseg,
       wa_rbkp_db TYPE rbkp,
       wa_rbkp_iv TYPE rbkp,
       ls_ekbe    TYPE ekbe,
       wa_bsik    TYPE bsik.

DATA : lv_amount TYPE bsik-wrbtr .
TYPES:BEGIN OF ty_alv,
        sno       TYPE i,
        bukrs     TYPE bukrs,
        gjahr     TYPE gjahr,
        lifnr     TYPE lfa1-lifnr,
        name1     TYPE adrc-name1,
        wrbtr     TYPE bsik-wrbtr,
        c_belnr   TYPE bsid-belnr,
        c_augbl   TYPE bsad-augbl,
        c_message TYPE char100,
        v_belnr   TYPE bsik-belnr,
        v_augbl   TYPE bsak-augbl,
        v_message TYPE char100,
*  c_type    TYPE c,
      END OF ty_alv.
DATA : gt_alv TYPE TABLE OF ty_alv,
       ls_alv TYPE ty_alv.
DATA :  lv_payment TYPE char50.
*** Constants
CONSTANTS :
  c_rfbu       TYPE glvor VALUE 'RFBU',
  c_kz         TYPE blart VALUE 'KZ',
  c_comp_code  TYPE char4 VALUE '1000',
  c_x(1)       VALUE 'X',
  c_e(1)       VALUE 'E',
  c_qr_code(7) VALUE 'QR_CODE',
  c_qr07(7)    VALUE 'QR07',
  c_01(2)      VALUE '01',
  c_02(2)      VALUE '02',
  c_03(2)      VALUE '03',
  c_04(2)      VALUE '04',
  c_05(2)      VALUE '05',
  c_06(2)      VALUE '06',
  c_07(2)      VALUE '07',
  c_gl         TYPE hkont VALUE '0000140001'.

DATA :  gs_whtax TYPE ty_whtax.
