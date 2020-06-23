*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD_T01
*&---------------------------------------------------------------------*
TYPES : BEGIN OF GTY_FILE,
          SLNO(4),
          DOC_DATE(10),
          PSTNG_DATE(10),
          MATERIAL(40),
          PLANT(20),
          STGE_LOC(20),
          MOVE_TYPE(20),
          SPEC_STOCK(20),
          VENDOR(10),
          ENTRY_QNT(10),
          ENTRY_UOM(3),
          BATCH(10),
          SALES_ORDER(10),
          LINE_ITEM(6),
          TO_CHECK(1),
          DATE(10),         " Date of Manufacture
          SERNR(18),        "Added by IBR on 5.4.2019
        END OF GTY_FILE,
        GTY_T_FILE TYPE STANDARD TABLE OF GTY_FILE.


DATA:GWA_FILE    TYPE GTY_FILE,
     GIT_FILE    TYPE  GTY_T_FILE,
     GIT_FILE_I  TYPE GTY_T_FILE,
     GIT_FILE_IT TYPE GTY_T_FILE.

DATA:FNAME TYPE LOCALFILE,
     ENAME TYPE CHAR4.

TYPES:BEGIN OF TY_FINAL,
        SLNO(5),
        MATNR   TYPE MARA-MATNR,
        CHARG   TYPE MSEG-CHARG,
        MBLNR   TYPE MKPF-MBLNR,
        MJAHR   TYPE MKPF-MJAHR,
        MSGTY   TYPE TEXT1,
        MSG     TYPE TEXT255,
      END OF TY_FINAL,
      TT_FINAL TYPE STANDARD TABLE OF TY_FINAL.

DATA :
  IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
  WA_LAYOUT   TYPE SLIS_LAYOUT_ALV.

DATA: IT_BDCDATA TYPE TABLE OF BDCDATA,
      WA_BDCDATA TYPE BDCDATA.
DATA: IT_MESSTAB TYPE TABLE OF BDCMSGCOLL,
      WA_MESSTAB TYPE BDCMSGCOLL.
DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'S'.

DATA : LS_FINAL TYPE TY_FINAL,
       LT_FINAL TYPE TABLE OF TY_FINAL.
