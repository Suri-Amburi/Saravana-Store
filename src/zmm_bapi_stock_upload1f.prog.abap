*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
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

  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GIT_FILE
*&---------------------------------------------------------------------*
FORM GET_DATA  CHANGING P_GIT_FILE.
DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.
  DATA:LV_FILE TYPE RLGRAP-FILENAME.
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GIT_FILE[].
    LV_FILE = P_FILE.
*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR          =
*       I_LINE_HEADER              =
        I_TAB_RAW_DATA             = I_TYPE
        I_FILENAME                 = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA       = GIT_FILE[]
     EXCEPTIONS
       CONVERSION_FAILED          = 1
       OTHERS                     = 2

              .
     DELETE GIT_FILE[] FROM 1 TO 2.
  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.
*    IF SY-SUBRC <> 0.
* Implement suitable error handling here
*    ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GIT_FILE
*&---------------------------------------------------------------------*
FORM PROCESS_DATA  USING    P_GIT_FILE.
DATA:LS_UPLOAD TYPE GTY_FILE.
  DATA:LV_PSTNG_DATE TYPE BAPI2017_GM_HEAD_01-PSTNG_DATE,
       LV_DOC_DATE   TYPE BAPI2017_GM_HEAD_01-DOC_DATE.

  DATA:LS_HEAD     TYPE BAPI2017_GM_HEAD_01,
       LS_CODE     TYPE BAPI2017_GM_CODE,
       LT_ITEM     TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
       LS_ITEM     TYPE BAPI2017_GM_ITEM_CREATE,
       LT_BAPIRET2 TYPE STANDARD TABLE OF BAPIRET2,
       LS_BAPIRET2 TYPE BAPIRET2,
       " Added by IBR===>
       IT_SER      TYPE TABLE OF BAPI2017_GM_SERIALNUMBER,
       WA_SER      TYPE BAPI2017_GM_SERIALNUMBER,
       IT_FILE1    TYPE TABLE OF GTY_FILE,
       LV_CNT      TYPE INT4.

  IT_FILE1[] = GIT_FILE[].
  SORT IT_FILE1 BY SLNO.
  DELETE ADJACENT DUPLICATES FROM IT_FILE1 COMPARING SLNO.

*  DATA:LT_UPLOAD2 TYPE TT_UPLOAD,
*       LS_UPLOAD2 TYPE TY_UPLOAD.

  DATA:LV_MBLNR TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
       LV_YEAR  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
       LV_STR   TYPE STRING,
       LV_ITEM TYPE MBLPO.

LV_ITEM = 1.
  LOOP AT IT_FILE1 INTO LS_UPLOAD.
    CLEAR:LV_PSTNG_DATE,LV_DOC_DATE.
    REFRESH LT_ITEM.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL                  = LS_UPLOAD-DOC_DATE
*       ACCEPT_INITIAL_DATE            =
     IMPORTING
       DATE_INTERNAL                  = LV_DOC_DATE
     EXCEPTIONS
       DATE_EXTERNAL_IS_INVALID       = 1
       OTHERS                         = 2
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        DATE_EXTERNAL                  = LS_UPLOAD-PSTNG_DATE
*       ACCEPT_INITIAL_DATE            =
     IMPORTING
       DATE_INTERNAL                  = LV_PSTNG_DATE
     EXCEPTIONS
       DATE_EXTERNAL_IS_INVALID       = 1
       OTHERS                         = 2
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
     CLEAR LS_HEAD.
    LS_HEAD-PSTNG_DATE = LV_PSTNG_DATE.
    LS_HEAD-DOC_DATE   = LV_DOC_DATE.

    CLEAR LS_ITEM.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT              = LS_UPLOAD-MATERIAL
     IMPORTING
       OUTPUT             = LS_UPLOAD-MATERIAL
     EXCEPTIONS
       LENGTH_ERROR       = 1
       OTHERS             = 2
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
     DATA(MAT_LEN) = STRLEN( LS_UPLOAD-MATERIAL ) .
    IF MAT_LEN > 18.
      LS_ITEM-MATERIAL_LONG = LS_UPLOAD-MATERIAL.
    ELSE .
      LS_ITEM-MATERIAL = LS_UPLOAD-MATERIAL.
    ENDIF.

    LS_ITEM-PLANT            = LS_UPLOAD-PLANT.
    LS_ITEM-STGE_LOC         = LS_UPLOAD-STGE_LOC.
    LS_ITEM-MOVE_STLOC       = LS_UPLOAD-STGE_LOC.
    LS_ITEM-ENTRY_UOM        = LS_UPLOAD-ENTRY_UOM.
    LS_ITEM-BATCH            = LS_UPLOAD-BATCH.
**************

*    LS_ITEM-            = LS_UPLOAD-BATCH.

**********************
    LS_ITEM-MOVE_TYPE        = LS_UPLOAD-MOVE_TYPE.
    LS_ITEM-SPEC_STOCK       = LS_UPLOAD-SPEC_STOCK.
    LS_ITEM-VAL_SALES_ORD    = LS_ITEM-SALES_ORD    = LS_UPLOAD-SALES_ORDER.
    LS_ITEM-VAL_S_ORD_ITEM   = LS_ITEM-S_ORD_ITEM   = LS_UPLOAD-LINE_ITEM.
    LS_ITEM-VENDOR           = LS_UPLOAD-VENDOR.
    LS_ITEM-ENTRY_QNT        = LS_UPLOAD-ENTRY_QNT.
    IF LS_UPLOAD-DATE IS NOT INITIAL.
      LS_ITEM-PROD_DATE        = LS_UPLOAD-DATE+6(4) && LS_UPLOAD-DATE+3(2) && LS_UPLOAD-DATE+0(2).              " Date of Manufacture
    ENDIF.
    APPEND LS_ITEM TO LT_ITEM.
    LS_CODE = '05'.

    CLEAR:LV_MBLNR,LV_YEAR.
    "ADDED BY IBR
    LV_CNT = 1.
    LOOP AT GIT_FILE ASSIGNING FIELD-SYMBOL(<FILE>) WHERE SLNO = LS_UPLOAD-SLNO.
      APPEND VALUE #( MATDOC_ITM = LV_ITEM "LS_UPLOAD-SLNO
                      SERIALNO = <FILE>-SERNR ) TO IT_SER.
*      ADD 1 TO LV_CNT.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER               = LS_HEAD
        GOODSMVT_CODE                 = LS_CODE
*       TESTRUN                       = ' '
*       GOODSMVT_REF_EWM              =
*       GOODSMVT_PRINT_CTRL           =
     IMPORTING
*       GOODSMVT_HEADRET              =
       MATERIALDOCUMENT              = LV_MBLNR
       MATDOCUMENTYEAR               = LV_YEAR
      TABLES
        GOODSMVT_ITEM                 = LT_ITEM
       GOODSMVT_SERIALNUMBER         = IT_SER
        RETURN                        = LT_BAPIRET2.
*       GOODSMVT_SERV_PART_DATA       =
*       EXTENSIONIN                   =
*       GOODSMVT_ITEM_CWM             =
              .

     IF LV_MBLNR IS NOT INITIAL.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT          = 'X'.
*        IMPORTING
*          RETURN        =
                 .

       LS_FINAL-SLNO = LS_UPLOAD-SLNO. "LS_ITEM-MATERIAL.
      LS_FINAL-MATNR = LS_UPLOAD-MATERIAL. "LS_ITEM-MATERIAL.
      LS_FINAL-MBLNR = LV_MBLNR.
      LS_FINAL-MJAHR = LV_YEAR.
      LS_FINAL-CHARG = LS_UPLOAD-BATCH.
      LS_FINAL-MSGTY = 'S'.
      LS_FINAL-MSG   =  'Success'.
      APPEND LS_FINAL TO LT_FINAL.
      CLEAR LS_FINAL.
      IF LS_UPLOAD-TO_CHECK IS NOT INITIAL.
        PERFORM CREATE_TO USING LS_UPLOAD-SLNO LS_UPLOAD-MATERIAL LV_MBLNR LV_YEAR.
      ENDIF.
    ELSE.

      LOOP AT LT_BAPIRET2 INTO LS_BAPIRET2 WHERE TYPE = 'E'.
        LS_FINAL-SLNO   = LS_UPLOAD-SLNO.
        LS_FINAL-MATNR   = LS_UPLOAD-MATERIAL.
        LS_FINAL-MSGTY = LS_BAPIRET2-TYPE.
        LS_FINAL-MSG   =  LS_BAPIRET2-MESSAGE.
        LS_FINAL-MSGTY = LS_BAPIRET2-TYPE.
        APPEND LS_FINAL TO LT_FINAL.
        CLEAR LS_FINAL.
      ENDLOOP.

ENDIF.
    CLEAR : LS_UPLOAD.
    REFRESH : IT_SER.
  ENDLOOP.

  DATA:IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
       WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
       WA_LAYOUT TYPE SLIS_LAYOUT_ALV.

  WA_FCAT-FIELDNAME            = 'SLNO'.
  WA_FCAT-TABNAME              = 'LT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'SLNO'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

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
  WA_FCAT-OUTPUTLEN            = 50.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = SY-REPID
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT                         = WA_LAYOUT
   IT_FIELDCAT                       = IT_FCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
   I_SAVE                            = 'A'
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = LT_FINAL
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_TO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_UPLOAD_SLNO
*&      --> LS_UPLOAD_MATERIAL
*&      --> LV_MBLNR
*&      --> LV_YEAR
*&---------------------------------------------------------------------*
FORM CREATE_TO  USING P_SNO P_MATNR P_LV_MBLNR P_LV_YEAR.
   REFRESH : IT_BDCDATA,IT_MESSTAB.
  PERFORM BDC_DYNPRO      USING 'SAPML02B' '0203'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RL02B-MBLNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RL02B-MBLNR'
                                P_LV_MBLNR.
  PERFORM BDC_FIELD       USING 'RL02B-MJAHR'
                                P_LV_YEAR.
  PERFORM BDC_FIELD       USING 'RL02B-DUNKL'
                                'H'.
  PERFORM BDC_DYNPRO      USING 'SAPML03T' '0132'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=TERZ'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LTBP1-OFMEA(01)'.
  PERFORM BDC_DYNPRO      USING 'SAPML03T' '0132'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LTBK-BWLVS'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.
  CALL TRANSACTION 'LT06' USING IT_BDCDATA
                                MODE   CTUMODE
                                UPDATE CUPDATE
                                MESSAGES INTO IT_MESSTAB.
  READ TABLE IT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSTAB>) WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC = 0.
    LOOP AT IT_MESSTAB ASSIGNING <LS_MESSTAB> WHERE MSGTYP = 'E'.
      CLEAR LS_FINAL.
      CALL FUNCTION 'FORMAT_MESSAGE'
       EXPORTING
         ID              = <LS_MESSTAB>-MSGID
         LANG            = 'EN'
         NO              = <LS_MESSTAB>-MSGNR
         V1              = <LS_MESSTAB>-MSGV1
         V2              = <LS_MESSTAB>-MSGV2
         V3              = <LS_MESSTAB>-MSGV3
         V4              = <LS_MESSTAB>-MSGV4
       IMPORTING
         MSG             = LS_FINAL-MSG
       EXCEPTIONS
         NOT_FOUND       = 1
         OTHERS          = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
       LS_FINAL-SLNO    = P_SNO.
      LS_FINAL-MATNR   = P_MATNR.
      LS_FINAL-MBLNR   = P_LV_MBLNR.
      LS_FINAL-MJAHR   = P_LV_YEAR.
      LS_FINAL-MSGTY   = <LS_MESSTAB>-MSGTYP.
      APPEND LS_FINAL TO LT_FINAL.
    ENDLOOP.
  ELSE.
    CLEAR : LS_FINAL.
    READ TABLE IT_MESSTAB ASSIGNING <LS_MESSTAB> WITH KEY MSGTYP = 'S' MSGID = 'L3' MSGNR = '016'.
    LS_FINAL-SLNO    = P_SNO.
    LS_FINAL-MATNR   = P_MATNR.
    LS_FINAL-MBLNR   = P_LV_MBLNR.
    LS_FINAL-MJAHR   = P_LV_YEAR.
    LS_FINAL-MSGTY   = 'S'.
    LS_FINAL-MSG     = | Transfer order  { <LS_MESSTAB>-MSGV1 } Created Succesfully |.
    APPEND LS_FINAL TO LT_FINAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING PROGRAM DYNPRO.
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
FORM BDC_FIELD  USING  FNAM FVAL.
   CLEAR WA_BDCDATA.
  WA_BDCDATA-FNAM = FNAM.
  WA_BDCDATA-FVAL = FVAL.
  SHIFT WA_BDCDATA-FVAL LEFT DELETING LEADING SPACE.
  APPEND WA_BDCDATA TO IT_BDCDATA.

ENDFORM.
