*&---------------------------------------------------------------------*
*& Include          ZSALFORMP_SUB
*&---------------------------------------------------------------------*

FORM GET_TABLEDATA.

  SELECT
        PERNR
        ENAME
        FROM PA0001 INTO TABLE IT_PA0001
        WHERE PERNR = PERNR-PERNR.

  IF IT_PA0001 IS NOT INITIAL.
    SELECT
        PERNR
        FAMSA
        FAVOR
        FANAM
      FROM PA0021 INTO TABLE IT_PA0021
      FOR ALL ENTRIES IN IT_PA0001
      WHERE PERNR = IT_PA0001-PERNR.
  ENDIF.

  SELECT SPRSL
         INFTY
         SUBTY
         STEXT
         FROM T591S INTO TABLE IT_T591S
         FOR ALL ENTRIES IN IT_PA0021
         WHERE SPRSL = SY-LANGU
         AND INFTY = '0021'
         AND SUBTY  = IT_PA0021-FAMSA.
ENDFORM.


FORM GET_FINAL.

  LOOP AT IT_PA0001 INTO WA_PA0001.
    SL = SL + 1.
    WA_FINAL-SL    = SL.
    WA_FINAL-PERNR = WA_PA0001-PERNR.
    WA_FINAL-ENAME = WA_PA0001-ENAME.

    READ TABLE IT_PA0021 INTO WA_PA0021 WITH KEY PERNR = WA_PA0001-PERNR.
      IF SY-SUBRC = 0.
        WA_FINAL-FAMSA = WA_PA0021-FAMSA.
        CONCATENATE WA_PA0021-FAVOR WA_PA0021-FANAM INTO WA_FINAL-NOMINEE SEPARATED BY ' '.
      ENDIF.

*      READ TABLE IT_T591S INTO WA_T591S
*   WITH KEY SUBTY  = WA_PA0021-FAMSA.
*      IF SY-SUBRC = 0.
*        WA_FINAL-NAME = WA_T591S-STEXT.
*        CONCATENATE WA_FINAL-NAME WA_FINAL-NOMINEE INTO WA_FINAL-RELATION SEPARATED BY '/'.
*      ENDIF.

    APPEND WA_FINAL TO IT_FINAL.
      CLEAR WA_FINAL.
  ENDLOOP.


  LOOP AT IT_FINAL INTO WA_FINAL.
    WA_ITEM-SL = WA_FINAL-SL.
    WA_ITEM-ENAME = WA_FINAL-ENAME.
    WA_ITEM-NOMINEE = WA_FINAL-NOMINEE.
    APPEND WA_ITEM TO IT_ITEM.
  ENDLOOP.
  REFRESH IT_FINAL.

*  DATA F_NAME TYPE RS38L_FNAM.
*  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*    EXPORTING
*      FORMNAME           = 'ZSAL_FORMP'
**     VARIANT            = ' '
**     DIRECT_CALL        = ' '
*    IMPORTING
*      FM_NAME            = F_NAME
*    EXCEPTIONS
*      NO_FORM            = 1
*      NO_FUNCTION_MODULE = 2
*      OTHERS             = 3.
*
*
*  CALL FUNCTION F_NAME
**    EXPORTING
*    TABLES
*      IT_ITEM          = IT_ITEM
*    EXCEPTIONS
*      FORMATTING_ERROR = 1
*      INTERNAL_ERROR   = 2
*      SEND_ERROR       = 3
*      USER_CANCELED    = 4
*      OTHERS           = 5.
*
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.

ENDFORM.

*FORM FIELD_CATALOG.
*  REFRESH IT_FCAT.
*  DATA LV_COL TYPE I VALUE 0.
*  IF IT_FINAL IS NOT INITIAL.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'sl'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'SERIAL NUMBER'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'ENAME'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'EMPLOYEE NAME'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'NOMINEE'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'FATHERS NAME'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*  ENDIF.
*ENDFORM.
*
*FORM ALV_LAYOUT.
*
*  WA_LAYOUT-ZEBRA             = 'X'. "Zebra looks
*  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'. "Column width optimized
*
*  IF IT_FINAL IS NOT INITIAL.
*
*    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*      EXPORTING
**       I_INTERFACE_CHECK                 = ' '
**       I_BYPASSING_BUFFER                = ' '
**       I_BUFFER_ACTIVE                   = ' '
*       I_CALLBACK_PROGRAM                = SY-REPID
**       I_CALLBACK_PF_STATUS_SET          = ' '
**       I_CALLBACK_USER_COMMAND           = ' '
**       I_CALLBACK_TOP_OF_PAGE            = ' '
**       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
**       I_CALLBACK_HTML_END_OF_LIST       = ' '
**       I_STRUCTURE_NAME                  =
**       I_BACKGROUND_ID                   = ' '
**       I_GRID_TITLE  =
**       I_GRID_SETTINGS                   =
*        IS_LAYOUT     = WA_LAYOUT
*        IT_FIELDCAT   = IT_FCAT
**       IT_EXCLUDING  =
**       IT_SPECIAL_GROUPS                 =
**       IT_SORT       =
**       IT_FILTER     =
**       IS_SEL_HIDE   =
**       I_DEFAULT     = 'X'
**       I_SAVE        = ' '
**       IS_VARIANT    =
**       IT_EVENTS     =
**       IT_EVENT_EXIT =
**       IS_PRINT      =
**       IS_REPREP_ID  =
**       I_SCREEN_START_COLUMN             = 0
**       I_SCREEN_START_LINE               = 0
**       I_SCREEN_END_COLUMN               = 0
**       I_SCREEN_END_LINE                 = 0
**       I_HTML_HEIGHT_TOP                 = 0
**       I_HTML_HEIGHT_END                 = 0
**       IT_ALV_GRAPHICS                   =
**       IT_HYPERLINK  =
**       IT_ADD_FIELDCAT                   =
**       IT_EXCEPT_QINFO                   =
**       IR_SALV_FULLSCREEN_ADAPTER        =
** IMPORTING
**       E_EXIT_CAUSED_BY_CALLER           =
**       ES_EXIT_CAUSED_BY_USER            =
*      TABLES
*        T_OUTTAB      = IT_FINAL
*      EXCEPTIONS
*        PROGRAM_ERROR = 1
*        OTHERS        = 2.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*  ENDIF.
*ENDFORM.
