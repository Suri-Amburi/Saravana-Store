*&---------------------------------------------------------------------*
*& Include          SAPMZ_PACKING_F01
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
***  Fecthing All Open Deliveries
  SELECT DISTINCT likp~vbeln INTO TABLE gt_lips FROM lips  AS lips INNER JOIN likp AS likp ON likp~vbeln = lips~vbeln WHERE likp~lfart = 'ZNL' AND lips~lfimg > 0 AND lips~pstyv = 'NLN'.
  gv_from = 1.
  gv_to = 7.
  SORT gt_lips BY vbeln.
  DESCRIBE TABLE gt_lips LINES gv_line.
  LOOP AT gt_lips ASSIGNING FIELD-SYMBOL(<ls_lips>)
  FROM gv_from TO gv_to.
    IF sy-tabix EQ gv_from.
      gs_del-slnum1 = sy-tabix.
      gs_del-vbeln1 = <ls_lips>-vbeln.
    ENDIF.
    IF sy-tabix EQ gv_from + 1.
      gs_del-slnum2 = sy-tabix.
      gs_del-vbeln2 = <ls_lips>-vbeln.
    ENDIF.
    IF sy-tabix EQ gv_from + 2.
      gs_del-slnum3 = sy-tabix.
      gs_del-vbeln3 = <ls_lips>-vbeln.
    ENDIF.
    IF sy-tabix EQ gv_from + 3.
      gs_del-slnum4 = sy-tabix.
      gs_del-vbeln4 = <ls_lips>-vbeln.
    ENDIF.
    IF sy-tabix EQ gv_from + 4.
      gs_del-slnum5 = sy-tabix.
      gs_del-vbeln5 = <ls_lips>-vbeln.
    ENDIF.
    IF sy-tabix EQ gv_from + 5.
      gs_del-slnum6 = sy-tabix.
      gs_del-vbeln6 = <ls_lips>-vbeln.
    ENDIF.
    IF sy-tabix EQ gv_from + 6.
      gs_del-slnum7 = sy-tabix.
      gs_del-vbeln7 = <ls_lips>-vbeln.
    ENDIF.
  ENDLOOP.
ENDFORM.


FORM process_pg_dn .

  IF gv_line > gv_to.
    CLEAR: gs_del.

    gv_from = gv_from + 7.
    gv_to = gv_to + 7.

    LOOP AT gt_lips ASSIGNING FIELD-SYMBOL(<ls_lips>)
      FROM gv_from TO gv_to.
      IF sy-tabix EQ gv_from.
        gs_del-slnum1 = sy-tabix.
        gs_del-vbeln1 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 1.
        gs_del-slnum2 = sy-tabix.
        gs_del-vbeln2 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 2.
        gs_del-slnum3 = sy-tabix.
        gs_del-vbeln3 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 3.
        gs_del-slnum4 = sy-tabix.
        gs_del-vbeln4 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 4.
        gs_del-slnum5 = sy-tabix.
        gs_del-vbeln5 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 5.
        gs_del-slnum6 = sy-tabix.
        gs_del-vbeln6 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 6.
        gs_del-slnum7 = sy-tabix.
        gs_del-vbeln7 = <ls_lips>-vbeln.
      ENDIF.
    ENDLOOP.
  ENDIF.                    "   IF gv_line > gv_to.

ENDFORM.                    " PROCESS_PG_DN!

FORM process_pg_up .

  IF gv_from > 1.
    gv_from = gv_from - 7.
    gv_to = gv_to - 7.

    CLEAR: gs_del.
    LOOP AT gt_lips ASSIGNING FIELD-SYMBOL(<ls_lips>)
      FROM gv_from TO gv_to.
      IF sy-tabix EQ gv_from.
        gs_del-slnum1 = sy-tabix.
        gs_del-vbeln1 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 1.
        gs_del-slnum2 = sy-tabix.
        gs_del-vbeln2 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 2.
        gs_del-slnum3 = sy-tabix.
        gs_del-vbeln3 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 3.
        gs_del-slnum4 = sy-tabix.
        gs_del-vbeln4 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 4.
        gs_del-slnum5 = sy-tabix.
        gs_del-vbeln5 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 5.
        gs_del-slnum6 = sy-tabix.
        gs_del-vbeln6 = <ls_lips>-vbeln.
      ENDIF.
      IF sy-tabix EQ gv_from + 6.
        gs_del-slnum7 = sy-tabix.
        gs_del-vbeln7 = <ls_lips>-vbeln.
      ENDIF.
    ENDLOOP.
  ENDIF.      "   IF gv_line > gv_to.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCAN_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM scan_batch.
  CHECK gv_charg IS NOT INITIAL.
  GET CURSOR FIELD gv_cur_field VALUE gv_cur_value.
  SELECT SINGLE mchb~matnr
         makt~maktx mchb~charg INTO ( gv_matnr , gv_maktx , gv_charg_s4 ) FROM mchb AS mchb
         INNER JOIN makt AS makt ON makt~matnr = mchb~matnr AND makt~spras = 'EN'
         WHERE mchb~charg = gv_charg AND mchb~werks = gv_plant.

  IF sy-subrc <> 0.
*    SELECT SINGLE MCH1~MATNR
*       MAKT~MAKTX ZB1_STOCK~BATCH INTO ( GV_MATNR , GV_MAKTX , GV_CHARG_S4 ) FROM MCH1 AS MCH1
*       INNER JOIN ZB1_STOCK AS ZB1_STOCK ON ZB1_STOCK~BATCH = MCH1~CHARG
*       INNER JOIN MAKT AS MAKT ON MAKT~MATNR = MCH1~MATNR AND MAKT~SPRAS = 'EN'
*       WHERE ZB1_STOCK~B1_BATCH = GV_CHARG.

    SELECT SINGLE mchb~matnr
     makt~maktx zb1_s4_map~s4_batch INTO ( gv_matnr , gv_maktx , gv_charg_s4 ) FROM mchb AS mchb
     INNER JOIN zb1_s4_map AS zb1_s4_map ON zb1_s4_map~s4_batch = mchb~charg
     INNER JOIN makt AS makt ON makt~matnr = mchb~matnr AND makt~spras = 'EN'
     WHERE zb1_s4_map~b1_batch = gv_charg AND mchb~werks = gv_plant.
    IF sy-subrc <> 0.
      MESSAGE s010(zmsg_cls) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM lips INTO @DATA(ls_lips) WHERE vbeln = @gv_del AND matnr = @gv_matnr AND pstyv = 'NLN'.
  IF ls_lips IS INITIAL.
    MESSAGE s009(zmsg_cls) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF ls_lips IS NOT INITIAL.
    DATA(lt_item_b)  = item_data.
    DELETE lt_item_b WHERE batch <> gv_charg_s4 .
    DESCRIBE TABLE lt_item_b LINES DATA(lv_lines).
    IF ( ls_lips-lfimg - ls_lips-kcmengvme ) LE lv_lines.
      MESSAGE s020(zmsg_cls) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    SUBTRACT 1 FROM gv_p_qty.
    gv_charg_s4 = |{ gv_charg_s4 ALPHA = IN }|.
    header_data-deliv_numb = gv_del .
    header_control-deliv_numb = gv_del.
    delivery = gv_del.

    ls_item_data-deliv_numb = gv_del.
    ls_item_data-deliv_item = ls_lips-posnr.
    ls_item_data-material = ls_lips-matnr.

    ls_item_data-dlv_qty = 1.
    ls_item_data-dlv_qty_imunit = 1.
    ls_item_data-fact_unit_nom = '1'.
    ls_item_data-fact_unit_denom = '1'.
    ls_item_data-sales_unit = ls_lips-vrkme.
    ls_item_data-base_uom = ls_lips-meins .
    ls_item_data-batch = gv_charg_s4 .
    SELECT SINGLE posnr FROM lips INTO @DATA(lv_posnr) WHERE vbeln = @gv_del AND matnr = @gv_matnr AND pstyv = 'YNLN'.
    IF sy-subrc = 0.
      ls_item_data-hieraritem  = lv_posnr .                 "'000010'.
    ELSE.
      ls_item_data-hieraritem  = ls_lips-posnr .            "'000010'.
    ENDIF.
    ls_item_data-usehieritm  = gv_count.
    APPEND ls_item_data TO item_data.
    CLEAR :ls_item_data, ls_item_control.
    gv_b_count = gv_b_count + 1.
    MESSAGE s014(zmsg_cls) WITH gv_b_count. "'Batch Scanned Succesffully' TYPE 'S'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_HU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_hu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLOSE_HU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM close_hu .
  SELECT * FROM lips INTO TABLE lt_lips_m WHERE vbeln = gv_del.
***  PERFORM batch_split USING gv_subrc.
***  IF gv_subrc = 0.
  PERFORM hu_process.
***  ENDIF.
ENDFORM.

FORM batch_split USING gv_subrc.

  DATA : lv_count TYPE int2.
  REFRESH : return , item_control , lt_item_data_f.
  SORT item_data BY deliv_numb deliv_item batch.
  DATA(lt_item_data)   = item_data.
  DATA(lt_item_data_i) = item_data.
  lt_item_data_f       = item_data.
  REFRESH : lt_item_data_f.
  DELETE ADJACENT DUPLICATES FROM item_data COMPARING deliv_numb deliv_item batch.
  SORT lt_item_data_i BY deliv_numb deliv_item material.
  DELETE ADJACENT DUPLICATES FROM lt_item_data_i COMPARING deliv_numb deliv_item material.
*** Header Date
  header_data-deliv_numb    = gv_del.
  header_control-deliv_numb = gv_del.
  delivery                  = gv_del.
  tec_ctrl-upd_ind          = 'U'.
***  LOOP AT lt_item_data_i ASSIGNING FIELD-SYMBOL(<ls_item_data_i>).   " Material Wise loop
***    lv_count = 1.
***    DATA(lv_item) = '900001'.
***    LOOP AT item_data ASSIGNING FIELD-SYMBOL(<ls_item_data>).        " Batch wise loop
***      DATA(lt_item) =  lt_item_data.
***      DELETE lt_item WHERE deliv_item <> <ls_item_data>-deliv_item.
***      DELETE lt_item WHERE batch <> <ls_item_data>-batch.
***      DESCRIBE TABLE lt_item LINES DATA(lv_line).
***
***      CLEAR :ls_item_data, ls_item_control.
***      READ TABLE lt_lips_m ASSIGNING FIELD-SYMBOL(<ls_lips>) WITH KEY vbeln = gv_del matnr = <ls_item_data>-material pstyv = 'NLN' .
***      IF sy-subrc = 0.
***        ls_item_data-deliv_item = <ls_lips>-posnr.
***      ENDIF.
***      ls_item_data-deliv_numb = gv_del.
***      ls_item_data-material   = <ls_item_data>-material.
***      ls_item_data-fact_unit_nom = '1'.
***      ls_item_data-fact_unit_denom = '1'.
***      ls_item_data-sales_unit = <ls_lips>-vrkme. "'EA'.
***      ls_item_data-base_uom = <ls_lips>-meins. "'EA'.
***
***      ls_item_control-deliv_numb = gv_del.
***      ls_item_control-deliv_item = ls_item_data-deliv_item.
***
***      APPEND ls_item_control TO item_control.
***      APPEND ls_item_data TO lt_item_data_f.
***      CLEAR : ls_item_data ,ls_item_control.
***
****** Btach Spilit
***      ls_item_data-batch = |{ <ls_item_data>-batch ALPHA = IN }|.
***      SELECT SINGLE lfimg FROM lips INTO @DATA(lv_menge) WHERE vbeln  = @<ls_item_data>-deliv_numb AND charg = @ls_item_data-batch.
***      IF  sy-subrc = 0 .
***        lv_line = lv_line + lv_menge.
***      ENDIF.
***
******  Checking For Line Item is Availble or not
***      READ TABLE lt_lips_m ASSIGNING FIELD-SYMBOL(<ls_lips1>) WITH KEY vbeln = gv_del matnr = <ls_item_data>-material charg = ls_item_data-batch pstyv = 'YNLN' .
***      IF sy-subrc <> 0.
***        SELECT posnr FROM lips INTO TABLE @DATA(lt_items) WHERE vbeln = @gv_del AND pstyv = 'YNLN'.
***        DESCRIBE TABLE lt_items LINES DATA(lv_items).
***        lv_item = lv_item + lv_items.
***      ELSE.
***        ls_item_data-deliv_item = <ls_lips1>-posnr.
***        ls_item_control-deliv_item = <ls_lips1>-posnr.
***      ENDIF.
***
***      ls_item_data-hieraritem  = <ls_item_data>-deliv_item.
***      ls_item_data-usehieritm  = '1'.
***
***      ls_item_data-deliv_numb = gv_del.
***      ls_item_data-material = <ls_item_data>-material.
***      ls_item_data-fact_unit_nom = '1'.
***      ls_item_data-fact_unit_denom = '1'.
***      ls_item_data-sales_unit = <ls_item_data>-sales_unit. "'EA'.
***      ls_item_data-base_uom = <ls_item_data>-base_uom. "'EA'.
***
***      ls_item_data-dlv_qty = lv_line.
***      ls_item_data-dlv_qty_imunit = lv_line.
***
***      ls_item_control-deliv_numb = gv_del.
****      LS_ITEM_CONTROL-DELIV_ITEM = LV_ITEM.
***      ls_item_control-chg_delqty = 'X'.
***
***      APPEND ls_item_control TO item_control.
***      APPEND ls_item_data TO lt_item_data_f.
***      CLEAR: ls_item_data,ls_item_control.
***      lv_count = lv_count + 1.
***      lv_item = lv_item + 1.
***    ENDLOOP.
***  ENDLOOP.
*** DELIVERY SPLIT


  LOOP AT item_data ASSIGNING FIELD-SYMBOL(<ls_item_data>).

  ENDLOOP.
  SORT lt_item_data_f BY deliv_numb deliv_item material batch.
  SORT item_control BY deliv_numb deliv_item.

  DELETE ADJACENT DUPLICATES FROM lt_item_data_f COMPARING deliv_numb deliv_item material batch.
  DELETE ADJACENT DUPLICATES FROM item_control COMPARING deliv_numb deliv_item.
  CHECK lt_item_data_f IS NOT INITIAL.

  CALL FUNCTION 'BAPI_INB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = header_data
      header_control = header_control
      delivery       = delivery
      techn_control  = tec_ctrl
    TABLES
      item_data      = lt_item_data_f
      item_control   = item_control
      return         = return.

  READ TABLE return INTO ls_return WITH TABLE KEY type = 'E'.
  IF sy-subrc = 0.
    gv_subrc = 8.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number WITH ls_return-message_v1 ls_return-message_v2
    ls_return-message_v3 ls_return-message_v4.
  ELSE.
    gv_subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HU_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hu_process .
  DATA : ls_error   TYPE xfeld,
         lt_hu      TYPE TABLE OF hum_rehang_hu,
         wa_hu      TYPE          hum_rehang_hu,
         created_hu TYPE TABLE OF vekpvb.

  DATA : ls_ef_error_any              TYPE xfeld,
         ls_ef_error_in_item_deletion TYPE xfeld,
         ls_ef_error_in_pod_update    TYPE xfeld,
         ls_ef_error_in_interface     TYPE xfeld,
         ls_ef_error_in_goods_issue   TYPE xfeld,
         ls_ef_error_in_final_check   TYPE xfeld,
         ls_ef_error_partner_update   TYPE xfeld,
         ls_ef_error_sernr_update     TYPE xfeld.

*** Updating in Delivery
  DATA : lt_lips TYPE TABLE OF lips,
         wa_lips TYPE lips,
         lt_prot TYPE TABLE OF prott.
  BREAK asarbani.
  REFRESH :itemsproposal,it_ret1,huitem,lt_hu.
  CLEAR : gv_hukey,ls_headerproposal,ls_huheader.
  SELECT SINGLE werks lgort INTO ( ls_headerproposal-plant , ls_headerproposal-stge_loc ) FROM lips WHERE vbeln = gv_del ."AND POSNR = <LS_DATA>-DELIV_ITEM .
  SORT item_data BY batch .
  DATA(sitem) = item_data[].
  DELETE ADJACENT DUPLICATES FROM item_data COMPARING batch.
  LOOP AT item_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*** Creation of HU
    IF <ls_data>-batch IS INITIAL.
      CONTINUE.
    ENDIF.
    ls_itemsproposal-batch = |{ <ls_data>-batch ALPHA = IN }|.
    ls_itemsproposal-plant = ls_headerproposal-plant.
    ls_itemsproposal-stge_loc =  ls_headerproposal-stge_loc.
    ls_itemsproposal-hu_item_type = 1.
****    READ TABLE lt_lips_m ASSIGNING FIELD-SYMBOL(<ls_lips>) WITH KEY vbeln = gv_del matnr = <ls_data>-material charg = ls_itemsproposal-batch ."pstyv = 'NLN' .
***  For HU Qty
***    IF sy-subrc = 0.
***      ls_itemsproposal-pack_qty = <ls_data>-dlv_qty - <ls_lips>-lfimg.
***    ELSE.

    DATA(sitem01) = sitem[].
    DELETE sitem01 WHERE batch <> <ls_data>-batch.
    DATA(hu_qty) = lines( sitem01 ).

    ls_itemsproposal-pack_qty = hu_qty.
***    ENDIF.
    ls_itemsproposal-base_unit_qty = <ls_data>-base_uom .
    ls_itemsproposal-material_long = ls_itemsproposal-material = <ls_data>-material.
    APPEND ls_itemsproposal TO itemsproposal.
  ENDLOOP.

  IF r_tray IS NOT INITIAL.
    ls_headerproposal-pack_mat     = c_tray.   " 'TRAY'.
  ELSE.
    ls_headerproposal-pack_mat     = c_bundle. " 'BUNDLE'.
  ENDIF.
  ls_headerproposal-hu_exid_type   = 'F'.

  CALL FUNCTION 'BAPI_HU_CREATE'
    EXPORTING
      headerproposal = ls_headerproposal
    IMPORTING
      huheader       = ls_huheader
      hukey          = gv_hukey
    TABLES
      itemsproposal  = itemsproposal
      return         = it_ret1
      huitem         = huitem.

  READ TABLE it_ret1 ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
*** Batch Split Items
  REFRESH : lt_verpo,lt_hu,lt_vbpok, lt_prot.
*** Get Delivery details after Batch Split
  SELECT * FROM lips INTO TABLE lt_lips_m WHERE vbeln = gv_del.
  lt_lips = lt_lips_m.
****  DELETE lt_lips WHERE charg = space.

  LOOP AT item_data ASSIGNING FIELD-SYMBOL(<ls_itemp>). "WITH KEY BATCH = WA_LIPS-CHARG.
    READ TABLE lt_lips INTO wa_lips WITH KEY charg = <ls_itemp>-batch.
    IF sy-subrc = 0.
      wa_hu-top_hu_external  = gv_hukey.
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

      sitem01 = sitem.
      DELETE sitem01 WHERE batch <> <ls_itemp>-batch .
      hu_qty = lines( sitem01 ).
      wa_vbpok-pikmg = hu_qty."<ls_itemp>-dlv_qty.

****  FOR PACKING
      wa_verpo-exidv_ob = gv_hukey.
      wa_verpo-vbeln = wa_lips-vbeln.
      wa_verpo-posnr = wa_lips-posnr.
      wa_verpo-tmeng = wa_vbpok-pikmg.

      APPEND wa_verpo TO lt_verpo.
      APPEND wa_vbpok TO lt_vbpok.
      CLEAR:wa_vbpok,wa_verpo, wa_lips.
    ENDIF.
  ENDLOOP.
  "Update Pick
  CHECK lt_hu[] IS NOT INITIAL.
***  IF sy-subrc EQ 0.
  SORT  lt_hu BY  top_hu_external charg.
  DELETE ADJACENT DUPLICATES FROM lt_hu COMPARING top_hu_external charg.
  wa_vbkok-vbeln_vl = gv_del.
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
    MESSAGE s013(zmsg_cls). "'HU Assigned to Delivery' TYPE 'S'.
    DATA(lv_hu) = gv_hukey.
    SUBMIT zmm_tray_sticker AND RETURN WITH p_hu = lv_hu.
    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE ID <ls_prot>-msgid TYPE <ls_prot>-msgty NUMBER <ls_prot>-msgno WITH <ls_prot>-msgv1 <ls_prot>-msgv2
        <ls_prot>-msgv3 <ls_prot>-msgv4.
  ENDIF.
***  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_data .
  REFRESH : lt_lips_m.
  CLEAR : gv_matnr, gv_maktx, gv_charg, gv_b_count, gv_t_qty,gv_p_qty, gv_cur_field, gv_cur_value.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_COUNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_count .
  DATA : lv_b_qty TYPE lips-lfimg.
  READ TABLE gt_lips ASSIGNING FIELD-SYMBOL(<ls_lisp>) INDEX gv_sel.
  IF sy-subrc = 0.
    gv_del = <ls_lisp>-vbeln.
    SELECT vbeln, posnr, lfimg, kcmeng, werks FROM lips INTO TABLE @DATA(lt_qty) WHERE vbeln = @gv_del.
    LOOP AT lt_qty ASSIGNING FIELD-SYMBOL(<ls_qty>).
      AT FIRST.
        gv_plant = <ls_qty>-werks.
      ENDAT.
      ADD <ls_qty>-lfimg  TO gv_t_qty.
      ADD <ls_qty>-kcmeng TO lv_b_qty.
    ENDLOOP.
    gv_p_qty = gv_t_qty - lv_b_qty.
  ELSE.
***  Message :  Invalid Line
    MESSAGE s008(zmsg_cls) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
ENDFORM.
