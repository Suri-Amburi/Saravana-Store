FUNCTION ZFM_PURCHASE_FORM_TEST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LV_EBELN) TYPE  EKKO-EBELN
*"     VALUE(REG_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(RETURN_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(TATKAL_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(PRINT_PRIEVIEW) TYPE  CHAR1 OPTIONAL
*"     VALUE(SERVICE_PO) TYPE  CHAR1 OPTIONAL
*"----------------------------------------------------------------------
  BREAK BREDDY.
  IF LV_EBELN IS NOT INITIAL.
    TYPES : BEGIN OF TY_EKPO,
              EBELN          TYPE EKPO-EBELN,
              EBELP          TYPE EKPO-EBELP,
              MENGE          TYPE EKPO-MENGE,
              WERKS          TYPE  EKPO-WERKS,
              MATNR          TYPE  EKPO-MATNR,
              MEINS          TYPE EKPO-MEINS,
              MATKL          TYPE EKPO-MATKL,
              NETPR          TYPE  EKPO-NETPR,
              NETWR          TYPE  EKPO-NETWR,
              ZZSET_MATERIAL TYPE EKPO-ZZSET_MATERIAL,
              WRF_CHARSTC2   TYPE EKPO-WRF_CHARSTC2,
              ZZTEXT100      TYPE ZTEXT,
            END OF TY_EKPO.
    DATA : I_ADDRNUMBER  TYPE ADR6-SMTP_ADDR .
*    TYPES : BEGIN OF TY_EKPO_P,
*              EBELN          TYPE EKPO-EBELN,
*              EBELP          TYPE EKPO-EBELP,
*              MENGE          TYPE EKPO-MENGE,
*              WERKS          TYPE  EKPO-WERKS,
*              MATNR          TYPE  EKPO-MATNR,
*              MEINS          TYPE EKPO-MEINS,
*              MATKL          TYPE EKPO-MATKL,
*              NETPR          TYPE  EKPO-NETPR,
*              ZZSET_MATERIAL TYPE EKPO-ZZSET_MATERIAL,
*              WRF_CHARSTC2   TYPE EKPO-WRF_CHARSTC2,
*
*            END OF TY_EKPO_P.

***********************START OF DECLARATION RETURN PO**********************************************
    TYPES: BEGIN OF TY_EKPO_PR,
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
           END OF TY_EKPO_PR.

    TYPES: BEGIN OF TY_EKKO_PR,
             EBELN TYPE EBELN,                               "Purchasing Document Number
             BSART TYPE ESART,
             AEDAT TYPE ERDAT,
             LIFNR TYPE ELIFN,                               "Vendor's account number
             BEDAT TYPE EBDAT,                               "Purchasing Document Date
             KNUMV TYPE	KNUMV,                               "Number of the Document Condition
           END OF TY_EKKO_PR.

    TYPES: BEGIN OF TY_T001W_PR,
             WERKS TYPE WERKS_D,                            "Plant
             NAME1 TYPE NAME1,                              "Name
             STRAS TYPE STRAS,                              "Street and House Number
             ORT01 TYPE ORT01,                              "City
             LAND1 TYPE LAND1,                              "Country Key
             ADRNR TYPE ADRNR,
           END OF TY_T001W_PR.

    TYPES: BEGIN OF TY_LFA1_PR,
             LIFNR TYPE LIFNR,                                "Account Number of Vendor or Creditor
             LAND1 TYPE LAND1_GP,                             "Country Key
             NAME1 TYPE NAME1_GP,                             "Name 1
             ORT01 TYPE ORT01_GP,                             "City
             REGIO TYPE REGIO,                                "Region (State, Province, County)
             STRAS TYPE STRAS_GP,                             "Street and House Number
             STCD3 TYPE STCD3,                                "Tax Number 3
             ADRNR TYPE ADRNR,
           END OF TY_LFA1_PR.

    TYPES: BEGIN OF TY_MAKT_PR,
             MATNR TYPE MATNR,                                "Material Number
             SPRAS TYPE SPRAS,                                "Language Key
             MAKTX TYPE MAKTX,                                "Material description
           END OF TY_MAKT_PR.

    TYPES: BEGIN OF TY_KONV_PR,
             KNUMV TYPE KNUMV,                                "Number of the Document Condition
             KPOSN TYPE KPOSN,                                "Condition item number
             STUNR TYPE STUNR,                                "Step Number
             ZAEHK TYPE DZAEHK,                               "Condition Counter
             KSCHL TYPE KSCHA,                                "Condition type
           END OF TY_KONV_PR.

    TYPES: BEGIN OF TY_MSEG_PR,
             EBELN TYPE EBELN,
             MBLNR TYPE MBLNR,                                "RETURN NO./DOCUMENT NO.
           END OF TY_MSEG_PR.

    TYPES: BEGIN OF TY_MKPF_PR,
             MBLNR TYPE MBLNR,
             BLDAT TYPE BLDAT,                                  " DOCUMENT DATE
           END OF TY_MKPF_PR.

    TYPES: BEGIN OF TY_J_1BBRANCH_PR,
             BUKRS TYPE BUKRS,                                  "COMPANY CODE
             GSTIN TYPE J_1IGSTCD3,                             "GST NO
           END OF TY_J_1BBRANCH_PR.

    TYPES: BEGIN OF TY_ADR6_PR,
             ADDRNUMBER TYPE AD_ADDRNUM,
             SMTP_ADDR  TYPE AD_SMTPADR,
           END OF TY_ADR6_PR.

    TYPES: BEGIN OF TY_ZINW_T_HDR_PR,
             QR_CODE    TYPE ZQR_CODE,
             EBELN      TYPE EBELN,
             TRNS       TYPE ZTRANS,                               "TRANSPORTER
             LR_NO      TYPE ZLR,                                   "LR NO
             BILL_NUM   TYPE ZBILL_NUM,                             "vendor invoice number
             BILL_DATE  TYPE ZBILL_DAT,                            "vendor invoice date
             ACT_NO_BUD TYPE ZNO_BUD,
             MBLNR      TYPE MBLNR,
             MBLNR_103  TYPE MBLNR,
             RETURN_PO  TYPE EBELN,
           END OF TY_ZINW_T_HDR_PR.

    TYPES: BEGIN OF TY_KNA1_PR,
             ADRNR TYPE ADRNR,                                    "PLANT ADDRESS NO
             NAME1 TYPE NAME1_GP,                                 "PLANT NAME
             SORTL TYPE SORTL,                                    "PLANT AREA
           END OF TY_KNA1_PR.

*TYPES: BEGIN OF TY_MEPO1211,
*        MATNR TYPE MATNR,
*        RETPO TYPE RETPO,                                     "RETURN ITEMS
*        END OF TY_MEPO1211.
    TYPES : BEGIN OF TY_ADRC_PR,
              ADDRNUMBER TYPE  ADRC-ADDRNUMBER,
              NAME1      TYPE ADRC-NAME1,
              CITY1      TYPE ADRC-CITY1,
              STREET     TYPE ADRC-STREET,
              STR_SUPPL1 TYPE ADRC-STR_SUPPL1,
              STR_SUPPL2 TYPE ADRC-STR_SUPPL2,
              COUNTRY    TYPE ADRC-COUNTRY,
              LANGU      TYPE ADRC-LANGU,
              REGION     TYPE ADRC-REGION,
              POST_CODE1 TYPE ADRC-POST_CODE1,
            END OF TY_ADRC_PR.

    TYPES :BEGIN OF TY_T005U_PR,
             SPRAS TYPE T005U-SPRAS,
             LAND1 TYPE T005U-LAND1,
             BLAND TYPE T005U-BLAND,
             BEZEI TYPE T005U-BEZEI,
           END OF TY_T005U_PR.

    TYPES : BEGIN OF TY_T005T_PR,
              SPRAS TYPE SPRAS,
              LAND1 TYPE LAND1,
              LANDX TYPE LANDX,
            END OF TY_T005T_PR.

    TYPES : BEGIN OF TY_EKBE_PR,
              EBELN TYPE EBELN,
              VGABE TYPE VGABE,
              BELNR TYPE MBLNR,
              BUDAT TYPE BUDAT,
            END OF TY_EKBE_PR.

    TYPES : BEGIN OF TY_ZINW_T_ITEM_PR,
              QR_CODE  TYPE   ZINW_T_ITEM-QR_CODE,
              EBELN    TYPE   ZINW_T_ITEM-EBELN,
              MATNR    TYPE   ZINW_T_ITEM-MATNR,
              WERKS    TYPE   ZINW_T_ITEM-WERKS,
              STEUC    TYPE  ZINW_T_ITEM-STEUC,
              NETPR_GP TYPE ZINW_T_ITEM-NETPR_GP,
            END OF TY_ZINW_T_ITEM_PR.


    TYPES : BEGIN OF TY_ZINW_T_STATUS_PR,
              INWD_DOC     TYPE ZINWD_DOC,
              QR_CODE      TYPE ZQR_CODE,
              STATUS_FIELD TYPE ZSTATUS_FIELD,
              STATUS_VALUE TYPE ZSTATUS_VALUE,
              DESCRIPTION  TYPE ZDESCRIPTION,
              CREATED_DATE TYPE ERDAT,
              CREATED_TIME TYPE ERZET,
              CREATED_BY   TYPE ERNAM,
            END OF TY_ZINW_T_STATUS_PR.

    TYPES : BEGIN OF TY_MARA,
              MATNR TYPE MARA-MATNR,
              EAN11 TYPE MARA-EAN11,
            END OF TY_MARA.



    DATA : WA_ZINW_T_STATUS_PR TYPE TY_ZINW_T_STATUS_PR.
    DATA: IT_EKKO_PR        TYPE TABLE OF TY_EKKO_PR,
          IT_EKKO1_PR       TYPE TABLE OF TY_EKKO_PR,
          WA_EKKO_PR        TYPE TY_EKKO_PR,
          WA_EKKO1_PR       TYPE TY_EKKO_PR,
          IT_EKPO_PR        TYPE  TABLE OF  TY_EKPO_PR,
          WA_EKPO_PR        TYPE TY_EKPO_PR,
          IT_T001W_PR       TYPE TABLE OF TY_T001W_PR,
          WA_T001W_PR       TYPE TY_T001W_PR,
          WA_T005U_PR       TYPE TY_T005U_PR,
          WA_T005U1_PR      TYPE TY_T005U_PR,
          WA_T005T_PR       TYPE TY_T005T_PR,
          WA_T005T1_PR      TYPE TY_T005T_PR,
          WA_ADRC_PR        TYPE TY_ADRC_PR,
          WA_ADRC1_PR       TYPE TY_ADRC_PR,
          IT_LFA1_PR        TYPE TABLE OF TY_LFA1_PR,
          WA_LFA1_PR        TYPE TY_LFA1_PR,
          WA_EKBE_PR        TYPE TY_EKBE_PR,
          IT_MAKT_PR        TYPE TABLE OF TY_MAKT_PR,
          WA_MAKT_PR        TYPE TY_MAKT_PR,
          IT_KONV_PR        TYPE TABLE OF TY_KONV_PR,
          WA_KONV_PR        TYPE TY_KONV_PR,
          IT_MSEG_PR        TYPE TABLE OF TY_MSEG_PR,
          WA_MSEG_PR        TYPE TY_MSEG_PR,
          IT_MKPF_PR        TYPE TABLE OF TY_MKPF_PR,
          WA_MKPF_PR        TYPE TY_MKPF_PR,
          IT_J_1BBRANCH_PR  TYPE TABLE OF TY_J_1BBRANCH_PR,
          WA_J_1BBRANCH_PR  TYPE TY_J_1BBRANCH_PR,
          IT_ADR6_PR        TYPE TABLE OF TY_ADR6_PR,
          WA_ADR6_PR        TYPE TY_ADR6_PR,
          IT_ZINW_T_HDR_PR  TYPE TABLE OF TY_ZINW_T_HDR_PR,
          WA_ZINW_T_HDR_PR  TYPE TY_ZINW_T_HDR_PR,
          IT_KNA1_PR        TYPE TABLE OF TY_KNA1_PR,
          IT_ZINW_T_ITEM_PR TYPE TABLE OF TY_ZINW_T_ITEM_PR,
          WA_KNA1_PR        TYPE TY_KNA1_PR,
          WA_ITEM_PR        TYPE TY_ZINW_T_ITEM_PR,
          IT_MARA_PR        TYPE TABLE OF TY_MARA,
*      IT_MEPO1211   TYPE TABLE OF TY_MEPO1211,
*      WA_MEPO1211   TYPE TY_MEPO1211,
          IT_FINAL          TYPE TABLE OF ZPURCHASE_FINAL,
          WA_FINAL          TYPE ZPURCHASE_FINAL,
          WA_HEADER         TYPE ZPURCHASE_HEADER.

    DATA: FM_NAME  TYPE  RS38L_FNAM.
    DATA: LV_SL(03)  TYPE  I VALUE 0.
    DATA : T_FINAL TYPE TABLE OF ZSERVICE_ITEM,
           W_FINAL TYPE ZSERVICE_ITEM,
           WA_HDR  TYPE ZSER_HDR.

    DATA : SL_NO TYPE I VALUE 1.
    DATA : SERIAL_NO TYPE I.
*           LV_TOT  TYPE SNETWR.
*DATA: lv_ebeln TYPE ekko-ebeln.
*** Types declaration for EKKO table
    TYPES: BEGIN OF TY_HDR,
             EBELN   TYPE EBELN,
             QR_CODE TYPE ZQR_CODE,
           END OF TY_HDR.

*** Types declaration for EKPO table
*TYPES: BEGIN OF TY_ITEM,
*         QR_CODE TYPE    ZQR_CODE,
*         EBELN   TYPE    EBELN,
*         EBELP   TYPE    EBELP,
*         MATNR   TYPE    MATNR,
*         LGORT   TYPE    LGORT_D,
*         WERKS   TYPE    EWERK,
*         MAKTX   TYPE    MAKTX,
*         MATKL   TYPE    MATKL,
*         MENGE_P TYPE    ZMENGE_P,
*         MEINS   TYPE    BSTME,
*       END OF TY_ITEM.

*** Types declaration for Output data structure
    TYPES: BEGIN OF TY_DET,
             EBELN       TYPE EBELN,
             MBLNR       TYPE MBLNR,
             MJAHR       TYPE MJAHR,
             MSG_TYPE(1),
             MESSAGE     TYPE BAPIRET2-MESSAGE,
           END OF TY_DET.

*** Internal Tables Declaration
    DATA: LT_HDR  TYPE STANDARD TABLE OF TY_HDR,
          LT_ITEM TYPE STANDARD TABLE OF ZINW_T_ITEM,
          LT_DET  TYPE STANDARD TABLE OF TY_DET.

*** Work area Declarations
    DATA:
          WA_DET  TYPE TY_DET.

*** BAPI Structure Declaration
    DATA:
      WA_GMVT_HEADER  TYPE BAPI2017_GM_HEAD_01,
      WA_GMVT_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
      WA_GMVT_HEADRET TYPE BAPI2017_GM_HEAD_RET,
      LT_BAPIRET      TYPE STANDARD TABLE OF BAPIRET2,
      LT_GMVT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE.
    FIELD-SYMBOLS :
      <LS_BAPIRET> TYPE BAPIRET2.

    DATA :LV_HED(15) TYPE C,
          LV_VAL(15) TYPE C,
          LV_PER     TYPE KBETR,
          LV_TAX(6)  TYPE C,
*          LV_PER     TYPE char100,
          LV_S(01)   TYPE C VALUE '/'.


    DATA : PO_LINES        TYPE TABLE OF TLINE WITH HEADER LINE,
           PO_TEXT         TYPE THEAD-TDNAME,
           LV_PO_TEXT(100) TYPE C.
**************************END OF PO RETURN TYPES*********************************************************
******************START OF DECLARATION PO CREATE***********************************************************
    TYPES : BEGIN OF TY_MAKT ,
              MATNR TYPE MAKT-MATNR,
              MAKTX TYPE MAKT-MAKTX,
            END OF TY_MAKT .
    DATA: WA_EKKO          TYPE EKKO,
          LV_ADRC          TYPE AD_ADDRNUM,
          LV_VEN           TYPE ADRNR,
          LV_SHP           TYPE ADRNR,
          LV_ADRC1         TYPE ADRNR,
          LV_ADRC2         TYPE ADRNR,
          IT_POITEM        TYPE TABLE OF ZPOITEM,
          WA_POITEM        TYPE ZPOITEM,
          WA_POHEADER      TYPE ZPOHEADER,
*          WA_LFA1       TYPE LFA1,
          IT_EKKO          TYPE TABLE OF EKKO,
          IT_EKKO_P        TYPE TABLE OF EKKO,
*          IT_EKPO_P        TYPE TABLE OF TY_EKPO,
          IT_EKPO_P        TYPE TABLE OF TY_EKPO,
          WA_EKPO_P        TYPE  TY_EKPO,
          WA_EKKO_P        TYPE  EKKO,
          IT_ZINW_T_ITEM_P TYPE TABLE OF ZINW_T_ITEM,
          WA_ZINW_T_ITEM_P TYPE  ZINW_T_ITEM,
*          WA_EKPO_P        TYPE  TY_EKPO,
          WA_ZINW_T_HDR    TYPE ZINW_T_HDR,
*          WA_EKKO TYPE EKKO,
          IT_EKPO          TYPE TABLE OF TY_EKPO,
          IT_EKPO1         TYPE TABLE OF TY_EKPO,
          WA_EKPO          TYPE  TY_EKPO,
          WA_EKPO_SET      TYPE  TY_EKPO,
          WA_EKPO1         TYPE  TY_EKPO,
*          WA_ADRC       TYPE ADRC,
          IT_MARA          TYPE TABLE OF MARA,
          WA_MARA          TYPE  MARA,
          IT_MAKT          TYPE TABLE OF TY_MAKT,
          IT_MAKT_T        TYPE TABLE OF TY_MAKT,
          WA_MAKT          TYPE TY_MAKT,
          WA_MAKT_T        TYPE TY_MAKT,
          LV_WORDS(100)    TYPE C,
          IT_O_WGH01       TYPE TABLE OF WGH01,
          WA_O_WGH01       TYPE WGH01.
    DATA : LV_POITEM TYPE EBELP.
*************************END OF DECLARATION OF PO_CREATE****************************************************************************
*********************************MAIL**************************************************************************************************
    DATA  : FMNAME TYPE RS38L_FNAM.
    DATA  : FMNAME1 TYPE RS38L_FNAM.
*    DATA  : FM_NAME TYPE RS38L_FNAM.
    DATA : SEND_REQUEST            TYPE REF TO CL_BCS,
           V_SEND_REQUEST          TYPE REF TO CL_SAPUSER_BCS,
           DOCUMENT                TYPE REF TO CL_DOCUMENT_BCS,
           RECIPIENT               TYPE REF TO IF_RECIPIENT_BCS,
           I_SENDER                TYPE REF TO IF_SENDER_BCS,
           BCS_EXCEPTION           TYPE REF TO CX_BCS,
           MAIN_TEXT               TYPE BCSY_TEXT,
           MAIN_TEXT1              TYPE BCSY_TEXT,
           LS_MAIN_TEXT            LIKE LINE OF MAIN_TEXT,
           LS_MAIN_TEXT1           LIKE LINE OF MAIN_TEXT,
           LS_TEXT                 TYPE SO_TEXT255,
           LS_TEXT1                TYPE SO_TEXT255,
           LS_TEXT2                TYPE SO_TEXT255,
           LS_TEXT3                TYPE SO_TEXT255,
           BINARY_CONTENT          TYPE SOLIX_TAB,
           SIZE                    TYPE SO_OBJ_LEN,
           SENT_TO_ALL             TYPE OS_BOOLEAN,
           SUBJECT                 TYPE SOOD-OBJDES,
           I_SUB                   TYPE SO_OBJ_DES,
           U,
*           FMNAME                  TYPE RS38L_FNAM,
           LS_OUTPUTOP             TYPE SSFCOMPOP,
           LT_PDF_DATA             TYPE SOLIX_TAB,
           LT_PDF_DATA1            TYPE SOLIX_TAB,
           LT_PDF_DATA2            TYPE SOLIX_TAB,
           LT_PDF_DATA3            TYPE SOLIX_TAB,
           LT_PDF_DATA4            TYPE SOLIX_TAB,
           LT_MAIL_BODY            TYPE SOLI_TAB,
           LT_OBJTEXT              TYPE TABLE OF SOLISTI1,
           LT_OBJPACK              TYPE TABLE OF SOPCKLSTI1,
           LT_LINES                TYPE TABLE OF TLINE,
           LT_LINES1               TYPE TABLE OF TLINE,
           LT_LINES2               TYPE TABLE OF TLINE,
           LT_LINES3               TYPE TABLE OF TLINE,
           LT_LINES4               TYPE TABLE OF TLINE,
           LT_RECORD               TYPE TABLE OF SOLISTI1,
           LT_OTF                  TYPE TSFOTF,
           LT_OTF1                 TYPE TSFOTF,
           LT_OTF2                 TYPE TSFOTF,
           LT_OTF3                 TYPE TSFOTF,
           LT_OTF4                 TYPE TSFOTF,
           LT_MAIL_SENDER          TYPE BAPIADSMTP_T,
           LT_MAIL_RECIPIENT       TYPE BAPIADSMTP_T,
           LS_CTRLOP               TYPE SSFCTRLOP,
           IS_CONTROL_PARAMETERS   TYPE SSFCTRLOP,
           IS_OUTPUT_OPTIONS       TYPE SSFCOMPOP,
           LS_DOCUMENT_OUTPUT_INFO TYPE SSFCRESPD,
           LS_JOB_OUTPUT_INFO      TYPE SSFCRESCL,
           LS_JOB_OUTPUT_OPTIONS   TYPE SSFCRESOP,
           LV_OTF                  TYPE XSTRING,
           LV_OTF1                 TYPE XSTRING,
           LV_OTF2                 TYPE XSTRING,
           LV_OTF3                 TYPE XSTRING,
           LV_OTF4                 TYPE XSTRING,
           LS_BIN_FILESIZE         TYPE SOOD-OBJLEN,
           LS_BIN_FILESIZE1        TYPE SOOD-OBJLEN,
           LS_BIN_FILESIZE2        TYPE SOOD-OBJLEN,
           LS_BIN_FILESIZE3        TYPE SOOD-OBJLEN,
           LS_BIN_FILESIZE4        TYPE SOOD-OBJLEN,
*           WA_ITOB                 TYPE ITOB,
           LV_DOC_SUBJECT          TYPE SOOD-OBJDES,
           LV_DOC_SUBJECT1         TYPE SOOD-OBJDES,
           LV_DOC_SUBJECT2         TYPE SOOD-OBJDES,
           LV_DOC_SUBJECT3         TYPE SOOD-OBJDES,
           LV_DOC_SUBJECT4         TYPE SOOD-OBJDES,
           LT_RECLIST              TYPE BCSY_SMTPA,
           LS_RECLIST              TYPE  AD_SMTPADR,
*           LS_SMAIL                TYPE ZSALES_EMAIL,
           I_ADDRESS_STRING        TYPE ADR6-SMTP_ADDR,
           ES_MSG(100)             TYPE C.
    DATA : LV_A       TYPE C,
           LV_B       TYPE C,
           LV_C       TYPE C,
           LV_DEL     TYPE SY-DATUM,
           LV_DEL1    TYPE SY-DATUM,
           LV_GSTIN_V TYPE STCD3,
           LV_GSTIN_C TYPE STCD1,
           LV_PDATE   TYPE T5A4A-DLYDY.
    DATA : LV_NAME   TYPE THEAD-TDNAME,
           LV_NAME1  TYPE THEAD-TDNAME,
           LV_NAME2  TYPE THEAD-TDNAME,
           LV_NAME3  TYPE THEAD-TDNAME,
           IT_LINES  TYPE TABLE OF TLINE WITH HEADER LINE,
           IT_LINES2 TYPE TABLE OF TLINE WITH HEADER LINE,
           IT_LINES3 TYPE TABLE OF TLINE WITH HEADER LINE,
           SET(03)   VALUE 'SET'.
    DATA :LV_BILLD      TYPE ZBILL_DAT,
          LV_RPO        TYPE EBELN,
          LV_ERNAME(12) TYPE C.
    DATA :  PO_QR  TYPE EBELN.
***************************************************END OF MAIL****************************************************************************************
******************************************************GET DATA OF PO CREATION***************************************************************************
*    IF LV_EBELN IS NOT INITIAL.
*    BREAK BREDDY.
    SELECT EKKO~EBELN ,
           EKKO~EKGRP ,
           EKKO~BUKRS ,
           EKKO~AEDAT ,
           EKKO~BEDAT ,
           EKKO~LIFNR ,
           EKKO~USER_NAME ,
           EKKO~ERNAM ,
           EKKO~ZINDENT FROM EKKO  INTO  CORRESPONDING FIELDS OF TABLE @IT_EKKO
                        WHERE EBELN = @LV_EBELN .
*    ENDIF.
    READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
    IF WA_EKKO IS NOT INITIAL.
      SELECT SINGLE
        LFA1~NAME1,
        LFA1~ADRNR ,
        LFA1~WERKS ,
        LFA1~STCD3 ,
        LFA1~LIFNR INTO @DATA(WA_LFA1) FROM LFA1 WHERE LIFNR = @WA_EKKO-LIFNR.
      SELECT
        EKPO~EBELN ,
        EKPO~EBELP ,
        EKPO~MENGE ,
        EKPO~WERKS ,
        EKPO~MATNR ,
        EKPO~MEINS ,
        EKPO~MATKL ,
        EKPO~NETPR ,
        EKPO~NETWR ,
        EKPO~ZZSET_MATERIAL  ,
        EKPO~WRF_CHARSTC2 ,
        EKPO~ZZTEXT100
        FROM EKPO INTO TABLE  @IT_EKPO WHERE EBELN = @LV_EBELN ."AND ZZSET_MATERIAL = '128703-7-8-9-10'.
    ENDIF.
*    READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
    READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = LV_EBELN.

    IF IT_EKPO IS NOT INITIAL.
      SELECT SINGLE T001W~ADRNR  FROM T001W INTO @DATA(LV_PADRNR) WHERE WERKS = @WA_EKPO-WERKS.
      SELECT SINGLE LFA1~STCD3   FROM LFA1 INTO @WA_POHEADER-GSTINP WHERE WERKS = @WA_EKPO-WERKS.
      SELECT MATNR MAKTX   FROM MAKT INTO TABLE IT_MAKT FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-ZZSET_MATERIAL.
    ENDIF.


    IF WA_EKKO IS NOT INITIAL.
      SELECT SINGLE T001~BUKRS , T001~ADRNR FROM T001 INTO @DATA(WA_T001) WHERE BUKRS = @WA_EKKO-BUKRS.
      SELECT SINGLE J_1BBRANCH~BUKRS, J_1BBRANCH~GSTIN FROM J_1BBRANCH INTO @DATA(WA_J_1BBRANCH) WHERE BUKRS = @WA_EKKO-BUKRS.
      SELECT SINGLE EKNAM FROM T024 INTO @DATA(LV_GROUP) WHERE EKGRP = @WA_EKKO-EKGRP .
    ENDIF.
    LV_ADRC = WA_LFA1-ADRNR.
    LV_ADRC1 = LV_PADRNR.
    LV_ADRC2 = LV_PADRNR.

*    ENDIF.
*    BREAK BREDDY.
    SELECT MARA~MATNR  MARA~MATKL  MARA~ZZPO_ORDER_TXT  MARA~SIZE1 MARA~COLOR EAN11 FROM MARA INTO CORRESPONDING FIELDS OF TABLE IT_MARA FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-MATNR .
    SELECT T023T~MATKL , T023T~WGBEZ , T023T~WGBEZ60 FROM T023T INTO TABLE @DATA(IT_T023T) FOR ALL ENTRIES IN @IT_EKPO WHERE MATKL = @IT_EKPO-MATKL.
*    SELECT * FROM MAKT INTO TABLE IT_MAKT
*      FOR ALL ENTRIES IN PO_ITEM
*      WHERE MATNR = PO_ITEM-MATNR AND SPRAS EQ SY-LANGU.
    IF IT_MARA IS NOT INITIAL.
      SELECT MAKT~MATNR ,
             MAKT~MAKTX   FROM MAKT INTO TABLE @DATA(IT_MAKT1) FOR ALL ENTRIES IN @IT_MARA WHERE MATNR = @IT_MARA-MATNR.
    ENDIF.

    WA_POHEADER-AD_NAME = WA_LFA1-NAME1.
    WA_POHEADER-LIFNR = WA_LFA1-LIFNR.
    WA_POHEADER-AEDAT =  WA_EKKO-AEDAT  .

*    IF WA_EKKO-USER_NAME IS INITIAL.
    WA_POHEADER-ZUNAME = WA_EKKO-ERNAM.
*    ELSE.
*      LV_ERNAME  =  WA_EKKO-ERNAM.
*    ENDIF.
*    WA_POHEADER-ZUNAME = WA_EKKO-USER_NAME.
    LV_GSTIN_V = WA_LFA1-STCD3.
    LV_GSTIN_C = WA_J_1BBRANCH-GSTIN.
*    BREAK BREDDY .

    SELECT SINGLE EKET~EBELN , EKET~EINDT FROM EKET INTO @DATA(WA_EKET) WHERE EBELN = @LV_EBELN.
    WA_POHEADER-DEL_BY = WA_EKET-EINDT.

    SELECT STPO~STLNR,
           STPO~IDNRK,
           STPO~POSNR,
           STPO~MENGE,
           MAST~MATNR,
           MAST~WERKS,
           MAST~STLAL,
           MARA~SIZE1
           INTO TABLE @DATA(IT_SIZE)
           FROM STPO AS STPO
           INNER JOIN MAST AS MAST ON STPO~STLNR = MAST~STLNR
           INNER JOIN MARA AS MARA ON MARA~MATNR = STPO~IDNRK
           FOR ALL ENTRIES IN @IT_MARA
           WHERE STPO~IDNRK = @IT_MARA-MATNR.
    DATA : LV_NO TYPE CHAR10.
    DATA : LV_NETPR TYPE EKPO-NETPR .
    DATA : LV_TOTAL1 TYPE EKPO-NETPR .
*    CLEAR : LV_POITEM.
*****************************If material is set*******************
    BREAK BREDDY.
    WA_POHEADER-PO_QR = LV_EBELN .
*    CLEAR : SL_NO.

*    LOOP AT IT_EKPO INTO WA_EKPO.
**      BREAK BREDDY.
*
*      IF WA_EKPO-ZZSET_MATERIAL IS NOT INITIAL.
*        DATA(IT_EKPO_SET) = IT_EKPO.
*        DELETE IT_EKPO_SET WHERE ZZSET_MATERIAL <> WA_EKPO-ZZSET_MATERIAL.          "" AND NETPR <> WA_EKPO-NETPR.
*        SORT IT_EKPO_SET BY ZZSET_MATERIAL   NETPR.               ""NETPR.
*        DESCRIBE TABLE IT_EKPO_SET LINES DATA(LV_LINES_SET).
*        DELETE ADJACENT DUPLICATES FROM IT_EKPO_SET COMPARING ZZSET_MATERIAL NETPR .                            ""NETPR.
*        READ TABLE IT_EKPO_SET INTO WA_EKPO_SET WITH KEY ZZSET_MATERIAL = WA_EKPO-ZZSET_MATERIAL.
*        READ TABLE IT_POITEM WITH KEY MATNR = WA_EKPO-ZZSET_MATERIAL TRANSPORTING NO FIELDS .
*        IF SY-SUBRC <> 0.
**          WA_POITEM-MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
**
**          WA_POITEM-MT_GRP = WA_EKPO_SET-MATKL.
****************ADDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
**          READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
**          IF SY-SUBRC = 0.
**            WA_POITEM-MAKTX = WA_MAKT-MAKTX .
**          ENDIF.
***************ENDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
*          LV_POITEM = LV_POITEM + 10.
*          LOOP AT IT_EKPO_SET  ASSIGNING FIELD-SYMBOL(<LS_EKPO>) WHERE  ZZSET_MATERIAL = WA_EKPO-ZZSET_MATERIAL .
*            WA_POITEM-MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
*            WA_POITEM-MT_GRP = WA_EKPO_SET-MATKL.
***************ADDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
*            READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
*            IF SY-SUBRC = 0.
*              WA_POITEM-MAKTX = WA_MAKT-MAKTX .
*            ENDIF.
**************ENDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
*
*            LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPO1>) WHERE ZZSET_MATERIAL = <LS_EKPO>-ZZSET_MATERIAL AND NETPR = <LS_EKPO>-NETPR.
**            AT NEW WRF_CHARSTC2 .
*
*
**              IF WA_POITEM-SIZE = <LS_EKPO1>-WRF_CHARSTC2.
**                IF SY-SUBRC = 0 .
*              IF WA_POITEM-SIZE IS INITIAL.
*                WA_POITEM-SIZE =  <LS_EKPO1>-WRF_CHARSTC2 .
*              ELSEIF WA_POITEM-SIZE NS <LS_EKPO1>-WRF_CHARSTC2.
*                WA_POITEM-SIZE = WA_POITEM-SIZE && '-' && <LS_EKPO1>-WRF_CHARSTC2 .
*              ENDIF.
*
**              ADD <LS_EKPO1>-MENGE TO WA_POITEM-MENGE .
*              WA_POITEM-MENGE = <LS_EKPO1>-MENGE + WA_POITEM-MENGE.
*              LV_NETPR = <LS_EKPO1>-NETPR * <LS_EKPO1>-MENGE .
*              WA_POITEM-NETAMT  =  WA_POITEM-NETAMT + LV_NETPR .
*              WA_POITEM-NETPR =   <LS_EKPO1>-NETPR  .                             ""WA_POITEM-NETPR    .      ""
*              CLEAR LV_NETPR .
**            CONCATENATE  WA_POITEM-SIZE '-'  WA_EKPO_SET-WRF_CHARSTC2  INTO  WA_POITEM-SIZE .
*              ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*              WA_POHEADER-TOTAL =  WA_POITEM-NETAMT .
*
**              ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
*
*            ENDLOOP .
**            BREAK BREDDY .
*            LV_TOTAL1 =  WA_POITEM-NETAMT + LV_TOTAL1  .
*            ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
*
*            CLEAR: WA_MARA.
*
*            READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T1>) WITH KEY MATKL = WA_EKPO-MATKL.
**          IF SY-SUBRC = 0 AND WA_POITEM-WGBEZ IS INITIAL  .
**            WA_POITEM-WGBEZ = <WA_T023T1>-WGBEZ60.
**          ENDIF.
*
*            REFRESH :IT_LINES[].
*            CLEAR LV_NAME1.
*            CONCATENATE LV_EBELN WA_EKPO_SET-EBELP INTO LV_NAME1.
*            CALL FUNCTION 'READ_TEXT'
*              EXPORTING
**               CLIENT                  = SY-MANDT
*                ID                      = 'F03'
*                LANGUAGE                = 'E'
*                NAME                    = LV_NAME1
*                OBJECT                  = 'EKPO'
**               ARCHIVE_HANDLE          = 0
**               LOCAL_CAT               = ' '
**       IMPORTING
**               HEADER                  =
**               OLD_LINE_COUNTER        =
*              TABLES
*                LINES                   = IT_LINES[]
*              EXCEPTIONS
*                ID                      = 1
*                LANGUAGE                = 2
*                NAME                    = 3
*                NOT_FOUND               = 4
*                OBJECT                  = 5
*                REFERENCE_CHECK         = 6
*                WRONG_ACCESS_TO_ARCHIVE = 7
*                OTHERS                  = 8.
*            IF SY-SUBRC <> 0.
** Implement suitable error handling here
*            ENDIF.
*            LOOP AT IT_LINES.
*              CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
*              CLEAR IT_LINES .
*            ENDLOOP.
*
*            REFRESH :IT_LINES2[].
*            CLEAR LV_NAME2.
*            CONCATENATE LV_EBELN WA_EKPO_SET-EBELP INTO LV_NAME2.
*            CALL FUNCTION 'READ_TEXT'
*              EXPORTING
**               CLIENT                  = SY-MANDT
*                ID                      = 'F07'
*                LANGUAGE                = 'E'
*                NAME                    = LV_NAME2
*                OBJECT                  = 'EKPO'
**               ARCHIVE_HANDLE          = 0
**               LOCAL_CAT               = ' '
**       IMPORTING
**               HEADER                  =
**               OLD_LINE_COUNTER        =
*              TABLES
*                LINES                   = IT_LINES2[]
*              EXCEPTIONS
*                ID                      = 1
*                LANGUAGE                = 2
*                NAME                    = 3
*                NOT_FOUND               = 4
*                OBJECT                  = 5
*                REFERENCE_CHECK         = 6
*                WRONG_ACCESS_TO_ARCHIVE = 7
*                OTHERS                  = 8.
*            IF SY-SUBRC <> 0.
** Implement suitable error handling here
*            ENDIF.
*
*
*            LOOP AT IT_LINES2.
*              CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*              CLEAR IT_LINES2 .
*            ENDLOOP.
**          CLEAR : wa_mara.
*            READ TABLE IT_MARA ASSIGNING FIELD-SYMBOL(<WA_MARA>)  WITH KEY MATNR = WA_EKPO-MATNR.
*
*            IF <WA_MARA>-EAN11 IS NOT INITIAL.
*
*              WA_POITEM-EAN11 = <WA_MARA>-EAN11.
*
*            ENDIF.
*            IF <WA_MARA>-MATKL IS NOT INITIAL .
*              CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*                EXPORTING
*                  MATKL       = <WA_MARA>-MATKL
*                  SPRAS       = SY-LANGU
*                TABLES
*                  O_WGH01     = IT_O_WGH01
*                EXCEPTIONS
*                  NO_BASIS_MG = 1
*                  NO_MG_HIER  = 2
*                  OTHERS      = 3.
*              IF SY-SUBRC <> 0.
** Implement suitable error handling here
*              ENDIF.
*            ENDIF.
*            READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
*            IF SY-SUBRC = 0.
*              WA_POHEADER-GROUP_ID = WA_O_WGH01-WWGHA.
*              CLEAR WA_O_WGH01.
*            ENDIF.
*            IF <WA_MARA>-COLOR IS NOT INITIAL.
*              WA_POITEM-COLOR = <WA_MARA>-COLOR.
*            ELSE.
*              REFRESH :IT_LINES3[].
*              CLEAR LV_NAME3.
*              CONCATENATE LV_EBELN WA_EKPO_SET-EBELP INTO LV_NAME3.
*              CALL FUNCTION 'READ_TEXT'
*                EXPORTING
**                 CLIENT                  = SY-MANDT
*                  ID                      = 'F08'
*                  LANGUAGE                = 'E'
*                  NAME                    = LV_NAME3
*                  OBJECT                  = 'EKPO'
**                 ARCHIVE_HANDLE          = 0
**                 LOCAL_CAT               = ' '
**       IMPORTING
**                 HEADER                  =
**                 OLD_LINE_COUNTER        =
*                TABLES
*                  LINES                   = IT_LINES3[]
*                EXCEPTIONS
*                  ID                      = 1
*                  LANGUAGE                = 2
*                  NAME                    = 3
*                  NOT_FOUND               = 4
*                  OBJECT                  = 5
*                  REFERENCE_CHECK         = 6
*                  WRONG_ACCESS_TO_ARCHIVE = 7
*                  OTHERS                  = 8.
*              IF SY-SUBRC <> 0.
** Implement suitable error handling here
*              ENDIF.
*
*              LOOP AT IT_LINES3.
*                CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*                CLEAR IT_LINES3 .
*              ENDLOOP.
*            ENDIF.
****          SHIFT  WA_POITEM-SIZE LEFT DELETING LEADING '-' .
*
*
*
***********added by bhavani 17.09.2019***********
*
*            IF WA_LFA1-LIFNR IS NOT INITIAL.
*              SELECT SINGLE
*                SMTP_ADDR FROM ADR6 INTO I_ADDRNUMBER WHERE ADDRNUMBER = WA_LFA1-ADRNR .
*            ENDIF.
*
***********ended by bhavani 17.09.2019***********
*
*            WA_POITEM-ZSL =  SL_NO.
*            APPEND WA_POITEM TO IT_POITEM.
*            SL_NO = SL_NO + 1.
**          LV_TOTAL1 =  WA_POITEM-NETAMT + LV_TOTAL1  .
**          ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
**          ENDLOOP.
*            CLEAR : WA_POITEM.
*          ENDLOOP .
*        ENDIF.
*
*      ELSE.
**        CLEAR : LV_TOTAL1 .
**        CLEAR : SL_NO.
***        LOOP AT IT_EKPO INTO WA_EKPO.
**        SL_NO = SL_NO + 1.
**        WA_POITEM-ZSL = SL_NO.
*        WA_POITEM-MENGE = WA_EKPO-MENGE.
*        WA_POITEM-NETPR = WA_EKPO-NETPR.
*        WA_POITEM-MT_GRP = WA_EKPO-MATKL.
*        WA_POITEM-NETAMT  = WA_EKPO-NETPR * WA_EKPO-MENGE.
*        ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*        ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
*        LV_TOTAL1  = WA_POITEM-NETAMT  + LV_TOTAL1 .
**        LV_POITEM = LV_POITEM + 10.
**        WA_POITEM-EBELP = LV_POITEM.
*        CLEAR: WA_MAKT, WA_MARA.
**        READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_PO_ITEM-MATNR .
*        READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T>) WITH KEY MATKL = WA_EKPO-MATKL.
*        IF SY-SUBRC = 0.
*          WA_POITEM-WGBEZ = <WA_T023T>-WGBEZ60.
*        ENDIF.
*        REFRESH :IT_LINES[].
*
*        CLEAR LV_NAME1.
*        CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME1.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F03'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME1
*            OBJECT                  = 'EKPO'
*          TABLES
*            LINES                   = IT_LINES[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES.
*
*          CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
*          CLEAR IT_LINES .
*
*        ENDLOOP.
*
*        REFRESH :IT_LINES2[].
*
*        CLEAR LV_NAME2.
*        CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME2.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F07'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME2
*            OBJECT                  = 'EKPO'
**           ARCHIVE_HANDLE          = 0
**           LOCAL_CAT               = ' '
**       IMPORTING
**           HEADER                  =
**           OLD_LINE_COUNTER        =
*          TABLES
*            LINES                   = IT_LINES2[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES2.
*
*          CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*          CLEAR IT_LINES2 .
*
*        ENDLOOP.
*        CLEAR : WA_MARA.
*        READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = WA_EKPO-MATNR .
*        WA_POITEM-MAKTX = WA_MARA-ZZPO_ORDER_TXT .
*        IF WA_MARA-EAN11 IS NOT INITIAL.
*          WA_POITEM-EAN11 = WA_MARA-EAN11.
*        ENDIF.
*        READ TABLE IT_MAKT1 ASSIGNING FIELD-SYMBOL(<WA_MAKT1>) WITH  KEY MATNR = WA_MARA-MATNR .
**        IF SY-SUBRC = 0.
**          WA_POITEM-MAKTX = <WA_MAKT1>-MAKTX .
**        ENDIF.
*        WA_POITEM-SIZE = WA_MARA-SIZE1.
*        IF WA_MARA-COLOR IS NOT INITIAL.
*          WA_POITEM-COLOR = WA_MARA-COLOR.
*        ELSE.
*          REFRESH :IT_LINES3[].
*
*          CLEAR LV_NAME3.
*          CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME3.
*          CALL FUNCTION 'READ_TEXT'
*            EXPORTING
**             CLIENT                  = SY-MANDT
*              ID                      = 'F08'
*              LANGUAGE                = 'E'
*              NAME                    = LV_NAME3
*              OBJECT                  = 'EKPO'
**             ARCHIVE_HANDLE          = 0
**             LOCAL_CAT               = ' '
**       IMPORTING
**             HEADER                  =
**             OLD_LINE_COUNTER        =
*            TABLES
*              LINES                   = IT_LINES3[]
*            EXCEPTIONS
*              ID                      = 1
*              LANGUAGE                = 2
*              NAME                    = 3
*              NOT_FOUND               = 4
*              OBJECT                  = 5
*              REFERENCE_CHECK         = 6
*              WRONG_ACCESS_TO_ARCHIVE = 7
*              OTHERS                  = 8.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*
*
*          LOOP AT IT_LINES3.
*
*            CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*            CLEAR IT_LINES3 .
*
*          ENDLOOP.
*        ENDIF.
*        IF WA_MARA-MATKL IS NOT INITIAL.
*
*          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*            EXPORTING
*              MATKL       = WA_MARA-MATKL
*              SPRAS       = SY-LANGU
*            TABLES
*              O_WGH01     = IT_O_WGH01
*            EXCEPTIONS
*              NO_BASIS_MG = 1
*              NO_MG_HIER  = 2
*              OTHERS      = 3.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*        ENDIF.
*
*        READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
*        IF SY-SUBRC = 0.
*          WA_POHEADER-GROUP_ID = WA_O_WGH01-WWGHA.
*          CLEAR WA_O_WGH01.
*        ENDIF.
*
*
***********added by bhavani 17.09.2019***********
*
*        IF WA_LFA1-LIFNR IS NOT INITIAL.
*          SELECT SINGLE
*            SMTP_ADDR FROM ADR6 INTO I_ADDRNUMBER WHERE ADDRNUMBER = WA_LFA1-ADRNR .
*        ENDIF.
*
***********ended by bhavani 17.09.2019********
**        BREAK BREDDY.
*        WA_POITEM-ZSL =  SL_NO.
*        APPEND WA_POITEM TO IT_POITEM.
*        SL_NO = SL_NO + 1.
*        CLEAR : WA_POITEM.
*      ENDIF.
*    ENDLOOP.






******changes done by bhavani 22.11.2019*********
    SELECT
      ZPH_T_ITEM~INDENT_NO     ,
      ZPH_T_ITEM~ITEM          ,
      ZPH_T_ITEM~VENDOR        ,
      ZPH_T_ITEM~CATEGORY_CODE ,
      ZPH_T_ITEM~FROM_SIZE     ,
      ZPH_T_ITEM~TO_SIZE       ,
      ZPH_T_ITEM~QUANTITY      ,
      ZPH_T_ITEM~PRICE    ,
      ZPH_T_ITEM~ZTEXT100 ,
      ZPH_T_ITEM~COLOR ,
      ZPH_T_ITEM~STYLE  FROM ZPH_T_ITEM INTO TABLE @DATA(IT_ZPH_T_ITEM)
                          FOR ALL ENTRIES IN @IT_EKKO
                          WHERE INDENT_NO = @IT_EKKO-ZINDENT .


    BREAK BREDDY .
    DATA :LV_TEXT100    TYPE ZTEXT,
          LV_PRICEB(11) TYPE C.
*    DATA(LT_POITEM) = IT_EKPO[] .
*    SORT LT_POITEM BY MATKL ZZTEXT100.
*    DELETE ADJACENT DUPLICATES FROM LT_POITEM COMPARING MATKL ZZTEXT100.

**********added by bhavani 17.09.2019***********

    IF WA_LFA1-LIFNR IS NOT INITIAL.
      SELECT SINGLE
        SMTP_ADDR FROM ADR6 INTO I_ADDRNUMBER WHERE ADDRNUMBER = WA_LFA1-ADRNR .
    ENDIF.

**********ended by bhavani 17.09.2019********
*        BREAK BREDDY.



    SORT IT_ZPH_T_ITEM BY ITEM .
    LOOP AT IT_ZPH_T_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
      WA_POHEADER-INDENT_NO = <LS_ITEM>-INDENT_NO .
      READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T>) WITH KEY MATKL = <LS_ITEM>-CATEGORY_CODE.
      IF SY-SUBRC = 0.
        WA_POITEM-WGBEZ = <WA_T023T>-WGBEZ60.
      ENDIF.
*      WA_POITEM-MENGE = <LS_ITEM>-QUANTITY.
      WA_POITEM-MATKL = <LS_ITEM>-CATEGORY_CODE.
      WA_POITEM-NETPR = <LS_ITEM>-PRICE.
      WA_POITEM-FROM_SIZE = <LS_ITEM>-FROM_SIZE.
      WA_POITEM-TO_SIZE = <LS_ITEM>-TO_SIZE.
*      WA_POITEM-NETPR = <LS_ITEM>-PRICE.
*      LOOP AT LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>)  WHERE MATKL = <LS_ITEM>-CATEGORY_CODE.
      LV_PRICEB = <LS_ITEM>-PRICE .
*      CONCATENATE <LS_ITEM>-CATEGORY_CODE <LS_ITEM>-FROM_SIZE <LS_ITEM>-TO_SIZE LV_PRICEB INTO LV_TEXT100 .
*      DATA(IT_ITEMQ) = IT_EKPO[] .
*      SORT IT_EKPO BY EBELP MATKL ZZTEXT100 .
*      DELETE ADJACENT DUPLICATES FROM IT_EKPO  COMPARING MATKL ZZTEXT100 .
*      LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPOITEM1>) WHERE ZZTEXT100 = . "WHERE MATKL = <LS_POITEM>-MATKL AND ZZTEXT100 = <LS_POITEM>-ZZTEXT100.
      READ TABLE IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_COLOR>) WITH KEY MATKL = <LS_ITEM>-CATEGORY_CODE ZZTEXT100 = <LS_ITEM>-ZTEXT100 .

      IF SY-SUBRC = 0.
        CLEAR : WA_MARA.
        READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = <LS_COLOR>-MATNR .
        IF WA_MARA-EAN11 IS NOT INITIAL.
          WA_POITEM-EAN11 = WA_MARA-EAN11.
        ENDIF.
        READ TABLE IT_MAKT1 ASSIGNING FIELD-SYMBOL(<WA_MAKT1>) WITH  KEY MATNR = WA_MARA-MATNR .
        WA_POITEM-SIZE = WA_MARA-SIZE1.
        IF WA_MARA-COLOR IS NOT INITIAL.
          WA_POITEM-COLOR = WA_MARA-COLOR.
        ELSE .

          WA_POITEM-COLOR = <LS_ITEM>-COLOR .

        ENDIF.
      ENDIF.


      WA_POITEM-STYLE = <LS_ITEM>-STYLE .
      LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPOITEM>) WHERE MATKL = <LS_ITEM>-CATEGORY_CODE  AND ZZTEXT100 = <LS_ITEM>-ZTEXT100 .
        WA_POITEM-NETAMT = <LS_EKPOITEM>-MENGE * <LS_EKPOITEM>-NETPR .
        WA_POITEM-G_TOTAL =  WA_POITEM-G_TOTAL + <LS_EKPOITEM>-NETWR .
        ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
        ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
        LV_TOTAL1  = WA_POITEM-NETAMT  + LV_TOTAL1 .
        WA_POITEM-MENGE = <LS_EKPOITEM>-MENGE + WA_POITEM-MENGE.

*        BREAK BREDDY .

*        CLEAR: WA_MAKT, WA_MARA.


*
*        REFRESH :IT_LINES[].
*
*        CLEAR LV_NAME1.
*        CONCATENATE LV_EBELN <LS_ITEM>-ITEM INTO LV_NAME1.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F03'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME1
*            OBJECT                  = 'EKPO'
*          TABLES
*            LINES                   = IT_LINES[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES.
*
*          CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
*          CLEAR IT_LINES .
*
*        ENDLOOP.
*
*        REFRESH :IT_LINES2[].
*
*        CLEAR LV_NAME2.
*        CONCATENATE LV_EBELN <LS_ITEM>-ITEM INTO LV_NAME2.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F07'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME2
*            OBJECT                  = 'EKPO'
**           ARCHIVE_HANDLE          = 0
**           LOCAL_CAT               = ' '
**       IMPORTING
**           HEADER                  =
**           OLD_LINE_COUNTER        =
*          TABLES
*            LINES                   = IT_LINES2[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES2.
*
*          CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*          CLEAR IT_LINES2 .
*
*        ENDLOOP.
*
*        CLEAR : WA_MARA.
*        READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = <LS_EKPOITEM>-MATNR .
*        IF WA_MARA-EAN11 IS NOT INITIAL.
*          WA_POITEM-EAN11 = WA_MARA-EAN11.
*        ENDIF.
*        READ TABLE IT_MAKT1 ASSIGNING FIELD-SYMBOL(<WA_MAKT1>) WITH  KEY MATNR = WA_MARA-MATNR .
*        WA_POITEM-SIZE = WA_MARA-SIZE1.
*        IF WA_MARA-COLOR IS NOT INITIAL.
*          WA_POITEM-COLOR = WA_MARA-COLOR.
*        ELSE.
*          REFRESH :IT_LINES3[].
*
*          CLEAR LV_NAME3.
*          CONCATENATE LV_EBELN <LS_ITEM>-ITEM INTO LV_NAME3.
*          CALL FUNCTION 'READ_TEXT'
*            EXPORTING
**             CLIENT                  = SY-MANDT
*              ID                      = 'F08'
*              LANGUAGE                = 'E'
*              NAME                    = LV_NAME3
*              OBJECT                  = 'EKPO'
**             ARCHIVE_HANDLE          = 0
**             LOCAL_CAT               = ' '
**       IMPORTING
**             HEADER                  =
**             OLD_LINE_COUNTER        =
*            TABLES
*              LINES                   = IT_LINES3[]
*            EXCEPTIONS
*              ID                      = 1
*              LANGUAGE                = 2
*              NAME                    = 3
*              NOT_FOUND               = 4
*              OBJECT                  = 5
*              REFERENCE_CHECK         = 6
*              WRONG_ACCESS_TO_ARCHIVE = 7
*              OTHERS                  = 8.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*
*
*          LOOP AT IT_LINES3.
*
*            CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*            CLEAR IT_LINES3 .
*
*          ENDLOOP.
*        ENDIF.








      ENDLOOP.



      IF WA_MARA-MATKL IS NOT INITIAL.

        CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
          EXPORTING
            MATKL       = WA_MARA-MATKL
            SPRAS       = SY-LANGU
          TABLES
            O_WGH01     = IT_O_WGH01
          EXCEPTIONS
            NO_BASIS_MG = 1
            NO_MG_HIER  = 2
            OTHERS      = 3.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.

*      BREAK BREDDY .
      READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
      IF SY-SUBRC = 0.
        WA_POHEADER-GROUP_ID = WA_O_WGH01-WWGHA.
        CLEAR WA_O_WGH01.
      ENDIF.




*      ENDLOOP.
*      ENDLOOP.
      WA_POITEM-ZSL =  SL_NO.
      APPEND WA_POITEM TO IT_POITEM.
*      ADD 1 TO SERIAL_NO .
      SL_NO = SL_NO + 1.
      CLEAR : WA_POITEM , LV_TEXT100 , LV_PRICEB  .

    ENDLOOP.
*    DATA CNT TYPE I .
*    DESCRIBE TABLE IT_POITEM LINES DATA(LV_POLINES).
*
*    LV_POLINES = LV_POLINES + CNT .
*    DATA(LV_SN)  =  LV_POLINES + 1 .
*    DO ( 5 - LV_POLINES ) TIMES .
*      APPEND WA_POITEM TO IT_POITEM.
*      CLEAR :WA_POITEM.
*
*    ENDDO.

******ended by bahvani 22.11.2109****************

    DATA : LV_AMT TYPE PC207-BETRG.
    LV_AMT  = LV_TOTAL1.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        AMT_IN_NUM         = LV_AMT
      IMPORTING
        AMT_IN_WORDS       = LV_WORDS
      EXCEPTIONS
        DATA_TYPE_MISMATCH = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        INPUT_STRING  = LV_WORDS
      IMPORTING
        OUTPUT_STRING = LV_WORDS.
******************************************************END OF PO CREATION**********************************************************
*****************************************SATRT OF PO RETURN DECLARATION*****************************************************************

*    BREAK BREDDY.
*    if p_ebeln is INITIAL.
    SELECT SINGLE
  EBELN
  BSART
  AEDAT
  LIFNR
  BEDAT
  KNUMV
   FROM EKKO INTO WA_EKKO_PR WHERE EBELN = LV_EBELN.



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
      FROM EKPO INTO TABLE IT_EKPO_PR WHERE EBELN = LV_EBELN AND RETPO = 'X'.

    SELECT
      MATNR
      EAN11 FROM MARA INTO TABLE IT_MARA_PR
            FOR ALL ENTRIES IN IT_EKPO_PR
            WHERE MATNR = IT_EKPO_PR-MATNR.

    READ TABLE IT_EKPO_PR INTO WA_EKPO_PR INDEX 1.

    SELECT SINGLE
      EBELN
      MBLNR
      FROM MSEG INTO WA_MSEG_PR WHERE EBELN = LV_EBELN.

    IF WA_MSEG_PR IS NOT INITIAL.

      SELECT SINGLE
        MBLNR
        BLDAT
        FROM MKPF INTO WA_MKPF_PR WHERE MBLNR = WA_MSEG_PR-MBLNR.

    ENDIF.



    IF IT_EKPO_PR IS NOT INITIAL.

      SELECT * FROM A003 INTO TABLE @DATA(IT_A003) FOR ALL ENTRIES IN @IT_EKPO_PR WHERE MWSKZ = @IT_EKPO_PR-MWSKZ.

    ENDIF.

    IF IT_A003 IS NOT INITIAL.

      SELECT * FROM KONP INTO TABLE @DATA(IT_KONP) FOR ALL ENTRIES IN @IT_A003 WHERE KNUMH = @IT_A003-KNUMH.

    ENDIF.

*      SELECT QR_CODE EBELN MATNR WERKS MWSKZ_P NETPR_GP FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM_PR
*                                                                  FOR ALL ENTRIES IN IT_EKPO_PR
*                                                                  WHERE MATNR = IT_EKPO_PR-MATNR AND WERKS = IT_EKPO_PR-WERKS.

*    ENDIF.

*    BREAK BREDDY.
*    READ TABLE IT_ZINW_T_ITEM_PR INTO WA_ITEM_PR INDEX 1.
    IF IT_EKPO_PR IS NOT INITIAL.

      SELECT
        QR_CODE
        EBELN
        TRNS
        LR_NO
        BILL_NUM
        BILL_DATE
        ACT_NO_BUD
*      GPRO_USER
        MBLNR
        MBLNR_103
        RETURN_PO
        FROM ZINW_T_HDR INTO TABLE IT_ZINW_T_HDR_PR FOR ALL ENTRIES IN IT_EKPO_PR WHERE RETURN_PO = IT_EKPO_PR-EBELN.
    ENDIF.

*        IF IT_ZINW_T_HDR_PR IS NOT INITIAL.
*
*          SELECT
*
*        ENDIF.




    READ TABLE IT_ZINW_T_HDR_PR INTO WA_ZINW_T_HDR_PR INDEX 1.
    IF WA_ZINW_T_HDR_PR IS NOT INITIAL.

      SELECT SINGLE
      EBELN
      BSART
      AEDAT
      LIFNR
      BEDAT
      KNUMV
       FROM EKKO INTO WA_EKKO1_PR WHERE EBELN = WA_ZINW_T_HDR_PR-EBELN.

      SELECT SINGLE
        INWD_DOC
        QR_CODE
        STATUS_FIELD
        STATUS_VALUE
        DESCRIPTION
        CREATED_DATE
        CREATED_TIME
        CREATED_BY FROM ZINW_T_STATUS INTO WA_ZINW_T_STATUS_PR WHERE QR_CODE = WA_ZINW_T_HDR_PR-QR_CODE .


    ENDIF.



    IF WA_EKPO_PR IS NOT INITIAL.
      SELECT SINGLE
          BUKRS
          GSTIN
          FROM J_1BBRANCH INTO WA_J_1BBRANCH_PR WHERE BUKRS = WA_EKPO_PR-BUKRS.

      SELECT SINGLE
        WERKS
        NAME1
        STRAS
        ORT01
        LAND1
        ADRNR
        FROM T001W INTO WA_T001W_PR WHERE WERKS = WA_EKPO_PR-WERKS.

      SELECT
    MATNR
    SPRAS
    MAKTX
    FROM MAKT INTO TABLE IT_MAKT_PR FOR ALL ENTRIES IN IT_EKPO_PR WHERE MATNR = IT_EKPO_PR-MATNR.
    ENDIF.

    IF WA_T001W_PR IS NOT INITIAL.
      SELECT SINGLE
        ADRC~ADDRNUMBER,
        ADRC~NAME1,
        ADRC~CITY1,
        ADRC~STREET,
        ADRC~STR_SUPPL1,
        ADRC~STR_SUPPL2,
        ADRC~COUNTRY,
        ADRC~LANGU,
        ADRC~REGION,
        ADRC~POST_CODE1
        FROM ADRC INTO @WA_ADRC_PR WHERE ADDRNUMBER = @WA_T001W_PR-ADRNR.



      SELECT SINGLE
        ADDRNUMBER
        SMTP_ADDR
        FROM ADR6 INTO WA_ADR6_PR WHERE ADDRNUMBER = WA_T001W_PR-ADRNR.

      SELECT SINGLE
        ADRNR
        NAME1
        SORTL
        FROM KNA1 INTO WA_KNA1_PR WHERE ADRNR = WA_T001W_PR-ADRNR.
    ENDIF.


    IF WA_ADRC_PR IS NOT INITIAL.

      SELECT SINGLE SPRAS
             LAND1
             BLAND
             BEZEI FROM T005U INTO WA_T005U_PR WHERE BLAND = WA_ADRC_PR-REGION AND LAND1 = WA_ADRC_PR-COUNTRY AND SPRAS = SY-LANGU.
      SELECT SINGLE
             SPRAS
             LAND1
             LANDX FROM T005T INTO WA_T005T_PR WHERE LAND1 = WA_ADRC_PR-COUNTRY AND SPRAS = SY-LANGU.


    ENDIF.


    IF WA_EKKO_PR IS NOT INITIAL.

      SELECT SINGLE
       LIFNR
       LAND1
       NAME1
       ORT01
       REGIO
       STRAS
       STCD3
       ADRNR
       FROM LFA1 INTO WA_LFA1_PR WHERE LIFNR = WA_EKKO_PR-LIFNR.

      SELECT SINGLE
              EBELN
              VGABE
              BELNR
              BUDAT FROM EKBE INTO WA_EKBE_PR WHERE EBELN = WA_EKKO_PR-EBELN AND VGABE = '2'.


    ENDIF.

    SELECT
      KNUMV
      KPOSN
      STUNR
      ZAEHK
      KSCHL
      FROM KONV INTO TABLE IT_KONV_PR FOR ALL ENTRIES IN IT_EKKO_PR WHERE KNUMV = IT_EKKO_PR-KNUMV.

    IF WA_LFA1_PR IS NOT INITIAL.

      SELECT SINGLE
      ADRC~ADDRNUMBER,
      ADRC~NAME1,
      ADRC~CITY1,
      ADRC~STREET,
      ADRC~STR_SUPPL1,
      ADRC~STR_SUPPL2,
      ADRC~COUNTRY,
      ADRC~LANGU,
      ADRC~REGION,
      ADRC~POST_CODE1
      FROM ADRC INTO @WA_ADRC1_PR WHERE ADDRNUMBER = @WA_LFA1_PR-ADRNR.




      SELECT SINGLE
      SMTP_ADDR
      FROM ADR6 INTO @DATA(RET_EMAIL) WHERE ADDRNUMBER = @WA_LFA1_PR-ADRNR.

    ENDIF.

    IF WA_ADRC1_PR IS NOT INITIAL.

      SELECT SINGLE SPRAS
             LAND1
             BLAND
             BEZEI FROM T005U INTO WA_T005U1_PR WHERE BLAND = WA_ADRC1_PR-REGION AND LAND1 = WA_ADRC1_PR-COUNTRY AND SPRAS = SY-LANGU.
      SELECT SINGLE
             SPRAS
             LAND1
             LANDX FROM T005T INTO WA_T005T1_PR WHERE LAND1 = WA_ADRC1_PR-COUNTRY AND SPRAS = SY-LANGU.


    ENDIF.


    WA_HEADER-CITY1       = WA_ADRC_PR-CITY1.
    WA_HEADER-STREET       = WA_ADRC_PR-STREET.
    WA_HEADER-STR_SUPPL1   = WA_ADRC_PR-STR_SUPPL1.
    WA_HEADER-STR_SUPPL2   = WA_ADRC_PR-STR_SUPPL2.
    WA_HEADER-POST_CODE1   = WA_ADRC_PR-POST_CODE1.
    WA_HEADER-BEZEI        = WA_T005U_PR-BEZEI.
    WA_HEADER-LANDX        = WA_T005T_PR-LANDX.
    IF WA_EKKO1_PR-BSART = 'ZOSP'.
      WA_HEADER-MBLNR       = WA_ZINW_T_HDR_PR-MBLNR.
*    WA_HEADER-GPRO_USER      = WA_ZINW_T_HDR-GPRO_USER.

    ELSEIF WA_EKKO1_PR-BSART = 'ZLOP'.
      WA_HEADER-MBLNR   = WA_ZINW_T_HDR_PR-MBLNR_103.
*    WA_HEADER-GPRO_USER      = WA_ZINW_T_HDR-GPRO_USER.

    ENDIF.

    WA_HEADER-GPRO_USER = WA_ZINW_T_STATUS_PR-CREATED_BY.
*    BREAK BREDDY.
    LOOP AT IT_EKPO_PR INTO WA_EKPO_PR.
      LV_SL = LV_SL + 1.
      WA_FINAL-SL = LV_SL.

*    WA_FINAL-MWSKZ = WA_EKPO-MWSKZ.
      WA_FINAL-MENGE = WA_EKPO_PR-MENGE.
      WA_FINAL-NETPR = WA_EKPO_PR-NETPR.
      WA_FINAL-NETWR = WA_EKPO_PR-NETWR.

      READ TABLE IT_MAKT_PR INTO WA_MAKT_PR WITH KEY MATNR = WA_EKPO_PR-MATNR.
      IF SY-SUBRC = 0.
        WA_FINAL-MAKTX = WA_MAKT_PR-MAKTX.
      ENDIF.
*      READ TABLE IT_ZINW_T_ITEM_PR ASSIGNING FIELD-SYMBOL(<WA_ITEM>) WITH KEY  MATNR = WA_EKPO_PR-MATNR WERKS = WA_EKPO_PR-WERKS.
*
*      IF SY-SUBRC = 0.
*
*        WA_FINAL-NETPR_GP = <WA_ITEM>-NETPR_GP.
*
*      ENDIF.
      BREAK BREDDY .
      LOOP AT IT_A003 ASSIGNING FIELD-SYMBOL(<WA_A003>) WHERE MWSKZ = WA_EKPO_PR-MWSKZ.
        IF <WA_A003>-KSCHL = 'JIIG'.
          LV_HED = 'IGST(%)'.
          LV_VAL = 'IGST Value'.
          READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<WA_KONP>) WITH KEY KNUMH = <WA_A003>-KNUMH.
          IF SY-SUBRC = 0.
            LV_PER =  <WA_KONP>-KBETR / 10 .                        """""| && | { '%' } |.
            WA_FINAL-PERCENTAGE =  LV_PER .
            LV_TAX = ( <WA_KONP>-KBETR * WA_EKPO_PR-NETWR ) / 1000.
            ADD LV_TAX TO WA_FINAL-NETPR_GP.
            WA_HEADER-NETPR_T = WA_HEADER-NETPR_T + WA_FINAL-NETPR_GP .
*            EXIT.
          ENDIF.
        ELSEIF <WA_A003>-KSCHL = 'JICG' OR <WA_A003>-KSCHL = 'JISG'.
          CLEAR : LV_HED , LV_VAL.
          READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<WA_KONP1>) WITH KEY KNUMH = <WA_A003>-KNUMH.
          LV_HED = 'CGST/SGST(%)'.
          LV_VAL = 'CGST/SGST Val'.
          IF SY-SUBRC = 0.
            CLEAR: LV_TAX,LV_PER .      ""WA_HEADER-NETPR_T.
            LV_PER =  <WA_KONP1>-KBETR / 10 .
*            ADD LV_PER TO WA_FINAL-PERCENTAGE.
            WA_FINAL-PERCENTAGE =  LV_PER .
            LV_S = '/'.                           """""| && | { '/' } |.
            LV_TAX = ( <WA_KONP1>-KBETR * WA_EKPO_PR-NETWR ) / 1000.
            ADD LV_TAX TO WA_FINAL-NETPR_GP.
            WA_HEADER-NETPR_T = WA_HEADER-NETPR_T + WA_FINAL-NETPR_GP .
          ENDIF.
        ENDIF.

*      LOOP AT IT_A003 ASSIGNING FIELD-SYMBOL(<WA_A003>) WHERE MWSKZ = WA_EKPO_PR-MWSKZ.
*        IF <WA_A003>-KSCHL = 'JIIG'.
*          READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<WA_KONP>) WITH KEY KNUMH = <WA_A003>-KNUMH.
*          IF SY-SUBRC = 0.
*            DATA(LV_TAX) = ( <WA_KONP>-KBETR * WA_EKPO_PR-NETWR ) / 1000.
*            ADD LV_TAX TO WA_FINAL-NETPR_GP.
**            EXIT.
*          ENDIF.
*        ELSEIF <WA_A003>-KSCHL = 'JICG' OR <WA_A003>-KSCHL = 'JISG'.
*          IF SY-SUBRC = 0.
*            CLEAR: LV_TAX.
*            LV_TAX = ( <WA_KONP>-KBETR * WA_EKPO_PR-NETWR ) / 1000.
*            ADD LV_TAX TO WA_FINAL-NETPR_GP.
*
*          ENDIF.
*        ENDIF.
      ENDLOOP.
      READ TABLE IT_MARA_PR ASSIGNING FIELD-SYMBOL(<LS_MARA_PR>) WITH KEY MATNR = WA_EKPO_PR-MATNR.
      IF SY-SUBRC = 0.

        WA_FINAL-EAN11 = <LS_MARA_PR>-EAN11.

      ENDIF.
*      BREAK BREDDY.
      WA_HEADER-TOQTY = WA_FINAL-TOQTY + WA_EKPO_PR-MENGE.
      WA_HEADER-TAMOUNT = WA_HEADER-TAMOUNT + WA_FINAL-NETWR.
      WA_HEADER-TAMT = WA_HEADER-TAMOUNT + WA_HEADER-NETPR_T.

      APPEND WA_FINAL TO IT_FINAL.
      CLEAR : WA_FINAL.
    ENDLOOP.
*      ENDLOOP.

    DATA: LV_AMT1     TYPE PC207-BETRG,
          WA_AMT(100) TYPE C.
    LV_AMT1 = WA_HEADER-TAMT.

    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        AMT_IN_NUM         = LV_AMT1
      IMPORTING
        AMT_IN_WORDS       = WA_AMT
      EXCEPTIONS
        DATA_TYPE_MISMATCH = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        INPUT_STRING  = WA_AMT
*       SEPARATORS    = ' -.,;:'
      IMPORTING
        OUTPUT_STRING = WA_AMT.

    WA_HEADER-P_NAME1   = WA_KNA1_PR-NAME1 .
    WA_HEADER-P_LAND1   = WA_T001W_PR-LAND1 .
    WA_HEADER-WERKS     = WA_T001W_PR-WERKS.
    WA_HEADER-P_NAME1     = WA_T001W_PR-NAME1.
    WA_HEADER-V_STCD3   = WA_LFA1_PR-STCD3 .
    WA_HEADER-MBLNR     = WA_MSEG_PR-MBLNR.
    WA_HEADER-BLDAT     = WA_MKPF_PR-BLDAT.
    WA_HEADER-BEDAT     = WA_EKKO_PR-BEDAT.
    WA_HEADER-GSTIN     = WA_J_1BBRANCH_PR-GSTIN.
    WA_HEADER-SMTP_ADDR = WA_ADR6_PR-SMTP_ADDR.
    WA_HEADER-TRNS      = WA_ZINW_T_HDR_PR-TRNS.
    WA_HEADER-LR_NO     = WA_ZINW_T_HDR_PR-LR_NO.
    WA_HEADER-ACT_NO_BUD     = WA_ZINW_T_HDR_PR-ACT_NO_BUD .
*  WA_HEADER-NO_BUD    = WA_ZINW_T_HDR-NO_BUD.
    WA_HEADER-BILL_NUM  = WA_ZINW_T_HDR_PR-BILL_NUM.
    WA_HEADER-BILL_DATE = WA_ZINW_T_HDR_PR-BILL_DATE.
    WA_HEADER-EBELN     = WA_EKPO_PR-EBELN.
    WA_HEADER-AEDAT     = WA_EKKO_PR-AEDAT.
    WA_HEADER-V_NAME1   = WA_LFA1_PR-NAME1 .
    WA_HEADER-STREET_V         = WA_ADRC1_PR-STREET.
    WA_HEADER-STR_SUPPL2_V     = WA_ADRC1_PR-STR_SUPPL2.
    WA_HEADER-STR_SUPPL1_V     = WA_ADRC1_PR-STR_SUPPL1.
    WA_HEADER-CITY1_V          = WA_ADRC1_PR-CITY1.
    WA_HEADER-POST_CODE1_V       = WA_ADRC1_PR-POST_CODE1.
    WA_HEADER-BEZEI_V        = WA_T005U1_PR-BEZEI.
    WA_HEADER-LANDX_V      = WA_T005T1_PR-LANDX.
    WA_HEADER-INV_NO     = WA_EKBE_PR-BELNR.
    WA_HEADER-INV_DT     = WA_EKBE_PR-BUDAT.
    DATA : LV_HEADING(100) TYPE C,
           LV_REF_PO(30)   TYPE C,
           LV_BILL_D(30)   TYPE C,
           P_AEDAT(10)     TYPE C.
    CLEAR : PO_TEXT.
    PO_TEXT = WA_HEADER-EBELN.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        ID                      = 'F01'
        LANGUAGE                = 'E'
        NAME                    = PO_TEXT
        OBJECT                  = 'EKKO'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
* IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        LINES                   = PO_LINES[]
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT PO_LINES.
      CONCATENATE PO_LINES-TDLINE LV_PO_TEXT INTO LV_PO_TEXT .
      CLEAR PO_LINES .
    ENDLOOP.


*********************END OF RETURN PO***********************************************************************************
********************************************************start of service po************************************************************************
    BREAK BREDDY.
    DATA : WA_EKPO_S1 TYPE EKPO.
    DATA : IT_EKPO_S TYPE TABLE OF EKPO.
*    DATA : IT_EKPO_S TYPE TABLE OF  EKKO.

    SELECT SINGLE * FROM ZINW_T_HDR INTO  @DATA(WA_HEADER_S) WHERE SERVICE_PO = @LV_EBELN.
    IF WA_HEADER_S IS NOT INITIAL.
      SELECT SINGLE EKKO~EBELN , EKKO~LIFNR , EKKO~ERNAM , EKKO~AEDAT FROM EKKO INTO @DATA(WA_EKKO_S) WHERE EBELN = @WA_HEADER_S-SERVICE_PO.
      SELECT EKPO~EBELN , EKPO~EBELP , EKPO~PACKNO , EKPO~WERKS , EKPO~MWSKZ , EKPO~NETWR FROM EKPO INTO CORRESPONDING FIELDS OF TABLE  @IT_EKPO_S WHERE EBELN = @WA_HEADER_S-SERVICE_PO.
      SELECT SINGLE ZINW_T_STATUS~QR_CODE , ZINW_T_STATUS~STATUS_FIELD , ZINW_T_STATUS~STATUS_VALUE , ZINW_T_STATUS~CREATED_DATE  FROM ZINW_T_STATUS INTO @DATA(WA_STATUS) WHERE QR_CODE = @WA_HEADER_S-QR_CODE AND STATUS_FIELD = 'QR02'.
      SELECT SINGLE EKKO~EBELN , EKKO~LIFNR  FROM EKKO INTO @DATA(WA_EKKO1_S) WHERE EBELN = @WA_HEADER_S-EBELN.
    ENDIF.

    IF WA_EKKO_S IS NOT INITIAL.

      SELECT SINGLE LFA1~LIFNR , LFA1~ADRNR , LFA1~NAME1 , LFA1~ORT01 , LFA1~STCD3 FROM LFA1 INTO @DATA(WA_VENDOR) WHERE LIFNR = @WA_EKKO_S-LIFNR.

    ENDIF.

    IF WA_EKKO1_S IS NOT INITIAL.

      SELECT SINGLE LFA1~LIFNR , LFA1~ADRNR , LFA1~NAME1 , LFA1~ORT01 , LFA1~STCD3 FROM LFA1 INTO @DATA(WA_VENDOR1) WHERE LIFNR = @WA_EKKO1_S-LIFNR.

    ENDIF.

    IF IT_EKPO_S IS NOT INITIAL.

      SELECT ESLL~PACKNO , ESLL~INTROW , ESLL~PACKAGE , ESLL~SUB_PACKNO FROM ESLL INTO TABLE  @DATA(IT_ESLL)
      FOR ALL ENTRIES IN @IT_EKPO_S WHERE PACKNO = @IT_EKPO_S-PACKNO.

    ENDIF.

    READ TABLE IT_EKPO_S INTO WA_EKPO_S1 INDEX 1.
    IF WA_EKPO_S1 IS NOT INITIAL.
      SELECT SINGLE T001W~WERKS , T001W~ADRNR FROM T001W INTO @DATA(WA_T001W_S) WHERE WERKS = @WA_EKPO_S1-WERKS.
      SELECT SINGLE LFA1~STCD3 FROM LFA1 INTO @WA_HDR-GSTINP WHERE WERKS = @WA_EKPO_S1-WERKS.
    ENDIF.

    IF IT_ESLL IS NOT INITIAL.

      SELECT ESLL~PACKNO , ESLL~INTROW , ESLL~SRVPOS , ESLL~PACKAGE , ESLL~SUB_PACKNO , ESLL~MENGE , ESLL~NETWR , ESLL~MWSKZ , ESLL~TBTWR , ESLL~KTEXT1  FROM ESLL
      INTO TABLE  @DATA(IT_ESLL1)
      FOR ALL ENTRIES IN @IT_ESLL WHERE PACKNO = @IT_ESLL-SUB_PACKNO.

    ENDIF.
    IF IT_EKPO_S IS NOT INITIAL.

      SELECT * FROM A003 INTO TABLE @DATA(IT_A003_S) FOR ALL ENTRIES IN @IT_EKPO_S WHERE MWSKZ = @IT_EKPO_S-MWSKZ.

    ENDIF.

    IF IT_A003_S IS NOT INITIAL.

      SELECT * FROM KONP INTO TABLE @DATA(IT_KONP_S) FOR ALL ENTRIES IN @IT_A003_S WHERE KNUMH = @IT_A003_S-KNUMH.

    ENDIF.
    IF WA_VENDOR1 IS NOT INITIAL.

      SELECT SINGLE
        ADR6~SMTP_ADDR FROM ADR6 INTO @DATA(SER_EMAIL)
                       WHERE ADDRNUMBER = @WA_VENDOR1-ADRNR .
    ENDIF.

    LV_VEN = WA_VENDOR-ADRNR.
    LV_SHP = WA_T001W_S-ADRNR.
    WA_HDR-LR_NO      = WA_HEADER_S-LR_NO.
    WA_HDR-ACT_NO_BUD = WA_HEADER_S-ACT_NO_BUD.
    WA_HDR-NAME       = WA_VENDOR-NAME1.
    WA_HDR-CITY       = WA_VENDOR-ORT01.
    WA_HDR-TRANSPORTER = WA_VENDOR-LIFNR.
    WA_HDR-BILL_NUM   = WA_HEADER_S-BILL_NUM.
    WA_HDR-BILL_DAT   = WA_HEADER_S-BILL_DATE.
    WA_HDR-GATE_ENTRY = WA_EKKO_S-AEDAT.
    WA_HDR-PO_NO      = WA_HEADER_S-EBELN.
    WA_HDR-SPO_NO     = LV_EBELN.
    WA_HDR-QR_CODE    = WA_HEADER_S-QR_CODE.
    WA_HDR-LR_DATE     = WA_HEADER_S-LR_DATE.
    WA_HDR-CREATED_BY = WA_EKKO_S-ERNAM.
    WA_HDR-AEDAT = WA_EKKO_S-AEDAT.
    WA_HDR-STCD3      = WA_VENDOR-STCD3.
    WA_HDR-VENDOR     = WA_VENDOR1-LIFNR.
    WA_HDR-VEN_NAME     = WA_VENDOR1-NAME1.



    LOOP AT IT_EKPO_S ASSIGNING FIELD-SYMBOL(<WA_EKPO_S>).

      W_FINAL-SEVICE_PO = <WA_EKPO_S>-EBELN.
      W_FINAL-LR_NO     = WA_HEADER_S-LR_NO.
      READ TABLE IT_ESLL ASSIGNING FIELD-SYMBOL(<WA_ESLL>) WITH KEY PACKNO = <WA_EKPO_S>-PACKNO.

      LOOP AT IT_ESLL1 ASSIGNING FIELD-SYMBOL(<WA_ESLL1>) WHERE  PACKNO = <WA_ESLL>-SUB_PACKNO .

        W_FINAL-GROSS_VALUE = <WA_ESLL1>-TBTWR.
        W_FINAL-MENGE = <WA_ESLL1>-MENGE.
        W_FINAL-NETWR = W_FINAL-GROSS_VALUE * W_FINAL-MENGE.
        W_FINAL-SORT_TEXT = <WA_ESLL1>-KTEXT1.
        WA_HDR-LV_TOT = WA_HDR-LV_TOT + W_FINAL-NETWR.
        WA_HDR-QTY_T  = WA_HDR-QTY_T  + W_FINAL-MENGE.

        APPEND W_FINAL TO T_FINAL.
        CLEAR : W_FINAL.

      ENDLOOP.

      LOOP AT IT_A003_S ASSIGNING FIELD-SYMBOL(<WA_A003_S>) WHERE MWSKZ = <WA_EKPO_S>-MWSKZ.
        IF <WA_A003_S>-KSCHL = 'JIIG'.
          READ TABLE IT_KONP_S ASSIGNING FIELD-SYMBOL(<WA_KONP_S>) WITH KEY KNUMH = <WA_A003_S>-KNUMH.
          IF SY-SUBRC = 0.
            DATA(LV_TAX_S) = ( <WA_KONP_S>-KBETR * <WA_EKPO_S>-NETWR ) / 1000.
            ADD LV_TAX_S TO WA_HDR-GST.
*            EXIT.
          ENDIF.
        ELSEIF <WA_A003_S>-KSCHL = 'JICG' OR <WA_A003_S>-KSCHL = 'JISG'.
          IF SY-SUBRC = 0.
            CLEAR: LV_TAX_S.
            LV_TAX = ( <WA_KONP_S>-KBETR * <WA_EKPO_S>-NETWR ) / 1000.
            ADD LV_TAX TO WA_HDR-GST.

          ENDIF.
        ENDIF.


        WA_HDR-NET_TOTAL = WA_HDR-GST + WA_HDR-LV_TOT.


      ENDLOOP.

    ENDLOOP.
    DATA : LV_AMOUNT TYPE PC207-BETRG.
    DATA : LV_W(100) TYPE C.
    LV_AMOUNT = WA_HDR-NET_TOTAL.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        AMT_IN_NUM         = LV_AMOUNT
      IMPORTING
        AMT_IN_WORDS       = LV_W
      EXCEPTIONS
        DATA_TYPE_MISMATCH = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        INPUT_STRING  = LV_W
*       SEPARATORS    = ' -.,;:'
      IMPORTING
        OUTPUT_STRING = LV_W.
    SELECT * FROM TVARVC INTO TABLE  @DATA(IT_TVARVC) WHERE NAME = 'ZZPO_MAIL'.

*****************************************************end of service po*******************************************************************
    BREAK BREDDY .
** For Reg PO & Packing List
    IF REG_PO IS NOT INITIAL.
      LV_HEADING = 'PURCHASE ORDER'.
      P_AEDAT  = SY-DATUM .

*      BREAK BREDDY.
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          INPUT  = P_AEDAT
        IMPORTING
          OUTPUT = P_AEDAT.


*****************************************END OF PO_RETURN DECLRATION*****************************************************************************

*      BREAK BREDDY.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = 'ZPURCHASE_ORDER_FORM_TEST1'
        IMPORTING
          FM_NAME            = FMNAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

*      BREAK SAMBURI.

      IF PRINT_PRIEVIEW IS NOT INITIAL.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ELSE.
        LS_CTRLOP-GETOTF = ABAP_TRUE.
        LS_CTRLOP-NO_DIALOG = 'X'.
        LS_CTRLOP-LANGU = SY-LANGU.

        LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
        LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ENDIF.



*      LS_CTRLOP-GETOTF = ABAP_TRUE.
*      LS_CTRLOP-NO_DIALOG = 'X'.
*      LS_CTRLOP-LANGU = SY-LANGU.
*
*      LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
*      LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
*      LS_OUTPUTOP-TDDEST  = 'LP01'.

      CALL FUNCTION FMNAME
        EXPORTING
          CONTROL_PARAMETERS   = LS_CTRLOP
          OUTPUT_OPTIONS       = LS_OUTPUTOP
          WA_POHEADER          = WA_POHEADER
          LV_EBELN             = LV_EBELN
          LV_ADRC              = LV_ADRC
          LV_ADRC1             = LV_ADRC1
          LV_ADRC2             = LV_ADRC2
          LV_WORDS             = LV_WORDS
          LV_GSTIN_V           = LV_GSTIN_V
          LV_GSTIN_C           = LV_GSTIN_C
          LV_HEADING           = LV_HEADING
          LV_BILLD             = LV_BILLD
          LV_RPO               = LV_RPO
          LV_REF_PO            = LV_REF_PO
          LV_BILL_D            = LV_BILL_D
          LV_ERNAME            = LV_ERNAME
          PO_QR                = LV_EBELN
        IMPORTING
          DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
          JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
          JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
        TABLES
          IT_POITEM            = IT_POITEM
        EXCEPTIONS
          FORMATTING_ERROR     = 1
          INTERNAL_ERROR       = 2
          SEND_ERROR           = 3
          USER_CANCELED        = 4
          OTHERS               = 5.
      IF SY-SUBRC <> 0.
**           Implement suitable error handling here
      ENDIF.

*      ELSE.
      IF PRINT_PRIEVIEW IS INITIAL.
        LT_OTF = LS_JOB_OUTPUT_INFO-OTFDATA.

*      BREAK-POINT.
        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            FORMAT                = 'PDF'
            MAX_LINEWIDTH         = 132
          IMPORTING
            BIN_FILESIZE          = LS_BIN_FILESIZE
            BIN_FILE              = LV_OTF
          TABLES
            OTF                   = LT_OTF[]
            LINES                 = LT_LINES[]
          EXCEPTIONS
            ERR_MAX_LINEWIDTH     = 1
            ERR_FORMAT            = 2
            ERR_CONV_NOT_POSSIBLE = 3
            ERR_BAD_OTF           = 4.

*      ENDIF.

        CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
          EXPORTING
            IP_XSTRING = LV_OTF
          RECEIVING
            RT_SOLIX   = LT_PDF_DATA[].

        TRY.
            REFRESH MAIN_TEXT.

*-------- create persistent send request ------------------------
            SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'To,'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'All Concerned' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'Sub: Purchase Order & Packing List release/amendment'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT3 =  | GROUP  : { WA_POHEADER-GROUP_ID } | .
            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =   LS_TEXT3 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'The following Purchase Order & Packing List is released/amendment. Please take necessary action:' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.
            LS_TEXT =  | VENDOR NAME  : { WA_POHEADER-AD_NAME } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            LS_MAIN_TEXT =   LS_TEXT .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT1 =  | PURCHASE ORDER NO  : { LV_EBELN  } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            LS_MAIN_TEXT =   LS_TEXT1 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT2 =  | PO. APPROVED DATE  : { P_AEDAT  } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            LS_MAIN_TEXT =   LS_TEXT2 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            LS_MAIN_TEXT =  'REMARKS : PO Created'   .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'From.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'PurchaseDept.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'clarifications contact TSG/MKTG.dept.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.

        ENDTRY.

        CONCATENATE 'Purchase Order' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT.

        TRY .
            DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                I_TYPE    = 'HTM'
                I_TEXT    = MAIN_TEXT
                I_SUBJECT = LV_DOC_SUBJECT ).
          CATCH CX_DOCUMENT_BCS .

        ENDTRY.

        TRY.
            DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
                                        I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT
                                        I_ATT_CONTENT_HEX = LT_PDF_DATA ).

          CATCH CX_DOCUMENT_BCS.
        ENDTRY.
      ENDIF.
*    BREAK BREDDY.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = 'ZPACKING_FORM'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          FM_NAME            = FM_NAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      CLEAR :
      LS_DOCUMENT_OUTPUT_INFO,
      LS_JOB_OUTPUT_INFO,
      LS_JOB_OUTPUT_OPTIONS.


      CALL FUNCTION FM_NAME
        EXPORTING
          CONTROL_PARAMETERS   = LS_CTRLOP
          OUTPUT_OPTIONS       = LS_OUTPUTOP
          WA_POHEADER          = WA_POHEADER
          LV_EBELN             = LV_EBELN
          LV_ADRC              = LV_ADRC
          LV_ADRC1             = LV_ADRC1
          LV_ADRC2             = LV_ADRC2
          LV_WORDS             = LV_WORDS
          LV_GSTIN_V           = LV_GSTIN_V
          LV_GSTIN_C           = LV_GSTIN_C
*         LV_HEADING           = LV_HEADING
          PO_QR                = WA_POHEADER-PO_QR
        IMPORTING
          DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
          JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
          JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
        TABLES
          IT_POITEM            = IT_POITEM
        EXCEPTIONS
          FORMATTING_ERROR     = 1
          INTERNAL_ERROR       = 2
          SEND_ERROR           = 3
          USER_CANCELED        = 4
          OTHERS               = 5.
      IF SY-SUBRC <> 0.
*           Implement suitable error handling here
      ENDIF.
*      ENDIF.


*      ELSE.
*      CLEAR :LS_BIN_FILESIZE,
*             LV_OTF,
*             LT_OTF,
*             LT_LINES.
      IF PRINT_PRIEVIEW IS INITIAL.
        LT_OTF1 = LS_JOB_OUTPUT_INFO-OTFDATA.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            FORMAT                = 'PDF'
            MAX_LINEWIDTH         = 132
          IMPORTING
            BIN_FILESIZE          = LS_BIN_FILESIZE1
            BIN_FILE              = LV_OTF1
          TABLES
            OTF                   = LT_OTF1[]
            LINES                 = LT_LINES1[]
          EXCEPTIONS
            ERR_MAX_LINEWIDTH     = 1
            ERR_FORMAT            = 2
            ERR_CONV_NOT_POSSIBLE = 3
            ERR_BAD_OTF           = 4.

*      ENDIF.

*            TRY .
*          DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
*              I_TYPE    = 'HTM'
*              I_TEXT    = MAIN_TEXT
*              I_SUBJECT = LV_DOC_SUBJECT1 ).
*        CATCH CX_DOCUMENT_BCS .
*
*      ENDTRY.

        CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
          EXPORTING
            IP_XSTRING = LV_OTF1
          RECEIVING
            RT_SOLIX   = LT_PDF_DATA1[].


        CLEAR LV_DOC_SUBJECT1.
        CONCATENATE 'Packing List' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT1.

        TRY.
            DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
                                        I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT1
                                        I_ATT_CONTENT_HEX = LT_PDF_DATA1 ).

          CATCH CX_DOCUMENT_BCS.
        ENDTRY.
        TRY.
*     add document object to send request
            SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).

*** Start of Changes By Suri : 21.08.2019
            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
*            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( conv SYST_UNAME('SUPERSTORESPO') ).
*** End of Changes By Suri : 21.08.2019

            CALL METHOD SEND_REQUEST->SET_SENDER
              EXPORTING
                I_SENDER = V_SEND_REQUEST.
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'suri.amburi@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'anuanilmehta@yahoo.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.

*            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            CLEAR I_ADDRESS_STRING.

**** START OF CHANGES BY SURI : 18.11.2019
**** Sending Mail to Vendor for Specific Groups
*****Changes done  by bhavani 10.12.2019****************
*            IF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
*                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.



*            IF WA_POHEADER-GROUP_ID = 'SAREES' OR WA_POHEADER-GROUP_ID = 'FOOTWEAR' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE'
*             OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR  WA_POHEADER-GROUP_ID = 'FURNISHING' OR  WA_POHEADER-GROUP_ID = 'BAGSANDLUGGAGE' OR  WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*               WA_POHEADER-GROUP_ID = 'HOMENEEDS' OR  WA_POHEADER-GROUP_ID = 'MENSREADYMADE' OR  WA_POHEADER-GROUP_ID = 'OPTICALS' OR  WA_POHEADER-GROUP_ID = 'PROVISION' OR
*               WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES' OR  WA_POHEADER-GROUP_ID = 'FRUITSANDVEGETABLE' OR  WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION' OR
*               WA_POHEADER-GROUP_ID = 'STATIONERY' OR  WA_POHEADER-GROUP_ID = 'VESSELS' OR  WA_POHEADER-GROUP_ID = 'BLOUSE' OR  WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR
*               WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' OR  WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'INNERWEAR' OR
*               WA_POHEADER-GROUP_ID = 'JUSTBORN' OR  WA_POHEADER-GROUP_ID = 'MENSACCESSORIES' OR  WA_POHEADER-GROUP_ID = 'MOBILE' OR WA_POHEADER-GROUP_ID = 'SILK' OR WA_POHEADER-GROUP_ID = 'SHIRTINGANDSUITING' OR
*               WA_POHEADER-GROUP_ID = 'SPORTS' OR WA_POHEADER-GROUP_ID = 'TOYS' OR  WA_POHEADER-GROUP_ID = 'WATCHES' OR  WA_POHEADER-GROUP_ID = 'FURNITURE' OR
*               WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
*************ended by bhavani 10.12.2019**********************
            CLEAR : I_ADDRESS_STRING.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          ENDIF.

*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC>).
*              I_ADDRESS_STRING = <WA_TVARVC>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.
*
*            BREAK BREDDY .
*********ADDED BY BHAVANI 17.09.2019*********
            CLEAR : I_ADDRESS_STRING.

            IF I_ADDRNUMBER IS NOT INITIAL.
              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRNUMBER ).
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
            ENDIF.
*********ENDED BY BHAVANI 17.09.2019*********

**** Start of Changes By Suri : 21.08.2019
**** Sending Mail to Vendor for Specific Groups
*            IF WA_POHEADER-GROUP_ID = 'COSMETICS'  OR WA_POHEADER-GROUP_ID = 'FOOTWARE' OR WA_POHEADER-GROUP_ID = 'FOOTWARE1' OR
*               WA_POHEADER-GROUP_ID = 'FOOTWARE_1' OR WA_POHEADER-GROUP_ID = 'BAGS'     OR WA_POHEADER-GROUP_ID = 'BAGS1'     OR
*               WA_POHEADER-GROUP_ID = 'MOBILES'.
*              CLEAR : I_ADDRESS_STRING.
*              SELECT SINGLE SMTP_ADDR INTO I_ADDRESS_STRING FROM ADR6 WHERE ADDRNUMBER = WA_LFA1-ADRNR.
*              IF I_ADDRESS_STRING IS NOT INITIAL.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
*                SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              ENDIF.
*            ELSEIF WA_POHEADER-GROUP_ID = 'SAREE' .
*              CLEAR : I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*
*            ENDIF.
**** End of Changes By Suri : 21.08.2019
*
******added by bhavani
*
*            IF WA_POHEADER-GROUP_ID = 'FOOTWARE'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Pothi3080@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'babushanmugam1987@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'TOYS' OR   WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Prakash.arikrish@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Augustin@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'FURNITURE' OR WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'jaichandran@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' .
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Chermananu1982@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MOBILES' OR WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'WATCHES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'elect@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADEN' OR WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'murugan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'INNERWARE' OR WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'JUSTBORN' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'pkannan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'thangaduraivo8@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'kmannanmaha@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.
***********Ended by bhavani
*** End of Changes By Suri : 18.11.2019

*     ---------- send document ---------------------------------------
            SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).

            COMMIT WORK.

            IF SENT_TO_ALL IS INITIAL.
              MESSAGE I500(SBCOMS).
            ELSE.
              ES_MSG = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
        ENDTRY.
      ENDIF.
****************************************************PO return****************************************************
*      BREAK BREDDY.
      CLEAR : LV_HEADING.
      CLEAR : P_AEDAT.
    ELSEIF RETURN_PO IS NOT INITIAL.

      LV_HEADING = 'PURCHASE ORDER'.
      P_AEDAT  = SY-DATUM .

*      BREAK BREDDY.
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          INPUT  = P_AEDAT
        IMPORTING
          OUTPUT = P_AEDAT.

      IF PRINT_PRIEVIEW IS NOT INITIAL.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ELSE.
        LS_CTRLOP-GETOTF = ABAP_TRUE.
        LS_CTRLOP-NO_DIALOG = 'X'.
        LS_CTRLOP-LANGU = SY-LANGU.

        LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
        LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ENDIF.

      READ TABLE IT_EKPO_PR INTO WA_EKPO_PR WITH KEY RETPO = 'X'.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            FORMNAME           = 'ZMM_PURCHASE_RETURN_F1'
          IMPORTING
            FM_NAME            = FM_NAME
          EXCEPTIONS
            NO_FORM            = 1
            NO_FUNCTION_MODULE = 2
            OTHERS             = 3.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
        CLEAR :
        LS_DOCUMENT_OUTPUT_INFO,
        LS_JOB_OUTPUT_INFO,
        LS_JOB_OUTPUT_OPTIONS.


        CALL FUNCTION FM_NAME
          EXPORTING
            CONTROL_PARAMETERS   = LS_CTRLOP
            OUTPUT_OPTIONS       = LS_OUTPUTOP
            WA_HEADER            = WA_HEADER
            WA_AMT               = WA_AMT
            LV_HED               = LV_HED
            LV_VAL               = LV_VAL
            LV_PER               = LV_PER
            LV_S                 = LV_S
            LV_PO_TEXT           = LV_PO_TEXT
          IMPORTING
            DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
            JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
            JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
          TABLES
            IT_FINAL             = IT_FINAL
          EXCEPTIONS
            FORMATTING_ERROR     = 1
            INTERNAL_ERROR       = 2
            SEND_ERROR           = 3
            USER_CANCELED        = 4
            OTHERS               = 5.
        IF SY-SUBRC <> 0.

* Implement suitable error handling here
        ENDIF.
      ENDIF.

      IF PRINT_PRIEVIEW IS INITIAL.
        LT_OTF2 = LS_JOB_OUTPUT_INFO-OTFDATA.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            FORMAT                = 'PDF'
            MAX_LINEWIDTH         = 132
          IMPORTING
            BIN_FILESIZE          = LS_BIN_FILESIZE1
            BIN_FILE              = LV_OTF2
          TABLES
            OTF                   = LT_OTF2[]
            LINES                 = LT_LINES2[]
          EXCEPTIONS
            ERR_MAX_LINEWIDTH     = 1
            ERR_FORMAT            = 2
            ERR_CONV_NOT_POSSIBLE = 3
            ERR_BAD_OTF           = 4.
*        ENDIF.

        CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
          EXPORTING
            IP_XSTRING = LV_OTF2
          RECEIVING
            RT_SOLIX   = LT_PDF_DATA2[].
*      ENDIF.
*    ENDIF.
*      BREAK BREDDY.
        TRY.
            REFRESH MAIN_TEXT.

*-------- create persistent send request ------------------------
            SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'To,'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'All Concerned' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'Sub: Return Purchase Order release/amendment'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'The following Return Purchase Order is released/amendment. Please take necessary action:' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.
            LS_TEXT =  | VENDOR NAME  : { WA_POHEADER-AD_NAME } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            LS_MAIN_TEXT =   LS_TEXT .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT1 =  | RETURN PURCHASE ORDER NO  : { LV_EBELN  } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            LS_MAIN_TEXT =   LS_TEXT1 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT2 =  | PO. APPROVED DATE  : { P_AEDAT  } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            LS_MAIN_TEXT =   LS_TEXT2 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            LS_MAIN_TEXT =  'REMARKS : Returned Po Created'   .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'From.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'PurchaseDept.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'clarifications contact TSG/MKTG.dept.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.

        ENDTRY.

        CLEAR LV_DOC_SUBJECT2.
        CONCATENATE 'Return PO' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT2.

        TRY .
            DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                I_TYPE    = 'HTM'
                I_TEXT    = MAIN_TEXT
                I_SUBJECT = LV_DOC_SUBJECT2 ).
          CATCH CX_DOCUMENT_BCS .

        ENDTRY.

        TRY.
            DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
                                        I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT2
                                        I_ATT_CONTENT_HEX = LT_PDF_DATA2 ).

          CATCH CX_DOCUMENT_BCS.
        ENDTRY.

        TRY.
*-------- create persistent send request ------------------------
            SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
*     add document object to send request
            SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).


            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).

            CALL METHOD SEND_REQUEST->SET_SENDER
              EXPORTING
                I_SENDER = V_SEND_REQUEST.
*        BREAK SAMBURI.
*break breddy.
*        LOOP AT LT_RECLIST INTO LS_RECLIST.
*          I_ADDRESS_STRING = LS_RECLIST.
*      RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'suri.amburi@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*        RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*        SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*        CLEAR I_ADDRESS_STRING.
*        ENDLOOP.
*
*            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'dummyposap@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            CLEAR I_ADDRESS_STRING.

**** START OF CHANGES BY SURI : 18.11.2019
**** Sending Mail to Vendor for Specific Groups

*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC2>).
*              I_ADDRESS_STRING = <WA_TVARVC2>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.

******changes done by bhavani 10.12.2019***********
*            IF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
*                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.
*              CLEAR : I_ADDRESS_STRING.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
**              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.
*
*            IF WA_POHEADER-GROUP_ID = 'SAREES' OR WA_POHEADER-GROUP_ID = 'FOOTWEAR' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE'
*             OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR  WA_POHEADER-GROUP_ID = 'FURNISHING' OR  WA_POHEADER-GROUP_ID = 'BAGSANDLUGGAGE' OR  WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*               WA_POHEADER-GROUP_ID = 'HOMENEEDS' OR  WA_POHEADER-GROUP_ID = 'MENSREADYMADE' OR  WA_POHEADER-GROUP_ID = 'OPTICALS' OR  WA_POHEADER-GROUP_ID = 'PROVISION' OR
*               WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES' OR  WA_POHEADER-GROUP_ID = 'FRUITSANDVEGETABLE' OR  WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION' OR
*               WA_POHEADER-GROUP_ID = 'STATIONERY' OR  WA_POHEADER-GROUP_ID = 'VESSELS' OR  WA_POHEADER-GROUP_ID = 'BLOUSE' OR  WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR
*               WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' OR  WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'INNERWEAR' OR
*               WA_POHEADER-GROUP_ID = 'JUSTBORN' OR  WA_POHEADER-GROUP_ID = 'MENSACCESSORIES' OR  WA_POHEADER-GROUP_ID = 'MOBILE' OR WA_POHEADER-GROUP_ID = 'SILK' OR WA_POHEADER-GROUP_ID = 'SHIRTINGANDSUITING' OR
*               WA_POHEADER-GROUP_ID = 'SPORTS' OR WA_POHEADER-GROUP_ID = 'TOYS' OR  WA_POHEADER-GROUP_ID = 'WATCHES' OR  WA_POHEADER-GROUP_ID = 'FURNITURE' OR
*               WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
            CLEAR : I_ADDRESS_STRING.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'VR@SARAVANASTORES.NET' ).
            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF .
**********ended by bhavani 10.12.2019***************
*** End of Changes By Suri : 18.11.2019

*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'anuanilmehta@yahoo.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.

*********ADDED BY BHAVANI 17.09.2019*********
            CLEAR : I_ADDRESS_STRING.

            IF RET_EMAIL IS NOT INITIAL.
              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( RET_EMAIL ).
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
            ENDIF.
*********ENDED BY BHAVANI 17.09.2019*********

*          LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC1>).
*            I_ADDRESS_STRING = <WA_TVARVC1>-LOW.
*            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            CLEAR I_ADDRESS_STRING.
*          ENDLOOP.

*     ---------- send document ---------------------------------------
            SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).

            COMMIT WORK.

            IF SENT_TO_ALL IS INITIAL.
              MESSAGE I500(SBCOMS).
            ELSE.
*        MESSAGE s022(so).
              ES_MSG = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
        ENDTRY.


      ENDIF.
*****************************************END OF PO_RETURN DECLRATION*****************************************************************************
*      BREAK BREDDY.
*********************************START OF TATKAL PO*********************************************
    ELSEIF TATKAL_PO IS NOT INITIAL.

      CLEAR : P_AEDAT,IT_POITEM,WA_POITEM,WA_POHEADER-ZUNAME ,WA_POHEADER-GSTINP , WA_POHEADER-PO_QR , WA_POHEADER-POTYPE .                    ""WA_POITEM,WA_POHEADER.
      LV_REF_PO = 'Reference PO :'.
      LV_BILL_D  = 'Bill Date :'.
      LV_HEADING = 'PURCHASE ORDER'.
      P_AEDAT  = SY-DATUM .
      WA_POHEADER-PO_QR = LV_EBELN .
*      BREAK BREDDY.
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          INPUT  = P_AEDAT
        IMPORTING
          OUTPUT = P_AEDAT.

*      IF LV_EBELN IS NOT INITIAL.
*        SELECT EKKO~EBELN EKKO~BUKRS EKKO~AEDAT EKKO~BEDAT  EKKO~LIFNR FROM EKKO  INTO  CORRESPONDING FIELDS OF TABLE IT_EKKO
*          WHERE EBELN = LV_EBELN .
*
**        ELSE.
**           SELECT * FROM ZINW_T_HDR INTO  @DATA(WA_ZINW_T_HDR) WHERE TAT_PO = LV_EBELN .            """TATKAL PO
*      ENDIF.
*      IF IT_EKKO IS NOT INITIAL.
*        SELECT  EKPO~EBELN , EKPO~EBELP , EKPO~MENGE , EKPO~WERKS  , EKPO~MATNR , EKPO~MEINS , EKPO~MATKL , EKPO~NETPR , EKPO~ZZSET_MATERIAL  ,
*          EKPO~WRF_CHARSTC2 FROM EKPO INTO TABLE  @IT_EKPO WHERE EBELN = @LV_EBELN.
*
*      ENDIF.
*
*      READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
*      READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = LV_EBELN.
*
*      SELECT SINGLE NAME1, ADRNR , WERKS, STCD3 INTO @DATA(WA_LFA1) FROM LFA1
*        WHERE LIFNR = @WA_EKKO-LIFNR.
*      IF IT_EKPO IS NOT INITIAL.
*        SELECT SINGLE T001W~ADRNR  FROM T001W INTO @DATA(LV_PADRNR) WHERE WERKS = @WA_EKPO-WERKS.
*      ENDIF.
*
*      IF WA_EKKO IS NOT INITIAL.
*        SELECT SINGLE T001~BUKRS , T001~ADRNR FROM T001 INTO @DATA(WA_T001) WHERE BUKRS = @WA_EKKO-BUKRS.
*        SELECT SINGLE J_1BBRANCH~BUKRS, J_1BBRANCH~GSTIN FROM J_1BBRANCH INTO @DATA(WA_J_1BBRANCH) WHERE BUKRS = @WA_EKKO-BUKRS.
*
*      ENDIF.
*      LV_ADRC = WA_LFA1-ADRNR.
*      LV_ADRC1 = LV_PADRNR.
*      LV_ADRC2 = WA_T001-ADRNR.
*
**    ENDIF.
*
*      SELECT MARA~MATNR  MARA~MATKL  MARA~ZZPO_ORDER_TXT  MARA~SIZE1 MARA~COLOR FROM MARA INTO CORRESPONDING FIELDS OF TABLE IT_MARA FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-MATNR .
*      SELECT T023T~MATKL , T023T~WGBEZ , T023T~WGBEZ60 FROM T023T INTO TABLE @DATA(IT_T023T) FOR ALL ENTRIES IN @IT_EKPO WHERE MATKL = @IT_EKPO-MATKL.
*      SELECT * FROM MAKT INTO TABLE IT_MAKT
*        FOR ALL ENTRIES IN PO_ITEM
*        WHERE MATNR = PO_ITEM-MATNR AND SPRAS EQ SY-LANGU.
*
*      WA_POHEADER-AD_NAME = WA_LFA1-NAME1.
*      WA_POHEADER-LIFNR = HEADER-VENDOR.
*      WA_POHEADER-AEDAT =  WA_EKKO-AEDAT  .
*      WA_POHEADER-ZUNAME = IM_HEADER-ZUNAME.
*      LV_GSTIN_V = WA_LFA1-STCD3.
*      LV_GSTIN_C = WA_J_1BBRANCH-GSTIN.
**    WA_POHEADER-REF_PO =  WA_ZINW_T_HDR-EBELN.                             ""TATKAL PO
**    WA_POHEADER-BILL_TAT =  WA_ZINW_T_HDR-BILL_DATE.                      ""TATKAL PO BILL DATE
*      SELECT SINGLE EKET~EBELN , EKET~EINDT FROM EKET INTO @DATA(WA_EKET) WHERE EBELN = @LV_EBELN.
*      WA_POHEADER-DEL_BY = WA_EKET-EINDT.
*
*      SELECT STPO~STLNR,
*             STPO~IDNRK,
*             STPO~POSNR,
*             STPO~MENGE,
*             MAST~MATNR,
*             MAST~WERKS,
*             MAST~STLAL,
*             MARA~SIZE1
*             INTO TABLE @DATA(IT_SIZE)
*             FROM STPO AS STPO
*             INNER JOIN MAST AS MAST ON STPO~STLNR = MAST~STLNR
*             INNER JOIN MARA AS MARA ON MARA~MATNR = STPO~IDNRK
*             FOR ALL ENTRIES IN @IT_MARA
*             WHERE STPO~IDNRK = @IT_MARA-MATNR.


*          LOOP AT IT_EKPO INTO WA_EKPO.
**      BREAK BREDDY.
*      IF WA_EKPO-ZZSET_MATERIAL IS NOT INITIAL.
*        DATA(IT_EKPO_SET) = IT_EKPO.
*        DELETE IT_EKPO_SET WHERE ZZSET_MATERIAL <> WA_EKPO-ZZSET_MATERIAL.
*        SORT IT_EKPO_SET BY ZZSET_MATERIAL.
*        DESCRIBE TABLE IT_EKPO_SET LINES DATA(LV_LINES_SET).
*        DELETE ADJACENT DUPLICATES FROM IT_EKPO_SET COMPARING ZZSET_MATERIAL.
*        READ TABLE IT_EKPO_SET INTO WA_EKPO_SET WITH KEY ZZSET_MATERIAL = WA_EKPO-ZZSET_MATERIAL.
*        READ TABLE IT_POITEM WITH KEY MATNR = WA_EKPO-ZZSET_MATERIAL TRANSPORTING NO FIELDS .
*        IF SY-SUBRC <> 0.
*          WA_POITEM-MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
*          WA_POITEM-MENGE = WA_EKPO_SET-MENGE.
*          WA_POITEM-MT_GRP = WA_EKPO_SET-MATKL.
*          LV_POITEM = LV_POITEM + 10.
*          WA_POITEM-EBELP = LV_POITEM.
*          WA_POITEM-NETPR = WA_EKPO_SET-NETPR * LV_LINES_SET.
*          WA_POITEM-NETAMT  = WA_POITEM-NETPR * WA_POITEM-MENGE.
*          ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*
*          LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPO>) WHERE ZZSET_MATERIAL = WA_EKPO_SET-ZZSET_MATERIAL.
*            IF WA_POITEM-SIZE IS INITIAL.
*              WA_POITEM-SIZE = <LS_EKPO>-WRF_CHARSTC2 .
*            ELSE.
*              WA_POITEM-SIZE = WA_POITEM-SIZE && '-' && <LS_EKPO>-WRF_CHARSTC2 .
*            ENDIF.
**          CONCATENATE  WA_POITEM-SIZE '-'  WA_EKPO_set-WRF_CHARSTC2  INTO  WA_POITEM-SIZE .
*          ENDLOOP.
*          CLEAR: WA_MARA.
**          READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_PO_ITEM-MATNR .
*          READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T1>) WITH KEY MATKL = WA_EKPO-MATKL.
*          IF SY-SUBRC = 0 AND WA_POITEM-WGBEZ IS INITIAL  .
*            WA_POITEM-WGBEZ = <WA_T023T1>-WGBEZ60.
*          ENDIF.
*************************END SET******************************
      BREAK BREDDY.
      SELECT SINGLE
         EKKO~EBELN
         EKKO~BUKRS
         EKKO~AEDAT
         EKKO~BEDAT
         EKKO~LIFNR
         EKKO~USER_NAME
         EKKO~BSART
*         EKKO~USER_NAME
         EKKO~ERNAM
*         EKKO~BSART
         EKKO~ZINDENT
       FROM EKKO INTO CORRESPONDING FIELDS OF WA_EKKO_P
       WHERE EBELN = LV_EBELN AND BSART = 'ZTAT' .
      IF WA_EKKO_P IS NOT INITIAL .
        SELECT SINGLE NAME1, ADRNR , WERKS, STCD3 INTO @DATA(WA_LFA1_P) FROM LFA1
                WHERE LIFNR = @WA_EKKO_P-LIFNR.
      ENDIF .
      IF WA_LFA1 IS  NOT INITIAL .
        SELECT SINGLE ADR6~SMTP_ADDR FROM ADR6 INTO @DATA(TAT_EMAIL)
                                     WHERE ADDRNUMBER =  @WA_LFA1-ADRNR .
      ENDIF .

      IF WA_EKKO_P IS NOT INITIAL.
        SELECT
         EBELN
         EBELP
         MENGE
         WERKS
         MATNR
         MEINS
         MATKL
         NETPR
         NETWR
         ZZSET_MATERIAL
         WRF_CHARSTC2
           FROM EKPO INTO TABLE IT_EKPO_P
                          WHERE EBELN = LV_EBELN.

        SELECT SINGLE * FROM ZINW_T_HDR INTO @DATA(WA_ZINW_T_HDR_T) WHERE TAT_PO = @WA_EKKO_P-EBELN.

      ENDIF.
      IF LV_EBELN IS NOT INITIAL.
        SELECT SINGLE ZINW_T_HDR~EBELN FROM ZINW_T_HDR INTO @DATA(REG_TPO) WHERE TAT_PO = @LV_EBELN.
      ENDIF.
      READ TABLE IT_EKPO_P INTO WA_EKPO_P INDEX 1.
      IF WA_EKPO_P IS NOT INITIAL.
        SELECT SINGLE LFA1~STCD3 FROM LFA1 INTO @WA_POHEADER-GSTINP WHERE WERKS = @WA_EKPO_P-WERKS.
      ENDIF.
      IF WA_ZINW_T_HDR_T IS NOT INITIAL.

        SELECT * FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM_P
                 WHERE EBELN = WA_ZINW_T_HDR_T-EBELN.


        SELECT MARA~MATNR  MARA~MATKL  MARA~ZZPO_ORDER_TXT  MARA~SIZE1 MARA~COLOR MARA~EAN11 FROM MARA INTO CORRESPONDING FIELDS OF TABLE IT_MARA FOR ALL ENTRIES IN IT_EKPO_P WHERE MATNR = IT_EKPO_P-MATNR .
        IF REG_TPO IS NOT INITIAL .
          SELECT SINGLE
            EKKO~ZINDENT FROM EKKO INTO @DATA(INDENT_NO) WHERE EBELN = @REG_TPO  .
        ENDIF .
*********start changes by bhabani 10.12.2019************
        IF IT_EKPO_P IS NOT INITIAL .
          SELECT
            MARA~MATNR ,
            MARA~MATKL ,
              MARA~SIZE1  FROM MARA INTO TABLE @DATA(IT_MARA_S)
              FOR ALL ENTRIES IN @IT_EKPO_P
               WHERE MATNR = @IT_EKPO_P-MATNR .
        ENDIF .
        IF     IT_MARA_S IS NOT INITIAL .
          SELECT
            ZSIZE_VAL~ZITEM ,
            ZSIZE_VAL~ZSIZE FROM ZSIZE_VAL INTO TABLE @DATA(IT_ZSIZE_S)
                            FOR ALL ENTRIES IN @IT_MARA_S
                            WHERE ZSIZE = @IT_MARA_S-SIZE1 .
        ENDIF .
***********end changes by bhavani 10.12.2019***************

        IF IT_MARA IS NOT INITIAL.

          SELECT
            MATNR
            MAKTX FROM MAKT INTO TABLE IT_MAKT FOR ALL ENTRIES IN IT_MARA WHERE MATNR =  IT_MARA-MATNR.

        ENDIF.
        SELECT T023T~MATKL , T023T~WGBEZ , T023T~WGBEZ60 FROM T023T INTO TABLE @DATA(IT_T023T_T) FOR ALL ENTRIES IN @IT_EKPO_P WHERE MATKL = @IT_EKPO_P-MATKL.

      ENDIF.
      LV_BILLD = WA_ZINW_T_HDR_T-BILL_DATE.
      LV_RPO   = WA_ZINW_T_HDR_T-EBELN.
      LV_ERNAME = WA_EKKO_P-ERNAM.
*      IF WA_EKKO_P-USER_NAME IS INITIAL.
      WA_POHEADER-ZUNAME = LV_ERNAME .
      WA_POHEADER-INWD_DOC = WA_ZINW_T_HDR_T-INWD_DOC.
      WA_POHEADER-BILL_TEXT = 'Bill No :'.
      WA_POHEADER-BILL_NUM  = WA_ZINW_T_HDR_T-BILL_NUM.
      WA_POHEADER-POTYPE    = WA_EKKO_P-BSART .
      WA_POHEADER-INDENT_NO   = INDENT_NO .

      CLEAR : SL_NO.
      BREAK BREDDY .
      LOOP AT IT_EKPO_P INTO WA_EKPO_P.      "" WA_ZINW_T_ITEM_P-EBELN AND MATNR = WA_ZINW_T_ITEM_P-MATNR  .

        SL_NO = SL_NO + 1.
        WA_POITEM-ZSL = SL_NO.

*******start changes by bhavani 10.12.2019********
        DATA(IT_MARA_S1) = IT_MARA_S[].

*        SORT  IT_MARA_S ASCENDING BY SIZE1 .
        DELETE IT_MARA_S WHERE MATKL <> WA_EKPO_P-MATKL .
        READ TABLE IT_MARA_S ASSIGNING FIELD-SYMBOL(<LS_MARA_S>) WITH KEY MATKL =  WA_EKPO_P-MATKL .
        IF SY-SUBRC = 0.
          SORT IT_ZSIZE_S ASCENDING BY ZITEM .
          READ TABLE IT_ZSIZE_S ASSIGNING FIELD-SYMBOL(<LS_ZSIZE_S>) INDEX 1 .
          IF SY-SUBRC = 0.
            WA_POITEM-FROM_SIZE = <LS_ZSIZE_S>-ZSIZE .
          ENDIF.

        ENDIF.

        SORT  IT_ZSIZE_S DESCENDING BY ZITEM .
        READ TABLE IT_ZSIZE_S ASSIGNING <LS_ZSIZE_S> INDEX 1 .
        IF SY-SUBRC = 0.
          WA_POITEM-TO_SIZE = <LS_ZSIZE_S>-ZSIZE .
        ENDIF.
        IF WA_POITEM-FROM_SIZE IS INITIAL .

          WA_POITEM-FROM_SIZE = WA_POITEM-TO_SIZE .

        ENDIF.
*******end changes by bhavani 10.12.2019*********
        WA_POITEM-MT_GRP = WA_EKPO_P-MATKL.
        WA_POITEM-MENGE = WA_EKPO_P-MENGE.
        WA_POITEM-NETPR = WA_EKPO_P-NETPR.
        WA_POITEM-G_TOTAL = WA_EKPO_P-NETPR * WA_EKPO_P-MENGE.
        WA_POITEM-MATKL = WA_EKPO_P-MATKL.
        WA_POITEM-MATKL = WA_EKPO_P-MATKL.
        WA_POITEM-NETAMT  = WA_EKPO_P-NETPR * WA_EKPO_P-MENGE.
        ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.

        LV_POITEM = LV_POITEM + 10.
        WA_POITEM-EBELP = LV_POITEM.


        CLEAR : WA_EKKO_P .
        READ TABLE IT_EKKO_P INTO WA_EKKO_P WITH KEY EBELN = LV_EBELN BSART = 'ZTAT'  .
*        READ TABLE IT_EKPO_P INTO WA_EKPO_P WITH KEY EBELN = WA_ZINW_T_ITEM_P-EBELN MATNR = WA_ZINW_T_ITEM_P-MATNR .
        IF SY-SUBRC = 0.
          WA_POHEADER-BSART =  WA_EKKO_P-BSART .
        ENDIF.
        READ TABLE IT_ZINW_T_ITEM_P  INTO WA_ZINW_T_ITEM_P WITH KEY EBELN = WA_ZINW_T_HDR_T-EBELN MATNR = WA_EKPO_P-MATNR.                ""WA_ZINW_T_ITEM_P-EBELN MATNR = WA_ZINW_T_ITEM_P-MATNR .
*        IF SY-SUBRC = 0.
*          WA_POITEM-MT_GRP = WA_EKPO_P-MATKL.
*          WA_POITEM-MENGE = WA_EKPO_P-MENGE.
*          WA_POITEM-NETPR = WA_EKPO_P-NETPR.
*          WA_POITEM-MT_GRP = WA_EKPO_P-MATKL.
*          WA_POITEM-NETAMT  = WA_EKPO_P-NETPR * WA_EKPO-MENGE.
*          ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*
*          LV_POITEM = LV_POITEM + 10.
*          WA_POITEM-EBELP = LV_POITEM.
**
*        ENDIF.

*        READ TABLE IT_ZINW_T_HDR INTO WA_ZINW_T_HDR WITH KEY TAT_PO = WA_EKKO_P-EBELN.
*        IF SY-SUBRC = 0.
*
*          LV_BILLD = WA_ZINW_T_HDR-BILL_DATE.
*          LV_RPO   = WA_ZINW_T_HDR-EBELN.
*
*        ENDIF.
        READ TABLE IT_T023T_T ASSIGNING FIELD-SYMBOL(<WA_T023T_T>) WITH KEY MATKL = WA_EKPO_P-MATKL.
        IF SY-SUBRC = 0.
          WA_POITEM-WGBEZ = <WA_T023T_T>-WGBEZ60.
        ENDIF.
        REFRESH :IT_LINES[].


        REFRESH :IT_LINES[].
        CLEAR LV_NAME1.
        CONCATENATE WA_ZINW_T_ITEM_P-EBELN WA_ZINW_T_ITEM_P-EBELP INTO LV_NAME1.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            ID                      = 'F03'
            LANGUAGE                = 'E'
            NAME                    = LV_NAME1
            OBJECT                  = 'EKPO'
          TABLES
            LINES                   = IT_LINES[]
          EXCEPTIONS
            ID                      = 1
            LANGUAGE                = 2
            NAME                    = 3
            NOT_FOUND               = 4
            OBJECT                  = 5
            REFERENCE_CHECK         = 6
            WRONG_ACCESS_TO_ARCHIVE = 7
            OTHERS                  = 8.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.

        LOOP AT IT_LINES.

          CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
          CLEAR IT_LINES .

        ENDLOOP.

        REFRESH :IT_LINES2[].

        CLEAR LV_NAME1.
        CONCATENATE WA_ZINW_T_ITEM_P-EBELN WA_ZINW_T_ITEM_P-EBELP INTO LV_NAME2.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            ID                      = 'F07'
            LANGUAGE                = 'E'
            NAME                    = LV_NAME2
            OBJECT                  = 'EKPO'
*           ARCHIVE_HANDLE          = 0
*           LOCAL_CAT               = ' '
*       IMPORTING
*           HEADER                  =
*           OLD_LINE_COUNTER        =
          TABLES
            LINES                   = IT_LINES2[]
          EXCEPTIONS
            ID                      = 1
            LANGUAGE                = 2
            NAME                    = 3
            NOT_FOUND               = 4
            OBJECT                  = 5
            REFERENCE_CHECK         = 6
            WRONG_ACCESS_TO_ARCHIVE = 7
            OTHERS                  = 8.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.


        LOOP AT IT_LINES2.

          CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
          CLEAR IT_LINES2 .

        ENDLOOP.
        CLEAR : WA_MARA.
        READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = WA_EKPO_P-MATNR .
        IF SY-SUBRC = 0 .
          IF WA_MARA-EAN11 IS NOT INITIAL.
            WA_POITEM-EAN11 =  WA_MARA-EAN11.
          ENDIF.
        ENDIF.

        CLEAR :WA_POHEADER-GROUP_ID .
        IF WA_MARA-MATKL IS NOT INITIAL .
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              MATKL       = WA_MARA-MATKL
              SPRAS       = SY-LANGU
            TABLES
              O_WGH01     = IT_O_WGH01
            EXCEPTIONS
              NO_BASIS_MG = 1
              NO_MG_HIER  = 2
              OTHERS      = 3.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
        READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
        IF SY-SUBRC = 0.
          WA_POHEADER-GROUP_ID = WA_O_WGH01-WWGHA.
          CLEAR WA_O_WGH01.
        ENDIF.
        READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_MARA-MATNR .
        IF SY-SUBRC = 0.
          WA_POITEM-MAKTX = WA_MAKT-MAKTX.
        ENDIF.

        WA_POITEM-SIZE = WA_MARA-SIZE1.
        IF WA_MARA-COLOR IS NOT INITIAL.
          WA_POITEM-COLOR = WA_MARA-COLOR.
        ELSE.

          REFRESH :IT_LINES3[].

          CLEAR LV_NAME1.
          CONCATENATE WA_ZINW_T_ITEM_P-EBELN WA_ZINW_T_ITEM_P-EBELP INTO LV_NAME3.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
*             CLIENT                  = SY-MANDT
              ID                      = 'F08'
              LANGUAGE                = 'E'
              NAME                    = LV_NAME3
              OBJECT                  = 'EKPO'
*             ARCHIVE_HANDLE          = 0
*             LOCAL_CAT               = ' '
*       IMPORTING
*             HEADER                  =
*             OLD_LINE_COUNTER        =
            TABLES
              LINES                   = IT_LINES3[]
            EXCEPTIONS
              ID                      = 1
              LANGUAGE                = 2
              NAME                    = 3
              NOT_FOUND               = 4
              OBJECT                  = 5
              REFERENCE_CHECK         = 6
              WRONG_ACCESS_TO_ARCHIVE = 7
              OTHERS                  = 8.
          IF SY-SUBRC <> 0.
* Implement suitable error handling here
          ENDIF.


          LOOP AT IT_LINES3.

            CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
            CLEAR IT_LINES3 .

          ENDLOOP.

          APPEND WA_POITEM TO IT_POITEM.
          CLEAR : WA_POITEM.

        ENDIF.

      ENDLOOP.
*      IF  WA_EKKO_P-bsart = 'ztat'.
      WA_POHEADER-TEXT = 'GRPO Inward :'.
*      ENDIF.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = 'ZPURCHASE_ORDER_FORM_TEST1'
        IMPORTING
          FM_NAME            = FMNAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.


      IF PRINT_PRIEVIEW IS NOT INITIAL.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ELSE.
        LS_CTRLOP-GETOTF = ABAP_TRUE.
        LS_CTRLOP-NO_DIALOG = 'X'.
        LS_CTRLOP-LANGU = SY-LANGU.

        LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
        LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ENDIF.



      BREAK BREDDY.
*      LS_CTRLOP-GETOTF = ABAP_TRUE.
*      LS_CTRLOP-NO_DIALOG = 'X'.
*      LS_CTRLOP-LANGU = SY-LANGU.
*
*      LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
*      LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
*      LS_OUTPUTOP-TDDEST  = 'LP01'.
      CLEAR : LV_HEADING.
      LV_HEADING = 'TATKAL PURCHASE ORDER FOR EXCESS RECIEVED'.
      CALL FUNCTION FMNAME
        EXPORTING
          CONTROL_PARAMETERS   = LS_CTRLOP
          OUTPUT_OPTIONS       = LS_OUTPUTOP
          WA_POHEADER          = WA_POHEADER
          LV_EBELN             = LV_EBELN
          LV_ADRC              = LV_ADRC
          LV_ADRC1             = LV_ADRC1
          LV_ADRC2             = LV_ADRC2
          LV_WORDS             = LV_WORDS
          LV_GSTIN_V           = LV_GSTIN_V
          LV_GSTIN_C           = LV_GSTIN_C
          LV_HEADING           = LV_HEADING
          LV_BILLD             = LV_BILLD
          LV_RPO               = LV_RPO
          LV_REF_PO            = LV_REF_PO
          LV_BILL_D            = LV_BILL_D
          LV_ERNAME            = LV_ERNAME
          PO_QR                = LV_EBELN
        IMPORTING
          DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
          JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
          JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
        TABLES
          IT_POITEM            = IT_POITEM
        EXCEPTIONS
          FORMATTING_ERROR     = 1
          INTERNAL_ERROR       = 2
          SEND_ERROR           = 3
          USER_CANCELED        = 4
          OTHERS               = 5.
      IF SY-SUBRC <> 0.
**           Implement suitable error handling here
      ENDIF.

*      ELSE.
      IF PRINT_PRIEVIEW IS INITIAL.
        LT_OTF = LS_JOB_OUTPUT_INFO-OTFDATA.

*      BREAK-POINT.
        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            FORMAT                = 'PDF'
            MAX_LINEWIDTH         = 132
          IMPORTING
            BIN_FILESIZE          = LS_BIN_FILESIZE
            BIN_FILE              = LV_OTF
          TABLES
            OTF                   = LT_OTF[]
            LINES                 = LT_LINES[]
          EXCEPTIONS
            ERR_MAX_LINEWIDTH     = 1
            ERR_FORMAT            = 2
            ERR_CONV_NOT_POSSIBLE = 3
            ERR_BAD_OTF           = 4.

*      ENDIF.

        CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
          EXPORTING
            IP_XSTRING = LV_OTF
          RECEIVING
            RT_SOLIX   = LT_PDF_DATA[].

        TRY.
            REFRESH MAIN_TEXT1.

*-------- create persistent send request ------------------------
            SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 = 'To,'.
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 = '<BR>'.
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 = 'All Concerned' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 = '<BR>'.
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 = 'Sub: Tatkal Purchase Order'.
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>'.
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>'.
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  'The following Tatkal Purchase Order ,Please take necessary action:' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.
            LS_TEXT =  | VENDOR NAME  : { WA_POHEADER-AD_NAME } | .
            CLEAR LS_MAIN_TEXT1.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            LS_MAIN_TEXT1 =   LS_TEXT1 .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.


            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            LS_TEXT1 =  | TATKAL ORDER NO  : { LV_EBELN  } | .
            CLEAR LS_MAIN_TEXT1.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            LS_MAIN_TEXT1 =   LS_TEXT1 .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            LS_TEXT2 =  | PO. APPROVED DATE  : { P_AEDAT  } | .
            CLEAR LS_MAIN_TEXT1.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            LS_MAIN_TEXT1 =   LS_TEXT2 .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            LS_MAIN_TEXT1 =  'REMARKS :Tatkal PO Created'   .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  'From.' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  'PurchaseDept.' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.


            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.


            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  'clarifications contact TSG/MKTG.dept.' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '<BR>' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

            CLEAR LS_MAIN_TEXT1.
            LS_MAIN_TEXT1 =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND LS_MAIN_TEXT1 TO MAIN_TEXT1.

          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.

        ENDTRY.
*    CLEAR :LV_DOC_SUBJECT3.
        CONCATENATE 'Tatkal Purchase Order' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT.

        TRY .
            DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                I_TYPE    = 'HTM'
                I_TEXT    = MAIN_TEXT1
                I_SUBJECT = LV_DOC_SUBJECT ).
          CATCH CX_DOCUMENT_BCS .
        ENDTRY.
        TRY.
            DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
                                        I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT
                                        I_ATT_CONTENT_HEX = LT_PDF_DATA ).

          CATCH CX_DOCUMENT_BCS.
        ENDTRY.
        TRY.

*     add document object to send request
            SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).
**** Start of Changes By Suri : 21.08.2019
            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
*            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( conv SYST_UNAME('SUPERSTORESPO') ).
**** End of Changes By Suri : 21.08.2019

            CALL METHOD SEND_REQUEST->SET_SENDER
              EXPORTING
                I_SENDER = V_SEND_REQUEST.
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'dummyposap@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'anuanilmehta@yahoo.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.

**** START OF CHANGES BY SURI : 18.11.2019
**** Sending Mail to Vendor for Specific Groups

*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC2>).
*              I_ADDRESS_STRING = <WA_TVARVC2>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.
*******changes done by bhavani 10.12.2019**************
*            IF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
*                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.


*
*            IF WA_POHEADER-GROUP_ID = 'SAREES' OR WA_POHEADER-GROUP_ID = 'FOOTWEAR' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE'
*             OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR  WA_POHEADER-GROUP_ID = 'FURNISHING' OR  WA_POHEADER-GROUP_ID = 'BAGSANDLUGGAGE' OR  WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*               WA_POHEADER-GROUP_ID = 'HOMENEEDS' OR  WA_POHEADER-GROUP_ID = 'MENSREADYMADE' OR  WA_POHEADER-GROUP_ID = 'OPTICALS' OR  WA_POHEADER-GROUP_ID = 'PROVISION' OR
*               WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES' OR  WA_POHEADER-GROUP_ID = 'FRUITSANDVEGETABLE' OR  WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION' OR
*               WA_POHEADER-GROUP_ID = 'STATIONERY' OR  WA_POHEADER-GROUP_ID = 'VESSELS' OR  WA_POHEADER-GROUP_ID = 'BLOUSE' OR  WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR
*               WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' OR  WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'INNERWEAR' OR
*               WA_POHEADER-GROUP_ID = 'JUSTBORN' OR  WA_POHEADER-GROUP_ID = 'MENSACCESSORIES' OR  WA_POHEADER-GROUP_ID = 'MOBILE' OR WA_POHEADER-GROUP_ID = 'SILK' OR WA_POHEADER-GROUP_ID = 'SHIRTINGANDSUITING' OR
*               WA_POHEADER-GROUP_ID = 'SPORTS' OR WA_POHEADER-GROUP_ID = 'TOYS' OR  WA_POHEADER-GROUP_ID = 'WATCHES' OR  WA_POHEADER-GROUP_ID = 'FURNITURE' OR
*               WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
********Ended by bhavani 10.12.2019******************
            CLEAR : I_ADDRESS_STRING.



*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.


*********ADDED BY BHAVANI 17.09.2019*********
            CLEAR : I_ADDRESS_STRING.

            IF TAT_EMAIL IS NOT INITIAL.
              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( TAT_EMAIL ).
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
            ENDIF.
*********ENDED BY BHAVANI 17.09.2019*********

*** End of Changes By Suri : 18.11.2019
**** START OF CHANGES BY SURI : 21.08.2019
**** Sending Mail to Vendor for Specific Groups
*            IF WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE1'OR WA_POHEADER-GROUP_ID = 'COSMETICS' OR
*               WA_POHEADER-GROUP_ID = 'FOOTWARE' OR WA_POHEADER-GROUP_ID = 'FOOTWARE1' OR WA_POHEADER-GROUP_ID = 'FOOTWARE_1' OR
*               WA_POHEADER-GROUP_ID = 'BAGS' OR WA_POHEADER-GROUP_ID = 'BAGS1' OR WA_POHEADER-GROUP_ID = 'MOBILES' OR
*               WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREDYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLREADY' .
*              CLEAR : I_ADDRESS_STRING.
*              SELECT SINGLE SMTP_ADDR INTO I_ADDRESS_STRING FROM ADR6 WHERE ADDRNUMBER = WA_LFA1-ADRNR.
*              IF I_ADDRESS_STRING IS NOT INITIAL.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
*                SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              ENDIF.
*            ENDIF.
**** End of Changes By Suri : 21.08.2019
*     ---------- send document ---------------------------------------
            SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).

            COMMIT WORK.

            IF SENT_TO_ALL IS INITIAL.
              MESSAGE I500(SBCOMS).
            ELSE.
              ES_MSG = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
        ENDTRY.
      ENDIF.

***********service po********
    ELSEIF SERVICE_PO IS NOT INITIAL.
      BREAK BREDDY .

      P_AEDAT  = SY-DATUM .
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          INPUT  = P_AEDAT
        IMPORTING
          OUTPUT = P_AEDAT.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = 'ZMM_SERVICE_PO_FORM'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          FM_NAME            = FMNAME1
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      IF PRINT_PRIEVIEW IS NOT INITIAL.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ELSE.
        LS_CTRLOP-GETOTF = ABAP_TRUE.
        LS_CTRLOP-NO_DIALOG = 'X'.
        LS_CTRLOP-LANGU = SY-LANGU.

        LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
        LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
        LS_OUTPUTOP-TDDEST  = 'LP01'.
      ENDIF.

      CALL FUNCTION FMNAME1
        EXPORTING
          CONTROL_PARAMETERS   = LS_CTRLOP
          OUTPUT_OPTIONS       = LS_OUTPUTOP
          LV_VEN               = LV_VEN
          LV_SHP               = LV_SHP
          WA_HDR               = WA_HDR
          LV_W                 = LV_W
          QR_CODE              = WA_HDR-QR_CODE
        IMPORTING
          DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
          JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
          JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
        TABLES
          T_FINAL              = T_FINAL
        EXCEPTIONS
          FORMATTING_ERROR     = 1
          INTERNAL_ERROR       = 2
          SEND_ERROR           = 3
          USER_CANCELED        = 4
          OTHERS               = 5.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

*      ELSE.
      IF PRINT_PRIEVIEW IS INITIAL.
        LT_OTF4 = LS_JOB_OUTPUT_INFO-OTFDATA.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            FORMAT                = 'PDF'
            MAX_LINEWIDTH         = 132
          IMPORTING
            BIN_FILESIZE          = LS_BIN_FILESIZE4
            BIN_FILE              = LV_OTF4
          TABLES
            OTF                   = LT_OTF4[]
            LINES                 = LT_LINES4[]
          EXCEPTIONS
            ERR_MAX_LINEWIDTH     = 1
            ERR_FORMAT            = 2
            ERR_CONV_NOT_POSSIBLE = 3
            ERR_BAD_OTF           = 4.
*      ENDIF.



        CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
          EXPORTING
            IP_XSTRING = LV_OTF4
          RECEIVING
            RT_SOLIX   = LT_PDF_DATA4[].
*    ENDIF.


        TRY.
            REFRESH MAIN_TEXT.

*-------- create persistent send request ------------------------
            SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'To,'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'All Concerned' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT = 'Sub: Service Purchase Order release/amendment'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>'.
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'The following Service Purchase Order is released/amendment. Please take necessary action:' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.
            LS_TEXT =  | VENDOR NAME  : { WA_POHEADER-AD_NAME } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            LS_MAIN_TEXT =   LS_TEXT .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT1 =  | SERVICE PURCHASE ORDER NO  : { LV_EBELN  } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            LS_MAIN_TEXT =   LS_TEXT1 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            LS_TEXT2 =  | PO. APPROVED DATE  : { P_AEDAT  } | .
            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            LS_MAIN_TEXT =   LS_TEXT2 .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            LS_MAIN_TEXT =  'REMARKS : Service Po Created'   .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'From.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'PurchaseDept.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  'clarifications contact TSG/MKTG.dept.' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '<BR>' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

            CLEAR LS_MAIN_TEXT.
            LS_MAIN_TEXT =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND LS_MAIN_TEXT TO MAIN_TEXT.

          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.

        ENDTRY.


        CLEAR LV_DOC_SUBJECT4.
        CONCATENATE 'Service Purchase Order' LV_EBELN '.pdf' INTO LV_DOC_SUBJECT4.

        TRY .
            DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                I_TYPE    = 'HTM'
                I_TEXT    = MAIN_TEXT
                I_SUBJECT = LV_DOC_SUBJECT4 ).
          CATCH CX_DOCUMENT_BCS .

        ENDTRY.
        TRY.
            DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
                                        I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT4
                                        I_ATT_CONTENT_HEX = LT_PDF_DATA4 ).

          CATCH CX_DOCUMENT_BCS.
        ENDTRY.

        TRY.
*-------- create persistent send request ------------------------
            SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
*     add document object to send request
            SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).


            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).

            CALL METHOD SEND_REQUEST->SET_SENDER
              EXPORTING
                I_SENDER = V_SEND_REQUEST.

*** Start of Changes By Suri : 21.08.2019
*** Sending Mail to Vendor for Specific Groups
*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC3>).
*              I_ADDRESS_STRING = <WA_TVARVC3>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.

*****Changes done  by bhavani 10.12.2019****************
*            IF WA_POHEADER-GROUP_ID = 'COSMETICS'  OR WA_POHEADER-GROUP_ID = 'FOOTWARE' OR WA_POHEADER-GROUP_ID = 'FOOTWARE1' OR
*               WA_POHEADER-GROUP_ID = 'FOOTWARE_1' OR WA_POHEADER-GROUP_ID = 'BAGS'     OR WA_POHEADER-GROUP_ID = 'BAGS1'     OR
*               WA_POHEADER-GROUP_ID = 'MOBILES'.
**                CLEAR : I_ADDRESS_STRING.
**                SELECT SINGLE SMTP_ADDR INTO I_ADDRESS_STRING FROM ADR6 WHERE ADDRNUMBER = WA_LFA1-ADRNR.
**                IF I_ADDRESS_STRING IS NOT INITIAL.
**                  RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**                  SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
**                ENDIF.
*            ELSEIF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
*                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.
*********ADDED BY BHAVANI 17.09.2019*********
            CLEAR : I_ADDRESS_STRING.

            IF SER_EMAIL IS NOT INITIAL.
              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( SER_EMAIL ).
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
            ENDIF.
*********ENDED BY BHAVANI 17.09.2019*********





*            IF WA_POHEADER-GROUP_ID = 'SAREES' OR WA_POHEADER-GROUP_ID = 'FOOTWEAR' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE'
*             OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR  WA_POHEADER-GROUP_ID = 'FURNISHING' OR  WA_POHEADER-GROUP_ID = 'BAGSANDLUGGAGE' OR  WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
*               WA_POHEADER-GROUP_ID = 'HOMENEEDS' OR  WA_POHEADER-GROUP_ID = 'MENSREADYMADE' OR  WA_POHEADER-GROUP_ID = 'OPTICALS' OR  WA_POHEADER-GROUP_ID = 'PROVISION' OR
*               WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES' OR  WA_POHEADER-GROUP_ID = 'FRUITSANDVEGETABLE' OR  WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION' OR
*               WA_POHEADER-GROUP_ID = 'STATIONERY' OR  WA_POHEADER-GROUP_ID = 'VESSELS' OR  WA_POHEADER-GROUP_ID = 'BLOUSE' OR  WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR
*               WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' OR  WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'INNERWEAR' OR
*               WA_POHEADER-GROUP_ID = 'JUSTBORN' OR  WA_POHEADER-GROUP_ID = 'MENSACCESSORIES' OR  WA_POHEADER-GROUP_ID = 'MOBILE' OR WA_POHEADER-GROUP_ID = 'SILK' OR WA_POHEADER-GROUP_ID = 'SHIRTINGANDSUITING' OR
*               WA_POHEADER-GROUP_ID = 'SPORTS' OR WA_POHEADER-GROUP_ID = 'TOYS' OR  WA_POHEADER-GROUP_ID = 'WATCHES' OR  WA_POHEADER-GROUP_ID = 'FURNITURE' OR
*               WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
*************ended by bhavani 10.12.2019**********************
            CLEAR : I_ADDRESS_STRING.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.
** End of Changes By Suri : 21.08.2019


******added by bhavani
*
*            IF WA_POHEADER-GROUP_ID = 'FOOTWARE'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Pothi3080@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'TOYS' OR   WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Prakash.arikrish@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
**            ELSEIF  WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
**              CLEAR I_ADDRESS_STRING.
**              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Augustin@saravanastores.net' )."( I_ADDRESS_STRING ).
**              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'FURNITURE' OR WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'jaichandran@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' .
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Chermananu1982@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MOBILES' OR WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'WATCHES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'elect@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADEN' OR WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'murugan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'INNERWARE' OR WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'JUSTBORN' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'pkannan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'thangaduraivo8@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'kmannanmaha@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.
************Ended by bhavani




















*     ---------- send document ---------------------------------------
            SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).

            COMMIT WORK.

            IF SENT_TO_ALL IS INITIAL.
              MESSAGE I500(SBCOMS).
            ELSE.
*        MESSAGE s022(so).
              ES_MSG = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
          CATCH CX_BCS INTO BCS_EXCEPTION.
            MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
