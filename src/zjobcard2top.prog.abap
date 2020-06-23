*&---------------------------------------------------------------------*
*& Include ZJOBCARD2TOP                             - Report ZJOBCARD2
*&---------------------------------------------------------------------*
REPORT ZJOBCARD2.
TYPES : BEGIN OF TY_EKPO,
          EBELN          TYPE EBELN,                              "Purchasing Document Number
          EBELP          TYPE EBELP,                              "Item Number of Purchasing Document
          WERKS          TYPE EWERK,                              "Plant
          MATNR          TYPE MATNR,                              "Material Number
          MWSKZ          TYPE MWSKZ,                              "Tax on Sales/Purchases Code
          MENGE          TYPE BSTMG,                              "Purchase Order Quantity
          MEINS          TYPE EKPO-MEINS,
          NETPR          TYPE BPREI,                              "Net Price in Purchasing Document (in Document Currency)
          PEINH          TYPE EPEIN,                              "Price unit
          ZZSET_MATERIAL TYPE EKPO-ZZSET_MATERIAL,
          NETWR          TYPE BWERT,                              "Net Order Value in PO Currency
          BUKRS          TYPE BUKRS,
          RETPO          TYPE RETPO,
*          APPROVER1
        END OF TY_EKPO,

        BEGIN OF TY_EKKO,
          EBELN     TYPE EBELN,                               "Purchasing Document Number
          BUKRS     TYPE BUKRS,                                " Company Code
          BSART     TYPE ESART,
          AEDAT     TYPE ERDAT,
          SPRAS     TYPE EKKO-SPRAS,
          LIFNR     TYPE ELIFN,                               "Vendor's account number
          EKGRP     TYPE EKKO-EKGRP,
          BEDAT     TYPE EBDAT,                               "Purchasing Document Date
          KNUMV     TYPE  KNUMV,                               "Number of the Document Condition
          APPROVER1 TYPE ZPPROVER1,
        END OF TY_EKKO,

        BEGIN OF TY_LFA1,
          LIFNR TYPE LIFNR,                                "Account Number of Vendor or Creditor
          LAND1 TYPE LAND1_GP,                             "Country Key
          NAME1 TYPE NAME1_GP,                             "Name 1
          ORT01 TYPE ORT01_GP,                             "City
          REGIO TYPE REGIO,                                "Region (State, Province, County)
          STRAS TYPE STRAS_GP,                             "Street and House Number
          STCD3 TYPE STCD3,                                "Tax Number 3
          ADRNR TYPE ADRNR,
        END OF TY_LFA1,

        BEGIN OF TY_T001W,
          WERKS TYPE WERKS_D,                            "Plant
          NAME1 TYPE NAME1,                              "Name
          STRAS TYPE STRAS,                              "Street and House Number
          ORT01 TYPE ORT01,                              "City
          LAND1 TYPE LAND1,                              "Country Key
          ADRNR TYPE ADRNR,
        END OF TY_T001W,

        BEGIN OF TY_MARA,
          MATNR TYPE MARA-MATNR,
          EAN11 TYPE MARA-EAN11,
          MATKL TYPE MARA-MATKL,
        END OF TY_MARA,

        BEGIN OF TY_MAKT,
          MATNR TYPE MATNR,                                "Material Number
          SPRAS TYPE SPRAS,                                "Language Key
          MAKTX TYPE MAKTX,                                "Material description
        END OF TY_MAKT,

        BEGIN OF TY_T001,
          BUKRS TYPE T001-BUKRS,
          ADRNR TYPE T001-ADRNR,
        END OF TY_T001,

        BEGIN OF TY_T024,
          EKNAM TYPE T024-EKNAM,
          EKGRP TYPE T024-EKGRP,
        END OF TY_T024,

        BEGIN OF TY_T023T,
          MATKL   TYPE T023T-MATKL,
          WGBEZ   TYPE T023T-WGBEZ,
          WGBEZ60 TYPE T023T-WGBEZ60,
        END OF TY_T023T,

        BEGIN OF TY_J_1BBRANCH,
          BUKRS TYPE J_1BBRANCH-BUKRS,                                  "COMPANY CODE
          GSTIN TYPE J_1IGSTCD3,                             "GST NO
        END OF TY_J_1BBRANCH,

        BEGIN OF TY_ADR6,
          ADDRNUMBER TYPE AD_ADDRNUM,
          SMTP_ADDR  TYPE AD_SMTPADR,
        END OF TY_ADR6,

        BEGIN OF TY_ADRC,
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
        END OF TY_ADRC,

        BEGIN OF TY_MSEG,
          MBLNR TYPE MSEG-MBLNR,
          MJAHR TYPE MSEG-MJAHR,
          XAUTO TYPE mseg-XAUTO,
          MATNR TYPE MSEG-MATNR,
          MENGE TYPE MSEG-MENGE,
          EBELN TYPE mseg-EBELN,
          EBELP TYPE mseg-EBELP,
          BWART TYPE MSEG-BWART,
          BUDAT_MKPF TYPE mseg-BUDAT_MKPF,
          USNAM_MKPF TYPE mseg-USNAM_MKPF,
        END OF TY_MSEG.

DATA : IT_EKKO       TYPE TABLE OF TY_EKKO,
       WA_EKKO       TYPE TY_EKKO,

       IT_EKPO       TYPE TABLE OF TY_EKPO,
       WA_EKPO       TYPE TY_EKPO,

       IT_LFA1       TYPE TABLE OF TY_LFA1,
       WA_LFA1       TYPE TY_LFA1,

       IT_T001W      TYPE TABLE OF TY_T001W,
       WA_T001W      TYPE TY_T001W,

       IT_MARA       TYPE TABLE OF TY_MARA,
       WA_MARA       TYPE TY_MARA,

       IT_MAKT       TYPE TABLE OF TY_MAKT,
       WA_MAKT       TYPE TY_MAKT,

       IT_T001       TYPE TABLE OF TY_T001,
       WA_T001       TYPE TY_T001,

       IT_T024       TYPE TABLE OF TY_T024,
       WA_T024       TYPE TY_T024,

       IT_T023T      TYPE TABLE OF TY_T023T,
       WA_T023T      TYPE TY_T023T,

       IT_J_1BBRANCH TYPE TABLE OF TY_J_1BBRANCH,
       WA_J_1BBRANCH TYPE TY_J_1BBRANCH,

       IT_ADR6       TYPE TABLE OF TY_ADR6,
       WA_ADR6       TYPE TY_ADR6,

       IT_ADRC       TYPE TABLE OF TY_ADRC,
       WA_ADRC       TYPE TY_ADRC,

       IT_MSEG       TYPE TABLE OF TY_MSEG,
       WA_MSEG       TYPE TY_MSEG,

       it_mseg2      TYPE TABLE OF ty_mseg,
       wa_mseg2       TYPE ty_mseg.

DATA : IT_ZMAIN   TYPE TABLE OF ZITEM_JOBCARD,
*       it_matdoc   TYPE TABLE OF zjb_matdoc,
       WA_ZMAIN   TYPE ZITEM_JOBCARD,

       IT_HDR     TYPE TABLE OF ZJOBCARD,
       WA_HDR     TYPE ZJOBCARD,
       SL_NO(100) TYPE C,
       TOT_QTY    TYPE EKPO-MENGE.

DATA : QR_CODE TYPE ZQR_CODE.

DATA : F_NAME TYPE RS38L_FNAM.
*       DATA : qr_code TYPE zqr_code.

SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_EBELN TYPE EBELN.
SELECTION-SCREEN END OF BLOCK A1.
