*&---------------------------------------------------------------------*
*& Report ZGSTR3_R
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGSTR3_R.
TYPE-POOLS : SLIS .
INCLUDE  ZGSTR3_R_TOP .
INCLUDE ZGSTR3_R_DAT .
INCLUDE ZGSTR3_R_SEL .


SELECT
     BELNR
     GJAHR
     BLART
     BUDAT
     RMWWR
     WMWST1
     XRECH
     STBLG FROM RBKP INTO TABLE IT_RBKP WHERE BUDAT IN R_DATE
    AND BLART = 'RE' .

  IF IT_RBKP IS NOT INITIAL .

    SELECT
       BELNR
       GJAHR
       BUZEI
       MATNR
       MWSKZ
       SALK3 FROM RSEG INTO TABLE IT_RSEG FOR ALL ENTRIES IN IT_RBKP
      WHERE BELNR = IT_RBKP-BELNR AND GJAHR = IT_RBKP-GJAHR .

    SELECT
      KAPPL
      KSCHL
      ALAND
      MWSKZ
      KNUMH FROM A003 INTO TABLE IT_A003 FOR ALL ENTRIES IN IT_RSEG
      WHERE MWSKZ = IT_RSEG-MWSKZ
      AND ALAND = 'IN' .

    SELECT
    KNUMH
    KOPOS
    KBETR FROM KONP INTO TABLE IT_KONP FOR ALL ENTRIES IN IT_A003
      WHERE KNUMH = IT_A003-KNUMH .

    SELECT
      MATNR
      MTART FROM MARA INTO TABLE IT_MARA FOR ALL ENTRIES IN IT_RSEG
      WHERE MATNR = IT_RSEG-MATNR .
  ENDIF .

  LOOP AT IT_RBKP INTO WA_RBKP .
    WA_TABLE-BELNR = WA_RBKP-BELNR .
    WA_TABLE-GJAHR = WA_RBKP-GJAHR .
    WA_TABLE-BUDAT = WA_RBKP-BUDAT .
    WA_TABLE-RMWWR = WA_RBKP-RMWWR .
    WA_TABLE-WMWST1 = WA_RBKP-WMWST1 .
    WA_TABLE-XRECH = WA_RBKP-XRECH .
    WA_TABLE-STBLG = WA_RBKP-STBLG .

    READ TABLE IT_RSEG INTO WA_RSEG WITH KEY BELNR = WA_RBKP-BELNR GJAHR = WA_RBKP-GJAHR .
    IF SY-SUBRC  = 0 .
      WA_TABLE-MATNR = WA_RSEG-MATNR .
      WA_TABLE-MWSKZ = WA_RSEG-MWSKZ .
      WA_TABLE-SALK3 = WA_RSEG-SALK3 .
    ENDIF .

    READ TABLE IT_A003 INTO WA_A003 WITH KEY MWSKZ = WA_RSEG-MWSKZ .
    IF SY-SUBRC  = 0 .
      WA_TABLE-KAPPL = WA_A003-KAPPL .
      WA_TABLE-KSCHL = WA_A003-KSCHL .
      WA_TABLE-KNUMH = WA_A003-KNUMH .
    ENDIF .

    READ TABLE IT_KONP INTO WA_KONP WITH KEY KNUMH = WA_A003-KNUMH .
    IF SY-SUBRC  = 0 .
      WA_TABLE-KBETR = WA_KONP-KBETR .
    ENDIF .

    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_RSEG-MATNR .
    IF SY-SUBRC  = 0 .
      WA_TABLE-MTART = WA_MARA-MTART .
    ENDIF .

    APPEND WA_TABLE TO IT_TABLE .
    CLEAR WA_TABLE .

  ENDLOOP .

**final table
  DATA : IT_FINAL TYPE TABLE OF ZGSTR_3_FINAL,
         WA_FINAL TYPE ZGSTR_3_FINAL.

  DATA : TOTAL_AMOUNT1 TYPE SALK3,
         TOTAL_AMOUNT2 TYPE SALK3,
         TOTAL_VALUE1  TYPE SALK3,
         TOTAL_VALUE2  TYPE SALK3,
         TAX%          TYPE KBETR_KOND,
         ITAX          TYPE SALK3,
         TITAX1        TYPE SALK3,
         TITAX2        TYPE SALK3,
         CTAX          TYPE SALK3,
         TCTAX1        TYPE SALK3,
         TCTAX2        TYPE SALK3,
         STAX          TYPE SALK3,
         TSTAX1        TYPE SALK3,
         TSTAX2        TYPE SALK3,
         AMOUNT        TYPE SALK3,
         COND          TYPE KSCHA.
  CLEAR TOTAL_AMOUNT1 .
  CLEAR TOTAL_AMOUNT2 .

**counter for index
  DATA CNT TYPE I .
  CNT = 1 .

  LOOP AT IT_TABLE INTO WA_TABLE .
    READ TABLE IT_TABLE INTO WA_TABLE INDEX CNT  .
    IF  WA_TABLE-MTART = 'HAWA' .        "condition for goods
      CLEAR AMOUNT .
      AMOUNT = WA_TABLE-SALK3 .
      TOTAL_AMOUNT1 = TOTAL_AMOUNT1 + AMOUNT .
      COND = WA_TABLE-KSCHL .
      CASE COND .
        WHEN 'JIIG' .
          TAX% = WA_TABLE-KBETR / 10 .
          ITAX = AMOUNT * TAX% .
          itax = Itax / 100 .
          TITAX1 = TITAX1 + ITAX .
          CLEAR ITAX .
        WHEN 'JICG' .
          TAX% = WA_TABLE-KBETR / 10 .
          CTAX = AMOUNT * TAX% .
          ctax = ctax / 100 .
          TCTAX1 = TCTAX1 + CTAX .
          CLEAR CTAX .
        WHEN 'JISG' .
          TAX% = WA_TABLE-KBETR / 10 .
          STAX = AMOUNT * TAX%  .
          stax = stax / 100 .
          TSTAX1 = TSTAX1 + STAX .
          CLEAR STAX .
      ENDCASE .

    ELSE .           "for services
      CLEAR AMOUNT .
      AMOUNT = WA_TABLE-SALK3 .
      TOTAL_AMOUNT2 = TOTAL_AMOUNT2 + AMOUNT .

      COND = WA_TABLE-KSCHL .
      CASE COND .
        WHEN 'JIIG' .
          TAX% = WA_TABLE-KBETR / 10 .
          ITAX = AMOUNT * TAX% .
          itax = itax / 100 .
          TITAX2 = TITAX2 + ITAX .
          CLEAR ITAX .
        WHEN 'JICG' .
          TAX% = WA_TABLE-KBETR / 10 .
          CTAX = AMOUNT * TAX% .
          ctax = ctax / 100 .
          TCTAX2 = TCTAX2 + CTAX .
          CLEAR CTAX .
        WHEN 'JISG' .
          TAX% = WA_TABLE-KBETR / 10 .
          STAX = AMOUNT * TAX% .
          stax = stax / 100 .
          TSTAX2 = TSTAX2 + STAX .
          CLEAR STAX .
      ENDCASE .



    ENDIF .
    CNT = CNT + 1 .
  ENDLOOP .
  TOTAL_VALUE1 = TOTAL_AMOUNT1 + TITAX1 + TCTAX1 + TSTAX1 .
  TOTAL_VALUE2 = TOTAL_AMOUNT2 + TITAX2 + TCTAX2 + TSTAX2 .

  WA_FINAL-ZTYPE = 'For Services' .
  WA_FINAL-ZINV = TOTAL_VALUE2 .
  WA_FINAL-ZTAX = TOTAL_AMOUNT2 .
  WA_FINAL-ZITAX = TITAX2 .
  WA_FINAL-ZCTAX = TCTAX2 .
  WA_FINAL-ZSTAX = TSTAX2 .

  APPEND WA_FINAL TO IT_FINAL .
  CLEAR WA_FINAL .

  WA_FINAL-ZTYPE = 'For Goods' .
  WA_FINAL-ZINV = TOTAL_VALUE1 .
  WA_FINAL-ZTAX = TOTAL_AMOUNT1 .
  WA_FINAL-ZITAX = TITAX1 .
  WA_FINAL-ZCTAX = TCTAX1 .
  WA_FINAL-ZSTAX = TSTAX1 .

  APPEND WA_FINAL TO IT_FINAL .
  CLEAR WA_FINAL .

  DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
       WA_FIELDCAT TYPE  SLIS_FIELDCAT_ALV.


WA_FIELDCAT-FIELDNAME = 'ZTYPE' .
WA_FIELDCAT-SELTEXT_M = 'Type' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'ZINV' .
WA_FIELDCAT-SELTEXT_M = 'Total Invoice Value' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'ZTAX' .
WA_FIELDCAT-SELTEXT_M = 'Total Taxable Value' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'ZITAX' .
WA_FIELDCAT-SELTEXT_M = 'Integrated Tax Amount' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'ZCTAX' .
WA_FIELDCAT-SELTEXT_M = 'Central Tax Amount' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'ZSTAX' .
WA_FIELDCAT-SELTEXT_M = 'State/UT Tax Amount' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

WA_FIELDCAT-FIELDNAME = 'ZCESS' .
WA_FIELDCAT-SELTEXT_M = 'CESS Amount' .
APPEND WA_FIELDCAT TO IT_FIELDCAT .
CLEAR WA_FIELDCAT .

**  ZEBRA LAYOUT AND OPTIMIZE

DATA : WA_LAYOUT  TYPE SLIS_LAYOUT_ALV  .
WA_LAYOUT-ZEBRA = 'X' .
WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .


CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
*   I_INTERFACE_CHECK  = ' '
*   I_BYPASSING_BUFFER = ' '
*   I_BUFFER_ACTIVE    = ' '
    I_CALLBACK_PROGRAM = SY-REPID
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME   =
*   I_BACKGROUND_ID    = ' '
*   I_GRID_TITLE       =
*   I_GRID_SETTINGS    =
    IS_LAYOUT          = WA_LAYOUT
    IT_FIELDCAT        = IT_FIELDCAT
*   IT_EXCLUDING       =
*   IT_SPECIAL_GROUPS  =
*   IT_SORT            =
*   IT_FILTER          =
*   IS_SEL_HIDE        =
*   I_DEFAULT          = 'X'
    I_SAVE             = 'A'
*   IS_VARIANT         =
*   IT_EVENTS          =
*   IT_EVENT_EXIT      =
*   IS_PRINT           =
*   IS_REPREP_ID       =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE  = 0
*   I_HTML_HEIGHT_TOP  = 0
*   I_HTML_HEIGHT_END  = 0
*   IT_ALV_GRAPHICS    =
*   IT_HYPERLINK       =
*   IT_ADD_FIELDCAT    =
*   IT_EXCEPT_QINFO    =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB           = IT_FINAL
  EXCEPTIONS
    PROGRAM_ERROR      = 1
    OTHERS             = 2.
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.