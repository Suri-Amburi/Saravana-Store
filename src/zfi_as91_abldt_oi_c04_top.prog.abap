*&---------------------------------------------------------------------*
*& Include          ZFI_AS91_ABLDT_OI_C04_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF TY_EXCELTAB,
*          invnr(20),
          ANLKL(08),
          BUKRS(04),
*          nassets(20),
          TXT50(70),
          TXA50(100),
          ANLHTTXT(70),
*          ktogr(20),
          INVNR1(20),
          MENGE(20),
          MEINS(20),
          GJAHR(04),
          AKTIV(20),
*          zujhr(20),
*          zuper(20),
          GSBER(20),
          KOSTL(20),
          WERKS(20),
*          lifnr(30),
          LIFNR         TYPE LIFNR,
          TYPBZ(40),
          ACQ_VALUE(40),
          ORD_DEP(40),
          NAFAG(40),
          ORD_DEP1(40),
        END OF TY_EXCELTAB,
        TY_T_EXCELTAB TYPE STANDARD TABLE OF TY_EXCELTAB.


DATA : WA_EXCELTAB TYPE TY_EXCELTAB,
       I_EXCELTAB  TYPE TY_T_EXCELTAB.

DATA : FNAME TYPE LOCALFILE,
       ENAME TYPE CHAR4.

TYPES : BEGIN OF TY_ERRMSG,
          SNO    TYPE I,
          MSGTYP TYPE BAPI_MTYPE,
          MESSG  TYPE BAPIRET2-MESSAGE,
          DOCNUM TYPE CHAR30,
        END OF TY_ERRMSG,
        TY_T_ERRMSG TYPE STANDARD TABLE OF TY_ERRMSG.

DATA: WA_ERRMSG      TYPE TY_ERRMSG,
      I_ERRMSG       TYPE TY_T_ERRMSG,
      I_FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV,

      GT_ANKB        TYPE TABLE OF ANKB,
      WA_ANKB        TYPE ANKB.
