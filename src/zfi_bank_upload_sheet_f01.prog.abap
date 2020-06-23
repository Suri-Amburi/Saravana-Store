*&---------------------------------------------------------------------*
*& Include          ZFI_BANK_UPLOAD_SHEET_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  DATA :
    lv_count  TYPE i,
    lv_amount TYPE nebtr.

  FIELD-SYMBOLS :
    <ls_final>  TYPE ty_final,
    <ls_inv_no> TYPE any.

  CONSTANTS :
    c_2l      TYPE wrbtr VALUE 200000,
    c_neft(4) VALUE 'NEFT',
    c_rtgs(4) VALUE 'RTGS',
    c_o(1)    VALUE 'O'.       " Online

*** Accounting Doc's
  SELECT
    bkpf~bukrs,             " Company Code
    bkpf~belnr,             " Document Numbe
    bkpf~gjahr,             " Fiscal Year
    bkpf~blart,             " Doc type
    bkpf~bldat,             " Document Date
    bkpf~budat,             " Posting Date
    bkpf~xblnr,             " Reference Number
    bseg~lifnr,             " Vendor
    bseg~nebtr,             " Payment Amount
    lfa1~name1,             " Vendor Name
    lfbk~bankl,             " Bank Key
    lfbk~bankn,             " Bank Account
    bnka~banka,             " Bank name
    bnka~provz,             " Region
    bnka~brnch,             " Branch
    zinw_t_hdr~bill_num,    " Vendor Bill Number
    adr6~smtp_addr,         " Email
    zqr_t_add~payment_mode  " Payment Mode - Online / Cheque
    INTO TABLE @DATA(lt_acc_data)
    FROM bkpf AS bkpf
    INNER JOIN bseg AS bseg ON bseg~bukrs = bkpf~bukrs AND bseg~belnr = bkpf~belnr AND bseg~gjahr = bkpf~gjahr
    LEFT  JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~acc_doc_no = bkpf~belnr AND zinw_t_hdr~acc_gjahr = bkpf~gjahr
    LEFT  JOIN zqr_t_add AS zqr_t_add ON zqr_t_add~qr_code = zinw_t_hdr~qr_code
    LEFT  JOIN lfa1 AS lfa1 ON lfa1~lifnr = bseg~lifnr
    LEFT  JOIN lfbk AS lfbk ON lfbk~lifnr = lfa1~lifnr
    LEFT  JOIN bnka AS bnka ON bnka~banks = lfbk~banks AND bnka~bankl = lfbk~bankl
    LEFT  JOIN adr6 AS adr6 ON adr6~addrnumber = lfa1~adrnr
    WHERE bkpf~blart = 'KZ' AND bseg~koart = 'K' AND bseg~shkzg = 'S' AND bkpf~budat IN @s_date .

*** Saparators
  SELECT SINGLE dcpfm FROM usr01 INTO @DATA(lv_dcpfm) WHERE bname EQ @sy-uname.
  IF lt_acc_data IS NOT INITIAL.
*** Delete which are not marked as Online through Inward Process
    DELETE lt_acc_data WHERE payment_mode = c_cheque.
*** Get Invoices
*** Comminted on 12.04.2020
*    SELECT
*      bse_clr~belnr_clr,
*      bse_clr~gjahr_clr,
*      bkpf~awkey
*      INTO TABLE @DATA(lt_inv)
*      FROM bse_clr AS bse_clr
*      INNER JOIN bkpf AS bkpf ON bkpf~belnr = bse_clr~belnr AND bkpf~gjahr = bse_clr~gjahr_clr
*      FOR ALL ENTRIES IN @lt_acc_data WHERE bse_clr~belnr_clr = @lt_acc_data-belnr AND bse_clr~bukrs_clr = @lt_acc_data-bukrs
*      AND bse_clr~gjahr_clr = @lt_acc_data-gjahr AND bkpf~blart IN ( 'RE' , 'ZH' , 'KR' ).

    DATA(lt_acc_doc) = lt_acc_data.
    SORT lt_acc_doc BY belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_acc_doc COMPARING belnr gjahr.

    DATA(lt_lifnr) = lt_acc_doc.
    SORT lt_lifnr BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING lifnr.

    FIELD-SYMBOLS :
      <ls_linfr>   LIKE LINE OF lt_acc_doc,
      <ls_acc_doc> LIKE LINE OF lt_acc_doc,
      <ls_inv>     LIKE LINE OF lt_acc_doc.
    SORT lt_lifnr BY lifnr belnr gjahr.
    SORT lt_acc_doc BY lifnr belnr gjahr.
    DATA(lv_tabix) = 1.

    LOOP AT lt_lifnr ASSIGNING <ls_linfr>.
      APPEND INITIAL LINE TO gt_final ASSIGNING <ls_final>.
      <ls_final>-lifnr      = <ls_linfr>-lifnr.
      <ls_final>-name       = <ls_linfr>-name1.
      <ls_final>-ifsc_code  = <ls_linfr>-bankl.
      <ls_final>-bank_name  = <ls_linfr>-banka.
      <ls_final>-acc_no     = <ls_linfr>-bankn.
      <ls_final>-branch     = <ls_linfr>-brnch.
      <ls_final>-email      = <ls_linfr>-smtp_addr.
      <ls_final>-budat      = sy-datum.

      lv_count = 1.
      CLEAR: lv_amount.
      LOOP AT lt_acc_doc ASSIGNING <ls_acc_doc> FROM lv_tabix. " WHERE lifnr = <ls_linfr>-lifnr.
        IF <ls_acc_doc>-lifnr = <ls_linfr>-lifnr.
          CONDENSE <ls_acc_doc>-xblnr.
          CHECK <ls_acc_doc>-xblnr = c_o.
          ADD <ls_acc_doc>-nebtr TO lv_amount.

**** Invoice   " Comminted on 12.04.2020
*        IF lv_count LE 7.
*          READ TABLE lt_inv ASSIGNING FIELD-SYMBOL(<ls_inv>) WITH KEY belnr_clr = <ls_acc_doc>-belnr.
*          IF sy-subrc IS INITIAL.
*            DATA(lv_inv_fld) = '<LS_FINAL>-V_INV' && lv_count.
*            ASSIGN (lv_inv_fld) TO <ls_inv_no>.
*            <ls_inv_no> = <ls_inv>-awkey+0(10).
*            lv_count = lv_count + 1.
*          ENDIF.
*        ENDIF.

*** Bill Number / Reference Number in Invoice
          IF lv_count LE 7.
            DATA(lv_inv_fld) = '<LS_FINAL>-V_INV' && lv_count.
            ASSIGN (lv_inv_fld) TO <ls_inv_no>.
            IF <ls_acc_doc>-bill_num IS NOT INITIAL.
              <ls_inv_no> = <ls_acc_doc>-bill_num.
            ELSE.
              <ls_inv_no> = <ls_acc_doc>-xblnr.
            ENDIF.
            IF <ls_inv_no> IS NOT INITIAL.
              lv_count = lv_count + 1.
            ENDIF.
          ENDIF.
        ELSE.
          lv_tabix = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.

      <ls_final>-amount = lv_amount.

*** Transaction Type - NEFT / RTGS
      IF <ls_final>-amount < c_2l.
        <ls_final>-trxn_type = c_neft+0(1).
        <ls_final>-cust_ref  = <ls_linfr>-name1.
      ELSE.
        <ls_final>-trxn_type = c_rtgs+0(1).
      ENDIF.
    ENDLOOP.
  ENDIF.

  DELETE gt_final WHERE amount EQ 0.
  LOOP AT gt_final ASSIGNING <ls_final>.
    <ls_final>-sno = sy-tabix.
  ENDLOOP.
*** Display Data
*** Fill Catlog
  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv.
  REFRESH : lt_fieldcat.

  APPEND VALUE #( fieldname = 'SNO'           seltext_l = 'SL No'                   tabname = 'GT_FINAL' outputlen = 5  ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'TRXN_TYPE'     seltext_l = 'Tran Type'               tabname = 'GT_FINAL' outputlen = 1  ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'LIFNR'         seltext_l = 'BP Code'                 tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'ACC_NO'        seltext_l = 'Bene. A/c No'            tabname = 'GT_FINAL' outputlen = 35 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'AMOUNT'        seltext_l = 'Instrument Amount'       tabname = 'GT_FINAL' outputlen = 15 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'NAME'          seltext_l = 'Bene Name'               tabname = 'GT_FINAL' outputlen = 35 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F1'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F2'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F3'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F4'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F5'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F6'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F7'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F8'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'CUST_REF'      seltext_l = 'Customer Ref No'         tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV1'        seltext_l = 'Invoice1'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV2'        seltext_l = 'Invoice2'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV3'        seltext_l = 'Invoice3'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV4'        seltext_l = 'Invoice4'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV5'        seltext_l = 'Invoice5'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV6'        seltext_l = 'Invoice6'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'V_INV7'        seltext_l = 'Invoice7'                tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F9'          seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'BUDAT'         seltext_l = 'Inst. Date'              tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'E_F10'         seltext_l = ' '                       tabname = 'GT_FINAL' outputlen = 10 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'IFSC_CODE'     seltext_l = 'IFSC CODE'               tabname = 'GT_FINAL' outputlen = 15 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'BANK_NAME'     seltext_l = 'Bene Bank Name'          tabname = 'GT_FINAL' outputlen = 35 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'BRANCH'        seltext_l = 'Bene Bank Branch Name'   tabname = 'GT_FINAL' outputlen = 35 ) TO lt_fieldcat.
  APPEND VALUE #( fieldname = 'EMAIL'         seltext_l = 'Bene Email Id'           tabname = 'GT_FINAL' outputlen = 35 ) TO lt_fieldcat.

*** Excluding Options
  DATA : lt_excluding TYPE  slis_t_extab.
  APPEND VALUE #( fcode = cl_gui_alv_grid=>mc_fc_help ) TO lt_excluding.
  APPEND VALUE #( fcode = '&VEXCEL' ) TO lt_excluding.
  APPEND VALUE #( fcode = '&OL0' ) TO lt_excluding.
  APPEND VALUE #( fcode = '&ABC' ) TO lt_excluding.
  APPEND VALUE #( fcode = '&AQW' ) TO lt_excluding.     " Word processing
  APPEND VALUE #( fcode = '%SL' ) TO lt_excluding.
  APPEND VALUE #( fcode = '%PC' ) TO lt_excluding.
  APPEND VALUE #( fcode = '&INFO' ) TO lt_excluding.
  APPEND VALUE #( fcode = '&RNT_PREV' ) TO lt_excluding.

break samburi.
*** Display Data
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid               " Name of the calling program
      it_fieldcat        = lt_fieldcat            " Field catalog with field descriptions
      it_excluding       = lt_excluding
    TABLES
      t_outtab           = gt_final               " Table with data to be displayed
    EXCEPTIONS
      program_error      = 1                      " Program errors
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.
