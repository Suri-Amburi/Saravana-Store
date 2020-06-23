*&---------------------------------------------------------------------*
*& Include          Z_GSTR2_REPORT_TOP
*&---------------------------------------------------------------------*
""""""""""""""" TYPES DECLARATION """""""""""""""""
TYPES : BEGIN OF TY_BKPF ,
          BUKRS	TYPE BUKRS,
          BELNR	TYPE BELNR_D,
          GJAHR	TYPE GJAHR,
          BLART	TYPE BLART,
          BLDAT	TYPE BLDAT,
          BUDAT	TYPE BUDAT,
        END OF TY_BKPF .

TYPES : BEGIN OF TY_BSEG ,
          BUKRS TYPE BUKRS,
          BELNR TYPE BELNR_D,
          GJAHR TYPE GJAHR,
          BUZID TYPE BUZID,
          KOART TYPE KOART,
          SHKZG TYPE SHKZG,
          MWSKZ TYPE MWSKZ,
          DMBTR	TYPE DMBTR,
          LIFNR	TYPE LIFNR,
        END OF TY_BSEG .

TYPES : BEGIN OF TY_A003 ,
          KAPPL	TYPE KAPPL,
          KSCHL	TYPE KSCHA,
          ALAND	TYPE ALAND,
          MWSKZ	TYPE MWSKZ,
          KNUMH	TYPE KNUMH,
        END OF TY_A003 .

TYPES : BEGIN OF TY_KONP ,
          KNUMH	TYPE KNUMH,
          KOPOS	TYPE KOPOS,
          KSCHL TYPE KSCHA,
          KBETR	TYPE KBETR_KOND,
          PKWRT	TYPE PKWRT,
        END OF TY_KONP .

TYPES : BEGIN OF TY_LFA1 ,
          LIFNR	TYPE LIFNR,
          ORT01	TYPE ORT01_GP,
        END OF TY_LFA1 .


TYPES : BEGIN OF TY_FINAL ,
          SLNO        TYPE I,
          BUKRS	      TYPE BUKRS,
          BELNR	      TYPE BELNR_D,
          GJAHR	      TYPE GJAHR,
          BLART	      TYPE BLART,
          BLDAT	      TYPE BLDAT,
          BUDAT	      TYPE BUDAT,
*          BUKRS       TYPE BUKRS,
*          BELNR       TYPE BELNR_D,
*          GJAHR       TYPE GJAHR,
          BUZID       TYPE BUZID,
          KOART       TYPE KOART,
          SHKZG       TYPE SHKZG,
          MWSKZ       TYPE MWSKZ,
          DMBTR	      TYPE DMBTR,
          ORT01       TYPE ORT01_GP,
          KSCHL	      TYPE KSCHA,
          KBETR	      TYPE KBETR_KOND,
          IGST%       TYPE KBETR_KOND,
          CGST%       TYPE KBETR_KOND,
          SGST%       TYPE KBETR_KOND,
          IGST        TYPE PKWRT,
          CGST        TYPE PKWRT,
          SGST        TYPE PKWRT,
*          TOTAL_INVOICE_VALUE TYPE INT4,
          MATNR       TYPE MATNR,
          WMWST1      TYPE FWSTEV,
          XRECH	      TYPE XRECH,
*          MSG                 TYPE CHAR4,
          CESS_AMOUNT TYPE CHAR4,
          WRBTR       TYPE WRBTR_CS,
          PKWRT       TYPE PKWRT,
          RMWWR       TYPE RMWWR,
          TOTAL_TAX   TYPE INT8,
        END OF  TY_FINAL .

"""""""""""""""""""""""' DATA DECLARATION """""""""""""""""""""""""
"""""""""""""""" INTERNAL AND WORKAREA DECLARATION """""""""""""""""""""""
DATA : IT_BKPF  TYPE TABLE OF TY_BKPF,
       WA_BKPF  TYPE TY_BKPF,
       IT_BSEG  TYPE TABLE OF TY_BSEG,
       WA_BSEG  TYPE TY_BSEG,
       IT_A003  TYPE TABLE OF TY_A003,
       WA_A003  TYPE TY_A003,
       IT_KONP  TYPE TABLE OF TY_KONP,
       WA_KONP  TYPE TY_KONP,
       IT_LFA1  TYPE TABLE OF TY_LFA1,
       WA_LFA1  TYPE TY_LFA1,
       IT_FINAL TYPE TABLE OF TY_FINAL,
       WA_FINAL TYPE TY_FINAL.

"""""""""""""""""""""""""" FOR DISPLAY OUTPUT """"""""""""""""""""""""""
DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
       WA_FIELDCAT TYPE  SLIS_FIELDCAT_ALV,
       WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.
WA_LAYOUT-ZEBRA = 'X'.
WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .

""""""""""""""""""""" FOR DATE RANGE """"""""""""""""""""""""""""""
DATA : FIRST_DATE TYPE SY-DATUM,
       LAST_DATE  TYPE  SY-DATUM,
       INPUT_DATE TYPE SY-DATUM,
       R_DATE     TYPE RANGE OF RBKP-BUDAT.

""""""""""""""""""' FOR SERIAL NO """""""""""""""""""""
DATA : SLNO  TYPE I .
SLNO = 1 .

""""""""""" FOR DROP DOWN _____________________________
DATA : NAME  TYPE VRM_ID,
       LIST  TYPE VRM_VALUES,
       VALUE LIKE LINE OF LIST.
CONSTANTS :
   C_X(1) VALUE 'X'.
