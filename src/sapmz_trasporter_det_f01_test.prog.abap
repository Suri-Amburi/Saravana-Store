*&---------------------------------------------------------------------*
*& Include          SAPMZ_TRASPORTER_DET_F01_TEST
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
*  BREAK BREDDY.
*  SELECT
*  QR_CODE
*  EBELN
*  LIFNR
*  SERVICE_PO
*  MBLNR
*  LR_NO FROM ZINW_T_HDR INTO TABLE IT_ZINW_T_HDR WHERE QR_CODE = QR_CODE.
*
*  IF  IT_ZINW_T_HDR IS NOT INITIAL.
*    SELECT
*    EBELN
*    EBELP
*    BELNR
*    DMBTR FROM EKBE INTO TABLE IT_EKBE FOR ALL ENTRIES IN IT_ZINW_T_HDR WHERE BELNR = IT_ZINW_T_HDR-MBLNR.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_QR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_QR INPUT.
****>>breddy 10.07.2019 23:05:33 <<*******
  BREAK BREDDY .


  IF LV_INVOICE_NO IS NOT INITIAL AND LV_QR IS NOT INITIAL AND IT_FINAL IS INITIAL.

    MESSAGE 'Please enter either QR_Code or Invoice Number' TYPE 'I' DISPLAY LIKE 'E' .


  ELSEIF LV_QR IS NOT INITIAL  AND  LV_INVOICE_NO IS INITIAL.       ""AND LV_INVOICE IS INITIAL.

    SELECT SINGLE
      QR_CODE
      EBELN
      LIFNR
      SERVICE_PO
      MBLNR
      LR_NO
      STATUS FROM ZINW_T_HDR INTO  WA_ZINW_T_HDR WHERE QR_CODE = LV_QR .

    IF WA_ZINW_T_HDR-QR_CODE <> LV_QR.
      MESSAGE 'Invalid QR Code ' TYPE 'E' .
    ENDIF.

    SELECT
     EBELN
     EBELP
     BELNR
     DMBTR
     MENGE
     BEWTP FROM EKBE INTO TABLE IT_EKBE1  WHERE EBELN = WA_ZINW_T_HDR-SERVICE_PO AND  BEWTP = 'Q'.
    READ TABLE IT_EKBE1 INTO WA_EKBE1 INDEX 1.
*******IF QR IS ALREADY POSTED
*    IF IT_EKBE1 IS NOT INITIAL .
*      MESSAGE 'QR is already posted ' TYPE 'E' .
*    ENDIF.

********For Same Qr_code
    IF IT_FINAL IS NOT INITIAL AND IT_EKBE1 IS NOT INITIAL.
      READ TABLE IT_FINAL  INTO WA_FINAL INDEX 1.
      IF WA_ZINW_T_HDR-QR_CODE = WA_FINAL-QR_CODE.
        MESSAGE 'QR Code is already considered' TYPE 'E' .
      ENDIF.

********For invoice done
      IF WA_EKBE1-BEWTP <> WA_FINAL-BEWTP.
        MESSAGE 'For this Qr_Code Invoice is already done' TYPE 'E' .
      ENDIF.
    ENDIF.

    IF IT_EKBE1 IS NOT INITIAL .
      SELECT
       RSEG~BELNR ,
       RSEG~EBELN ,
       RSEG~EBELP ,
       RSEG~GJAHR ,
       RSEG~WRBTR FROM RSEG INTO TABLE @DATA(IT_RSEG)
                  FOR ALL ENTRIES IN @IT_EKBE1
                  WHERE BELNR = @IT_EKBE1-BELNR.

      READ TABLE IT_RSEG ASSIGNING FIELD-SYMBOL(<LS_AWKEY>) INDEX 1.
*        LV_AMT1 = <LS_RSEG>-WRBTR + LV_AMT1 .
*        LV_INVOICE_NO = <LS_RSEG>-BELNR .
      IF SY-SUBRC = 0 .
        DATA(LV_GJAHR) =  <LS_AWKEY>-GJAHR .
      ENDIF.
      CONCATENATE  <LS_AWKEY>-BELNR LV_GJAHR INTO DATA(LV_AWKEY) .

      SELECT
        BSEG~BELNR ,
        BSEG~AUGBL ,
        BSEG~AWKEY  FROM BSEG INTO  TABLE @DATA(IT_BSEG_I)
                    WHERE AWKEY = @LV_AWKEY
                    AND KOART = 'K'.
*      READ TABLE IT_BSEG_I ASSIGNING FIELD-SYMBOL(<LS_BSEG_I>) WITH KEY AWKEY = LV_AWKEY.
*      IF SY-SUBRC = 0.
*        IF <LS_BSEG_I>-AUGBL IS NOT INITIAL.
*          MESSAGE 'Payment is already done' TYPE 'E' .
*        ENDIF.
*      ENDIF.

      SELECT
      RBKP~BELNR ,
      RBKP~XBLNR ,
      RBKP~RMWWR FROM RBKP INTO TABLE @DATA(IT_RBKP_I)
               FOR ALL ENTRIES IN @IT_RSEG
               WHERE BELNR = @IT_RSEG-BELNR.


      SELECT
        EKPO~EBELN,
        EKPO~EBELP ,
        EKPO~MENGE ,
        EKPO~NETWR ,
        EKPO~MWSKZ FROM EKPO INTO TABLE @DATA(IT_EKPO_I)
                    FOR ALL ENTRIES IN @IT_RSEG
                    WHERE EBELN = @IT_RSEG-EBELN
                    AND   EBELP = @IT_RSEG-EBELP.

      SELECT
        ZINW_T_HDR~QR_CODE,
        ZINW_T_HDR~SERVICE_PO ,
        ZINW_T_HDR~LR_NO FROM ZINW_T_HDR INTO TABLE @DATA(IT_ZINW_T_HDR_I)
                              FOR ALL ENTRIES IN @IT_RSEG
                              WHERE SERVICE_PO = @IT_RSEG-EBELN.



********QR Code Validations
      IF WA_ZINW_T_HDR IS INITIAL .
        MESSAGE 'Invalid QR Code ' TYPE 'E' .
      ELSEIF WA_ZINW_T_HDR-SERVICE_PO IS INITIAL .
        MESSAGE 'QR Code is not for Service PO' TYPE 'E' .
*    ELSEIF WA_ZINW_T_HDR-STATUS <> '06'.
*      MESSAGE 'GR Not Yet Posted' TYPE 'E' .
      ENDIF.

      SELECT SINGLE
        LIFNR FROM EKKO INTO @DATA(WA_LIFNR) WHERE EBELN = @WA_ZINW_T_HDR-SERVICE_PO.
      IF WA_LIFNR IS NOT INITIAL.

        SELECT SINGLE NAME1 FROM LFA1 INTO  @DATA(WA_NAME) WHERE LIFNR =  @WA_LIFNR.

      ENDIF.
****if vendor is same
      IF LV_LIFNR IS INITIAL .
        LV_LIFNR =  WA_LIFNR .        ""WA_ZINW_T_HDR-LIFNR .
        LV_NAME  =  WA_NAME  .
      ELSEIF LV_LIFNR  <> WA_LIFNR.                ""WA_ZINW_T_HDR-LIFNR .
        MESSAGE 'Posting for Multiple Vendor not possible' TYPE 'E' .
      ENDIF.

      LOOP AT IT_ZINW_T_HDR_I ASSIGNING FIELD-SYMBOL(<LS_ZINW_T_HDR_I>) .
        WA_FINAL-QR_CODE =  <LS_ZINW_T_HDR_I>-QR_CODE .
        WA_FINAL-SERVICE_PO = <LS_ZINW_T_HDR_I>-SERVICE_PO .
        WA_FINAL-LR_NO = <LS_ZINW_T_HDR_I>-LR_NO.
        DATA : LV_AMT1 TYPE WRBTR.
        SORT IT_RSEG BY EBELN  EBELP.
        CLEAR : LV_AMT1.
        LOOP AT IT_RSEG ASSIGNING FIELD-SYMBOL(<LS_RSEG>) WHERE EBELN = <LS_ZINW_T_HDR_I>-SERVICE_PO.
          LV_AMT1 = <LS_RSEG>-WRBTR + LV_AMT1 .
          LV_INVOICE_NO = <LS_RSEG>-BELNR .
        ENDLOOP.
        READ TABLE IT_RBKP_I ASSIGNING FIELD-SYMBOL(<WA_RBKP_I>) WITH KEY BELNR = <LS_RSEG>-BELNR.
        IF SY-SUBRC = 0.
          LV_BILL =  <WA_RBKP_I>-XBLNR.
        ENDIF.

        READ TABLE IT_EKPO_I ASSIGNING FIELD-SYMBOL(<WA_INV>) WITH KEY EBELN = <LS_RSEG>-EBELN  EBELP = <LS_RSEG>-EBELP.
        DATA : LV_PO_VAL1 TYPE NETWR.
        IF SY-SUBRC = 0.
          CLEAR LV_PO_VAL1.
          CALL METHOD ZCL_PO_ITEM_TAX=>GET_PO_ITEM_TAX
            EXPORTING
              I_EBELN     = <WA_INV>-EBELN                 " Purchasing Document Number
              I_EBELP     = <WA_INV>-EBELP                 " Item Number of Purchasing Document
              I_QUANTITY  = <WA_INV>-MENGE              " Quantity
            IMPORTING
*             E_TAX       = GS_FINAL1-TAX                 " Tax Amount in Document Currency
              E_TOTAL_VAL = LV_PO_VAL1.
        ENDIF.
        WA_FINAL-AMOUNT = LV_PO_VAL1.
        APPEND WA_FINAL TO IT_FINAL.
        CLEAR : WA_FINAL .
      ENDLOOP.
      READ TABLE IT_BSEG_I ASSIGNING FIELD-SYMBOL(<LS_BSEG_I>) WITH KEY AWKEY = LV_AWKEY.
      IF SY-SUBRC = 0.
        LV_PAYMENT = <LS_BSEG_I>-AUGBL .
        IF <LS_BSEG_I>-AUGBL IS NOT INITIAL.
          MESSAGE 'Payment is already done' TYPE 'I' DISPLAY LIKE 'E' .
        ENDIF.
      ENDIF.
      DATA(IT_FINAL1) = IT_FINAL[] .
      CLEAR LV_QR .
*    ENDIF.
    ELSE.
      REFRESH : IT_FINAL1 .
********QR Code Validations
      IF WA_ZINW_T_HDR IS INITIAL.
        MESSAGE 'Invalid QR Code ' TYPE 'E' .
      ELSEIF WA_ZINW_T_HDR-SERVICE_PO IS INITIAL .
        MESSAGE 'QR Code is not for Service PO' TYPE 'E' .
*    ELSEIF WA_ZINW_T_HDR-STATUS <> '06'.
*      MESSAGE 'GR Not Yet Posted' TYPE 'E' .
      ENDIF.

********For Same Qr_code
      IF IT_FINAL IS NOT INITIAL.
        READ TABLE IT_FINAL  INTO WA_FINAL INDEX 1.
        IF WA_ZINW_T_HDR-QR_CODE = WA_FINAL-QR_CODE.
          MESSAGE 'QR Code is already considered' TYPE 'E' .
        ENDIF.
      ENDIF.

      SELECT SINGLE
        LIFNR FROM EKKO INTO @DATA(WA_LIFNR1) WHERE EBELN = @WA_ZINW_T_HDR-SERVICE_PO.
      IF WA_LIFNR1 IS NOT INITIAL.

        SELECT SINGLE NAME1 FROM LFA1 INTO  @DATA(WA_NAME1) WHERE LIFNR =  @WA_LIFNR1.

      ENDIF.
****if vendor is same
      IF LV_LIFNR IS INITIAL .
        LV_LIFNR =  WA_LIFNR1 .        ""WA_ZINW_T_HDR-LIFNR .
        LV_NAME  =  WA_NAME1  .
      ELSEIF LV_LIFNR  <> WA_LIFNR1.                ""WA_ZINW_T_HDR-LIFNR .
        MESSAGE 'Posting for Multiple Vendor not possible ' TYPE 'E' .
      ENDIF.

      IF  WA_ZINW_T_HDR IS NOT INITIAL.
        SELECT
           EBELN
           EBELP
           BELNR
           DMBTR
           MENGE
           BEWTP FROM EKBE INTO TABLE IT_EKBE  WHERE EBELN = WA_ZINW_T_HDR-SERVICE_PO AND  BEWTP = 'E' AND BWART = '101'.

**********GR Validation
        IF IT_EKBE IS INITIAL .
          MESSAGE 'GR is not yet done' TYPE 'E' .
        ENDIF.

        IF IT_EKBE IS NOT INITIAL.
          SELECT
            EBELN
            EBELP
            MENGE
            NETWR
            MWSKZ FROM EKPO INTO TABLE IT_EKPO
                  FOR ALL ENTRIES IN IT_EKBE
                  WHERE EBELN = IT_EKBE-EBELN
                  AND EBELP = IT_EKBE-EBELP.
        ENDIF.

        LOOP AT IT_EKBE ASSIGNING FIELD-SYMBOL(<WA_EKBE>) WHERE EBELN = WA_ZINW_T_HDR-SERVICE_PO.
          READ TABLE IT_EKPO ASSIGNING FIELD-SYMBOL(<WA_RET>) WITH KEY EBELN = <WA_EKBE>-EBELN  EBELP = <WA_EKBE>-EBELP.
          WA_FINAL-QR_CODE = WA_ZINW_T_HDR-QR_CODE .
          WA_FINAL-SERVICE_PO = WA_ZINW_T_HDR-SERVICE_PO .
          WA_FINAL-LR_NO = WA_ZINW_T_HDR-LR_NO .
          WA_FINAL-BEWTP =  <WA_EKBE>-BEWTP.

*        WA_FINAL-AMOUNT = <WA_EKBE>-DMBTR.

          DATA : LV_PO_VAL TYPE NETWR.
          IF SY-SUBRC = 0.
            CLEAR LV_PO_VAL.
            CALL METHOD ZCL_PO_ITEM_TAX=>GET_PO_ITEM_TAX
              EXPORTING
                I_EBELN     = <WA_RET>-EBELN                 " Purchasing Document Number
                I_EBELP     = <WA_RET>-EBELP                 " Item Number of Purchasing Document
                I_QUANTITY  = <WA_RET>-MENGE              " Quantity
              IMPORTING
*               E_TAX       = GS_FINAL1-TAX                " Tax Amount in Document Currency
                E_TOTAL_VAL = LV_PO_VAL.
          ENDIF.

          WA_FINAL-AMOUNT = LV_PO_VAL.
          APPEND WA_FINAL TO IT_FINAL.
          CLEAR WA_FINAL .
        ENDLOOP.
      ENDIF.

      IT_FINAL1 = IT_FINAL[].
      SORT IT_FINAL1 BY SERVICE_PO.
      DELETE ADJACENT DUPLICATES FROM IT_FINAL1 COMPARING SERVICE_PO.

      LOOP AT IT_FINAL1 ASSIGNING FIELD-SYMBOL(<WA_FINAL1>) .
        CLEAR <WA_FINAL1>-AMOUNT.
        LOOP AT IT_FINAL INTO WA_FINAL WHERE SERVICE_PO = <WA_FINAL1>-SERVICE_PO.
          <WA_FINAL1>-AMOUNT = WA_FINAL-AMOUNT.
        ENDLOOP.
      ENDLOOP.
      CLEAR LV_QR .
*    elseif  qr_code is NOT INITIAL and

    ENDIF .

  ENDIF .

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BILL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BILL INPUT.
  BREAK BREDDY.

  IF LV_INVOICE_NO IS NOT INITIAL AND IT_FINAL IS INITIAL AND LV_QR IS INITIAL.
    SELECT
    RSEG~BELNR ,
    RSEG~EBELN ,
    RSEG~EBELP ,
    RSEG~GJAHR ,
    RSEG~WRBTR  FROM RSEG INTO TABLE @DATA(IT_RSEG_Q)
               WHERE BELNR = @LV_INVOICE_NO .

    IF IT_RSEG_Q IS INITIAL.
      MESSAGE 'Invoice number is incoreect' TYPE 'I' DISPLAY LIKE 'E' .
    ENDIF.
    CLEAR :  LV_INVOICE_NO  .
  ENDIF .

  IF IT_RSEG_Q IS NOT INITIAL AND IT_FINAL IS INITIAL AND LV_QR IS INITIAL.

    IF IT_RSEG_Q IS NOT INITIAL.
      SELECT
        ZINW_T_HDR~QR_CODE ,
        ZINW_T_HDR~SERVICE_PO ,
        ZINW_T_HDR~LR_NO FROM ZINW_T_HDR INTO TABLE @DATA(IT_ZINW_T_HDR_Q)
                              FOR ALL ENTRIES IN @IT_RSEG_Q
                              WHERE SERVICE_PO = @IT_RSEG_Q-EBELN .
      SELECT
        EKPO~EBELN,
        EKPO~EBELP ,
        EKPO~MENGE ,
        EKPO~NETWR ,
        EKPO~MWSKZ FROM EKPO INTO TABLE @DATA(IT_EKPO_Q)
                    FOR ALL ENTRIES IN @IT_RSEG_Q
                    WHERE EBELN = @IT_RSEG_Q-EBELN
                    AND   EBELP = @IT_RSEG_Q-EBELP.
      SELECT
      RBKP~BELNR ,
      RBKP~XBLNR ,
      RBKP~RMWWR FROM RBKP INTO TABLE @DATA(IT_RBKP_Q)
               FOR ALL ENTRIES IN @IT_RSEG_Q
               WHERE BELNR = @IT_RSEG_Q-BELNR.

    ENDIF.
    READ TABLE IT_RSEG_Q ASSIGNING FIELD-SYMBOL(<LS_AWKEY1>) INDEX 1.
*        LV_AMT1 = <LS_RSEG>-WRBTR + LV_AMT1 .
*        LV_INVOICE_NO = <LS_RSEG>-BELNR .
    IF SY-SUBRC = 0 .
      DATA(LV_GJAHR1) =  <LS_AWKEY1>-GJAHR .
      CONCATENATE  <LS_AWKEY1>-BELNR LV_GJAHR1 INTO DATA(LV_AWKEY1) .
    ENDIF.


    IF LV_AWKEY1 IS NOT INITIAL .
      SELECT
        BSEG~BELNR ,
        BSEG~AUGBL ,
        BSEG~AWKEY  FROM BSEG INTO  TABLE @DATA(IT_BSEG_Q)
                    WHERE AWKEY = @LV_AWKEY1
                    AND KOART = 'K'.
    ENDIF .
    READ TABLE IT_ZINW_T_HDR_Q ASSIGNING FIELD-SYMBOL(<WA_HDR>) INDEX 1.
    IF SY-SUBRC = 0 .
      SELECT SINGLE
      LIFNR FROM EKKO INTO @DATA(WA_LIFNR_Q) WHERE EBELN = @<WA_HDR>-SERVICE_PO.
    ENDIF .
    IF WA_LIFNR_Q IS NOT INITIAL.
      SELECT SINGLE NAME1 FROM LFA1 INTO  @DATA(WA_NAME_Q) WHERE LIFNR =  @WA_LIFNR_Q.
****if vendor is same
      LV_LIFNR =  WA_LIFNR_Q .        ""WA_ZINW_T_HDR-LIFNR .
      LV_NAME  =  WA_NAME_Q  .
    ENDIF.

    LOOP AT IT_ZINW_T_HDR_Q ASSIGNING FIELD-SYMBOL(<WA_ZINW_T_HDR_Q>).
      WA_FINAL-QR_CODE =  <WA_ZINW_T_HDR_Q>-QR_CODE .
      WA_FINAL-SERVICE_PO = <WA_ZINW_T_HDR_Q>-SERVICE_PO .
      WA_FINAL-LR_NO = <WA_ZINW_T_HDR_Q>-LR_NO.
      DATA : LV_AMT2 TYPE WRBTR.
      SORT IT_RSEG_Q BY EBELN  EBELP.
      CLEAR : LV_AMT2.
      LOOP AT IT_RSEG_Q ASSIGNING FIELD-SYMBOL(<LS_RSEG_Q>) WHERE EBELN = <WA_ZINW_T_HDR_Q>-SERVICE_PO.
        LV_AMT2 = <LS_RSEG_Q>-WRBTR + LV_AMT2 .
        LV_INVOICE_NO = <LS_RSEG_Q>-BELNR .
      ENDLOOP.
      READ TABLE IT_RBKP_Q ASSIGNING FIELD-SYMBOL(<WA_RBKP_Q>) WITH KEY BELNR = <LS_RSEG_Q>-BELNR.
      IF SY-SUBRC = 0.
        LV_BILL =  <WA_RBKP_Q>-XBLNR.
      ENDIF.

      READ TABLE IT_EKPO_Q ASSIGNING FIELD-SYMBOL(<WA_INV_Q>) WITH KEY EBELN = <LS_RSEG_Q>-EBELN  EBELP = <LS_RSEG_Q>-EBELP.
      DATA : LV_PO_VAL_Q TYPE NETWR.
      IF SY-SUBRC = 0.
        CLEAR LV_PO_VAL_Q.
        CALL METHOD ZCL_PO_ITEM_TAX=>GET_PO_ITEM_TAX
          EXPORTING
            I_EBELN     = <WA_INV_Q>-EBELN                 " Purchasing Document Number
            I_EBELP     = <WA_INV_Q>-EBELP                 " Item Number of Purchasing Document
            I_QUANTITY  = <WA_INV_Q>-MENGE              " Quantity
          IMPORTING
*           E_TAX       = GS_FINAL1-TAX                 " Tax Amount in Document Currency
            E_TOTAL_VAL = LV_PO_VAL_Q.
      ENDIF.
      WA_FINAL-AMOUNT = LV_PO_VAL_Q.
      APPEND WA_FINAL TO IT_FINAL.
      CLEAR : WA_FINAL .
    ENDLOOP.
    READ TABLE IT_BSEG_Q ASSIGNING FIELD-SYMBOL(<LS_BSEG_Q>) WITH KEY AWKEY = LV_AWKEY1.
    IF SY-SUBRC = 0.
      LV_PAYMENT = <LS_BSEG_Q>-AUGBL .
      IF <LS_BSEG_Q>-AUGBL IS NOT INITIAL.
        MESSAGE 'Payment is already done' TYPE 'I' DISPLAY LIKE 'E' .
      ENDIF.
    ENDIF.
    IT_FINAL1 = IT_FINAL[] .


  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_BILL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BILL .
********VALIDATION FOR SAME VENDOR
  BREAK BREDDY .
  IF  LV_INVOICE_NO IS INITIAL AND LV_LIFNR IS NOT INITIAL AND LV_BILL IS NOT INITIAL  .
    SELECT SINGLE
    XBLNR ,
    LIFNR FROM RBKP INTO  @DATA(WA_RBKP)
          WHERE XBLNR = @LV_BILL
          AND LIFNR   = @LV_LIFNR .
    IF SY-SUBRC = 0 .
      MESSAGE 'Bill Number is already existed for the same Vendor' TYPE 'I' DISPLAY LIKE  'E' .
    ENDIF .
  ENDIF .

*  ELSEIF WA_RBKP-XBLNR IS NOT INITIAL AND WA_RBKP-LIFNR IS NOT INITIAL.
*    MESSAGE 'Bill Number is already existed for the same Vendor' TYPE 'I' DISPLAY LIKE  'E' .
*    ELSEIF  LV_LIFNR IS NOT INITIAL AND LV_BILL IS NOT INITIAL AND WA_RBKP IS INITIAL .
*ENDIF.

  IF LV_BILL IS NOT INITIAL AND WA_RBKP IS INITIAL. "AND LV_INVOICE_NO IS NOT INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'G1'.
        SCREEN-INPUT = 0 .
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF WA_ZINW_T_HDR-QR_CODE IS NOT INITIAL .
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'G2'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF LV_INVOICE_NO IS NOT INITIAL AND LV_QR IS INITIAL .
    LOOP AT SCREEN.
      IF LV_PAYMENT IS INITIAL AND SCREEN-NAME = 'PAYMENT' .
        SCREEN-INPUT = 1.
        MODIFY SCREEN .
      ELSE.
        SCREEN-INPUT = 0.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF IT_FINAL IS NOT INITIAL AND LV_QR IS INITIAL .
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'REFRESH'.
        SCREEN-INPUT = 1.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SETUP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SETUP_ALV .
  CREATE OBJECT CONTAINER
    EXPORTING
      CONTAINER_NAME = 'CONTAINER'.
  CREATE OBJECT GRID
    EXPORTING
      I_PARENT = CONTAINER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILL_GRID .
*  IF IT_FINAL1 IS NOT INITIAL .
  REFRESH LT_FIELDCAT.
  DATA: WA_FC  TYPE  LVC_S_FCAT.
*  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .

  LW_LAYO-ZEBRA = ABAP_TRUE .
  LW_LAYO-CWIDTH_OPT = ABAP_TRUE .

  WA_FC-COL_POS   = '1'.
  WA_FC-FIELDNAME = 'QR_CODE'.
  WA_FC-TABNAME   = 'IT_FINAL1'.
  WA_FC-SCRTEXT_L = 'Qr Code'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '2'.
  WA_FC-FIELDNAME = 'SERVICE_PO'.
  WA_FC-TABNAME   = 'IT_FINAL1'.
  WA_FC-SCRTEXT_L = 'Service Po'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '3'.
  WA_FC-FIELDNAME = 'LR_NO'.
  WA_FC-TABNAME   = 'IT_FINAL1'.
  WA_FC-SCRTEXT_L = 'LR No'.
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.

  WA_FC-COL_POS   = '4'.
  WA_FC-FIELDNAME = 'AMOUNT'.
  WA_FC-TABNAME   = 'IT_FINAL1'.
  WA_FC-SCRTEXT_L = 'Amount'.
  WA_FC-DO_SUM    = 'X' .
  APPEND WA_FC TO LT_FIELDCAT.
  CLEAR WA_FC.



  PERFORM EXCLUDE_TB_FUNCTIONS CHANGING LT_EXCLUDE.

  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IT_TOOLBAR_EXCLUDING          = LT_EXCLUDE
      IS_LAYOUT                     = LW_LAYO
    CHANGING
      IT_OUTTAB                     = IT_FINAL1[] "it_item[]
      IT_FIELDCATALOG               = LT_FIELDCAT
*     IT_SORT                       = IT_SORT[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.
*  ENDIF .
  IF GRID IS BOUND.
    LS_STABLE-ROW = 'X'.
    LS_STABLE-COL = 'X'.
    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
    ENDIF .
  ENDIF .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING LT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FIND_MORE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUM.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_INVOICE_POST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_INVOICE_POST .
  BREAK BREDDY.

  TYPES : BEGIN OF TY_EKKN ,
            EBELN TYPE EBELN,
            SAKTO TYPE SAKNR,
            GSBER TYPE GSBER,
            KOSTL TYPE KOSTL,
            KOKRS TYPE KOKRS,
            PRCTR TYPE PRCTR,
          END OF TY_EKKN .
  TYPES : BEGIN OF TY_EKKO ,
            EBELN TYPE EBELN,
            BUKRS TYPE BUKRS,
            WAERS TYPE WAERS,
          END OF TY_EKKO .

  TYPES : BEGIN OF TY_EKBE ,
            EBELN TYPE EBELN,
            BELNR TYPE MBLNR,
            BEWTP TYPE BEWTP,
          END OF TY_EKBE .

  TYPES : BEGIN OF TY_ESLL ,
            PACKNO     TYPE  ESLL-PACKNO,
            SUB_PACKNO TYPE ESLL-SUB_PACKNO,
          END OF TY_ESLL .

  DATA : IT_EKKN TYPE TABLE OF TY_EKKN,
         IT_EKKO TYPE TABLE OF TY_EKKO,
         IT_EKBE TYPE TABLE OF TY_EKBE,
         IT_ESLL TYPE TABLE OF TY_ESLL,
         WA_EKKN TYPE TY_EKKN,
*         WA_ESLL TYPE TY_ESLL,
         WA_EKBE TYPE TY_EKBE,
         WA_EKKO TYPE TY_EKKO.

  TYPES :BEGIN OF TY_RETURN ,
           TYPE       TYPE BAPI_MTYPE,
           ID         TYPE SYMSGID,
           NUMBER     TYPE SYMSGNO,
           MESSAGE    TYPE BAPI_MSG,
           LOG_NO     TYPE BALOGNR,
           LOG_MSG_NO TYPE BALMNR,
           MESSAGE_V1 TYPE SYMSGV,
           MESSAGE_V2 TYPE SYMSGV,
           MESSAGE_V3 TYPE SYMSGV,
           MESSAGE_V4 TYPE SYMSGV,
         END OF TY_RETURN .

  DATA : WA_HEADERDATA     TYPE BAPI_INCINV_CREATE_HEADER,
         IT_ITEMDATA       TYPE TABLE OF BAPI_INCINV_CREATE_ITEM,
         WA_ITEMDATA       TYPE  BAPI_INCINV_CREATE_ITEM,
         IT_ACCOUNTINGDATA TYPE TABLE OF BAPI_INCINV_CREATE_ACCOUNT,
         WA_ACCOUNTINGDATA TYPE BAPI_INCINV_CREATE_ACCOUNT.


  DATA : TOT_AMOUNT TYPE BAPI_RMWWR .
  DATA : IT_RETURN  TYPE TABLE OF BAPIRET2,
         IT_RETURN1 TYPE TABLE OF TY_RETURN,
*         IT_RBKP    TYPE TABLE OF TY_RBKP,
         WA_RETURN  TYPE BAPIRET2,
*         WA_RBKP    TYPE TY_RBKP,
         WA_RETURN1 TYPE TY_RETURN.



  SELECT
    EBELN
    BUKRS
    WAERS FROM EKKO INTO TABLE IT_EKKO
          FOR ALL ENTRIES IN IT_FINAL1
          WHERE  EBELN = IT_FINAL1-SERVICE_PO .
  READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.

  SELECT
    EKPO~EBELN ,
    EKPO~EBELP ,
    EKPO~MWSKZ FROM EKPO INTO TABLE @DATA(IT_EKPO1)
               FOR ALL ENTRIES IN @IT_FINAL1
               WHERE EBELN = @IT_FINAL1-SERVICE_PO .

  SELECT
     EBELN
     SAKTO
     GSBER
     KOSTL
     KOKRS
     PRCTR FROM EKKN INTO TABLE IT_EKKN
           FOR ALL ENTRIES IN IT_FINAL1
           WHERE EBELN  = IT_FINAL1-SERVICE_PO .
  READ TABLE IT_EKKN INTO WA_EKKN INDEX 1.
  SELECT
    EBELN
    BELNR
    BEWTP FROM EKBE INTO TABLE IT_EKBE
          FOR ALL ENTRIES IN IT_FINAL1
          WHERE EBELN = IT_FINAL1-SERVICE_PO AND BEWTP = 'D'.

  IF IT_EKBE IS NOT INITIAL.

    SELECT
      ESSR~LBLNI ,
      ESSR~EBELN ,
      ESSR~PACKNO FROM ESSR INTO TABLE @DATA(IT_ESSR)
                  FOR ALL ENTRIES IN @IT_EKBE
                  WHERE  EBELN = @IT_EKBE-EBELN
                  AND LBLNI = @IT_EKBE-BELNR.

  ENDIF.
  IF IT_ESSR IS NOT INITIAL.
    SELECT
      PACKNO
      SUB_PACKNO FROM ESLL INTO TABLE IT_ESLL
                      FOR ALL ENTRIES IN IT_ESSR
                      WHERE PACKNO = IT_ESSR-PACKNO .
  ENDIF.
  BREAK BREDDY.
  IF IT_ESLL IS NOT INITIAL.
    SELECT
      ESLL~PACKNO ,
      ESLL~EXTROW ,
      ESLL~SUB_PACKNO ,
      ESLL~MENGE ,
      ESLL~MEINS ,
      ESLL~BRTWR  FROM ESLL INTO TABLE @DATA(IT_ESLL1)
                      FOR ALL ENTRIES IN @IT_ESLL
                      WHERE PACKNO = @IT_ESLL-SUB_PACKNO .
  ENDIF.

  WA_HEADERDATA-INVOICE_IND = 'X'.
  WA_HEADERDATA-DOC_TYPE = 'RE'.
  WA_HEADERDATA-DOC_DATE = SY-DATUM.
  WA_HEADERDATA-PSTNG_DATE = SY-DATUM.
  WA_HEADERDATA-REF_DOC_NO = LV_BILL.
  WA_HEADERDATA-COMP_CODE = WA_EKKO-BUKRS.
  WA_HEADERDATA-CURRENCY = WA_EKKO-WAERS.
*  WA_HEADERDATA-GROSS_AMOUNT = TOT_AMOUNT.
  WA_HEADERDATA-CALC_TAX_IND = 'X' .
  WA_HEADERDATA-BUS_AREA = WA_EKKN-GSBER .
  WA_HEADERDATA-BUSINESS_PLACE = WA_EKKN-GSBER .
  WA_HEADERDATA-SECCO = WA_EKKN-GSBER .
  WA_HEADERDATA-DE_CRE_IND = 'S' .
  DATA : LV_INV TYPE RBLGP  .

  BREAK BREDDY .


*  LOOP at it_final1 into wa_final ."WHERE SERVICE_PO = WA_EKBE-EBELN .
*        LV_INV = LV_INV + 1 .
*    WA_ITEMDATA-INVOICE_DOC_ITEM = LV_INV .
*    WA_ACCOUNTINGDATA-INVOICE_DOC_ITEM = LV_INV .
*    TOT_AMOUNT = WA_FINAL-AMOUNT + TOT_AMOUNT .
*    WA_HEADERDATA-GROSS_AMOUNT = TOT_AMOUNT.
  SORT IT_ESLL1 BY PACKNO EXTROW .
  LOOP AT IT_ESLL1 ASSIGNING FIELD-SYMBOL(<WA_ESLL1>) .

    READ TABLE IT_ESLL ASSIGNING  FIELD-SYMBOL(<WA_ESLL>) WITH KEY SUB_PACKNO = <WA_ESLL1>-PACKNO .
    IF <WA_ESLL> IS ASSIGNED .
      READ TABLE IT_ESSR ASSIGNING FIELD-SYMBOL(<WA_ESSR>) WITH KEY PACKNO = <WA_ESLL>-PACKNO .
    ENDIF.
    IF <WA_ESSR> IS ASSIGNED .
      READ TABLE IT_EKBE INTO WA_EKBE WITH KEY BELNR = <WA_ESSR>-LBLNI.
      IF SY-SUBRC = 0.
        WA_ITEMDATA-SHEET_NO = WA_EKBE-BELNR.
      ENDIF.
    ENDIF.

*  READ TABLE IT_FINAL1 INTO WA_FINAL WITH KEY  SERVICE_PO = WA_EKBE-EBELN .
    LOOP AT IT_FINAL1 INTO WA_FINAL WHERE  SERVICE_PO = WA_EKBE-EBELN .

      LV_INV = LV_INV + 1 .
      WA_ITEMDATA-INVOICE_DOC_ITEM = LV_INV .
      WA_ACCOUNTINGDATA-INVOICE_DOC_ITEM = LV_INV .
*      READ TABLE IT_EKBE INTO WA_EKBE WITH KEY EBELN = WA_FINAL-SERVICE_PO BEWTP = 'D' .
      WA_ITEMDATA-ITEM_AMOUNT = <WA_ESLL1>-BRTWR .
      WA_ITEMDATA-QUANTITY = <WA_ESLL1>-MENGE .
      WA_ITEMDATA-PO_UNIT = <WA_ESLL1>-MEINS .
      WA_ITEMDATA-PO_UNIT_ISO = <WA_ESLL1>-MEINS .
      WA_ITEMDATA-SHEET_ITEM = <WA_ESLL1>-EXTROW .
      WA_ACCOUNTINGDATA-SERIAL_NO = '01'.
      WA_ACCOUNTINGDATA-ITEM_AMOUNT = <WA_ESLL1>-BRTWR .
      WA_ACCOUNTINGDATA-QUANTITY = <WA_ESLL1>-MENGE .
      WA_ACCOUNTINGDATA-PO_UNIT = <WA_ESLL1>-MEINS .
      READ TABLE IT_EKKN INTO WA_EKKN WITH KEY  EBELN = WA_FINAL-SERVICE_PO .
      IF SY-SUBRC = 0.
        WA_ACCOUNTINGDATA-GL_ACCOUNT = WA_EKKN-SAKTO.
        WA_ACCOUNTINGDATA-COSTCENTER = WA_EKKN-KOSTL.
        WA_ACCOUNTINGDATA-BUS_AREA   = WA_EKKN-GSBER.
        WA_ACCOUNTINGDATA-CO_AREA   = WA_EKKN-KOKRS.
        WA_ACCOUNTINGDATA-PROFIT_CTR   = WA_EKKN-PRCTR.
      ENDIF.
      READ TABLE IT_EKPO1 ASSIGNING FIELD-SYMBOL(<WA_EKPO1>) WITH KEY EBELN = WA_FINAL-SERVICE_PO .
      IF SY-SUBRC = 0 .
        WA_ITEMDATA-PO_NUMBER = WA_FINAL-SERVICE_PO .
        WA_ITEMDATA-PO_ITEM = <WA_EKPO1>-EBELP .
        WA_ITEMDATA-TAX_CODE = <WA_EKPO1>-MWSKZ .
        WA_ACCOUNTINGDATA-TAX_CODE = <WA_EKPO1>-MWSKZ .
      ENDIF .
      APPEND : WA_ITEMDATA TO IT_ITEMDATA .
      CLEAR : WA_ITEMDATA.
      APPEND : WA_ACCOUNTINGDATA TO IT_ACCOUNTINGDATA .
      CLEAR : WA_ACCOUNTINGDATA .
    ENDLOOP.
  ENDLOOP.
  LOOP AT IT_FINAL1 INTO WA_FINAL.

*     TOT_AMOUNT = WA_FINAL-AMOUNT + TOT_AMOUNT .
    WA_HEADERDATA-GROSS_AMOUNT = WA_HEADERDATA-GROSS_AMOUNT + WA_FINAL-AMOUNT.

  ENDLOOP.
  DATA : LV_INVOICE TYPE BAPI_INCINV_FLD-INV_DOC_NO,
         LV_YEAR    TYPE BAPI_INCINV_FLD-FISC_YEAR.

  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
    EXPORTING
      HEADERDATA       = WA_HEADERDATA
*     ADDRESSDATA      =
    IMPORTING
      INVOICEDOCNUMBER = LV_INVOICE
      FISCALYEAR       = LV_YEAR
    TABLES
      ITEMDATA         = IT_ITEMDATA
      ACCOUNTINGDATA   = IT_ACCOUNTINGDATA
*     GLACCOUNTDATA    =
*     MATERIALDATA     =
*     TAXDATA          =
*     WITHTAXDATA      =
*     VENDORITEMSPLITDATA       =
      RETURN           = IT_RETURN
*     EXTENSIONIN      = it_EXTENSIONIN
*     TM_ITEMDATA      = it_TM_ITEMDATA
*     NFMETALLITMS     = it_NFMETALLITMS
*     ASSETDATA        = it_ASSETDATA
    .

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
  LV_INVOICE_NO = LV_INVOICE .

  DATA : LV_TEXT(30) TYPE C .
  IF LV_INVOICE IS NOT INITIAL.
    CONCATENATE LV_INVOICE 'INVOICE SUCCESSFULLY CREATED' INTO DATA(LV_MSG) .
    MESSAGE LV_MSG TYPE 'S' .
  ELSE .
    LOOP AT IT_RETURN INTO WA_RETURN WHERE TYPE = 'E'.
      WA_RETURN1-TYPE       = WA_RETURN-TYPE      .
      WA_RETURN1-ID         = WA_RETURN-ID        .
      WA_RETURN1-NUMBER     = WA_RETURN-NUMBER    .
      WA_RETURN1-MESSAGE    = WA_RETURN-MESSAGE   .
      WA_RETURN1-LOG_NO     = WA_RETURN-LOG_NO    .
      WA_RETURN1-LOG_MSG_NO = WA_RETURN-LOG_MSG_NO.
      WA_RETURN1-MESSAGE_V1 = WA_RETURN-MESSAGE_V1.
      WA_RETURN1-MESSAGE_V2 = WA_RETURN-MESSAGE_V2.
      WA_RETURN1-MESSAGE_V3 = WA_RETURN-MESSAGE_V3.
      WA_RETURN1-MESSAGE_V4 = WA_RETURN-MESSAGE_V4.
      APPEND WA_RETURN1 TO IT_RETURN1 .
    ENDLOOP.
  ENDIF.

  IF IT_RETURN1 IS NOT INITIAL .
    DATA : WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.


    DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
          WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

    DATA: IT_SORT TYPE SLIS_T_SORTINFO_ALV,
          WA_SORT TYPE SLIS_SORTINFO_ALV.

*    WA_FIELDCAT-FIELDNAME = 'SL_NO'.
*    WA_FIELDCAT-SELTEXT_L =  'Serial No'.
*    APPEND WA_FIELDCAT TO IT_FIELDCAT.
*    CLEAR   WA_FIELDCAT  .

    WA_FIELDCAT-FIELDNAME = 'TYPE'.
    WA_FIELDCAT-SELTEXT_L = 'TYPE'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR   WA_FIELDCAT  .

    WA_FIELDCAT-FIELDNAME = 'ID'.
    WA_FIELDCAT-SELTEXT_L = 'ID'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR   WA_FIELDCAT  .

    WA_FIELDCAT-FIELDNAME = 'MESSAGE'.
    WA_FIELDCAT-SELTEXT_L = 'MESSAGE'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR   WA_FIELDCAT  .
    WA_LAYOUT-ZEBRA = 'X'.
    WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_BUFFER_ACTIVE    = ' '
        I_CALLBACK_PROGRAM = SY-REPID
        IS_LAYOUT          = WA_LAYOUT
*       I_CALLBACK_USER_COMMAND     = 'USER_COMMAND'
*       I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
        IT_FIELDCAT        = IT_FIELDCAT
        IT_SORT            = IT_SORT
        I_DEFAULT          = 'X'
        I_SAVE             = 'A'
      TABLES
        T_OUTTAB           = IT_RETURN1
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.


*    PERFORM DISPLAY .
  ENDIF .
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAYMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PAYMENT .

  IF  LV_PAYMENT IS INITIAL.
    SELECT SINGLE * FROM RBKP INTO WA_RBKP_IV WHERE BELNR = LV_INVOICE_NO.
    DATA(LV_DOC) = WA_RBKP_IV-BELNR && WA_RBKP_IV-GJAHR.
    SELECT SINGLE * FROM BKPF INTO WA_BKPF WHERE AWKEY = LV_DOC.
    SELECT SINGLE * FROM BSIK INTO WA_BSIK WHERE BUKRS = WA_BKPF-BUKRS AND BELNR = WA_BKPF-BELNR  AND GJAHR = WA_BKPF-GJAHR.
    PERFORM FM_BAPI_CLEAR .
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
*& Form FM_BAPI_CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FM_BAPI_CLEAR .


********************** Local Declartion ********************************
  DATA : LS_STATUS TYPE ZINW_T_STATUS.
  DATA : LV_MODE  TYPE C VALUE 'N',
         LV_MSGID LIKE SY-MSGID,
         LV_MSGNO LIKE SY-MSGNO,
         LV_MSGTY LIKE SY-MSGTY,
         LV_MSGV1 LIKE SY-MSGV1,
         LV_MSGV2 LIKE SY-MSGV2,
         LV_MSGV3 LIKE SY-MSGV3,
         LV_MSGV4 LIKE SY-MSGV4,
         LV_SUBRC LIKE SY-SUBRC.

  DATA: LT_BLNTAB  TYPE TABLE OF BLNTAB,
        LS_BLNTAB  TYPE BLNTAB,
        LT_CLEAR   TYPE TABLE OF FTCLEAR,
        LS_CLEAR   TYPE FTCLEAR,
        LT_POST    TYPE TABLE OF FTPOST,
        LS_POST    TYPE FTPOST,
        LT_TAX     TYPE TABLE OF FTTAX,
        LV_DOC_DT  TYPE C LENGTH 10,
        LV_POST_DT TYPE C LENGTH 10,
        LV_COUNT   TYPE I VALUE 0,
        LV_MESSAGE TYPE C LENGTH 100.

*** Step:1 Starting Interface
  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      I_CLIENT           = SY-MANDT
      I_FUNCTION         = 'C'
      I_MODE             = LV_MODE
      I_UPDATE           = 'S'
    EXCEPTIONS
      CLIENT_INCORRECT   = 1
      FUNCTION_INVALID   = 2
      GROUP_NAME_MISSING = 3
      MODE_INVALID       = 4
      UPDATE_INVALID     = 5
      OTHERS             = 6.
  IF SY-SUBRC <> 0.
    MESSAGE 'Error initializing posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  CLEAR  : LV_MSGID, LV_MSGNO, LV_MSGTY, LV_MSGV1, LV_MSGV2, LV_MSGV3, LV_MSGV4, LV_SUBRC.
  CLEAR  : LV_DOC_DT, LV_POST_DT,  LS_CLEAR, LS_POST , LV_COUNT .

*** Filling Tables
*** Header Info in LT_POST Table

  LS_POST-STYPE = 'K'.                           " Header
  LS_POST-COUNT =  LV_COUNT + 1.

  IF WA_BKPF-BLDAT IS NOT INITIAL.
    LV_DOC_DT =  WA_BKPF-BLDAT+6(2) && '.' && WA_BKPF-BLDAT+4(2) && '.' && WA_BKPF-BLDAT+0(4).
  ENDIF.

  IF WA_BKPF-BLART IS NOT INITIAL.
    LV_POST_DT =  LV_DOC_DT.
  ENDIF.

  LS_POST-FNAM = 'BKPF-BUKRS'.         ""Company Cd
  LS_POST-FVAL = WA_BKPF-BUKRS .
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-WAERS'.          "Doc Currency
  LS_POST-FVAL = WA_BKPF-WAERS.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-BLART'.          "Doc Type
  LS_POST-FVAL =  'KZ' .
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-BLDAT'.         "Doc Date
  LS_POST-FVAL =  LV_DOC_DT.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-BUDAT'.         "Posting Dt
  LS_POST-FVAL = LV_POST_DT.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM =  'BKPF-XBLNR'.        "Ref Doc
  LS_POST-FVAL = WA_BKPF-XBLNR.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-MONAT'.                "Period
  LS_POST-FVAL = WA_BKPF-MONAT.
  APPEND LS_POST TO LT_POST.

*** item

  CLEAR: LV_COUNT.
  LS_POST-STYPE = 'P'.                          " For Item
  LV_COUNT = LV_COUNT + 1 .
  LS_POST-COUNT =  LV_COUNT .

  LS_POST-FNAM = 'RF05A-NEWBS'.                 "Post Key
  LS_POST-FVAL = '50'.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'RF05A-NEWKO'.                 "GL Account
  LS_POST-FVAL = C_GL.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BSEG-WRBTR'.                  "DC Amount
  LV_AMOUNT =    WA_RBKP_IV-RMWWR .
  LS_POST-FVAL = LV_AMOUNT .
  CONDENSE LS_POST-FVAL.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BSEG-BUPLA'.                 "bUSINESS Place
  LS_POST-FVAL = WA_BSIK-BUPLA.
  APPEND LS_POST TO LT_POST.

  LS_CLEAR-AGKOA = 'K'.                         "D-cust, K:v-vend
  LS_CLEAR-AGKON = WA_BSIK-LIFNR.               "Vendor Account
  LS_CLEAR-AGBUK = WA_BSIK-BUKRS.
  LS_CLEAR-XNOPS = 'X'.
  LS_CLEAR-XFIFO = SPACE.
  LS_CLEAR-AGUMS = SPACE.
  LS_CLEAR-AVSID = SPACE.
  LS_CLEAR-SELFD = 'XBLNR'.
  LS_CLEAR-SELVON = WA_BKPF-XBLNR.

  APPEND LS_CLEAR TO LT_CLEAR.
  CLEAR: LS_CLEAR.

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      I_AUGLV                    = 'UMBUCHNG'
      I_TCODE                    = 'FB05'
    IMPORTING
      E_MSGID                    = LV_MSGID
      E_MSGNO                    = LV_MSGNO
      E_MSGTY                    = LV_MSGTY
      E_MSGV1                    = LV_MSGV1
      E_MSGV2                    = LV_MSGV2
      E_MSGV3                    = LV_MSGV3
      E_MSGV4                    = LV_MSGV4
      E_SUBRC                    = LV_SUBRC
    TABLES
      T_BLNTAB                   = LT_BLNTAB
      T_FTCLEAR                  = LT_CLEAR
      T_FTPOST                   = LT_POST
      T_FTTAX                    = LT_TAX
    EXCEPTIONS
      CLEARING_PROCEDURE_INVALID = 1
      CLEARING_PROCEDURE_MISSING = 2
      TABLE_T041A_EMPTY          = 3
      TRANSACTION_CODE_INVALID   = 4
      AMOUNT_FORMAT_ERROR        = 5
      TOO_MANY_LINE_ITEMS        = 6
      COMPANY_CODE_INVALID       = 7
      SCREEN_NOT_FOUND           = 8
      NO_AUTHORIZATION           = 9
      OTHERS                     = 10.
  CLEAR: LV_MESSAGE.

  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      ID        = LV_MSGID
      LANG      = SY-LANGU
      NO        = LV_MSGNO
      V1        = LV_MSGV1
      V2        = LV_MSGV2
      V3        = LV_MSGV3
      V4        = LV_MSGV4
    IMPORTING
      MSG       = LV_MESSAGE
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  LV_PAYMENT = LV_MSGV1 .
** Step:3 Closing Interface
  CALL FUNCTION 'POSTING_INTERFACE_END'
    EXPORTING
      I_BDCIMMED              = ' '
    EXCEPTIONS
      SESSION_NOT_PROCESSABLE = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
    MESSAGE 'Error Ending posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  BREAK BREDDY .
*  IF LV_MESSAGE IS NOT INITIAL.
*    CLEAR LV_COUNT .
*    LV_COUNT = LV_COUNT + 1 .
*    LS_ALV-SNO = LV_COUNT .
**    ls_alv-
*    LS_ALV-BUKRS = WA_BSIK-BUKRS .
*    LS_ALV-GJAHR = WA_BSIK-GJAHR .
*    LS_ALV-LIFNR = WA_BSIK-LIFNR .
*    LS_ALV-WRBTR = WA_BSIK-WRBTR .
*    SELECT SINGLE NAME1 FROM LFA1 INTO  LS_ALV-NAME1 WHERE LIFNR = WA_BSIK-LIFNR .
**    ls_alv-NAME1 =
*      LS_ALV-V_BELNR   =  WA_BSIK-BELNR.
*      LS_ALV-V_AUGBL   =  LV_MSGV1.
*      LS_ALV-V_MESSAGE = LV_MESSAGE.
**        IF lv_msgty = 'A'.
**          ls_alv-c_type  =  lv_msgty.
**          ls_alv-c_message = 'Document already cleared'.
**        ENDIF.
**        ls_alv-c_type    =  lv_msgty.
*
**        APPEND ls_alv TO gt_alv.
**        CLEAR: ls_alv.
*    ENDIF.

  APPEND LS_ALV TO GT_ALV.
  CLEAR: LS_ALV.

*    PERFORM FM_DISP_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FM_DISP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FM_DISP_ALV .

  DATA: STR_REC_L_FCAT TYPE SLIS_FIELDCAT_ALV,
        ITAB_L_FCAT    TYPE TABLE OF SLIS_FIELDCAT_ALV.

  DATA: STR_REC_L_LAYOUT TYPE SLIS_LAYOUT_ALV.
  STR_REC_L_LAYOUT-ZEBRA = ABAP_TRUE.
  STR_REC_L_LAYOUT-COLWIDTH_OPTIMIZE = ABAP_TRUE.

  STR_REC_L_FCAT-FIELDNAME = 'SNO'.
  STR_REC_L_FCAT-SELTEXT_M = 'Sr.No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Sr.No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Sr.No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '7'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

*  STR_REC_L_FCAT-FIELDNAME = 'BUKRS'.
*  STR_REC_L_FCAT-SELTEXT_M = 'Company Code'.
*  STR_REC_L_FCAT-SELTEXT_S = 'Company Code'.
*  STR_REC_L_FCAT-SELTEXT_L = 'Company Code'.
*  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
*  STR_REC_L_FCAT-OUTPUTLEN = '15'.
*  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
*  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'GJAHR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Fiscal Year'.
  STR_REC_L_FCAT-SELTEXT_S = 'Fiscal Year'.
  STR_REC_L_FCAT-SELTEXT_L = 'Fiscal Year'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'LIFNR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Vendor No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Vendor No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Vendor No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'NAME1'.
  STR_REC_L_FCAT-SELTEXT_M = 'Vendor Name'.
  STR_REC_L_FCAT-SELTEXT_S = 'Vendor Name'.
  STR_REC_L_FCAT-SELTEXT_L = 'Vendor Name'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '15'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'WRBTR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Clearing Amount'.
  STR_REC_L_FCAT-SELTEXT_S = 'Clearing Amount'.
  STR_REC_L_FCAT-SELTEXT_L = 'Clearing Amount'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'V_BELNR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Doc. No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Doc. No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Doc. No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'V_AUGBL'.
  STR_REC_L_FCAT-SELTEXT_M = 'Clearing Doc.No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Clearing Doc.No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Clearing Doc.No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '15'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'V_MESSAGE'.
  STR_REC_L_FCAT-SELTEXT_M = 'Message'.
  STR_REC_L_FCAT-SELTEXT_S = 'Message'.
  STR_REC_L_FCAT-SELTEXT_L = 'Message'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '50'.

  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_LAYOUT-ZEBRA = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IS_LAYOUT     = STR_REC_L_LAYOUT
      IT_FIELDCAT   = ITAB_L_FCAT
    TABLES
      T_OUTTAB      = GT_ALV
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
