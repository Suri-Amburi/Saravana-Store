*&---------------------------------------------------------------------*
*& Include          SAPMZ_LOCAL_PURCH_GR_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data CHANGING gv_subrc.
  REFRESH : gt_item.
  IF gs_hdr-qr_code IS NOT INITIAL AND gs_hdr-mblnr_103 IS NOT INITIAL .
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE qr_code = gs_hdr-qr_code AND mblnr_103 = gs_hdr-mblnr_103.
  ELSEIF gs_hdr-qr_code IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE qr_code = gs_hdr-qr_code.
  ELSEIF gs_hdr-mblnr_103 IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE mblnr_103 = gs_hdr-mblnr_103.
  ENDIF.
  IF sy-subrc <> 0.
    gv_subrc = sy-subrc.
    MESSAGE s011(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ELSE.
    SELECT * FROM zinw_t_item INTO TABLE gt_item_t WHERE qr_code = gs_hdr-qr_code.
    SELECT mblnr, matnr, charg, ebeln, ebelp, bwtar, lfbnr, lfpos, sjahr FROM mseg INTO TABLE @DATA(lt_mseg) WHERE mblnr = @gs_hdr-mblnr_103.
    LOOP AT gt_item_t ASSIGNING <gs_item_t>.
      MOVE-CORRESPONDING <gs_item_t> TO gs_item.
      READ TABLE lt_mseg ASSIGNING FIELD-SYMBOL(<ls_msg>) WITH KEY matnr =  <gs_item_t>-matnr ebeln = <gs_item_t>-ebeln ebelp = <gs_item_t>-ebelp.
      IF sy-subrc = 0.
        gs_item-charg = <ls_msg>-charg.
        gs_item-bwtar = <ls_msg>-bwtar.
        gs_item-lfbnr = <ls_msg>-lfbnr.
        gs_item-lfpos = <ls_msg>-lfpos.
        gs_item-sjahr = <ls_msg>-sjahr.
      ENDIF.
      APPEND gs_item TO gt_item.
      CLEAR : gs_item.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_SUBRC
*&---------------------------------------------------------------------*
FORM display_data CHANGING gv_subrc.

  DATA: wa_fc   TYPE  lvc_s_fcat,
        it_sort TYPE lvc_t_sort,
        wa_sort TYPE lvc_s_sort,
        lv_pos  TYPE i VALUE 1.

  IF gt_fieldcat IS INITIAL .
*    GS_LAYO-CWIDTH_OPT = 'X'.
    gs_layo-frontend   = 'X'.
    gs_layo-zebra      = 'X'.

    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'EBELP'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-outputlen = '5'.
    wa_fc-scrtext_l = 'Item'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'MATNR'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-scrtext_l = 'Material'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'MENGE_P'.
    wa_fc-outputlen = 12.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-decimals  = '2'.
    wa_fc-scrtext_l = 'Pur Quantity'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'ACT_QTY'.
    wa_fc-ref_field = 'MENGE_P'.
    wa_fc-ref_table = 'ZINW_T_ITEM'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-decimals  = '0'.
    wa_fc-decimals_o = '0'.
    wa_fc-scrtext_l = 'Actual Quantity'.
    wa_fc-edit   = 'X'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'MEINS'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-scrtext_l = 'UOM'.
    wa_fc-outputlen = '5'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'NETWR_P'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-scrtext_l = 'Pur Price'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'NETWR_S'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-scrtext_l = 'Selling Price'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

    lv_pos = lv_pos + 1.
    wa_fc-col_pos   = lv_pos.
    wa_fc-fieldname = 'CHARG'.
    wa_fc-tabname   = 'LT_ITEM'.
    wa_fc-no_zero   = 'X'.
    wa_fc-scrtext_l = 'Batch'.
    APPEND wa_fc TO gt_fieldcat.
    CLEAR wa_fc.

  ELSEIF gv_mode = c_d.
    READ TABLE gt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = 'ACT_QTY'.
    IF sy-subrc = 0.
      CLEAR : <ls_fcat>-edit.
    ENDIF.
  ENDIF.

  IF container IS NOT BOUND.
    CREATE OBJECT container
      EXPORTING
        container_name = 'CONTAINER'.
    CREATE OBJECT grid
      EXPORTING
        i_parent = container.
  ENDIF.
*** Create Object for event_receiver.
  IF gr_event IS NOT BOUND.
    CREATE OBJECT gr_event.
  ENDIF.
  IF gt_exclude IS INITIAL.
    PERFORM exclude_tb_functions CHANGING gt_exclude.
  ENDIF.

  IF grid IS BOUND.
    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        is_layout                     = gs_layo
        it_toolbar_excluding          = gt_exclude
      CHANGING
        it_outtab                     = gt_item
        it_fieldcatalog               = gt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
    ENDIF.
***  Registering the EDIT Event
    CALL METHOD grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    SET HANDLER gr_event->handle_data_changed FOR grid.
  ENDIF.
ENDFORM.

FORM exclude_tb_functions  CHANGING gt_exclude TYPE ui_functions.
  DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gt_exclude.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_data .
  CLEAR : gv_qr, gv_mblnr_103, gv_mode.
  REFRESH : gt_item.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data USING gv_subrc.
*** BAPI STRUCTURE DECLARATION
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create.
  FIELD-SYMBOLS :
    <ls_ret> TYPE bapiret2.

  DATA:
    ls_status TYPE zinw_t_status,
    lt_status TYPE TABLE OF zinw_t_status.
  REFRESH : lt_bapiret,lt_status , lt_gmvt_item.
  CHECK gt_item IS NOT INITIAL.
***  Goods Movement 109
*** Looping the PO details.
  LOOP AT gt_item ASSIGNING <gs_item> ."WHERE ACT_QTY IS NOT INITIAL.
*** Fill the bapi Header structure details
  IF lv_budat IS NOT INITIAL.
    ls_gmvt_header-pstng_date = lv_budat.
  ELSE.
    ls_gmvt_header-pstng_date = sy-datum.
  ENDIF.

    ls_gmvt_header-doc_date   = sy-datum.
    ls_gmvt_header-pr_uname   = sy-uname.
    ls_gmvt_header-ref_doc_no   = gs_hdr-mblnr_103.

*** FILL THE BAPI ITEM STRUCTURE DETAILS
    IF strlen( <gs_item>-matnr ) > 18.
      ls_gmvt_item-material_long    = <gs_item>-matnr.
    ELSE.
      ls_gmvt_item-material    = <gs_item>-matnr.
    ENDIF.

    ls_gmvt_item-item_text   = <gs_item>-maktx.
    ls_gmvt_item-plant       = <gs_item>-werks.
    ls_gmvt_item-stge_loc    = <gs_item>-lgort.
    ls_gmvt_item-po_number   = <gs_item>-ebeln.
    ls_gmvt_item-po_item     = <gs_item>-ebelp.
    ls_gmvt_item-entry_uom   = <gs_item>-meins.
    ls_gmvt_item-prod_date   = sy-datum.
    ls_gmvt_item-mvt_ind     = c_mvt_ind_b.
    ls_gmvt_item-batch       = <gs_item>-charg.
    ls_gmvt_item-val_type    = <gs_item>-bwtar.
    ls_gmvt_item-ref_doc     = <gs_item>-lfbnr.
    ls_gmvt_item-ref_doc_it  = <gs_item>-lfpos.
    ls_gmvt_item-ref_doc_yr  = <gs_item>-sjahr.

    IF <gs_item>-act_qty < <gs_item>-menge_p.
      ls_gmvt_item-move_type = c_108.
      ls_gmvt_item-entry_qnt = <gs_item>-menge_p - <gs_item>-act_qty.
      APPEND ls_gmvt_item TO lt_gmvt_item.
    ENDIF.

    IF <gs_item>-act_qty IS NOT INITIAL.
      ls_gmvt_item-entry_qnt   = <gs_item>-act_qty.
      ls_gmvt_item-move_type   = c_109.
      APPEND ls_gmvt_item TO lt_gmvt_item.
    ENDIF.
    CLEAR ls_gmvt_item.
  ENDLOOP.
*  SORT LT_GMVT_ITEM BY MATERIAL PO_NUMBER PO_ITEM MOVE_TYPE.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = c_mvt_01
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING <ls_ret> WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
    gv_mode = c_d.
*** Updating Material Doc in Indw Header
    gs_hdr-mblnr  = ls_gmvt_headret-mat_doc.      " 109 Doc
    gs_hdr-status = c_04.                         " GRPO DONE
    gs_hdr-soe    = c_01.                         " Matched
    MODIFY zinw_t_hdr FROM gs_hdr.

*** Status Update
    ls_status-inwd_doc     = gs_hdr-inwd_doc.
    ls_status-qr_code      = gs_hdr-qr_code.
    ls_status-status_field = c_qr_code.
    ls_status-status_value = c_qr04.
    ls_status-description  = 'GR Posted'.
    ls_status-created_by   = sy-uname.
    ls_status-created_date = sy-datum.
    ls_status-created_time = sy-uzeit.
    APPEND ls_status TO lt_status.
*** Updating SOE Status as Matched
    ls_status-status_field = c_soe.
    ls_status-status_value = c_se01.
    ls_status-description  = 'Matched'.
    APPEND ls_status TO lt_status.

    MODIFY zinw_t_status FROM TABLE lt_status.
    COMMIT WORK.
***   Fetching Batch Details
    SELECT mblnr, matnr, charg, ebeln, ebelp, bwtar FROM mseg INTO TABLE @DATA(lt_batch) WHERE mblnr = @ls_gmvt_headret-mat_doc.
    LOOP AT lt_batch ASSIGNING FIELD-SYMBOL(<ls_item>).
      READ TABLE gt_item ASSIGNING <gs_item> WITH KEY matnr = <ls_item>-matnr ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
      IF sy-subrc = 0.
        <gs_item>-charg = <ls_item>-charg.
        <gs_item>-bwtar = <ls_item>-bwtar.
      ENDIF.
    ENDLOOP.
    MESSAGE 'Successfully Posted'  TYPE 'S'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_data .


  IF gs_hdr-qr_code IS NOT INITIAL AND gs_hdr-mblnr_103 IS NOT INITIAL .
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE qr_code = gs_hdr-qr_code AND mblnr_103 = gs_hdr-mblnr_103.
  ELSEIF gs_hdr-qr_code IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE qr_code = gs_hdr-qr_code.
  ELSEIF gs_hdr-mblnr_103 IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE mblnr_103 = gs_hdr-mblnr_103.
  ENDIF.
  IF sy-subrc <> 0.
    MESSAGE e011(zmsg_cls).
  ELSEIF gs_hdr-mblnr IS NOT INITIAL.

    MESSAGE e012(zmsg_cls).
  ENDIF.

ENDFORM.
