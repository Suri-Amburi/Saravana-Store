*&---------------------------------------------------------------------*
*& Form BDC_CALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_CALL .
  IF P_VK12 IS NOT INITIAL .

    SELECT
      A502~LIFNR ,
      A502~MATNR ,
      A502~KSCHL ,
      A502~KNUMH FROM A502 INTO TABLE @DATA(IT_A502)
      FOR ALL ENTRIES IN @IT_DATATAB
     WHERE  MATNR = @IT_DATATAB-MATNR
      AND LIFNR = @IT_DATATAB-LIFNR
      AND KSCHL = @IT_DATATAB-KSCHL.

    IF IT_A502 IS NOT INITIAL.
      SELECT
        KONP~KNUMH ,
        KONP~LOEVM_KO FROM KONP INTO TABLE @DATA(IT_KONP)
        FOR ALL ENTRIES IN @IT_A502
        WHERE KNUMH = @IT_A502-KNUMH
        AND LOEVM_KO = ' '.

    ENDIF.



    LOOP AT IT_DATATAB INTO WA_DATATAB.


      READ TABLE IT_A502 ASSIGNING FIELD-SYMBOL(<LS_A502>) WITH KEY  MATNR = WA_DATATAB-MATNR LIFNR = WA_DATATAB-LIFNR KSCHL = WA_DATATAB-KSCHL.
      IF SY-SUBRC = 0.
        READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP>) WITH KEY KNUMH = <LS_A502>-KNUMH LOEVM_KO = ' '.
        IF SY-SUBRC = 0.

          PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RV13A-KSCHL'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                        WA_DATATAB-KSCHL.             "" 'zmkp'.
          PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RV130-SELKZ(02)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=WEIT'.
          PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                                        ''.
          PERFORM BDC_FIELD       USING 'RV130-SELKZ(02)'
                                        'X'.
          PERFORM BDC_DYNPRO      USING 'RV13A502' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'F002-LOW'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ONLI'.
          PERFORM BDC_FIELD       USING 'F001'
                                        WA_DATATAB-LIFNR.                   ""'SC0002277'.
          PERFORM BDC_FIELD       USING 'F002-LOW'
                                        WA_DATATAB-MATNR.          "" '10115-FREE'.
*perform bdc_field       using 'SEL_DATE'
*                              '17.10.2019'.
          PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'KOMG-MATNR(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ENTF'.
          PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                                        'X'.
          PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'KOMG-MATNR(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=SICH'.
*perform bdc_transaction using 'VK12'.

          CALL TRANSACTION 'VK12'
                  USING BDCDATA
                  MODE   GV_BDC_MODE
                  UPDATE CUPDATE
                  MESSAGES INTO MESSTAB.
          WAIT UP TO 1 SECONDS .
          REFRESH : BDCDATA[].
          CLEAR : BDCDATA.

          DATA: WA_MESSTAB TYPE BDCMSGCOLL.
          CLEAR : WA_MESSTAB.
*      BREAK BREDDY .
          READ TABLE MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSTAB>) WITH KEY MSGTYP = 'E'.
          IF SY-SUBRC = 0.
            LOOP AT MESSTAB ASSIGNING <LS_MESSTAB> WHERE MSGTYP = 'E'.
              CLEAR WA_LOG.
              CALL FUNCTION 'FORMAT_MESSAGE'
                EXPORTING
                  ID        = <LS_MESSTAB>-MSGID
                  LANG      = 'EN'
                  NO        = <LS_MESSTAB>-MSGNR
                  V1        = <LS_MESSTAB>-MSGV1
                  V2        = <LS_MESSTAB>-MSGV2
                  V3        = <LS_MESSTAB>-MSGV3
                  V4        = <LS_MESSTAB>-MSGV4
                IMPORTING
                  MSG       = WA_LOG-MESSAGE1
                EXCEPTIONS
                  NOT_FOUND = 1
                  OTHERS    = 2.
              IF SY-SUBRC <> 0.
              ENDIF.
              WA_LOG-KSCHL   = WA_DATATAB-KSCHL.
              WA_LOG-MATNR   = WA_DATATAB-MATNR.
              WA_LOG-MSGTYP  = <LS_MESSTAB>-MSGTYP.
              APPEND WA_LOG TO IT_LOG.
              CLEAR  WA_LOG.
            ENDLOOP.
          ELSE.
            CLEAR : WA_LOG.
            READ TABLE MESSTAB ASSIGNING <LS_MESSTAB> WITH KEY MSGTYP = 'S' . " MSGID = 'VK' MSGNR = '344'.
            IF SY-SUBRC = 0.
              WA_LOG-KSCHL     = WA_DATATAB-KSCHL.
              WA_LOG-MATNR     = WA_DATATAB-MATNR.
              WA_LOG-MSGTYP    = 'S'.
              WA_LOG-MESSAGE1  = 'Deleted Successfully'.
              APPEND WA_LOG TO IT_LOG.
              CLEAR  WA_LOG.
            ELSE.
              WA_LOG-KSCHL    = WA_DATATAB-KSCHL.
              WA_LOG-MATNR    = WA_DATATAB-MATNR.
              WA_LOG-MSGTYP   = 'E'.
              WA_LOG-MESSAGE1 = 'Not Deleted'.
              APPEND WA_LOG TO IT_LOG.
              CLEAR  WA_LOG.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSEIF P_ZMEK2 IS NOT INITIAL .



        SELECT
      A502~LIFNR ,
      A502~MATNR ,
      A502~KSCHL ,
      A502~KNUMH FROM A502 INTO TABLE @DATA(IT_A501)
      FOR ALL ENTRIES IN @IT_DATATAB
     WHERE  MATNR = @IT_DATATAB-MATNR
      AND LIFNR = @IT_DATATAB-LIFNR
      AND KSCHL = @IT_DATATAB-KSCHL.

        IF IT_A501 IS NOT INITIAL.
          SELECT
            KONP~KNUMH ,
            KONP~LOEVM_KO FROM KONP INTO TABLE @DATA(IT_KONP1)
            FOR ALL ENTRIES IN @IT_A501
            WHERE KNUMH = @IT_A501-KNUMH
            AND LOEVM_KO = ' '.

        ENDIF.

        LOOP AT IT_DATATAB INTO WA_DATATAB.
    READ TABLE IT_A501 ASSIGNING FIELD-SYMBOL(<LS_A501>) WITH KEY  MATNR = WA_DATATAB-MATNR LIFNR = WA_DATATAB-LIFNR KSCHL = WA_DATATAB-KSCHL.
    IF SY-SUBRC = 0.
      READ TABLE IT_KONp1 ASSIGNING FIELD-SYMBOL(<LS_KONP1>) WITH KEY KNUMH = <LS_A501>-KNUMH LOEVM_KO = ' '.
      IF SY-SUBRC = 0.

          PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RV13A-KSCHL'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                        WA_DATATAB-KSCHL .           ""'pb00'.
          PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RV130-SELKZ(05)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=WEIT'.
          PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                                        ''.
          PERFORM BDC_FIELD       USING 'RV130-SELKZ(05)'
                                        'X'.
          PERFORM BDC_DYNPRO      USING 'RV13A502' '1000'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'F002-LOW'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ONLI'.
          PERFORM BDC_FIELD       USING 'F001'
                                        WA_DATATAB-LIFNR .           ""'SC0011972'.
          PERFORM BDC_FIELD       USING 'F002-LOW'
                                        WA_DATATAB-MATNR.                      ""'62289-36'.
*      PERFORM BDC_FIELD       USING 'SEL_DATE'
*                                    '17.10.2019'.
          PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'KOMG-MATNR(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ENTF'.
          PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                                        'X'.
          PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'KOMG-MATNR(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=SICH'.
*      PERFORM BDC_TRANSACTION USING 'MEK2'.


          CALL TRANSACTION 'MEK2'
                  USING BDCDATA
                  MODE   GV_BDC_MODE
                  UPDATE CUPDATE
                  MESSAGES INTO MESSTAB.
wait UP TO 1 SECONDS .
          REFRESH : BDCDATA[].
          CLEAR : BDCDATA.

          DATA: WA_MESSTAB1 TYPE BDCMSGCOLL.
          CLEAR : WA_MESSTAB1.
          BREAK BREDDY .
          READ TABLE MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSTAB1>) WITH KEY MSGTYP = 'E'.
          IF SY-SUBRC = 0.
            LOOP AT MESSTAB ASSIGNING <LS_MESSTAB1> WHERE MSGTYP = 'E'.
              CLEAR WA_LOG.
              CALL FUNCTION 'FORMAT_MESSAGE'
                EXPORTING
                  ID        = <LS_MESSTAB1>-MSGID
                  LANG      = 'EN'
                  NO        = <LS_MESSTAB1>-MSGNR
                  V1        = <LS_MESSTAB1>-MSGV1
                  V2        = <LS_MESSTAB1>-MSGV2
                  V3        = <LS_MESSTAB1>-MSGV3
                  V4        = <LS_MESSTAB1>-MSGV4
                IMPORTING
                  MSG       = WA_LOG-MESSAGE1
                EXCEPTIONS
                  NOT_FOUND = 1
                  OTHERS    = 2.
              IF SY-SUBRC <> 0.
              ENDIF.
              WA_LOG-KSCHL   = WA_DATATAB-KSCHL.
              WA_LOG-MATNR   = WA_DATATAB-MATNR.
              WA_LOG-MSGTYP  = <LS_MESSTAB1>-MSGTYP.
              APPEND WA_LOG TO IT_LOG.
              CLEAR  WA_LOG.
            ENDLOOP.
          ELSE.
            CLEAR : WA_LOG.
            READ TABLE MESSTAB ASSIGNING <LS_MESSTAB1> WITH KEY MSGTYP = 'S'.  " MSGID = 'VK' MSGNR = '822'.
            IF SY-SUBRC = 0.
              WA_LOG-KSCHL     = WA_DATATAB-KSCHL.
              WA_LOG-MATNR     = WA_DATATAB-MATNR.
              WA_LOG-MSGTYP    = 'S'.
              WA_LOG-MESSAGE1  = 'Deleted Successfully'.
              APPEND WA_LOG TO IT_LOG.
              CLEAR  WA_LOG.
            ELSE.
              WA_LOG-KSCHL    = WA_DATATAB-KSCHL.
              WA_LOG-MATNR    = WA_DATATAB-MATNR.
              WA_LOG-MSGTYP   = 'E'.
              WA_LOG-MESSAGE1 = 'Not Deleted'.
              APPEND WA_LOG TO IT_LOG.
              CLEAR  WA_LOG.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.




    ENDLOOP.


  ENDIF .

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
