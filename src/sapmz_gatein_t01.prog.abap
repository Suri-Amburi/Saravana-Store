*&---------------------------------------------------------------------*
*& Include          SAPMZ_GATEIN_T01
*&---------------------------------------------------------------------*

DATA :
  p_lr_no          TYPE zlr,
  p_trns           TYPE ztrans,
  p_qr_code        TYPE zqr_code,
  gs_inwd_hdr      TYPE zinw_t_hdr,
  ok_9000          TYPE sy-ucomm,
  ok_9001          TYPE sy-ucomm,
  container        TYPE REF TO cl_gui_custom_container,
  grid             TYPE REF TO cl_gui_alv_grid,
  mycontainer      TYPE scrfname VALUE 'MYCONTAINER',
  gt_exclude       TYPE ui_functions,
  gs_layo          TYPE lvc_s_layo,
  gt_fieldcat      TYPE lvc_t_fcat,
  gv_subrc         TYPE sy-subrc,
  gv_cur_field(10),
  gv_cur_value(10),
  gv_ebeln         TYPE ebeln,
  gv_mod(1),
  gv_bsart         TYPE bsart,
  r_lp(1),
  r_op(1).

* Event Class
CLASS event_class DEFINITION DEFERRED.
DATA: gr_event TYPE REF TO event_class.

** Event Handeler Class
CLASS event_class DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_data_changed
                FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.
ENDCLASS.

* Class Implemntation
CLASS event_class IMPLEMENTATION.
  METHOD handle_data_changed.
    DATA : error_in_data(1).
*** Refreshing Table Data
    IF grid IS BOUND.
      CALL METHOD grid->refresh_table_display.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CONSTANTS :
  c_x(1)       VALUE 'X',
  c_save(4)    VALUE 'SAVE',
  c_back(4)    VALUE 'BACK',
  c_exit(4)    VALUE 'EXIT',
  c_cancel(6)  VALUE 'CANCEL',
  c_execute(3) VALUE 'EXE',
  c_rb(3)      VALUE 'RB',
  c_doc        TYPE bsart  VALUE 'ZTSR',
  c_01(2)      VALUE '01',
  c_qr_code(7) VALUE 'QR_CODE',
  c_qr02(4)    VALUE 'QR02',
  c_02(4)      VALUE '02',
  c_d(1)       VALUE 'D',
  c_9(1)       VALUE '9',    " Service
  c_k(1)       VALUE 'K',    " Cost Center
  c_ztat(4)    VALUE 'ZTAT',
  c_zlop(4)    VALUE 'ZLOP'.

TYPES :
  BEGIN OF ty_final,
    qr_code      TYPE zinw_t_hdr-qr_code,
    inwd_doc     TYPE zinw_t_hdr-inwd_doc,
    ebeln        TYPE zinw_t_hdr-ebeln,
    lifnr        TYPE zinw_t_hdr-lifnr,
    name1        TYPE zinw_t_hdr-name1,
    status       TYPE zinw_t_hdr-status,
    bill_num     TYPE zinw_t_hdr-bill_num,
    trns         TYPE zinw_t_hdr-trns,
    lr_no        TYPE zinw_t_hdr-lr_no,
    act_no_bud   TYPE zinw_t_hdr-act_no_bud,
    bk_station   TYPE zinw_t_hdr-bk_station,
    small_bundle TYPE zinw_t_hdr-small_bundle,
    big_bundle   TYPE zinw_t_hdr-big_bundle,
    frt_no       TYPE zinw_t_hdr-frt_no,
    frt_amt      TYPE zinw_t_hdr-frt_amt,
    bay          TYPE zqr_t_add-bay,             " Bay Details : Added By Suri : 01.04.2020
    post_date    TYPE budat,                     " Posting Date manual input : 01.06.2020
  END OF ty_final,

  BEGIN OF ty_price,
    lifnr      TYPE a729-lifnr,
    srvpos     TYPE a729-srvpos,
    userf1_txt TYPE a729-userf1_txt,
    knumh      TYPE a729-knumh,
    kbetr      TYPE konp-kbetr,
  END OF ty_price.

DATA :
  gt_hdr TYPE STANDARD TABLE OF ty_final,
  gs_hdr TYPE ty_final.

DATA : gt_price TYPE STANDARD TABLE OF ty_price.

*** PO Creation Data
DATA:
  header               LIKE bapimepoheader,
  headerx              LIKE bapimepoheaderx,
  item                 TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
  poschedule           TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
  poschedulex          TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
  itemx                TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
  return               TYPE TABLE OF bapiret2,
  poservices           TYPE TABLE OF bapiesllc,
  ls_poservices        TYPE bapiesllc,
  posrvaccessvalues    TYPE TABLE OF  bapiesklc,
  ls_posrvaccessvalues TYPE bapiesklc,
  poaccount            TYPE TABLE OF bapimepoaccount,
  ls_poaccount         TYPE bapimepoaccount,
  poaccountx           TYPE TABLE OF  bapimepoaccountx,
  ls_poaccountx        TYPE  bapimepoaccountx.
