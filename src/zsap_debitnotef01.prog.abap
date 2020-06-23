*&---------------------------------------------------------------------*
*& Include          ZSAP_DEBITNOTEF01
*&---------------------------------------------------------------------*

FORM GETDATA.
*BREAK-POINT.
  SELECT   MBLNR
           MJAHR
           ZEILE
           CHARG
           MATNR
           BWART
           EBELN
           FROM MSEG INTO TABLE IT_MSEG
           WHERE CHARG = LV_BATCH.

  IF IT_MSEG IS NOT INITIAL.

    SELECT  EBELN
            KNUMV
            LIFNR
            FROM EKKO INTO TABLE IT_EKKO
            FOR ALL ENTRIES IN IT_MSEG
            WHERE EBELN = IT_MSEG-EBELN.


    SELECT EBELN
           EBELP
           MATNR
           MEINS
           MENGE
           NETPR
           FROM EKPO INTO TABLE IT_EKPO
           FOR ALL ENTRIES IN IT_MSEG
           WHERE EBELN = IT_MSEG-EBELN.

    SELECT QR_CODE
           EBELN
           EBELP
           SNO
           MATNR
           FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
           FOR ALL ENTRIES IN IT_MSEG
           WHERE EBELN = IT_MSEG-EBELN OR MATNR = IT_MSEG-MATNR.
  ENDIF.

  IF IT_EKKO IS NOT INITIAL.

    SELECT KNUMV
           KPOSN
           STUNR
           ZAEHK
           KBETR
           KWERT
           FROM PRCD_ELEMENTS INTO TABLE IT_PRCD_ELEMENTS FOR ALL ENTRIES IN IT_EKKO
           WHERE KNUMV = IT_EKKO-KNUMV.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_VALID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_VALID .

  IF LV_BATCH IS NOT INITIAL.
*    BREAK-POINT .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_BATCH
      IMPORTING
        OUTPUT = LV_BATCH.

    CLEAR : WA_EKKO , WA_EKPO , WA_MSEG , WA_PRCD_ELEMENTS , WA_ZINW_T_ITEM .
    READ TABLE IT_MSEG INTO WA_MSEG
    WITH KEY CHARG = LV_BATCH.

    READ TABLE IT_EKKO INTO WA_EKKO
    WITH KEY EBELN = WA_MSEG-EBELN.

    READ TABLE IT_EKPO INTO WA_EKPO
    WITH KEY MATNR = WA_MSEG-MATNR.

    READ TABLE IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM
    WITH KEY EBELN = WA_MSEG-EBELN.
*    MATNR = WA_MSEG-MATNR.

    IF SY-SUBRC = 0.
      LV_MATNR = WA_ZINW_T_ITEM-MATNR .
      LV_QR_CODE = WA_ZINW_T_ITEM-QR_CODE.
*      LV_BATCH = WA_MSEG-CHARG.
    ENDIF.

    READ TABLE IT_PRCD_ELEMENTS INTO WA_PRCD_ELEMENTS
    WITH KEY KNUMV = WA_EKKO-KNUMV.

*    WA_HEADER-LIFNR = WA_LFA1-LIFNR.
*    WA_HEADER-QR_CODE = WA_ZINW_T_ITEM-QR_CODE.
*    WA_HEADER-MBLNR = WA_MSEG-MBLNR.
*    WA_HEADER-CHARG = LV_BATCH.
*    WA_HEADER-EBELN = WA_EKKO-EBELN.


    LOOP AT SCREEN.
      IF WA_MSEG-BWART <> '101'.
        SCREEN-INPUT = '0'.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.

FORM BACK_FUN.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
*      WHEN 'SAVE'.
*      PERFORM PRINT.
*
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TABLE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM TABLE_DATA .
*  BREAK-POINT.
**********
*SST CODE MATNR
*BATCH = CHAEG
*********
*  BREAK DDASH.
  LOOP AT IT_MSEG INTO WA_MSEG WHERE MATNR = LV_MATNR AND CHARG = LV_BATCH AND BWART = '101'.
    SLNO = SLNO + 1.
    WA_ITEM1-SLNO = SLNO.

    WA_ITEM1-MATNR = WA_MSEG-MATNR.
    WA_ITEM1-CHARG = WA_MSEG-CHARG.
    WA_ITEM1-BWART = WA_MSEG-BWART.
    LV_BATCH = WA_ITEM1-CHARG.

    LOOP AT IT_EKPO INTO WA_EKPO WHERE  MATNR = WA_MSEG-MATNR  .
      WA_ITEM1-MEINS = WA_EKPO-MEINS.
      WA_ITEM1-MENGE = WA_EKPO-MENGE + WA_ITEM1-MENGE.
      WA_ITEM1-NETPR = WA_EKPO-NETPR + WA_ITEM1-NETPR.
*********READ EKKO THAN READ PRCD

      READ TABLE IT_EKKO INTO WA_EKKO WITH KEY EBELN = WA_EKPO-EBELN.
      IF SY-SUBRC = 0.
        READ TABLE IT_PRCD_ELEMENTS INTO WA_PRCD_ELEMENTS
        WITH KEY KNUMV = WA_EKKO-KNUMV.
        WA_ITEM1-KBETR = WA_PRCD_ELEMENTS-KBETR.
        WA_ITEM1-KWERT = ( WA_ITEM1-NETPR * WA_ITEM1-MENGE ) * WA_ITEM1-KBETR / 100.
*        WA_PRCD_ELEMENTS-KWERT + WA_ITEM1-KWERT.
      ENDIF.
    ENDLOOP.
    WA_ITEM1-AMOUNT = WA_ITEM1-AMOUNT + ( WA_ITEM1-NETPR * WA_ITEM1-MENGE ) + WA_ITEM1-KWERT. "WA_PRCD_ELEMENTS-KWERT.
    APPEND WA_ITEM1 TO IT_ITEM1.
    CLEAR WA_ITEM1.
  ENDLOOP.
ENDFORM.



*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GOODS_MOVEMENT.
*BREAK-POINT .
  CONSTANTS : C_161(3)       VALUE '161',
              C_MVT_IND_B(1) VALUE 'B',
              C_MVT_61(2)    VALUE '61',
              C_X(1)         VALUE 'X'.
*  BREAK SAMBURI.
*** Retrieve PO documents from Header table
  SELECT EBELN QR_CODE FROM ZINW_T_HDR INTO TABLE LT_HDR WHERE QR_CODE = LV_QR_CODE.
  IF SY-SUBRC = 0 AND LT_HDR IS NOT INITIAL.
*** Retrieve PO document details from Item (item) table
    SELECT QR_CODE
           EBELN
           EBELP
           MATNR
           LGORT
           WERKS
           MAKTX
           MATKL
           MENGE_P
           MEINS
           FROM ZINW_T_ITEM
           INTO TABLE LT_ITEM
           FOR ALL ENTRIES IN LT_HDR
           WHERE EBELN = LT_HDR-EBELN
           AND QR_CODE = LT_HDR-QR_CODE.
  ELSE.
    MESSAGE E003(ZMSG_CLS).
  ENDIF.

*** Looping the PO details.
  LOOP AT LT_ITEM INTO WA_ITEM .
*** Fill the bapi Header structure details
    WA_GMVT_HEADER-PSTNG_DATE = SY-DATUM.
    WA_GMVT_HEADER-DOC_DATE   = SY-DATUM.
    WA_GMVT_HEADER-PR_UNAME   = SY-UNAME.
    WA_GMVT_HEADER-REF_DOC_NO = WA_ITEM-EBELN.

*** FILL THE BAPI ITEM STRUCTURE DETAILS
    WA_GMVT_ITEM-MATERIAL  = WA_ITEM-MATNR.
    WA_GMVT_ITEM-ITEM_TEXT = WA_ITEM-MAKTX.
    WA_GMVT_ITEM-PLANT     = WA_ITEM-WERKS.
    WA_GMVT_ITEM-STGE_LOC  = WA_ITEM-LGORT.
    WA_GMVT_ITEM-MOVE_TYPE = C_161.
    WA_GMVT_ITEM-PO_NUMBER = WA_ITEM-EBELN.
    WA_GMVT_ITEM-PO_ITEM   = WA_ITEM-EBELP.
    WA_GMVT_ITEM-ENTRY_QNT = WA_ITEM-MENGE_P.
    WA_GMVT_ITEM-ENTRY_UOM = WA_ITEM-MEINS.
*    WA_GMVT_ITEM-NO_MORE_GR = 'X'.
    WA_GMVT_ITEM-REF_DOC   = WA_ITEM-EBELN.
    WA_GMVT_ITEM-PROD_DATE = SY-DATUM.
    WA_GMVT_ITEM-MVT_IND   = C_MVT_IND_B.

    APPEND WA_GMVT_ITEM TO LT_GMVT_ITEM.
    CLEAR WA_GMVT_ITEM.
  ENDLOOP.

*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = WA_GMVT_HEADER
      GOODSMVT_CODE    = C_MVT_61
    IMPORTING
      GOODSMVT_HEADRET = WA_GMVT_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_GMVT_ITEM
      RETURN           = LT_BAPIRET.

  READ TABLE LT_BAPIRET ASSIGNING <LS_BAPIRET> WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = C_X.
    MOVE : WA_GMVT_HEADRET-MAT_DOC TO WA_DET-MBLNR,
           WA_GMVT_HEADRET-DOC_YEAR TO WA_DET-MJAHR,
           WA_GMVT_HEADER-REF_DOC_NO TO WA_DET-EBELN.
    WA_DET-MESSAGE = 'Succefully Posted'.
    WA_DET-MSG_TYPE = 'S'.
    APPEND WA_DET TO LT_DET.
    CLEAR WA_DET.
  ELSE.
    MOVE : WA_GMVT_HEADRET-MAT_DOC TO WA_DET-MBLNR,
           WA_GMVT_HEADRET-DOC_YEAR TO WA_DET-MJAHR,
           WA_GMVT_HEADER-REF_DOC_NO TO WA_DET-EBELN.
    WA_DET-MESSAGE = <LS_BAPIRET>-MESSAGE.
    WA_DET-MSG_TYPE = <LS_BAPIRET>-TYPE.
    APPEND WA_DET TO LT_DET.
    CLEAR WA_DET.
  ENDIF.

ENDFORM.
