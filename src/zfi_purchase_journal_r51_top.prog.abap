*&---------------------------------------------------------------------*
*& Include          ZFI_PURCHASE_JOURNAL_R51_TOP
*&---------------------------------------------------------------------*

*********header detls******
TYPES:BEGIN OF TY_BKPF,
        BUKRS	TYPE BUKRS, " plant
        BELNR	TYPE 	BELNR_D, "doc nor
        GJAHR	TYPE 	GJAHR, "physical year
        BUDAT TYPE 	BUDAT, "posting date
        BLART TYPE   BLART, "doc type
        XBLNR TYPE  XBLNR1,
        WAERS TYPE  WAERS,
      END OF TY_BKPF,
*******item detiles*******
      BEGIN  OF TY_BSEG,
        BUKRS	TYPE BUKRS,   " com code
        BELNR	TYPE BELNR_D, "doc nor
        GJAHR	TYPE GJAHR,   "physical year
        BUZEI TYPE BUZEI,      "LINE ITEM
        SHKZG	TYPE SHKZG,   "Debit/Credit Indicator
        LIFNR	TYPE LIFNR,   "vendor nor
        KUNNR	TYPE KUNNR,    "custmor nor
        SGTXT TYPE  SGTXT,   "item desc
        ANLN1 TYPE BSEG-ANLN1,
        HKONT TYPE HKONT,   "g/l desc
        WRBTR TYPE WRBTR,
        WERKS TYPE WERKS_D,
        GSBER	TYPE GSBER,                                     "Business Area
      END OF TY_BSEG,
********vendor adress*************g/l description*********
      BEGIN OF TY_SKAT,
        SPRAS TYPE  SPRAS, "languge
        SAKNR TYPE SAKNR,  "g/l nor
        KTOPL TYPE KTOPL,
        TXT50 TYPE TXT50_SKAT, "g/l  desc
      END OF TY_SKAT,

      BEGIN OF TY_LFA1,
        LIFNR	TYPE LIFNR,   "vendor nor
        NAME1	TYPE NAME1_GP, "name1
      END OF TY_LFA1.

TYPES : BEGIN OF TY_T134G,
          WERKS TYPE  WERKS_D,
          SPART TYPE  SPART,
          GSBER TYPE  GSBER,
        END OF TY_T134G.

TYPES: BEGIN OF TY_KNA1,
         KUNNR TYPE KUNNR,   "vendor nor
         NAME1 TYPE NAME1_GP, "name1
       END OF TY_KNA1,

       BEGIN OF TY_ANLA ,
         BUKRS TYPE BUKRS,
         ANLN1 TYPE ANLN1,
         ANLN2 TYPE ANLN2,
         TXT50 TYPE TXA50_ANLT,
       END OF TY_ANLA.
""""""changed on 2 nov by naveen""""""""""""""""
TYPES: BEGIN OF T_T001,
         BUKRS TYPE T001-BUKRS,
         ADRNR TYPE T001-ADRNR,
       END OF T_T001.


TYPES: BEGIN OF T_J_1IMOCOMP,
         BUKRS     TYPE J_1IMOCOMP-BUKRS, "Company Code
         WERKS     TYPE J_1IMOCOMP-WERKS, "Plant
         J_1IEXCD  TYPE J_1IMOCOMP-J_1IEXCD, "ECC No.
         J_1ICSTNO TYPE J_1IMOCOMP-J_1ICSTNO, "CST number
         J_1ILSTNO TYPE J_1IMOCOMP-J_1ILSTNO, "LST number tin
         J_1ISERN  TYPE J_1IMOCOMP-J_1ISERN, "Service Tax Regn.No
       END OF T_J_1IMOCOMP.

TYPES: BEGIN OF T_ADRC,
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
       END OF T_ADRC.

TYPES: BEGIN OF T_T001Z,
         BUKRS TYPE T001Z-BUKRS,
         PARTY TYPE T001Z-PARTY,
         PAVAL TYPE T001Z-PAVAL,
       END OF T_T001Z.

TYPES: BEGIN OF T_T005T,
         SPRAS TYPE T005T-SPRAS,
         LAND1 TYPE T005T-LAND1,
         LANDX TYPE T005T-LANDX,
       END OF T_T005T.

TYPES: BEGIN OF T_ADR6,
         ADDRNUMBER TYPE ADR6-ADDRNUMBER,
         SMTP_ADDR  TYPE ADR6-SMTP_ADDR,
       END OF T_ADR6.

TYPES: BEGIN OF TY_T001W,
         WERKS TYPE WERKS_D,                    "Plant
         ADRNR TYPE ADRNR,                      "Address
       END OF TY_T001W.

****internal table and work area declartions*********
DATA:GT_BKPF       TYPE TABLE OF TY_BKPF,
     GT_BSEG       TYPE TABLE OF TY_BSEG,
     GT_BSEG1       TYPE TABLE OF TY_BSEG,
     GT_LFA1       TYPE TABLE OF TY_LFA1,
     GT_KNA1       TYPE TABLE OF TY_KNA1,
     GT_SKAT       TYPE TABLE OF TY_SKAT,
     GT_T001       TYPE TABLE OF T_T001,
     GT_T001W      TYPE TABLE OF TY_T001W,
     GT_ADRC       TYPE TABLE OF T_ADRC,
     GT_T001Z      TYPE TABLE OF T_T001Z,
     GT1_T001Z     TYPE TABLE OF T_T001Z,
     GT_T005T      TYPE TABLE OF T_T005T,
     GT_T134G      TYPE TABLE OF TY_T134G,
     GT_ADR6       TYPE TABLE OF T_ADR6,
     GT_J_1IMOCOMP TYPE TABLE OF T_J_1IMOCOMP,
     GT_ITEM       TYPE TABLE OF ZFI_CREDIT_I,    " zcditm,
     GT_ANLA       TYPE TABLE OF TY_ANLA,
     WA_ITEM       TYPE  ZFI_CREDIT_I,    "zcditm,
     WA_HEADER     TYPE  ZFI_CREDIT_H,   "zcdheader,
     WA_BKPF       TYPE  TY_BKPF,
     WA_BSEG       TYPE  TY_BSEG,
     WA_BSEG1      TYPE TY_BSEG,
     WA_LFA1       TYPE  TY_LFA1,
     WA_KNA1       TYPE  TY_KNA1,
     WA_SKAT       TYPE  TY_SKAT,
     WA_ANLA       TYPE TY_ANLA,
     WA_T001       TYPE  T_T001,
     WA_T134G      TYPE  TY_T134G,
     WA_T001W      TYPE  TY_T001W,
     WA_ADRC       TYPE  T_ADRC,
     WA_T001Z      TYPE  T_T001Z,
     WA_J_1IMOCOMP TYPE T_J_1IMOCOMP,
     WA1_T001Z     TYPE  T_T001Z,
     WA_T005T      TYPE  T_T005T,
     WA_ADR6       TYPE  T_ADR6.

DATA:LV_FM_NAME TYPE RS38L_FNAM.
