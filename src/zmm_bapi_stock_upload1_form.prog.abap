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

  READ TABLE  LI_FILETABLE INTO LX_FILETABLE INDEX 1.
  FP_P_FILE = LX_FILETABLE-FILENAME.

*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GIT_FILE  text
*----------------------------------------------------------------------*
FORM GET_DATA  CHANGING P_GIT_FILE.

  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.

  DATA:LV_FILE TYPE RLGRAP-FILENAME.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

*    refresh git_file[].

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


    DELETE GIT_FILE[] INDEX 1.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GIT_FILE  text
*----------------------------------------------------------------------*
FORM PROCESS_DATA  USING    P_GIT_FILE.

  DATA:LS_UPLOAD TYPE GTY_FILE,
       LS_FINAL  TYPE TY_FINAL,
       LT_FINAL  TYPE TABLE OF TY_FINAL..

  DATA:LV_PSTNG_DATE TYPE BAPI2017_GM_HEAD_01-PSTNG_DATE,
       LV_DOC_DATE   TYPE BAPI2017_GM_HEAD_01-DOC_DATE.

  DATA:LS_HEAD     TYPE BAPI2017_GM_HEAD_01,
       LS_CODE     TYPE BAPI2017_GM_CODE,
       LT_ITEM     TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
       LS_ITEM     TYPE BAPI2017_GM_ITEM_CREATE,
       LT_BAPIRET2 TYPE STANDARD TABLE OF BAPIRET2,
       LS_BAPIRET2 TYPE BAPIRET2.

*  DATA:LT_UPLOAD2 TYPE TT_UPLOAD,
*       LS_UPLOAD2 TYPE TY_UPLOAD.

  DATA:LV_MBLNR TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
       LV_YEAR  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
       LV_STR   TYPE STRING.

  BREAK BREDDY.
  LOOP AT GIT_FILE INTO LS_UPLOAD.


    CLEAR:LV_PSTNG_DATE,LV_DOC_DATE.
    REFRESH LT_ITEM.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL            = LS_UPLOAD-DOC_DATE
*       ACCEPT_INITIAL_DATE      =
      IMPORTING
        DATE_INTERNAL            = LV_DOC_DATE
      EXCEPTIONS
        DATE_EXTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL            = LS_UPLOAD-PSTNG_DATE
*       ACCEPT_INITIAL_DATE      =
      IMPORTING
        DATE_INTERNAL            = LV_PSTNG_DATE
      EXCEPTIONS
        DATE_EXTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
    BREAK-POINT.

    CLEAR LS_HEAD.
    LS_HEAD-PSTNG_DATE = LV_PSTNG_DATE.
    LS_HEAD-DOC_DATE   = LV_DOC_DATE.

*    LS_HEAD-HEADER_TXT = LS_UPLOAD-BKTEXT.



    CLEAR LS_ITEM.
*        LS_ITEM-MATERIAL =  LS_UPLOAD-MATERIAL.
    LS_ITEM-MATERIAL_LONG = LS_UPLOAD-MATERIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LS_ITEM-MATERIAL_LONG                      ""LS_ITEM-MATERIAL
      IMPORTING
        OUTPUT = LS_ITEM-MATERIAL_LONG.   "LS_ITEM-MATERIAL
    DATA:LV_VENDOR TYPE LIFNR.
    LV_VENDOR = LS_UPLOAD-VENDOR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_VENDOR
      IMPORTING
        OUTPUT = LV_VENDOR.

    LS_ITEM-PLANT            = LS_UPLOAD-PLANT.
    LS_ITEM-STGE_LOC         = LS_UPLOAD-STGE_LOC.
    TRANSLATE LS_ITEM-PLANT TO UPPER CASE.
    TRANSLATE LS_ITEM-STGE_LOC TO UPPER CASE.
*    ls_item-move_stloc       = ls_upload-stge_loc.
*    ls_item-entry_uom        = ls_upload-entry_uom.
*    ls_item-batch            = ls_upload-batch.
    LS_ITEM-MOVE_TYPE        =  LS_UPLOAD-MOVE_TYPE.
    LS_ITEM-SPEC_STOCK       =  LS_UPLOAD-SPEC_STOCK.
*    ls_item-val_sales_ord    = ls_item-sales_ord    = ls_upload-sales_order.
*    ls_item-val_s_ord_item   = ls_item-s_ord_item   = ls_upload-line_item.
    LS_ITEM-VENDOR           = LV_VENDOR.
*    BREAK-POINT.
    LS_ITEM-ENTRY_QNT        =  LS_UPLOAD-ENTRY_QNT.
    APPEND LS_ITEM TO LT_ITEM.
    LS_CODE = '05'.

    CLEAR:LV_MBLNR,LV_YEAR.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEAD
        GOODSMVT_CODE    = LS_CODE
      IMPORTING
*       GOODSMVT_HEADRET =
        MATERIALDOCUMENT = LV_MBLNR
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_BAPIRET2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'
* IMPORTING
*       RETURN        =
      .
    LS_FINAL-MATNR = LS_ITEM-MATERIAL_LONG."LS_ITEM-MATERIAL.
    LS_FINAL-MBLNR = LV_MBLNR.
    LS_FINAL-MJAHR = LV_YEAR.
*    ls_final-charg = ls_upload-batch.
    IF LT_BAPIRET2 IS INITIAL.
      LS_FINAL-MSGTY = 'S'.
      LS_FINAL-MSG   =  'Success'.
      APPEND LS_FINAL TO LT_FINAL.
      CLEAR LS_FINAL.
    ENDIF.

    LOOP AT LT_BAPIRET2 INTO LS_BAPIRET2.

      LS_FINAL-MSGTY = LS_BAPIRET2-TYPE.
      LS_FINAL-MSG   =  LS_BAPIRET2-MESSAGE.
      LS_FINAL-MSGTY = LS_BAPIRET2-TYPE.
      APPEND LS_FINAL TO LT_FINAL.
      CLEAR LS_FINAL.

    ENDLOOP.
  ENDLOOP.

  DATA:IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
       WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
       WA_LAYOUT TYPE SLIS_LAYOUT_ALV.

  WA_FCAT-FIELDNAME            = 'MBLNR'.
  WA_FCAT-TABNAME              = 'LT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'MAT.DOCUMENT NO'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MJAHR'.
  WA_FCAT-TABNAME              = 'LT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'ISCAL YEAR'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MATNR'.
  WA_FCAT-TABNAME              = 'LT_final'.
  WA_FCAT-SELTEXT_M            = 'MATERIAL NO'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'CHARG'.
  WA_FCAT-TABNAME              = 'LT_final'.
  WA_FCAT-SELTEXT_M            = 'Batch'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MSGTY'.
  WA_FCAT-TABNAME              = 'LT_final'.
  WA_FCAT-SELTEXT_M            = 'MSGTY.'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MSG'.
  WA_FCAT-TABNAME              = 'LT_final'.
  WA_FCAT-SELTEXT_M            = 'MSG'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

*  IF lt_final IS NOT INITIAL.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = IT_FCAT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = LT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

*    PERFORM disp_data.
ENDFORM.
