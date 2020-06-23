*&---------------------------------------------------------------------*
*& Report ZMMR_SDAF_SST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMMR_SDAF_SST.

TYPES :BEGIN OF TY_FINAL,
         BEDAT      TYPE EKKO-BEDAT,
         EBELN      TYPE EKKO-EBELN,
         WERKS      TYPE EKPO-WERKS,
         MENGE      TYPE EKPO-MENGE,
         LABST      TYPE MARD-LABST,
         STATUS     TYPE ZSTATUS,
         CELLCOLORS TYPE LVC_T_SCOL,
       END OF TY_FINAL,

       BEGIN OF TY_FINAL1,
         QR_CODE    TYPE ZQR_CODE,
         BEDAT      TYPE EKKO-BEDAT,
         EBELN      TYPE EKKO-EBELN,
         MATNR      TYPE EKPO-MATNR,
         MAKTX      TYPE MAKT-MAKTX,
         MATKL      TYPE EKPO-MATKL,
         WGBEZ      TYPE T023T-WGBEZ,
         MENGE      TYPE EKPO-MENGE,
         MENGE_WH   TYPE EKPO-MENGE,
         LABST      TYPE MARD-LABST,
         MENGE_P    TYPE ZINW_T_ITEM-MENGE_P,
         LR_NO      TYPE ZINW_T_HDR-LR_NO,
         ACT_NO_BUD TYPE ZINW_T_HDR-ACT_NO_BUD,
         TRNS       TYPE ZINW_T_HDR-TRNS,
         NAME       TYPE LFA1-NAME1,
         STATUS     TYPE ZINW_T_HDR-STATUS,
         WERKS      TYPE WERKS_D,
       END OF TY_FINAL1,

       BEGIN OF TY_EKKO,
         EBELN TYPE EKKO-EBELN,
         BSART TYPE EKKO-BSART,
         BEDAT TYPE EKKO-BEDAT,
       END OF TY_EKKO,

       BEGIN OF TY_EKPO,
         EBELN TYPE EKPO-EBELN,
         EBELP TYPE EKPO-EBELP,
         LOEKZ TYPE EKPO-LOEKZ,
         MATNR TYPE EKPO-MATNR,
         WERKS TYPE EKPO-WERKS,
         LGORT TYPE MARD-LGORT,
         MATKL TYPE EKPO-MATKL,
         MENGE TYPE EKPO-MENGE,
       END OF TY_EKPO,

       BEGIN OF TY_MARD,
         MATNR TYPE MARD-MATNR,
         WERKS TYPE MARD-WERKS,
         LGORT TYPE MARD-LGORT,
         LABST TYPE MARD-LABST,
         INSME TYPE MARD-INSME,
       END OF TY_MARD,

       BEGIN OF TY_ZINW_T_HDR,
*         MATNR      TYPE ZINW_T_HDR-MATNR,
         QR_CODE    TYPE ZINW_T_HDR-QR_CODE,
         EBELN      TYPE ZINW_T_HDR-EBELN,
         TRNS       TYPE ZINW_T_HDR-TRNS,
         LR_NO      TYPE ZINW_T_HDR-LR_NO,
         ACT_NO_BUD TYPE ZINW_T_HDR-ACT_NO_BUD,
         STATUS     TYPE ZSTATUS,
*         LIFNR      TYPE ZINW_T_HDR-LIFNR,
       END OF TY_ZINW_T_HDR,

       BEGIN OF TY_MAKT,
         MATNR TYPE MAKT-MATNR,
         SPRAS TYPE MAKT-SPRAS,
         MAKTX TYPE MAKT-MAKTX,
       END OF TY_MAKT,

       BEGIN OF TY_T023T,
         SPRAS TYPE T023T-SPRAS,
         MATKL TYPE T023T-MATKL,
         WGBEZ TYPE T023T-WGBEZ,
       END OF TY_T023T,

       BEGIN OF TY_ZINW_T_ITEM,
         QR_CODE TYPE ZINW_T_ITEM-QR_CODE,
         EBELN   TYPE ZINW_T_ITEM-EBELN,
         EBELP   TYPE ZINW_T_ITEM-EBELP,
         MATNR   TYPE ZINW_T_ITEM-MATNR,
         MENGE_P TYPE ZINW_T_ITEM-MENGE_P,
       END OF TY_ZINW_T_ITEM.



DATA: IT_EKKO  TYPE  TABLE OF TY_EKKO,
      WA_EKKO  TYPE TY_EKKO,
      IT_EKPO  TYPE TABLE OF TY_EKPO,
      WA_EKPO  TYPE  TY_EKPO,
      IT_MARD  TYPE TABLE OF TY_MARD,
      WA_MARD  TYPE TY_MARD,
      IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL TYPE TY_FINAL.

DATA: IT_CELLCOLOURS TYPE LVC_T_SCOL,
      WA_CELLCOLOR   TYPE LVC_S_SCOL.
*DATA L_DQTY TYPE MENGE.

DATA: IT_EKKO1  TYPE  TABLE OF TY_EKKO,
      WA_EKKO1  TYPE TY_EKKO,
      IT_EKPO1  TYPE TABLE OF TY_EKPO,
      WA_EKPO1  TYPE  TY_EKPO,
      IT_MARD1  TYPE TABLE OF TY_MARD,
      WA_MARD1  TYPE TY_MARD,
      IT_ZHDR   TYPE TABLE OF TY_ZINW_T_HDR,
      WA_ZHDR   TYPE TY_ZINW_T_HDR,
      WA_MAKT   TYPE TY_MAKT,
      IT_MAKT   TYPE TABLE OF TY_MAKT,
      IT_T023T  TYPE TABLE OF TY_T023T,
      WA_T023T  TYPE TY_T023T,
      IT_ZITEM  TYPE TABLE OF TY_ZINW_T_ITEM,
      WA_ZITEM  TYPE TY_ZINW_T_ITEM,
      IT_FINAL1 TYPE TABLE OF TY_FINAL1,
      IT_FINAL2 TYPE TABLE OF TY_FINAL1,
      WA_FINAL2 TYPE TY_FINAL1,
      WA_FINAL1 TYPE TY_FINAL1.


DATA: IT_EKPO2 TYPE TABLE OF TY_EKPO,
      WA_EKPO2 TYPE TY_EKPO,
      IT_EKKO2 TYPE TABLE OF TY_EKKO,
      WA_EKKO2 TYPE TY_EKKO.

DATA: IT_HDR  TYPE TABLE OF ZSDF_HDR,
      WA_HDR  TYPE ZSDF_HDR,
      IT_ITEM TYPE TABLE OF ZSDF_ITEM,
      WA_ITEM TYPE ZSDF_ITEM.

DATA : IT_FCAT  TYPE SLIS_T_FIELDCAT_ALV,
       WA_FCAT  TYPE SLIS_FIELDCAT_ALV,
       IT_EVENT TYPE SLIS_T_EVENT,
       WA_EVENT TYPE SLIS_ALV_EVENT,
       IT_SORT  TYPE SLIS_T_SORTINFO_ALV,
       WA_SORT  TYPE SLIS_SORTINFO_ALV.


DATA: LD_INDEX  TYPE SY-TABIX.
DATA : LV_FNAME TYPE RS38L_FNAM.
DATA: LV_MATKL TYPE MATKL.


START-OF-SELECTION.

  PERFORM GET_DATA.
  PERFORM POPULATE_FINAL_DATA.
  PERFORM PREPARE_FIELDCAT.
  PERFORM GET_EVENTS.
  PERFORM DISPLAY.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
*BREAK-POINT.
  BREAK BREDDY.
  SELECT EBELN
         BSART
         BEDAT FROM EKKO
               INTO TABLE IT_EKKO WHERE BSART = 'ZUB'.   ""ZDOM

  IF IT_EKKO IS NOT INITIAL .
    SELECT EBELN
           EBELP
           LOEKZ
           MATNR
           WERKS
           LGORT
           MATKL
           MENGE FROM EKPO
                 INTO TABLE IT_EKPO
                 FOR ALL ENTRIES IN IT_EKKO
                 WHERE EBELN = IT_EKKO-EBELN.

*    SELECT  EBELN
*            TRNS
*            LR_NO
*            ACT_NO_BUD
*            STATUS      FROM ZINW_T_HDR INTO TABLE IT_ZHDR FOR ALL ENTRIES IN IT_EKKO WHERE EBELN = IT_EKKO-EBELN.

  ENDIF.
  IF IT_EKPO IS NOT INITIAL.
**** ADDED BY BHABANI******
    SELECT  ZINW_T_ITEM~QR_CODE
      ZINW_T_ITEM~EBELN
      ZINW_T_ITEM~EBELP
      ZINW_T_ITEM~MATNR
      ZINW_T_ITEM~MENGE_P FROM ZINW_T_ITEM INTO TABLE IT_ZITEM FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-MATNR AND WERKS = IT_EKPO-WERKS.

    SELECT MATNR
           WERKS
           LGORT
           LABST
           INSME FROM MARD
                 INTO TABLE IT_MARD
                 FOR ALL ENTRIES IN IT_EKPO
                 WHERE MATNR = IT_EKPO-MATNR AND WERKS = IT_EKPO-WERKS.
  ENDIF.

  IF  IT_ZITEM IS NOT INITIAL.

    SELECT
      QR_CODE
      EBELN
      TRNS
      LR_NO
      ACT_NO_BUD
      STATUS      FROM ZINW_T_HDR INTO TABLE IT_ZHDR FOR ALL ENTRIES IN IT_ZITEM WHERE EBELN = IT_ZITEM-EBELN.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form POPULATE_FINAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM POPULATE_FINAL_DATA .
  BREAK BREDDY.
  SORT IT_EKKO BY EBELN BEDAT.
*  SORT IT_EKPO BY EBELN.
*  BREAK BREDDY.
  LOOP AT  IT_EKKO INTO WA_EKKO WHERE BSART = 'ZUB'.
    WA_FINAL-EBELN  = WA_EKKO-EBELN.
    WA_FINAL-BEDAT = WA_EKKO-BEDAT.

    CLEAR :WA_ZITEM , WA_ZHDR.
    READ TABLE IT_ZITEM INTO WA_ZITEM WITH KEY MATNR = WA_EKPO-MATNR.
    READ TABLE IT_ZHDR INTO WA_ZHDR WITH KEY EBELN = WA_ZITEM-EBELN.
    IF SY-SUBRC = 0.
      WA_FINAL-STATUS = WA_ZHDR-STATUS.
    ENDIF.
    READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = WA_EKKO-EBELN.
    IF  SY-SUBRC = 0.
      LOOP AT IT_EKPO INTO WA_EKPO WHERE EBELN = WA_EKKO-EBELN.
        WA_FINAL-WERKS = WA_EKPO-WERKS.
        WA_FINAL-MENGE = WA_EKPO-MENGE + WA_FINAL-MENGE.

        READ TABLE IT_MARD INTO WA_MARD WITH KEY MATNR = WA_EKPO-MATNR.
        IF SY-SUBRC = 0.
          LOOP AT IT_MARD INTO WA_MARD WHERE MATNR = WA_EKPO-MATNR.
            WA_FINAL-LABST  = WA_MARD-LABST + WA_FINAL-LABST.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
    ENDIF.
    LD_INDEX = SY-TABIX.
    IF WA_FINAL-LABST GE WA_FINAL-MENGE.

      WA_FINAL-LABST = WA_FINAL-MENGE.

    ELSEIF WA_FINAL-LABST LT WA_FINAL-MENGE.

      WA_CELLCOLOR-FNAME = 'LABST'.
      WA_CELLCOLOR-COLOR-COL = 6. "color code 1-7, if outside rage defaults to 7
      WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
      WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
      APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
      MODIFY IT_FINAL FROM WA_FINAL INDEX LD_INDEX TRANSPORTING CELLCOLORS.
      CLEAR WA_CELLCOLOR.
    ENDIF.
    APPEND WA_FINAL TO IT_FINAL.
    CLEAR WA_FINAL.


*  ENDLOOP.
*  ENDIF.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FIELDCAT .
  REFRESH : IT_FCAT.
  WA_FCAT-FIELDNAME = 'BEDAT'.
  WA_FCAT-SELTEXT_M =  TEXT-001. "'Demand Date'
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'EBELN'.
  WA_FCAT-SELTEXT_M = TEXT-002. "'Demand Number'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
*  WA_FCAT-EMPHASIZE = 'c110'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.


  WA_FCAT-FIELDNAME = 'WERKS'.
  WA_FCAT-SELTEXT_M = TEXT-003. "'Store Name'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'MENGE'.
  WA_FCAT-SELTEXT_M = TEXT-004. "'Demanded Qty'.
  WA_FCAT-EMPHASIZE = 'X'.
  WA_FCAT-DO_SUM = 'X'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

  WA_FCAT-FIELDNAME = 'LABST'.
  WA_FCAT-SELTEXT_M = TEXT-005. "'Fulfilled Qty'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  WA_FCAT-DO_SUM = 'X'.
  WA_FCAT-EMPHASIZE = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
*  REFRESH : IT_FCAT.
  DATA: WA_LAYOUT TYPE SLIS_LAYOUT_ALV.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-COLTAB_FIELDNAME  = 'CELLCOLORS'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      I_CALLBACK_PROGRAM      = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = ' '
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE  = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      IS_LAYOUT               = WA_LAYOUT
      IT_FIELDCAT             = IT_FCAT
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
      IT_SORT                 = IT_SORT
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
      IT_EVENTS               = IT_EVENT
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      T_OUTTAB                = IT_FINAL
* EXCEPTIONS
*     PROGRAM_ERROR           = 1
*     OTHERS                  = 2
    .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EVENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EVENTS .

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
*   EXPORTING
*     I_LIST_TYPE           = 0
    IMPORTING
      ET_EVENTS = IT_EVENT.
*    EXCEPTIONS
*      LIST_TYPE_WRONG = 1
*      OTHERS          = 2.
*
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.



  IF IT_EVENT IS NOT INITIAL .
    READ TABLE IT_EVENT INTO WA_EVENT WITH KEY NAME = 'USER_COMMAND'.
    IF SY-SUBRC = 0.
      WA_EVENT-NAME = 'USER_COMMAND'.
      WA_EVENT-FORM = 'USER_COMMAND'.
      MODIFY IT_EVENT FROM WA_EVENT INDEX SY-TABIX.
    ENDIF.
    READ TABLE IT_EVENT INTO WA_EVENT WITH KEY NAME = 'TOP_OF_PAGE'.
    IF SY-SUBRC = 0.
      WA_EVENT-NAME = 'TOP_OF_PAGE'.
      WA_EVENT-FORM = 'TOP_OF_PAGE'.
      MODIFY IT_EVENT FROM WA_EVENT INDEX SY-TABIX.
    ENDIF.
  ENDIF.

ENDFORM.

FORM TOP_OF_PAGE.

  DATA: IT_HEADER TYPE SLIS_T_LISTHEADER,
        WA_HEADER TYPE SLIS_LISTHEADER.


  WA_HEADER-TYP = 'H'.
  WA_HEADER-INFO = TEXT-017."'Store Demand and Fulfilment'.
  APPEND WA_HEADER TO IT_HEADER.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = IT_HEADER
*     I_LOGO             =
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .


ENDFORM.

FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
*BREAK-POINT.
  REFRESH IT_FINAL1.
  CASE R_UCOMM.
    WHEN '&IC1'.
      PERFORM SEC_FCAT USING RS_SELFIELD .

  ENDCASE.
ENDFORM.

FORM USER_COMMAND1 USING R_UCOMM TYPE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN '&IC1'.
      PERFORM SEC_FCAT1 USING RS_SELFIELD .
    WHEN 'PRINT'.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME = 'ZMMS_SDF_SST'
*         VARIANT  = ' '
*         DIRECT_CALL              = ' '
        IMPORTING
          FM_NAME  = LV_FNAME
* EXCEPTIONS
*         NO_FORM  = 1
*         NO_FUNCTION_MODULE       = 2
*         OTHERS   = 3
        .
      CALL FUNCTION LV_FNAME
        EXPORTING
*         ARCHIVE_INDEX              =
*         ARCHIVE_INDEX_TAB          =
*         ARCHIVE_PARAMETERS         =
*         CONTROL_PARAMETERS         =
*         MAIL_APPL_OBJ              =
*         MAIL_RECIPIENT             =
*         MAIL_SENDER                =
*         OUTPUT_OPTIONS             =
*         USER_SETTINGS              = 'X'
          WA_HDR   = WA_FINAL
*         lv_matnr = lv_matnr
          LV_MATKL = LV_MATKL
* IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
*         JOB_OUTPUT_INFO            =
*         JOB_OUTPUT_OPTIONS         =
        TABLES
          IT_ITEM  = IT_FINAL1
* EXCEPTIONS
*         FORMATTING_ERROR           = 1
*         INTERNAL_ERROR             = 2
*         SEND_ERROR                 = 3
*         USER_CANCELED              = 4
*         OTHERS   = 5
        .

  ENDCASE.

ENDFORM.
FORM AI100 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'AI100'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEC_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEC_FCAT USING  RS_SELFIELD TYPE SLIS_SELFIELD.
  REFRESH IT_FINAL1.
  READ TABLE IT_FINAL INTO WA_FINAL INDEX RS_SELFIELD-TABINDEX.
  CASE RS_SELFIELD-FIELDNAME.

    WHEN 'BEDAT' OR 'EBELN' OR
         'WERKS' OR 'MENGE' OR
         'LABST'.


      DATA: IT_FCAT1  TYPE SLIS_T_FIELDCAT_ALV,
            WA_FCAT1  TYPE SLIS_FIELDCAT_ALV,
            IT_EVENT1 TYPE SLIS_T_EVENT,
            WA_EVENT1 TYPE SLIS_ALV_EVENT.
*          BREAK BREDDY.
*** Start of Changes by Suri : 11.5.2019
***   Get STO Items
      BREAK BREDDY.
*      BREAK SAMBURI.
      SELECT EKPO~EBELN,
             EKPO~EBELP,
             EKPO~MATNR,
             EKPO~TXZ01,
             EKPO~CREATIONDATE,
             EKPO~WERKS,
             EKPO~LGORT,
             EKPO~MATKL,
             EKPO~MENGE,
             T023T~WGBEZ
             INTO TABLE @DATA(LT_EKPO_STO)
             FROM EKPO AS EKPO
             LEFT OUTER JOIN T023T AS T023T ON T023T~MATKL = EKPO~MATKL AND SPRAS = @SY-LANGU
             WHERE EKPO~EBELN = @WA_FINAL-EBELN AND LOEKZ <> 'L'.


      IF SY-SUBRC = 0 AND  LT_EKPO_STO IS NOT INITIAL.
        SELECT ZINW_T_ITEM~QR_CODE,
               ZINW_T_ITEM~EBELN,
               ZINW_T_ITEM~EBELP,
               ZINW_T_ITEM~MATNR,
               ZINW_T_ITEM~MAKTX,
               ZINW_T_ITEM~WERKS,
               ZINW_T_ITEM~MATKL,
               ZINW_T_ITEM~MENGE_P,
               ZINW_T_HDR~STATUS,
               ZINW_T_HDR~TRNS,
               ZINW_T_HDR~ACT_NO_BUD

               INTO TABLE @DATA(LT_INWD)
               FROM ZINW_T_ITEM AS ZINW_T_ITEM
               INNER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~QR_CODE = ZINW_T_ITEM~QR_CODE
               INNER JOIN MARD AS MARD ON MARD~MATNR = ZINW_T_ITEM~MATNR AND MARD~WERKS = ZINW_T_ITEM~WERKS
               FOR ALL ENTRIES IN @LT_EKPO_STO
               WHERE ZINW_T_ITEM~MATNR = @LT_EKPO_STO-MATNR AND ZINW_T_HDR~STATUS LT '04' AND ZINW_T_ITEM~WERKS = 'SSWH'.

        SELECT MATNR,
               WERKS,
               LABST,
               INSME FROM MARD
               INTO TABLE @DATA(IT_MARD_S2)
               FOR ALL ENTRIES IN @LT_EKPO_STO
               WHERE MATNR = @LT_EKPO_STO-MATNR AND WERKS = 'SSWH'.                    ""@LT_EKPO_STO-WERKS.
      ENDIF.
      REFRESH IT_FINAL1.
      CLEAR : WA_FINAL1.
      LOOP AT LT_EKPO_STO ASSIGNING FIELD-SYMBOL(<LS_EKPO_STO>).
        WA_FINAL1-EBELN = <LS_EKPO_STO>-EBELN.
        WA_FINAL1-MATNR = <LS_EKPO_STO>-MATNR.
        WA_FINAL1-MATKL = <LS_EKPO_STO>-MATKL.
        WA_FINAL1-WGBEZ = <LS_EKPO_STO>-WGBEZ.
        WA_FINAL1-MENGE = <LS_EKPO_STO>-MENGE.
        WA_FINAL1-BEDAT = <LS_EKPO_STO>-CREATIONDATE.
        READ TABLE IT_MARD_S2 ASSIGNING FIELD-SYMBOL(<WA_MARD_S2>) WITH KEY MATNR = <LS_EKPO_STO>-MATNR WERKS = 'SSWH'.
        IF SY-SUBRC = 0.
          WA_FINAL1-LABST = <WA_MARD_S2>-LABST.
        ENDIF.
*        WA_FINAL1-WERKS = <LS_EKPO_STO>-WERKS.

        LOOP AT LT_INWD ASSIGNING FIELD-SYMBOL(<LS_INWD>) WHERE MATNR = <LS_EKPO_STO>-MATNR.
          WA_FINAL1-WERKS = <LS_INWD>-WERKS.
          WA_FINAL1-QR_CODE = <LS_INWD>-QR_CODE.
          CASE <LS_INWD>-STATUS .
            WHEN '01'.
              ADD <LS_INWD>-ACT_NO_BUD TO WA_FINAL1-ACT_NO_BUD.
              ADD <LS_INWD>-MENGE_P TO WA_FINAL1-MENGE_P.
            WHEN '02'.
              ADD <LS_INWD>-MENGE_P TO WA_FINAL1-MENGE_WH.
          ENDCASE.
          WA_FINAL1-MAKTX = <LS_INWD>-MAKTX.
        ENDLOOP.
        APPEND WA_FINAL1 TO IT_FINAL1.
        CLEAR : WA_FINAL1.
      ENDLOOP.

*** End of Changes by Suri : 11.5.2019


      REFRESH : IT_FCAT1.
      WA_FCAT1-FIELDNAME = 'BEDAT'.
      WA_FCAT1-SELTEXT_M = TEXT-001."'Demand Date'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'EBELN'.
      WA_FCAT1-SELTEXT_M = TEXT-002."'Demand Number'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT.

      WA_FCAT1-FIELDNAME = 'MATNR'.
      WA_FCAT1-SELTEXT_M = TEXT-007."'SST Code'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'MAKTX'.
      WA_FCAT1-SELTEXT_M = TEXT-008."'SST DESCRIPTION'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'MATKL'.
      WA_FCAT1-SELTEXT_M = TEXT-009."'Group Name'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'WGBEZ'.
      WA_FCAT1-SELTEXT_M = TEXT-010."'GROUP TYPE'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'MENGE'.
      WA_FCAT1-SELTEXT_M = TEXT-011."'Qty'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'LABST'.
      WA_FCAT1-SELTEXT_L = TEXT-012."'WH Stock'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT.

      WA_FCAT1-FIELDNAME = 'MENGE_WH'.
      WA_FCAT1-SELTEXT_M = TEXT-013."'Bundle in WH'.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'MENGE_P'.
      WA_FCAT1-SELTEXT_M = TEXT-014.
      WA_FCAT1-TABNAME = 'IT_FINAL1'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
        IMPORTING
          ET_EVENTS = IT_EVENT1.
*BREAK-POINT.
      IF IT_EVENT1 IS NOT INITIAL .
        READ TABLE IT_EVENT1 INTO WA_EVENT1 WITH KEY NAME = 'PF_STATUS_SET'.
        IF SY-SUBRC = 0.
          WA_EVENT1-NAME = 'PF_STATUS_SET'.
          WA_EVENT1-FORM = 'AI100'.
          MODIFY IT_EVENT1 FROM WA_EVENT1 INDEX SY-TABIX.

          READ TABLE IT_EVENT1 INTO WA_EVENT1 WITH KEY NAME = 'USER_COMMAND'.
          WA_EVENT1-NAME = 'USER_COMMAND'.
          WA_EVENT1-FORM = 'USER_COMMAND1'.
          MODIFY IT_EVENT1 FROM WA_EVENT1 INDEX SY-TABIX.

        ENDIF.
      ENDIF.
*
      DATA WA_LAYOUT1 TYPE SLIS_LAYOUT_ALV.
      WA_LAYOUT1-COLWIDTH_OPTIMIZE = 'X'.
      WA_LAYOUT1-ZEBRA = 'X'.
      BREAK SAMBURI.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          I_CALLBACK_PROGRAM      = SY-REPID
*         I_CALLBACK_PF_STATUS_SET          = 'AI100'
          I_CALLBACK_USER_COMMAND = 'USER_COMMAND1'
          IS_LAYOUT               = WA_LAYOUT1
          IT_FIELDCAT             = IT_FCAT1
*         IT_EXCLUDING            =
*         IT_SPECIAL_GROUPS       =
*         IT_SORT                 =
*         IT_FILTER               =
*         IS_SEL_HIDE             =
*         I_DEFAULT               = 'X'
*         I_SAVE                  = ' '
*         IS_VARIANT              =
          IT_EVENTS               = IT_EVENT1
*         IT_EVENT_EXIT           =
*         IS_PRINT                =
*         IS_REPREP_ID            =
*         I_SCREEN_START_COLUMN   = 0
*         I_SCREEN_START_LINE     = 0
*         I_SCREEN_END_COLUMN     = 0
*         I_SCREEN_END_LINE       = 0
*         I_HTML_HEIGHT_TOP       = 0
*         I_HTML_HEIGHT_END       = 0
*         IT_ALV_GRAPHICS         =
*         IT_HYPERLINK            =
*         IT_ADD_FIELDCAT         =
*         IT_EXCEPT_QINFO         =
*         IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*         E_EXIT_CAUSED_BY_CALLER =
*         ES_EXIT_CAUSED_BY_USER  =
        TABLES
          T_OUTTAB                = IT_FINAL1
* EXCEPTIONS
*         PROGRAM_ERROR           = 1
*         OTHERS                  = 2
        .
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEC_FCAT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM SEC_FCAT1 USING  RS_SELFIELD TYPE SLIS_SELFIELD.
  REFRESH IT_FINAL2.
  READ TABLE IT_FINAL1 INTO WA_FINAL1 INDEX RS_SELFIELD-TABINDEX.
  CASE RS_SELFIELD-FIELDNAME.
*  CASE RS_SELFIELD-tabindex.

    WHEN 'MATNR' OR 'MENGE_P' OR
         'EBELN' OR 'MENGE' OR
         'LABST' OR 'ACT_NO_BUD' OR 'MAKTX' OR 'BEDAT' OR 'MATKL'.



      DATA: IT_FCAT1  TYPE SLIS_T_FIELDCAT_ALV,
            WA_FCAT1  TYPE SLIS_FIELDCAT_ALV,
            IT_EVENT1 TYPE SLIS_T_EVENT,
            WA_EVENT1 TYPE SLIS_ALV_EVENT.
      BREAK BREDDY.
      REFRESH : IT_ZITEM, IT_ZHDR.

*      SELECT ekpo~ebeln , ekpo~matnr from ekpo INTO @data(it_ekpo2)

      SELECT ZINW_T_ITEM~QR_CODE,
             ZINW_T_ITEM~EBELN,
             ZINW_T_ITEM~EBELP,
             ZINW_T_ITEM~MATNR,
             ZINW_T_ITEM~MENGE_P,
             ZINW_T_HDR~TRNS,
             ZINW_T_HDR~LR_NO,
             ZINW_T_HDR~ACT_NO_BUD,
             ZINW_T_HDR~STATUS,
             LFA1~NAME1
          INTO TABLE @DATA(LT_TRNS)
          FROM ZINW_T_ITEM AS ZINW_T_ITEM
*          INNER JOIN EKPO AS EKPO ON EKPO~MATNR = ZINW_T_ITEM~MATNR
          INNER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~QR_CODE = ZINW_T_ITEM~QR_CODE
          INNER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = ZINW_T_HDR~TRNS
          WHERE ZINW_T_ITEM~MATNR = @WA_FINAL1-MATNR AND ZINW_T_ITEM~WERKS = @WA_FINAL1-WERKS AND ZINW_T_HDR~STATUS = '01'.

      REFRESH : IT_FINAL2.
      LOOP AT LT_TRNS ASSIGNING FIELD-SYMBOL(<LS_TRNS>).
        APPEND VALUE #( TRNS = <LS_TRNS>-TRNS NAME = <LS_TRNS>-NAME1 LR_NO = <LS_TRNS>-LR_NO QR_CODE = <LS_TRNS>-QR_CODE MENGE_P = <LS_TRNS>-MENGE_P ACT_NO_BUD = <LS_TRNS>-ACT_NO_BUD ) TO IT_FINAL2.
      ENDLOOP.

      REFRESH : IT_FCAT1.
      WA_FCAT1-FIELDNAME = 'TRNS'.
      WA_FCAT1-SELTEXT_M = TEXT-016.
      WA_FCAT1-TABNAME = 'IT_FINAL2'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'Name'.
      WA_FCAT1-SELTEXT_M = TEXT-019."'name.
      WA_FCAT1-TABNAME = 'IT_FINAL2'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'LR_NO'.
      WA_FCAT1-SELTEXT_M = 'LR Number'. "'LR. NO'.
      WA_FCAT1-TABNAME = 'IT_FINAL2'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'QR_CODE'.
      WA_FCAT1-SELTEXT_M = 'QR Code'. "'LR. NO'.
      WA_FCAT1-TABNAME = 'IT_FINAL2'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'MENGE_P'.
      WA_FCAT1-SELTEXT_M = 'STOCK'.
      WA_FCAT1-TABNAME = 'IT_FINAL2'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      WA_FCAT1-FIELDNAME = 'ACT_NO_BUD'.
      WA_FCAT1-SELTEXT_L = TEXT-015."'Bundle In Transport'.
      WA_FCAT1-TABNAME = 'IT_FINAL2'.
      APPEND WA_FCAT1 TO IT_FCAT1.
      CLEAR WA_FCAT1.

      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
        IMPORTING
          ET_EVENTS = IT_EVENT1.

      DATA WA_LAYOUT1 TYPE SLIS_LAYOUT_ALV.
      WA_LAYOUT1-COLWIDTH_OPTIMIZE = 'X'.
      WA_LAYOUT1-ZEBRA = 'X'.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         I_INTERFACE_CHECK  = ' '
*         I_BYPASSING_BUFFER = ' '
*         I_BUFFER_ACTIVE    = ' '
          I_CALLBACK_PROGRAM = SY-REPID
*         I_CALLBACK_PF_STATUS_SET          = 'AI100'
*         I_CALLBACK_USER_COMMAND = 'USER_COMMAND1'
*         I_CALLBACK_TOP_OF_PAGE  = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*         I_CALLBACK_HTML_END_OF_LIST       = ' '
*         I_STRUCTURE_NAME   =
*         I_BACKGROUND_ID    = ' '
*         I_GRID_TITLE       =
*         I_GRID_SETTINGS    =
          IS_LAYOUT          = WA_LAYOUT1
          IT_FIELDCAT        = IT_FCAT1
*         IT_EXCLUDING       =
*         IT_SPECIAL_GROUPS  =
*         IT_SORT            =
*         IT_FILTER          =
*         IS_SEL_HIDE        =
*         I_DEFAULT          = 'X'
*         I_SAVE             = ' '
*         IS_VARIANT         =
*         IT_EVENTS          = IT_EVENT1
*         IT_EVENT_EXIT      =
*         IS_PRINT           =
*         IS_REPREP_ID       =
*         I_SCREEN_START_COLUMN   = 0
*         I_SCREEN_START_LINE     = 0
*         I_SCREEN_END_COLUMN     = 0
*         I_SCREEN_END_LINE  = 0
*         I_HTML_HEIGHT_TOP  = 0
*         I_HTML_HEIGHT_END  = 0
*         IT_ALV_GRAPHICS    =
*         IT_HYPERLINK       =
*         IT_ADD_FIELDCAT    =
*         IT_EXCEPT_QINFO    =
*         IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*         E_EXIT_CAUSED_BY_CALLER =
*         ES_EXIT_CAUSED_BY_USER  =
        TABLES
          T_OUTTAB           = IT_FINAL2
* EXCEPTIONS
*         PROGRAM_ERROR      = 1
*         OTHERS             = 2
        .
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
  ENDCASE.
ENDFORM.
