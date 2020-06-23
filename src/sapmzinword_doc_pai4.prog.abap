*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  DATA(ok_ucomm)  = ok_code.
  GET CURSOR FIELD lv_cur_field.
  CASE ok_ucomm.
    WHEN c_save.
      IF lv_mod <> c_d.
        PERFORM save_data.
        lv_mod = c_d.
        PERFORM lock_objects USING lv_mod.
      ENDIF.
    WHEN c_enter.
      PERFORM update_totals.
    WHEN c_display.
      lv_mod = c_d.
      PERFORM get_data.
    WHEN c_edit.
      CLEAR : lv_trns, wa_hdr.
      lv_mod = c_e1.
      PERFORM lock_objects USING lv_mod.
      PERFORM get_data.
    WHEN c_back OR c_exit OR c_cancel.
      PERFORM lock_objects USING c_d.
      LEAVE TO SCREEN 0.
    WHEN c_tat.
*** Tatkal PO Creation
      PERFORM create_tatkal_po.
    WHEN c_math.
*** Quantity Matched
      PERFORM update_status.
    WHEN c_debit.
*** Debit Note Creation
      PERFORM lock_objects USING c_e1.
      LEAVE TO TRANSACTION 'ZR_PO'.
    WHEN c_print.
*** Printing Form : Inward Doc
      IF wa_hdr-qr_code IS NOT INITIAL.
        PERFORM tp2_form IN PROGRAM zmm_grpo_det_rep USING wa_hdr-qr_code.
      ENDIF.
    WHEN c_tat_d.
***  Calling Tatkal PO
      CHECK  wa_hdr-tat_po IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          lv_ebeln       = wa_hdr-tat_po
          tatkal_po      = c_x   " Purchasing Document Number
          print_prieview = c_x.  " Single-Character Flag
    WHEN c_debit_d.
***  Calling Return PO
      CHECK  wa_hdr-return_po IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          lv_ebeln       = wa_hdr-return_po
          return_po      = c_x         " Purchasing Document Number
          print_prieview = c_x.        " Single-Character Flag
    WHEN c_refresh.
    WHEN c_close.
      PERFORM lock_objects USING c_e.
      PERFORM complite_doc.
    WHEN c_inv.
      PERFORM lock_objects USING c_e.
      SUBMIT zfi_miro WITH p_qr = wa_hdr-qr_code AND RETURN.
    WHEN c_apr1.
***  APPROVAL 1
      PERFORM lock_objects USING c_e1.
      SELECT SINGLE parid FROM usr05 INTO lv_approval WHERE bname = sy-uname AND parid = c_approval1 .
      IF sy-subrc IS INITIAL.
***     Invocie & Debit Note
        SUBMIT zfi_miro WITH p_qr = wa_hdr-qr_code AND RETURN.
      ELSE.
        MESSAGE s056(zmsg_cls) DISPLAY LIKE c_e1 WITH 'Level 1'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN c_apr2.
***  Approval 2
      PERFORM lock_objects USING c_e1.
      SELECT SINGLE parid FROM usr05 INTO lv_approval WHERE bname = sy-uname AND parid = c_approval2 .
      IF sy-subrc IS INITIAL.
        PERFORM update_invocie_approve USING 'L2' 'Level 2'.
      ELSE.
        MESSAGE s056(zmsg_cls) DISPLAY LIKE c_e1 WITH 'Level 2'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN c_apr3.
***  Approval 3
      PERFORM lock_objects USING c_e1.
      SELECT SINGLE parid FROM usr05 INTO lv_approval WHERE bname = sy-uname AND parid = c_approval3.
      IF sy-subrc IS INITIAL.
        PERFORM update_invocie_approve USING 'L3' 'Level 3'.
      ELSE.
        MESSAGE s056(zmsg_cls) DISPLAY LIKE 'E' WITH 'Level 3'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN c_pay.
      BREAK samburi.
***  Payment FB05
      IF wa_hdr-cfo_print_s IS NOT INITIAL.
        PERFORM lock_objects USING c_e1.
        IF wa_payment-payment_mode IS INITIAL.
          MESSAGE s096(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE TO LIST-PROCESSING.
        ELSE.
          SUBMIT zfi_payment WITH p_qr = wa_hdr-qr_code WITH p_pmode = wa_payment-payment_mode AND RETURN.
        ENDIF.
      ELSE.
        MESSAGE s084(zmsg_cls) DISPLAY LIKE 'E'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN c_grpo_p.
      PERFORM print_grpo_price_list.
    WHEN c_grpo_s.
      PERFORM print_grpo_summery.
    WHEN c_trns.
***  Calling Service PO
      CHECK  wa_hdr-service_po IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          lv_ebeln       = wa_hdr-service_po
          print_prieview = c_x
          service_po     = c_x.
    WHEN c_pay_adv.
      PERFORM payment_advice.
    WHEN c_auditor.
      PERFORM lock_objects USING c_e1.
      PERFORM update_auditor_check.
  ENDCASE.
  CLEAR : ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_PO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_po INPUT.
  PERFORM validate_po.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear INPUT.
  IF ok_code = c_exit OR ok_code = c_cancel.
    PERFORM clear.
  ENDIF.
  IF sy-ucomm = c_clear.
    PERFORM clear_all.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_QR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_qr INPUT.
  PERFORM validate_qr.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_HEADER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header INPUT.
  PERFORM validate_header .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_TRANS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_trans INPUT.
  PERFORM f4_trans.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CLEAR_ALL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_all INPUT.
  PERFORM clear_all.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_CHARGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_charges INPUT.
  PERFORM validate_charges.
ENDMODULE.

MODULE f4_paymode INPUT.
  PERFORM f4_paymode.
ENDMODULE.
