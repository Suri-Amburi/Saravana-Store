*&---------------------------------------------------------------------*
*& Include          ZMM_SCANNING_QR_F01
*&---------------------------------------------------------------------*
FORM do_gpro.
  DATA : ls_status TYPE zinw_t_status.
  DATA : lt_status TYPE TABLE OF zinw_t_status.
  CLEAR : ls_status.
  DATA : lv_error(1).
  REFRESH : lt_status.
*** Retrieve PO documents from Header table
  CLEAR : wa_hdr.
  SELECT SINGLE * FROM zinw_t_hdr INTO wa_hdr WHERE qr_code = p_qr.
  IF sy-subrc <> 0.
*** Invalid QR Code
    lv_error = c_e.
    MESSAGE s024(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

***   GRPO Already Posted
  IF wa_hdr-status GE c_04.
    lv_error = c_e.
    MESSAGE s072(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ELSE.
    SELECT SINGLE bsart FROM ekko INTO @DATA(lv_bsart) WHERE ebeln = @wa_hdr-ebeln.
    CASE lv_bsart.
      WHEN c_ztat.
***    Nothing
      WHEN c_zlop.
        IF wa_hdr-status = c_03.
          lv_error = c_e.
          MESSAGE s080(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      WHEN c_zvos OR c_zvlo.
***   For Vessels Group use the Transaction : ZTP3_V
        lv_error = c_e.
        MESSAGE s077(zmsg_cls) DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      WHEN c_zosp.
***   Gate In not yet done
        IF wa_hdr-status < c_02.
          lv_error = c_e.
          MESSAGE s081(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
    ENDCASE.
  ENDIF.

  IF wa_hdr IS NOT INITIAL AND lv_error IS INITIAL.
*** For Fruits & Veitables
    SELECT SINGLE klah~class
    INTO @DATA(lv_group)
    FROM klah AS klah
    INNER JOIN kssk AS kssk  ON kssk~clint = klah~clint
    INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
    INNER JOIN zinw_t_item AS zinw_t_item  ON klah1~class = zinw_t_item~matkl
    INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~qr_code = zinw_t_item~qr_code
    WHERE klah~klart = '026' AND zinw_t_item~qr_code = @wa_hdr-qr_code.

*** Retrieve PO document details from Item (item) table
    TRY .
        zcl_grpo=>get_inw_item(
          EXPORTING
            i_qr          = p_qr
          IMPORTING
            t_item        = lt_item ).
      CATCH cx_amdp_error.
    ENDTRY.
  ELSE.
    MESSAGE s003(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*** Fill the bapi Header structure details

IF p_budat IS NOT INITIAL.
    wa_gmvt_header-pstng_date = p_budat.
ELSE.
  wa_gmvt_header-pstng_date = sy-datum.
ENDIF.

  wa_gmvt_header-doc_date   = sy-datum.
  wa_gmvt_header-pr_uname   = sy-uname.
  wa_gmvt_header-ref_doc_no = wa_hdr-qr_code.
*** Looping the PO details.
  LOOP AT lt_item INTO wa_item WHERE menge_s IS NOT INITIAL.

*** FILL THE BAPI ITEM STRUCTURE DETAILS
    IF strlen( wa_item-matnr ) > 18.
      wa_gmvt_item-material_long  = wa_item-matnr.
    ELSE.
      wa_gmvt_item-material  = wa_item-matnr.
    ENDIF.
    wa_gmvt_item-item_text = wa_item-maktx.
    wa_gmvt_item-plant     = wa_item-werks.
    wa_gmvt_item-stge_loc  = wa_item-lgort.

*** For Doc type ZLOP - 103
    IF lv_bsart = c_zlop.
      wa_gmvt_item-move_type = c_103.
    ELSE.
      wa_gmvt_item-move_type = c_101.
    ENDIF.
*** For F&V , Consumbles
    IF lv_group = c_fv OR lv_group =  c_consumables.
      wa_gmvt_item-move_type = c_101.
    ENDIF.
    wa_gmvt_item-po_number = wa_item-ebeln.
    wa_gmvt_item-po_item   = wa_item-ebelp.
    wa_gmvt_item-entry_qnt = wa_item-menge_s.
    wa_gmvt_item-entry_uom = wa_item-meins.
    wa_gmvt_item-prod_date = sy-datum.
    wa_gmvt_item-mvt_ind   = c_mvt_ind_b.

    APPEND wa_gmvt_item TO lt_gmvt_item.
    CLEAR wa_gmvt_item.
  ENDLOOP.
*  BREAK-POINT.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = wa_gmvt_header
      goodsmvt_code    = c_mvt_01
    IMPORTING
      goodsmvt_headret = wa_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING <ls_bapiret> WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.

    gv_mat_doc =  wa_det-mblnr = wa_gmvt_headret-mat_doc .
    gv_doc_year = wa_det-mjahr = wa_gmvt_headret-doc_year.
    wa_det-ebeln = wa_hdr-ebeln.
    wa_det-message = 'GR Posted Successfully Posted'.
    wa_det-msg_type = 'S'.
    APPEND wa_det TO lt_det.
    CLEAR : wa_det, ls_status.

*** Updating Material Doc in Indw Header
*** For Doc type ZLOP - 103
*** Status Update
    ls_status-inwd_doc     = wa_hdr-inwd_doc.
    ls_status-qr_code      = wa_hdr-qr_code.
    ls_status-status_field = c_qr_code.
    ls_status-created_by   = sy-uname.
    ls_status-created_date = sy-datum.
    ls_status-created_time = sy-uzeit.

    IF lv_bsart = c_zlop .
      IF lv_group = c_fv OR lv_group = c_consumables .
        wa_hdr-mblnr  = wa_gmvt_headret-mat_doc.
        wa_hdr-status = c_04.              " GRPO DONE
        wa_hdr-soe    = c_01.              " Matched
        ls_status-status_value = c_qr04.
        ls_status-description  = 'GR Posted'.
      ELSE.
        wa_hdr-mblnr_103 = wa_gmvt_headret-mat_doc.
        wa_hdr-status = c_03.              " Local GRPO DONE
        ls_status-status_value = c_qr03.
        ls_status-description  = 'Local GR Posted'.
      ENDIF.
      APPEND ls_status TO lt_status.
    ELSEIF lv_bsart = c_ztat.
      wa_hdr-mblnr  = wa_gmvt_headret-mat_doc.
      wa_hdr-status = c_04.              " GRPO DONE
      wa_hdr-soe    = c_01.              " Matched
      ls_status-status_value = c_qr04.
      ls_status-description  = 'GR Posted'.
      APPEND ls_status TO lt_status.
***  For SOE Update Status
      ls_status-status_field = c_soe.
      ls_status-status_value = c_se01.
      ls_status-description  = 'Matched'.
      APPEND ls_status TO lt_status.
    ELSE.
      wa_hdr-mblnr  = wa_gmvt_headret-mat_doc.
      wa_hdr-status = c_04.              " GRPO DONE
      ls_status-status_value = c_qr04.
      ls_status-description  = 'GR Posted'.
      APPEND ls_status TO lt_status.
    ENDIF.

    MODIFY zinw_t_hdr FROM wa_hdr.
    MODIFY zinw_t_status FROM TABLE lt_status.
    COMMIT WORK.

*** GRPO - Summery Mail to Agent    commented temporarily as per requirement
*    CALL FUNCTION 'ZFM_AGENT_VENDOR_MAIL'
*      EXPORTING
*        lv_qr_code = wa_hdr-qr_code       " QR Code
*        grpo       = c_x                  " GRPO SUMMARY
*        agent      = c_x.                 " Single-Character Flag

***********changes added by bhavani 07.03.2019 ENTRYSHEET CREATION******************
*    PERFORM entrysheet.
**************end changes by bhavani 07.03.2019******************
  ELSE.
    wa_det-mblnr    = wa_hdr-mblnr = wa_gmvt_headret-mat_doc .
    wa_det-mjahr    = wa_gmvt_headret-doc_year.
    wa_det-ebeln    = wa_hdr-ebeln.
    wa_det-message  = <ls_bapiret>-message.
    wa_det-msg_type = <ls_bapiret>-type.
    APPEND wa_det TO lt_det.
    CLEAR wa_det.
  ENDIF.
ENDFORM.

*** Lable Printing
FORM print_lables.
*** Fetching Batches
  DATA: lt_con_rec TYPE TABLE OF zcon_rec_t,
        wa_con_rec TYPE zcon_rec_t.
  FIELD-SYMBOLS : <ls_item> TYPE zinw_t_item.
  IF lt_det IS NOT INITIAL.
    SELECT  matdoc~mblnr,
            matdoc~matnr,
            matdoc~ebeln,
            matdoc~ebelp,
            matdoc~charg,
            mara~ean11
            FROM  matdoc AS matdoc
            LEFT OUTER JOIN mara AS mara ON mara~matnr  = matdoc~matnr AND mara~numtp = @c_uc
            INTO TABLE @DATA(lt_matdoc) FOR ALL ENTRIES IN @lt_det WHERE matdoc~mblnr = @lt_det-mblnr AND matdoc~mjahr = @lt_det-mjahr.

    LOOP AT lt_matdoc ASSIGNING FIELD-SYMBOL(<ls_matdoc>).
      READ TABLE lt_item ASSIGNING <ls_item> WITH KEY matnr = <ls_matdoc>-matnr ebeln = <ls_matdoc>-ebeln ebelp = <ls_matdoc>-ebelp.
      IF sy-subrc = 0.
        wa_con_rec-mandt   = sy-mandt.
        wa_con_rec-kschl   = c_zkp0.
        wa_con_rec-werks   = <ls_item>-werks.
        wa_con_rec-vrkme   = <ls_item>-meins.
        wa_con_rec-matnr   = <ls_item>-matnr.
        wa_con_rec-mat_cat = <ls_item>-mat_cat.
        wa_con_rec-kbetr   = <ls_item>-netpr_s.
        wa_con_rec-konwa   = 'INR'.
        wa_con_rec-batch   = <ls_matdoc>-charg.
        wa_con_rec-ean11   = <ls_matdoc>-ean11.
        APPEND wa_con_rec TO lt_con_rec.
        CLEAR : wa_con_rec.
      ENDIF.
    ENDLOOP.
    MODIFY zcon_rec_t FROM TABLE lt_con_rec.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_log .
  DATA:
    wlayo	TYPE lvc_s_layo,
    wfcat TYPE lvc_s_fcat,
    tfcat TYPE lvc_t_fcat,
    wvari TYPE disvariant.

  wvari-report    = sy-repid.
  wvari-username  = sy-uname.

  wlayo-zebra       = abap_true.
  wlayo-cwidth_opt  = abap_true.
  wlayo-sel_mode    = 'D'.

*** Field Catlog
  REFRESH tfcat.
  wfcat-fieldname = 'MSG_TYPE'.
  wfcat-scrtext_l = 'Message Type'.
  wfcat-ref_table = 'LT_DET'.
  wfcat-no_zero = c_x.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'EBELN'.
  wfcat-scrtext_l = 'Purchase Order'.
  wfcat-ref_table = 'LT_DET'.
  wfcat-no_zero = c_x.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'MBLNR'.
  wfcat-scrtext_l = 'Doc Num'.
  wfcat-ref_table = 'LT_DET'.
  wfcat-no_zero = c_x.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'MESSAGE'.
  wfcat-scrtext_l = 'Message'.
  wfcat-ref_table = 'LT_DET'.
  wfcat-no_zero = c_x.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

*** Dispalying ALV Report
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid          " Name of the calling program
      i_callback_pf_status_set = 'PF_STATUS'       " Set EXIT routine to status
      i_callback_user_command  = 'USER_COMMAND'    " EXIT routine for command handling
      is_layout_lvc            = wlayo
      it_fieldcat_lvc          = tfcat
      is_variant               = wvari
      i_save                   = 'U'
    TABLES
      t_outtab                 = lt_det
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.

FORM pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTANDARD' EXCLUDING rt_extab .
ENDFORM. "Set_pf_status
FORM user_command USING r_ucomm TYPE sy-ucomm rs_selfield TYPE slis_selfield.
  DATA(ok_code) = r_ucomm.
  CLEAR : r_ucomm.
  CASE ok_code.
    WHEN c_back OR c_cancel.
      LEAVE TO SCREEN 0.
    WHEN c_exit.
      LEAVE PROGRAM.
    WHEN c_label.
      PERFORM grpo_print_lables.
    WHEN c_grpo_s.
      PERFORM print_grpo_summery.
    WHEN c_grpo_p.
      PERFORM print_grpo_price_list.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GRPO_PRINT_LABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grpo_print_lables .
*** Printing Lables
  IF wa_hdr-lable_print IS INITIAL.
*    PERFORM TP3_PRINT_STCKER IN PROGRAM ZTP3_LABLE USING GV_MAT_DOC C_X GV_DOC_YEAR.
    SUBMIT ztp3_lable AND RETURN WITH p_mblnr = gv_mat_doc WITH p_tp3 = c_x WITH p_mjahr = gv_doc_year.
    IF sy-subrc = 0 AND sy-ucomm = 'PRNT'.
***   Updating Printing status
      wa_hdr-lable_print = c_x.
      wa_hdr-l_printed_by = sy-uname.
      MODIFY zinw_t_hdr FROM wa_hdr.
    ENDIF.
  ELSE.
    MESSAGE s026(zmsg_cls) WITH wa_hdr-l_printed_by DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_GRPO_SUMMERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_grpo_summery.
****************calling smartform*************************
  CHECK p_qr IS NOT INITIAL.
  IF wa_hdr-grpo_s IS INITIAL.
    DATA : form_name TYPE rs38l_fnam.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZMM_GRPO_FORM'
      IMPORTING
        fm_name            = form_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    CALL FUNCTION form_name
      EXPORTING
        lv_qr_code       = p_qr
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc = 0 AND sy-ucomm = 'PRNT'.
*** Updating Printing status
      wa_hdr-grpo_s = c_x.
      wa_hdr-grpo_s_printed_by = sy-uname.
      MODIFY zinw_t_hdr FROM wa_hdr.
    ENDIF.
  ELSE.
    MESSAGE s026(zmsg_cls) WITH wa_hdr-l_printed_by DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_GRPO_PRICE_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_grpo_price_list .
  IF wa_hdr-grpo_p IS INITIAL.
    PERFORM grpo_price_form IN PROGRAM zmm_grpo_price_rep USING p_qr.
    IF sy-subrc = 0 AND sy-ucomm = 'PRNT'.
***    Updating Printing status
      wa_hdr-grpo_p = c_x.
      wa_hdr-grpo_p_printed_by = sy-uname.
      MODIFY zinw_t_hdr FROM wa_hdr.
    ENDIF.
  ELSE.
    MESSAGE s026(zmsg_cls) WITH wa_hdr-l_printed_by DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENTRYSHEET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM entrysheet .
  DATA:
    bapi_esll        LIKE bapiesllc OCCURS 1 WITH HEADER LINE,
    po_items         TYPE bapiekpo OCCURS 0 WITH HEADER LINE,
    po_services      TYPE bapiesll OCCURS 0 WITH HEADER LINE,
    bapi_return_po   TYPE TABLE OF bapiret2,
    wa_header        TYPE bapiessrc,
    i_return         TYPE TABLE OF bapiret2,
    s_return         TYPE  bapiret2,
    serial_no        LIKE bapiesknc-serial_no,
    line_no          LIKE bapiesllc-line_no,
    ws_entrysheet_no TYPE  bapiessr-sheet_no,
    wa_return        TYPE ty_det,
    wa_po_header     TYPE bapiekkol.

  SELECT SINGLE * FROM zinw_t_hdr INTO wa_hdr WHERE qr_code = p_qr.
  IF wa_hdr-service_po IS NOT INITIAL.
    CALL FUNCTION 'BAPI_PO_GETDETAIL'
      EXPORTING
        purchaseorder    = wa_hdr-service_po
        items            = 'X'
        services         = 'X'
      IMPORTING
        po_header        = wa_po_header
      TABLES
        po_items         = po_items
        po_item_services = po_services
        return           = bapi_return_po.

    wa_header-po_number = po_items-po_number.
    wa_header-po_item = po_items-po_item.
    wa_header-short_text = 'Service Entry Sheet'.
    wa_header-acceptance = 'X'.

 IF p_budat IS NOT INITIAL.
     wa_header-post_date = p_budat.
 ELSE.
    wa_header-post_date = sy-datum.
 ENDIF.

    wa_header-doc_date = sy-datum.
    wa_header-pckg_no = 1.
    serial_no = 0.
    line_no = 1.

    bapi_esll-pckg_no = 1.
    bapi_esll-line_no = line_no.
    bapi_esll-outl_level = '0'.
    bapi_esll-outl_ind = 'X'.
    bapi_esll-subpckg_no = 2.
    APPEND bapi_esll.

    LOOP AT po_services WHERE NOT short_text IS INITIAL.
      CLEAR bapi_esll.
      bapi_esll-pckg_no = 2.
      bapi_esll-line_no = line_no * 10.
      bapi_esll-service = po_services-service.
      bapi_esll-short_text = po_services-short_text.
      bapi_esll-quantity = po_services-quantity.
      bapi_esll-gr_price = po_services-gr_price.
      bapi_esll-price_unit = po_services-price_unit.
      APPEND bapi_esll.
      line_no = line_no + 1.
    ENDLOOP.

    CALL FUNCTION 'BAPI_ENTRYSHEET_CREATE'
      EXPORTING
        entrysheetheader   = wa_header
      IMPORTING
        entrysheet         = ws_entrysheet_no
      TABLES
        entrysheetservices = bapi_esll
        return             = i_return.

    DATA(ws_wait) = '3'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = ws_wait.

    LOOP AT i_return INTO s_return.
      IF  s_return-type = 'E'.
        wa_return-mblnr    = wa_hdr-mblnr = wa_gmvt_headret-mat_doc .
        wa_return-ebeln    = wa_hdr-service_po.
        wa_return-type     = s_return-type.
        wa_return-id       = s_return-id.
        wa_return-message1 = s_return-message.
        APPEND wa_return TO lt_det.
      ELSEIF s_return-type = 'S'.
        wa_return-ebeln    =  wa_hdr-service_po.
        wa_return-message  = s_return-message.
        wa_return-mblnr    = s_return-message_v1.
        wa_return-msg_type = s_return-type.
        APPEND wa_return TO lt_det.
        CLEAR wa_det.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GRPO_FV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grpo_fv.

ENDFORM.
