*&---------------------------------------------------------------------*
*& Include          SAPMZBGRPO_RCV_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ALV_GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_grid1 .

CREATE OBJECT container1
    EXPORTING
     container_name = 'CONTAINER1'.

  CREATE OBJECT grid1
    EXPORTING
      i_parent   = container1.

  CALL METHOD grid1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error = 1
      OTHERS = 2.

*  CREATE OBJECT g_verifier.
*  SET HANDLER g_verifier->toolbar FOR grid1.
*  SET HANDLER g_verifier->user_command FOR grid1.

PERFORM exclude_tb_function CHANGING it_exclude.
PERFORM fill_1grid1.
PERFORM fill_1grid2.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- IT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_function   CHANGING lt_exclude TYPE ui_functions.
    DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_filter.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdata.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_help.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_load_variant.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_mb_variant.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_maximum.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_minimum.
  APPEND ls_exclude TO lt_exclude.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_1GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_1grid1 .
REFRESH lt_fieldcat1.
 PERFORM fc USING: '01'  'EBELP'     'IT_ITEM'  'Item No'  'Item No'  'Item No'  '' '' '6'  ''  '' '' ''
                   CHANGING lt_fieldcat1,
                   '02'  'MATNR'     'IT_ITEM'  'Product'  'Product'  'Product'  '' '' '10'  '' '' '' ''
                   CHANGING lt_fieldcat1,
                   '03'  'MAKTX'     'IT_ITEM'   'Prd.desc '  'Product Des' 'Product Des'  '' '' '20'  ''  '' ''  ''
                   CHANGING lt_fieldcat1,
                   '04'  'MATKL'     'IT_ITEM'  'Category'  'Category'  'Category'  '' '' '10'  ''  '' '' ''
                   CHANGING lt_fieldcat1,
                   '05'  'EAN11'     'IT_ITEM'  'EAN'       'EAN'     'EAN'  '' '' '10'  ''  ''  '' ''
                   CHANGING lt_fieldcat1,
                   '06'  'OMENGE'    'IT_ITEM'  'Open Qty'  'Open Qty'  'Open Qty' ' ' ' ' '08'  ' '  'MSEG' 'MENGE' ' '
                   CHANGING lt_fieldcat1,
                   '07'  'RMENGE'    'IT_ITEM'  'Rec Qty'    'Rec Qty'   'Rec Qty'  'X'  ' '  '08'  ' '  'MSEG' 'MENGE'  ' '
                   CHANGING lt_fieldcat1,
                   '08'  'MEINS'     'IT_ITEM'  'UOM'  'UOM'  'UOM'  ' ' ' ' '04'  ' '  ' '  ' '  ' '
                   CHANGING lt_fieldcat1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      <-- LT_FIELDCAT1
*&---------------------------------------------------------------------*
FORM fc USING fp_colpos    TYPE sycucol
              fp_fldnam    TYPE fieldname
              fp_tabnam    TYPE tabname
              scrtext_s    TYPE scrtext_s
              scrtext_m    TYPE scrtext_m
              scrtext_l    TYPE scrtext_l
              edit         TYPE c
              do_sum       TYPE c
              olen         TYPE char2
              f4h          TYPE ddf4avail
              reftab       TYPE lvc_rtname
              reffld       TYPE lvc_rfname
              drdn_hndl    TYPE int4
         CHANGING lt_fieldcat TYPE  lvc_t_fcat.

  DATA: wa_fcat  TYPE  lvc_s_fcat.
  wa_fcat-row_pos        = '1'.     "ROW
  wa_fcat-col_pos        = fp_colpos.     "COLUMN
  wa_fcat-fieldname      = fp_fldnam.     "FIELD NAME
  wa_fcat-tabname        = fp_tabnam.     "INTERNAL TABLE NAME
  wa_fcat-edit           = edit.
  wa_fcat-outputlen      = olen.
  wa_fcat-do_sum         = do_sum.
  wa_fcat-f4availabl     = f4h.
  wa_fcat-scrtext_s      = scrtext_s.
  wa_fcat-scrtext_m      = scrtext_m.
  wa_fcat-scrtext_l      = scrtext_l.
  wa_fcat-reptext        = scrtext_l.
  wa_fcat-just           = 'L'.
  wa_fcat-ref_table      = reftab.
  wa_fcat-ref_field      = reffld.
  wa_fcat-drdn_hndl      = drdn_hndl.

  IF wa_fcat-fieldname = 'MEINS'.
   wa_fcat-convexit = 'CUNIT'.
  ENDIF.

  APPEND wa_fcat TO lt_fieldcat.
  CLEAR wa_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_1GRID2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_1grid2 .
 lw_layo1-frontend = 'X'.
  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      is_layout                     = lw_layo1
      it_toolbar_excluding          = it_exclude
    CHANGING
      it_outtab                     = it_item
      it_fieldcatalog               = lt_fieldcat1
*      IT_SORT                       = LT_SORT
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4 .

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

CALL METHOD grid1->set_ready_for_input
  EXPORTING
  i_ready_for_input = 1.

  CALL METHOD grid1->set_toolbar_interactive.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save.
 DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lw_return1      TYPE  bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1),
     gv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.
  gv_subrc = 0.
  CHECK wa_hdr-mblnr_101 IS INITIAL.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = wa_hdr-budat ."sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 3.
  lv_line_id = '000001'.
*** Looping the PO details.
  LOOP AT it_item ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE rmenge IS NOT INITIAL.
    IF <ls_item>-rmenge <> <ls_item>-omenge.
      gv_diff = 'X'.
    ENDIF.
    CHECK <ls_item>-rmenge > 0.
*** FILL THE BAPI ITEM STRUCTURE DETAILS - 101 Movement Type
    READ TABLE gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    CHECK sy-subrc = 0.
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-matnr.
    ls_gmvt_item-move_type = '101'.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-po_number = <ls_mseg>-ebeln.
    ls_gmvt_item-po_item   = <ls_mseg>-ebelp.
    ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = <ls_item>-rmenge.
    ls_gmvt_item-entry_uom = ls_gmvt_item-entry_uom_iso = ls_gmvt_item-orderpr_un = ls_gmvt_item-orderpr_un_iso = <ls_mseg>-meins.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-mvt_ind   = 'B'.

    ls_gmvt_item-vendor    = <ls_mseg>-lifnr.
    ls_gmvt_item-stge_loc  = 'FG01'.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.

*** FILL THE BAPI ITEM STRUCTURE DETAILS - 543 Movement Type
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-m_matnr.
    ls_gmvt_item-move_type = '543'.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-po_number = <ls_mseg>-ebeln.
    ls_gmvt_item-po_item   = <ls_mseg>-ebelp.
    ls_gmvt_item-entry_qnt = <ls_mseg>-m_menge.

*    ls_gmvt_item-entry_qnt = ( <ls_item>-rmenge  ) * ( <ls_mseg>-m_menge / <ls_item>-omenge ).
    ls_gmvt_item-entry_qnt = ( <ls_item>-rmenge   *  <ls_mseg>-m_menge ) / <ls_MSEG>-menge .
    ls_gmvt_item-entry_uom = <ls_mseg>-m_meins.
    ls_gmvt_item-entry_uom_iso = 'KGM' .
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type = <ls_mseg>-charg.

    ls_gmvt_item-vendor   = <ls_mseg>-lifnr.
    ls_gmvt_item-spec_stock = 'O'.
    ls_gmvt_item-line_id = lv_line_id.
    ls_gmvt_item-parent_id = lv_line_id - 1 .

    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = '01'
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    wa_hdr-mblnr_101 = ls_gmvt_headret-mat_doc.

                    APPEND VALUE #( type  = 'S'
                        id    = 'MIGO'
                        txtnr = '012'
                        msgv1 = wa_hdr-mblnr_101  ) TO it_log.

     CLEAR: it_item, wa_hdr.
     CALL METHOD grid1->refresh_table_display.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.

        LOOP AT lt_bapiret INTO lw_return1 WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return1-type
                            id    = lw_return1-id
                            txtnr = lw_return1-number
                            msgv1 = lw_return1-message_v1
                            msgv2 = lw_return1-message_v2 ) TO it_log.
        ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_MSGS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disp_msgs .
CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.


    LOOP AT it_log ASSIGNING FIELD-SYMBOL(<log>).
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb = <log>-id
*         EXCEPTION_IF_NOT_ACTIVE       = 'X'
          msgty = <log>-type
          msgv1 = <log>-msgv1
          msgv2 = <log>-msgv2
          txtnr = <log>-txtnr
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDLOOP.
    CALL FUNCTION 'MESSAGES_STOP'
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'MESSAGES_SHOW'
      EXCEPTIONS
        inconsistent_range = 1
        no_messages        = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_542_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_542 .

 DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lw_return1      TYPE bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

REFRESH: lt_gmvt_item, lt_bapiret.
  CHECK wa_hdr-mblnr_542 IS INITIAL.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = wa_hdr-budat. "sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 2.
  lv_line_id = '000001'.
*** Looping the PO details.
  LOOP AT it_item ASSIGNING FIELD-SYMBOL(<ls_item>).
*    CHECK <ls_item>-rmenge <> <ls_item>-omenge.
    READ TABLE gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    CHECK sy-subrc = 0.
    READ TABLE it_con ASSIGNING FIELD-SYMBOL(<ls_wst>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.

    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-m_matnr.
    ls_gmvt_item-move_type = '542'.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-vendor    = <ls_mseg>-lifnr.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type  = ls_gmvt_item-move_batch = ls_gmvt_item-move_val_type = <ls_mseg>-charg.
*    ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = ( <ls_item>-omenge - <ls_item>-rmenge  ) * ( <ls_mseg>-m_menge / <ls_item>-omenge ).
    ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = <ls_mseg>-m_menge - <ls_wst>-menge.
    ls_gmvt_item-entry_uom = ls_gmvt_item-entry_uom_iso = <ls_mseg>-m_meins.
    ls_gmvt_item-entry_uom_iso = 'KGM'.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-vendor    = <ls_mseg>-lifnr.
    ls_gmvt_item-stge_loc  = 'FG01'.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = '04'
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    wa_hdr-mblnr_542 = ls_gmvt_headret-mat_doc.
                    APPEND VALUE #( type  = 'S'
                                   id    = 'MIGO'
                                   txtnr = '012'
                                   msgv1 = wa_hdr-mblnr_542  ) TO it_log.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.

        LOOP AT lt_bapiret INTO lw_return1 WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return1-type
                            id    = lw_return1-id
                            txtnr = lw_return1-number
                            msgv1 = lw_return1-message_v1
                            msgv2 = lw_return1-message_v2 ) TO it_log.
        ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_201 .
*** BAPI STRUCTURE DECLARATION
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lw_return1      TYPE bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

REFRESH: lt_gmvt_item, lt_bapiret.

  CHECK wa_hdr-mblnr_201 IS INITIAL.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = wa_hdr-budat. "sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 1.
  lv_line_id = '000001'.

*** Looping the PO details.
  LOOP AT it_item ASSIGNING FIELD-SYMBOL(<ls_item>).
*    CHECK <ls_item>-rmenge <> <ls_item>-omenge.
*** FILL THE BAPI ITEM STRUCTURE DETAILS - 542 Movement Type
    READ TABLE gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    CHECK sy-subrc = 0.
     READ TABLE it_con ASSIGNING FIELD-SYMBOL(<ls_wst>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-m_matnr.
    ls_gmvt_item-move_type = '201'.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type   = <ls_mseg>-charg.
*    ls_gmvt_item-entry_qnt = ( <ls_item>-omenge - <ls_item>-rmenge ) * ( <ls_mseg>-m_menge / <ls_item>-omenge ).
    ls_gmvt_item-entry_qnt =  <ls_mseg>-m_menge - <ls_wst>-menge.
    ls_gmvt_item-entry_uom = <ls_mseg>-m_meins.
    ls_gmvt_item-entry_uom_iso = 'KGM'.
    ls_gmvt_item-stge_loc      = 'FG01'.
    ls_gmvt_item-gl_account    = '0000620100'.
  IF SY-sysid = 'SDS'.
     ls_gmvt_item-costcenter    = '0000010000'.
  ELSE.
    ls_gmvt_item-costcenter    = '0009100000'.
  ENDIF.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.
*** Call the BAPI FM for GR posting
  DATA(c_mvt_03) = '03'.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = c_mvt_03
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    wa_hdr-mblnr_201 = ls_gmvt_headret-mat_doc.

                    APPEND VALUE #( type  = 'S'
                                   id    = 'MIGO'
                                   txtnr = '012'
                                   msgv1 = wa_hdr-mblnr_201  ) TO it_log.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.
        LOOP AT lt_bapiret INTO lw_return1 WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return1-type
                            id    = lw_return1-id
                            txtnr = lw_return1-number
                            msgv1 = lw_return1-message_v1
                            msgv2 = lw_return1-message_v2 ) TO it_log.
        ENDLOOP.

      REFRESH  lt_bapiret .
     CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
       EXPORTING
         materialdocument          = wa_hdr-mblnr_542
         matdocumentyear           = SY-DATUM+0(4)
        GOODSMVT_PSTNG_DATE        = SY-DATUM
       TABLES
         return                    = lt_bapiret.

               .


  ENDIF.
ENDFORM.
