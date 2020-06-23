*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_FORM
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING FP_P_FILE.

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

  LX_FILETABLE = LI_FILETABLE[ 1 ].
  FP_P_FILE = LX_FILETABLE-FILENAME.

  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FILE  text
*----------------------------------------------------------------------*
FORM GET_DATA  CHANGING P_GT_FILE.
  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.
  DATA : LV_FILE TYPE RLGRAP-FILENAME.

  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.
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
  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.
  IF GT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FILE  text
*----------------------------------------------------------------------*
FORM PROCESS_DATA  USING P_GT_FILE.

  DATA:
    LV_PSTNG_DATE TYPE BAPI2017_GM_HEAD_01-PSTNG_DATE,
    LV_DOC_DATE   TYPE BAPI2017_GM_HEAD_01-DOC_DATE,
    LS_HEAD       TYPE BAPI2017_GM_HEAD_01,
    LT_ITEM       TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LS_ITEM       TYPE BAPI2017_GM_ITEM_CREATE,
    LT_BAPIRET    TYPE STANDARD TABLE OF BAPIRET2,
    LV_MBLNR      TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
    LV_YEAR       TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
    LV_ITEM       TYPE MBLPO,
    LT_B1_BATCH   TYPE TABLE OF ZB1_BATCH_T.

  DATA:
    LT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
    WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
    LS_LAYOUT TYPE SLIS_LAYOUT_ALV.

  CONSTANTS :
    C_CODE    TYPE BAPI2017_GM_CODE VALUE '05'.

  FIELD-SYMBOLS :
    <LS_FILE>    TYPE TY_FILE,
    <LS_FINAL>   TYPE TY_FINAL,
    <LS_BAPIRET> TYPE BAPIRET2.

  LOOP AT GT_FILE ASSIGNING <LS_FILE>.

    CLEAR:LV_PSTNG_DATE,LV_DOC_DATE,LS_ITEM,LV_MBLNR,LV_YEAR,LS_HEAD .
    REFRESH :LT_ITEM, LT_BAPIRET.
    LS_HEAD-PSTNG_DATE = <LS_FILE>-PSTNG_DATE+6(4) && <LS_FILE>-PSTNG_DATE+3(2) && <LS_FILE>-PSTNG_DATE+0(2).
    LS_HEAD-DOC_DATE   = <LS_FILE>-DOC_DATE+6(4) && <LS_FILE>-DOC_DATE+3(2) && <LS_FILE>-DOC_DATE+0(2).


*    <LS_FILE>-MATERIAL   =  |{ <LS_FILE>-MATERIAL ALPHA = IN }|.

    DATA(MAT_LEN) = STRLEN( <LS_FILE>-MATERIAL ) .
    IF MAT_LEN > 18.
      LS_ITEM-MATERIAL_LONG = <LS_FILE>-MATERIAL.
    ELSE.
      LS_ITEM-MATERIAL = <LS_FILE>-MATERIAL.
    ENDIF.

    LS_ITEM-PLANT            = <LS_FILE>-PLANT.
    LS_ITEM-STGE_LOC         = <LS_FILE>-STGE_LOC.
    LS_ITEM-MOVE_STLOC       = <LS_FILE>-STGE_LOC.
    LS_ITEM-ENTRY_UOM        = <LS_FILE>-ENTRY_UOM.
    LS_ITEM-BATCH            = <LS_FILE>-BATCH.
    LS_ITEM-MOVE_TYPE        = <LS_FILE>-MOVE_TYPE.
    LS_ITEM-SPEC_STOCK       = <LS_FILE>-SPEC_STOCK.
    LS_ITEM-ENTRY_QNT        = <LS_FILE>-ENTRY_QNT.
    LS_ITEM-AMOUNT_LC        = <LS_FILE>-AMOUNT.

    APPEND LS_ITEM TO LT_ITEM.
*** Goods Movement Bapi Call
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEAD
        GOODSMVT_CODE    = C_CODE
      IMPORTING
        MATERIALDOCUMENT = LV_MBLNR
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_BAPIRET.

    IF LV_MBLNR IS NOT INITIAL.
*** Commit the transaction if success
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
*** Append Success Messages
      APPEND VALUE #( SLNO = <LS_FILE>-SLNO MATNR = <LS_FILE>-MATERIAL MBLNR = LV_MBLNR
                      MJAHR = LV_YEAR CHARG = <LS_FILE>-BATCH MSGTY = 'S' MSG   = 'Success'
                      B1_BATCH = <LS_FILE>-B1_BATCH  B1_VENDOR = <LS_FILE>-B1_VENDOR ) TO GT_FINAL.
    ELSE.
*** Roll Back the transaction if fails
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*** Append Error Messages
      LOOP AT LT_BAPIRET ASSIGNING <LS_BAPIRET> WHERE TYPE = 'E'.
        APPEND VALUE #( SLNO = <LS_FILE>-SLNO MATNR = <LS_FILE>-MATERIAL MJAHR = LV_YEAR
                        CHARG = <LS_FILE>-BATCH MSGTY = <LS_BAPIRET>-TYPE MSG = <LS_BAPIRET>-MESSAGE ) TO GT_FINAL.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

***   Get Batch from Material Doc
  IF GT_FINAL IS NOT INITIAL.
    SELECT MBLNR, MJAHR , CHARG FROM MSEG INTO TABLE @DATA(LT_BATCH) FOR ALL ENTRIES IN @GT_FINAL WHERE MBLNR = @GT_FINAL-MBLNR AND MJAHR = @GT_FINAL-MJAHR.
  ENDIF.

***   Adding Records to Custom table to link B1 Batch and S4 Batch
  REFRESH : LT_B1_BATCH.
  LOOP AT LT_BATCH ASSIGNING FIELD-SYMBOL(<LS_BATCH>).
    READ TABLE GT_FINAL ASSIGNING <LS_FINAL> WITH KEY MBLNR = <LS_BATCH>-MBLNR MJAHR = <LS_BATCH>-MJAHR BINARY SEARCH.
    IF SY-SUBRC = 0.
      <LS_FINAL>-CHARG = <LS_BATCH>-CHARG.
      IF <LS_FINAL>-B1_BATCH IS NOT INITIAL.

        TRANSLATE <LS_FINAL>-B1_BATCH TO UPPER CASE.        "ADDED BY KRITHIKA 13.12.2019
        APPEND VALUE #( MANDT = SY-MANDT B1_BATCH = <LS_FINAL>-B1_BATCH B1_VENDOR = <LS_FINAL>-B1_VENDOR S4_BATCH = <LS_BATCH>-CHARG ) TO LT_B1_BATCH.
      ENDIF.
    ENDIF.
  ENDLOOP.

*** Updating Data Base Table
  IF LT_B1_BATCH IS NOT INITIAL.
    MODIFY ZB1_BATCH_T FROM TABLE LT_B1_BATCH.
  ENDIF.
*** Field Cat Log
  WA_FCAT-FIELDNAME            = 'SLNO'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'SLNO'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MBLNR'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'MAT.DOCUMENT NO'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MJAHR'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'FISCAL YEAR'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MATNR'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'MATERIAL NO'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'CHARG'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'Batch'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MSGTY'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'MSGTY.'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MSG'.
  WA_FCAT-TABNAME              = 'GT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'MSG'.
  WA_FCAT-OUTPUTLEN            = 50.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO LT_FCAT.
  CLEAR WA_FCAT.

***  Display Report.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = LS_LAYOUT
      IT_FIELDCAT        = LT_FCAT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = GT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.
