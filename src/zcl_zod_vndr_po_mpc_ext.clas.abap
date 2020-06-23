CLASS zcl_zod_vndr_po_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zod_vndr_po_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES : BEGIN OF ts_deep_entity ,
              po_number TYPE c LENGTH 10,
              vendor    TYPE c LENGTH 10,
              dtype     TYPE c LENGTH 4,
              bukrs     TYPE c LENGTH 4,
              aedat     TYPE c LENGTH 10,
              lifnr     TYPE c LENGTH 10,
              langu     TYPE c LENGTH 2,
              ekgrp     TYPE c LENGTH 3,
              ekorg     TYPE c LENGTH 4,
*             AEDAT1        TYPE  ZDATE_E,
*             AD_NAME       TYPE  AD_NAME1,
*             TOTAL         TYPE  ZNETPR,
*             DEL_BY        TYPE  EINDT,
*             REF_PO        TYPE  EBELN,
*             BILL_TAT      TYPE  ZBILL_DAT,
*             ERNAME        TYPE  ERNAM,
*             INWD_DOC      TYPE  ZINWD_DOC,
*             TEXT          TYPE  CHAR20,
*             GSTINP        TYPE  STCD3,
*             BILL_TEXT     TYPE  CHAR20,
*             BILL_NUM      TYPE  ZBILL_NUM,
*             TOT_QTY       TYPE  ZBSTMG,
*             GROUP_ID      TYPE  WWGHA,
*             BSART         TYPE  ESART,
*             ZTRANNO       TYPE  ZTRANNO,
*             APPROVER2     TYPE  ZPPROVER2,
*             APPROVER2_DT  TYPE ZDATE_E,
*             USER_NAME     TYPE ZUNAM,
*              itemset   TYPE TABLE OF zcl_zod_vndr_po_mpc=>ts_po_create_i WITH DEFAULT KEY,
*             RESULTset     TYPE STANDARD TABLE OF ZCL_ZOD_VNDR_PO_MPC=>TS_RESULT WITH DEFAULT KEY,
            END OF ts_deep_entity.

    METHODS define
        REDEFINITION .
protected section.
private section.
*  types TS_DEEP_ENTITY .
* TYPES: BEGIN OF TS_DEEP_ENTITY ,
*             PO_NUMBER     TYPE  EBELN,
*             VENDOR        TYPE  LIFNR,
*             DOC_TYPE      TYPE  ESART,
*             DTYPE         TYPE  CHAR4,
*             BUKRS         TYPE  BUKRS,
*             AEDAT         TYPE  ZDATE_E,
*             LIFNR         TYPE  ELIFN,
*             LANGU         TYPE  SPRAS,
*             EKGRP         TYPE  BKGRP,
*             EKORG         TYPE  EKORG,
*             AEDAT1        TYPE  ZDATE_E,
*             AD_NAME       TYPE  AD_NAME1,
*             TOTAL         TYPE  ZNETPR,
*             DEL_BY        TYPE  EINDT,
*             REF_PO        TYPE  EBELN,
*             BILL_TAT      TYPE  ZBILL_DAT,
*             ERNAME        TYPE  ERNAM,
*             INWD_DOC      TYPE  ZINWD_DOC,
*             TEXT          TYPE  CHAR20,
*             GSTINP        TYPE  STCD3,
*             BILL_TEXT     TYPE  CHAR20,
*             BILL_NUM      TYPE  ZBILL_NUM,
*             TOT_QTY       TYPE  ZBSTMG,
*             GROUP_ID      TYPE  WWGHA,
*             BSART         TYPE  ESART,
*             ZTRANNO       TYPE  ZTRANNO,
*             APPROVER2     TYPE  ZPPROVER2,
*             APPROVER2_DT  TYPE ZDATE_E,
*             USER_NAME     TYPE ZUNAM,
*             ITEMSET       TYPE TABLE OF ZCL_ZOD_VNDR_PO_MPC=>ts_po_create_i WITH DEFAULT KEY,
*             RESULTset     TYPE STANDARD TABLE OF ZCL_ZOD_VNDR_PO_MPC=>TS_RESULT WITH DEFAULT KEY,
*           END OF TS_DEEP_ENTITY.
ENDCLASS.



CLASS ZCL_ZOD_VNDR_PO_MPC_EXT IMPLEMENTATION.


  method DEFINE.

        DATA:
      LO_ANNOTATION   TYPE REF TO /IWBEP/IF_MGW_ODATA_ANNOTATION,
      LO_ENTITY_TYPE  TYPE REF TO /IWBEP/IF_MGW_ODATA_ENTITY_TYP,
      LO_COMPLEX_TYPE TYPE REF TO /IWBEP/IF_MGW_ODATA_CMPLX_TYPE,
      LO_PROPERTY     TYPE REF TO /IWBEP/IF_MGW_ODATA_PROPERTY,
      LO_ENTITY_SET   TYPE REF TO /IWBEP/IF_MGW_ODATA_ENTITY_SET.

    SUPER->DEFINE( ).
    LO_ENTITY_TYPE = MODEL->GET_ENTITY_TYPE( IV_ENTITY_NAME = 'PO_Create_H' ).
    LO_ENTITY_TYPE->BIND_STRUCTURE( IV_STRUCTURE_NAME  = 'ZCL_ZOD_VNDR_PO_MPC_EXT=>TS_DEEP_ENTITY' ).
  endmethod.
ENDCLASS.
