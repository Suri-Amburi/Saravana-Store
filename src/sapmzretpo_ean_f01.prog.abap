*&---------------------------------------------------------------------*
*& Include          SAPMZRETPO_EAN_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GLOBAL_VARIABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM global_variables .

REFRESH: it_final.
CLEAR: lv_werks, lv_lifnr,lv_name1,lv_ean,lv_count,lv_ekgrp,lv_lean ,lv_maktx,wa_final.
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
CHECK it_final IS NOT INITIAL.
DATA(it_final1) = it_final.

SORT it_final1 BY charg.
DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING charg.

READ TABLE it_final1 INTO DATA(wa_final1) INDEX 1.


  header_no_pp = 'X'.
  header-comp_code  = '1000'.
  header-creat_date = sy-datum .
  header-vendor     = wa_final1-lifnr.
  header-doc_type   = 'ZRET' .
  header-langu      = sy-langu .
  header-currency   = 'INR'.
  header-purch_org  = '1000'.
  header-pur_group  = wa_final1-ekgrp .

  headerx-comp_code   = 'X'.
  headerx-creat_date  = 'X'.
  headerx-vendor      = 'X'.
  headerx-doc_type    = 'X' .
  headerx-langu       = 'X' .
  headerx-purch_org   = 'X' .
  headerx-pur_group   = 'X' .
  headerx-currency    = 'X'.

  REFRESH: item,itemx,it_pocond,it_pocondx,it_return.
  CLEAR  : lv_poitem.

  LOOP AT it_final1 ASSIGNING FIELD-SYMBOL(<ls_item>).
    lv_poitem           = lv_poitem + 10.
    item-po_item        = itemx-po_item = lv_poitem .
    item-tax_code       = <ls_item>-mwsk1.
    item-po_item        = |{ item-po_item ALPHA = IN }|.

    DATA(mat_len) = strlen( <ls_item>-matnr ) .
    IF mat_len > 18.
      item-material_long = <ls_item>-matnr.
      itemx-material_long    = 'X'.
    ELSE.
      item-material =   <ls_item>-matnr.
      itemx-material    = 'X'.
    ENDIF.
    item-plant     = <ls_item>-werks.

    LOOP AT it_final ASSIGNING FIELD-SYMBOL(<fs>) WHERE charg = <ls_item>-charg.
        item-quantity  =  item-quantity  + <fs>-menge.
    ENDLOOP.
    item-net_price =  <ls_item>-verpr.
    item-stge_loc  = 'FG01'.
    item-ret_item  = 'X'.
    SELECT SINGLE meins FROM mara INTO item-po_unit  WHERE matnr = <ls_item>-matnr.

    itemx-plant       = 'X'.
    itemx-quantity    = 'X'.
    itemx-po_unit     = 'X'.
    itemx-net_price   = 'X'.
    itemx-batch       = 'X'.
    itemx-stge_loc    = 'X'.
    itemx-ret_item    = 'X'.
    itemx-tax_code    = 'X'.
    APPEND item.
    APPEND itemx .

    wa_pocond-itm_number = item-po_item.
    wa_pocond-calctypcon = 'C' .
    wa_pocond-cond_value = <ls_item>-verpr / 10.
    wa_pocond-change_id  = 'U'.
    APPEND wa_pocond TO it_pocond.
    CLEAR wa_pocond.

    wa_pocondx-itm_number = item-po_item.
    wa_pocondx-itm_numberx = 'X'.
    wa_pocondx-cond_type  = 'X'.
    wa_pocondx-cond_value = 'X'.
    wa_pocondx-calctypcon = 'X'.
    wa_pocondx-change_id  = 'X'.
    APPEND wa_pocondx TO it_pocondx.
    CLEAR wa_pocondx.

    wa_pocond-itm_number = item-po_item.
    wa_pocond-cond_type  = 'ZDS1'.
    wa_pocond-calctypcon = 'A' .
    wa_pocond-cond_value = '0.00'.
    wa_pocond-change_id  = 'U'.
    APPEND wa_pocond TO it_pocond.
    CLEAR wa_pocond.

    wa_pocondx-itm_number = item-po_item.
    wa_pocondx-itm_numberx = 'X'.
    wa_pocondx-cond_type   = 'X'.
    wa_pocondx-cond_value  = 'X'.
    wa_pocondx-calctypcon  = 'X'.
    wa_pocondx-change_id   = 'X'.
    APPEND wa_pocondx TO it_pocondx.
    CLEAR wa_pocondx.

    CLEAR : itemx , item.
  ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = header
        poheaderx        = headerx
        no_price_from_po = 'X'
      IMPORTING
        exppurchaseorder = lv_ebeln
      TABLES
        return           = it_return[]
        poitem           = item
        poitemx          = itemx
        pocond           = it_pocond
        pocondx          = it_pocondx.

    READ TABLE it_return[] ASSIGNING FIELD-SYMBOL(<ret>) WITH KEY type = 'E'.
    IF  sy-subrc <> '0'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
            CLEAR gw_mess.
            gw_mess-err   = 'S'.
            gw_mess-mess1 = lv_ebeln.
            gw_mess-mess2 = 'PO'.
            gw_mess-mess3 = 'CREATED'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
    ELSE .
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE it_return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
           CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = <ls_ret>-message+0(20).
            gw_mess-mess2 = <ls_ret>-message+20(20).
            gw_mess-mess3 = <ls_ret>-message+40(20).
            gw_mess-mess4 = <ls_ret>-message+60(20).
            gw_mess-mess5 = <ls_ret>-message+80(20).
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.

    ENDIF.

ENDFORM.
