*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form VALIDATE_PO
*&---------------------------------------------------------------------*
FORM VALIDATE_PO.
  DATA : LV_DATE TYPE DATUM.
  IF SY-UCOMM <> C_CLEAR.
    IF P_EBELN IS NOT INITIAL.
      CLEAR : WA_EKKO.
      SELECT SINGLE EBELN AEDAT BSART ZBD1T LIFNR KNUMV FRGKE FROM EKKO INTO WA_EKKO WHERE EBELN = P_EBELN .
      IF SY-SUBRC <> 0 .
        MESSAGE E000(ZMSG_CLS).
      ELSE.
        LV_BSART = WA_EKKO-BSART.
*** Tatkal PO Validation : Not Allowing TP2 For More then 10 days
        IF LV_BSART = C_ZTAT.
          LV_DATE =  WA_EKKO-AEDAT + 10.
          IF LV_DATE < SY-DATUM .
            MESSAGE E053(ZMSG_CLS) WITH P_EBELN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF P_QR_CODE IS NOT INITIAL.
      SELECT SINGLE QR_CODE FROM ZINW_T_HDR INTO @DATA(LV_QR) WHERE QR_CODE = @P_QR_CODE.
      IF SY-SUBRC  <> 0.
        MESSAGE E024(ZMSG_CLS).
      ENDIF.
*  ELSEIF P_EBELN IS INITIAL.
*    MESSAGE E001(ZMSG_CLS).
    ENDIF.
  ELSE.
    CLEAR : P_EBELN, P_QR_CODE , WA_HDR, LV_NET_PAY, LV_NET_SELLING.
    CLEAR : OK_CODE.
  ENDIF.
ENDFORM.
FORM GET_DATA.
  DATA: LV_QTY TYPE EKPO-MENGE.
  FIELD-SYMBOLS : <LS_EKPO> LIKE LINE OF LT_EKPO.
  IF P_QR_CODE IS NOT INITIAL.
    SELECT SINGLE * FROM ZINW_T_HDR INTO WA_HDR WHERE QR_CODE = P_QR_CODE.
    IF SY-SUBRC <> 0.
      MESSAGE S003(ZMSG_CLS) DISPLAY LIKE 'E'.
      EXIT.
    ELSEIF WA_HDR-STATUS GE C_05 AND LV_MOD = 'E'.
      LV_MOD  = C_D.
      CLEAR : WA_HDR.
      MESSAGE S045(ZMSG_CLS) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
***  GRPO Date
    IF WA_HDR-MBLNR IS NOT INITIAL.
      SELECT SINGLE CREATED_DATE FROM ZINW_T_STATUS INTO LV_GR_DATE WHERE QR_CODE = WA_HDR-QR_CODE AND STATUS_FIELD = C_QR_CODE AND STATUS_VALUE = C_QR04.
*      LV_GR_DATE = GR_DATE+6(2) && '.' && GR_DATE+4(2) && '.' && GR_DATE+0(4).
    ELSEIF WA_HDR-MBLNR_103 IS NOT INITIAL.
      SELECT SINGLE CREATED_DATE FROM ZINW_T_STATUS INTO LV_GR_DATE WHERE QR_CODE = WA_HDR-QR_CODE AND STATUS_FIELD = C_QR_CODE AND STATUS_VALUE = C_QR03.
    ENDIF.
    SELECT SINGLE NAME1 FROM LFA1 INTO LV_TRNS WHERE LIFNR = WA_HDR-TRNS.
    SELECT SINGLE DDTEXT FROM DD07V INTO LV_STATUS WHERE DOMNAME = 'ZSTATUS' AND DOMVALUE_L = WA_HDR-STATUS AND DDLANGUAGE = SY-LANGU.
    SELECT SINGLE DDTEXT FROM DD07V INTO LV_SOE_DES WHERE DOMNAME = 'ZSOE' AND DOMVALUE_L = WA_HDR-SOE AND DDLANGUAGE = SY-LANGU.
***  Get Approval Status
    CLEAR : WA_APPROVE.
    SELECT SINGLE * FROM ZINVOICE_T_APP INTO WA_APPROVE WHERE QR_CODE = P_QR_CODE.
    TRY .
        ZCL_GRPO=>GET_INW_ITEM(
          EXPORTING
            I_QR          = P_QR_CODE
          IMPORTING
            T_ITEM        = LT_ITEM ).
      CATCH CX_AMDP_ERROR.
    ENDTRY.
*** Grocess Profit in %

    IF WA_HDR-PUR_TOTAL IS NOT INITIAL .
      LV_PROF% = ( WA_HDR-GRC_PFR * 100 ) / WA_HDR-PUR_TOTAL.
    ENDIF.

    IF LT_ITEM IS NOT INITIAL.
***   Unit Converstion form Input to Output
      DATA(LT_ITEM_UC) = LT_ITEM.
      DATA : LV_MEINS TYPE BSTME.
      SORT LT_ITEM_UC BY MEINS.
      DELETE ADJACENT DUPLICATES FROM LT_ITEM_UC COMPARING MEINS.
      LOOP AT LT_ITEM_UC ASSIGNING <LS_ITEM>.
        LV_MEINS = <LS_ITEM>-MEINS.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            INPUT          = LV_MEINS
            LANGUAGE       = SY-LANGU
          IMPORTING
            OUTPUT         = <LS_ITEM>-MEINS
          EXCEPTIONS
            UNIT_NOT_FOUND = 1
            OTHERS         = 2.
        IF SY-SUBRC = 0.
          MODIFY LT_ITEM FROM <LS_ITEM> TRANSPORTING MEINS WHERE MEINS = LV_MEINS.
        ENDIF.
      ENDLOOP.
      UNASSIGN : <LS_ITEM>.
*      SELECT ZINW_T_ITEM~QR_CODE,
*             ZINW_T_ITEM~EBELN,
*             ZINW_T_ITEM~EBELP,
*             ZINW_T_ITEM~MENGE
*             INTO TABLE @DATA(LT_TEMP)
*             FROM ZINW_T_ITEM
*             INNER JOIN ZINW_T_HDR
*             ON ZINW_T_ITEM~EBELN =  ZINW_T_HDR~EBELN
*             WHERE ZINW_T_HDR~QR_CODE = @P_QR_CODE
*             AND ZINW_T_HDR~STATUS = @C_QR_NEW.
*
*      DELETE LT_TEMP WHERE QR_CODE = P_QR_CODE.
*      SELECT EBELN,
*             EBELP,
*             MENGE,
*             WEMNG
*             INTO TABLE @DATA(LT_TEMP1)
*             FROM EKET
*             FOR ALL ENTRIES IN @LT_ITEM
*             WHERE EBELN = @LT_ITEM-EBELN AND EBELP =  @LT_ITEM-EBELP.
*
*      DATA : LV_QTY_O TYPE EKET-MENGE.
*      LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
*        CLEAR : LV_QTY_O.
*        LOOP AT LT_TEMP ASSIGNING FIELD-SYMBOL(<LS_TEMP>) WHERE EBELN = <LS_ITEM>-EBELN AND EBELP = <LS_ITEM>-EBELP.
*          ADD <LS_TEMP>-MENGE  TO LV_QTY_O.
*        ENDLOOP.
*        READ TABLE LT_TEMP1 ASSIGNING FIELD-SYMBOL(<LS_TEMP1>) WITH KEY EBELN = <LS_ITEM>-EBELN EBELP = <LS_ITEM>-EBELP.
*        IF SY-SUBRC = 0.
*          <LS_ITEM>-OPEN_QTY = <LS_TEMP1>-MENGE - <LS_TEMP1>-WEMNG - LV_QTY_O.
*        ENDIF.
*      ENDLOOP.

*** For Displaing As SET Materials
***  For Set Materials
      DATA(LT_ITEM_SET) = LT_ITEM.
      DELETE LT_ITEM_SET WHERE ZZSET_MATERIAL IS INITIAL.
      IF LT_ITEM_SET IS NOT INITIAL.
        UNASSIGN :<LS_EKPO>.
        SORT LT_ITEM_SET BY ZZSET_MATERIAL.
        DELETE ADJACENT DUPLICATES FROM LT_ITEM_SET COMPARING ZZSET_MATERIAL.
***       SET Material Wise Loop
        LOOP AT LT_ITEM_SET ASSIGNING <LS_ITEM>.
          WA_ITEM = <LS_ITEM>.
          CLEAR : WA_ITEM-ZZSET_MATERIAL.
          WA_ITEM-EBELN    = <LS_ITEM>-EBELN.
          WA_ITEM-EBELP    = <LS_ITEM>-EBELP.
          WA_ITEM-MATNR    = <LS_ITEM>-ZZSET_MATERIAL.
          WA_ITEM-MAKTX    = <LS_ITEM>-MAKTX.
          WA_ITEM-MATKL    = <LS_ITEM>-MATKL.
          WA_ITEM-WERKS    = <LS_ITEM>-WERKS.
          WA_ITEM-LGORT    = <LS_ITEM>-LGORT.
          WA_ITEM-EAN11    = <LS_ITEM>-EAN11.
***         For Set Material Sub Components
          DATA(LT_ITEM_S)  = LT_ITEM.
          DELETE LT_ITEM_S WHERE ZZSET_MATERIAL <> <LS_ITEM>-ZZSET_MATERIAL.
          DESCRIBE TABLE LT_ITEM_S LINES DATA(LV_LINES).
          WA_ITEM-MENGE_P    = <LS_ITEM>-MENGE_P * LV_LINES.
          WA_ITEM-MENGE_S    = <LS_ITEM>-MENGE_S * LV_LINES.
          WA_ITEM-MEINS      = C_SET.
          WA_ITEM-NETPR_P    = <LS_ITEM>-NETPR_P.
          WA_ITEM-NETWR_P    = <LS_ITEM>-NETWR_P * LV_LINES.
          WA_ITEM-NETWR_S    = <LS_ITEM>-NETWR_S * LV_LINES.
          WA_ITEM-NETPR_GP   = <LS_ITEM>-NETPR_GP * LV_LINES.
          WA_ITEM-NETPR_GS   = <LS_ITEM>-NETPR_GS * LV_LINES.
          APPEND WA_ITEM TO LT_ITEM.
          CLEAR: WA_ITEM.
        ENDLOOP.
      ENDIF. " Set Material
      DELETE LT_ITEM WHERE ZZSET_MATERIAL IS NOT INITIAL.
      P_EBELN = WA_HDR-EBELN.
      IF WA_HDR-STATUS = C_03 AND LV_MOD = C_E.
        LV_MOD = C_D.
        MESSAGE  W005(ZMSG_CLS).
      ENDIF.
    ENDIF.
    SORT LT_ITEM BY EBELN EBELP.
  ELSE.
*** PO as input
    REFRESH : LT_ITEM.
*** PO Header data
*    SELECT SINGLE EBELN
*                  AEDAT
*                  ZBD1T
*                  LIFNR
*                  KNUMV
*                  FROM EKKO INTO WA_EKKO WHERE EBELN = P_EBELN.
*** PO Item Date
    IF WA_EKKO IS NOT INITIAL.
      TRY .
          ZCL_GRPO=>GET_PO_ITEM(
            EXPORTING
              I_EBELN =  WA_EKKO-EBELN
            IMPORTING
              T_EKPO  =  LT_EKPO ).
        CATCH CX_AMDP_ERROR.
      ENDTRY.
***  SET Materials
      SORT LT_EKPO BY EBELN EBELP.
*      IF SY-UNAME = 'SAMBURI'.
      LOOP AT LT_EKPO ASSIGNING <LS_EKPO> WHERE ZZSET_MATERIAL IS NOT INITIAL.
        DATA(LV_SET) = 'X'.
        EXIT.
      ENDLOOP.
      IF LV_SET = C_X.
***     Bom Components
        SELECT MAST~MATNR,
               MAST~WERKS,
               MAST~STLNR,
               MAST~STLAL,
               STPO~STLKN,
               STPO~IDNRK,
               STPO~POSNR,
               STPO~MENGE,
               STPO~MEINS
               INTO TABLE @DATA(LT_COMP)
               FROM MAST AS MAST
               INNER JOIN STPO AS STPO ON STPO~STLTY = @C_M AND MAST~STLNR = STPO~STLNR
               FOR ALL ENTRIES IN @LT_EKPO
               WHERE MAST~MATNR = @LT_EKPO-ZZSET_MATERIAL.
      ENDIF.
*      ENDIF.

      IF LT_EKPO IS NOT INITIAL.
***     For Booking Station
        UNASSIGN : <LS_EKPO>.
        READ TABLE LT_EKPO ASSIGNING <LS_EKPO> INDEX 1.
        IF SY-SUBRC = 0.
          SELECT SINGLE NAME1 FROM T001W INTO WA_HDR-BK_STATION WHERE WERKS = <LS_EKPO>-WERKS.
        ENDIF.
***   Unit Converstion from Input to Output
        SORT LT_EKPO BY EBELN EBELP.
        DATA(LT_EKPO_UC) = LT_EKPO.
        SORT LT_EKPO_UC BY MEINS.
        DELETE ADJACENT DUPLICATES FROM LT_EKPO_UC COMPARING MEINS.

        LOOP AT LT_EKPO_UC ASSIGNING <LS_EKPO>.
          LV_MEINS = <LS_EKPO>-MEINS.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              INPUT          = LV_MEINS
              LANGUAGE       = SY-LANGU
            IMPORTING
              OUTPUT         = <LS_EKPO>-MEINS
            EXCEPTIONS
              UNIT_NOT_FOUND = 1
              OTHERS         = 2.
          IF SY-SUBRC = 0.
            MODIFY LT_EKPO FROM <LS_EKPO> TRANSPORTING MEINS WHERE MEINS = LV_MEINS.
          ENDIF.
        ENDLOOP.
        UNASSIGN : <LS_ITEM>.
        DELETE LT_EKPO WHERE OPEN_QTY = 0.
** For Updating Open Qty
        SELECT * FROM ZINW_T_HDR INTO TABLE @DATA(LT_HDR_O) WHERE EBELN = @P_EBELN AND STATUS < '04'.  "@C_QR_NEW'.
        IF SY-SUBRC = 0.
          SELECT * FROM ZINW_T_ITEM INTO TABLE @DATA(LT_ITEM_O) FOR ALL ENTRIES IN @LT_HDR_O WHERE QR_CODE = @LT_HDR_O-QR_CODE.
        ENDIF.
        LOOP AT LT_EKPO ASSIGNING <LS_EKPO>.
          CLEAR : LV_QTY.
          LOOP AT LT_ITEM_O ASSIGNING FIELD-SYMBOL(<LS_ITEM_O>) WHERE EBELN = <LS_EKPO>-EBELN AND EBELP = <LS_EKPO>-EBELP AND MATNR = <LS_EKPO>-MATNR.
            ADD <LS_ITEM_O>-MENGE_P TO LV_QTY.
          ENDLOOP.
***       Calculating the OVER TOLARANCE Quantity
          DATA(LV_QTY_TOL) =  ( <LS_EKPO>-MENGE * <LS_EKPO>-UEBTO ) / 100.
          <LS_EKPO>-OPEN_QTY = <LS_EKPO>-OPEN_QTY - LV_QTY + LV_QTY_TOL.
        ENDLOOP.

        DELETE LT_EKPO WHERE OPEN_QTY LE 0.
*** HSN code details
        SELECT MATNR
               STEUC
               STAWN
               FROM MARC INTO TABLE LT_MARC FOR ALL ENTRIES IN LT_EKPO WHERE MATNR = LT_EKPO-MATNR.
        DELETE LT_MARC WHERE STEUC IS INITIAL.
*** Condtion Records
        SELECT * FROM A003 INTO TABLE LT_TAX_CODE FOR ALL ENTRIES IN LT_EKPO WHERE MWSKZ = LT_EKPO-MWSKZ.
        IF LT_TAX_CODE IS NOT INITIAL.
          SELECT * FROM KONP INTO TABLE LT_KONP FOR ALL ENTRIES IN LT_TAX_CODE WHERE KNUMH = LT_TAX_CODE-KNUMH.
        ENDIF.

*** Selling Price GST
        IF LT_MARC IS NOT INITIAL.
          SELECT A900~STEUC A900~KNUMH KONP~KBETR FROM A900
                 INNER JOIN KONP ON A900~KNUMH EQ KONP~KNUMH INTO TABLE LT_900
                 FOR ALL ENTRIES IN LT_MARC WHERE A900~STEUC = LT_MARC-STEUC AND REGIO = C_REG AND WKREG = C_PLNT AND DATBI GE SY-DATUM AND DATAB LE SY-DATUM.
        ENDIF.
*** Get Material Type : Branded or Non Branded
        SELECT MATNR BRAND_ID EAN11 FROM MARA INTO TABLE LT_MARA FOR ALL ENTRIES IN LT_EKPO WHERE MATNR = LT_EKPO-MATNR AND BRAND_ID IS NOT NULL AND NUMTP = C_UC  .
      ENDIF.

***  Header Data
      CLEAR : WA_ITEM.
      WA_HDR-EBELN = WA_EKKO-EBELN.
      WA_HDR-LIFNR = WA_EKKO-LIFNR.
      WA_HDR-REC_DATE = SY-DATUM.
      IF LV_GR_DATE IS NOT INITIAL.
        WA_HDR-DUE_DATE = LV_GR_DATE + WA_EKKO-ZBD1T.
      ENDIF.
*      WA_HDR-REC_DATE = LV_DUE_DATE+6(2) && '.' && LV_DUE_DATE+4(2) && '.' && LV_DUE_DATE+0(4).
      SELECT SINGLE NAME1 J_1IVTYP FROM LFA1 INTO ( WA_HDR-NAME1 , WA_HDR-J_1IVTYP ) WHERE LIFNR = WA_HDR-LIFNR.
*** Item Details
      LOOP AT LT_EKPO ASSIGNING <LS_EKPO> WHERE ZZSET_MATERIAL IS INITIAL.
        WA_ITEM-EBELN    = <LS_EKPO>-EBELN.
        WA_ITEM-EBELP    = <LS_EKPO>-EBELP.
        WA_ITEM-MATNR    = <LS_EKPO>-MATNR.
        WA_ITEM-MAKTX    = <LS_EKPO>-MAKTX.
        WA_ITEM-MATKL    = <LS_EKPO>-MATKL.
        WA_ITEM-WERKS    = <LS_EKPO>-WERKS.
        WA_ITEM-LGORT    = <LS_EKPO>-LGORT.
        WA_ITEM-MENGE    = <LS_EKPO>-MENGE.
        WA_ITEM-MEINS    = <LS_EKPO>-MEINS.
        WA_ITEM-NETPR_P  = <LS_EKPO>-NETPR.
        WA_ITEM-OPEN_QTY = <LS_EKPO>-OPEN_QTY.
        WA_ITEM-NETWR_P  = <LS_EKPO>-NETWR.
        WA_ITEM-EAN11  = <LS_EKPO>-EAN11.
*** Purchage Tax Amount : Moved to Data Change method
*        LOOP AT LT_TAX_CODE ASSIGNING FIELD-SYMBOL(<LS_TAX_CODE>) WHERE MWSKZ = <LS_EKPO>-MWSKZ.
*          IF <LS_TAX_CODE>-KSCHL = 'JIIG'.
*            READ TABLE LT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP>) WITH KEY KNUMH = <LS_TAX_CODE>-KNUMH.
*            IF SY-SUBRC = 0.
*              DATA(LV_TAX) = ( <LS_KONP>-KBETR * <LS_EKPO>-NETWR ) / 1000.
*              ADD LV_TAX TO WA_ITEM-NETPR_GP.
*              EXIT.
*            ENDIF.
*          ELSEIF <LS_TAX_CODE>-KSCHL = 'JICG' OR <LS_TAX_CODE>-KSCHL = 'JISG'.
*            READ TABLE LT_KONP ASSIGNING <LS_KONP> WITH KEY KNUMH = <LS_TAX_CODE>-KNUMH.
*            IF SY-SUBRC = 0.
*              CLEAR :LV_TAX.
*              LV_TAX = ( <LS_KONP>-KBETR * <LS_EKPO>-NETWR ) / 1000.
*              ADD LV_TAX TO WA_ITEM-NETPR_GP.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.
*** AMDP Query
*        IF WA_HDR-LIFNR IS NOT INITIAL AND WA_ITEM-MATNR IS NOT INITIAL.
*          ZCL_GST=>GET_GST_PER(
*            EXPORTING
*              I_MATNR =   WA_ITEM-MATNR " Material Number
*              I_LIFNR =   WA_HDR-LIFNR  " Account Number of Vendor or Creditor
*            IMPORTING
*              ET_TAX  =   DATA(LT_TAX) ). " Tax Table type
**          CLEAR : LV_TAX.
*          LOOP AT LT_TAX ASSIGNING FIELD-SYMBOL(<LS_TAX>).
*            DATA(LV_TAX) = ( <LS_TAX>-TAX * <LS_EKPO>-NETWR ) / 1000.
*            ADD LV_TAX TO WA_ITEM-NETPR_GP.
*          ENDLOOP.
*        ENDIF.
        APPEND WA_ITEM TO LT_ITEM.
        CLEAR : WA_ITEM.
      ENDLOOP.
***  For Set Materials
      DATA(LT_EKPO_SET) = LT_EKPO.
***     Set Material Wise Loop
      DELETE LT_EKPO_SET WHERE ZZSET_MATERIAL IS INITIAL.
      IF LT_EKPO_SET IS NOT INITIAL.
        UNASSIGN :<LS_EKPO>.
        SORT LT_EKPO_SET BY ZZSET_MATERIAL.
        DELETE ADJACENT DUPLICATES FROM LT_EKPO_SET COMPARING ZZSET_MATERIAL.
        LOOP AT LT_EKPO_SET ASSIGNING <LS_EKPO>.
          WA_ITEM-EBELN    = <LS_EKPO>-EBELN.
          WA_ITEM-EBELP    = <LS_EKPO>-EBELP.
          WA_ITEM-MATNR    = <LS_EKPO>-ZZSET_MATERIAL.
          WA_ITEM-MAKTX    = <LS_EKPO>-MAKTX.
          WA_ITEM-MATKL    = <LS_EKPO>-MATKL.
          WA_ITEM-WERKS    = <LS_EKPO>-WERKS.
          WA_ITEM-LGORT    = <LS_EKPO>-LGORT.
***         For Set Material Sub Components
          CLEAR :LV_LINES.
          DATA(LT_EKPO_S)  = LT_EKPO.
          DELETE LT_EKPO_S WHERE ZZSET_MATERIAL <> <LS_EKPO>-ZZSET_MATERIAL.
          DESCRIBE TABLE LT_EKPO_S LINES LV_LINES.
          WA_ITEM-MENGE    = <LS_EKPO>-MENGE * LV_LINES.
          WA_ITEM-MEINS    = C_SET.
          WA_ITEM-NETPR_P  = <LS_EKPO>-NETPR.
          WA_ITEM-OPEN_QTY = <LS_EKPO>-OPEN_QTY * LV_LINES.
          WA_ITEM-NETWR_P  = <LS_EKPO>-NETWR * LV_LINES.
          APPEND WA_ITEM TO LT_ITEM.
        ENDLOOP.
      ENDIF. " Set Material
    ENDIF.
  ENDIF.
  SORT LT_ITEM BY EBELN EBELP.
*** For Serial Number's
  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.

  ENDLOOP.
ENDFORM.

FORM SAVE_DATA .
  DATA :
    LV_MAT_CAT  TYPE CHAR20,
    LV_ERROR(1),
    WA_STATUS   TYPE ZINW_T_STATUS.

*** Skipping Validation On Mandatory Fields for ZLOP Doc type
  IF LV_BSART <> C_ZLOP.
*** Skipping LR Number & Transporter Validation On Mandatory Fields for ZTAQ Doc type
    IF LV_BSART <> C_ZTAT.
      IF WA_HDR-TRNS IS INITIAL OR WA_HDR-LR_NO IS INITIAL OR WA_HDR-LR_DATE IS INITIAL OR
        WA_HDR-BILL_NUM IS INITIAL OR WA_HDR-BILL_DATE IS INITIAL AND WA_HDR-ACT_NO_BUD IS INITIAL .
        LV_ERROR = C_E.
        MESSAGE E006(ZMSG_CLS).
        EXIT.
      ENDIF.
    ELSEIF  LV_BSART = C_ZTAT.
      IF WA_HDR-BILL_NUM IS INITIAL OR WA_HDR-BILL_DATE IS INITIAL.
        LV_ERROR = C_E.
        MESSAGE E006(ZMSG_CLS)." DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
***  Deleting the Items which has '0' Purchage Quantity
  DELETE LT_ITEM WHERE MENGE_P IS INITIAL.
  CHECK LT_ITEM IS NOT INITIAL.
  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
    IF <LS_ITEM>-MENGE_P > <LS_ITEM>-OPEN_QTY.
      LV_ERROR = C_E.
      MESSAGE E004(ZMSG_CLS)."DISPLAY LIKE C_E.
      EXIT.
    ENDIF.
    READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATNR = <LS_ITEM>-MATNR.
    IF SY-SUBRC = 0.
      IF <LS_MARA>-BRAND_ID IS INITIAL.
        IF <LS_ITEM>-MARGN IS INITIAL AND <LS_ITEM>-MENGE_P IS NOT INITIAL.
          LV_ERROR = C_E.
          MESSAGE E015(ZMSG_CLS).
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF LV_ERROR <> C_E.
    IF WA_HDR-QR_CODE IS INITIAL.
*** Get Next number for QR code from Number range
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR             = '1'
          OBJECT                  = 'ZQR_NO'
        IMPORTING
          NUMBER                  = WA_HDR-INWD_DOC
        EXCEPTIONS
          INTERVAL_NOT_FOUND      = 1
          NUMBER_RANGE_NOT_INTERN = 2
          OBJECT_NOT_FOUND        = 3
          QUANTITY_IS_0           = 4
          QUANTITY_IS_NOT_1       = 5
          INTERVAL_OVERFLOW       = 6
          BUFFER_OVERFLOW         = 7
          OTHERS                  = 8.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
      P_QR_CODE        = WA_HDR-QR_CODE = SY-DATUM && SY-UZEIT.
      WA_HDR-ERNAME    = SY-UNAME.
      WA_HDR-ERDATE    = SY-DATUM.
      WA_HDR-ERTIME    = SY-UZEIT.
      WA_HDR-STATUS    = C_01.
      LV_STATUS = 'NEW'.
      WA_ITEM-QR_CODE = WA_HDR-QR_CODE.

***   For Updating Status Table
      WA_STATUS-QR_CODE      = WA_HDR-QR_CODE.
      WA_STATUS-INWD_DOC     = WA_HDR-INWD_DOC.
      WA_STATUS-STATUS_FIELD = C_QR_CODE.
      WA_STATUS-STATUS_VALUE = C_QR01.
      WA_STATUS-DESCRIPTION  = 'QR Code Created'.
      WA_STATUS-CREATED_BY   = SY-UNAME.
      WA_STATUS-CREATED_DATE = SY-DATUM.
      WA_STATUS-CREATED_TIME = SY-UZEIT.
***   Updating Sub Components for SET Materials
      READ TABLE LT_ITEM WITH KEY MEINS = C_SET TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        DATA(LT_ITEM_SET) = LT_ITEM.
        DELETE LT_ITEM_SET WHERE MEINS = C_SET.
        LOOP AT LT_ITEM ASSIGNING <LS_ITEM> WHERE MEINS = C_SET.
          MOVE-CORRESPONDING <LS_ITEM> TO WA_ITEM.
          DATA(LT_EKPO_SET) = LT_EKPO.
          DELETE LT_EKPO_SET WHERE ZZSET_MATERIAL <> <LS_ITEM>-MATNR.
          DESCRIBE TABLE LT_EKPO_SET LINES DATA(LV_LINES).
***       Sub Components
          LOOP AT LT_EKPO_SET ASSIGNING FIELD-SYMBOL(<LS_EKPO>) WHERE ZZSET_MATERIAL =  <LS_ITEM>-MATNR.
            WA_ITEM-QR_CODE = WA_HDR-QR_CODE.
            WA_ITEM-MATNR   = <LS_EKPO>-MATNR.
            WA_ITEM-MAKTX   = <LS_EKPO>-MAKTX.
            WA_ITEM-EBELP   = <LS_EKPO>-EBELP.
            WA_ITEM-MEINS   = <LS_EKPO>-MEINS.
            WA_ITEM-ZZSET_MATERIAL   = <LS_EKPO>-ZZSET_MATERIAL.
            WA_ITEM-MENGE_P = <LS_ITEM>-MENGE_P / LV_LINES.
            WA_ITEM-NETPR_GP = <LS_ITEM>-NETPR_GP / LV_LINES.
            WA_ITEM-MENGE_S = <LS_ITEM>-MENGE_S / LV_LINES.
            WA_ITEM-NETPR_GS = <LS_ITEM>-NETPR_GS / LV_LINES.
            WA_ITEM-NETWR_P = <LS_ITEM>-NETWR_P / LV_LINES.
            WA_ITEM-NETWR_S = <LS_ITEM>-NETWR_S / LV_LINES.
            APPEND WA_ITEM TO LT_ITEM_SET.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
      IF LT_ITEM_SET IS NOT INITIAL.
***   FOR UPDATING CONDITION RECORDS
        LOOP AT LT_ITEM_SET ASSIGNING <LS_ITEM>.
          CLEAR : LV_MAT_CAT.
          SELECT SINGLE EANNR FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND EANNR = C_UC.
***  EAN Managed material
          IF SY-SUBRC = 0.
            <LS_ITEM>-MAT_CAT = C_E.
          ELSE.
            SELECT SINGLE XCHPF FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND XCHPF = C_X.
***  Batch Managed material
            IF SY-SUBRC = 0.
              <LS_ITEM>-MAT_CAT = C_B.
            ELSE.
              SELECT SINGLE SERNP FROM MARC INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND WERKS = <LS_ITEM>-WERKS AND SERNP IS NOT NULL.
***  Serial Number Managed material
              IF SY-SUBRC = 0.
                <LS_ITEM>-MAT_CAT = C_S.
              ELSE.
***  General Material
                <LS_ITEM>-MAT_CAT = C_G.
              ENDIF.
            ENDIF.
          ENDIF.
          <LS_ITEM>-QR_CODE = WA_HDR-QR_CODE.
        ENDLOOP.
        MODIFY ZINW_T_HDR FROM WA_HDR.
        MODIFY ZINW_T_ITEM FROM TABLE LT_ITEM_SET.
        IF SY-SUBRC = 0.
          IF WA_STATUS IS NOT INITIAL.
            MODIFY ZINW_T_STATUS FROM WA_STATUS.
          ENDIF.
          MESSAGE S002(ZMSG_CLS).
        ENDIF.
      ELSE.
***   FOR UPDATING CONDITION RECORDS
        LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
          CLEAR : LV_MAT_CAT.
          SELECT SINGLE EAN11 FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND NUMTP = C_UC.
***  EAN Managed material
          IF SY-SUBRC = 0.
            <LS_ITEM>-MAT_CAT = C_E.
          ELSE.
            SELECT SINGLE XCHPF FROM MARA INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND XCHPF = C_X.
***  Batch Managed material
            IF SY-SUBRC = 0.
              <LS_ITEM>-MAT_CAT = C_B.
            ELSE.
              SELECT SINGLE SERNP FROM MARC INTO LV_MAT_CAT WHERE MATNR = <LS_ITEM>-MATNR AND WERKS = <LS_ITEM>-WERKS AND SERNP IS NOT NULL.
***  Serial Number Managed material
              IF SY-SUBRC = 0.
                <LS_ITEM>-MAT_CAT = C_S.
              ELSE.
***  General Material
                <LS_ITEM>-MAT_CAT = C_G.
              ENDIF.
            ENDIF.
          ENDIF.
          <LS_ITEM>-QR_CODE = WA_HDR-QR_CODE.
        ENDLOOP.
        MODIFY ZINW_T_HDR FROM WA_HDR.
        MODIFY ZINW_T_ITEM FROM TABLE LT_ITEM.
        IF SY-SUBRC = 0.
          IF WA_STATUS IS NOT INITIAL.
            MODIFY ZINW_T_STATUS FROM WA_STATUS.
          ENDIF.
          MESSAGE S002(ZMSG_CLS).
        ENDIF.
      ENDIF.
    ELSE.
      MODIFY ZINW_T_HDR FROM WA_HDR.
      MODIFY ZINW_T_STATUS FROM LS_STATUS.
*      MODIFY ZINW_T_ITEM FROM TABLE LT_ITEM.
      IF SY-SUBRC = 0.
        MESSAGE S002(ZMSG_CLS).
      ENDIF.
    ENDIF.
**** Printing Form
*    PERFORM TP2_FORM IN PROGRAM ZMM_GRPO_DET_REP USING WA_HDR-QR_CODE.
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
FORM CLEAR .
  CLEAR : P_EBELN, LV_TRNS, P_QR_CODE ,OK_CODE ,WA_HDR.
  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form MODIFY_TC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_PRICE .
** Calling the check_changed_data method to trigger the data_changed  event
  DATA : WL_REFRESH TYPE C VALUE 'X'.
  IF GRID IS BOUND.
    CALL METHOD GRID->CHECK_CHANGED_DATA
      CHANGING
        C_REFRESH = WL_REFRESH.
  ENDIF.
  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
    IF <LS_ITEM>-MENGE_P IS NOT INITIAL.
      IF <LS_ITEM>-MENGE_P LE <LS_ITEM>-OPEN_QTY.
*** Selling Qty
        <LS_ITEM>-MENGE_S = WA_ITEM-MENGE_P.
*** Purchage Rate
        <LS_ITEM>-NETWR_P = WA_ITEM-MENGE_P * WA_ITEM-NETPR_P.
*** Margin
*** Vendor & Material Combination
        SELECT SINGLE KONP~KBETR FROM KONP
               INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
               WHERE A502~LIFNR = WA_HDR-LIFNR
               AND   A502~MATNR = <LS_ITEM>-MATNR.

        IF SY-SUBRC <> 0 OR <LS_ITEM>-MARGN IS INITIAL.
          SELECT SINGLE KONP~KBETR FROM KONP
               INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
               WHERE A502~LIFNR = WA_HDR-LIFNR
               AND   A502~MATNR = <LS_ITEM>-MATNR.
        ENDIF.
***  Selling GST tax code
        <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P.
        <LS_ITEM>-MARGN = <LS_ITEM>-MARGN / 10.
*** Selling Price
        <LS_ITEM>-NETPR_S = ( ( <LS_ITEM>-MARGN * <LS_ITEM>-NETPR_P ) / 100 ) +  ( ( ( <LS_ITEM>-NETPR_GP * <LS_ITEM>-MARGN ) / 100 ) / <LS_ITEM>-MENGE_S  ) + <LS_ITEM>-NETPR_P.
***  Selling Amount
        <LS_ITEM>-NETWR_S =  <LS_ITEM>-MENGE_S * <LS_ITEM>-NETPR_S.
*** Selling Price GST
        READ TABLE LT_MARC ASSIGNING FIELD-SYMBOL(<LS_MARC>) WITH KEY MATNR = <LS_ITEM>-MATNR.
***  HSN Code
        IF SY-SUBRC = 0.
          <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P = <LS_MARC>-STEUC.
          READ TABLE LT_900 ASSIGNING FIELD-SYMBOL(<LS_900>) WITH KEY STEUC = <LS_MARC>-STEUC.
          IF SY-SUBRC = 0.
            DATA(LV_TAX) = <LS_900>-KBETR / 5 .
            <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TAX + 100 ) ) * LV_TAX .
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE E004(ZMSG_CLS).
      ENDIF.
    ENDIF.
*** Updating Totals
    CLEAR : WA_HDR-TOTAL, WA_HDR-PUR_TOTAL,WA_HDR-NET_AMT,WA_HDR-T_GST,WA_HDR-GRC_PFR.
    ADD <LS_ITEM>-NETWR_S  TO WA_HDR-TOTAL.
    ADD <LS_ITEM>-NETWR_P  TO WA_HDR-PUR_TOTAL.
    ADD <LS_ITEM>-NETPR_GP TO WA_HDR-PUR_TOTAL.
    ADD <LS_ITEM>-NETPR_GS TO WA_HDR-T_GST.
    WA_HDR-NET_AMT = WA_HDR-PUR_TOTAL.
  ENDLOOP.
  WA_HDR-GRC_PFR =  WA_HDR-TOTAL - WA_HDR-NET_AMT.
  IF GRID IS BOUND.
*    CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
    DATA: IS_STABLE TYPE LVC_S_STBL.
    IS_STABLE = 'XX'.
    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = IS_STABLE
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
*     Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MODE
*&---------------------------------------------------------------------*
FORM DISPLAY_MODE.
  IF WA_HDR-STATUS = '07' OR WA_HDR-STATUS = '06' OR  WA_HDR-STATUS = '05'.
    CASE WA_HDR-STATUS.
      WHEN '07'.
*** Payment Done
        LOOP AT SCREEN.
          IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR
            SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D'.
            CONTINUE.
          ELSE.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      WHEN '06'.
*** Invoice Done
        LOOP AT SCREEN.
          IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR
            SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D' OR SCREEN-NAME = 'B_PAYMENT'.
            CONTINUE.
          ELSE.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      WHEN '05'.
*** DOC COMPLITED
        CASE WA_APPROVE-APP_STATUS.
          WHEN 'L2'.
            LOOP AT SCREEN.
              IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR
                SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D' OR SCREEN-NAME = 'B_APPROVE_1'.
                CONTINUE.
              ELSE.
                SCREEN-INPUT = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
          WHEN 'L3'.
            LOOP AT SCREEN.
              IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR
                SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D' OR SCREEN-NAME = 'B_APPROVE_2'.
                CONTINUE.
              ELSE.
                SCREEN-INPUT = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
          WHEN SPACE.
            LOOP AT SCREEN.
              IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR
                SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D' OR SCREEN-NAME = 'B_APPROVE_3'.
                CONTINUE.
              ELSE.
                SCREEN-INPUT = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
        ENDCASE.

    ENDCASE.
  ELSE.
    IF LV_MOD = C_D AND ( P_EBELN IS NOT INITIAL OR P_QR_CODE IS NOT INITIAL ) .
***  Display Mode with PO or QR Code
      LOOP AT SCREEN.
        IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D'.
          CONTINUE.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
*** Edit Mode & QR as input
    ELSEIF LV_MOD  = 'E' AND P_EBELN IS NOT INITIAL AND P_QR_CODE IS NOT INITIAL.
      LOOP AT SCREEN.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
        IF LV_BSART = C_ZLOP OR LV_BSART = C_ZTAT.
          IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR SCREEN-NAME = 'B_CLOSE' OR
            SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'P_EBELN' OR SCREEN-NAME = 'P_QR_CODE' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
          IF SCREEN-NAME = 'B_DISP' OR SCREEN-NAME = 'B_EDIT' OR SCREEN-NAME = 'B_PRINT' OR SCREEN-NAME = 'B_CLEAR' OR SCREEN-NAME = 'P_EBELN' OR SCREEN-NAME = 'P_QR_CODE' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          ELSEIF WA_HDR-STATUS = '04' AND WA_HDR-SOE IS INITIAL.
            IF SCREEN-NAME = 'B_SHORTAGE' OR SCREEN-NAME = 'B_EXCESS' OR SCREEN-NAME = 'B_MATCHED' .
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF WA_HDR-STATUS = '04' AND WA_HDR-SOE = '03'.
            IF SCREEN-NAME = 'B_SHORTAGE' OR SCREEN-NAME = 'B_CLOSE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF WA_HDR-STATUS = '04' AND WA_HDR-SOE = '02'.
            IF SCREEN-NAME = 'B_EXCESS' OR SCREEN-NAME = 'B_CLOSE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF WA_HDR-STATUS = '04' AND WA_HDR-SOE IS NOT INITIAL.
            IF SCREEN-NAME = 'B_CLOSE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.
*      IF SCREEN-NAME = 'WA_HDR-SOE' AND WA_HDR-STATUS > '02' AND WA_HDR-SOE IS INITIAL.
*        SCREEN-INPUT = 1.
*        MODIFY SCREEN.
*      ELSE.
*        SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*      ENDIF.
      ENDLOOP.
*** Edit Mode with only PO as inputed
    ELSEIF LV_MOD  = 'E' AND P_EBELN IS NOT INITIAL AND P_QR_CODE IS INITIAL.

      LOOP AT SCREEN.
*** Unble Shortage or Excess edit before GRPO
*      IF SCREEN-NAME = 'WA_HDR-SOE' AND WA_HDR-STATUS < '03'." AND WA_HDR-SOE IS INITIAL.
*        SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*      ENDIF.

***  Disabling Excess / Shortage / Matched Buttons
        IF SCREEN-NAME = 'B_SHORTAGE' OR SCREEN-NAME = 'B_EXCESS' OR SCREEN-NAME = 'B_MATCHED' OR
          SCREEN-NAME = 'B_CLOSE' OR SCREEN-NAME = 'B_DEBIT_D' OR SCREEN-NAME = 'B_TAT_D' OR
          SCREEN-NAME = 'B_APPROVE_1' OR SCREEN-NAME = 'B_APPROVE_2' OR SCREEN-NAME = 'B_APPROVE_3' OR SCREEN-NAME = 'B_PAYMENT' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
***   For Tatkal PO Transporter , Number of Bundles and LR number in display mode
        IF LV_BSART = C_ZTAT.
          IF SCREEN-NAME = 'WA_HDR-TRNS' OR SCREEN-NAME = 'WA_HDR-ACT_NO_BUD' OR SCREEN-NAME = 'WA_HDR-LR_NO'.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_PO_QTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_PO_QTY .
  IF LT_ITEM IS NOT INITIAL.
    IF WA_ITEM-MENGE_P IS INITIAL.
      MESSAGE 'Enter PO' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.
*** Totals
*FORM UPDATE_TOTALS.
*  CLEAR : WA_HDR-TOTAL, WA_HDR-PUR_TOTAL,WA_HDR-NET_AMT,WA_HDR-T_GST,WA_HDR-GRC_PFR.
*  LOOP AT LT_ITEM INTO WA_ITEM.
*    ADD WA_ITEM-NETWR_S  TO WA_HDR-TOTAL.
*    ADD WA_ITEM-NETWR_P  TO WA_HDR-PUR_TOTAL.
*    ADD WA_ITEM-NETPR_GP TO WA_HDR-PUR_TOTAL.
*    ADD WA_ITEM-NETPR_GS TO WA_HDR-T_GST.
*    WA_HDR-NET_AMT = WA_HDR-PUR_TOTAL.
*  ENDLOOP.
*  WA_HDR-GRC_PFR =  WA_HDR-TOTAL - WA_HDR-NET_AMT.
*ENDFORM.

***** Comdition Record Uplaod - VK11
*FORM MATERIAL_CAT_UPDATE.
*  DATA : LV_MAT_CAT TYPE CHAR10.
*
*  LOOP AT LT_ITEM INTO WA_ITEM.
*    SELECT SINGLE XCHPF FROM MARA INTO LV_MAT_CAT WHERE MATNR = WA_ITEM-MATNR AND XCHPF = C_X.
*    IF SY-SUBRC = 0.
****  Batch Managed material
*      DATA(I_TYPE) = 'B'.
*      PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*    ELSE.
*      SELECT SINGLE SERNP FROM MARC INTO LV_MAT_CAT WHERE MATNR = WA_ITEM-MATNR AND WERKS = WA_ITEM-WERKS AND SERNP IS NOT NULL.
*      IF SY-SUBRC = 0.
****  Serial Number Managed material
*        I_TYPE = 'S'.
*        PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*      ELSE.
*        SELECT SINGLE EANNR FROM MARA INTO LV_MAT_CAT WHERE MATNR = WA_ITEM-MATNR AND EANNR = C_UC.
*        IF SY-SUBRC = 0.
****  EAN Managed material
*          I_TYPE = C_E.
*          PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*        ELSE.
****  General Material
*          I_TYPE = 'G'.
*          PERFORM UPLOAD_CONDTION_RECORD USING I_TYPE.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.
**&---------------------------------------------------------------------*
*& Form UPLOAD_CONDTION_RECORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_TYPE
*&---------------------------------------------------------------------*
*FORM UPLOAD_CONDTION_RECORD USING P_I_TYPE.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FCAT.
***  Displaying date in ALV Grid
  IF LT_FIELDCAT IS INITIAL.
*** Group Code
    LS_FIELDCAT-FIELDNAME   = 'MATKL'.
    LS_FIELDCAT-REPTEXT     = 'Category Code'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.
*** SST CODE
    LS_FIELDCAT-FIELDNAME   = 'MATNR'.
    LS_FIELDCAT-REPTEXT     = 'SST Code'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Product Description
    LS_FIELDCAT-FIELDNAME   = 'MAKTX'.
    LS_FIELDCAT-REPTEXT     = 'Product Description'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** OPEN_QTY
    LS_FIELDCAT-FIELDNAME   = 'OPEN_QTY'.
    LS_FIELDCAT-REPTEXT     = 'Open Qty'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    LS_FIELDCAT-DECIMALS_O   = '2'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Pur.Qty
    LS_FIELDCAT-FIELDNAME   = 'MENGE_P'.
    LS_FIELDCAT-REPTEXT     = 'Pur.Qty'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-REF_TABLE   = 'ZINW_T_ITEM'.
    LS_FIELDCAT-DATATYPE   = 'QUAN'.

    IF LV_MOD = 'E'.
      LS_FIELDCAT-EDIT   = 'X'.
    ELSEIF LV_MOD = 'D'.
      CLEAR : LS_FIELDCAT-EDIT.
    ENDIF.

    LS_FIELDCAT-NO_ZERO   = 'X'.
    LS_FIELDCAT-DATATYPE  = 'INT4'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Pur.UoM
    LS_FIELDCAT-FIELDNAME   = 'MEINS'.
    LS_FIELDCAT-REPTEXT     = 'Pur.UoM'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** EAN Number
    LS_FIELDCAT-FIELDNAME   = 'EAN11'.
    LS_FIELDCAT-REPTEXT     = 'EAN NO'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Pur Rate
    LS_FIELDCAT-FIELDNAME   = 'NETPR_P'.
    LS_FIELDCAT-REPTEXT     = 'Pur Rate'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Pur.GST Code
    LS_FIELDCAT-FIELDNAME   = 'MWSKZ_P'.
    LS_FIELDCAT-REPTEXT     = 'Pur.GST Code'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Pur.GST Value
    LS_FIELDCAT-FIELDNAME   = 'NETPR_GP'.
    LS_FIELDCAT-REPTEXT     = 'Pur.GST Value'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Pur Amount
    LS_FIELDCAT-FIELDNAME   = 'NETWR_P'.
    LS_FIELDCAT-REPTEXT     = 'Pur Amount'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Margin
    LS_FIELDCAT-FIELDNAME   = 'MARGN'.
    LS_FIELDCAT-REPTEXT     = 'Margin'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Discount
    LS_FIELDCAT-FIELDNAME   = 'DISCOUNT'.
    LS_FIELDCAT-REPTEXT     = 'Discount'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Selling Rate
    LS_FIELDCAT-FIELDNAME   = 'MENGE_S'.
    LS_FIELDCAT-REPTEXT     = 'Selling Qty'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    LS_FIELDCAT-DECIMALS_O   = '2'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Selling Rate
    LS_FIELDCAT-FIELDNAME   = 'NETPR_S'.
    LS_FIELDCAT-REPTEXT     = 'Selling Rate'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Sel GST Code
    LS_FIELDCAT-FIELDNAME   = 'MWSKZ_S'.
    LS_FIELDCAT-REPTEXT     = 'Sel GST Code'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Sel GST Value
    LS_FIELDCAT-FIELDNAME   = 'NETPR_GS'.
    LS_FIELDCAT-REPTEXT     = 'Sel GST Value'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.

*** Selling Amount
    LS_FIELDCAT-FIELDNAME   = 'NETWR_S'.
    LS_FIELDCAT-REPTEXT     = 'Selling Amount'.
    LS_FIELDCAT-COL_OPT     = 'X'.
    LS_FIELDCAT-TXT_FIELD   = 'X'.
    LS_FIELDCAT-NO_ZERO   = 'X'.
    APPEND LS_FIELDCAT TO LT_FIELDCAT.
    CLEAR LS_FIELDCAT.
  ELSE.
    READ TABLE LT_FIELDCAT ASSIGNING FIELD-SYMBOL(<LS_FIELDCAT>) WITH KEY FIELDNAME   = 'MENGE_P'.
    IF SY-SUBRC  = 0.
      IF LV_MOD = 'E'.
        IF  WA_HDR-QR_CODE IS NOT INITIAL.
          CLEAR : <LS_FIELDCAT>-EDIT.
        ELSE.
          <LS_FIELDCAT>-EDIT   = 'X'.
        ENDIF.
      ELSEIF LV_MOD = 'D'.
        CLEAR : <LS_FIELDCAT>-EDIT.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
FORM DISPLAY_DATA .

  IF CUSTOM_CONTAINER IS INITIAL .
    CREATE OBJECT CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME = MYCONTAINER.
    CREATE OBJECT GRID
      EXPORTING
        I_PARENT = CUSTOM_CONTAINER.
  ENDIF.
*** CREATE OBJECT event_receiver.
  IF LR_EVENT IS NOT BOUND.
    CREATE OBJECT LR_EVENT.
***---setting event handlers
*    SET HANDLER LR_EVENT->HANDLE_USER_COMMAND  FOR GRID.
  ENDIF.

  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = LS_LAYOUT
      IT_TOOLBAR_EXCLUDING          = LT_TLBR_EXCL  " Excluded Toolbar Standard Functions
    CHANGING
      IT_OUTTAB                     = LT_ITEM
      IT_FIELDCATALOG               = LT_FIELDCAT
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*** input
  CALL METHOD GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.
***  Registering the EDIT Event
  CALL METHOD GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  SET HANDLER LR_EVENT->HANDLE_DATA_CHANGED FOR GRID.
*  SET HANDLER LR_EVENT->HANDLE_HOTSPOT_CLICK FOR GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_ICONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_ICONS .
  IF LT_TLBR_EXCL IS NOT INITIAL.
    RETURN.
  ENDIF.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO LT_TLBR_EXCL.
  CLEAR : LS_EXCLUDE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> T_DATA
*&---------------------------------------------------------------------*
*FORM CHECK_DATA  USING    P_ER_DATA_CHANGED
*                          P_T_DATA.
*  data: ls_good type lvc_s_modi.
*  BREAK-POINT.
* loop at P_ER_DATA_CHANGED->mt_good_cells into ls_good.
* ENDLOOP.
*  LOOP AT LT_ITEM ASSIGNING <LS_ITEM>.
*    IF <LS_ITEM>-MENGE_P IS NOT INITIAL.
*      IF <LS_ITEM>-MENGE_P LE <LS_ITEM>-OPEN_QTY.
**** Selling Qty
*        <LS_ITEM>-MENGE_S = WA_ITEM-MENGE_P.
**** Purchage Rate
*        <LS_ITEM>-NETWR_P = WA_ITEM-MENGE_P * WA_ITEM-NETPR_P.
**** Margin
**** Vendor & Material Combination
*        SELECT SINGLE KONP~KBETR FROM KONP
*               INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
*               WHERE A502~LIFNR = WA_HDR-LIFNR
*               AND   A502~MATNR = <LS_ITEM>-MATNR.
*
*        IF SY-SUBRC <> 0 OR <LS_ITEM>-MARGN IS INITIAL.
*          SELECT SINGLE KONP~KBETR FROM KONP
*               INNER JOIN A502 ON KONP~KNUMH = A502~KNUMH INTO <LS_ITEM>-MARGN
*               WHERE A502~LIFNR = WA_HDR-LIFNR
*               AND   A502~MATNR = <LS_ITEM>-MATNR.
*        ENDIF.
****  Selling GST tax code
*        <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P.
*        <LS_ITEM>-MARGN = <LS_ITEM>-MARGN / 10.
**** Selling Price
*        <LS_ITEM>-NETPR_S = ( ( <LS_ITEM>-MARGN * <LS_ITEM>-NETPR_P ) / 100 ) +  ( ( ( <LS_ITEM>-NETPR_GP * <LS_ITEM>-MARGN ) / 100 ) / <LS_ITEM>-MENGE_S  ) + <LS_ITEM>-NETPR_P.
****  Selling Amount
*        <LS_ITEM>-NETWR_S =  <LS_ITEM>-MENGE_S * <LS_ITEM>-NETPR_S.
**** Selling Price GST
*        READ TABLE LT_MARC ASSIGNING FIELD-SYMBOL(<LS_MARC>) WITH KEY MATNR = <LS_ITEM>-MATNR.
****  HSN Code
*        IF SY-SUBRC = 0.
*          <LS_ITEM>-MWSKZ_S = <LS_ITEM>-MWSKZ_P = <LS_MARC>-STEUC.
*          READ TABLE LT_900 ASSIGNING FIELD-SYMBOL(<LS_900>) WITH KEY STEUC = <LS_MARC>-STEUC.
*          IF SY-SUBRC = 0.
*            DATA(LV_TAX) = <LS_900>-KBETR / 5 .
*            <LS_ITEM>-NETPR_GS = ( <LS_ITEM>-NETWR_S / ( LV_TAX + 100 ) ) * LV_TAX .
*          ENDIF.
*        ENDIF.
*      ELSE.
*        MESSAGE 'Entered PO Quantity greater than Open PO Quantity' TYPE C_E.
*      ENDIF.
*    ENDIF.
**** Updating Totals
*    CLEAR : WA_HDR-TOTAL, WA_HDR-PUR_TOTAL,WA_HDR-NET_AMT,WA_HDR-T_GST,WA_HDR-GRC_PFR.
*    ADD <LS_ITEM>-NETWR_S  TO WA_HDR-TOTAL.
*    ADD <LS_ITEM>-NETWR_P  TO WA_HDR-PUR_TOTAL.
*    ADD <LS_ITEM>-NETPR_GP TO WA_HDR-PUR_TOTAL.
*    ADD <LS_ITEM>-NETPR_GS TO WA_HDR-T_GST.
*    WA_HDR-NET_AMT = WA_HDR-PUR_TOTAL.
*  ENDLOOP.
*  WA_HDR-GRC_PFR =  WA_HDR-TOTAL - WA_HDR-NET_AMT.
*  IF GRID IS BOUND.
*    CALL METHOD GRID->REFRESH_TABLE_DISPLAY.
*  ENDIF.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_QR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_QR .
  IF P_QR_CODE IS NOT INITIAL.
    SELECT SINGLE QR_CODE FROM ZINW_T_HDR INTO @DATA(LV_QR) WHERE QR_CODE = @P_QR_CODE.
    IF SY-SUBRC  <> 0.
      MESSAGE E024(ZMSG_CLS).
    ENDIF.
  ELSEIF P_EBELN IS INITIAL.
    MESSAGE E001(ZMSG_CLS).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_HEADER.
  CHECK SY-UCOMM <> C_CLEAR.
  CHECK P_QR_CODE IS INITIAL.
***     DOC TYPE CHECKING
  CHECK LV_BSART <> C_ZLOP.
*** Billing Date should not be fucture
  IF WA_HDR-BILL_DATE GT SY-DATUM.
    MESSAGE E016(ZMSG_CLS).
  ENDIF.
*** For Tatkal PO
  IF LV_BSART = C_ZTAT.
*** VALIDATION ON PO AMOUNT MORE THEN 3000.
*    SELECT SUM( NETWR ) FROM EKPO INTO @DATA(LV_PO_AMOUNT) WHERE EBELN = @P_EBELN.
*    IF LV_PO_AMOUNT > C_3000 AND WA_EKKO-FRGKE = 'B'.
    IF WA_EKKO-FRGKE = 'B'.
      MESSAGE E052(ZMSG_CLS) WITH P_EBELN.
    ENDIF.
*** For Fetching Same Transported & LR Number
    SELECT SINGLE * FROM ZINW_T_HDR INTO @DATA(LS_HDR) WHERE  TAT_PO = @P_EBELN.
    IF LS_HDR IS NOT INITIAL.
      WA_HDR-TRNS = LS_HDR-TRNS.
      WA_HDR-LR_NO = LS_HDR-LR_NO.
      SELECT SINGLE NAME1 FROM LFA1 INTO LV_TRNS WHERE LIFNR = WA_HDR-TRNS.
      IF SY-SUBRC <> 0.
        MESSAGE E021(ZMSG_CLS) WITH WA_HDR-TRNS.
      ENDIF.
    ENDIF.
  ELSE.
***   For Out Station PO
    IF WA_HDR-TRNS IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = WA_HDR-TRNS
        IMPORTING
          OUTPUT = WA_HDR-TRNS.

      SELECT SINGLE NAME1 FROM LFA1 INTO LV_TRNS WHERE LIFNR = WA_HDR-TRNS.
      IF SY-SUBRC <> 0.
        MESSAGE E021(ZMSG_CLS) WITH WA_HDR-TRNS.
      ENDIF.
    ENDIF.
    IF WA_HDR-LR_NO IS NOT INITIAL.
*** Checking For LR numebr and Transporter exist for this Vendor
      SELECT SINGLE  QR_CODE INTO @DATA(LV_QR) FROM ZINW_T_HDR WHERE LIFNR = @WA_HDR-LIFNR AND LR_NO = @WA_HDR-LR_NO AND TRNS = @WA_HDR-TRNS.
      IF  SY-SUBRC = 0.
        MESSAGE E017(ZMSG_CLS) WITH WA_HDR-LIFNR.
      ENDIF.
    ENDIF.

*  IF WA_HDR-FRT_NO IS NOT INITIAL.
**** Checking For LR numebr and Transporter exist for this Vendor
*    SELECT SINGLE  QR_CODE INTO LV_QR FROM ZINW_T_HDR WHERE LIFNR = WA_HDR-LIFNR AND FRT_NO = WA_HDR-FRT_NO.
*    IF  SY-SUBRC = 0.
*      MESSAGE E018(ZMSG_CLS) WITH WA_HDR-LIFNR.
*    ENDIF.
*  ENDIF.

  ENDIF.
  IF WA_HDR-BILL_NUM IS NOT INITIAL.
*** Checking For Bill numebr exist for this Vendor
    SELECT SINGLE  QR_CODE INTO LV_QR FROM ZINW_T_HDR WHERE LIFNR = WA_HDR-LIFNR AND BILL_NUM = WA_HDR-BILL_NUM.
    IF  SY-SUBRC = 0.
      MESSAGE E019(ZMSG_CLS) WITH WA_HDR-LIFNR.
    ENDIF.
  ENDIF.

***  Bill Date Validation
  IF WA_HDR-BILL_DATE IS NOT INITIAL.
    IF WA_HDR-BILL_DATE GT SY-DATUM.
      MESSAGE E027(ZMSG_CLS) WITH WA_HDR-BILL_DATE.
    ELSEIF WA_HDR-BILL_DATE LT WA_EKKO-AEDAT.
      MESSAGE E032(ZMSG_CLS) WITH WA_HDR-BILL_DATE WA_EKKO-AEDAT.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_TRANS .
  DATA: LT_VALUES TYPE TABLE OF VRM_VALUE.

  SELECT LIFNR , NAME1 INTO TABLE @DATA(LT_TRNS) FROM LFA1 WHERE KTOKK = 'KRED'.
  IF LT_TRNS IS NOT INITIAL.
    REFRESH LT_VALUES.
    LOOP AT LT_TRNS ASSIGNING FIELD-SYMBOL(<LS_TRNS>).
      APPEND VALUE #( KEY = <LS_TRNS>-LIFNR TEXT = <LS_TRNS>-NAME1 ) TO LT_VALUES.
    ENDLOOP.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID              = 'WA_HDR-TRNS'
        VALUES          = LT_VALUES
      EXCEPTIONS
        ID_ILLEGAL_NAME = 1
        OTHERS          = 2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLEAR_ALL.
  IF OK_CODE = C_CLEAR.
    CLEAR : P_EBELN, P_QR_CODE,LV_MOD, WA_HDR, LV_TRNS, LV_STATUS,LV_ERROR , LV_TAX_%,LV_TAX_CAT, LV_SOE_DES , LV_PROF%, LV_GR_DATE.
    REFRESH : LT_ITEM, LT_EKPO.
    CLEAR : OK_CODE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_STATUS.
  WA_HDR-SOE = C_01.
*** Status Update
  LS_STATUS-INWD_DOC     = WA_HDR-INWD_DOC.
  LS_STATUS-QR_CODE      = WA_HDR-QR_CODE.
  LS_STATUS-STATUS_FIELD = C_ES_CODE.
  LS_STATUS-CREATED_BY   = SY-UNAME.
  LS_STATUS-CREATED_DATE = SY-DATUM.
  LS_STATUS-CREATED_TIME = SY-UZEIT.
  LS_STATUS-STATUS_VALUE = C_ES01.
  LS_STATUS-DESCRIPTION  = 'Matched'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_TATKAL_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_TATKAL_PO.
  SET PARAMETER ID 'ZQR' FIELD WA_HDR-QR_CODE.
  LEAVE TO TRANSACTION 'ZTAT_PO' AND SKIP FIRST SCREEN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPLITE_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM COMPLITE_DOC.
  DATA : I_ANSWER TYPE CHAR10.
  DATA : WA_STATUS TYPE ZINW_T_STATUS.
  SELECT SINGLE ID
  FROM ICON
  INTO @DATA(LV_ID)
  WHERE NAME = 'ICON_MESSAGE_WARNING'.
  CONCATENATE LV_ID 'Once the QR code document completed you can not do further' INTO DATA(LV_TXT) SEPARATED BY SPACE.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      DEFAULTOPTION = 'N'
      TEXTLINE1     = LV_TXT
      TEXTLINE2     = 'changes Click OK to Continue'
      TITEL         = 'Confirmation'
    IMPORTING
      ANSWER        = I_ANSWER.

  IF I_ANSWER = 'J'.
    WA_HDR-UNAME    = SY-UNAME.
    WA_HDR-UDATE    = SY-DATUM.
    WA_HDR-UTIME    = SY-UZEIT.
    WA_HDR-STATUS   = C_05.
    LV_STATUS = 'QR Code Completed'.
    LV_MOD = C_D.
    MODIFY ZINW_T_HDR FROM WA_HDR.
*** For Updating Status Table
    WA_STATUS-QR_CODE      = WA_HDR-QR_CODE.
    WA_STATUS-INWD_DOC     = WA_HDR-INWD_DOC.
    WA_STATUS-STATUS_FIELD = C_QR_CODE.
    WA_STATUS-STATUS_VALUE = C_QR05.
    WA_STATUS-DESCRIPTION  = 'QR Code Completed'.
    WA_STATUS-CREATED_BY   = SY-UNAME.
    WA_STATUS-CREATED_DATE = SY-DATUM.
    WA_STATUS-CREATED_TIME = SY-UZEIT.
    MODIFY ZINW_T_STATUS FROM WA_STATUS.
    MESSAGE S002(ZMSG_CLS).

*** Return PO / Debit Note Mail
    IF WA_HDR-RETURN_PO IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          LV_EBELN  = WA_HDR-RETURN_PO
          RETURN_PO = 'X'.
    ENDIF.

*** RETURN PO / DEBIT NOTE MAIL
    IF WA_HDR-RETURN_PO IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          LV_EBELN  = WA_HDR-TAT_PO       " Purchasing Document Number
          TATKAL_PO = 'X'.            " Purchasing Document Number
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_INVOCIE_APPROVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_INVOCIE_APPROVE USING P_L P_DES.
  WA_APPROVE-MANDT      = SY-MANDT.
  WA_APPROVE-APP_STATUS = P_L.
  WA_APPROVE-QR_CODE    = WA_HDR-QR_CODE.
  MODIFY ZINVOICE_T_APP FROM WA_APPROVE.
  MESSAGE S055(ZMSG_CLS) WITH  P_DES.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_TOTALS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_TOTALS.
  WA_HDR-NET_AMT  = LV_NET_PAY = WA_HDR-PUR_TOTAL + WA_HDR-PUR_TAX + WA_HDR-PACKING_CHARGE - WA_HDR-DISCOUNT.
  LV_NET_SELLING  = WA_HDR-TOTAL - WA_HDR-T_GST.
  WA_HDR-GRC_PFR  =  LV_NET_SELLING - LV_NET_PAY.
  IF WA_HDR-PUR_TOTAL IS NOT INITIAL.
    LV_PROF%      = ( WA_HDR-GRC_PFR * 100 ) / LV_NET_PAY.
  ENDIF.
ENDFORM.
