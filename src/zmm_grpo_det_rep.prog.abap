*&---------------------------------------------------------------------*
*& Report ZMM_GRPO_DET_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_GRPO_DET_REP.

TYPES : BEGIN OF TY_MSEG,
          MBLNR TYPE MBLNR,
          MJAHR TYPE MJAHR,
          ZEILE TYPE MBLPO,
          LIFNR TYPE ELIFN,
          WERKS TYPE WERKS_D,
          MATNR TYPE MATNR,
          MENGE TYPE MENGE_D,
          EBELN	TYPE BSTNR,
        END OF TY_MSEG.

TYPES : BEGIN OF TY_MKPF ,
          MBLNR TYPE MBLNR,
          MJAHR TYPE MJAHR,
          BLDAT TYPE BLDAT,
        END OF TY_MKPF.

TYPES: BEGIN OF TY_LFA1,
         LIFNR TYPE LIFNR,
         LAND1 TYPE LAND1_GP,
         NAME1 TYPE NAME1_GP,
         "STRAS TYPE STRAS_GP,
         "ORT01 TYPE ORT01_GP,
         STCD3 TYPE STCD3,
         REGIO TYPE REGIO,
         ADRNR TYPE ADRNR,
       END OF TY_LFA1.

TYPES : BEGIN OF TY_T001W,
          WERKS TYPE WERKS_D,
          NAME1 TYPE NAME1,
          STRAS TYPE STRAS,
          ORT01 TYPE ORT01,
          LAND1 TYPE LAND1,
        END OF TY_T001W.

TYPES: BEGIN OF TY_KONV,
         KNUMV TYPE KNUMV,
         KPOSN TYPE KPOSN,
         STUNR TYPE STUNR,
         ZAEHK TYPE DZAEHK,
         KSCHL TYPE KSCHA,
         KBETR TYPE KBETR,
       END OF TY_KONV.
*
*TYPES: BEGIN OF TY_EKPO,
*         EBELN TYPE EBELN,
*         EBELP TYPE EBELP,
*         NETWR TYPE BWERT,
*         NETPR TYPE BPREI,
*       END OF  TY_EKPO.

TYPES : BEGIN OF TY_EKKO,
          EBELN TYPE EBELN,
          KNUMV TYPE KNUMV,
        END OF TY_EKKO.

TYPES : BEGIN OF TY_T005U,
          SPRAS TYPE SPRAS,
          LAND1 TYPE LAND1,
          BLAND TYPE REGIO,
          BEZEI TYPE BEZEI20,
        END OF TY_T005U.



TYPES: BEGIN OF TY_MAKT,
         MATNR TYPE MATNR,
         SPRAS TYPE SPRAS,
         MAKTX TYPE MAKTX,
       END OF TY_MAKT.

*TYPES : BEGIN OF TY_ZINW_T_HDR ,
*          EBELN       TYPE EBELN,
*          LIFNR       TYPE ELIFN,
*          QR_CODE     TYPE ZQR_CODE,
*          TRNS       TYPE ZTRANS  , "CHAR  40  0 Transporter Name
*          LR_NO      TYPE ZLR , "CHAR  20  0 L.R.NO
*          RCV_NO_BUD TYPE ZRCV_NOB, " INT2  5 0 No.of Bundle
*          GRPO_NO     TYPE ZGRPO_NO,
*          GRPO_DATE   TYPE ZGRPO_DATE,
*          DUE_DATE   TYPE ZDUE_DATE,
*          BILL_NUM    TYPE ZBILL_NUM,
*
**          ebeln type ZINW_T_HDR-ebeln ,
*        END OF TY_ZINW_T_HDR .

*TYPES : BEGIN OF TY_ZINW_T_ITEM ,
*          QR_CODE TYPE ZQR_CODE,
*          EBELN    TYPE EBELN,
*          EBELP    TYPE EBELP,
**          SNO      TYPE INT2,
*          MATNR    TYPE MATNR,
*          LGORT    TYPE LGORT_D,
*          WERKS    TYPE EWERK,
*          MENGE_P TYPE ZMENGE_P,
*          MEINS    TYPE BSTME,
*          MAKTX    TYPE MAKTX,
*          NETPR_P  TYPE ZBPREI_P,
*          NETWR_P  TYPE ZBPREI_PT,
*        END OF TY_ZINW_T_ITEM .

*DATA :IT_MSEG  TYPE TABLE OF  TY_MSEG,
*      WA_MSEG  TYPE  TY_MSEG,
* IT_MKPF  TYPE TABLE OF  TY_MKPF,
*      WA_MKPF  TYPE  TY_MKPF,


TYPES: BEGIN OF TY_EKPO,
         EBELN TYPE EBELN,                              "Purchasing Document Number
         EBELP TYPE EBELP,                              "Item Number of Purchasing Document
         WERKS TYPE EWERK,                              "Plant
         MATNR TYPE MATNR,                              "Material Number
         MWSKZ TYPE MWSKZ,                              "Tax on Sales/Purchases Code
         MENGE TYPE BSTMG,                              "Purchase Order Quantity
         NETPR TYPE BPREI,                              "Net Price in Purchasing Document (in Document Currency)
         PEINH TYPE EPEIN,                              "Price unit
         NETWR TYPE BWERT,                              "Net Order Value in PO Currency
         BUKRS TYPE BUKRS,
         RETPO TYPE RETPO,
       END OF TY_EKPO.
TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MARA-MATNR,
          EAN11 TYPE MARA-EAN11,
        END OF TY_MARA.
DATA: IT_LFA1  TYPE TABLE OF  TY_LFA1,
      WA_LFA1  TYPE  TY_LFA1,
      IT_T001W TYPE TABLE OF TY_T001W,
      IT_EKPO  TYPE TABLE OF TY_EKPO,
      WA_T001W TYPE  TY_T001W,
      WA_EKPO  TYPE  TY_EKPO,
      IT_KONV  TYPE TABLE OF  TY_KONV,
      WA_KONV  TYPE  TY_KONV,
*      IT_EKPO  TYPE TABLE OF  TY_EKPO,
      IT_EKKO  TYPE TABLE OF  TY_EKKO,
      WA_EKKO  TYPE  TY_EKKO,
      IT_MAKT  TYPE TABLE OF  TY_MAKT,
      WA_MAKT  TYPE  TY_MAKT,
      WA_T005U TYPE  TY_T005U,
      LV_SLNO  TYPE  I.
DATA :
  LV1 TYPE  STRING,
  LVA TYPE  STRING,
  LVB TYPE  STRING,
  LVC TYPE  STRING,
  LV2 TYPE  STRING,
  LV3 TYPE  STRING.
DATA : LV_HEADING(30) TYPE C.
DATA FMNAME TYPE RS38L_FNAM.
DATA : IT_ZINW_T_HDR  TYPE TABLE OF ZINW_T_HDR,
       WA_ZINW_T_HDR  TYPE ZINW_T_HDR,
       IT_ZINW_T_ITEM TYPE TABLE OF ZINW_T_ITEM,
       WA_ZINW_T_ITEM TYPE ZINW_T_ITEM.
DATA : WA_HEADER TYPE  ZGRPO_H_PRICE,
       IT_FINAL  TYPE TABLE OF ZGRPO_I_PRICE,
       WA_FINAL  TYPE  ZGRPO_I_PRICE.
DATA :  QR_CODE  TYPE ZQR_CODE.
FIELD-SYMBOLS : <WA_SET> TYPE ZINW_T_ITEM.

DATA : IT_DD07V_TAB TYPE TABLE OF DD07V,
       WA_DD07V_TAB TYPE DD07V.
DATA :LV_HED(15) TYPE C,
      LV_VAL(15) TYPE C,
      LV_PER     TYPE KBETR,
      LV_PER1    TYPE KBETR,
      LV_S(01)   TYPE C.

DATA: GT_MARA TYPE TABLE OF TY_MARA.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
TABLES : ZINW_T_HDR .
*SELECT-OPTIONS :  "P_QR FOR  ZINW_T_HDR-QR_CODE NO INTERVALS ,
*PARAMETERS :S_INW TYPE ZINWD_DOC .  ""ZINW_T_HDR-INWD_DOC NO INTERVALS.
PARAMETERS :P_QR TYPE ZQR_CODE .  ""ZINW_T_HDR-INWD_DOC NO INTERVALS.
SELECTION-SCREEN : END OF BLOCK B1.


PERFORM TP2_FORM USING P_QR  .
*&---------------------------------------------------------------------*
*& Form TP2_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_QR
*&---------------------------------------------------------------------*
FORM TP2_FORM  USING P_QR .
  REFRESH : IT_ZINW_T_ITEM, IT_ZINW_T_HDR,IT_FINAL.
  CLEAR : WA_FINAL, WA_ZINW_T_ITEM, WA_HEADER,LV1, LVA,LVB, LVC,LV2,LV3.

*  BREAK BREDDY.
  IF P_QR  IS NOT INITIAL ..
    SELECT * FROM ZINW_T_HDR INTO TABLE IT_ZINW_T_HDR
             WHERE QR_CODE = P_QR .
*               WHERE INWD_DOC = P_QR    .

  ENDIF.
*  IF P_QR IS NOT INITIAL.
*    SELECT * FROM ZINW_T_HDR INTO TABLE IT_ZINW_T_HDR
*           WHERE QR_CODE = P_QR .
**             WHERE INWD_DOC = S_INW   .
*
*  ENDIF.
*  BREAK BREDDY.


  IF IT_ZINW_T_HDR IS NOT INITIAL .

    SELECT * FROM ZINW_T_STATUS INTO TABLE @DATA(IT_ZINW_T_STATUS) FOR ALL ENTRIES IN @IT_ZINW_T_HDR
                                                                  WHERE QR_CODE = @IT_ZINW_T_HDR-QR_CODE.
  ENDIF.


  READ TABLE  IT_ZINW_T_HDR INTO WA_ZINW_T_HDR INDEX 1.
  DATA :  LV_STATUS        TYPE VAL_TEXT.
*  BREAK BREDDY .
  IF WA_ZINW_T_HDR IS NOT INITIAL .
    SELECT SINGLE DDTEXT FROM DD07V INTO LV_STATUS WHERE DOMNAME = 'ZSTATUS' AND DOMVALUE_L = WA_ZINW_T_HDR-STATUS AND DDLANGUAGE = SY-LANGU.
    SELECT SINGLE EKKO~EBELN , EKKO~BSART FROM EKKO INTO @DATA(WA_EKKO) WHERE EBELN = @WA_ZINW_T_HDR-EBELN .

    SELECT * FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
                              WHERE QR_CODE = WA_ZINW_T_HDR-QR_CODE.

  ENDIF.
*  BREAK BREDDY.
  IF IT_ZINW_T_ITEM IS NOT INITIAL.
    SELECT
    EBELN
    EBELP
    WERKS
    MATNR
    MWSKZ
    MENGE
    NETPR
    PEINH
    NETWR
    BUKRS
    RETPO
    FROM EKPO INTO TABLE IT_EKPO FOR ALL ENTRIES IN IT_ZINW_T_ITEM WHERE EBELN = IT_ZINW_T_ITEM-EBELN AND MATNR = IT_ZINW_T_ITEM-MATNR AND EBELP = IT_ZINW_T_ITEM-EBELP.

  ENDIF.

  IF IT_EKPO IS NOT INITIAL.

    SELECT * FROM A003 INTO TABLE @DATA(IT_A003) FOR ALL ENTRIES IN @IT_EKPO WHERE MWSKZ = @IT_EKPO-MWSKZ.

  ENDIF.

  IF IT_A003 IS NOT INITIAL.

    SELECT * FROM KONP INTO TABLE @DATA(IT_KONP) FOR ALL ENTRIES IN @IT_A003 WHERE KNUMH = @IT_A003-KNUMH.

  ENDIF.

  IF IT_ZINW_T_ITEM IS NOT INITIAL.

    SELECT
      MATNR
      EAN11 FROM MARA INTO TABLE GT_MARA
             FOR ALL ENTRIES IN IT_ZINW_T_ITEM
                 WHERE MATNR = IT_ZINW_T_ITEM-MATNR.

  ENDIF.

*  CALL FUNCTION 'DD_DOMVALUES_GET'
*    EXPORTING
*      DOMNAME        = 'ZSTATUS'
*      TEXT           = 'X'
*      LANGU          = 'E'
**     BYPASS_BUFFER  = ' '
** IMPORTING
**     RC             =
*    TABLES
*      DD07V_TAB      = IT_DD07V_TAB
*    EXCEPTIONS
*      WRONG_TEXTFLAG = 1
*      OTHERS         = 2.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  CLEAR : WA_DD07V_TAB-DDTEXT .
**READ TABLE IT_DD07V_TAB INTO WA_DD07V_TAB INDEX 1.
*
*  CLEAR : WA_FINAL, WA_DD07V_TAB.
*  REFRESH : IT_FINAL.
*  LOOP AT IT_DD07V_TAB INTO WA_DD07V_TAB WHERE DOMVALUE_L = WA_ZINW_T_HDR-STATUS.
*    CASE WA_DD07V_TAB-DOMVALUE_L .
*      WHEN '01'.
*        WA_HEADER-QR_STATUS = WA_DD07V_TAB-DDTEXT.
*      WHEN '02'.
*        WA_HEADER-QR_STATUS = WA_DD07V_TAB-DDTEXT.
*      WHEN '03'.
*        WA_HEADER-QR_STATUS = WA_DD07V_TAB-DDTEXT.
*      WHEN '04'.
*        WA_HEADER-QR_STATUS = WA_DD07V_TAB-DDTEXT.
*      WHEN '05'.
*        WA_HEADER-QR_STATUS = WA_DD07V_TAB-DDTEXT.
*      WHEN '06'.
*        WA_HEADER-QR_STATUS = WA_DD07V_TAB-DDTEXT.
*    ENDCASE.
*
*  ENDLOOP.


*READ TABLE IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM INDEX 1 .
*IF WA_ZINW_T_HDR IS NOT INITIAL.
*  SELECT SINGLE LIFNR
*                LAND1
*                NAME1
*                STCD3
*                REGIO
*                ADRNR FROM LFA1 INTO WA_LFA1
*                      WHERE LIFNR = WA_ZINW_T_HDR-LIFNR.
*ENDIF.

*IF WA_LFA1 IS NOT INITIAL.
*
*  SELECT SINGLE ADRC~ADDRNUMBER,
*               ADRC~CITY1,
*               ADRC~POST_CODE1,
*               ADRC~STREET,
*               ADRC~HOUSE_NUM1,
*               ADRC~STR_SUPPL1,
*               ADRC~STR_SUPPL2,
*               ADRC~STR_SUPPL3 FROM ADRC INTO @DATA(WA_ADRC) WHERE ADDRNUMBER =  @WA_LFA1-ADRNR.
*
*BREAK breddy.
  WA_HEADER-QR_CODE = WA_ZINW_T_HDR-QR_CODE.
  WA_HEADER-INWD_DOC = WA_ZINW_T_HDR-INWD_DOC.   " Added By Suri : 16.05.2019
  WA_HEADER-LR_DATE = WA_ZINW_T_HDR-LR_DATE.
  WA_HEADER-PO_NUM = WA_ZINW_T_HDR-EBELN.
*WA_HEADER-EBELN = WA_ZINW_T_HDR-EBELN.
  WA_HEADER-BREC_DATE = WA_ZINW_T_HDR-REC_DATE.

  WA_HEADER-TRNS = WA_ZINW_T_HDR-TRNS.
  WA_HEADER-LR_NO = WA_ZINW_T_HDR-LR_NO .
  WA_HEADER-ACT_NO_BUD = WA_ZINW_T_HDR-ACT_NO_BUD.
  WA_HEADER-BK_STATION = WA_ZINW_T_HDR-BK_STATION.
  WA_HEADER-FRIGHT = WA_ZINW_T_HDR-FRT_AMT .
  WA_HEADER-FRIGHT_NO = WA_ZINW_T_HDR-FRT_NO .
  WA_HEADER-V_NAME1 = WA_ZINW_T_HDR-NAME1 .
  WA_HEADER-LIFNR  = WA_ZINW_T_HDR-LIFNR .
  WA_HEADER-BILL_NUM = WA_ZINW_T_HDR-BILL_NUM .
  WA_HEADER-BILL_DATE = WA_ZINW_T_HDR-BILL_DATE.
*  WA_HEADER-VEN_CAT = WA_ZINW_T_HDR-J_1IVTYP.
*  WA_HEADER-PRO_CAT = WA_ZINW_T_HDR-VDR_PRF.
*  WA_HEADER-QR_STATUS = WA_ZINW_T_HDR-STATUS.
  WA_HEADER-QR_STATUS = LV_STATUS .
  READ TABLE IT_ZINW_T_STATUS ASSIGNING FIELD-SYMBOL(<WA_STATUS>) WITH KEY QR_CODE = WA_ZINW_T_HDR-QR_CODE.

  IF SY-SUBRC = 0 AND <WA_STATUS>-STATUS_FIELD = 'QR_CODE' .
*    WA_HEADER-QR_STATUS = <WA_STATUS>-DESCRIPTION.
    WA_HEADER-QR_USER = <WA_STATUS>-CREATED_BY .
    WA_HEADER-QR_DATE = <WA_STATUS>-CREATED_DATE.
    WA_HEADER-QR_TIME = <WA_STATUS>-CREATED_TIME.
  ENDIF.
*  DATA : LV_SET TYPE C VALUE 'SET'.
*BREAK BREDDY.
*
*******************set************************
*  DATA(IT_SET) = IT_ZINW_T_ITEM.
*  DELETE IT_SET WHERE ZZSET_MATERIAL IS INITIAL.
*  IF IT_SET IS NOT INITIAL.
*    SORT IT_SET BY ZZSET_MATERIAL.
*    DELETE ADJACENT DUPLICATES FROM IT_SET COMPARING ZZSET_MATERIAL.
*******loop for set**********************
*    LOOP AT IT_SET ASSIGNING <WA_SET>.
*      WA_FINAL = <WA_SET>.
*      LV_SLNO = LV_SLNO + 1.
*
*      WA_FINAL-MATKL  = <WA_SET>-MATKL.
*      WA_FINAL-MATNR  = <WA_SET>-MATNR.
*      WA_FINAL-MAKTX  = <WA_SET>-MAKTX.
*
*      DATA(IT_COUNT) = IT_ZINW_T_ITEM.
*      DELETE  IT_COUNT WHERE ZZSET_MATERIAL <> <WA_SET>-ZZSET_MATERIAL.
*      DESCRIBE TABLE IT_COUNT LINES DATA(LV_LINES).
*      WA_FINAL-MENGE = <WA_SET>-MENGE / LV_LINES.
**      WA_FINAL-MENGE = <WA_SET>-MENGE * LV_LINES.
*      WA_FINAL-MEINS = <WA_SET>-MEINS.
*      WA_FINAL-MWSKZ_P = <WA_SET>-MWSKZ_P.
*      WA_FINAL-NETPR_GP = <WA_SET>-NETPR_GP * LV_LINES.
*      WA_FINAL-NETWR_P = <WA_SET>-NETWR_P * <WA_SET>-MENGE.
*    ENDLOOP.
*
*WA_HEADER-QN_T =
*WA_HEADER-NETPR_T =
*WA_HEADER-NETWR_T =
*
*  ENDIF.

*      WA_HEADER-QN_T = WA_HEADER-QN_T + WA_FINAL-MENGE .
*      WA_HEADER-NETPR_T = WA_HEADER-NETPR_T + WA_FINAL-NETPR_GP .
*      WA_HEADER-NETWR_T = WA_HEADER-NETWR_T + WA_FINAL-NETWR_P .
*
*
*    ELSE.
  IF WA_EKKO-BSART = 'ZTAT'.

    LV_HEADING = 'Tatkal Inward Document'.

  ELSE.
    LV_HEADING = 'Inward Document'.

  ENDIF.

*  BREAK BREDDY.
  DATA : LV_TAX TYPE KONP-KBETR .
  CLEAR : LV_SLNO.
  LOOP AT IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM.

    LV_SLNO = LV_SLNO + 1.
    WA_FINAL-SLNO = LV_SLNO .

    WA_FINAL-MATKL = WA_ZINW_T_ITEM-MATKL.
    WA_FINAL-MATNR = WA_ZINW_T_ITEM-MATNR.
    WA_FINAL-MAKTX = WA_ZINW_T_ITEM-MAKTX.
    WA_FINAL-EAN11 = WA_ZINW_T_ITEM-EAN11.
*    LV1 = WA_ZINW_T_ITEM-MENGE .
*  SPLIT LV1 AT '.' INTO LV3 LV2.
    WA_FINAL-MENGE = WA_ZINW_T_ITEM-MENGE_P .
    WA_FINAL-NETPR_GP = WA_ZINW_T_ITEM-NETPR_GP .


    WA_FINAL-MEINS = WA_ZINW_T_ITEM-MEINS.
    WA_FINAL-NETPR_P = WA_ZINW_T_ITEM-NETPR_P.
*    WA_FINAL-MWSKZ_P = WA_ZINW_T_ITEM-MWSKZ_P.
*    WA_FINAL-NETPR_GP = WA_ZINW_T_ITEM-NETPR_GP.             ""gst value
    WA_FINAL-NETWR_P = WA_ZINW_T_ITEM-NETWR_P.

*    LVA = WA_ZINW_T_ITEM-MENGE_P.
    WA_HEADER-QN_T = WA_HEADER-QN_T + WA_FINAL-MENGE .
    WA_HEADER-NETWR_T = WA_HEADER-NETWR_T + WA_FINAL-NETWR_P .               ""gst total value
*    BREAK BREDDY.
    READ TABLE GT_MARA ASSIGNING FIELD-SYMBOL(<GS_MARA>) WITH KEY MATNR = WA_ZINW_T_ITEM.
*    IF SY-SUBRC = 0.
*
*      WA_FINAL-EAN11 = <GS_MARA>-EAN11.
*
*    ENDIF.

    BREAK BREDDY.
    READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN =   WA_ZINW_T_ITEM-EBELN MATNR = WA_ZINW_T_ITEM-MATNR EBELP = WA_ZINW_T_ITEM-EBELP.
    LOOP AT IT_A003 ASSIGNING FIELD-SYMBOL(<WA_A003>) WHERE MWSKZ = WA_EKPO-MWSKZ.
      IF <WA_A003>-KSCHL = 'JIIG'.
        LV_HED = 'IGST(%)'.
        LV_VAL = 'IGST Value'.
        READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<WA_KONP>) WITH KEY KNUMH = <WA_A003>-KNUMH.
        IF SY-SUBRC = 0.
          LV_PER =  <WA_KONP>-KBETR / 10   .
          ADD LV_PER TO WA_FINAL-PERCENTAGE.                     """""| && | { '%' } |.


*******************changes done on 28.11.2019*******
*          LV_TAX = ( <WA_KONP>-KBETR * WA_ZINW_T_ITEM-NETWR_P ) / 1000.
          LV_TAX = ( LV_PER  * WA_EKPO-NETPR ) / 10 .
*          ADD LV_TAX TO WA_FINAL-NETPR_GP.
*          WA_FINAL-NETPR_GP = LV_TAX.
****************end of changes***********************
*          WA_HEADER-NETPR_T = WA_HEADER-NETPR_T +  WA_FINAL-NETPR_GP .
*            EXIT.
        ENDIF.
      ELSEIF <WA_A003>-KSCHL = 'JICG' OR <WA_A003>-KSCHL = 'JISG'.
        CLEAR : LV_HED , LV_VAL.
        READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<WA_KONP1>) WITH KEY KNUMH = <WA_A003>-KNUMH.
        LV_HED = 'CGST/SGST(%)'.
        LV_VAL = 'CGST/SGST Val'.
*        CONDENSE LV_HED.
        IF SY-SUBRC = 0.
          CLEAR: LV_TAX,LV_PER,WA_FINAL-PERCENTAGE ,LV_PER1.
          LV_PER =  <WA_KONP1>-KBETR / 10 .
          LV_PER1 = LV_PER +   LV_PER    .
          ADD LV_PER TO WA_FINAL-PERCENTAGE.
          LV_S = '/'.                           """""| && | { '/' } |.

****changes done on 28.11.2019 *****************
*          LV_TAX = ( <WA_KONP1>-KBETR * WA_EKPO-NETWR ) / 1000.
*          ADD LV_TAX TO WA_FINAL-NETPR_GP.
          LV_TAX = ( LV_PER1 * WA_EKPO-NETPR ) / 10 .
*          WA_FINAL-NETPR_GP = LV_TAX.
********end of changes*************************
*          WA_HEADER-NETPR_T = WA_HEADER-NETPR_T + WA_FINAL-NETPR_GP .
        ENDIF.
*      ELSEIF <WA_A003>-KSCHL = 'JICG'   .            ""OR <WA_A003>-KSCHL = 'JISG'.
*        IF SY-SUBRC = 0.
*          CLEAR: LV_TAX,LV_PER.
*          LV_PER = |{ <WA_KONP>-KBETR / 10 }| && | { '%' } |.
*          LV_TAX = ( <WA_KONP>-KBETR * WA_EKPO-NETWR ) / 1000.
**          ADD LV_TAX TO WA_FINAL-NETPR_GP.
*        ENDIF.
      ENDIF.

    ENDLOOP.
    WA_HEADER-NETPR_T = WA_HEADER-NETPR_T +  WA_FINAL-NETPR_GP .

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR : WA_FINAL, WA_ZINW_T_ITEM.
  ENDLOOP.

*  ENDIF.
*PERFORM GRPO_TP2 USING P_QR.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZMM_GRPO_DET_F'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = FMNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
*  BREAK BREDDY.

  CALL FUNCTION FMNAME
    EXPORTING
      WA_HEADER        = WA_HEADER
      QR_CODE          = WA_HEADER-QR_CODE
      LV_HEADING       = LV_HEADING
      LV_HED           = LV_HED
      LV_VAL           = LV_VAL
      LV_PER           = LV_PER
      LV_S             = LV_S
    TABLES
      IT_FINAL         = IT_FINAL
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
