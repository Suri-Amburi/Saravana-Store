*&---------------------------------------------------------------------*
*& Include          SAPMZ_TATKAL_PO_F01
*&---------------------------------------------------------------------*

FORM SAVE_DATA.
  SELECT SINGLE * FROM ZINW_T_HDR INTO GS_INW_HDR WHERE QR_CODE = GS_HDR-QR_CODE.
  IF GV_PO_CREATE IS INITIAL.
    PERFORM CREATE_PO CHANGING GV_SUBRC.

********************************Started by bhavani 05/24/2019**************
*    IF GV_SUBRC IS INITIAL.
*      CALL FUNCTION 'ZFM_PURCHASE_FORM'
*        EXPORTING
*          LV_EBELN  = GV_EBELN
*          TATKAL_PO = 'X'.
*    ENDIF.
********************************End by bhavani*********************************
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCAN_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1          text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SCAN_BATCH.
  DATA :  LS_ITEM TYPE TY_ITEM.
  CHECK GS_HDR-CHARG IS NOT INITIAL.
  READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY CHARG = GS_HDR-CHARG.
  IF SY-SUBRC = 0.
    READ TABLE GT_ITEM_T ASSIGNING FIELD-SYMBOL(<LS_ITEM_T>) WITH KEY CHARG = GS_HDR-CHARG.
    IF SY-SUBRC = 0.
*** Updating Quantity for existing Batch
      IF <LS_ITEM>-MENGE LE <LS_ITEM>-MENGE_S.
*        MESSAGE 'Batch quantity exceeded' TYPE 'S' DISPLAY LIKE 'E'.
        MESSAGE S029(ZMSG_CLS) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      <LS_ITEM>-MENGE_S  = <LS_ITEM>-MENGE_S + 1.
      <LS_ITEM>-NETWR    = <LS_ITEM>-NETPR * <LS_ITEM>-MENGE_S.
      <LS_ITEM>-BPREI_GP = <LS_ITEM_T>-BPREI_GP * <LS_ITEM>-MENGE_S.
      <LS_ITEM>-BPREI_T  = <LS_ITEM>-BPREI_GP + <LS_ITEM>-NETWR.
    ENDIF.
  ELSE.
    SELECT
      MSEG~MBLNR,
      MSEG~MJAHR,
      MSEG~ZEILE,
      MSEG~CHARG,
      MSEG~WERKS,
      MSEG~LGORT,
      EKPO~MWSKZ,
      ZINW_T_ITEM~EBELN,
      ZINW_T_ITEM~EBELP,
      ZINW_T_ITEM~NETPR_GP,
      ZINW_T_ITEM~NETPR_P,
      ZINW_T_ITEM~MENGE_P,
      ZINW_T_ITEM~MATNR,
      ZINW_T_HDR~QR_CODE,
      ZINW_T_HDR~LIFNR,
      ZINW_T_HDR~NAME1,
      ZINW_T_HDR~RETURN_PO
      INTO TABLE @DATA(LT_DATA)
      FROM MSEG AS MSEG
      INNER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~MBLNR = MSEG~MBLNR
      INNER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON ZINW_T_ITEM~EBELN = MSEG~EBELN
      INNER JOIN EKPO AS EKPO ON ZINW_T_ITEM~EBELN = EKPO~EBELN AND ZINW_T_ITEM~MATNR = EKPO~MATNR
      AND ZINW_T_ITEM~EBELP = MSEG~EBELP AND ZINW_T_ITEM~MATNR = MSEG~MATNR
      WHERE MSEG~CHARG = @GS_HDR-CHARG." AND ZINW_T_HDR~SOE IS NOT NULL.

    SORT LT_DATA BY CHARG QR_CODE MATNR EBELN EBELP.
    DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING CHARG QR_CODE MATNR EBELN EBELP.
*** Validating Batch from Same Batch
    IF  GS_HDR-QR_CODE IS NOT INITIAL AND LT_DATA IS NOT INITIAL .
      READ TABLE LT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>) WITH KEY QR_CODE = GS_HDR-QR_CODE.
      IF SY-SUBRC <> 0.
*        MESSAGE 'Batch is not from the same QR Code' TYPE 'S' DISPLAY LIKE 'E'.
        MESSAGE S023(ZMSG_CLS) WITH GS_HDR-CHARG GS_HDR-QR_CODE DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
*** Adding Batch
    LOOP AT LT_DATA ASSIGNING <LS_DATA>.
      IF GS_HDR-QR_CODE IS INITIAL.
        GS_HDR-QR_CODE = <LS_DATA>-QR_CODE.
        GS_HDR-MBLNR = <LS_DATA>-MBLNR.
        GS_HDR-EBELN = <LS_DATA>-EBELN.
        GS_HDR-LIFNR = <LS_DATA>-LIFNR.
        GS_HDR-NAME1 = <LS_DATA>-NAME1.
      ENDIF.
      DESCRIBE TABLE GT_ITEM LINES DATA(LV_LINES).
      LS_ITEM-EBELP     = ( LV_LINES + 1 ) * 10.
      LS_ITEM-CHARG     = <LS_DATA>-CHARG.
      LS_ITEM-MATNR     = <LS_DATA>-MATNR.
      LS_ITEM-MENGE     = <LS_DATA>-MENGE_P .
      LS_ITEM-MENGE_S   = 1.
      LS_ITEM-MEINS     = 'EA'.
      LS_ITEM-NETWR     = LS_ITEM-NETPR = <LS_DATA>-NETPR_P .
      LS_ITEM-WAERS     = 'INR'.
      LS_ITEM-BPREI_GP  = <LS_DATA>-NETPR_GP / <LS_DATA>-MENGE_P.
      LS_ITEM-BPREI_T   = LS_ITEM-NETPR * LS_ITEM-MENGE_S + LS_ITEM-BPREI_GP.
      LS_ITEM-LGORT     = <LS_DATA>-LGORT.
      LS_ITEM-WERKS     = <LS_DATA>-WERKS.
      LS_ITEM-MWSKZ     = <LS_DATA>-MWSKZ.
      APPEND LS_ITEM TO GT_ITEM.
      APPEND LS_ITEM TO GT_ITEM_T.
      CLEAR : LS_ITEM.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV.
  CREATE OBJECT CONTAINER
    EXPORTING
      CONTAINER_NAME = MYCONTAINER.

  CREATE OBJECT GRID
    EXPORTING
      I_PARENT = CONTAINER.

  DATA: LS_FC   TYPE  LVC_S_FCAT,
        IT_SORT TYPE LVC_T_SORT,
        LS_SORT TYPE LVC_S_SORT,
        LV_POS  TYPE I VALUE 1.

  IF GT_FIELDCAT IS INITIAL.
    GS_LAYO-FRONTEND   = C_X.
    GS_LAYO-ZEBRA      = C_X.

    LS_FC-COL_POS   = LV_POS.
    LS_FC-FIELDNAME = 'MATNR'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'SST Code'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'CHARG'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-SCRTEXT_L = 'Batch'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'MENGE_S'.
    LS_FC-REF_FIELD = 'MENGE'.
    LS_FC-REF_TABLE = 'ZINW_T_ITEM'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'Quantity'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'MEINS'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'UOM'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'NETPR'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'Pur Price'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'NETWR'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'Amount'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'BPREI_GP'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'GST Amount'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

    LS_FC-COL_POS   = LV_POS + 1.
    LS_FC-FIELDNAME = 'BPREI_T'.
    LS_FC-TABNAME   = 'GT_ITEM'.
    LS_FC-NO_ZERO   = C_X.
    LS_FC-SCRTEXT_L = 'Total Amount'.
    APPEND LS_FC TO GT_FIELDCAT.
    CLEAR LS_FC.

  ENDIF.

  IF GT_EXCLUDE IS INITIAL.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
  ENDIF.

  IF GRID IS BOUND.
    CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
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
***  Refresh
    IF GRID IS BOUND.
      CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
    ENDIF.
  ENDIF.
ENDFORM.


FORM EXCLUDE_TB_FUNCTIONS  CHANGING GT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FIND_MORE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUM.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
ENDFORM.


FORM CREATE_PO CHANGING GV_SUBRC.
  CONSTANTS : C_BSART       TYPE BSART VALUE 'ZTAT'.
  DATA : LS_STATUS TYPE ZINW_T_STATUS.
  IF GT_ITEM IS NOT INITIAL.
    SELECT SINGLE * FROM EKKO INTO @DATA(LS_EKKO) WHERE EBELN = @GS_HDR-EBELN.
    CHECK SY-SUBRC IS INITIAL.
    HEADER-COMP_CODE    = LS_EKKO-BUKRS .
    HEADER-CREAT_DATE   = SY-DATUM.
    HEADER-VENDOR       = LS_EKKO-LIFNR.
    HEADER-DOC_TYPE     = C_BSART.
    HEADER-LANGU        = SY-LANGU .
    HEADER-PURCH_ORG    = LS_EKKO-EKORG.
    HEADER-PUR_GROUP    = LS_EKKO-EKGRP.

    HEADERX-COMP_CODE   = C_X.
    HEADERX-CREAT_DATE  = C_X.
    HEADERX-VENDOR      = C_X.
    HEADERX-DOC_TYPE    = C_X .
    HEADERX-LANGU       = C_X .
    HEADERX-PURCH_ORG   = C_X .
    HEADERX-PUR_GROUP   = C_X.

    REFRESH ITEM .
    REFRESH ITEMX .
    LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
      ITEM-PO_ITEM   = <LS_ITEM>-EBELP.
      ITEM-MATERIAL  = <LS_ITEM>-MATNR.
      ITEM-PLANT     = <LS_ITEM>-WERKS.
      ITEM-QUANTITY  = <LS_ITEM>-MENGE_S.
      ITEM-PO_UNIT   = <LS_ITEM>-MEINS.
      ITEM-NET_PRICE = <LS_ITEM>-NETPR.
      ITEM-STGE_LOC  = <LS_ITEM>-LGORT.
      ITEM-RET_ITEM  = C_X.
      ITEM-TAX_CODE  = <LS_ITEM>-MWSKZ.

      ITEMX-PO_ITEM     = <LS_ITEM>-EBELP.
      ITEMX-MATERIAL    = C_X.
      ITEMX-PLANT       = C_X.
      ITEMX-QUANTITY    = C_X.
      ITEMX-PO_UNIT     = C_X.
      ITEMX-NET_PRICE   = C_X.
      ITEMX-STGE_LOC    = C_X.
      ITEMX-TAX_CODE    = C_X.
      APPEND ITEM.
      APPEND ITEMX .
      CLEAR : ITEMX , ITEM.
    ENDLOOP.
*** Return PO Creation
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        POHEADER         = HEADER
        POHEADERX        = HEADERX
      IMPORTING
        EXPPURCHASEORDER = GV_EBELN
      TABLES
        RETURN           = RETURN
        POITEM           = ITEM
        POITEMX          = ITEMX.
    READ TABLE RETURN ASSIGNING FIELD-SYMBOL(<LS_RET>) WITH KEY TYPE = 'E'.
    IF SY-SUBRC <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = C_X.
      GV_MOD = C_D.
      GV_PO_CREATE = C_X.
*** Update Inward Header Table
      GS_INW_HDR-TAT_PO  = GV_EBELN.

*** Status Update
      CLEAR : LS_STATUS.
      LS_STATUS-INWD_DOC     = GS_INW_HDR-INWD_DOC.
      LS_STATUS-QR_CODE      = GS_INW_HDR-QR_CODE.
      LS_STATUS-STATUS_FIELD = C_SE_CODE.
      LS_STATUS-CREATED_BY   = SY-UNAME.
      LS_STATUS-CREATED_DATE = SY-DATUM.
      LS_STATUS-CREATED_TIME = SY-UZEIT.
      IF GS_INW_HDR-RETURN_PO IS NOT INITIAL.
        LS_STATUS-STATUS_VALUE  = C_SE04.
        LS_STATUS-DESCRIPTION  = 'Excess & Shortage'.
        GS_INW_HDR-SOE         = C_04.
      ELSE.
        LS_STATUS-STATUS_VALUE = C_SE03.
        LS_STATUS-DESCRIPTION  = 'Excess'.
        GS_INW_HDR-SOE         = C_03.
      ENDIF.
      MODIFY ZINW_T_HDR FROM GS_INW_HDR.
      MODIFY ZINW_T_STATUS FROM LS_STATUS.
      MESSAGE S022(ZMSG_CLS) WITH GV_EBELN.
    ELSE.
      GV_SUBRC = 4.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MESSAGE ID <LS_RET>-ID TYPE <LS_RET>-TYPE NUMBER <LS_RET>-NUMBER WITH <LS_RET>-MESSAGE_V1 <LS_RET>-MESSAGE_V2
      <LS_RET>-MESSAGE_V3 <LS_RET>-MESSAGE_V4.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MODE .
  IF GV_MOD = C_D.
    LOOP AT SCREEN.
      SCREEN-NAME = 'GS_HDR-CHARG'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      SCREEN-NAME = 'GS_HDR-CHARG'.
      SCREEN-INPUT = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form VALIDATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATIONS .
  CHECK GS_HDR-CHARG IS NOT INITIAL.
  SELECT SINGLE
    MSEG~MBLNR,
    MSEG~MJAHR,
    MSEG~ZEILE,
    MSEG~CHARG,
    MSEG~WERKS,
    MSEG~LGORT,
    ZINW_T_ITEM~EBELN,
    ZINW_T_ITEM~EBELP,
    ZINW_T_ITEM~NETPR_GP,
    ZINW_T_ITEM~NETPR_P,
    ZINW_T_ITEM~MENGE_P,
    ZINW_T_ITEM~MATNR,
    ZINW_T_HDR~QR_CODE,
    ZINW_T_HDR~LIFNR,
    ZINW_T_HDR~NAME1,
    ZINW_T_HDR~SOE,
    ZINW_T_HDR~RETURN_PO,
    ZINW_T_HDR~TAT_PO,
    ZINW_T_HDR~MBLNR_161
    INTO @DATA(LS_DATA)
    FROM MSEG AS MSEG
    INNER JOIN ZINW_T_HDR AS ZINW_T_HDR ON ZINW_T_HDR~MBLNR = MSEG~MBLNR
    INNER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON ZINW_T_ITEM~EBELN = MSEG~EBELN
    AND ZINW_T_ITEM~EBELP = MSEG~EBELP AND ZINW_T_ITEM~MATNR = MSEG~MATNR
    WHERE MSEG~CHARG = @GS_HDR-CHARG AND ZINW_T_HDR~QR_CODE = @GS_HDR-QR_CODE.

  IF LS_DATA-TAT_PO IS NOT INITIAL.
    MESSAGE E039(ZMSG_CLS) WITH LS_DATA-RETURN_PO.
  ELSEIF LS_DATA-RETURN_PO IS NOT INITIAL.
    SELECT SINGLE MATDOC~MBLNR,
           MATDOC~MJAHR,
           MATDOC~CHARG
           FROM   MATDOC INTO @DATA(LS_MATDOC) WHERE MBLNR = @LS_DATA-MBLNR_161 AND CHARG = @LS_DATA-CHARG AND BWART = @C_161 AND EBELN = @LS_DATA-RETURN_PO AND MATNR = @LS_DATA-MATNR.
    IF SY-SUBRC = 0.
      MESSAGE E038(ZMSG_CLS).
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_QR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_QR .
  CHECK GS_HDR-QR_CODE IS NOT INITIAL.
  SELECT SINGLE * FROM ZINW_T_HDR INTO GS_INW_HDR WHERE QR_CODE = GS_HDR-QR_CODE AND STATUS = C_04 AND TAT_PO EQ SPACE.
  IF SY-SUBRC <> 0.
***    Invalid QR Code
    MESSAGE E003(ZMSG_CLS).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLEAR.
  CLEAR : GS_HDR, GS_INW_HDR.
* REFRESH : GT_HDR  .
  IF GRID IS BOUND.
    GRID->FREE( ).
    CLEAR : GRID.
    CONTAINER->FREE( ).
    CLEAR : CONTAINER.
  ENDIF.
  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.
