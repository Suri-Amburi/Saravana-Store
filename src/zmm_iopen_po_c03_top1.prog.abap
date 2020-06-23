*&---------------------------------------------------------------------*
*& Include          ZMM_IOPEN_PO_C03_TOP1
*&---------------------------------------------------------------------*
TYPES : BEGIN OF GTY_FILE,
         SNO(05),
          BSART(04),                          " Purchase order Header lines
          EBELN(10),
*  org data
          EKORG(04),
          EKGRP(03),
          BUKRS(04),
*  vendor
          LIFNR(41),
          BEDAT(10),
*  Exchange Rate
          WKURS(09),
*  Texts
          07(30),
          05(30),
          03(30),
          08(30),
          10(30),
          22(30),
          23(30),
*  Additional Data
          SUBMI(10),                            " Additional data
*Item Overview
          EBELP(05),
          KNTTP(01),
          EPSTP(01),
          MATNR(40),
          TXZ01(40),
          MATKL(09),
          MENGE(13),
          EEIND(10),
          NETPR(11)," TYPE BPREI,
          NAME1(30),
          LGOBE(16),

          MWSKZ(02),                             " Item detail

*Item Texts
          11(30),
          SAKNR(10),
          KOSTL(10),
          KOKRS(4),
          SERVICE(18),
          KSCHL(1),
          COMPONENT(40),
          ERFMG(10),
          MARK(1),


        END OF GTY_FILE,
        GTY_T_FILE TYPE STANDARD TABLE OF GTY_FILE.


DATA:GWA_FILE    TYPE GTY_FILE,
     GIT_FILE    TYPE GTY_T_FILE,
     GIT_FILE_I  TYPE GTY_T_FILE,
     GIT_FILE_IT TYPE GTY_T_FILE.

DATA:FNAME TYPE LOCALFILE,
     ENAME TYPE CHAR4.

TYPES:BEGIN OF GTY_DISPLAY,
        SNO     TYPE I,
        ID      TYPE BAPIRET2-ID,
        PO_ITEM   TYPE CHAR10,
        TYPE    TYPE BAPIRET2-TYPE,
        MESSAGE TYPE BAPIRET2-MESSAGE,
      END OF GTY_DISPLAY,
      GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.

DATA: "GWA_DISPLAY TYPE BAPIRET2,
      "GIT_DISPLAY TYPE BAPIRET2,

      GWA_DISPLAY TYPE GTY_DISPLAY,
      GIT_DISPLAY TYPE GTY_T_DISPLAY,


      IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.

DATA: IT_BDCDATA TYPE TABLE OF BDCDATA,
      WA_BDCDATA TYPE BDCDATA.
DATA: IT_MESSTAB TYPE TABLE OF BDCMSGCOLL,
      WA_MESSTAB TYPE BDCMSGCOLL,
*        wa_log TYPE zint_log,
      MESSTAB1   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A'.

*  field-symbols:<fs_flatfile>  type gty_file,
*                <fs_flatfile_it> type gty_file,
*                <fs_flatfile1> type gty_file.

*DATA: LV_MATNR TYPE CSAP_MBOM-MATNR,          " Material BOM Initial Screen Data
*      LV_WERKS TYPE CSAP_MBOM-WERKS,
*      LV_STLAN TYPE CSAP_MBOM-STLAN,
*      LV_DATUV TYPE CSAP_MBOM-DATUV.
