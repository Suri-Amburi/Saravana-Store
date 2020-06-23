*&---------------------------------------------------------------------*
*& Include          Z_GSTR2_REPORT_FORM
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

  """""""""""""""""""""""" FOR DATE RANGE """""""""""""""""""""""""""""""
  INPUT_DATE =  P_YEAR && P_MONTH && '01' .
  CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
    EXPORTING
      IV_DATE             = INPUT_DATE
    IMPORTING
      EV_MONTH_BEGIN_DATE = FIRST_DATE     "start date
      EV_MONTH_END_DATE   = LAST_DATE. " end date
  APPEND VALUE #( SIGN = 'I' OPTION = 'BT' LOW = FIRST_DATE HIGH = LAST_DATE  ) TO R_DATE .

  """"""""""""""""""""""""""' SELECT """""""""""""""""""""""""""""""""""""""
  SELECT
     BUKRS
     BELNR
     GJAHR
     BLART
     BLDAT
     BUDAT
  FROM BKPF INTO TABLE IT_BKPF WHERE BUDAT IN  R_DATE
    AND BLART IN ( 'RE' , 'KR', 'KG' , 'KA' ,'C1' ,'C2' ,  'C3', 'C4' ) .

  IF IT_BKPF  IS NOT INITIAL .
    SELECT
      BUKRS
      BELNR
      GJAHR
      BUZID
      KOART
      SHKZG
      MWSKZ
      DMBTR
      LIFNR
      FROM BSEG INTO TABLE IT_BSEG FOR ALL ENTRIES IN IT_BKPF WHERE  BELNR = IT_BKPF-BELNR AND GJAHR = IT_BKPF-GJAHR .
  ENDIF .

  IF IT_BSEG  IS NOT INITIAL .
    SELECT
      KAPPL
      KSCHL
      ALAND
      MWSKZ
      KNUMH
       FROM A003 INTO TABLE IT_A003 FOR ALL ENTRIES IN IT_BSEG WHERE  MWSKZ =  IT_BSEG-MWSKZ AND ALAND = 'IN' .
  ENDIF .

  IF IT_A003  IS NOT INITIAL .
    SELECT
      KNUMH
      KOPOS
      KSCHL
      KBETR
      PKWRT
      FROM KONP INTO TABLE IT_KONP FOR ALL ENTRIES IN IT_A003 WHERE KNUMH = IT_A003-KNUMH .
  ENDIF .

  IF IT_BSEG  IS NOT INITIAL .
    SELECT
      LIFNR
      ORT01
      FROM LFA1 INTO TABLE  IT_LFA1 FOR ALL ENTRIES IN IT_BSEG WHERE LIFNR = IT_BSEG-LIFNR .
  ENDIF .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LOOP .
  """"""""""""""""""""""""" LOOPING """""""""""""""""""""""""""""""""""""""""""""""
  LOOP AT IT_BKPF INTO WA_BKPF .
    WA_FINAL-BELNR = WA_BKPF-BELNR .
    WA_FINAL-BLDAT = WA_BKPF-BLDAT .
*    WA_FINAL-XRECH = WA_BKPF-XRECH .
*    WA_FINAL-RMWWR = WA_BKPF-RMWWR.
*  IF  wa_final-XRECH = 'X' .
*    wa_final-WMWST1 = WA_bkpf-WMWST1 .
*  ELSE .
*    wa_final-WMWST1 =  -1 * WA_bkpf-WMWST1 .
*  ENDIF .

    READ TABLE IT_BSEG INTO WA_BSEG WITH KEY BELNR = WA_BKPF-BELNR  GJAHR = WA_BKPF-GJAHR KOART = 'K'  BUZID = ''.
    IF SY-SUBRC  = 0 .
      WA_FINAL-DMBTR = WA_BSEG-DMBTR .
    ENDIF .

    READ TABLE IT_BSEG INTO DATA(WA_BSEG1) WITH KEY BELNR = WA_BKPF-BELNR  GJAHR = WA_BKPF-GJAHR BUZID = 'T' ." SHKZG = 'H' . " BUZID = 'T'.
    IF SY-SUBRC  = 0 .
      WA_FINAL-IGST = WA_BSEG1-DMBTR .
    ENDIF .


    READ TABLE IT_BSEG INTO DATA(WA_BSEG2) WITH KEY BELNR = WA_BKPF-BELNR  GJAHR = WA_BKPF-GJAHR  BUZID = 'S' .
    IF SY-SUBRC  = 0 .
      WA_FINAL-SGST = WA_BSEG1-DMBTR .
      WA_FINAL-CGST = WA_BSEG1-DMBTR .
    ENDIF .
    WA_FINAL-TOTAL_TAX = WA_FINAL-DMBTR - WA_FINAL-IGST .
*    READ TABLE IT_A003 INTO WA_A003 WITH KEY  MWSKZ = WA_BSEG-MWSKZ  ALAND = 'IN' .
*    IF SY-SUBRC  = 0 .
*    ENDIF .
*
*    LOOP AT IT_KONP INTO WA_KONP WHERE KNUMH = WA_A003-KNUMH AND KSCHL = WA_A003-KSCHL .
*      CASE : WA_KONP-KSCHL.
*        WHEN 'JIIG'.
*          WA_FINAL-IGST% = WA_KONP-KBETR  .
**          WA_FINAL-IGST =  WA_FINAL-DMBTR * ( WA_FINAL-IGST% /  100 ) . "WA_KONP-PKWRT .
*        WHEN 'JICG'.
*          WA_FINAL-CGST% =  WA_KONP-KBETR  .
*          WA_FINAL-CGST =  WA_FINAL-DMBTR * ( WA_FINAL-CGST% /  100 ) .
*        WHEN 'JISG'.
*          WA_FINAL-SGST% =  WA_KONP-KBETR .
*          WA_FINAL-SGST =  WA_FINAL-DMBTR * ( WA_FINAL-SGST% /  100 ) .
*
*          CLEAR : WA_KONP .
*      ENDCASE.
*    ENDLOOP.

    LOOP AT  IT_A003 INTO DATA(WA_A003) WHERE MWSKZ = WA_BSEG-MWSKZ  .
      LOOP AT  IT_KONP INTO DATA(WA_KONP) WHERE KNUMH = WA_A003-KNUMH  .
        CASE WA_KONP-KSCHL .
          WHEN 'JICG' .
            WA_FINAL-CGST% = ( WA_KONP-KBETR * 10 ) / 100.
*            wa_final-CGST  = ( wa_final-DMBTR * ( wa_final-CGST% / 100 ) ).
          WHEN 'JISG' .
            WA_FINAL-SGST% = ( WA_KONP-KBETR * 10 ) / 100.
*            wa_final-SGST  = ( wa_final-DMBTR * ( wa_final-SGST% / 100 ) ).
          WHEN 'JIIG' .
            WA_FINAL-IGST% = ( WA_KONP-KBETR * 10 ) / 100.
*            wa_final-IGST = ( wa_final-DMBTR * ( wa_final-IGST% / 100 ) ).

          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP .

    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY  LIFNR = WA_BSEG-LIFNR .
    IF SY-SUBRC  = 0 .
      WA_FINAL-ORT01 = WA_LFA1-ORT01 .
    ENDIF .

*  wa_final-TOTAL_INVOICE_VALUE = wa_final-WMWST1 +  wa_final-IGST + wa_final-CGST + wa_final-SGST  .
    WA_FINAL-SLNO = SLNO .
    SLNO = SLNO + 1 .

    APPEND WA_FINAL TO IT_FINAL .
    CLEAR WA_FINAL .
  ENDLOOP .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  """"""""""""""""""""""""""""" DISPLAY OUTPUT """""""""""""""""""""""""""""""""""
  WA_FIELDCAT-FIELDNAME = 'slno' .
  WA_FIELDCAT-SELTEXT_M = 'Serial No' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'BELNR' .
  WA_FIELDCAT-SELTEXT_M = 'Invoice No' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'BLDAT' .
  WA_FIELDCAT-SELTEXT_M = 'Invoice Date' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'ORT01' .
  WA_FIELDCAT-SELTEXT_M = 'Vendor Location' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'DMBTR' .
  WA_FIELDCAT-SELTEXT_M = 'TOTAL_INVOICE_VALUE' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'TOTAL_TAX' .
  WA_FIELDCAT-SELTEXT_M = 'Total Taxable Value' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'IGST' .
  WA_FIELDCAT-SELTEXT_M = 'Integrated Tax Amount' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .


  WA_FIELDCAT-FIELDNAME = 'CGST' .
  WA_FIELDCAT-SELTEXT_M = 'Central Tax Amount' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'SGST' .
  WA_FIELDCAT-SELTEXT_M = 'State Tax Amount' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  WA_FIELDCAT-FIELDNAME = 'CESS_AMOUNT' .
  WA_FIELDCAT-SELTEXT_M = 'Cess Amount' .
  APPEND WA_FIELDCAT TO IT_FIELDCAT .
  CLEAR WA_FIELDCAT .

  """""""""""""""""""""" FUNCTION MODULE FOR OUTPUT DISPLAY """""""""""""""""""""""
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      I_CALLBACK_PROGRAM = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = IT_FIELDCAT
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     IT_SORT            =
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = ' '
*     IS_VARIANT         =
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
*     IS_PRINT           =
*     IS_REPREP_ID       =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  = 0
*     I_HTML_HEIGHT_END  = 0
*     IT_ALV_GRAPHICS    =
*     IT_HYPERLINK       =
*     IT_ADD_FIELDCAT    =
*     IT_EXCEPT_QINFO    =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB           = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
