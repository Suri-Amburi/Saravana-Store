*&---------------------------------------------------------------------*
*& Include          ZMM_STK_UPLD_FORM
*&---------------------------------------------------------------------*

FORM get_filename  CHANGING fp_p_file.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
    CHANGING
      file_table              = li_filetable
      rc                      = lv_return_code
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF li_filetable IS NOT INITIAL.
    lx_filetable = li_filetable[ 1 ].
    fp_p_file = lx_filetable-filename.

  ENDIF.
  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FILE  text
*----------------------------------------------------------------------*
FORM get_data  CHANGING p_gt_file.
  DATA : i_type    TYPE truxs_t_text_data.
  DATA : lv_file TYPE rlgrap-filename.

  IF ename EQ 'XLSX' OR ename EQ 'XLS'.
    REFRESH gt_file[].
    lv_file = p_file.
***  FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = gt_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    DELETE gt_file[] FROM 1 TO 2.
  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'.
  ENDIF.
  IF gt_file IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ELSE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BACKGROUND_JOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_background_job.
  DATA :
    lv_authcknam TYPE tbtcjob-authcknam,
    lv_jobcount  TYPE tbtcjob-jobcount.

  lv_authcknam = sy-uname.
*** Job Open
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = 'INITIAL_STOCK'
    IMPORTING
      jobcount         = lv_jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      authcknam               = lv_authcknam
      jobcount                = lv_jobcount
      jobname                 = 'INITIAL_STOCK'
      report                  = sy-repid
    EXCEPTIONS
      bad_priparams           = 1
      bad_xpgflags            = 2
      invalid_jobdata         = 3
      jobname_missing         = 4
      job_notex               = 5
      job_submit_failed       = 6
      lock_failed             = 7
      program_missing         = 8
      prog_abap_and_extpg_set = 9
      OTHERS                  = 10.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = lv_jobcount
      jobname              = 'INITIAL_STOCK'
      strtimmed            = 'X'
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      OTHERS               = 9.

  IF sy-subrc = 0.
    MESSAGE 'Background job start' TYPE 'S'.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BACKGROUND_JOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM background_job.

***  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form STOCK_TRANSF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FILE
*&      <-- GT_MSG
*&---------------------------------------------------------------------*
FORM stock_transf  USING    gt_file01 TYPE st_file
                   CHANGING gt_msg TYPE st_msg.

  DATA:
    lv_pstng_date  TYPE bapi2017_gm_head_01-pstng_date,
    lv_doc_date    TYPE bapi2017_gm_head_01-doc_date,
    ls_head        TYPE bapi2017_gm_head_01,
    lt_item        TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    ls_item        TYPE bapi2017_gm_item_create,
    lt_bapiret     TYPE STANDARD TABLE OF bapiret2,
    lv_mblnr       TYPE bapi2017_gm_head_ret-mat_doc,
    lv_year        TYPE bapi2017_gm_head_ret-doc_year,
    lv_item        TYPE mblpo,
    lv_msg         TYPE char200,
    ls_b1_s4_map   TYPE zb1_s4_map,
    lt_b1_s4_map01 TYPE TABLE OF zb1_s4_map.

  CONSTANTS :
    c_code    TYPE bapi2017_gm_code VALUE '04'.

  DATA : stabix TYPE int4,
         slines TYPE sy-tabix.

  FIELD-SYMBOLS :
    <ls_file>    TYPE ty_file,
    <ls_bapiret> TYPE bapiret2.
*** Get All unprocessed Record
*  REFRESH : gt_file01.
  DATA : sdate TYPE char8.
  sdate = |{ sy-datum+0(4) }{ sy-datum+4(2) }{ sy-datum+6(2) }|.

  SORT gt_file01 BY matnr plant .
  CHECK gt_file01[] IS NOT INITIAL.

LOOP AT gt_file01 INTO gw_file01.
  MOVE-CORRESPONDING gw_file01 TO gw_file02.
  gw_file02-matnr = gw_file01-matnr+0(18).
  APPEND  gw_file02 TO gt_file02.
  CLEAR   gw_file02.
ENDLOOP.

********************************************************************************
 SELECT matnr,ean11
   FROM mara INTO TABLE @DATA(it_mara)
   FOR ALL ENTRIES IN @gt_file02[]
   WHERE ean11 = @gt_file02-matnr AND mstae = ' ' AND attyp <> '01'.

 SELECT s4_batch,matnr,b1_batch
   FROM zb1_s4_map INTO TABLE @DATA(it_batch)
   FOR ALL ENTRIES IN @gt_file01[]
   WHERE b1_batch  = @gt_file01-batch
                                                                                                           AND   plant     = @gt_file01-plant.

********************************************************************************
  DESCRIBE TABLE gt_file01 LINES slines.
  LOOP AT gt_file01 ASSIGNING <ls_file>.
    DATA(stabix01) = sy-tabix.
    ADD 1 TO stabix.  "Increase Counter
    CLEAR: lv_pstng_date, lv_doc_date, ls_item, lv_mblnr, lv_year, ls_head, lv_msg .
***    REFRESH :lt_item, lt_bapiret.

    ls_head-pstng_date = <ls_file>-pstng_date+6(4) && <ls_file>-pstng_date+3(2) && <ls_file>-pstng_date+0(2).
    ls_head-doc_date   = <ls_file>-doc_date+6(4) && <ls_file>-doc_date+3(2) && <ls_file>-doc_date+0(2).
    ls_head-header_txt = <ls_file>-gate_pass.


*    DATA(mat_len) = strlen( <ls_file>-matnr ) .
*    IF mat_len > 18.
*      ls_item-material_long = <ls_file>-matnr.
*    ELSE.
*      ls_item-material = <ls_file>-matnr.
*    ENDIF.

***************************************************************************************
    IF <ls_file>-matnr IS NOT INITIAL.

      READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<mara>) WITH KEY ean11 = <ls_file>-matnr.
       IF sy-subrc = 0.
           DATA(mat_len) = strlen( <mara>-matnr ) .
           IF mat_len > 18.
             ls_item-material_long = <mara>-matnr.
           ELSE.
             ls_item-material = <mara>-matnr.
           ENDIF.
           CLEAR mat_len.
       ENDIF.
    ENDIF.

**      IF <ls_file>-batch IS NOT INITIAL.
**        READ TABLE it_batch ASSIGNING FIELD-SYMBOL(<batch>) WITH KEY b1_batch = <ls_file>-batch.
**        IF sy-subrc = 0.
**          ls_item-batch = ls_item-move_batch  = <batch>-s4_batch.
**          IF ls_item-material IS INITIAL.
**           DATA(mat_len1) = strlen( <batch>-matnr ) .
**           IF mat_len1 > 18.
**             ls_item-material_long = <batch>-matnr.
**           ELSE.
**             ls_item-material = <batch>-matnr.
**           ENDIF.
**          ENDIF.
**         ELSE.
**           ls_item-batch = ls_item-move_batch  = <ls_file>-batch.
**           SELECT SINGLE matnr FROM mchb INTO  ls_item-material_long WHERE charg =  <ls_file>-batch.
**       ENDIF.
**    ENDIF.

***************************************************************************************
    ls_item-batch            = <ls_file>-batch.
    ls_item-material_long    = <ls_file>-matnr.
    ls_item-material         = <ls_file>-matnr.
    ls_item-plant            = <ls_file>-plant.
    ls_item-stge_loc         = <ls_file>-stge_loc.
    ls_item-move_plant       = <ls_file>-move_plant.
    ls_item-move_stloc       = <ls_file>-move_stloc.
    ls_item-entry_uom        = <ls_file>-uom.
*    ls_item-batch            = <ls_file>-batch.
*    ls_item-move_batch       = <ls_file>-batch.
    ls_item-move_type        = <ls_file>-move_type.
***    ls_item-spec_stock       = <ls_file>-spec_stock.
    ls_item-entry_qnt        = <ls_file>-quantity.
***    ls_item-amount_lc        = <ls_file>-amount.
    ls_item-item_text       = <ls_file>-sgtxt.
    APPEND ls_item TO lt_item.
    CLEAR : ls_item.

*--> Prepare Spool Log ->
    MOVE-CORRESPONDING <ls_file> TO gw_msg.
    APPEND gw_msg TO gt_msg01.

*--> Call BAPI when 400 Line items reached ->
    IF stabix = 400 OR stabix01 = slines.
      CLEAR : stabix.
      CLEAR : lv_msg,lv_mblnr,lv_year.
      REFRESH : lt_bapiret.
*** Goods Movement Bapi Call
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_head
          goodsmvt_code    = c_code
        IMPORTING
          materialdocument = lv_mblnr
          matdocumentyear  = lv_year
        TABLES
          goodsmvt_item    = lt_item
          return           = lt_bapiret.

      REFRESH : lt_item."lt_bapiret.
      CLEAR  :ls_head,ls_item.
      IF lv_mblnr IS NOT INITIAL.
*** Commit the transaction if success
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
****        MOVE-CORRESPONDING <ls_file> TO gw_msg.
        CLEAR : gw_msg.
        LOOP AT gt_msg01 INTO gw_msg.
          gw_msg-mblnr = lv_mblnr.
          gw_msg-mjahr = lv_year.
          gw_msg-msg = 'Success'.    "Message Log.
          MODIFY gt_msg01 FROM gw_msg INDEX sy-tabix.    "Log Data
        ENDLOOP.
        APPEND LINES OF gt_msg01 TO gt_msg.
        REFRESH : gt_msg01.
      ELSE.
*** Roll Back the transaction if fails
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*** Append Error Messages

        LOOP AT gt_msg01 INTO gw_msg.
          gw_msg-mblnr = lv_mblnr.
          gw_msg-mjahr = lv_year.
          gw_msg-msg = 'Failed'.    "Message Log.
          MODIFY gt_msg01 FROM gw_msg INDEX sy-tabix.    "Log Data
        ENDLOOP.
        APPEND LINES OF gt_msg01 TO gt_msg.
        REFRESH : gt_msg01.

        LOOP AT  lt_bapiret ASSIGNING <ls_bapiret> WHERE type = 'E'.
          CLEAR : gw_msg.
          MOVE-CORRESPONDING <ls_file> TO gw_msg.
          lv_msg = lv_msg && <ls_bapiret>-message.
          gw_msg-msg = lv_msg.    "Message Log.
          APPEND gw_msg TO gt_msg.    "Log Data
          CLEAR  : gw_msg.
***        ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MSG
*&---------------------------------------------------------------------*
FORM display_data  USING  gt_msg TYPE st_msg.

  CHECK gt_msg IS NOT INITIAL.   "Log Data
  TRY.
      cl_salv_table=>factory(
  EXPORTING
  list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
*    r_container    =     " Abstract Container for GUI Controls
*    container_name =
        IMPORTING
        r_salv_table   = lr_alv   " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_msg[]
                                ).

      lo_cols = lr_alv->get_columns( ).

*    *   set the Column optimization
      lo_cols->set_optimize( 'X' ).
      gr_display = lr_alv->get_display_settings( ).
      gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

** header object
*      CREATE OBJECT lo_header.
*      lo_h_label = lo_header->create_label( row = 1 column = 1 ).
*      lo_h_label->set_text( 'Incomplete Pallet Carton Details' ).
*      lr_alv->set_top_of_list( lo_header ).

*      GET layout object
      lo_layout = lr_alv->get_layout( ).
*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
      ls_key-report = sy-repid.
      lo_layout->set_key( ls_key ).
*   2. Remove Save layout the restriction.
*    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

*      CALL METHOD lr_alv->set_screen_status(
*        EXPORTING
*          report        = sy-repid
*          pfstatus      = 'PF_STAT'
*          set_functions = lr_alv->c_functions_all ).

    CATCH cx_salv_msg.    "
  ENDTRY .
  lr_alv->display( ).
ENDFORM.
