CLASS zcl_zgr_p DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

      TYPES: BEGIN OF TY_FINAL,
             REC_DATE     TYPE ZINW_T_HDR-rec_date,
             LIFNR        TYPE zinw_t_hdr-lifnr,
             LR_NO        TYPE ZINW_T_HDR-lr_no,
             ACT_NO_BUD   TYPE ZINW_T_HDR-act_no_bud,
             TRNS         TYPE ZINW_T_HDR-trns,
             NAME1        TYPE ZINW_T_HDR-name1,
             BILL_NUM     TYPE ZINW_T_HDR-bill_num,
             BILL_DATE    TYPE ZINW_T_HDR-bill_date,
             NET_AMT      TYPE ZINW_T_HDR-net_amt,
             LR_DATE      TYPE ZINW_T_HDR-lr_date,
             MBLNR        TYPE ZINW_T_HDR-mblnr,
             TOTAL        TYPE ZINW_T_HDR-total,
             PUR_TOTAL    TYPE ZINW_T_HDR-pur_total,
             QR_CODE      TYPE ZINW_T_HDR-qr_code,
             city1        TYPE adrc-city1,
             budat        TYPE mkpf-budat,
             CREATED_DATE TYPE ZINW_T_STATUS-created_date,
             STATUS_VALUE TYPE ZINW_T_STATUS-status_value,
       END OF TY_FINAL.

       TYPES: it_final TYPE STANDARD TABLE OF ty_final.

       CLASS-METHODS GET_OUTPUT_PRD
         IMPORTING

           VALUE(LV_SELECT)  TYPE string
           VALUE(LV_SELECT1) TYPE STRING

         EXPORTING
           VALUE(ET_FINAL_DATA) TYPE it_final.

       ENDCLASS.


CLASS zcl_zgr_p IMPLEMENTATION.


 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING ZINW_T_HDR  adrc mkpf ZINW_T_STATUS LFA1 .


     IT_final = apply_filter ( ZINW_T_HDR, :LV_SELECT);
     IT_MKPF  = apply_filter (MKPF,   :LV_SELECT1);


   ET_FINAL_DATA = SELECT
                   ZINW_T_HDR.REC_DATE ,
                   ZINW_T_HDR.LIFNR,
                   ZINW_T_HDR.LR_NO,
                   ZINW_T_HDR.ACT_NO_BUD,
                   ZINW_T_HDR.TRNS,
                   ZINW_T_HDR.NAME1,
                   ZINW_T_HDR.BILL_NUM,
                   ZINW_T_HDR.BILL_DATE,
                   ZINW_T_HDR.NET_AMT,
                   ZINW_T_HDR.LR_DATE ,
                   ZINW_T_HDR.MBLNR,
                   ZINW_T_HDR.TOTAL,
                   ZINW_T_HDR.PUR_TOTAL,
                   ZINW_T_HDR.QR_CODE ,
                   ADRC.CITY1,
                   MKPF.BUDAT,
                   ZINW_T_STATUS.CREATED_DATE,
                   ZINW_T_STATUS.STATUS_VALUE
                   FROM lfa1 as lfa1
                   INNER JOIN :IT_FINAL AS ZINW_T_HDR on ZINW_T_HDR.LIFNR = LFA1.LIFNR
*                   INNER JOIN LFA1 AS LFA1 ON ZINW_T_HDR.LIFNR = LFA1.LIFNR
                   INNER JOIN ADRC AS ADRC ON LFA1.ADRNR = ADRC.ADDRNUMBER
                   INNER JOIN :it_mkpf as MKPF ON ZINW_T_HDR.MBLNR = MKPF.MBLNR
                   INNER JOIN ZINW_T_STATUS AS ZINW_T_STATUS ON ZINW_T_STATUS.QR_CODE = ZINW_T_HDR.QR_CODE
                   WHERE ZINW_T_STATUS.STATUS_VALUE = 'QR02' ;


 ENDMETHOD.


ENDCLASS.
