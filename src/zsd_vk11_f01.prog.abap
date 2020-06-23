*&---------------------------------------------------------------------*
*& Include          ZSD_VK11_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DATA USING P_GIT_FILE.
  LOOP AT GIT_FILE ASSIGNING FIELD-SYMBOL(<GS_FILE>).
    REFRESH : IT_BDCDATA,IT_MESSTAB.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                  <GS_FILE>-KSCHL. "'ZMKP'.
    PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(02)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=WEIT'.
    PERFORM BDC_FIELD       USING 'RV130-SELKZ(01)'
                                  ''.
    PERFORM BDC_FIELD       USING 'RV130-SELKZ(02)'
                                  'X'.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KONP-KPEIN(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'KOMG-LIFNR'
                                  <GS_FILE>-lifnr ."'SC0002423'.
    PERFORM BDC_FIELD       USING 'KOMG-MATNR(01)'
                                  <GS_FILE>-matnr. "  '311334-0'.
    PERFORM BDC_FIELD       USING 'KOMG-KBSTAT(01)'
                                  ''.
    PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                                  <GS_FILE>-KBETR .
    PERFORM BDC_FIELD       USING 'KONP-KONWA(01)'
                                  'INR'.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1502'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KOMG-MATNR(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SICH'.

    CALL TRANSACTION 'VK11' USING         IT_BDCDATA
                            MODE          CTUMODE
                            UPDATE        CUPDATE
                            MESSAGES INTO IT_MESSTAB.

    READ TABLE IT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSTAB>) WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      LOOP AT IT_MESSTAB ASSIGNING <LS_MESSTAB> WHERE MSGTYP = 'E'.
        CLEAR LS_FINAL.
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
            MSG       = LS_FINAL-MSG
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
        ENDIF.
        LS_FINAL-KSCHL   = <GS_FILE>-KSCHL.
        LS_FINAL-MATNR   = <GS_FILE>-MATNR.
        LS_FINAL-MATNR   = <GS_FILE>-lifnr.
        LS_FINAL-MSGTY   = <LS_MESSTAB>-MSGTYP..
        APPEND LS_FINAL TO LT_FINAL.
      ENDLOOP.
    ELSE.
      CLEAR : LS_FINAL.
      READ TABLE IT_MESSTAB ASSIGNING <LS_MESSTAB> WITH KEY MSGTYP = 'S' MSGID = 'L3' MSGNR = '016'.
      LS_FINAL-KSCHL   = <GS_FILE>-KSCHL.
      LS_FINAL-MATNR   = <GS_FILE>-lifnr.
      LS_FINAL-MATNR   = <GS_FILE>-MATNR.
      LS_FINAL-MSGTY   = 'S'.
      LS_FINAL-MSG     = 'Created Succesfully'.
      APPEND LS_FINAL TO LT_FINAL.
    ENDIF.
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

  WA_FCAT-FIELDNAME            = 'KSCHL'.
  WA_FCAT-TABNAME              = 'LT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'Condition Type'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'MATNR'.
  WA_FCAT-TABNAME              = 'LT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'Material'.
  WA_FCAT-OUTPUTLEN            = 20.
  WA_FCAT-JUST                 = 'C'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME            = 'LIFNR'.
  WA_FCAT-TABNAME              = 'LT_FINAL'.
  WA_FCAT-SELTEXT_M            = 'Vendor'.
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

***  IF lt_final IS NOT INITIAL.
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

FORM BDC_FIELD  USING FNAM FVAL.

  CLEAR WA_BDCDATA.
  WA_BDCDATA-FNAM = FNAM.
  WA_BDCDATA-FVAL = FVAL.
  SHIFT WA_BDCDATA-FVAL LEFT DELETING LEADING SPACE.
  APPEND WA_BDCDATA TO IT_BDCDATA.

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

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GIT_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE GIT_FILE[] FROM 1 TO 2.
  ELSE.
    MESSAGE E398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF GIT_FILE IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.
ENDFORM.
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
