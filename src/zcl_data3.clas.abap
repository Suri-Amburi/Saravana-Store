CLASS zcl_data3 DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES : if_amdp_marker_hdb.
    TYPES : BEGIN OF ty_data,
              matnr   TYPE matnr,
              werks   TYPE werks_d,
              charg   TYPE charg_d,
              clabs   TYPE labst,
              matnr1  TYPE matnr,
              werks1  TYPE werks_d,
              qty     TYPE labst,
              batch   TYPE char40,
              s4batch TYPE charg_d,
              mvt     TYPE bwart,
            END OF ty_data,

            tt_data3 TYPE STANDARD TABLE OF ty_data.



    CLASS-METHODS : gt_data3
      EXPORTING
        VALUE(et_data) TYPE tt_data3.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_data3 IMPLEMENTATION.
  METHOD gt_data3  BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING nsdm_v_mchb zb1_stock.
    et_data =    SELECT  nsdm_v_mchb.matnr,
                         nsdm_v_mchb.werks,
                         nsdm_v_mchb.charg,
                         nsdm_v_mchb.clabs,
                         zb1_stock.matnr as matnr1,
                         zb1_stock.plant  as werks1,
                         zb1_stock.quantity as qty,
                         zb1_stock.b1_batch as batch,
                         zb1_stock.batch as s4batch,
                         zb1_stock.move_type AS mvt
                         FROM NSDM_V_MCHB AS NSDM_V_MCHB
                         INNER JOIN ZB1_STOCK  AS zb1_stock ON NSDM_V_MCHB.CHARG = zb1_stock.batch
                         AND NSDM_V_MCHB.werks = zb1_stock.plant
                         WHERE NSDM_V_MCHB.clabs > 0;


  ENDMETHOD.

ENDCLASS.
