CLASS zeod_po DEFINITION

  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

      TYPES: BEGIN OF TY_FINAL,
             ebeln type ekko-ebeln,
             aedat type ekko-aedat,
             ekgrp type ekko-ekgrp,
             lifnr type ekko-lifnr,
             bsart type ekko-bsart,
             ebelp type ekpo-ebelp,
             retpo type ekpo-retpo,
             netwr type ekpo-netwr,
             menge type ekpo-menge,
             name1 type lfa1-name1,
             ort01 type lfa1-ort01,
       END OF TY_FINAL.

       TYPES: it_final TYPE STANDARD TABLE OF ty_final.

       CLASS-METHODS GET_OUTPUT_PRD
         IMPORTING
*           VALUE(LV_DATE)    TYPE bldat
           VALUE(LV_SELECT)  TYPE string

         EXPORTING
           VALUE(ET_FINAL_DATA) TYPE it_final.

       ENDCLASS.


CLASS zeod_po IMPLEMENTATION.


 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING ekko ekpo LFA1 .


     IT_final = apply_filter ( EKKO, :LV_SELECT );


   ET_FINAL_DATA = SELECT
                   ekko.ebeln,
                   ekko.aedat,
                   ekko.ekgrp,
                   ekko.lifnr,
                   ekko.bsart,
                   ekpo.ebelp,
                   ekpo.retpo,
                   ekpo.netwr,
                   ekpo.menge,
                   lfa1.name1,
                   lfa1.ort01
                   FROM ekPo AS ekPo
                   INNER JOIN :IT_FINAL AS ekKo  ON ( ekko.ebeln = ekpo.ebeln AND ekpo.retpo <> 'X' )
                   INNER JOIN lfa1 AS lfa1 ON ekko.lifnr = lfa1.lifnr
                   WHERE ekko.bsart IN ('ZLOP','ZOSP','ZTAT','ZVLO','ZOSP') ;



 ENDMETHOD.


ENDCLASS.
