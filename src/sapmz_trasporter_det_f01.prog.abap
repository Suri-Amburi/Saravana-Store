*&---------------------------------------------------------------------*
*& Include          SAPMZ_TRASPORTER_DET_F01
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
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_QR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_qr INPUT.
*  IF lv_qr IS NOT INITIAL .

  IF lv_invoice_no IS NOT INITIAL AND lv_qr IS NOT INITIAL AND it_final IS INITIAL. """added

    MESSAGE 'Please enter either QR_Code or Invoice Number' TYPE 'I' DISPLAY LIKE 'E' .

 ELSEIF lv_qr IS NOT INITIAL  AND  lv_invoice_no IS INITIAL.

    SELECT SINGLE
           qr_code
           ebeln
           lifnr
           service_po
           mblnr
           lr_no
           status FROM zinw_t_hdr INTO  wa_zinw_t_hdr WHERE qr_code = lv_qr .

    IF wa_zinw_t_hdr-qr_code <> lv_qr.
      MESSAGE 'Invalid QR Code ' TYPE 'E' .
    ENDIF.

    SELECT
     ebeln
     ebelp
     belnr
     dmbtr
     menge
     bewtp FROM ekbe INTO TABLE it_ekbe1  WHERE ebeln = wa_zinw_t_hdr-service_po AND bewtp = 'Q'.

    READ TABLE it_ekbe1 INTO wa_ekbe1 INDEX 1.""" added

*** IF QR IS ALREADY POSTED
*      IF it_ekbe1 IS NOT INITIAL .           """commented
*        MESSAGE 'QR is already posted ' TYPE 'E' .
*      ENDIF.

********QR Code Validations
*    IF wa_zinw_t_hdr IS INITIAL.               """commented
*      MESSAGE 'Invalid QR Code ' TYPE 'E' .
*    ELSEIF wa_zinw_t_hdr-service_po IS INITIAL .
*      MESSAGE 'QR Code is not for Service PO' TYPE 'E'.
*    ENDIF.

********For Same Qr_code
    IF it_final IS NOT INITIAL.
      READ TABLE it_final  INTO wa_final INDEX 1.
      IF wa_zinw_t_hdr-qr_code = wa_final-qr_code.
        MESSAGE 'QR Code is already considered' TYPE 'E' .
      ENDIF.

**********************************added on 26.04.2020****************

********For invoice done
      IF wa_ekbe1-bewtp <> wa_final-bewtp.
        MESSAGE 'For this Qr_Code Invoice is already done' TYPE 'E' .
      ENDIF.
    ENDIF.
    IF it_ekbe1 IS NOT INITIAL .
      SELECT
       rseg~belnr ,
       rseg~ebeln ,
       rseg~ebelp ,
       rseg~gjahr ,
       rseg~wrbtr FROM rseg INTO TABLE @DATA(it_rseg)
                  FOR ALL ENTRIES IN @it_ekbe1
                  WHERE belnr = @it_ekbe1-belnr.

       READ TABLE it_rseg ASSIGNING FIELD-SYMBOL(<ls_awkey>) INDEX 1.
      IF sy-subrc = 0 .
        DATA(lv_gjahr) =  <ls_awkey>-gjahr .
      ENDIF.
      CONCATENATE  <ls_awkey>-belnr lv_gjahr INTO DATA(lv_awkey) .

      SELECT
        bseg~belnr ,
        bseg~augbl ,
        bseg~awkey  FROM bseg INTO  TABLE @DATA(it_bseg_i)
                    WHERE awkey = @lv_awkey
                    AND koart = 'K'.

       SELECT
      rbkp~belnr ,
      rbkp~xblnr ,
      rbkp~rmwwr FROM rbkp INTO TABLE @DATA(it_rbkp_i)
               FOR ALL ENTRIES IN @it_rseg
               WHERE belnr = @it_rseg-belnr.

     SELECT
        ekpo~ebeln,
        ekpo~ebelp ,
        ekpo~menge ,
        ekpo~netwr ,
        ekpo~mwskz FROM ekpo INTO TABLE @DATA(it_ekpo_i)
                    FOR ALL ENTRIES IN @it_rseg
                    WHERE ebeln = @it_rseg-ebeln
                    AND   ebelp = @it_rseg-ebelp.

      SELECT
        zinw_t_hdr~qr_code,
        zinw_t_hdr~service_po ,
        zinw_t_hdr~lr_no FROM zinw_t_hdr INTO TABLE @DATA(it_zinw_t_hdr_i)
                              FOR ALL ENTRIES IN @it_rseg
                              WHERE service_po = @it_rseg-ebeln.

********QR Code Validations
      IF wa_zinw_t_hdr IS INITIAL .
        MESSAGE 'Invalid QR Code ' TYPE 'E' .
      ELSEIF wa_zinw_t_hdr-service_po IS INITIAL .
        MESSAGE 'QR Code is not for Service PO' TYPE 'E' .
*    ELSEIF WA_ZINW_T_HDR-STATUS <> '06'.
*      MESSAGE 'GR Not Yet Posted' TYPE 'E' .
      ENDIF.

*********************************************************************

    SELECT SINGLE lifnr FROM ekko INTO @DATA(wa_lifnr) WHERE ebeln = @wa_zinw_t_hdr-service_po.

****if vendor is same
    IF lv_lifnr IS INITIAL .
      lv_lifnr =  wa_lifnr.
      IF wa_lifnr IS NOT INITIAL.
        SELECT SINGLE name1 FROM lfa1 INTO @lv_name WHERE lifnr = @wa_lifnr.
        IF gs_whtax IS INITIAL.
***      Start of Changes by Suri : 17.04.2020 : For TDS tax
          SELECT SINGLE lfbw~witht,
                        lfbw~wt_withcd,
                        t059z~qsatz
                        INTO @gs_whtax
                        FROM lfbw AS lfbw
                        INNER JOIN t059z AS t059z ON t059z~witht = lfbw~witht AND t059z~wt_withcd = lfbw~wt_withcd
                        WHERE lfbw~lifnr = @wa_lifnr AND lfbw~witht IN ( 'W1','W2','W3','W4','W5','W6','W7','W8' ).
***      End of Changes by Suri : 17.04.2020 : For TDS tax
        ENDIF.
      ENDIF.
    ELSEIF lv_lifnr  <> wa_lifnr.                ""WA_ZINW_T_HDR-LIFNR .
      MESSAGE 'Posting for Multiple Vendor not possible ' TYPE 'E' .
    ENDIF.

********************************added****************************************
 LOOP AT it_zinw_t_hdr_i ASSIGNING FIELD-SYMBOL(<ls_zinw_t_hdr_i>) .
        wa_final-qr_code =  <ls_zinw_t_hdr_i>-qr_code .
        wa_final-service_po = <ls_zinw_t_hdr_i>-service_po .
        wa_final-lr_no = <ls_zinw_t_hdr_i>-lr_no.
        DATA : lv_amt1 TYPE wrbtr.
        SORT it_rseg BY ebeln  ebelp.
        CLEAR : lv_amt1.
        LOOP AT it_rseg ASSIGNING FIELD-SYMBOL(<ls_rseg>) WHERE ebeln = <ls_zinw_t_hdr_i>-service_po.
          lv_amt1 = <ls_rseg>-wrbtr + lv_amt1 .
          lv_invoice_no = <ls_rseg>-belnr .
        ENDLOOP.
        READ TABLE it_rbkp_i ASSIGNING FIELD-SYMBOL(<wa_rbkp_i>) WITH KEY belnr = <ls_rseg>-belnr.
        IF sy-subrc = 0.
          lv_bill =  <wa_rbkp_i>-xblnr.
        ENDIF.

        READ TABLE it_ekpo_i ASSIGNING FIELD-SYMBOL(<wa_inv>) WITH KEY ebeln = <ls_rseg>-ebeln  ebelp = <ls_rseg>-ebelp.
        DATA : lv_po_val1 TYPE netwr.
        DATA : lv_po_tax1 TYPE wmwst.
        IF sy-subrc = 0.
          CLEAR: lv_po_val1 , lv_po_tax1.
          CALL METHOD zcl_po_item_tax=>get_po_item_tax
            EXPORTING
              i_ebeln     = <wa_inv>-ebeln                 " Purchasing Document Number
              i_ebelp     = <wa_inv>-ebelp                 " Item Number of Purchasing Document
              i_quantity  = <wa_inv>-menge              " Quantity
            IMPORTING
             e_tax       = lv_po_tax1  .               " Tax Amount in Document Currency
**              e_total_val = lv_po_val1.
        ENDIF.
*        wa_final-amount = lv_po_val1.

        wa_final-amount = <wa_inv>-netwr.
        wa_final-tax    = lv_po_tax1.
****************************added on 11.05.2020*************************************
        IF gs_whtax-qsatz IS NOT INITIAL.
          wa_final-tds = ( <wa_inv>-netwr   * gs_whtax-qsatz ) / 100.
        ENDIF.

************************************************************************************
        APPEND wa_final TO it_final.
        CLEAR : wa_final .
      ENDLOOP.
     READ TABLE it_bseg_i ASSIGNING FIELD-SYMBOL(<ls_bseg_i>) WITH KEY awkey = lv_awkey.
      IF sy-subrc = 0.
        lv_payment = <ls_bseg_i>-augbl .
        IF <ls_bseg_i>-augbl IS NOT INITIAL.
          MESSAGE 'Payment is already done' TYPE 'I' DISPLAY LIKE 'E' .
        ENDIF.
      ENDIF.
      DATA(it_final1) = it_final[] .
      CLEAR lv_qr .
*    ENDIF.
    ELSE.
      REFRESH : it_final1 .
********QR Code Validations
      IF wa_zinw_t_hdr IS INITIAL.
        MESSAGE 'Invalid QR Code ' TYPE 'E' .
      ELSEIF wa_zinw_t_hdr-service_po IS INITIAL .
        MESSAGE 'QR Code is not for Service PO' TYPE 'E' .
      ENDIF.

********For Same Qr_code
      IF it_final IS NOT INITIAL.
        READ TABLE it_final  INTO wa_final INDEX 1.
        IF wa_zinw_t_hdr-qr_code = wa_final-qr_code.
          MESSAGE 'QR Code is already considered' TYPE 'E' .
        ENDIF.
      ENDIF.

      SELECT SINGLE
        lifnr FROM ekko INTO @DATA(wa_lifnr1) WHERE ebeln = @wa_zinw_t_hdr-service_po.
      IF wa_lifnr1 IS NOT INITIAL.

        SELECT SINGLE name1 FROM lfa1 INTO  @DATA(wa_name1) WHERE lifnr =  @wa_lifnr1.

      ENDIF.
****if vendor is same
      IF lv_lifnr IS INITIAL .
        lv_lifnr =  wa_lifnr1 .        ""WA_ZINW_T_HDR-LIFNR .
        lv_name  =  wa_name1  .
******************added on 11.05.2020*******************
     IF gs_whtax IS INITIAL.
          SELECT SINGLE lfbw~witht,
                        lfbw~wt_withcd,
                        t059z~qsatz
                        INTO @gs_whtax
                        FROM lfbw AS lfbw
                        INNER JOIN t059z AS t059z ON t059z~witht = lfbw~witht AND t059z~wt_withcd = lfbw~wt_withcd
                        WHERE lfbw~lifnr = @lv_lifnr AND lfbw~witht IN ( 'W1','W2','W3','W4','W5','W6','W7','W8' ).
        ENDIF.

********************************************************
      ELSEIF lv_lifnr  <> wa_lifnr1.                ""WA_ZINW_T_HDR-LIFNR .
        MESSAGE 'Posting for Multiple Vendor not possible ' TYPE 'E' .
      ENDIF.


*****************************************************************************
    IF  wa_zinw_t_hdr IS NOT INITIAL.
      SELECT
         ebeln
         ebelp
         belnr
         dmbtr
         menge
         bewtp FROM ekbe INTO TABLE it_ekbe  WHERE ebeln = wa_zinw_t_hdr-service_po AND  bewtp = 'E' AND bwart = '101'.

**********GR Validation
      IF it_ekbe IS INITIAL .
        MESSAGE 'GR is not yet done' TYPE 'E' .
      ENDIF.

      IF it_ekbe IS NOT INITIAL.
        SELECT
          ebeln
          ebelp
          menge
          netwr
          mwskz FROM ekpo INTO TABLE it_ekpo
                FOR ALL ENTRIES IN it_ekbe
                WHERE ebeln = it_ekbe-ebeln
                AND ebelp = it_ekbe-ebelp.
      ENDIF.

      LOOP AT it_ekbe ASSIGNING FIELD-SYMBOL(<wa_ekbe>) WHERE ebeln = wa_zinw_t_hdr-service_po.
        READ TABLE it_ekpo ASSIGNING FIELD-SYMBOL(<wa_ret>) WITH KEY ebeln = <wa_ekbe>-ebeln  ebelp = <wa_ekbe>-ebelp.
        wa_final-qr_code = wa_zinw_t_hdr-qr_code .
        wa_final-service_po = wa_zinw_t_hdr-service_po .
        wa_final-lr_no = wa_zinw_t_hdr-lr_no .
        wa_final-bewtp =  <wa_ekbe>-bewtp.   """"added


        DATA : lv_po_val TYPE netwr.
        DATA : lv_po_tax TYPE wmwst.
        IF sy-subrc = 0.
          CLEAR : lv_po_val , lv_po_tax.

          CALL METHOD zcl_po_item_tax=>get_po_item_tax
            EXPORTING
              i_ebeln     = <wa_ret>-ebeln                 " Purchasing Document Number
              i_ebelp     = <wa_ret>-ebelp                 " Item Number of Purchasing Document
              i_quantity  = <wa_ret>-menge                 " Quantity
            IMPORTING
              e_tax       = lv_po_tax.
*              e_total_val = lv_po_val.
        ENDIF.

        wa_final-amount = <wa_ret>-netwr.     " Suri : 02.04.2020
        wa_final-tax    = lv_po_tax.          " Suri : 02.04.2020

        IF gs_whtax-qsatz IS NOT INITIAL.
          wa_final-tds = ( <wa_ret>-netwr   * gs_whtax-qsatz ) / 100.
        ENDIF.
        APPEND wa_final TO it_final.
        CLEAR wa_final .
      ENDLOOP.
    ENDIF.

    it_final1 = it_final[].   """changed
    SORT it_final1 BY service_po.
    DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING service_po.

    LOOP AT it_final1 ASSIGNING FIELD-SYMBOL(<wa_final1>) .
      CLEAR <wa_final1>-amount.
      LOOP AT it_final INTO wa_final WHERE service_po = <wa_final1>-service_po.
        <wa_final1>-amount = wa_final-amount.
        <wa_final1>-tax = wa_final-tax.
        <wa_final1>-tds = wa_final-tds.
      ENDLOOP.
    ENDLOOP.
    CLEAR lv_qr .
   ENDIF.
  ENDIF .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BILL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_bill INPUT.

  IF lv_invoice_no IS NOT INITIAL AND it_final IS INITIAL AND lv_qr IS INITIAL.
    SELECT
    rseg~belnr ,
    rseg~ebeln ,
    rseg~ebelp ,
    rseg~gjahr ,
    rseg~wrbtr  FROM rseg INTO TABLE @DATA(it_rseg_q)
               WHERE belnr = @lv_invoice_no .

    IF it_rseg_q IS INITIAL.
      MESSAGE 'Invoice number is incoreect' TYPE 'I' DISPLAY LIKE 'E' .
    ENDIF.
    CLEAR :  lv_invoice_no  .
  ENDIF .

  IF it_rseg_q IS NOT INITIAL AND it_final IS INITIAL AND lv_qr IS INITIAL.

    IF it_rseg_q IS NOT INITIAL.
      SELECT
        zinw_t_hdr~qr_code ,
        zinw_t_hdr~service_po ,
        zinw_t_hdr~lr_no FROM zinw_t_hdr INTO TABLE @DATA(it_zinw_t_hdr_q)
                              FOR ALL ENTRIES IN @it_rseg_q
                              WHERE service_po = @it_rseg_q-ebeln .
      SELECT
        ekpo~ebeln,
        ekpo~ebelp ,
        ekpo~menge ,
        ekpo~netwr ,
        ekpo~mwskz FROM ekpo INTO TABLE @DATA(it_ekpo_q)
                    FOR ALL ENTRIES IN @it_rseg_q
                    WHERE ebeln = @it_rseg_q-ebeln
                    AND   ebelp = @it_rseg_q-ebelp.
      SELECT
      rbkp~belnr ,
      rbkp~xblnr ,
      rbkp~rmwwr FROM rbkp INTO TABLE @DATA(it_rbkp_q)
               FOR ALL ENTRIES IN @it_rseg_q
               WHERE belnr = @it_rseg_q-belnr.

    ENDIF.
    READ TABLE it_rseg_q ASSIGNING FIELD-SYMBOL(<ls_awkey1>) INDEX 1.
*        LV_AMT1 = <LS_RSEG>-WRBTR + LV_AMT1 .
*        LV_INVOICE_NO = <LS_RSEG>-BELNR .
    IF sy-subrc = 0 .
      DATA(lv_gjahr1) =  <ls_awkey1>-gjahr .
      CONCATENATE  <ls_awkey1>-belnr lv_gjahr1 INTO DATA(lv_awkey1) .
    ENDIF.


    IF lv_awkey1 IS NOT INITIAL .
      SELECT
        bseg~belnr ,
        bseg~augbl ,
        bseg~awkey  FROM bseg INTO  TABLE @DATA(it_bseg_q)
                    WHERE awkey = @lv_awkey1
                    AND koart = 'K'.
    ENDIF .
    READ TABLE it_zinw_t_hdr_q ASSIGNING FIELD-SYMBOL(<wa_hdr>) INDEX 1.
    IF sy-subrc = 0 .
      SELECT SINGLE
      lifnr FROM ekko INTO @DATA(wa_lifnr_q) WHERE ebeln = @<wa_hdr>-service_po.
    ENDIF .
    IF wa_lifnr_q IS NOT INITIAL.
      SELECT SINGLE name1 FROM lfa1 INTO  @DATA(wa_name_q) WHERE lifnr =  @wa_lifnr_q.
****if vendor is same
      lv_lifnr =  wa_lifnr_q .        ""WA_ZINW_T_HDR-LIFNR .
      lv_name  =  wa_name_q  .
    ENDIF.

    LOOP AT it_zinw_t_hdr_q ASSIGNING FIELD-SYMBOL(<wa_zinw_t_hdr_q>).
      wa_final-qr_code =  <wa_zinw_t_hdr_q>-qr_code .
      wa_final-service_po = <wa_zinw_t_hdr_q>-service_po .
      wa_final-lr_no = <wa_zinw_t_hdr_q>-lr_no.
      DATA : lv_amt2 TYPE wrbtr.
      SORT it_rseg_q BY ebeln  ebelp.
      CLEAR : lv_amt2.
      LOOP AT it_rseg_q ASSIGNING FIELD-SYMBOL(<ls_rseg_q>) WHERE ebeln = <wa_zinw_t_hdr_q>-service_po.
        lv_amt2 = <ls_rseg_q>-wrbtr + lv_amt2 .
        lv_invoice_no = <ls_rseg_q>-belnr .
      ENDLOOP.
      READ TABLE it_rbkp_q ASSIGNING FIELD-SYMBOL(<wa_rbkp_q>) WITH KEY belnr = <ls_rseg_q>-belnr.
      IF sy-subrc = 0.
        lv_bill =  <wa_rbkp_q>-xblnr.
      ENDIF.

      READ TABLE it_ekpo_q ASSIGNING FIELD-SYMBOL(<wa_inv_q>) WITH KEY ebeln = <ls_rseg_q>-ebeln  ebelp = <ls_rseg_q>-ebelp.
      DATA : lv_po_val_q TYPE netwr.
      IF sy-subrc = 0.
        CLEAR lv_po_val_q.
        CALL METHOD zcl_po_item_tax=>get_po_item_tax
          EXPORTING
            i_ebeln     = <wa_inv_q>-ebeln                 " Purchasing Document Number
            i_ebelp     = <wa_inv_q>-ebelp                 " Item Number of Purchasing Document
            i_quantity  = <wa_inv_q>-menge              " Quantity
          IMPORTING
*           E_TAX       = GS_FINAL1-TAX                 " Tax Amount in Document Currency
            e_total_val = lv_po_val_q.
      ENDIF.
      wa_final-amount = lv_po_val_q.
      APPEND wa_final TO it_final.
      CLEAR : wa_final .
    ENDLOOP.
    READ TABLE it_bseg_q ASSIGNING FIELD-SYMBOL(<ls_bseg_q>) WITH KEY awkey = lv_awkey1.
    IF sy-subrc = 0.
      lv_payment = <ls_bseg_q>-augbl .
      IF <ls_bseg_q>-augbl IS NOT INITIAL.
        MESSAGE 'Payment is already done' TYPE 'I' DISPLAY LIKE 'E' .
      ENDIF.
    ENDIF.
    it_final1 = it_final[] .


  ENDIF.



ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_BILL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bill .

  IF  lv_invoice_no IS INITIAL AND lv_lifnr IS NOT INITIAL AND lv_bill IS NOT INITIAL  .
    SELECT SINGLE
    xblnr ,
    lifnr FROM rbkp INTO  @DATA(wa_rbkp)
          WHERE xblnr = @lv_bill
          AND lifnr   = @lv_lifnr .
    IF sy-subrc = 0 .
      MESSAGE 'Bill Number is already existed for the same Vendor' TYPE 'I' DISPLAY LIKE  'E' .
    ENDIF .
  ENDIF .

  IF lv_bill IS NOT INITIAL AND wa_rbkp IS INITIAL. "AND LV_INVOICE_NO IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0 .
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.
*******************************************
  IF wa_zinw_t_hdr-qr_code IS NOT INITIAL .
    LOOP AT SCREEN.
      IF screen-group1 = 'G2'.
        screen-input = 0.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.

******************************************

  IF lv_invoice_no IS NOT INITIAL AND lv_qr IS INITIAL .
    LOOP AT SCREEN.
      IF lv_payment IS INITIAL AND screen-name = 'PAYMENT'.
        screen-input = 1.
        MODIFY SCREEN .
      ELSE.
        screen-input = 0.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.

*  IF it_final IS NOT INITIAL AND lv_qr IS INITIAL .
*    LOOP AT SCREEN.
*      IF screen-name = 'REFRESH'.
*        screen-input = 1.
*        MODIFY SCREEN .
*      ENDIF.
*    ENDLOOP.
*  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SETUP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setup_alv .
  CREATE OBJECT container
    EXPORTING
      container_name = 'CONTAINER'.
  CREATE OBJECT grid
    EXPORTING
      i_parent = container.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_grid .

  REFRESH lt_fieldcat.
  DATA: wa_fc  TYPE  lvc_s_fcat.
*
  wa_fc-col_pos   = '1'.
  wa_fc-fieldname = 'QR_CODE'.
  wa_fc-tabname   = 'IT_FINAL1'.
  wa_fc-scrtext_l = 'Qr Code'.
  wa_fc-outputlen = '20'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '2'.
  wa_fc-fieldname = 'SERVICE_PO'.
  wa_fc-tabname   = 'IT_FINAL1'.
  wa_fc-scrtext_l = 'Service Po'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


  wa_fc-col_pos   = '3'.
  wa_fc-fieldname = 'AMOUNT'.
  wa_fc-tabname   = 'IT_FINAL1'.
  wa_fc-scrtext_l = 'Amount'.
  wa_fc-do_sum    = 'X' .
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  APPEND VALUE #( col_pos = 4 fieldname = 'TAX' tabname = 'IT_FINAL1' scrtext_m = 'Tax Amount' do_sum = 'X' ) TO lt_fieldcat.   " Suri : 02.04.2020
  APPEND VALUE #( col_pos = 5 fieldname = 'TDS' tabname = 'IT_FINAL1' scrtext_m = 'TDS Amount' do_sum = 'X' ) TO lt_fieldcat.   " Suri : 02.04.2020

  wa_fc-col_pos   = '6'.
  wa_fc-fieldname = 'LR_NO'.
  wa_fc-tabname   = 'IT_FINAL1'.
  wa_fc-scrtext_l = 'LR No'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  PERFORM exclude_tb_functions CHANGING lt_exclude.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = lt_exclude
      is_layout                     = lw_layo
    CHANGING
      it_outtab                     = it_final1[] "it_item[]
      it_fieldcatalog               = lt_fieldcat
*     IT_SORT                       = IT_SORT[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

  IF grid IS BOUND.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.
    CALL METHOD grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
    ENDIF .
  ENDIF .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_functions  CHANGING lt_exclude TYPE ui_functions.

  DATA ls_exclude TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
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
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO lt_exclude.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_INVOICE_POST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bapi_invoice_post .

  TYPES : BEGIN OF ty_ekkn ,
            ebeln TYPE ebeln,
            sakto TYPE saknr,
            gsber TYPE gsber,
            kostl TYPE kostl,
            kokrs TYPE kokrs,
            prctr TYPE prctr,
          END OF ty_ekkn .
  TYPES : BEGIN OF ty_ekko ,
            ebeln TYPE ebeln,
            bukrs TYPE bukrs,
            waers TYPE waers,
            lifnr TYPE lifnr,
          END OF ty_ekko .

  TYPES : BEGIN OF ty_ekbe ,
            ebeln TYPE ebeln,
            belnr TYPE mblnr,
            bewtp TYPE bewtp,
          END OF ty_ekbe .

  TYPES : BEGIN OF ty_esll ,
            packno     TYPE  esll-packno,
            sub_packno TYPE esll-sub_packno,
          END OF ty_esll .

  DATA : it_ekkn TYPE TABLE OF ty_ekkn,
         it_ekko TYPE TABLE OF ty_ekko,
         it_ekbe TYPE TABLE OF ty_ekbe,
         it_esll TYPE TABLE OF ty_esll,
         wa_ekkn TYPE ty_ekkn,
*         WA_ESLL TYPE TY_ESLL,
         wa_ekbe TYPE ty_ekbe,
         wa_ekko TYPE ty_ekko.

  TYPES :BEGIN OF ty_return ,
           type       TYPE bapi_mtype,
           id         TYPE symsgid,
           number     TYPE symsgno,
           message    TYPE bapi_msg,
           log_no     TYPE balognr,
           log_msg_no TYPE balmnr,
           message_v1 TYPE symsgv,
           message_v2 TYPE symsgv,
           message_v3 TYPE symsgv,
           message_v4 TYPE symsgv,
         END OF ty_return .

  DATA : wa_headerdata     TYPE bapi_incinv_create_header,
         it_itemdata       TYPE TABLE OF bapi_incinv_create_item,
         wa_itemdata       TYPE  bapi_incinv_create_item,
         it_accountingdata TYPE TABLE OF bapi_incinv_create_account,
         wa_accountingdata TYPE bapi_incinv_create_account,
         withtaxdata       TYPE TABLE OF bapi_incinv_create_withtax.

  DATA : tot_amount TYPE bapi_rmwwr .
  DATA : it_return  TYPE TABLE OF bapiret2,
         it_return1 TYPE TABLE OF ty_return,
         wa_return  TYPE bapiret2,
         wa_return1 TYPE ty_return.

  SELECT
    ebeln
    bukrs
    waers
    lifnr
    FROM ekko INTO TABLE it_ekko
          FOR ALL ENTRIES IN it_final1
          WHERE  ebeln = it_final1-service_po .
  READ TABLE it_ekko INTO wa_ekko INDEX 1.
  SELECT
    ekpo~ebeln,
    ekpo~ebelp,
    ekpo~mwskz
     FROM ekpo INTO TABLE @DATA(it_ekpo1)
               FOR ALL ENTRIES IN @it_final1
               WHERE ebeln = @it_final1-service_po .
  SELECT
     ebeln
     sakto
     gsber
     kostl
     kokrs
     prctr FROM ekkn INTO TABLE it_ekkn
           FOR ALL ENTRIES IN it_final1
           WHERE ebeln  = it_final1-service_po .
  READ TABLE it_ekkn INTO wa_ekkn INDEX 1.
  SELECT
    ebeln
    belnr
    bewtp FROM ekbe INTO TABLE it_ekbe
          FOR ALL ENTRIES IN it_final1
          WHERE ebeln = it_final1-service_po AND bewtp = 'D'.

  IF it_ekbe IS NOT INITIAL.

    SELECT
      essr~lblni ,
      essr~ebeln ,
      essr~packno FROM essr INTO TABLE @DATA(it_essr)
                  FOR ALL ENTRIES IN @it_ekbe
                  WHERE  ebeln = @it_ekbe-ebeln
                  AND lblni = @it_ekbe-belnr.

  ENDIF.
  IF it_essr IS NOT INITIAL.
    SELECT
      packno
      sub_packno FROM esll INTO TABLE it_esll
                      FOR ALL ENTRIES IN it_essr
                      WHERE packno = it_essr-packno .
  ENDIF.
  IF it_esll IS NOT INITIAL.
    SELECT
      esll~packno ,
      esll~extrow ,
      esll~sub_packno ,
      esll~menge ,
      esll~meins ,
      esll~brtwr  FROM esll INTO TABLE @DATA(it_esll1)
                      FOR ALL ENTRIES IN @it_esll
                      WHERE packno = @it_esll-sub_packno .
  ENDIF.

  wa_headerdata-invoice_ind = 'X'.
  wa_headerdata-doc_type = 'RE'.
  wa_headerdata-doc_date = sy-datum.
  wa_headerdata-pstng_date = sy-datum.
  wa_headerdata-ref_doc_no = lv_bill.
  wa_headerdata-comp_code = wa_ekko-bukrs.
  wa_headerdata-currency = wa_ekko-waers.
  wa_headerdata-calc_tax_ind = 'X' .
  wa_headerdata-bus_area = wa_ekkn-gsber .
  wa_headerdata-business_place = '1000'.
  wa_headerdata-secco = '1000' .  " added by Suri : 27.03.2020
  wa_headerdata-de_cre_ind = 'S' .
  DATA : lv_inv TYPE rblgp  .
  SORT it_esll1 BY packno extrow .
  LOOP AT it_esll1 ASSIGNING FIELD-SYMBOL(<wa_esll1>) .

    READ TABLE it_esll ASSIGNING  FIELD-SYMBOL(<wa_esll>) WITH KEY sub_packno = <wa_esll1>-packno .
    IF <wa_esll> IS ASSIGNED .
      READ TABLE it_essr ASSIGNING FIELD-SYMBOL(<wa_essr>) WITH KEY packno = <wa_esll>-packno .
    ENDIF.
    IF <wa_essr> IS ASSIGNED .
      READ TABLE it_ekbe INTO wa_ekbe WITH KEY belnr = <wa_essr>-lblni.
      IF sy-subrc = 0.
        wa_itemdata-sheet_no = wa_ekbe-belnr.
      ENDIF.
    ENDIF.

    LOOP AT it_final1 INTO wa_final WHERE  service_po = wa_ekbe-ebeln .
      lv_inv = lv_inv + 1 .
      wa_itemdata-invoice_doc_item = lv_inv .
      wa_accountingdata-invoice_doc_item = lv_inv .
      wa_itemdata-item_amount = <wa_esll1>-brtwr .
      wa_itemdata-quantity = <wa_esll1>-menge .
      wa_itemdata-po_unit = <wa_esll1>-meins .
      wa_itemdata-po_unit_iso = <wa_esll1>-meins .
      wa_itemdata-sheet_item = <wa_esll1>-extrow .
      wa_accountingdata-serial_no = '01'.
      wa_accountingdata-item_amount = <wa_esll1>-brtwr .
      wa_accountingdata-quantity = <wa_esll1>-menge .
      wa_accountingdata-po_unit = <wa_esll1>-meins .
      READ TABLE it_ekkn INTO wa_ekkn WITH KEY  ebeln = wa_final-service_po .
      IF sy-subrc = 0.
        wa_accountingdata-gl_account = wa_ekkn-sakto.
        wa_accountingdata-costcenter = wa_ekkn-kostl.
        wa_accountingdata-bus_area   = wa_ekkn-gsber.
        wa_accountingdata-co_area   = wa_ekkn-kokrs.
        wa_accountingdata-profit_ctr   = wa_ekkn-prctr.
      ENDIF.
      READ TABLE it_ekpo1 ASSIGNING FIELD-SYMBOL(<wa_ekpo1>) WITH KEY ebeln = wa_final-service_po .
      IF sy-subrc = 0 .
        wa_itemdata-po_number = wa_final-service_po .
        wa_itemdata-po_item = <wa_ekpo1>-ebelp .
        wa_itemdata-tax_code = <wa_ekpo1>-mwskz .
        wa_accountingdata-tax_code = <wa_ekpo1>-mwskz .
      ENDIF .
      APPEND : wa_itemdata TO it_itemdata .
      CLEAR : wa_itemdata.
      APPEND : wa_accountingdata TO it_accountingdata .
      CLEAR : wa_accountingdata .
    ENDLOOP.
  ENDLOOP.
  LOOP AT it_final1 INTO wa_final.
    wa_headerdata-gross_amount = wa_headerdata-gross_amount + wa_final-amount + wa_final-tax.
  ENDLOOP.

*** Start Of Changes by Suri : 02.04.2020 : For TDS tax
  IF gs_whtax IS NOT INITIAL.
    APPEND VALUE #( split_key = '000001' wi_tax_type = gs_whtax-witht wi_tax_code = gs_whtax-wt_withcd ) TO withtaxdata.
  ENDIF.
*** End Of Changes by Suri : 02.04.2020 : For TDS tax

  DATA : lv_invoice TYPE bapi_incinv_fld-inv_doc_no,
         lv_year    TYPE bapi_incinv_fld-fisc_year.
  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
    EXPORTING
      headerdata       = wa_headerdata
    IMPORTING
      invoicedocnumber = lv_invoice
      fiscalyear       = lv_year
    TABLES
      itemdata         = it_itemdata
      accountingdata   = it_accountingdata
      withtaxdata      = withtaxdata
      return           = it_return.

  DATA : lv_text(30) TYPE c .
  IF lv_invoice IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    lv_invoice_no = lv_invoice .
    CONCATENATE lv_invoice ' Invoice Successfully Created' INTO DATA(lv_msg) .
    MESSAGE lv_msg TYPE 'S' .
  ELSE .
    LOOP AT it_return INTO wa_return WHERE type = 'E'.
      wa_return1-type       = wa_return-type      .
      wa_return1-id         = wa_return-id        .
      wa_return1-number     = wa_return-number    .
      wa_return1-message    = wa_return-message   .
      wa_return1-log_no     = wa_return-log_no    .
      wa_return1-log_msg_no = wa_return-log_msg_no.
      wa_return1-message_v1 = wa_return-message_v1.
      wa_return1-message_v2 = wa_return-message_v2.
      wa_return1-message_v3 = wa_return-message_v3.
      wa_return1-message_v4 = wa_return-message_v4.
      APPEND wa_return1 TO it_return1 .
    ENDLOOP.
  ENDIF.

  IF it_return1 IS NOT INITIAL .
    DATA : wa_layout   TYPE slis_layout_alv.
    DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
          wa_fieldcat TYPE slis_fieldcat_alv.

    DATA: it_sort TYPE slis_t_sortinfo_alv,
          wa_sort TYPE slis_sortinfo_alv.

*    WA_FIELDCAT-FIELDNAME = 'SL_NO'.
*    WA_FIELDCAT-SELTEXT_L =  'Serial No'.
*    APPEND WA_FIELDCAT TO IT_FIELDCAT.
*    CLEAR   WA_FIELDCAT  .

    wa_fieldcat-fieldname = 'TYPE'.
    wa_fieldcat-seltext_l = 'TYPE'.
    APPEND wa_fieldcat TO it_fieldcat.
    CLEAR   wa_fieldcat  .

    wa_fieldcat-fieldname = 'ID'.
    wa_fieldcat-seltext_l = 'ID'.
    APPEND wa_fieldcat TO it_fieldcat.
    CLEAR   wa_fieldcat  .

    wa_fieldcat-fieldname = 'MESSAGE'.
    wa_fieldcat-seltext_l = 'MESSAGE'.
    APPEND wa_fieldcat TO it_fieldcat.
    CLEAR   wa_fieldcat  .
    wa_layout-zebra = 'X'.
    wa_layout-colwidth_optimize = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_buffer_active    = ' '
        i_callback_program = sy-repid
        is_layout          = wa_layout
*       I_CALLBACK_USER_COMMAND     = 'USER_COMMAND'
*       I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
        it_fieldcat        = it_fieldcat
        it_sort            = it_sort
        i_default          = 'X'
        i_save             = 'A'
      TABLES
        t_outtab           = it_return1
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAYMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM payment .

  IF  lv_payment IS INITIAL.
    SELECT SINGLE * FROM rbkp INTO wa_rbkp_iv WHERE belnr = lv_invoice_no.
    DATA(lv_doc) = wa_rbkp_iv-belnr && wa_rbkp_iv-gjahr.
    SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE awkey = lv_doc.
    SELECT SINGLE * FROM bseg INTO wa_bseg WHERE awkey = lv_doc AND koart = 'K'.  " Added By Suri : for TDS in Payment : 08.04.2020
    SELECT SINGLE * FROM bsik INTO wa_bsik WHERE bukrs = wa_bkpf-bukrs AND belnr = wa_bkpf-belnr  AND gjahr = wa_bkpf-gjahr.
    PERFORM fm_bapi_clear .
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
*& Form FM_BAPI_CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fm_bapi_clear .


********************** Local Declartion ********************************
  DATA : ls_status TYPE zinw_t_status.
  DATA : lv_mode  TYPE c VALUE 'N',
         lv_msgid LIKE sy-msgid,
         lv_msgno LIKE sy-msgno,
         lv_msgty LIKE sy-msgty,
         lv_msgv1 LIKE sy-msgv1,
         lv_msgv2 LIKE sy-msgv2,
         lv_msgv3 LIKE sy-msgv3,
         lv_msgv4 LIKE sy-msgv4,
         lv_subrc LIKE sy-subrc.

  DATA: lt_blntab  TYPE TABLE OF blntab,
        ls_blntab  TYPE blntab,
        lt_clear   TYPE TABLE OF ftclear,
        ls_clear   TYPE ftclear,
        lt_post    TYPE TABLE OF ftpost,
        ls_post    TYPE ftpost,
        lt_tax     TYPE TABLE OF fttax,
        lv_doc_dt  TYPE c LENGTH 10,
        lv_post_dt TYPE c LENGTH 10,
        lv_count   TYPE i VALUE 0,
        lv_message TYPE c LENGTH 100.

*** Step:1 Starting Interface
  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      i_client           = sy-mandt
      i_function         = 'C'
      i_mode             = lv_mode
      i_update           = 'S'
    EXCEPTIONS
      client_incorrect   = 1
      function_invalid   = 2
      group_name_missing = 3
      mode_invalid       = 4
      update_invalid     = 5
      OTHERS             = 6.
  IF sy-subrc <> 0.
    MESSAGE 'Error initializing posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  CLEAR  : lv_msgid, lv_msgno, lv_msgty, lv_msgv1, lv_msgv2, lv_msgv3, lv_msgv4, lv_subrc.
  CLEAR  : lv_doc_dt, lv_post_dt,  ls_clear, ls_post , lv_count .

*** Filling Tables
*** Header Info in LT_POST Table

  ls_post-stype = 'K'.                           " Header
  ls_post-count =  lv_count + 1.

  IF wa_bkpf-bldat IS NOT INITIAL.
    lv_doc_dt =  wa_bkpf-bldat+6(2) && '.' && wa_bkpf-bldat+4(2) && '.' && wa_bkpf-bldat+0(4).
  ENDIF.

  IF wa_bkpf-blart IS NOT INITIAL.
    lv_post_dt =  lv_doc_dt.
  ENDIF.

  ls_post-fnam = 'BKPF-BUKRS'.         ""Company Cd
  ls_post-fval = wa_bkpf-bukrs .
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-WAERS'.          "Doc Currency
  ls_post-fval = wa_bkpf-waers.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BLART'.          "Doc Type
  ls_post-fval =  'KZ' .
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BLDAT'.         "Doc Date
  ls_post-fval =  lv_doc_dt.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BUDAT'.         "Posting Dt
  ls_post-fval = lv_post_dt.
  APPEND ls_post TO lt_post.

  ls_post-fnam =  'BKPF-XBLNR'.        "Ref Doc
*  ls_post-fval = wa_bkpf-xblnr.
  ls_post-fval = lv_pmode.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-MONAT'.                "Period
  ls_post-fval = wa_bkpf-monat.
  APPEND ls_post TO lt_post.

*** item

  CLEAR: lv_count.
  ls_post-stype = 'P'.                          " For Item
  lv_count = lv_count + 1 .
  ls_post-count =  lv_count .

  ls_post-fnam = 'RF05A-NEWBS'.                 "Post Key
  ls_post-fval = '50'.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'RF05A-NEWKO'.                 "GL Account
  ls_post-fval = c_gl.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BSEG-WRBTR'.                  "DC Amount
*  lv_amount =    wa_rbkp_iv-rmwwr .
  lv_amount =    wa_bseg-wrbtr.              " Suri : 08.04.2020 : with TDS Amount
  ls_post-fval = lv_amount .
  CONDENSE ls_post-fval.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BSEG-BUPLA'.                 "bUSINESS Place
  ls_post-fval = wa_bsik-bupla.
  APPEND ls_post TO lt_post.

***  Start of Changes By Suri : 04.04.2020 : For Business Area
  ls_post-fnam = 'COBL-GSBER'.               " Business Area
  ls_post-fval = wa_rbkp_iv-gsber.
  APPEND ls_post TO lt_post.
***  End of Changes By Suri : 04.04.2020 : For Business Area

  ls_clear-agkoa = 'K'.                         "D-cust, K:v-vend
  ls_clear-agkon = wa_bsik-lifnr.               "Vendor Account
  ls_clear-agbuk = wa_bsik-bukrs.
  ls_clear-xnops = 'X'.
  ls_clear-xfifo = space.
  ls_clear-agums = space.
  ls_clear-avsid = space.
*  ls_clear-selfd = 'XBLNR'.
*  ls_clear-selvon = wa_bkpf-xblnr.

  ls_clear-selfd = 'BELNR'.
  ls_clear-selvon = wa_bkpf-belnr.

  APPEND ls_clear TO lt_clear.
  CLEAR: ls_clear.


  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
*      i_auglv                    = 'UMBUCHNG'
      i_auglv                    = 'AUSGZAHL'
      i_tcode                    = 'FB05'
    IMPORTING
      e_msgid                    = lv_msgid
      e_msgno                    = lv_msgno
      e_msgty                    = lv_msgty
      e_msgv1                    = lv_msgv1
      e_msgv2                    = lv_msgv2
      e_msgv3                    = lv_msgv3
      e_msgv4                    = lv_msgv4
      e_subrc                    = lv_subrc
    TABLES
      t_blntab                   = lt_blntab
      t_ftclear                  = lt_clear
      t_ftpost                   = lt_post
      t_fttax                    = lt_tax
    EXCEPTIONS
      clearing_procedure_invalid = 1
      clearing_procedure_missing = 2
      table_t041a_empty          = 3
      transaction_code_invalid   = 4
      amount_format_error        = 5
      too_many_line_items        = 6
      company_code_invalid       = 7
      screen_not_found           = 8
      no_authorization           = 9
      OTHERS                     = 10.
  CLEAR: lv_message.

  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      id        = lv_msgid
      lang      = sy-langu
      no        = lv_msgno
      v1        = lv_msgv1
      v2        = lv_msgv2
      v3        = lv_msgv3
      v4        = lv_msgv4
    IMPORTING
      msg       = lv_message
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  lv_payment = lv_msgv1 .
  MESSAGE lv_message TYPE 'I'.
** Step:3 Closing Interface
  CALL FUNCTION 'POSTING_INTERFACE_END'
    EXPORTING
      i_bdcimmed              = ' '
    EXCEPTIONS
      session_not_processable = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Error Ending posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  APPEND ls_alv TO gt_alv.
  CLEAR: ls_alv.

*    PERFORM FM_DISP_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FM_DISP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fm_disp_alv .

  DATA: str_rec_l_fcat TYPE slis_fieldcat_alv,
        itab_l_fcat    TYPE TABLE OF slis_fieldcat_alv.

  DATA: str_rec_l_layout TYPE slis_layout_alv.

  str_rec_l_fcat-fieldname = 'SNO'.
  str_rec_l_fcat-seltext_m = 'Sr.No.'.
  str_rec_l_fcat-seltext_s = 'Sr.No.'.
  str_rec_l_fcat-seltext_l = 'Sr.No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '7'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

*  STR_REC_L_FCAT-FIELDNAME = 'BUKRS'.
*  STR_REC_L_FCAT-SELTEXT_M = 'Company Code'.
*  STR_REC_L_FCAT-SELTEXT_S = 'Company Code'.
*  STR_REC_L_FCAT-SELTEXT_L = 'Company Code'.
*  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
*  STR_REC_L_FCAT-OUTPUTLEN = '15'.
*  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
*  CLEAR  STR_REC_L_FCAT.

  str_rec_l_fcat-fieldname = 'GJAHR'.
  str_rec_l_fcat-seltext_m = 'Fiscal Year'.
  str_rec_l_fcat-seltext_s = 'Fiscal Year'.
  str_rec_l_fcat-seltext_l = 'Fiscal Year'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'LIFNR'.
  str_rec_l_fcat-seltext_m = 'Vendor No.'.
  str_rec_l_fcat-seltext_s = 'Vendor No.'.
  str_rec_l_fcat-seltext_l = 'Vendor No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'NAME1'.
  str_rec_l_fcat-seltext_m = 'Vendor Name'.
  str_rec_l_fcat-seltext_s = 'Vendor Name'.
  str_rec_l_fcat-seltext_l = 'Vendor Name'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '15'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'WRBTR'.
  str_rec_l_fcat-seltext_m = 'Clearing Amount'.
  str_rec_l_fcat-seltext_s = 'Clearing Amount'.
  str_rec_l_fcat-seltext_l = 'Clearing Amount'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'V_BELNR'.
  str_rec_l_fcat-seltext_m = 'Doc. No.'.
  str_rec_l_fcat-seltext_s = 'Doc. No.'.
  str_rec_l_fcat-seltext_l = 'Doc. No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'V_AUGBL'.
  str_rec_l_fcat-seltext_m = 'Clearing Doc.No.'.
  str_rec_l_fcat-seltext_s = 'Clearing Doc.No.'.
  str_rec_l_fcat-seltext_l = 'Clearing Doc.No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '15'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'V_MESSAGE'.
  str_rec_l_fcat-seltext_m = 'Message'.
  str_rec_l_fcat-seltext_s = 'Message'.
  str_rec_l_fcat-seltext_l = 'Message'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '50'.

  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_layout-zebra = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = str_rec_l_layout
      it_fieldcat   = itab_l_fcat
    TABLES
      t_outtab      = gt_alv
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
