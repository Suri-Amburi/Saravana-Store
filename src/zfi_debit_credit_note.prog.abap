*&---------------------------------------------------------------------*
*& Report ZFI_DEBIT_CREDIT_NOTE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_DEBIT_CREDIT_NOTE.


TABLES: VBRK,VBAP,VBRP,KNA1,T001,T001W,ADRC,PRCD_ELEMENTS,LIKP,VBPA,VBKD,BSEG.
TYPES : BEGIN OF TY_VBRK,
          VBELN TYPE VBRK-VBELN,                        "Billing Document
          FKART TYPE VBRK-VBELN,                        "Billing Type
          WAERK TYPE VBRK-WAERK,                        "sd document currency
          FKDAT TYPE VBRK-FKDAT,                        "Billing date
          BUKRS TYPE VBRK-BUKRS,                        "Company Code
          KUNAG TYPE VBRK-KUNAG,                        "Sold-to party
          KNUMV TYPE VBRK-KNUMV,                        "Number of the Document Condition
          VTWEG TYPE VBRK-VTWEG,                        "Number of the Document Condition
        END OF TY_VBRK.

TYPES : BEGIN OF TY_VBRP,
          VBELN TYPE VBRP-VBELN,                        "Billing Document
          POSNR TYPE VBRP-POSNR,                        "Billing Item
          MEINS TYPE VBRP-MEINS,                        "Base Unit of Measure
          FKLMG TYPE VBRP-FKLMG,                        "Billing quantity in stockkeeping unit
          NETWR TYPE VBRP-NETWR,                        "Net value of the billing item in document currency
          AUBEL TYPE VBRP-AUBEL,                        " controlling area
          MATNR TYPE VBRP-MATNR,
          CHARG TYPE VBRP-CHARG,                        "Batch Number
          WERKS TYPE VBRP-WERKS,                        "Plant
        END OF TY_VBRP.

TYPES: BEGIN OF TY_BSEG,
         BUKRS   TYPE BUKRS,                              "Company Code
         BELNR   TYPE BELNR_D,                            "Accounting Document Number
         GJAHR   TYPE GJAHR,                              "Fiscal Year
         BUZEI   TYPE BUZEI,                              "Number of Line Item Within Accounting Document
         GSBER   TYPE  GSBER,                             "Business Area
         DMBTR   TYPE DMBTR,                              "Amount in local currency
         KTOSL   TYPE KTOSL,                              "Transaction Key
         SGTXT   TYPE SGTXT,                              "Item Text
         MWSKZ   TYPE  MWSKZ,                             "Tax on Sales/Purchases Code
         WERKS   TYPE  WERKS_D,                           "Plant
         KOART   TYPE  KOART,                              "Account type
         KUNNR   TYPE KUNNR,                              "Customer Number
         HKONT   TYPE HKONT,                              " General Ledger Account
         LIFNR   TYPE LIFNR,                              "Account Number of Vendor or Creditor
         REBZG   TYPE  REBZG,                              "Document No. of the Invoice to Which the Transaction Belongs
         HSN_SAC TYPE J_1IG_HSN_SAC,                    "hsn_sac code
         H_BUDAT TYPE BUDAT,                            "Posting Date in Document
         H_BLART TYPE BLART,                            "Document type
         BSCHL   TYPE BSCHL,                            "Posting key
         H_WAERS TYPE WAERS,                            "Currency key
         PSWBT   TYPE PSWBT,
         WRBTR   TYPE WRBTR,                            "Amount in document currency
         ZUONR   TYPE DZUONR,                           " Assignment number
       END OF TY_BSEG.

TYPES:BEGIN OF TY_KNA1,
        KUNNR TYPE KNA1-KUNNR,                          "Plant
        ADRNR TYPE KNA1-ADRNR,
        STCD3 TYPE KNA1-STCD3,                          "Tax Number 3
        LAND1 TYPE LAND1_GP,
        REGIO TYPE REGIO,
      END OF  TY_KNA1.

TYPES: BEGIN OF TY_LFA1,
         LIFNR TYPE LIFNR,                             "Account Number of Vendor or Creditor
         ADRNR TYPE ADRNR,                             "Address
         STCD3 TYPE  STCD3,                              "Tax Number 3
         LAND1 TYPE LAND1_GP,
         REGIO TYPE REGIO,
       END OF TY_LFA1.

TYPES: BEGIN OF TY_T001,
         BUKRS TYPE T001-BUKRS,                         "Plant
         ADRNR TYPE T001-ADRNR,                         "Address
       END OF  TY_T001.

TYPES: BEGIN OF TY_T134G,
         WERKS TYPE  WERKS_D ,                           "Plant
         SPART TYPE SPART,                              "Division
         GSBER TYPE  GSBER,                              "Business Area
       END OF TY_T134G.

TYPES: BEGIN OF TY_T001W,
         WERKS      TYPE T001W-WERKS,                   "Plant
         KUNNR      TYPE T001W-KUNNR,
         ADRNR      TYPE T001W-ADRNR,                   "Address
         J_1BBRANCH TYPE T001W-J_1BBRANCH,
         LAND1      TYPE LAND1,
         REGIO      TYPE REGIO,
       END OF  TY_T001W.

TYPES: BEGIN OF TY_KONP,
         KNUMH TYPE KNUMH,                             "Condition record number
         KOPOS TYPE  KOPOS,                            "Sequential number of the condition
         KBETR TYPE  KBETR_KOND,                       "Condition amount or percentage where no scale exists
         KSCHL TYPE  KSCHA,                            "Condition type
       END OF TY_KONP.

TYPES: BEGIN OF TY_A003,
         KAPPL TYPE KAPPL,                             "Application
         KSCHL TYPE  KSCHA,                            "Condition type
         ALAND TYPE ALAND,                             "Departure country (country from which the goods are sent)
         MWSKZ TYPE MWSKZ,                             "Tax on Sales/Purchases Code
         KNUMH TYPE KNUMH,                             "Condition record number
       END OF TY_A003.

TYPES: BEGIN OF TY_ADRC,
         ADDRNUMBER TYPE ADRC-ADDRNUMBER,
         NAME1      TYPE ADRC-NAME2,
         STREET     TYPE ADRC-STREET,
         STR_SUPPL1 TYPE ADRC-STR_SUPPL1,
         STR_SUPPL2 TYPE ADRC-STR_SUPPL2,
         STR_SUPPL3 TYPE ADRC-STR_SUPPL3,
         CITY1      TYPE ADRC-CITY1,
         POST_CODE1 TYPE ADRC-POST_CODE1,
         TEL_NUMBER TYPE ADRC-TEL_NUMBER,
         FAX_NUMBER TYPE ADRC-FAX_NUMBER,
         COUNTRY    TYPE ADRC-COUNTRY,
         HOUSE_NUM1	TYPE AD_HSNM1,                                "House Number
         FLOOR      TYPE AD_FLOOR,
         BUILDING	  TYPE AD_BLDNG,
         LOCATION	  TYPE AD_LCTN,
         CITY2      TYPE AD_CITY2,
         TIME_ZONE  TYPE AD_TZONE,
       END OF TY_ADRC.

TYPES: BEGIN OF TY_MARC,
         MATNR TYPE  MARC-MATNR,                       "Material Number
         WERKS TYPE MARC-WERKS,                        "Plant
         STEUC TYPE  MARC-STEUC,                       "Control code for consumption taxes in foreign trade
       END OF TY_MARC.

TYPES: BEGIN OF TY_MAKT,
         MATNR TYPE MAKT-MATNR,                         "Material Number
         SPRAS TYPE MAKT-SPRAS,                         "Language Key
         MAKTX TYPE MAKT-MAKTX,                         "Material description
       END OF TY_MAKT.

TYPES: BEGIN OF TY_PRCD_ELEMENTS,
         KNUMV TYPE KNUMV,
         KPOSN TYPE KPOSN,
         STUNR TYPE STUNR,
         ZAEHK TYPE VFPRC_COND_COUNT,
         KWERT TYPE VFPRC_ELEMENT_VALUE,
         KBETR TYPE VFPRC_ELEMENT_AMOUNT,
         KSCHL TYPE KSCHA,
       END OF TY_PRCD_ELEMENTS.

TYPES  : BEGIN OF TY_MARA,
           MATNR TYPE MARA-MATNR,
           MEINS TYPE MARA-MEINS,
         END OF TY_MARA.

TYPES: BEGIN OF TY_LIKP,
         VBELN TYPE LIKP-VBELN,
         LFDAT TYPE LIKP-LFDAT,
*           zzlr_no    TYPE likp-zzlr_no,
*           zzlr_date  TYPE likp-zzlr_date,
*           zzlorry_no TYPE likp-zzlorry_no,
*           ztr_name   TYPE likp-ztr_name,
         VSTEL TYPE VSTEL,                                        "Shipping Point/Receiving Point
       END OF TY_LIKP.

TYPES : BEGIN OF TY_T012,
          BUKRS TYPE T012-BUKRS,
          HBKID TYPE T012-HBKID,
          BANKS TYPE T012-BANKS,
          BANKL TYPE T012-BANKL,
          TELF1 TYPE T012-TELF1,
          STCD1 TYPE T012-STCD1,
          NAME1 TYPE T012-NAME1,
          SPRAS TYPE T012-SPRAS,
        END OF TY_T012.
*  banks bankl banka brnch.

TYPES : BEGIN OF TY_BNKA,
          BANKS TYPE BNKA-BANKS,
          BANKL TYPE BNKA-BANKL,
          BANKA TYPE BNKA-BANKA,
          BRNCH TYPE BNKA-BRNCH,
        END OF TY_BNKA.

TYPES: BEGIN OF TY_J_1IMOCOMP,
         BUKRS     TYPE BUKRS,                          "Company Code
         WERKS     TYPE WERKS_D,                        "Plant
         J_1IEXCD  TYPE  J_1IEXCD,                      "ECC Number
         J_1IPANNO TYPE J_1IPANNO,                      "Permanent Account Number
       END OF TY_J_1IMOCOMP.

TYPES: BEGIN OF TY_T001Z,
         BUKRS TYPE BUKRS,
         PARTY TYPE PARTY,
         PAVAL TYPE PAVAL,
       END OF TY_T001Z.

TYPES : BEGIN OF TY_J_1BBRANCH,
          BUKRS  TYPE J_1BBRANCH-BUKRS,
          BRANCH TYPE J_1BBRANCH-BRANCH,
          ADRNR  TYPE J_1BBRANCH-ADRNR,
          GSTIN  TYPE J_1BBRANCH-GSTIN,
        END OF TY_J_1BBRANCH.

TYPES: BEGIN OF TY_VBPA,
         VBELN TYPE VBPA-VBELN,
         POSNR TYPE VBPA-POSNR,
         PARVW TYPE VBPA-PARVW,
         ADRNR TYPE VBPA-ADRNR,
       END OF TY_VBPA.

TYPES : BEGIN OF TY_VBKD,
          VBELN TYPE VBKD-VBELN,
          POSNR TYPE VBKD-POSNR,
          BSTKD TYPE VBKD-BSTKD,
          BSTDK TYPE VBKD-BSTDK,
        END OF TY_VBKD.

TYPES: BEGIN OF TY_T005T,
         SPRAS TYPE SPRAS,     "Language Key
         LAND1 TYPE LAND1,     "Country Key
         LANDX TYPE LANDX,     "Country Name
       END OF TY_T005T.

TYPES : BEGIN OF TY_T005U,
          LAND1 TYPE LAND1,
          BLAND TYPE REGIO,
          BEZEI TYPE BEZEI20,
        END OF TY_T005U,


        BEGIN OF ty_SKAT,
          SPRAS TYPE SPRAS,
          KTOPL TYPE KTOPL,
          SAKNR TYPE SAKNR,
          TXT20 TYPE TXT20_SKAT,
          TXT50 TYPE TXT50_SKAT,
          END OF ty_skat.

DATA: FM_NAME TYPE  RS38L_FNAM.

DATA : IT_VBRK          TYPE TABLE OF TY_VBRK,
       IT_VBRP          TYPE TABLE OF TY_VBRP,
       IT_BSEG          TYPE TABLE OF TY_BSEG,
       IT_BSEG1         TYPE TABLE OF TY_BSEG,
       it_SKAT          TYPE TABLE OF ty_SKAT,
       wa_SKAT          TYPE          ty_SKAT,
       IT_KNA1          TYPE TABLE OF TY_KNA1,
       IT_T001W         TYPE TABLE OF TY_T001W,
       IT_T001          TYPE TABLE OF TY_T001,
       IT_ADRC          TYPE TABLE OF TY_ADRC,
       IT_MARC          TYPE TABLE OF TY_MARC,
       IT_MAKT          TYPE TABLE OF TY_MAKT,
       IT_MARA          TYPE TABLE OF TY_MARA,
       IT_PRCD_ELEMENTS TYPE TABLE OF TY_PRCD_ELEMENTS,
       IT_J_1BBRANCH    TYPE TABLE OF TY_J_1BBRANCH,
       IT_VBPA          TYPE TABLE OF TY_VBPA,
       IT_LIKP          TYPE TABLE OF TY_LIKP,
       IT_T012          TYPE TABLE OF TY_T012,
       IT_BNKA          TYPE TABLE OF TY_BNKA,
       IT_A003          TYPE TABLE OF TY_A003,
       IT_KONP          TYPE TABLE OF TY_KONP,
       IT_J_1IMOCOMP    TYPE TABLE OF TY_J_1IMOCOMP,
       IT_T001Z         TYPE TABLE OF TY_T001Z,
       WA_VBRK          TYPE TY_VBRK,
       WA_VBRP          TYPE TY_VBRP,
       WA_BSEG          TYPE TY_BSEG,
       WA_BSEG1         TYPE TY_BSEG,
       WA_KNA1          TYPE TY_KNA1,
*       it_kna1          TYPE TABLE OF ty_kna1,
       WA_KNA1_1        TYPE TY_KNA1,
       WA_LFA1          TYPE TY_LFA1,
       IT_LFA1          TYPE TABLE OF TY_LFA1,
       WA_T001W         TYPE TY_T001W,
       WA_T134G         TYPE TY_T134G,
       WA_T001          TYPE TY_T001,
       WA_ADRC          TYPE TY_ADRC,
       WA_MARC          TYPE TY_MARC,
       WA_MAKT          TYPE TY_MAKT,
       WA_MARA          TYPE TY_MARA,
       WA_PRCD_ELEMENTS TYPE TY_PRCD_ELEMENTS,
       WA_LIKP          TYPE TY_LIKP,
       WA_T012          TYPE TY_T012,
       WA_BNKA          TYPE TY_BNKA,
       WA_J_1BBRANCH    TYPE TY_J_1BBRANCH,
       WA_VBPA          TYPE TY_VBPA,
       WA_A003          TYPE TY_A003,
       WA_KONP          TYPE TY_KONP,
       WA_VBKD          TYPE TY_VBKD,
       WA_J_1IMOCOMP    TYPE TY_J_1IMOCOMP,
       WA_ADRC_D        TYPE TY_ADRC,
       WA_ADRC_C        TYPE TY_ADRC,
       WA_T001Z         TYPE  TY_T001Z,
       WA_T005T         TYPE  TY_T005T,
       WA_T005U         TYPE  TY_T005U,
       WA_T005T1        TYPE  TY_T005T,
       WA_T005U1        TYPE  TY_T005U,
       WA_T005T2        TYPE  TY_T005T,
       WA_T005U2        TYPE  TY_T005U.

DATA : LV_S        TYPE I ,
       LV_DISCOUNT TYPE NETWR_FP,
       LV_AMT      TYPE NETWR_FP,
       LV_BUKRS    TYPE BUKRS,
       LV_GJAHR    TYPE GJAHR.

DATA : WA_HDR TYPE ZDEBIT_HEADER.
*DATA : it_hdr TYPE TABLE OF zsd_tax_inv_hdr.
DATA : WA_ITEM TYPE ZDEBIT_ITEM.
DATA : IT_ITEM TYPE TABLE OF ZDEBIT_ITEM.
DATA: IT_FTR TYPE TABLE OF ZSD_TAX_INV_FTR.
DATA : WA_FTR TYPE ZSD_TAX_INV_FTR.

SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: S_BUKRS FOR LV_BUKRS NO INTERVALS NO-EXTENSION OBLIGATORY,
                S_GJAHR FOR LV_GJAHR NO INTERVALS NO-EXTENSION OBLIGATORY.

PARAMETERS : P_BELNR TYPE BELNR_D OBLIGATORY.     "Input

PARAMETERS:P_RAD1 RADIOBUTTON GROUP RB1,
           P_RAD2 RADIOBUTTON GROUP RB1.
*           P_RAD3 RADIOBUTTON GROUP RB1,
*           P_RAD4 RADIOBUTTON GROUP RB1.
SELECTION-SCREEN: END OF BLOCK B1.


START-OF-SELECTION.
break CLIKHITHA.
  IF P_RAD1 = 'X'.
*SORT it_bseg BY buzei.

    SELECT
         BUKRS
         BELNR
         GJAHR
         BUZEI
         GSBER
         DMBTR
         KTOSL
         SGTXT
         MWSKZ
         WERKS
         KOART
         KUNNR
         HKONT
         LIFNR
         REBZG
         HSN_SAC
         H_BUDAT
         H_BLART
         BSCHL
         H_WAERS
         PSWBT
         WRBTR
         ZUONR
                 FROM BSEG INTO TABLE IT_BSEG
         WHERE BUKRS IN S_BUKRS
           AND GJAHR IN S_GJAHR
           AND BELNR = P_BELNR
           AND H_BLART = 'KG'.
*        AND koart in ( 'D', 'K' ).
*    AND KOART = 'K'.
    SORT IT_BSEG BY BUZEI.
    IF SY-SUBRC <> 0.
      MESSAGE 'Invalid Document' TYPE 'E'.
    ENDIF.

  ELSEIF P_RAD2 = 'X'.

*   SORT it_bseg BY buzei.
    SELECT
         BUKRS
         BELNR
         GJAHR
         BUZEI
         GSBER
         DMBTR
         KTOSL
         SGTXT
         MWSKZ
         WERKS
         KOART
         KUNNR
         HKONT
         LIFNR
         REBZG
         HSN_SAC
         H_BUDAT
         H_BLART
         BSCHL
         H_WAERS
         PSWBT
         WRBTR
         ZUONR
               FROM BSEG INTO TABLE IT_BSEG
         WHERE BUKRS IN S_BUKRS
           AND GJAHR IN S_GJAHR
           AND BELNR = P_BELNR
           AND H_BLART = 'DG'.
    SORT IT_BSEG BY BUZEI.
    IF SY-SUBRC <> 0.
      MESSAGE 'Invalid Document' TYPE 'E'.
    ENDIF.

  ENDIF.

  DATA(IT_bsegg) = IT_bseg[] .
  READ TABLE IT_BSEG INTO WA_BSEG INDEX 1.
  WA_HDR-BELNR = WA_BSEG-BELNR.
  WA_HDR-BUKRS = WA_BSEG-BUKRS.
  WA_HDR-FKDAT = WA_BSEG-H_BUDAT.
  WA_HDR-WAERS = WA_BSEG-H_WAERS.
  WA_HDR-SGTXT = WA_BSEG-SGTXT.

*   READ TABLE it_bsegg ASSIGNING FIELD-SYMBOL(<ls_bsegg>) WITH


  SELECT SINGLE XBLNR BKTXT BUDAT FROM BKPF INTO (WA_HDR-REBZG , WA_HDR-BKTXT , WA_HDR-BUDAT ) WHERE BUKRS = WA_BSEG-BUKRS
                                                    AND BELNR = WA_BSEG-BELNR
                                                    AND GJAHR = WA_BSEG-GJAHR.

*  wa_hdr-rebzg = wa_bseg-rebzg.

  IF WA_BSEG IS NOT INITIAL.
    SELECT SINGLE
                 WERKS
                 SPART
                 GSBER
      FROM T134G INTO WA_T134G
      WHERE GSBER = WA_BSEG-GSBER.
  ENDIF.
 if it_bseg is NOT INITIAL.
   SELECT SPRAS
          KTOPL
          SAKNR
          TXT20
          TXT50
     FROM SKAT INTO TABLE it_SKAT
      FOR ALL ENTRIES IN it_bseg
     WHERE SAKNR = it_bseg-HKONT AND KTOPL = IT_BSEG-BUKRS.

   ENDIF.

  IF IT_BSEG IS NOT INITIAL.
    SELECT
             LIFNR
             ADRNR
             STCD3
      FROM LFA1 INTO TABLE IT_LFA1
      FOR ALL ENTRIES IN IT_BSEG
      WHERE LIFNR = IT_BSEG-LIFNR.

    SELECT
             KUNNR
             ADRNR
             STCD3
      FROM KNA1 INTO TABLE IT_KNA1
      FOR ALL ENTRIES IN IT_BSEG
      WHERE KUNNR = IT_BSEG-KUNNR.

  ENDIF.

  READ TABLE IT_KNA1 INTO WA_KNA1 INDEX 1.
  READ TABLE IT_LFA1 INTO WA_LFA1 INDEX 1.

  IF IT_BSEG IS NOT INITIAL.
    SELECT
           VBELN
           FKART
           WAERK
           FKDAT
           BUKRS
           KUNAG
           KNUMV
           VTWEG
           FROM VBRK INTO TABLE IT_VBRK
           FOR ALL ENTRIES IN IT_BSEG
           WHERE BUKRS = IT_BSEG-BUKRS.
  ENDIF.

  READ TABLE IT_VBRK INTO WA_VBRK INDEX 1.

  IF WA_VBRK IS NOT INITIAL.
    SELECT  VBELN
            POSNR
            MEINS
            FKLMG
            NETWR
            AUBEL
            MATNR
            CHARG
            WERKS
          FROM VBRP INTO TABLE  IT_VBRP
           WHERE VBELN = WA_VBRK-VBELN.
  ENDIF.
  READ TABLE IT_VBRP INTO WA_VBRP INDEX 1.

  IF WA_BSEG IS NOT INITIAL.
    SELECT SINGLE
        BUKRS
        ADRNR
       FROM T001 INTO WA_T001
       WHERE BUKRS = WA_BSEG-BUKRS.
  ENDIF.



  IF WA_T134G IS NOT INITIAL.

    SELECT SINGLE WERKS
                   KUNNR
                   ADRNR
                   J_1BBRANCH
                   LAND1
                   REGIO
                   FROM T001W INTO  WA_T001W
*                  FOR ALL ENTRIES IN IT_VBRP
                   WHERE WERKS = WA_T134G-WERKS.
*                and kunnr = wa_vbrk-kunnr.
  ENDIF.

  IF WA_T001W IS NOT INITIAL.
    SELECT SINGLE
         ADDRNUMBER
         NAME1
         STREET
         STR_SUPPL1
         STR_SUPPL2
         STR_SUPPL3
         CITY1
         POST_CODE1
         TEL_NUMBER
         FAX_NUMBER
         COUNTRY
         HOUSE_NUM1
         FLOOR
         BUILDING
         LOCATION
         CITY2
         TIME_ZONE
      FROM ADRC INTO WA_ADRC
      WHERE ADDRNUMBER = WA_T001W-ADRNR.

    SELECT SINGLE
     SPRAS
     LAND1
     LANDX  FROM T005T INTO WA_T005T
     WHERE SPRAS = SY-LANGU AND LAND1 = WA_T001W-LAND1.

    SELECT SINGLE
               LAND1
               BLAND
               BEZEI FROM T005U
                 INTO WA_T005U WHERE SPRAS = SY-LANGU AND LAND1 = WA_T001W-LAND1
                 AND BLAND = WA_T001W-REGIO .
  ENDIF.

  WA_HDR-P_NAME1       = WA_ADRC-NAME1 .
  WA_HDR-P_CITY1       = WA_ADRC-CITY1 .
  WA_HDR-P_CITY2       = WA_ADRC-CITY2 .
  WA_HDR-P_POST_CODE1  = WA_ADRC-POST_CODE1.
*  WA_HDR-P_POST_CODE2  = WA_ADRC-POST_CODE2.
  WA_HDR-P_STREET      = WA_ADRC-STREET.
  WA_HDR-P_STR_SUPPL1  = WA_ADRC-STR_SUPPL1.
  WA_HDR-P_STR_SUPPL2  = WA_ADRC-STR_SUPPL2.
  WA_HDR-P_STR_SUPPL3  = WA_ADRC-STR_SUPPL3.
  WA_HDR-LANDX         = WA_T005T-LANDX.
  WA_HDR-BLAND         = WA_T005U-BLAND.
  WA_HDR-BEZEI         = WA_T005U-BEZEI.

  WA_HDR-P_TEL_NUMBER = WA_ADRC-TEL_NUMBER.
  WA_HDR-P_FAX_NUMBER = WA_ADRC-FAX_NUMBER.
  WA_HDR-P_FLOOR      = WA_ADRC-FLOOR.
  WA_HDR-P_BUILDING   = WA_ADRC-BUILDING.
  WA_HDR-P_LOCATION   = WA_ADRC-LOCATION.
  WA_HDR-P_CITY2      = WA_ADRC-CITY2.
  WA_HDR-P_TIME_ZONE  = WA_ADRC-TIME_ZONE.

  IF WA_T001W IS NOT INITIAL.
    SELECT SINGLE BUKRS
      BRANCH
      ADRNR
      GSTIN
      FROM J_1BBRANCH INTO WA_J_1BBRANCH
      WHERE BUKRS = WA_VBRK-BUKRS
      AND BRANCH  = WA_T001W-J_1BBRANCH.
  ENDIF.
  WA_HDR-C_GSTIN = WA_J_1BBRANCH-GSTIN.

  WA_HDR-VBELN = WA_VBRK-VBELN .


  SELECT SINGLE
    VBELN
    POSNR
    BSTKD
    BSTDK
         FROM VBKD INTO WA_VBKD
         WHERE VBELN = WA_VBRP-AUBEL.

  WA_HDR-PO_NO   =  WA_VBKD-BSTKD              .
  WA_HDR-PO_DATE =  WA_VBKD-BSTDK              .

  MOVE WA_KNA1-ADRNR TO WA_HDR-C_ADRNR.
  MOVE WA_KNA1-STCD3 TO WA_HDR-STCD3.
  MOVE WA_KNA1-KUNNR TO WA_HDR-KUNNR.
  MOVE WA_LFA1-LIFNR TO WA_HDR-LIFNR.

  SELECT SINGLE
ADDRNUMBER
NAME1
STREET
STR_SUPPL1
STR_SUPPL2
STR_SUPPL3
CITY1
POST_CODE1
TEL_NUMBER
FAX_NUMBER
COUNTRY
HOUSE_NUM1
FLOOR
BUILDING
LOCATION
CITY2
TIME_ZONE
  FROM ADRC INTO WA_ADRC_C
  WHERE ADDRNUMBER = WA_KNA1-ADRNR.
**********************************************************************************************
  SELECT SINGLE
  SPRAS
  LAND1
  LANDX  FROM T005T INTO WA_T005T1
  WHERE SPRAS = SY-LANGU AND LAND1 = WA_KNA1-LAND1.

  SELECT SINGLE
             LAND1
             BLAND
             BEZEI FROM T005U
               INTO WA_T005U1 WHERE SPRAS = SY-LANGU AND LAND1 = WA_KNA1-LAND1
               AND BLAND = WA_KNA1-REGIO .
**********************************************************************************************

  WA_HDR-C_LANDX  = WA_T005T1-LAND1.
  WA_HDR-C_BLAND  = WA_T005U1-BLAND.
  WA_HDR-C_BEZEI  = WA_T005U1-BEZEI.
  WA_HDR-C_HOUSE_NUM1 = WA_ADRC_C-HOUSE_NUM1.
  MOVE WA_ADRC_C-NAME1 TO WA_HDR-C_NAME1.
  MOVE WA_ADRC_C-CITY1 TO WA_HDR-C_CITY1.
  MOVE WA_ADRC_C-CITY2 TO WA_HDR-C_CITY2.
  MOVE WA_ADRC_C-POST_CODE1 TO WA_HDR-C_POST_CODE1.
*  MOVE WA_ADRC_C-POST_CODE2 TO WA_HDR-C_POST_CODE2.
  MOVE WA_ADRC_C-STREET TO WA_HDR-C_STREET.
  MOVE WA_ADRC_C-STR_SUPPL1 TO WA_HDR-C_STR_SUPPL1.
  MOVE WA_ADRC_C-STR_SUPPL2 TO WA_HDR-C_STR_SUPPL2.
  MOVE WA_ADRC_C-STR_SUPPL3 TO WA_HDR-C_STR_SUPPL3.
  MOVE WA_KNA1-STCD3 TO WA_HDR-C_STCD3.
  WA_HDR-C_TEL_NUMBER = WA_ADRC_C-TEL_NUMBER.
  WA_HDR-C_FAX_NUMBER = WA_ADRC_C-FAX_NUMBER.
  WA_HDR-C_FLOOR      = WA_ADRC_C-FLOOR.
  WA_HDR-C_BUILDING   = WA_ADRC_C-BUILDING.
  WA_HDR-C_LOCATION   = WA_ADRC_C-LOCATION.
  WA_HDR-C_CITY2      = WA_ADRC_C-CITY2.
  WA_HDR-C_TIME_ZONE  = WA_ADRC_C-TIME_ZONE.

  " for consignee address

  SELECT SINGLE  VBELN POSNR PARVW ADRNR
    FROM  VBPA INTO WA_VBPA
    WHERE VBELN = WA_VBRK-VBELN
    AND PARVW = 'WE'.
  MOVE WA_VBPA-ADRNR TO WA_HDR-CON_ADRNR .

  SELECT SINGLE
    ADDRNUMBER
    NAME1
    STREET
    STR_SUPPL1
    STR_SUPPL2
    STR_SUPPL3
    CITY1
    POST_CODE1
    TEL_NUMBER
    FAX_NUMBER
    COUNTRY
    HOUSE_NUM1
    FLOOR
    BUILDING
    LOCATION
    CITY2
    TIME_ZONE
      FROM ADRC INTO WA_ADRC_D
  WHERE ADDRNUMBER = WA_LFA1-ADRNR.

**********************************************************************************************
  SELECT SINGLE
  SPRAS
  LAND1
  LANDX  FROM T005T INTO WA_T005T2
  WHERE SPRAS = SY-LANGU AND LAND1 = WA_LFA1-LAND1.

  SELECT SINGLE
             LAND1
             BLAND
             BEZEI FROM T005U
               INTO WA_T005U2 WHERE SPRAS = SY-LANGU AND LAND1 = WA_LFA1-LAND1
               AND BLAND = WA_LFA1-REGIO .


  WA_HDR-V_LANDX  = WA_T005T2-LAND1.
  WA_HDR-V_BLAND  = WA_T005U2-BLAND.
  WA_HDR-V_BEZEI  = WA_T005U2-BEZEI.
  WA_HDR-V_HOUSE_NUM1 = WA_ADRC_D-HOUSE_NUM1.
**********************************************************************************************************

  MOVE WA_ADRC_D-NAME1 TO WA_HDR-S_NAME1.
  MOVE WA_ADRC_D-CITY1 TO WA_HDR-S_CITY1.
  MOVE WA_ADRC_D-CITY2 TO WA_HDR-S_CITY2.
  MOVE WA_ADRC_D-POST_CODE1 TO WA_HDR-S_POST_CODE1.
*  MOVE WA_ADRC_D-POST_CODE2 TO WA_HDR-S_POST_CODE2.
  MOVE WA_ADRC_D-STREET TO WA_HDR-S_STREET.
  MOVE WA_ADRC_D-STR_SUPPL1 TO WA_HDR-S_STR_SUPPL1.
  MOVE WA_ADRC_D-STR_SUPPL2 TO WA_HDR-S_STR_SUPPL2.
  MOVE WA_ADRC_D-STR_SUPPL3 TO WA_HDR-S_STR_SUPPL3.
  MOVE WA_LFA1-STCD3 TO WA_HDR-S_STCD3.
  WA_HDR-S_TEL_NUMBER = WA_ADRC_D-TEL_NUMBER.
  WA_HDR-S_FAX_NUMBER = WA_ADRC_D-FAX_NUMBER.
  WA_HDR-S_FLOOR      = WA_ADRC_D-FLOOR.
  WA_HDR-S_BUILDING   = WA_ADRC_D-BUILDING.
  WA_HDR-S_LOCATION   = WA_ADRC_D-LOCATION.
  WA_HDR-S_CITY2      = WA_ADRC_D-CITY2.
  WA_HDR-S_TIME_ZONE  = WA_ADRC_D-TIME_ZONE.




*********************
  " for fetching item details

  IF IT_VBRP IS NOT INITIAL.
    SELECT
        MATNR
        MEINS
        FROM MARA INTO TABLE IT_MARA
        FOR ALL ENTRIES IN IT_VBRP
        WHERE MATNR = IT_VBRP-MATNR.
  ENDIF.

*READ TABLE it_mara INTO wa_mara ,INDEX 1.
  IF IT_VBRP IS NOT INITIAL.
    SELECT MATNR
        WERKS
        STEUC
        FROM MARC INTO TABLE IT_MARC
        FOR ALL ENTRIES IN IT_VBRP
        WHERE WERKS = IT_VBRP-WERKS
      AND MATNR = IT_VBRP-MATNR.
*  matnr = it_vbrp-matnr AND
  ENDIF.
  SELECT
    MATNR
    SPRAS
    MAKTX
    FROM MAKT INTO TABLE IT_MAKT
    FOR ALL ENTRIES IN IT_MARA
    WHERE MATNR = IT_MARA-MATNR AND SPRAS = SY-LANGU.

  " challa no and challan date

  IF IT_BSEG IS NOT INITIAL.
    SELECT
    KAPPL
    KSCHL
    ALAND
    MWSKZ
    KNUMH
    FROM A003 INTO TABLE IT_A003
    FOR ALL ENTRIES IN IT_BSEG
    WHERE MWSKZ = IT_BSEG-MWSKZ.
  ENDIF.

  IF IT_A003 IS NOT INITIAL.
    SELECT
      KNUMH
      KOPOS
      KBETR
      KSCHL
      FROM KONP INTO TABLE IT_KONP
      FOR ALL ENTRIES IN IT_A003
      WHERE KNUMH = IT_A003-KNUMH.
  ENDIF.

  SELECT
        BUKRS
        BELNR
        GJAHR
        BUZEI
        GSBER
        DMBTR
        KTOSL
        SGTXT
        MWSKZ
        WERKS
        KOART
        KUNNR
        HKONT
        LIFNR
        REBZG
        HSN_SAC
        H_BUDAT
        H_BLART
        BSCHL
        H_WAERS
        PSWBT
        WRBTR
        ZUONR
            FROM BSEG INTO TABLE IT_BSEG1
    FOR ALL ENTRIES IN IT_BSEG
    WHERE BUKRS = IT_BSEG-BUKRS
    AND BELNR = IT_BSEG-BELNR
    AND KTOSL IN ( 'JII' , 'JIC', 'JIS' ).

*  IF wa_bseg IS NOT INITIAL.
*    SELECT SINGLE
*      bukrs
*      werks
*      j_1iexcd
*      j_1ipanno
*      FROM j_1imocomp INTO wa_j_1imocomp
*          WHERE bukrs = wa_bseg-bukrs.
*  ENDIF.
*
*  wa_hdr-p_cin = wa_j_1imocomp-j_1iexcd.
*  wa_hdr-p_pan = wa_j_1imocomp-j_1ipanno.

  IF IT_BSEG IS NOT INITIAL.
    SELECT
         BUKRS
         PARTY
         PAVAL FROM T001Z INTO TABLE IT_T001Z
               FOR ALL ENTRIES IN IT_BSEG
               WHERE BUKRS = IT_BSEG-BUKRS.
  ENDIF.
  READ TABLE IT_T001Z INTO WA_T001Z WITH KEY PARTY = 'CIN'.
  IF SY-SUBRC = 0.
    WA_HDR-P_CIN = WA_T001Z-PAVAL.
  ENDIF.
  READ TABLE IT_T001Z INTO WA_T001Z WITH KEY PARTY = 'J_1I02'.
  IF SY-SUBRC = 0.
    WA_HDR-P_PAN = WA_T001Z-PAVAL.
  ENDIF.




  IF WA_VBRP IS NOT INITIAL.
    SELECT SINGLE
      VBELN
    LFDAT
*    ZZLR_NO
*    ZZLR_DATE
*    ZZLORRY_NO
*    ZTR_NAME
      VSTEL
    FROM LIKP INTO  WA_LIKP
*    FOR ALL ENTRIES IN it_vbrk
    WHERE VSTEL = WA_VBRP-WERKS.

  ENDIF.

*READ TABLE it_likp INTO wa_likp with key vbeln = wa_vbrk-vbeln.
  MOVE WA_LIKP-VBELN TO WA_HDR-CHALAN_NO .
  MOVE WA_LIKP-LFDAT TO WA_HDR-CHALLAN_DATE.
*  MOVE WA_LIKP-ZZLR_NO TO WA_HDR-ZZLR_NO.
*  MOVE WA_LIKP-ZZLR_DATE TO WA_HDR-ZZLR_DATE.
*  MOVE WA_LIKP-ZZLORRY_NO TO WA_HDR-ZZLORRY_NO.
*  MOVE WA_LIKP-ZTR_NAME TO WA_HDR-ZTR_NAME.
*APPEND wa_hdr to it_hdr.


  " for bank name and bank account no
  SELECT SINGLE
                VBELN
                FKART
                WAERK
                FKDAT
                BUKRS
                KUNAG
                KNUMV
                VTWEG
                FROM VBRK INTO  WA_VBRK
                WHERE BUKRS = WA_BSEG-BUKRS.

  IF WA_VBRK IS NOT INITIAL.
    SELECT SINGLE
    BUKRS
    HBKID
    BANKS
    BANKL
    TELF1
    STCD1
    NAME1
    SPRAS
    FROM T012 INTO  WA_T012
    WHERE BUKRS = WA_VBRK-BUKRS
    AND HBKID IN ('1000' ,'2000').
  ENDIF.
  SELECT SINGLE BANKS BANKL BANKA BRNCH
     FROM BNKA INTO WA_BNKA
    WHERE BANKS = WA_T012-BANKS
    AND BANKL = WA_T012-BANKL.

  MOVE WA_BNKA-BANKA TO WA_HDR-BANK_NAME.
  MOVE WA_BNKA-BRNCH TO WA_HDR-BRANCH.
*APPEND wa_hdr to it_hdr.
******************************
  BREAK PPADHY.
  LOOP AT IT_BSEG INTO WA_BSEG WHERE GSBER NE ' ' AND  BUZEI NE '01'.

    LV_S = LV_S + 1.
    WA_ITEM-SL  = LV_S.

    MOVE WA_BSEG-DMBTR TO WA_ITEM-DMBTR.
    MOVE WA_BSEG-WRBTR TO WA_ITEM-WRBTR.
    MOVE WA_BSEG-ZUONR TO WA_ITEM-ZUONR.
    MOVE WA_BSEG-ZUONR TO WA_HDR-ZUONR.
*      MOVE wa_bseg-ktosl TO wa_item-ktosl.
    MOVE WA_BSEG-SGTXT TO WA_ITEM-SGTXT.
*    MOVE WA_BSEG-HSN_SAC TO WA_ITEM-STEUC.
    WA_ITEM-PSWBT = WA_BSEG-PSWBT.
    CLEAR WA_VBRK.

     READ TABLE it_SKAT INTO wa_SKAT with key SAKNR = wa_bseg-HKONT.
     move wa_skat-TXT50 TO wa_item-HKONT.



    READ TABLE IT_VBRK INTO WA_VBRK
    WITH KEY BUKRS = WA_BSEG-BUKRS.

    READ TABLE IT_VBRP INTO WA_VBRP
    WITH KEY VBELN = WA_VBRK-VBELN.

    IF SY-SUBRC = 0.
      MOVE WA_VBRP-CHARG TO WA_ITEM-CHARG.      "lot no
      MOVE WA_VBRP-FKLMG TO WA_ITEM-FKLMG.       " quantity
      MOVE WA_VBRP-MEINS TO WA_ITEM-MEINS.       " unit
      MOVE WA_VBRP-NETWR TO WA_ITEM-NETWR.        "net amount
    ENDIF.

    READ TABLE IT_MARC INTO WA_MARC
     WITH KEY MATNR = WA_VBRP-MATNR
              WERKS = WA_VBRP-WERKS.

    IF SY-SUBRC = 0.
      MOVE WA_MARC-STEUC TO WA_ITEM-STEUC.
    ENDIF.

    READ TABLE IT_MAKT INTO WA_MAKT INDEX 1.

    IF SY-SUBRC = 0.
      MOVE WA_MAKT-MAKTX TO WA_ITEM-MAKTX.
    ENDIF.


    MOVE WA_MAKT-MAKTX TO WA_ITEM-MAKTX.

    WA_ITEM-LV_RATE = WA_VBRP-NETWR / WA_VBRP-FKLMG .

*    WA_HDR-TOT = WA_HDR-TOT + WA_ITEM-DMBTR.
    WA_HDR-TOT = WA_HDR-TOT + WA_ITEM-WRBTR.



    BREAK PPADHY.
*    READ TABLE IT_A003 INTO WA_A003 WITH KEY MWSKZ = WA_BSEG-MWSKZ." kschl = 'JICG' .
    LOOP AT IT_A003 INTO WA_A003 WHERE MWSKZ = WA_BSEG-MWSKZ.
      READ TABLE IT_KONP INTO WA_KONP WITH KEY KNUMH = WA_A003-KNUMH KSCHL = WA_A003-KSCHL.

      CASE WA_A003-KSCHL.
        WHEN 'JOIG' OR 'JIIG'.

          WA_ITEM-I_PER_I = WA_KONP-KBETR / 10.
*          WA_ITEM-IGST = WA_BSEG-DMBTR.
*            WA_HDR-I_PER_I = WA_HDR-I_PER_I + WA_HDR-I_PER_I ."/ 100.


        WHEN 'JOCG' OR 'JICG'.

          WA_ITEM-I_PER_C = WA_KONP-KBETR / 10.
*          WA_ITEM-CGST = WA_BSEG-DMBTR.
*            WA_HDR-I_PER_C = WA_HDR-I_PER_C + WA_HDR-I_PER_C." / 100.

        WHEN 'JOSG' OR 'JISG'.

          WA_ITEM-I_PER_S = WA_KONP-KBETR / 10.
*          WA_ITEM-SGST = WA_BSEG-DMBTR.
*            WA_HDR-I_PER_S = WA_HDR-I_PER_S + WA_HDR-I_PER_S." / 100.


      ENDCASE.

*      WA_HDR-IGST = WA_HDR-IGST + WA_ITEM-I_PER_I.
*      WA_HDR-CGST = WA_HDR-CGST + WA_ITEM-I_PER_C.
*      WA_HDR-SGST = WA_HDR-SGST + WA_ITEM-I_PER_S.


    ENDLOOP.

    APPEND WA_ITEM TO IT_ITEM.
    CLEAR WA_ITEM.

  ENDLOOP.

  BREAK PPADHY.
  LOOP AT IT_BSEG INTO WA_BSEG.

    IF WA_BSEG-KTOSL = 'JOI' OR WA_BSEG-KTOSL = 'JII'.
      WA_HDR-IGST = WA_HDR-IGST + WA_BSEG-WRBTR.

    ELSEIF WA_BSEG-KTOSL = 'JOC' OR WA_BSEG-KTOSL = 'JIC'.
      WA_HDR-CGST = WA_HDR-CGST + WA_BSEG-WRBTR.

    ELSEIF WA_BSEG-KTOSL = 'JOS' OR WA_BSEG-KTOSL = 'JIS'.
      WA_HDR-SGST = WA_HDR-SGST + WA_BSEG-WRBTR.


    ENDIF.

  ENDLOOP.
*    APPEND WA_ITEM TO IT_ITEM.
*    CLEAR WA_ITEM.
*
*  ENDLOOP.
  BREAK PPADHY.
  WA_HDR-TOT1 = WA_HDR-TOT1 + WA_HDR-TOT + WA_HDR-IGST + WA_HDR-CGST + WA_HDR-SGST + WA_HDR-UGST.

  DATA:LV_TOT      LIKE PC207-BETRG,
       WA_AMT(130) TYPE C.
**********************to convert rate value into word********************
  LV_TOT = WA_HDR-TOT1.

  CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
    EXPORTING
      AMT_IN_NUM         = LV_TOT
    IMPORTING
      AMT_IN_WORDS       = WA_AMT
    EXCEPTIONS
      DATA_TYPE_MISMATCH = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
  DATA WA_AMT1(100) TYPE C.
  WA_AMT1 = WA_AMT.


  CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
    EXPORTING
      INPUT_STRING  = WA_AMT1
*     SEPARATORS    = ' -.,;:'
    IMPORTING
      OUTPUT_STRING = WA_AMT.



*    DATA : t_spell TYPE spell.
*    DATA : lv_tot TYPE string.
*    DATA: lv_amt1(300) TYPE c.
*    lv_tot = wa_ftr-total2.
*
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = lv_tot
*      IMPORTING
*        output = lv_tot.
*
*
*    CALL FUNCTION 'SPELL_AMOUNT'
*      EXPORTING
*        amount    = lv_tot
*        currency  = 'USD'
**       FILLER    = ' '
*        language  = sy-langu
*      IMPORTING
*        in_words  = t_spell
*      EXCEPTIONS
*        not_found = 1
*        too_large = 2
*        OTHERS    = 3.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
*    lv_amt1 = t_spell-word.
**  CONCATENATE LV_AMT1'AND't_spell-decword 'PAISE''Only' INTO LV_AMT1 SEPARATED BY ''.
**  CONCATENATE T_SPELL-WORD'AND't_spell-decword 'PAISE''Only' INTO LV_AMT1 SEPARATED BY ''.
*    CONCATENATE : t_spell-word 'AND' t_spell-decword 'PAISE'
*          INTO lv_amt1 SEPARATED BY ' '.
*
*    wa_ftr-lv_total = lv_amt1.


*****************************
*

*

  IF P_RAD1 = 'X'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = 'ZFI_DEBIT_NOTE_F07'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        FM_NAME            = FM_NAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION FM_NAME "'/1BCDWB/SF00000074'
      EXPORTING
*       ARCHIVE_INDEX    =
*       ARCHIVE_INDEX_TAB          =
*       ARCHIVE_PARAMETERS         =
*       CONTROL_PARAMETERS         =
*       MAIL_APPL_OBJ    =
*       MAIL_RECIPIENT   =
*       MAIL_SENDER      =
*       OUTPUT_OPTIONS   =
*       USER_SETTINGS    = 'X'
        WA_HDR           = WA_HDR
        WA_PRCD_ELEMENTS = WA_FTR
        WA_AMT           = WA_AMT
*       lv_total         = LV_TOT
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO  =
*       JOB_OUTPUT_OPTIONS         =
      TABLES
        IT_ITEM          = IT_ITEM
* EXCEPTIONS
*       FORMATTING_ERROR = 1
*       INTERNAL_ERROR   = 2
*       SEND_ERROR       = 3
*       USER_CANCELED    = 4
*       OTHERS           = 5
      .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSEIF P_RAD2 = 'X'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = 'ZFI_CREDIT_NOTE_F07'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        FM_NAME            = FM_NAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION FM_NAME "'/1BCDWB/SF00000074'
      EXPORTING
*       ARCHIVE_INDEX    =
*       ARCHIVE_INDEX_TAB          =
*       ARCHIVE_PARAMETERS         =
*       CONTROL_PARAMETERS         =
*       MAIL_APPL_OBJ    =
*       MAIL_RECIPIENT   =
*       MAIL_SENDER      =
*       OUTPUT_OPTIONS   =
*       USER_SETTINGS    = 'X'
        WA_HDR           = WA_HDR
        WA_PRCD_ELEMENTS = WA_FTR
        WA_AMT           = WA_AMT
*       lv_total         = LV_TOT
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO  =
*       JOB_OUTPUT_OPTIONS         =
      TABLES
        IT_ITEM          = IT_ITEM
* EXCEPTIONS
*       FORMATTING_ERROR = 1
*       INTERNAL_ERROR   = 2
*       SEND_ERROR       = 3
*       USER_CANCELED    = 4
*       OTHERS           = 5
      .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.



*  ELSEIF P_RAD3 = 'X'.
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        FORMNAME           = 'ZFI_SALESINVOICE_F07'
**       VARIANT            = ' '
**       DIRECT_CALL        = ' '
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
*    CALL FUNCTION FM_NAME "'/1BCDWB/SF00000074'
*      EXPORTING
**       ARCHIVE_INDEX    =
**       ARCHIVE_INDEX_TAB          =
**       ARCHIVE_PARAMETERS         =
**       CONTROL_PARAMETERS         =
**       MAIL_APPL_OBJ    =
**       MAIL_RECIPIENT   =
**       MAIL_SENDER      =
**       OUTPUT_OPTIONS   =
**       USER_SETTINGS    = 'X'
*        WA_HDR           = WA_HDR
*        WA_PRCD_ELEMENTS = WA_FTR
*        WA_AMT           = WA_AMT
**       lv_total         = LV_TOT
** IMPORTING
**       DOCUMENT_OUTPUT_INFO       =
**       JOB_OUTPUT_INFO  =
**       JOB_OUTPUT_OPTIONS         =
*      TABLES
*        IT_ITEM          = IT_ITEM
** EXCEPTIONS
**       FORMATTING_ERROR = 1
**       INTERNAL_ERROR   = 2
**       SEND_ERROR       = 3
**       USER_CANCELED    = 4
**       OTHERS           = 5
*      .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*  ELSEIF P_RAD4 = 'X'.
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        FORMNAME           = 'ZFI_CUST_DEBITNOTE_02'
**       VARIANT            = ' '
**       DIRECT_CALL        = ' '
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
*    CALL FUNCTION FM_NAME "'/1BCDWB/SF00000074'
*      EXPORTING
**       ARCHIVE_INDEX    =
**       ARCHIVE_INDEX_TAB          =
**       ARCHIVE_PARAMETERS         =
**       CONTROL_PARAMETERS         =
**       MAIL_APPL_OBJ    =
**       MAIL_RECIPIENT   =
**       MAIL_SENDER      =
**       OUTPUT_OPTIONS   =
**       USER_SETTINGS    = 'X'
*        WA_HDR           = WA_HDR
*        WA_PRCD_ELEMENTS = WA_FTR
*        WA_AMT           = WA_AMT
**       lv_total         = LV_TOT
** IMPORTING
**       DOCUMENT_OUTPUT_INFO       =
**       JOB_OUTPUT_INFO  =
**       JOB_OUTPUT_OPTIONS         =
*      TABLES
*        IT_ITEM          = IT_ITEM
** EXCEPTIONS
**       FORMATTING_ERROR = 1
**       INTERNAL_ERROR   = 2
**       SEND_ERROR       = 3
**       USER_CANCELED    = 4
**       OTHERS           = 5
*      .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.





  ENDIF.
