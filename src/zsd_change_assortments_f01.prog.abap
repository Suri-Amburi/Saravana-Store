*&---------------------------------------------------------------------*
*& Include          ZSD_CHANGE_ASSORTMENTS_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DATA.
  DATA :
    LV_MSG     TYPE STRING,
    LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.
  FIELD-SYMBOLS:
    <LS_MESSTAB> TYPE BDCMSGCOLL,
    <LS_FILE>    TYPE TY_FILE.

  LOOP AT GT_FILE ASSIGNING <LS_FILE>.
    REFRESH : GT_BDCDATA,LT_MESSTAB.

    PERFORM BDC_DYNPRO      USING 'WRFM_WSO6' '0001'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'V_WRS1-ASORT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM BDC_FIELD       USING 'V_WRS1-ASORT'
                                  <LS_FILE>-ASSRT.  " 'UNIVERSAL'.
    PERFORM BDC_DYNPRO      USING 'WRFM_WSO6' '0010'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'V_WRS1-NAME1'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'V_WRS1-NAME1'
                                  'UNIVERSAL'.
    PERFORM BDC_FIELD       USING 'V_WRS1-STATU'
                                  '1'.
    PERFORM BDC_FIELD       USING 'V_WRS1-VKORG'
                                  '1000'.
    PERFORM BDC_FIELD       USING 'V_WRS1-VTWEG'
                                  '10'.
    PERFORM BDC_FIELD       USING 'V_WRS1-KZLIK'
                                  'X'.
    PERFORM BDC_FIELD       USING 'V_WRS1-LSTFL'
                                  '02'.
    PERFORM BDC_FIELD       USING 'V_WRS1-LAYPR'
                                  'X'.
    PERFORM BDC_DYNPRO      USING 'WRFM_WSO6' '0010'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'V_WRS1-NAME1'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ASORT_TAB_FC3'.
    PERFORM BDC_FIELD       USING 'V_WRS1-NAME1'
                                  'UNIVERSAL'.
    PERFORM BDC_FIELD       USING 'V_WRS1-STATU'
                                  '1'.
    PERFORM BDC_FIELD       USING 'V_WRS1-VKORG'
                                  '1000'.
    PERFORM BDC_FIELD       USING 'V_WRS1-VTWEG'
                                  '10'.
    PERFORM BDC_FIELD       USING 'V_WRS1-KZLIK'
                                  'X'.
    PERFORM BDC_FIELD       USING 'V_WRS1-LSTFL'
                                  '02'.
    PERFORM BDC_FIELD       USING 'V_WRS1-LAYPR'
                                  'X'.
    PERFORM BDC_DYNPRO      USING 'WRFM_WSO6' '0010'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'V_WRS1-NAME1'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=MSL'.
    PERFORM BDC_FIELD       USING 'V_WRS1-NAME1'
                                  'UNIVERSAL'.
    PERFORM BDC_DYNPRO      USING 'SAPLSDH4' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=GOON'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'G_SELFLD_TAB-LOW(01)'.
    PERFORM BDC_FIELD       USING 'DDSHF4CTRL-MAXRECORDS'
                                  ' 500'.
    PERFORM BDC_FIELD       USING 'G_SELFLD_TAB-LOW(01)'
                                    <LS_FILE>-MATKL. "'mr01'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0' '0120'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  '04/05'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=AMAR'.
    PERFORM BDC_DYNPRO      USING 'SAPMSSY0' '0120'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  '04/05'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM BDC_DYNPRO      USING 'WRFM_WSO6' '0010'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'V_WRS1-NAME1'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=XSI'.
    PERFORM BDC_FIELD       USING 'V_WRS1-NAME1'
                                  'UNIVERSAL'.

    CALL TRANSACTION 'WSOA2' USING         GT_BDCDATA
                             MODE          CTUMODE
                             UPDATE        CUPDATE
                             MESSAGES INTO LT_MESSTAB.

    READ TABLE LT_MESSTAB ASSIGNING <LS_MESSTAB> WITH KEY MSGTYP = C_E.
    IF SY-SUBRC = 0.
      LOOP AT LT_MESSTAB ASSIGNING <LS_MESSTAB> WHERE MSGTYP = C_E.
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
            MSG       = LV_MSG
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
        ENDIF.
        <LS_FILE>-MSGTYP = <LS_MESSTAB>-MSGTYP.
        <LS_FILE>-MSG = LV_MSG.
      ENDLOOP.
    ELSE.
      <LS_FILE>-MSGTYP = 'S'.
      <LS_FILE>-MSG = 'Created Succesfully'.
    ENDIF.
ENDLOOP.

DATA:
  LT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
  LS_LAYOUT TYPE SLIS_LAYOUT_ALV.
*** Field Cat log
APPEND VALUE #( FIELDNAME = 'SLNO'   TABNAME = 'GT_FILE' SELTEXT_M = 'SLNO'           OUTPUTLEN = 20 ) TO LT_FCAT.
APPEND VALUE #( FIELDNAME = 'MATKL'  TABNAME = 'GT_FILE' SELTEXT_M = 'Material Group' OUTPUTLEN = 20 ) TO LT_FCAT.
APPEND VALUE #( FIELDNAME = 'MSGTYP' TABNAME = 'GT_FILE' SELTEXT_M = 'Message Type'   OUTPUTLEN = 20 ) TO LT_FCAT.
APPEND VALUE #( FIELDNAME = 'MSG'    TABNAME = 'GT_FILE' SELTEXT_M = 'Message'        OUTPUTLEN = 50 ) TO LT_FCAT.

*** Display Final Table
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    I_CALLBACK_PROGRAM = SY-REPID
    IS_LAYOUT          = LS_LAYOUT
    IT_FIELDCAT        = LT_FCAT
    I_SAVE             = 'A'
  TABLES
    T_OUTTAB           = GT_FILE
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
  APPEND VALUE #( PROGRAM  = PROGRAM DYNPRO = DYNPRO DYNBEGIN = C_X ) TO GT_BDCDATA.
ENDFORM.

FORM BDC_FIELD USING FNAM FVAL.
  DATA : LS_BDCDATA TYPE BDCDATA.
  CLEAR LS_BDCDATA.
  LS_BDCDATA-FNAM = FNAM.
  LS_BDCDATA-FVAL = FVAL.
  SHIFT LS_BDCDATA-FVAL LEFT DELETING LEADING SPACE.
  APPEND LS_BDCDATA TO GT_BDCDATA.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GIT_FILE
*&---------------------------------------------------------------------*
FORM GET_DATA.

  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GT_FILE[].
    LV_FILE = P_FILE.

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
    MESSAGE E069(ZMSG_CLS).
    EXIT.
  ENDIF.

  IF GT_FILE IS INITIAL.
    MESSAGE E070(ZMSG_CLS).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING P_FILE.
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

  P_FILE = LI_FILETABLE[ 1 ]-FILENAME.
  SPLIT P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.
ENDFORM.
