*&---------------------------------------------------------------------*
*& Include          ZFI_VACCOUNT_DP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select .

  DATA(lv_gsber) = s_gsber-low.

  SELECT SINGLE gtext FROM tgsbt INTO wa_header-text WHERE gsber = lv_gsber AND spras = sy-langu.

  SELECT  bukrs
          belnr
          gjahr
          bldat
          awkey
          bktxt
          xblnr
          FROM bkpf INTO TABLE it_bkpf WHERE belnr IN s_belnr AND
                                                   bukrs IN s_bukrs AND
                                                   gjahr IN s_gjahr AND
  bldat IN s_bldat.
  READ TABLE it_bkpf INTO wa_bkpf INDEX 1.
  wa_header-bldat = wa_bkpf-bldat.


  IF it_bkpf IS NOT INITIAL.
    SELECT  bukrs
            belnr
            gjahr
            buzei
            augdt
            koart
            lifnr
            bschl
            shkzg
            dmbtr
            h_budat
            zfbdt
            sgtxt
            gsber
      FROM bseg INTO TABLE it_bseg FOR ALL ENTRIES IN it_bkpf WHERE lifnr IN s_lifnr AND
                                                                                bukrs = it_bkpf-bukrs AND
                                                                                belnr = it_bkpf-belnr AND
    gjahr = it_bkpf-gjahr AND koart = 'K' AND augbl EQ space AND umskz EQ space AND gsber IN s_gsber.

*** Start of Changes By Suri : 24.03.2020 : 10.14.00
    SELECT invoice bill_num debit_note INTO TABLE lt_inw_hdr FROM zinw_t_hdr FOR ALL ENTRIES IN it_bkpf WHERE invoice = it_bkpf-awkey+0(10) OR debit_note = it_bkpf-awkey+0(10) AND inv_gjahr = it_bkpf-gjahr.
*** End of Changes By Suri : 24.03.2020 : 10.14.00
  ENDIF.
  IF it_bseg IS NOT INITIAL.
    SELECT  lifnr
            werks
            adrnr
            psohs
            name1
            stras
            ort01
    pstlz FROM lfa1 INTO TABLE it_lfa1 FOR ALL ENTRIES IN it_bseg WHERE lifnr = it_bseg-lifnr.

    SELECT bukrs
           butxt
           ort01
    adrnr FROM t001 INTO TABLE it_t001 FOR ALL ENTRIES IN it_bseg WHERE bukrs = it_bseg-bukrs.

  ENDIF.

  IF it_lfa1 IS NOT INITIAL.
    SELECT addrnumber
           name1
           house_num1
           street
           city1
    post_code1 FROM adrc INTO TABLE it_adrc FOR ALL ENTRIES IN it_lfa1 WHERE addrnumber = it_lfa1-adrnr.
  ENDIF.

*SELECT WERKS
*       ADRNR
*       NAME1
*       STRAS
*       ORT01
*       PSTLZ FROM T001W INTO TABLE IT_T001W FOR ALL ENTRIES IN IT_LFA1 WHERE WERKS = IT_LFA1-WERKS.

  IF it_t001 IS NOT INITIAL.
    SELECT addrnumber
           name1
           house_num1
           street
           city1
    post_code1 FROM adrc INTO TABLE it_adrc_p FOR ALL ENTRIES IN it_t001 WHERE addrnumber = it_t001-adrnr.
  ENDIF.
*  ENDIF.
*SORT IT_BKPF BY BLDAT.
*SORT IT_BSEG BY H_BUDAT ZFBDT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM loop .
  FIELD-SYMBOLS : <ls_inw_hdr> TYPE ty_inw_hdr.

  SORT it_bseg BY h_budat zfbdt.


  LOOP AT it_bseg INTO wa_bseg. "WHERE WA_BSEG-KOART = 'K'.            " AND SHKZG = 'H'.

    wa_item-bukrs   = wa_bseg-bukrs .
    wa_item-belnr   = wa_bseg-belnr .
    wa_item-gjahr   = wa_bseg-gjahr .
    wa_item-buzei   = wa_bseg-buzei .
    wa_item-augdt   = wa_bseg-augdt .

    wa_item-koart   = wa_bseg-koart .
    wa_header-lifnr = wa_bseg-lifnr .
    wa_item-lifnr   = wa_bseg-lifnr .
    wa_item-bschl   = wa_bseg-bschl .
    IF wa_bseg-shkzg = 'H'.
      wa_item-credit   = wa_bseg-dmbtr .

    ELSEIF wa_bseg-shkzg = 'S'.
      wa_item-debit   = wa_bseg-dmbtr .

    ENDIF.
    IF wa_item-credit IS NOT INITIAL.
      wa_item-koart = 'PURCHASE'.
    ENDIF.
    IF wa_item-debit IS NOT INITIAL.
      wa_item-koart = 'DEBIT NOTE'.
    ENDIF.
    wa_item-h_budat   = wa_bseg-h_budat.
    wa_header-h_budat = wa_bseg-h_budat.
    wa_header-gsber   = wa_bseg-gsber.
    wa_header-zfbdt   = wa_bseg-zfbdt .
*  WA_HEADER-ZFBDT_M = WA_BSEG-ZFBDT - 120.

    READ TABLE it_bkpf INTO wa_bkpf WITH KEY  bukrs = wa_bseg-bukrs
                                               belnr = wa_bseg-belnr
                                               gjahr = wa_bseg-gjahr.
    IF sy-subrc = 0.
      wa_item-awkey        = wa_bkpf-awkey.
      wa_item-bldat        = wa_bkpf-bldat.
      wa_header-bldat_low  = wa_bkpf-bldat.
      wa_header-bldat_high = wa_bkpf-bldat.

      IF wa_item-sgtxt IS INITIAL.
        wa_item-sgtxt = wa_bkpf-bktxt.
      ENDIF.

*** Start of Changes By Suri : 24.03.2020 : 10.14.00
*** For Text in Perticulers
      IF wa_item-sgtxt IS INITIAL.
***     Invoice : Vendor Bill Number from Inward Doc
        READ TABLE lt_inw_hdr ASSIGNING <ls_inw_hdr> WITH KEY invoice = wa_bkpf-awkey+0(10).
        IF sy-subrc IS INITIAL.
          wa_item-sgtxt = <ls_inw_hdr>-bill_num.
        ELSE.
***       Debit Note : Vendor Bill Number from Inward Doc
          READ TABLE lt_inw_hdr ASSIGNING <ls_inw_hdr> WITH KEY debit_note = wa_bkpf-awkey+0(10).
          IF sy-subrc IS INITIAL.
            wa_item-sgtxt = <ls_inw_hdr>-bill_num.
          ELSEIF wa_bkpf-xblnr IS NOT INITIAL.
***        Returns : Vendor Bill Number
            wa_item-sgtxt = wa_bkpf-xblnr.
          ENDIF.
        ENDIF.
      ENDIF.
*** End of Changes By Suri : 24.03.2020 : 10.14.00

* WA_HEADER-BLDAT_M = WA_BKPF-BLDAT - 7.
* WA_HEADER-BLDAT = WA_BKPF-BLDAT.


    ENDIF.

    IF wa_item-sgtxt IS INITIAL.
      wa_item-sgtxt = wa_bseg-sgtxt .
    ENDIF.

    READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_bseg-lifnr.
    IF sy-subrc = 0.
*WA_HEADER-LIFNR  = WA_LFA1-LIFNR .
      wa_header-werks  = wa_lfa1-werks .
      wa_header-adrnr  = wa_lfa1-adrnr  .
      wa_header-psohs  = wa_lfa1-psohs  .
      wa_header-name1  = wa_lfa1-name1  .
      wa_header-stras  = wa_lfa1-stras  .
      wa_header-ort01  = wa_lfa1-ort01  .
      wa_header-pstlz  = wa_lfa1-pstlz  .
    ENDIF.

    READ TABLE it_adrc INTO wa_adrc WITH KEY addrnumber = wa_lfa1-adrnr.
    IF sy-subrc = 0.
      wa_header-vname1       = wa_adrc-name1       .
      wa_header-vhouse_num1  = wa_adrc-house_num1  .
      wa_header-vstreet      = wa_adrc-street      .
      wa_header-vcity1       = wa_adrc-city1       .
      wa_header-vpost_code1  = wa_adrc-post_code1  .
    ENDIF.

    READ TABLE it_t001 INTO wa_t001 WITH KEY bukrs = wa_bseg-bukrs.
    IF sy-subrc = 0.
      wa_header-bukrs = wa_t001-bukrs  .
      wa_header-butxt = wa_t001-butxt  .
      wa_header-ort01 = wa_t001-ort01  .
      wa_header-adrnr = wa_t001-adrnr  .
    ENDIF.

*READ TABLE IT_T001W INTO WA_T001W WITH KEY WERKS = WA_LFA1-WERKS.
*IF SY-SUBRC = 0.
*WA_HEADER-WERKS = WA_T001W-WERKS.
*WA_HEADER-ADRNR = WA_T001W-ADRNR.
*WA_HEADER-NAME1 = WA_T001W-NAME1.
*WA_HEADER-STRAS = WA_T001W-STRAS.
*WA_HEADER-ORT01 = WA_T001W-ORT01.
*WA_HEADER-PSTLZ = WA_T001W-PSTLZ.
*ENDIF.

    READ TABLE it_adrc_p INTO wa_adrc_p WITH KEY addrnumber = wa_t001-adrnr.
    IF sy-subrc = 0.
*WA_HEADER-ADDRNUMBER = WA_ADRC_P-ADDRNUMBER.
      wa_header-name1      = wa_adrc_p-name1     .
      wa_header-house_num1 = wa_adrc_p-house_num1.
      wa_header-street     = wa_adrc_p-street    .
      wa_header-city1      = wa_adrc_p-city1     .
      wa_header-post_code1 = wa_adrc_p-post_code1.
    ENDIF.


    credit_tot = credit_tot + wa_item-credit.
    wa_item-credit_tot = credit_tot.

    debit_tot = debit_tot + wa_item-debit.
    wa_item-debit_tot = debit_tot.

    paid_amount = credit_tot - debit_tot.
    wa_item-paid_amount = paid_amount.

    total = paid_amount + debit_tot.
    wa_item-total = total.

    total1 = credit_tot + 00 .
    wa_item-total1 = total1.


    APPEND wa_item TO it_item.
    CLEAR wa_item.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_cat .

  PERFORM get_fieldcat.
  wa_layout-box_fieldname = 'SEL'.
  wa_events-name = 'USER_COMMAND'.
  wa_events-form = 'USER_COMMAND'.
  APPEND wa_events TO it_events.

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
      t_outtab                 = it_item
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*ENDIF.

ENDFORM.

FORM gui_set USING p_extab TYPE slis_t_extab.

*- Pf status
  SET PF-STATUS 'ZSTANDARD'. "this is we copied
  "it is having all you want
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

  CONSTANTS: lc_lifnr   TYPE slis_fieldname VALUE 'LIFNR',
             lc_belnr   TYPE slis_fieldname VALUE 'BELNR',
             lc_budat   TYPE slis_fieldname VALUE 'H_BUDAT',
             lc_sgtxt   TYPE slis_fieldname VALUE 'SGTXT',
             lc_gsber   TYPE slis_fieldname VALUE 'GSBER',
             lc_koart   TYPE slis_fieldname VALUE 'KOART',
             lc_bldat   TYPE slis_fieldname VALUE 'BLDAT',
             lc_debit   TYPE slis_fieldname VALUE 'DEBIT',
             lc_credit  TYPE slis_fieldname VALUE 'CREDIT',
             lc_tabname TYPE slis_tabname   VALUE 'IT_SELDATA'.

  PERFORM get_line_fieldcat USING  'SEL'      lc_tabname 'SELECT' 2.
  PERFORM get_line_fieldcat USING  lc_lifnr   lc_tabname 'Vendor' 12.
  PERFORM get_line_fieldcat USING  lc_budat   lc_tabname 'Date' 25.
  PERFORM get_line_fieldcat USING  lc_sgtxt   lc_tabname 'Particulars' 10.
  PERFORM get_line_fieldcat USING  lc_koart   lc_tabname 'Voucher Type' 35.
  PERFORM get_line_fieldcat USING  lc_belnr   lc_tabname 'Document No' 15.
  PERFORM get_line_fieldcat USING  lc_bldat   lc_tabname 'Bill Date' 25.
  PERFORM get_line_fieldcat USING  lc_debit   lc_tabname 'Debit' 10.
  PERFORM get_line_fieldcat USING  lc_credit  lc_tabname 'Credit' 10.


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

  IF p_field = 'SEL'.
    wa_fieldcat-checkbox = 'X'.
    wa_fieldcat-edit = 'X'.
  ENDIF.

  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

ENDFORM.

FORM top-of-page..

  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        lv_name1      TYPE name1,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        lv_top(255)   TYPE c.

  wa_header-typ  = 'H'.
  wa_header-info = 'Super Saravana Stores( Payment Summary Report ) '.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Date: '.

  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.



  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
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

    DATA(lt_item) = it_item.

    DELETE lt_item WHERE sel IS INITIAL.

    LOOP AT lt_item INTO DATA(ls_item).

      wa_header-credit_tot  = wa_header-credit_tot + ls_item-credit.
      wa_header-debit_tot   = wa_header-debit_tot + ls_item-debit.
      wa_header-paid_amount = wa_header-credit_tot - wa_header-debit_tot.
      wa_header-total       = wa_header-paid_amount + wa_header-debit_tot.
      wa_header-total1      = wa_header-credit_tot + 00 .

    ENDLOOP.

    DATA: lv_num   TYPE pc207-betrg,
          amt(200) TYPE c.

    lv_num =  wa_header-paid_amount.

    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = lv_num
      IMPORTING
        amt_in_words       = amt
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        input_string  = amt
*       SEPARATORS    = ' -.,;:'
      IMPORTING
        output_string = amt.

    amt = amt && 'Only'.

****    DATA:control TYPE ssfctrlop.
****    control-no_open  = 'X'.
****    control-preview  = 'X'.
****    control-no_close = 'X'.
****
****    CALL FUNCTION 'SSF_OPEN'
****      EXPORTING
*****       ARCHIVE_PARAMETERS =
****        user_settings      = 'X'
*****       MAIL_SENDER        =
*****       MAIL_RECIPIENT     =
*****       MAIL_APPL_OBJ      =
*****       OUTPUT_OPTIONS     =
****        control_parameters = control
*****   IMPORTING
*****       JOB_OUTPUT_OPTIONS =
****      EXCEPTIONS
****        formatting_error   = 1
****        internal_error     = 2
****        send_error         = 3
****        user_canceled      = 4
****        OTHERS             = 5.
****
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZFI_VACCOUNT_FORM'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = f_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.


    IF sy-subrc <> 0.
*   error handling
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
****
****    DATA(lt_item) = it_item.
****    LOOP AT it_item INTO DATA(lw_item) WHERE sel = 'X'.
****
****      READ TABLE lt_item INTO DATA(ls_item1) WITH KEY belnr = lw_item-belnr.
****      IF sy-subrc = 0.
****
****        ls_item-lifnr   = ls_item1-lifnr  .
****        ls_item-belnr   = ls_item1-belnr  .
****        ls_item-h_budat = ls_item1-h_budat.
****        ls_item-sgtxt   = ls_item1-sgtxt  .
****        ls_item-koart       = ls_item1-koart  .
****        ls_item-bldat       = ls_item1-bldat  .
****        ls_item-debit       = ls_item1-debit  .
****        ls_item-credit      = ls_item1-credit .
****        ls_item-credit_tot  = ls_item1-credit_tot .
****        ls_item-debit_tot   = ls_item1-debit_tot  .
****        ls_item-total       = ls_item1-total      .
****        ls_item-total1      = ls_item1-total1     .
****        ls_item-paid_amount = ls_item1-paid_amount.
****
****
****
****
****
****
****
    CALL FUNCTION f_name                "'/1BCDWB/SF00000036'
      EXPORTING
*       ARCHIVE_INDEX    =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
*       control_parameters = contro
*       MAIL_APPL_OBJ    =
*       MAIL_RECIPIENT   =
*       MAIL_SENDER      =
*       OUTPUT_OPTIONS   =
*       USER_SETTINGS    = 'X'
        wa_header        = wa_header
        amt              = amt
*       ls_item          = ls_item
*       BLDAT_LOW        = BLDAT_LOW
*       BLDAT_HIGH       = BLDAT_HIGH
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO  =
*       JOB_OUTPUT_OPTIONS =
      TABLES
        it_item          = lt_item
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

****      ENDIF.
****
****    ENDLOOP.
****
****    CALL FUNCTION 'SSF_CLOSE'.





  ENDIF.


ENDFORM.
