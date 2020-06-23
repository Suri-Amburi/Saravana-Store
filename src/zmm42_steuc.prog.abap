*&---------------------------------------------------------------------*
*& Report ZMM42_STEUC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM42_STEUC.
*** File Structure
TYPES :
  BEGIN OF TY_FILE,
    MATERIAL(40),
    PLANT(4),
    STEUC(16),
  END OF TY_FILE,

*** Final table for Display Status
  BEGIN OF TY_FINAL,
    MATNR TYPE MARA-MATNR,
    WERKS TYPE MARC-WERKS,
    STEUC TYPE MARC-STEUC,
    MSG   TYPE TEXT255,
  END OF TY_FINAL.

DATA:
  LT_FILE       TYPE TABLE OF TY_FILE,
  LT_FINAL      TYPE TABLE OF TY_FINAL,
  FNAME         TYPE LOCALFILE,
  ENAME         TYPE CHAR4,

  LV_MATNR_LAST TYPE MATNR,
  LV_NUMBER_ERR TYPE TBIST-NUMERROR, "BIERRNUM,
  LT_ERROR      TYPE STANDARD TABLE OF MERRDAT_F,
  LT_MARA_HDR   TYPE STANDARD TABLE OF SMATNR_HDR,
  LT_MARA       TYPE STANDARD TABLE OF MARA_UEB,
  LT_MARC       TYPE STANDARD TABLE OF MARC_UEB,
  L_MSG(255).

CONSTANTS : C_SPACE TYPE C VALUE SPACE.
CONSTANTS : C_E TYPE C VALUE 'E'.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_FILE TYPE STRING.
SELECTION-SCREEN END OF BLOCK B1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

START-OF-SELECTION.
  PERFORM GET_DATA CHANGING LT_FILE.
  PERFORM PROCESS_DATA USING LT_FILE.

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

  LX_FILETABLE = LI_FILETABLE[ 1 ].
  P_P_FILE = LX_FILETABLE-FILENAME.

  SPLIT P_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FILE
*&---------------------------------------------------------------------*
FORM GET_DATA  CHANGING P_LT_FILE.
  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.
  DATA : LV_FILE TYPE RLGRAP-FILENAME.

  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.
    REFRESH LT_FILE[].
    LV_FILE = P_FILE.
***  FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = LT_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE LT_FILE[] FROM 1 TO 1.
  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.
  IF LT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.
ENDFORM.


FORM PROCESS_DATA  USING P_LT_FILE.

  DATA:
    LT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
    LS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  FIELD-SYMBOLS :
    <LS_FILE>    TYPE TY_FILE.

  LOOP AT LT_FILE ASSIGNING <LS_FILE>.
    REFRESH : LT_MARA , LT_MARC, LT_ERROR, LT_MARA_HDR.
    APPEND VALUE #( MANDT = SY-MANDT MATNR = <LS_FILE>-MATERIAL ) TO LT_MARA.
    APPEND VALUE #( MATNR = <LS_FILE>-MATERIAL ) TO LT_MARA_HDR.
    APPEND VALUE #( MANDT = SY-MANDT MATNR = <LS_FILE>-MATERIAL WERKS = <LS_FILE>-PLANT STEUC = <LS_FILE>-STEUC ) TO LT_MARC.
*    LV_MATNR_LAST = <LS_FILE>-MATERIAL.
*      CALL FUNCTION 'MATERIAL_MAINTAIN_DARK'
*        EXPORTING
*          SPERRMODUS                = 'E'
*          MAX_ERRORS                = 0
*          P_KZ_NO_WARN              = 'E'
*          KZ_PRF                    = C_SPACE
*          KZ_VERW                   = 'X'
*          KZ_AEND                   = 'X'
*          KZ_DISPO                  = 'X'
*          NO_DATABASE_UPDATE        = C_SPACE
*        IMPORTING
*          MATNR_LAST                = LV_MATNR_LAST
*          NUMBER_ERRORS_TRANSACTION = LV_NUMBER_ERR
*        TABLES
*          AMARA_UEB                 = LT_MARA
*          AMARC_UEB                 = LT_MARC
*          AMERRDAT                  = LT_ERROR
*        EXCEPTIONS
*          KSTATUS_EMPTY             = 1
*          TKSTATUS_EMPTY            = 2
*          T130M_ERROR               = 3
*          INTERNAL_ERROR            = 4
*          TOO_MANY_ERRORS           = 5
*          UPDATE_ERROR              = 6
*          ERROR_PROPAGATE_HEADER    = 7
*          OTHERS                    = 8.

    CALL FUNCTION 'MATERIAL_MAINTAIN_DARK_RETAIL'
      EXPORTING
        FLAG_MUSS_PRUEFEN         = 'X'
        SPERRMODUS                = 'E'
        MAX_ERRORS                = 0
        P_KZ_NO_WARN              = 'N'
        KZ_PRF                    = C_SPACE
        KZ_VERW                   = 'X'
        KZ_AEND                   = 'X'
        KZ_DISPO                  = 'X'
        KZ_TEST                   = ' '
        NO_DATABASE_UPDATE        = ' '
        CALL_MODE                 = ' '
        CALL_MODE2                = ' '
      IMPORTING
        MATNR_LAST                = LV_MATNR_LAST
        NUMBER_ERRORS_TRANSACTION = LV_NUMBER_ERR
      TABLES
        MATNR_HDR                 = LT_MARA_HDR
        AMARC_UEB                 = LT_MARC
        AMERRDAT                  = LT_ERROR
      EXCEPTIONS
        T130M_ERROR               = 1
        INTERNAL_ERROR            = 2
        TOO_MANY_ERRORS           = 3
        UPDATE_ERROR              = 4
        OTHERS                    = 5.
    IF SY-SUBRC <> 0.
*     Implement suitable error handling here
    ENDIF.

    IF NOT ( SY-SUBRC IS INITIAL ).
      APPEND VALUE #( MATNR = <LS_FILE>-MATERIAL WERKS = <LS_FILE>-PLANT STEUC = <LS_FILE>-STEUC MSG = 'Error' ) TO LT_FINAL.
    ELSE.
      READ TABLE LT_ERROR ASSIGNING FIELD-SYMBOL(<LS_ERROR>) WITH KEY MSGTY = C_E.
      IF SY-SUBRC = 0.
        READ TABLE LT_ERROR ASSIGNING <LS_ERROR> WITH KEY MSGTY = 'D' MSGID = 'MH' MSGNO = '243'.
        IF SY-SUBRC = 0.
          APPEND VALUE #( MATNR = <LS_FILE>-MATERIAL WERKS = <LS_FILE>-PLANT STEUC = <LS_FILE>-STEUC MSG = 'Success' ) TO LT_FINAL.
          COMMIT WORK.
        ELSE.
          APPEND VALUE #( MATNR = <LS_FILE>-MATERIAL WERKS = <LS_FILE>-PLANT STEUC = <LS_FILE>-STEUC MSG = 'Error' ) TO LT_FINAL.
        ENDIF.
      ELSE.
        COMMIT WORK.
        APPEND VALUE #( MATNR = <LS_FILE>-MATERIAL WERKS = <LS_FILE>-PLANT STEUC = <LS_FILE>-STEUC MSG = 'Success' ) TO LT_FINAL.
      ENDIF.
    ENDIF.
  ENDLOOP.

*** Field Cat Log
  APPEND VALUE #( FIELDNAME = 'MATNR' TABNAME = 'GT_FINAL' SELTEXT_M = 'Material' OUTPUTLEN = 20 JUST = 'C' ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'WERKS' TABNAME = 'GT_FINAL' SELTEXT_M = 'Plant'    OUTPUTLEN = 20 JUST = 'C' ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'STEUC' TABNAME = 'GT_FINAL' SELTEXT_M = 'HSN'      OUTPUTLEN = 20 JUST = 'C' ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'MSG'   TABNAME = 'GT_FINAL' SELTEXT_M = 'Message'  OUTPUTLEN = 10 JUST = 'C' ) TO LT_FCAT.
***  Display Report.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = LS_LAYOUT
      IT_FIELDCAT        = LT_FCAT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = LT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.
