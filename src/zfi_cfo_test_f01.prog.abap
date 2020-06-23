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
*  BREAK BREDDY.
  lv_to_date = p_year && p_month && lv_number_of_days.
  lv_from_date =  lv_to_date - 212.
  APPEND VALUE #( sign = c_i option = c_op low = lv_from_date high = lv_to_date ) TO r_date.
*  SELECT
*    EKBE~EBELN,
*    EKBE~EBELP,
*    EKBE~BEWTP,
*    EKBE~BELNR,
*    EKBE~GJAHR,
*    EKBE~BUDAT ,
*    EKKO~BSART ,
*    EKKO~LOEKZ ,
*    EKKO~AEDAT ,
*    EKKO~LIFNR ,
*    EKKO~WAERS ,
*    EKKO~ZTERM ,
*    EKKO~ZBD1T ,
*    ZINW_T_HDR~QR_CODE,
*    ZINW_T_HDR~NAME1,
*    ZINW_T_HDR~STATUS,
*    ZINW_T_HDR~SOE ,
*    ZINW_T_HDR~MBLNR_103 ,
*    ZINW_T_HDR~MBLNR ,
*    ZINW_T_HDR~INWD_DOC ,
*    ZINW_T_ITEM~MATNR ,
*    ZINW_T_ITEM~MATKL ,
*    ZINW_T_ITEM~NETPR_P ,
*    ZINW_T_ITEM~NETWR_P + ZINW_T_ITEM~NETPR_GP AS NETWR_P ,
*    ZINW_T_ITEM~NETPR_GP,
*    ZINW_T_ITEM~MENGE_P,
*    EKBE~BUDAT AS DUE_DATE
*    INTO TABLE @DATA(TEST)
*    FROM  EKBE AS EKBE
*    INNER JOIN ZINW_T_HDR AS ZINW_T_HDR ON EKBE~BELNR = ZINW_T_HDR~MBLNR
*    INNER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON ZINW_T_ITEM~QR_CODE = ZINW_T_HDR~QR_CODE
*    INNER JOIN EKKO AS EKKO ON EKKO~EBELN = ZINW_T_HDR~EBELN
*    INNER JOIN EKPO AS EKPO ON EKBE~EBELN = EKPO~EBELN AND  EKBE~EBELP = EKPO~EBELP
*    WHERE  EKKO~BSART IN ( 'ZLOP' , 'ZOSP' , 'ZTAT' )
*    AND EKBE~EBELN = '4600001540'
*    AND ZINW_T_HDR~SOE <> ' ' AND EKBE~BUDAT IN @R_DATE AND EKKO~LOEKZ <> @C_X AND EKBE~BEWTP IN ( 'Q' , 'E' )." AND EKBE~BWART IN ( '107' , '101', ' ' ) .
*  BREAK BREDDY.
  SELECT
    ekbe~ebeln,
    ekbe~ebelp,
    ekbe~bewtp,
    ekbe~bwart,
    ekbe~menge,
    ekbe~belnr,
    ekbe~gjahr,
    ekbe~budat,
    ekbe~lfbnr,
    ekko~bsart,
    ekko~loekz,
    ekko~aedat,
    ekko~lifnr,
    ekko~waers,
    ekko~zterm,
    ekko~zbd1t,
    zinw_t_hdr~qr_code,
    zinw_t_hdr~name1,
    zinw_t_hdr~status,
    zinw_t_hdr~soe ,
    zinw_t_hdr~bill_num ,
    zinw_t_hdr~mblnr_103 ,
    zinw_t_hdr~mblnr ,
    zinw_t_hdr~inwd_doc ,
    zinw_t_hdr~return_po ,
    zinw_t_hdr~bill_date ,
*    ZINW_T_HDR~LR_NO,
    zinw_t_item~matnr ,
    zinw_t_item~matkl ,
    zinw_t_item~netpr_p ,
    zinw_t_item~netwr_p + zinw_t_item~netpr_gp AS netwr_p ,
    zinw_t_item~netpr_gp,
    zinw_t_item~menge_p,
*    MKPF~BUDAT,
    ekbe~budat AS due_date
*    EKBE~BELNR AS BELNR1
    INTO TABLE @gt_data
    FROM  ekbe AS ekbe
    INNER JOIN zinw_t_hdr AS zinw_t_hdr ON ekbe~belnr = zinw_t_hdr~mblnr
    INNER JOIN zinw_t_item AS zinw_t_item ON zinw_t_item~qr_code = zinw_t_hdr~qr_code AND zinw_t_item~ebeln = ekbe~ebeln AND zinw_t_item~ebelp = ekbe~ebelp
    INNER JOIN ekko AS ekko ON ekko~ebeln = zinw_t_hdr~ebeln
*    INNER JOIN MKPF AS MKPF ON MBLNR = ZINW_T_HDR~MBLNR
    LEFT OUTER JOIN ekpo AS ekpo ON ekpo~ebeln = zinw_t_hdr~return_po
*    LEFT OUTER JOIN EKBE AS EKBE ON EKBE~BEWTP IN ( 'Q' , 'E' )
    WHERE  ekko~bsart IN ( 'ZLOP' , 'ZOSP' , 'ZTAT' , 'ZVLO', 'ZVOS' )
*    AND EKBE~EBELN = '4500000550'
    AND zinw_t_hdr~soe <> ' ' AND ekbe~budat IN @r_date AND ekko~loekz <> @c_x  AND ekbe~bwart IN ( '109' , '101', ' ' ) AND ekbe~bewtp = 'E' .
*  BREAK BREDDY.
  SORT gt_data BY ebeln ebelp belnr.
  DELETE ADJACENT DUPLICATES FROM gt_data COMPARING ebeln ebelp belnr.
  IF gt_data IS NOT INITIAL.
    SELECT * FROM ekpo INTO TABLE it_ekpo FOR ALL ENTRIES IN gt_data WHERE ebeln = gt_data-return_po .
  ENDIF.

  TYPES  : BEGIN OF ty_awkey  ,
             awkey TYPE bkpf-awkey,
           END OF ty_awkey .
  DATA : it_awkey  TYPE TABLE OF ty_awkey,
         it_awkey1 TYPE TABLE OF ty_awkey,
         wa_awkey1 TYPE ty_awkey,
         wa_awkey  TYPE ty_awkey.

*  DATA(IT_DATA) = GT_DATA[].
*  DATA : LV_AWKEY(20) TYPE C.

*** Invoice Records
  SELECT ekbe~ebeln,
         ekbe~ebelp,
         ekbe~bewtp,
         ekbe~belnr ,
         ekbe~gjahr,
         ekbe~budat,
         ekbe~lfbnr
         FROM ekbe INTO TABLE @DATA(gt_data_inv) FOR ALL ENTRIES IN @gt_data WHERE ebeln = @gt_data-ebeln AND ebelp = @gt_data-ebelp AND bewtp = 'Q'.
*** For Date Wise
  DELETE gt_data_inv WHERE bewtp <> 'Q'.

  LOOP AT gt_data_inv ASSIGNING FIELD-SYMBOL(<gs_data_inv>).
    wa_awkey-awkey = <gs_data_inv>-belnr && <gs_data_inv>-gjahr.                              ""GS_DATA-BELNR && GS_DATA-GJAHR.

    APPEND wa_awkey TO it_awkey .
    CLEAR wa_awkey .
  ENDLOOP.



*  SELECT MSEG~MBLNR, MSEG~MJAHR FROM MSEG INTO TABLE  @DATA(GT_MSEG) FOR ALL ENTRIES IN @GT_DATA_INV WHERE LFBNR = @GT_DATA_INV-LFBNR AND BWART = '109'.

*  LOOP AT GT_MSEG ASSIGNING FIELD-SYMBOL(<GS_MSEG>).
*    WA_AWKEY1-AWKEY = <GS_MSEG>-MBLNR && <GS_MSEG>-MJAHR.
*    APPEND WA_AWKEY1 TO IT_AWKEY1.
*    CLEAR WA_AWKEY.
*  ENDLOOP.

*  IF IT_AWKEY1 IS NOT INITIAL.
*  SELECT BKPF~BELNR  ,
*        BKPF~BUKRS  ,
*        BKPF~GJAHR  ,
*        BKPF~AWKEY  FROM BKPF INTO TABLE @DATA(IT_BKPF1) FOR ALL ENTRIES IN @IT_AWKEY1 WHERE AWKEY = @IT_AWKEY1-AWKEY.
**  ENDIF.

*  IF IT_BKPF1 IS NOT INITIAL.
*
*    SELECT BSEG~BUKRS ,
*             BSEG~BELNR ,
*             BSEG~GJAHR ,
*             BSEG~AUGBL FROM BSEG INTO TABLE @DATA(IT_BSEG1) FOR ALL ENTRIES IN @IT_BKPF1
*            WHERE  BUKRS = @IT_BKPF1-BUKRS AND BELNR = @IT_BKPF1-BELNR
*            AND GJAHR = @IT_BKPF1-GJAHR AND AUGBL  <> @SPACE AND BSCHL = '31' " CLEARING DOCUMNET
*            AND BUZID = ' ' .
*  ENDIF.

  IF it_awkey IS NOT INITIAL.
    SELECT bkpf~belnr  ,
           bkpf~bukrs  ,
           bkpf~gjahr  ,
           bkpf~awkey  FROM bkpf INTO TABLE @DATA(it_bkpf) FOR ALL ENTRIES IN @it_awkey
            WHERE awkey  = @it_awkey-awkey .
  ENDIF.
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


*  SELECT  BELNR FROM BKPF INTO TABLE IT_BKPF FOR ALL ENTRIES IN IT_DATA WHERE AWKEY = IT_DATA-BELNR1.

*  IF IT_BKPF IS NOT INITIAL .
*
*    SELECT BELNR AUGBL FROM BSEG INTO TABLE IT_BSEG FOR ALL ENTRIES IN IT_BKPF WHERE BELNR = IT_BKPF-BELNR.
*
*  ENDIF.
*
*
  IF it_ekpo IS NOT INITIAL.
    SELECT * FROM a003 INTO TABLE it_a003 FOR ALL ENTRIES IN it_ekpo WHERE mwskz = it_ekpo-mwskz.
  ENDIF.

  IF it_a003 IS NOT INITIAL.
    SELECT * FROM konp INTO TABLE it_konp FOR ALL ENTRIES IN it_a003 WHERE knumh = it_a003-knumh.
  ENDIF.

*
*  SORT GT_DATA BY MBLNR EBELN MATNR.
*  DELETE ADJACENT DUPLICATES FROM GT_DATA COMPARING MBLNR EBELN MATNR.
*  DELETE GT_DATA WHERE MBLNR <> '5000000836'.
*** For Calculating Due Date
  IF  gt_data IS NOT INITIAL.         "" IF SY-SUBRC = 0 AND
    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      <ls_data>-due_date = <ls_data>-budat +  <ls_data>-zbd1t.
    ENDLOOP.
  ENDIF.
  DELETE gt_data WHERE due_date GT lv_to_date.
  IF gt_data IS INITIAL.
    MESSAGE | No Payment pending for month  { p_month } { p_year } | TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
**** Invoice Records

*** Deleting the Invoice Records
*  DELETE GT_DATA WHERE DUE_DATE = C_X.
*** For Date Wise
  DATA(gt_data_date) = gt_data.
  SORT gt_data_date BY due_date.
  DATA : lv_tax TYPE ekpo-netpr .
  DATA : lv_return TYPE ekpo-netpr .
*  DELETE ADJACENT DUPLICATES FROM GT_DATA_DATE COMPARING DUE_DATE.

  DATA(lv_start_date) = p_year && p_month && '01'.
  REFRESH : gt_final1.
  DATA : lv_off(10)     TYPE c,
         lv_off1(10)    TYPE c,
         lv_string(15)  TYPE c,
         lv_string1(15) TYPE c.


*** Start of Changes by Suri : 11.04.2020 : 19.24.00 For Removing Clearing Doc
**  LOOP AT it_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>) .
**    READ TABLE it_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>) WITH KEY belnr = <ls_bseg>-belnr bukrs =  <ls_bseg>-bukrs.
***    LV_STRING = <LS_BKPF>-AWKEY.
***    LV_OFF = LV_STRING+0(10).
**
**    LOOP AT gt_data_inv ASSIGNING FIELD-SYMBOL(<ls_dat>) WHERE belnr = <ls_bkpf>-awkey+0(10) AND gjahr = <ls_bkpf>-awkey+10(4).
**      READ TABLE gt_data  ASSIGNING FIELD-SYMBOL(<ls_del>) WITH KEY lfbnr = <ls_dat>-lfbnr gjahr = <ls_dat>-gjahr.
**      IF sy-subrc = 0.
**        DELETE gt_data WHERE lfbnr = <ls_dat>-lfbnr and gjahr = <ls_dat>-gjahr.
***        modify gt_data set lfbnr  where lfbnr = <ls_dat>-lfbnr and gjahr = <ls_dat>-gjahr.
**      ENDIF.
**    ENDLOOP.
***    APPEND <LS_DEL> TO GT_DATA.
**  ENDLOOP.

  FIELD-SYMBOLS :
    <ls_bseg>     LIKE LINE OF it_bseg,
    <ls_bkpf>     LIKE LINE OF it_bkpf,
    <ls_data_inv> LIKE LINE OF gt_data_inv.
  DATA :
    ls_data LIKE LINE OF gt_data.

  SORT it_bseg BY belnr gjahr.
  SORT it_bkpf BY belnr gjahr.

  LOOP AT it_bseg ASSIGNING <ls_bseg>.
    READ TABLE it_bkpf ASSIGNING <ls_bkpf> WITH KEY belnr = <ls_bseg>-belnr gjahr = <ls_bseg>-gjahr BINARY SEARCH.
    IF sy-subrc = 0.
      READ TABLE gt_data_inv ASSIGNING <ls_data_inv> WITH KEY belnr = <ls_bkpf>-awkey+0(10) gjahr = <ls_bkpf>-awkey+10(4).
      IF sy-subrc IS INITIAL.
        READ TABLE gt_data WITH KEY lfbnr = <ls_data_inv>-lfbnr gjahr = <ls_data_inv>-gjahr TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          ls_data-lfbnr = 'XX'.  " Deletion Mark
***       Modify Remaining Items
          MODIFY gt_data FROM ls_data TRANSPORTING lfbnr WHERE lfbnr = <ls_data_inv>-lfbnr AND gjahr = <ls_data_inv>-gjahr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DELETE gt_data WHERE lfbnr = 'XX'.
*** End of Changes by Suri : 11.04.2020 : 19.24.00 For Removing Clearing Doc

  DO lv_number_of_days TIMES.
*    LOOP AT IT_BSEG ASSIGNING FIELD-SYMBOL(<Ls_BSEG>) .
*      READ TABLE IT_BKPF ASSIGNING FIELD-SYMBOL(<LS_BKPF>) WITH KEY BELNR = <LS_BSEG>-BELNR BUKRS =  <LS_BSEG>-BUKRS.
*      LV_STRING = <LS_BKPF>-AWKEY.
*      LV_OFF = LV_STRING+0(10).
    LOOP AT gt_data ASSIGNING <ls_data> WHERE due_date = lv_start_date . ""AND MBLNR = LV_STRING.
**        READ TABLE GT_DATA_INV ASSIGNING FIELD-SYMBOL(<LS_DAT>) WITH KEY LFBNR = <LS_DATA>-BELNR.
*        IF SY-SUBRC = 0.
*
*        ENDIF.
*      IF <ls_data>-belnr = lv_string.
*        delete <ls_data>-netwr_p .
*      ENDIF.

      IF <ls_data>-bwart = '109'.
*          DATA(LV_AMOUNT) = ( <LS_DATA>-MENGE * <LS_DATA>-NETPR_P ) + ( ( <LS_DATA>-NETPR_GP / <LS_DATA>-MENGE_P ) * <LS_DATA>-MENGE ).
        lv_amount =  ( <ls_data>-netwr_p / <ls_data>-menge_p ) * <ls_data>-menge .
        ADD lv_amount TO gs_final1-amount.
      ELSE.
        ADD <ls_data>-netwr_p TO gs_final1-amount.
      ENDIF.

*        LOOP AT IT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).
*          LOOP AT IT_BSEG INTO WA_BSEG.
*            READ TABLE IT_BKPF INTO WA_BKPF WITH KEY AWKEY = <LS_DATA>-BELNR.
*            READ TABLE IT_EKBE INTO WA_EKBE WITH KEY BELNR = <LS_DATA>-BELNR.
*            IF SY-SUBRC = 0.
*              DELETE GT_DATA-EBELN .
*            ENDIF.
*          ENDLOOP.
      gs_final1-mblnr = <ls_data>-belnr.
    ENDLOOP.
*      READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<LS_DAT>) WITH KEY BELNR = LV_STRING.   ""WITH KEY DUE_DATE = LV_START_DATE.
*      IF SY-SUBRC = 0.
*        DELETE gt_data.
*      ENDIF.
*    ENDLOOP.

    gs_final1-amount = gs_final1-amount - lv_return .
    gs_final1-slno = sy-index.
    gs_final1-date = lv_start_date+6(2) && '.' && lv_start_date+4(2) && '.' && lv_start_date+0(4).
    gs_final1-currency = 'INR'.
    APPEND gs_final1 TO gt_final1.
    CLEAR : gs_final1.
    lv_start_date = lv_start_date + 1.
  ENDDO.
*  READ TABLE GT_FINAL1 ASSIGNING FIELD-SYMBOL(<gs_pay>).
*  IF <gs_pay>-mblnr = lv_string.
*
*  ENDIF.

***  Return PO Values

  DATA(gt_data_rpo) = gt_data .
  SORT gt_data_rpo BY return_po.
  DELETE gt_data_rpo WHERE return_po IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM gt_data_rpo COMPARING return_po.
  LOOP AT gt_final1 ASSIGNING FIELD-SYMBOL(<ls_final1>).
    lv_start_date = <ls_final1>-date+6(4) && <ls_final1>-date+3(2) && <ls_final1>-date+0(2).
    CLEAR : lv_return.
    LOOP AT gt_data_rpo ASSIGNING <ls_data> WHERE due_date = lv_start_date.
      LOOP AT it_ekpo ASSIGNING FIELD-SYMBOL(<wa_ret>) WHERE ebeln = <ls_data>-return_po .
        LOOP AT it_a003 ASSIGNING FIELD-SYMBOL(<wa_a003>) WHERE mwskz = <wa_ret>-mwskz  .
          LOOP AT it_konp ASSIGNING FIELD-SYMBOL(<wa_konp>) WHERE knumh = <wa_a003>-knumh .
            CASE <wa_konp>-kschl.
              WHEN 'JIIG'.
                lv_tax = lv_tax + ( ( <wa_ret>-netwr *  ( <wa_konp>-kbetr / 10 ) ) / 100 ) .
              WHEN 'JICG'.
                lv_tax = lv_tax + ( ( <wa_ret>-netwr *  ( <wa_konp>-kbetr / 10 ) ) / 100 ) .
              WHEN 'JISG'.
                lv_tax = lv_tax + ( ( <wa_ret>-netwr *  ( <wa_konp>-kbetr / 10 ) ) / 100 ) .
            ENDCASE.
          ENDLOOP.
        ENDLOOP.
        lv_return = lv_return + <wa_ret>-netwr + lv_tax .
        CLEAR lv_tax.
      ENDLOOP.
    ENDLOOP.
    <ls_final1>-amount = <ls_final1>-amount - lv_return.
  ENDLOOP.




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
*  WFCAT-REF_TABNAME = 'GT_FINAL1'.
*  WFCAT-REF_FIELDNAME  = 'NETWR'.
  wfcat-do_sum       = 'X'.

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
  DATA :lv_count TYPE int4 VALUE 1.
  DATA : lv_return TYPE ekpo-netpr .
  DATA : lv_tax TYPE ekpo-netpr .
  REFRESH : gt_final2.
  DATA(lv_date) = i_date+6(4) && i_date+3(2) && i_date+0(2).
*  BREAK BREDDY .
  gt_data_po[] = gt_data[].

*** Suri : added
  DELETE gt_data_po WHERE due_date <> lv_date.

  DATA(lt_data_inw) = gt_data_po.
  SORT gt_data_po BY inwd_doc.
  DELETE ADJACENT DUPLICATES FROM gt_data_po COMPARING inwd_doc.

*** Checking For Return PO's
  LOOP AT gt_data_po ASSIGNING FIELD-SYMBOL(<ls_po>) WHERE return_po IS NOT INITIAL.
    DATA(lv_return_flg) = 'X'.
    EXIT.
  ENDLOOP.
  IF lv_return_flg IS NOT INITIAL.
    IF gt_data_po IS NOT INITIAL.
      SELECT * FROM ekpo INTO TABLE @DATA(it_ekpo_1) FOR ALL ENTRIES IN @gt_data_po WHERE ebeln = @gt_data_po-return_po.
      IF it_ekpo_1 IS NOT INITIAL.
        SELECT * FROM a003 INTO TABLE @DATA(it_a003_1) FOR ALL ENTRIES IN @it_ekpo_1 WHERE mwskz = @it_ekpo_1-mwskz.
        IF it_a003 IS NOT INITIAL.
          SELECT * FROM konp INTO TABLE @DATA(it_konp_1) FOR ALL ENTRIES IN @it_a003_1 WHERE knumh = @it_a003_1-knumh.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*** Suri : Ended
*  IF I_TABIX = 1.
  LOOP AT gt_data_po ASSIGNING <ls_po> WHERE due_date = lv_date.
*  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE DUE_DATE = LV_DATE.
    gs_final2-slno      = lv_count.
    LOOP AT lt_data_inw ASSIGNING FIELD-SYMBOL(<ls_data>) WHERE inwd_doc = <ls_po>-inwd_doc.

      gs_final2-date      = <ls_data>-due_date.
      gs_final2-currency  = 'INR'.
      gs_final2-ebeln     = <ls_data>-ebeln.
      gs_final2-ebelp     = <ls_data>-ebelp.
      gs_final2-waers     = <ls_data>-waers.
      gs_final2-lifnr     = <ls_data>-lifnr.
      gs_final2-name1     = <ls_data>-name1.
      gs_final2-bill_num     = <ls_data>-bill_num.
      gs_final2-bill_date     = <ls_data>-bill_date.
      gs_final2-grpo_no   = <ls_data>-mblnr.
      gs_final2-matkl     = <ls_data>-matkl.
      gs_final2-aedat     = <ls_data>-aedat.
      gs_final2-inwd_doc  = <ls_data>-inwd_doc.
      gs_final2-qr_code   = <ls_data>-qr_code.
*            GS_FINAL2-LR_NO    = <LS_DATA>-LR_NO.

      IF <ls_data>-bwart = '109'.
        gs_final2-amount =  gs_final2-amount  + ( ( <ls_data>-netwr_p / <ls_data>-menge_p ) * <ls_data>-menge ) .
      ELSE.
        gs_final2-amount = gs_final2-amount + <ls_data>-netwr_p.
      ENDIF.
    ENDLOOP.
**********chnages on 25/06/2019 10:43******************
    IF <ls_po>-return_po IS NOT INITIAL .
      LOOP AT it_ekpo_1 ASSIGNING FIELD-SYMBOL(<wa_ret>) WHERE ebeln = <ls_po>-return_po .
*            DATA(DATA_RET) = ( <LS_DATA>-NETWR_P ) * ( -1 ).
        LOOP AT it_a003_1 ASSIGNING FIELD-SYMBOL(<wa_a003>) WHERE mwskz = <wa_ret>-mwskz  .
          LOOP AT it_konp_1 ASSIGNING FIELD-SYMBOL(<wa_konp>) WHERE knumh = <wa_a003>-knumh .
            CASE <wa_konp>-kschl.
              WHEN 'JIIG'.
                lv_tax = lv_tax + ( ( <wa_ret>-netwr *  ( <wa_konp>-kbetr / 10 ) ) / 100 ) .
              WHEN 'JICG'.
                lv_tax = lv_tax + ( ( <wa_ret>-netwr *  ( <wa_konp>-kbetr / 10 ) ) / 100 ) .
              WHEN 'JISG'.
                lv_tax = lv_tax + ( ( <wa_ret>-netwr *  ( <wa_konp>-kbetr / 10 ) ) / 100 ) .
            ENDCASE.
          ENDLOOP.
        ENDLOOP.
        lv_return = lv_return + <wa_ret>-netwr + lv_tax .
        CLEAR lv_tax .
      ENDLOOP .
    ENDIF.
************
    gs_final2-amount  = gs_final2-amount -  lv_return  .
    CLEAR lv_return .
    APPEND gs_final2 TO gt_final2.
    CLEAR : gs_final2.
    lv_count = lv_count + 1.
  ENDLOOP.
*  ELSE.
*    LOOP AT GT_DATA ASSIGNING <LS_DATA> WHERE DUE_DATE = LV_DATE.
*      GS_FINAL2-SLNO      = LV_COUNT.
*      GS_FINAL2-DATE      = <LS_DATA>-DUE_DATE.
**      GS_FINAL2-AMOUNT    = <LS_DATA>-NETWR_P.
*      GS_FINAL2-CURRENCY  = 'INR'.
*      GS_FINAL2-EBELN     = <LS_DATA>-EBELN.
*      GS_FINAL2-EBELP     = <LS_DATA>-EBELP.
*      GS_FINAL2-WAERS     = <LS_DATA>-WAERS.
*      GS_FINAL2-LIFNR     = <LS_DATA>-LIFNR.
*      GS_FINAL2-NAME1     = <LS_DATA>-NAME1.
*      GS_FINAL2-GRPO_NO   = <LS_DATA>-MBLNR.
*      GS_FINAL2-MATKL     = <LS_DATA>-MATKL.
*      GS_FINAL2-AEDAT     = <LS_DATA>-AEDAT.
*      GS_FINAL2-INWD_DOC  = <LS_DATA>-INWD_DOC.
*      GS_FINAL2-QR_CODE   = <LS_DATA>-QR_CODE.
*
*      IF <LS_DATA>-BWART = '109'.
*        GS_FINAL2-AMOUNT =  ( <LS_DATA>-NETWR_P / <LS_DATA>-MENGE_P ) * <LS_DATA>-MENGE.
*      ELSE.
*        GS_FINAL2-AMOUNT = <LS_DATA>-NETWR_P.
*      ENDIF.
*      APPEND GS_FINAL2 TO GT_FINAL2.
*      CLEAR : GS_FINAL2.
*      LV_COUNT = LV_COUNT + 1.
*    ENDLOOP.
*  ENDIF.

**** Field Catlog
*  DATA: USER_COMMAND1 TYPE SLIS_FORMNAME VALUE 'USER_COMMAND1'.
***field Catalog
*  IF GRID IS BOUND.

*    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
*      EXPORTING
*        IS_STABLE = LS_STABLE   " With Stable Rows/Columns
**       i_soft_refresh =     " Without Sort, Filter, etc.
*      EXCEPTIONS
*        FINISHED  = 1
*        OTHERS    = 2.
*    IF SY-SUBRC <> 0.
*    ENDIF.
*  ENDIF.

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
*  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .

  lw_layo-zebra = abap_true .
  lw_layo-cwidth_opt = abap_true .
**  REFRESH : TFCAT.
**  WFCAT-FIELDNAME = 'SEL'.
**  WFCAT-SELTEXT_L = 'Selection'.
**  WFCAT-CHECKBOX = 'X'.
**  WFCAT-EDIT = 'X'.
**  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '1'.
  wa_fc-fieldname = 'SEL'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Selection'.
  wa_fc-checkbox = 'X' .
  wa_fc-edit = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


  wa_fc-col_pos   = '2'.
  wa_fc-fieldname = 'SLNO'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'SLNO'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

**  WFCAT-FIELDNAME = 'SLNO'.
**  WFCAT-SELTEXT_L = 'SLNO'.
**  WFCAT-OUTPUTLEN = 4.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.


  wa_fc-col_pos   = '3'.
  wa_fc-fieldname = 'DATE'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Due Date'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'DATE'.
**  WFCAT-SELTEXT_L = 'Due Date'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '4'.
  wa_fc-fieldname = 'LIFNR'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Vendor'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

**  WFCAT-FIELDNAME = 'LIFNR'.
**  WFCAT-SELTEXT_L = 'Vendor'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '5'.
  wa_fc-fieldname = 'NAME1'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Vendor Name'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'NAME1'.
**  WFCAT-SELTEXT_L = 'Vendor Name'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '6'.
  wa_fc-fieldname = 'EBELN'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'PO Number'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

**  WFCAT-FIELDNAME = 'EBELN'.
**  WFCAT-SELTEXT_L = 'PO'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '7'.
  wa_fc-fieldname = 'AEDAT'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Doc Date'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

**  WFCAT-FIELDNAME = 'AEDAT'.
**  WFCAT-SELTEXT_L = 'Doc Date'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.


  wa_fc-col_pos   = '8'.
  wa_fc-fieldname = 'INWD_DOC'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Inward Document'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'INWD_DOC'.
**  WFCAT-SELTEXT_L = 'Inward Document'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '9'.
  wa_fc-fieldname = 'BILL_NUM'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Bill Number'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'BILL_NUM'.
**  WFCAT-SELTEXT_L = 'Bill Number'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '10'.
  wa_fc-fieldname = 'BILL_DATE'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Bill Date'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'BILL_DATE'.
**  WFCAT-SELTEXT_L = 'Bill Date'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '11'.
  wa_fc-fieldname = 'GRPO_NO'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'GRPO No'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'GRPO_NO'.
**  WFCAT-SELTEXT_L = 'GRPO No'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '12'.
  wa_fc-fieldname = 'MATKL'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Material Group'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'MATKL'.
**  WFCAT-SELTEXT_L = 'Material Group'.
***  WFCAT-TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.

  wa_fc-col_pos   = '13'.
  wa_fc-fieldname = 'AMOUNT'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Amount'.
  wa_fc-do_sum    = 'X' .
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


**  WFCAT-FIELDNAME = 'AMOUNT'.
**  WFCAT-SELTEXT_S = 'Amount'.
***  WFCAT-TABNAME  = 'GT_FINAL2'.
***  WFCAT-REF_FIELDNAME  = 'NETWR'.
**  WFCAT-DO_SUM       = 'X'.
**
***  ENDIF.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.
**

  wa_fc-col_pos   = '14'.
  wa_fc-fieldname = 'CURRENCY'.
  wa_fc-tabname   = 'GT_FINAL2'.
  wa_fc-scrtext_l = 'Currency'.
*  WA_FC-CHECKBOX = 'X' .
*  WA_FC-EDIT = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

**  WFCAT-FIELDNAME = 'CURRENCY'.
**  WFCAT-SELTEXT_L = 'Currency'.
***  WFCAT-REF_TABNAME = 'GT_FINAL2'.
**  APPEND WFCAT TO TFCAT.
**  CLEAR WFCAT.



*** Create Object for event_receiver.
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
        is_layout                     = lw_layo
      CHANGING
        it_outtab                     = gt_final2[] "it_item[]
        it_fieldcatalog               = lt_fieldcat
*       IT_SORT                       = IT_SORT[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
    ENDIF.

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

*** Start Of Changes by Suri : 13.01.2019
*** Restricting the Options in Report
  APPEND  cl_gui_alv_grid=>mc_fc_call_xml_export TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_call_xxl TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_mb_export TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_expcrdata TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_data_save TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_expcrtempl TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_view_excel TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_views TO lt_exclude.
  APPEND  cl_gui_alv_grid=>mc_fc_print_prev TO lt_exclude.
*** End Of Changes by Suri : 13.01.2019
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
*  BREAK BREDDY .


*  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
*  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
*    IMPORTING
*      E_GRID = REF_GRID.
*  IF REF_GRID IS NOT INITIAL.
*    CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).
*  ENDIF.

  ok_code = sy-ucomm.
  REFRESH gt_ftable.

  CASE ok_code.
    WHEN 'BACK' .
      CLEAR lv_sum.
      LEAVE TO SCREEN 0.
    WHEN '&CPRINT'.
      DATA : form_name TYPE rs38l_fnam.
      DATA : form_name1 TYPE rs38l_fnam.
      DATA : lv_slno TYPE i .
      DATA : lv_total TYPE zbprei_pt.
      DATA : lt_inw_hdr TYPE TABLE OF zinw_t_hdr.

      REFRESH : lt_inw_hdr.
      LOOP AT gt_final2 INTO gs_final2 WHERE sel = 'X'.
        MOVE-CORRESPONDING  gs_final2 TO gs_ftable .
        CLEAR gs_ftable-slno .
        lv_slno = lv_slno + 1 .
        gs_ftable-slno = lv_slno .
        lv_total = gs_ftable-amount + lv_total.
*        APPEND VALUE #( INWD_DOC = GS_FTABLE-INWD_DOC QR_CODE = GS_FTABLE-QR_CODE CFO_PRINT_BY = SY-UNAME
*                        CFO_PRINT_S = C_X CFO_PRINT_ON = SY-DATUM CFO_PRINT_ON_T  = SY-UZEIT ) TO LT_INW_HDR.

        APPEND gs_ftable TO gt_ftable.
        CLEAR gs_ftable .
      ENDLOOP.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZCFO_DIARY_FORM'
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

      IF sy-ucomm = 'PRNT'.
        LOOP AT gt_ftable ASSIGNING FIELD-SYMBOL(<ls_flt>).
          UPDATE zinw_t_hdr  SET  cfo_print_by = sy-uname cfo_print_s     = c_x
                                  cfo_print_on = sy-datum cfo_print_on_t  = sy-uzeit
                                  WHERE qr_code = <ls_flt>-qr_code AND inwd_doc = <ls_flt>-inwd_doc.
        ENDLOOP.
        COMMIT WORK.
      ENDIF.
  ENDCASE.
  CLEAR : lv_total .
  CLEAR : ok_code , sy-ucomm .

ENDMODULE.
