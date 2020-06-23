*&---------------------------------------------------------------------*
*& Include          ZMM_SCANNING_QR_TOP
*&---------------------------------------------------------------------*
*** Types declaration for EKKO table
TYPES: BEGIN OF ty_hdr,
         ebeln   TYPE ebeln,
         qr_code TYPE zqr_code,
       END OF ty_hdr.

*** Types declaration for Output data structure
TYPES: BEGIN OF ty_det,
         ebeln       TYPE ebeln,
         mblnr       TYPE mblnr,
         mjahr       TYPE mjahr,
         msg_type(1),
         message     TYPE bapi_msg,
         message1    TYPE bapi_msg,
         id          TYPE symsgid,
         type        TYPE bapi_mtype,
         entrysheet  TYPE symsgv,
       END OF ty_det.

*** Internal Tables Declaration
DATA: lt_hdr  TYPE STANDARD TABLE OF zinw_t_hdr,
      lt_item TYPE STANDARD TABLE OF zinw_t_item,
      lt_det  TYPE STANDARD TABLE OF ty_det.

*** Work area Declarations
DATA: wa_hdr  TYPE zinw_t_hdr,
      wa_item TYPE zinw_t_item,
      wa_det  TYPE ty_det.

*** BAPI Structure Declaration
DATA:
  wa_gmvt_header  TYPE bapi2017_gm_head_01,
  wa_gmvt_item    TYPE bapi2017_gm_item_create,
  wa_gmvt_headret TYPE bapi2017_gm_head_ret,
  lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
  lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create.
FIELD-SYMBOLS :
  <ls_bapiret> TYPE bapiret2.

*** Constants
CONSTANTS :
  c_101(3)          VALUE '101',
  c_103(3)          VALUE '107',
  c_mvt_ind_b(1)    VALUE 'B',
  c_mvt_01(2)       VALUE '01',
  c_x(1)            VALUE 'X',
  c_e(1)            VALUE 'E',
  c_zlop(4)         VALUE 'ZLOP',
  c_zosp(4)         VALUE 'ZOSP',
  c_exit(4)         VALUE 'EXIT',
  c_back(4)         VALUE 'BACK',
  c_cancel(4)       VALUE 'CANCEL',
  c_label(5)        VALUE 'LABEL',
  c_grpo_s(4)       VALUE 'GR_S',
  c_grpo_p(4)       VALUE 'GR_P',
  c_01(2)           VALUE '01',
  c_02(2)           VALUE '02',
  c_03(2)           VALUE '03',
  c_04(2)           VALUE '04',
  c_qr03(4)         VALUE 'QR03',
  c_qr04(4)         VALUE 'QR04',
  c_qr_code(7)      VALUE 'QR_CODE',
  c_ztat(4)         VALUE 'ZTAT',
  c_soe(4)          VALUE 'SOE',
  c_se01(4)         VALUE 'SE01',
  c_zkp0(4)         VALUE 'ZKP0',
  c_uc(2)           VALUE 'ZE',
  c_zvos(4)         VALUE 'ZVOS',
  c_zvlo(4)         VALUE 'ZVLO',
  c_fv(30)          VALUE 'FRUITSANDVEGETABLE',
  c_consumables(30) VALUE 'CONSUMABLES'.

DATA :
  gv_mat_doc  TYPE mblnr,
  gv_doc_year TYPE mjahr.
