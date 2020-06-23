*&---------------------------------------------------------------------*
*& Include          SAPMZHUSTO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save .

IF it_final IS NOT INITIAL.
  PERFORM create_stopo.
ELSE.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = ' NOTHING '.
            gw_mess-mess2 = ' IS '.
            gw_mess-mess3 = ' SCANNED !!!! '.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM enter .
    IF wa_hdr-exidv IS NOT INITIAL.

    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_STOPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_stopo .

CLEAR: header, headerx,it_return,item[], itemx[].
READ TABLE it_final INTO DATA(wa_final) INDEX 1.

 DATA : lv_doc TYPE esart .
  lv_doc = 'ZUB' .
  header_no_pp      = 'X'.
  header-comp_code  = '1000'.
  header-creat_date = sy-datum .
  header-doc_type   = lv_doc .
  header-langu      = sy-langu .
  header-currency   = 'INR'.
  header-purch_org  = '1000'.
  header-pur_group  = 'P03'.
  header-suppl_plnt = wa_hdr-werks .
  header-currency     = header-currency_iso  = 'INR'.

  headerx-comp_code    = 'X'.
  headerx-creat_date   = 'X'.
  headerx-doc_type     = 'X' .
  headerx-langu        = 'X' .
  headerx-purch_org    = 'X' .
  headerx-pur_group    = 'X' .
  headerx-currency     = 'X'.
  headerx-suppl_plnt   = 'X'.
  headerx-currency     = headerx-currency_iso  = 'INR'.

  DATA : lv_poitem TYPE ebelp.

DATA(it_final1) = it_final.
SORT it_final1 BY matnr charg.
DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING matnr charg.
CLEAR: wa_item, wa_itemx.
 LOOP AT it_final1 ASSIGNING FIELD-SYMBOL(<ls_item>).
    lv_poitem = lv_poitem + 10.
    wa_item-po_item = wa_itemx-po_item = lv_poitem .
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_item>-matnr
      IMPORTING
        output = <ls_item>-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_item-po_item
      IMPORTING
        output = wa_item-po_item.

          DATA(mat_len) = strlen( <ls_item>-matnr ) .
           IF mat_len > 18.
             wa_item-material_long = <ls_item>-matnr.
             wa_itemx-material_long    = 'X'.
           ELSE.
             wa_item-material = <ls_item>-matnr.
             wa_itemx-material    = 'X'.
           ENDIF.

    wa_item-plant     = wa_hdr-twerks.
  LOOP AT it_final ASSIGNING FIELD-SYMBOL(<fin>) WHERE matnr = <ls_item>-matnr AND   charg = <ls_item>-charg.
    wa_item-quantity  = wa_item-quantity + <fin>-vemng.
  ENDLOOP.
    wa_item-batch     = <ls_item>-charg.
    wa_item-stge_loc  = 'FG01'.
    wa_item-po_unit   = 'EA' .
    wa_item-gi_based_gr  = 'X' .


    wa_itemx-plant        = 'X'.
    wa_itemx-quantity     = 'X'.
    wa_itemx-po_unit      = 'X'.
    wa_itemx-batch        = 'X'.
    wa_itemx-stge_loc     = 'X'.
    wa_itemx-gi_based_gr  = 'X' .
    APPEND wa_item TO item[].
    APPEND wa_itemx TO itemx[].
    CLEAR: wa_item , wa_itemx.

  ENDLOOP.
    CLEAR lv_ebeln.
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
        poitemx          = itemx.

  READ TABLE it_return[] ASSIGNING FIELD-SYMBOL(<ret>) WITH KEY type = 'E'.
   IF  sy-subrc <> '0'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.


      PERFORM create_delvery.

   ELSE .
     CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE it_return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = <ls_ret>-message_v1.
            gw_mess-mess2 = <ls_ret>-message_v2.
            gw_mess-mess3 = <ls_ret>-message_v3.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.

   ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DELVERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_delvery .
    CLEAR : it_return1, lt_sto_items, lt_sto_items[] .


    ls_sto_items-ref_doc =  lv_ebeln.
    APPEND ls_sto_items TO lt_sto_items.

    CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_STO'
      EXPORTING
        ship_point        = wa_hdr-werks
      IMPORTING
        delivery          = xsto_hdr_vbeln
      TABLES
        stock_trans_items = lt_sto_items
        return            = it_return1[].

    IF xsto_hdr_vbeln IS NOT INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      PERFORM assign_hu.
    ELSE.
          PERFORM delete_po.
          READ TABLE it_return1 ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E' id = 'BAPI'.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = <ls_ret>-message.
            gw_mess-mess2 = <ls_ret>-message_v2.
            gw_mess-mess3 = <ls_ret>-message_v3.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_HU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM assign_hu .

  REFRESH : lt_verpo,lt_hu,lt_vbpok, lt_prot.

SELECT * FROM lips INTO TABLE lt_lips_m WHERE vbeln = xsto_hdr_vbeln.
  lt_lips = lt_lips_m.

 DATA(it_final1) = it_final.

  DELETE ADJACENT DUPLICATES FROM it_final COMPARING charg.

 LOOP AT it_final ASSIGNING FIELD-SYMBOL(<ls_itemp>). "WITH KEY BATCH = WA_LIPS-CHARG.
    READ TABLE lt_lips INTO wa_lips WITH KEY charg = <ls_itemp>-charg.
    IF sy-subrc = 0.
      wa_hu-top_hu_external  = <ls_itemp>-exidv.
      wa_hu-charg            = wa_lips-charg.
      APPEND wa_hu TO lt_hu.
      CLEAR : wa_hu.

***  Batch Item
      wa_vbkok-vbeln_vl = wa_lips-vbeln.
      wa_vbpok-lgort    = wa_lips-lgort.
      wa_vbpok-charg    = wa_lips-charg.
      wa_vbpok-vbeln_vl = wa_lips-vbeln.
      wa_vbpok-posnr_vl = wa_lips-posnr.
      wa_vbpok-vbeln    = wa_lips-vbeln.
      wa_vbpok-posnn    = wa_lips-vgpos.
      wa_vbpok-kzlgo    = 'X'.
      wa_vbpok-werks    = wa_lips-werks.
      wa_vbpok-xwmpp    = 'X'.
      wa_vbpok-lgpla    = wa_lips-lgpla.
      wa_vbpok-lgtyp    = wa_lips-lgtyp.
      wa_vbpok-bwlvs    = wa_lips-bwlvs.
      wa_vbpok-matnr    = wa_lips-matnr.
      wa_vbpok-lfimg    = wa_lips-lfimg.

      DATA(sitem01) = it_final1.
      DELETE sitem01 WHERE charg <> <ls_itemp>-charg.
      DATA(hu_qty) = lines( sitem01 ).
      wa_vbpok-pikmg = hu_qty."<ls_itemp>-dlv_qty.

****  FOR PACKING
      wa_verpo-exidv_ob = wa_final-exidv.
      wa_verpo-vbeln = wa_lips-vbeln.
      wa_verpo-posnr = wa_lips-posnr.
      wa_verpo-tmeng = wa_vbpok-pikmg.

      APPEND wa_verpo TO lt_verpo.
      APPEND wa_vbpok TO lt_vbpok.
      CLEAR:wa_vbpok,wa_verpo, wa_lips.
    ENDIF.
  ENDLOOP.

  CHECK lt_hu[] IS NOT INITIAL.
*  SORT  lt_hu BY  top_hu_external charg.
  DELETE ADJACENT DUPLICATES FROM lt_hu COMPARING top_hu_external charg.
  wa_vbkok-vbeln_vl = xsto_hdr_vbeln.
  wa_vbkok-packing_refresh = 'X'.
  CALL FUNCTION 'WS_DELIVERY_UPDATE'
    EXPORTING
      vbkok_wa                    = wa_vbkok
      synchron                    = 'X'
      commit                      = 'X'
      delivery                    = wa_vbkok-vbeln_vl
      update_picking              = 'X'
      if_database_update          = '1'
      if_error_messages_send_0    = 'X'
      if_late_delivery_upd        = 'X'
    IMPORTING
      ef_error_any_0              = ls_ef_error_any
      ef_error_in_item_deletion_0 = ls_ef_error_in_item_deletion
      ef_error_in_pod_update_0    = ls_ef_error_in_pod_update
      ef_error_in_interface_0     = ls_ef_error_in_interface
      ef_error_in_goods_issue_0   = ls_ef_error_in_goods_issue
      ef_error_in_final_check_0   = ls_ef_error_in_final_check
      ef_error_partner_update     = ls_ef_error_partner_update
      ef_error_sernr_update       = ls_ef_error_sernr_update
    TABLES
      vbpok_tab                   = lt_vbpok
      prot                        = lt_prot
      it_handling_units           = lt_hu.

  READ TABLE lt_prot ASSIGNING FIELD-SYMBOL(<ls_prot>) WITH KEY msgty = 'E'.
  IF sy-subrc <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
*    MESSAGE s013(zmsg_cls). "'HU Assigned to
*    DATA(lv_hu) = gv_hukey.
*    SUBMIT zmm_tray_sticker AND RETURN WITH p_hu = lv_hu.
*    LEAVE TO SCREEN 0.
         READ TABLE lt_prot INTO DATA(ls_ret) WITH KEY msgty = 'S'.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            CLEAR gw_mess.
            gw_mess-err   = 'S'.
            gw_mess-mess1 = 'DATA SAVED'.
            gw_mess-mess2 = lv_ebeln && '-' && 'PO'.
            gw_mess-mess3 = xsto_hdr_vbeln && '-' && 'DELIVERY'.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.


  ELSE.
    PERFORM delete_po.
*    MESSAGE ID <ls_prot>-msgid TYPE <ls_prot>-msgty NUMBER <ls_prot>-msgno WITH <ls_prot>-msgv1 <ls_prot>-msgv2
*        <ls_prot>-msgv3 <ls_prot>-msgv4.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = <ls_prot>-msgid.
            gw_mess-mess2 = <ls_prot>-msgno.
            gw_mess-mess3 = <ls_prot>-msgv1.
            gw_mess-mess4 = <ls_prot>-msgv2.
            gw_mess-mess5 = <ls_prot>-msgv3.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_po .

DATA: wa_purchaseorder TYPE bapimepoheader-po_number,
      it_poitem  TYPE STANDARD TABLE OF bapimepoitem,
      wa_poitem  TYPE bapimepoitem,
      it_poitemx TYPE STANDARD TABLE OF bapimepoitemx,
      wa_poitemx TYPE bapimepoitemx,
      it_return  TYPE TABLE OF bapiret2.


 IF lv_ebeln IS NOT INITIAL.

  wa_purchaseorder = lv_ebeln.

   SELECT ebeln,ebelp FROM ekpo INTO TABLE @DATA(it_po) WHERE ebeln = @lv_ebeln.

   LOOP AT it_po ASSIGNING FIELD-SYMBOL(<po>).

     wa_poitem-po_item     = <po>-ebelp.
     wa_poitem-delete_ind  = 'X'.

     wa_poitemx-po_item     = <po>-ebelp.
     wa_poitemx-po_itemx    = 'X'.
     wa_poitemx-delete_ind  = 'X'.

     APPEND wa_poitem TO it_poitem.
     APPEND wa_poitemx TO it_poitemx.

    CLEAR: wa_poitem,wa_poitemx.

   ENDLOOP.

   CALL FUNCTION 'BAPI_PO_CHANGE'
     EXPORTING
       purchaseorder               = wa_purchaseorder
     TABLES
      return                       = it_return
      poitem                       = it_poitem
      poitemx                      = it_poitemx
             .
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
 EXPORTING
   wait          = 'X'.

REFRESH:it_return,
        it_poitem,
        it_poitemx.

CLEAR: wa_poitem, wa_poitemx.


ENDIF.

ENDFORM.
