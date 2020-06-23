*&---------------------------------------------------------------------*
*& Report ZHR_EMP_MASTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHR_EMP_MASTER.

INCLUDE ZHR_EMP_MASTER_TOP.
START-OF-SELECTION.

  GET PERNR.
  INCLUDE ZHR_EMP_MASTER_FORM.
  INCLUDE ZHR_EMP_MASTER_SUB.

END-OF-SELECTION.

  WA_LAYOUT-ZEBRA             = 'X'. "Zebra looks
*  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'. "Column width optimized
  WA_LAYOUT-EXPAND_ALL = 'X'.
  wa_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS                   =
      IS_LAYOUT     = WA_LAYOUT
      IT_FIELDCAT   = IT_FCAT
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
      I_DEFAULT     = 'X'
      I_SAVE        = ' '
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
      T_OUTTAB      = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
*  ENDIF.
