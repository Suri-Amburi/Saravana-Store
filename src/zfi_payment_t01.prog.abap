*&---------------------------------------------------------------------*
*& Include          ZFI_PAYMENT_T01
*&---------------------------------------------------------------------*

DATA :
  GT_HDR     TYPE TABLE OF ZINW_T_HDR,
  GS_HDR     TYPE ZINW_T_HDR,
  IT_BKPF    TYPE TABLE OF BKPF,
  WA_BKPF    TYPE BKPF,
  WA_BKPF_DN    TYPE BKPF,
  IT_BSEG    TYPE TABLE OF BSEG,
  WA_BSEG    TYPE BSEG,
  WA_RBKP_DN TYPE RBKP,
  WA_RBKP_IV TYPE RBKP,
  WA_EKBE    TYPE EKBE,
  WA_BSIK    TYPE BSIK,
  LV_AMOUNT  TYPE BSIK-WRBTR.

TYPES:
  BEGIN OF TY_ALV,
    SNO       TYPE I,
    BUKRS     TYPE BUKRS,
    GJAHR     TYPE GJAHR,
    LIFNR     TYPE LFA1-LIFNR,
    NAME1     TYPE ADRC-NAME1,
    WRBTR     TYPE BSIK-WRBTR,
    C_BELNR   TYPE BSID-BELNR,
    C_AUGBL   TYPE BSAD-AUGBL,
    C_MESSAGE TYPE CHAR100,
    V_BELNR   TYPE BSIK-BELNR,
    V_AUGBL   TYPE BSAK-AUGBL,
    V_MESSAGE TYPE CHAR100,
*  c_type    TYPE c,
  END OF TY_ALV.
DATA : GT_ALV TYPE TABLE OF TY_ALV .
*** Constants
CONSTANTS :
  C_RFBU       TYPE GLVOR VALUE 'RFBU',
  C_KZ         TYPE BLART VALUE 'KZ',
  C_COMP_CODE  TYPE CHAR4 VALUE '1000',
  C_X(1)       VALUE 'X',
  C_E(1)       VALUE 'E',
  C_QR_CODE(7) VALUE 'QR_CODE',
  C_QR07(7)    VALUE 'QR07',
  C_01(2)      VALUE '01',
  C_02(2)      VALUE '02',
  C_03(2)      VALUE '03',
  C_04(2)      VALUE '04',
  C_05(2)      VALUE '05',
  C_06(2)      VALUE '06',
  C_07(2)      VALUE '07',
  C_GL         TYPE HKONT VALUE '0000140001'.
