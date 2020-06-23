*&---------------------------------------------------------------------*
*& Include          ZFI_IMBRS_R01_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
*  PERFORM get_dates.
  BREAK ppadhy.
  SELECT SINGLE bukrs    "Company Code
                hbkid    "Short Key for a House Bank
                hktid    "ID for account details
                bankn    "Bank account number
                hkont    "General Ledger Account
           INTO wa_t012k
           FROM t012k    "House Bank Accounts
          WHERE bukrs = p_bukrs
            AND hbkid = p_hbkid
            AND hktid = p_hktid.

  IF sy-subrc = 0.
    g_rbank = wa_t012k-hkont.
    CONDENSE g_rbank.

    SELECT SUM( dmbtr ) INTO lv_gl_credit FROM bsis WHERE bukrs = p_bukrs AND hkont = g_rbank AND shkzg = 'H' AND budat <= p_date.
    SELECT SUM( dmbtr ) INTO lv_gl_debit  FROM bsis WHERE bukrs = p_bukrs AND hkont = g_rbank AND shkzg = 'S' AND budat <= p_date.

    lv_tot_gl = lv_gl_credit - lv_gl_debit.

    SELECT SINGLE ukont FROM t042i INTO g_oubank WHERE zbukr = p_bukrs
                                                   AND hbkid = p_hbkid
                                                   AND hktid = p_hktid.

    IF g_oubank IS INITIAL.

      SELECT SINGLE ukont FROM t042iy INTO g_oubank WHERE zbukr = p_bukrs
                                                    AND hbkid = p_hbkid
                                                    AND hktid = p_hktid.
      CASE p_hbkid.
        WHEN 'ADC01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'ANB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'AXIS1'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'BAR01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'BBK01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'BOB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'BOB02'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'BOB03'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'BOI01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'CAN01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'CIT01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'DBS01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'DEB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'DNB02'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'HDFC1'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'ICI01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'IDBI1'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'INB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'IOB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'KKB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'LVB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'PNB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'RBL01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SBI01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SBI02'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SBM01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SBT01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SCB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SIB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'SYB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'UBI01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'UBI02'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'UBI03'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'UCB01'.
          g_oubank = wa_t012k-hkont + 1.
        WHEN 'YES01'.
          g_oubank = wa_t012k-hkont + 1.
      ENDCASE.

    ENDIF.

    CASE p_hbkid.
      WHEN 'ADC01'.
        g_inbank = g_oubank + 5.
      WHEN 'ANB01'.
        g_inbank = g_oubank + 5.
      WHEN 'AXIS1'.
        g_inbank = g_oubank + 5.
      WHEN 'BAR01'.
        g_inbank = g_oubank + 5.
      WHEN 'BBK01'.
        g_inbank = g_oubank + 5.
      WHEN 'BOB01'.
        g_inbank = g_oubank + 5.
      WHEN 'BOB02'.
        g_inbank = g_oubank + 5.
      WHEN 'BOB03'.
        g_inbank = g_oubank + 5.
      WHEN 'BOI01'.
        g_inbank = g_oubank + 5.
      WHEN 'CAN01'.
        g_inbank = g_oubank + 5.
      WHEN 'CIT01'.
        g_inbank = g_oubank + 5.
      WHEN 'DBS01'.
        g_inbank = g_oubank + 5.
      WHEN 'DEB01'.
        g_inbank = g_oubank + 5.
      WHEN 'DNB02'.
        g_inbank = g_oubank + 5.
      WHEN 'HDFC1'.
        g_inbank = g_oubank + 5.
      WHEN 'ICI01'.
        g_inbank = g_oubank + 5.
      WHEN 'IDBI1'.
        g_inbank = g_oubank + 5.
      WHEN 'INB01'.
        g_inbank = g_oubank + 5.
      WHEN 'IOB01'.
        g_inbank = g_oubank + 5.
      WHEN 'KKB01'.
        g_inbank = g_oubank + 5.
      WHEN 'LVB01'.
        g_inbank = g_oubank + 5.
      WHEN 'PNB01'.
        g_inbank = g_oubank + 5.
      WHEN 'RBL01'.
        g_inbank = g_oubank + 5.
      WHEN 'SBI01'.
        g_inbank = g_oubank + 5.
      WHEN 'SBI02'.
        g_inbank = g_oubank + 5.
      WHEN 'SBM01'.
        g_inbank = g_oubank + 5.
      WHEN 'SBT01'.
        g_inbank = g_oubank + 5.
      WHEN 'SCB01'.
        g_inbank = g_oubank + 5.
      WHEN 'SIB01'.
        g_inbank = g_oubank + 5.
      WHEN 'SYB01'.
        g_inbank = g_oubank + 5.
      WHEN 'UBI01'.
        g_inbank = g_oubank + 5.
      WHEN 'UBI02'.
        g_inbank = g_oubank + 5.
      WHEN 'UBI03'.
        g_inbank = g_oubank + 5.
      WHEN 'UCB01'.
        g_inbank = g_oubank + 5.
      WHEN 'YES01'.
        g_inbank = g_oubank + 5.
    ENDCASE.

    SELECT SINGLE text1    "House Bank Account Names - Description
             INTO g_text1
             FROM t012t    "House Bank Account Names
             WHERE spras = 'EN'
              AND bukrs = p_bukrs
              AND hbkid = p_hbkid
              AND hktid = wa_t012k-hktid.

  ENDIF.
  SELECT SINGLE ktopl
         FROM t001
         INTO g_ktopl
 WHERE bukrs = p_bukrs.
  IF sy-subrc = 0.
    SELECT ktopl
           saknr
           txt50
      INTO TABLE it_skat
      FROM skat
     WHERE spras = sy-langu
       AND ktopl = g_ktopl.
    IF sy-subrc = 0.
      SORT it_skat BY saknr.
      DELETE ADJACENT DUPLICATES FROM it_skat COMPARING saknr.
    ENDIF.
  ENDIF.
  PERFORM get_bsis  TABLES it_inbsis USING g_inbank.
  PERFORM get_bsis  TABLES it_oubsis USING g_oubank.
  PERFORM in_out_bsis .
  PERFORM get_payr.
  PERFORM get_name.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
  DATA: l_flag TYPE c.

  IF it_oubsis[] IS NOT INITIAL.
    SORT it_oubsis BY hkont belnr.
    CLEAR l_flag.
    LOOP AT it_oubsis INTO wa_bsis.
      wa_seldata-hkont  = wa_bsis-hkont.
      wa_seldata-belnr  = wa_bsis-belnr.
      wa_seldata-posdat =  wa_bsis-budat.
      wa_seldata-dmbtr  = wa_bsis-dmbtr.
      wa_seldata-gsber  = wa_bsis-gsber.
      wa_seldata-wrbtr  = wa_bsis-wrbtr.
      wa_seldata-waers  = wa_bsis-waers.

      READ TABLE it_payr INTO wa_payr WITH KEY vblnr = wa_bsis-belnr gjahr = wa_bsis-gjahr.
      IF sy-subrc = 0.
        wa_seldata-chect = wa_payr-chect.
      ENDIF.
      IF wa_bsis-shkzg = 'H'.
        wa_seldata-drcr = 'Cr.'.
        wa_seldata-descr = 'Outgoing Bank Account'.

        READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_bsis-belnr gjahr = wa_bsis-gjahr.
        IF sy-subrc = 0.
          wa_seldata-chect = wa_bkpf-xblnr.
          wa_seldata-bktxt = wa_bkpf-bktxt.
        ENDIF.

      ENDIF.
      IF wa_bsis-shkzg = 'S'.
        wa_seldata-drcr = 'Dr.'.
        wa_seldata-descr = 'Incoming Bank Account'.

        READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_bsis-belnr gjahr = wa_bsis-gjahr.
        IF sy-subrc = 0.
          wa_seldata-chect = wa_bkpf-xblnr.
          wa_seldata-bktxt = wa_bkpf-bktxt.
        ENDIF.

      ENDIF.
      READ TABLE it_bsegk INTO wa_bseg WITH KEY bukrs = wa_bsis-bukrs belnr = wa_bsis-belnr.
      IF sy-subrc = 0.
        READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_bseg-lifnr.
        wa_seldata-name = wa_lfa1-name1.
      ELSE.
        READ TABLE it_bsegd INTO wa_bseg WITH KEY bukrs = wa_bsis-bukrs belnr = wa_bsis-belnr.
        READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_bseg-kunnr.
        wa_seldata-name = wa_kna1-name1.
      ENDIF.

      IF wa_seldata-name IS INITIAL.
        READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_bsis-belnr gjahr = wa_bsis-gjahr blart = 'SA'.
        IF sy-subrc IS INITIAL.
          READ TABLE it_bseg_sa INTO wa_bseg_sa WITH KEY belnr = wa_bkpf-belnr gjahr = wa_bkpf-gjahr.
          IF sy-subrc IS INITIAL.
            READ TABLE it_skat INTO wa_skat WITH KEY saknr = wa_bseg_sa-hkont.
            IF sy-subrc IS INITIAL.
              wa_seldata-name = wa_skat-txt50.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND wa_seldata TO it_seldata.
      CLEAR: wa_seldata,
             wa_bsis,
             wa_bkpf,
             wa_payr,
             wa_bseg_sa,
             wa_skat.
      l_flag = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  IF it_seldata[] IS NOT INITIAL.
*DATA: IT_SAVE1 TYPE TABLE OF ZMBRS.
*    BREAK ppadhy.
    SELECT * FROM zmbrs INTO TABLE @DATA(it_save1) FOR ALL ENTRIES IN @it_seldata
      WHERE bukrs = @p_bukrs
       AND  hbkid = @p_hbkid
*       AND  monat = @p_monat
       AND  gjahr = @p_gjahr
       AND  posdat = @it_seldata-posdat
       AND  belnr = @it_seldata-belnr.

    LOOP AT it_save1 INTO DATA(wa_save1).

      READ TABLE it_seldata INTO wa_seldata WITH KEY belnr   = wa_save1-belnr.

      IF sy-subrc = 0.

        IF wa_save1-budat IS NOT INITIAL.
          wa_seldata-sel    = 'X'."wa_save1-sel   .
        ENDIF.
        wa_seldata-hkont  = wa_save1-hkont .
        wa_seldata-descr  = wa_save1-descr .
        wa_seldata-belnr  = wa_save1-belnr .
        wa_seldata-posdat = wa_save1-posdat.
        wa_seldata-gsber  = wa_save1-gsber .
        wa_seldata-name   = wa_save1-name  .
        wa_seldata-dmbtr  = wa_save1-dmbtr .
        wa_seldata-chect  = wa_save1-chect .
        wa_seldata-bktxt  = wa_save1-bktxt .
        wa_seldata-budat  = wa_save1-budat .
        wa_seldata-prctr  = wa_save1-prctr .
        wa_seldata-drcr   = wa_save1-drcr  .
        wa_seldata-wrbtr  = wa_save1-wrbtr .
        wa_seldata-waers  = wa_save1-waers .

        DELETE it_seldata WHERE belnr = wa_seldata-belnr AND budat IS INITIAL.

        APPEND wa_seldata TO it_seldata.
        CLEAR wa_seldata.
      ENDIF.
    ENDLOOP.

    SORT it_seldata BY hkont belnr.

    it_seltemp[] = it_seldata.
*    sort it_seldata by hkont.
    PERFORM get_fieldcat.
    wa_layout-box_fieldname = 'SEL'.
    wa_events-name = 'USER_COMMAND'.
    wa_events-form = 'USER_COMMAND'.
    APPEND wa_events TO it_events.

    CLEAR wa_sort.
    wa_sort-fieldname = 'HKONT'.
    wa_sort-up = 'X'.
    wa_sort-subtot = 'X'.
    APPEND wa_sort TO it_sort.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = sy-repid
        i_callback_pf_status_set = 'GUI_SET'
        is_layout                = wa_layout
        it_fieldcat              = it_fieldcat
        i_save                   = 'X'
        it_sort                  = it_sort
        it_events                = it_events
        i_callback_top_of_page   = 'TOP-OF-PAGE '
        i_callback_user_command  = 'USER_COMMAND'
      TABLES
        t_outtab                 = it_seldata
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form IN_OUT_BSIS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM in_out_bsis .
  LOOP AT it_inbsis INTO wa_bsis.
    wa_in_out = wa_bsis.
    APPEND wa_in_out TO it_in_out.
    CLEAR : wa_in_out,wa_bsis.
  ENDLOOP.

  LOOP AT it_oubsis INTO wa_bsis.
    wa_in_out = wa_bsis.
    APPEND wa_in_out TO it_in_out.
    CLEAR : wa_in_out,wa_bsis.
  ENDLOOP.

  REFRESH : it_oubsis.
  it_oubsis[] = it_in_out[].
  REFRESH : it_in_out.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PAYR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_payr .
  SELECT zbukr
         chect
         vblnr
         gjahr
         zaldt
    FROM payr
    INTO TABLE it_payr
     FOR ALL ENTRIES IN it_oubsis
   WHERE zbukr = it_oubsis-bukrs
     AND vblnr = it_oubsis-belnr
     AND voidr = space.
  IF sy-subrc = 0.
    SORT it_payr BY vblnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_name .
  IF NOT it_oubsis IS INITIAL.
    SELECT bukrs
           belnr
           gjahr
           koart
           shkzg
           hkont
           kunnr
           lifnr
      FROM bseg
      INTO TABLE it_bsegk
      FOR ALL ENTRIES IN it_oubsis
      WHERE bukrs = it_oubsis-bukrs
        AND belnr = it_oubsis-belnr
        AND gjahr = it_oubsis-gjahr
        AND koart = 'K'.

    SELECT bukrs
           belnr
           gjahr
           koart
           shkzg
           hkont
           kunnr
           lifnr
      FROM bseg
      INTO TABLE it_bsegd
      FOR ALL ENTRIES IN it_oubsis
      WHERE bukrs = it_oubsis-bukrs
        AND belnr = it_oubsis-belnr
        AND gjahr = it_oubsis-gjahr
        AND koart = 'D' .


    SELECT bukrs
           belnr
           gjahr
           blart
           xblnr
           bktxt
           budat
           monat
           FROM bkpf
           INTO TABLE it_bkpf
           FOR ALL ENTRIES IN it_oubsis
           WHERE bukrs = it_oubsis-bukrs
           AND belnr = it_oubsis-belnr
           AND gjahr = it_oubsis-gjahr.

  ENDIF.


  IF NOT it_bkpf IS INITIAL.
    SELECT bukrs
           belnr
           gjahr
           hkont
           INTO TABLE it_bseg_sa
           FROM bseg
           FOR ALL ENTRIES IN it_bkpf
           WHERE belnr = it_bkpf-belnr
           AND   gjahr = it_bkpf-gjahr.
  ENDIF.


  IF NOT it_bsegk IS INITIAL.
    SELECT lifnr
           name1
      FROM lfa1
      INTO TABLE it_lfa1
      FOR ALL ENTRIES IN it_bsegk
      WHERE lifnr = it_bsegk-lifnr.
  ENDIF.

  IF NOT it_bsegd IS INITIAL.
    SELECT kunnr
           name1
      FROM kna1
      INTO TABLE it_kna1
      FOR ALL ENTRIES IN it_bsegd
      WHERE kunnr = it_bsegd-kunnr.
  ENDIF.

  SORT it_bsegk BY bukrs belnr.
  SORT it_bsegd BY bukrs belnr.
  SORT it_lfa1 BY lifnr.
  SORT it_kna1 BY kunnr.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BSIS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_INBSIS
*&      --> G_INBANK
*&---------------------------------------------------------------------*
FORM get_bsis  TABLES  lp_bsis LIKE it_inbsis
               USING    lp_bank TYPE t012k-hkont.

  DATA : v_bukrs(8),
         v_hkont(12),
         v_budat(12),
         v_gjahr(4),
         v_gsber(4),
         curr_date(8),pre_date(8).
  DATA: t_where  TYPE TABLE OF rfc_db_opt WITH HEADER LINE,
        lv_where TYPE string,
        s_fields TYPE TABLE OF  ddshselopt WITH HEADER LINE.

  curr_date = v_budat. " p_budat.
  pre_date = curr_date+0(6).

  CONCATENATE p_gjahr  '0401' INTO pre_date.
  CONCATENATE ',' p_bukrs ',' INTO v_bukrs.
  REPLACE ALL OCCURRENCES OF ',' IN v_bukrs WITH ''''.
  CONCATENATE ',' p_gjahr ',' INTO v_gjahr.
  REPLACE ALL OCCURRENCES OF ',' IN v_gjahr WITH ''''.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lp_bank
    IMPORTING
      output = lp_bank.

  CONCATENATE ',' lp_bank ',' INTO v_hkont.
  REPLACE ALL OCCURRENCES OF ',' IN v_hkont WITH ''''.

**  CONCATENATE ',' g_tdate ',' INTO v_budat.
**  REPLACE ALL OCCURRENCES OF ',' IN v_budat WITH ''''.

  CONCATENATE ',' p_date ',' INTO v_budat.
  REPLACE ALL OCCURRENCES OF ',' IN v_budat WITH ''''.

  CONCATENATE 'bukrs' '=' v_bukrs 'AND' 'hkont' '=' v_hkont
              'AND' 'BUDAT' '<=' v_budat  INTO options-text SEPARATED BY space.
  APPEND options TO t_options.
  CLEAR options.


  fields-fieldname = 'BUKRS'.
  fields-length = '04'.
  fields-fieldtext = 'Company Code'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'HKONT'.
  fields-length = '10'.
  fields-fieldtext = 'General Ledger Account'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'GJAHR'.
  fields-length = '04'.
  fields-fieldtext = 'Fiscal Year'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'BELNR'.
  fields-length = '10'.
  fields-fieldtext = 'Accounting Document Number'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'BUDAT'.
  fields-length = '08'.
  fields-fieldtext = 'Posting Date in the Document'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'WAERS'.
  fields-length = '05'.
  fields-fieldtext = 'Currency Key'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'SHKZG'.
  fields-length = '01'.
  fields-fieldtext = 'Debit/Credit Indicator'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'GSBER'.
  fields-length = '4'.
  fields-fieldtext = 'Business Area'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'DMBTR'.
  fields-length = '13'.
  fields-fieldtext = 'Amount in Local Currency'.
  APPEND fields TO t_fields.
  CLEAR fields.

  fields-fieldname = 'WRBTR'.
  fields-length = '17'.
  fields-fieldtext = 'Amount in document currency'.
  APPEND fields TO t_fields.
  CLEAR fields.

*******************To read database tables. Here it will display only openitems from BSIS table
  CALL FUNCTION 'RFC_READ_TABLE'
    EXPORTING
      query_table = 'BSIS'
    TABLES
      options     = t_options
      fields      = t_fields
      data        = t_data.


  IF NOT t_data IS INITIAL.
    LOOP AT t_data INTO data.
      wa_bsis-bukrs = data+0(4).
      wa_bsis-hkont = data+4(10).
      wa_bsis-gjahr = data+14(4).
      wa_bsis-belnr = data+18(10).
      wa_bsis-budat = data+28(8).
      wa_bsis-waers = data+36(5).
      wa_bsis-shkzg = data+41(1).

      IF wa_bsis-shkzg = 'H' .
        wa_bsis-gsber = data+42(4).
        wa_bsis-dmbtr = data+46(23) * -1.                                          "DATA+46(13) * -1.
      ELSE.
        wa_bsis-gsber = data+42(4).
        wa_bsis-dmbtr = data+46(23).                                                    "DATA+46(13).
      ENDIF.
      wa_bsis-wrbtr = data+59(17).
*      IF P_GSBER IS NOT INITIAL.
*        IF WA_BSIS-GSBER = P_GSBER.
      APPEND wa_bsis TO lp_bsis.
*        ENDIF.
*      ELSE.
*        APPEND wa_bsis TO lp_bsis.
*      ENDIF.
      CLEAR wa_bsis.
    ENDLOOP.

**************************************************************************    DELETE LP_BSIS WHERE GJAHR <> P_GJAHR.
*   DELETE LP_BSIS WHERE budat NOT BETWEEN s_date-low AND s_date-high.
  ENDIF.

  CLEAR: t_options,
        t_fields,
        t_data.

*  BREAK ppadhy.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_dates .
  g_poper = p_monat.
  CALL FUNCTION 'G_POSTING_DATE_OF_PERIOD_GET'
    EXPORTING
      period              = g_poper
      variant             = 'V3'
      year                = p_gjahr
    IMPORTING
      from_date           = g_fdate
*     LAST_NORMAL_PERIOD  =
      to_date             = g_tdate
*     FROM_DATE_ORIG      =
    EXCEPTIONS
      period_not_defined  = 1
      variant_not_defined = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_fieldcat .
  CONSTANTS: lc_hkont   TYPE slis_fieldname VALUE 'HKONT',
             lc_descr   TYPE slis_fieldname VALUE 'DESCR',
             lc_belnr   TYPE slis_fieldname VALUE 'BELNR',
             lc_post    TYPE slis_fieldname VALUE 'POSDAT',
             lc_gsber   TYPE slis_fieldname VALUE 'GSBER',
*             lc_prctr   TYPE slis_fieldname VALUE 'PRCTR',
             lc_name    TYPE slis_fieldname VALUE 'NAME',
             lc_dmbtr   TYPE slis_fieldname VALUE 'DMBTR',
             lc_chect   TYPE slis_fieldname VALUE 'CHECT',
             lc_budat   TYPE slis_fieldname VALUE 'BUDAT',
             lc_drcr    TYPE slis_fieldname VALUE 'DRCR',
             lc_bktxt   TYPE slis_fieldname VALUE 'BKTXT',
             lc_tabname TYPE slis_tabname   VALUE 'IT_SELDATA'.

  PERFORM get_line_fieldcat USING  'SEL'     lc_tabname 'SELECT' 2.
  PERFORM get_line_fieldcat USING  lc_hkont  lc_tabname 'ACCOUNT NUMBER' 12.
  PERFORM get_line_fieldcat USING  lc_descr  lc_tabname 'DESCRIPTION' 20.
  PERFORM get_line_fieldcat USING  lc_belnr  lc_tabname 'DOCUMENT NUMBER' 12.
  PERFORM get_line_fieldcat USING  lc_post   lc_tabname 'POSTING DATE' 10.
*  PERFORM get_line_fieldcat USING  lc_gsber  lc_tabname 'BUSINESS AREA' 4.
  PERFORM get_line_fieldcat USING  lc_name   lc_tabname 'VENDOR / CUSTOMER' 35.
  PERFORM get_line_fieldcat USING  lc_dmbtr  lc_tabname 'AMOUNT' 15.
  PERFORM get_line_fieldcat USING  lc_chect  lc_tabname 'CHECK' 25.
  PERFORM get_line_fieldcat USING  lc_budat  lc_tabname 'VALUE DATE' 10.
*  PERFORM get_line_fieldcat USING  lc_prctr  lc_tabname 'PROFIT CENTER' 10.
  PERFORM get_line_fieldcat USING  lc_drcr   lc_tabname 'Dr/Cr' 3.
  PERFORM get_line_fieldcat USING  lc_bktxt   lc_tabname 'Header Doc' 25.

  PERFORM get_line_fieldcat USING  'WRBTR'   lc_tabname 'Amount in Document Currency' 17.
  PERFORM get_line_fieldcat USING  'WAERS'   lc_tabname 'Currency' 5.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LINE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LC_TABNAME
*&      --> P_
*&      --> P_2
*&---------------------------------------------------------------------*
FORM get_line_fieldcat  USING p_field   TYPE slis_fieldname
                              p_tabname TYPE slis_tabname
                              p_seltext TYPE slis_fieldcat_alv-seltext_l
                              p_outlen  TYPE slis_fieldcat_alv-outputlen.

  STATICS:  l_col_pos TYPE slis_fieldcat_alv-col_pos.
  ADD 1 TO l_col_pos.

  wa_fieldcat-col_pos        = l_col_pos.
  wa_fieldcat-fieldname      = p_field.
  wa_fieldcat-tabname        = p_tabname.
  wa_fieldcat-seltext_l      = p_seltext.
  wa_fieldcat-outputlen      = p_outlen.

  IF p_field = 'BUDAT'.
    wa_fieldcat-edit = 'X'.
************************test********
    wa_fieldcat-ref_fieldname = 'H_BUDAT'.
    wa_fieldcat-ref_tabname = 'BSEG' .
  ENDIF.

  IF p_field = 'SEL'.
    wa_fieldcat-checkbox = 'X'.
    wa_fieldcat-edit = 'X'.
  ENDIF.

*  IF p_field = 'PRCTR'.
*    wa_fieldcat-edit = 'X'.
*  ENDIF.


  IF p_field = 'DMBTR'.
    wa_fieldcat-do_sum = 'X'.
  ENDIF.

  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

ENDFORM.
FORM user_command USING r_ucomm LIKE sy-ucomm
                            rs_selfield TYPE slis_selfield.

  DATA: grid1 TYPE REF TO cl_gui_alv_grid.
  CALL FUNCTION 'HR_ALV_LIST_REFRESH'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
* EXPORTING
*   IR_SALV_FULLSCREEN_ADAPTER       =
    IMPORTING
*     ET_EXCLUDING                     =
*     E_REPID                          = grid1
*     E_CALLBACK_PROGRAM               =
*     E_CALLBACK_ROUTINE               =
      e_grid = grid1
*     ET_FIELDCAT_LVC                  =
*     ER_TRACE                         =
*     E_FLG_NO_HTML                    =
*     ES_LAYOUT_KKBLO                  =
*     ES_SEL_HIDE                      =
*     ET_EVENT_EXIT                    =
*     ER_FORM_TOL                      =
*     ER_FORM_EOL                      =
    .
  CALL METHOD grid1->check_changed_data.
  DATA: lc_text TYPE string.
  IF r_ucomm = '&PRS'.
*    BREAK ppadhy.
    READ TABLE it_seldata INTO wa_seldata WITH KEY sel = 'X'.
    IF sy-subrc = 0.
      IF wa_seldata-budat IS INITIAL .
        MESSAGE 'Value date should not be blank' TYPE 'E' .
      ENDIF .

      IF wa_seldata-budat > p_date.
        MESSAGE 'Value date should not be greater than reconciliation date' TYPE 'E' .
      ENDIF.

      CLEAR wa_seldata.
      LOOP AT it_seldata INTO wa_seldata WHERE sel = 'X'.
        CLEAR wa_bsis.

        READ TABLE it_inbsis INTO wa_bsis
                         WITH KEY bukrs = p_bukrs
                                  belnr = wa_seldata-belnr.
        IF sy-subrc = 0.
          IF wa_seldata-budat LT wa_bsis-budat.
            CONCATENATE 'Value date is lesser than posting date'
                         'for document' wa_seldata-belnr
                         INTO lc_text.
            MESSAGE lc_text TYPE 'E'.
          ENDIF.
        ENDIF.
        CLEAR wa_bsis.
        READ TABLE it_oubsis INTO wa_bsis
                         WITH KEY bukrs = p_bukrs
                                  belnr = wa_seldata-belnr.
        IF sy-subrc = 0.
          IF wa_seldata-budat LT wa_bsis-budat.
            CONCATENATE 'Value date is lesser than posting date'
                         'for document' wa_seldata-belnr
                         INTO lc_text.
            MESSAGE lc_text TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      PERFORM bdc_f04.
      PERFORM bdc_fchr.
      PERFORM display_log.
      LEAVE PROGRAM.
    ENDIF.
*      ENDIF.
  ELSEIF sy-ucomm = 'BACK' OR sy-ucomm = 'EXIT' OR sy-ucomm = 'CANCEL'.
    LEAVE TO SCREEN 0.
  ELSEIF r_ucomm = '&HLD'.
    PERFORM save_alv.
  ELSEIF r_ucomm = '&REF'.
    PERFORM refresh.
  ELSEIF r_ucomm = '&EXC'.
    PERFORM excel.
  ENDIF.
ENDFORM.                    "user_command
FORM gui_set USING p_extab TYPE slis_t_extab..              "#EC *
  "USING p_extab TYPE slis_t_extab.
*  SET PF-STATUS 'ZABC' .""'ZBRS'.
  SET PF-STATUS 'STANDARD' .""'ZBRS'.
ENDFORM. "PF_STATUS
*&---------------------------------------------------------------------*
*& Form BDC_F04
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bdc_f04 .
  DATA: l_agkon  TYPE bsis-hkont,
        l_newbs  TYPE rf05a-newbs,
        l_date   TYPE sy-datum,
        l_date1  TYPE char10,
        l_amount TYPE char15,
        l_date2  TYPE char10,
        lv_blart TYPE blart.
  DATA: v_prctr TYPE prctr.
*  l_date = wa_seldata-posdat . "lc_budat . "p_budat. """"changed by naveen
*  WRITE p_budat TO l_date1.
*  WRITE wa_seldata-posdat TO l_date1.
*  l_date1 = p_budat.    """"end of changes
  CLEAR wa_seldata.
  CLEAR l_date2.
  g_rbank = g_rbank.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = g_rbank
    IMPORTING
      output = g_rbank.
*  BREAK-POINT.
  LOOP AT it_seldata INTO wa_seldata WHERE sel = 'X'
                                     AND   budat <> 0 .

*    v_prctr = wa_seldata-prctr.
    """ changes

*      l_date = wa_seldata-BUDAT.
    WRITE wa_seldata-budat TO l_date1.
    PERFORM bdc_dynpro      USING 'SAPMF05A' '0122'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-NEWKO'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
*     BREAK-POINT.
    CLEAR:lv_blart,wa_bkpf.
    DATA: lv_date(10) TYPE c.
    DATA: lv_monat TYPE monat.
    READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_seldata-belnr.
    IF sy-subrc = 0.
      CONCATENATE  wa_bkpf-budat+6(2) '.'
                   wa_bkpf-budat+4(2) '.'
                   wa_bkpf-budat(4) INTO lv_date.

      lv_monat = wa_bkpf-monat.

    ENDIF.


    PERFORM bdc_field       USING 'BKPF-BLDAT'
                                   lv_date . "l_date1.
    PERFORM bdc_field       USING 'BKPF-BLART'
                                  'ZR'." lv_blart.
    PERFORM bdc_field       USING 'BKPF-BUKRS'
                                  p_bukrs.
    PERFORM bdc_field       USING 'BKPF-BUDAT'
                                  l_date1.
    PERFORM bdc_field       USING 'BKPF-MONAT'
                                  lv_monat.
    PERFORM bdc_field       USING 'BKPF-WAERS'
                                  wa_seldata-waers.
    PERFORM bdc_field       USING 'FS006-DOCID'
                                  '*'.

    CLEAR wa_bsis.
    CLEAR l_newbs.
    READ TABLE it_inbsis INTO wa_bsis WITH KEY belnr = wa_seldata-belnr.
    IF sy-subrc = 0.
      IF wa_bsis-shkzg = 'H'.
        l_newbs = '50'.
      ELSE.
        l_newbs = '40'.
      ENDIF.
      l_agkon = wa_bsis-hkont.
    ENDIF.
    CLEAR wa_bsis.
    READ TABLE it_oubsis INTO wa_bsis WITH KEY belnr = wa_seldata-belnr.
    IF sy-subrc = 0.
      IF wa_bsis-shkzg = 'H'.
        l_newbs = '50'.
      ELSE.
        l_newbs = '40'.
      ENDIF.
      l_agkon = wa_bsis-hkont.
    ENDIF.

    PERFORM bdc_field       USING 'RF05A-NEWBS'
                                  l_newbs.
    PERFORM bdc_field       USING 'RF05A-NEWKO'
                                  g_rbank.

    PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-WRBTR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=PA'.
    IF wa_seldata-waers <> 'INR'.
      wa_seldata-dmbtr = wa_seldata-wrbtr.
    ENDIF.

    IF wa_seldata-dmbtr LT 0.
      wa_seldata-dmbtr = wa_seldata-dmbtr * -1.
    ENDIF.
    WRITE wa_seldata-dmbtr TO l_amount.


    PERFORM bdc_field       USING 'BSEG-WRBTR'
                                  l_amount.

    WRITE wa_seldata-budat TO l_date2.

    PERFORM bdc_field       USING 'BSEG-VALUT'
                                    l_date2.

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'COBL-PRCTR'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=ENTE'.
**->  Begin Of Changes NCHOUDHURY  28.11.2016 10:59:25
*    PERFORM bdc_field       USING 'COBL-GSBER'
*                                      wa_seldata-gsber.
*    *->  End Of Changes NCHOUDHURY | 28.11.2016 10:59:25

*    PERFORM bdc_field       USING 'COBL-PRCTR'
*                                   v_prctr.


    PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-XPOS1(03)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF05A-AGBUK'
                                   p_bukrs.

    PERFORM bdc_field       USING 'RF05A-AGKON'
                                   l_agkon.
    PERFORM bdc_field       USING 'RF05A-AGKOA'
                                  'S'.
    PERFORM bdc_field       USING 'RF05A-XNOPS'
                                  'X'.
    PERFORM bdc_field       USING 'RF05A-XAUTS'
                                  'X'.
    PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
                                  ''.
    PERFORM bdc_field       USING 'RF05A-XPOS1(03)'
                                  'X'.
    PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF05A-SEL01(01)'
                                   wa_seldata-belnr.
    PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=PA'.
    PERFORM bdc_dynpro      USING 'SAPDF05X' '3100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BS'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-ABPOS'.
    PERFORM bdc_field       USING 'RF05A-ABPOS'
                                  '1'.
    PERFORM bdc_dynpro      USING 'SAPMF05A' '0700'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-NEWBS'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BU'.
*    BREAK-POINT.
    CALL TRANSACTION 'F-04' USING it_bdcdata
*                              MODE 'E'
                             MODE 'N'
                            UPDATE 'A'
                    MESSAGES INTO it_mess.
    COMMIT WORK.
    WAIT UP TO 1 SECONDS.

    CALL FUNCTION 'DEQUEUE_ALL'.


    PERFORM get_log USING l_agkon.
    DO.
*To check any lock object in that client
      CALL FUNCTION 'ENQUE_READ2'
        EXPORTING
          gclient = sy-mandt
*         GNAME   = ' '
*         GARG    = ' '
*         GUNAME  = SY-UNAME
* IMPORTING
*         NUMBER  =
*         SUBRC   =
        TABLES
          enq     = it_enq.
      IF it_enq IS NOT INITIAL.

* if any lock object found then check is it for the Entered Sales Order
*if found then give an error log
        CONCATENATE sy-mandt '1000' wa_seldata-hkont INTO w_garg.
        READ TABLE it_enq WITH KEY gname = 'SKB1'
                                   garg = w_garg INTO wa_enq.
        IF sy-subrc = 0.
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    CLEAR:w_garg.

    REFRESH it_bdcdata[].
    REFRESH it_mess[].
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_FCHR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bdc_fchr .
  DATA: l_date1  TYPE char10,
        v_hktid  TYPE payr-hktid,
        lv_blart TYPE blart.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = g_oubank
    IMPORTING
      output = g_oubank.

*  BREAK-POINT.
  LOOP AT it_seldata INTO wa_seldata WHERE sel = 'X'.
*                                      AND chect <> ''.
*    and DESCR+0(3) <> 'OUT'.


    IF wa_seldata-hkont = g_oubank AND wa_seldata-drcr = 'Cr.'.

*      SELECT SINGLE hktid INTO v_hktid  FROM t012k
*                               WHERE hbkid = p_hbkid AND
*                                     hkont = g_oubank.

      PERFORM bdc_dynpro      USING 'SAPMFCHK' '0650'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'BSEG-VALUT'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'PAYR-ZBUKR'
                                     p_bukrs.
      PERFORM bdc_field       USING 'PAYR-HBKID'
                                     p_hbkid.
      PERFORM bdc_field       USING 'PAYR-HKTID'
                                     p_hktid.
      CLEAR l_date1.
      WRITE wa_seldata-budat TO l_date1.
      PERFORM bdc_field       USING '*PAYR-BANCD'
                                     l_date1.
      PERFORM bdc_field       USING 'BSEG-VALUT'
                                     l_date1.

      PERFORM bdc_dynpro      USING 'SAPMFCHK' '0651'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    '*PAYR-BANCD(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING '*PAYR-CHECT(01)'
                                     wa_seldata-chect.
      PERFORM bdc_field       USING 'BSEG-VALUT(01)'
                                     l_date1.
      PERFORM bdc_field       USING '*PAYR-BANCD(01)'
                                     l_date1.
      PERFORM bdc_dynpro      USING 'SAPMFCHK' '0651'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    '*PAYR-CHECT(02)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=EINL'.
      PERFORM bdc_dynpro      USING 'SAPMFCHK' '0652'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'BKPF-BLART'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM bdc_field       USING 'BKPF-BUDAT'
                                     l_date1. " p_budat.
      CLEAR:lv_blart,wa_bkpf.
      READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_seldata-belnr.
      DATA: lv_date(10) TYPE c.
      CONCATENATE  wa_bkpf-budat+6(2) '.'
                   wa_bkpf-budat+4(2) '.'
                   wa_bkpf-budat(4) INTO lv_date.

      PERFORM bdc_field       USING 'BKPF-BLDAT'
                                     lv_date. "l_date1. "p_budat.
*      CLEAR:lv_blart,wa_bkpf.
*      READ TABLE it_bkpf INTO wa_bkpf WITH KEY belnr = wa_seldata-belnr.
*      lv_blart = wa_bkpf-blart.
      PERFORM bdc_field       USING 'BKPF-BLART'
                                     'ZR'. " lv_blart.
      PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=&F03'.
      PERFORM bdc_dynpro      USING 'SAPMFCHK' '0650'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'PAYR-ZBUKR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=EZUR'.
      PERFORM bdc_field       USING 'PAYR-ZBUKR'
                                     p_bukrs.
      PERFORM bdc_field       USING 'PAYR-HBKID' p_hbkid.
      "  'BI01'.
      PERFORM bdc_field       USING 'PAYR-HKTID' p_hktid.
      "  'BI01'.
      PERFORM bdc_field       USING '*PAYR-BANCD' l_date1.  " p_budat.  "Check encashment date
      PERFORM bdc_field       USING 'BSEG-VALUT' l_date1.

      CALL TRANSACTION 'FCHR' USING it_bdcdata
*                                  MODE 'E'
                                  MODE  'N'
                                UPDATE  'A'
                        MESSAGES INTO it_mess.
      COMMIT WORK AND WAIT.
      CALL FUNCTION 'DEQUEUE_ALL'.
      PERFORM get_log USING g_oubank.

      REFRESH it_bdcdata[].
      REFRESH it_mess[].
      CLEAR: v_hktid.

    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_log .
  PERFORM get_fieldcat1.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'GUI_SET'
*     is_layout                = wa_layout
      it_fieldcat              = it_fieldcat1
      i_save                   = 'X'
*     it_sort                  = it_sort
*     it_events                = it_events
    TABLES
      t_outtab                 = it_log
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM get_log USING lp_agkon.
  DATA: lv_msg TYPE string.
  CLEAR wa_mess.
  LOOP AT it_mess INTO wa_mess WHERE msgtyp = 'E' OR
                        msgtyp = 'S'.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_mess-msgid
        lang = sy-langu
        no   = wa_mess-msgnr
        v1   = wa_mess-msgv1
        v2   = wa_mess-msgv2
        v3   = wa_mess-msgv3
        v4   = wa_mess-msgv4
      IMPORTING
        msg  = lv_msg.
    wa_log-hkont = lp_agkon.
    wa_log-belnr = wa_seldata-belnr.
    wa_log-msg = lv_msg.

    APPEND wa_log TO it_log.
    CLEAR wa_log.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELDCAT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_fieldcat1 .
  CONSTANTS: lc_hkont   TYPE slis_fieldname VALUE 'HKONT',
             lc_belnr   TYPE slis_fieldname VALUE 'BELNR',
             lc_msg     TYPE slis_fieldname VALUE 'MSG',
             lc_tabname TYPE slis_tabname VALUE 'IT_LOG'.

  PERFORM get_line_fieldcat1 USING  lc_hkont  lc_tabname 'Account Number' 12.
  PERFORM get_line_fieldcat1 USING  lc_belnr  lc_tabname 'Document Number' 12.
  PERFORM get_line_fieldcat1 USING  lc_msg    lc_tabname 'Message' 100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LINE_FIELDCAT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LC_HKONT
*&      --> LC_TABNAME
*&      --> P_
*&      --> P_12
*&---------------------------------------------------------------------*
FORM get_line_fieldcat1  USING  p_field TYPE slis_fieldname
                              p_tabname TYPE slis_tabname
                              p_seltext TYPE slis_fieldcat_alv-seltext_l
                              p_outlen TYPE slis_fieldcat_alv-outputlen.

  STATICS:  l_col_pos TYPE slis_fieldcat_alv-col_pos.
  ADD 1 TO l_col_pos.

  wa_fieldcat-col_pos        = l_col_pos.
  wa_fieldcat-fieldname      = p_field.
  wa_fieldcat-tabname        = p_tabname.
  wa_fieldcat-seltext_l      = p_seltext.
  wa_fieldcat-outputlen      = p_outlen.
  APPEND wa_fieldcat TO it_fieldcat1.
  CLEAR wa_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_HOUSEBANK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_housebank .
  SELECT  bukrs    "Company Code
        hbkid    "Short Key for a House Bank
        hktid    "ID for account details
        bankn    "Bank account number
        hkont    "General Ledger Account
   INTO TABLE gt_t012k
   FROM t012k.    "House Bank Accounts
*  WHERE bukrs = p_bukrs.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'HBKID'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'P_HBKID'
      value_org   = 'S'
    TABLES
      value_tab   = gt_t012k.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ACCTID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_acctid .
  SELECT  bukrs    "Company Code
         hbkid    "Short Key for a House Bank
         hktid    "ID for account details
         bankn    "Bank account number
         hkont    "General Ledger Account
    INTO TABLE gt_t012k
    FROM t012k.    "House Bank Accounts
*  WHERE bukrs = p_bukrs.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'HKTID'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'P_HKTID'
      value_org   = 'S'
    TABLES
      value_tab   = gt_t012k.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_dynpro  USING program dynpro.
  CLEAR wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = 'X'.
  APPEND wa_bdcdata TO it_bdcdata.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_field  USING fnam fval.

  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fnam.
  wa_bdcdata-fval = fval.
  APPEND wa_bdcdata TO it_bdcdata.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_alv .

  BREAK ppadhy.

  LOOP AT it_seldata INTO DATA(w_seldata).

    READ TABLE it_seltemp INTO wa_seltemp WITH KEY belnr = w_seldata-belnr.
    IF sy-subrc = 0.

      IF w_seldata-budat IS INITIAL AND w_seldata-sel IS NOT INITIAL .

        MESSAGE 'Enter Value Date' TYPE 'E'.

      ENDIF.

      IF w_seldata-budat gt p_date.
        data(lv_msg) = 'Value date should not be greater than reconciliation date' && w_seldata-belnr.
        MESSAGE lv_msg TYPE 'E' .
      ENDIF.

      IF wa_seltemp-budat <> w_seldata-budat."( wa_seltemp-sel <> w_seldata-sel ) OR ( wa_seltemp-budat <> w_seldata-budat ).

        wa_save-mandt   = sy-mandt.
        wa_save-bukrs   = p_bukrs.
        wa_save-hbkid   = p_hbkid.
        wa_save-hktid   = p_hktid.
        wa_save-monat   = p_monat.
        wa_save-gjahr   = p_gjahr.
        wa_save-sel     = w_seldata-sel   ."'X'."wa_seltemp-sel   .
        wa_save-hkont   = w_seldata-hkont .
        wa_save-descr   = w_seldata-descr .
        wa_save-belnr   = w_seldata-belnr .
        wa_save-posdat  = w_seldata-posdat.
        wa_save-gsber   = w_seldata-gsber .
        wa_save-name    = w_seldata-name  .
        wa_save-dmbtr   = w_seldata-dmbtr .
        wa_save-chect   = w_seldata-chect .
        wa_save-bktxt   = w_seldata-bktxt .
        wa_save-budat   = w_seldata-budat .
        wa_save-prctr   = w_seldata-prctr .
        wa_save-drcr    = w_seldata-drcr  .
        wa_save-wrbtr   = w_seldata-wrbtr .
        wa_save-waers   = w_seldata-waers .
        wa_save-ERNAM   = SY-uname .
        wa_save-ERDAT   = SY-datum .

        APPEND wa_save TO it_save.
        CLEAR wa_save.

      ENDIF.

    ENDIF.

  ENDLOOP.
  MODIFY zmbrs FROM TABLE it_save[].


ENDFORM.

FORM top-of-page.

*  *ALV Header declarations
  PERFORM refresh.


ENDFORM.

FORM refresh.

  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        lv_name1      TYPE name1,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        lv_top(255)   TYPE c.

  wa_header-typ  = 'H'.
  wa_header-info = 'Sarvana Stores ( Tex )'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Date: '.

  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*  BREAK ppadhy.

  DATA(it_sel) = it_seldata.
  DATA(it_sel1) = it_seldata.
  DATA: lv_line(05) TYPE c.
  DATA: lv_line1(05) TYPE c.
  DATA: lv_amount TYPE bseg-dmbtr.
  DATA: lv_amount1 TYPE bseg-dmbtr.

  DELETE it_sel WHERE budat IS INITIAL .
  DELETE it_sel WHERE drcr NE 'Dr.'.
  DESCRIBE TABLE it_sel LINES lv_line.
  CONDENSE lv_line.

  LOOP AT it_sel INTO DATA(wa_sel).

    lv_amount = lv_amount + wa_sel-dmbtr.

  ENDLOOP.

  DELETE it_sel1 WHERE budat IS INITIAL .
  DELETE it_sel1 WHERE drcr NE 'Cr.'.
  DESCRIBE TABLE it_sel1 LINES lv_line1.
  CONDENSE lv_line1.

  LOOP AT it_sel1 INTO DATA(wa_sel1).

    lv_amount1 = lv_amount1 + wa_sel1-dmbtr.

  ENDLOOP.



  wa_header-typ  = 'S'.
  wa_header-key = 'Selected Debit Lines'.
  wa_header-info = lv_line.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Total Debit Amount'.
  wa_header-info = lv_amount.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Selected Credit Lines'.
  wa_header-info = lv_line1.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Total Credit Amount'.
  wa_header-info = lv_amount1.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Last Balance'.
  wa_header-info = lv_tot_gl .
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Ending Balance'.
  wa_header-info = p_amount.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.



  lv_diff = ( lv_tot_gl  - p_amount ) + ( lv_amount + lv_amount1 ).

  wa_header-typ  = 'S'.
  wa_header-key = 'Difference'.
  wa_header-info = lv_diff .
  APPEND wa_header TO t_header.
  CLEAR: wa_header.




  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel .
*  BREAK ppadhy.

  DATA(it_seldata1) = it_seldata.

  DELETE it_seldata1 WHERE budat IS INITIAL.

  LOOP AT it_seldata1 INTO DATA(wa_seldata1).

    wa_seldata1-sel = 'X'.

    MODIFY it_seldata1 FROM wa_seldata1 TRANSPORTING sel.

  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'GUI_SET'
      is_layout                = wa_layout
      it_fieldcat              = it_fieldcat
      i_save                   = 'X'
      it_sort                  = it_sort
      it_events                = it_events
      i_callback_top_of_page   = 'TOP-OF-PAGE '
      i_callback_user_command  = 'USER_COMMAND'
    TABLES
      t_outtab                 = it_seldata1
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
