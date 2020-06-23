CLASS zcl_stock DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

      TYPES: BEGIN OF TY_FINAL,
                   docnum type edidc-docnum,
                   rcvprn type edidc-rcvprn,
                   status type edidc-status,
                   credat type edidc-credat,
                   segnam type edid4-segnam,
                   segnum type edid4-segnum,
                   sdata  type edid4-sdata,
       END OF TY_FINAL.

       TYPES: it_final TYPE STANDARD TABLE OF ty_final.

       CLASS-METHODS GET_OUTPUT_PRD
         IMPORTING
           VALUE(LV_SELECT)  TYPE string
          EXPORTING
           VALUE(ET_FINAL_DATA) TYPE it_final.
ENDCLASS.


CLASS zcl_stock IMPLEMENTATION.

 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING edid4 edidc  .

it_final = apply_filter ( edidc, :lv_select);

 ET_FINAL_DATA = SELECT
                   edidc.docnum,
                   edidc.rcvprn,
                   edidc.status,
                   edidc.credat,
                   edid4.segnam,
                   edid4.segnum,
                   edid4.sdata
                   FROM edid4 AS edid4
                   INNER JOIN :it_final AS edidc ON edid4.docnum = edidc.docnum
                   WHERE edidc.status <> '53' AND edidc.status <> '70' AND edid4.segnam = 'E1WPU02' ;





 ENDMETHOD.


ENDCLASS.
