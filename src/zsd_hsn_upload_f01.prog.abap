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
FORM PROCESS_DATA.
  DATA :
    LV_MSG     TYPE STRING,
    LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.
  FIELD-SYMBOLS:
    <LS_MESSTAB> TYPE BDCMSGCOLL.

  LOOP AT GT_FILE ASSIGNING FIELD-SYMBOL(<GS_FILE>).
    REFRESH : GT_BDCDATA,LT_MESSTAB.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                  <GS_FILE>-KSCHL.
    PERFORM BDC_DYNPRO      USING 'SAPLV14A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=WEIT'.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1519'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KONP-MWSK1(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'KOMG-ALAND'
                                  <GS_FILE>-ALAND.
    PERFORM BDC_FIELD       USING 'KOMG-WKREG(01)'
                                  <GS_FILE>-WKREG.
    PERFORM BDC_FIELD       USING 'KOMG-REGIO(01)'
                                  <GS_FILE>-REGIO.
    PERFORM BDC_FIELD       USING 'KOMG-STEUC(01)'
                                  <GS_FILE>-STEUC.
    PERFORM BDC_FIELD       USING 'KOMG-WAERK(01)'
                                  'INR'.
    PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                                  ''.
    PERFORM BDC_FIELD       USING 'KONP-KONWA(01)'
                                  ''.
    PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)'
                                  '01.02.2020'.

    PERFORM BDC_FIELD       USING 'KONP-MWSK1(01)'
                                  <GS_FILE>-MWSK1.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1519'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KOMG-WKREG(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SICH'.

    CALL TRANSACTION 'VK11' USING         GT_BDCDATA
                            MODE          CTUMODE
                            UPDATE        CUPDATE
                            MESSAGES INTO LT_MESSTAB.

    READ TABLE LT_MESSTAB ASSIGNING <LS_MESSTAB> WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      LOOP AT LT_MESSTAB ASSIGNING <LS_MESSTAB> WHERE MSGTYP = 'E'.
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
        APPEND VALUE #( SLNO = <GS_FILE>-SLNO KSCHL  = <GS_FILE>-KSCHL ALAND = <GS_FILE>-ALAND WKREG = <GS_FILE>-WKREG REGIO = <GS_FILE>-REGIO STEUC = <GS_FILE>-STEUC MSGTYP = <LS_MESSTAB>-MSGTYP MSG = LV_MSG ) TO GT_FINAL.
      ENDLOOP.
    ELSE.
      READ TABLE LT_MESSTAB ASSIGNING <LS_MESSTAB> WITH KEY MSGTYP = 'S' MSGID = 'VK' MSGNR = '023'.
      IF SY-SUBRC = 0.
        APPEND VALUE #( SLNO = <GS_FILE>-SLNO KSCHL  = <GS_FILE>-KSCHL ALAND = <GS_FILE>-ALAND WKREG = <GS_FILE>-WKREG REGIO = <GS_FILE>-REGIO STEUC = <GS_FILE>-STEUC MSGTYP = 'S' MSG = 'Created Succesfully') TO GT_FINAL.
      ELSE.
        APPEND VALUE #( SLNO = <GS_FILE>-SLNO KSCHL  = <GS_FILE>-KSCHL ALAND = <GS_FILE>-ALAND WKREG = <GS_FILE>-WKREG REGIO = <GS_FILE>-REGIO STEUC = <GS_FILE>-STEUC MSGTYP = 'S' MSG = 'Not Created') TO GT_FINAL.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DATA:
    LT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
    LS_LAYOUT TYPE SLIS_LAYOUT_ALV.
*** Field Cat log
  APPEND VALUE #( FIELDNAME = 'SLNO'   TABNAME = 'GT_FINAL' SELTEXT_M = 'SLNO'           OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'KSCHL'  TABNAME = 'GT_FINAL' SELTEXT_M = 'Condition Type' OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'REGIO'  TABNAME = 'GT_FINAL' SELTEXT_M = 'Region'         OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'STEUC'  TABNAME = 'GT_FINAL' SELTEXT_M = 'HSN Code'       OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'MSGTYP' TABNAME = 'GT_FINAL' SELTEXT_M = 'Message Type'   OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'MSG'    TABNAME = 'GT_FINAL' SELTEXT_M = 'Message'        OUTPUTLEN = 50 ) TO LT_FCAT.

*** Display Final Table
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
