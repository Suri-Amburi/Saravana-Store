*&---------------------------------------------------------------------*
*& Include          ZFI_MIRO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data USING p_qr CHANGING gv_subrc.
  DATA :
    fiscalyear     TYPE  bapi_incinv_fld-fisc_year,
    headerdata     TYPE  bapi_incinv_create_header,
    itemdata       TYPE  TABLE OF bapi_incinv_create_item,
    ls_itemdata    TYPE  bapi_incinv_create_item,
    return         TYPE  TABLE OF bapiret2,
    lv_doc_item    TYPE  rblgp VALUE '000001',
    ls_status      TYPE  zinw_t_status,
    lv_amount      TYPE  p DECIMALS 4,
    r_ebeln        TYPE RANGE OF ebeln,
    lv_tax_amount  TYPE p DECIMALS 3,
    lv_tax         TYPE ekpo-netwr,
    lv_item_amount TYPE ekpo-netwr.

  FIELD-SYMBOLS :
    <ls_return> TYPE bapiret2.
**** Inward Item
  IF gs_hdr-return_po IS NOT INITIAL.
    gv_return_po = gs_hdr-return_po.
  ENDIF.
  IF gs_hdr-mblnr IS NOT INITIAL AND gs_hdr-invoice IS INITIAL.
    SELECT * FROM zinw_t_item INTO TABLE @DATA(lt_item) WHERE qr_code = @p_qr.
    SELECT matdoc~mblnr,
           matdoc~mjahr,
           matdoc~zeile,
           matdoc~matnr,
           matdoc~bwart,
           matdoc~waers,
           matdoc~dmbtr,
           matdoc~bukrs,
           matdoc~ebeln,
           matdoc~ebelp,
           matdoc~menge,
           matdoc~bstme,
           ekpo~mwskz,
           ekpo~werks
           INTO TABLE @DATA(lt_matdoc)
           FROM matdoc AS matdoc
           INNER JOIN ekpo AS ekpo ON ekpo~ebeln = matdoc~ebeln AND ekpo~ebelp = matdoc~ebelp
           WHERE matdoc~mblnr IN ( @gs_hdr-mblnr, @gs_hdr-mblnr_103 ) AND matdoc~ebeln = @gs_hdr-ebeln AND matdoc~record_type = @c_mdoc.

    IF lt_matdoc IS NOT INITIAL.
      SELECT a003~kschl,
             a003~mwskz,
             konp~kbetr
             INTO TABLE @DATA(gt_tax)
             FROM a003 AS a003
             INNER JOIN konp AS konp ON konp~knumh = a003~knumh AND konp~kappl = a003~kappl
             FOR ALL ENTRIES IN @lt_matdoc WHERE a003~mwskz = @lt_matdoc-mwskz AND a003~aland = @c_in AND konp~loevm_ko = @space.
    ENDIF.
    REFRESH : return, itemdata. CLEAR : headerdata ,lv_tax_amount.

***  Header Data in Incoming Invoice
    headerdata-invoice_ind  = c_x.
    headerdata-doc_date     = headerdata-bline_date = sy-datum.
    headerdata-pstng_date   = sy-datum.
*    headerdata-pstng_date   = '20200301'.
    headerdata-calc_tax_ind = c_x.
*    headerdata-del_costs    = gs_hdr-packing_charge.
*    headerdata-ref_doc_no   = gs_hdr-inwd_doc.
    headerdata-ref_doc_no   = gs_hdr-bill_num.          " 04.05.2020 : Vendor Bill Number
    headerdata-secco        = headerdata-business_place  = headerdata-bus_area = c_1000.
    SORT lt_matdoc BY mblnr zeile.
    TRY .
        headerdata-comp_code     = lt_matdoc[ 1 ]-bukrs.
        headerdata-currency      = lt_matdoc[ 1 ]-waers.
        DATA(lv_werks)           = lt_matdoc[ 1 ]-werks.
        SELECT SINGLE gsber FROM t134g INTO headerdata-bus_area WHERE werks = lv_werks.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    IF gs_hdr-mblnr_103 IS NOT INITIAL.
*** For Local Purchase
      CLEAR : headerdata-gross_amount.
*** Document Number of an Invoice Document
      LOOP AT lt_matdoc ASSIGNING FIELD-SYMBOL(<ls_matdoc>) WHERE bwart = '109'.
        CLEAR : ls_itemdata.
***     107 Movement
        READ TABLE lt_matdoc ASSIGNING FIELD-SYMBOL(<ls_matdoc_107>) WITH KEY bwart = '107' ebeln = <ls_matdoc>-ebeln ebelp = <ls_matdoc>-ebelp.
        IF sy-subrc = 0.
          ls_itemdata-invoice_doc_item  = lv_doc_item.
          ls_itemdata-po_number         = <ls_matdoc_107>-ebeln.
          ls_itemdata-po_item           = <ls_matdoc_107>-ebelp.
          ls_itemdata-ref_doc           = <ls_matdoc_107>-mblnr.
          ls_itemdata-ref_doc_year      = <ls_matdoc_107>-mjahr.
          ls_itemdata-ref_doc_it        = <ls_matdoc_107>-zeile.
          ls_itemdata-tax_code          = <ls_matdoc_107>-mwskz.
          ls_itemdata-item_amount       = ( <ls_matdoc_107>-dmbtr * <ls_matdoc>-menge ) / <ls_matdoc_107>-menge  .
          ls_itemdata-quantity          = <ls_matdoc>-menge.
          ls_itemdata-po_unit           = <ls_matdoc_107>-bstme.
          ls_itemdata-tax_code          = <ls_matdoc_107>-mwskz.
          lv_doc_item                   = lv_doc_item + 1.

          CLEAR : lv_tax.
          READ TABLE gt_tax ASSIGNING FIELD-SYMBOL(<ls_tax>) WITH KEY mwskz = <ls_matdoc>-mwskz.
          IF sy-subrc = 0.
            IF <ls_tax>-kschl = 'JIIG'.
              lv_tax = ( ls_itemdata-item_amount * ( <ls_tax>-kbetr / 10 ) ) / 100. " With 2 decimals with rounding
              lv_tax_amount = lv_tax_amount + lv_tax.                      " With 3 decimals
            ELSEIF <ls_tax>-kschl = 'JISG' OR <ls_tax>-kschl = 'JICG'.
              lv_tax = ( ls_itemdata-item_amount * ( <ls_tax>-kbetr / 10 ) ) / 100. " With 2 decimals with rounding
              lv_tax_amount = lv_tax_amount + lv_tax + lv_tax.             " With 3 decimals
            ENDIF.
          ENDIF.
          ADD ls_itemdata-item_amount TO headerdata-gross_amount.
          APPEND ls_itemdata TO itemdata.
          CLEAR:ls_itemdata.
        ENDIF.
      ENDLOOP.
    ELSE.
*** Document Number of an Invoice Document
      LOOP AT lt_matdoc ASSIGNING <ls_matdoc>.
        CLEAR : ls_itemdata.
        ls_itemdata-invoice_doc_item  = lv_doc_item.
        ls_itemdata-po_number         = <ls_matdoc>-ebeln.
        ls_itemdata-po_item           = <ls_matdoc>-ebelp.
        ls_itemdata-ref_doc           = <ls_matdoc>-mblnr.
        ls_itemdata-ref_doc_year      = <ls_matdoc>-mjahr.
        ls_itemdata-ref_doc_it        = <ls_matdoc>-zeile.
        ls_itemdata-tax_code          = <ls_matdoc>-mwskz.
        ls_itemdata-item_amount       = <ls_matdoc>-dmbtr.
        ls_itemdata-quantity          = <ls_matdoc>-menge.
        ls_itemdata-po_unit           = <ls_matdoc>-bstme.
        ls_itemdata-tax_code          = <ls_matdoc>-mwskz.

        CLEAR : lv_tax.
        READ TABLE gt_tax ASSIGNING <ls_tax> WITH KEY mwskz = <ls_matdoc>-mwskz.
        IF sy-subrc = 0.
          IF <ls_tax>-kschl = 'JIIG'.
            lv_tax = ( ls_itemdata-item_amount * ( <ls_tax>-kbetr / 10 ) ) / 100. " With 2 decimals with rounding
            lv_tax_amount = lv_tax_amount + lv_tax.                      " With 3 decimals
          ELSEIF <ls_tax>-kschl = 'JISG' OR <ls_tax>-kschl = 'JICG'.
            lv_tax = ( ls_itemdata-item_amount * ( <ls_tax>-kbetr / 10 ) ) / 100. " With 2 decimals with rounding
            lv_tax_amount = lv_tax_amount + lv_tax + lv_tax.             " With 3 decimals
          ENDIF.
        ENDIF.
        ADD ls_itemdata-item_amount TO headerdata-gross_amount.
        lv_doc_item = lv_doc_item + 1.
        APPEND ls_itemdata TO itemdata.
      ENDLOOP.
    ENDIF.

    lv_tax_amount = floor( lv_tax_amount * 100 ) / 100.
    headerdata-gross_amount = headerdata-gross_amount + lv_tax_amount.

**** Header Amount Calculation
*    DATA: lv_tabix TYPE sy-tabix.
*    DATA: lv_item_amount TYPE bapiwrbtr.
*    DATA(lt_tax_code) = itemdata.
*    SORT : lt_tax_code BY tax_code , itemdata BY tax_code.
*    DELETE ADJACENT DUPLICATES FROM lt_tax_code COMPARING tax_code.
*    LOOP AT lt_tax_code ASSIGNING FIELD-SYMBOL(<ls_tax_code>).
*      READ TABLE itemdata ASSIGNING FIELD-SYMBOL(<ls_item>) WITH KEY tax_code = <ls_tax_code>-tax_code.
*      IF sy-subrc = 0.
*        lv_tabix = sy-tabix.
*        CLEAR : lv_item_amount.
*        LOOP AT itemdata ASSIGNING <ls_item> FROM lv_tabix.
*          IF <ls_item>-tax_code <> <ls_tax_code>-tax_code.
*            EXIT.
*          ELSE.
*            ADD <ls_item>-item_amount TO lv_item_amount.
*          ENDIF.
*        ENDLOOP.
**** TAX CALCULATION
*        READ TABLE gt_tax ASSIGNING FIELD-SYMBOL(<ls_tax>) WITH KEY mwskz = <ls_tax_code>-tax_code.
*        IF sy-subrc = 0.
*          IF <ls_tax>-kschl = 'JIIG'.
*            lv_tax_amount = lv_item_amount + ( ( lv_item_amount * <ls_tax>-kbetr ) / 1000 ) .
*          ELSEIF <ls_tax>-kschl = 'JISG' OR <ls_tax>-kschl = 'JICG'.
*            lv_tax_amount =  ( ( lv_item_amount * <ls_tax>-kbetr ) / 1000 ) .
*            lv_tax_amount = lv_item_amount + lv_tax_amount + lv_tax_amount.
*          ENDIF.
*        ENDIF.
*        headerdata-gross_amount = headerdata-gross_amount + lv_tax_amount.
*      ENDIF.
*    ENDLOOP.

    SORT itemdata BY invoice_doc_item.
*** MIRO Invoice Post
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = headerdata           " Header Data in Incoming Invoice (Create)
      IMPORTING
        invoicedocnumber = invoicedocnumber     " Document Number of an Invoice Document
        fiscalyear       = fiscalyear           " Fiscal Year
      TABLES
        itemdata         = itemdata             " Item Data in Incoming Invoice
        return           = return.              " Return Messages

    IF invoicedocnumber IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_x.
*** Update Header Status
      gv_subrc = 0.
      gs_hdr-invoice   = invoicedocnumber.
      gs_hdr-inv_gjahr = fiscalyear.
*** For Updating Status Table
      ls_status-qr_code      = gs_hdr-qr_code.
      ls_status-inwd_doc     = gs_hdr-inwd_doc.
      ls_status-status_field = c_qr_code.
      ls_status-status_value = c_qr06.
      IF gs_hdr-return_po IS INITIAL.
        gs_hdr-status  = c_06.
      ENDIF.
      ls_status-description  = 'Invoice Created'.
      ls_status-created_by   = sy-uname.
      ls_status-created_date = sy-datum.
      ls_status-created_time = sy-uzeit.

*** Invoice Approvel
      DATA : wa_approve  TYPE zinvoice_t_app.
      wa_approve-app_status = 'L1'.
      wa_approve-mandt      = sy-mandt.
      wa_approve-qr_code    = gs_hdr-qr_code.
      MODIFY zinvoice_t_app FROM wa_approve.
      MODIFY zinw_t_hdr FROM gs_hdr.
      MODIFY zinw_t_status FROM ls_status.
      COMMIT WORK.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PERFORM msg_init.
      LOOP AT return ASSIGNING <ls_return>.
        CALL FUNCTION 'MESSAGE_STORE'
          EXPORTING
            arbgb                  = <ls_return>-id
            msgty                  = <ls_return>-type
            msgv1                  = <ls_return>-message_v1
            msgv2                  = <ls_return>-message_v2
            msgv3                  = <ls_return>-message_v3
            msgv4                  = <ls_return>-message_v4
            txtnr                  = <ls_return>-number
          EXCEPTIONS
            message_type_not_valid = 1
            not_active             = 2
            OTHERS                 = 3.
        IF sy-subrc <> 0.
          gv_subrc = sy-subrc.
        ENDIF.
      ENDLOOP.
      PERFORM msg_stop.
      PERFORM msg_show.
    ENDIF.
  ELSE.
    gv_subrc = 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_data.
  CLEAR:  gv_return_po, gv_subrc.
  IF p_qr IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE qr_code = p_qr.
    IF gs_hdr-status = c_05.
    ELSE.
      CASE gs_hdr-status.
        WHEN c_01 OR c_02 OR c_03 OR c_04 .
          MESSAGE s046(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        WHEN c_06 OR c_07.
          MESSAGE s049(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.

FORM msg_init.
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      log_not_active       = 1
      wrong_identification = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM msg_stop.
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
ENDFORM.
FORM msg_show.
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
*& Form DEBIT_NOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM debit_note USING gv_return_po CHANGING gv_subrc.
  DATA :
    headerdata    TYPE bapi_incinv_create_header,
    fiscalyear    TYPE bapi_incinv_fld-fisc_year,
    ls_itemdata   TYPE bapi_incinv_create_item,
    itemdata      TYPE STANDARD TABLE OF bapi_incinv_create_item,
    return        TYPE STANDARD TABLE OF bapiret2,
    lv_tax        TYPE ekpo-netwr,
    lv_tax_amount TYPE p DECIMALS 3,
    ls_status     TYPE zinw_t_status,
    lv_dec3       TYPE p DECIMALS 3.

*** Header Data
  IF gv_return_po IS NOT INITIAL AND gs_hdr-debit_note IS INITIAL AND gs_hdr-invoice IS NOT INITIAL.
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
           ekpo~werks,
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
           WHERE ekko~ebeln = @gv_return_po AND konp~loevm_ko = @space.

    SORT lt_debit BY mblnr zeile.
    DELETE ADJACENT DUPLICATES FROM lt_debit COMPARING ebeln ebelp.

    headerdata-doc_date     = sy-datum.
    headerdata-pstng_date   = sy-datum.
*    headerdata-pstng_date   =  '20200301'.
    headerdata-bline_date   = sy-datum.
    headerdata-calc_tax_ind = c_x.
*    headerdata-ref_doc_no   = gs_hdr-inwd_doc.
    headerdata-ref_doc_no   = gs_hdr-bill_num.                       " 04.05.2020 : Vendor Bill Number
    headerdata-secco        = headerdata-business_place = c_1000.

    FIELD-SYMBOLS : <ls_debit> LIKE LINE OF lt_debit.
    CLEAR : lv_tax_amount.
    DATA(lt_tax_code) = lt_debit.
    SORT : lt_tax_code BY mwskz.
    DELETE ADJACENT DUPLICATES FROM lt_tax_code COMPARING mwskz.
*** Item Data
    LOOP AT lt_debit ASSIGNING <ls_debit>.
      AT FIRST.
        headerdata-comp_code        = <ls_debit>-bukrs.
        headerdata-currency         = <ls_debit>-waers.
        SELECT SINGLE gsber FROM t134g INTO headerdata-bus_area WHERE werks = <ls_debit>-werks.
      ENDAT.
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

      CLEAR : lv_tax.
      READ TABLE lt_tax_code ASSIGNING FIELD-SYMBOL(<ls_tax>) WITH KEY mwskz = <ls_debit>-mwskz.
      IF sy-subrc IS INITIAL.
        IF <ls_tax>-kschl = 'JIIG'.
          lv_tax = ( ls_itemdata-item_amount * ( <ls_tax>-kbetr / 10 ) ) / 100. " With 2 decimals with rounding
          lv_tax_amount = lv_tax_amount + lv_tax.                               " With 3 decimals
        ELSEIF <ls_tax>-kschl = 'JISG' OR <ls_tax>-kschl = 'JICG'.
          lv_tax = ( ls_itemdata-item_amount * ( <ls_tax>-kbetr / 10 ) ) / 100. " With 2 decimals with rounding
          lv_tax_amount = lv_tax_amount + lv_tax + lv_tax.                      " With 3 decimals
        ENDIF.
      ENDIF.
      ADD ls_itemdata-item_amount TO headerdata-gross_amount.
      APPEND ls_itemdata TO itemdata.
      CLEAR : ls_itemdata.
    ENDLOOP.

    lv_tax_amount = floor( lv_tax_amount * 100 ) / 100.
    headerdata-gross_amount = headerdata-gross_amount + lv_tax_amount.

**** Header Amount Calculation
*    DATA: lv_tabix TYPE sy-tabix.
*    DATA: lv_item_amount TYPE bapiwrbtr.
*    DATA(lt_tax_code) = itemdata.
*    SORT : lt_tax_code , itemdata BY tax_code.
*    DELETE ADJACENT DUPLICATES FROM lt_tax_code COMPARING tax_code.
*    LOOP AT lt_tax_code ASSIGNING FIELD-SYMBOL(<ls_tax_code>).
*      READ TABLE itemdata ASSIGNING FIELD-SYMBOL(<ls_item>) WITH KEY tax_code = <ls_tax_code>-tax_code.
*      IF sy-subrc = 0.
*        lv_tabix = sy-tabix.
*        CLEAR : lv_item_amount.
*        LOOP AT itemdata ASSIGNING <ls_item> FROM lv_tabix.
*          IF <ls_item>-tax_code <> <ls_tax_code>-tax_code.
*            EXIT.
*          ELSE.
*            ADD <ls_item>-item_amount TO lv_item_amount.
*          ENDIF.
*        ENDLOOP.
**** TAX CALCULATION
*        READ TABLE lt_debit ASSIGNING <ls_debit> WITH KEY mwskz = <ls_tax_code>-tax_code.
*        IF sy-subrc = 0.
*          IF <ls_debit>-kschl = 'JIIG'.
*            lv_tax_amount = lv_item_amount + ( ( lv_item_amount * <ls_debit>-kbetr ) / 1000 ) .
*          ELSEIF <ls_debit>-kschl = 'JISG' OR <ls_debit>-kschl = 'JICG'.
*            lv_tax_amount =   ( lv_item_amount * <ls_debit>-kbetr ) / 1000  .
*            lv_tax_amount = lv_item_amount + lv_tax_amount + lv_tax_amount.
*          ENDIF.
*        ENDIF.
*        headerdata-gross_amount = headerdata-gross_amount + lv_tax_amount.
*      ENDIF.
*    ENDLOOP.

    SORT itemdata BY invoice_doc_item..
*** Create Debit Note
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = headerdata                  " Header Data in Incoming Invoice (Create)
      IMPORTING
        invoicedocnumber = invoicedocnumber_dn         " Document Number of an Invoice Document
        fiscalyear       = fiscalyear                  " Fiscal Year
      TABLES
        itemdata         = itemdata                    " Item Data in Incoming Invoice
        return           = return.                     " Return Messages

    READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_x.

*** Update Inward Header Table
      gs_hdr-debit_note = invoicedocnumber_dn.
      gs_hdr-status  = c_06.
*** Status Update
      ls_status-inwd_doc     = gs_hdr-inwd_doc.
      ls_status-qr_code      = gs_hdr-qr_code.
      ls_status-status_field = c_se_code.
      ls_status-created_by   = sy-uname.
      ls_status-created_date = sy-datum.
      ls_status-created_time = sy-uzeit.
      IF gs_hdr-tat_po IS NOT INITIAL.
        ls_status-status_value = c_se04.
        ls_status-description  = 'Shortage & Excess'.
        gs_hdr-soe = c_04.
      ELSE.
        ls_status-status_value = c_se02.
        ls_status-description  = 'Shortage'.
        gs_hdr-soe = c_02.
      ENDIF.
      MODIFY zinw_t_hdr FROM gs_hdr.
      MODIFY zinw_t_status FROM ls_status.
      COMMIT WORK.
      CLEAR : ls_status.
    ELSE.
*** Roll Back if any error.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*      MESSAGE ID <LS_RET>-ID TYPE <LS_RET>-TYPE NUMBER <LS_RET>-NUMBER WITH <LS_RET>-MESSAGE_V1 <LS_RET>-MESSAGE_V2
*      <LS_RET>-MESSAGE_V3 <LS_RET>-MESSAGE_V4.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PERFORM msg_init.
      LOOP AT return ASSIGNING <ls_return>.
        CALL FUNCTION 'MESSAGE_STORE'
          EXPORTING
            arbgb                  = <ls_return>-id
            msgty                  = <ls_return>-type
            msgv1                  = <ls_return>-message_v1
            msgv2                  = <ls_return>-message_v2
            msgv3                  = <ls_return>-message_v3
            msgv4                  = <ls_return>-message_v4
            txtnr                  = <ls_return>-number
          EXCEPTIONS
            message_type_not_valid = 1
            not_active             = 2
            OTHERS                 = 3.
        IF sy-subrc <> 0.
        ENDIF.
      ENDLOOP.
      PERFORM msg_stop.
      PERFORM msg_show.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_messages .
*      MESSAGE | { INVOICEDOCNUMBER } Successfully Debit Note Created | TYPE 'S'.
  PERFORM msg_init.
  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      arbgb                  = 'ZMSG_CLS'
      msgty                  = 'S'
      msgv1                  = invoicedocnumber
      msgv2                  = 'Invoice Created'
      txtnr                  = '047'
    EXCEPTIONS
      message_type_not_valid = 1
      not_active             = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
  ENDIF.

  IF invoicedocnumber_dn IS NOT INITIAL.
*    MESSAGE S054(ZMSG_CLS) WITH INVOICEDOCNUMBER_DN.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb                  = 'ZMSG_CLS'
        msgty                  = 'S'
        msgv1                  = invoicedocnumber_dn
        msgv2                  = 'Debit Note Created'
        txtnr                  = '054'
      EXCEPTIONS
        message_type_not_valid = 1
        not_active             = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

  PERFORM msg_stop.
  PERFORM msg_show.
ENDFORM.
