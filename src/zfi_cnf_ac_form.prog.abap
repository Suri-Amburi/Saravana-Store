*&---------------------------------------------------------------------*
*& Include          ZFI_CNF_AC_FORM
*&---------------------------------------------------------------------*
CALL METHOD zcl_conf_acc=>get_posting_deatils
  EXPORTING
    i_company_code = p_bukrs                  " Company Code
    i_vendor       = p_lifnr                  " Account Number of Vendor or Creditor
    i_fiscal_year  = p_year                   " Fiscal Year
    i_posting_date = s_date[]                 " Posting Date
  IMPORTING
    es_header      = wa_header                " Header
    et_item        = it_final                 " Item
    et_return      = DATA(it_return).

**IF r_form = c_x.

  PERFORM form_display.

**ELSE.
***** Start of Changes by Suri : 19.05.2020
***** Report Display
**  PERFORM display.
***** End of Changes by Suri : 19.05.2020
**ENDIF.


FORM display.
*** Display Data
  DATA : lr_alv       TYPE REF TO cl_salv_table,
         lr_cols      TYPE REF TO cl_salv_columns,
         lr_col       TYPE REF TO cl_salv_column,
         lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings.

  DATA: lo_table   TYPE REF TO cl_salv_table,
        lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column_list.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = it_final ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).
*** Store
      TRY.
          lr_col = lr_cols->get_column( 'BELNR' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'BLDAT' ).
          lr_col->set_medium_text( 'Doc Date' ).

          lr_col = lr_cols->get_column( 'BUDAT' ).
          lr_col->set_medium_text( 'Posting Date' ).

          lr_col = lr_cols->get_column( 'XBLNR' ).
          lr_col->set_long_text( 'Reference' ).
          lr_col->set_medium_text( 'Reference' ).

          lr_col = lr_cols->get_column( 'GSBER' ).
          lr_col->set_long_text( 'Business area Code' ).
          lr_col->set_medium_text( 'Business area Code' ).

          lr_col = lr_cols->get_column( 'GTEXT' ).
          lr_col->set_long_text( 'Business area Description' ).
          lr_col->set_medium_text( 'Business area Desc' ).

          lr_col = lr_cols->get_column( 'DEBIT' ).
          lr_col->set_long_text( 'Debit Amount' ).
          lr_col->set_medium_text( 'Debit Amount' ).
          lr_col->set_short_text( 'Debit' ).

          lr_col = lr_cols->get_column( 'CREDIT' ).
          lr_col->set_long_text( 'Credit Amount' ).
          lr_col->set_medium_text( 'Credit Amount' ).
          lr_col->set_short_text( 'Credit' ).

          lr_col = lr_cols->get_column( 'BAL' ).
          lr_col->set_long_text( 'Cumlative Balances' ).
          lr_col->set_medium_text( 'Cumlative Balances' ).
          lr_col->set_short_text( 'Cuml Bal' ).


        CATCH cx_salv_not_found.
      ENDTRY.
    CATCH cx_salv_msg.
  ENDTRY .

  lr_alv->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FORM_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM form_display .

  SELECT SINGLE adrnr FROM t001 INTO wa_header1-addrnumber WHERE bukrs = p_bukrs.
  SELECT SINGLE
    name1
    city1
    street
    str_suppl1
    str_suppl2
    str_suppl3
    house_num1
    region
    country
    FROM adrc INTO
    ( wa_header1-name1 , wa_header1-city1 , wa_header1-street , wa_header1-str_suppl1 , wa_header1-str_suppl2 , wa_header1-str_suppl3 ,
    wa_header1-house_num1 , wa_header1-region , wa_header1-country )
    WHERE  addrnumber = wa_header1-addrnumber.

  SELECT SINGLE bezei FROM t005u INTO wa_header1-bezei WHERE spras = sy-langu AND land1 = wa_header1-country AND bland = wa_header1-region.

  SELECT SINGLE adrnr FROM lfa1 INTO wa_header1-adrc_v WHERE lifnr = p_lifnr.
  SELECT SINGLE adrnr FROM t001 INTO wa_header1-adrc   WHERE bukrs = p_bukrs.

  IF s_date IS NOT INITIAL.
    wa_header1-from = s_date-low.
    wa_header1-to   = s_date-high.
    IF s_date-high IS INITIAL.
      wa_header1-from = s_date-low.
      wa_header1-to   = s_date-low.
    ENDIF.
  ELSE.
    DATA(year) = p_year + 1.
    wa_header1-from = p_year && '04' && '01'.
    wa_header1-to   = year && '03' && '31'.
  ENDIF.

  LOOP AT it_final INTO DATA(wa_final).

    wa_header1-tot_debit  = wa_header1-tot_debit  + wa_final-debit.
    wa_header1-tot_credit = wa_header1-tot_credit + wa_final-credit.
    wa_header1-tot_bal    = wa_header1-tot_bal    + wa_final-bal.
    wa_header1-rem        = wa_header1-tot_credit - wa_header1-tot_debit.

  ENDLOOP.

  DATA(it_debit)  = it_final.
  DATA(it_credit) = it_final.

  DELETE it_debit  WHERE debit  = 0.
  DELETE it_credit WHERE credit = 0.

  DESCRIBE TABLE it_debit  LINES lv_debit .
  DESCRIBE TABLE it_credit LINES lv_credit .

  IF lv_credit GT lv_debit.

    LOOP AT it_credit INTO DATA(w_credit).

      wa_final1-budat1 = w_credit-budat.
      wa_final1-xblnr1 = w_credit-xblnr.
      wa_final1-credit = w_credit-credit.

      READ TABLE it_debit INTO DATA(w_debit) INDEX sy-tabix.
      IF sy-subrc = 0.
        wa_final1-budat   = w_debit-budat.
        wa_final1-xblnr = w_debit-xblnr.
        wa_final1-debit = w_debit-debit.
      ENDIF.

      APPEND wa_final1 TO it_final1.
      CLEAR wa_final1.

    ENDLOOP.

  ELSEIF lv_debit GT lv_credit.

    LOOP AT it_debit INTO w_debit.

      wa_final1-budat = w_debit-budat.
      wa_final1-xblnr = w_debit-xblnr.
      wa_final1-debit = w_debit-debit.

      READ TABLE it_credit INTO w_credit INDEX sy-tabix.
      IF sy-subrc = 0.
        wa_final1-budat1 = w_credit-budat.
        wa_final1-xblnr1 = w_credit-xblnr.
        wa_final1-credit = w_credit-credit.
      ENDIF.

      APPEND wa_final1 TO it_final1.
      CLEAR wa_final1.

    ENDLOOP.

  ELSEIF lv_debit EQ lv_credit.

    LOOP AT it_debit INTO w_debit.

      wa_final1-budat = w_debit-budat.
      wa_final1-xblnr = w_debit-xblnr.
      wa_final1-debit = w_debit-debit.

      READ TABLE it_credit INTO w_credit INDEX sy-tabix.
      IF sy-subrc = 0.
        wa_final1-budat1 = w_credit-budat.
        wa_final1-xblnr1 = w_credit-xblnr.
        wa_final1-credit = w_credit-credit.
      ENDIF.

      APPEND wa_final1 TO it_final1.
      CLEAR wa_final1.

    ENDLOOP.

  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = 'ZCNF_AC'
*     VARIANT  = ' '
*     DIRECT_CALL              = ' '
    IMPORTING
      fm_name  = fm_name
* EXCEPTIONS
*     NO_FORM  = 1
*     NO_FUNCTION_MODULE       = 2
*     OTHERS   = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION fm_name
    EXPORTING
      wa_header  = wa_header
      wa_header1 = wa_header1
    TABLES
      it_final   = it_final
      it_final1  = it_final1
* EXCEPTIONS
*     FORMATTING_ERROR           = 1
*     INTERNAL_ERROR             = 2
*     SEND_ERROR = 3
*     USER_CANCELED              = 4
*     OTHERS     = 5
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
