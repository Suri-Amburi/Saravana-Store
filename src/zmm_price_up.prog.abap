
*&---------------------------------------------------------------------*
*& Report ZMM_PRICE_UP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_PRICE_UP.

INCLUDE ZMM_PRICE_UP_TOP.
INCLUDE ZMM_PRICE_UP_SEL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN ON P_FILE.
  PERFORM CHECK_FILE_PATH.

START-OF-SELECTION.
  IF SY-BATCH = ' '.
    PERFORM GET_DATA CHANGING TA_FLATFILE.
  ENDIF.

  PERFORM UPLOAD_PRICE USING TA_FLATFILE .

END-OF-SELECTION.
  PERFORM DISPLAY_DATA.

*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING P_P_FILE.

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
  P_P_FILE = LX_FILETABLE-FILENAME.


  SPLIT P_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FILE_PATH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
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
FORM GET_DATA  CHANGING TA_FLATFILE TYPE TA_T_FLATFILE.


  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.

  DATA:LV_FILE TYPE RLGRAP-FILENAME.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH TA_FLATFILE[].

    LV_FILE = P_FILE.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = TA_FLATFILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.


*    DELETE TA_FLATFILE FROM 1 TO 2.

  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF TA_FLATFILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_PRICE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPLOAD_PRICE USING  TA_FLATFILE TYPE TA_T_FLATFILE .
*  BREAK BREDDY.
  SELECT *  FROM MARA INTO TABLE @DATA(IT_MARA)
                 FOR ALL ENTRIES IN @TA_FLATFILE
                 WHERE MATNR = @TA_FLATFILE-MATNR.
  DATA IT_MARA1 TYPE TABLE OF MARA .
  LOOP AT TA_FLATFILE INTO WA_FLATFILE.

    READ TABLE IT_MARA ASSIGNING FIELD-SYMBOL(<WA_MARA>) WITH KEY MATNR = WA_FLATFILE-MATNR.
    IF SY-SUBRC  = 0.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT  = WA_FLATFILE-MATNR
        IMPORTING
          OUTPUT = WA_FLATFILE-MATNR.

*      BREAK BREDDY.
*      UPDATE MARA SET ZZPRICE_FRM = WA_FLATFILE-PRICE_FRM
*                      ZZPRICE_TO  = WA_FLATFILE-PRICE_TO
**                      LAEDA       = SY-DATUM
**                      AENAM       = SY-UNAME
*                      WHERE MATNR =  WA_FLATFILE-MATNR.
      <WA_MARA>-ZZPRICE_FRM = WA_FLATFILE-PRICE_FRM .
      <WA_MARA>-ZZPRICE_TO = WA_FLATFILE-PRICE_TO .
      <WA_MARA>-LAEDA = SY-DATUM .
      <WA_MARA>-AENAM = SY-UNAME .

      APPEND <WA_MARA> TO IT_MARA1 .
      CLEAR <WA_MARA> .

    ELSE.
      WA_DISPLAY-TYPE = 'E'.
      WA_DISPLAY-MESSAGE1 = 'Material does not Exist'.
    ENDIF.



  ENDLOOP.


  MODIFY MARA FROM TABLE IT_MARA1 .

  IF SY-SUBRC = 0 .
*    WA_DISPLAY-MATNR = WA_FLATFILE-MATNR.
    WA_DISPLAY-TYPE = 'S'.
    WA_DISPLAY-MESSAGE = 'Changes done Successfully'.
  ENDIF.

  APPEND WA_DISPLAY TO IT_DISPLAY.
  CLEAR : WA_DISPLAY.


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

  DATA:LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
       LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
       LWA_LAYOUT  TYPE SLIS_LAYOUT_ALV.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'MATNR'.
  LS_FIELDCAT-SELTEXT_L = 'MATNR'.
  LS_FIELDCAT-SELTEXT_M = 'MATNR'.
  LS_FIELDCAT-SELTEXT_S = 'MATNR'.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'TYPE'.
  LS_FIELDCAT-SELTEXT_L = 'Message Type'.
  LS_FIELDCAT-SELTEXT_M = 'Message Type'.
  LS_FIELDCAT-SELTEXT_S = 'Message Type'.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

*  CLEAR LS_FIELDCAT.
*  LS_FIELDCAT-FIELDNAME = 'MESSAGE_V1'.
*  LS_FIELDCAT-SELTEXT_L = 'Material'.
*  LS_FIELDCAT-SELTEXT_M = 'Material'.
*  LS_FIELDCAT-SELTEXT_S = 'Material'.
*  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'MESSAGE'.
  LS_FIELDCAT-SELTEXT_L = 'Message'.
  LS_FIELDCAT-SELTEXT_M = 'Message'.
  LS_FIELDCAT-SELTEXT_S = 'Message'.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.


  LWA_LAYOUT-ZEBRA = 'X'.
  LWA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = LWA_LAYOUT
      IT_FIELDCAT        = LT_FIELDCAT
      I_SAVE             = 'X'
    TABLES
      T_OUTTAB           = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

ENDFORM.
