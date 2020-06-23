*&---------------------------------------------------------------------*
*& Include          SAPMZ_GRPO_VESSELS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLEAR.
  CHECK OK_CODE = C_EXIT OR OK_CODE = C_CANCEL OR OK_CODE = C_BACK.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HEADER_QR_CODE
*&---------------------------------------------------------------------*
FORM GET_DATA USING QR_CODE.
  CHECK QR_CODE IS NOT INITIAL.
  SELECT SINGLE * FROM ZINW_T_HDR INTO GS_HEADER WHERE QR_CODE = QR_CODE AND STATUS LE C_02.
  IF SY-SUBRC = 0.
*** Get PO Doc type
    SELECT SINGLE BSART FROM EKKO INTO GV_BSART WHERE EBELN = GS_HEADER-EBELN AND BSART IN  ( C_ZVOS , C_ZVLO ) .
    IF SY-SUBRC = 0.
      SELECT ZINW_T_ITEM~QR_CODE,
             ZINW_T_ITEM~EBELN,
             ZINW_T_ITEM~EBELP,
             ZINW_T_ITEM~MATNR,
             ZINW_T_ITEM~MAKTX,
             ZINW_T_ITEM~MENGE_P,
             EKPO~BPRME,
             ZINW_T_ITEM~MENGE_S,
             EKPO~LMEIN,
             ZINW_T_ITEM~LGORT,
             ZINW_T_ITEM~WERKS
             INTO TABLE @GT_ITEM
             FROM ZINW_T_ITEM AS ZINW_T_ITEM
             INNER JOIN EKPO AS EKPO ON EKPO~EBELN = ZINW_T_ITEM~EBELN and EKPO~EBELP = ZINW_T_ITEM~EBELP
             WHERE ZINW_T_ITEM~QR_CODE = @QR_CODE.
      IF SY-SUBRC <> 0.
        MESSAGE E003(ZMSG_CLS).
      ENDIF.
    ELSE.
      MESSAGE E074(ZMSG_CLS).
    ENDIF.
  ELSE.
    MESSAGE I072(ZMSG_CLS) DISPLAY LIKE C_E.
    EXIT.
  ENDIF.
ENDFORM.

FORM DISPLAY_DATA.

  CHECK GT_FIELDCAT IS INITIAL .
*** Layout
  GS_LAYO-FRONTEND   = C_X.
  GS_LAYO-ZEBRA      = C_X.
*** Field Catlog
  GT_FIELDCAT = VALUE #(
                         ( FIELDNAME = 'EBELP'    TABNAME = 'GT_ITEM' SCRTEXT_L = 'Item' OUTPUTLEN = '5')
                         ( FIELDNAME = 'MATNR'    TABNAME = 'GT_ITEM' SCRTEXT_L = 'Child SST' OUTPUTLEN = '10')
                         ( FIELDNAME = 'MAKTX'    TABNAME = 'GT_ITEM' SCRTEXT_L = 'Child SST Des' OUTPUTLEN = '20' )
                         ( FIELDNAME = 'MENGE_S'  TABNAME = 'GT_ITEM' SCRTEXT_L = 'Ordered Qty' OUTPUTLEN = '10' )
                         ( FIELDNAME = 'BPRME'    TABNAME = 'GT_ITEM' SCRTEXT_L = 'UOM' OUTPUTLEN = '5' )
                         ( FIELDNAME = 'MENGE_T'  TABNAME = 'GT_ITEM' SCRTEXT_L = 'Received Qty' EDIT = C_X
                           REF_FIELD = 'MENGE_P'  REF_TABLE = 'ZINW_T_ITEM' DECIMALS = '0' DECIMALS_O = '0' )
                         ( FIELDNAME = 'LMEIN'    TABNAME = 'GT_ITEM' SCRTEXT_L = 'UOM' OUTPUTLEN = '5' )
                        ).

*** Creating Object Ref
  IF GR_CONTAINER IS NOT BOUND.
    CREATE OBJECT GR_CONTAINER  EXPORTING CONTAINER_NAME = 'CONTAINER'.
    CREATE OBJECT GR_GRID EXPORTING I_PARENT = GR_CONTAINER.
  ENDIF.

*** Create Object for event_receiver.
  IF GR_EVENT IS NOT BOUND.
    CREATE OBJECT GR_EVENT.
  ENDIF.

  IF GT_EXCLUDE IS INITIAL.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
  ENDIF.

  IF GR_GRID IS BOUND.
*** Displaying Table
    CALL METHOD GR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT                     = GS_LAYO
        IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
      CHANGING
        IT_OUTTAB                     = GT_ITEM
        IT_FIELDCATALOG               = GT_FIELDCAT
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.

    IF SY-SUBRC <> 0.
    ENDIF.

***  Registering the EDIT Event
    CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
    SET HANDLER GR_EVENT->HANDLE_DATA_CHANGED FOR GR_GRID.
  ENDIF.
ENDFORM.

FORM EXCLUDE_TB_FUNCTIONS  CHANGING GT_EXCLUDE TYPE UI_FUNCTIONS.

  GT_EXCLUDE = VALUE #(   ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW    )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW    )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE         )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY          )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW      )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT           )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO          )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW    )
                          ( CL_GUI_ALV_GRID=>MC_FC_PRINT             )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW      )
                          ( CL_GUI_ALV_GRID=>MC_FC_FIND_MORE         )
                          ( CL_GUI_ALV_GRID=>MC_FC_SUM               )
                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
                         ).
ENDFORM.

FORM POST_DATA.
*** BAPI STRUCTURE DECLARATION
  DATA:
    LS_GMVT_HEADER  TYPE BAPI2017_GM_HEAD_01,
    LS_GMVT_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
    LS_GMVT_HEADRET TYPE BAPI2017_GM_HEAD_RET,
    LT_BAPIRET      TYPE STANDARD TABLE OF BAPIRET2,
    LT_GMVT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LS_STATUS       TYPE ZINW_T_STATUS,
    LT_STATUS       TYPE TABLE OF ZINW_T_STATUS.

  FIELD-SYMBOLS :
    <LS_BAPIRET> TYPE BAPIRET2.

  REFRESH : LT_BAPIRET,LT_STATUS.
  CHECK GT_ITEM IS NOT INITIAL AND GS_HEADER-STATUS < C_03.
  READ TABLE GT_ITEM ASSIGNING <GS_ITEM> WITH KEY MENGE_T = SPACE.
  IF SY-SUBRC = 0.
    MESSAGE E073(ZMSG_CLS).
    EXIT.
  ENDIF.
*** Fill the bapi Header structure details
  LS_GMVT_HEADER-PSTNG_DATE = SY-DATUM.
*  LS_GMVT_HEADER-PSTNG_DATE = '20200229'.
  LS_GMVT_HEADER-DOC_DATE   = SY-DATUM.
  LS_GMVT_HEADER-PR_UNAME   = SY-UNAME.
  LS_GMVT_HEADER-REF_DOC_NO = GS_HEADER-QR_CODE.

*** Looping the PO details.
  LOOP AT GT_ITEM ASSIGNING <GS_ITEM>.
*** FILL THE BAPI ITEM STRUCTURE DETAILS
    LS_GMVT_ITEM-MATERIAL  = <GS_ITEM>-MATNR.
    LS_GMVT_ITEM-ITEM_TEXT = <GS_ITEM>-MAKTX.
    LS_GMVT_ITEM-PLANT     = <GS_ITEM>-WERKS.
    LS_GMVT_ITEM-STGE_LOC  = <GS_ITEM>-LGORT.
*** For Doc type ZLOP - 103
    IF GV_BSART = C_ZVLO.
      LS_GMVT_ITEM-MOVE_TYPE = C_107.
    ELSEIF GV_BSART = C_ZVOS .
      LS_GMVT_ITEM-MOVE_TYPE = C_101.
    ENDIF.
    LS_GMVT_ITEM-PO_NUMBER      = <GS_ITEM>-EBELN.
    LS_GMVT_ITEM-PO_ITEM        = <GS_ITEM>-EBELP.
    LS_GMVT_ITEM-ENTRY_QNT      = <GS_ITEM>-MENGE_T.
    LS_GMVT_ITEM-ENTRY_UOM      = <GS_ITEM>-LMEIN.
    LS_GMVT_ITEM-PO_PR_QNT      = <GS_ITEM>-MENGE_S.
    LS_GMVT_ITEM-ORDERPR_UN     = <GS_ITEM>-BPRME.
    LS_GMVT_ITEM-ORDERPR_UN_ISO = <GS_ITEM>-BPRME.
    LS_GMVT_ITEM-PROD_DATE      = SY-DATUM.
    LS_GMVT_ITEM-MVT_IND        = C_MVT_IND_B.
    APPEND LS_GMVT_ITEM TO LT_GMVT_ITEM.
    CLEAR LS_GMVT_ITEM.
  ENDLOOP.
*  BREAK-POINT.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_GMVT_HEADER
      GOODSMVT_CODE    = C_MVT_01
    IMPORTING
      GOODSMVT_HEADRET = LS_GMVT_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_GMVT_ITEM
      RETURN           = LT_BAPIRET.

  READ TABLE LT_BAPIRET ASSIGNING <LS_BAPIRET> WITH KEY TYPE = C_E.
  IF SY-SUBRC <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = C_X.

*** Updating Material Doc in Indw Header
*** For Doc type ZVLS - 103
*** Status Update
    LS_STATUS-INWD_DOC     = GS_HEADER-INWD_DOC.
    LS_STATUS-QR_CODE      = GS_HEADER-QR_CODE.
    LS_STATUS-STATUS_FIELD = C_QR_CODE.
    LS_STATUS-CREATED_BY   = SY-UNAME.
    LS_STATUS-CREATED_DATE = SY-DATUM.
    LS_STATUS-CREATED_TIME = SY-UZEIT.

    IF GV_BSART = C_ZVLO.
      GS_HEADER-MBLNR_103 = LS_GMVT_HEADRET-MAT_DOC.
      GS_HEADER-STATUS = C_03.              " Local GRPO DONE
      LS_STATUS-STATUS_VALUE = C_QR03.
      LS_STATUS-DESCRIPTION  = 'Local GR Posted'.
      APPEND LS_STATUS TO LT_STATUS.
    ELSE.
      GS_HEADER-MBLNR  = LS_GMVT_HEADRET-MAT_DOC.
      GS_HEADER-STATUS = C_04.              " GRPO DONE
      LS_STATUS-STATUS_VALUE = C_QR04.
      LS_STATUS-DESCRIPTION  = 'GR Posted'.
      APPEND LS_STATUS TO LT_STATUS.
    ENDIF.
    MODIFY ZINW_T_HDR FROM GS_HEADER.
    MODIFY ZINW_T_STATUS FROM TABLE LT_STATUS.
    COMMIT WORK.

    IF GS_HEADER-SERVICE_PO IS NOT INITIAL.
***  For Service Entry Sheet
      PERFORM SERVICE_ENTRYSHEET.
    ELSE.
      PERFORM MSG_INIT.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          ARBGB                  = 'ZMSG_CLS'
          MSGTY                  = 'S'
          MSGV1                  = LS_GMVT_HEADRET-MAT_DOC
          MSGV2                  = LS_STATUS-DESCRIPTION
          TXTNR                  = 076
        EXCEPTIONS
          MESSAGE_TYPE_NOT_VALID = 1
          NOT_ACTIVE             = 2
          OTHERS                 = 3.
      PERFORM MSG_STOP.
      PERFORM MSG_SHOW.
    ENDIF.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    PERFORM MSG_INIT.
    PERFORM MSG_STORE TABLES LT_BAPIRET .
    PERFORM MSG_STOP.
    PERFORM MSG_SHOW.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MSG_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MSG_INIT.
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      LOG_NOT_ACTIVE       = 1
      WRONG_IDENTIFICATION = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MSG_STORE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MSG_STORE TABLES LT_BAPIRET TYPE BAPIRET2_T.
  FIELD-SYMBOLS : <LS_BAPIRET> TYPE BAPIRET2.
  LOOP AT LT_BAPIRET ASSIGNING <LS_BAPIRET> WHERE TYPE = C_E.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB                  = <LS_BAPIRET>-ID
        MSGTY                  = <LS_BAPIRET>-TYPE
        MSGV1                  = <LS_BAPIRET>-MESSAGE_V1
        MSGV2                  = <LS_BAPIRET>-MESSAGE_V2
        MSGV3                  = <LS_BAPIRET>-MESSAGE_V3
        MSGV4                  = <LS_BAPIRET>-MESSAGE_V4
        TXTNR                  = <LS_BAPIRET>-NUMBER
      EXCEPTIONS
        MESSAGE_TYPE_NOT_VALID = 1
        NOT_ACTIVE             = 2
        OTHERS                 = 3.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MSG_STOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MSG_STOP .
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      A_MESSAGE         = 1
      E_MESSAGE         = 2
      W_MESSAGE         = 3
      I_MESSAGE         = 4
      S_MESSAGE         = 5
      DEACTIVATED_BY_MD = 6
      OTHERS            = 7.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM MSG_SHOW.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      INCONSISTENT_RANGE = 1
      NO_MESSAGES        = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SERVICE_ENTRYSHEET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SERVICE_ENTRYSHEET .

  DATA:
    BAPI_ESLL        LIKE BAPIESLLC OCCURS 1 WITH HEADER LINE,
    PO_ITEMS         TYPE BAPIEKPO OCCURS 0 WITH HEADER LINE,
    PO_SERVICES      TYPE BAPIESLL OCCURS 0 WITH HEADER LINE,
    BAPI_RETURN_PO   TYPE TABLE OF BAPIRET2,
    LS_HEADER        TYPE BAPIESSRC,
    LT_BAPIRET       TYPE TABLE OF BAPIRET2,
    SERIAL_NO        LIKE BAPIESKNC-SERIAL_NO,
    LINE_NO          LIKE BAPIESLLC-LINE_NO,
    LS_ENTRYSHEET_NO TYPE BAPIESSR-SHEET_NO,
    LS_PO_HEADER     TYPE BAPIEKKOL.

  FIELD-SYMBOLS :
    <LS_BAPIRET> TYPE BAPIRET2.

  CHECK GS_HEADER-SERVICE_PO IS NOT INITIAL.
  CALL FUNCTION 'BAPI_PO_GETDETAIL'
    EXPORTING
      PURCHASEORDER    = GS_HEADER-SERVICE_PO
      ITEMS            = C_X
      SERVICES         = C_X
    IMPORTING
      PO_HEADER        = LS_PO_HEADER
    TABLES
      PO_ITEMS         = PO_ITEMS
      PO_ITEM_SERVICES = PO_SERVICES
      RETURN           = BAPI_RETURN_PO.

  LS_HEADER-PO_NUMBER   = PO_ITEMS-PO_NUMBER.
  LS_HEADER-PO_ITEM     = PO_ITEMS-PO_ITEM.
  LS_HEADER-SHORT_TEXT  = 'Service Entry Sheet'.
  LS_HEADER-ACCEPTANCE  = C_X.
  LS_HEADER-POST_DATE   = SY-DATUM.
*  LS_HEADER-POST_DATE   = '20200301'.
  LS_HEADER-DOC_DATE    = SY-DATUM.
  LS_HEADER-PCKG_NO     = 1.
  SERIAL_NO             = 0.
  LINE_NO               = 1.

  BAPI_ESLL-PCKG_NO     = 1.
  BAPI_ESLL-LINE_NO     = LINE_NO.
  BAPI_ESLL-OUTL_LEVEL  = '0'.
  BAPI_ESLL-OUTL_IND    = C_X.
  BAPI_ESLL-SUBPCKG_NO  = 2.
  APPEND BAPI_ESLL.

  LOOP AT PO_SERVICES WHERE NOT SHORT_TEXT IS INITIAL.
    CLEAR BAPI_ESLL.
    BAPI_ESLL-PCKG_NO    = 2.
    BAPI_ESLL-LINE_NO    = LINE_NO * 10.
    BAPI_ESLL-SERVICE    = PO_SERVICES-SERVICE.
    BAPI_ESLL-SHORT_TEXT = PO_SERVICES-SHORT_TEXT.
    BAPI_ESLL-QUANTITY   = PO_SERVICES-QUANTITY.
    BAPI_ESLL-GR_PRICE   = PO_SERVICES-GR_PRICE.
    BAPI_ESLL-PRICE_UNIT = PO_SERVICES-PRICE_UNIT.
    APPEND BAPI_ESLL.
    LINE_NO = LINE_NO + 1.
  ENDLOOP.

  CALL FUNCTION 'BAPI_ENTRYSHEET_CREATE'
    EXPORTING
      ENTRYSHEETHEADER   = LS_HEADER
    IMPORTING
      ENTRYSHEET         = LS_ENTRYSHEET_NO
    TABLES
      ENTRYSHEETSERVICES = BAPI_ESLL
      RETURN             = LT_BAPIRET.

  READ TABLE LT_BAPIRET ASSIGNING <LS_BAPIRET> WITH KEY TYPE = C_E.
  IF SY-SUBRC <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = C_X.

    PERFORM MSG_INIT.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB                  = 'ZMSG_CLS'
        MSGTY                  = 'S'
        MSGV1                  = GS_HEADER-MBLNR
        MSGV2                  = 'Created Succesfully'
        TXTNR                  = 076
      EXCEPTIONS
        MESSAGE_TYPE_NOT_VALID = 1
        NOT_ACTIVE             = 2
        OTHERS                 = 3.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB                  = 'ZMSG_CLS'
        MSGTY                  = 'S'
        MSGV1                  = LS_ENTRYSHEET_NO
        MSGV2                  = 'Created Succesfully'
        TXTNR                  = 075
      EXCEPTIONS
        MESSAGE_TYPE_NOT_VALID = 1
        NOT_ACTIVE             = 2
        OTHERS                 = 3.

    PERFORM MSG_STOP.
    PERFORM MSG_SHOW.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    PERFORM MSG_INIT.
    PERFORM MSG_STORE TABLES LT_BAPIRET.
    PERFORM MSG_STOP.
    PERFORM MSG_SHOW.
  ENDIF.
ENDFORM.
