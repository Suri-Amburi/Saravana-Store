*&---------------------------------------------------------------------*
*& Include          ZGSTR1_B2C_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:SLIS.

**************Types structure decleration

TYPES: BEGIN OF TY_VBRK,
         VBELN TYPE  VBELN_VF,
         ERDAT TYPE  ERDAT,
         KNUMV TYPE  KNUMV,
         FKART TYPE  FKART,
         FKSTO TYPE  FKSTO,
       END OF TY_VBRK.

TYPES: BEGIN OF TY_VBRP,
         VBELN TYPE VBELN_VF,     """""""""Invoice
         POSNR TYPE POSNR_VF,     """"""""""Item
         MATNR TYPE  MATNR,       """"""""""Material
         NETWR TYPE  NETWR_FP,     """""""""Sales Amount
         MWSBP TYPE  MWSBP,       """""""""""Tax Amount
         FKIMG TYPE  FKIMG,     """""""""Quantity
         MWSK1 TYPE  MWSKZ,
*         NRAB_KNUMH TYPE  KNUMH,
       END OF TY_VBRP.

TYPES: BEGIN OF TY_MARC,
         MATNR TYPE  MATNR,
         WERKS TYPE  WERKS_D,
         STEUC TYPE STEUC,
       END OF TY_MARC.

TYPES: BEGIN OF TY_A519,
         KAPPL TYPE	KAPPL,
         KSCHL TYPE  KSCHA,
         ALAND TYPE  ALAND,
         WKREG TYPE  WKREG,
         REGIO TYPE REGIO,
         STEUC TYPE  STEUC,
         WAERK TYPE  WAERK,
         KFRST TYPE  KFRST,
         DATBI TYPE  KODATBI,
         DATAB TYPE	KODATAB,
         KNUMH TYPE	KNUMH,
       END OF TY_A519.

TYPES: BEGIN OF TY_KONP,
         KNUMH    TYPE  KNUMH,
         KOPOS    TYPE  KOPOS,
         KSCHL    TYPE KONP-KSCHL,
         KBETR    TYPE  KBETR_KOND,
         PKWRT    TYPE PKWRT,
         MWSK1    TYPE  MWSKZ,
         LOEVM_KO TYPE  KONP-LOEVM_KO,
       END OF TY_KONP.

TYPES: BEGIN OF TY_T007S,
         SPRAS TYPE  SPRAS,
         KALSM TYPE  KALSM_D,
         MWSKZ TYPE  MWSKZ,
         TEXT1 TYPE  TEXT1_007S,
       END OF TY_T007S.

""""""""""""""""""""""""""Final Table Decleration

TYPES: BEGIN OF TY_FINALT,
         VBELN    TYPE  VBELN_VF,
         ERDAT    TYPE  ERDAT,
         KNUMV    TYPE  KNUMV,
         FKART    TYPE  FKART,
         FKSTO    TYPE  FKSTO,
         POSNR    TYPE POSNR_VF,
         MATNR    TYPE  MATNR,
         NETWR    TYPE  NETWR_FP,
         MWSBP    TYPE  MWSBP,
         FKIMG    TYPE  FKIMG,
         WERKS    TYPE  WERKS_D,
         STEUC    TYPE STEUC,
         KNUMH    TYPE  KNUMH,
         KSCHL    TYPE  KONP-KSCHL,
         KBETR    TYPE  KBETR_KOND,
         LOEVM_KO TYPE  KONP-LOEVM_KO,
         MWSK1    TYPE  MWSKZ,
         IGST%    TYPE KBETR_KOND,
         CGST%    TYPE KBETR_KOND,
         SGST%    TYPE KBETR_KOND,
         IGST     TYPE PKWRT,
         CGST     TYPE PKWRT,
         SGST     TYPE PKWRT,
         SPRAS    TYPE  SPRAS,
         KALSM    TYPE  KALSM_D,
         MWSKZ    TYPE  MWSKZ,
         TEXT1    TYPE  TEXT1_007S,
         CESS     TYPE INT4,
       END OF TY_FINALT.

*********** internal table and work area decleration

DATA: IT_VBRK    TYPE TABLE OF TY_VBRK,
      WA_VBRK    TYPE TY_VBRK,
      IT_VBRP    TYPE TABLE OF TY_VBRP,
      WA_VBRP    TYPE TY_VBRP,
      IT_MARC    TYPE TABLE OF TY_MARC,
      WA_MARC    TYPE TY_MARC,
      IT_A519    TYPE TABLE OF TY_A519,
      WA_A519    TYPE TY_A519,
      IT_KONP    TYPE TABLE OF TY_KONP,
      WA_KONP    TYPE TY_KONP,
      IT_T007S   TYPE TABLE OF TY_T007S,
      WA_T007S   TYPE TY_T007S,
      IT_FINALT  TYPE TABLE OF TY_FINALT,
      WA_FINALT  TYPE TY_FINALT,
      IT_FINALT1 TYPE TABLE OF TY_FINALT,
      WA_FINALT1 TYPE TY_FINALT,
      IT_FINAL2  TYPE TABLE OF TY_FINALT,
      WA_FINAL2  TYPE TY_FINALT,
      IT_FINAL3  TYPE TABLE OF TY_FINALT,
      WA_FINAL3  TYPE TY_FINALT.
DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
       WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
       WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.

DATA: FIRST_DAY TYPE SY-DATUM.
DATA: LAST_DAY TYPE SY-DATUM.
*DATA: DATE TYPE SY-DATUM.
