*&---------------------------------------------------------------------*
*& Include          ZFI_MIRO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA USING P_QR CHANGING GV_SUBRC.
  DATA :
    FISCALYEAR  TYPE  BAPI_INCINV_FLD-FISC_YEAR,
    HEADERDATA  TYPE  BAPI_INCINV_CREATE_HEADER,
    ITEMDATA    TYPE  TABLE OF BAPI_INCINV_CREATE_ITEM,
    LS_ITEMDATA TYPE  BAPI_INCINV_CREATE_ITEM,
    RETURN      TYPE  TABLE OF BAPIRET2,
    LV_DOC_ITEM TYPE RBLGP VALUE '000001',
    LS_STATUS   TYPE ZINW_T_STATUS,
    LV_AMOUNT   TYPE P DECIMALS 4,
    R_EBELN     TYPE RANGE OF EBELN.
  FIELD-SYMBOLS :
    <LS_RETURN> TYPE BAPIRET2.
**** Inward Item
  IF GS_HDR-MBLNR IS NOT INITIAL.
    SELECT * FROM ZINW_T_ITEM INTO TABLE @DATA(LT_ITEM) WHERE QR_CODE = @P_QR.
    SELECT MATDOC~MBLNR,
           MATDOC~MJAHR,
           MATDOC~ZEILE,
           MATDOC~MATNR,
           MATDOC~BWART,
           MATDOC~WAERS,
           MATDOC~DMBTR,
           MATDOC~BUKRS,
           MATDOC~EBELN,
           MATDOC~EBELP,
           MATDOC~MENGE,
           MATDOC~BSTME,
           EKPO~MWSKZ
           INTO TABLE @DATA(LT_MATDOC)
           FROM MATDOC AS MATDOC
           INNER JOIN EKPO AS EKPO ON EKPO~EBELN = MATDOC~EBELN AND EKPO~EBELP = MATDOC~EBELP
           WHERE MATDOC~MBLNR IN ( @GS_HDR-MBLNR, @GS_HDR-MBLNR_103 ) AND MATDOC~EBELN = @GS_HDR-EBELN AND MATDOC~RECORD_TYPE = @C_MDOC.

    IF LT_MATDOC IS NOT INITIAL.
*** Condtion Records
      SELECT * FROM A003 INTO TABLE GT_TAX_CODE FOR ALL ENTRIES IN LT_MATDOC WHERE MWSKZ = LT_MATDOC-MWSKZ.
      IF GT_TAX_CODE IS NOT INITIAL.
        SELECT * FROM KONP INTO TABLE GT_KONP FOR ALL ENTRIES IN GT_TAX_CODE WHERE KNUMH = GT_TAX_CODE-KNUMH.
      ENDIF.
    ENDIF.

    REFRESH : RETURN, ITEMDATA. CLEAR : HEADERDATA.
    BREAK SAMBURI.
***  Calculating Header Gross Amount
    DATA : LV_TAX_TOL TYPE P DECIMALS 5.
    DATA : LV_TAX TYPE P DECIMALS 5.
    DATA : LV_TOTAL TYPE P DECIMALS 5.
    LV_TOTAL = GS_HDR-PUR_TOTAL + GS_HDR-PACKING_CHARGE - GS_HDR-DISCOUNT.
    DATA(LT_MATDOC_T) = LT_MATDOC.
    SORT LT_MATDOC_T BY EBELN EBELP.
    DELETE ADJACENT DUPLICATES FROM LT_MATDOC_T COMPARING EBELN EBELP.
    DESCRIBE TABLE LT_MATDOC_T LINES data(lv_lines).
    LOOP AT LT_MATDOC_T ASSIGNING FIELD-SYMBOL(<LS_MATDOC>).
      READ TABLE GT_TAX_CODE ASSIGNING FIELD-SYMBOL(<LS_TAX_CODE>) WITH KEY MWSKZ = <LS_MATDOC>-MWSKZ.
      IF SY-SUBRC = 0.
        LOOP AT GT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP>) WHERE KNUMH = <LS_TAX_CODE>-KNUMH.
          LV_TAX = ( <LS_KONP>-KBETR * ( <LS_MATDOC>-DMBTR + ( GS_HDR-PACKING_CHARGE - GS_HDR-DISCOUNT ) / lv_lines ) ) / 1000.
          ADD LV_TAX TO LV_TAX_TOL.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    HEADERDATA-GROSS_AMOUNT = LV_TOTAL + LV_TAX_TOL.
***  Header Data in Incoming Invoice
    HEADERDATA-INVOICE_IND  = C_X.
    HEADERDATA-DOC_DATE     = HEADERDATA-PSTNG_DATE = HEADERDATA-BLINE_DATE = SY-DATUM.
    HEADERDATA-CALC_TAX_IND = C_X.
    HEADERDATA-REF_DOC_NO   = GS_HDR-INWD_DOC.
    HEADERDATA-DEL_COSTS    = GS_HDR-PACKING_CHARGE - GS_HDR-DISCOUNT.
    IF HEADERDATA-GROSS_AMOUNT IS INITIAL.
      HEADERDATA-GROSS_AMOUNT = GS_HDR-NET_AMT.
    ENDIF.
    HEADERDATA-SECCO = HEADERDATA-BUSINESS_PLACE  = HEADERDATA-BUS_AREA = C_1000.

    IF GS_HDR-MBLNR_103 IS NOT INITIAL.
*** For Local Purchase
*** Document Number of an Invoice Document
      LOOP AT LT_MATDOC ASSIGNING <LS_MATDOC> WHERE BWART = '109'.
        CLEAR : LS_ITEMDATA.
        HEADERDATA-COMP_CODE          = <LS_MATDOC>-BUKRS.
        HEADERDATA-CURRENCY           = <LS_MATDOC>-WAERS.
***     107 Movement
        READ TABLE LT_MATDOC ASSIGNING FIELD-SYMBOL(<LS_MATDOC_107>) WITH KEY BWART = '107' EBELN = <LS_MATDOC>-EBELN EBELP = <LS_MATDOC>-EBELP.
        IF SY-SUBRC = 0.
          LS_ITEMDATA-INVOICE_DOC_ITEM  = LV_DOC_ITEM.
          LS_ITEMDATA-PO_NUMBER         = <LS_MATDOC_107>-EBELN.
          LS_ITEMDATA-PO_ITEM           = <LS_MATDOC_107>-EBELP.
          LS_ITEMDATA-REF_DOC           = <LS_MATDOC_107>-MBLNR.
          LS_ITEMDATA-REF_DOC_YEAR      = <LS_MATDOC_107>-MJAHR.
          LS_ITEMDATA-REF_DOC_IT        = <LS_MATDOC_107>-ZEILE.
          LS_ITEMDATA-TAX_CODE          = <LS_MATDOC_107>-MWSKZ.
          LS_ITEMDATA-ITEM_AMOUNT       = <LS_MATDOC_107>-DMBTR.
          LS_ITEMDATA-QUANTITY          = <LS_MATDOC_107>-MENGE.
          LS_ITEMDATA-PO_UNIT           = <LS_MATDOC_107>-BSTME.
          LV_DOC_ITEM = LV_DOC_ITEM + 1.
***       Reverse
          BREAK SAMBURI.
          READ TABLE LT_MATDOC ASSIGNING FIELD-SYMBOL(<LS_MATDOC_108>) WITH KEY BWART = '108' EBELN = <LS_MATDOC>-EBELN EBELP = <LS_MATDOC>-EBELP.
          IF SY-SUBRC = 0.
            LS_ITEMDATA-ITEM_AMOUNT = LS_ITEMDATA-ITEM_AMOUNT - <LS_MATDOC_108>-DMBTR.
            LS_ITEMDATA-QUANTITY = LS_ITEMDATA-QUANTITY - <LS_MATDOC_108>-MENGE.
            READ TABLE LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY EBELN = <LS_MATDOC_108>-EBELN EBELP = <LS_MATDOC_108>-EBELP MATNR = <LS_MATDOC_108>-MATNR.
            IF SY-SUBRC = 0.
              LV_AMOUNT = <LS_MATDOC_108>-DMBTR + ( <LS_ITEM>-NETPR_GP / <LS_ITEM>-MENGE_P ) * <LS_MATDOC_108>-MENGE.
            ENDIF.
          ENDIF.
          HEADERDATA-GROSS_AMOUNT = HEADERDATA-GROSS_AMOUNT  - LV_AMOUNT.
          APPEND LS_ITEMDATA TO ITEMDATA.
          CLEAR:LS_ITEMDATA, LV_AMOUNT.
        ENDIF.
      ENDLOOP.

*** For the Items which are 109 not posted
      LOOP AT LT_MATDOC ASSIGNING <LS_MATDOC_108> WHERE BWART = '108'.
        READ TABLE ITEMDATA INTO LS_ITEMDATA WITH KEY PO_NUMBER = <LS_MATDOC_108>-EBELN PO_ITEM = <LS_MATDOC_108>-EBELP.
        IF SY-SUBRC <> 0.
          READ TABLE LT_ITEM ASSIGNING <LS_ITEM> WITH KEY EBELN = <LS_MATDOC_108>-EBELN EBELP = <LS_MATDOC_108>-EBELP MATNR = <LS_MATDOC_108>-MATNR.
          IF SY-SUBRC = 0.
            CLEAR : LV_AMOUNT.
            LV_AMOUNT = <LS_MATDOC_108>-DMBTR + ( <LS_ITEM>-NETPR_GP / <LS_ITEM>-MENGE_P ) * <LS_MATDOC_108>-MENGE.
            HEADERDATA-GROSS_AMOUNT = HEADERDATA-GROSS_AMOUNT  - LV_AMOUNT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
*** Document Number of an Invoice Document
      LOOP AT LT_MATDOC ASSIGNING <LS_MATDOC>.
        CLEAR : LS_ITEMDATA.
        HEADERDATA-COMP_CODE          = <LS_MATDOC>-BUKRS.
        HEADERDATA-CURRENCY           = <LS_MATDOC>-WAERS.

        LS_ITEMDATA-INVOICE_DOC_ITEM  = LV_DOC_ITEM.
        LS_ITEMDATA-PO_NUMBER         = <LS_MATDOC>-EBELN.
        LS_ITEMDATA-PO_ITEM           = <LS_MATDOC>-EBELP.
        LS_ITEMDATA-REF_DOC           = <LS_MATDOC>-MBLNR.
        LS_ITEMDATA-REF_DOC_YEAR      = <LS_MATDOC>-MJAHR.
        LS_ITEMDATA-REF_DOC_IT        = <LS_MATDOC>-ZEILE.
        LS_ITEMDATA-TAX_CODE          = <LS_MATDOC>-MWSKZ.
        LS_ITEMDATA-ITEM_AMOUNT       = <LS_MATDOC>-DMBTR.
        LS_ITEMDATA-QUANTITY          = <LS_MATDOC>-MENGE.
        LS_ITEMDATA-PO_UNIT           = <LS_MATDOC>-BSTME.
        LV_DOC_ITEM = LV_DOC_ITEM + 1.
        APPEND LS_ITEMDATA TO ITEMDATA.
      ENDLOOP.
    ENDIF.
*** MIRO Invoice Post
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        HEADERDATA       = HEADERDATA           " Header Data in Incoming Invoice (Create)
      IMPORTING
        INVOICEDOCNUMBER = INVOICEDOCNUMBER     " Document Number of an Invoice Document
        FISCALYEAR       = FISCALYEAR           " Fiscal Year
      TABLES
        ITEMDATA         = ITEMDATA             " Item Data in Incoming Invoice
        RETURN           = RETURN.              " Return Messages

    IF INVOICEDOCNUMBER IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = C_X.
      IF GS_HDR-RETURN_PO  IS NOT INITIAL.
        GV_RETURN_PO = GS_HDR-RETURN_PO.
      ENDIF.
*** Update Header Status
      GV_SUBRC = 0.
      GS_HDR-STATUS  = C_06.
      GS_HDR-INVOICE = INVOICEDOCNUMBER.
      MODIFY ZINW_T_HDR FROM GS_HDR.
*** For Updating Status Table
      LS_STATUS-QR_CODE      = GS_HDR-QR_CODE.
      LS_STATUS-INWD_DOC     = GS_HDR-INWD_DOC.
      LS_STATUS-STATUS_FIELD = C_QR_CODE.
      LS_STATUS-STATUS_VALUE = C_QR06.
      LS_STATUS-DESCRIPTION  = 'Invoice Created'.
      LS_STATUS-CREATED_BY   = SY-UNAME.
      LS_STATUS-CREATED_DATE = SY-DATUM.
      LS_STATUS-CREATED_TIME = SY-UZEIT.
      MODIFY ZINW_T_STATUS FROM LS_STATUS.

*** Invoice Approvel
      DATA : WA_APPROVE  TYPE ZINVOICE_T_APP.
      WA_APPROVE-APP_STATUS = 'L1'.
      WA_APPROVE-MANDT = SY-DATUM.
      WA_APPROVE-QR_CODE = GS_HDR-QR_CODE.
      MODIFY ZINVOICE_T_APP FROM WA_APPROVE .
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PERFORM MSG_INIT.
      LOOP AT RETURN ASSIGNING <LS_RETURN>.
        CALL FUNCTION 'MESSAGE_STORE'
          EXPORTING
            ARBGB                  = <LS_RETURN>-ID
            MSGTY                  = <LS_RETURN>-TYPE
            MSGV1                  = <LS_RETURN>-MESSAGE_V1
            MSGV2                  = <LS_RETURN>-MESSAGE_V2
            MSGV3                  = <LS_RETURN>-MESSAGE_V3
            MSGV4                  = <LS_RETURN>-MESSAGE_V4
            TXTNR                  = <LS_RETURN>-NUMBER
          EXCEPTIONS
            MESSAGE_TYPE_NOT_VALID = 1
            NOT_ACTIVE             = 2
            OTHERS                 = 3.
        IF SY-SUBRC <> 0.
        ENDIF.
      ENDLOOP.
      PERFORM MSG_STOP.
      PERFORM MSG_SHOW.
    ENDIF.
  ELSE.
    GV_SUBRC = 4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_DATA.
  CLEAR:  GV_RETURN_PO, GV_SUBRC.
  IF P_QR IS NOT INITIAL.
    SELECT SINGLE * FROM ZINW_T_HDR INTO GS_HDR WHERE QR_CODE = P_QR.
    IF GS_HDR-STATUS = C_05.
    ELSE.
      CASE GS_HDR-STATUS.
        WHEN C_01 OR C_02 OR C_03 OR C_04 .
          MESSAGE S046(ZMSG_CLS) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        WHEN C_06 OR C_07.
          MESSAGE S049(ZMSG_CLS) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.

FORM MSG_INIT.
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      LOG_NOT_ACTIVE       = 1
      WRONG_IDENTIFICATION = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM MSG_STOP.
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      A_MESSAGE         = 1
      E_MESSAGE         = 2
      W_MESSAGE         = 3
      I_MESSAGE         = 4
      S_MESSAGE         = 5
      DEACTIVATED_BY_MD = 6
      OTHERS            = 7.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
FORM MSG_SHOW.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      INCONSISTENT_RANGE = 1
      NO_MESSAGES        = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEBIT_NOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM DEBIT_NOTE USING GV_RETURN_PO CHANGING GV_SUBRC.
  DATA :
    HEADERDATA    TYPE BAPI_INCINV_CREATE_HEADER,
    FISCALYEAR    TYPE BAPI_INCINV_FLD-FISC_YEAR,
    LS_ITEMDATA   TYPE BAPI_INCINV_CREATE_ITEM,
    ITEMDATA      TYPE STANDARD TABLE OF BAPI_INCINV_CREATE_ITEM,
    RETURN        TYPE STANDARD TABLE OF BAPIRET2,
    LV_TAX_AMOUNT TYPE NETPR,
    LS_STATUS     TYPE ZINW_T_STATUS.

*** Header Data
  IF GV_RETURN_PO IS NOT INITIAL.
    CLEAR   : HEADERDATA.
    REFRESH : ITEMDATA.
    SELECT EKKO~EBELN,
           EKKO~BUKRS,
           EKKO~WAERS,
           EKPO~EBELP,
           EKPO~MWSKZ,
           EKPO~MENGE,
           EKPO~MEINS,
           EKPO~NETWR,
           EKPO~BRTWR,
           MATDOC~MBLNR,
           MATDOC~MJAHR,
           MATDOC~ZEILE,
           MATDOC~GSBER,
           A003~KNUMH,
           A003~KSCHL,
           KONP~KBETR
           INTO TABLE @DATA(LT_DEBIT)
           FROM EKKO AS EKKO
           INNER JOIN EKPO AS EKPO ON EKPO~EBELN = EKKO~EBELN
           INNER JOIN MATDOC AS MATDOC ON MATDOC~EBELN =  EKPO~EBELN AND MATDOC~EBELP = EKPO~EBELP
           LEFT  OUTER JOIN A003 AS A003 ON A003~MWSKZ =  EKPO~MWSKZ AND A003~KSCHL IN ( 'JIIG' , 'JICG' , 'JISG' )
           LEFT  OUTER JOIN KONP AS KONP ON KONP~KNUMH =  A003~KNUMH
           WHERE EKKO~EBELN = @GV_RETURN_PO.

    HEADERDATA-DOC_DATE     = SY-DATUM.
    HEADERDATA-PSTNG_DATE   = SY-DATUM.
    HEADERDATA-BLINE_DATE   = SY-DATUM.
    HEADERDATA-CALC_TAX_IND = C_X.
    HEADERDATA-REF_DOC_NO   = GS_HDR-INWD_DOC.
    HEADERDATA-SECCO = HEADERDATA-BUSINESS_PLACE  = HEADERDATA-BUS_AREA = C_1000.
*** Item Data
    LOOP AT LT_DEBIT ASSIGNING FIELD-SYMBOL(<LS_DEBIT>).
      LS_ITEMDATA-INVOICE_DOC_ITEM  = SY-TABIX.
      LS_ITEMDATA-PO_NUMBER         = <LS_DEBIT>-EBELN.
      LS_ITEMDATA-PO_ITEM           = <LS_DEBIT>-EBELP.
      LS_ITEMDATA-REF_DOC           = <LS_DEBIT>-MBLNR.
      LS_ITEMDATA-REF_DOC_YEAR      = <LS_DEBIT>-MJAHR.
      LS_ITEMDATA-REF_DOC_IT        = <LS_DEBIT>-ZEILE.
      LS_ITEMDATA-TAX_CODE          = <LS_DEBIT>-MWSKZ.
      LS_ITEMDATA-ITEM_AMOUNT       = <LS_DEBIT>-BRTWR.
      LS_ITEMDATA-QUANTITY          = <LS_DEBIT>-MENGE.
      LS_ITEMDATA-PO_UNIT           = <LS_DEBIT>-MEINS.
      HEADERDATA-COMP_CODE          = <LS_DEBIT>-BUKRS.
      HEADERDATA-CURRENCY           = <LS_DEBIT>-WAERS.

*** Tax Calculation
      IF <LS_DEBIT>-KSCHL = 'JIIG'.
        LV_TAX_AMOUNT = LS_ITEMDATA-ITEM_AMOUNT + ( ( LS_ITEMDATA-ITEM_AMOUNT * <LS_DEBIT>-KBETR ) / 1000 ) .
      ELSEIF <LS_DEBIT>-KSCHL = 'JISG' OR <LS_DEBIT>-KSCHL = 'JICG'.
        LV_TAX_AMOUNT = LS_ITEMDATA-ITEM_AMOUNT + ( ( LS_ITEMDATA-ITEM_AMOUNT * <LS_DEBIT>-KBETR ) / 500 ) .
      ENDIF.
      ADD  LV_TAX_AMOUNT TO HEADERDATA-GROSS_AMOUNT.
      APPEND LS_ITEMDATA TO ITEMDATA.
      CLEAR : LS_ITEMDATA.
    ENDLOOP.

*** Create Debit Note
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        HEADERDATA       = HEADERDATA                  " Header Data in Incoming Invoice (Create)
      IMPORTING
        INVOICEDOCNUMBER = INVOICEDOCNUMBER_DN            " Document Number of an Invoice Document
        FISCALYEAR       = FISCALYEAR                  " Fiscal Year
      TABLES
        ITEMDATA         = ITEMDATA                    " Item Data in Incoming Invoice
        RETURN           = RETURN.                     " Return Messages

    READ TABLE RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = 'E'.
    IF SY-SUBRC <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = C_X.

*** Update Inward Header Table
      GS_HDR-DEBIT_NOTE = INVOICEDOCNUMBER_DN.
*** Status Update
      LS_STATUS-INWD_DOC     = GS_HDR-INWD_DOC.
      LS_STATUS-QR_CODE      = GS_HDR-QR_CODE.
      LS_STATUS-STATUS_FIELD = C_SE_CODE.
      LS_STATUS-CREATED_BY   = SY-UNAME.
      LS_STATUS-CREATED_DATE = SY-DATUM.
      LS_STATUS-CREATED_TIME = SY-UZEIT.
      IF GS_HDR-TAT_PO IS NOT INITIAL.
        LS_STATUS-STATUS_VALUE = C_SE04.
        LS_STATUS-DESCRIPTION  = 'Shortage & Excess'.
        GS_HDR-SOE = C_04.
      ELSE.
        LS_STATUS-STATUS_VALUE = C_SE02.
        LS_STATUS-DESCRIPTION  = 'Shortage'.
        GS_HDR-SOE = C_02.
      ENDIF.
      MODIFY ZINW_T_HDR FROM GS_HDR.
      MODIFY ZINW_T_STATUS FROM LS_STATUS.
      CLEAR : LS_STATUS.
    ELSE.
*** Roll Back if any error.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*      MESSAGE ID <LS_RET>-ID TYPE <LS_RET>-TYPE NUMBER <LS_RET>-NUMBER WITH <LS_RET>-MESSAGE_V1 <LS_RET>-MESSAGE_V2
*      <LS_RET>-MESSAGE_V3 <LS_RET>-MESSAGE_V4.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PERFORM MSG_INIT.
      LOOP AT RETURN ASSIGNING <LS_RETURN>.
        CALL FUNCTION 'MESSAGE_STORE'
          EXPORTING
            ARBGB                  = <LS_RETURN>-ID
            MSGTY                  = <LS_RETURN>-TYPE
            MSGV1                  = <LS_RETURN>-MESSAGE_V1
            MSGV2                  = <LS_RETURN>-MESSAGE_V2
            MSGV3                  = <LS_RETURN>-MESSAGE_V3
            MSGV4                  = <LS_RETURN>-MESSAGE_V4
            TXTNR                  = <LS_RETURN>-NUMBER
          EXCEPTIONS
            MESSAGE_TYPE_NOT_VALID = 1
            NOT_ACTIVE             = 2
            OTHERS                 = 3.
        IF SY-SUBRC <> 0.
        ENDIF.
      ENDLOOP.
      PERFORM MSG_STOP.
      PERFORM MSG_SHOW.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MESSAGES .
*      MESSAGE | { INVOICEDOCNUMBER } Successfully Debit Note Created | TYPE 'S'.
  PERFORM MSG_INIT.
  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      ARBGB                  = 'ZMSG_CLS'
      MSGTY                  = 'S'
      MSGV1                  = INVOICEDOCNUMBER
      MSGV2                  = 'Invoice Created'
      TXTNR                  = '047'
    EXCEPTIONS
      MESSAGE_TYPE_NOT_VALID = 1
      NOT_ACTIVE             = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
  ENDIF.

  IF INVOICEDOCNUMBER_DN IS NOT INITIAL.
*    MESSAGE S054(ZMSG_CLS) WITH INVOICEDOCNUMBER_DN.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB                  = 'ZMSG_CLS'
        MSGTY                  = 'S'
        MSGV1                  = INVOICEDOCNUMBER_DN
        MSGV2                  = 'Debit Note Created'
        TXTNR                  = '054'
      EXCEPTIONS
        MESSAGE_TYPE_NOT_VALID = 1
        NOT_ACTIVE             = 2
        OTHERS                 = 3.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

  PERFORM MSG_STOP.
  PERFORM MSG_SHOW.
ENDFORM.
