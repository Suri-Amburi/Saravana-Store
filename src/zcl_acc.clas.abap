CLASS zcl_acc DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

      TYPES: BEGIN OF TY_FINAL,
           ebeln    type  ekbe-ebeln,
           ebelp    TYPE  ekbe-ebelp,
           bewtp    TYPE  ekbe-bewtp,
           bwart    TYPE  ekbe-bwart,
           menge    TYPE  ekbe-menge,
           belnr    TYPE  ekbe-belnr,
           gjahr    TYPE  ekbe-gjahr,
           budat    TYPE  ekbe-budat,
           lfbnr    type  ekbe-lfbnr,
           dmbtr    type  ekbe-dmbtr,
           matnr    type  ekbe-matnr,
           XBLNR    type  ekbe-XBLNR,
           BUZEI    TYPE  EKBE-BUZEI,
           bsart    type  ekko-bsart,
           loekz    type  ekko-loekz,
           aedat    type  ekko-aedat,
           lifnr    type  ekko-lifnr,
           waers    type  ekko-waers,
           zterm    type  ekko-zterm,
           zbd1t    type  ekko-zbd1t,
           mblnr    type  matdoc-mblnr,
           zeile    TYPE  matdoc-zeile,
           mwskz    type  ekpo-mwskz,
           kostl    type  ekkn-kostl,
           anln1    type  ekkn-anln1,
           due_date type  ekbe-budat,
       END OF TY_FINAL.

       TYPES: begin of ty_final1,
            bukrs    type bsik-bukrs,
            lifnr    type bsik-lifnr,
            augbl    type bsik-augbl,
            belnr    type bsik-belnr,
            gjahr    type bsik-gjahr,
            budat    type bsik-budat,
            due_date type bsik-budat,
            xblnr    type bsik-xblnr,
            ekorg    TYPE lfm1-ekorg,
            zterm    type lfm1-zterm,
            ebeln    type bseg-ebeln,
            buzei    type bseg-buzei,
            dmbtr    type bseg-dmbtr,
            kostl    type bseg-kostl,
            H_BLART  TYPE BSEG-H_BLART,
          END OF ty_final1.

       TYPES: it_final  TYPE STANDARD TABLE OF ty_final.
       TYPES: it_final1 TYPE STANDARD TABLE OF ty_final1.

       CLASS-METHODS GET_OUTPUT_PRD
         IMPORTING
           VALUE(LV_SELECT)  TYPE string
           VALUE(LV_YEAR)    TYPE BDATJ
          EXPORTING
           VALUE(ET_FINAL_DATA) TYPE it_final.

     CLASS-METHODS GET_OUTPUT_PRD1
         IMPORTING
           VALUE(LV_SELECT1)  TYPE string
           VALUE(LV_YEAR1)    TYPE BDATJ
          EXPORTING
           VALUE(ET_FINAL_DATA1) TYPE it_final1.
ENDCLASS.


CLASS zcl_acc IMPLEMENTATION.

 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING ekbe ekko ekpo matdoc ekkn .

it_final = apply_filter ( EKBE , :lv_select);

 ET_FINAL_DATA =   SELECT
                     ekbe.ebeln,
                     ekbe.ebelp,
                     ekbe.bewtp,
                     ekbe.bwart,
                     ekbe.menge,
                     ekbe.belnr,
                     ekbe.gjahr,
                     ekbe.budat,
                     ekbe.lfbnr,
                     ekbe.dmbtr,
                     ekbe.matnr,
                     ekbe.XBLNR,
                     EKBE.BUZEI,
                     ekko.bsart,
                     ekko.loekz,
                     ekko.aedat,
                     ekko.lifnr,
                     ekko.waers,
                     ekko.zterm,
                     ekko.zbd1t,
                     matdoc.mblnr,
                     matdoc.zeile,
                     ekpo.mwskz,
                     ekkn.kostl,
                     ekkn.anln1,
                     ekbe.budat AS due_date
                     FROM :it_final AS ekbe
                     INNER JOIN ekko AS ekko ON ekko.ebeln = ekbe.ebeln
                     INNER JOIN ekpo AS ekpo ON ekbe.ebeln = ekpo.ebeln
                     INNER JOIN ekkn AS ekkn ON ekbe.ebeln = ekkn.ebeln
                     INNER JOIN matdoc AS matdoc ON ekbe.belnr = matdoc.mblnr AND ekbe.buzei = matdoc.zeile AND ekbe.matnr = matdoc.matnr
                     WHERE ekbe.bewtp = 'E'  AND ekbe.bwart IN ( '101' , '102' ) AND EKBE.GJAHR = LV_YEAR
                     and ekko.bsart IN ('NB' , 'ZTSR')  AND ekko.loekz <> 'X' ;

*                     INNER JOIN mseg AS mseg ON mseg.mblnr = ekbe.belnr
*                     AND mseg.matnr = ekbe.matnr AND ekbe.buzei = mseg.zeile
*                     INNER JOIN ekkn AS ekkn ON ekkn.ebeln = ekbe.ebeln
*                     WHERE ekko.bsart IN ('NB' , 'ZTSR')
*                     AND ekko.loekz <> 'X' AND ekbe.bewtp = 'E'  AND ekbe.bwart IN ( '101' , '102' ) AND EKBE.GJAHR = LV_YEAR ;


 ENDMETHOD.

METHOD GET_OUTPUT_PRD1 BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING bsik lfm1 bseg .

it_final1 = apply_filter ( bsik , :lv_select1);

 ET_FINAL_DATA1 =   select
                       bsik.bukrs,
                       bsik.lifnr,
                       bsik.augbl,
                       bsik.belnr,
                       bsik.gjahr,
                       bsik.budat,
                       bsik.budat AS due_date,
                       bsik.xblnr,
                       lfm1.ekorg,
                       lfm1.zterm,
                       bseg.ebeln,
                       bseg.buzei,
                       bseg.dmbtr,
                       bseg.kostl,
                       bseg.h_blart
                       FROM :it_final1 AS bsik
                       INNER JOIN bseg AS bseg ON bsik.bukrs = bseg.bukrs AND bsik.belnr = bseg.belnr AND bsik.gjahr = bseg.gjahr
                       INNER JOIN lfm1 AS lfm1 ON bsik.lifnr = lfm1.lifnr
                       WHERE bsik.augbl = ' ' AND bsik.gjahr = lv_year1 and bseg.h_blart <> 'KG';


 ENDMETHOD.


ENDCLASS.
