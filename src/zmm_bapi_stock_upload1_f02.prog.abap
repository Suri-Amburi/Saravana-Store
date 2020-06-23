*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_FORM
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
*** Updating into DB table
    MODIFY zb1_stock FROM TABLE gt_file.
    IF sy-subrc <> 0.
      MESSAGE 'Invalid Format Data' TYPE 'E'.
    ELSE.
      PERFORM call_background_job.
      MESSAGE 'Data uploading is Started' TYPE 'S'.
    ENDIF.
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
  DATA:
    lv_pstng_date TYPE bapi2017_gm_head_01-pstng_date,
    lv_doc_date   TYPE bapi2017_gm_head_01-doc_date,
    ls_head       TYPE bapi2017_gm_head_01,
    lt_item       TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    ls_item       TYPE bapi2017_gm_item_create,
    lt_bapiret    TYPE STANDARD TABLE OF bapiret2,
    lv_mblnr      TYPE bapi2017_gm_head_ret-mat_doc,
    lv_year       TYPE bapi2017_gm_head_ret-doc_year,
    lv_item       TYPE mblpo,
    lv_msg        TYPE char200,
    ls_b1_s4_map  TYPE zb1_s4_map.

  CONSTANTS :
    c_code    TYPE bapi2017_gm_code VALUE '05'.

  FIELD-SYMBOLS :
    <ls_file>    TYPE zb1_stock,
    <ls_bapiret> TYPE bapiret2.
*** Get All unprocessed Records
  SELECT * FROM zb1_stock INTO TABLE gt_file.
  SELECT * FROM zb1_s4_map INTO TABLE @DATA(lt_b1_s4_map).
  SORT lt_b1_s4_map BY matnr plant b1_batch.
  SORT gt_file BY matnr plant b1_batch.
  IF sy-subrc = 0.
    LOOP AT gt_file ASSIGNING <ls_file>.
      CLEAR: lv_pstng_date, lv_doc_date, ls_item, lv_mblnr, lv_year, ls_head, lv_msg .
      REFRESH :lt_item, lt_bapiret.

      READ TABLE lt_b1_s4_map WITH KEY matnr = <ls_file>-matnr plant = <ls_file>-plant b1_batch = <ls_file>-b1_batch TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_file>-move_type = '561'.
        UPDATE zb1_stock SET status_flag = c_e message = 'Record is already Posted with this Key' WHERE matnr = <ls_file>-matnr AND b1_batch = <ls_file>-b1_batch
                              AND move_type = <ls_file>-move_type AND plant = <ls_file>-plant.
        COMMIT WORK.
        CONTINUE.
      ENDIF.
      ls_head-pstng_date = <ls_file>-pstng_date+6(4) && <ls_file>-pstng_date+3(2) && <ls_file>-pstng_date+0(2).
      ls_head-doc_date   = <ls_file>-doc_date+6(4) && <ls_file>-doc_date+3(2) && <ls_file>-doc_date+0(2).

      DATA(mat_len) = strlen( <ls_file>-matnr ) .
      IF mat_len > 18.
        ls_item-material_long = <ls_file>-matnr.
      ELSE.
        ls_item-material = <ls_file>-matnr.
      ENDIF.

      ls_item-plant            = <ls_file>-plant.
      ls_item-stge_loc         = <ls_file>-stge_loc.
      ls_item-move_stloc       = <ls_file>-stge_loc.
      ls_item-entry_uom        = <ls_file>-uom.
      ls_item-batch            = <ls_file>-batch.
      ls_item-move_type        = <ls_file>-move_type.
      ls_item-spec_stock       = <ls_file>-spec_stock.
      ls_item-entry_qnt        = <ls_file>-quantity.
      ls_item-amount_lc        = <ls_file>-amount.
      APPEND ls_item TO lt_item.
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

      IF lv_mblnr IS NOT INITIAL.
*** Commit the transaction if success
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
***   Get Batch from Material Doc
        SELECT SINGLE charg FROM mseg INTO <ls_file>-batch WHERE mblnr = lv_mblnr AND mjahr = lv_year.
        IF sy-subrc = 0 AND <ls_file>-move_type = '561'.
          ls_b1_s4_map-mandt   = sy-mandt.
          ls_b1_s4_map-b1_batch   = <ls_file>-b1_batch.
          ls_b1_s4_map-matnr      = <ls_file>-matnr.
          ls_b1_s4_map-b1_vendor  = <ls_file>-b1_vendor.
          ls_b1_s4_map-plant      = <ls_file>-plant.
          ls_b1_s4_map-s4_batch   = <ls_file>-batch.
          ls_b1_s4_map-amount     = <ls_file>-amount.
          INSERT zb1_s4_map FROM ls_b1_s4_map.
          COMMIT WORK.
        ENDIF.
      ELSE.
*** Roll Back the transaction if fails
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*** Append Error Messages
        LOOP AT lt_bapiret ASSIGNING <ls_bapiret> WHERE type = 'E'.
          AT FIRST.
            lv_msg = <ls_bapiret>-message.
          ENDAT.
          lv_msg = lv_msg && <ls_bapiret>-message.
        ENDLOOP.
***     Update Error Message
        CONDENSE lv_msg.
        UPDATE zb1_stock SET status_flag = c_e message = lv_msg WHERE matnr = <ls_file>-matnr AND b1_batch = <ls_file>-b1_batch
                         AND move_type = <ls_file>-move_type AND quantity = <ls_file>-quantity AND plant = <ls_file>-plant.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
