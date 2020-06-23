CLASS zcl_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES : if_amdp_marker_hdb.
  TYPES : BEGIN OF ty_data,
          MATNR TYPE matnr ,
          WERKS TYPE werks_d,
          CHARG  TYPE charg_d,
          CLABS   TYPE LABST,
          matnr1  TYPE matnr,
          werks1  TYPE werks_d,
          qty     TYPE LABST,
          batch   TYPE char40,
          s4batch TYPE charg_d,
          mvt     TYPE BWART,
          END OF ty_data,

          tt_data TYPE STANDARD TABLE OF ty_data.



         CLASS-METHODS : gt_data
          EXPORTING
           VALUE(et_data) TYPE tt_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data IMPLEMENTATION .
  METHOD gt_data BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING NSDM_V_MCHB zb1_stock.
et_data =    select NSDM_V_MCHB.MATNR,
       NSDM_V_MCHB.WERKS,
       NSDM_V_MCHB.CHARG,
       NSDM_V_MCHB.CLABS,
       zb1_stock.matnr as matnr1,
       zb1_stock.plant  as werks1,
       zb1_stock.QUANTITY AS qty,
       zb1_stock.B1_BATCH as batch,
       zb1_stock.batch as s4batch,
       zb1_stock.move_type AS mvt
       FROM NSDM_V_MCHB AS NSDM_V_MCHB
       LEFT OUTER JOIN ZB1_STOCK  AS zb1_stock ON NSDM_V_MCHB.CHARG = zb1_stock.batch AND NSDM_V_MCHB.werks = zb1_stock.plant;

  ENDMETHOD.

ENDCLASS.
