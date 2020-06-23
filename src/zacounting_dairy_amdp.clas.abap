CLASS ZACOUNTING_DAIRY_AMDP DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES IF_AMDP_MARKER_HDB.

    types : BEGIN OF ty_ekko ,
             ebeln type ekko-EBELN ,
             BSART type ekko-bsart ,
             LOEKZ type ekko-LOEKZ ,
             AEDAT type ekko-AEDAT ,
             LIFNR type ekko-LIFNR ,
             WAERS TYPE EKKO-WAERS ,
             zterm type EKKO-ZTERM ,
             ZBD1T type EKKO-ZBD1T ,
             EBELP    TYPE ekpo-EBELP ,
             REPOS TYPE ekpo-REPOS ,
             QR_CODE type ZINW_T_HDR-QR_CODE ,
             NAME1 type ZINW_T_HDR-NAME1 ,
             STATUS      TYPE ZINW_T_HDR-STATUS ,
             SOE      TYPE ZINW_T_HDR-SOE ,
             MBLNR_103   TYPE ZINW_T_HDR-MBLNR ,
             MBLNR       TYPE ZINW_T_HDR-MBLNR ,
             CREATED_DATE  type   ZINW_T_STATUS-CREATED_DATE,
             INWD_DOC  TYPE ZINW_T_HDR-INWD_DOC ,
             REC_DATE  TYPE ZINW_T_HDR-REC_DATE ,
             MATNR    TYPE ZINW_T_ITEM-MATNR ,
             MATKL    TYPE ZINW_T_ITEM-MATKL ,
             NETPR_P  TYPE ZINW_T_ITEM-NETPR_P ,
             NETwr_p  type ZINW_T_ITEM-NETwr_p ,
             NETPR_GP TYPE ZINW_T_ITEM-NETPR_GP,
             MENGE_P  TYPE ZINW_T_ITEM-MENGE_P ,
             due_date TYPE datum ,

           END OF ty_ekko ,
           it_ekko type STANDARD TABLE OF ty_ekko .

   CLASS-METHODS : get_Acc_detail
   IMPORTING
      value(lv_date)  type sy-datum
      value(lv_date1) type sy-datum
   exporting
       value(it_ekko) type it_ekko .


ENDCLASS.



CLASS ZACOUNTING_DAIRY_AMDP IMPLEMENTATION.

METHOD get_Acc_detail  BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                  OPTIONS READ-ONLY
                  USING  ekko  ekpo ZINW_T_HDR ZINW_T_STATUS ZINW_T_item  .

     it_ekko = select EKKO.EBELN ,
                      EKKO.BSART ,
                      EKKO.LOEKZ ,
                      EKKO.AEDAT ,
                      EKKO.LIFNR ,
                      EKKO.WAERS ,
                      EKKO.ZTERM ,
                      EKKO.ZBD1T ,
                      ekpo.ebelp ,
                      EKPO.REPOS ,
                      ZINW_T_HDR.QR_CODE  ,
                      ZINW_T_HDR.NAME1 ,
                      ZINW_T_HDR.STATUS ,
                      ZINW_T_HDR.SOE ,
                      ZINW_T_HDR.MBLNR_103 ,
                      ZINW_T_HDR.MBLNR ,
*ZINW_T_HDR.GRPO_NO ,
                      ZINW_T_STATUS.CREATED_DATE ,
                      ZINW_T_HDR.INWD_DOC ,
                      ZINW_T_HDR.REC_DATE ,
                      ZINW_T_ITEM.MATNR ,
                      ZINW_T_ITEM.MATKL ,
                      ZINW_T_ITEM.NETPR_P ,
                      ZINW_T_ITEM.NETwr_p + ZINW_T_ITEM.NETPR_GP as NETwr_p ,
                      ZINW_T_ITEM.NETPR_GP  ,
                      ZINW_T_ITEM.MENGE_P ,
                      due_date

                    /*  EKBE.VGABE ,
                      EKBE.BEWTP   */
                      from  ZINW_T_HDR as  ZINW_T_HDR
                      inner join ekko as ekko on ekko.ebeln =  ZINW_T_HDR.ebeln
                      INNER  join ekpo as ekpo on ekpo.ebeln = ekko.ebeln
                      inner JOIN ZINW_T_STATUS as ZINW_T_STATUS on ZINW_T_STATUS.qr_code =  ZINW_T_HDR.QR_CODE
                      inner join ZINW_T_item as ZINW_T_item on ZINW_T_item.qr_code = ZINW_T_HDR.QR_CODE and ZINW_T_item.ebeln = ZINW_T_HDR.ebeln and ZINW_T_item.ebelp = ekpo.ebelp
                      where  ZINW_T_STATUS.STATUS_VALUE = 'QR04'
                      and ekko.BSART in ( 'ZLOP' , 'ZOSP' , 'ZTAT' )
                      and  ZINW_T_HDR.Soe != ' '   ;
                     /* and ekpo.REPOS != 'X'    ZINW_T_STATUS.created_date BETWEEN lv_date and lv_date1 and     ; */



 endmethod .

ENDCLASS.
