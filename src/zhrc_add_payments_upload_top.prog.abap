*&---------------------------------------------------------------------*
*& Include          ZHRC_ADD_PAYMENTS_UPLOAD_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF TY_FINAL,
         PERNR     TYPE PERNR,   "Personnel Number
*           TIMR6 type RP50G-TIMR6,   "Time period indicator: Period
         BEGDA(10) TYPE C,   "Start Date
         SUBTY     TYPE RP50G-SUBTY,   "Subtype
*           CHOIC type RP50G-CHOIC,   "Infotype selection for HR master data maintenance
         BETRG     TYPE Q0015-BETRG,   "Wage Type Amount for Payments
*           WAERS type P0015-WAERS,   "Currency Key



       END OF TY_FINAL.

TYPES :BEGIN OF TY_LOG,
         PERNR    TYPE PERNR,
         TCODE    TYPE BDC_TCODE,
         DYNAME   TYPE BDC_MODULE,
         DYNUMB   TYPE BDC_DYNNR,
         MSGTYP   TYPE BDC_MART,
         MSGSPRA  TYPE  BDC_SPRAS,
         MSGID    TYPE  BDC_MID,
         MSGNR    TYPE  BDC_MNR,
         MSGV1    TYPE  BDC_VTEXT1,
         MSGV2    TYPE BDC_VTEXT1,
         MSGV3    TYPE BDC_VTEXT1,
         MSGV4    TYPE BDC_VTEXT1,
         ENV      TYPE BDC_AKT,
         FLDNAME  TYPE  FNAM_____4,
         MSG_TEXT TYPE STRING,
       END OF TY_LOG.

DATA: IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL TYPE TY_FINAL.

DATA: IT_BDCDATA  TYPE TABLE OF BDCDATA,
      WA_BDCDATA  TYPE BDCDATA,
      IT_MESSTAB  TYPE TABLE OF BDCMSGCOLL,
      WA_MESSTAB  TYPE BDCMSGCOLL,
      IT_LOG      TYPE TABLE OF TY_LOG,
      WA_LOG      TYPE TY_LOG,
      IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.

DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A',
      LS_OPT  TYPE CTU_PARAMS.
