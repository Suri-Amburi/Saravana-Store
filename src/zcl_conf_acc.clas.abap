class ZCL_CONF_ACC definition
  public
  final
  create public .

public section.

  types:
*** Header
    BEGIN OF ty_header,
        linfr   TYPE lifnr,
        name1   TYPE name1_gp,
        ope_bal TYPE dmbtr,
      END OF ty_header .
  types:
*** Item
    BEGIN OF ty_item,
        belnr  TYPE belnr_d,
        BLDAT  TYPE BLDAT,
        budat  TYPE budat,
        xblnr  TYPE xblnr,
        gsber  TYPE gsber,
        gtext  TYPE gtext,
        debit  TYPE dmbtr,
        credit TYPE dmbtr,
        bal    TYPE dmbtr,
      END OF ty_item .
  types:
*** Return
    BEGIN OF ty_return,
        msg_type(1),
        message     TYPE bapi_msg,
      END OF ty_return .
***  Tables
  types TS_HEADER type TY_HEADER .
  types:
    tt_item   TYPE TABLE OF ty_item .
  types:
    tt_return TYPE TABLE OF ty_return .
  types:
    tt_date TYPE RANGE OF budat .

  constants C_CREDIT type SHKZG value 'H' ##NO_TEXT.
  constants C_DEBIT type SHKZG value 'S' ##NO_TEXT.
  constants C_KOART type KOART value 'K' ##NO_TEXT.

  class-methods GET_POSTING_DEATILS
    importing
      !I_COMPANY_CODE type BUKRS optional
      !I_VENDOR type LIFNR optional
      !I_FISCAL_YEAR type GJAHR optional
      !I_POSTING_DATE type TT_DATE
    exporting
      !ES_HEADER type TS_HEADER
      !ET_ITEM type TT_ITEM
      !ET_RETURN type TT_RETURN .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CONF_ACC IMPLEMENTATION.


  METHOD get_posting_deatils.
    DATA: lv_credit   TYPE dmbtr,
          lv_debit    TYPE dmbtr,
          lv_open_bal TYPE dmbtr,
          r_date      TYPE RANGE OF budat,
          r_fyear     TYPE RANGE OF gjahr.
    FIELD-SYMBOLS  : <ls_item> TYPE ty_item.

    REFRESH : et_item , r_date.
    CLEAR : es_header.

**** Posting Date Supplied
*    IF i_from_posting_date > i_to_posting_date.
*      APPEND VALUE #( msg_type = 'E' message = 'From Date is greater then To Date' ) TO et_return.
*    ENDIF.
*    IF i_from_posting_date IS NOT INITIAL AND i_to_posting_date IS NOT INITIAL.
*      APPEND VALUE #( low = i_from_posting_date high = i_to_posting_date sign = 'I' option = 'BT' ) TO r_date.
*    ELSEIF i_from_posting_date IS NOT INITIAL.
*      APPEND VALUE #( low = i_from_posting_date sign = 'I' option = 'EQ' ) TO r_date.
*    ENDIF.

*** Fiscal Year
    IF i_fiscal_year IS NOT INITIAL.
      APPEND VALUE #( low = i_fiscal_year sign = 'I' option = 'EQ' ) TO r_fyear.
    ENDIF.

*** Get Data
    SELECT
      bseg~belnr,
      bseg~gsber,
      bseg~h_bldat,
      bseg~h_budat,
      bseg~lifnr,
      bseg~sgtxt,
      bseg~dmbtr,
      bseg~gjahr,
      bseg~bukrs,
      bseg~koart,
      bseg~shkzg,
      bkpf~xblnr,
      lfa1~name1,
      tgsbt~gtext
      INTO TABLE @DATA(lt_bseg)
      FROM bseg AS bseg
      INNER JOIN bkpf AS bkpf ON bkpf~belnr = bseg~belnr AND bkpf~bukrs = bseg~bukrs AND bkpf~gjahr = bseg~gjahr
      LEFT JOIN lfa1 AS lfa1 ON lfa1~lifnr = bseg~lifnr
      LEFT JOIN tgsbt AS tgsbt ON tgsbt~gsber = bseg~gsber AND tgsbt~spras = @sy-langu
      WHERE bseg~bukrs = @i_company_code AND bseg~lifnr = @i_vendor AND bseg~gjahr IN @r_fyear AND
            bseg~h_budat IN @i_posting_date AND bseg~koart = @c_koart.

    READ TABLE i_posting_date INTO DATA(w_date) INDEX 1.
    DATA(lv_date) = w_date-low.
    SELECT
      bsik~bukrs,
      bsik~lifnr,
      bsik~budat,
      bsik~gjahr,
      bsik~dmbtr,
      bsik~shkzg
      INTO TABLE @DATA(it_bsik)
      FROM bsik AS bsik
      WHERE bsik~bukrs = @i_company_code AND bsik~lifnr = @i_vendor AND bsik~gjahr IN @r_fyear AND bsik~budat <= @lv_date  .

    LOOP AT it_bsik ASSIGNING FIELD-SYMBOL(<ls_bsik>).
      IF <ls_bsik>-shkzg = c_debit.
        ADD <ls_bsik>-dmbtr TO lv_debit.
      ELSEIF <ls_bsik>-shkzg = c_credit.
        ADD <ls_bsik>-dmbtr TO lv_credit.
      ENDIF.
    ENDLOOP.
    lv_open_bal = lv_debit - lv_credit.

    IF lt_bseg IS NOT INITIAL.
***   For Opeining Balance
      SORT lt_bseg BY belnr bukrs gjahr.
*      LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>).
*        IF <ls_bseg>-shkzg = c_debit.
*          ADD <ls_bseg>-dmbtr TO lv_debit.
*        ELSEIF <ls_bseg>-shkzg = c_credit.
*          ADD <ls_bseg>-dmbtr TO lv_credit.
*        ENDIF.
*      ENDLOOP.
*      lv_open_bal = lv_debit - lv_credit.

      LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>).
        AT FIRST.
          es_header-linfr   = <ls_bseg>-lifnr.
          es_header-name1   = <ls_bseg>-name1.
          es_header-ope_bal = lv_open_bal.
        ENDAT.
        APPEND INITIAL LINE TO et_item ASSIGNING <ls_item>.
        <ls_item>-belnr = <ls_bseg>-belnr.
        <ls_item>-xblnr = <ls_bseg>-xblnr.
        <ls_item>-budat = <ls_bseg>-h_budat.
        <ls_item>-bldat = <ls_bseg>-h_bldat.
        <ls_item>-gsber = <ls_bseg>-gsber.
        <ls_item>-gtext = <ls_bseg>-gtext.

        IF <ls_bseg>-shkzg = c_debit.
          <ls_item>-debit =  <ls_bseg>-dmbtr.
          <ls_item>-bal = lv_open_bal = lv_open_bal - <ls_bseg>-dmbtr.
        ELSEIF <ls_bseg>-shkzg = c_credit.
          <ls_item>-credit =  <ls_bseg>-dmbtr.
          <ls_item>-bal = lv_open_bal = lv_open_bal + <ls_bseg>-dmbtr.
        ENDIF.
      ENDLOOP.
    ELSE.
      APPEND VALUE #( msg_type = 'E' message = 'No Data Found' ) TO et_return.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
