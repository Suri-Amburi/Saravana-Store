*&---------------------------------------------------------------------*
*& Include          ZACCOUNTANT_DIARY_F01
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
    r_date       TYPE RANGE OF sy-datum,
    lv_to_date   TYPE sy-datum,
    lv_from_date TYPE sy-datum.

  CONSTANTS :
    c_i(1)  VALUE 'I',
    c_op(2) VALUE 'BT'.

  IF  p_month IS INITIAL AND p_year IS INITIAL.
    MESSAGE s006(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  DATA : lv_number_of_days TYPE t009b-butag.

  CALL FUNCTION 'NUMBER_OF_DAYS_PER_MONTH_GET'
    EXPORTING
      par_month = p_month
      par_year  = p_year
    IMPORTING
      par_days  = lv_number_of_days.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  lv_to_date = p_year && p_month && lv_number_of_days.
  lv_from_date =  lv_to_date - 212.
  APPEND VALUE #( sign = c_i option = c_op low = lv_from_date high = lv_to_date ) TO r_date.


  DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
  it_named_seltabs = VALUE #( ( name = 'BUDAT' dref = REF #( r_date[] ) ) ) iv_client_field = 'MANDT' ) .

  zcl_acc=>get_output_prd(
  EXPORTING
   lv_select     = lv_select
   lv_year       = p_year
  IMPORTING
   et_final_data = gt_data2 ).

  DATA(lv_select1) = cl_shdb_seltab=>combine_seltabs(
  it_named_seltabs = VALUE #( ( name = 'BUDAT' dref = REF #( r_date[] ) ) ) iv_client_field = 'MANDT' ) .

  zcl_acc=>get_output_prd1(
  EXPORTING
   lv_select1     = lv_select1
   lv_year1       = p_year
  IMPORTING
   et_final_data1 = gt_data3 ).

  REFRESH gt_data.

  BREAK ppadhy.

  LOOP AT gt_data2 ASSIGNING FIELD-SYMBOL(<w_data21>).

    READ TABLE gt_data3 INTO DATA(wa_data_31) WITH KEY ebeln = <w_data21>-ebeln.
    IF sy-subrc = 0.
      <w_data21>-xblnr = wa_data_31-xblnr.
*      DELETE gt_data3 WHERE ebeln = <w_data21>-ebeln .
*      DELETE gt_data3 WHERE belnr = wa_data_3-belnr..
    ENDIF.

  ENDLOOP.

  LOOP AT gt_data2 ASSIGNING FIELD-SYMBOL(<w_data2>).

    READ TABLE gt_data3 INTO DATA(wa_data_3) WITH KEY ebeln = <w_data2>-ebeln.
    IF sy-subrc = 0.
*      <w_data2>-xblnr = wa_data_3-xblnr.
      DELETE gt_data3 WHERE ebeln = <w_data2>-ebeln .
      DELETE gt_data3 WHERE belnr = wa_data_3-belnr..
    ENDIF.

  ENDLOOP.

  SELECT
    ebeln,
    bsart
    FROM ekko INTO TABLE @DATA(gt_ekko)
    FOR ALL ENTRIES IN @gt_data3
    WHERE ebeln = @gt_data3-ebeln AND bsart NOT IN ( 'ZLOP' ,'ZOSP', 'ZTAT','ZTSR','ZRET' ).

**  SELECT
**    lifnr,
**    ekorg,
**    zterm
**    FROM lfm1 INTO TABLE @DATA(gt_lfm1)
**    FOR ALL ENTRIES IN @gt_data3
**    WHERE lifnr = @gt_data3-lifnr.

  SELECT
    zterm,
    ztagg,
    ztag1
     FROM t052 INTO TABLE @DATA(gt_t052) FOR ALL ENTRIES IN @gt_data3 WHERE zterm = @gt_data3-zterm .

  LOOP AT gt_data3 INTO DATA(gs_data3).

    wa_final1-bukrs    = gs_data3-bukrs.
    wa_final1-buzei    = gs_data3-buzei.
    wa_final1-lifnr    = gs_data3-lifnr.
    wa_final1-augbl    = gs_data3-augbl.
    wa_final1-belnr    = gs_data3-belnr.
    wa_final1-gjahr    = gs_data3-gjahr.
    wa_final1-due_date = gs_data3-due_date.
    wa_final1-budat    = gs_data3-due_date.
    wa_final1-xblnr    = gs_data3-xblnr.
    wa_final1-dmbtr    = gs_data3-dmbtr.
    wa_final1-kostl    = gs_data3-kostl.
*    g_data1-ekorg = gs_data3-ekorg.
    wa_final1-zterm    = gs_data3-zterm.
*    g_data1-ztagg = gs_data3-ztagg.
*    g_data1-ztag1 = gs_data3-ztag1.

    wa_final1-dmbtr    = gs_data3-dmbtr.

    READ TABLE gt_ekko INTO DATA(gs_ekko) WITH KEY ebeln = gs_data3-ebeln.
    IF sy-subrc = 0.
      wa_final1-ebeln = gs_ekko-ebeln.
      wa_final1-bsart = gs_ekko-bsart.
    ENDIF.

**    READ TABLE gt_lfm1 INTO DATA(gs_lfm1) WITH KEY lifnr = gs_data3-lifnr.
**    IF sy-subrc = 0.
**      g_data1-zterm = gs_lfm1-zterm.
**    ENDIF.

    READ TABLE gt_t052 INTO DATA(gs_t052) WITH KEY zterm = gs_data3-zterm.
    IF sy-subrc = 0.
      wa_final1-ztagg = gs_t052-ztagg.
      wa_final1-ztag1 = gs_t052-ztag1.
    ENDIF.

    APPEND wa_final1 TO it_final1.
    CLEAR wa_final1.

  ENDLOOP.

  LOOP AT gt_data2 INTO DATA(w_data).
    wa_final-ebeln    = w_data-ebeln   .
    wa_final-ebelp    = w_data-ebelp   .
    wa_final-xblnr    = w_data-xblnr   .
    wa_final-bewtp    = w_data-bewtp   .
    wa_final-bwart    = w_data-bwart   .
    wa_final-menge    = w_data-menge   .
    wa_final-belnr    = w_data-belnr   .
    wa_final-gjahr    = w_data-gjahr   .
    wa_final-budat    = w_data-budat   .
    wa_final-lfbnr    = w_data-lfbnr   .
    wa_final-dmbtr    = w_data-dmbtr   .
    wa_final-matnr    = w_data-matnr   .
    wa_final-bsart    = w_data-bsart   .
    wa_final-loekz    = w_data-loekz   .
    wa_final-aedat    = w_data-aedat   .
    wa_final-lifnr    = w_data-lifnr   .
    wa_final-waers    = w_data-waers   .
    wa_final-zterm    = w_data-zterm   .
    wa_final-zbd1t    = w_data-zbd1t   .
    wa_final-mblnr    = w_data-mblnr   .
    wa_final-mwskz    = w_data-mwskz   .
    wa_final-kostl    = w_data-kostl   .
    wa_final-anln1    = w_data-anln1   .
    wa_final-due_date = w_data-due_date.

    APPEND wa_final TO gt_data.
    CLEAR wa_final.

  ENDLOOP.


*** For Calculating Due Date
  IF gt_data2 IS NOT INITIAL.
    LOOP AT gt_data2 ASSIGNING FIELD-SYMBOL(<ls_data>).
*      <LS_DATA>-DUE_DATE = <LS_DATA>-BUDAT +  <LS_DATA>-ZBD1T.
      <ls_data>-due_date = <ls_data>-aedat +  <ls_data>-zbd1t.
    ENDLOOP.
  ENDIF.

  IF it_final1 IS NOT INITIAL.
    LOOP AT it_final1 ASSIGNING FIELD-SYMBOL(<ls_final1>).
      <ls_final1>-due_date = <ls_final1>-budat +  <ls_final1>-ztag1.
    ENDLOOP.
  ENDIF.

  APPEND LINES OF it_final1 TO gt_data.


  IF gt_data IS NOT INITIAL.
    SELECT * FROM a003 INTO TABLE @DATA(it_a003) FOR ALL ENTRIES IN @gt_data WHERE mwskz = @gt_data-mwskz.
    SELECT * FROM ekpo INTO TABLE it_ekpo FOR ALL ENTRIES IN gt_data WHERE ebeln = gt_data-ebeln AND mwskz = gt_data-mwskz. "AND MATNR = GT_DATA-MATNR.
    SELECT lifnr  name1 adrnr FROM lfa1 INTO TABLE it_lfa1 FOR ALL ENTRIES IN gt_data WHERE lifnr = gt_data-lifnr.
    SELECT lr_no service_po FROM zinw_t_hdr INTO TABLE it_hdr FOR ALL ENTRIES IN gt_data WHERE service_po = gt_data-ebeln.
  ENDIF.

  IF it_lfa1 IS NOT INITIAL.
    SELECT name1 FROM adrc INTO TABLE it_adrc FOR ALL ENTRIES IN it_lfa1 WHERE addrnumber = it_lfa1-adrnr.
  ENDIF.

  IF it_a003 IS NOT INITIAL .
    SELECT * FROM konp INTO TABLE @DATA(it_konp) FOR ALL ENTRIES IN @it_a003 WHERE knumh = @it_a003-knumh.
  ENDIF.

  DELETE gt_data WHERE due_date GT lv_to_date.
  IF gt_data IS INITIAL.
    MESSAGE | No Payment pending for month  { p_month } { p_year } | TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  TYPES  : BEGIN OF ty_awkey  ,
             awkey TYPE bkpf-awkey,
           END OF ty_awkey .
  DATA : it_awkey TYPE TABLE OF ty_awkey,
         wa_awkey TYPE ty_awkey.

*  DATA(IT_DATA) = GT_DATA[].
*  DATA : LV_AWKEY(20) TYPE C.

*** Invoice Records
  SELECT ekbe~ebeln,
         ekbe~ebelp,
         ekbe~bewtp,
         ekbe~belnr ,
         ekbe~gjahr,
         ekbe~budat,
         ekbe~lfbnr,
         ekbe~bwart
         FROM ekbe INTO TABLE @DATA(gt_data_inv) FOR ALL ENTRIES IN @gt_data WHERE ebeln = @gt_data-ebeln AND ebelp = @gt_data-ebelp AND bewtp = 'Q' .

  SELECT
    bseg~bukrs,
    bseg~belnr,
    bseg~gjahr,
    bseg~ebeln,
    bseg~ebelp,
    bseg~augbl
    FROM bseg INTO TABLE @DATA(it_bseg1)
    FOR ALL ENTRIES IN @gt_data
    WHERE ebeln = @gt_data-ebeln AND ebelp = @gt_data-ebelp AND augbl <> @space AND gjahr = @p_year.

  IF it_bseg1 IS NOT INITIAL.
    SELECT
      bukrs,
      belnr,
      gjahr,
      awkey
      FROM bkpf INTO TABLE @DATA(it_bkpf1)
      FOR ALL ENTRIES IN @it_bseg1
      WHERE belnr = @it_bseg1-augbl AND gjahr = @p_year.
  ENDIF.

  IF it_bseg1 IS NOT INITIAL.

    SELECT
      bseg~bukrs,
      bseg~belnr,
      bseg~gjahr,
      bseg~ebeln,
      bseg~ebelp,
      bseg~augbl
      FROM bseg INTO TABLE @DATA(it_bseg2)
      FOR ALL ENTRIES IN @it_bseg1
      WHERE belnr = @it_bseg1-belnr AND gjahr = @p_year.
  ENDIF.

  LOOP AT it_bseg2 INTO DATA(wa_bseg2).

    IF wa_bseg2-ebeln IS NOT INITIAL.
      READ TABLE gt_data INTO DATA(wa_gt) WITH KEY ebeln = wa_bseg2-ebeln.
      IF  sy-subrc = 0.
        DELETE gt_data   WHERE ebeln = wa_gt-ebeln.
        DELETE it_final1 WHERE ebeln = wa_gt-ebeln.
        DELETE gt_data2  WHERE ebeln = wa_gt-ebeln.
      ENDIF.
    ENDIF.

  ENDLOOP.


  LOOP AT gt_data_inv ASSIGNING FIELD-SYMBOL(<gs_data_inv>).
    wa_awkey-awkey = <gs_data_inv>-belnr && <gs_data_inv>-gjahr.                              ""GS_DATA-BELNR && GS_DATA-GJAHR.

    APPEND wa_awkey TO it_awkey .
    CLEAR wa_awkey .
  ENDLOOP.
  SELECT bkpf~belnr  ,
         bkpf~bukrs  ,
         bkpf~gjahr  ,
         bkpf~awkey  FROM bkpf INTO TABLE @DATA(it_bkpf) FOR ALL ENTRIES IN @it_awkey
          WHERE awkey  = @it_awkey-awkey .

  IF it_bkpf IS NOT INITIAL .
    SELECT bseg~bukrs ,
           bseg~belnr ,
           bseg~gjahr ,
           bseg~augbl
         FROM bseg INTO TABLE @DATA(it_bseg) FOR ALL ENTRIES IN @it_bkpf
         WHERE  bukrs = @it_bkpf-bukrs AND belnr = @it_bkpf-belnr
         AND gjahr = @it_bkpf-gjahr AND augbl  <> @space AND bschl = '31' " CLEARING DOCUMNET
         AND buzid = ' ' . " WITH TAX AMOUNT
  ENDIF.


*******************
  REFRESH : gt_final1.
  DATA : lv_off(10)    TYPE c,
         lv_string(15) TYPE c.
  LOOP AT it_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>) .
    READ TABLE it_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>) WITH KEY belnr = <ls_bseg>-belnr bukrs =  <ls_bseg>-bukrs.
    lv_string = <ls_bkpf>-awkey.
    lv_off = lv_string+0(10).
    LOOP AT gt_data_inv ASSIGNING FIELD-SYMBOL(<ls_dat>) WHERE belnr = lv_off.

      READ TABLE gt_data  ASSIGNING FIELD-SYMBOL(<ls_del>) WITH KEY lfbnr = <ls_dat>-lfbnr.
      IF sy-subrc = 0.
        DELETE gt_data WHERE lfbnr = <ls_dat>-lfbnr.
      ENDIF.

    ENDLOOP.
*    APPEND <LS_DEL> TO GT_DATA.
  ENDLOOP.
** Deleting the Invoice Records
  DELETE gt_data WHERE due_date = c_x.
*** For Date Wise
  DATA(gt_data_date) = gt_data.
  SORT gt_data_date BY due_date.
  DELETE ADJACENT DUPLICATES FROM gt_data_date COMPARING due_date.

  DATA(lv_start_date) = p_year && p_month && '01'.
  REFRESH : gt_final1.

  REFRESH gt_data.

  SORT gt_data2 BY ebeln ebelp mblnr.
  DELETE ADJACENT DUPLICATES FROM gt_data2 COMPARING ebeln ebelp mblnr.
  APPEND LINES OF gt_data2 TO gt_data.
  APPEND LINES OF it_final1 TO gt_data.
  DELETE gt_data WHERE bwart = '102'.
  DATA: lv_dmbtr TYPE bseg-dmbtr.

  DO lv_number_of_days TIMES.

    CLEAR : lv_tax.

*    BREAK breddy.
    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data1>) WHERE due_date = lv_start_date.
*      LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<WA_RET>) WHERE EBELN = <LS_DATA>-EBELN AND MWSKZ = <LS_DATA>-MWSKZ AND EBELP = <LS_DATA>-EBELP.
      READ TABLE it_ekpo ASSIGNING FIELD-SYMBOL(<wa_ret>) WITH KEY ebeln = <ls_data1>-ebeln mwskz = <ls_data1>-mwskz ebelp = <ls_data1>-ebelp.
      IF sy-subrc = 0.


        DATA : lv_po_val TYPE netwr.
        CLEAR lv_po_val.
        CALL METHOD zcl_po_item_tax=>get_po_item_tax
          EXPORTING
            i_ebeln     = <wa_ret>-ebeln                 " Purchasing Document Number
            i_ebelp     = <wa_ret>-ebelp                 " Item Number of Purchasing Document
            i_quantity  = <wa_ret>-menge                 " Quantity
          IMPORTING
*           E_TAX       = GS_FINAL1-TAX                " Tax Amount in Document Currency
            e_total_val = lv_po_val.              " Net Value in Document Currency
        ADD lv_po_val TO gs_final1-amount .
        <ls_data1>-dmbtr  = lv_po_val.

      ELSE.

        READ TABLE gt_data INTO DATA(wa_data) WITH KEY belnr = <ls_data1>-belnr.
        IF sy-subrc = 0.
          gs_final1-amount = gs_final1-amount + wa_data-dmbtr.
*          <ls_data1>-dmbtr = gs_final1-amount.
          DELETE gt_data WHERE belnr = wa_data-belnr AND buzei <> wa_data-buzei.
        ENDIF.

      ENDIF.

    ENDLOOP.

    lv_sl = lv_sl + 1.
    gs_final1-slno  = lv_sl.
    gs_final1-date = lv_start_date+6(2) && '.' && lv_start_date+4(2) && '.' && lv_start_date+0(4).
    gs_final1-currency = 'INR'.
    APPEND gs_final1 TO gt_final1.
    CLEAR : gs_final1 , wa_data.
    lv_start_date = lv_start_date + 1.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data.
*** Field Catlog
  DATA:
    wlayo	TYPE slis_layout_alv,
    wfcat TYPE slis_fieldcat_alv,
    tfcat TYPE slis_t_fieldcat_alv,
    wvari TYPE disvariant.

  wvari-report    = sy-repid.
  wvari-username  = sy-uname.

  wlayo-zebra       = abap_true.
  wlayo-colwidth_optimize  = abap_true.
*  WLAYO-    = 'D'.

*** Field Catlog
  REFRESH tfcat.
  wfcat-fieldname   = 'SLNO'.
  wfcat-seltext_l   = 'SLNO'.
  wfcat-outputlen   = 4.
*  WFCAT-REF_TABNAME = 'GT_FINAL1'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname   = 'DATE'.
  wfcat-seltext_l   = 'Due Date'.
*  WFCAT-REF_TABNAME = 'GT_FINAL1'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname   = 'AMOUNT'.
  wfcat-seltext_l   = 'Amount'.
  wfcat-do_sum  = 'X'.
*  WFCAT-REF_TABNAME = 'GT_FINAL1'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'CURRENCY'.
  wfcat-seltext_l = 'Currency'.
*  WFCAT-REF_TABNAME = 'GT_FINAL1'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

*** Dispalying ALV Report

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = wlayo
      it_fieldcat             = tfcat
      i_save                  = 'U'
      is_variant              = wvari
    TABLES
      t_outtab                = gt_final1
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.
FORM user_command USING  sy-ucomm rs_selfield TYPE slis_selfield.
  CASE sy-ucomm.
    WHEN '&IC1'.
      READ TABLE gt_final1 ASSIGNING FIELD-SYMBOL(<ls_final1>) INDEX rs_selfield-tabindex.
      IF sy-subrc = 0.
        IF <ls_final1>-amount > 0.
          PERFORM get_po_data USING <ls_final1>-date rs_selfield-tabindex.
          CALL SCREEN '9000' .
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_po_data USING i_date i_tabix.
*** PO Data
  BREAK breddy.
******************************************start of test query********************************
  DATA :lv_count TYPE int4 VALUE 1.

  REFRESH : gt_final2.
  DATA(lv_date) = i_date+6(4) && i_date+3(2) && i_date+0(2).

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data>) WHERE due_date = lv_date.


    gs_final2-slno      = lv_count.
    gs_final2-date      = <ls_data>-due_date.
****      GS_FINAL2-AMOUNT    = <LS_DATA>-NETWR_P.
    gs_final2-amount    = <ls_data>-dmbtr.
    gs_final2-currency  = 'INR'.
    gs_final2-ebeln     = <ls_data>-ebeln.
    gs_final2-ebelp     = <ls_data>-ebelp.
    IF <ls_data>-ebeln IS INITIAL.
      gs_final2-belnr = <ls_data>-belnr.
    ENDIF.
    gs_final2-waers     = <ls_data>-waers.
    gs_final2-lifnr     = <ls_data>-lifnr.
****      GS_FINAL2-NAME1     = <LS_DATA>-NAME1.
    gs_final2-grpo_no   = <ls_data>-mblnr.
***      GS_FINAL2-MATKL     = <LS_DATA>-MATKL.
    gs_final2-aedat     = <ls_data>-aedat.
    gs_final2-xblnr     = <ls_data>-xblnr.

    IF gs_final2-kostl IS NOT INITIAL.
      gs_final2-kostl     = <ls_data>-kostl.
    ELSE.
      CLEAR gs_final2-kostl.
      gs_final2-kostl     = <ls_data>-anln1.
    ENDIF.

***      GS_FINAL2-LR_NO    = <LS_DATA>-LR_NO.
***      GS_FINAL2-INWD_DOC  = <LS_DATA>-INWD_DOC.
***      GS_FINAL2-QR_CODE   = <LS_DATA>-QR_CODE.
    IF <ls_data>-ebeln IS NOT INITIAL.
      READ TABLE it_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr1>) WITH KEY service_po = <ls_data>-ebeln.
      IF sy-subrc = 0.
        gs_final2-lr_no   = <ls_hdr1>-lr_no.
      ENDIF.
    ENDIF.

    IF <ls_data>-bwart = '101'.
***        GS_FINAL2-AMOUNT =  ( <LS_DATA>-NETWR_P / <LS_DATA>-MENGE_P ) * <LS_DATA>-MENGE.
      gs_final2-amount =   <ls_data>-dmbtr   .
**      ELSE.
**        GS_FINAL2-AMOUNT = <LS_DATA>-NETWR_P.
    ENDIF.
    READ TABLE it_lfa1 ASSIGNING FIELD-SYMBOL(<ls_lfa1>) WITH KEY lifnr = <ls_data>-lifnr.
    IF sy-subrc = 0.
      gs_final2-name1     = <ls_lfa1>-name1.
    ENDIF.
    APPEND gs_final2 TO gt_final2.
    CLEAR : gs_final2.
    lv_count = lv_count + 1.
  ENDLOOP.
*  ENDIF.
  gt_final3[] = gt_final2.
  SORT gt_final3 BY ebeln.
  BREAK breddy.
  DELETE ADJACENT DUPLICATES FROM  gt_final3 COMPARING ebeln.
  LOOP AT gt_final3  ASSIGNING FIELD-SYMBOL(<gs_final3>).
    CLEAR : <gs_final3>-amount.
    LOOP AT gt_final2 ASSIGNING FIELD-SYMBOL(<gs_amt>) WHERE ebeln = <gs_final3>-ebeln.
      ADD <gs_amt>-amount TO <gs_final3>-amount.
    ENDLOOP.
  ENDLOOP.

  IF container IS INITIAL.
    PERFORM setup_alv.
  ENDIF.

  PERFORM fill_grid.

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
  IF container IS NOT BOUND.
    CREATE OBJECT container
      EXPORTING
        container_name = 'CONTAINER'.
    CREATE OBJECT grid
      EXPORTING
        i_parent = container.
  ENDIF.
ENDFORM.
FORM fill_grid.
*** Field Catlog
  DATA:
    wlayo	TYPE  lvc_s_layo,
    wfcat TYPE lvc_s_fcat,
    tfcat TYPE lvc_t_fcat,
    wvari TYPE disvariant.
  DATA: lt_exclude TYPE ui_functions.
  wvari-report    = sy-repid.
  wvari-username  = sy-uname.

  wlayo-zebra       = abap_true.
  wlayo-cwidth_opt  = abap_true.
*  WLAYO-    = 'D'.

  REFRESH gt_ftable.
*  DATA: USER_COMMAND1 TYPE SLIS_FORMNAME VALUE 'USER_COMMAND1'.

*  REFRESH TFCAT.
  REFRESH : tfcat.
  wfcat-fieldname = 'SEL'.
  wfcat-scrtext_l = 'Selection'.
  wfcat-checkbox = 'X'.
  wfcat-edit = 'X'.
*  WFCAT-TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

*** Field Catlog

  wfcat-fieldname = 'SLNO'.
  wfcat-scrtext_l = 'SLNO'.
  wfcat-outputlen = 4.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'DATE'.
  wfcat-scrtext_l = 'Due Date'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'LIFNR'.
  wfcat-scrtext_l = 'Vendor'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'NAME1'.
  wfcat-scrtext_l = 'Vendor Name'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'EBELN'.
  wfcat-scrtext_l = 'PO'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'BELNR'.
  wfcat-scrtext_l = 'Document No'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'AEDAT'.
  wfcat-scrtext_l = 'Doc Date'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'LR_NO'.
  wfcat-scrtext_l = 'LR NUMBER'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'XBLNR'.
  wfcat-scrtext_l = 'Reference'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.


  wfcat-fieldname = 'KOSTL'.
  wfcat-scrtext_l = 'Cost Center/Asset'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'AMOUNT'.
  wfcat-scrtext_l = 'Amount'.
*  WFCAT-TABNAME = 'GT_FINAL2'.
*  WFCAT-REF_FIELDNAME = 'NETWR'.
  wfcat-do_sum = 'X'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.

  wfcat-fieldname = 'CURRENCY'.
  wfcat-scrtext_l = 'Currency'.
*  WFCAT-REF_TABNAME = 'GT_FINAL2'.
  APPEND wfcat TO tfcat.
  CLEAR wfcat.
****  Diaplsy PO Detailed Report
*
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      I_CALLBACK_PROGRAM       = SY-REPID
*      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
*      I_CALLBACK_USER_COMMAND  = USER_COMMAND1
*      IS_LAYOUT                = WLAYO
*      IT_FIELDCAT              = TFCAT
*      I_SAVE                   = 'U'
*      IS_VARIANT               = WVARI
*      I_DEFAULT                = 'A'
*    TABLES
*      T_OUTTAB                 = GT_FINAL3
*    EXCEPTIONS
*      PROGRAM_ERROR            = 1
*      OTHERS                   = 2.
*  IF SY-SUBRC <> 0.
*  ENDIF.



  IF gr_event IS NOT BOUND.
    CREATE OBJECT gr_event.
  ENDIF.


  IF grid IS BOUND.

    IF lt_exclude IS INITIAL.
      PERFORM exclude_tb_functions CHANGING lt_exclude.
    ENDIF.



    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding          = lt_exclude
        is_layout                     = wlayo
      CHANGING
        it_outtab                     = gt_final2[] "it_item[]
        it_fieldcatalog               = tfcat[]
*       IT_SORT                       = IT_SORT[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
    ENDIF.
    BREAK breddy.
***  Registering the EDIT Event
    CALL METHOD grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    SET HANDLER gr_event->handle_data_changed FOR grid.



  ENDIF.

  IF grid IS BOUND.

    ls_stable-row = 'X'.
    ls_stable-col = 'X'.
    CALL METHOD grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
    ENDIF .

  ENDIF.

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
*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUM.
*  APPEND LS_EXCLUDE TO LT_EXCLUDE.
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
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ZSTATUS'.
* SET TITLEBAR 'xxx'.
  LOOP AT SCREEN .
    IF screen-group1 = 'G1'.
      screen-color = 1 .
      screen-intensified = 5.
    ENDIF.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  ok_code = sy-ucomm .



  CASE ok_code.
    WHEN 'BACK' .
      CLEAR lv_sum.
      LEAVE TO SCREEN 0.
    WHEN '&CPRINT'.
      REFRESH gt_ftable.
      DATA : form_name TYPE rs38l_fnam.
      DATA : form_name1 TYPE rs38l_fnam.
      DATA : lv_slno TYPE i .
      DATA : lv_total TYPE zbprei_pt.
*      DATA : GS_FINAL3 TYPE TY_FINAL2.
      BREAK breddy.
      CLEAR : lv_slno .

      LOOP AT gt_final3 INTO gs_final3 WHERE sel = 'X'.
        MOVE-CORRESPONDING  gs_final3 TO gs_ftable .
        CLEAR gs_ftable-slno .
        lv_slno = lv_slno + 1 .
        gs_ftable-slno = lv_slno .
        lv_total = gs_ftable-amount + lv_total.
        APPEND gs_ftable TO gt_ftable .
        CLEAR : gs_ftable .
      ENDLOOP.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZACC_DIARY_FORM'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
*         GT_FINAL           = GT_FINAL2
        IMPORTING
          fm_name            = form_name1
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
      CALL FUNCTION form_name1
        EXPORTING
          lv_total         = lv_total
*         CONTROL_PARAMETERS = LW_CPARAM
*         OUTPUT_OPTIONS   = OUTPUT_OPTIONS
**           user_settings      = 'X'
*         WA_HEADER        = WA_HEADER
*         WA_ADRC          = WA_ADRC
        TABLES
          gt_ftable        = gt_ftable
        EXCEPTIONS
          formatting_error = 1
          internal_error   = 2
          send_error       = 3
          user_canceled    = 4
          OTHERS           = 5.

  ENDCASE.
  CLEAR : lv_total .
  CLEAR : ok_code , sy-ucomm .


ENDMODULE.









**&---------------------------------------------------------------------*
**&      Form  set_pf_status
**&---------------------------------------------------------------------*
*FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
*  SET PF-STATUS 'ZPAYSLIP_STATUS1' EXCLUDING RT_EXTAB.
*ENDFORM. "Set_pf_status
**&---------------------------------------------------------------------*
**&      Form  user_command
**&---------------------------------------------------------------------*
*FORM USER_COMMAND1 USING R_UCOMM     LIKE SY-UCOMM
*                        RS_SELFIELD TYPE SLIS_SELFIELD.
*  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
*  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
*    IMPORTING
*      E_GRID = REF_GRID.
*
*  IF REF_GRID IS NOT INITIAL.
*    CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).
*  ENDIF.
*
*  REFRESH GT_FTABLE.
**  BREAK BREDDY .
*  CASE R_UCOMM.
*    WHEN 'BACK' .
*      LEAVE TO SCREEN 0.
*    WHEN '&CPRINT'.
*      DATA : FORM_NAME TYPE RS38L_FNAM.
*      DATA : FORM_NAME1 TYPE RS38L_FNAM.
*      DATA : LV_SLNO TYPE I .
*      DATA : LV_TOTAL TYPE ZBPREI_PT.
**      DATA : GS_FINAL3 TYPE TY_FINAL2.
*      BREAK BREDDY.
*      LOOP AT GT_FINAL3 INTO GS_FINAL3 WHERE SEL = 'X'.
*        MOVE-CORRESPONDING  GS_FINAL3 TO GS_FTABLE .
*        CLEAR GS_FTABLE-SLNO .
*        LV_SLNO = LV_SLNO + 1 .
*        GS_FTABLE-SLNO = LV_SLNO .
*        LV_TOTAL = GS_FTABLE-AMOUNT + LV_TOTAL.
*        APPEND GS_FTABLE TO GT_FTABLE .
*        CLEAR GS_FTABLE .
*      ENDLOOP.
*
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          FORMNAME           = 'ZACC_DIARY_FORM'
**         VARIANT            = ' '
**         DIRECT_CALL        = ' '
**         GT_FINAL           = GT_FINAL2
*        IMPORTING
*          FM_NAME            = FORM_NAME1
*        EXCEPTIONS
*          NO_FORM            = 1
*          NO_FUNCTION_MODULE = 2
*          OTHERS             = 3.
*      IF SY-SUBRC <> 0.
** Implement suitable error handling here
*      ENDIF.
*      CALL FUNCTION FORM_NAME1
*        EXPORTING
*          LV_TOTAL         = LV_TOTAL
**         CONTROL_PARAMETERS = LW_CPARAM
**         OUTPUT_OPTIONS   = OUTPUT_OPTIONS
***           user_settings      = 'X'
**         WA_HEADER        = WA_HEADER
**         WA_ADRC          = WA_ADRC
*        TABLES
*          GT_FTABLE        = GT_FTABLE
*        EXCEPTIONS
*          FORMATTING_ERROR = 1
*          INTERNAL_ERROR   = 2
*          SEND_ERROR       = 3
*          USER_CANCELED    = 4
*          OTHERS           = 5.
*
*  ENDCASE.
*ENDFORM.
