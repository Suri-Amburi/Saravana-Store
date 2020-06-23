*&---------------------------------------------------------------------*
*& Include          ZSAPMP_FI_CFO_DIARY_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FINAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FINAL_DATA .
  REFRESH IT_FINAL1.
  CLEAR WA_FINAL1.
  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = LV_DATE7.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-QR_CODE        = WA_FINAL-QR_CODE.
    WA_FINAL1-DUE_ON         =  WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_AMOUNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_AMOUNT .
*  BREAK-POINT.
  YEAR = LV_DATE7+0(4).
*  DATE = LV_DATE7+0(2).
*lv_date7 = syst-datum.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = lv_date7
      DAYS      = 1
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = WA_HEADER-DATE1.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = WA_HEADER-DATE1
      DAYS      = 1
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = WA_HEADER-DATE2.


  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = WA_HEADER-DATE2
      DAYS      = 1
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = WA_HEADER-DATE3.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = WA_HEADER-DATE3
      DAYS      = 1
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = WA_HEADER-DATE4.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = WA_HEADER-DATE4
      DAYS      = 1
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = WA_HEADER-DATE5.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = WA_HEADER-DATE5
      DAYS      = 1
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = WA_HEADER-DATE6.

year1 = WA_HEADER-DATE6+0(4).

IF year = year1 .



  SELECT
    BUKRS
    BELNR
    GJAHR
    BUZEI
    BSCHL
    KOART
    LIFNR
    H_BLDAT
    H_BLART
    ZFBDT
    NETDT
     FROM BSEG INTO TABLE IT_BSEG
    WHERE GJAHR = YEAR
    AND BUKRS     = '1000'
    AND BSCHL     IN ('31' , '21')
    AND KOART     = 'K'
    AND H_BLART  IN ('RE' , 'KR' , 'KG').

else.
    SELECT
    BUKRS
    BELNR
    GJAHR
    BUZEI
    BSCHL
    KOART
    LIFNR
    H_BLDAT
    H_BLART
    ZFBDT
    NETDT
     FROM BSEG INTO TABLE IT_BSEG
    WHERE GJAHR in ( year , year1 )
    AND BUKRS     = '1000'
    AND BSCHL     IN ('31','21')
    AND KOART     = 'K'
    AND H_BLART  IN ('RE','KR','KG').


  ENDIF.
  IF IT_BSEG IS NOT INITIAL.

    SELECT BUKRS
           LIFNR
           GJAHR
           BELNR
           BUDAT
           WAERS
           XBLNR
           WRBTR
           BSCHL
           BLART
           ZTERM
           BLDAT
           DMBTR
        FROM BSIK INTO TABLE IT_BSIK
        FOR ALL ENTRIES IN IT_BSEG
        WHERE BUKRS = IT_BSEG-BUKRS
        AND BELNR = IT_BSEG-BELNR
        AND   BSCHL = IT_BSEG-BSCHL
        AND   GJAHR = IT_BSEG-GJAHR.
*        WHERE GJAHR = YEAR
*        AND BSCHL  IN ('31''21')
*        AND BLART  IN ('RE''KR''KG').

  ENDIF.


  IF IT_BSIK IS NOT INITIAL .
    SELECT LIFNR
           NAME1 FROM LFA1 INTO TABLE IT_LFA1
          FOR ALL ENTRIES IN IT_BSIK
          WHERE LIFNR = IT_BSIK-LIFNR.
*
*    SELECT  BUKRS
*            BELNR
*            GJAHR
*            REINDAT FROM BKPF INTO TABLE IT_BKPF
*                    FOR ALL ENTRIES IN IT_BSIK
*                    WHERE BUKRS = IT_BSIK-BUKRS
*                    AND   BELNR   = IT_BSIK-BELNR
*                    AND   GJAHR   = IT_BSIK-GJAHR.

    SELECT
      EBELN
      LIFNR
      QR_CODE FROM ZINW_T_HDR INTO TABLE IT_INW_T_HDR
             FOR ALL ENTRIES IN IT_BSIK
             WHERE LIFNR = IT_BSIK-LIFNR.
  ENDIF.


*BREAK-POINT.

*  LOOP AT IT_BSIK INTO WA_BSIK.
  REFRESH IT_FINAL .
  LOOP AT IT_BSEG INTO WA_BSEG.
*    READ TABLE IT_BKPF INTO WA_BKPF WITH KEY BUKRS = WA_BSIK-BUKRS
*                                             BELNR = WA_BSIK-BELNR
*                                             GJAHR = WA_BSIK-GJAHR.
    WA_FINAL-DUEDATE = WA_BSEG-NETDT .
    READ TABLE IT_BSIK INTO WA_BSIK WITH KEY BUKRS = WA_BSEG-BUKRS
                                             BSCHL = WA_BSEG-BSCHL
                                             BELNR = WA_BSEG-BELNR
                                             GJAHR = WA_BSEG-GJAHR.


    IF SY-SUBRC = 0.
      WA_FINAL-INVOICE_NO     = WA_BSIK-BELNR.
      WA_FINAL-VENDOR_INVOICE = WA_BSIK-XBLNR.
      WA_FINAL-AMOUNT         = WA_BSIK-DMBTR.
      WA_FINAL-VENDOR_NO      = WA_BSIK-LIFNR.
    ENDIF.

    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSIK-LIFNR.
    IF SY-SUBRC = 0.
      WA_FINAL-VENDOR_NAME = WA_LFA1-NAME1.
    ENDIF.

    READ TABLE IT_INW_T_HDR INTO WA_INW_T_HDR
                            WITH KEY LIFNR = WA_BSIK-LIFNR.
    IF SY-SUBRC = 0.
      WA_FINAL-QR_CODE = WA_INW_T_HDR-QR_CODE.
    ENDIF.



*    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
*      EXPORTING
*        I_BLDAT         = WA_BSIK-BLDAT
*        I_BUDAT         = WA_BSIK-BUDAT
*        I_CPUDT         = SY-DATUM
*        I_ZFBDT         = WA_BSIK-ZFBDT
*        I_ZTERM         = WA_BSIK-ZTERM    " payment terms
*        I_REINDAT       = WA_BKPF-REINDAT  " Invoice receipt date
*        I_LIFNR         = WA_BSIK-LIFNR
*        I_BUKRS         = WA_BSIK-BUKRS
*      IMPORTING
*        E_ZBD1T         = LV_ZBD1T
*        E_ZBD1P         = LV_ZBD1P
*        E_ZBD2T         = LV_ZBD2T
*        E_ZBD2P         = LV_ZBD2P
*        E_ZBD3T         = LV_ZBD3T
*        E_ZFBDT         = LV_ZFBDT
*        E_SPLIT         = LV_XSPLT
*        E_ZSCHF         = LV_ZSCHF
*        E_ZLSCH         = LV_ZLSCH
*        E_T052          = WA_T052
*      EXCEPTIONS
*        TERMS_NOT_FOUND = 1
*        OTHERS          = 2.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*
*    ELSE.
*      CALL FUNCTION 'J_1B_FI_NETDUE'
*        EXPORTING
*          ZFBDT   = LV_ZFBDT
*          ZBD1T   = LV_ZBD1T
*          ZBD2T   = LV_ZBD2T
*          ZBD3T   = LV_ZBD3T
**         ZSTG1   =
**         ZSMN1   =
**         ZSTG2   =
**         ZSMN2   =
**         ZSTG3   =
**         ZSMN3   =
*        IMPORTING
*          DUEDATE = DUEDATE.
*    ENDIF.
*    WA_FINAL-DUEDATE = DUEDAT.


*    IF DUEDATE BETWEEN WA_HEADER-DATE1 AND WA_HEADER-DATE6.

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR:WA_FINAL.

  ENDLOOP.
*CLEAR:WA_HEADER.
*    ENDIF.
*BREAK-POINT.
          CLEAR :WA_HEADER-D1_AMT,
        WA_HEADER-D2_AMT,
        WA_HEADER-D3_AMT,
        WA_HEADER-D4_AMT,
        WA_HEADER-D5_AMT,
        WA_HEADER-D6_AMT .
  LOOP AT IT_FINAL INTO WA_FINAL.

    IF WA_FINAL-DUEDATE     = WA_HEADER-DATE1.
      WA_HEADER-D1_AMT     = WA_HEADER-D1_AMT + WA_FINAL-AMOUNT.
      WA_HEADER-D1_CUR     = WA_BSIK-WAERS.
    ELSEIF WA_FINAL-DUEDATE  = WA_HEADER-DATE2.
*       CLEAR WA_HEADER-D2_AMT .
      WA_HEADER-D2_AMT     = WA_HEADER-D2_AMT + WA_FINAL-AMOUNT.
      WA_HEADER-D2_CUR     = WA_BSIK-WAERS.
    ELSEIF WA_FINAL-DUEDATE  = WA_HEADER-DATE3.
*       CLEAR WA_HEADER-D3_AMT .
      WA_HEADER-D3_AMT     = WA_HEADER-D3_AMT + WA_FINAL-AMOUNT.
      WA_HEADER-D3_CUR     = WA_BSIK-WAERS.
    ELSEIF WA_FINAL-DUEDATE  = WA_HEADER-DATE4.
*       CLEAR WA_HEADER-D4_AMT .
      WA_HEADER-D4_AMT     = WA_HEADER-D4_AMT + WA_FINAL-AMOUNT.
      WA_HEADER-D4_CUR     = WA_BSIK-WAERS.
    ELSEIF WA_FINAL-DUEDATE  = WA_HEADER-DATE5.
*       CLEAR WA_HEADER-D5_AMT .
      WA_HEADER-D5_AMT     = WA_HEADER-D5_AMT + WA_FINAL-AMOUNT.
      WA_HEADER-D5_CUR     = WA_BSIK-WAERS.
    ELSEIF WA_FINAL-DUEDATE  = WA_HEADER-DATE6.
*       CLEAR WA_HEADER-D6_AMT .
      WA_HEADER-D6_AMT     = WA_HEADER-D6_AMT + WA_FINAL-AMOUNT.
      WA_HEADER-D6_CUR     = WA_BSIK-WAERS.
    ENDIF.




*
*    CALL FUNCTION 'DETERMINE_DUE_DATE'
*      EXPORTING
*        I_FAEDE                    = WA_I_FAEDE
*        I_GL_FAEDE                 = WA_I_GL_FAEDE
*      IMPORTING
*        E_FAEDE                    = WA_E_FAEDE
*      EXCEPTIONS
*        ACCOUNT_TYPE_NOT_SUPPORTED = 1
*        OTHERS                     = 2.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*APPEND wa_final to it_final.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE1_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATE1_DATA .

  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = WA_HEADER-DATE1.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-QR_CODE        = WA_FINAL-QR_CODE.
    WA_FINAL1-DUE_ON = WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE2_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATE2_DATA .

  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = WA_HEADER-DATE2.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-DUE_ON = WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE3_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATE3_DATA .


  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = WA_HEADER-DATE3.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-QR_CODE        = WA_FINAL-QR_CODE.
    WA_FINAL1-DUE_ON = WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE4_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATE4_DATA .

  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = WA_HEADER-DATE4.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-QR_CODE        = WA_FINAL-QR_CODE.
    WA_FINAL1-DUE_ON = WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE5_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATE5_DATA .

  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = WA_HEADER-DATE5.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-QR_CODE        = WA_FINAL-QR_CODE.
    WA_FINAL1-DUE_ON = WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE6_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATE6_DATA .

  LOOP AT IT_FINAL INTO WA_FINAL WHERE DUEDATE = WA_HEADER-DATE6.
    WA_FINAL1-INVOICE_NO     = WA_FINAL-INVOICE_NO.
    WA_FINAL1-VENDOR_INVOICE = WA_FINAL-VENDOR_INVOICE.
    WA_FINAL1-AMOUNT         = WA_FINAL-AMOUNT.
    WA_FINAL1-VENDOR_NO      = WA_FINAL-VENDOR_NO.
    WA_FINAL1-VENDOR_NAME    = WA_FINAL-VENDOR_NAME.
    WA_FINAL1-QR_CODE        = WA_FINAL-QR_CODE.
    WA_FINAL1-DUE_ON = WA_FINAL-DUEDATE .
    APPEND WA_FINAL1 TO IT_FINAL1.
    CLEAR:WA_FINAL1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BANK_AMT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BANK_AMT .
*BREAK-POINT.
  SELECT
    BUKRS
    HBKID
    HKTID
    BANKN
    HKONT FROM T012K INTO TABLE IT_T012K.

  IF IT_T012K IS NOT INITIAL.
    SELECT
      BUKRS
      HKONT
      ZUONR
      GJAHR
      BELNR
      SHKZG
      DMBTR FROM BSIS INTO TABLE IT_BSIS
      FOR ALL ENTRIES IN IT_T012K
      WHERE BUKRS = IT_T012K-BUKRS
      AND   HKONT = IT_T012K-HKONT.

  ENDIF.

  LOOP AT IT_BSIS INTO WA_BSIS.

    IF WA_BSIS-HKONT = 'H'.
      LV_NET = LV_NET + WA_BSIS-DMBTR.
    ELSEIF WA_BSIS-HKONT = 'S'.
      LV_NET = LV_NET - WA_BSIS-DMBTR.
    ENDIF.

  ENDLOOP.


ENDFORM.
