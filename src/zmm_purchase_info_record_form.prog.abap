*&---------------------------------------------------------------------*
*& Include          ZMM_PURCHASE_INFO_RECORD_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING FP_P_FILE TYPE STRING.

  DATA: LI_FILETABLE    TYPE FILETABLE,    "FILENAMETABLE
        LX_FILETABLE    TYPE FILE_TABLE,   "FILETABLE
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
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GIT_FILE  text
*----------------------------------------------------------------------*
FORM GET_DATA  CHANGING GIT_FILE TYPE GTY_T_FILE.

  DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.

  DATA:LV_FILE TYPE RLGRAP-FILENAME.


*  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

*    REFRESH GIT_FILE[].

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


    DELETE GIT_FILE FROM 1 TO 2.

*  ELSE.
*    MESSAGE E398(00) WITH 'Invalid File Type'  .
*  ENDIF.

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

  DATA: MSG_TEXT TYPE STRING.
  DATA :  F_OPTION TYPE CTU_PARAMS.

  SORT GIT_FILE[] BY LIFNR.

  GIT_FILE_D[] = GIT_FILE_I[] = GIT_FILE[].

  LOOP AT GIT_FILE INTO GWA_FILE.

    REFRESH IT_BDCDATA[].

 perform bdc_dynpro      using 'SAPMM06I' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'EINA-LIFNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'EINA-LIFNR'
                                gwa_file-lifnr.             "'200263'.
  perform bdc_field       using 'EINA-MATNR'
                                gwa_file-matnr."'PILLOW6'.
  perform bdc_field       using 'EINE-EKORG'
                                gwa_file-ekorg."'1000'.
  perform bdc_field       using 'EINE-WERKS'
                                gwa_file-werks."'P001'.
 if  gwa_file-normb is not initial.

 perform bdc_field       using 'RM06I-NORMB'
                                gwa_file-normb.
 endif.
 if  gwa_file-lohnb is not initial.

 perform bdc_field       using 'RM06I-LOHNB'
                                gwa_file-lohnb.
  endif.
  perform bdc_dynpro      using 'SAPMM06I' '0101'.
  perform bdc_field       using 'BDC_CURSOR'
                                'EINA-MAHN3'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'EINA-MAHN1'
                                gwa_file-MAHN1. "'1'.
  perform bdc_field       using 'EINA-MAHN2'
                                gwa_file-MAHN2."'2'.
  perform bdc_field       using 'EINA-MAHN3'
                                gwa_file-MAHN3. "'3'.
*  perform bdc_field       using 'EINA-URZLA'
*                                'IN'.
*  perform bdc_field       using 'EINA-REGIO'
*                                '22'.
  perform bdc_field       using 'EINA-MEINS'
                                 gwa_file-MEINS."'EA'
  perform bdc_field       using 'EINA-UMREZ'
                                gwa_file-UMREZ."'1'.
  perform bdc_field       using 'EINA-UMREN'
                                gwa_file-UMREN. "'1'.

  perform bdc_dynpro      using 'SAPMM06I' '0102'.
  perform bdc_field       using 'BDC_CURSOR'
                                'EINE-NETPR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'EINE-APLFZ'
                                GWA_FILE-APLFZ."'4'.
*  perform bdc_field       using 'EINE-UNTTO'
*                                '5.0'.
  perform bdc_field       using 'EINE-EKGRP'
                                GWA_FILE-EKGRP."'P01'.
*  perform bdc_field       using 'EINE-UEBTO'
*                                '5.0'.
  perform bdc_field       using 'EINE-NORBM'
                                GWA_FILE-NORBM."'1'.
  perform bdc_field       using 'EINE-MINBM'
                                GWA_FILE-MINBM."'1'.
  if GWA_FILE-WEBRE IS NOT INITIAL.
  perform bdc_field       using 'EINE-WEBRE'
                                GWA_FILE-WEBRE."'X'.
  endif.
  perform bdc_field       using 'EINE-MWSKZ'
                                GWA_FILE-MWSKZ."'V6'.

*  perform bdc_field       using 'EINE-IPRKZ'
*                                GWA_FILE-IPRKZ."'D'.
  if GWA_FILE-VERID IS NOT INITIAL.
  perform bdc_field       using 'EINE-VERID'
                                GWA_FILE-VERID."'SPO'.
  endif.
  perform bdc_field       using 'EINE-NETPR'
                                GWA_FILE-NETPR." '300'.
*  perform bdc_field       using 'EINE-WAERS'
*                                'INR'.
  perform bdc_field       using 'EINE-PEINH'
                                GWA_FILE-PEINH."'1'.
  if GWA_FILE-BPRME IS NOT INITIAL.
  perform bdc_field       using 'EINE-BPRME'
                                GWA_FILE-BPRME."'EA'.
  endif.
  perform bdc_field       using 'EINE-BPUMZ'
                                GWA_FILE-BPUMZ."'1'.
  perform bdc_field       using 'EINE-BPUMN'
                                GWA_FILE-BPUMN."'1'.
  perform bdc_dynpro      using 'SAPMM06I' '0105'.
  perform bdc_field       using 'BDC_CURSOR'
                                'EINE-ANGNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=KO'.
  perform bdc_dynpro      using 'SAPMV13A' '1017'.
  perform bdc_field       using 'BDC_CURSOR'
                                'KOMG-ESOKZ(01)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=SICH'.

    F_OPTION-DEFSIZE = 'X'.
    F_OPTION-DISMODE = 'N'.
    F_OPTION-UPDMODE = 'A'.

    REFRESH : IT_MSGCOLL.

    CALL TRANSACTION 'ME11'  USING  IT_BDCDATA
                             OPTIONS FROM F_OPTION
                             MESSAGES INTO IT_MSGCOLL.
    REFRESH IT_BDCDATA.

    LOOP AT IT_MSGCOLL INTO WA_MSGCOLL.

      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          ID        = WA_MSGCOLL-MSGID
          LANG      = 'EN'
          NO        = WA_MSGCOLL-MSGNR
          V1        = WA_MSGCOLL-MSGV1
          V2        = WA_MSGCOLL-MSGV2
          V3        = SY-MSGV3
          V4        = SY-MSGV4
        IMPORTING
          MSG       = MSG_TEXT
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
      ENDIF.

      MOVE-CORRESPONDING WA_MSGCOLL TO WA_LOG.
      WA_LOG-LIFNR = GWA_FILE-LIFNR.
      WA_LOG-MSG_TEXT = MSG_TEXT.
      APPEND WA_LOG TO IT_LOG.
      CLEAR:WA_LOG,WA_MSGCOLL,MSG_TEXT.

*    ENDLOOP.
    ENDLOOP.
  ENDLOOP.
*    CLEAR:gwa_file,cnt.
  REFRESH IT_MSGCOLL.
*  ENDLOOP.
ENDFORM.

FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR WA_BDCDATA.
  WA_BDCDATA-PROGRAM  = PROGRAM.
  WA_BDCDATA-DYNPRO   = DYNPRO.
  WA_BDCDATA-DYNBEGIN = 'X'.
  APPEND WA_BDCDATA TO IT_BDCDATA.
ENDFORM.

FORM BDC_FIELD USING FNAM FVAL.

  CLEAR WA_BDCDATA.
  WA_BDCDATA-FNAM = FNAM.
  WA_BDCDATA-FVAL = FVAL.
  APPEND WA_BDCDATA TO IT_BDCDATA.
*  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELD_CATLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATLOG .

  PERFORM CREATE_FIELDCAT USING:

       '01' '01' 'LIFNR'    'IT_LOG' 'L' 'Vendor No',
       '01' '02' 'MSGID'    'IT_LOG' 'L' 'MSGID',
       '01' '03' 'MSGNR'    'IT_LOG' 'L' 'MSGNR',
       '01' '04' 'MSGV1'    'IT_LOG' 'L' 'MSGV1',
       '01' '05' 'MSGV2'    'IT_LOG' 'L' 'MSGV2',
       '01' '06' 'MSGV3'    'IT_LOG' 'L' 'MSGV3',
       '01' '07' 'MSGV4'    'IT_LOG' 'L' 'MSGV4',
       '01' '08' 'ENV'      'IT_LOG' 'L' 'ENV',
       '01' '09' 'FLDNAME'  'IT_LOG' 'L' 'FLDNAME',
       '01' '10' 'MSG_TEXT'  'IT_LOG' 'L' 'Message'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0554   text
*      -->P_0555   text
*      -->P_0556   text
*      -->P_0557   text
*      -->P_0558   text
*      -->P_0559   text
*----------------------------------------------------------------------*
FORM CREATE_FIELDCAT  USING FP_ROWPOS    TYPE SYCUROW
                            FP_COLPOS    TYPE SYCUCOL
                            FP_FLDNAM    TYPE FIELDNAME
                            FP_TABNAM    TYPE TABNAME
                            FP_JUSTIF    TYPE CHAR1
                            FP_SELTEXT   TYPE DD03P-SCRTEXT_L.

  DATA: WA_FCAT    TYPE  SLIS_FIELDCAT_ALV.
  WA_FCAT-ROW_POS        =  FP_ROWPOS.     "Row
  WA_FCAT-COL_POS        =  FP_COLPOS.     "Column
  WA_FCAT-FIELDNAME      =  FP_FLDNAM.     "Field Name
  WA_FCAT-TABNAME        =  FP_TABNAM.     "Internal Table Name
  WA_FCAT-JUST           =  FP_JUSTIF.     "Screen Justified
  WA_FCAT-SELTEXT_L      =  FP_SELTEXT.    "Field Text

  APPEND WA_FCAT TO IT_FIELDCAT.

  CLEAR WA_FCAT.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV .

  DATA: L_REPID TYPE SYREPID .

  IF IT_LOG IS NOT INITIAL.

    WA_LAYOUT-ZEBRA = 'X'.
    WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.


    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_CALLBACK_PROGRAM = L_REPID
        IS_LAYOUT          = WA_LAYOUT
        IT_FIELDCAT        = IT_FIELDCAT
        I_SAVE             = 'X'
      TABLES
        T_OUTTAB           = IT_LOG
      EXCEPTIONS
        PROGRAM_ERROR      = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* MESSAGE 'ERROR IN ALV DISPLAY'(010) TYPE 'I'.
    ENDIF.
  ENDIF.
ENDFORM.
