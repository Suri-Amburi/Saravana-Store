*&---------------------------------------------------------------------*
*& Include          ZFI_IBANKMASTER_C02_FORMS
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
*      <--P_IT_FILE  text
*----------------------------------------------------------------------*
FORM GET_DATA  CHANGING I_FILE TYPE TY_T_FILE.

  DATA:I_TYPE TYPE TRUXS_T_TEXT_DATA.
*  *  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH I_FILE[].

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = I_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE I_FILE FROM 1 TO 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    MESSAGE E398(00) WITH 'INVALID FILE TYPE'  .
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_FILE  text
*----------------------------------------------------------------------*
FORM PROCESS_DATA  USING    P_IT_FILE.

  LOOP AT IT_FILE INTO WA_FILE.

    REFRESH IT_BDCDATA.

*perform open_group.

    PERFORM BDC_DYNPRO      USING 'SAPMF02B' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'BNKA-BANKL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.

    PERFORM BDC_FIELD       USING 'BNKA-BANKS'
                                  WA_FILE-COUNTRY. "'in'.
    PERFORM BDC_FIELD       USING 'BNKA-BANKL'
                                  WA_FILE-BANKKEY.    "'BKID0000007'.
    PERFORM BDC_DYNPRO      USING 'SAPMF02B' '0110'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'BNKA-BANKA'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ADDR'.
    PERFORM BDC_FIELD       USING 'BNKA-BANKA'
                                  WA_FILE-BANKNAME.   "'Bank Of India'.
    PERFORM BDC_DYNPRO      USING 'SAPLSZA1' '0201'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'ADDR1_DATA-REGION'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=CONT'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-NAME1'
                                  WA_FILE-BANKNAME1.  "'Bank Of India'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-STREET'
                                  WA_FILE-STREET.     "'Breach Candy,Sky Scraper A,4/697, Bhul'
*                                & 'abhai Desai,Mumbai'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-POST_CODE1'
                                  WA_FILE-PINCODE.          "'400026'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-CITY1'
                                  WA_FILE-CITY.     "'Mumbai'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-COUNTRY'
                                  WA_FILE-COUNTRY1.   "'IN'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-REGION'
                                  WA_FILE-REGION.   "'13'.
    PERFORM BDC_FIELD       USING 'ADDR1_DATA-LANGU'
                                  'EN'.
    PERFORM BDC_DYNPRO      USING 'SAPMF02B' '0110'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'BNKA-BANKA'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=UPDA'.
    PERFORM BDC_FIELD       USING 'BNKA-BANKA'
                                  WA_FILE-BANKNAME.

    CALL TRANSACTION 'FI01' USING IT_BDCDATA
                              MODE CTUMODE
                            UPDATE CUPDATE
                            MESSAGES INTO IT_BDCMSGCOLL.

    READ TABLE IT_BDCMSGCOLL INTO WA_BDCMSGCOLL INDEX 1.

    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        ID   = SY-MSGID
        LANG = SY-LANGU
        NO   = SY-MSGNO
        V1   = SY-MSGV1
        V2   = SY-MSGV2
        V3   = SY-MSGV3
        V4   = SY-MSGV4
      IMPORTING
        MSG  = V_TEXT.

    IF SY-SUBRC EQ '0'.

      COUNT = COUNT + 1.

      IT_ERROR-RECORD = COUNT.
      IT_ERROR-MESSAGE = V_TEXT.

      APPEND IT_ERROR.

    ENDIF.

    REFRESH:IT_BDCMSGCOLL.
    CLEAR:IT_ERROR,WA_BDCMSGCOLL,WA_FILE,V_TEXT.

  ENDLOOP.

ENDFORM.

FORM BDC_DYNPRO USING PROGRAM DYNPRO.

  CLEAR WA_BDCDATA.

  WA_BDCDATA-PROGRAM  = PROGRAM.
  WA_BDCDATA-DYNPRO   = DYNPRO.
  WA_BDCDATA-DYNBEGIN = 'X'.
  APPEND WA_BDCDATA TO IT_BDCDATA.

ENDFORM.

FORM BDC_FIELD USING FNAM FVAL.

  CLEAR WA_BDCDATA.

  WA_BDCDATA-FNAM  =   FNAM.
  WA_BDCDATA-FVAL  =   FVAL.

  APPEND WA_BDCDATA TO IT_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELDCAT .

  WA_FCAT-FIELDNAME = 'RECORD'.
  WA_FCAT-TABNAME   = 'IT_ERROR'.
  WA_FCAT-OUTPUTLEN = '5'.
  WA_FCAT-SELTEXT_M = 'SNO'.
  APPEND WA_FCAT TO IT_FCAT.

  WA_FCAT-FIELDNAME = 'MESSAGE'.
  WA_FCAT-TABNAME   = 'IT_ERROR'.
  WA_FCAT-OUTPUTLEN = '100'.
  WA_FCAT-SELTEXT_M = 'Error Descrption'.
  APPEND WA_FCAT TO IT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

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
      IT_FIELDCAT                 = IT_FCAT
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS           =
*     IT_SORT                     =
*     IT_FILTER                   =
*     IS_SEL_HIDE                 =
      I_DEFAULT                   = 'X'
      I_SAVE                      = 'X'
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
      T_OUTTAB                    = IT_ERROR
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

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
      TEXT      = 'RETURN MESSAGES LOG'
      SAP_STYLE = 'HEADING'.


ENDFORM. " TOP_OF_PAGE
