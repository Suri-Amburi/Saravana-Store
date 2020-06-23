*&---------------------------------------------------------------------*
*& Include          ZACCOUNTANT_DIARY_T01
*&---------------------------------------------------------------------*

  DATA : lv_edate TYPE  sy-datum .
  DATA : lv_sdate TYPE  sy-datum .
  DATA : lv_days TYPE p .
  DATA : lv_day(10) TYPE c .
  DATA : d(10) TYPE c .

  TYPES: BEGIN OF ty_final,
           ebeln    TYPE ekbe-ebeln,
           ebelp    TYPE ekbe-ebelp,
           bewtp    TYPE ekbe-bewtp,
           bwart    TYPE ekbe-bwart,
           menge    TYPE ekbe-menge,
           belnr    TYPE ekbe-belnr,
           gjahr    TYPE ekbe-gjahr,
           budat    TYPE ekbe-budat,
           lfbnr    TYPE ekbe-lfbnr,
           dmbtr    TYPE ekbe-dmbtr,
           matnr    TYPE ekbe-matnr,
           xblnr    TYPE ekbe-xblnr,
           buzei    TYPE ekbe-buzei,
           bsart    TYPE ekko-bsart,
           loekz    TYPE ekko-loekz,
           aedat    TYPE ekko-aedat,
           lifnr    TYPE ekko-lifnr,
           waers    TYPE ekko-waers,
           zterm    TYPE ekko-zterm,
           zbd1t    TYPE ekko-zbd1t,
           mblnr    TYPE matdoc-mblnr,
           zeile    TYPE matdoc-zeile,
           mwskz    TYPE ekpo-mwskz,
           kostl    TYPE ekkn-kostl,
           anln1    TYPE ekkn-anln1,
           due_date TYPE ekbe-budat,
           augbl    TYPE bsik-augbl,
           bukrs    TYPE bsik-bukrs,
           ekorg    TYPE lfm1-ekorg,
           ztagg    TYPE t052-ztagg,
           ztag1    TYPE t052-ztag1,

         END OF ty_final.

  DATA: gt_data   TYPE TABLE OF ty_final,
        wa_final  TYPE ty_final,
        it_final1 TYPE TABLE OF ty_final,
        wa_final1 TYPE ty_final,
        gt_data1  TYPE TABLE OF ty_final,
        g_data1   TYPE ty_final.

  TYPES :
    BEGIN OF ty_data,
      ebeln    TYPE ekbe-ebeln,
      ebelp    TYPE ekbe-ebelp,
      bewtp    TYPE ekbe-bewtp,
      bwart    TYPE ekbe-bwart,
      menge    TYPE ekbe-menge,
      belnr    TYPE ekbe-belnr,
      gjahr    TYPE ekbe-gjahr,
      budat    TYPE ekbe-budat,
      lfbnr    TYPE ekbe-lfbnr,
      dmbtr    TYPE ekbe-dmbtr,
      matnr    TYPE ekbe-matnr,
      xblnr    TYPE ekbe-xblnr,
      buzei    TYPE ekbe-buzei,
*      BEWTP    TYPE EKBE-BEWTP,
      bsart    TYPE ekko-bsart,
      loekz    TYPE ekko-loekz,
      aedat    TYPE ekko-aedat,
      lifnr    TYPE ekko-lifnr,
      waers    TYPE ekko-waers,
      zterm    TYPE ekko-zterm,
      zbd1t    TYPE ekko-zbd1t,
      mblnr    TYPE matdoc-mblnr,
      zeile    TYPE matdoc-zeile,
      mwskz    TYPE ekpo-mwskz,
      kostl    TYPE ekkn-kostl,
      anln1    TYPE ekkn-anln1,
**      LR_NO    TYPE ZLR,
**      QR_CODE   TYPE ZINW_T_HDR-QR_CODE,
**      NAME1     TYPE ZINW_T_HDR-NAME1,
**      STATUS    TYPE ZINW_T_HDR-STATUS,
**      SOE       TYPE ZINW_T_HDR-SOE,
**      MBLNR_103 TYPE ZINW_T_HDR-MBLNR_103,
**      MBLNR     TYPE ZINW_T_HDR-MBLNR,
**      INWD_DOC  TYPE ZINW_T_HDR-INWD_DOC,
**      MATNR     TYPE ZINW_T_ITEM-MATNR,
**      MATKL     TYPE ZINW_T_ITEM-MATKL,
**      NETPR_P   TYPE ZINW_T_ITEM-NETPR_P,
**      NETWR_P   TYPE ZINW_T_ITEM-NETWR_P,
**      NETPR_GP  TYPE ZINW_T_ITEM-NETPR_GP,
**      MENGE_P   TYPE ZINW_T_ITEM-MENGE_P,
**      SERVICE_PO TYPE ZINW_T_HDR-SERVICE_PO,
**      TAX type EKBE-DMBTR,
      due_date TYPE ekbe-budat,
    END OF ty_data.

  TYPES: BEGIN OF ty_gtdata3,
           bukrs    TYPE bsik-bukrs,
           lifnr    TYPE bsik-lifnr,
           augbl    TYPE bsik-augbl,
           belnr    TYPE bsik-belnr,
           gjahr    TYPE bsik-gjahr,
           budat    TYPE bsik-budat,
           due_date TYPE bsik-budat,
           xblnr    TYPE bsik-xblnr,
           ekorg    TYPE lfm1-ekorg,
           zterm    TYPE lfm1-zterm,
           ebeln    TYPE bseg-ebeln,
           buzei    TYPE bseg-buzei,
           dmbtr    TYPE bseg-dmbtr,
           kostl    TYPE bseg-kostl,
           h_blart  TYPE bseg-h_blart,
         END OF ty_gtdata3.

  TYPES : BEGIN OF ty_test,
            ebeln    TYPE ekko-ebeln,
            bsart    TYPE ekko-bsart,
            loekz    TYPE ekko-loekz,
            aedat    TYPE ekko-aedat,
            lifnr    TYPE ekko-lifnr,
            waers    TYPE ekko-waers,
            zterm    TYPE ekko-zterm,
            zbd1t    TYPE ekko-zbd1t,
*            MBLNR   TYPE MSEG-MBLNR,
            mwskz    TYPE ekpo-mwskz,
            menge    TYPE ekpo-menge,
            netwr    TYPE ekpo-netwr,
            kostl    TYPE ekkn-kostl,
            ebelp    TYPE ekpo-ebelp,
            due_date TYPE ekpo-aedat,
          END OF ty_test.




  TYPES :
    BEGIN OF ty_final1,
      slno(03) TYPE i,
      date(10) TYPE c,
*      AMOUNT   TYPE NETPR,
      amount   TYPE dmbtr,
      currency TYPE waers,
      ebeln    TYPE ekko-ebeln,
      tax      TYPE ekbe-dmbtr,
      netwr    TYPE ekpo-netwr,
    END OF ty_final1 .

  TYPES :
    BEGIN OF ty_final2,
      sel(01),
      slno         TYPE int4,
      date         TYPE sy-datum,
*      AMOUNT       TYPE NETPR,
*      AMOUNT       TYPE DMBTR,
      amount       TYPE ekpo-netwr,
      currency     TYPE waers,
      ebeln        TYPE ekko-ebeln,
      ebelp        TYPE ekpo-ebelp,
      waers        TYPE ekko-waers,
      lifnr        TYPE ekko-lifnr,
*      NAME1        TYPE LFA1-NAME1,
      name1        TYPE lfa1-name1,
      grpo_no      TYPE zinw_t_hdr-mblnr,
      due_date     TYPE sy-datum,
      created_date TYPE sy-datum,
      matkl        TYPE matkl,
      aedat        TYPE ekko-aedat,
      kostl(10)    TYPE c,
*      INWD_DOC     TYPE ZINW_T_HDR-INWD_DOC,
*      QR_CODE      TYPE ZINW_T_HDR-QR_CODE,
*      REC_DATE     TYPE ZINW_T_HDR-REC_DATE,
      lr_no        TYPE zlr,
      tax          TYPE ekbe-dmbtr,
      belnr        TYPE bseg-belnr,
      xblnr        TYPE bsik-xblnr,
    END OF ty_final2 .
  TYPES : BEGIN OF ty_lfa1,
            lifnr TYPE lfa1-lifnr,
            name1 TYPE lfa1-name1,
            adrnr TYPE lfa1-adrnr,
          END OF ty_lfa1.

  TYPES: BEGIN OF ty_hdr,
           lr_no      TYPE zinw_t_hdr-lr_no,
           service_po TYPE zinw_t_hdr-service_po,
         END OF ty_hdr.
*** Tables
  DATA :
*    GT_DATA   TYPE STANDARD TABLE OF TY_DATA,
    gt_data2  TYPE STANDARD TABLE OF ty_data,
    gt_data3  TYPE STANDARD TABLE OF ty_gtdata3,
*    gt_data1  TYPE STANDARD TABLE OF ty_test,
    gt_final1 TYPE STANDARD TABLE OF ty_final1,
    gs_final1 TYPE ty_final1,
    gt_final2 TYPE STANDARD TABLE OF ty_final2,
    gt_final3 TYPE STANDARD TABLE OF ty_final2,
    gt_ftable TYPE STANDARD TABLE OF zacc_strc,
    gs_final2 TYPE ty_final2,
    gs_final3 TYPE ty_final2,
    gs_ftable TYPE zacc_strc,
    it_hdr    TYPE TABLE OF ty_hdr.
  DATA : it_lfa1 TYPE TABLE OF ty_lfa1,
         it_ekpo TYPE TABLE OF ekpo,
         it_adrc TYPE TABLE OF adrc.
  DATA : lv_return TYPE ekpo-netpr .
  DATA : lv_tax TYPE ekpo-netpr .
*** Constants
  CONSTANTS :
    c_x(1) VALUE 'X'.
  DATA : lv_sl TYPE i VALUE 0.

  FIELD-SYMBOLS :
    <gs_final3>  TYPE ty_final2.

  DATA: ok_code LIKE sy-ucomm.
*
*  *** Constants
*  CONSTANTS :
*    C_X(1) VALUE 'X'.



  DATA:container   TYPE REF TO cl_gui_custom_container,
       grid        TYPE REF TO cl_gui_alv_grid,
       it_exclude  TYPE ui_functions,
       lw_layo     TYPE lvc_s_layo,
       lt_fieldcat TYPE  lvc_t_fcat.
  DATA: lt_exclude TYPE ui_functions.
  DATA : ls_stable TYPE lvc_s_stbl.
  DATA : lv_sum    TYPE zbprei_pt,
         c_refresh TYPE syucomm VALUE 'REF'.
*** Event Class
  CLASS event_class DEFINITION DEFERRED.
  DATA: gr_event TYPE REF TO event_class.

*** Event Handeler Class
  CLASS event_class DEFINITION.
    PUBLIC SECTION.
      METHODS: handle_data_changed
                  FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
  ENDCLASS.
*** Class Implemntation
  BREAK breddy .
  CLASS event_class IMPLEMENTATION.
    METHOD handle_data_changed.
*      BREAK BREDDY .
      DATA : error_in_data(1).

      LOOP AT er_data_changed->mt_mod_cells ASSIGNING FIELD-SYMBOL(<x_mod_cells>).
        READ TABLE gt_final3 ASSIGNING <gs_final3> INDEX <x_mod_cells>-row_id .
        IF sy-subrc = 0 .
          <gs_final3>-sel = <x_mod_cells>-value .
          IF  <x_mod_cells>-value IS NOT INITIAL.
            lv_sum =   <gs_final3>-amount +   lv_sum .
          ENDIF .

*        READ TABLE GT_FINAL2 ASSIGNING <GL_FINAL2> INDEX <X_MOD_CELLS>-VALUE .
          IF <x_mod_cells>-value  IS  INITIAL.

            lv_sum = lv_sum - <gs_final3>-amount .

          ENDIF.
*          modify gt_final3 TRANSPORTING
        ENDIF.
      ENDLOOP.

*** Refreshing Table Data
      IF grid IS BOUND.
        DATA: is_stable TYPE lvc_s_stbl, lv_lines TYPE int2.
        is_stable = 'XX'.
        IF grid IS BOUND.
          CALL METHOD grid->refresh_table_display
            EXPORTING
              is_stable = is_stable               " With Stable Rows/Columns
            EXCEPTIONS
              finished  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      ENDIF.


*** Display Errors
      IF error_in_data IS NOT INITIAL .
        CALL METHOD er_data_changed->display_protocol( ).
      ELSE.
*** Refreshing Main Screen
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = c_refresh.
      ENDIF.

    ENDMETHOD.
  ENDCLASS .
