*&---------------------------------------------------------------------*
*& Include          ZFI_PUR_REGISTER_TOP
*&---------------------------------------------------------------------*
 TYPE-POOLS : SLIS.
 TABLES: EKBE,RBKP,RSEG,MARA,MSEG,BKPF,BSEG.

 TYPES: BEGIN OF T_EKBE,
          EBELN TYPE EKBE-EBELN,
          BELNR TYPE EKBE-BELNR,
          BEWTP TYPE EKBE-BEWTP,
          BUDAT TYPE EKBE-BUDAT,
          WERKS TYPE EKBE-WERKS,
          GJAHR TYPE EKBE-GJAHR,
        END OF T_EKBE.

 TYPES : BEGIN OF TY_RBKP,
           BELNR  TYPE RBKP-BELNR, "INVOICE NO
           GJAHR  TYPE RBKP-GJAHR, "FISCAL YEAR
           BLDAT  TYPE RBKP-BLDAT, "DOCUMENT DATE
           BUDAT  TYPE RBKP-BUDAT, " POSTING DATE
           XBLNR  TYPE RBKP-XBLNR, " REFERENCE NUMBER
           LIFNR  TYPE RBKP-LIFNR, "Invoicing Party
           WAERS  TYPE RBKP-WAERS , "Currency
           KURSF  TYPE RBKP-KURSF, " Exchange Rate
           BEZNK  TYPE RBKP-BEZNK, "Unplanned delivery cost
           WMWST1 TYPE RBKP-WMWST1, " TAX AMAOUNT
           XRECH  TYPE RBKP-XRECH, "INDICATOR
           SGTXT  TYPE RBKP-SGTXT, "text
           BUKRS  TYPE RBKP-BUKRS,
           BKTXT  TYPE RBKP-BKTXT,
           GSBER  TYPE RBKP-GSBER,
*           SGTXT  TYPE RBKP-SGTXT,
         END OF TY_RBKP,

         BEGIN OF TY_RSEG,
           BELNR   TYPE RSEG-BELNR, "INVOICE NO
           BUKRS   TYPE RSEG-BUKRS, "COMPANY CODE
           GJAHR   TYPE RSEG-GJAHR, "FISCAL YEAR
           BUZEI   TYPE RSEG-BUZEI, "Document Item in Invoice Document
           EBELN   TYPE RSEG-EBELN, "PURCHASE ORDER
           EBELP   TYPE RSEG-EBELP, "Item Number of Purchasing Document
           MATNR   TYPE RSEG-MATNR, " Material number
           WERKS   TYPE RSEG-WERKS, "PLANT
           WRBTR   TYPE dec8_2,                     "RSEG-WRBTR, " Gross amount
           MWSKZ   TYPE RSEG-MWSKZ, " Tax Code
           MENGE   TYPE RSEG-MENGE, "Quantity
           MEINS   TYPE RSEG-MEINS, "UOM
           LFBNR   TYPE RSEG-LFBNR, "reference document no
           HSN_SAC TYPE RSEG-HSN_SAC,  "HSN code
           XBLNR   TYPE RSEG-XBLNR,
           KSCHL   TYPE RSEG-KSCHL,
           SHKZG   TYPE SHKZG,
         END OF TY_RSEG,

         BEGIN OF TY_MSEG,
           MBLNR      TYPE MSEG-MBLNR,
           MJAHR      TYPE MSEG-MJAHR,
           ZEILE type mseg-ZEILE ,
           EBELN      TYPE MSEG-EBELN,
           EBELP      TYPE MSEG-EBELP,
           BUDAT_MKPF TYPE MSEG-BUDAT_MKPF,
           VBELN_IM   TYPE MSEG-VBELN_IM,
           BWART      TYPE MSEG-BWART,
           LGORT      TYPE MSEG-LGORT,
           MENGE      TYPE  MENGE_D,                  "Quantity
           DMBTR      TYPE DMBTR_CS,                      "Amount in Local Currency
           SHKZG      TYPE SHKZG,                                            "ADDED BY N
         END OF TY_MSEG,

         BEGIN OF TY_BKPF ,
           BUKRS TYPE BKPF-BUKRS, "COMPANY CODE
           BELNR TYPE BKPF-BELNR, " FI DOC NUMBER
           GJAHR TYPE BKPF-GJAHR, "FISCAL YEAR
           CPUDT TYPE BKPF-CPUDT, "CREATION DATE
           CPUTM TYPE BKPF-CPUTM, "CREATION TIME
           BLART TYPE BKPF-BLART, " DOC TYPE
           BLDAT TYPE BKPF-BLDAT, " DOC DATE
           USNAM TYPE BKPF-USNAM, "USERNAME
           WAERS TYPE BKPF-WAERS, "Currency
           MONAT TYPE BKPF-MONAT,  "Posting period.
           KURSF TYPE BKPF-KURSF, "Exchange rate
           AWKEY TYPE BKPF-AWKEY, "Reference Key
           XBLNR TYPE BKPF-XBLNR, "Reference doc
         END OF TY_BKPF,

         BEGIN OF TY_BSEG ,
           BUKRS TYPE BSEG-BUKRS,
           BELNR TYPE BSEG-BELNR,
           GJAHR TYPE BSEG-GJAHR,
           BUZEI TYPE BSEG-BUZEI,
           BSCHL TYPE BSEG-BSCHL,
           KOART TYPE BSEG-KOART,
           MWSKZ TYPE BSEG-MWSKZ,
           HKONT TYPE BSEG-HKONT,
           BUPLA TYPE BSEG-BUPLA,
           SHKZG TYPE BSEG-SHKZG,
           DMBTR TYPE BSEG-WRBTR,
           WRBTR TYPE BSEG-WRBTR,
           MENGE TYPE BSEG-MENGE,
           EBELN TYPE BSEG-EBELN,
           EBELP TYPE BSEG-EBELP,
           MATNR TYPE BSEG-MATNR,
           TAXPS TYPE BSEG-TAXPS,
           TXGRP TYPE BSEG-TXGRP,
           AWKEY TYPE BSEG-AWKEY,
           VBELN TYPE BSEG-VBELN,
           ZUONR TYPE BSEG-ZUONR,
         END OF TY_BSEG,

         BEGIN OF TY_LFA1,
           LIFNR     TYPE LFA1-LIFNR,
           REGIO     TYPE LFA1-REGIO,
           ADRNR     TYPE LFA1-ADRNR,
           STCD1     TYPE LFA1-STCD1,
           J_1ILSTNO TYPE LFA1-J_1ILSTNO,
           LAND1     TYPE	LAND1_GP,                   "Country Key
           STCD3     TYPE	STCD3,                      "Tax Number 3
         END OF TY_LFA1,

         BEGIN OF TY_T005T,
           SPRAS   TYPE SPRAS,                      "Language Key
           LAND1   TYPE LAND1,                        "Country Key
           LANDX50 TYPE LANDX50,                          "Country Name (Max. 50 Characters)
         END OF TY_T005T,

         BEGIN OF TY_ADRC,
           ADDRNUMBER TYPE ADRC-ADDRNUMBER,
           NAME1      TYPE ADRC-NAME1,
           CITY1      TYPE ADRC-CITY1,
           COUNTRY    TYPE ADRC-COUNTRY,
         END OF TY_ADRC,
* """"""""BSET"""""""""""""""""
         BEGIN OF T_BSET,
           BUKRS TYPE BSET-BUKRS,
           BELNR TYPE BSET-BELNR,
           GJAHR TYPE BSET-GJAHR,
           BUZEI TYPE BSET-BUZEI,
           MWSKZ TYPE BSET-MWSKZ,
           HWBAS TYPE BSET-HWBAS,
           HWSTE TYPE BSET-HWSTE,
           HKONT TYPE BSET-HKONT,
           TAXPS TYPE BSET-TAXPS, "tax item
           TXGRP TYPE BSET-TXGRP,
           KSCHL TYPE BSET-KSCHL,
           SHKZG TYPE SHKZG,
         END OF T_BSET,

         BEGIN OF T_MAKT,
           MATNR TYPE MAKT-MATNR,
           MAKTX TYPE MAKT-MAKTX,
         END OF T_MAKT,

*        BEGIN OF T_KONV,
*          KNUMV TYPE KONV-KNUMV,
*          KPOSN TYPE KONV-KPOSN,
*          KSCHL TYPE KONV-KSCHL,
*          KBETR TYPE KONV-KBETR,
*          KWERT TYPE KONV-KWERT,
*        END OF T_KONV,
********************************************************************
         BEGIN OF TY_MARA,
           MATNR TYPE MATNR,
           MATKL TYPE MATKL,
           MFRPN TYPE MFRPN,
         END OF TY_MARA,

         BEGIN OF TY_EKPO,
           EBELN TYPE EBELN,
           EBELP TYPE EBELP,
           MENGE TYPE BSTMG,
           NETWR TYPE BWERT,
         END OF TY_EKPO,

         BEGIN OF TY_EKET,
           EBELN TYPE EBELN,
           EBELP TYPE EBELP,
           EINDT TYPE EINDT,
         END OF TY_EKET,

         BEGIN OF TY_PRCD,
           KNUMV TYPE  KNUMV,
           KPOSN TYPE KPOSN,
           KSCHL TYPE KSCHA,
           KNUMH TYPE KNUMH,
           KOPOS TYPE KOPOS_LONG,
           KWERT TYPE VFPRC_ELEMENT_VALUE,
           KBETR TYPE  VFPRC_ELEMENT_VALUE,
           MWSK1 TYPE MWSKZ,
         END OF TY_PRCD,

         BEGIN OF TY_EKKO,
           EBELN TYPE EBELN,
           KNUMV TYPE KNUMV,
           RLWRT TYPE RLWRT,
           BSART TYPE ESART,
         END OF TY_EKKO,

         BEGIN OF TY_MCH1,
           LIFNR TYPE LIFNR,
           LICHA TYPE LICHN,
         END OF TY_MCH1,

*         BEGIN OF TY_ZGEMIGO,
*           MBLNR    TYPE MBLNR,               "material doc no
*           MJAHR    TYPE MJAHR,               "material doc year
*           ZLR_NO   TYPE ZLR_NO,              "lr no
*           ZLR_DATE TYPE ZLR_DATE,            "lr date
*           ZVEHICLE TYPE ZVEHICLE,            "lorry no
*           ZTRNPRT  TYPE ZTRANSPORT_NAME,     "transporter name
*         END OF TY_ZGEMIGO,

         BEGIN OF TY_MARC,
           MATNR TYPE MATNR,                     "Material Number
           WERKS TYPE WERKS_D,                     "Plant
           STEUC TYPE STEUC,                       "Control code for consumption taxes in foreign trade
         END OF TY_MARC,

         BEGIN OF TY_MKPF,
           MBLNR TYPE MKPF-MBLNR,
           MJAHR TYPE MKPF-MJAHR,
           FRBNR TYPE MKPF-FRBNR,
         END OF TY_MKPF,

         BEGIN OF TY_FINAL,
           BELNR      TYPE RSEG-BELNR, "INVOICE NO
           GJAHR      TYPE RSEG-GJAHR, "FISCAL YEAR
           BUKRS      TYPE RSEG-BUKRS,
           BLDAT      TYPE RBKP-BLDAT, "DOCUMENT DATE
           BUDAT      TYPE RBKP-BUDAT, " POSTING DATE
           XBLNR      TYPE RBKP-XBLNR, " REFERENCE NUMBER
           LIFNR      TYPE RBKP-LIFNR, "Invoicing Party
           LANDX50    TYPE LANDX50,
           STEUC      TYPE STEUC,
           WAERS      TYPE RBKP-WAERS , "Currency
*        WMWST1 TYPE RBKP-WMWST1, " TAX AMAOUNT
           BUZEI      TYPE RSEG-BUZEI, "Document Item in Invoice Document
           EBELN      TYPE RSEG-EBELN, "PURCHASE ORDER
           EBELP      TYPE RSEG-EBELP, "Item Number of Purchasing Document
           MATNR      TYPE RSEG-MATNR, " Material number
           WERKS      TYPE RSEG-WERKS, "PLANT
           MEINS      TYPE RSEG-MEINS, "UOM
           WRBTR      TYPE dec8_2,"RSEG-WRBTR, " BASE amount
           MWSKZ      TYPE RSEG-MWSKZ, " Tax Code
           MENGE      TYPE RSEG-MENGE, "QUANTITY
*          XEKBZ      TYPE RSEG-XEKBZ, "unplanned delivery cost
           HSN_SAC    TYPE RSEG-HSN_SAC,  "HSN code
           MBLNR      TYPE MSEG-MBLNR,
           BUDAT1     TYPE MSEG-BUDAT_MKPF,
           MENGE1     TYPE MENGE_D,                    "Quantity
           MAKTX      TYPE MAKT-MAKTX,   "material description
           G_AMT      TYPE WRBTR, "GROSS AMOUNT
           NAME1      TYPE ADRC-NAME1,
           CITY1      TYPE ADRC-CITY1,
           MWSKZ1     TYPE BSEG-MWSKZ,
           WRBTR1     TYPE dec8_2,
           FI_DOC     TYPE BSEG-BELNR,
           BELNR2     TYPE BSET-BELNR,
           BUZEI2     TYPE BSET-BUZEI,
           IGST       TYPE BSET-HWSTE,
           CGST       TYPE BSET-HWSTE,
           SGST       TYPE BSET-HWSTE,
           UGST       TYPE BSET-HWSTE,
           NET_AMOUNT TYPE WRBTR,
           MATKL      TYPE MATKL,
           VBELN_IM   TYPE MSEG-VBELN_IM,
           P_TERM     TYPE STRING,
           MENGE_P    TYPE BSTMG,
           CUSTOM     TYPE WRBTR,
           EINDT      TYPE EINDT,
           FREIGHT    TYPE KWERT,
           JCDB       TYPE KWERT,
           OTHR       TYPE KWERT,
           ZSOC       TYPE KWERT,
           JEDB       TYPE KWERT,
           JEDS       TYPE KWERT,
           JADD       TYPE KWERT,
           DADD       TYPE KWERT,
           TYPE       TYPE CHAR6,
           LICHA      TYPE LICHN,
           MFRPN      TYPE MFRPN,
           BWART      TYPE BWART,
           LGORT      TYPE LGORT_D,
           NETWR      TYPE NETWR,
           BSART      TYPE ESART,
           PACK       TYPE KWERT,
           ZLR_NO     TYPE char18, "ZLR_NO,              "lr no
           ZLR_DATE   TYPE DATUM,            "lr date
           ZVEHICLE   TYPE CHAR18,            "lorry no
           ZTRNPRT    TYPE CHAR40,     "transporter name
           STCD3      TYPE STCD3,               "Tax Number 3
           DMBTR      TYPE DMBTR_CS,                      "Amount in Local Currency
           ZUONR      TYPE BSEG-ZUONR,
           BKTXT      TYPE RBKP-BKTXT,
           SGTXT      TYPE RBKP-SGTXT,
           FRBNR      TYPE MKPF-FRBNR,
           HWBAS      TYPE BSET-HWBAS,
         END OF TY_FINAL.


 DATA : IT_EKBE    TYPE STANDARD TABLE OF T_EKBE,
        IT_RBKP    TYPE STANDARD TABLE OF TY_RBKP,
        IT_RSEG    TYPE STANDARD TABLE OF TY_RSEG,
        IT_RSEG1    TYPE STANDARD TABLE OF TY_RSEG,
        IT_MSEG    TYPE STANDARD TABLE OF TY_MSEG,
        IT_BKPF    TYPE STANDARD TABLE OF TY_BKPF,
        IT_BSEG    TYPE STANDARD TABLE OF TY_BSEG,
        IT_BSET    TYPE STANDARD TABLE OF T_BSET,
        IT_MAKT    TYPE STANDARD TABLE OF T_MAKT,
        IT_LFA1    TYPE STANDARD TABLE OF TY_LFA1,
        IT_ADRC    TYPE STANDARD TABLE OF TY_ADRC,
        IT_FINAL   TYPE STANDARD TABLE OF TY_FINAL,
        IT_FINAL1  TYPE STANDARD TABLE OF TY_FINAL,
        IT_FINAL2  TYPE STANDARD TABLE OF TY_FINAL,
        IT_ACCTIT  TYPE TABLE OF ACCTIT,
        IT_MARA    TYPE TABLE OF TY_MARA,
        WA_MARA    TYPE TY_MARA,
        IT_MARC    TYPE TABLE OF TY_MARC,
        WA_MARC    TYPE TY_MARC,
        WA_EKBE    TYPE T_EKBE,
        WA_RBKP    TYPE TY_RBKP,
        WA_RSEG    TYPE TY_RSEG,
        WA_RSEG1    TYPE TY_RSEG,
        WA_MSEG    TYPE TY_MSEG,
        WA_BKPF    TYPE TY_BKPF,
        WA_BSEG    TYPE TY_BSEG,
        WA_BSET    TYPE T_BSET,
        WA_MAKT    TYPE T_MAKT,
        WA_LFA1    TYPE TY_LFA1,
        WA_ADRC    TYPE TY_ADRC,
        WA_FINAL   TYPE TY_FINAL,
        WA_FINAL1  TYPE TY_FINAL,
        WA_FINAL2  TYPE TY_FINAL,
        TDOBNAME   TYPE TDOBNAME,
        WA_LINE    TYPE TLINE,
        IT_LINE    TYPE TABLE OF TLINE,
        WA_EKKO    TYPE TY_EKKO,
        IT_EKKO    TYPE TABLE OF TY_EKKO,
        WA_EKPO    TYPE TY_EKPO,
        IT_EKPO    TYPE TABLE OF TY_EKPO,
        WA_EKET    TYPE TY_EKET,
        IT_T005T   TYPE TABLE OF TY_T005T,
        WA_T005T   TYPE TY_T005T,
        IT_EKET    TYPE TABLE OF TY_EKET,
        IT_PRCD    TYPE TABLE OF TY_PRCD,
        WA_PRCD    TYPE TY_PRCD,
        IT_MCH1    TYPE TABLE OF TY_MCH1,
        WA_MCH1    TYPE TY_MCH1.
*        IT_ZGEMIGO TYPE TABLE OF TY_ZGEMIGO,
*        WA_ZGEMIGO TYPE TY_ZGEMIGO.
 DATA: WA_KONP  TYPE KONP.
*       lv_menge type BSTMG.
DATA: IT_MKPF TYPE TABLE OF TY_MKPF,
      WA_MKPF TYPE TY_MKPF.
 DATA : IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
        WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
*        IT_SORT   TYPE SLIS_T_SORTINFO_ALV,
*        WA_SORT   TYPE SLIS_SORTINFO_ALV,
        GT_LAYOUT TYPE SLIS_LAYOUT_ALV.

 DATA : I_SORT TYPE SLIS_T_SORTINFO_ALV .
 DATA : WA_SORT LIKE LINE OF I_SORT .


 DATA: V_ADDR(60)   TYPE C,
       G_AMT        TYPE WRBTR,
       NET_AMOUNT   TYPE WRBTR,
       LV_NAME1(60) TYPE C,
       LV_FREIGHT   TYPE KWERT.
