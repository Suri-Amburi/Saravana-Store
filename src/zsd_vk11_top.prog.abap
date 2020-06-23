*&---------------------------------------------------------------------*
*& Include          ZSD_VK11_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          ZSD_VK11_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF GTY_FILE,
          KSCHL(4),
          MATNR(40),
          lifnr(10),
          KBETR(16),
        END OF GTY_FILE,
        GTY_T_FILE TYPE STANDARD TABLE OF GTY_FILE.

TYPES:BEGIN OF TY_FINAL,
        SLNO(5),
        KSCHL(4),
        VKORG(4),
        VTWEG(2),
        MATNR(40),
        lifnr(10),
        KBETR(16),
        MSGTY     TYPE TEXT1,
        MSG       TYPE TEXT255,
      END OF TY_FINAL,
      TT_FINAL TYPE STANDARD TABLE OF TY_FINAL.


DATA:
  GWA_FILE    TYPE GTY_FILE,
  GIT_FILE    TYPE  GTY_T_FILE,
  GIT_FILE_I  TYPE GTY_T_FILE,
  GIT_FILE_IT TYPE GTY_T_FILE.

DATA:
  FNAME TYPE LOCALFILE,
  ENAME TYPE CHAR4.

DATA :
  IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
  WA_LAYOUT   TYPE SLIS_LAYOUT_ALV,
  IT_BDCDATA  TYPE TABLE OF BDCDATA,
  WA_BDCDATA  TYPE BDCDATA,
  IT_MESSTAB  TYPE TABLE OF BDCMSGCOLL,
  WA_MESSTAB  TYPE BDCMSGCOLL,
  CTUMODE     LIKE CTU_PARAMS-DISMODE VALUE 'N',
  CUPDATE     LIKE CTU_PARAMS-UPDMODE VALUE 'S',
  LS_FINAL    TYPE TY_FINAL,
  LT_FINAL    TYPE TABLE OF TY_FINAL.
