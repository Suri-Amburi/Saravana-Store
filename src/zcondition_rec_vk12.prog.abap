*&---------------------------------------------------------------------*
*& Report ZCONDITION_REC_VK12
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCONDITION_REC_VK12.

TYPE-POOLS: TRUXS.

PARAMETERS: P_FILE TYPE  RLGRAP-FILENAME.

TYPES : BEGIN OF T_DATATAB,
          KSCHL(04) ,
          MATNR(40) ,
*          DATE(08) ,
          KBETR(11) ,
        END OF T_DATATAB ,


        BEGIN OF GTY_DISPLAY,
          KSCHL(04) ,
          MATNR(40) ,
          MSGTYP(1),
          MESSAGE1  TYPE CAMSG,
          MESSAGE2  TYPE CAMSG,
        END OF GTY_DISPLAY,
        GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.

DATA : IT_DATATAB  TYPE STANDARD TABLE OF T_DATATAB,
       IT_DATATAB1 TYPE STANDARD TABLE OF T_DATATAB,
       WA_DATATAB  TYPE T_DATATAB,
       WA_DATATAB1 TYPE T_DATATAB,
       GV_BDC_MODE TYPE CHAR1,
       CUPDATE     TYPE CHAR1,
       BDCDATA     LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
       MESSTAB     LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       IT_RAW      TYPE TRUXS_T_TEXT_DATA,
       IT_LOG      TYPE GTY_T_DISPLAY,
       WA_LOG      TYPE GTY_DISPLAY,
       IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
       WA_LAYOUT   TYPE SLIS_LAYOUT_ALV,
       ENAME       TYPE CHAR4,
       LV_TAB(5)   TYPE C.
DATA: L_REPID TYPE SYREPID .
GV_BDC_MODE = 'N'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      FIELD_NAME = 'P_FILE'
    IMPORTING
      FILE_NAME  = P_FILE.

START-OF-SELECTION.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_LINE_HEADER        = 'X'
      I_TAB_RAW_DATA       = IT_RAW
      I_FILENAME           = P_FILE
    TABLES
      I_TAB_CONVERTED_DATA = IT_DATATAB[]
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.

  IF SY-SUBRC <> 0.

    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSEIF IT_DATATAB[] IS NOT INITIAL.
*    DELETE IT_DATATAB[] INDEX 1.
*    IF IT_DATATAB[] IS NOT INITIAL.
    BREAK BREDDY.
    PERFORM BDC_CALL.
    PERFORM FIELD_CATLOG.
    PERFORM DISPLAY.
  ENDIF.
*&---------------------------------------------------------------------*
*& Form BDC_CALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_CALL .

  LOOP AT IT_DATATAB INTO WA_DATATAB.

    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                  WA_DATATAB-KSCHL.
    PERFORM BDC_DYNPRO      USING 'RV13A515' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'F001-LOW'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ONLI'.
    PERFORM BDC_FIELD       USING 'F001-LOW'
                                  WA_DATATAB-MATNR.
*    PERFORM BDC_FIELD       USING 'SEL_DATE'
*                                  WA_DATATAB-DATE.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1515'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KONP-KBETR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                                 WA_DATATAB-KBETR.
*    PERFORM BDC_TRANSACTION USING 'VK12'.
    CALL TRANSACTION 'VK12'
            USING BDCDATA
            MODE   GV_BDC_MODE
            UPDATE CUPDATE
            MESSAGES INTO MESSTAB.

    REFRESH : BDCDATA[].
    CLEAR : BDCDATA.

*    REFRESH MESSTAB.
    DATA: WA_MESSTAB TYPE BDCMSGCOLL.
    CLEAR : WA_MESSTAB.
    READ TABLE MESSTAB INTO WA_MESSTAB  .        "WITH KEY MSGTYP = 'E'.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        ID        = WA_MESSTAB-MSGID
        LANG      = 'EN'
        NO        = WA_MESSTAB-MSGNR
        V1        = WA_MESSTAB-MSGV1
        V2        = WA_MESSTAB-MSGV2
        V3        = WA_MESSTAB-MSGV3
        V4        = WA_MESSTAB-MSGV4
      IMPORTING
        MSG       = WA_LOG-MESSAGE2
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.


    IF WA_MESSTAB-MSGTYP = 'E'.
*      LOOP AT MESSTAB INTO WA_MESSTAB WHERE MSGTYP = 'E'.


      WA_LOG-MATNR = WA_DATATAB-MATNR.
      WA_LOG-MESSAGE2 = WA_MESSTAB-MSGV1 .

*        APPEND WA_LOG TO IT_LOG.
*        CLEAR WA_LOG.

*      ENDLOOP.
*      REFRESH MESSTAB.
    ELSEIF WA_MESSTAB-MSGTYP = 'S'.
*      CLEAR :WA_MESSTAB.
*      READ TABLE MESSTAB INTO WA_MESSTAB WITH KEY MSGTYP = 'S' .

*      IF SY-SUBRC = 0.
      WA_LOG-MATNR = WA_DATATAB-MATNR.
      WA_LOG-MESSAGE1 =  WA_MESSTAB-MSGV1     .                         "WA_MESSTAB-MSGV1.
      WA_LOG-MSGTYP = WA_MESSTAB-MSGTYP.

*      ENDIF.
    ENDIF.
    APPEND WA_LOG TO IT_LOG.
    CLEAR WA_LOG.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING   PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_FIELD  USING FNAM FVAL.
  IF FVAL IS NOT INITIAL."<> '/'."NODATA.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELD_CATLOG .

  PERFORM CREATE_FIELDCAT USING:

*      '01' '01' 'SL_NO'       'IT_LOG' 'L' 'Serial No',
    '01' '01' 'MATNR'     'IT_LOG' 'L' 'Material',
    '01' '02' 'KSCHL'      'IT_LOG' 'L' 'Condition Type',
    '01' '03' 'MSGTYP'      'IT_LOG' 'L' 'Msgtyp',
    '01' '04' 'MESSAGE1'    'IT_LOG' 'L' 'Status',
    '01' '05' 'MESSAGE2'    'IT_LOG' 'L' 'Details'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CREATE_FIELDCAT  USING     FP_ROWPOS    TYPE SYCUROW
                            FP_COLPOS    TYPE SYCUCOL
                            FP_FLDNAM    TYPE FIELDNAME
                            FP_TABNAM    TYPE TABNAME
                            FP_JUSTIF    TYPE CHAR1
                            FP_SELTEXT   TYPE DD03P-SCRTEXT_L..


  DATA: WA_FCAT    TYPE  SLIS_FIELDCAT_ALV.
  WA_FCAT-ROW_POS        =  FP_ROWPOS.     "Row
  WA_FCAT-COL_POS        =  FP_COLPOS.     "Column
  WA_FCAT-FIELDNAME      =  FP_FLDNAM.     "Field Name
  WA_FCAT-TABNAME        =  FP_TABNAM.     "Internal Table Name
  WA_FCAT-JUST           =  FP_JUSTIF.     "Screen Justified
  WA_FCAT-SELTEXT_L      =  FP_SELTEXT.    "Field Text

  APPEND WA_FCAT TO IT_FIELDCAT.

  CLEAR WA_FCAT.
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
  IF IT_LOG IS NOT INITIAL.

    WA_LAYOUT-ZEBRA = 'X'.
    WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK  = ' '
*       I_BYPASSING_BUFFER = ' '
*       I_BUFFER_ACTIVE    = ' '
        I_CALLBACK_PROGRAM = L_REPID
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
        IT_FIELDCAT        = IT_FIELDCAT
*       IT_EXCLUDING       =
*       IT_SPECIAL_GROUPS  =
*       IT_SORT            =
*       IT_FILTER          =
*       IS_SEL_HIDE        =
*       I_DEFAULT          = 'X'
        I_SAVE             = 'X'
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
*       O_PREVIOUS_SRAL_HANDLER           =
*     IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        T_OUTTAB           = IT_LOG
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDFORM.
