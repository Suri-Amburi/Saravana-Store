*&---------------------------------------------------------------------*
*&  Include           ZHR_012_INFOTYPE_UPDATE_TOP
*&---------------------------------------------------------------------*

  TYPES:BEGIN OF GTY_DATA,
          PERNR     TYPE CHAR8,
          EINDA     TYPE CHAR10,
          SELEC_01  TYPE CHAR1,
          BEGDA     TYPE CHAR10,
          ENDDA     TYPE CHAR10,
          MASSN(2),"    TYPE p0000-massn,
          MASSG(2),"    TYPE p0000-massg,
          PLANS(10),"     TYPE p0001-plans,
          WERKS(20),"     TYPE p0001-werks,
          PERSG(10),"     TYPE p0001-persg,
          PERSK(10),"     TYPE p0001-persk,
          BTRTL(10),"   TYPE p0001-btrtl,
          ABKRS(20),"    TYPE p0001-abkrs,
          STELL(20),"    TYPE p0001-stell,
          VDSK1(20),"    TYPE p0001-vdsk1,
          ANRED(10),"    TYPE p0002-anred,
          NACHN(40),"    TYPE p0002-nachn,
          VORNA(40),"    TYPE p0002-vorna,
          GESCH,"    TYPE p0002-gesch,
          SPRSL(10),"    TYPE p0002-sprsl,
          GBDAT(10),
          NATIO(3),"    TYPE p0002-natio,
          FAMST,"    TYPE p0002-famst,
        END OF GTY_DATA,
        GTY_T_DATA TYPE STANDARD TABLE OF GTY_DATA.


  DATA:IT_FINAL TYPE GTY_T_DATA,
       GT_PROP  TYPE STANDARD TABLE OF PPROP.

  FIELD-SYMBOLS <FS_FINAL> TYPE GTY_DATA.

  DATA:FNAME TYPE LOCALFILE,
       ENAME TYPE CHAR4.

  TYPES:BEGIN OF GTY_DISPLAY,
          TYPE    TYPE BAPI_MTYPE,
          PERNR   TYPE PERNR,
          MESSAGE	TYPE BAPI_MSG,
        END OF GTY_DISPLAY,
        GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.

  DATA:GWA_DISPLAY TYPE GTY_DISPLAY,
       GIT_DISPLAY TYPE GTY_T_DISPLAY.
