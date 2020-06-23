*&---------------------------------------------------------------------*
*& Include          ZFI_CASH_PAYMENT_F50_TOP
*&---------------------------------------------------------------------*

DATA:GV_BELNR TYPE TCJ_DOCUMENTS-POSTING_NUMBER.

TYPES : BEGIN OF TY_BKPF,
          BUKRS TYPE  BUKRS,
          BELNR TYPE  BELNR_D,
          GJAHR TYPE  GJAHR,
          BUDAT TYPE BUDAT,
          BKTXT TYPE BKTXT,
          WAERS TYPE WAERS,
          AWKEY TYPE AWKEY,
          XBLNR	TYPE XBLNR1,
        END OF TY_BKPF,

        BEGIN  OF TY_BSEG,
          BUKRS	TYPE BUKRS,
          BELNR	TYPE BELNR_D,
          GJAHR	TYPE GJAHR,
          BUZEI TYPE BUZEI,
          SHKZG TYPE  SHKZG,
          HKONT TYPE  HKONT,
          DMBTR TYPE  DMBTR,
          SGTXT TYPE  SGTXT,
          AWKEY TYPE AWKEY,
*          total TYPE dmbtr,
          WERKS	TYPE WERKS_D,
          GSBER	TYPE GSBER,
        END OF TY_BSEG,

        BEGIN OF TY_SKAT,
          SAKNR TYPE SAKNR,
          SPRAS	TYPE SPRAS,
          TXT20 TYPE TXT20_SKAT,
          TXT50 TYPE TXT50_SKAT,
        END OF TY_SKAT,

        BEGIN OF TY_TCJ_DOCUMENTS,
          COMP_CODE	     TYPE BUKRS,
          CAJO_NUMBER	   TYPE CJNR,
          FISC_YEAR	     TYPE GJAHR,
          POSTING_NUMBER TYPE CJBELNR,
          BP_NAME        TYPE CJBPNAME,
          POSTING_DATE   TYPE BUDAT,
          D_POSTING_NUMB TYPE CJBELNR_DISP,
        END OF TY_TCJ_DOCUMENTS,

        BEGIN OF TY_T001W,
          WERKS TYPE WERKS_D,
          ADRNR TYPE ADRNR,
        END OF TY_T001W,

        BEGIN OF TY_T001,
          BUKRS TYPE BUKRS,
          ADRNR TYPE ADRNR,
        END OF TY_T001,

        BEGIN OF TY_ADRC,
          ADDRNUMBER  TYPE ADRC-ADDRNUMBER,
          NAME1       TYPE ADRC-NAME2,
          STREET      TYPE ADRC-STREET,
          STR_SUPPL1  TYPE ADRC-STR_SUPPL1,
          STR_SUPPL2  TYPE ADRC-STR_SUPPL2,
          STR_SUPPL3  TYPE ADRC-STR_SUPPL3,
          CITY1       TYPE ADRC-CITY1,
          POST_CODE1  TYPE ADRC-POST_CODE1,
          TEL_NUMBER  TYPE ADRC-TEL_NUMBER,
          FAX_NUMBER  TYPE ADRC-FAX_NUMBER,
          COUNTRY     TYPE ADRC-COUNTRY,
          HOUSE_NUM1  TYPE AD_HSNM1,                                "House Number
          FLOOR       TYPE AD_FLOOR,
          BUILDING    TYPE AD_BLDNG,
          LOCATION    TYPE AD_LCTN,
          CITY2       TYPE AD_CITY2,
          TIME_ZONE   TYPE AD_TZONE,
          REGION      TYPE REGIO,                                    "Region (State, Province, County)
                  END OF TY_ADRC,

        BEGIN OF TY_T134G,
          WERKS	TYPE WERKS_D,
          GSBER	TYPE GSBER,
        END OF TY_T134G,

        BEGIN OF TY_T005U,
          SPRAS	TYPE SPRAS,
          LAND1	TYPE LAND1,
          BLAND	TYPE REGIO,
          BEZEI	TYPE BEZEI20,
        END OF TY_T005U,

        BEGIN OF TY_ADR6,
          ADDRNUMBER TYPE AD_ADDRNUM,
          SMTP_ADDR	 TYPE AD_SMTPADR,      " Email
        END OF TY_ADR6.



TYPES : BEGIN OF TY_J_1IMOCOMP,
          BUKRS     TYPE   BUKRS,
          WERKS	    TYPE WERKS_D,
          J_1IEXCD  TYPE J_1IMOCOMP-J_1IEXCD,
          J_1IPANNO TYPE J_1IMOCOMP-J_1IPANNO,
        END OF TY_J_1IMOCOMP .

****internal table and work area declartions*********
DATA:GT_BKPF          TYPE TABLE OF TY_BKPF,
     GT_BSEG          TYPE TABLE OF TY_BSEG,
     GT_ITEM          TYPE TABLE OF ZFI_ITEM_CASH,    " zcditm,
     WA_ITEM          TYPE  ZFI_ITEM_CASH,    "zcditm,
     WA_HEADER        TYPE  ZFI_HEADER_CASH,   "zcdheader,
     WA_BKPF          TYPE  TY_BKPF,
     WA_BSEG          TYPE  TY_BSEG,
     WA_SKAT          TYPE  TY_SKAT,
     GT_SKAT          TYPE TABLE OF TY_SKAT,
     GT_TCJ_DOCUMENTS TYPE TABLE OF TY_TCJ_DOCUMENTS,
     GV_CUR           TYPE WAERS,
     WA_TCJ_DOCUMENTS TYPE TY_TCJ_DOCUMENTS,
     GT_T001W         TYPE TABLE OF TY_T001W,
     WA_T001W         TYPE TY_T001W,
     GT_ADRC          TYPE TABLE OF TY_ADRC,
     WA_ADRC          TYPE TY_ADRC,
     GT_T134G         TYPE TABLE OF TY_T134G,
     WA_T134G         TYPE TY_T134G,
     GT_T005U         TYPE  TABLE OF TY_T005U,
     WA_T005U         TYPE TY_T005U,
     IT_J_1IMOCOMP    TYPE TABLE OF TY_J_1IMOCOMP,
*     wa_j_1imocomp TYPE ty_j_1imocomp,
     WA_T001Z         TYPE T001Z,
     IT_T001Z         TYPE TABLE OF T001Z,
     WA_TCJ_CJ_NAMES  TYPE TCJ_CJ_NAMES,
     GT_T001          TYPE TABLE OF TY_T001,
     WA_T001          TYPE TY_T001,
     GT_ADR6          TYPE TABLE OF TY_ADR6,
     WA_ADR6          TYPE TY_ADR6.
DATA: LV_FM_NAME TYPE RS38L_FNAM,
      LV_XBLNR   TYPE XBLNR1.

DATA: V_STR  TYPE BSEG-AWKEY,
      V_STR1 TYPE STRING.
