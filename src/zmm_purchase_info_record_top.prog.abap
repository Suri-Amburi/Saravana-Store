*&---------------------------------------------------------------------*
*& Include          ZMM_PURCHASE_INFO_RECORD_TOP
*&---------------------------------------------------------------------*
TYPES:BEGIN OF GTY_FILE,
        LIFNR(10),     " Vendor Account Number
        MATNR type matnr,     " Material Number
        EKORG(4),      " Purchasing Organization
        WERKS(4),      "Plant
        NORMB(1),      " Indicator
        LOHNB(1),      " Indicator
        MAHN1(03),
        MAHN2(03),
        MAHN3(03),
        MEINS(05),
        UMREZ(05),
        UMREN(05),
        APLFZ(4),      "
        EKGRP(4),      "
        NORBM(13),      " Standard qty
        MINBM(13),
        WEBRE(01),
        MWSKZ(2),      " Tax Code
        VERID(03),
        NETPR(11),     " Net Price
        PEINH(05),
        BPRME(3),      "uom
        BPUMZ(5),
        BPUMN(5),

      END OF GTY_FILE,
      GTY_T_FILE TYPE STANDARD TABLE OF GTY_FILE,

      BEGIN OF TY_LOG,
        LIFNR    TYPE LIFNR,
*        tcode    TYPE bdc_tcode,
*        dyname   TYPE bdc_module,
*        dynumb   TYPE bdc_dynnr,
*        msgtyp   TYPE bdc_mart,
*        msgspra  TYPE bdc_spras,
        MSGID    TYPE BDC_MID,
        MSGNR    TYPE BDC_MNR,
        MSGV1    TYPE BDC_VTEXT1,
        MSGV2    TYPE BDC_VTEXT1,
        MSGV3    TYPE BDC_VTEXT1,
        MSGV4    TYPE BDC_VTEXT1,
        ENV      TYPE BDC_AKT,
        FLDNAME  TYPE  FNAM_____4,
        MSG_TEXT TYPE STRING,
      END OF TY_LOG.


DATA:GWA_FILE    TYPE GTY_FILE,
     GIT_FILE    TYPE GTY_T_FILE,

     GWA_FILE_I  TYPE GTY_FILE,
     GWA_FILE_D  TYPE GTY_FILE,
     GIT_FILE_I  TYPE GTY_T_FILE,
     GIT_FILE_D  TYPE GTY_T_FILE,

     IT_BDCDATA  TYPE STANDARD TABLE OF BDCDATA,
     WA_BDCDATA  TYPE BDCDATA,

     IT_MSGCOLL  TYPE STANDARD TABLE OF BDCMSGCOLL,
     WA_MSGCOLL  TYPE BDCMSGCOLL,

     IT_LOG      TYPE STANDARD TABLE OF TY_LOG,
     WA_LOG      TYPE TY_LOG,

     IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
     WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.

DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A'.

DATA:FNAME TYPE LOCALFILE,
     ENAME TYPE CHAR4.
DATA MESSAGE TYPE STRING.
