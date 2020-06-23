*&---------------------------------------------------------------------*
*& Include          SAPMZ_FV_PROCESS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcat.
  CHECK gt_fieldcat IS INITIAL.
*** Layout
  gs_layo-frontend   = c_x.
  gs_layo-zebra      = c_x.
*** Field Catlog
  gt_fieldcat = VALUE #(
                         ( fieldname = 'MATNR'     tabname = 'GT_ITEM' scrtext_l = 'Product' outputlen = '20' edit = c_x )
                         ( fieldname = 'MAKTX'     tabname = 'GT_ITEM' scrtext_l = 'Product Des' outputlen = '40' )
                         ( fieldname = 'MENGE'     tabname = 'GT_ITEM' scrtext_l = 'Quantity' outputlen = '10' edit = c_x )
*                           ref_field = 'NETPR_P'   ref_table = 'ZINW_T_ITEM' decimals = '0' decimals_o = '0'  txt_field = 'X' )
                         ( fieldname = 'MEINS'     tabname = 'GT_ITEM' scrtext_l = 'UOM' outputlen = '5' )                        ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

*** Creating Object Ref
  IF gr_container IS NOT BOUND.
    CREATE OBJECT gr_container  EXPORTING container_name = 'MYCONTAINER'.
    CREATE OBJECT gr_grid EXPORTING i_parent = gr_container.
  ENDIF.

*** Create Object for event_receiver.
  IF gr_event IS NOT BOUND.
    CREATE OBJECT gr_event.
  ENDIF.

  IF gt_exclude IS INITIAL.
    PERFORM exclude_tb_functions CHANGING gt_exclude.
  ENDIF.

  IF gr_grid IS BOUND.
*** Displaying Table
    CALL METHOD gr_grid->set_table_for_first_display
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

**  Registering the EDIT Event
    CALL METHOD gr_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    SET HANDLER gr_event->handle_data_changed FOR gr_grid.
  ENDIF.
ENDFORM.


FORM exclude_tb_functions  CHANGING gt_exclude TYPE ui_functions.

  gt_exclude = VALUE #(   ( cl_gui_alv_grid=>mc_fc_loc_insert_row    )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste         )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy          )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy_row      )
                          ( cl_gui_alv_grid=>mc_fc_loc_cut           )
                          ( cl_gui_alv_grid=>mc_fc_loc_undo          )
                          ( cl_gui_alv_grid=>mc_fc_loc_append_row    )
                          ( cl_gui_alv_grid=>mc_fc_print             )
                          ( cl_gui_alv_grid=>mc_fc_loc_move_row      )
                          ( cl_gui_alv_grid=>mc_fc_find_more         )
                          ( cl_gui_alv_grid=>mc_fc_sum               )
                          ( cl_gui_alv_grid=>mc_fc_average           )
                         ).
*  ( cl_gui_alv_grid=>mc_fc_loc_delete_row    )
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear.
  CHECK ok_code = c_exit OR ok_code = c_cancel OR ok_code = c_back.
  LEAVE TO SCREEN 0.
  CLEAR : ok_code.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM post_data.
  gv_subrc = 0.
  PERFORM create_po.
  CHECK gv_subrc = 0.
  PERFORM goods_movement_541 CHANGING gv_subrc.
*  CHECK GV_SUBRC = 0.
*  PERFORM GOODS_MOVEMENT_101_543 CHANGING GV_SUBRC.
*  CHECK GV_SUBRC = 0.
*  PERFORM CONDITION_RECORD_UPLOAD CHANGING GV_SUBRC.
*  CHECK GV_SUBRC = 0.
*  PERFORM PRINT_STICKER CHANGING GV_SUBRC.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_po .
*** PO CREATION DATA
  DATA:
    header         LIKE bapimepoheader,
    headerx        LIKE bapimepoheaderx,
    item           TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
    itemx          TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
    poschedule     TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
    poschedulex    TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
    pocomponents   TYPE TABLE OF bapimepocomponent WITH HEADER LINE,
    pocomponentsx  TYPE TABLE OF  bapimepocomponentx WITH HEADER LINE,
    extensionin    TYPE TABLE OF bapiparex,
    ls_extensionin TYPE bapiparex,
    return         TYPE TABLE OF bapiret2,
    bapi_te_po     TYPE bapi_te_mepoheader,
    bapi_te_pox    TYPE bapi_te_mepoheaderx,
    lv_item        TYPE ebelp,
    lv_schd_line   TYPE etenr.

  BREAK samburi.
  CHECK gs_hdr-ebeln IS INITIAL.
  DELETE gt_item WHERE matnr IS INITIAL.
  IF gt_item IS NOT INITIAL.
*    READ TABLE GT_ITEM ASSIGNING <GS_ITEM> WITH KEY NETPR_S  = 0.
*    IF SY-SUBRC = 0.
*      MESSAGE S088(ZMSG_CLS) DISPLAY LIKE 'E' WITH <GS_ITEM>-MATNR.
*      EXIT.
*    ENDIF.

    SELECT DISTINCT mseg~matnr, mseg~menge AS labst, mast~matnr AS po_matnr ,stpo~meins, stpo~menge INTO TABLE @DATA(lt_mard)
           FROM mseg AS mseg INNER JOIN stpo AS stpo ON stpo~idnrk = mseg~matnr
           INNER JOIN mchb AS mchb ON mchb~matnr = mseg~matnr AND mchb~charg = mseg~charg
           INNER JOIN mast AS mast ON mast~stlnr = stpo~stlnr
           FOR ALL ENTRIES IN @gt_item WHERE  mast~matnr = @gt_item-matnr AND mchb~clabs > 0 AND mseg~werks = @gs_hdr-werks
           AND mseg~mblnr = @gs_hdr-mblnr_b_101.
    IF sy-subrc = 0.
      header-comp_code    = '1000'.
      header-creat_date   = sy-datum.
      header-vendor       = '0000200012'.
      header-doc_type     = c_zpro.
      header-langu        = sy-langu.
      header-purch_org    = '1000'.
      header-pur_group    = 'P01'.
      header-pmnttrms     = '0001'.
      header-item_intvl   = '00010'.
      header-exch_rate    = 1.
      header-currency     = header-currency_iso  = 'INR'.

      headerx-comp_code   = c_x .
      headerx-creat_date  = c_x .
      headerx-vendor      = c_x .
      headerx-doc_type    = c_x .
      headerx-langu       = c_x .
      headerx-purch_org   = c_x .
      headerx-pur_group   = c_x .
      headerx-pmnttrms    = c_x .
      headerx-item_intvl  = c_x .
      headerx-exch_rate   = 1.
      headerx-currency    = headerx-currency_iso  = 'INR'.

      ls_extensionin-structure = 'BAPI_TE_MEPOHEADER'.
      bapi_te_po-po_number = ' '.
      bapi_te_po-approver1 = gs_hdr-packing_head .  " Packing Dep Head
      ls_extensionin-valuepart1 = bapi_te_po.
      APPEND ls_extensionin TO extensionin.
      CLEAR ls_extensionin.

      ls_extensionin-structure = 'BAPI_TE_MEPOHEADERX'.
      bapi_te_pox-po_number = ' '.
      bapi_te_pox-approver1 = 'X'.
      ls_extensionin-valuepart1 = bapi_te_pox.
      APPEND ls_extensionin TO extensionin.
      CLEAR ls_extensionin.

      REFRESH : item, itemx.
      lv_item = 10.
      lv_schd_line = 1.
      LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        item-po_item         = lv_item.
        item-item_cat        = 'L'.
        item-material        = item-ematerial = item-material_long  = item-ematerial_long = <ls_item>-matnr.
        item-plant           = gs_hdr-werks.
        item-quantity        = <ls_item>-menge.
        item-po_unit         = item-po_unit_iso = item-orderpr_un = item-orderpr_un_iso = <ls_item>-meins.
        item-stge_loc        = 'FG01'.
        item-gr_pr_time      = 0.
        item-weightunit      = 'KG'.
        item-weightunit_iso  = 'KGM'.
        item-producttype     = 1.
        item-prnt_price      = c_x.
        item-info_upd        = 'C'.
        item-free_item       = c_x.
        item-price_unit      = 1.
        item-conv_num1       = item-conv_den1  = 1.
        item-price_date      = sy-datum.

        itemx-po_item        = lv_item.
        itemx-item_cat       = c_x.
        itemx-material       = itemx-ematerial  = itemx-material_long  = itemx-ematerial_long = c_x.
        itemx-plant          = c_x.
        itemx-quantity       = c_x.
        itemx-po_unit        = itemx-po_unit_iso = itemx-orderpr_un = itemx-orderpr_un_iso = c_x.
        itemx-stge_loc       = c_x.
        itemx-gr_pr_time     = c_x.
        itemx-weightunit     = c_x.
        itemx-weightunit_iso = c_x.
        itemx-producttype    = c_x.
        itemx-period_ind_expiration_date  = c_x.
        itemx-prnt_price     = c_x.
        itemx-info_upd       = c_x.
        itemx-free_item      = c_x.
        itemx-price_unit     = c_x.
        itemx-conv_num1      = c_x.
        itemx-price_date     = c_x.

*** Schedule Line Items
        poschedule-po_item       = lv_item.
        poschedule-sched_line    = lv_schd_line.
        poschedule-delivery_date = sy-datum.
        poschedule-quantity      = <ls_item>-menge.

*** Schedule Line Items Update Flag
        poschedulex-po_item       = lv_item.
        poschedulex-sched_line    = lv_schd_line.
        poschedulex-po_itemx      = c_x.
        poschedulex-sched_linex   = c_x.
        poschedulex-delivery_date = c_x.
        poschedulex-quantity      = c_x.

***   PO Components
        READ TABLE lt_mard ASSIGNING FIELD-SYMBOL(<ls_mard>) WITH KEY po_matnr = <ls_item>-matnr.
        IF sy-subrc = 0.
          pocomponents-po_item        = lv_item.
          pocomponents-sched_line     = pocomponents-item_no = lv_schd_line.
          pocomponents-material       = <ls_mard>-matnr.
          pocomponents-entry_quantity = <ls_item>-menge * <ls_mard>-menge.
          pocomponents-entry_uom      = <ls_mard>-meins.
          pocomponents-entry_uom_iso  = 'KGM'.
          pocomponents-plant          = gs_hdr-werks.
          pocomponents-req_date       = sy-datum.
          pocomponents-item_cat       = 'L'.
          pocomponents-req_quan       = <ls_item>-menge.
          pocomponents-base_uom       = <ls_mard>-meins.
          pocomponents-base_uom_iso   = 'KGM'.
          pocomponents-change_id      = 'I'.

***   PO Components Update Flag
          pocomponentsx-po_item        = lv_item.
          pocomponentsx-sched_line     = pocomponentsx-item_no = lv_schd_line.
          pocomponentsx-po_itemx       = c_x.
          pocomponentsx-sched_linex    = pocomponentsx-item_nox = c_x.
          pocomponentsx-material       = c_x.
          pocomponentsx-entry_quantity = c_x.
          pocomponentsx-entry_uom      = c_x.
          pocomponentsx-entry_uom_iso  = c_x.
          pocomponentsx-plant          = c_x.
          pocomponentsx-req_date       = c_x.
          pocomponentsx-item_cat       = c_x.
          pocomponentsx-req_quan       = c_x.
          pocomponentsx-base_uom       = c_x.
          pocomponentsx-base_uom_iso   = c_x.
          pocomponentsx-change_id      = c_x.
        ENDIF.
        APPEND : item, itemx, pocomponents , pocomponentsx, poschedule, poschedulex .
        CLEAR : itemx , item, pocomponents , pocomponentsx, poschedule, poschedulex.
        lv_item = lv_item + 10.
        lv_schd_line = lv_schd_line + 1.
      ENDLOOP.
*** Return PO Creation
      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          poheader         = header
          poheaderx        = headerx
        IMPORTING
          exppurchaseorder = gs_hdr-ebeln
        TABLES
          return           = return
          poitem           = item
          poitemx          = itemx
          poschedule       = poschedule
          poschedulex      = poschedulex
          extensionin      = extensionin
          pocomponents     = pocomponents
          pocomponentsx    = pocomponentsx.

      READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
      IF sy-subrc <> 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = c_x.
      ELSE.
        gv_subrc = 4.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
        <ls_ret>-message_v3 <ls_ret>-message_v4.
      ENDIF.
    ELSE.
      MESSAGE 'No Components' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_541
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_SUBRC
*&---------------------------------------------------------------------*
FORM goods_movement_541 CHANGING gv_subrc.
*** BAPI Structure Declaration
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    ls_status       TYPE zinw_t_status.

  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  DATA : lv_open_qty TYPE menge_d.
  DATA : lv_act_qty TYPE menge_d.

  CHECK gs_hdr-mblnr_541 IS INITIAL.
  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @gs_hdr-ebeln.
  IF sy-subrc = 0.
    SELECT DISTINCT mchb~matnr, mchb~charg, mchb~clabs, mast~matnr AS po_matnr ,stpo~meins, stpo~menge INTO TABLE @DATA(lt_mchb)
           FROM mchb AS mchb INNER JOIN stpo AS stpo ON stpo~idnrk = mchb~matnr
           INNER JOIN mast AS mast ON mast~stlnr = stpo~stlnr
           INNER JOIN mseg AS mseg ON mseg~matnr = mchb~matnr AND mseg~charg = mchb~charg
           FOR ALL ENTRIES IN @lt_ekpo
           WHERE mast~matnr = @lt_ekpo-matnr AND mchb~clabs > 0 AND mseg~werks = @gs_hdr-werks AND mseg~mblnr = @gs_hdr-mblnr_b_101.
    IF sy-subrc = 0.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
      ls_gmvt_header-pstng_date       = sy-datum.
      ls_gmvt_header-doc_date         = sy-datum.
      ls_gmvt_header-pr_uname         = sy-uname.
      ls_gmvt_header-ver_gr_gi_slip   = 1.

*** Looping the PO details.
      LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_item>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS
        LOOP AT lt_mchb ASSIGNING FIELD-SYMBOL(<ls_mchb>) WHERE po_matnr = <ls_item>-matnr.
          ls_gmvt_item-move_mat  = ls_gmvt_item-material  = ls_gmvt_item-material_long = ls_gmvt_item-move_mat_long = <ls_mchb>-matnr.
          ls_gmvt_item-move_type = c_541.
          ls_gmvt_item-po_number = <ls_item>-ebeln.
          ls_gmvt_item-po_item   = <ls_item>-ebelp.
          ls_gmvt_item-prod_date = sy-datum.
          ls_gmvt_item-vendor    = '0000200012'.
          ls_gmvt_item-plant     = ls_gmvt_item-move_plant = gs_hdr-werks.
          ls_gmvt_item-stge_loc  = 'FG01'.
          ls_gmvt_item-entry_uom = <ls_mchb>-meins.
          ls_gmvt_item-entry_uom_iso = 'KGM'.
          ls_gmvt_item-batch     = ls_gmvt_item-val_type = ls_gmvt_item-move_batch = ls_gmvt_item-move_val_type = <ls_mchb>-charg.

***   Quantity Converstion
          lv_act_qty = ( <ls_item>-menge - lv_open_qty ) * <ls_mchb>-menge.
          IF <ls_mchb>-clabs GE lv_act_qty.
            ls_gmvt_item-entry_qnt = lv_act_qty.
            APPEND ls_gmvt_item TO lt_gmvt_item.
            CLEAR ls_gmvt_item.
            EXIT.
          ELSE.
            ls_gmvt_item-entry_qnt = <ls_mchb>-clabs.
            lv_open_qty = lv_open_qty + ls_gmvt_item-entry_qnt .
            APPEND ls_gmvt_item TO lt_gmvt_item.
            CLEAR ls_gmvt_item.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
*** Call the BAPI FM for GR posting
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_gmvt_header
          goodsmvt_code    = c_mvt_06
        IMPORTING
          goodsmvt_headret = ls_gmvt_headret
        TABLES
          goodsmvt_item    = lt_gmvt_item
          return           = lt_bapiret.

      READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = c_e.
      IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = c_x.
        gs_hdr-mblnr_541 = ls_gmvt_headret-mat_doc.
***  Form
        SUBMIT zmm_contract_po WITH p_ebeln = gs_hdr-ebeln.
      ELSE.
*** Roll Back if any error.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        gv_subrc = 4.
        MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
        <ls_ret>-message_v3 <ls_ret>-message_v4.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_101_543
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM goods_movement_101_543 CHANGING gv_subrc.
*** BAPI Structure Declaration
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id.
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  SELECT mseg~matnr, mseg~charg, mseg~ebeln, mseg~ebelp, mseg~menge,
         mseg~meins, ekpo~meins AS po_meins, ekpo~menge AS po_menge, ekpo~matnr AS po_matnr
         INTO TABLE @DATA(lt_mseg) FROM mseg AS mseg
         INNER JOIN ekpo AS ekpo ON ekpo~ebeln = mseg~ebeln  AND ekpo~ebelp = mseg~ebelp
         WHERE mblnr = @gs_hdr-mblnr_541 AND xauto = @space.

*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 3.
  lv_line_id = '000001'.

*** Looping the PO details.
  LOOP AT lt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS - 101 Movement Type
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-po_matnr.
    ls_gmvt_item-move_type = c_101.
    ls_gmvt_item-plant     = gs_hdr-werks.
    ls_gmvt_item-po_number = <ls_mseg>-ebeln.
    ls_gmvt_item-po_item   = <ls_mseg>-ebelp.
    ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = <ls_mseg>-po_menge.
    ls_gmvt_item-entry_uom = ls_gmvt_item-entry_uom_iso = ls_gmvt_item-orderpr_un = ls_gmvt_item-orderpr_un_iso = <ls_mseg>-po_meins.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-mvt_ind   = c_mvt_ind_b.

    ls_gmvt_item-vendor    = '0000200012'.
    ls_gmvt_item-stge_loc  = 'FG01'.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.

*** FILL THE BAPI ITEM STRUCTURE DETAILS - 543 Movement Type
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-matnr.
    ls_gmvt_item-move_type = c_543.
    ls_gmvt_item-plant     = gs_hdr-werks.
    ls_gmvt_item-po_number = <ls_mseg>-ebeln.
    ls_gmvt_item-po_item   = <ls_mseg>-ebelp.
    ls_gmvt_item-entry_qnt = <ls_mseg>-menge.
    ls_gmvt_item-entry_uom = <ls_mseg>-meins. " KG
    ls_gmvt_item-entry_uom_iso = 'KGM' ."<LS_MSEG>-MEINS.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type = <ls_mseg>-charg.

    ls_gmvt_item-vendor   = '0000200012'.
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
      goodsmvt_code    = c_mvt_01
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = c_e.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
    gs_hdr-mblnr_101 = ls_gmvt_headret-mat_doc.
    MESSAGE 'Successfully Posted' TYPE 'S'.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONDITION_RECORD_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM condition_record_upload CHANGING gv_subrc.

  DATA: lv_ctumode(1) VALUE 'N',
        lv_cupdate(1) VALUE 'S'.

  REFRESH : messtab, bdcdata.
  CHECK gs_hdr-mblnr_101 IS NOT INITIAL AND gs_hdr-cond_rec IS INITIAL.
  DATA(lv_date) = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4) .

  SELECT matnr , charg, menge, meins FROM mseg INTO TABLE @DATA(lt_mseg) WHERE mblnr = @gs_hdr-mblnr_101 AND bwart = @c_101.
  IF sy-subrc = 0.
    LOOP AT lt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>).
      PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RV13A-KSCHL'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'RV13A-KSCHL'
                                    'ZKP0'.
      PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM bdc_field       USING 'RV130-SELKZ(02)'
                                    'X'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1511'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RV13A-DATBI(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                    <ls_mseg>-matnr.
      PERFORM bdc_field       USING 'KOMG-CHARG(01)'
                                    <ls_mseg>-charg.
      READ TABLE gt_item ASSIGNING <gs_item> WITH KEY matnr = <ls_mseg>-matnr menge = <ls_mseg>-menge.
      IF sy-subrc = 0.
        PERFORM bdc_field       USING 'KONP-KBETR(01)'
                              <gs_item>-netpr_s.
      ENDIF.
      PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                    'INR'.
      PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                    '    1'.
      PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                    <ls_mseg>-meins.
      PERFORM bdc_field       USING 'RV13A-KRECH(01)'
                                    ''.
      PERFORM bdc_field       USING 'RV13A-DATAB(01)'
                                    lv_date.
      PERFORM bdc_field       USING 'RV13A-DATBI(01)'
                                    '31.12.9999'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1511'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.

      CALL TRANSACTION 'VK11'
          USING  bdcdata
          MODE   lv_ctumode
          UPDATE lv_cupdate
          MESSAGES INTO messtab.
      READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
      IF sy-subrc <> 0.
        READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
        IF sy-subrc = 0.
          gv_subrc = 0.
          gs_hdr-cond_rec = c_x.
        ELSE.
          gv_subrc = 4.
          CLEAR gs_hdr-cond_rec.
          MESSAGE 'Condition Recods Not Saved' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        gv_subrc = 4.
        CLEAR gs_hdr-cond_rec.
        MESSAGE ID <ls_messtab>-msgid TYPE <ls_messtab>-msgtyp NUMBER <ls_messtab>-msgnr WITH <ls_messtab>-msgv1 <ls_messtab>-msgv2 <ls_messtab>-msgv3 <ls_messtab>-msgv4.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_STICKER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM print_sticker CHANGING gv_subrc.
  CHECK gs_hdr-mblnr_101 IS NOT INITIAL AND gs_hdr-print IS INITIAL AND gs_hdr-cond_rec IS NOT INITIAL.
  SUBMIT ztp3_lable AND RETURN WITH p_mblnr = gs_hdr-mblnr_101 WITH p_prov = c_x.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_all.
  CLEAR : gt_item , gs_hdr.
ENDFORM.

FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.

FORM bdc_field USING fnam fval.
  IF fval IS NOT INITIAL.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    SHIFT bdcdata-fval LEFT DELETING LEADING space.
    APPEND bdcdata.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_stock.
  CALL SCREEN 9100.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate INPUT.
  SELECT mseg~mblnr INTO TABLE @DATA(lv_mblnr)
       FROM mseg AS mseg INNER JOIN stpo AS stpo ON stpo~idnrk = mseg~matnr
       INNER JOIN mchb AS mchb ON mchb~matnr = mseg~matnr AND mchb~charg = mseg~charg
       WHERE mchb~clabs > 0 AND mseg~werks = @gs_hdr-werks AND mseg~mblnr = @gs_hdr-mblnr_b_101 AND bwart = @c_101.
  IF sy-subrc <> 0.
    MESSAGE e089(zmsg_cls).
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form DISPLAY_STOCK_REPORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_stock_report.
  DATA :
    lt_exclude   TYPE ui_functions,
    lt_fieldcat  TYPE lvc_t_fcat,
*** Object References
    lr_container TYPE REF TO cl_gui_custom_container,
    lr_grid      TYPE REF TO cl_gui_alv_grid.

  SELECT
    mseg~mblnr,
    mseg~ebelp,
    mseg~matnr,
    makt~maktx,
    mseg~menge,
    mseg~meins
    INTO TABLE @gt_mseg
    FROM mseg AS mseg
    INNER JOIN makt AS makt ON makt~matnr = mseg~matnr
    WHERE mblnr = @gs_hdr-mblnr_b_101 AND mseg~bwart = @c_101.

  BREAK samburi.
*** Field Catlog
  lt_fieldcat = VALUE #(
                        ( fieldname = 'MBLNR'     tabname = 'GT_MSEG' scrtext_l = 'GR Num' outputlen = '10' )
                        ( fieldname = 'EBELP'     tabname = 'GT_MSEG' scrtext_l = 'Item' outputlen = '10' )
                        ( fieldname = 'MATNR'     tabname = 'GT_ITEM' scrtext_l = 'Product' outputlen = '10' )
                        ( fieldname = 'MAKTX'     tabname = 'GT_ITEM' scrtext_l = 'Product Des' outputlen = '40' )
                        ( fieldname = 'MENGE'     tabname = 'GT_ITEM' scrtext_l = 'Quantity' outputlen = '10'
                          ref_field = 'MENGE_S'     ref_table = 'ZINW_T_ITEM' decimals = '0' decimals_o = '0' )
                        ( fieldname = 'MEINS'     tabname = 'GT_ITEM' scrtext_l = 'UOM' outputlen = '5' )
                       ).


*** Creating Object Ref
  IF lr_container IS NOT BOUND.
    CREATE OBJECT lr_container  EXPORTING container_name = 'CONTAINER_9100'.
    CREATE OBJECT lr_grid EXPORTING i_parent = lr_container.
  ENDIF.

*  IF GT_EXCLUDE IS INITIAL.
*    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
*  ENDIF.

  IF lr_grid IS BOUND.
*** Displaying Table
    CALL METHOD lr_grid->set_table_for_first_display
      EXPORTING
        is_layout                     = gs_layo
        it_toolbar_excluding          = gt_exclude
      CHANGING
        it_outtab                     = gt_mseg
        it_fieldcatalog               = lt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.
ENDFORM.
