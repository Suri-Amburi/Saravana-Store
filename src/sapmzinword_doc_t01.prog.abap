*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_T01
*&---------------------------------------------------------------------*

*** Data Decleration
*** types
TYPE-POOLS  : ICON , SLIS.
TYPES :
  BEGIN OF TY_MARC,
    MATNR TYPE MARC-MATNR,
    STEUC TYPE MARC-STEUC,
    STAWN TYPE MARC-STAWN,
  END OF TY_MARC.

TYPES :
  BEGIN OF TY_900,
    STEUC TYPE A900-STEUC,
    KNUMH TYPE A900-KNUMH,
    KBETR TYPE KONP-KBETR,
  END OF TY_900.

TYPES :
  BEGIN OF TY_EKKO,
    EBELN TYPE EKKO-EBELN,
    AEDAT TYPE EKKO-AEDAT,
    BSART TYPE ESART,
    ZBD1T TYPE DZBDET,
    LIFNR TYPE EKKO-LIFNR,
    KNUMV TYPE EKKO-KNUMV,
    FRGKE TYPE EKKO-FRGKE,
  END OF TY_EKKO.

TYPES :
  BEGIN OF TY_MARA,
    MATNR    TYPE MATNR,
    BRAND_ID TYPE WRF_BRAND_ID,
    ENA11    TYPE EAN11,
    NUMTP    TYPE NUMTP,
    XCHPF    TYPE XCHPF,
  END OF TY_MARA.

*** TYPES DECLARATION FOR PO ITEM DATA
TYPES:
  BEGIN OF TY_EKPO,
    EBELN          TYPE EBELN,
    EBELP          TYPE EBELP,
    MATNR          TYPE MATNR,
    WERKS          TYPE WERKS_D,
    LGORT          TYPE LGORT_D,
    MATKL          TYPE MATKL,
    MENGE          TYPE BSTMG,
    MEINS          TYPE BSTME,
    NETPR          TYPE BPREI,
    NETWR          TYPE BWERT,
    MWSKZ          TYPE MWSKZ,
    UEBTO          TYPE UEBTO,
    EAN11          TYPE EAN11,
    ZZSET_MATERIAL TYPE MATNR,
    MAKTX          TYPE MAKTX,
    OPEN_QTY       TYPE BSTMG,
  END OF TY_EKPO,

  BEGIN OF TY_ITEM_SCR,
    SNO            TYPE INT2,
    MANDT          TYPE ZINW_T_ITEM-MANDT,
    QR_CODE        TYPE ZINW_T_ITEM-QR_CODE,
    EBELN          TYPE ZINW_T_ITEM-EBELN,
    EBELP          TYPE ZINW_T_ITEM-EBELP,
    MATNR          TYPE ZINW_T_ITEM-MATNR,
    LGORT          TYPE ZINW_T_ITEM-LGORT,
    WERKS          TYPE ZINW_T_ITEM-WERKS,
    MAKTX          TYPE ZINW_T_ITEM-MAKTX,
    MATKL          TYPE ZINW_T_ITEM-MATKL,
    EAN11          TYPE ZINW_T_ITEM-EAN11,
    MENGE          TYPE ZINW_T_ITEM-MENGE,
    MENGE_P        TYPE ZINW_T_ITEM-MENGE_P,
    MEINS          TYPE ZINW_T_ITEM-MEINS,
    OPEN_QTY       TYPE ZINW_T_ITEM-OPEN_QTY,
    NETPR_P        TYPE ZINW_T_ITEM-NETPR_P,
    STEUC          TYPE ZINW_T_ITEM-STEUC,
    KBETR          TYPE ZINW_T_ITEM-KBETR,
    NETPR_GP       TYPE ZINW_T_ITEM-NETPR_GP,
    NETWR_P        TYPE ZINW_T_ITEM-NETWR_P,
    MARGN          TYPE ZINW_T_ITEM-MARGN,
    DISCOUNT       TYPE ZINW_T_ITEM-DISCOUNT,
    MENGE_S        TYPE ZINW_T_ITEM-MENGE_S,
    NETPR_S        TYPE ZINW_T_ITEM-NETPR_S,
    NETPR_GS       TYPE ZINW_T_ITEM-NETPR_GS,
    NETWR_S        TYPE ZINW_T_ITEM-NETWR_S,
    MAT_CAT        TYPE ZINW_T_ITEM-MAT_CAT,
    ZZSET_MATERIAL TYPE ZINW_T_ITEM-ZZSET_MATERIAL,
  END OF TY_ITEM_SCR.

*** Table Decleration
DATA :
  LT_ITEM     TYPE STANDARD TABLE OF ZINW_T_ITEM,
  LT_ITEM_SCR TYPE STANDARD TABLE OF TY_ITEM_SCR,
  LT_MARC     TYPE STANDARD TABLE OF TY_MARC,
  LT_900      TYPE STANDARD TABLE OF TY_900,
  LT_EKPO     TYPE STANDARD TABLE OF TY_EKPO,
  LT_MARA     TYPE STANDARD TABLE OF TY_MARA,
  LT_TAX_CODE TYPE TABLE OF A003,
  LT_KONP     TYPE TABLE OF KONP,
  WA_HDR      TYPE ZINW_T_HDR,
  WA_ITEM     TYPE ZINW_T_ITEM,
  LS_ITEM_SCR TYPE TY_ITEM_SCR,
  LS_STATUS   TYPE ZINW_T_STATUS,
  WA_EKKO     TYPE TY_EKKO,
  WA_APPROVE  TYPE ZINVOICE_T_APP.

DATA :
  P_EBELN          TYPE EKKO-EBELN,
  P_QR_CODE        TYPE ZINW_T_HDR-QR_CODE,
  OK_CODE          TYPE SY-UCOMM,
  LV_MOD(1)        VALUE 'D',
  LV_TAX_CAT(4),
  LV_TAX_%         TYPE KONP-KBETR,
  LV_ERROR(1),
  LV_STATUS        TYPE VAL_TEXT,
  LV_BSART         TYPE EKKO-BSART,
  LV_CUR_FIELD(20),
  LV_CUR_VALUE(20),
  LV_TRNS          TYPE LFA1-NAME1,
  LV_SOE_DES(20),
  LV_GR_DATE       TYPE DATUM,
  LV_APPROVAL      TYPE MEMORYID,
  LV_PROF%         TYPE KBETR,
  LV_PROF_AMT      TYPE KBETR,
  LV_NET_PAY       TYPE BWERT,
  LV_GRC_PROF      TYPE BWERT,
  LV_GRC_PROF%     TYPE BWERT,
  LV_NET_SELLING   TYPE BWERT.

FIELD-SYMBOLS :
  <LS_ITEM>     TYPE ZINW_T_ITEM,
  <LS_ITEM_SCR> TYPE TY_ITEM_SCR.

*** Constants
CONSTANTS :
  C_REG           TYPE REGIO VALUE '33',
  C_PLNT          TYPE WKREG VALUE '33',
  C_UC(2)         VALUE 'ZE',
  C_X(1)          VALUE 'X',
  C_B(2)          VALUE '01',
  C_S(2)          VALUE '02',
  C_E(2)          VALUE '03',
  C_G(2)          VALUE '04',
  C_ZLOP(4)       VALUE 'ZLOP',
  C_3000          TYPE   BWERT VALUE 3000,
  C_ZTAT(4)       VALUE 'ZTAT',
  C_03(2)         VALUE '03',
  C_01(2)         VALUE '01',
  C_05(2)         VALUE '05',
  C_D(2)          VALUE 'D',
  C_BACK(4)       VALUE 'BACK',
  C_CANCEL(6)     VALUE 'CANCEL',
  C_PRINT(5)      VALUE 'PRINT',
  C_EXIT(4)       VALUE 'EXIT',
  C_CLEAR(5)      VALUE 'CLEAR',
  C_EDIT(4)       VALUE 'EDIT',
  C_SAVE(4)       VALUE 'SAVE',
  C_DISPLAY(7)    VALUE 'DISPLAY',
  C_REFRESH(7)    VALUE 'REFRESH',
  C_ENTER(6)      VALUE 'ENTER',
  C_DEBIT(5)      VALUE 'DEBIT',
  C_DEBIT_D(7)    VALUE 'DEBIT_D',
  C_TAT(3)        VALUE 'TAT',
  C_TAT_D(5)      VALUE 'TAT_D',
  C_MATH(4)       VALUE 'MATH',
  C_QR01(4)       VALUE 'QR01',
  C_QR03(4)       VALUE 'QR03',
  C_QR04(4)       VALUE 'QR04',
  C_QR05(4)       VALUE 'QR05',
  C_QR_CODE(7)    VALUE 'QR_CODE',
  C_ES_CODE(20)   VALUE 'SHORTAGE_EXCESS',
  C_ES01(4)       VALUE 'ES01',
  C_SET(3)        VALUE 'SET',
  C_ZDIS(4)       VALUE 'ZDIS',
  C_ZMKP(4)       VALUE 'ZMKP',
  C_ZMRP(4)       VALUE 'ZMRP',
  C_CLOSE(5)      VALUE 'CLOSE',
  C_INV(3)        VALUE 'INV',
  C_APR1(4)       VALUE 'APR1',
  C_APR2(4)       VALUE 'APR2',
  C_APR3(4)       VALUE 'APR3',
  C_PAY(4)        VALUE 'PAY',
  C_PAYMENT(7)    VALUE 'PAYMENT',
  C_APPROVAL1(20) VALUE 'ZINV_APPROVAL_1',
  C_APPROVAL2(20) VALUE 'ZINV_APPROVAL_2',
  C_APPROVAL3(20) VALUE 'ZINV_APPROVAL_3',
  C_GRPO_P(10)    VALUE 'GRPO_P',
  C_GRPO_S(10)    VALUE 'GRPO_S',
  C_TRNS(10)      VALUE 'TRNS',
  C_PAY_ADV(10)   VALUE 'PAY_ADV',
  C_AUDITOR(10)   VALUE 'AUDITOR',
  C_QR_NEW(2)     VALUE '01',
  C_M(1)          VALUE 'M'.

*** reference to custom container: neccessary to bind ALV Control
DATA :
  CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GRID             TYPE REF TO CL_GUI_ALV_GRID,
  LS_PRINT         TYPE LVC_S_PRNT,
  LS_LAYOUT        TYPE LVC_S_LAYO,
  LT_LAYOUT        LIKE TABLE OF LS_LAYOUT,
  MYCONTAINER      TYPE SCRFNAME VALUE 'MYCONTAINER',
  LS_FIELDCAT      TYPE LVC_S_FCAT,
  LT_FIELDCAT      TYPE LVC_T_FCAT.

*** Declaration for excluding toolbar buttons
DATA :
  LS_EXCLUDE   TYPE UI_FUNC,
  LT_TLBR_EXCL TYPE UI_FUNCTIONS.

*** Declaration for toolbar buttons
DATA :
  TY_TOOLBAR     TYPE STB_BUTTON,
  E_OBJECT       TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET,
  IO_ALV_TOOLBAR TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

*** Event Class
CLASS EVENT_CLASS DEFINITION DEFERRED.
DATA :
  LR_EVENT TYPE REF TO EVENT_CLASS.

CLASS EVENT_CLASS DEFINITION.
  PUBLIC SECTION.
    METHODS: HANDLE_DATA_CHANGED
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.

ENDCLASS.            "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS EVENT_CLASS IMPLEMENTATION.

  METHOD HANDLE_DATA_CHANGED.
    CLEAR : LV_ERROR.
    DATA : LV_FIELD TYPE LVC_FNAME.
    DATA: IS_STABLE TYPE LVC_S_STBL, LV_LINES TYPE INT2.
    DATA : LV_TX TYPE P DECIMALS 5.
    DATA : LV_TAX TYPE P DECIMALS 5.

*** Event is triggered when data is changed in the output
    IS_STABLE = 'XX'.
*** Refreshing Data with Cusrsor Hold
    IF GRID IS BOUND.
      CALL METHOD GRID->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = IS_STABLE        " With Stable Rows/Columns
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    FIELD-SYMBOLS: <FS> TYPE ANY.
    LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS ASSIGNING FIELD-SYMBOL(<X_MOD_CELLS>).
      READ TABLE LT_ITEM ASSIGNING <LS_ITEM> INDEX <X_MOD_CELLS>-ROW_ID.
      IF SY-SUBRC = 0.
***   For Tatkal PO
***   Quantity Should be Same as Open Quantity
        IF LV_BSART = C_ZTAT.
          <LS_ITEM>-MENGE_P = <X_MOD_CELLS>-VALUE.
          IF <LS_ITEM>-MENGE <> <LS_ITEM>-MENGE_P.
            CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = 'ZMSG_CLS'
                I_MSGTY     = 'E'
                I_MSGNO     = '034'
                I_FIELDNAME = <X_MOD_CELLS>-FIELDNAME
                I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
            CLEAR : <X_MOD_CELLS>-VALUE, <LS_ITEM>-MENGE_P.
            LV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
*** Purchage Tax Amount
        <LS_ITEM>-MENGE_P = <X_MOD_CELLS>-VALUE.
        READ TABLE LT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPO>) WITH KEY EBELN = <LS_ITEM>-EBELN EBELP = <LS_ITEM>-EBELP.
        IF SY-SUBRC = 0.
          CLEAR : <LS_ITEM>-NETPR_GP.
          IF <LS_EKPO>-ZZSET_MATERIAL IS NOT INITIAL.
            DATA(LT_SET_LINES) = LT_EKPO.
            DELETE LT_SET_LINES WHERE ZZSET_MATERIAL <> <LS_EKPO>-ZZSET_MATERIAL.
            SORT   LT_SET_LINES BY ZZSET_MATERIAL MATNR.
            DELETE ADJACENT DUPLICATES FROM LT_SET_LINES COMPARING ZZSET_MATERIAL MATNR.
            LV_LINES = LINES( LT_SET_LINES ).
***         For Checking Input Quantity is matches with Set Values
            DATA(LV_MOD) = <X_MOD_CELLS>-VALUE MOD LV_LINES.
            IF LV_MOD <> 0.
              CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
                EXPORTING
                  I_MSGID     = 'ZMSG_CLS'
                  I_MSGTY     = 'E'
                  I_MSGNO     = '061'
                  I_FIELDNAME = <X_MOD_CELLS>-FIELDNAME
                  I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
              CLEAR : <X_MOD_CELLS>-VALUE, <LS_ITEM>-MENGE_P.
              LV_ERROR = 'X'.
              EXIT.
            ENDIF.
          ENDIF.
          LOOP AT LT_TAX_CODE ASSIGNING FIELD-SYMBOL(<LS_TAX_CODE>) WHERE MWSKZ = <LS_EKPO>-MWSKZ.
            IF <LS_TAX_CODE>-KSCHL = 'JIIG'.
              READ TABLE LT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP>) WITH KEY KNUMH = <LS_TAX_CODE>-KNUMH.
              IF SY-SUBRC = 0.
                LV_TX = <LS_KONP>-KBETR / 10.
                LV_TAX = ( <LS_KONP>-KBETR * <LS_EKPO>-NETWR ) / 1000.
                ADD LV_TAX TO <LS_ITEM>-NETPR_GP.
                <LS_ITEM>-KBETR = <LS_KONP>-KBETR / 10.
                EXIT.
              ENDIF.
            ELSEIF <LS_TAX_CODE>-KSCHL = 'JICG' OR <LS_TAX_CODE>-KSCHL = 'JISG'.
              READ TABLE LT_KONP ASSIGNING <LS_KONP> WITH KEY KNUMH = <LS_TAX_CODE>-KNUMH.
              IF SY-SUBRC = 0.
                CLEAR :LV_TAX.
                LV_TAX = ( <LS_KONP>-KBETR * <LS_EKPO>-NETWR ) / 1000.
                ADD LV_TAX TO <LS_ITEM>-NETPR_GP.
                LV_TX  = <LS_KONP>-KBETR / 5.
                <LS_ITEM>-KBETR = <LS_KONP>-KBETR / 5.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF <LS_EKPO>-ZZSET_MATERIAL IS NOT INITIAL.
            <LS_ITEM>-NETPR_GP = ( ( <LS_ITEM>-NETPR_GP / <LS_ITEM>-MENGE ) * <LS_ITEM>-MENGE_P ) * LV_LINES.
          ELSE.
            <LS_ITEM>-NETPR_GP = ( ( <LS_ITEM>-NETPR_GP / <LS_ITEM>-MENGE ) * <LS_ITEM>-MENGE_P ) .
          ENDIF.
        ENDIF.

        IF <LS_ITEM>-MENGE_P LE <LS_ITEM>-OPEN_QTY.
***       Selling Qty
          <LS_ITEM>-MENGE_S = <LS_ITEM>-MENGE_P.
***       Purchage Rate
          <LS_ITEM>-NETWR_P = <LS_ITEM>-MENGE_P * <LS_ITEM>-NETPR_P.
***       Purchage Tax
*          <LS_ITEM>-NETPR_GP = ( <LS_ITEM>-NETWR_P * LV_TX ) / 100.
***       Discount
***       Checking MRP Condition record Maintained or Not / EAN Managed material
          READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATNR = <LS_ITEM>-MATNR.
          IF SY-SUBRC = 0.
***         EAN Managed - Branded
            IF <LS_MARA>-ENA11 IS NOT INITIAL AND <LS_MARA>-NUMTP = C_UC.
              SELECT SINGLE KONP~KBETR FROM KONP
                     INNER JOIN A516 AS A516 ON KONP~KNUMH = A516~KNUMH INTO @DATA(LV_SPRICE)
                     WHERE A516~KSCHL = 'ZKP0' AND A516~MATNR = @<LS_ITEM>-MATNR AND A516~EAN11 = @<LS_ITEM>-EAN11 AND A516~DATAB LE @SY-DATUM AND A516~DATBI GE @SY-DATUM.
              IF SY-SUBRC <> 0.
***            Selling Price is not Maintained
                CLEAR : LV_FIELD.
                LV_FIELD = 'MATNR'.
                CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
                  EXPORTING
                    I_MSGID     = 'ZMSG_CLS'
                    I_MSGTY     = 'E'
                    I_MSGNO     = '067'
                    I_FIELDNAME = LV_FIELD
                    I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
                CLEAR : <X_MOD_CELLS>-VALUE.
                LV_ERROR = 'X'.
                EXIT.
              ENDIF.
***       SELLING PRICE WITH PURCHAGE TAX
              <LS_ITEM>-DISCOUNT = <LS_ITEM>-DISCOUNT / 10.
*            <LS_ITEM>-NETPR_S = LV_MRP  + ( ( <LS_ITEM>-DISCOUNT * LV_MRP ) / 100 ).
              <LS_ITEM>-NETPR_S = LV_SPRICE.
***       Selling Amount
              <LS_ITEM>-NETWR_S =  <LS_ITEM>-MENGE_S * <LS_ITEM>-NETPR_S.
***       Selling Price GST
              <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TX + 100 ) ) * LV_TX .
              READ TABLE LT_MARC ASSIGNING FIELD-SYMBOL(<LS_MARC>) WITH KEY MATNR = <LS_ITEM>-MATNR.
***       HSN Code
              IF SY-SUBRC = 0.
                <LS_ITEM>-STEUC = <LS_MARC>-STEUC.
              ENDIF.
            ELSEIF <LS_MARA>-XCHPF = C_X.
***         Batach Managed - Branded
              CLEAR :LV_SPRICE.
              SELECT SINGLE KONP~KBETR FROM KONP
                     INNER JOIN A502 AS A502 ON KONP~KNUMH = A502~KNUMH INTO @LV_SPRICE
                     WHERE A502~KSCHL = 'ZKP0' AND A502~MATNR = @<LS_ITEM>-MATNR AND A502~DATAB LE @SY-DATUM AND A502~DATBI GE @SY-DATUM.
              IF SY-SUBRC <> 0.
***            Selling Price is not Maintained
                CLEAR : LV_FIELD.
                LV_FIELD = 'MATNR'.
                CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
                  EXPORTING
                    I_MSGID     = 'ZMSG_CLS'
                    I_MSGTY     = 'E'
                    I_MSGNO     = '067'
                    I_FIELDNAME = LV_FIELD
                    I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
                CLEAR : <X_MOD_CELLS>-VALUE.
                LV_ERROR = 'X'.
                EXIT.
              ENDIF.

***       SELLING PRICE WITH PURCHAGE TAX
              <LS_ITEM>-DISCOUNT = <LS_ITEM>-DISCOUNT / 10.
*            <LS_ITEM>-NETPR_S = LV_MRP  + ( ( <LS_ITEM>-DISCOUNT * LV_MRP ) / 100 ).
              <LS_ITEM>-NETPR_S = LV_SPRICE.
***       Selling Amount
              <LS_ITEM>-NETWR_S =  <LS_ITEM>-MENGE_S * <LS_ITEM>-NETPR_S.
***       Selling Price GST
              <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TX + 100 ) ) * LV_TX .
              READ TABLE LT_MARC ASSIGNING <LS_MARC> WITH KEY MATNR = <LS_ITEM>-MATNR.
***       HSN Code
              IF SY-SUBRC = 0.
                <LS_ITEM>-STEUC = <LS_MARC>-STEUC.
              ENDIF.

*            SELECT SINGLE KONP~KBETR FROM KONP
*                   INNER JOIN A515 AS A515 ON KONP~KNUMH = A515~KNUMH INTO @DATA(LV_MRP)
*                   WHERE A515~KSCHL = @C_ZMRP AND A515~MATNR = @<LS_ITEM>-MATNR AND A515~DATAB LE @SY-DATUM AND A515~DATBI GE @SY-DATUM.
*            IF SY-SUBRC = 0.
*              SELECT SINGLE KONP~KBETR FROM KONP
*                     INNER JOIN A515 AS A515 ON KONP~KNUMH = A515~KNUMH INTO @<LS_ITEM>-DISCOUNT
*                     WHERE A515~KSCHL = @C_ZDIS AND A515~MATNR = @<LS_ITEM>-MATNR AND A515~DATAB LE @SY-DATUM AND A515~DATBI GE @SY-DATUM.
*              IF SY-SUBRC <> 0.
*                CLEAR : LV_FIELD.
*                LV_FIELD = 'MATNR'.
*                CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
*                  EXPORTING
*                    I_MSGID     = 'ZMSG_CLS'
*                    I_MSGTY     = 'E'
*                    I_MSGNO     = '042'
*                    I_FIELDNAME = LV_FIELD
*                    I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
*                CLEAR : <X_MOD_CELLS>-VALUE.
*                LV_ERROR = 'X'.
*                EXIT.
            ENDIF.
          ELSE.

***       Margin
***       Vendor & Material Combination
            SELECT SINGLE KONP~KBETR FROM KONP
                   INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
                   WHERE A502~LIFNR = WA_HDR-LIFNR
                   AND   A502~MATNR = <LS_ITEM>-MATNR AND A502~KSCHL = C_ZMKP AND DATAB LE SY-DATUM AND DATBI GE SY-DATUM.
***       Checking Margin
            IF <LS_ITEM>-MARGN IS INITIAL.
              CLEAR : LV_FIELD.
              LV_FIELD = 'MATNR'.
              CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
                EXPORTING
                  I_MSGID     = 'ZMSG_CLS'
                  I_MSGTY     = 'E'
                  I_MSGNO     = '015'
                  I_FIELDNAME = LV_FIELD
                  I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
              CLEAR : <X_MOD_CELLS>-VALUE, <LS_ITEM>-MENGE_P.
              LV_ERROR = 'X'.
              EXIT.
            ELSE.
***       SELLING GST TAX CODE
              IF <LS_ITEM>-MARGN IS NOT INITIAL.
                <LS_ITEM>-MARGN = <LS_ITEM>-MARGN / 10.
***       Selling Price with purchage tax
                <LS_ITEM>-NETPR_S = ( ( <LS_ITEM>-MARGN * <LS_ITEM>-NETPR_P ) / 100 ) + <LS_ITEM>-NETPR_P .
***       Selling Amount
                <LS_ITEM>-NETWR_S =  <LS_ITEM>-MENGE_S * <LS_ITEM>-NETPR_S.
***       Selling Price GST
                <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TX + 100 ) ) * LV_TX .
                READ TABLE LT_MARC ASSIGNING <LS_MARC> WITH KEY MATNR = <LS_ITEM>-MATNR.
***       HSN Code
                IF SY-SUBRC = 0.
                  <LS_ITEM>-STEUC = <LS_MARC>-STEUC.
                ENDIF.
              ENDIF.
            ENDIF. " Margin
          ENDIF.   " Mara
        ELSE.
***       Error  : Entered PO Quantity greater than Open PO Quantity
          CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
            EXPORTING
              I_MSGID     = 'ZMSG_CLS'
              I_MSGTY     = 'E'
              I_MSGNO     = '004'
              I_FIELDNAME = <X_MOD_CELLS>-FIELDNAME
              I_ROW_ID    = <X_MOD_CELLS>-ROW_ID.
          CLEAR : <X_MOD_CELLS>-VALUE.
          LV_ERROR = 'X'.
          EXIT.
        ENDIF. " Open Qty
      ENDIF.   " ROW_ID
    ENDLOOP.

    IF GRID IS BOUND AND LV_ERROR IS INITIAL.
      REFRESH LT_ITEM_SCR.
      MOVE-CORRESPONDING LT_ITEM TO LT_ITEM_SCR.
      LOOP AT LT_ITEM_SCR ASSIGNING <LS_ITEM_SCR>.
        <LS_ITEM_SCR>-SNO = SY-TABIX.
      ENDLOOP.

      CALL METHOD GRID->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = IS_STABLE        " With Stable Rows/Columns
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
***    Update Totals
    IF LV_ERROR IS INITIAL.
      CLEAR : WA_HDR-TOTAL, WA_HDR-PUR_TOTAL,WA_HDR-NET_AMT,WA_HDR-T_GST, WA_HDR-PUR_TAX ,LV_NET_SELLING , LV_NET_PAY, LV_PROF_AMT, LV_GRC_PROF,LV_GRC_PROF%.
      LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
        IF <LS_ITEM>-MENGE_P IS NOT INITIAL.
          ADD <LS_ITEM>-NETWR_S  TO WA_HDR-TOTAL.
          ADD <LS_ITEM>-NETWR_P  TO WA_HDR-PUR_TOTAL.
*          ADD <LS_ITEM>-NETPR_GP TO WA_HDR-PUR_TOTAL.
          ADD <LS_ITEM>-NETPR_GS TO WA_HDR-T_GST.
          ADD <LS_ITEM>-NETPR_GP TO WA_HDR-PUR_TAX.
          WA_HDR-NET_AMT = WA_HDR-PUR_TOTAL.
        ENDIF.
      ENDLOOP.
*      WA_HDR-PUR_TOTAL = WA_HDR-PUR_TOTAL.
      WA_HDR-NET_AMT   = LV_NET_PAY = WA_HDR-PUR_TOTAL + WA_HDR-PUR_TAX + WA_HDR-PACKING_CHARGE - WA_HDR-DISCOUNT.
      LV_NET_SELLING   = WA_HDR-TOTAL - WA_HDR-T_GST.
      LV_GRC_PROF      = WA_HDR-TOTAL - WA_HDR-PUR_TOTAL.
      LV_PROF_AMT      = WA_HDR-TOTAL - WA_HDR-NET_AMT.
      IF WA_HDR-NET_AMT IS NOT INITIAL.
        LV_PROF%       = ( LV_PROF_AMT * 100 ) / WA_HDR-NET_AMT.
      ENDIF.

      IF WA_HDR-NET_AMT IS NOT INITIAL.
        LV_GRC_PROF%       = ( LV_GRC_PROF * 100 ) / WA_HDR-PUR_TOTAL.
      ENDIF.

****   To Refresh the Main Screen
*      CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*        EXPORTING
*          NEW_CODE = 'REFRESH'.
    ELSE.
      CALL METHOD ER_DATA_CHANGED->DISPLAY_PROTOCOL( ).
    ENDIF.
    CLEAR :LV_ERROR.
  ENDMETHOD.
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
