*&---------------------------------------------------------------------*
*& Report ZMM_CHANGE_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_CHANGE_UPLOAD.

TYPE-POOLS: TRUXS.

PARAMETERS: P_FILE TYPE  RLGRAP-FILENAME.

TYPES : BEGIN OF T_DATATAB,
          SL_NO(06) TYPE C,
          MATNR(40),
*          MAKTX(40),
          IDNRK(40),
          CPQTY(10),
        END OF T_DATATAB,

        BEGIN OF GTY_DISPLAY,
          SL_NO(06) TYPE C,
          MATNR(40),
*          MAKTX(40),
          IDNRK(40),
          CPQTY(10),
          MSGTYP(1),
          MESSAGE1  TYPE CAMSG,
          MESSAGE2  TYPE CAMSG,
        END OF GTY_DISPLAY,
        GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.

DATA : IT_DATATAB   TYPE STANDARD TABLE OF T_DATATAB,
       IT_DATATAB1  TYPE STANDARD TABLE OF T_DATATAB,
       WA_DATATAB   TYPE T_DATATAB,
       WA_DATATAB_D TYPE T_DATATAB,
       WA_DATATAB1  TYPE T_DATATAB,
       GV_BDC_MODE  TYPE CHAR1,
       CUPDATE      TYPE CHAR1,
       BDCDATA      LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
       MESSTAB      LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       IT_RAW       TYPE TRUXS_T_TEXT_DATA,
       IT_LOG       TYPE GTY_T_DISPLAY,
       WA_LOG       TYPE GTY_DISPLAY,
       IT_FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV,
       WA_LAYOUT    TYPE SLIS_LAYOUT_ALV,
       ENAME        TYPE CHAR4,
       LV_TAB(5)    TYPE C,
       LV_SL_NO     TYPE I VALUE 1.


GV_BDC_MODE = 'N'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      FIELD_NAME = 'P_FILE'
    IMPORTING
      FILE_NAME  = P_FILE.

START-OF-SELECTION.

*  BREAK BREDDY.
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


  ELSEIF IT_DATATAB[] IS NOT INITIAL .

    BREAK BREDDY.
    PERFORM BDC_CALL.
    PERFORM FIELD_CATLOG.
    PERFORM DISPLAY.


*    ENDIF.
  ENDIF.
*&---------------------------------------------------------------------*
*& Form BDC_CALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_CALL.
*  REFRESH : BDCDATA[].
  IT_DATATAB1[] = IT_DATATAB.
  SORT IT_DATATAB BY SL_NO MATNR.
  DELETE ADJACENT DUPLICATES FROM IT_DATATAB COMPARING SL_NO  MATNR.

  LOOP AT IT_DATATAB INTO WA_DATATAB.
    LV_TAB = 1.
    CALL FUNCTION 'CONVERSION_EXIT_MATN2_INPUT'
      EXPORTING
        INPUT            = WA_DATATAB-MATNR
      IMPORTING
        OUTPUT           = WA_DATATAB-MATNR
      EXCEPTIONS
        NUMBER_NOT_FOUND = 1
        LENGTH_ERROR     = 2
        OTHERS           = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
*    PERFORM BDC_DYNPRO      USING 'SAPLMGMW' '0100'.
    PERFORM BDC_DYNPRO      USING 'SAPLMGMW' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'MSICHTAUSW-DYTXT(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RMMW1-MATNR'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM BDC_FIELD       USING 'RMMW1-MATNR'
                                   WA_DATATAB-MATNR.                                   ""RECORD-MATNR_001. Material
    PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(01)'
                                   'X'        .                                           ""RECORD-KZSEL_01_002. Basic Data
    PERFORM BDC_DYNPRO      USING 'SAPLMGMW' '4008'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PB47'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'MAKT-MAKTX'.
*    PERFORM BDC_FIELD       USING 'MAKT-MAKTX'
*                                  WA_DATATAB-MAKTX.                                                   ""RECORD-MAKTX_003. Description
*    PERFORM BDC_FIELD       USING 'MARA-TAKLV'
*                                 RECORD-TAKLV_004.
*    PERFORM BDC_FIELD       USING 'MAW1-WBKLA'
*                                  RECORD-WBKLA_005.
*    PERFORM BDC_FIELD       USING 'MAW1-WLADG'
*                                  RECORD-WLADG_006.
*    PERFORM BDC_FIELD       USING 'MARA-MTPOS_MARA'
*                                  RECORD-MTPOS_MARA_007.
*    PERFORM BDC_FIELD       USING 'MARA-DATAB'
*                                  RECORD-DATAB_008.
*    PERFORM BDC_FIELD       USING 'MARA-IPRKZ'
*                                  RECORD-IPRKZ_009.
*    BREAK BREDDY.
*    CLEAR : SY-TABIX.
*    SY-TABIX = 1.
    LV_TAB = '01' .
    LOOP AT IT_DATATAB1 INTO WA_DATATAB1 WHERE SL_NO = WA_DATATAB-SL_NO.

*     lv_tab = 1 .
*      PERFORM BDC_DYNPRO      USING 'SAPLWST1' '0200'.      " Change By Suri : 05.08.2019
      PERFORM BDC_DYNPRO      USING 'SAPLWST1' '0100'.       " Change By Suri : 05.08.2019
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'WSTR_DYNP-CPQTY(03)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'

                                    '/00'.
      CONCATENATE 'WSTR_DYNP-IDNRK(' LV_TAB ')' INTO DATA(LV_DATA).
      CONCATENATE 'WSTR_DYNP-CPQTY(' LV_TAB ')' INTO DATA(LV_QTY).
      CONDENSE LV_DATA NO-GAPS .
      CONDENSE LV_QTY NO-GAPS .
*      CASE LV_TAB.
*
*        WHEN '1'.
      PERFORM BDC_FIELD       USING LV_DATA "'WSTR_DYNP-IDNRK(01)'
                                     WA_DATATAB1-IDNRK.                                                 "" RECORD-IDNRK_01_010.components
      PERFORM BDC_FIELD       USING  LV_QTY  "'WSTR_DYNP-CPQTY(01)'
                                     WA_DATATAB1-CPQTY.

      LV_TAB  = LV_TAB + '01' .                                                                                              "" RECORD-CPQTY_01_013.quantity
*        WHEN '2'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(02)'
*                                         WA_DATATAB1-IDNRK.                                                ""RECORD-IDNRK_02_011.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(02)'
*                                         WA_DATATAB1-CPQTY.                                                                          ""RECORD-CPQTY_02_014.
*        WHEN  '3'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(03)'
*                                         WA_DATATAB1-IDNRK.                                                                   ""RECORD-IDNRK_03_012.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(03)'
*                                         WA_DATATAB1-CPQTY.
*        WHEN  '4'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(04)'
*                                         WA_DATATAB1-IDNRK.                                                 "" RECORD-IDNRK_01_010.components
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(04)'
*                                         WA_DATATAB1-CPQTY.                                                                 "" RECORD-CPQTY_01_013.quantity
*        WHEN  '5'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(05)'
*                                         WA_DATATAB1-IDNRK.                                                ""RECORD-IDNRK_02_011.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(05)'
*                                         WA_DATATAB1-CPQTY.                                                                          ""RECORD-CPQTY_02_014.
*        WHEN  '6'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(06)'
*                                         WA_DATATAB1-IDNRK.                                                                   ""RECORD-IDNRK_03_012.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(06)'
*                                         WA_DATATAB1-CPQTY.
*
*        WHEN  '7'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(07)'
*                                         WA_DATATAB1-IDNRK.                                                 "" RECORD-IDNRK_01_010.components
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(07)'
*                                         WA_DATATAB1-CPQTY.                                                                 "" RECORD-CPQTY_01_013.quantity
*        WHEN  '8'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(08)'
*                                         WA_DATATAB1-IDNRK.                                                ""RECORD-IDNRK_02_011.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(08)'
*                                         WA_DATATAB1-CPQTY.                                                                          ""RECORD-CPQTY_02_014.
*        WHEN  '9'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(09)'
*                                         WA_DATATAB1-IDNRK.                                                                   ""RECORD-IDNRK_03_012.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(09)'
*                                         WA_DATATAB1-CPQTY.
*        WHEN  '10'.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-IDNRK(10)'
*                                         WA_DATATAB1-IDNRK.                                                                   ""RECORD-IDNRK_03_012.
*          PERFORM BDC_FIELD       USING 'WSTR_DYNP-CPQTY(10)'
*                                         WA_DATATAB1-CPQTY.
*      ENDCASE.

*      LV_TAB = LV_TAB + 1.
    ENDLOOP.
    CLEAR : LV_TAB.
*    PERFORM BDC_DYNPRO      USING 'SAPLWST1' '0200'.    "" Change By Suri : 05.08.2019
    PERFORM BDC_DYNPRO      USING 'SAPLWST1' '0100'.    "" Change By Suri : 05.08.2019
*    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                  'WSTR_DYNP-SATNR'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BACK'.
    PERFORM BDC_DYNPRO      USING 'SAPLMGMW' '4008'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.
*    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                  'MAKT-MAKTX'.
*    PERFORM BDC_FIELD       USING 'MAKT-MAKTX'
*                                  RECORD-MAKTX_016.
*    PERFORM BDC_FIELD       USING 'MARA-TAKLV'
*                                  RECORD-TAKLV_017.
*    PERFORM BDC_FIELD       USING 'MAW1-WBKLA'
*                                  RECORD-WBKLA_018.
*    PERFORM BDC_FIELD       USING 'MAW1-WLADG'
*                                  RECORD-WLADG_019.
*    PERFORM BDC_FIELD       USING 'MARA-MTPOS_MARA'
*                                  RECORD-MTPOS_MARA_020.
*    PERFORM BDC_FIELD       USING 'MARA-DATAB'
*                                  RECORD-DATAB_021.
*    PERFORM BDC_FIELD       USING 'MARA-IPRKZ'
*                                  RECORD-IPRKZ_022.
    CALL TRANSACTION 'MM42'
                    USING BDCDATA
                    MODE   GV_BDC_MODE
                    UPDATE CUPDATE
                    MESSAGES INTO MESSTAB.
    REFRESH : BDCDATA[].
    CLEAR : BDCDATA.
*    SELECT  IDNRK FROM STPO INTO TABLE @DATA(IT_STPO)
*                 FOR ALL ENTRIES IN @IT_DATATAB1
*                 WHERE IDNRK = @IT_DATATAB1-IDNRK .
**    READ TABLE IT_STPO ASSIGNING FIELD-SYMBOL(<WA_STPO>) WITH KEY IDNRK = WA_DATATAB-IDNRK.
*
*    IF SY-SUBRC <> 0 .
*
*
*      WA_LOG-SL_NO = LV_SL_NO.
*      WA_LOG-MATNR = WA_DATATAB-MATNR.
**      WA_LOG-MAKTX = WA_DATATAB-MAKTX.
*      WA_LOG-IDNRK = WA_DATATAB-IDNRK.
*      WA_LOG-CPQTY = WA_DATATAB-CPQTY.
*      WA_LOG-MESSAGE2 = 'COMPONENTS DOESNOT ASSIGNED' .
*
*
*      APPEND WA_LOG TO IT_LOG.
*      CLEAR WA_LOG.
*
*
*
*    ENDIF.


    DATA: WA_MESSTAB TYPE BDCMSGCOLL.
    READ TABLE MESSTAB INTO WA_MESSTAB WITH KEY MSGTYP = 'E'.
*    BREAK BREDDY .
    IF SY-SUBRC = 0.

      LOOP AT MESSTAB INTO WA_MESSTAB WHERE MSGTYP = 'E'.
        WA_LOG-SL_NO = LV_SL_NO.
        WA_LOG-MATNR = WA_DATATAB-MATNR.
*        WA_LOG-MAKTX = WA_DATATAB-MAKTX.
        WA_LOG-IDNRK = WA_DATATAB-IDNRK.
        WA_LOG-CPQTY = WA_DATATAB-CPQTY.
        WA_LOG-MESSAGE2 = WA_MESSTAB-MSGV1 .

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

        APPEND WA_LOG TO IT_LOG.
        CLEAR WA_LOG.

      ENDLOOP.

      REFRESH MESSTAB.
    ELSE.
      READ TABLE MESSTAB INTO WA_MESSTAB WITH KEY MSGTYP = 'S' .

      IF SY-SUBRC = 0.
        WA_LOG-SL_NO = LV_SL_NO .
        WA_LOG-MATNR = WA_DATATAB-MATNR.
*        WA_LOG-IDNRK = WA_DATATAB-IDNRK.
*        WA_LOG-MESSAGE2 = WA_MESSTAB-MSGV1 . "'Component Assigned'.
        WA_LOG-MSGTYP = WA_MESSTAB-MSGTYP . "'Component Assigned'.

        APPEND WA_LOG TO IT_LOG.
        CLEAR WA_LOG.

        LOOP AT IT_DATATAB1 INTO WA_DATATAB1 WHERE MATNR = WA_DATATAB-MATNR .
*             WA_LOG-MATNR = WA_DATATAB-MATNR.
          WA_LOG-IDNRK = WA_DATATAB1-IDNRK.
          WA_LOG-MESSAGE2 = 'Component Assigned'.

          APPEND WA_LOG TO IT_LOG.
          CLEAR WA_LOG.
        ENDLOOP.
        REFRESH MESSTAB.
      ENDIF.

    ENDIF.

*    SELECT SINGLE IDNRK FROM STPO INTO  @DATA(WA_STPO)
**              FOR ALL ENTRIES IN @IT_DATATAB
*              WHERE IDNRK = @WA_DATATAB-IDNRK .
*
**    READ TABLE IT_STPO ASSIGNING FIELD-SYMBOL(<WA_STPO>) WITH KEY IDNRK = WA_DATATAB1-IDNRK.
*
*    IF SY-SUBRC <> 0 .
*
*
*      WA_LOG-SL_NO = LV_SL_NO.
*      WA_LOG-MATNR = WA_DATATAB-MATNR.
**      WA_LOG-MAKTX = WA_DATATAB-MAKTX.
*      WA_LOG-IDNRK = WA_DATATAB-IDNRK.
*      WA_LOG-CPQTY = WA_DATATAB-CPQTY.
*      WA_LOG-MESSAGE2 = 'COMPONENTS DOESNOT ASSIGNED' .
*
*
*      APPEND WA_LOG TO IT_LOG.
*      CLEAR : WA_LOG , WA_DATATAB-IDNRK.
*
*
*
*    ENDIF.


    LV_SL_NO =  LV_SL_NO  + 1.
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
FORM BDC_DYNPRO  USING    PROGRAM DYNPRO.
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
        '01' '01' 'SL_NO'       'IT_LOG' 'L' 'Serial No',
        '01' '02' 'MATNR'       'IT_LOG' 'L' 'Material',
        '01' '03' 'IDNRK'       'IT_LOG' 'L' 'Components',
        '01' '04' 'MSGTYP'      'IT_LOG' 'L' 'Msgtyp',
        '01' '05' 'message1'    'IT_LOG' 'L' 'Status',
        '01' '06' 'message2'    'IT_LOG' 'L' 'Details'.

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
FORM CREATE_FIELDCAT  USING  FP_ROWPOS    TYPE SYCUROW
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

  DATA: L_REPID TYPE SYREPID .


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
* IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        T_OUTTAB           = IT_LOG
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.
