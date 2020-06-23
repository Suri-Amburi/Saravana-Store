*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_REPORT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CATEGORY_WISE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM CATEGORY_WISE .
*
*  SELECT SINGLE  CLINT
*            KLART
*            CLASS
*            VONDT
*            BISDT
*            WWSKZ FROM KLAH INTO WA_KLAH
*            WHERE WWSKZ = '0'
*            AND KLART = '026'
*            AND CLASS = CATEGORY .
**  ENDIF.
*  IF WA_KLAH IS NOT INITIAL.
*    SELECT OBJEK
*           MAFID
*           KLART
*           CLINT
*           ADZHL
*           DATUB FROM KSSK INTO TABLE IT_KSSK
*            WHERE CLINT = WA_KLAH-CLINT.
*  ENDIF.
*
*  LOOP AT IT_KSSK INTO WA_KSSK .
*    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
*    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
*    APPEND WA_KSSK1 TO IT_KSSK1 .
*    CLEAR WA_KSSK1 .
*  ENDLOOP.
*
*  IF IT_KSSK1 IS NOT INITIAL .
*    SELECT CLINT
*           KLART
*           CLASS
*           VONDT
*           BISDT
*           WWSKZ FROM KLAH INTO TABLE IT_KLAH
*           FOR ALL ENTRIES IN IT_KSSK1
*           WHERE CLINT = IT_KSSK1-OBJEK
*            AND WWSKZ = '1'.
*  ENDIF.
*  IT_KLAH1[] = IT_KLAH[] .
*  IF IT_KLAH IS NOT INITIAL .
*    SELECT MATNR
*           MATKL FROM MARA INTO TABLE IT_MARA
*           FOR ALL ENTRIES IN IT_KLAH1
*           WHERE MATKL = IT_KLAH1-CLASS .
*
*  ENDIF.
*
*  IF  IT_MARA IS NOT INITIAL .
*    SELECT MBLNR
*           MJAHR
*           ZEILE
*           BWART
*           MATNR
*           WERKS
*           LIFNR FROM MSEG INTO TABLE IT_MSEG
*           FOR ALL ENTRIES IN IT_MARA
*           WHERE  MATNR = IT_MARA-MATNR AND BWART = '101'
*           . ""101 OR 103 FOR UNRESTRICTED
*  ENDIF.
*
*  IF IT_MSEG IS NOT INITIAL .
*    SELECT MATNR
*           BWKEY
*           BWTAR
*           VERPR
*           STPRS  FROM MBEW INTO TABLE IT_MBEW
*            FOR ALL ENTRIES IN IT_MSEG
*            WHERE MATNR = IT_MSEG-MATNR AND BWKEY = IT_MSEG-WERKS .    " VALUATION TABLE
*
*    SELECT  MATNR
*            WERKS
*            LGORT
*            LFGJA
*            LABST FROM MARD INTO TABLE IT_MARD
*            FOR ALL ENTRIES IN IT_MSEG
*             WHERE MATNR = IT_MSEG-MATNR AND WERKS  = IT_MSEG-WERKS.    "WITHOUT BATCH STOCK
*  ENDIF.
*
*
*  IT_MSEG1[] = IT_MSEG[] .
*  DELETE ADJACENT DUPLICATES FROM IT_MSEG1 COMPARING WERKS . ""single plant
**  IT_MSEG2[] = IT_MSEG[] .
**  DELETE ADJACENT DUPLICATES FROM IT_MSEG2 COMPARING LIFNR . ""single vendor
*
*  IF IT_MSEG2 IS NOT INITIAL .
*    SELECT LIFNR
*           LAND1
*           NAME1 FROM LFA1 INTO TABLE IT_LFA1
*          FOR ALL ENTRIES IN IT_MSEG2
*          WHERE LIFNR = IT_MSEG2-LIFNR .
*  ENDIF.
*
*
*
**  LOOP AT it_klah INTO wa_klah .
**    LOOP AT it_kssk INTO wa_kssk where objek = wa_klah-clint .
**
**    ENDLOOP.
**  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form DISPLAY_C
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM DISPLAY_C .
*
*
*

*ENDFORM.
*&---------------------------------------------------------------------*
*& Form VENDOR_WISE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VENDOR_WISE .

  IF CATEGORY IS NOT INITIAL .
    SELECT SINGLE  CLINT
            KLART
            CLASS
            VONDT
            BISDT
            WWSKZ FROM KLAH INTO WA_KLAH
            WHERE CLASS = CATEGORY
             AND  WWSKZ = '0'
             AND KLART = '026'.
  ENDIF.
  IF WA_KLAH IS NOT INITIAL.
    SELECT OBJEK
           MAFID
           KLART
           CLINT
           ADZHL
           DATUB FROM KSSK INTO TABLE IT_KSSK
            WHERE CLINT = WA_KLAH-CLINT.
  ENDIF.

  LOOP AT IT_KSSK INTO WA_KSSK .
    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
    APPEND WA_KSSK1 TO IT_KSSK1 .
    CLEAR WA_KSSK1 .
  ENDLOOP.

  IF IT_KSSK1 IS NOT INITIAL .
    SELECT CLINT
           KLART
           CLASS
           VONDT
           BISDT
           WWSKZ FROM KLAH INTO TABLE IT_KLAH
           FOR ALL ENTRIES IN IT_KSSK1
           WHERE CLINT = IT_KSSK1-OBJEK
           AND WWSKZ = '1'.
  ENDIF.

  IT_KLAH1[] = IT_KLAH[] .
  IF IT_KLAH IS NOT INITIAL .
    SELECT MATNR
           MATKL FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_KLAH1
           WHERE MATKL = IT_KLAH1-CLASS .

  ENDIF.
  BREAK BREDDY.
  IF  IT_MARA IS NOT INITIAL .
    SELECT MBLNR
           MJAHR
           ZEILE
           BWART
           MATNR
           WERKS
           LIFNR FROM MSEG INTO TABLE IT_MSEG
           FOR ALL ENTRIES IN IT_MARA
           WHERE MATNR = IT_MARA-MATNR AND BWART IN ( '101'  , '107' ,  '202'  , '642'  ).
  ENDIF.

  IF IT_MARA IS NOT INITIAL.
    SELECT MBLNR
           MJAHR
           ZEILE
           BWART
           MATNR
           WERKS
           LIFNR FROM MSEG INTO TABLE IT_MSEG_M
           FOR ALL ENTRIES IN IT_MARA
           WHERE MATNR = IT_MARA-MATNR AND BWART IN ( '102'  , '108' ,  '201'  , '251' , '641'  ).


  ENDIF.

  IF IT_MSEG IS NOT INITIAL .
    SELECT MATNR
           BWKEY
           BWTAR
           VERPR
           STPRS  FROM MBEW INTO TABLE IT_MBEW
            FOR ALL ENTRIES IN IT_MSEG
            WHERE MATNR = IT_MSEG-MATNR AND BWKEY = IT_MSEG-WERKS .

    SELECT  MATNR
            WERKS
            LGORT
            LFGJA
            LABST FROM MARD INTO TABLE IT_MARD
            FOR ALL ENTRIES IN IT_MSEG
             WHERE MATNR = IT_MSEG-MATNR AND WERKS  = IT_MSEG-WERKS.
  ENDIF.


  IT_MSEG1[] = IT_MSEG[] .
  SORT IT_MSEG1 DESCENDING BY LIFNR WERKS MATNR .
  DELETE ADJACENT DUPLICATES FROM IT_MSEG1 COMPARING LIFNR WERKS MATNR. ""single plant
  IT_MSEG2[] = IT_MSEG[] .
  SORT IT_MSEG2 DESCENDING BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM IT_MSEG2 COMPARING LIFNR. ""single vendor

  IF IT_MSEG2 IS NOT INITIAL .
    SELECT LIFNR
           LAND1
           NAME1 FROM LFA1 INTO TABLE IT_LFA1
          FOR ALL ENTRIES IN IT_MSEG2
          WHERE LIFNR = IT_MSEG2-LIFNR .
  ENDIF.


*  LOOP AT IT_MSEG2 INTO WA_MSEG2 .
*    WA_FINAL-LIFNR = WA_MSEG2-LIFNR .
*    LOOP AT IT_MSEG1 INTO WA_MSEG1 WHERE LIFNR = WA_MSEG2-LIFNR  .
*      LOOP AT IT_MARD INTO WA_MARD WHERE WERKS = WA_MSEG1-WERKS AND LIFNR = WA_MSEG2-LIFNR  .
*        WA_FINAL-LABST = WA_MARD-LABST +  WA_FINAL-LABST .
*        WA_FINAL-WERKS = WA_MARD-WERKS .
*        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY MATNR = WA_MARD-MATNR BWKEY = WA_MARD-WERKS.
*        IF SY-SUBRC = 0.
*          WA_FINAL-VALUE = ( WA_MBEW-VERPR * WA_MARD-LABST ) + WA_FINAL-VALUE .
*        ENDIF.
*      ENDLOOP.
*      APPEND WA_FINAL TO IT_FINAL.
*      CLEAR WA_FINAL .
*    ENDLOOP.
*  ENDLOOP.



  LOOP AT IT_MSEG2 INTO WA_MSEG2 .
    WA_FINAL-LIFNR = WA_MSEG2-LIFNR .
    LOOP AT IT_MSEG1 INTO WA_MSEG1 WHERE LIFNR = WA_MSEG2-LIFNR AND WERKS = WA_MSEG2-WERKS  .
      LOOP AT IT_MARD INTO WA_MARD WHERE WERKS = WA_MSEG2-WERKS  AND MATNR = WA_MSEG1-MATNR .
        WA_FINAL-LABST = WA_MARD-LABST +  WA_FINAL-LABST .
        WA_FINAL-WERKS = WA_MARD-WERKS .
        READ TABLE IT_MBEW INTO WA_MBEW WITH KEY MATNR = WA_MARD-MATNR BWKEY = WA_MARD-WERKS.
        IF SY-SUBRC = 0.
          WA_FINAL-VALUE = ( WA_MBEW-VERPR * WA_MARD-LABST ) + WA_FINAL-VALUE .
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    APPEND WA_FINAL TO IT_FINAL.
    CLEAR WA_FINAL .
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_V
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_V .

  DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
         WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
  TYPE-POOLS : SLIS.
  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .
  WA_LAYOUT-ZEBRA = 'X' .
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .
  WA_FIELDCAT-FIELDNAME = 'LIFNR'.
  WA_FIELDCAT-SELTEXT_M = 'VENDOR NAME '.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'WERKS'.
  WA_FIELDCAT-SELTEXT_M =  'PLANT'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'LABST'.
  WA_FIELDCAT-SELTEXT_M = 'QTY'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'VALUE'.
  WA_FIELDCAT-SELTEXT_M = 'VALUE'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK      = ' '
*     I_BYPASSING_BUFFER     = ' '
*     I_BUFFER_ACTIVE        = ' '
*     i_callback_program     = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     i_callback_top_of_page = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME       =
*     I_BACKGROUND_ID        = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS        =
      IS_LAYOUT     = WA_LAYOUT
      IT_FIELDCAT   = IT_FIELDCAT
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS      =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
*     I_DEFAULT     = 'X'
*     I_SAVE        = ' '
*     IS_VARIANT    =
*     IT_EVENTS     =
*     IT_EVENT_EXIT =
*     IS_PRINT      =
*     IS_REPREP_ID  =
*     I_SCREEN_START_COLUMN  = 0
*     I_SCREEN_START_LINE    = 0
*     I_SCREEN_END_COLUMN    = 0
*     I_SCREEN_END_LINE      = 0
*     I_HTML_HEIGHT_TOP      = 0
*     I_HTML_HEIGHT_END      = 0
*     IT_ALV_GRAPHICS        =
*     IT_HYPERLINK  =
*     IT_ADD_FIELDCAT        =
*     IT_EXCEPT_QINFO        =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER =
    TABLES
      T_OUTTAB      = IT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
