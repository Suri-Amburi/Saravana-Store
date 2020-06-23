**&---------------------------------------------------------------------*
**& Include          ZMM_PURCHASE_RETURN_FORM
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Form GET_DATA
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*
*FORM GET_DATA .
**  BREAK BREDDY.
*  SELECT SINGLE
*    EBELN
*    BSART
*    AEDAT
*    LIFNR
*    BEDAT
*    KNUMV
*     FROM EKKO INTO WA_EKKO WHERE EBELN = P_EBELN.
*
*  SELECT
*    EBELN
*    EBELP
*    WERKS
*    MATNR
*    MWSKZ
*    MENGE
*    NETPR
*    PEINH
*    NETWR
*    BUKRS
*    RETPO
*    FROM EKPO INTO TABLE IT_EKPO WHERE EBELN = P_EBELN AND RETPO = 'X'.
*
*  READ TABLE IT_EKPO INTO WA_EKPO INDEX 1.
*
*  SELECT SINGLE
*    EBELN
*    MBLNR
*    FROM MSEG INTO WA_MSEG WHERE EBELN = P_EBELN.
*
*  IF WA_MSEG IS NOT INITIAL.
*
*    SELECT SINGLE
*      MBLNR
*      BLDAT
*      FROM MKPF INTO WA_MKPF WHERE MBLNR = WA_MSEG-MBLNR.
*
*  ENDIF.
*  IF IT_EKPO IS NOT INITIAL.
*
*    SELECT QR_CODE EBELN MATNR WERKS MWSKZ_P NETPR_GP FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
*                                                                FOR ALL ENTRIES IN IT_EKPO
*                                                                WHERE MATNR = IT_EKPO-MATNR AND WERKS = IT_EKPO-WERKS.
*
*  ENDIF.
*  READ TABLE IT_ZINW_T_ITEM INTO WA_ITEM INDEX 1.
*  IF WA_ITEM IS NOT INITIAL.
*
*    SELECT SINGLE
*      QR_CODE
*      EBELN
*      TRNS
*      LR_NO
*      BILL_NUM
*      BILL_DATE
*      ACT_NO_BUD
**      GPRO_USER
*      MBLNR
*      MBLNR_103
*      RETURN_PO
*      FROM ZINW_T_HDR INTO WA_ZINW_T_HDR WHERE QR_CODE = WA_ITEM-QR_CODE AND RETURN_PO = WA_ITEM-EBELN.
*  ENDIF.
*
*  IF WA_ZINW_T_HDR IS NOT INITIAL.
*
*    SELECT SINGLE
*    EBELN
*    BSART
*    AEDAT
*    LIFNR
*    BEDAT
*    KNUMV
*     FROM EKKO INTO WA_EKKO1 WHERE EBELN = WA_ZINW_T_HDR-EBELN.
*
*    SELECT SINGLE
*      INWD_DOC
*      QR_CODE
*      STATUS_FIELD
*      STATUS_VALUE
*      DESCRIPTION
*      CREATED_DATE
*      CREATED_TIME
*      CREATED_BY FROM ZINW_T_STATUS INTO WA_ZINW_T_STATUS WHERE QR_CODE = WA_ZINW_T_HDR-QR_CODE .
*
*
*  ENDIF.
*
*
*
*  IF WA_EKPO IS NOT INITIAL.
*    SELECT SINGLE
*        BUKRS
*        GSTIN
*        FROM J_1BBRANCH INTO WA_J_1BBRANCH WHERE BUKRS = WA_EKPO-BUKRS.
*
*    SELECT SINGLE
*      WERKS
*      NAME1
*      STRAS
*      ORT01
*      LAND1
*      ADRNR
*      FROM T001W INTO WA_T001W WHERE WERKS = WA_EKPO-WERKS.
*
*    SELECT
*  MATNR
*  SPRAS
*  MAKTX
*  FROM MAKT INTO TABLE IT_MAKT FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-MATNR.
*  ENDIF.
*
*  IF WA_T001W IS NOT INITIAL.
*    SELECT SINGLE
*      ADRC~ADDRNUMBER,
*      ADRC~NAME1,
*      ADRC~CITY1,
*      ADRC~STREET,
*      ADRC~STR_SUPPL1,
*      ADRC~STR_SUPPL2,
*      ADRC~COUNTRY,
*      ADRC~LANGU,
*      ADRC~REGION,
*      ADRC~POST_CODE1
*      FROM ADRC INTO @WA_ADRC WHERE ADDRNUMBER = @WA_T001W-ADRNR.
*
*
*
*    SELECT SINGLE
*      ADDRNUMBER
*      SMTP_ADDR
*      FROM ADR6 INTO WA_ADR6 WHERE ADDRNUMBER = WA_T001W-ADRNR.
*
*    SELECT SINGLE
*      ADRNR
*      NAME1
*      SORTL
*      FROM KNA1 INTO WA_KNA1 WHERE ADRNR = WA_T001W-ADRNR.
*  ENDIF.
*
*
*  IF WA_ADRC IS NOT INITIAL.
*
*    SELECT SINGLE SPRAS
*           LAND1
*           BLAND
*           BEZEI FROM T005U INTO WA_T005U WHERE BLAND = WA_ADRC-REGION AND LAND1 = WA_ADRC-COUNTRY AND SPRAS = SY-LANGU.
*    SELECT SINGLE
*           SPRAS
*           LAND1
*           LANDX FROM T005T INTO WA_T005T WHERE LAND1 = WA_ADRC-COUNTRY AND SPRAS = SY-LANGU.
*
*
*  ENDIF.
*
*
*  IF WA_EKKO IS NOT INITIAL.
*
*    SELECT SINGLE
*     LIFNR
*     LAND1
*     NAME1
*     ORT01
*     REGIO
*     STRAS
*     STCD3
*     ADRNR
*     FROM LFA1 INTO WA_LFA1 WHERE LIFNR = WA_EKKO-LIFNR.
*
*    SELECT SINGLE
*            EBELN
*            VGABE
*            BELNR
*            BUDAT FROM EKBE INTO WA_EKBE WHERE EBELN = WA_EKKO-EBELN AND VGABE = '2'.
*
*
*  ENDIF.
*
*  SELECT
*    KNUMV
*    KPOSN
*    STUNR
*    ZAEHK
*    KSCHL
*    FROM KONV INTO TABLE IT_KONV FOR ALL ENTRIES IN IT_EKKO WHERE KNUMV = IT_EKKO-KNUMV.
*
*  IF WA_LFA1 IS NOT INITIAL.
*
*    SELECT SINGLE
*    ADRC~ADDRNUMBER,
*    ADRC~NAME1,
*    ADRC~CITY1,
*    ADRC~STREET,
*    ADRC~STR_SUPPL1,
*    ADRC~STR_SUPPL2,
*    ADRC~COUNTRY,
*    ADRC~LANGU,
*    ADRC~REGION,
*    ADRC~POST_CODE1
*    FROM ADRC INTO @WA_ADRC1 WHERE ADDRNUMBER = @WA_LFA1-ADRNR.
*
*  ENDIF.
*
*  IF WA_ADRC1 IS NOT INITIAL.
*
*    SELECT SINGLE SPRAS
*           LAND1
*           BLAND
*           BEZEI FROM T005U INTO WA_T005U1 WHERE BLAND = WA_ADRC1-REGION AND LAND1 = WA_ADRC1-COUNTRY AND SPRAS = SY-LANGU.
*    SELECT SINGLE
*           SPRAS
*           LAND1
*           LANDX FROM T005T INTO WA_T005T1 WHERE LAND1 = WA_ADRC1-COUNTRY AND SPRAS = SY-LANGU.
*
*
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form GET_TABLEDATA
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM GET_TABLEDATA .
*  WA_HEADER-CITY1        = WA_ADRC-CITY1.
*  WA_HEADER-STREET       = WA_ADRC-STREET.
*  WA_HEADER-STR_SUPPL1   = WA_ADRC-STR_SUPPL1.
*  WA_HEADER-STR_SUPPL2   = WA_ADRC-STR_SUPPL2.
*  WA_HEADER-POST_CODE1   = WA_ADRC-POST_CODE1.
*  WA_HEADER-BEZEI        = WA_T005U-BEZEI.
*  WA_HEADER-LANDX        = WA_T005T-LANDX.
*  IF WA_EKKO1-BSART = 'ZOSP'.
*    WA_HEADER-MBLNR       = WA_ZINW_T_HDR-MBLNR.
**    WA_HEADER-GPRO_USER      = WA_ZINW_T_HDR-GPRO_USER.
*
*  ELSEIF WA_EKKO1-BSART = 'ZLOP'.
*    WA_HEADER-MBLNR_103       = WA_ZINW_T_HDR-MBLNR_103.
**    WA_HEADER-GPRO_USER      = WA_ZINW_T_HDR-GPRO_USER.
*  ENDIF.
*
*  WA_HEADER-GPRO_USER = WA_ZINW_T_STATUS-CREATED_BY.
*  LOOP AT IT_EKPO INTO WA_EKPO.
*    LV_SL = LV_SL + 1.
*    WA_FINAL-SL = LV_SL.
*
**    WA_FINAL-MWSKZ = WA_EKPO-MWSKZ.
*    WA_FINAL-MENGE = WA_EKPO-MENGE.
*    WA_FINAL-NETPR = WA_EKPO-NETPR.
*    WA_FINAL-NETWR = WA_EKPO-NETWR.
*
*    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_EKPO-MATNR.
*    IF SY-SUBRC = 0.
*      WA_FINAL-MAKTX = WA_MAKT-MAKTX.
*    ENDIF.
*    READ TABLE IT_ZINW_T_ITEM ASSIGNING FIELD-SYMBOL(<WA_ITEM>) WITH KEY  MATNR = WA_EKPO-MATNR WERKS = WA_EKPO-WERKS.
*
*    IF SY-SUBRC = 0.
*
*      WA_FINAL-NETPR_GP = <WA_ITEM>-NETPR_GP.
*
*    ENDIF.
**  READ TABLE IT_MEPO1211 INTO WA_MEPO1211 WITH KEY MATNR = WA_EKPO-MATNR.
**  IF SY-SUBRC = 0.
**    WA_FINAL-RETPO = WA_MEPO1211-RETPO.
**    WA_FINAL-RET_ITEM = 'X'.
**  ENDIF.
*
*    WA_HEADER-TOQTY = WA_FINAL-TOQTY + WA_FINAL-MENGE.
*    WA_HEADER-TAMOUNT = WA_HEADER-TAMOUNT + WA_FINAL-NETWR.
*    WA_HEADER-TAMT = WA_HEADER-TAMOUNT + WA_FINAL-NETPR_GP.
*
*    APPEND WA_FINAL TO IT_FINAL.
*    CLEAR : WA_FINAL.
*  ENDLOOP.
*
*  DATA: LV_AMT      TYPE PC207-BETRG,
*        WA_AMT(100) TYPE C.
*  LV_AMT = WA_HEADER-TAMT.
*
*  CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
*    EXPORTING
*      AMT_IN_NUM         = LV_AMT
*    IMPORTING
*      AMT_IN_WORDS       = WA_AMT
*    EXCEPTIONS
*      DATA_TYPE_MISMATCH = 1
*      OTHERS             = 2.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
*    EXPORTING
*      INPUT_STRING  = WA_AMT
**     SEPARATORS    = ' -.,;:'
*    IMPORTING
*      OUTPUT_STRING = WA_AMT.
*
*
*
**  CALL FUNCTION 'ISP_CONVERT_FIRSTCHARS_TOUPPER'
**    EXPORTING
**      INPUT_STRING  = WA_AMT1
***     SEPARATORS    = ' -.,;:'
**    IMPORTING
**      OUTPUT_STRING = WA_AMT.
*
*
*
*  WA_HEADER-P_NAME1   = WA_KNA1-NAME1 .
**  WA_HEADER-P_SORTL   = WA_KNA1-SORTL .
**  WA_HEADER-P_STRAS   = WA_T001W-STRAS .
**  WA_HEADER-P_ORT01   = WA_T001W-ORT01 .
*  WA_HEADER-P_LAND1   = WA_T001W-LAND1 .
*  WA_HEADER-WERKS     = WA_T001W-WERKS.
*  WA_HEADER-P_NAME1     = WA_T001W-NAME1.
*
**  WA_HEADER-V_STRAS   = WA_LFA1-STRAS .
**  WA_HEADER-V_ORT01   = WA_LFA1-ORT01 .
**  WA_HEADER-V_LAND1   = WA_LFA1-LAND1 .
**  WA_HEADER-V_REGIO   = WA_LFA1-REGIO .
*  WA_HEADER-V_STCD3   = WA_LFA1-STCD3 .
**WA_HEADER-V_SORTL   = WA_LFA1-SORTL .
*  WA_HEADER-MBLNR     = WA_MSEG-MBLNR.
*  WA_HEADER-BLDAT     = WA_MKPF-BLDAT.
*  WA_HEADER-BEDAT     = WA_EKKO-BEDAT.
*  WA_HEADER-GSTIN     = WA_J_1BBRANCH-GSTIN.
*  WA_HEADER-SMTP_ADDR = WA_ADR6-SMTP_ADDR.
*  WA_HEADER-TRNS      = WA_ZINW_T_HDR-TRNS.
*  WA_HEADER-LR_NO     = WA_ZINW_T_HDR-LR_NO.
*  WA_HEADER-ACT_NO_BUD     = WA_ZINW_T_HDR-ACT_NO_BUD .
**  WA_HEADER-NO_BUD    = WA_ZINW_T_HDR-NO_BUD.
*  WA_HEADER-BILL_NUM  = WA_ZINW_T_HDR-BILL_NUM.
*  WA_HEADER-BILL_DATE = WA_ZINW_T_HDR-BILL_DATE.
*  WA_HEADER-EBELN     = WA_EKPO-EBELN.
*  WA_HEADER-AEDAT     = WA_EKKO-AEDAT.
*  WA_HEADER-V_NAME1   = WA_LFA1-NAME1 .
*  WA_HEADER-STREET_V         = WA_ADRC1-STREET.
*  WA_HEADER-STR_SUPPL2_V     = WA_ADRC1-STR_SUPPL2.
*  WA_HEADER-STR_SUPPL1_V     = WA_ADRC1-STR_SUPPL1.
*  WA_HEADER-CITY1_V          = WA_ADRC1-CITY1.
*  WA_HEADER-POST_CODE1_V       = WA_ADRC1-POST_CODE1.
*  WA_HEADER-BEZEI_V        = WA_T005U1-BEZEI.
*  WA_HEADER-LANDX_V      = WA_T005T1-LANDX.
*  WA_HEADER-INV_NO     = WA_EKBE-BELNR.
*  WA_HEADER-INV_DT     = WA_EKBE-BUDAT.
*
*
*  IF WA_EKPO-RETPO = 'X'.
*
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        FORMNAME           = 'ZMM_PURCHASE_RETURN_F1'
*      IMPORTING
*        FM_NAME            = FM_NAME
*      EXCEPTIONS
*        NO_FORM            = 1
*        NO_FUNCTION_MODULE = 2
*        OTHERS             = 3.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*
*    CALL FUNCTION FM_NAME
*      EXPORTING
*        WA_HEADER        = WA_HEADER
*        WA_AMT           = WA_AMT
*      TABLES
*        IT_FINAL         = IT_FINAL
*      EXCEPTIONS
*        FORMATTING_ERROR = 1
*        INTERNAL_ERROR   = 2
*        SEND_ERROR       = 3
*        USER_CANCELED    = 4
*        OTHERS           = 5.
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*  ELSE.
*    MESSAGE 'Invalid Purchase Order' TYPE 'E'.
*  ENDIF.
*
*ENDFORM.
*
**"--------------------------"--------------------------"--------------------------"--------------------------"--------------------------"--------------------------
**
**FORM DO_GPRO.
**  CONSTANTS : C_161(3)       VALUE '161',
**              C_MVT_IND_B(1) VALUE 'B',
**              C_MVT_61(2)    VALUE '61',
**              C_X(1)         VALUE 'X'.
***** Retrieve PO documents from Header table
**  SELECT EBELN QR_CODE FROM ZINW_T_HDR INTO TABLE LT_HDR WHERE EBELN = P_EBELN.
**  IF SY-SUBRC = 0 AND LT_HDR IS NOT INITIAL.
***** Retrieve PO document details from Item (item) table
**    SELECT * FROM ZINW_T_ITEM
**           INTO TABLE LT_ITEM
**           FOR ALL ENTRIES IN LT_HDR
**           WHERE EBELN = LT_HDR-EBELN.
***           AND QR_CODE = LT_HDR-QR_CODE.
**  ELSE.
**    MESSAGE E003(ZMSG_CLS).
**  ENDIF.
**
***** Looping the PO details.
**  LOOP AT LT_ITEM INTO WA_ITEM .
***** Fill the bapi Header structure details
**    WA_GMVT_HEADER-PSTNG_DATE = SY-DATUM.
**    WA_GMVT_HEADER-DOC_DATE   = SY-DATUM.
**    WA_GMVT_HEADER-PR_UNAME   = SY-UNAME.
**    WA_GMVT_HEADER-REF_DOC_NO = WA_ITEM-EBELN.
**
***** FILL THE BAPI ITEM STRUCTURE DETAILS
**    WA_GMVT_ITEM-MATERIAL  = WA_ITEM-MATNR.
**    WA_GMVT_ITEM-ITEM_TEXT = WA_ITEM-MAKTX.
**    WA_GMVT_ITEM-PLANT     = WA_ITEM-WERKS.
**    WA_GMVT_ITEM-STGE_LOC  = WA_ITEM-LGORT.
**    WA_GMVT_ITEM-MOVE_TYPE = C_161.
**    WA_GMVT_ITEM-PO_NUMBER = WA_ITEM-EBELN.
**    WA_GMVT_ITEM-PO_ITEM   = WA_ITEM-EBELP.
**    WA_GMVT_ITEM-ENTRY_QNT = WA_ITEM-MENGE_P.
**    WA_GMVT_ITEM-ENTRY_UOM = WA_ITEM-MEINS.
***    WA_GMVT_ITEM-RET_ITEM = 'X'.
**    WA_GMVT_ITEM-REF_DOC   = WA_ITEM-EBELN.
**    WA_GMVT_ITEM-PROD_DATE = SY-DATUM.
**    WA_GMVT_ITEM-MVT_IND   = C_MVT_IND_B.
**
**    APPEND WA_GMVT_ITEM TO LT_GMVT_ITEM.
**    CLEAR WA_GMVT_ITEM.
**  ENDLOOP.
***** Call the BAPI FM for GR posting
**  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
**    EXPORTING
**      GOODSMVT_HEADER  = WA_GMVT_HEADER
**      GOODSMVT_CODE    = C_MVT_61
**    IMPORTING
**      GOODSMVT_HEADRET = WA_GMVT_HEADRET
**    TABLES
**      GOODSMVT_ITEM    = LT_GMVT_ITEM
**      RETURN           = LT_BAPIRET.
**
**  READ TABLE LT_BAPIRET ASSIGNING <LS_BAPIRET> WITH KEY TYPE = 'E'.
**  IF SY-SUBRC <> 0 .
***** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
**    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**      EXPORTING
**        WAIT = C_X.
**    MOVE : WA_GMVT_HEADRET-MAT_DOC TO WA_DET-MBLNR,
**           WA_GMVT_HEADRET-DOC_YEAR TO WA_DET-MJAHR,
**           WA_GMVT_HEADER-REF_DOC_NO TO WA_DET-EBELN.
**    WA_DET-MESSAGE = 'Succefully Posted'.
**    WA_DET-MSG_TYPE = 'S'.
**    APPEND WA_DET TO LT_DET.
**    CLEAR WA_DET.
**  ELSE.
**    MOVE : WA_GMVT_HEADRET-MAT_DOC TO WA_DET-MBLNR,
**           WA_GMVT_HEADRET-DOC_YEAR TO WA_DET-MJAHR,
**           WA_GMVT_HEADER-REF_DOC_NO TO WA_DET-EBELN.
**    WA_DET-MESSAGE = <LS_BAPIRET>-MESSAGE.
**    WA_DET-MSG_TYPE = <LS_BAPIRET>-TYPE.
**    APPEND WA_DET TO LT_DET.
**    CLEAR WA_DET.
**  ENDIF.
**ENDFORM.
