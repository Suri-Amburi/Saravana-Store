*&---------------------------------------------------------------------*
*& Include          ZMAT_UPLOAD_FORM
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING FP_P_FILE TYPE STRING.

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

ENDFORM.                    " GET_FILENAME




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
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- TA_FLATFILE
*&---------------------------------------------------------------------*
FORM GET_DATA  CHANGING IT_FILE TYPE TY_FILE1.

  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.

  DATA:LV_FILE TYPE RLGRAP-FILENAME.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH IT_FILE[].

    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = IT_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.


    DELETE IT_FILE FROM 1 TO 2.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF IT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
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
FORM BDC_FIELD  USING   FNAM FVAL.

  IF FVAL IS NOT INITIAL.
    CLEAR WA_BDCDATA.
    WA_BDCDATA-FNAM = FNAM.
    WA_BDCDATA-FVAL = FVAL.
    SHIFT WA_BDCDATA-FVAL LEFT DELETING LEADING SPACE.
    APPEND WA_BDCDATA TO IT_BDCDATA.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAT_DATA .
  LOOP AT IT_FILE INTO WA_FILE.

    PERFORM BDC_DYNPRO      USING 'SAPMWBE3' '0102'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WR02D-LOCNR'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM BDC_FIELD       USING 'WR02D-LOCNR'
                                   WA_FILE-LOCNR.                                             " record-LOCNR_001.
    PERFORM BDC_DYNPRO      USING 'SAPMWBE3' '0401'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=WAGR'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'T001K-BUKRS'.
*perform bdc_field       using 'T001K-BUKRS'
*                              record-BUKRS_002.
*perform bdc_field       using 'T001W-EKORG'
*                              record-EKORG_003.
*perform bdc_field       using 'T001W-VKORG'
*                              record-VKORG_004.
*perform bdc_field       using 'T001W-VTWEG'
*                              record-VTWEG_005.
*perform bdc_field       using 'T001W-SPART'
*                              record-SPART_006.
*perform bdc_field       using 'T001W-FABKL'
*                              record-FABKL_007.
    PERFORM BDC_DYNPRO      USING 'SAPLWR22' '0430'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WRF6-ABTNR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=KOPE'.
    PERFORM BDC_DYNPRO      USING 'SAPLWR22' '0431'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WRF6-MATKL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'WRF6-MATKL'
                                   WA_FILE-MATKL.                                "record-MATKL_008.
    PERFORM BDC_DYNPRO      USING 'SAPLWR22' '0431'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WRF6-ABTNR'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_DYNPRO      USING 'SAPLWR22' '0431'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WRF6-ABTNR'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=UPDA'.
    PERFORM BDC_DYNPRO      USING 'SAPLWR22' '0430'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'WRF6-ABTNR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=UPDA'.


    REFRESH: IT_MESSTAB.
    CALL TRANSACTION 'WB02' USING IT_BDCDATA
                     MODE   CTUMODE
                     UPDATE CUPDATE
                     MESSAGES INTO IT_MESSTAB.
    REFRESH IT_BDCDATA.
*    WA_LOG-NOTI_NO = P_QMNUM .
    READ TABLE IT_MESSTAB INTO  WA_MESSTAB WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      LOOP AT IT_MESSTAB INTO WA_MESSTAB.

        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            ID        = WA_MESSTAB-MSGID
            LANG      = '-D'
            NO        = WA_MESSTAB-MSGNR
            V1        = WA_MESSTAB-MSGV1
            V2        = WA_MESSTAB-MSGV2
            V3        = WA_MESSTAB-MSGV3
            V4        = WA_MESSTAB-MSGV4
          IMPORTING
            MSG       = WA_DISPLAY-MESSAGE
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.

        WA_DISPLAY-SLNO     = WA_FILE-SLNO.
        WA_DISPLAY-LOCNR    = WA_FILE-LOCNR.
        WA_DISPLAY-MATKL    = WA_FILE-MATKL.
        WA_DISPLAY-TYPE     = WA_MESSTAB-MSGTYP.
*       WA_DISPLAY-MESSAGE   = WA_MESSTAB-MSGV1.

        APPEND WA_DISPLAY TO IT_DISPLAY.
        CLEAR WA_DISPLAY.

      ENDLOOP.
    ELSE .
      WA_DISPLAY-SLNO     = WA_FILE-SLNO.
      WA_DISPLAY-LOCNR    = WA_FILE-LOCNR.
      WA_DISPLAY-MATKL    = WA_FILE-MATKL.
      WA_DISPLAY-TYPE     = 'S'.
      WA_DISPLAY-MESSAGE  = 'SUCCESSFULLY UPDATED' .

    ENDIF.
    APPEND WA_DISPLAY TO IT_DISPLAY.
    CLEAR WA_DISPLAY.

    WAIT UP TO 1 seconds.
  ENDLOOP.
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

  DATA:IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
       WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
       WA_LAYOUT TYPE SLIS_LAYOUT_ALV.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_FCAT-COL_POS = 1.
  WA_FCAT-FIELDNAME = 'SLNO'.
  WA_FCAT-SELTEXT_M = 'SERIAL NO'.
  WA_FCAT-OUTPUTLEN = '10' .
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-COL_POS = 2.
  WA_FCAT-FIELDNAME = 'LOCNR'.
  WA_FCAT-SELTEXT_M = 'PLANT'.
  WA_FCAT-OUTPUTLEN = '10' .
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-COL_POS = 3.
  WA_FCAT-FIELDNAME = 'MATKL'.
  WA_FCAT-SELTEXT_M = 'MATERIAL GROUP'.
  WA_FCAT-OUTPUTLEN = '20' .
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-COL_POS = 4.
  WA_FCAT-FIELDNAME = 'TYPE'.
  WA_FCAT-SELTEXT_M = 'MESSEGE TYPE'.
  WA_FCAT-OUTPUTLEN = '20' .
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-COL_POS = 5.
  WA_FCAT-FIELDNAME = 'MESSAGE'.
  WA_FCAT-SELTEXT_M = 'MESSAGE'.
  WA_FCAT-OUTPUTLEN = '30' .
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IS_LAYOUT     = WA_LAYOUT
      IT_FIELDCAT   = IT_FCAT[]
    TABLES
      T_OUTTAB      = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.




ENDFORM.
