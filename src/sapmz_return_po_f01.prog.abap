*&---------------------------------------------------------------------*
*& Include          SAPMZ_RETURN_PO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data.
  SELECT SINGLE * FROM zinw_t_hdr INTO gs_inw_hdr WHERE qr_code = gs_hdr-qr_code.
  IF gv_po_create IS INITIAL.
    PERFORM create_po CHANGING gv_subrc.
    IF gv_ebeln IS NOT INITIAL.
********************START CHANGES BY BHAVANI DT-29/06/2019********************************
*      BREAK BREDDY.
      DATA : it_lines TYPE TABLE OF tline,
             wa_lines TYPE tline.
      wa_header-tdobject  = 'EKKO'.
      wa_header-tdname = gv_ebeln.
      wa_header-tdid  = 'F01'.
      wa_header-tdspras = 'E'.

      DATA :it_values TYPE TABLE OF dynpread,
            wa_values TYPE dynpread.
      CLEAR: wa_values, it_values.
      REFRESH it_values.
      wa_values-fieldname = 'DROP_DOWN'.
      APPEND wa_values TO it_values.

      CALL FUNCTION 'DYNP_VALUES_READ'
        EXPORTING
          dyname             = sy-repid
          dynumb             = sy-dynnr
          translate_to_upper = c_x
        TABLES
          dynpfields         = it_values.
      READ TABLE it_values ASSIGNING FIELD-SYMBOL(<ls_values>) INDEX 1.
      READ TABLE it_list ASSIGNING FIELD-SYMBOL(<ls_list>) WITH KEY key = <ls_values>-fieldvalue.
      IF sy-subrc = 0.
        wa_lines-tdline = <ls_list>-text .
        APPEND wa_lines TO it_lines.
      ENDIF.

      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          client          = sy-mandt
          header          = wa_header
          insert          = 'I'
          savemode_direct = 'X'
        TABLES
          lines           = it_lines
        EXCEPTIONS
          id              = 1
          language        = 2
          name            = 3
          object          = 4
          OTHERS          = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.
**********************END CHANGES BY BHAVANI 29/06/2019**************

  ENDIF.
  IF gv_subrc IS INITIAL AND gv_goods_mvt IS INITIAL.
    PERFORM goods_return CHANGING gv_subrc.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCAN_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1          text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM scan_batch.
  DATA : ls_item  TYPE ty_item,
         lv_netpr TYPE menge_d.
  CHECK gs_hdr-charg IS NOT INITIAL.
  BREAK samburi.
  READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<ls_item>) WITH KEY charg = gs_hdr-charg.
  IF sy-subrc = 0.
    READ TABLE gt_item_t ASSIGNING FIELD-SYMBOL(<ls_item_t>) WITH KEY charg = gs_hdr-charg.
    IF sy-subrc = 0.
*** Updating Quantity for existing Batch
      IF <ls_item>-menge LE <ls_item>-menge_s.
*        MESSAGE 'Batch quantity exceeded' TYPE 'S' DISPLAY LIKE 'E'.
        MESSAGE s029(zmsg_cls) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      <ls_item>-menge_s  = <ls_item>-menge_s + 1.
      <ls_item>-netwr    = <ls_item>-netpr * <ls_item>-menge_s.
      <ls_item>-bprei_gp = <ls_item_t>-bprei_gp * <ls_item>-menge_s.
      <ls_item>-bprei_t  = <ls_item>-bprei_gp + <ls_item>-netwr.
    ENDIF.
  ELSE.
    SELECT
      matdoc~mblnr,
      matdoc~mjahr,
      matdoc~zeile,
      matdoc~charg,
      matdoc~werks,
      matdoc~lgort,
      matdoc~meins,
      ekpo~mwskz,
      zinw_t_item~ebeln,
      zinw_t_item~ebelp,
      zinw_t_item~netpr_gp,
      zinw_t_item~netpr_p,
      zinw_t_item~menge_p,
      zinw_t_item~matnr,
      zinw_t_item~discount,
      zinw_t_hdr~qr_code,
      zinw_t_hdr~lifnr,
      zinw_t_hdr~name1,
      zinw_t_hdr~tat_po
      INTO TABLE @DATA(lt_data)
      FROM matdoc AS matdoc
      INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr = matdoc~mblnr
      INNER JOIN zinw_t_item AS zinw_t_item ON zinw_t_item~ebeln = matdoc~ebeln
      INNER JOIN ekpo AS ekpo ON zinw_t_item~ebeln = ekpo~ebeln AND zinw_t_item~matnr = ekpo~matnr
      AND zinw_t_item~ebelp = matdoc~ebelp AND zinw_t_item~matnr = matdoc~matnr
      WHERE matdoc~charg = @gs_hdr-charg.

    SORT lt_data BY charg qr_code matnr ebeln ebelp.
    DELETE ADJACENT DUPLICATES FROM lt_data COMPARING charg qr_code matnr ebeln ebelp.
*** Validating Batch from Same Batch
    IF gs_hdr-qr_code IS NOT INITIAL AND lt_data IS NOT INITIAL .
      READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY qr_code = gs_hdr-qr_code.
      IF sy-subrc <> 0.
        MESSAGE s023(zmsg_cls) WITH gs_hdr-charg gs_hdr-qr_code DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
*** Adding Batch
    LOOP AT lt_data ASSIGNING <ls_data>.
      IF gs_hdr-qr_code IS INITIAL.
        gs_hdr-qr_code = <ls_data>-qr_code.
        gs_hdr-mblnr = <ls_data>-mblnr.
        gs_hdr-ebeln = <ls_data>-ebeln.
        gs_hdr-lifnr = <ls_data>-lifnr.
        gs_hdr-name1 = <ls_data>-name1.
      ENDIF.
      DESCRIBE TABLE gt_item LINES DATA(lv_lines).
      ls_item-ebelp     = ( lv_lines + 1 ) * 10.
      ls_item-charg     = <ls_data>-charg.
      ls_item-matnr     = <ls_data>-matnr.
      ls_item-menge     = <ls_data>-menge_p .
      ls_item-menge_s   = 1.
      ls_item-meins     = <ls_data>-meins . " EA'.
*      ls_item-netwr     = ls_item-netpr = <ls_data>-netpr_p .
      ls_item-actprice   = <ls_data>-netpr_p .
********************ADDED BY SKN ON 21.02.2020**************************************************************
      IF <ls_data>-discount IS NOT INITIAL.
        CLEAR lv_netpr.
        lv_netpr  = ( ( <ls_data>-netpr_p * <ls_data>-discount ) / 100 ) * -1.
        ls_item-netwr =  ls_item-netpr =  ( <ls_data>-netpr_p  - lv_netpr ).
        CLEAR lv_netpr.
        ls_item-disc     = <ls_data>-discount.
      ELSE.
        ls_item-netwr =  ls_item-netpr =   <ls_data>-netpr_p.

      ENDIF.

****************************************************************************************************
      ls_item-waers     = <ls_data>-werks.
      ls_item-bprei_gp  = <ls_data>-netpr_gp / <ls_data>-menge_p.
      ls_item-bprei_t   = ls_item-netpr * ls_item-menge_s + ls_item-bprei_gp.
      ls_item-lgort     = <ls_data>-lgort.
      ls_item-werks     = <ls_data>-werks.
      ls_item-mwskz     = <ls_data>-mwskz.
      APPEND ls_item TO gt_item.
      APPEND ls_item TO gt_item_t.
      CLEAR : ls_item.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv.
  DATA:
    ls_fc   TYPE  lvc_s_fcat,
    it_sort TYPE lvc_t_sort,
    ls_sort TYPE lvc_s_sort,
    lv_pos  TYPE i VALUE 1.

  CREATE OBJECT container EXPORTING container_name = mycontainer.
  CREATE OBJECT grid EXPORTING i_parent = container.

  IF gt_fieldcat IS INITIAL.
    gs_layo-frontend   = c_x.
    gs_layo-zebra      = c_x.

    ls_fc-col_pos   = lv_pos.
    ls_fc-fieldname = 'MATNR'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'SST Code'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'CHARG'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-scrtext_l = 'Batch'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'MENGE_S'.
    ls_fc-ref_field = 'MENGE'.
    ls_fc-ref_table = 'ZINW_T_ITEM'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Quantity'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'MEINS'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'UOM'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'NETPR'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Pur Price'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'NETWR'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Amount'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'BPREI_GP'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'GST Amount'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'BPREI_T'.
    ls_fc-tabname   = 'GT_ITEM'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Total Amount'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

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
***  Refresh
    IF grid IS BOUND.
      CALL METHOD grid->refresh_table_display.
    ENDIF.
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


FORM create_po CHANGING gv_subrc.
  IF gt_item IS NOT INITIAL.
    SELECT SINGLE * FROM ekko INTO @DATA(ls_ekko) WHERE ebeln = @gs_hdr-ebeln.
    CHECK sy-subrc IS INITIAL.
    header-comp_code    = ls_ekko-bukrs.
    header-creat_date   = sy-datum.
    header-vendor       = ls_ekko-lifnr.
*    HEADER-DOC_TYPE     = LS_EKKO-BSART.
    header-doc_type     = c_bsart.
    header-langu        = sy-langu.
    header-purch_org    = ls_ekko-ekorg.
    header-pur_group    = ls_ekko-ekgrp.

    headerx-comp_code   = c_x.
    headerx-creat_date  = c_x.
    headerx-vendor      = c_x.
    headerx-doc_type    = c_x.
    headerx-langu       = c_x.
    headerx-purch_org   = c_x.
    headerx-pur_group   = c_x.

    REFRESH item.
    REFRESH itemx.
    LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
      item-po_item   = <ls_item>-ebelp.
      item-material  = <ls_item>-matnr.
      item-plant     = <ls_item>-werks.
      item-quantity  = <ls_item>-menge_s.
      item-po_unit   = <ls_item>-meins.
*      item-net_price = <ls_item>-netpr.
      item-net_price = <ls_item>-actprice.
      item-stge_loc  = <ls_item>-lgort.
      item-ret_item  = c_x.
      item-tax_code  = <ls_item>-mwskz.

      itemx-po_item     = <ls_item>-ebelp.
      itemx-material    = c_x.
      itemx-plant       = c_x.
      itemx-quantity    = c_x.
      itemx-po_unit     = c_x.
      itemx-net_price   = c_x.
      itemx-stge_loc    = c_x.
      itemx-ret_item    = c_x.
      itemx-tax_code    = c_x.

****************************************************************
      SELECT SINGLE xchpf FROM mara INTO @DATA(lv_xchpf) WHERE matnr = @item-material.
      IF lv_xchpf IS NOT INITIAL.
        item-batch = <ls_item>-charg.
        itemx-batch = c_x.
      ENDIF.


      APPEND item.
      APPEND itemx .
      CLEAR : itemx , item.

*******************************ADDED BY SKN ON 21.02.2020*****************************
      wa_pocond-itm_number = <ls_item>-ebelp.
      wa_pocond-cond_type  = 'PBXX'.
      wa_pocond-cond_unit = <ls_item>-meins.
      wa_pocond-calctypcon = 'C' .
      wa_pocond-cond_value = <ls_item>-actprice / 10.
      wa_pocond-change_id  = 'U'.
      APPEND wa_pocond TO it_pocond.
      CLEAR wa_pocond.

      wa_pocondx-itm_number = <ls_item>-ebelp.
      wa_pocondx-itm_numberx = c_x.
      wa_pocondx-cond_type  = c_x.
      wa_pocondx-cond_value = c_x.
      wa_pocondx-calctypcon = c_x.
      wa_pocondx-cond_unit  = c_x.
      wa_pocondx-change_id  = c_x.
      APPEND wa_pocondx TO it_pocondx.
      CLEAR wa_pocondx.


*IF <ls_item>-disc IS NOT INITIAL.
      wa_pocond-itm_number = <ls_item>-ebelp.
      wa_pocond-cond_type  = 'ZDS1'.
      wa_pocond-cond_unit =  '%'.
      wa_pocond-calctypcon = 'A' .
      wa_pocond-cond_value = <ls_item>-disc.
      wa_pocond-change_id  = 'U'.
      APPEND wa_pocond TO it_pocond.
      CLEAR wa_pocond.

      wa_pocondx-itm_number = <ls_item>-ebelp.
      wa_pocondx-itm_numberx = c_x.
      wa_pocondx-cond_type  = c_x.
      wa_pocondx-cond_value = c_x.
      wa_pocondx-calctypcon = c_x.
      wa_pocondx-cond_unit  = c_x.
      wa_pocondx-change_id  = c_x.
      APPEND wa_pocondx TO it_pocondx.
      CLEAR wa_pocondx.
* ENDIF.
****************************************************************************************

    ENDLOOP.
*** Return PO Creation
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = header
        poheaderx        = headerx
*       NO_PRICE_FROM_PO = C_X
      IMPORTING
        exppurchaseorder = gv_ebeln
      TABLES
        return           = return
        poitem           = item
        poitemx          = itemx
        pocond           = it_pocond
        pocondx          = it_pocondx.
    READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_x.
      gv_mod = c_d.
      gv_po_create = c_x.
*** Update Inward Header Table
      gs_inw_hdr-return_po  = gv_ebeln.
      MODIFY zinw_t_hdr FROM gs_inw_hdr.
      MESSAGE s022(zmsg_cls) WITH gv_ebeln.
    ELSE.
      gv_subrc = 4.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
      <ls_ret>-message_v3 <ls_ret>-message_v4.
    ENDIF.
  ENDIF.
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
  IF gv_mod = c_d.
    LOOP AT SCREEN.
      screen-name = 'GS_HDR-CHARG'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      screen-name = 'GS_HDR-CHARG'.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_RETURN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM goods_return CHANGING gv_subrc.
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

  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @gv_ebeln.
  SELECT DISTINCT ebeln,ebelp,charg FROM eket INTO TABLE @DATA(it_ekbe) FOR ALL ENTRIES IN
                  @lt_ekpo WHERE ebeln = @lt_ekpo-ebeln AND ebelp = @lt_ekpo-ebelp AND charg <> ' '.

*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum.
*  ls_gmvt_header-pstng_date = '20200229'.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.

*** Looping the PO details.
  LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_item>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS
    ls_gmvt_item-material  = <ls_item>-matnr.
    ls_gmvt_item-move_type = c_101.
    ls_gmvt_item-po_number = <ls_item>-ebeln.
    ls_gmvt_item-po_item   = <ls_item>-ebelp.
    ls_gmvt_item-entry_qnt = <ls_item>-menge.
    ls_gmvt_item-entry_uom = <ls_item>-meins.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-mvt_ind   = c_mvt_ind_b.
    ls_gmvt_item-move_reas = c_02.

    READ TABLE it_ekbe INTO DATA(wa_ekbe) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    IF sy-subrc = 0.
      ls_gmvt_item-batch     = wa_ekbe-charg.
    ENDIF.

    READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<ls_item_t>) WITH KEY ebelp = <ls_item>-ebelp matnr = <ls_item>-matnr .
    IF sy-subrc = 0.
      IF ls_gmvt_item-batch IS INITIAL.
        ls_gmvt_item-batch = <ls_item_t>-charg.
      ENDIF.
      ls_gmvt_item-stge_loc = <ls_item_t>-lgort.
      ls_gmvt_item-plant = <ls_item_t>-werks.
    ENDIF.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
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
    gv_goods_mvt = c_x.
    gv_mblnr_n = ls_gmvt_headret-mat_doc.
    gv_mod  = c_d.
*** Update Inward Header Table
    gs_inw_hdr-return_po  = gv_ebeln.
    gs_inw_hdr-mblnr_161  = gv_mblnr_n.
*** Status Update
    ls_status-inwd_doc     = gs_inw_hdr-inwd_doc.
    ls_status-qr_code      = gs_inw_hdr-qr_code.
    ls_status-status_field = c_se_code.
    ls_status-created_by   = sy-uname.
    ls_status-created_date = sy-datum.
    ls_status-created_time = sy-uzeit.
    IF gs_inw_hdr-tat_po IS NOT INITIAL.
      ls_status-status_value = c_se04.
      ls_status-description  = 'Shortage & Excess'.
      gs_inw_hdr-soe = c_04.
    ELSE.
      ls_status-status_value = c_se02.
      ls_status-description  = 'Shortage'.
      gs_inw_hdr-soe = c_02.
    ENDIF.
    MODIFY zinw_t_hdr FROM gs_inw_hdr.
    MODIFY zinw_t_status FROM ls_status.
    CLEAR : ls_status.

  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEBIT_NOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM debit_note CHANGING gv_subrc.
  DATA :
    headerdata       TYPE bapi_incinv_create_header,
    invoicedocnumber TYPE bapi_incinv_fld-inv_doc_no,
    fiscalyear       TYPE bapi_incinv_fld-fisc_year,
    ls_itemdata      TYPE bapi_incinv_create_item,
    itemdata         TYPE STANDARD TABLE OF bapi_incinv_create_item,
    return           TYPE STANDARD TABLE OF bapiret2,
    lv_tax_amount    TYPE netpr,
    ls_status        TYPE zinw_t_status.

*** Header Data
*  CHECK SY-UNAME = 'SAMBURI'.
  IF gv_ebeln IS NOT INITIAL.
    CLEAR   : headerdata.
    REFRESH : itemdata.

    SELECT ekko~ebeln,
           ekko~bukrs,
           ekko~waers,
           ekpo~ebelp,
           ekpo~mwskz,
           ekpo~menge,
           ekpo~meins,
           ekpo~netwr,
           ekpo~brtwr,
           matdoc~mblnr,
           matdoc~mjahr,
           matdoc~zeile,
           matdoc~gsber,
           a003~knumh,
           a003~kschl,
           konp~kbetr
           INTO TABLE @DATA(lt_debit)
           FROM ekko AS ekko
           INNER JOIN ekpo AS ekpo ON ekpo~ebeln = ekko~ebeln
           INNER JOIN matdoc AS matdoc ON matdoc~ebeln =  ekpo~ebeln AND matdoc~ebelp = ekpo~ebelp
           LEFT  OUTER JOIN a003 AS a003 ON a003~mwskz =  ekpo~mwskz AND a003~kschl IN ( 'JIIG' , 'JICG' , 'JISG' )
           LEFT  OUTER JOIN konp AS konp ON konp~knumh =  a003~knumh
           WHERE ekko~ebeln = @gv_ebeln.

    headerdata-doc_date     = sy-datum.
    headerdata-pstng_date   = sy-datum.
*    headerdata-pstng_date   = '20200229'.
    headerdata-bline_date   = sy-datum.
    headerdata-calc_tax_ind = c_x.
    headerdata-ref_doc_no   = gs_inw_hdr-inwd_doc.

*** Item Data
    LOOP AT lt_debit ASSIGNING FIELD-SYMBOL(<ls_debit>).
      ls_itemdata-invoice_doc_item  = sy-tabix.
      ls_itemdata-po_number         = <ls_debit>-ebeln.
      ls_itemdata-po_item           = <ls_debit>-ebelp.
      ls_itemdata-ref_doc           = <ls_debit>-mblnr.
      ls_itemdata-ref_doc_year      = <ls_debit>-mjahr.
      ls_itemdata-ref_doc_it        = <ls_debit>-zeile.
      ls_itemdata-tax_code          = <ls_debit>-mwskz.
      ls_itemdata-item_amount       = <ls_debit>-brtwr.
      ls_itemdata-quantity          = <ls_debit>-menge.
      ls_itemdata-po_unit           = <ls_debit>-meins.
      headerdata-comp_code          = <ls_debit>-bukrs.
      headerdata-currency           = <ls_debit>-waers.

*** Tax Calculation
      IF <ls_debit>-kschl = 'JIIG'.
        lv_tax_amount = ls_itemdata-item_amount + ( ( ls_itemdata-item_amount * <ls_debit>-kbetr ) / 1000 ) .
      ELSEIF <ls_debit>-kschl = 'JISG' OR <ls_debit>-kschl = 'JICG'.
        lv_tax_amount = ls_itemdata-item_amount + ( ( ls_itemdata-item_amount * <ls_debit>-kbetr ) / 500 ) .
      ENDIF.
      ADD  lv_tax_amount TO headerdata-gross_amount.
      APPEND ls_itemdata TO itemdata.
      CLEAR : ls_itemdata.
    ENDLOOP.

*** Create Debit Note
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = headerdata                  " Header Data in Incoming Invoice (Create)
      IMPORTING
        invoicedocnumber = invoicedocnumber            " Document Number of an Invoice Document
        fiscalyear       = fiscalyear                  " Fiscal Year
      TABLES
        itemdata         = itemdata                    " Item Data in Incoming Invoice
        return           = return.                     " Return Messages

    READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_x.
      gv_d_note = c_x.
      gv_vbeln = invoicedocnumber.
*** Update Inward Header Table
      gs_inw_hdr-return_po  = gv_ebeln.
      gs_inw_hdr-mblnr_161  = gv_mblnr_n.
      gs_inw_hdr-debit_note = invoicedocnumber.
*** Status Update
      ls_status-inwd_doc     = gs_inw_hdr-inwd_doc.
      ls_status-qr_code      = gs_inw_hdr-qr_code.
      ls_status-status_field = c_se_code.
      ls_status-created_by   = sy-uname.
      ls_status-created_date = sy-datum.
      ls_status-created_time = sy-uzeit.
      IF gs_inw_hdr-tat_po IS NOT INITIAL.
        ls_status-status_value = c_se04.
        ls_status-description  = 'Shortage & Excess'.
        gs_inw_hdr-soe = c_04.
      ELSE.
        ls_status-status_value = c_se02.
        ls_status-description  = 'Shortage'.
        gs_inw_hdr-soe = c_02.
      ENDIF.
      MODIFY zinw_t_hdr FROM gs_inw_hdr.
      MODIFY zinw_t_status FROM ls_status.
      CLEAR : ls_status.

      MESSAGE | { invoicedocnumber } Successfully Debit Note Created | TYPE 'S'.
    ELSE.
*** Roll Back if any error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
      <ls_ret>-message_v3 <ls_ret>-message_v4.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validations .
  CHECK gs_hdr-charg IS NOT INITIAL.
*** Batch
  SELECT SINGLE
     zinw_t_item~matnr,
     zinw_t_hdr~qr_code,
     zinw_t_hdr~return_po,
     zinw_t_hdr~tat_po
     INTO @DATA(ls_data)
     FROM mseg AS mseg
     INNER JOIN zinw_t_hdr AS zinw_t_hdr ON ( zinw_t_hdr~mblnr = mseg~mblnr or zinw_t_hdr~mblnr_103 = mseg~mblnr )
     INNER JOIN zinw_t_item AS zinw_t_item ON zinw_t_item~ebeln = mseg~ebeln
     AND zinw_t_item~ebelp = mseg~ebelp AND zinw_t_item~matnr = mseg~matnr
     WHERE mseg~charg = @gs_hdr-charg AND zinw_t_hdr~qr_code = @gs_hdr-qr_code and zinw_t_hdr~status = @c_04.

*** EAN
  IF ls_data-return_po IS NOT INITIAL.
    MESSAGE e040(zmsg_cls) WITH ls_data-return_po.
  ENDIF.

  IF ls_data-tat_po IS NOT INITIAL.
    SELECT SINGLE ebeln FROM ekpo INTO @DATA(ls_ekpo) WHERE ebeln = @ls_data-tat_po AND matnr = @ls_data-matnr.
    IF sy-subrc IS INITIAL.
      MESSAGE e041(zmsg_cls).
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_QR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_qr.
  CHECK gs_hdr-qr_code IS NOT INITIAL.
  SELECT SINGLE * FROM zinw_t_hdr INTO gs_inw_hdr WHERE qr_code = gs_hdr-qr_code AND status = c_04 AND return_po EQ space.
  IF sy-subrc <> 0.
***    Invalid QR Code
    MESSAGE e003(zmsg_cls).
  ENDIF.
ENDFORM.
