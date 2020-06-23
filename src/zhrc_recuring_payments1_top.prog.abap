*&---------------------------------------------------------------------*
*& Include          ZHRC_RECURING_PAYMENTS1_TOP
*&---------------------------------------------------------------------*




TYPES: BEGIN OF TY_DATA,
         PERNR     TYPE  PERNR_D,                          "Personnel Number
         BEGDA(10) TYPE  C,                                "Start Date
         ENDDA(10) TYPE  C,                                "End Date
         LGART     TYPE  LGART,                            "Wage Type
         BETRG(15) TYPE  C,                                "Wage Type Amount for Payments
       END OF TY_DATA.

TYPES: BEGIN OF TY_LOG,
         PERNR    TYPE  PERNR_D,                          "Personnel Number
         TCODE    TYPE BDC_TCODE,
         DYNAME   TYPE BDC_MODULE,
         DYNUMB   TYPE BDC_DYNNR,
         MSGTYP   TYPE BDC_MART,
         MSGSPRA  TYPE BDC_SPRAS,
         MSGID    TYPE BDC_MID,
         MSGNR    TYPE BDC_MNR,
         MSGV1    TYPE BDC_VTEXT1,
         MSGV2    TYPE BDC_VTEXT1,
         MSGV3    TYPE BDC_VTEXT1,
         MSGV4    TYPE BDC_VTEXT1,
         ENV      TYPE BDC_AKT,
         FLDNAME  TYPE FNAM_____4,
         MSG_TEXT TYPE STRING,
       END OF TY_LOG.

DATA: GT_DATA TYPE TABLE OF TY_DATA,
      WA_DATA TYPE TY_DATA.


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
