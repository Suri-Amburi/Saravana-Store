*&---------------------------------------------------------------------*
*& Include          ZSALFORMR_SUB
*&---------------------------------------------------------------------*

FORM GET_TABLEDATA.

  SELECT PERNR
         FROM PA0000 INTO TABLE IT_PA0000
         WHERE PERNR = PERNR-PERNR.

  IF IT_PA0000 IS NOT INITIAL.
    SELECT  PERNR
            ENAME
            PERSK
            FROM PA0001 INTO TABLE IT_PA0001
            FOR ALL ENTRIES IN IT_PA0000
            WHERE PERNR = IT_PA0000-PERNR.

    SELECT PERNR
           GESCH
           FROM PA0002 INTO TABLE IT_PA0002
           FOR ALL ENTRIES IN IT_PA0000
           WHERE PERNR = IT_PA0000-PERNR.

    SELECT PERNR
           BETRG
           FROM PA0021 INTO TABLE IT_PA0021
           FOR ALL ENTRIES IN IT_PA0000
           WHERE PERNR = IT_PA0000-PERNR.

    SELECT PERNR
           VERSL
           FROM PA2010 INTO TABLE IT_PA2010
           FOR ALL ENTRIES IN IT_PA0000
           WHERE PERNR = IT_PA0000-PERNR.

    SELECT PERNR
           ESINM
           FROM PA0588 INTO TABLE IT_PA0588
           FOR ALL ENTRIES IN IT_PA0000
           WHERE PERNR = IT_PA0000-PERNR.
  ENDIF.

  SELECT PERSK
         PTEXT
       FROM T503T INTO TABLE IT_T503T
       FOR ALL ENTRIES IN IT_PA0001
       WHERE PERSK  = IT_PA0001-PERSK.



  YEAR = SY-DATUM+(4).
  MONTH = SY-DATUM+4(2).

  CALL FUNCTION 'NUMBER_OF_DAYS_PER_MONTH_GET'
    EXPORTING
      PAR_MONTH = MONTH
      PAR_YEAR  = YEAR
    IMPORTING
      PAR_DAYS  = DAYS.


  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      DOMAIN_NAME   = 'GESCH'
*     GET_STATE     = 'M  '
      LANGU         = SY-LANGU
*     PRID          = 0
      WITHTEXT      = 'X'
*   IMPORTING
*     DD01V_WA_A    =
*     DD01V_WA_N    =
*     GOT_STATE     =
    TABLES
      DD07V_TAB_A   = IT_TABA
      DD07V_TAB_N   = IT_TABB
    EXCEPTIONS
      ILLEGAL_VALUE = 1
      OP_FAILURE    = 2
      OTHERS        = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM GET_FINAL.
*  IF IT_PA0000 IS NOT INITIAL.
*    CLEAR : SL.

  LOOP AT IT_PA0000 INTO WA_PA0000.
    SL = SL + 1.
    WA_FINAL-SL    = SL.
    WA_FINAL-PERNR = WA_PA0000-PERNR.

    READ TABLE IT_PA0001 INTO WA_PA0001
      WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-ENAME = WA_PA0001-ENAME.
      WA_FINAL-PERSK = WA_PA0001-PERSK.
    ENDIF.

    READ TABLE IT_PA0002 INTO WA_PA0002
     WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      LOOP AT IT_TABA INTO WA_TABA.
        IF WA_TABA-DOMVALUE_L = WA_PA0002-GESCH.
          WA_FINAL-GENDER = WA_TABA-DDTEXT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    READ TABLE IT_PA0021 INTO WA_PA0021
     WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-BETRG = WA_PA0021-BETRG.
    ENDIF.

    READ TABLE IT_PA2010 INTO WA_PA2010
     WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-VERSL = WA_PA2010-VERSL.
    ENDIF.

    READ TABLE IT_PA0588 INTO WA_PA0588
     WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-ESINM = WA_PA0588-ESINM.
    ENDIF.
    WA_FINAL-DAYS = DAYS.

    READ TABLE IT_T503T INTO WA_T503T
  WITH KEY PERSK  = WA_PA0001-PERSK.
    IF SY-SUBRC = 0.
      WA_FINAL-PTEXT = WA_T503T-PTEXT.
    ENDIF.

    CALL FUNCTION 'CU_READ_RGDIR'
      EXPORTING
        PERSNR          = WA_PA0000-PERNR
*       BUFFER          =
*       NO_AUTHORITY_CHECK       = ' '
*       IMPORTING
*       MOLGA           =
      TABLES
        IN_RGDIR        = IT_RGDIR
      EXCEPTIONS
        NO_RECORD_FOUND = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    IF IT_RGDIR[] IS NOT INITIAL.
      READ TABLE IT_RGDIR INTO WA_RGDIR INDEX 1.
    ENDIF.



    CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
      EXPORTING
*       CLUSTERID                    =
        EMPLOYEENUMBER               = WA_PA0000-PERNR
        SEQUENCENUMBER               = WA_RGDIR-SEQNR
*       READ_ONLY_BUFFER             = ' '
        READ_ONLY_INTERNATIONAL      = 'X'
*       ARC_GROUP                    = ' '
*       CHECK_READ_AUTHORITY         = 'X'
*       FILTER_CUMULATIONS           = 'X'
*       CLIENT                       =
* IMPORTING
*       VERSION_NUMBER_PAYVN         =
*       VERSION_NUMBER_PCL2          =
      CHANGING
        PAYROLL_RESULT               = PAYROLL
      EXCEPTIONS
        ILLEGAL_ISOCODE_OR_CLUSTERID = 1
        ERROR_GENERATING_IMPORT      = 2
        IMPORT_MISMATCH_ERROR        = 3
        SUBPOOL_DIR_FULL             = 4
        NO_READ_AUTHORITY            = 5
        NO_RECORD_FOUND              = 6
        VERSIONS_DO_NOT_MATCH        = 7
        ERROR_READING_ARCHIVE        = 8
        ERROR_READING_RELID          = 9
        OTHERS                       = 10.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    IT_RT[] = PAYROLL-INTER-RT[].

    LOOP AT IT_RT INTO WA_RT.
      CASE WA_RT-LGART.
        WHEN '/101'.  " Gross
          WA_FINAL-GROSS = WA_FINAL-GROSS + WA_RT-BETRG.
        WHEN '/560'.  " Net
          WA_FINAL-NET = WA_FINAL-NET + WA_RT-BETRG.
        WHEN '/1000'.  " BASIC
          WA_FINAL-BASICWAGES = WA_FINAL-BASICWAGES.
        WHEN '/1001'.  " DA
          WA_FINAL-DA = WA_FINAL-DA.
        WHEN '/1003'.  " HRA
          WA_FINAL-HRA = WA_FINAL-HRA.
        WHEN '/1004'.  " SPECIAL
          WA_FINAL-SPECIALALLOWANCE = WA_FINAL-SPECIALALLOWANCE.
      ENDCASE.
    ENDLOOP.

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR WA_FINAL.
  ENDLOOP.
*  ENDIF.
ENDFORM.

FORM FIELD_CATALOG.
  REFRESH IT_FCAT.
  DATA LV_COL TYPE I VALUE 0.
  IF IT_FINAL IS NOT INITIAL.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'SL'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'SERIAL NUMBER'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'PERNR'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'EMPLOYEE NUMBER'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'ENAME'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'EMPLOYEE NAME'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'PTEXT'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'EMPLOYEE DESIGNATION'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'GENDER'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'EMPLOYEE GENDER'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Daily rated/Weekly rated/Monthly rated'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'DAYS'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Wage Period/Weekly/Fortnight'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Total number of days worked during the week/FN/Month'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Unit of work done/Number of days done'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BETRG'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'DAILY RATE OF WAGES'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'OT Rate'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BASICWAGES'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Basic Wages'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'DA'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'DA'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'HRA'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'HRA'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'SPECIALALLOWANCE'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Special Allowance'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'VERSL'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'OT AMOUNT'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Leave wages including cash in lends'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Surrender Wages'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'GROSS'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Gross'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Master Gross'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Salary PY'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'ESINM'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'ESI'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Miscellaneous Expenses'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Washing Deductions'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Other If Any'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'NET'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Net Salary'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Signature with Date or Thumb Impression/ Cheque and Date in case of payment through Bank'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

    LV_COL            = LV_COL + 1.
    WA_FCAT-COL_POS   = LV_COL.
    WA_FCAT-FIELDNAME = 'BLANK'.
    WA_FCAT-TABNAME   = 'IT_FINAL'.
    WA_FCAT-SELTEXT_L = 'Total'.
    APPEND WA_FCAT TO IT_FCAT.
    CLEAR WA_FCAT.

  ENDIF.
ENDFORM.

FORM ALV_LAYOUT.

  WA_LAYOUT-ZEBRA             = 'X'. "Zebra looks
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'. "Column width optimized

  IF IT_FINAL IS NOT INITIAL.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK  = ' '
*       I_BYPASSING_BUFFER = ' '
*       I_BUFFER_ACTIVE    = ' '
        I_CALLBACK_PROGRAM = SY-REPID
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME   =
*       I_BACKGROUND_ID    = ' '
*       I_GRID_TITLE       =
*       I_GRID_SETTINGS    =
        IS_LAYOUT          = WA_LAYOUT
        IT_FIELDCAT        = IT_FCAT
*       IT_EXCLUDING       =
*       IT_SPECIAL_GROUPS  =
*       IT_SORT            =
*       IT_FILTER          =
*       IS_SEL_HIDE        =
*       I_DEFAULT          = 'X'
*       I_SAVE             = ' '
*       IS_VARIANT         =
*       IT_EVENTS          =
*       IT_EVENT_EXIT      =
*       IS_PRINT           =
*       IS_REPREP_ID       =
*       I_SCREEN_START_COLUMN             = 0
*       I_SCREEN_START_LINE               = 0
*       I_SCREEN_END_COLUMN               = 0
*       I_SCREEN_END_LINE  = 0
*       I_HTML_HEIGHT_TOP  = 0
*       I_HTML_HEIGHT_END  = 0
*       IT_ALV_GRAPHICS    =
*       IT_HYPERLINK       =
*       IT_ADD_FIELDCAT    =
*       IT_EXCEPT_QINFO    =
*       IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        T_OUTTAB           = IT_FINAL
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDFORM.
