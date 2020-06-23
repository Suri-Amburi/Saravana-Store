*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  PERFORM get_data .
  ok_code = sy-ucomm .

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0 .
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0 .
    WHEN 'SAVE' .
    PERFORM bal_validation.
    READ TABLE it_final ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY tax_per = ' '.
     IF sy-subrc = 0 AND sy-ucomm <> 'REF'.
       MESSAGE 'Tax code is not there in all line item' TYPE 'E' DISPLAY LIKE 'S'.
     ELSE.
       REFRESH it_log.
      PERFORM create_rpo .
   IF it_log IS NOT INITIAL.
    PERFORM messages.
  ENDIF.
     ENDIF.

    WHEN 'REF' .
*      CALL TRANSACTION 'ZRETPO'.
   CLEAR: lv_batch,lv_ebeln , gv_mblnr_n ,  lv_debit_note, lv_werks.
   REFRESH: it_final, it_log.
   CALL METHOD grid->refresh_table_display.

  WHEN 'PRINT'.
    CHECK lv_ebeln IS NOT INITIAL.
    CALL FUNCTION 'ZFM_PURCHASE_FORM1'
      EXPORTING
        lv_ebeln               = lv_ebeln
       vendor_return_po        = 'X'
       print_prieview          = 'X'.

  WHEN 'PRINT_D'.
    CHECK lv_ebeln IS NOT INITIAL.
    CALL FUNCTION 'ZFM_PURCHASE_FORM1'
      EXPORTING
        lv_ebeln               = lv_ebeln
       vendor_debit_note        = 'X'
       print_prieview           = 'X'.

  ENDCASE.
  CLEAR : ok_code , sy-ucomm .
ENDMODULE.
