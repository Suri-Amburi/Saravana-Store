*&---------------------------------------------------------------------*
*& Include          ZSST_DEBITNOTE_F01
*&---------------------------------------------------------------------*

FORM GETDATA.
*  BREAK-POINT.
  SELECT EBELN
         KNUMV
         LIFNR
         WAERS
         FROM EKKO INTO TABLE IT_EKKO.

  IF IT_EKKO IS NOT INITIAL.
    SELECT EBELN
           EBELP
           MATNR
           MEINS
           MENGE
           NETPR
           FROM EKPO INTO TABLE IT_EKPO FOR ALL ENTRIES IN IT_EKKO
           WHERE EBELN = IT_EKKO-EBELN.
  ENDIF.

  SELECT QR_CODE
         EBELN
         EBELP
         SNO
         MATNR
         FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM FOR ALL ENTRIES IN IT_EKKO
         WHERE EBELN = IT_EKKO-EBELN.

  SELECT LIFNR
         NAME1
         FROM LFA1 INTO TABLE IT_LFA1 FOR ALL ENTRIES IN IT_EKKO
         WHERE LIFNR = IT_EKKO-LIFNR.

  SELECT KNUMV
         KPOSN
         STUNR
         ZAEHK
         KBETR
         KWERT
         WAERS
         FROM PRCD_ELEMENTS INTO TABLE IT_PRCD_ELEMENTS FOR ALL ENTRIES IN IT_EKKO
         WHERE WAERS = IT_EKKO-WAERS.



  IF IT_EKPO IS NOT INITIAL.
    SELECT MBLNR
           MJAHR
           ZEILE
           CHARG
           MATNR
           BWART
           EBELN
           FROM MSEG INTO TABLE IT_MSEG FOR ALL ENTRIES IN IT_EKPO
           WHERE MATNR = IT_EKPO-MATNR.
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

    CLEAR : WA_EKKO , WA_EKPO , WA_MSEG , WA_PRCD_ELEMENTS , WA_ZINW_T_ITEM ,WA_LFA1 .
    READ TABLE IT_MSEG INTO WA_MSEG
    WITH KEY CHARG = LV_BATCH.

    READ TABLE IT_EKPO INTO WA_EKPO
    WITH KEY MATNR = WA_MSEG-MATNR.

    READ TABLE IT_EKKO INTO WA_EKKO
    WITH KEY EBELN = WA_EKPO-EBELN.

    READ TABLE IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM
    WITH KEY EBELN = WA_MSEG-EBELN.
    IF SY-SUBRC = 0.
      LV_MATNR = WA_ZINW_T_ITEM-MATNR .
      LV_QR_CODE = WA_ZINW_T_ITEM-QR_CODE.
*      LV_BATCH = WA_MSEG-CHARG.
    ENDIF.
    READ TABLE IT_PRCD_ELEMENTS INTO WA_PRCD_ELEMENTS
    WITH KEY WAERS = WA_EKKO-WAERS.

    READ TABLE IT_LFA1 INTO WA_LFA1
    WITH KEY LIFNR = WA_EKKO-LIFNR.

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
  BREAK-POINT.
**********
*SST CODE MATNR
*BATCH = CHAEG
*********

  LOOP AT IT_MSEG INTO WA_MSEG WHERE MATNR = LV_MATNR AND CHARG = LV_BATCH AND BWART = '101'.
    SLNO = 0.
    SLNO = SLNO + 1.
    WA_ITEM_1-SLNO = SLNO.

    WA_ITEM_1-MATNR = WA_MSEG-MATNR.
    WA_ITEM_1-CHARG = WA_MSEG-CHARG.
    WA_ITEM_1-BWART = WA_MSEG-BWART.

    LOOP AT IT_EKPO INTO WA_EKPO WHERE  MATNR = WA_MSEG-MATNR  .
      WA_ITEM_1-MENGE = WA_EKPO-MENGE + WA_ITEM_1-MENGE.
      WA_ITEM_1-MEINS = WA_EKPO-MEINS.
***************


      WA_ITEM_1-NETPR = WA_EKPO-NETPR + WA_ITEM_1-NETPR .
*********READ EKKO THAN READ PRCD

      READ TABLE IT_EKKO INTO WA_EKKO WITH KEY EBELN = WA_EKPO-EBELN.
      IF SY-SUBRC = 0.
        READ TABLE IT_PRCD_ELEMENTS INTO WA_PRCD_ELEMENTS
        WITH KEY WAERS = WA_EKKO-WAERS.
        LV_GST% = WA_PRCD_ELEMENTS-KBETR / 10 .
        WA_ITEM_1-KBETR = WA_ITEM_1-KBETR + LV_GST% .
        WA_ITEM_1-KWERT = ( WA_ITEM_1-NETPR * WA_ITEM_1-MENGE ) * WA_ITEM_1-KBETR / 100 .
      ENDIF.
    ENDLOOP.
    WA_ITEM_1-AMOUNT = WA_ITEM_1-AMOUNT + WA_ITEM_1-NETPR + WA_PRCD_ELEMENTS-KWERT.
*    WA_ITEM_1-AMOUNT = ( WA_ITEM_1-NETPR * WA_ITEM_1-MENGE ) + WA_ITEM_1-GST .
    APPEND WA_ITEM_1 TO IT_ITEM_1.
    CLEAR WA_ITEM_1.
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
  CONSTANTS : C_102(3)       VALUE '102',
              C_MVT_IND_B(1) VALUE 'B',
              C_MVT_02(2)    VALUE '02',
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
    WA_GMVT_ITEM-MOVE_TYPE = C_102.
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
*  BREAK SAMBURI.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = WA_GMVT_HEADER
      GOODSMVT_CODE    = C_MVT_02
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


*FORM PRINT.
*  DATA F_NAME TYPE RS38L_FNAM.
*  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*    EXPORTING
*      FORMNAME           = 'ZSAP_DEBITNOTE'
**     VARIANT            = ' '
**     DIRECT_CALL        = ' '
*    IMPORTING
*      FM_NAME            = F_NAME
*    EXCEPTIONS
*      NO_FORM            = 1
*      NO_FUNCTION_MODULE = 2
*      OTHERS             = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  CALL FUNCTION F_NAME
*    EXPORTING
*      WA_HEADER        = WA_HEADER
**     LV_MATNR         = LV_MATNR
**     LV_AMOUNT        = LV_AMOUNT
*      LV_BATCH         = LV_BATCH
**     LV_QR_CODE       = LV_QR_CODE
*    TABLES
*      IT_ITEM1         = IT_ITEM1
*    EXCEPTIONS
*      FORMATTING_ERROR = 1
*      INTERNAL_ERROR   = 2
*      SEND_ERROR       = 3
*      USER_CANCELED    = 4
*      OTHERS           = 5.
*
*ENDFORM.
