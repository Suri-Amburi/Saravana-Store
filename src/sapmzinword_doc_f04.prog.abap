*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form VALIDATE_PO
*&---------------------------------------------------------------------*
FORM validate_po.
  DATA : lv_date TYPE datum.
  IF sy-ucomm <> c_clear.
    IF sy-ucomm = c_edit.
      lv_mod = c_e1.
    ELSEIF sy-ucomm = c_display.
      lv_mod = c_d.
    ENDIF.

    IF p_ebeln IS NOT INITIAL AND p_qr_code IS INITIAL.
      CLEAR : wa_ekko.
      SELECT SINGLE ekko~ebeln ekko~aedat ekko~bsart ekko~zbd1t ekko~lifnr ekko~knumv ekko~frgke eket~eindt INTO wa_ekko
              FROM ekko AS ekko INNER JOIN eket AS eket ON ekko~ebeln = eket~ebeln  WHERE ekko~ebeln = p_ebeln .
      IF sy-subrc <> 0 .
        MESSAGE e000(zmsg_cls).
      ELSE.
        lv_bsart = wa_ekko-bsart.
*** Return PO Validation : Not Possible
        IF lv_bsart = c_zret.
          MESSAGE e078(zmsg_cls).
*** Tatkal PO Validation : Not Allowing TP2 For More then 10 days
        ELSEIF lv_bsart = c_ztat AND lv_mod = c_e1.
          lv_date =  wa_ekko-aedat + 10.
          IF lv_date < sy-datum .
            MESSAGE e053(zmsg_cls) WITH p_ebeln.
          ENDIF.
*** Validation for Inward before Delivery Date
        ELSEIF wa_ekko-eindt LT sy-datum AND lv_mod = c_e1.
          MESSAGE e079(zmsg_cls).
        ENDIF.
      ENDIF.

    ELSEIF p_qr_code IS NOT INITIAL.
      SELECT SINGLE ebeln FROM zinw_t_hdr INTO p_ebeln WHERE qr_code = p_qr_code.
      IF sy-subrc  <> 0.
        MESSAGE e024(zmsg_cls).
      ELSE.
        SELECT SINGLE ekko~ebeln ekko~aedat ekko~bsart ekko~zbd1t ekko~lifnr ekko~knumv ekko~frgke eket~eindt INTO wa_ekko
               FROM ekko AS ekko INNER JOIN eket AS eket ON ekko~ebeln = eket~ebeln  WHERE ekko~ebeln = p_ebeln.
        lv_bsart = wa_ekko-bsart.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR : p_ebeln, p_qr_code , wa_hdr, lv_net_pay, lv_net_selling , wa_hdr-bill_amt.
    CLEAR : ok_code.
  ENDIF.
ENDFORM.
FORM get_data.
  DATA : lv_qty     TYPE ekpo-menge,
         lv_qty_tol TYPE p DECIMALS 2,
         lv_dis     TYPE p DECIMALS 5.

  FIELD-SYMBOLS : <ls_ekpo> LIKE LINE OF lt_ekpo.
  IF p_qr_code IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO wa_hdr WHERE qr_code = p_qr_code.
    IF sy-subrc <> 0.
      MESSAGE s003(zmsg_cls) DISPLAY LIKE 'E'.
      EXIT.
    ELSEIF wa_hdr-status GE c_05 AND lv_mod = 'E'.
      lv_mod  = c_d.
      CLEAR : wa_hdr.
      MESSAGE s045(zmsg_cls) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
***  GRPO Date
    IF wa_hdr-mblnr IS NOT INITIAL.
      SELECT SINGLE created_date FROM zinw_t_status INTO lv_gr_date WHERE qr_code = wa_hdr-qr_code AND status_field = c_qr_code AND status_value = c_qr04.
    ELSEIF wa_hdr-mblnr_103 IS NOT INITIAL.
      SELECT SINGLE created_date FROM zinw_t_status INTO lv_gr_date WHERE qr_code = wa_hdr-qr_code AND status_field = c_qr_code AND status_value = c_qr03.
    ENDIF.
    SELECT SINGLE name1 FROM lfa1 INTO lv_trns WHERE lifnr = wa_hdr-trns.
    SELECT SINGLE ddtext FROM dd07v INTO lv_status WHERE domname = 'ZSTATUS' AND domvalue_l = wa_hdr-status AND ddlanguage = sy-langu.
    SELECT SINGLE ddtext FROM dd07v INTO lv_soe_des WHERE domname = 'ZSOE' AND domvalue_l = wa_hdr-soe AND ddlanguage = sy-langu.
*** Payment Mode
    IF wa_hdr-status > '06'.
      SELECT SINGLE * FROM zqr_t_add INTO wa_payment WHERE qr_code = p_qr_code.
    ENDIF.
***  Get Approval Status
    CLEAR : wa_approve.
    SELECT SINGLE * FROM zinvoice_t_app INTO wa_approve WHERE qr_code = p_qr_code.
    TRY .
        zcl_grpo=>get_inw_item(
          EXPORTING
            i_qr          = p_qr_code
          IMPORTING
            t_item        = lt_item ).
      CATCH cx_amdp_error.
    ENDTRY.
*** Groces & Net Profit in %
    lv_net_selling   = wa_hdr-total - wa_hdr-t_gst .
    lv_grc_prof      = wa_hdr-total - wa_hdr-pur_total.
    lv_prof_amt      = wa_hdr-total - wa_hdr-net_amt.

    IF wa_hdr-net_amt IS NOT INITIAL.
      lv_prof%       = ( lv_prof_amt * 100 ) / wa_hdr-net_amt.
    ENDIF.

    IF wa_hdr-net_amt IS NOT INITIAL.
      lv_grc_prof%       = ( lv_grc_prof * 100 ) / wa_hdr-pur_total.
    ENDIF.

    IF lt_item IS NOT INITIAL.
      UNASSIGN : <ls_item>.
***  PO item
      TRY .
          zcl_grpo=>get_po_item(
            EXPORTING
              i_ebeln =  wa_hdr-ebeln
            IMPORTING
              t_ekpo  =  lt_ekpo ).
        CATCH cx_amdp_error.
      ENDTRY.
***  Discounts
      SELECT prcd~knumv,
             prcd~kposn,
             prcd~kschl,
             prcd~kawrt,
             prcd~knumh,
             prcd~kbetr,
             prcd~kwert INTO TABLE @lt_prcd FROM prcd_elements AS prcd
             INNER JOIN ekko AS ekko ON ekko~knumv = prcd~knumv
             WHERE kschl IN ( @c_pbxx , @c_wotb , @c_zds1 ,  @c_zds2 ,  @c_zds3 ,  @c_zfrb ) AND ekko~ebeln = @wa_hdr-ebeln.
*** For item Dicount
*      LOOP AT lt_item ASSIGNING <ls_item>.
*        DATA(lv_dis)  = ( <ls_item>-discount * <ls_item>-netpr_p / 100 ) * <ls_item>-menge_p.
*        ADD lv_dis TO lv_hdr_discount.
*      ENDLOOP.
      MOVE-CORRESPONDING lt_item TO lt_item_scr.
      SORT lt_prcd BY kposn.
      LOOP AT lt_item_scr ASSIGNING <ls_item_scr>.
*** Discount 2 & 3 , Freight
        LOOP AT lt_prcd ASSIGNING <ls_prcd> WHERE kposn = <ls_item_scr>-ebelp.
          CASE <ls_prcd>-kschl.
            WHEN c_zds1.
              <ls_item_scr>-discount   = <ls_prcd>-kbetr.
            WHEN c_zds2.
              <ls_item_scr>-discount2  = <ls_prcd>-kbetr.
            WHEN c_zds3.
              <ls_item_scr>-discount3  = <ls_prcd>-kbetr.
            WHEN c_zfrb.
              <ls_item_scr>-freight  = <ls_prcd>-kbetr.
          ENDCASE.
        ENDLOOP.
        READ TABLE lt_ekpo ASSIGNING <ls_ekpo> WITH KEY ebeln = <ls_item_scr>-ebeln ebelp = <ls_item_scr>-ebelp BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lv_dis = ( <ls_item_scr>-netpr_p - <ls_ekpo>-netpr  ) * <ls_item_scr>-menge_p .
        ENDIF.
        ADD  lv_dis TO lv_hdr_discount.
      ENDLOOP.

*** For Displaing As SET Materials
***  For Set Materials
      DATA(lt_item_set) = lt_item.
      DELETE lt_item_set WHERE zzset_material IS INITIAL.
      IF lt_item_set IS NOT INITIAL.
        UNASSIGN :<ls_ekpo>.
        SORT lt_item_set BY zzset_material netpr_p.
        DELETE ADJACENT DUPLICATES FROM lt_item_set COMPARING zzset_material netpr_p.
***       SET Material Wise Loop
        LOOP AT lt_item_set ASSIGNING <ls_item>.
          wa_item = <ls_item>.
          CLEAR : wa_item-zzset_material.
          wa_item_scr-ebeln    = <ls_item>-ebeln.
          wa_item_scr-ebelp    = <ls_item>-ebelp.
          wa_item_scr-matnr    = <ls_item>-zzset_material.
          wa_item_scr-maktx    = <ls_item>-maktx.
          wa_item_scr-matkl    = <ls_item>-matkl.
          wa_item_scr-werks    = <ls_item>-werks.
          wa_item_scr-lgort    = <ls_item>-lgort.
          wa_item_scr-ean11    = <ls_item>-ean11.
***         For Set Material Sub Components
          DATA(lt_item_s)  = lt_item.
          SORT lt_item_s BY zzset_material matnr.
          DELETE lt_item_s WHERE zzset_material <> <ls_item>-zzset_material.
          DELETE ADJACENT DUPLICATES FROM lt_item_s COMPARING zzset_material matnr.
          DESCRIBE TABLE lt_item_s LINES DATA(lv_lines).

          wa_item_scr-discount = <ls_item>-discount.
          wa_item_scr-menge_p    = <ls_item>-menge_p * lv_lines.
          wa_item_scr-menge_s    = <ls_item>-menge_s * lv_lines.
          wa_item_scr-meins      = c_set.
          wa_item_scr-netpr_p    = <ls_item>-netpr_p.
          wa_item_scr-netwr_p    = <ls_item>-netwr_p  * lv_lines.
          wa_item_scr-netwr_s    = <ls_item>-netwr_s  * lv_lines.
          wa_item_scr-netpr_gp   = <ls_item>-netpr_gp * lv_lines.
          wa_item_scr-netpr_gs   = <ls_item>-netpr_gs * lv_lines.

*** Discount 2 & 3 , Freight
          LOOP AT lt_prcd ASSIGNING <ls_prcd> WHERE kposn = <ls_item_scr>-ebelp.
            CASE <ls_prcd>-kschl.
              WHEN c_zds1.
                wa_item_scr-discount   = <ls_prcd>-kbetr.
              WHEN c_zds2.
                wa_item_scr-discount2  = <ls_prcd>-kbetr.
              WHEN c_zds3.
                wa_item_scr-discount3  = <ls_prcd>-kbetr.
              WHEN c_zfrb.
                wa_item_scr-freight  = <ls_prcd>-kbetr.
            ENDCASE.
          ENDLOOP.
          READ TABLE lt_ekpo ASSIGNING <ls_ekpo> WITH KEY ebeln = <ls_item_scr>-ebeln ebelp = <ls_item_scr>-ebelp BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            lv_dis = ( <ls_item_scr>-netpr_p - <ls_ekpo>-netpr  ) * <ls_item_scr>-menge_p .
          ENDIF.
          ADD  lv_dis TO lv_hdr_discount.

          APPEND wa_item_scr TO lt_item_scr.
          CLEAR: wa_item_scr.
        ENDLOOP.
      ENDIF. " Set Material
      DELETE lt_item WHERE zzset_material IS NOT INITIAL.
      p_ebeln = wa_hdr-ebeln.
      IF wa_hdr-status = c_03 AND lv_mod = c_e.
        lv_mod = c_d.
        MESSAGE  w005(zmsg_cls).
      ENDIF.
    ENDIF.
    SORT lt_item_scr BY ebeln ebelp.
  ELSE.
*** PO as input
    REFRESH : lt_item.
*** PO Header data
*** PO Item Date
    IF wa_ekko IS NOT INITIAL.
      TRY .
          zcl_grpo=>get_po_item(
            EXPORTING
              i_ebeln =  wa_ekko-ebeln
            IMPORTING
              t_ekpo  =  lt_ekpo ).
        CATCH cx_amdp_error.
      ENDTRY.

*** For Group Validation
*** For Fruits & Veitables
      SELECT SINGLE klah~class
                    INTO @lv_group
                    FROM klah AS klah
                    INNER JOIN kssk AS kssk  ON kssk~clint = klah~clint
                    INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
                    INNER JOIN ekpo AS ekpo  ON klah1~class = ekpo~matkl
                    WHERE klah~klart = '026' AND ekpo~ebeln = @wa_ekko-ebeln.

*** Get Groupwise Margin
      SELECT SINGLE CASE WHEN low = @lv_group THEN @c_x END AS low INTO @lv_group_margin
             FROM tvarvc WHERE name = @c_zzgroup_margin AND low = @lv_group AND sign = 'I'.

***  SET Materials
      SORT lt_ekpo BY ebeln ebelp.
***  Discounts
      SELECT prcd~knumv,
             prcd~kposn,
             prcd~kschl,
             prcd~kawrt,
             prcd~knumh,
             prcd~kbetr,
             prcd~kwert INTO TABLE @lt_prcd FROM prcd_elements AS prcd
             INNER JOIN ekko AS ekko ON ekko~knumv = prcd~knumv
             WHERE kschl IN ( @c_pbxx , @c_wotb , @c_zds1 ,  @c_zds2 ,  @c_zds3 ,  @c_zfrb ) AND ekko~ebeln = @wa_ekko-ebeln.

      LOOP AT lt_ekpo ASSIGNING <ls_ekpo> WHERE zzset_material IS NOT INITIAL.
        DATA(lv_set) = 'X'.
        EXIT.
      ENDLOOP.
      IF lv_set = c_x.
***     Bom Components
        SELECT mast~matnr,
               mast~werks,
               mast~stlnr,
               mast~stlal,
               stpo~stlkn,
               stpo~idnrk,
               stpo~posnr,
               stpo~menge,
               stpo~meins
               INTO TABLE @DATA(lt_comp)
               FROM mast AS mast
               INNER JOIN stpo AS stpo ON stpo~stlty = @c_m AND mast~stlnr = stpo~stlnr
               FOR ALL ENTRIES IN @lt_ekpo
               WHERE mast~matnr = @lt_ekpo-zzset_material.
      ENDIF.
*      ENDIF.

      IF lt_ekpo IS NOT INITIAL.
***     For Booking Station
        UNASSIGN : <ls_ekpo>.
        READ TABLE lt_ekpo ASSIGNING <ls_ekpo> INDEX 1.
        IF sy-subrc = 0.
          SELECT SINGLE name1 FROM t001w INTO wa_hdr-bk_station WHERE werks = <ls_ekpo>-werks.
        ENDIF.

        UNASSIGN : <ls_item>.
        DELETE lt_ekpo WHERE open_qty = 0.
** For Updating Open Qty
        SELECT * FROM zinw_t_hdr INTO TABLE @DATA(lt_hdr_o) WHERE ebeln = @p_ebeln AND status < '04'.
        IF sy-subrc = 0.
          SELECT * FROM zinw_t_item INTO TABLE @DATA(lt_item_o) FOR ALL ENTRIES IN @lt_hdr_o WHERE qr_code = @lt_hdr_o-qr_code.
        ENDIF.
        LOOP AT lt_ekpo ASSIGNING <ls_ekpo>.
          CLEAR : lv_qty.
          LOOP AT lt_item_o ASSIGNING FIELD-SYMBOL(<ls_item_o>) WHERE ebeln = <ls_ekpo>-ebeln AND ebelp = <ls_ekpo>-ebelp AND matnr = <ls_ekpo>-matnr.
            ADD <ls_item_o>-menge_p TO lv_qty.
          ENDLOOP.
***       Calculating the OVER TOLARANCE Quantity
          CLEAR : lv_qty_tol.
          lv_qty_tol =  ( <ls_ekpo>-menge * <ls_ekpo>-uebto ) / 100.
          lv_qty_tol = floor( lv_qty_tol ).
          <ls_ekpo>-open_qty = <ls_ekpo>-open_qty - lv_qty + lv_qty_tol.
        ENDLOOP.

        DELETE lt_ekpo WHERE open_qty LE 0.
*** HSN code details
        SELECT matnr
               steuc
               stawn
               FROM marc INTO TABLE lt_marc FOR ALL ENTRIES IN lt_ekpo WHERE matnr = lt_ekpo-matnr.
        DELETE lt_marc WHERE steuc IS INITIAL.
*** Condtion Records
        SELECT * FROM a003 INTO TABLE lt_tax_code FOR ALL ENTRIES IN lt_ekpo WHERE mwskz = lt_ekpo-mwskz.
        IF lt_tax_code IS NOT INITIAL.
          SELECT * FROM konp INTO TABLE lt_konp FOR ALL ENTRIES IN lt_tax_code WHERE knumh = lt_tax_code-knumh AND loevm_ko = space.
        ENDIF.

*** Selling Price GST
        IF lt_marc IS NOT INITIAL.
          SELECT a900~steuc a900~knumh konp~kbetr FROM a900
                 INNER JOIN konp ON a900~knumh EQ konp~knumh INTO TABLE lt_900
                 FOR ALL ENTRIES IN lt_marc WHERE a900~steuc = lt_marc-steuc AND regio = c_reg AND wkreg = c_plnt
                 AND datbi GE sy-datum AND datab LE sy-datum AND loevm_ko = space.
        ENDIF.
*** Get Material Type : Branded or Non Branded
*        SELECT MATNR BRAND_ID EAN11 FROM MARA INTO TABLE LT_MARA FOR ALL ENTRIES IN LT_EKPO WHERE MATNR = LT_EKPO-MATNR AND BRAND_ID IS NOT NULL AND NUMTP = C_UC  .
        SELECT matnr brand_id ean11 numtp xchpf FROM mara INTO TABLE lt_mara FOR ALL ENTRIES IN lt_ekpo WHERE matnr = lt_ekpo-matnr AND brand_id IS NOT NULL.
        DELETE lt_mara WHERE brand_id IS INITIAL.
      ENDIF.

***  Header Data
      CLEAR : wa_item.
      wa_hdr-ebeln = wa_ekko-ebeln.
      wa_hdr-lifnr = wa_ekko-lifnr.
      wa_hdr-rec_date = sy-datum.
      IF lv_gr_date IS NOT INITIAL.
        wa_hdr-due_date = lv_gr_date + wa_ekko-zbd1t.
      ENDIF.
      SELECT SINGLE name1 FROM lfa1 INTO wa_hdr-name1  WHERE lifnr = wa_hdr-lifnr.
*** Item Details
      LOOP AT lt_ekpo ASSIGNING <ls_ekpo> WHERE zzset_material IS INITIAL.
        wa_item_scr-ebeln    = <ls_ekpo>-ebeln.
        wa_item_scr-ebelp    = <ls_ekpo>-ebelp.
        wa_item_scr-matnr    = <ls_ekpo>-matnr.
        wa_item_scr-maktx    = <ls_ekpo>-maktx.
        wa_item_scr-matkl    = <ls_ekpo>-matkl.
        wa_item_scr-werks    = <ls_ekpo>-werks.
        wa_item_scr-lgort    = <ls_ekpo>-lgort.
        wa_item_scr-menge    = <ls_ekpo>-menge.
        wa_item_scr-meins    = <ls_ekpo>-meins.
        wa_item_scr-open_qty = <ls_ekpo>-open_qty.
        wa_item_scr-netpr_p  = <ls_ekpo>-netpr.
        wa_item_scr-ean11    = <ls_ekpo>-ean11.

***     Discounts
*        READ TABLE lt_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd>) WITH KEY kposn = <ls_ekpo>-ebelp kschl = c_zds1.
*        IF sy-subrc = 0.
*          wa_item-discount  = <ls_prcd>-kbetr.
*        ENDIF.
        LOOP AT lt_prcd ASSIGNING <ls_prcd> WHERE kposn = <ls_ekpo>-ebelp.
          CASE <ls_prcd>-kschl.
            WHEN c_zds1.
              wa_item_scr-discount   = <ls_prcd>-kbetr.
            WHEN c_zds2.
              wa_item_scr-discount2  = <ls_prcd>-kbetr.
            WHEN c_zds3.
              wa_item_scr-discount3  = <ls_prcd>-kbetr.
            WHEN c_zfrb.
              wa_item_scr-freight  = <ls_prcd>-kbetr.
          ENDCASE.
        ENDLOOP.
***    Net price before Discount
        READ TABLE lt_prcd ASSIGNING <ls_prcd> WITH KEY kposn = <ls_ekpo>-ebelp kschl = c_pbxx.
        IF sy-subrc = 0.
          wa_item_scr-netpr_p   = <ls_prcd>-kbetr.
        ENDIF.
        APPEND wa_item_scr TO lt_item_scr.
        CLEAR : wa_item_scr.
      ENDLOOP.
***  For Set Materials
      DATA(lt_ekpo_set) = lt_ekpo.
***     Set Material Wise Loop
      DELETE lt_ekpo_set WHERE zzset_material IS INITIAL.
      IF lt_ekpo_set IS NOT INITIAL.
        UNASSIGN :<ls_ekpo>.
        SORT lt_ekpo_set BY zzset_material netpr.
        DELETE ADJACENT DUPLICATES FROM lt_ekpo_set COMPARING zzset_material netpr.
        LOOP AT lt_ekpo_set ASSIGNING <ls_ekpo>.
          wa_item_scr-ebeln    = <ls_ekpo>-ebeln.
          wa_item_scr-ebelp    = <ls_ekpo>-ebelp.
          wa_item_scr-matnr    = <ls_ekpo>-zzset_material.
          wa_item_scr-maktx    = <ls_ekpo>-maktx.
          wa_item_scr-matkl    = <ls_ekpo>-matkl.
          wa_item_scr-werks    = <ls_ekpo>-werks.
          wa_item_scr-lgort    = <ls_ekpo>-lgort.
***         For Set Material Sub Components
          CLEAR :lv_lines.
          DATA(lt_ekpo_s)  = lt_ekpo.
          SORT lt_ekpo_s BY zzset_material matnr.
          DELETE lt_ekpo_s WHERE zzset_material <> <ls_ekpo>-zzset_material.
          DELETE ADJACENT DUPLICATES FROM lt_ekpo_s COMPARING zzset_material matnr.
          DESCRIBE TABLE lt_ekpo_s LINES lv_lines.

          wa_item_scr-menge    = <ls_ekpo>-menge * lv_lines.
          wa_item_scr-meins    = c_set.
          wa_item_scr-netpr_p  = <ls_ekpo>-netpr.
          wa_item_scr-open_qty = <ls_ekpo>-open_qty * lv_lines.
          wa_item_scr-netwr_p  = <ls_ekpo>-netwr * lv_lines.
***     Discounts
          READ TABLE lt_prcd ASSIGNING <ls_prcd> WITH KEY kposn = <ls_ekpo>-ebelp.
          IF sy-subrc = 0.
            wa_item_scr-discount     = <ls_prcd>-kbetr.
          ENDIF.

***    Net price before Discount
          READ TABLE lt_prcd ASSIGNING <ls_prcd> WITH KEY kposn = <ls_ekpo>-ebelp kschl = c_pbxx.
          IF sy-subrc = 0.
            wa_item_scr-netpr_p   = <ls_prcd>-kbetr.
          ENDIF.

          APPEND wa_item_scr TO lt_item_scr.
          CLEAR :wa_item_scr.
        ENDLOOP.
      ENDIF. " Set Material
    ENDIF.
    SORT lt_item_scr BY ebeln ebelp.
  ENDIF.
ENDFORM.

FORM save_data .
  DATA :
    lv_mat_cat  TYPE char20,
    lv_error(1),
    wa_status   TYPE zinw_t_status.

*** Bill Amount Validation
*  IF wa_hdr-bill_amt IS INITIAL.
*    MESSAGE 'Fill the Bill Amount' TYPE 'E'.
*    EXIT.
*  ELSE.
*    IF wa_hdr-bill_amt <> lv_net_pay.
*      DATA(lv_diff_val) = lv_net_pay - wa_hdr-bill_amt.
*      DATA(lv_diff_per) =  ( lv_diff_val / lv_net_pay  ) * 100.
*      lv_diff_per = abs( lv_diff_per ).
*      lv_diff_val = abs( lv_diff_val ).
*      IF lv_diff_val > 50 OR lv_diff_per > 10 .
*        lv_error = c_e.
*        MESSAGE 'Net Bill Amount not Matched with Inward Amount' TYPE 'E'.
*        EXIT.
**      ELSEIF lv_diff_per > 10.
**        lv_error = c_e.
**        MESSAGE 'Net Bill Amount not Matched with Inward Amount' TYPE 'E'.
**        EXIT.
*      ENDIF.
*    ENDIF.
*  ENDIF.




*** Bill Amount Validation
  IF wa_hdr-bill_amt IS INITIAL.
    MESSAGE 'Fill the Bill Amount' TYPE 'E'.
    EXIT.
  ELSE.
    IF wa_hdr-bill_amt <> lv_net_pay.
      MESSAGE 'Net Bill Amount not Matched with Inward amount' TYPE 'I'.
    ENDIF.
  ENDIF.

*** Skipping Validation On Mandatory Fields for ZLOP Doc type
  IF lv_bsart <> c_zlop.
*** Skipping LR Number & Transporter Validation On Mandatory Fields for ZTAT Doc type
    IF lv_bsart <> c_ztat.
      IF wa_hdr-trns IS INITIAL OR wa_hdr-lr_no IS INITIAL OR wa_hdr-lr_date IS INITIAL OR
        wa_hdr-bill_num IS INITIAL OR wa_hdr-bill_date IS INITIAL AND wa_hdr-act_no_bud IS INITIAL.
        lv_error = c_e.
        MESSAGE e006(zmsg_cls).
        EXIT.
      ELSEIF wa_hdr-act_no_bud LE 0.
        lv_error = c_e.
        MESSAGE e064(zmsg_cls).
        EXIT.
      ENDIF.
    ELSEIF lv_bsart = c_ztat.
      IF wa_hdr-bill_num IS INITIAL OR wa_hdr-bill_date IS INITIAL.
        lv_error = c_e.
        MESSAGE e006(zmsg_cls)." DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
  ELSE.
    IF  wa_hdr-bill_num IS INITIAL OR wa_hdr-bill_date IS INITIAL AND wa_hdr-act_no_bud IS INITIAL.
      lv_error = c_e.
      MESSAGE e006(zmsg_cls).
      EXIT.
    ELSEIF wa_hdr-act_no_bud LE 0.
      lv_error = c_e.
      MESSAGE e064(zmsg_cls).
      EXIT.
    ENDIF.
  ENDIF.
  REFRESH lt_item.
  MOVE-CORRESPONDING lt_item_scr TO lt_item.
***  Deleting the Items which has '0' Purchage Quantity
  DELETE lt_item WHERE menge_p IS INITIAL.
  CHECK lt_item IS NOT INITIAL.
  LOOP AT lt_item ASSIGNING <ls_item>.
    IF <ls_item>-menge_p > <ls_item>-open_qty.
      lv_error = c_e.
      MESSAGE e004(zmsg_cls)."DISPLAY LIKE C_E.
      EXIT.
    ENDIF.
***  Margin or Discount check
    IF <ls_item>-netwr_s IS INITIAL AND lv_group <> c_consumables.
      lv_error = c_e.
      MESSAGE e066(zmsg_cls).
      EXIT.
    ENDIF.
    READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = <ls_item>-matnr.
    IF sy-subrc = 0.
      IF <ls_mara>-brand_id IS INITIAL.
        IF <ls_item>-margn IS INITIAL AND <ls_item>-menge_p IS NOT INITIAL.
          lv_error = c_e.
          MESSAGE e015(zmsg_cls).
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_error <> c_e.
    IF wa_hdr-qr_code IS INITIAL.
*** Get Next number for QR code from Number range
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '1'
          object                  = 'ZQR_NO'
        IMPORTING
          number                  = wa_hdr-inwd_doc
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
      p_qr_code        = wa_hdr-qr_code = sy-datum && sy-uzeit && wa_hdr-inwd_doc+8(2).
      wa_hdr-ername    = sy-uname.
      wa_hdr-erdate    = sy-datum.
      wa_hdr-ertime    = sy-uzeit.
      wa_hdr-status    = c_01.
      lv_status = 'NEW'.
      wa_item-qr_code = wa_hdr-qr_code.

***   For Updating Status Table
      wa_status-qr_code      = wa_hdr-qr_code.
      wa_status-inwd_doc     = wa_hdr-inwd_doc.
      wa_status-status_field = c_qr_code.
      wa_status-status_value = c_qr01.
      wa_status-description  = 'QR Code Created'.
      wa_status-created_by   = sy-uname.
      wa_status-created_date = sy-datum.
      wa_status-created_time = sy-uzeit.
***   Updating Sub Components for SET Materials
      READ TABLE lt_item WITH KEY meins = c_set TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DATA(lt_item_set) = lt_item.
        DELETE lt_item_set WHERE meins = c_set.
        LOOP AT lt_item ASSIGNING <ls_item> WHERE meins = c_set.
          MOVE-CORRESPONDING <ls_item> TO wa_item.
          DATA(lt_ekpo_set) = lt_ekpo.
          SORT lt_ekpo_set BY zzset_material matnr.
          DELETE lt_ekpo_set WHERE zzset_material <> <ls_item>-matnr .
          DELETE lt_ekpo_set WHERE netpr <> <ls_item>-netpr_p.
          DESCRIBE TABLE lt_ekpo_set LINES DATA(lv_lines).
***       Sub Components
          LOOP AT lt_ekpo_set ASSIGNING FIELD-SYMBOL(<ls_ekpo>) WHERE zzset_material =  <ls_item>-matnr.
            wa_item-qr_code          = wa_hdr-qr_code.
            wa_item-matnr            = <ls_ekpo>-matnr.
            wa_item-maktx            = <ls_ekpo>-maktx.
            wa_item-ebelp            = <ls_ekpo>-ebelp.
            wa_item-meins            = <ls_ekpo>-meins.
            wa_item-zzset_material   = <ls_ekpo>-zzset_material.
            wa_item-menge            = <ls_item>-menge / lv_lines.
            wa_item-open_qty         = <ls_item>-open_qty / lv_lines.
            wa_item-menge_p          = <ls_item>-menge_p / lv_lines.
            wa_item-netpr_gp         = <ls_item>-netpr_gp / lv_lines.
            wa_item-menge_s          = <ls_item>-menge_s / lv_lines.
            wa_item-netpr_gs         = <ls_item>-netpr_gs / lv_lines.
            wa_item-netwr_p          = <ls_item>-netwr_p / lv_lines.
            wa_item-netwr_s          = <ls_item>-netwr_s / lv_lines.
            APPEND wa_item TO lt_item_set.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
      IF lt_item_set IS NOT INITIAL.
***   FOR UPDATING CONDITION RECORDS
        LOOP AT lt_item_set ASSIGNING <ls_item>.
          CLEAR : lv_mat_cat.
*          SELECT SINGLE EANNR FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR." AND EANNR = C_UC.
****  EAN Managed material
*          IF SY-SUBRC = 0.
*            <LS_ITEM>-MAT_CAT = C_E.
*          ELSE.
*            SELECT SINGLE XCHPF FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND XCHPF = C_X.
****  Batch Managed material
*            IF SY-SUBRC = 0.
*              <LS_ITEM>-MAT_CAT = C_B.
*            ELSE.
*              SELECT SINGLE SERNP FROM MARC INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND WERKS = <LS_ITEM>-WERKS AND SERNP IS NOT NULL.
****  Serial Number Managed material
*              IF SY-SUBRC = 0.
*                <LS_ITEM>-MAT_CAT = C_S.
*              ELSE.
****  General Material
*                <LS_ITEM>-MAT_CAT = C_G.
*              ENDIF.
*            ENDIF.
*          ENDIF.

***  BATCH MANAGED MATERIAL
          SELECT SINGLE xchpf FROM mara INTO lv_mat_cat WHERE matnr = <ls_item>-matnr AND xchpf = c_x ."AND BRAND_ID EQ SPACE.
          IF sy-subrc = 0.
            <ls_item>-mat_cat = c_b.
          ENDIF.
          <ls_item>-qr_code = wa_hdr-qr_code.
        ENDLOOP.
        MODIFY zinw_t_hdr FROM wa_hdr.
        MODIFY zinw_t_item FROM TABLE lt_item_set.
        IF sy-subrc = 0.
          IF wa_status IS NOT INITIAL.
            MODIFY zinw_t_status FROM wa_status.
          ENDIF.
          MESSAGE s002(zmsg_cls).
        ENDIF.
      ELSE.
***   FOR UPDATING CONDITION RECORDS
        LOOP AT lt_item ASSIGNING <ls_item>.
          CLEAR : lv_mat_cat.
*          SELECT SINGLE EAN11 FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR.
****  EAN Managed material
*          IF SY-SUBRC = 0.
*            <LS_ITEM>-MAT_CAT = C_E.
*          ELSE.
*            SELECT SINGLE XCHPF FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND XCHPF = C_X AND BRAND_ID EQ SPACE.
****  Batch Managed material
*            IF SY-SUBRC = 0.
*              <LS_ITEM>-MAT_CAT = C_B.
*            ELSE.
*              SELECT SINGLE SERNP FROM MARC INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND WERKS = <LS_ITEM>-WERKS AND SERNP IS NOT NULL.
****  Serial Number Managed material
*              IF SY-SUBRC = 0.
*                <LS_ITEM>-MAT_CAT = C_S.
*              ELSE.
****  General Material
*                <LS_ITEM>-MAT_CAT = C_G.
*              ENDIF.
*            ENDIF.
*          ENDIF.

***  BATCH MANAGED MATERIAL
          SELECT SINGLE xchpf FROM mara INTO lv_mat_cat WHERE matnr = <ls_item>-matnr AND xchpf = c_x ."AND BRAND_ID EQ SPACE.
          IF sy-subrc = 0.
            <ls_item>-mat_cat = c_b.
          ENDIF.
          <ls_item>-qr_code = wa_hdr-qr_code.
        ENDLOOP.
        MODIFY zinw_t_hdr FROM wa_hdr.
        MODIFY zinw_t_item FROM TABLE lt_item.
        IF sy-subrc = 0.
          IF wa_status IS NOT INITIAL.
            MODIFY zinw_t_status FROM wa_status.
          ENDIF.
          MESSAGE s002(zmsg_cls).
        ENDIF.
      ENDIF.
    ELSE.
      MODIFY zinw_t_hdr FROM wa_hdr.
      MODIFY zinw_t_status FROM ls_status.
      IF sy-subrc = 0.
        MESSAGE s002(zmsg_cls).
      ENDIF.
    ENDIF.
**** Printing Form
*    PERFORM TP2_FORM IN PROGRAM ZMM_GRPO_DET_REP USING WA_HDR-QR_CODE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear .
  CLEAR : p_ebeln, lv_trns, p_qr_code ,ok_code ,wa_hdr , wa_hdr-bill_amt.
  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form MODIFY_TC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_price .
** Calling the check_changed_data method to trigger the data_changed  event
  DATA : wl_refresh TYPE c VALUE 'X'.
  IF grid IS BOUND.
    CALL METHOD grid->check_changed_data
      CHANGING
        c_refresh = wl_refresh.
  ENDIF.
  LOOP AT lt_item ASSIGNING <ls_item>.
    IF <ls_item>-menge_p IS NOT INITIAL.
      IF <ls_item>-menge_p LE <ls_item>-open_qty.
*** Selling Qty
        <ls_item>-menge_s = wa_item-menge_p.
*** Purchage Rate
        <ls_item>-netwr_p = wa_item-menge_p * wa_item-netpr_p.
*** Margin
*** Vendor & Material Combination
        SELECT SINGLE konp~kbetr FROM konp
               INNER JOIN a502 ON konp~knumh = a502~knumh INTO <ls_item>-margn
               WHERE a502~lifnr = wa_hdr-lifnr
               AND   a502~matnr = <ls_item>-matnr.

        IF sy-subrc <> 0 OR <ls_item>-margn IS INITIAL.
          SELECT SINGLE konp~kbetr FROM konp
               INNER JOIN a502 ON konp~knumh = a502~knumh INTO <ls_item>-margn
               WHERE a502~lifnr = wa_hdr-lifnr
               AND   a502~matnr = <ls_item>-matnr.
        ENDIF.
***  Selling GST tax code
*        <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P.
        <ls_item>-margn = <ls_item>-margn / 10.
*** Selling Price
        <ls_item>-netpr_s = ( ( <ls_item>-margn * <ls_item>-netpr_p ) / 100 ) +  ( ( ( <ls_item>-netpr_gp * <ls_item>-margn ) / 100 ) / <ls_item>-menge_s  ) + <ls_item>-netpr_p.
***  Selling Amount
        <ls_item>-netwr_s =  <ls_item>-menge_s * <ls_item>-netpr_s.
*** Selling Price GST
        READ TABLE lt_marc ASSIGNING FIELD-SYMBOL(<ls_marc>) WITH KEY matnr = <ls_item>-matnr.
***  HSN Code
        IF sy-subrc = 0.
          <ls_item>-steuc = <ls_marc>-steuc.
          READ TABLE lt_900 ASSIGNING FIELD-SYMBOL(<ls_900>) WITH KEY steuc = <ls_marc>-steuc.
          IF sy-subrc = 0.
            DATA(lv_tax) = <ls_900>-kbetr / 5 .
            <ls_item>-netpr_gs = ( <ls_item>-netwr_s / ( lv_tax + 100 ) ) * lv_tax .
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE e004(zmsg_cls).
      ENDIF.
    ENDIF.
*** Updating Totals
    CLEAR : wa_hdr-total, wa_hdr-pur_total,wa_hdr-net_amt,wa_hdr-t_gst.
    ADD <ls_item>-netwr_s  TO wa_hdr-total.
    ADD <ls_item>-netwr_p  TO wa_hdr-pur_total.
    ADD <ls_item>-netpr_gp TO wa_hdr-pur_total.
    ADD <ls_item>-netpr_gs TO wa_hdr-t_gst.
    wa_hdr-net_amt = wa_hdr-pur_total.
  ENDLOOP.
*  WA_HDR-GRC_PFR =  WA_HDR-TOTAL - WA_HDR-NET_AMT.
  IF grid IS BOUND.
*    CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
    DATA: is_stable TYPE lvc_s_stbl.
    is_stable = 'XX'.
    CALL METHOD grid->refresh_table_display
      EXPORTING
        is_stable = is_stable
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MODE
*&---------------------------------------------------------------------*
FORM display_mode.
  IF wa_hdr-status = '07' OR wa_hdr-status = '06' OR  wa_hdr-status = '05'.
    CASE wa_hdr-status.
      WHEN '07'.
*** Payment Done
        LOOP AT SCREEN.
          IF screen-name = 'B_DISP'   OR screen-name = 'B_EDIT'     OR screen-name = 'B_PRINT'   OR
             screen-name = 'B_CLEAR'  OR screen-name = 'B_DEBIT_D'  OR screen-name = 'B_TAT_D'   OR
             screen-name = 'B_GRPO_P' OR screen-name = 'B_GRPO_S'   OR screen-name = 'B_PAY_ADV' OR
             screen-name = 'B_TRNS'   OR screen-name = 'B_AUDITOR'.
            CONTINUE.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      WHEN '06'.
*** Invoice Done
        LOOP AT SCREEN.
          IF screen-name = 'B_DISP'    OR screen-name = 'B_EDIT'    OR screen-name = 'B_PRINT'  OR
             screen-name = 'B_CLEAR'   OR screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'  OR
             screen-name = 'B_PAYMENT' OR screen-name = 'B_GRPO_P'  OR screen-name = 'B_GRPO_S' OR
             screen-name = 'B_TRNS'    OR screen-name = 'WA_PAYMENT-PAYMENT_MODE'.
            CONTINUE.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      WHEN '05'.
*** DOC COMPLITED
        CASE wa_approve-app_status.
          WHEN 'L1'.
            LOOP AT SCREEN.
              IF screen-name = 'B_DISP'       OR screen-name = 'B_EDIT'    OR screen-name = 'B_PRINT'  OR
                 screen-name = 'B_CLEAR'      OR screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'  OR
                 screen-name = 'B_APPROVE_1'  OR screen-name = 'B_GRPO_P'  OR screen-name = 'B_GRPO_S' OR
                 screen-name = 'B_TRNS'.
                CONTINUE.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
          WHEN 'L2'.
            LOOP AT SCREEN.
              IF screen-name = 'B_DISP'       OR screen-name = 'B_EDIT'    OR screen-name = 'B_PRINT'  OR
                 screen-name = 'B_CLEAR'      OR screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'  OR
                 screen-name = 'B_APPROVE_1'  OR screen-name = 'B_GRPO_P'  OR screen-name = 'B_GRPO_S' OR
                 screen-name = 'B_TRNS'.
                CONTINUE.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
          WHEN 'L3'.
            LOOP AT SCREEN.
              IF screen-name = 'B_DISP'      OR screen-name = 'B_EDIT'    OR screen-name = 'B_PRINT'  OR
                 screen-name = 'B_CLEAR'     OR screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'  OR
                 screen-name = 'B_APPROVE_2' OR screen-name = 'B_GRPO_P'  OR screen-name = 'B_GRPO_S' OR
                 screen-name = 'B_TRNS'.
                CONTINUE.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
          WHEN space.
            LOOP AT SCREEN.
              IF screen-name = 'B_DISP'      OR screen-name = 'B_EDIT'    OR screen-name = 'B_PRINT'  OR
                 screen-name = 'B_CLEAR'     OR screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'  OR
                 screen-name = 'B_APPROVE_3' OR screen-name = 'B_GRPO_P'  OR screen-name = 'B_GRPO_S' OR
                 screen-name = 'B_TRNS'.
                CONTINUE.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
        ENDCASE.

    ENDCASE.
  ELSE.
    IF lv_mod = c_d AND ( p_ebeln IS NOT INITIAL OR p_qr_code IS NOT INITIAL ) .
***  Display Mode with PO or QR Code
      LOOP AT SCREEN.
        IF screen-name = 'B_DISP'   OR screen-name  = 'B_EDIT'    OR screen-name = 'B_PRINT'   OR
           screen-name = 'B_CLEAR'  OR screen-name  = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'   OR
           screen-name = 'B_GRPO_P' OR screen-name  = 'B_GRPO_S'  OR screen-name = 'B_TRNS' .
          CONTINUE.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
*** Edit Mode & QR as input
    ELSEIF lv_mod  = 'E' AND p_ebeln IS NOT INITIAL AND p_qr_code IS NOT INITIAL.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
        IF lv_bsart = c_zlop OR lv_bsart = c_ztat.
          IF screen-name = 'B_DISP'    OR screen-name = 'B_EDIT'    OR screen-name = 'B_PRINT' OR
             screen-name = 'B_CLOSE'   OR screen-name = 'B_CLEAR'   OR screen-name = 'P_EBELN' OR
             screen-name = 'P_QR_CODE' OR screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D' OR
             screen-name = 'B_GRPO_P'  OR screen-name = 'B_GRPO_S'  OR screen-name = 'B_TRNS'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
          IF screen-name = 'B_DISP'    OR screen-name = 'B_EDIT'   OR screen-name = 'B_PRINT'   OR
             screen-name = 'B_CLEAR'   OR screen-name = 'P_EBELN'  OR screen-name = 'P_QR_CODE' OR
             screen-name = 'B_DEBIT_D' OR screen-name = 'B_TAT_D'  OR screen-name = 'B_GRPO_P'  OR
             screen-name = 'B_GRPO_S'  OR screen-name = 'B_TRNS'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSEIF wa_hdr-status = '04' AND wa_hdr-soe IS INITIAL.
            IF screen-name = 'B_SHORTAGE' OR screen-name = 'B_EXCESS' OR screen-name = 'B_MATCHED' .
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF wa_hdr-status = '04' AND wa_hdr-soe = '03'.
            IF screen-name = 'B_SHORTAGE' OR screen-name = 'B_CLOSE'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF wa_hdr-status = '04' AND wa_hdr-soe = '02'.
            IF screen-name = 'B_EXCESS' OR screen-name = 'B_CLOSE'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF wa_hdr-status = '04' AND wa_hdr-soe IS NOT INITIAL.
            IF screen-name = 'B_CLOSE'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
*** Edit Mode with only PO as inputed
    ELSEIF lv_mod  = 'E' AND p_ebeln IS NOT INITIAL AND p_qr_code IS INITIAL.
      LOOP AT SCREEN.
***  Disabling Excess / Shortage / Matched Buttons
        IF screen-name = 'B_SHORTAGE'  OR screen-name = 'B_EXCESS'    OR screen-name = 'B_MATCHED'   OR
           screen-name = 'B_CLOSE'     OR screen-name = 'B_DEBIT_D'   OR screen-name = 'B_TAT_D'     OR
           screen-name = 'B_APPROVE_1' OR screen-name = 'B_APPROVE_2' OR screen-name = 'B_APPROVE_3' OR
           screen-name = 'B_PAYMENT'   OR screen-name = 'B_PAY_ADV'   OR screen-name = 'B_TRNS'      OR
           screen-name = 'B_AUDITOR'   OR screen-name = 'B_GRPO_P'    OR screen-name = 'B_GRPO_S'    OR
           screen-name = 'B_PRINT'     OR screen-name = 'WA_PAYMENT-PAYMENT_MODE'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
***   For Tatkal PO Transporter , Number of Bundles and LR number in display mode
        IF lv_bsart = c_ztat.
          IF screen-name = 'WA_HDR-TRNS' OR screen-name = 'WA_HDR-ACT_NO_BUD' OR screen-name = 'WA_HDR-LR_NO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_PO_QTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM VALIDATE_PO_QTY.
*  IF LT_ITEM IS NOT INITIAL.
*    IF wa_item-MENGE_P IS INITIAL.
*      MESSAGE 'Enter PO' TYPE 'E'.
*    ENDIF.
*  ENDIF.
*ENDFORM.
*** Totals
*FORM UPDATE_TOTALS.
*  CLEAR : WA_HDR-TOTAL, WA_HDR-PUR_TOTAL,WA_HDR-NET_AMT,WA_HDR-T_GST,WA_HDR-GRC_PFR.
*  LOOP AT LT_ITEM INTO wa_item.
*    ADD wa_item-NETWR_S  TO WA_HDR-TOTAL.
*    ADD wa_item-NETWR_P  TO WA_HDR-PUR_TOTAL.
*    ADD wa_item-NETPR_GP TO WA_HDR-PUR_TOTAL.
*    ADD wa_item-NETPR_GS TO WA_HDR-T_GST.
*    WA_HDR-NET_AMT = WA_HDR-PUR_TOTAL.
*  ENDLOOP.
*  WA_HDR-GRC_PFR =  WA_HDR-TOTAL - WA_HDR-NET_AMT.
*ENDFORM.

***** Comdition Record Uplaod - VK11
*FORM MATERIAL_CAT_UPDATE.
*  DATA : LV_MAT_CAT TYPE CHAR10.
*
*  LOOP AT LT_ITEM INTO wa_item.
*    SELECT SINGLE XCHPF FROM MARA INTO LV_MAT_CAT WHERE MATNR = wa_item-MATNR AND XCHPF = C_X.
*    IF SY-SUBRC = 0.
****  Batch Managed material
*      DATA(I_TYPE) = 'B'.
*      PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*    ELSE.
*      SELECT SINGLE SERNP FROM MARC INTO LV_MAT_CAT WHERE MATNR = wa_item-MATNR AND WERKS = wa_item-WERKS AND SERNP IS NOT NULL.
*      IF SY-SUBRC = 0.
****  Serial Number Managed material
*        I_TYPE = 'S'.
*        PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*      ELSE.
*        SELECT SINGLE EANNR FROM MARA INTO LV_MAT_CAT WHERE MATNR = wa_item-MATNR AND EANNR = C_UC.
*        IF SY-SUBRC = 0.
****  EAN Managed material
*          I_TYPE = C_E.
*          PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*        ELSE.
****  General Material
*          I_TYPE = 'G'.
*          PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.
**&---------------------------------------------------------------------*
*& Form UPLOAD_CONDTION_RECORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_TYPE
*&---------------------------------------------------------------------*
*FORM UPLOAD_CONDTION_RECORD USING P_I_TYPE.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcat.
***  Displaying date in ALV Grid
  IF lt_fieldcat IS INITIAL.
*** SLNO
    ls_fieldcat-fieldname   = 'SNO'.
    ls_fieldcat-reptext     = 'SNO'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Group Code
    ls_fieldcat-fieldname   = 'MATKL'.
    ls_fieldcat-reptext     = 'Category Code'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** SST CODE
    ls_fieldcat-fieldname   = 'MATNR'.
    ls_fieldcat-reptext     = 'SST Code'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Product Description
    ls_fieldcat-fieldname   = 'MAKTX'.
    ls_fieldcat-reptext     = 'Product Description'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** OPEN_QTY
    ls_fieldcat-fieldname   = 'OPEN_QTY'.
    ls_fieldcat-reptext     = 'Open Qty'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
*    ls_fieldcat-decimals_o  = '0'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Pur.Qty
    ls_fieldcat-fieldname   = 'MENGE_P'.
    ls_fieldcat-reptext     = 'Pur.Qty'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-ref_table   = 'ZINW_T_ITEM'.
    ls_fieldcat-datatype    = 'QUAN'.

    IF lv_mod = 'E'.
      ls_fieldcat-edit   = 'X'.
      ls_fieldcat-decimals_o   = '0'.
    ELSEIF lv_mod = 'D'.
      CLEAR : ls_fieldcat-edit.
    ENDIF.
    ls_fieldcat-no_zero   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Pur.UoM
    ls_fieldcat-fieldname   = 'MEINS'.
    ls_fieldcat-reptext     = 'Pur.UoM'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Num Of Rolls
    ls_fieldcat-fieldname   = 'NO_ROLL'.
    ls_fieldcat-reptext     = 'Num of Rolls'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.

    IF lv_mod = 'E'.
      ls_fieldcat-edit   = 'X'.
      ls_fieldcat-decimals_o   = '0'.
      ls_fieldcat-datatype     = 'DEC'.
    ELSEIF lv_mod = 'D'.
      CLEAR : ls_fieldcat-edit.
    ENDIF.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** EAN Number
    ls_fieldcat-fieldname   = 'EAN11'.
    ls_fieldcat-reptext     = 'EAN NO'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Pur Rate
    ls_fieldcat-fieldname   = 'NETPR_P'.
    ls_fieldcat-reptext     = 'Pur Rate'.
    ls_fieldcat-fieldname   = 'NETPR_P'.
    ls_fieldcat-tabname     = 'ZINW_T_ITEM'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-datatype    = 'CURR'.
    ls_fieldcat-currency    = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Discount
    ls_fieldcat-fieldname   = 'DISCOUNT'.
    ls_fieldcat-reptext     = 'Discount1 %'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

    APPEND VALUE #( fieldname   = 'DISCOUNT2' reptext = 'Discount2 %' col_opt = 'X' txt_field = 'X' no_zero = 'X' ) TO lt_fieldcat.
    APPEND VALUE #( fieldname   = 'DISCOUNT3' reptext = 'Discount3' col_opt = 'X' no_zero = 'X' datatype = 'CURR' currency = 'X' ) TO lt_fieldcat.
    APPEND VALUE #( fieldname   = 'FREIGHT' reptext = 'Freight' col_opt = 'X' no_zero = 'X' datatype = 'CURR' currency = 'X' ) TO lt_fieldcat.

*** Pur.GST Code
    ls_fieldcat-fieldname   = 'STEUC'.
    ls_fieldcat-reptext     = 'GST Code'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Tax %
    ls_fieldcat-fieldname   = 'KBETR'.
    ls_fieldcat-reptext     = 'Tax %'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Pur.GST Value
    ls_fieldcat-fieldname   = 'NETPR_GP'.
    ls_fieldcat-reptext     = 'Pur.GST Value'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Pur Amount
    ls_fieldcat-fieldname   = 'NETWR_P'.
    ls_fieldcat-reptext     = 'Pur Amount'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Margin
    ls_fieldcat-fieldname   = 'MARGN'.
    ls_fieldcat-reptext     = 'Margin'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Selling Rate
    ls_fieldcat-fieldname   = 'MENGE_S'.
    ls_fieldcat-reptext     = 'Selling Qty'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Selling Rate
    ls_fieldcat-fieldname   = 'NETPR_S'.
    ls_fieldcat-reptext     = 'Selling Rate'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Sel GST Value
    ls_fieldcat-fieldname   = 'NETPR_GS'.
    ls_fieldcat-reptext     = 'Sel GST Value'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.

*** Selling Amount
    ls_fieldcat-fieldname   = 'NETWR_S'.
    ls_fieldcat-reptext     = 'Selling Amount'.
    ls_fieldcat-col_opt     = 'X'.
    ls_fieldcat-txt_field   = 'X'.
    ls_fieldcat-no_zero     = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
  ELSE.
*** Input Quantity
    READ TABLE lt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>) WITH KEY fieldname   = 'MENGE_P'.
    IF sy-subrc  = 0.
      IF lv_mod = 'E'.
        IF  wa_hdr-qr_code IS NOT INITIAL.
          CLEAR : <ls_fieldcat>-edit.
        ELSEIF lv_group = 'BLOUSE' OR lv_group = 'CHUDIMATERIAL' OR  lv_group = 'SHIRTINGANDSUITING' OR lv_group = 'PROVISIONS' OR lv_group = 'VESSELS'.
          <ls_fieldcat>-edit       = 'X'.
          <ls_fieldcat>-decimals_o = '2'.
          <ls_fieldcat>-ref_field  = 'MENGE_P'.
          <ls_fieldcat>-ref_table  = 'ZINW_T_ITEM'.
        ELSE.
          <ls_fieldcat>-edit         = 'X'.
          <ls_fieldcat>-decimals_o   = '0'.
          ls_fieldcat-datatype    = 'INT4'.
        ENDIF.
      ELSEIF lv_mod = 'D'.
        CLEAR : <ls_fieldcat>-edit.
      ENDIF.
    ENDIF.
*** Number of Rolls
    READ TABLE lt_fieldcat ASSIGNING <ls_fieldcat> WITH KEY fieldname = 'NO_ROLL' .
    IF sy-subrc  = 0.
      IF lv_group = 'BLOUSE' OR lv_group = 'CHUDIMATERIAL' OR  lv_group = 'SHIRTINGANDSUITING' OR  lv_group = 'FURNISHING'.  "" FURNISHING added by skn on 02.03.2020 as per praveen reddy
        IF lv_mod = 'E'.
          IF  wa_hdr-qr_code IS NOT INITIAL.
            CLEAR : <ls_fieldcat>-edit.
          ELSE.
            <ls_fieldcat>-edit       = 'X'.
          ENDIF.
        ELSEIF lv_mod = 'D'.
          CLEAR : <ls_fieldcat>-edit.
        ENDIF.
      ELSE.
        <ls_fieldcat>-tech   = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
FORM display_data .

  IF custom_container IS INITIAL .
    CREATE OBJECT custom_container
      EXPORTING
        container_name = mycontainer.
    CREATE OBJECT grid
      EXPORTING
        i_parent = custom_container.
  ENDIF.
*** CREATE OBJECT event_receiver.
  IF lr_event IS NOT BOUND.
    CREATE OBJECT lr_event.
***---setting event handlers
*    SET HANDLER LR_EVENT->HANDLE_USER_COMMAND  FOR GRID.
  ENDIF.
  LOOP AT lt_item_scr ASSIGNING <ls_item_scr>.
    <ls_item_scr>-sno = sy-tabix.
  ENDLOOP.
  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = ls_layout
      it_toolbar_excluding          = lt_tlbr_excl  " Excluded Toolbar Standard Functions
    CHANGING
      it_outtab                     = lt_item_scr
      it_fieldcatalog               = lt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*** input
  CALL METHOD grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.
***  Registering the EDIT Event
  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  SET HANDLER lr_event->handle_data_changed FOR grid.
*  SET HANDLER LR_EVENT->HANDLE_HOTSPOT_CLICK FOR GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_ICONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_icons .
  IF lt_tlbr_excl IS NOT INITIAL.
    RETURN.
  ENDIF.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO lt_tlbr_excl.
  CLEAR : ls_exclude.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> T_DATA
*&---------------------------------------------------------------------*
*FORM CHECK_DATA  USING    P_ER_DATA_CHANGED
*                          P_T_DATA.
*  data: ls_good type lvc_s_modi.
*  BREAK-POINT.
* loop at P_ER_DATA_CHANGED->mt_good_cells into ls_good.
* ENDLOOP.
*  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
*    IF <LS_ITEM>-MENGE_P IS NOT INITIAL.
*      IF <LS_ITEM>-MENGE_P LE <LS_ITEM>-OPEN_QTY.
**** Selling Qty
*        <LS_ITEM>-MENGE_S = wa_item-MENGE_P.
**** Purchage Rate
*        <LS_ITEM>-NETWR_P = wa_item-MENGE_P * wa_item-NETPR_P.
**** Margin
**** Vendor & Material Combination
*        SELECT SINGLE KONP~KBETR FROM KONP
*               INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
*               WHERE A502~LIFNR = WA_HDR-LIFNR
*               AND   A502~MATNR = <LS_ITEM>-MATNR.
*
*        IF SY-SUBRC <> 0 OR <LS_ITEM>-MARGN IS INITIAL.
*          SELECT SINGLE KONP~KBETR FROM KONP
*               INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
*               WHERE A502~LIFNR = WA_HDR-LIFNR
*               AND   A502~MATNR = <LS_ITEM>-MATNR.
*        ENDIF.
****  Selling GST tax code
*        <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P.
*        <LS_ITEM>-MARGN = <LS_ITEM>-MARGN / 10.
**** Selling Price
*        <LS_ITEM>-NETPR_S = ( ( <LS_ITEM>-MARGN * <LS_ITEM>-NETPR_P ) / 100 ) +  ( ( ( <LS_ITEM>-NETPR_GP * <LS_ITEM>-MARGN ) / 100 ) / <LS_ITEM>-MENGE_S  ) + <LS_ITEM>-NETPR_P.
****  Selling Amount
*        <LS_ITEM>-NETWR_S =  <LS_ITEM>-MENGE_S * <LS_ITEM>-NETPR_S.
**** Selling Price GST
*        READ TABLE LT_MARC ASSIGNING FIELD-SYMBOL(<LS_MARC>) WITH KEY MATNR = <LS_ITEM>-MATNR.
****  HSN Code
*        IF SY-SUBRC = 0.
*          <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P = <LS_MARC>-STEUC.
*          READ TABLE LT_900 ASSIGNING FIELD-SYMBOL(<LS_900>) WITH KEY STEUC = <LS_MARC>-STEUC.
*          IF SY-SUBRC = 0.
*            DATA(LV_TAX) = <LS_900>-KBETR / 5 .
*            <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TAX + 100 ) ) * LV_TAX .
*          ENDIF.
*        ENDIF.
*      ELSE.
*        MESSAGE 'Entered PO Quantity greater than Open PO Quantity' TYPE C_E.
*      ENDIF.
*    ENDIF.
**** Updating Totals
*    CLEAR : WA_HDR-TOTAL, WA_HDR-PUR_TOTAL,WA_HDR-NET_AMT,WA_HDR-T_GST,WA_HDR-GRC_PFR.
*    ADD <LS_ITEM>-NETWR_S  TO WA_HDR-TOTAL.
*    ADD <LS_ITEM>-NETWR_P  TO WA_HDR-PUR_TOTAL.
*    ADD <LS_ITEM>-NETPR_GP TO WA_HDR-PUR_TOTAL.
*    ADD <LS_ITEM>-NETPR_GS TO WA_HDR-T_GST.
*    WA_HDR-NET_AMT = WA_HDR-PUR_TOTAL.
*  ENDLOOP.
*  WA_HDR-GRC_PFR =  WA_HDR-TOTAL - WA_HDR-NET_AMT.
*  IF GRID IS BOUND.
*    CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
*  ENDIF.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_QR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_qr .
  IF p_qr_code IS NOT INITIAL.
    SELECT SINGLE qr_code FROM zinw_t_hdr INTO @DATA(lv_qr) WHERE qr_code = @p_qr_code.
    IF sy-subrc  <> 0.
      MESSAGE e024(zmsg_cls).
    ENDIF.
  ELSEIF p_ebeln IS INITIAL.
    MESSAGE e001(zmsg_cls).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_header.
  CHECK sy-ucomm <> c_clear.
  CHECK p_qr_code IS INITIAL.
***  DOC TYPE CHECKING
  IF lv_bsart <> c_zlop.
*** Billing Date should not be future
    IF wa_hdr-bill_date GT sy-datum.
      MESSAGE e016(zmsg_cls).
    ENDIF.
*** For Tatkal PO
    IF lv_bsart = c_ztat.
*** VALIDATION ON PO AMOUNT MORE THEN 3000.
*    SELECT SUM( NETWR ) FROM EKPO INTO @DATA(LV_PO_AMOUNT) WHERE EBELN = @P_EBELN.
*    IF LV_PO_AMOUNT > C_3000 AND WA_EKKO-FRGKE = 'B'.
      IF wa_ekko-frgke = 'B'.
        MESSAGE e052(zmsg_cls) WITH p_ebeln.
      ENDIF.
*** For Fetching Same Transported & LR Number
      SELECT SINGLE * FROM zinw_t_hdr INTO @DATA(ls_hdr) WHERE  tat_po = @p_ebeln.
      IF ls_hdr IS NOT INITIAL.
        wa_hdr-trns = ls_hdr-trns.
        wa_hdr-lr_no = ls_hdr-lr_no.
        SELECT SINGLE name1 FROM lfa1 INTO lv_trns WHERE lifnr = wa_hdr-trns.
        IF sy-subrc <> 0.
          MESSAGE e021(zmsg_cls) WITH wa_hdr-trns.
        ENDIF.
      ENDIF.
    ELSEIF lv_bsart <> c_zlop.
***   For Out Station PO
      IF wa_hdr-trns IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_hdr-trns
          IMPORTING
            output = wa_hdr-trns.

        SELECT SINGLE name1 FROM lfa1 INTO lv_trns WHERE lifnr = wa_hdr-trns.
        IF sy-subrc <> 0.
          MESSAGE e021(zmsg_cls) WITH wa_hdr-trns.
        ENDIF.
      ENDIF.
      IF wa_hdr-lr_no IS NOT INITIAL.
***  Checking for Special Chars in LR Nnum
        IF wa_hdr-lr_no CA '!@#$%^&*()_+=|.?,.~`"'':;}]{[\/><' && |'|.
          MESSAGE e065(zmsg_cls) WITH wa_hdr-lr_no.
        ENDIF.
*** Checking For LR numebr and Transporter exist for this Vendor
*        SELECT SINGLE  qr_code INTO @DATA(lv_qr) FROM zinw_t_hdr WHERE lifnr = @wa_hdr-lifnr AND lr_no = @wa_hdr-lr_no AND trns = @wa_hdr-trns.
        SELECT SINGLE qr_code INTO @DATA(lv_qr) FROM zinw_t_hdr WHERE lr_no = @wa_hdr-lr_no AND trns = @wa_hdr-trns.
        IF  sy-subrc = 0.
          MESSAGE e017(zmsg_cls) WITH wa_hdr-trns.
        ENDIF.
      ENDIF.

      IF wa_hdr-lr_date IS NOT INITIAL.
        IF wa_hdr-lr_date GT sy-datum.
          MESSAGE e083(zmsg_cls) WITH wa_hdr-lr_date.
        ELSEIF wa_hdr-lr_date LT wa_ekko-aedat.
***      MESSAGE E082(ZMSG_CLS) WITH WA_HDR-LR_DATE WA_EKKO-AEDAT.
        ENDIF.
      ENDIF.

*  IF WA_HDR-FRT_NO IS NOT INITIAL.
**** Checking For LR numebr and Transporter exist for this Vendor
*    SELECT SINGLE  QR_CODE INTO LV_QR FROM ZINW_T_HDR WHERE LIFNR = WA_HDR-LIFNR AND FRT_NO = WA_HDR-FRT_NO.
*    IF  SY-SUBRC = 0.
*      MESSAGE E018(ZMSG_CLS) WITH WA_HDR-LIFNR.
*    ENDIF.
*  ENDIF.

*** Number of Bundles
*    IF WA_HDR-ACT_NO_BUD IS NOT INITIAL.
*      IF WA_HDR-ACT_NO_BUD LE 0.
*        LV_ERROR = C_E.
*        MESSAGE E064(ZMSG_CLS).
*      ENDIF.
*    ENDIF.
    ENDIF.
  ENDIF.
  IF wa_hdr-bill_num IS NOT INITIAL.
***  Checking for Special Chars in LR Nnum
    IF wa_hdr-bill_num CA '!@#$%^&*()_+=|.?,.~`"'':;}]{[\/><' && |'|.
      MESSAGE e065(zmsg_cls) WITH wa_hdr-bill_num.
    ENDIF.
*** Checking For Bill numebr exist for this Vendor
    SELECT SINGLE  qr_code INTO lv_qr FROM zinw_t_hdr WHERE lifnr = wa_hdr-lifnr AND bill_num = wa_hdr-bill_num.
    IF  sy-subrc = 0.
      MESSAGE e019(zmsg_cls) WITH wa_hdr-lifnr.
    ENDIF.
  ENDIF.

***  Bill Date Validation
  IF wa_hdr-bill_date IS NOT INITIAL.
    IF wa_hdr-bill_date GT sy-datum.
      MESSAGE e027(zmsg_cls) WITH wa_hdr-bill_date.
    ELSEIF wa_hdr-bill_date LT wa_ekko-aedat.
*      MESSAGE E032(ZMSG_CLS) WITH WA_HDR-BILL_DATE WA_EKKO-AEDAT.  " for Open PO's
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_trans .
  DATA: lt_values TYPE TABLE OF vrm_value.
  SELECT lifnr , name1 INTO TABLE @DATA(lt_trns) FROM lfa1 WHERE ktokk = 'ZTAN'.
  IF lt_trns IS NOT INITIAL.
    REFRESH lt_values.
    LOOP AT lt_trns ASSIGNING FIELD-SYMBOL(<ls_trns>).
      APPEND VALUE #( key = <ls_trns>-lifnr text = <ls_trns>-name1 ) TO lt_values.
    ENDLOOP.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'WA_HDR-TRNS'
        values          = lt_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_all.
  IF ok_code = c_clear.
    CLEAR : p_ebeln, p_qr_code,lv_mod, wa_hdr, lv_trns, lv_status,lv_error ,
            lv_tax_%,lv_tax_cat, lv_soe_des , lv_prof%,lv_prof_amt, lv_gr_date,
            lv_grc_prof, lv_grc_prof% ,wa_hdr-bill_amt , lv_group , lv_group_margin ,wa_payment.
    REFRESH : lt_item, lt_ekpo , lt_item_scr.
    CLEAR : ok_code.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status.
  wa_hdr-soe = c_01.
*** Status Update
  ls_status-inwd_doc     = wa_hdr-inwd_doc.
  ls_status-qr_code      = wa_hdr-qr_code.
  ls_status-status_field = c_es_code.
  ls_status-created_by   = sy-uname.
  ls_status-created_date = sy-datum.
  ls_status-created_time = sy-uzeit.
  ls_status-status_value = c_es01.
  ls_status-description  = 'Matched'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_TATKAL_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_tatkal_po.
  SET PARAMETER ID 'ZQR' FIELD wa_hdr-qr_code.
  LEAVE TO TRANSACTION 'ZTAT_PO' AND SKIP FIRST SCREEN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPLITE_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM complite_doc.
  DATA : i_answer TYPE char10.
  DATA : wa_status TYPE zinw_t_status.

  CHECK wa_hdr-status = '04'.
  SELECT SINGLE id  FROM icon  INTO @DATA(lv_id) WHERE name = 'ICON_MESSAGE_WARNING'.
  CONCATENATE lv_id 'Once the QR code document completed you can not do further' INTO DATA(lv_txt) SEPARATED BY space.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'N'
      textline1     = lv_txt
      textline2     = 'changes Click OK to Continue'
      titel         = 'Confirmation'
    IMPORTING
      answer        = i_answer.

  IF i_answer = 'J'.
    wa_hdr-uname    = sy-uname.
    wa_hdr-udate    = sy-datum.
    wa_hdr-utime    = sy-uzeit.
    wa_hdr-status   = c_05.
    lv_status = 'QR Code Completed'.
    lv_mod = c_d.
    MODIFY zinw_t_hdr FROM wa_hdr.
*** For Updating Status Table
    wa_status-qr_code      = wa_hdr-qr_code.
    wa_status-inwd_doc     = wa_hdr-inwd_doc.
    wa_status-status_field = c_qr_code.
    wa_status-status_value = c_qr05.
    wa_status-description  = 'QR Code Completed'.
    wa_status-created_by   = sy-uname.
    wa_status-created_date = sy-datum.
    wa_status-created_time = sy-uzeit.
    MODIFY zinw_t_status FROM wa_status.
    MESSAGE s002(zmsg_cls).

*** Return PO / Debit Note Mail
    IF wa_hdr-return_po IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          lv_ebeln  = wa_hdr-return_po
          return_po = 'X'.
    ENDIF.

*** Tatkal PO Mail
    IF wa_hdr-tat_po IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          lv_ebeln  = wa_hdr-tat_po       " Purchasing Document Number
          tatkal_po = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_INVOCIE_APPROVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM update_invocie_approve USING p_l p_des.
  wa_approve-mandt      = sy-mandt.
  wa_approve-app_status = p_l.
  wa_approve-qr_code    = wa_hdr-qr_code.
  MODIFY zinvoice_t_app FROM wa_approve.
  MESSAGE s055(zmsg_cls) WITH  p_des.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_TOTALS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_totals.
  DATA : lv_net_val TYPE netwr.
  DATA : lv_tax     TYPE wmwst.

  CHECK lv_mod    = 'E'.
*  CHECK WA_HDR-DISCOUNT IS NOT INITIAL OR WA_HDR-PACKING_CHARGE IS NOT INITIAL.
****  For Splitting Discount for Line Items
*  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
*    DATA(LV_QTY)     = <LS_ITEM>-MENGE_P.
**    DESCRIBE TABLE LT_ITEM LINES DATA(LV_LINE).
**    DATA(LV_DIS) = WA_HDR-DISCOUNT / LV_LINE.
**    LV_NET_VAL = ( <LS_ITEM>-MENGE_P * <LS_ITEM>-NETPR_P ) - LV_DIS.
*    LV_NET_VAL = ( <LS_ITEM>-MENGE_P * <LS_ITEM>-NETPR_P ).
*    CALL METHOD ZCL_PO_ITEM_TAX=>GET_PO_ITEM_TAX
*      EXPORTING
*        I_EBELN    = <LS_ITEM>-EBELN  " Purchasing Document Number
*        I_EBELP    = <LS_ITEM>-EBELP  " Item Number of Purchasing Document
*        I_QUANTITY = LV_QTY           " Quantity
*        I_NET_VAL  = LV_NET_VAL       " Net Value in Document Currency
*      IMPORTING
*        E_TAX      = LV_TAX.          " Tax Amount in Document Currency
*
*    <LS_ITEM>-NETPR_P  = LV_NET_VAL / LV_QTY.
*    <LS_ITEM>-NETWR_P  = LV_NET_VAL.
*    <LS_ITEM>-NETPR_GP = LV_TAX.
*
*    <LS_ITEM>-NETWR_S  = <LS_ITEM>-NETWR_P + ( <LS_ITEM>-NETWR_P * <LS_ITEM>-MARGN ) / 100 .
*    <LS_ITEM>-NETPR_S  = <LS_ITEM>-NETWR_S / <LS_ITEM>-MENGE_S.
*    if <LS_ITEM>-NETWR_S is NOT INITIAL.
*    DATA(LV_TX) = ( LV_TAX * 100 ) / <LS_ITEM>-NETWR_S.
*    <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TX + 100 ) ) * LV_TX .
*    ENDIF.
*  ENDLOOP.

  wa_hdr-net_amt   = lv_net_pay = wa_hdr-pur_total + wa_hdr-pur_tax + wa_hdr-packing_charge - wa_hdr-discount - lv_hdr_discount.
  lv_net_selling   = wa_hdr-total - wa_hdr-t_gst.
  lv_grc_prof      = wa_hdr-total - wa_hdr-pur_total.
  lv_prof_amt      = wa_hdr-total - wa_hdr-net_amt.

  IF wa_hdr-net_amt IS NOT INITIAL.
    lv_prof%       = ( lv_prof_amt * 100 ) / wa_hdr-net_amt.
  ENDIF.
  IF wa_hdr-net_amt IS NOT INITIAL.
    lv_grc_prof%       = ( lv_grc_prof * 100 ) / wa_hdr-pur_total.
  ENDIF.

ENDFORM.

FORM validate_charges.
*  IF SY-UCOMM <> C_CLEAR.
*    CHECK LV_MOD = 'E' AND WA_HDR-STATUS IS INITIAL.
**** Validations On Packing and Discount
*    SELECT SINGLE * FROM ZINW_T_HDR INTO @DATA(LS_HDR_P) WHERE EBELN = @P_EBELN.
*    IF LS_HDR_P IS NOT INITIAL.
*      IF LS_HDR_P-PACKING_CHARGE IS NOT INITIAL OR LS_HDR_P-DISCOUNT IS NOT INITIAL.
*        IF WA_HDR-DISCOUNT IS NOT INITIAL OR WA_HDR-PACKING_CHARGE IS NOT INITIAL.
*          MESSAGE E062(ZMSG_CLS).
*          EXIT.
*        ENDIF.
*      ELSE.
*        IF WA_HDR-DISCOUNT IS NOT INITIAL OR WA_HDR-PACKING_CHARGE IS NOT INITIAL.
*          MESSAGE E063(ZMSG_CLS).
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSE.
*    CLEAR : WA_HDR.
*  ENDIF.
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
*  IF WA_HDR-GRPO_P IS INITIAL.   " Comminted on 08.08.2019 by Suri ( By Sandeep Sir word )
  PERFORM grpo_price_form IN PROGRAM zmm_grpo_price_rep USING wa_hdr-qr_code.
  IF sy-subrc = 0 AND sy-ucomm = 'PRNT'.
***    Updating Printing status
    wa_hdr-grpo_p = c_x.
    wa_hdr-grpo_p_printed_by = sy-uname.
    MODIFY zinw_t_hdr FROM wa_hdr.
  ENDIF.
*  ELSE.
*    MESSAGE S026(ZMSG_CLS) WITH WA_HDR-L_PRINTED_BY DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
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
*  IF WA_HDR-GRPO_S IS INITIAL.    " Comminted on 08.08.2019 by Suri ( By Sandeep Sir word )
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
      lv_qr_code       = wa_hdr-qr_code
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
*  ELSE.
*    MESSAGE S026(ZMSG_CLS) WITH WA_HDR-L_PRINTED_BY DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_AUDITOR_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_auditor_check.
  wa_hdr-status = '08'.
  MODIFY zinw_t_hdr FROM wa_hdr.
  MESSAGE s002(zmsg_cls).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAYMENT_ADVICE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM payment_advice.
  CHECK wa_hdr-acc_doc_no IS NOT INITIAL.
  SUBMIT zfi_ven_bank_det WITH cl_doc = wa_hdr-acc_doc_no AND RETURN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOCK_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM lock_objects USING lv_mod.
*  IF LV_MOD = C_E1.
*    CALL FUNCTION 'ENQUEUE_EZTP2'
*      EXPORTING
*        MODE_ZINW_T_HDR = 'E'              " Lock mode for table ZINW_T_HDR
*        MANDT           = SY-MANDT         " Enqueue argument 01
*        QR_CODE         = P_QR_CODE   " Enqueue argument 02
*        EBELN           = P_EBELN
*      EXCEPTIONS
*        FOREIGN_LOCK    = 1                " Object already locked
*        SYSTEM_FAILURE  = 2                " Internal error from enqueue server
*        OTHERS          = 3.
*    IF SY-SUBRC <> 0.
*      IF SY-SUBRC = 1.
*        MESSAGE E071(ZMSG_CLS) WITH SY-MSGV1.
*      ENDIF.
*    ENDIF.
*  ELSE.
*    CALL FUNCTION 'DEQUEUE_EZTP2'
*      EXPORTING
*        MODE_ZINW_T_HDR = 'E'              " Lock mode for table ZINW_T_HDR
*        MANDT           = SY-MANDT         " Enqueue argument 01
*        QR_CODE         = P_QR_CODE   " Enqueue argument 02
*        EBELN           = P_EBELN.
*  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F4_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_paymode.
  DATA: lt_values TYPE TABLE OF vrm_value.
  SELECT domvalue_l , ddtext FROM dd07v INTO TABLE @DATA(lt_pymode) WHERE domname = 'ZPAY_MODE' AND ddlanguage = @sy-langu.
  IF lt_pymode IS NOT INITIAL.
    REFRESH lt_values.
    lt_values = VALUE #( FOR ls_paymode IN lt_pymode ( key = ls_paymode-domvalue_l text = ls_paymode-ddtext ) ).
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'WA_PAYMENT-PAYMENT_MODE'
        values          = lt_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
  ENDIF.
ENDFORM.
