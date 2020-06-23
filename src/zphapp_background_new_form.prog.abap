*&---------------------------------------------------------------------*
*& Include          ZPHAPP_BACKGROUND_NEW_FORM
*&---------------------------------------------------------------------*

START-OF-SELECTION.
BREAK-POINT.
SELECT a~vendor a~pgroup a~pur_group a~indent_no a~pdate a~sup_sal_no a~sup_name   """ GETTING DATA FROM HEADER AND ITEM TABLE
       a~vendor_name a~transporter a~vendor_location a~delivery_at a~lead_time a~freight_charges a~category_type
       b~item b~category_code b~style b~from_size b~to_size b~color  b~quantity
       b~price b~remarks b~e_msg b~s_msg b~ztext100 b~discount2 b~discount3 b~matnr
       FROM zph_t_hdr AS a INNER JOIN zph_t_item AS b ON a~indent_no = b~indent_no AND a~pgroup = b~pgroup
       INTO TABLE it_final WHERE a~mark_ok <> 'X' AND a~pdate > '20200622'.


  SELECT zindent FROM ekko INTO TABLE @DATA(it_ekko) FOR ALL ENTRIES IN @it_final WHERE zindent = @it_final-indent_no.

    LOOP AT it_final INTO DATA(wa_fin).    """" DELETING INDENT WHOSE PO HAS ALREDY DONE
      READ TABLE it_ekko INTO DATA(wa_ekko) WITH KEY zindent = wa_fin-indent_no.
        IF sy-subrc = 0.
          DELETE it_final  WHERE indent_no = wa_fin-indent_no.
        ENDIF.
    ENDLOOP.

  SELECT * FROM zsize_val INTO TABLE @DATA(lt_size).
  SORT  lt_size BY zitem.

 DATA(it_final1) = it_final.

SORT it_final1 BY indent_no.
DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING indent_no.

DATA: lv_msg TYPE char100.
LOOP AT it_final1 INTO DATA(wa_final1).

 IF wa_final1-category_type <> 'E'.

    CLEAR lv_msg.
    REFRESH: it_final2.
    CLEAR: wa_final2.
    REFRESH: item[] ,    itemx[] , pocond[] ,pocondx[] ,extensionin[] , potextitem[], it_poaccount[] , it_poaccountx[],pocondhdr[], pocondhdrx[].
    LOOP AT it_final INTO wa_final WHERE indent_no = wa_final1-indent_no.
       MOVE-CORRESPONDING wa_final TO wa_final2.
       APPEND wa_final2 TO it_final2.
       CLEAR  wa_final2.
    ENDLOOP.

   SELECT matkl,brand_id FROM mara INTO TABLE @DATA(it_brand) FOR ALL ENTRIES IN @it_final2  WHERE matkl = @it_final2-category_code AND brand_id NE ' '.
  LOOP AT it_final2 INTO wa_final2.

    DATA(lv_item) = wa_final2-item.
            IF wa_final2-from_size IS NOT INITIAL.
              READ TABLE lt_size WITH KEY zsize = wa_final2-from_size TRANSPORTING NO FIELDS.
              DATA(lv_from) = sy-tabix.
              READ TABLE lt_size WITH KEY zsize = wa_final2-to_size TRANSPORTING NO FIELDS.
              DATA(lv_to) = sy-tabix.
              IF lv_to IS NOT INITIAL .
                LOOP AT lt_size ASSIGNING FIELD-SYMBOL(<ls_size>) FROM lv_from TO lv_to.
                  APPEND VALUE #( sign  = 'I' option = 'EQ' low = <ls_size>-zsize ) TO r_range.
                  APPEND VALUE #( item = lv_item matkl = wa_final2-category_code size = <ls_size>-zsize ) TO lt_cat_size.
                ENDLOOP.
              ELSE.
                READ TABLE lt_size ASSIGNING <ls_size> INDEX lv_from.
                IF sy-subrc = 0.
                  APPEND VALUE #( sign  = 'I' option = 'EQ' low = <ls_size>-zsize ) TO r_range.
                  APPEND VALUE #( item  = lv_item matkl = wa_final2-category_code size = <ls_size>-zsize ) TO lt_cat_size.
                ENDIF.
              ENDIF.
            ELSE.
              APPEND VALUE #( sign  = 'I' option = 'EQ' low = space ) TO r_range.
              APPEND VALUE #( item = lv_item matkl = wa_final2-category_code size = space  ) TO lt_cat_size.
            ENDIF.

 ENDLOOP.

  SORT r_range BY low.
  DELETE ADJACENT DUPLICATES FROM r_range COMPARING low.
  SORT lt_cat_size BY item matkl size.
  DELETE ADJACENT DUPLICATES FROM lt_cat_size COMPARING item matkl size.

  IF it_brand IS  INITIAL .
    SELECT mara~matnr,mara~matkl,mara~size1,mara~zzprice_frm, mara~zzprice_to,mara~meins,mara~bstme
           INTO TABLE @DATA(lt_mara) FROM mara AS mara FOR ALL ENTRIES IN @it_final2 WHERE mara~matkl = @it_final2-category_code
           AND zzprice_frm <= @it_final2-price  AND zzprice_to  >= @it_final2-price
           AND mara~size1 IN @r_range  AND mara~mstae = ' ' .

          ELSE.
            SELECT mara~matnr,mara~matkl,mara~size1,mara~zzprice_frm,mara~zzprice_to , mara~meins,mara~bstme
            INTO TABLE @lt_mara FROM mara AS mara FOR ALL ENTRIES IN @it_final2
            WHERE mara~matkl = @it_final2-category_code
            AND mara~size1 IN @r_range AND   mara~mstae = ' ' .
          ENDIF .

        IF it_final2 IS NOT INITIAL .
          SELECT mara~matnr,mara~matkl, mara~size1,mara~zzprice_frm,mara~zzprice_to ,mara~meins,mara~bstme
                INTO TABLE @DATA(lt_set) FROM mara AS mara FOR ALL ENTRIES IN @it_final2
                WHERE mara~matkl = @it_final2-category_code
                AND   mara~mstae = ' ' .
          DELETE  lt_set WHERE meins <> 'SET' .
        ENDIF.

        IF lt_set IS NOT INITIAL .
          SELECT mast~matnr, mast~werks,mast~stlnr,mast~stlal,stpo~stlkn,
                 stpo~idnrk,stpo~posnr,stpo~menge,stpo~matkl,stpo~meins
                   INTO TABLE @DATA(lt_comp)
                   FROM mast AS mast
                   INNER JOIN stpo AS stpo ON stpo~stlty = 'M' AND mast~stlnr = stpo~stlnr
                   FOR ALL ENTRIES IN @lt_set
                   WHERE mast~matnr = @lt_set-matnr.
        ENDIF.
  READ TABLE it_final2 INTO wa_final2 INDEX 1.

   wa_final2-vendor = |{ wa_final2-vendor ALPHA = IN }|.

        SELECT SINGLE
           lfa1~regio FROM lfa1 INTO  @DATA(ls_lfa1)
             WHERE lifnr = @wa_final2-vendor.

        IF lt_mara IS NOT INITIAL .
          SELECT a792~wkreg,a792~regio ,a792~steuc , a792~knumh ,marc~matnr,t001w~werks
           FROM marc AS marc   INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
           INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
           INTO TABLE @DATA(it_hsn)
           FOR ALL ENTRIES IN @lt_mara
           WHERE marc~matnr = @lt_mara-matnr
           AND a792~regio   = @ls_lfa1
           AND t001w~werks =  @wa_final2-delivery_at.
        ENDIF .

   IF lt_comp IS NOT INITIAL.
          SELECT a792~wkreg ,a792~regio ,a792~steuc , a792~knumh , marc~matnr ,t001w~werks
          FROM marc AS marc
           INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
           INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
           INTO TABLE @DATA(it_hsn_s)
           FOR ALL ENTRIES IN @lt_comp
           WHERE marc~matnr = @lt_comp-idnrk
           AND a792~regio   = @ls_lfa1
           AND t001w~werks =  @wa_final-delivery_at.
   ENDIF.

        IF it_hsn IS NOT INITIAL .
          SELECT konp~knumh ,konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp)
                       FOR ALL ENTRIES IN @it_hsn
                       WHERE knumh = @it_hsn-knumh .
        ENDIF.

        IF it_hsn_s IS NOT INITIAL .
          SELECT konp~knumh ,konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp_s)
                       FOR ALL ENTRIES IN @it_hsn_s
                       WHERE knumh = @it_hsn_s-knumh .
        ENDIF .

      IF wa_final2-vendor IS NOT INITIAL .
          SELECT SINGLE
           lfa1~adrnr FROM  lfa1 INTO @DATA(p_adrnr)
                      WHERE lifnr = @wa_final2-vendor+0(10) .       " 0(10) added on (3-3-20)
     ENDIF .
        IF p_adrnr IS NOT INITIAL .
          SELECT SINGLE
            adrc~addrnumber ,
            adrc~city1 FROM adrc INTO @DATA(wa_city)
                    WHERE addrnumber = @p_adrnr .
        ENDIF .
        IF wa_city-city1 = 'CHENNAI'.
         lv_doc = 'ZLOP' .
        ELSE .
          lv_doc = 'ZOSP'.
        ENDIF.

        header-comp_code = '1000' .
        headerx-comp_code = 'X'.
        IF wa_final2-pdate IS NOT INITIAL.
          header-doc_date =  wa_final2-pdate.
        ELSE.
          header-doc_date = sy-datum .
        ENDIF.
        headerx-doc_date = 'X' .
        header-creat_date = sy-datum .
        headerx-creat_date = 'X' .
        DATA: lv_lifnr TYPE lfa1-lifnr.
        DATA: lv_lifnr1 TYPE lfa1-lifnr.
        DATA: lv_zztemp_vendor TYPE lfa1-zztemp_vendor.
*        SELECT SINGLE
*               lifnr
*         FROM lfa1 INTO lv_lifnr
*         WHERE lifnr = wa_final2-vendor.
*        IF lv_lifnr IS INITIAL.
*          SELECT SINGLE lifnr zztemp_vendor FROM lfa1 INTO ( lv_lifnr1 , lv_zztemp_vendor ) WHERE zztemp_vendor = wa_final2-vendor.
*          header-vendor = lv_lifnr1.
*        ELSE.
*          IF sy-subrc = 0.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = im_header-vendor+0(10)
*              IMPORTING
*                output = im_header-vendor+0(10).
*          ENDIF.

*****************************************************************************************************
 IF wa_final2-pur_group IS NOT INITIAL AND wa_final2-pur_group = 'P34'.
   SELECT SINGLE eknam FROM t024 INTO @DATA(lv_eknam) WHERE ekgrp = 'P34'.
     IF lv_eknam IS NOT INITIAL.
       SELECT SINGLE gl_account,costcenter FROM zgl_acc_t INTO @DATA(wa_data)
                                      WHERE   wwgha = @lv_eknam
                                      AND     werks = @wa_final2-delivery_at.
     ENDIF.
ENDIF.
******************************************************************************************************
** Get Groupwise Discount
      SELECT SINGLE low
        INTO @DATA(lv_group_margin)
        FROM tvarvc WHERE name = @c_zzgroup_margin AND low = @wa_final2-pgroup AND sign = 'I'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE kbetr
                      FROM konp
                      INNER JOIN a924 ON konp~knumh = a924~knumh INTO @DATA(lv_discount)
                      WHERE a924~lifnr = @wa_final2-vendor AND a924~userf1_txt = @wa_final2-pgroup
                      AND   a924~kschl = 'ZDS1' AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
      ENDIF.

*****************************************************************************************************
        header-vendor = wa_final2-vendor. .
        headerx-vendor = 'X' .
        header-doc_type = lv_doc .
        headerx-doc_type = 'X' .
        header-langu = sy-langu .
        header-langu = 'X' .
        header-purch_org = '1000'.
        headerx-purch_org = 'X'.
        header-pur_group =  wa_final2-pur_group .
        headerx-pur_group =  'X' .

*        READ TABLE it_final1 INTO wa_final1 INDEX 1.
        wa_extensionin-structure  = 'BAPI_TE_MEPOHEADER'.
        bapi_te_po-po_number      = ' '.
        bapi_te_po-zindent          = wa_final2-indent_no.
        bapi_te_po-user_name        = wa_final2-sup_name.
        wa_extensionin-valuepart1 = bapi_te_po.
        APPEND wa_extensionin TO extensionin.

        wa_extensionin-structure  = 'BAPI_TE_MEPOHEADERX'.
        bapi_te_pox-po_number     = ' '.
        bapi_te_pox-zindent  = 'X'.
        bapi_te_pox-user_name  = 'X'.
        wa_extensionin-valuepart1 = bapi_te_pox.
        APPEND wa_extensionin TO extensionin.
        CLEAR wa_extensionin.

*** Freight charges

        APPEND VALUE #( cond_type = 'ZFRB' cond_value = wa_final2-freight_charges  change_id = 'I' ) TO pocondhdr[] .  "/ 10
        APPEND VALUE #( cond_type = 'X'    cond_value = 'X' change_id = 'X' ) TO pocondhdrx[] .



        DATA lv_line TYPE ebelp .
        DATA : lv_text1     TYPE ztext,
               lv_text2     TYPE zp_remarks, "ZREMARK,
               lv_price(11) TYPE c.
        REFRESH : it_return .
******************************************************************************************
        LOOP AT it_final2 ASSIGNING FIELD-SYMBOL(<ls_fin>).
          lv_price = <ls_fin>-price .
          CONDENSE lv_price .
          DATA(lv_index) = sy-tabix.
          DATA(lt_count) = lt_mara.
          DELETE lt_count WHERE matkl <> <ls_fin>-category_code.
          IF lt_count IS INITIAL.
            lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
            UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final1-indent_no.
*            MESSAGE lv_msg TYPE 'E' DISPLAY LIKE 'S'.
            EXIT .
          ENDIF.
          READ TABLE it_brand ASSIGNING FIELD-SYMBOL(<ls_brand>) WITH KEY matkl = <ls_fin>-category_code .
          IF sy-subrc NE 0.
            DELETE lt_count WHERE zzprice_frm > <ls_fin>-price.
            DELETE lt_count WHERE zzprice_to < <ls_fin>-price.
            IF lt_count IS INITIAL.
              lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
              UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final1-indent_no.
              EXIT .
*              MESSAGE lv_msg TYPE 'E' DISPLAY LIKE 'S'.
            ENDIF.
          ENDIF.
          CLEAR : lv_count.
          IF <ls_fin>-from_size IS NOT INITIAL.
            IF <ls_fin>-from_size <> 'SET' .
              LOOP AT lt_count ASSIGNING FIELD-SYMBOL(<ls_mara>) WHERE matkl = <ls_fin>-category_code.
                READ TABLE lt_cat_size ASSIGNING FIELD-SYMBOL(<ls_ca_size>) WITH KEY matkl = <ls_fin>-category_code size = <ls_mara>-size1 item = <ls_fin>-item.
                IF sy-subrc = 0.
                  CHECK it_brand IS INITIAL.
                  IF <ls_mara>-zzprice_frm LE <ls_fin>-price AND <ls_mara>-zzprice_to GE <ls_fin>-price.
                  ELSE.
                    <ls_mara>-matkl = 'XXX'.
                  ENDIF.
                ELSE.
                  <ls_mara>-matkl = 'XXX'.
                ENDIF.
              ENDLOOP.
              DELETE lt_count WHERE matkl = 'XXX'.
              IF lt_count IS INITIAL.
                CLEAR lv_msg.
                 lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
                 UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final1-indent_no.
                 EXIT.
              ENDIF.
              DESCRIBE TABLE lt_count LINES lv_count.
            ENDIF.
          ENDIF.

          IF <ls_fin>-from_size = 'SET' .
            SORT lt_set BY matkl matnr .
            LOOP AT lt_set ASSIGNING FIELD-SYMBOL(<ls_marp>) WHERE matkl = <ls_fin>-category_code.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = <ls_marp>-matnr
                IMPORTING
                  output = <ls_marp>-matnr.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = wa_item-po_item
                IMPORTING
                  output = wa_item-po_item.

              wa_item-po_item = wa_itemx-po_item =  sl_item.

              SORT lt_comp BY matnr stlnr stlkn idnrk posnr .
              LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>) WHERE matnr = <ls_marp>-matnr.

                READ TABLE it_hsn_s ASSIGNING FIELD-SYMBOL(<ls_hsn_s>) WITH KEY matnr = <ls_comp>-idnrk .
                IF sy-subrc = 0.
                  CLEAR :  lv_mwsk1 .
                  READ TABLE it_konp_s ASSIGNING FIELD-SYMBOL(<ls_konp_s>) WITH KEY knumh = <ls_hsn_s>-knumh .
                  IF sy-subrc = 0.
                    wa_item-tax_code = <ls_konp_s>-mwsk1.
                    wa_itemx-tax_code = 'X'.
                    lv_mwsk1 = <ls_konp_s>-mwsk1.
                  ENDIF.
                ENDIF.
                DATA(lt_comp_t) = lt_comp.
                DELETE lt_comp_t WHERE matnr <> <ls_marp>-matnr.
                IF lt_comp_t IS INITIAL.
                  CLEAR lv_msg.
                  lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
                  UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final1-indent_no.
                  EXIT.
                ENDIF.
                DESCRIBE TABLE lt_comp_t LINES DATA(lv_linesc).
                wa_item-po_item = wa_itemx-po_item =  sl_item.
                SHIFT <ls_marp>-matnr LEFT DELETING LEADING '0'.
                wa_item-material_long      = <ls_comp>-idnrk.
                wa_itemx-material_long  = 'X'.
                wa_item-quantity      =  <ls_fin>-quantity / lv_linesc .
                c = wa_item-quantity .
                CONDENSE c .
                SPLIT c AT '.' INTO a b .
                wa_item-quantity = a .
                wa_itemx-quantity         =  'X' .

                wa_item-plant         =   <ls_fin>-delivery_at.
                wa_itemx-plant         = 'X' .
                wa_item-stge_loc = 'FG01' .
                wa_itemx-stge_loc = 'X' .
                wa_item-net_price     = <ls_fin>-price .
                wa_itemx-net_price = 'X'.
                wa_item-ir_ind = 'X'.
                wa_itemx-ir_ind = 'X'.
                wa_item-gr_basediv = 'X'.
                wa_itemx-gr_basediv = 'X'.

                wa_potextitem-po_item = sl_item.
                wa_potextitem-text_id = 'F03'.
                wa_potextitem-text_form = '*'.
                wa_potextitem-text_line = <ls_fin>-remarks.
                APPEND wa_potextitem TO potextitem.

                wa_potextitem-po_item = sl_item.
                wa_potextitem-text_id = 'F08'.
                wa_potextitem-text_form = '*'.
                wa_potextitem-text_line = <ls_fin>-color.
                APPEND wa_potextitem TO potextitem.


                wa_potextitem-po_item = sl_item.
                wa_potextitem-text_id = 'F07'.
                wa_potextitem-text_form = '*'.
                wa_potextitem-text_line = <ls_fin>-style.
                APPEND wa_potextitem TO potextitem.
                MOVE <ls_fin>-remarks TO lv_text2.
                CONCATENATE <ls_fin>-item <ls_fin>-category_code <ls_fin>-style  <ls_fin>-from_size <ls_fin>-to_size  <ls_fin>-color lv_price  INTO lv_text1 .
                CLEAR :bapi_te_poitem ,bapi_te_poitemx.

***       Item extenction fields
                wa_extensionin-structure = 'BAPI_TE_MEPOITEM'.
                bapi_te_poitem-po_item  = sl_item.
                bapi_te_poitem-zztext100  = lv_text1.
                bapi_te_poitem-zzremarks  = <ls_fin>-remarks.              " ADDED BY LIKHITHA
                wa_extensionin-valuepart1 = bapi_te_poitem.
                APPEND wa_extensionin TO extensionin.
                CLEAR : wa_extensionin.
***       Item extenction fields Updation Flags
                wa_extensionin-structure = 'BAPI_TE_MEPOITEMX'.
                bapi_te_poitemx-po_item = sl_item.
                bapi_te_poitemx-zztext100 = 'X'.
                bapi_te_poitemx-zzremarks = 'X'.
                wa_extensionin-valuepart1 = bapi_te_poitemx.
                APPEND wa_extensionin TO extensionin.
                CLEAR wa_extensionin.

                CLEAR : lv_text .
                wa_item-plan_del = wa_final2-lead_time.
                wa_itemx-plan_del = 'X'.
                wa_item-over_dlv_tol  = '10'.
                wa_itemx-over_dlv_tol  = 'X'.

               IF wa_final2-pur_group = 'P34'.
                   wa_item-acctasscat = 'K'.
                   wa_itemx-acctasscat = 'X'.
               ENDIF.

                APPEND wa_item TO item[].
                APPEND wa_itemx TO itemx[].
*          MODIFY PO_ITEM FROM   WA_ITEM TRANSPORTING LV_POITEM .
                wa_pocond-cond_type = 'PBXX' .
                wa_pocond-cond_value = <ls_fin>-price  / 10.
                wa_pocond-itm_number = wa_item-po_item  .
                wa_pocond-change_id = 'U' .
                wa_pocondx-cond_type = 'X' .
                wa_pocondx-cond_value = 'X' .
                wa_pocondx-itm_number = 'X' .
                wa_pocondx-change_id = 'X' .

                APPEND wa_pocond TO pocond[] .
                APPEND wa_pocondx TO pocondx[] .


*** Discount 1  : Group / Vendor level Discount
                IF lv_group_margin IS NOT INITIAL.
                  APPEND VALUE #( cond_type = 'ZDS1' cond_value = ( lv_discount / 10 ) itm_number = sl_item change_id = 'I' ) TO pocond[] .
                  APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .
                ENDIF.
*** Discount 2 in %
                APPEND VALUE #( cond_type = 'ZDS2' cond_value = <ls_fin>-discount2 itm_number = sl_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .

*** Discount 3 per Piece
                APPEND VALUE #( cond_type = 'ZDS3' cond_value = <ls_fin>-discount3 itm_number = sl_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .


*****************************************************************************************

*****************************************************************************************
*   IF wa_final2-pur_group = 'P34'.
   IF <ls_fin>-pur_group = 'P34'.

    wa_poaccount-po_item    = sl_item.
    wa_poaccount-gl_account = wa_data-gl_account.
    wa_poaccount-costcenter = wa_data-costcenter.

    wa_poaccountx-po_item    = sl_item.
    wa_poaccountx-gl_account = 'X'.
    wa_poaccountx-costcenter = 'X'.

  APPEND wa_poaccount TO it_poaccount.
  APPEND wa_poaccountx TO it_poaccountx.

   ENDIF.
****************************************************************************************

                CLEAR : wa_item,wa_itemx ,wa_pocond,wa_pocondx ,a , b ,c ,wa_poaccount,wa_poaccountx,lv_group_margin,
                        lv_discount .

                sl_item =  sl_item + 10 .
              ENDLOOP.
            ENDLOOP.
          ELSE .
            CLEAR : lv_mwsk1 .
            SORT lt_count BY matkl matnr .
            DATA(lt_size1) = lt_count[].
            SORT lt_size1 BY matkl matnr.
            DELETE ADJACENT DUPLICATES FROM lt_size1 COMPARING matkl matnr.
            DESCRIBE TABLE lt_size1 LINES DATA(lv_size) .
            LOOP AT lt_count ASSIGNING <ls_marp> WHERE matkl = <ls_fin>-category_code.
              wa_item-po_item = wa_itemx-po_item =  sl_item.
              READ TABLE it_hsn ASSIGNING FIELD-SYMBOL(<ls_hsnb>) WITH KEY matnr = <ls_marp>-matnr .
              IF sy-subrc = 0.
                READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<ls_konpb>) WITH KEY knumh = <ls_hsnb>-knumh .
                IF sy-subrc = 0.
                  wa_item-tax_code = <ls_konpb>-mwsk1.
                  lv_mwsk1 = <ls_konpb>-mwsk1 .
                  wa_itemx-tax_code = 'X'.
                ENDIF.
              ENDIF.

              wa_item-material_long = <ls_marp>-matnr .
              wa_itemx-material_long  = 'X'.
              wa_item-po_unit       = <ls_marp>-meins.
              wa_item-quantity       =  <ls_fin>-quantity / lv_size .
              c = wa_item-quantity .
              CONDENSE c .
              SPLIT c AT '.' INTO a b .
              wa_item-quantity = a .
              wa_itemx-quantity         =  'X' .
              wa_item-plant         =   <ls_fin>-delivery_at.
              wa_itemx-plant         =   'X' .
              wa_item-stge_loc = 'FG01' .
              wa_itemx-stge_loc = 'X' .
              wa_item-net_price     = <ls_fin>-price .
              wa_itemx-net_price = 'X'.

              wa_item-ir_ind = 'X'.
              wa_itemx-ir_ind = 'X'.
              wa_item-gr_basediv = 'X'.
              wa_itemx-gr_basediv = 'X'.

              wa_potextitem-po_item = sl_item.
              wa_potextitem-text_id = 'F03'.
              wa_potextitem-text_form = '*'.
              wa_potextitem-text_line = <ls_fin>-remarks.
              APPEND wa_potextitem TO potextitem.

              wa_potextitem-po_item = sl_item.
              wa_potextitem-text_id = 'F08'.
              wa_potextitem-text_form = '*'.
              wa_potextitem-text_line = <ls_fin>-color.
              APPEND wa_potextitem TO potextitem.
              wa_potextitem-po_item = sl_item.
              wa_potextitem-text_id = 'F07'.
              wa_potextitem-text_form = '*'.
              wa_potextitem-text_line = <ls_fin>-style.
              APPEND wa_potextitem TO potextitem.
              CONCATENATE <ls_fin>-item <ls_fin>-category_code <ls_fin>-style  <ls_fin>-from_size <ls_fin>-to_size  <ls_fin>-color lv_price  INTO lv_text1 .
***       Item extenction fields
              wa_extensionin-structure = 'BAPI_TE_MEPOITEM'.
              bapi_te_poitem-po_item  = sl_item.
              bapi_te_poitem-zztext100  = lv_text1.
              bapi_te_poitem-zzremarks  = <ls_fin>-remarks.
              bapi_te_poitem-zzcolor    = <ls_fin>-color.
              bapi_te_poitem-zzstyle    = <ls_fin>-style.
              wa_extensionin-valuepart1 = bapi_te_poitem.
              APPEND wa_extensionin TO extensionin.
              CLEAR : wa_extensionin.
***       Item extenction fields Updation Flags
              wa_extensionin-structure = 'BAPI_TE_MEPOITEMX'.
              bapi_te_poitemx-po_item = sl_item.
              bapi_te_poitemx-zztext100 = 'X'.
              bapi_te_poitemx-zzremarks = 'X'.
              bapi_te_poitemx-zzcolor  = 'X'.                         "
              bapi_te_poitemx-zzstyle = 'X'.
              wa_extensionin-valuepart1 = bapi_te_poitemx.
*              BAPI_TE_POITEMX-ZZREMARKS = C_X.
*              WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEMX.
              APPEND wa_extensionin TO extensionin.
              CLEAR wa_extensionin.

              CLEAR : lv_text .
              wa_item-plan_del = wa_final2-lead_time.
              wa_itemx-plan_del = 'X'.
              wa_item-over_dlv_tol  = '10'.           ""tolerance
              wa_itemx-over_dlv_tol  = 'X'.           ""tolerance

   IF wa_final2-pur_group = 'P34'.
       wa_item-acctasscat = 'K'.
       wa_itemx-acctasscat = 'X'.
   ENDIF.

              APPEND wa_item TO item[].
              APPEND wa_itemx TO itemx[].

              wa_pocond-cond_type = 'PBXX' .
              wa_pocond-cond_value = <ls_fin>-price  / 10.
              wa_pocond-itm_number = wa_item-po_item  .
              wa_pocond-change_id = 'U' .
              wa_pocondx-cond_type = 'X' .
              wa_pocondx-cond_value = 'X' .
              wa_pocondx-itm_number = 'X' .
              wa_pocondx-change_id = 'X' .
              APPEND wa_pocond TO pocond[] .
              APPEND wa_pocondx TO pocondx[] .


*** Discount 1  : Group / Vendor level Discount
                IF lv_group_margin IS NOT INITIAL.
                  APPEND VALUE #( cond_type = 'ZDS1' cond_value = ( lv_discount / 10 ) itm_number = sl_item change_id = 'I' ) TO pocond[] .
                  APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .
                ENDIF.
*** Discount 2 in %
                APPEND VALUE #( cond_type = 'ZDS2' cond_value = <ls_fin>-discount2 itm_number = sl_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .

*** Discount 3 per Piece
                APPEND VALUE #( cond_type = 'ZDS3' cond_value = <ls_fin>-discount3 itm_number = sl_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .

*****************************************************************************************
   IF <ls_fin>-pur_group = 'P34'.

    wa_poaccount-po_item    = sl_item.
    wa_poaccount-gl_account = wa_data-gl_account.
    wa_poaccount-costcenter = wa_data-costcenter.

    wa_poaccountx-po_item    = sl_item.
    wa_poaccountx-gl_account = 'X'.
    wa_poaccountx-costcenter = 'X'.

  APPEND wa_poaccount TO it_poaccount.
  APPEND wa_poaccountx TO it_poaccountx.

   ENDIF.
****************************************************************************************
              CLEAR : wa_item,wa_itemx ,wa_pocond,wa_pocondx ,a , b ,c ,wa_poaccount,wa_poaccountx ,lv_group_margin,
                      lv_discount.

              sl_item =  sl_item + 10 .
            ENDLOOP .
          ENDIF .
        ENDLOOP.
        CLEAR : sl_item .
  IF lv_msg IS INITIAL.
        sl_item = '10'.
        DATA(it_tax) = item[] .
        READ TABLE it_tax  WITH KEY tax_code = space TRANSPORTING NO FIELDS.
        IF   sy-subrc <> 0 .
          CLEAR lv_ebeln.
          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader         = header
              poheaderx        = headerx
            IMPORTING
              exppurchaseorder = lv_ebeln
            TABLES
              return           = it_return[]
              poitem           = item[]
              poitemx          = itemx[]
              poaccount        = it_poaccount
              poaccountx       = it_poaccountx
              pocondheader     = pocondhdr[]
              pocondheaderx    = pocondhdrx[]
              pocond           = pocond[]
              pocondx          = pocondx[]
              extensionin      = extensionin[]
              potextitem       = potextitem[]
            .
        ELSE.
              CLEAR lv_msg.
              lv_msg = 'Po tax is not maintained '.
              UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final1-indent_no.
              CLEAR lv_msg.
              CONTINUE.
        ENDIF .
        IF lv_ebeln IS NOT INITIAL .
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        UPDATE zph_t_hdr  SET mark_ok = 'X' WHERE indent_no = wa_final1-indent_no.
        UPDATE zph_t_hdr  SET error = ' ' WHERE indent_no = wa_final1-indent_no.
        DELETE FROM zphapp_msg  WHERE zindent_no = wa_final1-indent_no.


         lv_tex = 'Created Successfully' .
         CONCATENATE lv_ebeln lv_tex  INTO lv_tebeln SEPARATED BY space.
         MESSAGE lv_tebeln TYPE  'S' .
        ELSE.

          READ TABLE it_return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY type = 'E'.
          IF sy-subrc = 0.
             LOOP AT it_return ASSIGNING FIELD-SYMBOL(<fs>) WHERE type = 'E'.
               wa_addf-mandt            = sy-mandt.
               wa_addf-zindent_no       = wa_final1-indent_no.
               wa_addf-item             = sy-tabix.
               wa_addf-ztype            = <fs>-type.
               wa_addf-zid              = <fs>-id.
               wa_addf-znumber          = <fs>-number.
               wa_addf-zmessage         = <fs>-message.
               wa_addf-zlog_no          = <fs>-log_no.
               wa_addf-zlog_msg_no      = <fs>-log_msg_no.
               wa_addf-zmessage_v1      = <fs>-message_v1.
               wa_addf-zmessage_v2      = <fs>-message_v2.
              MODIFY zphapp_msg FROM wa_addf.
               CLEAR wa_addf.
            ENDLOOP.

          IF <ls_return>-id = '06' AND <ls_return>-number = '0070'.
            lv_error = 'Please check the quantity you have entered' .
            UPDATE zph_t_hdr SET error = lv_error WHERE indent_no = wa_final1-indent_no.
            CLEAR lv_error.
         ENDIF.
           CONTINUE.
          ENDIF.
        ENDIF.
ENDIF.
CLEAR lv_msg.
  WAIT UP TO 2 SECONDS.

****************************************************END CATEGORY*******************************************************************
***********************************************************************************************************************
 ELSE.


      DATA :
             ls_item             TYPE bapimepoitem,
             ls_itemx            TYPE bapimepoitemx,
             return              TYPE TABLE OF bapiret2,
             errorcat            TYPE TABLE OF slis_t_fieldcat_alv,
             ls_errorcat         TYPE  slis_t_fieldcat_alv,
             ls_poservicestext   TYPE bapieslltx,
             ls_potextitem       TYPE bapimepotext,
             ls_no_price_from_po TYPE bapiflag-bapiflag,
             ls_poaccount        TYPE bapimepoaccount,
             poaccount           TYPE TABLE OF bapimepoaccount,
             ls_poaccountx       TYPE bapimepoaccountx,
             poaccountx          TYPE TABLE OF bapimepoaccountx,
             ls_pocond           TYPE bapimepocond,
             ls_pocondx          TYPE  bapimepocondx.


    CLEAR lv_msg.
    REFRESH: it_final3.
    CLEAR: wa_final3, header, headerx.
    REFRESH: item[] ,    itemx[] , pocond[] ,pocondx[] ,extensionin[] , potextitem[], it_poaccount[] , it_poaccountx[],pocondhdr[], pocondhdrx[].
    LOOP AT it_final INTO wa_final WHERE indent_no = wa_final1-indent_no.
       MOVE-CORRESPONDING wa_final TO wa_final2.
       APPEND wa_final3 TO it_final3.
       CLEAR  wa_final3.
    ENDLOOP.

  READ TABLE it_final3 INTO wa_final3 INDEX 1.

     IF wa_final3-vendor IS NOT INITIAL.
        DATA : lv_lifn TYPE lifnr.
        lv_lifn = wa_final3-vendor+0(10).
        lv_lifn = |{ lv_lifnr1 ALPHA = IN }|.
      SELECT SINGLE lfa1~lifnr, lfa1~name1, lfa1~ort01, lfa1~regio FROM lfa1 INTO @DATA(ls_vendor) WHERE lifnr = @lv_lifn.
      IF sy-subrc <> 0.
                  CLEAR lv_msg.
                  lv_msg = 'Vendor Does not Exist'.
                  UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final3-indent_no.
                  EXIT.

      ENDIF .
ENDIF.

*** Get Groupwise Discount
      SELECT SINGLE low INTO @DATA(lv_group_margin1) FROM tvarvc WHERE name = 'ZZGROUP_MARGIN' AND low = @wa_final3-pur_group AND sign = 'I'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE kbetr
                      FROM konp
                      INNER JOIN a924 ON konp~knumh = a924~knumh INTO @DATA(lv_discount1)
                      WHERE a924~lifnr = @lv_lifn AND a924~userf1_txt = @wa_final3-pur_group
                      AND   a924~kschl = 'ZDS1' AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
      ENDIF.



  IF ls_vendor-ort01 = 'CHENNAI'.
        IF wa_final3-pur_group = 'P17'.
          header-doc_type = 'ZVLO'.
        ELSE.
          header-doc_type = 'ZLOP'.
        ENDIF.
      ELSE.
        IF wa_final3-pur_group = 'P17'.
          header-doc_type = 'ZVOS'.
        ELSE.
          header-doc_type = 'ZOSP'.
        ENDIF.
      ENDIF.
      headerx-doc_type = 'X' .


        IF wa_final3-pdate IS NOT INITIAL.
          header-doc_date =  wa_final3-pdate.
        ELSE.
          header-doc_date = sy-datum .
        ENDIF.
      headerx-doc_date = 'X' .

      header-comp_code    = '1000' .
      headerx-comp_code   = 'X'.
      header-creat_date   = sy-datum .
      headerx-creat_date  = 'X' .
      header-vendor       = lv_lifn.
      headerx-vendor      = 'X' .
      header-langu        = sy-langu.
      headerx-langu       = 'X' .
      header-purch_org    = '1000'.
      headerx-purch_org   = 'X'.
      header-pur_group    = wa_final3-pur_group .
      headerx-pur_group   = 'X' .

      bapi_te_po-zindent          = wa_final3-indent_no.
      bapi_te_po-user_name        = wa_final3-sup_name.
      bapi_te_po-zzcategory_type  = 'E'.
      APPEND VALUE #( structure  = 'BAPI_TE_MEPOHEADER' valuepart1 = bapi_te_po ) TO extensionin.
      CLEAR : bapi_te_po.
      bapi_te_pox-zindent          = 'X'.
      bapi_te_pox-user_name        = 'X'.
      bapi_te_pox-zzcategory_type  = 'X'.
      APPEND VALUE #( structure  = 'BAPI_TE_MEPOHEADERX' valuepart1 = bapi_te_pox ) TO extensionin.
      CLEAR : bapi_te_po.


*** HSN & Tax Code
      SELECT
       a792~regio ,
       a792~steuc ,
       marc~matnr ,
       konp~mwsk1
       FROM marc AS marc
       INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
       INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
       INNER JOIN konp AS konp ON konp~knumh = a792~knumh
       INTO TABLE @DATA(lt_hsn)
       FOR ALL ENTRIES IN @it_final3
       WHERE marc~matnr = @it_final3-matnr
       AND a792~regio   = @ls_vendor-regio
       AND t001w~werks  = @wa_final3-delivery_at AND konp~loevm_ko = @space AND a792~datbi GE @sy-datum AND a792~datab LE @sy-datum.

      IF wa_final3-pur_group = 'P34'.
        SELECT SINGLE eknam FROM t024 INTO @DATA(lv_eknam1) WHERE ekgrp = 'P34'.
        IF lv_eknam IS NOT INITIAL.
          SELECT SINGLE gl_account,costcenter FROM zgl_acc_t INTO @DATA(ls_data) WHERE wwgha = @lv_eknam1 AND werks = @wa_final3-delivery_at.
        ENDIF.
      ENDIF.

*** Freight charges
      APPEND VALUE #( cond_type = 'ZFRB' cond_value = wa_final3-freight_charges / 10 change_id = 'I' ) TO pocondhdr[] .
      APPEND VALUE #( cond_type = 'X'    cond_value = 'X' change_id = 'X' ) TO pocondhdrx[] .


*** Item Data
      CLEAR : lv_count.
      IF it_final3 IS NOT INITIAL.
        LOOP AT it_final3 ASSIGNING FIELD-SYMBOL(<ls_ph_item>).
*          CLEAR : ls_item.
          lv_count = lv_count + 10.

          READ TABLE lt_hsn ASSIGNING FIELD-SYMBOL(<ls_hsn>) WITH KEY matnr = <ls_ph_item>-matnr.
          IF sy-subrc IS INITIAL.
***     Tax Code Validation
            ls_item-po_item        = lv_count.
            ls_itemx-po_item       = lv_count.
            ls_itemx-po_itemx      = 'X'.
            IF strlen( <ls_ph_item>-matnr ) > 18.
              ls_item-material_long      = <ls_ph_item>-matnr.
              ls_itemx-material_long     = 'X'.
            ELSE.
              ls_item-material      = <ls_ph_item>-matnr.
              ls_itemx-material     = 'X'.
            ENDIF.
            ls_item-quantity       = <ls_ph_item>-quantity.
            ls_itemx-quantity      = 'X'.
            ls_item-plant          = wa_final3-delivery_at.
            ls_itemx-plant         = 'X' .
            ls_item-stge_loc       = 'FG01' .
            ls_itemx-stge_loc      = 'X' .
            ls_item-net_price      = <ls_ph_item>-price.
            ls_itemx-net_price     = 'X'.
            ls_item-ir_ind         = 'X'.
            ls_itemx-ir_ind        = 'X'.
            ls_item-gr_basediv     = 'X'.
            ls_itemx-gr_basediv    = 'X'.
            ls_item-plan_del       = wa_final3-lead_time.
            ls_itemx-plan_del      = 'X'.
            ls_item-over_dlv_tol   = '10'.         " Tolerance
            ls_itemx-over_dlv_tol  = 'X'.


*** Consumbales - to Cost Center
            IF wa_FINAL3-pur_group = 'P34'.
              ls_item-acctasscat   = 'K'.
              ls_itemx-acctasscat  = 'X'.

              APPEND VALUE #( po_item  = lv_count gl_account = ls_data-gl_account costcenter = ls_data-costcenter ) TO poaccount.
              APPEND VALUE #( po_item  = lv_count gl_account = 'X' costcenter = 'X' ) TO poaccountx.
            ENDIF.

            APPEND ls_item TO item[].
            APPEND ls_itemx TO itemx[].

            APPEND VALUE #( po_item   = lv_count text_id   = 'F03' text_form = '*' text_line = <ls_ph_item>-remarks ) TO potextitem.
            APPEND VALUE #( po_item   = lv_count text_id   = 'F08' text_form = '*' text_line = <ls_ph_item>-color ) TO potextitem.
            APPEND VALUE #( po_item   = lv_count text_id   = 'F07' text_form = '*' text_line = <ls_ph_item>-style ) TO potextitem.
            CLEAR :bapi_te_poitem,bapi_te_poitemx.

***     Item extenction fields
            bapi_te_poitem-po_item    = lv_count.
            bapi_te_poitem-zztext100  = lv_text.
            bapi_te_poitem-zzremarks  = <ls_ph_item>-remarks.
            bapi_te_poitem-zzcolor    = <ls_ph_item>-color.
            bapi_te_poitem-zzstyle    = <ls_ph_item>-style.
            APPEND VALUE #( structure = 'BAPI_TE_MEPOITEM' valuepart1 = bapi_te_poitem ) TO extensionin.


***     Item extenction fields Updation Flags
            bapi_te_poitemx-po_item   = lv_count.
            bapi_te_poitemx-zztext100 = 'X'.
            bapi_te_poitemx-zzremarks = 'X'.
            bapi_te_poitemx-zzcolor   = 'X'.
            bapi_te_poitemx-zzstyle   = 'X'.
            APPEND VALUE #( structure = 'BAPI_TE_MEPOITEMX' valuepart1 = bapi_te_poitemx ) TO extensionin.

*** Conditions
            APPEND VALUE #( cond_type = 'PBXX' cond_value = <ls_ph_item>-price  / 10 itm_number = lv_count change_id = 'U'  ) TO pocond[].
            APPEND VALUE #( cond_type = 'X' cond_value = 'X'  itm_number = 'X' change_id = 'X' ) TO pocondx[].


** Discount 1  : Group / Vendor level Discount
            IF lv_group_margin IS NOT INITIAL.
              APPEND VALUE #( cond_type = 'ZDS1'  cond_value = ( lv_discount / 10 ) itm_number = lv_count change_id = 'I' ) TO pocond[] .
              APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .
            ENDIF.
*** Discount 2 in %
            APPEND VALUE #( cond_type = 'ZDS2' cond_value = <ls_ph_item>-discount2 itm_number = lv_count change_id = 'I' ) TO pocond[] .
            APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .

*** Discount 3 per Piece
            APPEND VALUE #( cond_type = 'ZDS3' cond_value = <ls_ph_item>-discount3 / 10 itm_number = lv_count change_id = 'I' ) TO pocond[] .
            APPEND VALUE #( cond_type = 'X' cond_value = 'X' itm_number = 'X' change_id = 'X' ) TO pocondx[] .
*
  ELSE.
*** No Tax Code Found
                  CLEAR lv_msg.
                  lv_msg = 'No tax Code'.
                  UPDATE zph_t_hdr SET error = lv_msg WHERE indent_no = wa_final3-indent_no.
                  EXIT.

          ENDIF.
        ENDLOOP.

    IF lv_msg IS INITIAL.

 CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader         = header
              poheaderx        = headerx
              no_price_from_po = 'X'
            IMPORTING
              exppurchaseorder = lv_ebeln
            TABLES
              return           = return[]
              poitem           = item[]
              poitemx          = itemx[]
              poaccount        = poaccount
              poaccountx       = poaccountx
              pocondheader     = pocondhdr[]
              pocondheaderx    = pocondhdrx[]
              pocond           = pocond[]
              pocondx          = pocondx[]
              extensionin      = extensionin[]
              potextitem       = potextitem[].


          READ TABLE return ASSIGNING <ls_return> WITH KEY type = 'E'.
          IF sy-subrc IS NOT INITIAL AND lv_ebeln IS NOT INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
           UPDATE zph_t_hdr  SET mark_ok = 'X' WHERE indent_no = wa_final3-indent_no.
           UPDATE zph_t_hdr  SET error = ' ' WHERE indent_no = wa_final3-indent_no.
           DELETE FROM zphapp_msg  WHERE zindent_no = wa_final3-indent_no.


          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          ENDIF.
        ENDIF.
      ELSE.
       READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_return1>) WITH KEY type = 'E'.
          IF sy-subrc = 0.
             LOOP AT return ASSIGNING FIELD-SYMBOL(<fs1>) WHERE type = 'E'.
               wa_addf-mandt            = sy-mandt.
               wa_addf-zindent_no       = wa_final3-indent_no.
               wa_addf-item             = sy-tabix.
               wa_addf-ztype            = <fs1>-type.
               wa_addf-zid              = <fs1>-id.
               wa_addf-znumber          = <fs1>-number.
               wa_addf-zmessage         = <fs1>-message.
               wa_addf-zlog_no          = <fs1>-log_no.
               wa_addf-zlog_msg_no      = <fs1>-log_msg_no.
               wa_addf-zmessage_v1      = <fs1>-message_v1.
               wa_addf-zmessage_v2      = <fs1>-message_v2.
              MODIFY zphapp_msg FROM wa_addf.
               CLEAR wa_addf.
            ENDLOOP.

          IF <ls_return>-id = '06' AND <ls_return1>-number = '0070'.
            lv_error = 'Please check the quantity you have entered' .
            UPDATE zph_t_hdr SET error = lv_error WHERE indent_no = wa_final3-indent_no.
            CLEAR lv_error.
         ENDIF.
           CONTINUE.
          ENDIF.
        ENDIF.


****************************************************************************************************************
  ENDIF.

CLEAR lv_msg.
 ENDLOOP.
