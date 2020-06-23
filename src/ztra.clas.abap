CLASS ztra DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

      TYPES: BEGIN OF TY_FINAL,
            ebeln      type ekko-ebeln,
            aedat      type ekko-aedat,
            lifnr      type ekko-lifnr,
            name1      type zinw_t_hdr-name1,
            lr_no      type zinw_t_hdr-lr_no,
            lr_date    type zinw_t_hdr-lr_date,
            inwd_doc   type zinw_t_hdr-inwd_doc,
            service_po type zinw_t_hdr-service_po,
            ebelp      type ekpo-ebelp,
            matnr      type ekpo-matnr,
            menge      type ekpo-menge,
            mwskz      type ekpo-mwskz,
            netpr      type ekpo-netpr,
            netwr      type ekpo-netwr,
       END OF TY_FINAL.

       TYPES: it_final TYPE STANDARD TABLE OF ty_final.

       CLASS-METHODS GET_OUTPUT_PRD
         IMPORTING
           VALUE(LV_SELECT)  TYPE string
          EXPORTING
           VALUE(ET_FINAL_DATA) TYPE it_final.
       ENDCLASS.


CLASS ztra IMPLEMENTATION.

 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING ZINW_T_HDR ekko ekpo  .

     IT_final = apply_filter ( ekko, :lv_select);

   ET_FINAL_DATA = SELECT
                     ekko.ebeln,
                     ekko.aedat,
                     ekko.lifnr,
                     zinw_t_hdr.name1,
                     zinw_t_hdr.lr_no,
                     zinw_t_hdr.lr_date,
                     zinw_t_hdr.inwd_doc,
                     zinw_t_hdr.service_po,
                     ekpo.ebelp,
                     ekpo.matnr,
                     ekpo.menge,
                     ekpo.mwskz,
                     ekpo.netpr,
                     ekpo.netwr
                     FROM ekpo AS ekpo
                     INNER JOIN :it_final as ekko on  ekpo.ebeln =  ekko.ebeln
                     LEFT OUTER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr.service_po = ekko.ebeln
*                     INNER JOIN ekpo AS ekpo ON ekpo~ebeln =  ekko~ebeln
                     WHERE ekko.bsart = 'ZTSR';


 ENDMETHOD.


ENDCLASS.
