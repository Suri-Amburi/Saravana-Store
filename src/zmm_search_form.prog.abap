*&---------------------------------------------------------------------*
*& Include          ZMM_SEARCH_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM getdata .

*  IF s_from IS NOT INITIAL .
*    s_from-option = 'GE' .
*    MODIFY s_from INDEX 1.
*  ENDIF.
**  IF r_to IS NOT INITIAL .
*    r_to-option = 'LE' .
*
*    MODIFY r_to INDEX 1 .
*  ENDIF.

  s_from[] = r_from[].
  s_size[] = r_size[].

  SELECT
   mara~matnr,
   mara~matkl,
   mara~zzprice_frm,
   mara~zzprice_to,
   makt~maktx
   INTO TABLE @it_mara
   FROM mara AS mara
   INNER JOIN makt AS makt ON makt~matnr = mara~matnr
   WHERE matkl IN @s_matkl
   AND   zzprice_frm IN @s_from
   AND   zzprice_to   IN @r_to
   AND   size1 IN @s_size.       " Added by Suri : 31.03.2020

  IF it_mara IS NOT INITIAL.
    SELECT
      matnr
      werks
      labst FROM mard INTO TABLE it_mard
            FOR ALL ENTRIES IN it_mara
            WHERE matnr = it_mara-matnr
            AND   werks IN s_plant.
  ENDIF.

  IF  it_mard IS NOT INITIAL.
    SELECT
      qr_code
      ebeln
      ebelp
      matnr
      menge_p
      open_qty
      matkl FROM zinw_t_item INTO TABLE it_zinw_t_item
               FOR ALL ENTRIES IN it_mard
               WHERE matnr = it_mard-matnr
               AND werks = it_mard-werks .
*               AND   EBELN IN ( '4600001837' , '4600001838' ) .

  ENDIF.

  IF it_zinw_t_item IS NOT INITIAL.
    SELECT
    qr_code
    inwd_doc
    ebeln
    lifnr
    name1
    bill_num
    bill_date
    trns
    lr_no
    act_no_bud
    status      FROM zinw_t_hdr INTO TABLE it_zinw_t_hdr
                FOR ALL ENTRIES IN it_zinw_t_item
                WHERE ebeln = it_zinw_t_item-ebeln
                AND qr_code = it_zinw_t_item-qr_code
                AND status IN ( '01' , '02' ).
  ENDIF.


  IF it_mara IS NOT INITIAL.

*    SELECT
*      EKPO~EBELN ,
*      EKPO~EBELP ,
*      EKPO~MATNR ,
*      EKPO~MENGE
*           INTO TABLE @IT_EKPO FROM EKPO AS EKPO
*           LEFT JOIN MATDOC AS MATDOC ON MATDOC~EBELN = EKPO~EBELN AND MATDOC~EBELP = EKPO~EBELP
*           FOR ALL ENTRIES IN @IT_MARA
*           WHERE  EKPO~MATNR = @IT_MARA-MATNR
**            AND EKPO~EBELN IN  ( '4600001827' , '4600001828' )."
*             AND MATDOC~EBELN IS NULL.
**            AND EBELN =  '4600001828'.

    SELECT
 ekpo~ebeln ,
 ekpo~ebelp ,
 ekpo~matnr ,
 ekpo~menge
      INTO TABLE @it_ekpo FROM ekpo AS ekpo
      LEFT JOIN zinw_t_item AS zinw_t_item ON zinw_t_item~ebeln = ekpo~ebeln AND zinw_t_item~ebelp = ekpo~ebelp
      FOR ALL ENTRIES IN @it_mara
      WHERE  ekpo~matnr = @it_mara-matnr
      AND zinw_t_item~ebeln IS NULL AND zinw_t_item~ebelp IS NULL.
  ENDIF.


  DATA : sl_no(05) TYPE i .
  LOOP AT it_mara ASSIGNING FIELD-SYMBOL(<ls_mara>).
    sl_no = sl_no + 1 .
    wa_final-sl_no = sl_no .
    wa_final-matnr =  <ls_mara>-matnr.
    wa_final-matkl =  <ls_mara>-matkl.
    wa_final-maktx =  <ls_mara>-maktx.
    wa_final-zzprice_frm =  <ls_mara>-zzprice_frm.
    wa_final-zzprice_to =  <ls_mara>-zzprice_to.
    READ TABLE it_mard ASSIGNING FIELD-SYMBOL(<ls_mard>) WITH KEY matnr = <ls_mara>-matnr.
    IF sy-subrc = 0.
      wa_final-open_qty = <ls_mard>-labst .  "+ WA_FINAL-OPEN_QTY.
    ENDIF.

    LOOP AT it_zinw_t_item ASSIGNING FIELD-SYMBOL(<ls_zinw_t_item>) WHERE matnr = wa_final-matnr.
      wa_final-ebeln = <ls_zinw_t_item>-ebeln .
      READ TABLE it_zinw_t_hdr ASSIGNING FIELD-SYMBOL(<ls_zinw_t_hdr>) WITH KEY qr_code = <ls_zinw_t_item>-qr_code.
      IF sy-subrc = 0.
        IF <ls_zinw_t_hdr>-status = '02'.
          wa_final-menge_wh = wa_final-menge_wh + <ls_zinw_t_item>-menge_p .
        ELSEIF <ls_zinw_t_hdr>-status = '01'.
          wa_final-menge_tr = wa_final-menge_tr + <ls_zinw_t_item>-menge_p .
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>) WHERE matnr = wa_final-matnr..
      ADD <ls_ekpo>-menge TO wa_final-inwh_bun.
    ENDLOOP.
*    BREAK BREDDY .
*      WA_FINAL-INWH_BUN = <LS_EKPO>-MENGE + WA_FINAL-INWH_BUN .
*  ENDLOOP.
*        WA_FINAL-INWH_BUN = <LS_EKPO>-MENGE + WA_FINAL-INWH_BUN .
*      ENDLOOP.
*
*    ENDLOOP.

    APPEND wa_final TO it_final .
    CLEAR : wa_final.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .

  DATA: it_fcat1  TYPE slis_t_fieldcat_alv,
        wa_fcat1  TYPE slis_fieldcat_alv,
        it_event1 TYPE slis_t_event,
        wa_event1 TYPE slis_alv_event,
        wvari     TYPE disvariant.

  DATA wa_layout TYPE slis_layout_alv.
  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra = 'X'.

  wa_fcat1-fieldname = 'SL_NO'.
  wa_fcat1-seltext_m = 'Serial No'.
  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .

  wa_fcat1-fieldname = 'MATKL'.
  wa_fcat1-seltext_m = 'Category Number'.
  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .

  wa_fcat1-fieldname = 'MATNR'.
  wa_fcat1-seltext_m = 'SST No'.
  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .

  APPEND VALUE #( fieldname = 'MAKTX' seltext_m = 'Description' )      TO  it_fcat1.
  APPEND VALUE #( fieldname = 'ZZPRICE_FRM' seltext_m = 'From Price' ) TO  it_fcat1.
  APPEND VALUE #( fieldname = 'ZZPRICE_TO' seltext_m = 'To Price' )    TO  it_fcat1.

  wa_fcat1-fieldname = 'OPEN_QTY'.
  wa_fcat1-seltext_l = 'Opened Warehouse Stock'.
  wa_fcat1-do_sum = 'X'.

  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .

  wa_fcat1-fieldname = 'MENGE_WH'.
  wa_fcat1-seltext_m = 'In Warehouse Bundles'.
  wa_fcat1-do_sum = 'X'.
  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .

  wa_fcat1-fieldname = 'MENGE_TR'.
  wa_fcat1-seltext_m = 'In Transport Bundles'.
  wa_fcat1-do_sum = 'X'.
  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .

  wa_fcat1-fieldname = 'INWH_BUN'.
  wa_fcat1-seltext_m = 'In Open PO Qty'.
  wa_fcat1-do_sum = 'X'.
  APPEND  wa_fcat1 TO it_fcat1.
  CLEAR : wa_fcat1 .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = sy-repid
      i_callback_user_command     = 'USER_COMMAND'
      i_callback_html_top_of_page = 'TOP_OF_PAGE1'
      is_layout                   = wa_layout
      it_fieldcat                 = it_fcat1
      i_save                      = 'U'
      is_variant                  = wvari
    TABLES
      t_outtab                    = it_final
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
FORM top_of_page1 USING top TYPE REF TO cl_dd_document.
  DATA: lv_top1  TYPE sdydo_text_element,
        lv_from1 TYPE sdydo_text_element,
        lv_to1   TYPE sdydo_text_element.

  lv_top1 = s_matkl-low .
  CONCATENATE  'Category Code' lv_top1  INTO lv_top1 SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top1
      sap_style = 'HEADING'.
*     to move to next line
  CALL METHOD top->new_line.
  IF s_from[] IS NOT INITIAL.
    SORT s_from[] BY low ASCENDING.
    s_from = s_from[ 1 ].
  ENDIF.
  lv_from1 = s_from-low .
  CONDENSE lv_from1 .
  CONCATENATE 'From Price' lv_from1 INTO lv_from1 SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_from1
      sap_style = 'HEADING'.
  CALL METHOD top->new_line.
  IF r_to[] IS NOT INITIAL.
    SORT r_to[] BY low DESCENDING.
    r_to = r_to[ 1 ].
  ENDIF.
  lv_to1 = r_to-low .
  CONDENSE lv_to1 .
  CONCATENATE 'To Price' lv_to1 INTO lv_to1 SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_to1
      sap_style = 'HEADING'.
ENDFORM .
FORM user_command USING  r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.
  REFRESH it_final1.
  CASE r_ucomm.
    WHEN '&IC1'.
      gv_heading = rs_selfield-fieldname.
      IF rs_selfield-fieldname = 'OPEN_QTY'.
        PERFORM display_open_wr_qunatity.
      ELSE.
        PERFORM get_po_data USING rs_selfield .
      ENDIF.
  ENDCASE.
ENDFORM.
FORM get_po_data  USING  rs_selfield TYPE slis_selfield.
  REFRESH it_zinw_t_item1 .
  DATA(it_final2) = it_final[].

  READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_final>) INDEX rs_selfield-tabindex.
  IF sy-subrc = 0 .
    DELETE it_final2 WHERE matnr <> <ls_final>-matnr .
  ENDIF .

  CASE rs_selfield-fieldname.
    WHEN  'MENGE_WH' .
      DATA(lv_status) = '02'.
    WHEN  'MENGE_TR' .
      lv_status = '01' .
  ENDCASE .

  IF lv_status IS NOT INITIAL .
    SELECT
    zinw_t_item~qr_code ,
    zinw_t_item~ebeln   ,
    zinw_t_item~ebelp   ,
    zinw_t_item~matnr   ,
    zinw_t_item~menge_p ,
    zinw_t_item~open_qty,
    zinw_t_item~matkl FROM zinw_t_item INTO TABLE @DATA(it_zinw_t_item1)
        FOR ALL ENTRIES IN @it_final2
          WHERE  matnr = @it_final2-matnr .

    SELECT
    zinw_t_hdr~qr_code
    zinw_t_hdr~inwd_doc
    zinw_t_hdr~ebeln
    zinw_t_hdr~lifnr
    zinw_t_hdr~name1
    zinw_t_hdr~bill_num
    zinw_t_hdr~bill_date
    zinw_t_hdr~trns
    zinw_t_hdr~lr_no
    zinw_t_hdr~act_no_bud
    zinw_t_hdr~status
    zqr_t_add~bay
    INTO TABLE it_zinw_t_hdr
    FROM zinw_t_hdr AS zinw_t_hdr
    LEFT JOIN zqr_t_add AS zqr_t_add ON zqr_t_add~qr_code = zinw_t_hdr~qr_code
    FOR ALL ENTRIES IN it_zinw_t_item1
    WHERE ebeln = it_zinw_t_item1-ebeln AND zinw_t_hdr~qr_code = it_zinw_t_item1-qr_code AND zinw_t_hdr~status = lv_status.

    IF it_zinw_t_hdr IS NOT INITIAL.

      SELECT
        zinw_t_status~qr_code ,
        zinw_t_status~status_value ,
        zinw_t_status~created_date FROM zinw_t_status INTO TABLE @DATA(it_zinw_t_status)
                                   FOR ALL ENTRIES IN @it_zinw_t_hdr
                                   WHERE qr_code = @it_zinw_t_hdr-qr_code
                                   AND status_value = 'QR02' .
    ENDIF.

******FOR OPEN PO**********
    DATA : sl_no(05) TYPE i VALUE 1.

    LOOP AT it_zinw_t_item1 ASSIGNING FIELD-SYMBOL(<ls_zinw_t_item1>) .
      wa_final1-sl_no = sl_no .
      wa_final1-ebeln = <ls_zinw_t_item1>-ebeln.
      wa_final1-menge_wh = <ls_zinw_t_item1>-menge_p.
      wa_final1-matnr = <ls_zinw_t_item1>-matnr.
      READ TABLE it_zinw_t_hdr ASSIGNING FIELD-SYMBOL(<wa_hdr>) WITH KEY qr_code = <ls_zinw_t_item1>-qr_code ebeln = <ls_zinw_t_item1>-ebeln .
      IF sy-subrc = 0.
        IF <wa_hdr>-bill_num IS NOT INITIAL .
          sl_no = sl_no + 1.
        ENDIF .
        wa_final1-lifnr = <wa_hdr>-lifnr .
        wa_final1-bil_no = <wa_hdr>-bill_num.
        wa_final1-bil_date = <wa_hdr>-bill_date.
        wa_final1-lr_no = <wa_hdr>-lr_no.
        wa_final1-act_no_bud = <wa_hdr>-act_no_bud.
        wa_final1-trns = <wa_hdr>-trns.
        wa_final1-name = <wa_hdr>-name1.
        wa_final1-bay = <wa_hdr>-bay.

        READ TABLE it_zinw_t_status ASSIGNING FIELD-SYMBOL(<ls_zinw_t_status>) WITH  KEY qr_code = <wa_hdr>-qr_code  status_value = 'QR02'.
        IF sy-subrc = 0 .
          wa_final1-created_date =  <ls_zinw_t_status>-created_date .
        ENDIF.
      ENDIF.

      APPEND wa_final1 TO it_final1 .
      DELETE it_final1 WHERE bil_no IS INITIAL .
      CLEAR : wa_final1 .
    ENDLOOP.

*  ENDIF .



*  IF LV_STATUS IS NOT INITIAL .

    DATA: it_fcat  TYPE slis_t_fieldcat_alv,
          wa_fcat  TYPE slis_fieldcat_alv,
          it_event TYPE slis_t_event,
          wa_event TYPE slis_alv_event,
          wvari    TYPE disvariant.

    DATA wa_layout1 TYPE slis_layout_alv.
    wa_layout1-colwidth_optimize = 'X'.
    wa_layout1-zebra = 'X'.

    wa_fcat-fieldname = 'SL_NO'.
    wa_fcat-seltext_m = 'Serial No'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.


    wa_fcat-fieldname = 'EBELN'.
    wa_fcat-seltext_m = 'PO Number'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.

    wa_fcat-fieldname = 'NAME'.
    wa_fcat-seltext_m = 'Vendor Name'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.

    wa_fcat-fieldname = 'MATNR'.
    wa_fcat-seltext_m = 'SST No'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.

    wa_fcat-fieldname = 'BIL_NO'.
    wa_fcat-seltext_m = 'Bill No'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.

    wa_fcat-fieldname = 'BIL_DATE'.
    wa_fcat-seltext_l = 'Bill Date'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.

    wa_fcat-fieldname = 'MENGE_WH'.
    wa_fcat-seltext_m = 'Quantity'.
    wa_fcat-do_sum = 'X'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat.

    wa_fcat-fieldname = 'LR_NO'.
    wa_fcat-seltext_m = 'LR No'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat .

    wa_fcat-fieldname = 'ACT_NO_BUD'.
    wa_fcat-seltext_m = 'Number Of Bundles'.
    wa_fcat-do_sum = 'X'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat .

    wa_fcat-fieldname = 'TRNS'.
    wa_fcat-seltext_m = 'Transporter'.
    APPEND  wa_fcat TO it_fcat.
    CLEAR : wa_fcat .

    IF rs_selfield-fieldname = 'MENGE_WH'.
     append VALUE #(  fieldname = 'BAY' seltext_m = 'Bay' ) to it_fcat.
      wa_fcat-fieldname = 'CREATED_DATE'.
      wa_fcat-seltext_m = 'Gatein Date'.
      APPEND  wa_fcat TO it_fcat.
      CLEAR : wa_fcat .
    ENDIF .

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program          = sy-repid
        i_callback_html_top_of_page = 'TOP_OF_PAGE'
        is_layout                   = wa_layout1
        it_fieldcat                 = it_fcat
        i_save                      = 'U'
        is_variant                  = wvari
      TABLES
        t_outtab                    = it_final1
      EXCEPTIONS
        program_error               = 1
        OTHERS                      = 2.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

  IF rs_selfield-fieldname = 'INWH_BUN'.
    SELECT
      ekpo~ebeln ,
      ekpo~ebelp ,
      ekpo~matnr ,
      ekpo~menge
      INTO TABLE @DATA(it_ekpo1) FROM ekpo AS ekpo
      LEFT JOIN zinw_t_item AS zinw_t_item ON zinw_t_item~ebeln = ekpo~ebeln AND zinw_t_item~ebelp = ekpo~ebelp
      WHERE  ekpo~matnr = @<ls_final>-matnr
      AND zinw_t_item~ebeln IS NULL AND zinw_t_item~ebelp IS NULL.
    IF it_ekpo1 IS NOT INITIAL.

      SELECT
        ekko~ebeln ,
        ekko~aedat ,
        ekko~lifnr FROM ekko INTO TABLE @DATA(it_ekko)
                   FOR ALL ENTRIES IN @it_ekpo1
                   WHERE ebeln = @it_ekpo1-ebeln .

    ENDIF.

    IF it_ekko IS NOT INITIAL.
      SELECT
      lfa1~lifnr ,
      lfa1~name1,
      lfa1~ort01
         FROM lfa1 INTO TABLE @DATA(it_lfa1)
                 FOR ALL ENTRIES IN @it_ekko
                 WHERE lifnr = @it_ekko-lifnr .
    ENDIF.

    DATA : sl_no1(05) TYPE i .
    LOOP AT it_ekpo1 ASSIGNING FIELD-SYMBOL(<ls_ekpo1>).

      sl_no1 = sl_no1 + 1 .
      wa_final1-sl_no = sl_no1 .
      wa_final1-ebeln = <ls_ekpo1>-ebeln.
      wa_final1-inwh_bun = <ls_ekpo1>-menge.
      wa_final1-matnr = <ls_ekpo1>-matnr.

      READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<ls_ekko>) WITH KEY ebeln = <ls_ekpo1>-ebeln .
      IF sy-subrc = 0 .
        wa_final1-lifnr = <ls_ekko>-lifnr .
        wa_final1-created_date = <ls_ekko>-aedat .
      ENDIF.
      READ TABLE it_lfa1 ASSIGNING FIELD-SYMBOL(<ls_lfa1>) WITH KEY lifnr = <ls_ekko>-lifnr .
      IF sy-subrc = 0 .
        wa_final1-name = <ls_lfa1>-name1.
        wa_final1-ort01 = <ls_lfa1>-ort01.
      ENDIF .

      APPEND wa_final1  TO it_final1 .
      CLEAR : wa_final1 .
    ENDLOOP.
*  ENDIF .
    DATA: it_fcat2  TYPE slis_t_fieldcat_alv,
          wa_fcat2  TYPE slis_fieldcat_alv,
          it_event2 TYPE slis_t_event,
          wa_event2 TYPE slis_alv_event,
          wvari2    TYPE disvariant.

    DATA wa_layout3 TYPE slis_layout_alv.
    wa_layout3-colwidth_optimize = 'X'.
    wa_layout3-zebra = 'X'.

*  IF RS_SELFIELD-FIELDNAME = 'INWH_BUN'  .
    wa_fcat2-fieldname = 'SL_NO'.
    wa_fcat2-seltext_m = 'Serial No'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2.


    wa_fcat2-fieldname = 'LIFNR'.
    wa_fcat2-seltext_m = 'Vendor Code'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2 .

    wa_fcat2-fieldname = 'NAME'.
    wa_fcat2-seltext_m = 'Vendor Name'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2.

    wa_fcat2-fieldname = 'ORT01'.
    wa_fcat2-seltext_m = 'Vendor Location'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2 .

    wa_fcat2-fieldname = 'CREATED_DATE'.
    wa_fcat2-seltext_m = 'Created Date'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2 .

    wa_fcat2-fieldname = 'EBELN'.
    wa_fcat2-seltext_m = 'PO Number'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2.

    wa_fcat2-fieldname = 'MATNR'.
    wa_fcat2-seltext_m = 'SST No'.
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2.

    wa_fcat2-fieldname = 'INWH_BUN'.
    wa_fcat2-seltext_m = 'Quantity'.
    wa_fcat2-do_sum = 'X' .
    APPEND  wa_fcat2 TO it_fcat2.
    CLEAR : wa_fcat2.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program          = sy-repid
        i_callback_html_top_of_page = 'TOP_OF_PAGE'
        is_layout                   = wa_layout3
        it_fieldcat                 = it_fcat2
        i_save                      = 'U'
        is_variant                  = wvari2
      TABLES
        t_outtab                    = it_final1
      EXCEPTIONS
        program_error               = 1
        OTHERS                      = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDFORM .
FORM top_of_page USING top TYPE REF TO cl_dd_document.
  DATA: lv_top  TYPE sdydo_text_element,
        lv_from TYPE sdydo_text_element,
        lv_to   TYPE sdydo_text_element.

  CASE gv_heading.
    WHEN 'MENGE_TR' .
      lv_top = 'Transport Bundles'.
    WHEN 'MENGE_WH'.
      lv_top = 'Warehouse Bundles'.
    WHEN 'OPEN_QTY'.
      lv_top = 'Open Warehouse Quantity'.
    WHEN 'INWH_BUN'.
      lv_top = 'Open PO Quantity'.
  ENDCASE.
  IF  lv_top IS NOT INITIAL.
    CALL METHOD top->add_text
      EXPORTING
        text      = lv_top
        sap_style = 'HEADING'.
    CALL METHOD top->new_line.
  ENDIF.

  lv_top = s_matkl-low.
  CONCATENATE  'Category Code' lv_top  INTO lv_top SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'HEADING'.

*     to move to next line
  CALL METHOD top->new_line.
  IF s_from[]  IS NOT INITIAL.
    SORT s_from[] BY low ASCENDING.
    s_from = r_to[ 1 ].
  ENDIF.
  lv_from = s_from-low .
  CONDENSE lv_from .

  IF r_to[]  IS NOT INITIAL.
    SORT r_to[] BY low DESCENDING.
    r_to = r_to[ 1 ].
  ENDIF.
  lv_to = r_to-low .
  CONDENSE lv_to .

  lv_from = 'From Price' && ' - ' && lv_from && ' To Price' && ' - ' && lv_to.
*  CONCATENATE 'From Price' lv_from INTO lv_from SEPARATED BY '-' .
  CALL METHOD top->add_text
    EXPORTING
      text      = lv_from
      sap_style = 'HEADING'.
  CALL METHOD top->new_line.

ENDFORM .


FORM display_open_wr_qunatity.

  DATA: lt_fcat   TYPE slis_t_fieldcat_alv,
        vari      TYPE disvariant,
        wa_layout TYPE slis_layout_alv.

  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra = 'X'.
  REFRESH : lt_fcat.
*** Field Catlog
  lt_fcat = VALUE #(
                    ( fieldname = 'RACK'   seltext_m = 'Rack' )
                    ( fieldname = 'PALLET' seltext_m = 'Pallet' )
                    ( fieldname = 'TRAY'   seltext_m = 'Tray' )
                    ( fieldname = 'QTY'    seltext_m = 'Quantity' )
                    ).
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = sy-repid
      i_callback_html_top_of_page = 'TOP_OF_PAGE'
      is_layout                   = wa_layout
      it_fieldcat                 = lt_fcat
      i_save                      = 'U'
      is_variant                  = vari
    TABLES
      t_outtab                    = it_final1
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
