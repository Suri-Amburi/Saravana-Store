**&---------------------------------------------------------------------*
**& Include          ZMM_PURCHASE_RETURN_TOP
**&---------------------------------------------------------------------*
*
*TYPES: BEGIN OF TY_EKPO,
*         EBELN TYPE EBELN,                              "Purchasing Document Number
*         EBELP TYPE EBELP,                              "Item Number of Purchasing Document
*         WERKS TYPE EWERK,                              "Plant
*         MATNR TYPE MATNR,                              "Material Number
*         MWSKZ TYPE MWSKZ,                              "Tax on Sales/Purchases Code
*         MENGE TYPE BSTMG,                              "Purchase Order Quantity
*         NETPR TYPE BPREI,                              "Net Price in Purchasing Document (in Document Currency)
*         PEINH TYPE EPEIN,                              "Price unit
*         NETWR TYPE BWERT,                              "Net Order Value in PO Currency
*         BUKRS TYPE BUKRS,
*         RETPO TYPE RETPO,
*       END OF TY_EKPO.
*
*TYPES: BEGIN OF TY_EKKO,
*         EBELN TYPE EBELN,                               "Purchasing Document Number
*         BSART TYPE ESART,
*         AEDAT TYPE ERDAT,
*         LIFNR TYPE ELIFN,                               "Vendor's account number
*         BEDAT TYPE EBDAT,                               "Purchasing Document Date
*         KNUMV TYPE  KNUMV,                               "Number of the Document Condition
*       END OF TY_EKKO.
*
*TYPES: BEGIN OF TY_T001W,
*         WERKS TYPE WERKS_D,                            "Plant
*         NAME1 TYPE NAME1,                              "Name
*         STRAS TYPE STRAS,                              "Street and House Number
*         ORT01 TYPE ORT01,                              "City
*         LAND1 TYPE LAND1,                              "Country Key
*         ADRNR TYPE ADRNR,
*       END OF TY_T001W.
*
*TYPES: BEGIN OF TY_LFA1,
*         LIFNR TYPE LIFNR,                                "Account Number of Vendor or Creditor
*         LAND1 TYPE LAND1_GP,                             "Country Key
*         NAME1 TYPE NAME1_GP,                             "Name 1
*         ORT01 TYPE ORT01_GP,                             "City
*         REGIO TYPE REGIO,                                "Region (State, Province, County)
*         STRAS TYPE STRAS_GP,                             "Street and House Number
*         STCD3 TYPE STCD3,                                "Tax Number 3
*         ADRNR TYPE ADRNR,
*       END OF TY_LFA1.
*
*TYPES: BEGIN OF TY_MAKT,
*         MATNR TYPE MATNR,                                "Material Number
*         SPRAS TYPE SPRAS,                                "Language Key
*         MAKTX TYPE MAKTX,                                "Material description
*       END OF TY_MAKT.
*
*TYPES: BEGIN OF TY_KONV,
*         KNUMV TYPE KNUMV,                                "Number of the Document Condition
*         KPOSN TYPE KPOSN,                                "Condition item number
*         STUNR TYPE STUNR,                                "Step Number
*         ZAEHK TYPE DZAEHK,                               "Condition Counter
*         KSCHL TYPE KSCHA,                                "Condition type
*       END OF TY_KONV.
*
*TYPES: BEGIN OF TY_MSEG,
*         EBELN TYPE EBELN,
*         MBLNR TYPE MBLNR,                                "RETURN NO./DOCUMENT NO.
*       END OF TY_MSEG.
*
*TYPES: BEGIN OF TY_MKPF,
*         MBLNR TYPE MBLNR,
*         BLDAT TYPE BLDAT,                                  " DOCUMENT DATE
*       END OF TY_MKPF.
*
*TYPES: BEGIN OF TY_J_1BBRANCH,
*         BUKRS TYPE BUKRS,                                  "COMPANY CODE
*         GSTIN TYPE J_1IGSTCD3,                             "GST NO
*       END OF TY_J_1BBRANCH.
*
*TYPES: BEGIN OF TY_ADR6,
*         ADDRNUMBER TYPE AD_ADDRNUM,
*         SMTP_ADDR  TYPE AD_SMTPADR,
*       END OF TY_ADR6.
*
*TYPES: BEGIN OF TY_ZINW_T_HDR,
*         QR_CODE    TYPE ZQR_CODE,
*         EBELN      TYPE EBELN,
*         TRNS       TYPE ZTRANS,                               "TRANSPORTER
*         LR_NO      TYPE ZLR,                                   "LR NO
*         BILL_NUM   TYPE ZBILL_NUM,                             "vendor invoice number
*         BILL_DATE  TYPE ZBILL_DAT,                            "vendor invoice date
*         ACT_NO_BUD TYPE ZNO_BUD,
*         MBLNR      TYPE MBLNR,
*         MBLNR_103  TYPE MBLNR,
*         return_po TYPE EBELN,
*       END OF TY_ZINW_T_HDR.
*
*TYPES: BEGIN OF TY_KNA1,
*         ADRNR TYPE ADRNR,                                    "PLANT ADDRESS NO
*         NAME1 TYPE NAME1_GP,                                 "PLANT NAME
*         SORTL TYPE SORTL,                                    "PLANT AREA
*       END OF TY_KNA1.
*
**TYPES: BEGIN OF TY_MEPO1211,
**        MATNR TYPE MATNR,
**        RETPO TYPE RETPO,                                     "RETURN ITEMS
**        END OF TY_MEPO1211.
*TYPES : BEGIN OF TY_ADRC,
*          ADDRNUMBER TYPE  ADRC-ADDRNUMBER,
*          NAME1      TYPE ADRC-NAME1,
*          CITY1      TYPE ADRC-CITY1,
*          STREET     TYPE ADRC-STREET,
*          STR_SUPPL1 TYPE ADRC-STR_SUPPL1,
*          STR_SUPPL2 TYPE ADRC-STR_SUPPL2,
*          COUNTRY    TYPE ADRC-COUNTRY,
*          LANGU      TYPE ADRC-LANGU,
*          REGION     TYPE ADRC-REGION,
*          POST_CODE1 TYPE ADRC-POST_CODE1,
*        END OF TY_ADRC.
*
*TYPES :BEGIN OF TY_T005U,
*         SPRAS TYPE T005U-SPRAS,
*         LAND1 TYPE T005U-LAND1,
*         BLAND TYPE T005U-BLAND,
*         BEZEI TYPE T005U-BEZEI,
*       END OF TY_T005U.
*
*TYPES : BEGIN OF TY_T005T,
*          SPRAS TYPE SPRAS,
*          LAND1 TYPE LAND1,
*          LANDX TYPE LANDX,
*        END OF TY_T005T.
*
*TYPES : BEGIN OF TY_EKBE,
*          EBELN TYPE EBELN,
*          VGABE TYPE VGABE,
*          BELNR TYPE MBLNR,
*          BUDAT TYPE BUDAT,
*        END OF TY_EKBE.
*
*TYPES : BEGIN OF TY_ZINW_T_ITEM,
*          QR_CODE  TYPE   ZINW_T_ITEM-QR_CODE,
*          EBELN    TYPE   ZINW_T_ITEM-EBELN,
*          MATNR    TYPE   ZINW_T_ITEM-MATNR,
*          WERKS    TYPE   ZINW_T_ITEM-WERKS,
*          MWSKZ_P  TYPE  ZINW_T_ITEM-MWSKZ_P,
*          NETPR_GP TYPE ZINW_T_ITEM-NETPR_GP,
*        END OF TY_ZINW_T_ITEM.
*
*
*TYPES : BEGIN OF TY_ZINW_T_STATUS,
*          INWD_DOC     TYPE ZINWD_DOC,
*          QR_CODE      TYPE ZQR_CODE,
*          STATUS_FIELD TYPE ZSTATUS_FIELD,
*          STATUS_VALUE TYPE ZSTATUS_VALUE,
*          DESCRIPTION  TYPE ZDESCRIPTION,
*          CREATED_DATE TYPE ERDAT,
*          CREATED_TIME TYPE ERZET,
*          CREATED_BY   TYPE ERNAM,
*        END OF TY_ZINW_T_STATUS.
*DATA : WA_ZINW_T_STATUS TYPE TY_ZINW_T_STATUS.
*DATA: IT_EKKO        TYPE TABLE OF TY_EKKO,
*      IT_EKKO1       TYPE TABLE OF TY_EKKO,
*      WA_EKKO        TYPE TY_EKKO,
*      WA_EKKO1       TYPE TY_EKKO,
*      IT_EKPO        TYPE TABLE OF TY_EKPO,
*      WA_EKPO        TYPE TY_EKPO,
*      IT_T001W       TYPE TABLE OF TY_T001W,
*      WA_T001W       TYPE TY_T001W,
*      WA_T005U       TYPE TY_T005U,
*      WA_T005U1      TYPE TY_T005U,
*      WA_T005T       TYPE TY_T005T,
*      WA_T005T1      TYPE TY_T005T,
*      WA_ADRC        TYPE TY_ADRC,
*      WA_ADRC1       TYPE TY_ADRC,
*      IT_LFA1        TYPE TABLE OF TY_LFA1,
*      WA_LFA1        TYPE TY_LFA1,
*      WA_EKBE        TYPE TY_EKBE,
*      IT_MAKT        TYPE TABLE OF TY_MAKT,
*      WA_MAKT        TYPE TY_MAKT,
*      IT_KONV        TYPE TABLE OF TY_KONV,
*      WA_KONV        TYPE TY_KONV,
*      IT_MSEG        TYPE TABLE OF TY_MSEG,
*      WA_MSEG        TYPE TY_MSEG,
*      IT_MKPF        TYPE TABLE OF TY_MKPF,
*      WA_MKPF        TYPE TY_MKPF,
*      IT_J_1BBRANCH  TYPE TABLE OF TY_J_1BBRANCH,
*      WA_J_1BBRANCH  TYPE TY_J_1BBRANCH,
*      IT_ADR6        TYPE TABLE OF TY_ADR6,
*      WA_ADR6        TYPE TY_ADR6,
*      IT_ZINW_T_HDR  TYPE TABLE OF TY_ZINW_T_HDR,
*      WA_ZINW_T_HDR  TYPE TY_ZINW_T_HDR,
*      IT_KNA1        TYPE TABLE OF TY_KNA1,
*      IT_ZINW_T_ITEM TYPE TABLE OF TY_ZINW_T_ITEM,
*      WA_KNA1        TYPE TY_KNA1,
*      WA_ITEM        TYPE TY_ZINW_T_ITEM,
**      IT_MEPO1211   TYPE TABLE OF TY_MEPO1211,
**      WA_MEPO1211   TYPE TY_MEPO1211,
*      IT_FINAL       TYPE TABLE OF ZPURCHASE_FINAL,
*      WA_FINAL       TYPE ZPURCHASE_FINAL,
*      WA_HEADER      TYPE ZPURCHASE_HEADER.
*
*DATA: FM_NAME  TYPE  RS38L_FNAM.
*DATA: LV_SL(03)  TYPE  I VALUE 0.
*
**DATA: lv_ebeln TYPE ekko-ebeln.
*
*"-------------------------------------------------"-------------------------------------------------"-------------------------------------------------"-------------------------------------------------
*
**** Types declaration for EKKO table
*TYPES: BEGIN OF TY_HDR,
*         EBELN   TYPE EBELN,
*         QR_CODE TYPE ZQR_CODE,
*       END OF TY_HDR.
*
**** Types declaration for EKPO table
**TYPES: BEGIN OF TY_ITEM,
**         QR_CODE TYPE    ZQR_CODE,
**         EBELN   TYPE    EBELN,
**         EBELP   TYPE    EBELP,
**         MATNR   TYPE    MATNR,
**         LGORT   TYPE    LGORT_D,
**         WERKS   TYPE    EWERK,
**         MAKTX   TYPE    MAKTX,
**         MATKL   TYPE    MATKL,
**         MENGE_P TYPE    ZMENGE_P,
**         MEINS   TYPE    BSTME,
**       END OF TY_ITEM.
*
**** Types declaration for Output data structure
*TYPES: BEGIN OF TY_DET,
*         EBELN       TYPE EBELN,
*         MBLNR       TYPE MBLNR,
*         MJAHR       TYPE MJAHR,
*         MSG_TYPE(1),
*         MESSAGE     TYPE BAPIRET2-MESSAGE,
*       END OF TY_DET.
*
**** Internal Tables Declaration
*DATA: LT_HDR  TYPE STANDARD TABLE OF TY_HDR,
*      LT_ITEM TYPE STANDARD TABLE OF ZINW_T_ITEM,
*      LT_DET  TYPE STANDARD TABLE OF TY_DET.
*
**** Work area Declarations
*DATA:
*      WA_DET  TYPE TY_DET.
*
**** BAPI Structure Declaration
*DATA:
*  WA_GMVT_HEADER  TYPE BAPI2017_GM_HEAD_01,
*  WA_GMVT_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
*  WA_GMVT_HEADRET TYPE BAPI2017_GM_HEAD_RET,
*  LT_BAPIRET      TYPE STANDARD TABLE OF BAPIRET2,
*  LT_GMVT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE.
*FIELD-SYMBOLS :
*  <LS_BAPIRET> TYPE BAPIRET2.
