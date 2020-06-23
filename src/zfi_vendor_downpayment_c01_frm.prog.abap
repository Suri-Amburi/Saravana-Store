*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_DOWNPAYMENT_C01_FRM
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING FP_P_FILE TYPE LOCALFILE.

  DATA: LI_FILETABLE    TYPE FILETABLE,
        LX_FILETABLE    TYPE FILE_TABLE,
        LV_RETURN_CODE  TYPE I,
        LV_WINDOW_TITLE TYPE STRING.

  LV_WINDOW_TITLE = TEXT-002.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LV_WINDOW_TITLE
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      FILE_TABLE              = LI_FILETABLE
      RC                      = LV_RETURN_CODE
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE   LI_FILETABLE INTO LX_FILETABLE INDEX 1.
*
  FP_P_FILE = LX_FILETABLE-FILENAME.



*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.

ENDFORM.                    " GET_FILENAME


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM GET_DATA  CHANGING FP_I_EXCELTAB TYPE TY_T_EXCELTAB.

  DATA : LI_TEMP     TYPE TABLE OF ALSMEX_TABLINE,
         LW_TEMP     TYPE ALSMEX_TABLINE,
         LW_EXCELTAB TYPE TY_EXCELTAB,
         LV_MAT      TYPE MATNR,
         LW_INTERN   TYPE  KCDE_CELLS,
         LI_INTERN   TYPE STANDARD TABLE OF KCDE_CELLS,
         LV_INDEX    TYPE I,
         I_TYPE      TYPE TRUXS_T_TEXT_DATA.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH FP_I_EXCELTAB[].
    BREAK BREDDY.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = FP_I_EXCELTAB[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE FP_I_EXCELTAB INDEX 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .            "#EC *

*
  ENDIF.


ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM PROCESS_DATA  USING    FP_I_EXCELTAB TYPE TY_T_EXCELTAB.

  DATA : LV_COUNT    TYPE I,
         TEMP        TYPE CHAR1,
         LV_DATC     TYPE CHAR2,
         LV_DAT      TYPE NUMC2,
         LV_MONC     TYPE CHAR2,
         LV_MON      TYPE NUMC2,
         LV_YEAR     TYPE CHAR4,
         LV_DATE     TYPE CHAR8,
         LV_DATE1    TYPE CHAR8,
         LV_DATE2    TYPE CHAR8,
         LV_SNO      TYPE I VALUE 0,
         LW_EXCELTAB TYPE TY_EXCELTAB.

  DATA:WA_DOCUMENTHEADER TYPE BAPIACHE09,
       WA_ACCOUNTGL      TYPE BAPIACGL09,
       WA_ACCOUNTPAYABLE TYPE BAPIACAP09,
       WA_CURRENCYAMOUNT TYPE BAPIACCR09,
       WA_RETURN         TYPE BAPIRET2,

       I_ACCOUNTGL       TYPE TABLE OF BAPIACGL09,
       I_ACCOUNTPAYABLE  TYPE TABLE OF BAPIACAP09,
       I_CURRENCYAMOUNT  TYPE TABLE OF BAPIACCR09,
       I_RETURN          TYPE TABLE OF BAPIRET2.

*BREAK-POINT.
  LOOP AT FP_I_EXCELTAB INTO LW_EXCELTAB.
    LV_SNO = LV_SNO + 1.

    REPLACE ALL OCCURRENCES OF '.' IN LW_EXCELTAB-BLDAT WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN LW_EXCELTAB-BLDAT WITH '/'.
    REPLACE ALL OCCURRENCES OF '.' IN LW_EXCELTAB-BUDAT WITH '/'.
    REPLACE ALL OCCURRENCES OF '-' IN LW_EXCELTAB-BUDAT WITH '/'.

    SPLIT LW_EXCELTAB-BLDAT AT '/' INTO LV_MONC LV_DATC LV_YEAR.
    LV_MON = LV_MONC.
    LV_DAT = LV_DATC.
    CONCATENATE LV_YEAR LV_DAT LV_MON INTO LV_DATE1.
    CONDENSE LV_DATE1.
    CLEAR : LV_YEAR, LV_MON, LV_DAT, LV_MONC, LV_DATC.

    SPLIT LW_EXCELTAB-BUDAT AT '/' INTO LV_MONC LV_DATC LV_YEAR.
    LV_MON = LV_MONC.
    LV_DAT = LV_DATC.
    CONCATENATE LV_YEAR LV_DAT LV_MON INTO LV_DATE2.
    CONDENSE LV_DATE2.
    CLEAR : LV_YEAR, LV_MON, LV_DAT, LV_MONC, LV_DATC.

    SPLIT LW_EXCELTAB-ZFBDT AT '.' INTO LV_MONC LV_DATC LV_YEAR.
    LV_MON = LV_MONC.
    LV_DAT = LV_DATC.
    CONCATENATE LV_YEAR LV_DAT LV_MON INTO LV_DATE.
    CONDENSE LV_DATE.
    CLEAR : LV_YEAR, LV_MON, LV_DAT, LV_MONC, LV_DATC.

    REFRESH : I_ACCOUNTGL,
              I_ACCOUNTPAYABLE,
              I_CURRENCYAMOUNT,
              I_RETURN.

    CLEAR : WA_DOCUMENTHEADER,
            WA_ACCOUNTGL,
            WA_ACCOUNTPAYABLE,
            WA_CURRENCYAMOUNT,
            WA_RETURN.

    CONDENSE:LW_EXCELTAB-BLART,LW_EXCELTAB-XBLNR,LW_EXCELTAB-BUKRS,
             LW_EXCELTAB-NEWBS,LW_EXCELTAB-NEWKO,LW_EXCELTAB-WRBTR,LW_EXCELTAB-BUPLA,LW_EXCELTAB-ZUONR,LW_EXCELTAB-GSBER,
             LW_EXCELTAB-LIFNR,LW_EXCELTAB-BUPLA1,LW_EXCELTAB-ZUONR1,LW_EXCELTAB-GSBER1,
             LW_EXCELTAB-ZFBDT,LW_EXCELTAB-ZLSPR.


    WA_DOCUMENTHEADER-BUS_ACT    = 'RFBU'.
    WA_DOCUMENTHEADER-USERNAME   = SY-UNAME.
    WA_DOCUMENTHEADER-COMP_CODE  = LW_EXCELTAB-BUKRS.
    WA_DOCUMENTHEADER-DOC_DATE   = LV_DATE1.
    WA_DOCUMENTHEADER-PSTNG_DATE = LV_DATE2.
    WA_DOCUMENTHEADER-REF_DOC_NO = LW_EXCELTAB-XBLNR.
    WA_DOCUMENTHEADER-DOC_TYPE   = LW_EXCELTAB-BLART.   "'KZ'.
    WA_DOCUMENTHEADER-HEADER_TXT = LW_EXCELTAB-SGTXT.

    WA_ACCOUNTGL-ITEMNO_ACC = '0000000001'.
    WA_ACCOUNTGL-GL_ACCOUNT = LW_EXCELTAB-NEWKO.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_ACCOUNTGL-GL_ACCOUNT
      IMPORTING
        OUTPUT = WA_ACCOUNTGL-GL_ACCOUNT.
    WA_ACCOUNTGL-COMP_CODE  = LW_EXCELTAB-BUKRS.
    WA_ACCOUNTGL-BUS_AREA   = LW_EXCELTAB-GSBER1.
    WA_ACCOUNTGL-ITEM_TEXT  = LW_EXCELTAB-SGTXT1.
    WA_ACCOUNTGL-ALLOC_NMBR = LW_EXCELTAB-ZUONR1.
    APPEND WA_ACCOUNTGL TO I_ACCOUNTGL.
    CLEAR WA_ACCOUNTGL.

    WA_CURRENCYAMOUNT-ITEMNO_ACC = '0000000001'.
    IF LW_EXCELTAB-NEWBS1 = 50.
      WA_CURRENCYAMOUNT-AMT_DOCCUR = LW_EXCELTAB-WRBTR1 * -1.
    ENDIF.
    WA_CURRENCYAMOUNT-CURRENCY   = LW_EXCELTAB-WAERS.
    WA_CURRENCYAMOUNT-EXCH_RATE = LW_EXCELTAB-KURSF.
    APPEND WA_CURRENCYAMOUNT TO I_CURRENCYAMOUNT.
    CLEAR WA_CURRENCYAMOUNT.

    WA_ACCOUNTPAYABLE-ITEMNO_ACC  = '0000000002'.
    WA_ACCOUNTPAYABLE-VENDOR_NO   = LW_EXCELTAB-LIFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_ACCOUNTPAYABLE-VENDOR_NO
      IMPORTING
        OUTPUT = WA_ACCOUNTPAYABLE-VENDOR_NO.

    WA_ACCOUNTPAYABLE-COMP_CODE     = LW_EXCELTAB-BUKRS.
    WA_ACCOUNTPAYABLE-SP_GL_IND     = LW_EXCELTAB-UMSKZ.

    IF LW_EXCELTAB-UMSKZ = ''.
      TEMP = 'X'.
*    MESSAGE E208(00) WITH 'Error'.
    ENDIF.
    WA_ACCOUNTPAYABLE-BUSINESSPLACE = LW_EXCELTAB-BUPLA.
    WA_ACCOUNTPAYABLE-SECTIONCODE   = LW_EXCELTAB-SECCO.
    WA_ACCOUNTPAYABLE-BUS_AREA      = LW_EXCELTAB-GSBER.
    WA_ACCOUNTPAYABLE-ALLOC_NMBR    = LW_EXCELTAB-ZUONR.
    WA_ACCOUNTPAYABLE-ITEM_TEXT     = LW_EXCELTAB-SGTXT.
    WA_ACCOUNTPAYABLE-BLINE_DATE    = LV_DATE1.
    WA_ACCOUNTPAYABLE-PMNT_BLOCK    = LW_EXCELTAB-ZLSPR.

    APPEND WA_ACCOUNTPAYABLE TO I_ACCOUNTPAYABLE.
    CLEAR WA_ACCOUNTPAYABLE.

    WA_CURRENCYAMOUNT-ITEMNO_ACC = '0000000002'.
    WA_CURRENCYAMOUNT-AMT_DOCCUR = LW_EXCELTAB-WRBTR.
    WA_CURRENCYAMOUNT-CURRENCY   = LW_EXCELTAB-WAERS.
    WA_CURRENCYAMOUNT-EXCH_RATE = LW_EXCELTAB-KURSF.
    APPEND WA_CURRENCYAMOUNT TO I_CURRENCYAMOUNT.
    CLEAR WA_CURRENCYAMOUNT.


*    BREAK-POINT.
    IF TEMP <> 'X'.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          DOCUMENTHEADER = WA_DOCUMENTHEADER
        TABLES
          ACCOUNTGL      = I_ACCOUNTGL
          ACCOUNTPAYABLE = I_ACCOUNTPAYABLE
          CURRENCYAMOUNT = I_CURRENCYAMOUNT
          RETURN         = I_RETURN.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ELSE.
      WA_ERRMSG-SNO = LV_SNO.
      WA_ERRMSG-MSGTYP = 'E'.
      WA_ERRMSG-MESSG = 'Spl GL indicator is blank'.
      APPEND WA_ERRMSG TO I_ERRMSG.
      CLEAR: WA_ERRMSG,TEMP.
    ENDIF.


    LOOP AT I_RETURN INTO WA_RETURN.
      IF WA_RETURN-TYPE EQ 'E'.
        WA_ERRMSG-SNO = LV_SNO.
        WA_ERRMSG-MSGTYP = WA_RETURN-TYPE.
*        wa_errmsg-xblnr = wa_return-ref_doc_no.
*        wa_errmsg-bktxt = wa_return-header_txt.
        WA_ERRMSG-MESSG = WA_RETURN-MESSAGE.
        APPEND WA_ERRMSG TO I_ERRMSG.
        CLEAR WA_ERRMSG.
        CLEAR WA_MSG.

      ELSEIF WA_RETURN-TYPE EQ 'S'.
        DATA : LV_STR1 TYPE STRING VALUE 'Document',
               LV_STR2 TYPE STRING,
               LV_STR3 TYPE STRING VALUE 'was posted in company code',
               LV_STR4 TYPE STRING.

        LV_STR2 = WA_RETURN-MESSAGE_V2+0(10).
        LV_STR4 = WA_RETURN-MESSAGE_V2+10(4).

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_STR2
          IMPORTING
            OUTPUT = LV_STR2.

        CONCATENATE LV_STR1 LV_STR2 LV_STR3 LV_STR4 INTO WA_ERRMSG-MESSG SEPARATED BY SPACE.

        WA_ERRMSG-SNO = LV_SNO.
        WA_ERRMSG-MSGTYP = WA_RETURN-TYPE.
*        wa_errmsg-xblnr = wa_header-ref_doc_no.
*        wa_errmsg-bktxt = wa_header-header_txt.
        WA_ERRMSG-DOCNUM = LV_STR2.
        APPEND WA_ERRMSG TO I_ERRMSG.
        CLEAR : LV_STR2, LV_STR4.
        CLEAR WA_ERRMSG.
        CLEAR WA_MSG.
      ENDIF.
    ENDLOOP.

    CLEAR : LV_DATE1, LV_DATE2.
    CLEAR LW_EXCELTAB.
*    CLEAR wa_header.
*    REFRESH i_item[].
*    REFRESH i_curr[].
    REFRESH I_MSGT[].

  ENDLOOP.

ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  ERRMSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MSG  text
*----------------------------------------------------------------------*
FORM ERRMSG  USING    FP_I_ERRMSG TYPE TY_T_ERRMSG.

  PERFORM BUILD_FIELDCAT CHANGING I_FIELDCATALOG.

ENDFORM.                    " ERRMSG
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT  CHANGING FP_I_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  PERFORM FIELDCAT USING '1' 'SNO'    'Line No'              '4'   CHANGING FP_I_FIELDCAT.
  PERFORM FIELDCAT USING '2' 'DOCNUM' 'Document Number'      '15'  CHANGING FP_I_FIELDCAT.
*  PERFORM fieldcat USING '3' 'XBLNR'  'Reference'            '16'  CHANGING fp_i_fieldcat.
*  PERFORM fieldcat USING '4' 'BKTXT'  'Document Header Text' '25'  CHANGING fp_i_fieldcat.
  PERFORM FIELDCAT USING '5' 'MESSG'  'Messages Log'         '80' CHANGING FP_I_FIELDCAT.

  PERFORM DISP_ERRMSG USING I_ERRMSG.

ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0531   text
*      -->P_0532   text
*      -->P_0533   text
*      -->P_0534   text
*      <--P_FP_I_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM FIELDCAT  USING    P_POS1 TYPE SYCUCOL
                        P_FNAME1 TYPE SLIS_FIELDNAME
                        P_STXT1 TYPE SCRTEXT_L
                        P_OUTL1 TYPE DD03P-OUTPUTLEN
               CHANGING FP_I_FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV.

  DATA : LW_FIELDCAT TYPE SLIS_FIELDCAT_ALV.


  LW_FIELDCAT-COL_POS = P_POS1.
  LW_FIELDCAT-FIELDNAME = P_FNAME1.
  LW_FIELDCAT-SELTEXT_L = P_STXT1.
  LW_FIELDCAT-TABNAME = 'I_ERRMSG'.
  LW_FIELDCAT-OUTPUTLEN = P_OUTL1.
  APPEND LW_FIELDCAT TO FP_I_FIELDCATALOG.
  CLEAR LW_FIELDCAT.

ENDFORM.                    " FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  DISP_ERRMSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ERRMSG  text
*----------------------------------------------------------------------*
FORM DISP_ERRMSG  USING    FP_I_ERRMSG TYPE TY_T_ERRMSG.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      I_CALLBACK_PROGRAM          = SY-CPROG
*     I_CALLBACK_PF_STATUS_SET    = ' '
*     I_CALLBACK_USER_COMMAND     = ' '
*     I_CALLBACK_TOP_OF_PAGE      = ' '
      I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     I_BACKGROUND_ID             = ' '
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
*     IS_LAYOUT                   =
      IT_FIELDCAT                 = I_FIELDCATALOG
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS           =
*     IT_SORT                     =
*     IT_FILTER                   =
*     IS_SEL_HIDE                 =
      I_DEFAULT                   = 'X'
*     I_SAVE                      = ' '
*     IS_VARIANT                  =
*     IT_EVENTS                   =
*     IT_EVENT_EXIT               =
*     IS_PRINT                    =
*     IS_REPREP_ID                =
*     I_SCREEN_START_COLUMN       = 0
*     I_SCREEN_START_LINE         = 0
*     I_SCREEN_END_COLUMN         = 0
*     I_SCREEN_END_LINE           = 0
*     I_HTML_HEIGHT_TOP           = 0
*     I_HTML_HEIGHT_END           = 0
*     IT_ALV_GRAPHICS             =
*     IT_HYPERLINK                =
*     IT_ADD_FIELDCAT             =
*     IT_EXCEPT_QINFO             =
*     IR_SALV_FULLSCREEN_ADAPTER  =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER     =
*     ES_EXIT_CAUSED_BY_USER      =
    TABLES
      T_OUTTAB                    = FP_I_ERRMSG
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISP_ERRMSG
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TOP        text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE USING TOP TYPE REF TO CL_DD_DOCUMENT.      "#EC CALLED

  CALL METHOD TOP->ADD_GAP    "method to provide space in heading
    EXPORTING
      WIDTH = 130.


  CALL METHOD TOP->ADD_TEXT    "method to provide heading
    EXPORTING
      TEXT      = 'Return Messages Log'
      SAP_STYLE = 'HEADING'.


ENDFORM. " TOP_OF_PAGE
