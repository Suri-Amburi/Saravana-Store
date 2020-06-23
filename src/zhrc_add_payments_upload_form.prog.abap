*&---------------------------------------------------------------------*
*& Include          ZHRC_ADD_PAYMENTS_UPLOAD_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  IF P_FILE IS NOT INITIAL .



    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
        I_LINE_HEADER        = 'X'
        I_TAB_RAW_DATA       = IT_TYPE
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = IT_FINAL
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.

ENDFORM.

FORM BDC_DATA.
  IF P_FILE IS NOT INITIAL.
    IF  IT_FINAL IS NOT INITIAL .

      LOOP AT IT_FINAL INTO WA_FINAL .

        PERFORM BDC_DYNPRO      USING 'SAPMP50A' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=INS'.
        PERFORM BDC_FIELD       USING 'RP50G-PERNR'
                                      WA_FINAL-PERNR.
        PERFORM BDC_FIELD       USING 'RP50G-TIMR6'
                                'X'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RP50G-SUBTY'.
        PERFORM BDC_FIELD       USING 'RP50G-CHOIC'
                                '15'.
        PERFORM BDC_FIELD       USING 'RP50G-SUBTY'
                                      WA_FINAL-SUBTY.
        PERFORM BDC_DYNPRO      USING 'MP001500' '2040'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'Q0015-BETRG'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                'UPD'.
        PERFORM BDC_FIELD       USING 'Q0015-BETRG'
                                      WA_FINAL-BETRG.
        PERFORM BDC_FIELD       USING 'P0015-WAERS'
                                'INR'.
        PERFORM BDC_FIELD       USING 'P0015-BEGDA'
                                     WA_FINAL-BEGDA.
*     PERFORM bdc_transaction USING 'PA30'.


        REFRESH: IT_MESSTAB.
        CALL TRANSACTION 'PA30' USING IT_BDCDATA
                         MODE   CTUMODE
                         UPDATE CUPDATE
                         MESSAGES INTO IT_MESSTAB.
        REFRESH IT_BDCDATA.

        LOOP AT IT_MESSTAB INTO WA_MESSTAB.

          WA_LOG-PERNR = WA_FINAL-PERNR.

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
              MSG       = WA_LOG-MSG_TEXT
            EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.

          MOVE-CORRESPONDING WA_MESSTAB TO WA_LOG.
          APPEND WA_LOG TO IT_LOG.
          CLEAR : WA_LOG, WA_FINAL.


        ENDLOOP.

      ENDLOOP.

    ENDIF.
  ENDIF.
ENDFORM.


FORM BDC_DYNPRO  USING   PROGRAM DYNPRO.

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
*&      --> WA_FINAL_PERNR
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
*& Form CATALOG_DESIGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CATALOG_DESIGN .


  PERFORM CREATE_FIELDCAT USING:

         '01' '01' 'PERNR'    'IT_LOG' 'L' 'EMPLOYEE NUMBER',
         '01' '02' 'TCODE'    'IT_LOG' 'L' 'TCODE',
         '01' '03' 'DYNAME'   'IT_LOG' 'L' 'DYNAME',
         '01' '04' 'DYNUMB'   'IT_LOG' 'L' 'DYNUMB',
         '01' '05' 'MSGTYP'   'IT_LOG' 'L' 'MSGTYP',
         '01' '06' 'MSGSPRA'  'IT_LOG' 'L' 'MSGSPRA',
         '01' '07' 'MSGID'    'IT_LOG' 'L' 'MSGID',
         '01' '8' 'MSGNR'    'IT_LOG' 'L' 'MSGNR',
         '01' '9' 'MSGV1'    'IT_LOG' 'L' 'MSGV1',
         '01' '10' 'MSGV2'    'IT_LOG' 'L' 'MSGV2',
         '01' '11' 'MSGV3'    'IT_LOG' 'L' 'MSGV3',
         '01' '12' 'MSGV4'    'IT_LOG' 'L' 'MSGV4',
         '01' '13' 'ENV'      'IT_LOG' 'L' 'ENV',
         '01' '14' 'FLDNAME'  'IT_LOG' 'L' 'FLDNAME',
         '01' '15' 'MSG_TEXT'  'IT_LOG' 'L' 'MESSAGE'.

ENDFORM.



FORM CREATE_FIELDCAT  USING  FP_ROWPOS    TYPE SYCUROW
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

FORM DISPLAY .

  DATA: L_REPID TYPE SYREPID .


  IF P_FILE IS NOT INITIAL.


    IF IT_LOG IS NOT INITIAL.

      WA_LAYOUT-ZEBRA = 'X'.
      WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         I_INTERFACE_CHECK  = ' '
*         I_BYPASSING_BUFFER = ' '
*         I_BUFFER_ACTIVE    = ' '
*         i_callback_program = l_repid
*         I_CALLBACK_PF_STATUS_SET          = ' '
*         I_CALLBACK_USER_COMMAND           = ' '
*         I_CALLBACK_TOP_OF_PAGE            = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*         I_CALLBACK_HTML_END_OF_LIST       = ' '
*         I_STRUCTURE_NAME   =
*         I_BACKGROUND_ID    = ' '
*         I_GRID_TITLE  =
*         I_GRID_SETTINGS    =
          IS_LAYOUT     = WA_LAYOUT
          IT_FIELDCAT   = IT_FIELDCAT
*         IT_EXCLUDING  =
*         IT_SPECIAL_GROUPS  =
*         IT_SORT       =
*         IT_FILTER     =
*         IS_SEL_HIDE   =
*         I_DEFAULT     = 'X'
          I_SAVE        = 'X'
*         IS_VARIANT    =
*         IT_EVENTS     =
*         IT_EVENT_EXIT =
*         IS_PRINT      =
*         IS_REPREP_ID  =
*         I_SCREEN_START_COLUMN             = 0
*         I_SCREEN_START_LINE               = 0
*         I_SCREEN_END_COLUMN               = 0
*         I_SCREEN_END_LINE  = 0
*         I_HTML_HEIGHT_TOP  = 0
*         I_HTML_HEIGHT_END  = 0
*         IT_ALV_GRAPHICS    =
*         IT_HYPERLINK  =
*         IT_ADD_FIELDCAT    =
*         IT_EXCEPT_QINFO    =
*         IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*         E_EXIT_CAUSED_BY_CALLER           =
*         ES_EXIT_CAUSED_BY_USER            =
        TABLES
          T_OUTTAB      = IT_LOG
        EXCEPTIONS
          PROGRAM_ERROR = 1
          OTHERS        = 2.
      IF SY-SUBRC <> 0.
* MESSAGE 'RROR IN ALV DISPLAY'(010) TYPE 'E'.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.
