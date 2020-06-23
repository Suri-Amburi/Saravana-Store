CLASS ZMCSTOCK DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

      TYPES: BEGIN OF TY_FINAL,
           matnr TYPE MARA-MATNR,
           matkl TYPE MARA-MATKL,
           bwkey TYPE MBEW-bwkey,
           bwtar TYPE mbew-bwtar,
           lbkum TYPE MBEW-lbkum,
           salk3 TYPE MBEW-salk3,
           spras type t023t-spras,
           wgbez TYPE T023T-WGBEZ,
       END OF TY_FINAL.

       TYPES: it_final TYPE STANDARD TABLE OF ty_final.

       CLASS-METHODS GET_OUTPUT_PRD
         IMPORTING
           VALUE(LV_SELECT)  TYPE string
          EXPORTING
           VALUE(ET_FINAL_DATA) TYPE it_final.
ENDCLASS.


CLASS ZMCSTOCK IMPLEMENTATION.

 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING mara mbew t023t  .

*ET_FINAL_DATA = apply_filter ( :it_final1, :lv_select);

 it_final1 = SELECT
                     mara.matnr,
                     mara.matkl,
                     mbew.bwkey,
                     mbew.bwtar,
                     mbew.lbkum,
                     mbew.salk3,
                     t023t.spras,
                     t023t.wgbez
                     FROM mara AS mara
                     INNER JOIN mbew AS mbew ON mbew.matnr = mara.matnr
                     INNER JOIN t023t AS t023t ON mara.matkl = t023t.matkl
                     WHERE mbew.bwkey IN ('SSCP' , 'SSPO' , 'SSPU' , 'SSTN' , 'SSWH' )
                     AND mbew.lbkum <> '0' AND mara.mandt = mbew.mandt ;

ET_FINAL_DATA = apply_filter ( :it_final1, :lv_select);



 ENDMETHOD.


ENDCLASS.
