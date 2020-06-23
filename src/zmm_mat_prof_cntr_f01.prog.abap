*&---------------------------------------------------------------------*
*& Include          ZMM_MAT_PROF_CNTR_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING P_FILE.
  DATA :
    LV_WINDOW_TITLE      TYPE STRING,
    LV_DEFAULT_EXTENSION TYPE STRING,
    LT_FILETABLE         TYPE FILETABLE,
    LV_RC                TYPE SY-SUBRC,
    FNAME                TYPE STRING,
    ENAME                TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LV_WINDOW_TITLE        " Title Of File Open Dialog
      DEFAULT_EXTENSION       = LV_DEFAULT_EXTENSION   " Default Extension
      DEFAULT_FILENAME        = P_FILE                 " Default File Name
    CHANGING
      FILE_TABLE              = LT_FILETABLE           " Table Holding Selected Files
      RC                      = LV_RC
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1                      " "Open File" dialog failed
      CNTL_ERROR              = 2                      " Control error
      ERROR_NO_GUI            = 3                      " No GUI available
      NOT_SUPPORTED_BY_GUI    = 4                      " GUI does not support this
      OTHERS                  = 5.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  P_FILE = LT_FILETABLE[ 1 ]-FILENAME.
  SPLIT P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.
  IF ENAME <> 'XLS' AND ENAME <> 'XLSX'.
    MESSAGE E069(ZMSG_CLS).
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_FILE
*&---------------------------------------------------------------------*
FORM GET_DATA.
  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.
  DATA : LV_FILE TYPE RLGRAP-FILENAME.
  REFRESH GT_FILE[].
  LV_FILE = P_FILE.
***  FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_TAB_RAW_DATA       = I_TYPE
      I_FILENAME           = LV_FILE
    TABLES
      I_TAB_CONVERTED_DATA = GT_FILE[]
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.

  DELETE GT_FILE[] FROM 1 TO 2.
  IF GT_FILE IS INITIAL.
    MESSAGE E070(ZMSG_CLS).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FILE
*&---------------------------------------------------------------------*
FORM PROCESS_DATA.
  FIELD-SYMBOLS : <LS_MSGS> TYPE TY_MSGS.
*** Get Group Hierarchy
  SELECT
        MARC~MATNR,
        MARC~WERKS,
        KSSK~CLINT,
        KLAH1~CLASS,
        ZPROF_CENTER~PRCTR
        INTO TABLE @DATA(LT_GROUP)
        FROM KLAH AS KLAH
        INNER JOIN MARA AS MARA ON KLAH~CLASS = MARA~MATKL
        INNER JOIN MARC AS MARC ON MARC~MATNR = MARA~MATNR
        INNER JOIN KSSK AS KSSK ON KSSK~OBJEK = KLAH~CLINT
        INNER JOIN KLAH AS KLAH1 ON KLAH1~CLINT = KSSK~CLINT
        INNER JOIN ZPROF_CENTER AS ZPROF_CENTER ON ZPROF_CENTER~CLASS = KLAH1~CLASS AND ZPROF_CENTER~WERKS = MARC~WERKS
        FOR ALL ENTRIES IN @GT_FILE
        WHERE MARA~MATNR = @GT_FILE-MATNR AND KLAH~KLART = '026'.

  SORT GT_FILE BY MATNR.
  SORT LT_GROUP BY MATNR.
  LOOP AT GT_FILE ASSIGNING FIELD-SYMBOL(<LS_FILE>).
    READ TABLE LT_GROUP ASSIGNING FIELD-SYMBOL(<LS_GROUP>) WITH KEY MATNR = <LS_FILE>-MATNR.
    IF SY-SUBRC = 0.
      LOOP AT LT_GROUP ASSIGNING <LS_GROUP> FROM SY-TABIX.
        IF <LS_FILE>-MATNR <> <LS_GROUP>-MATNR.
          EXIT.
        ENDIF.
        UPDATE MARC SET PRCTR = <LS_GROUP>-PRCTR WHERE MATNR = <LS_GROUP>-MATNR AND WERKS = <LS_GROUP>-WERKS.
        IF SY-SUBRC = 0.
          APPEND INITIAL LINE TO GT_MSGS ASSIGNING <LS_MSGS>.
          <LS_MSGS>-MATNR   = <LS_GROUP>-MATNR.
          <LS_MSGS>-PLANT   = <LS_GROUP>-WERKS.
          <LS_MSGS>-MESSAGE = 'Success'.
        ELSE.
          APPEND INITIAL LINE TO GT_MSGS ASSIGNING <LS_MSGS>.
          <LS_MSGS>-MATNR   = <LS_GROUP>-MATNR.
          <LS_MSGS>-PLANT   = <LS_GROUP>-WERKS.
          <LS_MSGS>-MESSAGE = 'Fail'.
        ENDIF.
      ENDLOOP.
    ELSE.
      APPEND INITIAL LINE TO GT_MSGS ASSIGNING <LS_MSGS>.
      <LS_MSGS>-MATNR   = <LS_FILE>-MATNR.
      <LS_MSGS>-MESSAGE = 'No Profit Center Maintained'.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .
  DATA:
    LT_FCAT TYPE SLIS_T_FIELDCAT_ALV,
    WA_FCAT TYPE SLIS_FIELDCAT_ALV.

*** Field Cat Log
  LT_FCAT = VALUE #(
                    ( FIELDNAME = 'MATNR'   TABNAME = 'GT_MSGS' SELTEXT_M = 'Material' OUTPUTLEN = 20  JUST = 'C')
                    ( FIELDNAME = 'PLANT'   TABNAME = 'GT_MSGS' SELTEXT_M = 'Plant'    OUTPUTLEN = 20  JUST = 'C')
                    ( FIELDNAME = 'MESSAGE' TABNAME = 'GT_MSGS' SELTEXT_M = 'Message'  OUTPUTLEN = 40  JUST = 'C')
                    ).

***  Display Report.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
*     IS_LAYOUT          = LS_LAYOUT
      IT_FIELDCAT        = LT_FCAT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = GT_MSGS
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.
