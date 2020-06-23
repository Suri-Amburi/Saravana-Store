*&---------------------------------------------------------------------*
*& Include          ZSD_INVOICE_IDOC_U_F01
*&---------------------------------------------------------------------*

FORM get_filename CHANGING fp_p_file.

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
    fp_p_file = li_filetable[ 1 ]-filename.
  ENDIF.
  SPLIT fp_p_file AT '.' INTO gv_fname gv_ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE gv_ename TO UPPER CASE.

ENDFORM.

FORM get_data_xls TABLES gt_file.
  DATA : lv_file TYPE rlgrap-filename,
         i_type  TYPE truxs_t_text_data.

***  PROCEED ONLY IF ITS A VALID FILETYPE
  IF gv_ename EQ 'XLSX' OR gv_ename EQ 'XLS'.
    REFRESH gt_file.
    lv_file = p_file.

***   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = gt_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    DELETE gt_file[] FROM 1 TO 2 .
    IF gt_file[] IS INITIAL.
*** No records to upload
      MESSAGE e091(zmsg_cls).
    ENDIF.
  ELSE.
***   Invalid File type : only possible types XLS & XLSX
    MESSAGE e097(zmsg_cls).
  ENDIF.
ENDFORM.

FORM upload_data TABLES gt_file STRUCTURE gs_file.

  DATA: ls_file  TYPE ty_file,
        lv_tabix TYPE sy-tabix,
        lv_count TYPE int4.
  TYPES : ty_file_idoc TYPE STANDARD TABLE OF ty_file WITH EMPTY KEY.
  FIELD-SYMBOLS : <ls_file_key> TYPE ty_file.
  FIELD-SYMBOLS : <ls_file> TYPE ty_file.
*** To Read Data from Application Layer
  IF sy-batch = 'X'.
    TRY.
        OPEN DATASET gv_a_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc IS INITIAL.
          DO.
            CLEAR ls_file .
            READ DATASET gv_a_file INTO ls_file.
            IF sy-subrc = 0.
              APPEND ls_file TO gt_file.
              CLEAR ls_file.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.
        ELSE.
          MESSAGE 'No Path Exist' TYPE 'E'.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
    CLOSE DATASET gv_a_file.
  ENDIF.

*** Upload Data
*** Updating Control Records
  SORT gt_file BY store belegdatum.
  DATA(gt_file_key) = gt_file[].
  DELETE ADJACENT DUPLICATES FROM gt_file_key COMPARING store belegdatum.
  lv_tabix = 1.
  LOOP AT gt_file_key ASSIGNING <ls_file_key>.
    REFRESH : gt_idoc_contrl , gt_idoc_data , gt_return_variables, gt_serialization_info.
    DATA(lt_file_idoc) = VALUE ty_file_idoc( FOR ls_file1 IN gt_file WHERE ( belegdatum =  <ls_file_key>-belegdatum AND store = <ls_file_key>-store ) (
    store           = ls_file1-store
    belegdatum      = ls_file1-belegdatum
    belegwaers      = ls_file1-belegwaers
    package_id      = ls_file1-package_id
    qualartnr       = ls_file1-qualartnr
    artnr           = ls_file1-artnr
    aktionsnr       = ls_file1-aktionsnr
    vorzmenge       = ls_file1-vorzmenge
    umsmenge        = ls_file1-umsmenge
    umswert         = ls_file1-umswert
    sales_uom       = ls_file1-sales_uom
    c_sign          = ls_file1-c_sign
    c_taxcode       = ls_file1-c_taxcode
    c_taxvalue      = ls_file1-c_taxvalue
    s_sign          = ls_file1-s_sign
    s_taxcode       = ls_file1-s_taxcode
    s_taxvalue      = ls_file1-s_taxvalue ) ).
    CLEAR : lv_count , gv_seg.
    DESCRIBE TABLE lt_file_idoc LINES DATA(lv_lines).
    LOOP AT lt_file_idoc ASSIGNING <ls_file>.
      lv_count = lv_count + 1.
      PERFORM data_record USING <ls_file>.
      IF lv_count = 350 OR lv_count = lv_lines.
        PERFORM control_record USING <ls_file>.
        PERFORM create_idoc USING <ls_file>.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

*** Uploading Data in Application Layer
FORM load_data_app TABLES gt_file.
  DATA: ls_file      TYPE ty_file,
        lv_authcknam TYPE tbtcjob-authcknam,
        lv_jobcount  TYPE tbtcjob-jobcount.
  TRY.
      OPEN DATASET gv_a_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
      LOOP AT gt_file INTO ls_file .
        TRANSFER ls_file TO gv_a_file.
      ENDLOOP.
    CATCH cx_root.
  ENDTRY.
  CLOSE DATASET gv_a_file.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = c_job
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
      jobname                 = c_job
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
      jobname              = c_job
      strtimmed            = c_x
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
***  Background job start
  MESSAGE s098(zmsg_cls) WITH c_job.
ENDFORM.


FORM display_data.
  DATA : lr_alv       TYPE REF TO cl_salv_table,
         lr_cols      TYPE REF TO cl_salv_columns,
         lr_col       TYPE REF TO cl_salv_column,
         lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_result ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

*** Store
      lr_col = lr_cols->get_column( 'STORE' ).
      lr_col->set_long_text('Store' ).
      lr_col->set_medium_text('Store' ).
      lr_col->set_short_text('Store').

      lr_col = lr_cols->get_column( 'BELEGDATUM' ).
      lr_col->set_long_text('Date' ).
      lr_col->set_medium_text('Date' ).
      lr_col->set_short_text('Date').

    CATCH cx_salv_msg.
  ENDTRY .
  lr_alv->display( ).
ENDFORM.

FORM control_record USING ls_file STRUCTURE gs_file.
  CONSTANTS :
    c_idoctp TYPE edidc-idoctp VALUE 'WPUUMS01',
    c_mestyp TYPE edidc-mestyp VALUE 'WPUUMS',
    c_rcvprt TYPE edidc-rcvprt VALUE 'KU',
    c_sndprt TYPE edidc-sndprt VALUE 'KU',
    c_docrel TYPE edidc-docrel VALUE '752',
    c_status TYPE edidc-status VALUE '62',
    c_direct TYPE edidc-direct VALUE '2'.

  DATA :
    lv_sndpor TYPE edidc-sndpor VALUE 'SAPSCD0037',
    lv_rcvpor TYPE edidc-rcvpor VALUE 'SAPSCD0037'.

  REFRESH : gt_idoc_contrl.
*** Sendor & Receiver PORT Details
  CASE sy-sysid.
    WHEN 'SDS'.
      lv_sndpor = 'SAPSDS'.
      lv_rcvpor = 'SAPSDS'.
      gv_logsys = 'SDSCLNT200'.
    WHEN 'SQS'.
      lv_sndpor = 'SAPSQS'.
      lv_rcvpor = 'SAPSQS'.
      gv_logsys = 'SQSCLNT200'.
    WHEN 'SPS'.
      lv_sndpor = 'SAPSPS'.
      lv_rcvpor = 'SAPSPS'.
      gv_logsys = 'SPSCLNT800'.
  ENDCASE.

*** Controll Data
  APPEND VALUE #( docrel    = '753'
                 mandt     = sy-mandt
                 status    = c_status
                 direct    = c_direct
                 rcvpor    = lv_rcvpor
                 rcvprt    = c_rcvprt
                 rcvprn    = ls_file-store
                 sndpor    = lv_sndpor
                 sndprt    = c_sndprt
                 sndprn    = ls_file-store
                 mestyp    = c_mestyp
                 idoctp    = c_idoctp
                 credat    = sy-datum
                 upddat    = sy-datum
                 cretim    = sy-uzeit
                 updtim    = sy-uzeit ) TO gt_idoc_contrl.
ENDFORM.

FORM data_record USING ls_file TYPE ty_file.
  DATA :
    ls_idoc_data    TYPE edidd,
    lv_batch        TYPE charg_d,
    lv_matnr        TYPE matnr,
    lv_b1_batch(40),
    lv_tendor       TYPE p DECIMALS 5.

  FIELD-SYMBOLS :
    <ls_items> TYPE ty_file.

  IF gv_seg = 0.
    gv_seg = gv_seg + 1.
*** POS interface: inbound sales, header segment
    ls_idoc_data-mandt           = sy-mandt.
    ls_idoc_data-docnum          = gs_control_record_db_in-docnum.
    ls_idoc_data-psgnum          = 0.
    ls_idoc_data-hlevel          = 02.
    ls_idoc_data-dtint2          = 1000.
    ls_idoc_data-segnum          = gv_seg.
    ls_idoc_data-segnam          = 'E1WPU01'.                   " Segment Name
    ls_idoc_data-sdata+0(8)      = ls_file-belegdatum+6(4) && ls_file-belegdatum+3(2) && ls_file-belegdatum+0(2).                     " Business Date
    ls_idoc_data-sdata+8(4)      = ls_file-belegwaers .          " Currency
    APPEND  ls_idoc_data TO gt_idoc_data. CLEAR ls_idoc_data.
  ENDIF.
  gv_seg = gv_seg + 1.
*** POS interface, inbound sales, items
  ls_idoc_data-mandt           = sy-mandt.
  ls_idoc_data-docnum          = gs_control_record_db_in-docnum.
  ls_idoc_data-psgnum          = 1.
  ls_idoc_data-hlevel          = 03.
  ls_idoc_data-dtint2          = 1000.
  ls_idoc_data-segnum          = gv_seg.
  ls_idoc_data-segnam          = 'E1WPU02'.                       " Segment Name
  ls_idoc_data-sdata+0(4)      = ls_file-qualartnr.               " Qualifier
  IF strlen( ls_file-artnr ) > 18.
    ls_idoc_data-sdata+121(40)   = ls_file-artnr.                 " Materail Long
  ELSE.
    ls_idoc_data-sdata+4(25)     = ls_file-artnr.                 " Material
    ls_idoc_data-sdata+121(40)   = ls_file-artnr.                 " Materail Long
  ENDIF.
  ls_idoc_data-sdata+29(15)    = ls_file-aktionsnr.               " Batch
  ls_idoc_data-sdata+44(1)     = ls_file-vorzmenge.               " Sign
  ls_idoc_data-sdata+45(35)    = ls_file-umsmenge.                " Quantity
  ls_idoc_data-sdata+81(35)    = ls_file-umswert.                 " Sales Amount
  ls_idoc_data-sdata+116(5)    = ls_file-sales_uom.               " Sales UOM

  APPEND  ls_idoc_data TO gt_idoc_data. CLEAR ls_idoc_data.
  gv_seg = gv_seg + 1.

*** Sales Tax Data - JOCG / JOSG
  ls_idoc_data-mandt          = sy-mandt.
  ls_idoc_data-psgnum         = 2.
  ls_idoc_data-hlevel         = 04.
  ls_idoc_data-dtint2         = 1000.
  ls_idoc_data-segnum         = gv_seg.
  ls_idoc_data-segnam         = 'E1WPU05'.                          " Segment Name
  ls_idoc_data-sdata+0(1)     = ls_file-c_sign.                     " Sign
  ls_idoc_data-sdata+1(4)     = ls_file-c_taxcode.                  " Tax Type
  ls_idoc_data-sdata+5(20)    = ls_file-c_taxvalue.                 " Tax Amount
  APPEND ls_idoc_data TO gt_idoc_data. CLEAR ls_idoc_data.
  gv_seg = gv_seg + 1.
  ls_idoc_data-mandt          = sy-mandt.
  ls_idoc_data-psgnum         = 2.
  ls_idoc_data-hlevel         = 04.
  ls_idoc_data-dtint2         = 1000.
  ls_idoc_data-segnum         = gv_seg.
  ls_idoc_data-segnam         = 'E1WPU05'.                          " Segment Name
  ls_idoc_data-sdata+0(1)     = ls_file-s_sign.                     " Sign
  ls_idoc_data-sdata+1(4)     = ls_file-s_taxcode.                  " Tax Type
  ls_idoc_data-sdata+5(20)    = ls_file-s_taxvalue.                 " Tax Amount
  APPEND ls_idoc_data TO gt_idoc_data. CLEAR ls_idoc_data.

  SORT gt_idoc_data BY segnum.
ENDFORM.

FORM create_idoc USING ls_file TYPE ty_file.

  DATA:
    l_do_handle_error       TYPE edigeneral-errhandle VALUE 'X',
    state_of_processing_in  TYPE sy-subrc,
    inbound_process_data_in TYPE tede2,
    ls_idoc_data            TYPE edidd.

  FIELD-SYMBOLS :
    <ls_idoc_status> TYPE bdidocstat.

  DATA(l_t_data_records_db) = gt_idoc_data.
  gs_idoc_contrl = gt_idoc_contrl[ 1 ].
*** Creating Idoc to DB
  CALL FUNCTION 'IDOC_INBOUND_WRITE_TO_DB'
    EXPORTING
      pi_do_handle_error      = l_do_handle_error
      pi_return_data_flag     = c_false
    IMPORTING
      pe_idoc_number          = gs_idoc_contrl-docnum
      pe_state_of_processing  = state_of_processing_in
      pe_inbound_process_data = inbound_process_data_in
    TABLES
      t_data_records          = l_t_data_records_db
    CHANGING
      pc_control_record       = gs_idoc_contrl
    EXCEPTIONS
      idoc_not_saved          = 1
      OTHERS                  = 2.
  ls_idoc_data-docnum = gs_idoc_contrl-docnum.
*** Updading IDoc number in Data Records
  MODIFY gt_idoc_data FROM ls_idoc_data TRANSPORTING docnum WHERE docnum = space.
  MODIFY gt_idoc_contrl FROM gs_idoc_contrl TRANSPORTING docnum WHERE docnum = space.
*** Updating Data to IDoc
  CALL FUNCTION 'IDOC_INPUT_POS_SALES_ACCOUNT'
    EXPORTING
      input_method          = space                " Input Method for Inbound IDoc Function Module
      mass_processing       = space                " Flag: Mass processing
    TABLES
      idoc_contrl           = gt_idoc_contrl               " Control record (IDoc)
      idoc_data             = gt_idoc_data                 " Data record (IDoc)
      idoc_status           = gt_idoc_status               " ALE IDoc status (subset of all IDoc status fields)
      return_variables      = gt_return_variables          " Assignment of IDoc or document no. to method parameter
      serialization_info    = gt_serialization_info        " Serialization objects for one/several IDocs
    EXCEPTIONS
      wrong_function_called = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
  ENDIF.
*** Success or Error
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  SORT : gt_idoc_status BY status.
  READ TABLE gt_idoc_status ASSIGNING <ls_idoc_status> WITH KEY status = '53' BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    DATA : idoc_control TYPE  edidc.
    DATA : i_db_read        TYPE edi_help-dbr_option VALUE 'Y',
           i_enqueue_option TYPE edi_help-enq_option VALUE 'L'.

*** Open the Idocs to Process
    CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_PROCESS'
      EXPORTING
        db_read_option           = i_db_read                    " 'Y' = Read data records from DB, 'N' = Do not read
        document_number          = gs_idoc_contrl-docnum        " IDoc number
        enqueue_option           = i_enqueue_option             " SYNCHRONOUS " 'A' = Lock asynchronously, 'S' = Lock synchronously
      IMPORTING
        idoc_control             = idoc_control                 " IDoc control record
      EXCEPTIONS
        document_foreign_lock    = 1                            " IDoc locked
        document_not_exist       = 2                            " IDoc does not exist
        document_number_invalid  = 3                            " IDoc number is invalid
        document_is_already_open = 4                            " IDoc already opened in process mode
        OTHERS                   = 5.
    IF sy-subrc <> 0.
    ENDIF.

    CALL FUNCTION 'EDI_DOCUMENT_STATUS_SET'
      EXPORTING
        document_number         = gs_idoc_contrl-docnum         " IDoc number
        idoc_status             = gs_status_record              " Status record
      EXCEPTIONS
        document_number_invalid = 1                             " IDoc number is invalid
        other_fields_invalid    = 2                             " One field in status record is invalid
        status_invalid          = 3                             " Status value is invalid
        OTHERS                  = 4.
    IF sy-subrc <> 0.
    ENDIF.

*** Close the Idocs open for Process
    CALL FUNCTION 'EDI_DOCUMENT_CLOSE_PROCESS'
      EXPORTING
        document_number = gs_idoc_contrl-docnum.                " IDoc number
    IF sy-subrc <> 0.
    ENDIF.
    APPEND VALUE #( store = ls_file-store belegdatum = ls_file-belegdatum idoc = gs_idoc_contrl-docnum message = c_success ) TO gt_result.
  ELSE.
    APPEND VALUE #( store = ls_file-store belegdatum = ls_file-belegdatum idoc = gs_idoc_contrl-docnum message = c_fail ) TO gt_result.
  ENDIF.

  REFRESH: gt_idoc_data,gt_idoc_status,gt_serialization_info , gt_return_variables.
  CLEAR : gv_seg.
  CALL FUNCTION 'DEQUEUE_ALL'.
ENDFORM.

FORM initialization.
*** Status Records
  gs_status_record-mandt      = sy-mandt.
  gs_status_record-logdat     = sy-datum.
  gs_status_record-logtim     = sy-uzeit.
  gs_status_record-status     = '53'.
  gs_status_record-uname      = sy-uname.
  gs_status_record-repid      = sy-repid.
  gs_status_record-routid     = 'Idoc Created Successfully'.
  gs_status_record-statyp     = 'I'.
  gv_a_file = '/usr/sap/' && sy-sysid && '/D00/work/sales_upload_' && sy-uname && '.txt'.
ENDFORM.
