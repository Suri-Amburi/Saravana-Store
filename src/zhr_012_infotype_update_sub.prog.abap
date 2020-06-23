*&---------------------------------------------------------------------*
*&  Include           ZHR_012_INFOTYPE_UPDATE_SUB
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING FP_P_FILE TYPE STRING.

  DATA: LI_FILETABLE    TYPE FILETABLE,
        LX_FILETABLE    TYPE FILE_TABLE,
        LV_RETURN_CODE  TYPE I,
        LV_WINDOW_TITLE TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LV_WINDOW_TITLE
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      FILE_TABLE              = LI_FILETABLE
      RC                      = LV_RETURN_CODE
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE   LI_FILETABLE INTO LX_FILETABLE INDEX 1.
*
  FP_P_FILE = LX_FILETABLE-FILENAME.

*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT FP_P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.

ENDFORM.                    " GET_FILENAME


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM GET_DATA CHANGING IT_FINAL TYPE GTY_T_DATA.

  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.
    LV_FILE = P_FILE.

    REFRESH:IT_FINAL[].

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = IT_FINAL[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.

    DELETE IT_FINAL FROM 1 TO 2.

  ELSE.
    MESSAGE 'Invalid File Path' TYPE 'E'.
  ENDIF.

  IF IT_FINAL[] IS INITIAL.
    MESSAGE 'No Data Exists' TYPE 'E'.
  ENDIF.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM PROCESS_DATA USING IT_FINAL TYPE GTY_T_DATA.

  DATA: LV_DATE TYPE P0000-BEGDA,
        LV_FLAG TYPE C.

  LOOP AT IT_FINAL ASSIGNING <FS_FINAL>.
    IF <FS_FINAL> IS ASSIGNED.

      REFRESH: GT_PROP[].
************** INFOTYPE-0000*****************************
      CLEAR: LV_FLAG.

      IF <FS_FINAL>-MASSN IS NOT INITIAL.
        PERFORM ADD_DATA USING '0000'
                               'P0000-MASSN'
                               <FS_FINAL>-MASSN.
        LV_FLAG = 'X'.

      ENDIF.

      IF <FS_FINAL>-MASSG IS NOT INITIAL.
        PERFORM ADD_DATA USING '0000'
                               'P0000-MASSG'
                               <FS_FINAL>-MASSG.
        LV_FLAG = 'X'.
      ENDIF.


      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-BEGDA+6(4)
                  <FS_FINAL>-BEGDA+3(2)
                  <FS_FINAL>-BEGDA+0(2)
                INTO LV_DATE.

      IF <FS_FINAL>-BEGDA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0000'
                               'P0000-BEGDA'
                               LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.

      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-ENDDA+6(4)
                  <FS_FINAL>-ENDDA+3(2)
                  <FS_FINAL>-ENDDA+0(2)
             INTO LV_DATE .

      IF <FS_FINAL>-ENDDA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0000'
                               'P0000-ENDDA'
                               LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-PERNR IS NOT INITIAL AND
                LV_FLAG IS NOT INITIAL .

        PERFORM ADD_DATA USING '0000'
                               'P0000-PERNR'
                               <FS_FINAL>-PERNR.
      ENDIF.
************** INFOTYPE-0001*****************************
      CLEAR: LV_FLAG.



      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-BEGDA+6(4)
                  <FS_FINAL>-BEGDA+3(2)
                  <FS_FINAL>-BEGDA+0(2)
             INTO LV_DATE.

      IF <FS_FINAL>-BEGDA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-BEGDA'
                               LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.

      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-ENDDA+6(4)
                  <FS_FINAL>-ENDDA+3(2)
                  <FS_FINAL>-ENDDA+0(2)
            INTO LV_DATE .

      IF <FS_FINAL>-ENDDA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-ENDDA'
                               LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-PLANS IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-PLANS'
                               <FS_FINAL>-PLANS.
        LV_FLAG = 'X'.
      ENDIF.
      IF <FS_FINAL>-WERKS IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-WERKS'
                               <FS_FINAL>-WERKS.
        LV_FLAG = 'X'.
      ENDIF.



      IF <FS_FINAL>-PERSG IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-PERSG'
                               <FS_FINAL>-PERSG.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-PERSK IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-PERSK'
                               <FS_FINAL>-PERSK.
        LV_FLAG = 'X'.
      ENDIF.
      IF <FS_FINAL>-BTRTL IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-BTRTL'
                               <FS_FINAL>-BTRTL.
        LV_FLAG = 'X'.
      ENDIF.
      IF <FS_FINAL>-ABKRS IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-ABKRS'
                               <FS_FINAL>-ABKRS.
        LV_FLAG = 'X'.
      ENDIF.
      IF <FS_FINAL>-STELL IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-STELL'
                               <FS_FINAL>-STELL.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-VDSK1 IS NOT INITIAL.
        PERFORM ADD_DATA USING '0001'
                               'P0001-VDSK1'
                               <FS_FINAL>-VDSK1.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-PERNR IS NOT INITIAL AND
               LV_FLAG  IS NOT INITIAL.

        PERFORM ADD_DATA USING '0001'
                               'P0001-PERNR'
                               <FS_FINAL>-PERNR.
      ENDIF.

************** INFOTYPE-0002*****************************
      CLEAR: LV_FLAG.

      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-BEGDA+6(4)
                  <FS_FINAL>-BEGDA+3(2)
                  <FS_FINAL>-BEGDA+0(2)
             INTO LV_DATE.

      IF <FS_FINAL>-BEGDA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                               'P0002-BEGDA'
                               LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.

      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-ENDDA+6(4)
                  <FS_FINAL>-ENDDA+3(2)
                  <FS_FINAL>-ENDDA+0(2)
             INTO LV_DATE .

      IF <FS_FINAL>-ENDDA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                               'P0002-ENDDA'
                               LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.
      CLEAR: LV_DATE.
      CONCATENATE <FS_FINAL>-GBDAT+6(4)
                  <FS_FINAL>-GBDAT+3(2)
                  <FS_FINAL>-GBDAT+0(2)
             INTO LV_DATE .

      IF <FS_FINAL>-GBDAT IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-GBDAT'
                              LV_DATE.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-ANRED IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-ANRED'
                              <FS_FINAL>-ANRED.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-NACHN IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-NACHN'
                              <FS_FINAL>-NACHN.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-VORNA IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-VORNA'
                              <FS_FINAL>-VORNA.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-GESCH IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-GESCH'
                              <FS_FINAL>-GESCH.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-FAMST IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-FAMST'
                              <FS_FINAL>-FAMST.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-SPRSL IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-SPRSL'
                              <FS_FINAL>-SPRSL.
        LV_FLAG = 'X'.
      ENDIF.

      IF <FS_FINAL>-NATIO IS NOT INITIAL.
        PERFORM ADD_DATA USING '0002'
                              'P0002-NATIO'
                              <FS_FINAL>-NATIO.
        LV_FLAG = 'X'.
      ENDIF.

      PERFORM EMPLOYEE_CREATION.

    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ADD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0054   text
*      -->P_0055   text
*      -->P_GWA_DATA_MASSN  text
*----------------------------------------------------------------------*
FORM ADD_DATA  USING  IV_INFTY TYPE INFTY
                       IV_FIELD TYPE PROP_FNAME
                       IV_VALUE.

  DATA: LWA_PROP   TYPE PPROP.

  CLEAR: LWA_PROP.

  LWA_PROP-INFTY = IV_INFTY.
  LWA_PROP-FNAME = IV_FIELD.
  LWA_PROP-FVAL  = IV_VALUE.
  APPEND LWA_PROP TO GT_PROP.
  CLEAR  LWA_PROP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EMPLOYEE_CREATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EMPLOYEE_CREATION .

  DATA:LWA_BAPIRETURN TYPE BAPIRETURN,
       LV_BEGDA       TYPE P0000-BEGDA,
       LV_ENDDA       TYPE P0000-ENDDA,
       LV_PERNR       TYPE P0000-PERNR,
       LWA_RETURN     TYPE BAPIRETURN,
       GV_MODE        TYPE C.

  DATA:LV_WERKS TYPE PSPAR-WERKS,
       LV_PERSG TYPE PSPAR-PERSG,
       LV_PERSK TYPE PSPAR-PERSK,
       LV_PLANS TYPE PSPAR-PLANS.

  CLEAR: LV_BEGDA.
  CONCATENATE <FS_FINAL>-BEGDA+6(4)
              <FS_FINAL>-BEGDA+3(2)
              <FS_FINAL>-BEGDA+0(2)
         INTO LV_BEGDA.


  CONCATENATE <FS_FINAL>-ENDDA+6(4)
              <FS_FINAL>-ENDDA+3(2)
              <FS_FINAL>-ENDDA+0(2)
         INTO LV_ENDDA.

  LV_PERNR = <FS_FINAL>-PERNR.

  IF <FS_FINAL>-MASSN IS INITIAL.

    CALL FUNCTION 'BAPI_EMPLOYEE_CHECKEXISTENCE'
      EXPORTING
        NUMBER = LV_PERNR
      IMPORTING
        RETURN = LWA_RETURN.

  ENDIF.
  GV_MODE = '0'.           " Foreground

*  BREAK-POINT.
  IF LWA_RETURN IS INITIAL.

    LV_WERKS = <FS_FINAL>-WERKS.
    LV_PERSG = <FS_FINAL>-PERSG.
    LV_PERSK = <FS_FINAL>-PERSK.
    LV_PLANS = <FS_FINAL>-PLANS.

    CALL FUNCTION 'HR_MAINTAIN_MASTERDATA'
      EXPORTING
        PERNR              = LV_PERNR
*       massn              = <fs_final>-massn
        BEGDA              = LV_BEGDA
        ENDDA              = LV_ENDDA
        WERKS              = LV_WERKS
        PERSG              = LV_PERSG
        PERSK              = LV_PERSK
        PLANS              = LV_PLANS
        DIALOG_MODE        = GV_MODE          " Foreground
        NO_EXISTENCE_CHECK = 'x'
      IMPORTING
        RETURN             = LWA_BAPIRETURN
      TABLES
        PROPOSED_VALUES    = GT_PROP.

    IF LWA_BAPIRETURN IS NOT INITIAL.
      GWA_DISPLAY-TYPE    = LWA_BAPIRETURN-TYPE.
      GWA_DISPLAY-PERNR   = <FS_FINAL>-PERNR.
      GWA_DISPLAY-MESSAGE = LWA_BAPIRETURN-MESSAGE.
      APPEND GWA_DISPLAY TO GIT_DISPLAY.
      CLEAR GWA_DISPLAY.

    ELSE.
      GWA_DISPLAY-TYPE    = 'S'.  "lwa_bapireturn-type.
      GWA_DISPLAY-PERNR   = <FS_FINAL>-PERNR.
      GWA_DISPLAY-MESSAGE = 'Employee Created'. "lwa_bapireturn-message.
      APPEND GWA_DISPLAY TO GIT_DISPLAY.
      CLEAR GWA_DISPLAY.


    ENDIF.

  ELSE.

    GWA_DISPLAY-TYPE    = 'E'.
    GWA_DISPLAY-PERNR   = <FS_FINAL>-PERNR.
    GWA_DISPLAY-MESSAGE = 'Employee already existed'.
    APPEND GWA_DISPLAY TO GIT_DISPLAY.
    CLEAR GWA_DISPLAY.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA.

  DATA :LWA_LAYOUT TYPE SLIS_LAYOUT_ALV,
        WA_FCAT    TYPE SLIS_FIELDCAT_ALV,
        IT_FCAT    TYPE SLIS_T_FIELDCAT_ALV.

  WA_FCAT-FIELDNAME = 'TYPE'.
  WA_FCAT-SELTEXT_M = 'Type'.
  WA_FCAT-TABNAME = 'GIT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'PERNR'.
  WA_FCAT-SELTEXT_M = 'Emp Number'.
  WA_FCAT-TABNAME = 'GIT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MESSAGE'.
  WA_FCAT-SELTEXT_M = 'Message'.
  WA_FCAT-TABNAME = 'GIT_DISPLAY'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.


  LWA_LAYOUT-ZEBRA = 'X'.
  LWA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS                   =
      IS_LAYOUT     = LWA_LAYOUT
      IT_FIELDCAT   = IT_FCAT
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
      I_DEFAULT     = 'X'
      I_SAVE        = 'X'
*     IS_VARIANT    =
*     IT_EVENTS     =
*     IT_EVENT_EXIT =
*     IS_PRINT      =
*     IS_REPREP_ID  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK  =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB      = GIT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
