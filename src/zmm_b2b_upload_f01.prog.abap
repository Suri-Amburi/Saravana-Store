*&---------------------------------------------------------------------*
*& Include          ZMM_B2B_UPLOAD_F01
*&---------------------------------------------------------------------*
FORM get_filename  CHANGING p_file TYPE localfile.

  DATA: li_filetable    TYPE filetable,
        ls_filetable    TYPE file_table,
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

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE li_filetable INTO ls_filetable INDEX 1.
  p_file = ls_filetable-filename.

  SPLIT p_file AT '.' INTO DATA(fname) DATA(ename).
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
  DATA : i_type  TYPE truxs_t_text_data,
         lv_file TYPE rlgrap-filename.
  lv_file = p_file.
  REFRESH gt_data.
*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_tab_raw_data       = i_type
      i_filename           = lv_file
    TABLES
      i_tab_converted_data = gt_data
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  DELETE gt_data FROM 1 TO 2.
ENDFORM.

FORM prepare_fcat.

*  ***  Preparing Field Catlog
  IF gi_fieldcat IS INITIAL.
    REFRESH : gi_fieldcat[].
    gs_layout-frontend = 'X'.
*** Batch
    gs_fieldcat-fieldname   = 'BATCH'.
    gs_fieldcat-reptext     = 'Old Batch'.
    gs_fieldcat-col_opt     = 'X'.
    gs_fieldcat-txt_field   = 'X'.
    gs_fieldcat-outputlen   = 10.
    APPEND gs_fieldcat TO gi_fieldcat.
    CLEAR gs_fieldcat.

*** Old Price
    gs_fieldcat-fieldname   = 'OLD_PRICE'.
    gs_fieldcat-reptext     = 'Old Price'.
    gs_fieldcat-col_opt     = 'X'.
    gs_fieldcat-txt_field   = 'X'.
    gs_fieldcat-outputlen   = 10.
    APPEND gs_fieldcat TO gi_fieldcat.
    CLEAR gs_fieldcat.

*** Qty
    gs_fieldcat-fieldname   = 'MENGE'.
    gs_fieldcat-reptext     = 'Quantity'.
    gs_fieldcat-col_opt     = 'X'.
    gs_fieldcat-txt_field   = 'X'.
    gs_fieldcat-outputlen   = 10.
    APPEND gs_fieldcat TO gi_fieldcat.
    CLEAR gs_fieldcat.

*** New Price
    gs_fieldcat-fieldname   = 'NEW_PRICE'.
    gs_fieldcat-reptext     = 'New Price'.
    gs_fieldcat-col_opt     = 'X'.
    gs_fieldcat-txt_field   = 'X'.
    gs_fieldcat-edit        = 'X'.
    gs_fieldcat-outputlen   = 10.
    APPEND gs_fieldcat TO gi_fieldcat.
    CLEAR gs_fieldcat.

  ELSEIF sy-ucomm = 'SAVE'.
    READ TABLE gi_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>) WITH KEY fieldname = 'NEW_PRICE'.
    IF sy-subrc = 0.
      CLEAR : <ls_fieldcat>-edit.
    ENDIF.

*** New Batch
    gs_fieldcat-fieldname   = 'BATCH_N'.
    gs_fieldcat-reptext     = 'New Batch'.
    gs_fieldcat-col_opt     = 'X'.
    gs_fieldcat-txt_field   = 'X'.
    gs_fieldcat-outputlen   = 10.
    APPEND gs_fieldcat TO gi_fieldcat.
    CLEAR gs_fieldcat.

*** Messgae
    gs_fieldcat-fieldname   = 'MESSAGE'.
    gs_fieldcat-reptext     = 'Message'.
    gs_fieldcat-col_opt     = 'X'.
    gs_fieldcat-txt_field   = 'X'.
    gs_fieldcat-outputlen   = 40.
    APPEND gs_fieldcat TO gi_fieldcat.
    CLEAR gs_fieldcat.
  ENDIF.

ENDFORM.

FORM display_data.
***  Displaying date in ALV Grid
*** Fetching Old Price
*  IF gt_data IS NOT INITIAL.
*    DATA(gt_data_t) = gt_data.
*    DATA : lv_index TYPE sy-index.
*    DELETE gt_data_t WHERE old_price IS NOT INITIAL.
**** Batch based Material
*    SELECT a511~charg, konp~kbetr
*           INTO TABLE @DATA(lt_price) FROM konp
*           INNER JOIN a511
*           ON a511~knumh = konp~knumh
*           INNER JOIN mseg
*           ON a511~charg = mseg~charg
*           FOR ALL ENTRIES IN  @gt_data_t
*           WHERE a511~charg EQ @gt_data_t-batch
*           AND   a511~datbi GE @sy-datum
*           AND   mseg~bwart =  @c_101.
*
*    IF lt_price IS NOT INITIAL.
*      SORT : lt_price BY charg, gt_data BY batch.
*      LOOP AT lt_price ASSIGNING FIELD-SYMBOL(<ls_price>).
*        READ TABLE gt_data WITH KEY batch = <ls_price>-charg TRANSPORTING NO FIELDS BINARY SEARCH.
*        IF sy-subrc = 0.
*          lv_index = sy-tabix.
*          LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<gs_data>) FROM lv_index.
*            IF <gs_data>-batch <> <ls_price>-charg.
*              EXIT.
*            ENDIF.
*            <gs_data>-old_price = <ls_price>-kbetr.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

  CHECK gv_batch IS NOT INITIAL.
**  READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY batch = gv_batch.
**  IF sy-subrc = 0.
**    <ls_data>-menge = <ls_data>-menge + 1.
*  ENDIF.
*** Batch based Material
  SELECT SINGLE a511~charg, konp~kbetr
         INTO @DATA(ls_price) FROM konp
         INNER JOIN a511 ON a511~knumh = konp~knumh
         INNER JOIN mseg ON a511~charg = mseg~charg
         WHERE a511~charg EQ @gv_batch
         AND   a511~datbi GE @sy-datum
         AND   konp~loevm_ko = @space
         AND   mseg~bwart IN ( '101' , '107' ) ." @c_101.

*    IF ls_price-kbetr IS NOT INITIAL.
*      APPEND VALUE #( batch = gv_batch menge = 1 old_price = ls_price-kbetr ) TO gt_data.

  READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY batch = gv_batch.
  IF sy-subrc = 0.
    <ls_data>-menge = <ls_data>-menge + 1.
  ELSE.
    APPEND VALUE #( batch = gv_batch menge = 1 old_price = ls_price-kbetr new_price = '' ) TO gt_data.
  ENDIF.

*  CLEAR : gv_batch.
**    ELSE.
**      MESSAGE 'Invalid Batch' TYPE 'E'.
*    ENDIF.
**  ENDIF.

  IF custom_container IS INITIAL .
    CREATE OBJECT custom_container
      EXPORTING
        container_name = mycontainer.
    CREATE OBJECT grid
      EXPORTING
        i_parent = custom_container.
  ENDIF.

*** CREATE OBJECT event_receiver.
  IF lr_event IS NOT BOUND.
    CREATE OBJECT lr_event.
***---setting event handlers
*    SET HANDLER LR_EVENT->HANDLE_TOOLBAR_SET   FOR GRID.
    SET HANDLER lr_event->handle_user_command  FOR grid.
  ENDIF.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_layout
      it_toolbar_excluding          = gt_tlbr_excl  " Excluded Toolbar Standard Functions
    CHANGING
      it_outtab                     = gt_data
      it_fieldcatalog               = gi_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

***  Registering the EDIT Event
  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  SET HANDLER lr_event->handle_data_changed FOR grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data.
*** BAPI Structure Declaration
  DATA:
    ls_goodsmvt_header TYPE bapi2017_gm_head_01,
    ls_goodsmvt_item   TYPE bapi2017_gm_item_create,
    ls_gmvt_headret    TYPE bapi2017_gm_head_ret,
    lt_goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lt_bapiret         TYPE STANDARD TABLE OF bapiret2.
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  DATA : lt_det TYPE STANDARD TABLE OF ty_det,
         ls_det TYPE ty_det.


  TYPES : BEGIN OF ty_mvt,
            matnr   TYPE matnr,
            charg   TYPE charg_d,
            lgort   TYPE lgort_d,
            werks   TYPE werks,
            qty     TYPE int4,
            charg_n TYPE charg_d,
            message TYPE char80,
          END OF ty_mvt.

  DATA : lt_mvt TYPE STANDARD TABLE OF ty_mvt.
  FIELD-SYMBOLS :       <ls_mvt> TYPE ty_mvt.
  BREAK ppadhy.
  READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<gs_data>) WITH KEY new_price = ''.
  IF sy-subrc = 0 .
    DATA(lv_msg) = 'For batch ' && <gs_data>-batch && ' New Price is empty'.
    MESSAGE lv_msg TYPE 'E'.
  ELSEIF gt_data IS NOT INITIAL.
    SELECT matnr,
           charg,
           lgort,
           werks FROM mchb
           INTO TABLE @DATA(lt_mchb)
           FOR ALL ENTRIES IN @gt_data
           WHERE charg = @gt_data-batch.
  ENDIF.

**** Batch to Batch Transfer
  SORT lt_mchb BY charg.
  DATA(lt_mchb_t) = lt_mchb.
  DELETE ADJACENT DUPLICATES FROM lt_mchb_t COMPARING charg.

  LOOP AT lt_mchb_t ASSIGNING FIELD-SYMBOL(<ls_mchb_t>).
    DATA(lt_mchb_t1) = lt_mchb.
    DELETE lt_mchb_t1 WHERE charg <> <ls_mchb_t>-charg.
*    DESCRIBE TABLE lt_mchb_t1 LINES DATA(lv_qty).
    READ TABLE gt_data INTO DATA(gt_data2) WITH KEY batch =  <ls_mchb_t>-charg.
    IF sy-subrc = 0.
      DATA(lv_qty) = gt_data2-menge.
      APPEND VALUE #( matnr =  <ls_mchb_t>-matnr charg =  <ls_mchb_t>-charg
                      lgort =  <ls_mchb_t>-lgort werks =  <ls_mchb_t>-werks qty = lv_qty ) TO lt_mvt.
    ENDIF.

  ENDLOOP.
  REFRESH : lt_goodsmvt_item.
  ls_goodsmvt_header-doc_date     = ls_goodsmvt_header-pstng_date = sy-datum.
  LOOP AT lt_mvt ASSIGNING <ls_mvt>.
    ls_goodsmvt_item-material       = <ls_mvt>-matnr.
    ls_goodsmvt_item-plant          = <ls_mvt>-werks.
    ls_goodsmvt_item-stge_loc       = <ls_mvt>-lgort.
    ls_goodsmvt_item-batch          = <ls_mvt>-charg.
    ls_goodsmvt_item-move_type      = c_311.
    ls_goodsmvt_item-entry_qnt      = <ls_mvt>-qty.
    ls_goodsmvt_item-entry_uom      = 'EA'.
    ls_goodsmvt_item-move_mat       = <ls_mvt>-matnr.
    ls_goodsmvt_item-move_plant     = <ls_mvt>-werks.
    ls_goodsmvt_item-move_stloc     = <ls_mvt>-lgort.
    ls_goodsmvt_item-move_batch     = <ls_mvt>-charg_n = 'N' && <ls_mvt>-charg+1(9).
    APPEND ls_goodsmvt_item TO lt_goodsmvt_item.
  ENDLOOP.

*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_goodsmvt_header
      goodsmvt_code    = c_mvt_04
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_goodsmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING <ls_bapiret> WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
    gv_mod = c_d.
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
    gv_mblnr = ls_det-mblnr = ls_gmvt_headret-mat_doc .
    gv_mjahr = ls_det-mjahr = ls_gmvt_headret-doc_year.
    <ls_mvt>-message = 'Successfully Posted'.
    APPEND ls_det TO lt_det.
    CLEAR ls_det.

**** Updating Display table
*      READ TABLE lt_goodsmvt_item ASSIGNING  FIELD-SYMBOL(<ls_goodsmvt_item>) WITH KEY batch = <ls_mvt>-charg.
*      IF sy-subrc = 0.
*        LOOP AT gt_data ASSIGNING <gs_data> WHERE batch = <ls_mvt>-charg.
*          <gs_data>-batch_n = <ls_goodsmvt_item>-move_batch.
*          <gs_data>-message = <ls_mvt>-message.
*        ENDLOOP.
*      ENDIF.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE <ls_bapiret>-message TYPE <ls_bapiret>-type.
  ENDIF.
  BREAK ppadhy.

*** Update conditonal records
  CHECK gv_mblnr IS NOT INITIAL.
  DATA: lt_con_rec TYPE TABLE OF zcon_rec_t,
        ls_con_rec TYPE zcon_rec_t.
  FIELD-SYMBOLS : <ls_item> TYPE zinw_t_item.
  REFRESH : lt_con_rec.
  SELECT DISTINCT matnr, mat_cat FROM zinw_t_item INTO TABLE @DATA(lt_mat_cat) FOR ALL ENTRIES IN @lt_mvt WHERE matnr = @lt_mvt-matnr.
  SELECT charg, matnr, dmbtr, werks INTO TABLE @DATA(lt_mseg) FROM mseg WHERE mblnr = @gv_mblnr AND mjahr = @gv_mjahr AND shkzg = 'S'.
  LOOP AT lt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>).

    ls_con_rec-mandt = sy-mandt.
    ls_con_rec-kschl = 'ZKP0'.
    ls_con_rec-werks = <ls_mseg>-werks.
    ls_con_rec-vrkme = 'EA'.
    ls_con_rec-matnr = <ls_mseg>-matnr.
    READ TABLE lt_mat_cat ASSIGNING FIELD-SYMBOL(<ls_mst_cat>) WITH KEY matnr = <ls_mseg>-matnr.
    IF sy-subrc = 0 .
      ls_con_rec-mat_cat =  <ls_mst_cat>-mat_cat.
    ELSE.
      ls_con_rec-mat_cat = '01'.
    ENDIF.

    READ TABLE gt_data INTO DATA(w_data) WITH KEY batch+1(9) = <ls_mseg>-charg+1(9).
    IF sy-subrc = 0.
      ls_con_rec-kbetr = w_data-new_price."<ls_mseg>-dmbtr.
    ENDIF.
    ls_con_rec-konwa = 'INR'.
    ls_con_rec-batch = <ls_mseg>-charg.
    APPEND ls_con_rec TO lt_con_rec.
    CLEAR : ls_con_rec.
  ENDLOOP.
  MODIFY zcon_rec_t FROM TABLE lt_con_rec.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_ICONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_icons .

  IF gt_tlbr_excl IS NOT INITIAL.
    RETURN.
  ENDIF.

  gt_tlbr_excl = VALUE #( ( cl_gui_alv_grid=>mc_fc_loc_delete_row    )
                          ( cl_gui_alv_grid=>mc_fc_loc_insert_row    )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste         )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy          )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy_row      )
                          ( cl_gui_alv_grid=>mc_fc_loc_cut           )
                          ( cl_gui_alv_grid=>mc_fc_loc_undo          )
                          ( cl_gui_alv_grid=>mc_fc_loc_append_row    )
                          ( cl_gui_alv_grid=>mc_fc_print             )
                         ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_mode .
  LOOP AT SCREEN.
    IF gv_mod = 'D'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print USING gv_mblnr p_tp3 gv_mjahr.
  BREAK ppadhy.

  SELECT charg, matnr, dmbtr, werks INTO TABLE @DATA(it_mseg) FROM mseg WHERE mblnr = @gv_mblnr AND mjahr = @gv_mjahr AND shkzg = 'S'.

*  LOOP AT it_mseg INTO DATA(w_mseg).

  CALL FUNCTION 'ZRE_STICKERING'
    EXPORTING
      i_mblnr       = gv_mblnr
      i_tp3_sticker = p_tp3
      i_mjahr       = gv_mjahr
*     i_charg       = w_mseg-charg
*     i_prints      = '00000000'.
    .
*  ENDLOOP.

ENDFORM.
