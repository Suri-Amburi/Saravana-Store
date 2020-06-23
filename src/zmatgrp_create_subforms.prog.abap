*&---------------------------------------------------------------------*
*& Include          ZMATGRP_CREATE_SUBFORMS
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING FP_P_FILE TYPE STRING.
***********commented by bhavani*********
  DATA: LI_FILETABLE    TYPE FILETABLE,
        LX_FILETABLE    TYPE FILE_TABLE,
        LV_RETURN_CODE  TYPE I,
        LV_WINDOW_TITLE TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LV_WINDOW_TITLE
    CHANGING
      FILE_TABLE              = LI_FILETABLE
      RC                      = LV_RETURN_CODE
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.

  READ TABLE  LI_FILETABLE INTO LX_FILETABLE INDEX 1.
  FP_P_FILE = LX_FILETABLE-FILENAME.

*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.
***************changes done by bhavani**********

*  DATA:LV_FILE TYPE STRING,
*       LV_RES  TYPE CHAR1.
*
*
*  CHECK SY-BATCH = ' '.
*
*  LV_FILE = P_FILE.
*
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
*    EXPORTING
*      FILE                 = LV_FILE
*    RECEIVING
*      RESULT               = LV_RES
*    EXCEPTIONS
*      CNTL_ERROR           = 1
*      ERROR_NO_GUI         = 2
*      WRONG_PARAMETER      = 3
*      NOT_SUPPORTED_BY_GUI = 4
*      OTHERS               = 5.
*
*  IF LV_RES = ' '.
*    MESSAGE 'Check File Path'  TYPE 'E'.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GIT_FILE
*&---------------------------------------------------------------------*
FORM GET_DATA  CHANGING GIT_FILE TYPE GTY_T_FILE.

  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GIT_FILE[].
    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GIT_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE GIT_FILE FROM 1 TO 1.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.
FORM GET_DATA1  CHANGING GIT_FILE1 TYPE GTY_T_FILE1.

  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GIT_FILE1[].
    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GIT_FILE1[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE GIT_FILE1 FROM 1 TO 1.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE1 IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.


FORM GET_DATA2  CHANGING GIT_FILE2 TYPE GTY_T_FILE2.

  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GIT_FILE2[].
    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GIT_FILE2[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE GIT_FILE2 FROM 1 TO 1.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE2 IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GIT_FILE
*&---------------------------------------------------------------------*
FORM PROCESS_DATA  USING  P_GIT_FILE.

  DATA: FLD(20)  TYPE C,  FLD1(20) TYPE C, FLD2(20) TYPE C, FLD3(20) TYPE C, FLD4(20) TYPE C,
        CNT(2)   TYPE N, LV_LINE TYPE I,
        MSG_TEXT TYPE STRING.

  FIELD-SYMBOLS:<FS_FLATFILE>    TYPE GTY_FILE,
                <FS_FLATFILE_IT> TYPE GTY_FILE.

  GIT_FILE_IT[] = GIT_FILE_I[] = GIT_FILE[].
  DELETE ADJACENT DUPLICATES FROM GIT_FILE COMPARING MATKL.
  BREAK BREDDY.
********ADDDED BY BHAVANI 10.09.2019
  SELECT
    MARA~MATNR FROM MARA INTO TABLE @DATA(IT_MARA)
    FOR ALL ENTRIES IN @GIT_FILE
    WHERE MATNR = @GIT_FILE-MATKL.



  LOOP AT GIT_FILE ASSIGNING <FS_FLATFILE>.

*******************Comented by thippesh****************************
*****    PERFORM bdc_dynpro      USING 'SAPMWWG2' '1000'.
*****    PERFORM bdc_field       USING 'BDC_CURSOR'
*****                                  'T023D-MATKL'.
*****    PERFORM bdc_field       USING 'BDC_OKCODE'
*****                                  '/00'.
*****    PERFORM bdc_field       USING 'T023D-MATKL'
*****                                 <fs_flatfile>-matkl.
*****    PERFORM bdc_dynpro      USING 'SAPMWWG2' '1100'.
*****    PERFORM bdc_field       USING 'BDC_CURSOR'
*****                                  'T023TD-WGBEZ'.
*****    PERFORM bdc_field       USING 'BDC_OKCODE'
*****                                  '=SAVE'.
*****    PERFORM bdc_field       USING 'T023TD-WGBEZ'
*****                                  <fs_flatfile>-wgbez.
******perform bdc_transaction using 'WG21'.
*****
*****    REFRESH it_messtab.
*****    CALL TRANSACTION 'WG21' USING it_bdcdata
*****                            MODE  ctumode
*****                            UPDATE cupdate
*****                            MESSAGES INTO it_messtab.
*****
*****    REFRESH: it_bdcdata.
******    DESCRIBE TABLE IT_MESSTAB LINES LV_LINE.
******    READ TABLE IT_MESSTAB INTO WA_MESSTAB INDEX LV_LINE.
*****
*****    IF it_messtab IS NOT INITIAL.
*****      PERFORM bdc_dynpro      USING 'SAPMWWG2' '1000'.
*****      PERFORM bdc_field       USING 'BDC_CURSOR'
*****                                    'T023D-MATKL'.
*****      PERFORM bdc_field       USING 'BDC_OKCODE'
*****                                    '/00'.
*****      PERFORM bdc_field       USING 'T023D-MATKL'
*****                                   <fs_flatfile>-matkl.
*****      PERFORM bdc_dynpro      USING 'SAPLSPO1' '0300'.
*****      PERFORM bdc_field       USING 'BDC_OKCODE'
*****                                    '=YES'.
*****      PERFORM bdc_dynpro      USING 'SAPMWWG2' '1100'.
*****      PERFORM bdc_field       USING 'BDC_CURSOR'
*****                                    'T023TD-WGBEZ'.
*****      PERFORM bdc_field       USING 'BDC_OKCODE'
*****                                    '=SAVE'.
*****      PERFORM bdc_field       USING 'T023TD-WGBEZ'
*****                                    <fs_flatfile>-wgbez.
******perform bdc_transaction using 'WG21'.
************adde by bhavani*******
    READ TABLE IT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATNR = <FS_FLATFILE>-MATKL .
    IF SY-SUBRC = 0 .

**********Added by thippesh************************************
      REFRESH :IT_BDCDATA."""""""""THB::Clear BDC DATA once data been saved

      PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'T023D-MATKL'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'T023D-MATKL'
                                    <FS_FLATFILE>-MATKL.

*********added by bhavani 09.09.2019********************

      PERFORM BDC_FIELD       USING 'WWGDS4-CONFIG_CLASS'
                                    ''.
      PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0300'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=YES'.
**************ended by bhavani 09.09.2019*************


      PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '1100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'T023TD-WGBEZ60'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'T023TD-WGBEZ'
                                    <FS_FLATFILE>-WGBEZ.
      PERFORM BDC_FIELD       USING 'T023TD-WGBEZ60'
                                    <FS_FLATFILE>-WGBEZ60.
      PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '1100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'T023TD-WGBEZ'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=SAVE'.


      REFRESH IT_MESSTAB.
      CALL TRANSACTION 'WG21' USING IT_BDCDATA
                              MODE  CTUMODE
                              UPDATE CUPDATE
                              MESSAGES INTO IT_MESSTAB.

    ELSE.
********Added By bhavani*******10.09.2019
      REFRESH :IT_BDCDATA.

      PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'T023D-MATKL'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'T023D-MATKL'
                                    <FS_FLATFILE>-MATKL.

**********added by bhavani 09.09.2019********************

*    PERFORM BDC_FIELD       USING 'WWGDS4-CONFIG_CLASS'
*                                  ''.
*    PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0300'.
*    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                  '=YES'.
***************ended by bhavani 09.09.2019*************


      PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '1100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'T023TD-WGBEZ60'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'T023TD-WGBEZ'
                                    <FS_FLATFILE>-WGBEZ.
      PERFORM BDC_FIELD       USING 'T023TD-WGBEZ60'
                                    <FS_FLATFILE>-WGBEZ60.
      PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '1100'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'T023TD-WGBEZ'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=SAVE'.

      REFRESH IT_MESSTAB.
      CALL TRANSACTION 'WG21' USING IT_BDCDATA
                              MODE  CTUMODE
                              UPDATE CUPDATE
                              MESSAGES INTO IT_MESSTAB.
    ENDIF .
*********ENDED BY BHAVANI  10.09.2019***********
    IF IT_MESSTAB IS NOT INITIAL.
      LOOP AT IT_MESSTAB INTO WA_MESSTAB.

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
            MSG       = MSG_TEXT
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.

        LV_SQNO = LV_SQNO + 1.
        GWA_DISPLAY-MATKL   = <FS_FLATFILE>-MATKL.
        GWA_DISPLAY-WGBEZ   = <FS_FLATFILE>-WGBEZ.
        MOVE-CORRESPONDING WA_MESSTAB TO GWA_DISPLAY.
        GWA_DISPLAY-MESSAGE1 = MSG_TEXT.
        GWA_DISPLAY-SNO = LV_SQNO.

        APPEND GWA_DISPLAY TO GIT_DISPLAY.
        CLEAR:GWA_DISPLAY, MSG_TEXT.
      ENDLOOP.

    ELSE.
      LV_SQNO = LV_SQNO + 1.
      GWA_DISPLAY-MATKL   = <FS_FLATFILE>-MATKL.
      GWA_DISPLAY-WGBEZ   = <FS_FLATFILE>-WGBEZ.
      GWA_DISPLAY-MESSAGE1 = 'Successfully Created'.
      GWA_DISPLAY-SNO = LV_SQNO.

      APPEND GWA_DISPLAY TO GIT_DISPLAY.
      CLEAR:GWA_DISPLAY, MSG_TEXT.
    ENDIF.
*    ENDIF.
  ENDLOOP.
*  ENDIF .
ENDFORM.

FORM PROCESS_DATA1  USING  P_GIT_FILE1.

  DATA: FLD(20)  TYPE C,  FLD1(20) TYPE C, FLD2(20) TYPE C, FLD3(20) TYPE C, FLD4(20) TYPE C,
        CNT(2)   TYPE N, LV_LINE TYPE I,
        MSG_TEXT TYPE STRING.

  FIELD-SYMBOLS:<FS_FLATFILE1>    TYPE GTY_FILE1,
                <FS_FLATFILE_IT1> TYPE GTY_FILE1.

  GIT_FILE_IT1[] = GIT_FILE_I1[] = GIT_FILE1[].
  DELETE ADJACENT DUPLICATES FROM GIT_FILE1 COMPARING MATKL.

  LOOP AT GIT_FILE1 ASSIGNING <FS_FLATFILE1>.

    PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '0600'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WWGD-CLASS1'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=HANL'.
    PERFORM BDC_FIELD       USING 'T023D-MATKL'
                                  <FS_FLATFILE1>-MATKL.
    PERFORM BDC_FIELD       USING 'WWGD-CLASS1'
                                  <FS_FLATFILE1>-CLASS1.
    PERFORM BDC_FIELD       USING 'WWGDS4-CONFIG_KLART'
                                  ''.
    PERFORM BDC_FIELD       USING 'WWGDS4-CONFIG_CLASS'
                                  ''.


*perform bdc_transaction using 'WG26'.

    REFRESH IT_MESSTAB.
    CALL TRANSACTION 'WG26' USING IT_BDCDATA
                            MODE  CTUMODE
                            UPDATE CUPDATE
                            MESSAGES INTO IT_MESSTAB.


    REFRESH: IT_BDCDATA.
    DESCRIBE TABLE IT_MESSTAB LINES LV_LINE.

    READ TABLE IT_MESSTAB INTO WA_MESSTAB INDEX LV_LINE.


    LOOP AT IT_MESSTAB INTO WA_MESSTAB .

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
          MSG       = MSG_TEXT
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      LV_SQNO = LV_SQNO + 1.
      GWA_DISPLAY1-MATKL   = <FS_FLATFILE1>-MATKL.
      GWA_DISPLAY1-CLASS1  = <FS_FLATFILE1>-CLASS1.
      MOVE-CORRESPONDING WA_MESSTAB TO GWA_DISPLAY.
      GWA_DISPLAY1-MESSAGE1 = MSG_TEXT.
      GWA_DISPLAY1-SNO = LV_SQNO.

      APPEND GWA_DISPLAY1 TO GIT_DISPLAY1.
      CLEAR:GWA_DISPLAY1, MSG_TEXT.
    ENDLOOP.

  ENDLOOP.

ENDFORM.


FORM PROCESS_DATA2  USING  P_GIT_FILE2.

  DATA: FLD(20)  TYPE C,  FLD1(20) TYPE C, FLD2(20) TYPE C, FLD3(20) TYPE C, FLD4(20) TYPE C,
        CNT(2)   TYPE N, LV_LINE TYPE I,
        MSG_TEXT TYPE STRING.

  FIELD-SYMBOLS:<FS_FLATFILE2>    TYPE GTY_FILE2,
                <FS_FLATFILE_IT2> TYPE GTY_FILE2.

  GIT_FILE_IT2[] = GIT_FILE_I2[] = GIT_FILE2[].
  DELETE ADJACENT DUPLICATES FROM GIT_FILE2 COMPARING MATKL.

  LOOP AT GIT_FILE2 ASSIGNING <FS_FLATFILE2>.

    PERFORM BDC_DYNPRO      USING 'SAPMWWG2' '0600'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'WWGD-CLASS2'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BANL'.
    PERFORM BDC_FIELD       USING 'T023D-MATKL'
                                  <FS_FLATFILE2>-MATKL.
    PERFORM BDC_FIELD       USING 'WWGD-CLASS2'
                                  <FS_FLATFILE2>-CLASS2.
    PERFORM BDC_FIELD       USING 'WWGDS4-CONFIG_KLART'
                                  ''.
    PERFORM BDC_FIELD       USING 'WWGDS4-CONFIG_CLASS'
                                  ''.
*perform bdc_transaction using 'WG26'.

    REFRESH IT_MESSTAB.
    CALL TRANSACTION 'WG26' USING IT_BDCDATA
                            MODE  CTUMODE
                            UPDATE CUPDATE
                            MESSAGES INTO IT_MESSTAB.


    REFRESH: IT_BDCDATA.
    DESCRIBE TABLE IT_MESSTAB LINES LV_LINE.
    READ TABLE IT_MESSTAB INTO WA_MESSTAB INDEX LV_LINE.


    LOOP AT IT_MESSTAB INTO WA_MESSTAB.

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
          MSG       = MSG_TEXT
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      LV_SQNO = LV_SQNO + 1.
      GWA_DISPLAY2-MATKL   = <FS_FLATFILE2>-MATKL.
      GWA_DISPLAY2-CLASS2  = <FS_FLATFILE2>-CLASS2.
      MOVE-CORRESPONDING WA_MESSTAB TO GWA_DISPLAY.
      GWA_DISPLAY2-MESSAGE1 = MSG_TEXT.
      GWA_DISPLAY2-SNO = LV_SQNO.

      APPEND GWA_DISPLAY2 TO GIT_DISPLAY2.
      CLEAR:GWA_DISPLAY2, MSG_TEXT.
    ENDLOOP.

  ENDLOOP.

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
       '01' '01' 'SNO'       'GIT_DISPLAY' 'L' 'SNO',
       '01' '02' 'MATKL'     'GIT_DISPLAY' 'L' 'MATERIAL GROUP',
       '01' '03' 'WGBEZ'     'GIT_DISPLAY' 'L' 'DESCRIPTION',
       '01' '04' 'MESSAGE1'  'GIT_DISPLAY' 'L' 'MESSAGE'.

ENDFORM.

FORM FIELD_CATLOG1 .

  PERFORM CREATE_FIELDCAT USING:
       '01' '01' 'SNO'       'GIT_DISPLAY' 'L' 'SNO',
       '01' '02' 'MATKL'     'GIT_DISPLAY' 'L' 'MATERIAL GROUP',
       '01' '03' 'CLASS1'    'GIT_DISPLAY' 'L' 'HIERARCHY',
       '01' '04' 'MESSAGE1'  'GIT_DISPLAY' 'L' 'MESSAGE'.

ENDFORM.

FORM FIELD_CATLOG2 .

  PERFORM CREATE_FIELDCAT USING:
       '01' '01' 'SNO'        'GIT_DISPLAY' 'L' 'SNO',
       '01' '02' 'MATKL'      'GIT_DISPLAY' 'L' 'MATERIAL GROUP',
       '01' '03' 'CLASS2'     'GIT_DISPLAY' 'L' 'PROFILE',
       '01' '04' 'MESSAGE1'   'GIT_DISPLAY' 'L' 'MESSAGE'.
*       '01' '03' 'CONFIG_KLART'     'GIT_DISPLAY' 'L' 'CLASSTYPE',
*       '01' '03' 'CONFIG_CLASS'     'GIT_DISPLAY' 'L' 'CLASS',

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_OUTPUT .

  DATA: L_REPID TYPE SYREPID .

*  IF it_error IS NOT INITIAL.
  IF GIT_DISPLAY IS NOT INITIAL.

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
        T_OUTTAB           = GIT_DISPLAY
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.

FORM DISPLAY_OUTPUT1 .

  DATA: L_REPID TYPE SYREPID .

*  IF it_error IS NOT INITIAL.
  IF GIT_DISPLAY1 IS NOT INITIAL.


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
        T_OUTTAB           = GIT_DISPLAY1
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.


FORM DISPLAY_OUTPUT2 .

  DATA: L_REPID TYPE SYREPID .

*  IF it_error IS NOT INITIAL.
  IF GIT_DISPLAY2 IS NOT INITIAL.


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
        T_OUTTAB           = GIT_DISPLAY2
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM CREATE_FIELDCAT  USING FP_ROWPOS    TYPE SYCUROW
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
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING  PROGRAM DYNPRO.

  CLEAR WA_BDCDATA.
  WA_BDCDATA-PROGRAM  = PROGRAM.
  WA_BDCDATA-DYNPRO   = DYNPRO.
  WA_BDCDATA-DYNBEGIN = 'X'.
  APPEND WA_BDCDATA TO IT_BDCDATA.

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

  CLEAR WA_BDCDATA.
  WA_BDCDATA-FNAM = FNAM.
  WA_BDCDATA-FVAL = FVAL.
  APPEND WA_BDCDATA TO IT_BDCDATA.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CHECK_FILE_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_FILE_PATH .

  DATA:LV_FILE TYPE STRING,
       LV_RES  TYPE CHAR1.

  CHECK SY-BATCH = ' '.
  LV_FILE = P_FILE.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = LV_FILE
    RECEIVING
      RESULT               = LV_RES
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.

  IF LV_RES = ' '.
    MESSAGE 'Check File Path'  TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GIT_FILE3
*&---------------------------------------------------------------------*
FORM GET_DATA3  CHANGING P_GIT_FILE3.

  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GIT_FILE2[].
    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GIT_FILE2[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE GIT_FILE2 FROM 1 TO 1.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE2 IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GIT_FILE3
*&---------------------------------------------------------------------*
FORM PROCESS_DATA3  USING    P_GIT_FILE3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CATLOG3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELD_CATLOG3 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_OUTPUT3 .

ENDFORM.
