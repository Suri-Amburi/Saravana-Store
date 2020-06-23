FUNCTION zfm_purchase_form1.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LV_EBELN) TYPE  EKKO-EBELN
*"     VALUE(REG_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(RETURN_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(TATKAL_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(PRINT_PRIEVIEW) TYPE  CHAR1 OPTIONAL
*"     VALUE(SERVICE_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(VENDOR_RETURN_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(VENDOR_DEBIT_NOTE) TYPE  CHAR1 OPTIONAL
*"----------------------------------------------------------------------
  """"VENDOR RETURN FORM STARTS FROM LINE NO 2856"""""""
  "
  IF lv_ebeln IS NOT INITIAL.
    TYPES : BEGIN OF ty_ekpo,
              ebeln          TYPE ekpo-ebeln,
              ebelp          TYPE ekpo-ebelp,
              menge          TYPE ekpo-menge,
              werks          TYPE ekpo-werks,
              matnr          TYPE ekpo-matnr,
              meins          TYPE ekpo-meins,
              matkl          TYPE ekpo-matkl,
              netpr          TYPE ekpo-netpr,
              netwr          TYPE ekpo-netwr,
              ean11          TYPE ekpo-ean11,    " ADDED ON (11-4-20)
              zzstyle        TYPE   ekpo-zzstyle,  " ADDED ON (11-4-20)
              zzcolor        TYPE ekpo-zzcolor,    " ADDED ON (11-4-20)
*              MENGE          TYPE EKPO-MENGE,
*             NETPR
              zzset_material TYPE ekpo-zzset_material,
              wrf_charstc2   TYPE ekpo-wrf_charstc2,
              zztext100      TYPE ztext,
            END OF ty_ekpo.
    DATA : i_addrnumber  TYPE adr6-smtp_addr .
*    TYPES : BEGIN OF TY_EKPO_P,
*              EBELN          TYPE EKPO-EBELN,
*              EBELP          TYPE EKPO-EBELP,
*              MENGE          TYPE EKPO-MENGE,
*              WERKS          TYPE  EKPO-WERKS,
*              MATNR          TYPE  EKPO-MATNR,
*              MEINS          TYPE EKPO-MEINS,
*              MATKL          TYPE EKPO-MATKL,
*              NETPR          TYPE  EKPO-NETPR,
*              ZZSET_MATERIAL TYPE EKPO-ZZSET_MATERIAL,
*              WRF_CHARSTC2   TYPE EKPO-WRF_CHARSTC2,
*
*            END OF TY_EKPO_P.

***********************START OF DECLARATION RETURN PO**********************************************
    TYPES: BEGIN OF ty_ekpo_pr,
             ebeln TYPE ebeln,                              "Purchasing Document Number
             ebelp TYPE ebelp,                              "Item Number of Purchasing Document
             werks TYPE ewerk,                              "Plant
             matnr TYPE matnr,                              "Material Number
             mwskz TYPE mwskz,                              "Tax on Sales/Purchases Code
             menge TYPE bstmg,                              "Purchase Order Quantity
             netpr TYPE bprei,                              "Net Price in Purchasing Document (in Document Currency)
             peinh TYPE epein,                              "Price unit
             netwr TYPE bwert,                              "Net Order Value in PO Currency
             bukrs TYPE bukrs,
             retpo TYPE retpo,
             ean11 TYPE ean11,
           END OF ty_ekpo_pr.

    TYPES: BEGIN OF ty_ekko_pr,
             ebeln TYPE ebeln,                               "Purchasing Document Number

             bsart TYPE esart,
*             ERNAM TYPE ERNAM,
             aedat TYPE erdat,
             ernam TYPE ernam,
             lifnr TYPE elifn,                               "Vendor's account number
             bedat TYPE ebdat,                               "Purchasing Document Date
             knumv TYPE	knumv,                               "Number of the Document Condition
           END OF ty_ekko_pr.

    TYPES: BEGIN OF ty_t001w_pr,
             werks TYPE werks_d,                            "Plant
             name1 TYPE name1,                              "Name
             stras TYPE stras,                              "Street and House Number
             ort01 TYPE ort01,                              "City
             land1 TYPE land1,                              "Country Key
             adrnr TYPE adrnr,
           END OF ty_t001w_pr.

    TYPES: BEGIN OF ty_lfa1_pr,
             lifnr TYPE lifnr,                                "Account Number of Vendor or Creditor
             land1 TYPE land1_gp,                             "Country Key
             name1 TYPE name1_gp,                             "Name 1
             ort01 TYPE ort01_gp,                             "City
             regio TYPE regio,                                "Region (State, Province, County)
             stras TYPE stras_gp,                             "Street and House Number
             stcd3 TYPE stcd3,                                "Tax Number 3
             adrnr TYPE adrnr,
           END OF ty_lfa1_pr.

    TYPES: BEGIN OF ty_makt_pr,
             matnr TYPE matnr,                                "Material Number
             spras TYPE spras,                                "Language Key
             maktx TYPE maktx,                                "Material description
           END OF ty_makt_pr.

    TYPES: BEGIN OF ty_konv_pr,
             knumv TYPE knumv,                                "Number of the Document Condition
             kposn TYPE kposn,                                "Condition item number
             stunr TYPE stunr,                                "Step Number
             zaehk TYPE dzaehk,                               "Condition Counter
             kschl TYPE kscha,                                "Condition type
           END OF ty_konv_pr.

    TYPES: BEGIN OF ty_mseg_pr,
             ebeln TYPE ebeln,
             ebelp TYPE ebelp,
             mblnr TYPE mblnr,                                "RETURN NO./DOCUMENT NO.
             charg TYPE charg_d,                     " added on(17-3-20) for barcode field
             matnr TYPE matnr,
           END OF ty_mseg_pr,

           BEGIN OF ty_ekbe,
             ebeln TYPE ebeln,
             ebelp TYPE ebelp,
             belnr TYPE mblnr,
             bewtp TYPE bewtp,
           END OF ty_ekbe.


***********           ADDED ON(17-3-20) FOR SELLING PRICE IN RETURN    **********
    TYPES : BEGIN OF ty_a511,
              kappl TYPE kappl,
              kschl TYPE kscha,
              matnr TYPE matnr,
              charg TYPE charg_d,
              datbi TYPE kodatbi,
              knumh TYPE knumh,
            END OF ty_a511,

            BEGIN OF ty_konp_pr ,
              knumh TYPE knumh,
              kopos TYPE kopos,
              kschl TYPE kscha,
              kbetr TYPE kbetr_kond,
            END OF ty_konp_pr.



********************           END(17-3-20)   *********************

    TYPES: BEGIN OF ty_mkpf_pr,
             mblnr TYPE mblnr,
             bldat TYPE bldat,                                  " DOCUMENT DATE
           END OF ty_mkpf_pr.

    TYPES: BEGIN OF ty_j_1bbranch_pr,
             bukrs TYPE bukrs,                                  "COMPANY CODE
             gstin TYPE j_1igstcd3,                             "GST NO
           END OF ty_j_1bbranch_pr.

    TYPES: BEGIN OF ty_adr6_pr,
             addrnumber TYPE ad_addrnum,
             smtp_addr  TYPE ad_smtpadr,
           END OF ty_adr6_pr.

    TYPES: BEGIN OF ty_zinw_t_hdr_pr,
             qr_code    TYPE zqr_code,
             ebeln      TYPE ebeln,
             trns       TYPE ztrans,                               "TRANSPORTER
             lr_no      TYPE zlr,                                   "LR NO
             bill_num   TYPE zbill_num,                             "vendor invoice number
             bill_date  TYPE zbill_dat,                            "vendor invoice date
             act_no_bud TYPE zno_bud,
             mblnr      TYPE mblnr,
             mblnr_103  TYPE mblnr,
             return_po  TYPE ebeln,
           END OF ty_zinw_t_hdr_pr.

    TYPES: BEGIN OF ty_kna1_pr,
             adrnr TYPE adrnr,                                    "PLANT ADDRESS NO
             name1 TYPE name1_gp,                                 "PLANT NAME
             sortl TYPE sortl,                                    "PLANT AREA
           END OF ty_kna1_pr.

*TYPES: BEGIN OF TY_MEPO1211,
*        MATNR TYPE MATNR,
*        RETPO TYPE RETPO,                                     "RETURN ITEMS
*        END OF TY_MEPO1211.
    TYPES : BEGIN OF ty_adrc_pr,
              addrnumber TYPE  adrc-addrnumber,
              name1      TYPE adrc-name1,
              city1      TYPE adrc-city1,
              street     TYPE adrc-street,
              str_suppl1 TYPE adrc-str_suppl1,
              str_suppl2 TYPE adrc-str_suppl2,
              country    TYPE adrc-country,
              langu      TYPE adrc-langu,
              region     TYPE adrc-region,
              post_code1 TYPE adrc-post_code1,
            END OF ty_adrc_pr.

    TYPES :BEGIN OF ty_t005u_pr,
             spras TYPE t005u-spras,
             land1 TYPE t005u-land1,
             bland TYPE t005u-bland,
             bezei TYPE t005u-bezei,
           END OF ty_t005u_pr.

    TYPES : BEGIN OF ty_t005t_pr,
              spras TYPE spras,
              land1 TYPE land1,
              landx TYPE landx,
            END OF ty_t005t_pr.

    TYPES : BEGIN OF ty_ekbe_pr,
              ebeln TYPE ebeln,
              vgabe TYPE vgabe,
              belnr TYPE mblnr,
              budat TYPE budat,
            END OF ty_ekbe_pr.

    TYPES : BEGIN OF ty_zinw_t_item_pr,
              qr_code  TYPE   zinw_t_item-qr_code,
              ebeln    TYPE   zinw_t_item-ebeln,
              matnr    TYPE   zinw_t_item-matnr,
              werks    TYPE   zinw_t_item-werks,
              steuc    TYPE  zinw_t_item-steuc,
              netpr_gp TYPE zinw_t_item-netpr_gp,
            END OF ty_zinw_t_item_pr.


    TYPES : BEGIN OF ty_zinw_t_status_pr,
              inwd_doc     TYPE zinwd_doc,
              qr_code      TYPE zqr_code,
              status_field TYPE zstatus_field,
              status_value TYPE zstatus_value,
              description  TYPE zdescription,
              created_date TYPE erdat,
              created_time TYPE erzet,
              created_by   TYPE ernam,
            END OF ty_zinw_t_status_pr.

    TYPES : BEGIN OF ty_mara,
              matnr TYPE mara-matnr,
              ean11 TYPE mara-ean11,
            END OF ty_mara.

    TYPES  : BEGIN OF ty_ekko,
               ebeln           TYPE ekko-ebeln,
               bsart           TYPE ekko-bsart,
               ekgrp           TYPE ekko-ekgrp,
               bukrs           TYPE ekko-bukrs,
               aedat           TYPE ekko-aedat,
               bedat           TYPE ekko-bedat,
               lifnr           TYPE ekko-lifnr,
               user_name       TYPE ekko-user_name,
               ernam           TYPE ekko-ernam,
               zindent         TYPE ekko-zindent,
               zzcategory_type TYPE zcat_type,                            " ADDED ON (10-6-20)
             END OF ty_ekko,

             BEGIN OF ty_t024,
               ekgrp TYPE t024-ekgrp,
               eknam TYPE t024-eknam,
             END OF ty_t024.

*            BEGIN OF TY_T023,
*               MATKL TYPE T023-MATKL,
*               WGBEZ TYPE T023-WGBEZ,
*               WGBEZ60 TYPE T023-WGBEZ60,
*              END OF TY_T023.



    DATA : wa_zinw_t_status_pr TYPE ty_zinw_t_status_pr.
    DATA: it_ekko_pr        TYPE TABLE OF ty_ekko_pr,
          it_ekko1_pr       TYPE TABLE OF ty_ekko_pr,
          wa_ekko_pr        TYPE ty_ekko_pr,
          wa_ekko1_pr       TYPE ty_ekko_pr,
          it_ekpo_pr        TYPE  TABLE OF  ty_ekpo_pr,
          wa_ekpo_pr        TYPE ty_ekpo_pr,
          it_ekbe           TYPE  TABLE OF ty_ekbe,
          it_t024           TYPE TABLE OF ty_t024,
          wa_t024           TYPE ty_t024,
          wa_ekbe           TYPE ty_ekbe,
          it_t001w_pr       TYPE TABLE OF ty_t001w_pr,
          wa_t001w_pr       TYPE ty_t001w_pr,
          wa_t005u_pr       TYPE ty_t005u_pr,
          wa_t005u1_pr      TYPE ty_t005u_pr,
          wa_t005t_pr       TYPE ty_t005t_pr,
          wa_t005t1_pr      TYPE ty_t005t_pr,
          wa_adrc_pr        TYPE ty_adrc_pr,
          wa_adrc1_pr       TYPE ty_adrc_pr,
          it_lfa1_pr        TYPE TABLE OF ty_lfa1_pr,
          wa_lfa1_pr        TYPE ty_lfa1_pr,
          wa_ekbe_pr        TYPE ty_ekbe_pr,
          it_makt_pr        TYPE TABLE OF ty_makt_pr,
          wa_makt_pr        TYPE ty_makt_pr,
          it_konv_pr        TYPE TABLE OF ty_konv_pr,
          wa_konv_pr        TYPE ty_konv_pr,
          it_mseg_pr        TYPE TABLE OF ty_mseg_pr,
          wa_mseg_pr        TYPE ty_mseg_pr,
          it_mkpf_pr        TYPE TABLE OF ty_mkpf_pr,
          wa_mkpf_pr        TYPE ty_mkpf_pr,
          it_j_1bbranch_pr  TYPE TABLE OF ty_j_1bbranch_pr,
          wa_j_1bbranch_pr  TYPE ty_j_1bbranch_pr,
          it_adr6_pr        TYPE TABLE OF ty_adr6_pr,
          wa_adr6_pr        TYPE ty_adr6_pr,
          it_zinw_t_hdr_pr  TYPE TABLE OF ty_zinw_t_hdr_pr,
          wa_zinw_t_hdr_pr  TYPE ty_zinw_t_hdr_pr,
          it_kna1_pr        TYPE TABLE OF ty_kna1_pr,
          it_zinw_t_item_pr TYPE TABLE OF ty_zinw_t_item_pr,
          wa_kna1_pr        TYPE ty_kna1_pr,
          wa_item_pr        TYPE ty_zinw_t_item_pr,
          it_mara_pr        TYPE TABLE OF ty_mara,
          it_konp_pr        TYPE TABLE OF ty_konp_pr,
          wa_konp_pr        TYPE ty_konp_pr,
*      IT_MEPO1211   TYPE TABLE OF TY_MEPO1211,
*      WA_MEPO1211   TYPE TY_MEPO1211,
          it_final          TYPE TABLE OF zpurchase_final,
          wa_final          TYPE zpurchase_final,
          wa_header         TYPE zpurchase_header.

    DATA: fm_name  TYPE  rs38l_fnam.
    DATA: lv_sl(03)  TYPE  i VALUE 0.
    DATA : t_final TYPE TABLE OF zservice_item,
           w_final TYPE zservice_item,
           wa_hdr  TYPE zser_hdr.

    DATA : sl_no TYPE i VALUE 1.
*           LV_TOT  TYPE SNETWR.
*DATA: lv_ebeln TYPE ekko-ebeln.
*** Types declaration for EKKO table
    TYPES: BEGIN OF ty_hdr,
             ebeln   TYPE ebeln,
             qr_code TYPE zqr_code,
           END OF ty_hdr.

*** Types declaration for EKPO table
*TYPES: BEGIN OF TY_ITEM,
*         QR_CODE TYPE    ZQR_CODE,
*         EBELN   TYPE    EBELN,
*         EBELP   TYPE    EBELP,
*         MATNR   TYPE    MATNR,
*         LGORT   TYPE    LGORT_D,
*         WERKS   TYPE    EWERK,
*         MAKTX   TYPE    MAKTX,
*         MATKL   TYPE    MATKL,
*         MENGE_P TYPE    ZMENGE_P,
*         MEINS   TYPE    BSTME,
*       END OF TY_ITEM.

*** Types declaration for Output data structure
    TYPES: BEGIN OF ty_det,
             ebeln       TYPE ebeln,
             mblnr       TYPE mblnr,
             mjahr       TYPE mjahr,
             msg_type(1),
             message     TYPE bapiret2-message,
           END OF ty_det.

*** Internal Tables Declaration
    DATA: lt_hdr  TYPE STANDARD TABLE OF ty_hdr,
          lt_item TYPE STANDARD TABLE OF zinw_t_item,
          lt_det  TYPE STANDARD TABLE OF ty_det.

*** Work area Declarations
    DATA:
          wa_det  TYPE ty_det.

*** BAPI Structure Declaration
    DATA:
      wa_gmvt_header  TYPE bapi2017_gm_head_01,
      wa_gmvt_item    TYPE bapi2017_gm_item_create,
      wa_gmvt_headret TYPE bapi2017_gm_head_ret,
      lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
      lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create.
    FIELD-SYMBOLS :
      <ls_bapiret> TYPE bapiret2.

    DATA :lv_hed(15)  TYPE c,
          lv_val(15)  TYPE c,
          lv_code(20) TYPE c,
          lv_per      TYPE kbetr,
          lv_tax(6)   TYPE c,
*          LV_PER     TYPE char100,
          lv_s(01)    TYPE c VALUE '/'.


    DATA : po_lines        TYPE TABLE OF tline WITH HEADER LINE,
           po_text         TYPE thead-tdname,
           lv_po_text(100) TYPE c.
**************************END OF PO RETURN TYPES*********************************************************
******************START OF DECLARATION PO CREATE***********************************************************
    TYPES : BEGIN OF ty_makt ,
              matnr TYPE makt-matnr,
              maktx TYPE makt-maktx,
            END OF ty_makt .
    DATA: wa_ekko          TYPE ty_ekko, "ekko,
          lv_adrc          TYPE ad_addrnum,
          lv_ven           TYPE adrnr,
          lv_shp           TYPE adrnr,
          lv_adrc1         TYPE adrnr,
          lv_adrc2         TYPE adrnr,
          it_poitem        TYPE TABLE OF zpoitem,
          wa_poitem        TYPE zpoitem,
          wa_poheader      TYPE zpoheader,
*          WA_LFA1       TYPE LFA1,
          it_ekko          TYPE TABLE OF ty_ekko, "ekko,

          it_ekko_p        TYPE TABLE OF ekko,
*          IT_EKPO_P        TYPE TABLE OF TY_EKPO,
          it_ekpo_p        TYPE TABLE OF ty_ekpo,
          wa_ekpo_p        TYPE  ty_ekpo,
          wa_ekko_p        TYPE  ekko,
          it_zinw_t_item_p TYPE TABLE OF zinw_t_item,
          wa_zinw_t_item_p TYPE  zinw_t_item,
*          WA_EKPO_P        TYPE  TY_EKPO,
          wa_zinw_t_hdr    TYPE zinw_t_hdr,
*          WA_EKKO TYPE EKKO,
          it_ekpo          TYPE TABLE OF ty_ekpo,
          it_ekpo1         TYPE TABLE OF ty_ekpo,
          wa_ekpo          TYPE  ty_ekpo,
          wa_ekpo_set      TYPE  ty_ekpo,
          wa_ekpo1         TYPE  ty_ekpo,
*          WA_ADRC       TYPE ADRC,
          it_mara          TYPE TABLE OF mara,
          wa_mara          TYPE  mara,
          it_makt          TYPE TABLE OF ty_makt,
          it_makt_t        TYPE TABLE OF ty_makt,
          wa_makt          TYPE ty_makt,
          wa_makt_t        TYPE ty_makt,
          lv_words(100)    TYPE c,
          it_o_wgh01       TYPE TABLE OF wgh01,
          wa_o_wgh01       TYPE wgh01,

          it_a511          TYPE TABLE OF ty_a511,
          wa_a511          TYPE ty_a511.
    DATA : lv_poitem TYPE ebelp.
*************************END OF DECLARATION OF PO_CREATE****************************************************************************
*********************************MAIL**************************************************************************************************
    DATA  : fmname TYPE rs38l_fnam.
    DATA  : fmname1 TYPE rs38l_fnam.
*    DATA  : FM_NAME TYPE RS38L_FNAM.
    DATA : send_request            TYPE REF TO cl_bcs,
           v_send_request          TYPE REF TO cl_sapuser_bcs,
           document                TYPE REF TO cl_document_bcs,
           recipient               TYPE REF TO if_recipient_bcs,
           i_sender                TYPE REF TO if_sender_bcs,
           bcs_exception           TYPE REF TO cx_bcs,
           main_text               TYPE bcsy_text,
           main_text1              TYPE bcsy_text,
           ls_main_text            LIKE LINE OF main_text,
           ls_main_text1           LIKE LINE OF main_text,
           ls_text                 TYPE so_text255,
           ls_text1                TYPE so_text255,
           ls_text2                TYPE so_text255,
           ls_text3                TYPE so_text255,
           binary_content          TYPE solix_tab,
           size                    TYPE so_obj_len,
           sent_to_all             TYPE os_boolean,
           subject                 TYPE sood-objdes,
           i_sub                   TYPE so_obj_des,
           u,
*           FMNAME                  TYPE RS38L_FNAM,
           ls_outputop             TYPE ssfcompop,
           lt_pdf_data             TYPE solix_tab,
           lt_pdf_data1            TYPE solix_tab,
           lt_pdf_data2            TYPE solix_tab,
           lt_pdf_data3            TYPE solix_tab,
           lt_pdf_data4            TYPE solix_tab,
           lt_mail_body            TYPE soli_tab,
           lt_objtext              TYPE TABLE OF solisti1,
           lt_objpack              TYPE TABLE OF sopcklsti1,
           lt_lines                TYPE TABLE OF tline,
           lt_lines1               TYPE TABLE OF tline,
           lt_lines2               TYPE TABLE OF tline,
           lt_lines3               TYPE TABLE OF tline,
           lt_lines4               TYPE TABLE OF tline,
           lt_record               TYPE TABLE OF solisti1,
           lt_otf                  TYPE tsfotf,
           lt_otf1                 TYPE tsfotf,
           lt_otf2                 TYPE tsfotf,
           lt_otf3                 TYPE tsfotf,
           lt_otf4                 TYPE tsfotf,
           lt_mail_sender          TYPE bapiadsmtp_t,
           lt_mail_recipient       TYPE bapiadsmtp_t,
           ls_ctrlop               TYPE ssfctrlop,
           is_control_parameters   TYPE ssfctrlop,
           is_output_options       TYPE ssfcompop,
           ls_document_output_info TYPE ssfcrespd,
           ls_job_output_info      TYPE ssfcrescl,
           ls_job_output_options   TYPE ssfcresop,
           lv_otf                  TYPE xstring,
           lv_otf1                 TYPE xstring,
           lv_otf2                 TYPE xstring,
           lv_otf3                 TYPE xstring,
           lv_otf4                 TYPE xstring,
           ls_bin_filesize         TYPE sood-objlen,
           ls_bin_filesize1        TYPE sood-objlen,
           ls_bin_filesize2        TYPE sood-objlen,
           ls_bin_filesize3        TYPE sood-objlen,
           ls_bin_filesize4        TYPE sood-objlen,
*           WA_ITOB                 TYPE ITOB,
           lv_doc_subject          TYPE sood-objdes,
           lv_doc_subject1         TYPE sood-objdes,
           lv_doc_subject2         TYPE sood-objdes,
           lv_doc_subject3         TYPE sood-objdes,
           lv_doc_subject4         TYPE sood-objdes,
           lt_reclist              TYPE bcsy_smtpa,
           ls_reclist              TYPE  ad_smtpadr,
*           LS_SMAIL                TYPE ZSALES_EMAIL,
           i_address_string        TYPE adr6-smtp_addr,
           es_msg(100)             TYPE c.
    DATA : lv_a       TYPE c,
           lv_b       TYPE c,
           lv_c       TYPE c,
           lv_del     TYPE sy-datum,
           lv_del1    TYPE sy-datum,
           lv_gstin_v TYPE stcd3,
           lv_gstin_c TYPE stcd1,
           lv_pdate   TYPE t5a4a-dlydy.
    DATA : lv_name   TYPE thead-tdname,
           lv_name1  TYPE thead-tdname,
           lv_name2  TYPE thead-tdname,
           lv_name3  TYPE thead-tdname,
           it_lines  TYPE TABLE OF tline WITH HEADER LINE,
           it_lines2 TYPE TABLE OF tline WITH HEADER LINE,
           it_lines3 TYPE TABLE OF tline WITH HEADER LINE,
           set(03)   VALUE 'SET'.
    DATA :lv_billd      TYPE zbill_dat,
          lv_rpo        TYPE ebeln,
          lv_ername(12) TYPE c.
    DATA :  po_qr  TYPE ebeln.
    DATA: lv_werks TYPE name1.

***************************************************END OF MAIL****************************************************************************************
******************************************************GET DATA OF PO CREATION***************************************************************************
*    IF LV_EBELN IS NOT INITIAL.
*    "
*******************commented on (11-4-20)  ***************** indent values not picking
**    SELECT ekko~ebeln ,
**           ekko~ekgrp ,
**           ekko~bukrs ,
**           ekko~aedat ,
**           ekko~bedat ,
**           ekko~lifnr ,
**           ekko~user_name ,
**           ekko~ernam ,
**           ekko~zindent FROM ekko  INTO  CORRESPONDING FIELDS OF TABLE @it_ekko
**                        WHERE ebeln = @lv_ebeln .
*********************end(11-4-20)  ********************
********************added on (11-4-20)   ****************
    SELECT  ebeln
            bsart
            ekgrp
            bukrs
            aedat
            bedat
            lifnr
            user_name
            ernam
            zindent
            zzcategory_type FROM ekko INTO CORRESPONDING FIELDS OF TABLE it_ekko  WHERE ebeln = lv_ebeln ."AND BSART NE 'NB'.


    SELECT ekgrp
              eknam FROM t024 INTO TABLE it_t024
         FOR ALL ENTRIES IN it_ekko
            WHERE ekgrp = it_ekko-ekgrp.




***********************end(11-4-20)  ****************
*    ENDIF.
    READ TABLE it_ekko INTO wa_ekko INDEX 1.
    IF wa_ekko IS NOT INITIAL.
      SELECT SINGLE
        lfa1~name1,
        lfa1~adrnr ,
        lfa1~werks ,
        lfa1~stcd3 ,
        lfa1~lifnr INTO @DATA(wa_lfa1) FROM lfa1 WHERE lifnr = @wa_ekko-lifnr.
      SELECT
        ekpo~ebeln ,
        ekpo~ebelp ,
        ekpo~menge ,
        ekpo~werks ,
        ekpo~matnr ,
        ekpo~meins ,
        ekpo~matkl ,
        ekpo~netpr ,
        ekpo~netwr ,
        ekpo~ean11,
*        EKPO~ZZCOLOR,
        ekpo~zzstyle,
        ekpo~zzcolor,
        ekpo~zzset_material  ,
        ekpo~wrf_charstc2 ,
        ekpo~zztext100 FROM ekpo INTO TABLE  @it_ekpo WHERE ebeln = @lv_ebeln ."AND ZZSET_MATERIAL = '128703-7-8-9-10'.






*********************************ADDED ON 12.03.2020 SKN*********************
BREAK CLIKHITHA.
      IF it_ekpo IS NOT INITIAL.
        SELECT a~matnr,
               b~kbetr,
               a~knumh INTO TABLE @DATA(it_data)
               FROM  a515 AS a
               INNER JOIN konp AS b ON a~knumh = b~knumh
               FOR ALL ENTRIES IN @it_ekpo
               WHERE a~matnr = @it_ekpo-matnr
               AND   a~kschl = 'ZMRP'
               AND   a~datbi GE @sy-datum.


      ENDIF.
*****************************************************************************
    ENDIF.
*    READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
    READ TABLE it_ekpo INTO wa_ekpo WITH KEY ebeln = lv_ebeln.
    IF sy-subrc = 0.
      SELECT SINGLE name1 FROM t001w INTO lv_werks WHERE werks = wa_ekpo-werks.
    ENDIF.

    IF it_ekpo IS NOT INITIAL.
      SELECT SINGLE t001w~adrnr  FROM t001w INTO @DATA(lv_padrnr) WHERE werks = @wa_ekpo-werks.
      SELECT SINGLE lfa1~stcd3   FROM lfa1 INTO @wa_poheader-gstinp WHERE werks = @wa_ekpo-werks.
      SELECT matnr maktx   FROM makt INTO TABLE it_makt FOR ALL ENTRIES IN it_ekpo WHERE matnr = it_ekpo-zzset_material.
    ENDIF.


    IF wa_ekko IS NOT INITIAL.
      SELECT SINGLE t001~bukrs , t001~adrnr FROM t001 INTO @DATA(wa_t001) WHERE bukrs = @wa_ekko-bukrs.
      SELECT SINGLE j_1bbranch~bukrs, j_1bbranch~gstin FROM j_1bbranch INTO @DATA(wa_j_1bbranch) WHERE bukrs = @wa_ekko-bukrs.
      SELECT SINGLE eknam FROM t024 INTO @DATA(lv_group) WHERE ekgrp = @wa_ekko-ekgrp .
*        SELECT EKGRP EKNAM FROM T024 INTO TABLE IT_T024 FOR ALL ENTRIES IN IT_EKKO WHERE ekgrp = wa_ekko-ekgrp .
    ENDIF.
    lv_adrc = wa_lfa1-adrnr.
    lv_adrc1 = lv_padrnr.
    lv_adrc2 = lv_padrnr.

*    ENDIF.
*    "
    SELECT mara~matnr  mara~matkl  mara~zzpo_order_txt  mara~size1 mara~color ean11 FROM mara INTO CORRESPONDING FIELDS OF TABLE it_mara FOR ALL ENTRIES IN it_ekpo WHERE matnr = it_ekpo-matnr .
    SELECT t023t~matkl , t023t~wgbez , t023t~wgbez60 FROM t023t INTO TABLE @DATA(it_t023t) FOR ALL ENTRIES IN @it_ekpo WHERE matkl = @it_ekpo-matkl.
*    SELECT * FROM MAKT INTO TABLE IT_MAKT
*      FOR ALL ENTRIES IN PO_ITEM
*      WHERE MATNR = PO_ITEM-MATNR AND SPRAS EQ SY-LANGU.
    IF it_mara IS NOT INITIAL.
      SELECT makt~matnr ,
             makt~maktx   FROM makt INTO TABLE @DATA(it_makt1) FOR ALL ENTRIES IN @it_mara WHERE matnr = @it_mara-matnr.
    ENDIF.

    wa_poheader-ad_name = wa_lfa1-name1.
    wa_poheader-lifnr = wa_lfa1-lifnr.
    wa_poheader-aedat =  wa_ekko-aedat  .

*    IF WA_EKKO-USER_NAME IS INITIAL.
    wa_poheader-zuname = wa_ekko-user_name."wa_ekko-ernam.
    wa_poheader-prepared = wa_ekko-ernam.
*    ELSE.
*      LV_ERNAME  =  WA_EKKO-ERNAM.
*    ENDIF.
*    WA_POHEADER-ZUNAME = WA_EKKO-USER_NAME.
    lv_gstin_v = wa_lfa1-stcd3.
    lv_gstin_c = wa_j_1bbranch-gstin.
*    BREAK BREDDY .

    SELECT SINGLE eket~ebeln , eket~eindt FROM eket INTO @DATA(wa_eket) WHERE ebeln = @lv_ebeln.
    wa_poheader-del_by = wa_eket-eindt.

    SELECT stpo~stlnr,
           stpo~idnrk,
           stpo~posnr,
           stpo~menge,
           mast~matnr,
           mast~werks,
           mast~stlal,
           mara~size1
           INTO TABLE @DATA(it_size)
           FROM stpo AS stpo
           INNER JOIN mast AS mast ON stpo~stlnr = mast~stlnr
           INNER JOIN mara AS mara ON mara~matnr = stpo~idnrk
           FOR ALL ENTRIES IN @it_mara
           WHERE stpo~idnrk = @it_mara-matnr.
    DATA : lv_no TYPE char10.
    DATA : lv_netpr TYPE ekpo-netpr .
    DATA : lv_total1 TYPE ekpo-netpr .
*    CLEAR : LV_POITEM.
*****************************If material is set*******************
    "
    wa_poheader-po_qr = lv_ebeln .
*    CLEAR : SL_NO.

*    LOOP AT IT_EKPO INTO WA_EKPO.
**      "
*
*      IF WA_EKPO-ZZSET_MATERIAL IS NOT INITIAL.
*        DATA(IT_EKPO_SET) = IT_EKPO.
*        DELETE IT_EKPO_SET WHERE ZZSET_MATERIAL <> WA_EKPO-ZZSET_MATERIAL.          "" AND NETPR <> WA_EKPO-NETPR.
*        SORT IT_EKPO_SET BY ZZSET_MATERIAL   NETPR.               ""NETPR.
*        DESCRIBE TABLE IT_EKPO_SET LINES DATA(LV_LINES_SET).
*        DELETE ADJACENT DUPLICATES FROM IT_EKPO_SET COMPARING ZZSET_MATERIAL NETPR .                            ""NETPR.
*        READ TABLE IT_EKPO_SET INTO WA_EKPO_SET WITH KEY ZZSET_MATERIAL = WA_EKPO-ZZSET_MATERIAL.
*        READ TABLE IT_POITEM WITH KEY MATNR = WA_EKPO-ZZSET_MATERIAL TRANSPORTING NO FIELDS .
*        IF SY-SUBRC <> 0.
**          WA_POITEM-MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
**
**          WA_POITEM-MT_GRP = WA_EKPO_SET-MATKL.
****************ADDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
**          READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
**          IF SY-SUBRC = 0.
**            WA_POITEM-MAKTX = WA_MAKT-MAKTX .
**          ENDIF.
***************ENDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
*          LV_POITEM = LV_POITEM + 10.
*          LOOP AT IT_EKPO_SET  ASSIGNING FIELD-SYMBOL(<LS_EKPO>) WHERE  ZZSET_MATERIAL = WA_EKPO-ZZSET_MATERIAL .
*            WA_POITEM-MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
*            WA_POITEM-MT_GRP = WA_EKPO_SET-MATKL.
***************ADDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
*            READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
*            IF SY-SUBRC = 0.
*              WA_POITEM-MAKTX = WA_MAKT-MAKTX .
*            ENDIF.
**************ENDED BY BHAVANI 21.07.2019*************SET MATERIAL TEXT*****************
*
*            LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPO1>) WHERE ZZSET_MATERIAL = <LS_EKPO>-ZZSET_MATERIAL AND NETPR = <LS_EKPO>-NETPR.
**            AT NEW WRF_CHARSTC2 .
*
*
**              IF WA_POITEM-SIZE = <LS_EKPO1>-WRF_CHARSTC2.
**                IF SY-SUBRC = 0 .
*              IF WA_POITEM-SIZE IS INITIAL.
*                WA_POITEM-SIZE =  <LS_EKPO1>-WRF_CHARSTC2 .
*              ELSEIF WA_POITEM-SIZE NS <LS_EKPO1>-WRF_CHARSTC2.
*                WA_POITEM-SIZE = WA_POITEM-SIZE && '-' && <LS_EKPO1>-WRF_CHARSTC2 .
*              ENDIF.
*
**              ADD <LS_EKPO1>-MENGE TO WA_POITEM-MENGE .
*              WA_POITEM-MENGE = <LS_EKPO1>-MENGE + WA_POITEM-MENGE.
*              LV_NETPR = <LS_EKPO1>-NETPR * <LS_EKPO1>-MENGE .
*              WA_POITEM-NETAMT  =  WA_POITEM-NETAMT + LV_NETPR .
*              WA_POITEM-NETPR =   <LS_EKPO1>-NETPR  .                             ""WA_POITEM-NETPR    .      ""
*              CLEAR LV_NETPR .
**            CONCATENATE  WA_POITEM-SIZE '-'  WA_EKPO_SET-WRF_CHARSTC2  INTO  WA_POITEM-SIZE .
*              ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*              WA_POHEADER-TOTAL =  WA_POITEM-NETAMT .
*
**              ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
*
*            ENDLOOP .
**            BREAK BREDDY .
*            LV_TOTAL1 =  WA_POITEM-NETAMT + LV_TOTAL1  .
*            ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
*
*            CLEAR: WA_MARA.
*
*            READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T1>) WITH KEY MATKL = WA_EKPO-MATKL.
**          IF SY-SUBRC = 0 AND WA_POITEM-WGBEZ IS INITIAL  .
**            WA_POITEM-WGBEZ = <WA_T023T1>-WGBEZ60.
**          ENDIF.
*
*            REFRESH :IT_LINES[].
*            CLEAR LV_NAME1.
*            CONCATENATE LV_EBELN WA_EKPO_SET-EBELP INTO LV_NAME1.
*            CALL FUNCTION 'READ_TEXT'
*              EXPORTING
**               CLIENT                  = SY-MANDT
*                ID                      = 'F03'
*                LANGUAGE                = 'E'
*                NAME                    = LV_NAME1
*                OBJECT                  = 'EKPO'
**               ARCHIVE_HANDLE          = 0
**               LOCAL_CAT               = ' '
**       IMPORTING
**               HEADER                  =
**               OLD_LINE_COUNTER        =
*              TABLES
*                LINES                   = IT_LINES[]
*              EXCEPTIONS
*                ID                      = 1
*                LANGUAGE                = 2
*                NAME                    = 3
*                NOT_FOUND               = 4
*                OBJECT                  = 5
*                REFERENCE_CHECK         = 6
*                WRONG_ACCESS_TO_ARCHIVE = 7
*                OTHERS                  = 8.
*            IF SY-SUBRC <> 0.
** Implement suitable error handling here
*            ENDIF.
*            LOOP AT IT_LINES.
*              CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
*              CLEAR IT_LINES .
*            ENDLOOP.
*
*            REFRESH :IT_LINES2[].
*            CLEAR LV_NAME2.
*            CONCATENATE LV_EBELN WA_EKPO_SET-EBELP INTO LV_NAME2.
*            CALL FUNCTION 'READ_TEXT'
*              EXPORTING
**               CLIENT                  = SY-MANDT
*                ID                      = 'F07'
*                LANGUAGE                = 'E'
*                NAME                    = LV_NAME2
*                OBJECT                  = 'EKPO'
**               ARCHIVE_HANDLE          = 0
**               LOCAL_CAT               = ' '
**       IMPORTING
**               HEADER                  =
**               OLD_LINE_COUNTER        =
*              TABLES
*                LINES                   = IT_LINES2[]
*              EXCEPTIONS
*                ID                      = 1
*                LANGUAGE                = 2
*                NAME                    = 3
*                NOT_FOUND               = 4
*                OBJECT                  = 5
*                REFERENCE_CHECK         = 6
*                WRONG_ACCESS_TO_ARCHIVE = 7
*                OTHERS                  = 8.
*            IF SY-SUBRC <> 0.
** Implement suitable error handling here
*            ENDIF.
*
*
*            LOOP AT IT_LINES2.
*              CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*              CLEAR IT_LINES2 .
*            ENDLOOP.
**          CLEAR : wa_mara.
*            READ TABLE IT_MARA ASSIGNING FIELD-SYMBOL(<WA_MARA>)  WITH KEY MATNR = WA_EKPO-MATNR.
*
*            IF <WA_MARA>-EAN11 IS NOT INITIAL.
*
*              WA_POITEM-EAN11 = <WA_MARA>-EAN11.
*
*            ENDIF.
*            IF <WA_MARA>-MATKL IS NOT INITIAL .
*              CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*                EXPORTING
*                  MATKL       = <WA_MARA>-MATKL
*                  SPRAS       = SY-LANGU
*                TABLES
*                  O_WGH01     = IT_O_WGH01
*                EXCEPTIONS
*                  NO_BASIS_MG = 1
*                  NO_MG_HIER  = 2
*                  OTHERS      = 3.
*              IF SY-SUBRC <> 0.
** Implement suitable error handling here
*              ENDIF.
*            ENDIF.
*            READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
*            IF SY-SUBRC = 0.
*              WA_POHEADER-GROUP_ID = WA_O_WGH01-WWGHA.
*              CLEAR WA_O_WGH01.
*            ENDIF.
*            IF <WA_MARA>-COLOR IS NOT INITIAL.
*              WA_POITEM-COLOR = <WA_MARA>-COLOR.
*            ELSE.
*              REFRESH :IT_LINES3[].
*              CLEAR LV_NAME3.
*              CONCATENATE LV_EBELN WA_EKPO_SET-EBELP INTO LV_NAME3.
*              CALL FUNCTION 'READ_TEXT'
*                EXPORTING
**                 CLIENT                  = SY-MANDT
*                  ID                      = 'F08'
*                  LANGUAGE                = 'E'
*                  NAME                    = LV_NAME3
*                  OBJECT                  = 'EKPO'
**                 ARCHIVE_HANDLE          = 0
**                 LOCAL_CAT               = ' '
**       IMPORTING
**                 HEADER                  =
**                 OLD_LINE_COUNTER        =
*                TABLES
*                  LINES                   = IT_LINES3[]
*                EXCEPTIONS
*                  ID                      = 1
*                  LANGUAGE                = 2
*                  NAME                    = 3
*                  NOT_FOUND               = 4
*                  OBJECT                  = 5
*                  REFERENCE_CHECK         = 6
*                  WRONG_ACCESS_TO_ARCHIVE = 7
*                  OTHERS                  = 8.
*              IF SY-SUBRC <> 0.
** Implement suitable error handling here
*              ENDIF.
*
*              LOOP AT IT_LINES3.
*                CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*                CLEAR IT_LINES3 .
*              ENDLOOP.
*            ENDIF.
****          SHIFT  WA_POITEM-SIZE LEFT DELETING LEADING '-' .
*
*
*
***********added by bhavani 17.09.2019***********
*
*            IF WA_LFA1-LIFNR IS NOT INITIAL.
*              SELECT SINGLE
*                SMTP_ADDR FROM ADR6 INTO I_ADDRNUMBER WHERE ADDRNUMBER = WA_LFA1-ADRNR .
*            ENDIF.
*
***********ended by bhavani 17.09.2019***********
*
*            WA_POITEM-ZSL =  SL_NO.
*            APPEND WA_POITEM TO IT_POITEM.
*            SL_NO = SL_NO + 1.
**          LV_TOTAL1 =  WA_POITEM-NETAMT + LV_TOTAL1  .
**          ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
**          ENDLOOP.
*            CLEAR : WA_POITEM.
*          ENDLOOP .
*        ENDIF.
*
*      ELSE.
**        CLEAR : LV_TOTAL1 .
**        CLEAR : SL_NO.
***        LOOP AT IT_EKPO INTO WA_EKPO.
**        SL_NO = SL_NO + 1.
**        WA_POITEM-ZSL = SL_NO.
*        WA_POITEM-MENGE = WA_EKPO-MENGE.
*        WA_POITEM-NETPR = WA_EKPO-NETPR.
*        WA_POITEM-MT_GRP = WA_EKPO-MATKL.
*        WA_POITEM-NETAMT  = WA_EKPO-NETPR * WA_EKPO-MENGE.
*        ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*        ADD WA_POITEM-MENGE TO WA_POHEADER-TOT_QTY.
*        LV_TOTAL1  = WA_POITEM-NETAMT  + LV_TOTAL1 .
**        LV_POITEM = LV_POITEM + 10.
**        WA_POITEM-EBELP = LV_POITEM.
*        CLEAR: WA_MAKT, WA_MARA.
**        READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_PO_ITEM-MATNR .
*        READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T>) WITH KEY MATKL = WA_EKPO-MATKL.
*        IF SY-SUBRC = 0.
*          WA_POITEM-WGBEZ = <WA_T023T>-WGBEZ60.
*        ENDIF.
*        REFRESH :IT_LINES[].
*
*        CLEAR LV_NAME1.
*        CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME1.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F03'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME1
*            OBJECT                  = 'EKPO'
*          TABLES
*            LINES                   = IT_LINES[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES.
*
*          CONCATENATE IT_LINES-TDLINE WA_POITEM-REMARKS INTO WA_POITEM-REMARKS .
*          CLEAR IT_LINES .
*
*        ENDLOOP.
*
*        REFRESH :IT_LINES2[].
*
*        CLEAR LV_NAME2.
*        CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME2.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F07'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME2
*            OBJECT                  = 'EKPO'
**           ARCHIVE_HANDLE          = 0
**           LOCAL_CAT               = ' '
**       IMPORTING
**           HEADER                  =
**           OLD_LINE_COUNTER        =
*          TABLES
*            LINES                   = IT_LINES2[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES2.
*
*          CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*          CLEAR IT_LINES2 .
*
*        ENDLOOP.
*        CLEAR : WA_MARA.
*        READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = WA_EKPO-MATNR .
*        WA_POITEM-MAKTX = WA_MARA-ZZPO_ORDER_TXT .
*        IF WA_MARA-EAN11 IS NOT INITIAL.
*          WA_POITEM-EAN11 = WA_MARA-EAN11.
*        ENDIF.
*        READ TABLE IT_MAKT1 ASSIGNING FIELD-SYMBOL(<WA_MAKT1>) WITH  KEY MATNR = WA_MARA-MATNR .
**        IF SY-SUBRC = 0.
**          WA_POITEM-MAKTX = <WA_MAKT1>-MAKTX .
**        ENDIF.
*        WA_POITEM-SIZE = WA_MARA-SIZE1.
*        IF WA_MARA-COLOR IS NOT INITIAL.
*          WA_POITEM-COLOR = WA_MARA-COLOR.
*        ELSE.
*          REFRESH :IT_LINES3[].
*
*          CLEAR LV_NAME3.
*          CONCATENATE LV_EBELN WA_EKPO-EBELP INTO LV_NAME3.
*          CALL FUNCTION 'READ_TEXT'
*            EXPORTING
**             CLIENT                  = SY-MANDT
*              ID                      = 'F08'
*              LANGUAGE                = 'E'
*              NAME                    = LV_NAME3
*              OBJECT                  = 'EKPO'
**             ARCHIVE_HANDLE          = 0
**             LOCAL_CAT               = ' '
**       IMPORTING
**             HEADER                  =
**             OLD_LINE_COUNTER        =
*            TABLES
*              LINES                   = IT_LINES3[]
*            EXCEPTIONS
*              ID                      = 1
*              LANGUAGE                = 2
*              NAME                    = 3
*              NOT_FOUND               = 4
*              OBJECT                  = 5
*              REFERENCE_CHECK         = 6
*              WRONG_ACCESS_TO_ARCHIVE = 7
*              OTHERS                  = 8.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*
*
*          LOOP AT IT_LINES3.
*
*            CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*            CLEAR IT_LINES3 .
*
*          ENDLOOP.
*        ENDIF.
*        IF WA_MARA-MATKL IS NOT INITIAL.
*
*          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
*            EXPORTING
*              MATKL       = WA_MARA-MATKL
*              SPRAS       = SY-LANGU
*            TABLES
*              O_WGH01     = IT_O_WGH01
*            EXCEPTIONS
*              NO_BASIS_MG = 1
*              NO_MG_HIER  = 2
*              OTHERS      = 3.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*        ENDIF.
*
*        READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
*        IF SY-SUBRC = 0.
*          WA_POHEADER-GROUP_ID = WA_O_WGH01-WWGHA.
*          CLEAR WA_O_WGH01.
*        ENDIF.
*
*
***********added by bhavani 17.09.2019***********
*
*        IF WA_LFA1-LIFNR IS NOT INITIAL.
*          SELECT SINGLE
*            SMTP_ADDR FROM ADR6 INTO I_ADDRNUMBER WHERE ADDRNUMBER = WA_LFA1-ADRNR .
*        ENDIF.
*
***********ended by bhavani 17.09.2019********
**        "
*        WA_POITEM-ZSL =  SL_NO.
*        APPEND WA_POITEM TO IT_POITEM.
*        SL_NO = SL_NO + 1.
*        CLEAR : WA_POITEM.
*      ENDIF.
*    ENDLOOP.






******changes done by bhavani 22.11.2019*********
*IF IT_EKKO-BSART NE 'NB'.

*BREAK CLIKHITHA.
    IF it_ekko IS NOT INITIAL .
      SELECT
        zph_t_item~indent_no     ,
        zph_t_item~item          ,
        zph_t_item~vendor        ,
        zph_t_item~category_code ,
        zph_t_item~from_size     ,
        zph_t_item~to_size       ,
        zph_t_item~quantity      ,
        zph_t_item~price    ,
        zph_t_item~ztext100 ,
        zph_t_item~matnr,
        zph_t_item~color ,
        zph_t_item~style  FROM zph_t_item INTO TABLE @DATA(it_zph_t_item)
                            FOR ALL ENTRIES IN @it_ekko
                            WHERE indent_no = @it_ekko-zindent." AND BSART NE 'NB'.
    ENDIF.
*ENDIF.
***************************added on (10-6-20)
    IF it_zph_t_item IS NOT INITIAL.
      SELECT makt~matnr ,
             makt~maktx   FROM makt INTO TABLE @DATA(it_makt_l) FOR ALL ENTRIES IN @it_zph_t_item WHERE matnr = @it_zph_t_item-matnr.
    ENDIF.
*************************end(10-6-20)
    DATA :lv_text100    TYPE ztext,
          lv_priceb(11) TYPE c.
*    DATA(LT_POITEM) = IT_EKPO[] .
*    SORT LT_POITEM BY MATKL ZZTEXT100.
*    DELETE ADJACENT DUPLICATES FROM LT_POITEM COMPARING MATKL ZZTEXT100.
    SORT it_zph_t_item BY item .
*    SORT it_ekpo BY ebelp .
*    IF IT_EKKO-BSART = 'NB'.
*      ENDIF.
*    IF REG_PO NE 'X'.
****************    ADDED ON (11-4-20)
    READ TABLE it_ekko INTO DATA(wa_ek) INDEX 1." zindent = <ls_item>-indent_no .
*    IF WA_EK-BSART <> 'NB'.
***********      ADDED ON (10-6-20) for end category
    IF wa_ek-zzcategory_type = 'E'.
      lv_code = 'SST CODE'.
    ELSE.
      lv_code = 'CAT CODE'.
    ENDIF.

***************      end(10-6-20)
    IF wa_ek-bsart <> 'NB'.
*****************      END(11-4-20)  **************
      LOOP AT it_zph_t_item ASSIGNING FIELD-SYMBOL(<ls_item>).
*      READ TABLE IT_EKKO INTO DATA(WA_EK) WITH KEY zindent = <ls_item>-indent_no .
*    IF WA_EK-BSART <> 'NB'.
        wa_poheader-indent_no = <ls_item>-indent_no .
        READ TABLE it_t023t ASSIGNING FIELD-SYMBOL(<wa_t023t>) WITH KEY matkl = <ls_item>-category_code.
        IF sy-subrc = 0.
          wa_poitem-wgbez = <wa_t023t>-wgbez60.
          wa_poitem-wgbez_l = <wa_t023t>-wgbez60.
        ENDIF.
*      WA_POITEM-MENGE = <LS_ITEM>-QUANTITY.
        wa_poitem-matkl = <ls_item>-category_code.
***************************      added on (10-6-20)
        IF wa_ek-zzcategory_type = 'E'.
          wa_poitem-matkl = <ls_item>-matnr.
*        ENDIF.
        ELSE.
          wa_poitem-matkl = <ls_item>-category_code.
        ENDIF.
***********************      end(10-6-20)
        wa_poitem-netpr = <ls_item>-price.
        wa_poitem-from_size = <ls_item>-from_size.
        IF wa_ek-zzcategory_type = 'E'.
          wa_poitem-to_size = <ls_item>-from_size.
        ELSE.
          wa_poitem-to_size = <ls_item>-to_size.
        ENDIF.
*      WA_POITEM-NETPR = <LS_ITEM>-PRICE.
*      LOOP AT LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>)  WHERE MATKL = <LS_ITEM>-CATEGORY_CODE.
        lv_priceb = <ls_item>-price .
**************      added on (10-6-20) for end category
        READ TABLE it_makt_l ASSIGNING FIELD-SYMBOL(<ls_makt_l>) WITH KEY matnr = <ls_item>-matnr.
        IF sy-subrc = 0.
          IF wa_ek-zzcategory_type = 'E'.
            wa_poitem-wgbez = <ls_makt_l>-maktx.
*        ENDIF.
          ELSE.
*
            wa_poitem-wgbez = wa_poitem-wgbez_l.

          ENDIF.
        ENDIF.
  break clikhitha.
*        ******************        added on (16-6-20)
*  CLIKHITHA.
IF wa_ek-zzcategory_type = 'E'.
 READ TABLE it_data ASSIGNING FIELD-SYMBOL(<wa_EMRP>)
          WITH KEY matnr =  <ls_item>-matnr.
          IF sy-subrc = 0.
            wa_poitem-mrp = <WA_EMRP>-kbetr.
          ENDIF.
*          ENDIF.
          READ TABLE it_ekpo ASSIGNING FIELD-SYMBOL(<ls_EKPOO>) with key matnr = <ls_item>-matnr.
          if sy-subrc = 0.
            wa_poitem-ean11  = <ls_EKPOO>-ean11.
            ENDIF.
       ENDIF.
*********************end(16-6-20)
********************      end(10-6-20)
*      CONCATENATE <LS_ITEM>-CATEGORY_CODE <LS_ITEM>-FROM_SIZE <LS_ITEM>-TO_SIZE LV_PRICEB INTO LV_TEXT100 .
*      DATA(IT_ITEMQ) = IT_EKPO[] .
*      SORT IT_EKPO BY EBELP MATKL ZZTEXT100 .
*      DELETE ADJACENT DUPLICATES FROM IT_EKPO  COMPARING MATKL ZZTEXT100 .
*      LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPOITEM1>) WHERE ZZTEXT100 = . "WHERE MATKL = <LS_POITEM>-MATKL AND ZZTEXT100 = <LS_POITEM>-ZZTEXT100.
*     if  it_zph_t_item IS INITIAL.     " added on (11-4-20)

        READ TABLE it_ekpo ASSIGNING FIELD-SYMBOL(<ls_color>) WITH KEY matkl = <ls_item>-category_code zztext100 = <ls_item>-ztext100 .

        IF sy-subrc = 0.

*************        added on (11-4-20)  *****************
********************        end(11-4-20)


          CLEAR : wa_mara.
          READ TABLE it_mara INTO wa_mara WITH  KEY matnr = <ls_color>-matnr .
          IF wa_mara-ean11 IS NOT INITIAL.
            wa_poitem-ean11 = wa_mara-ean11.
          ENDIF.
          READ TABLE it_makt1 ASSIGNING FIELD-SYMBOL(<wa_makt1>) WITH  KEY matnr = wa_mara-matnr .
          wa_poitem-size = wa_mara-size1.
          IF wa_mara-color IS NOT INITIAL.
            wa_poitem-color = wa_mara-color.
          ELSE .

            wa_poitem-color = <ls_item>-color .

          ENDIF.
        ENDIF.


        wa_poitem-style = <ls_item>-style .
**************************  ADDED ON (10-3-20)   ***********************************
        wa_poitem-menge = <ls_item>-quantity." + wa_poitem-menge.            " added on (10-3-20) to change  qty
        wa_poitem-g_total = wa_poitem-menge *  wa_poitem-netpr.
        lv_total1  = wa_poitem-g_total  + lv_total1 .           " added on (6-3-20) for amount in wrds

***************************   END (10-3-20)   *****************************
*   ENDIF.    " added on (11-4-20)
*    IF IT_EKKO-BSART = 'NB'.
* IF REG_PO = 'X'.

*   if  it_zph_t_item IS INITIAL.     " added on (11-4-20)
        LOOP AT it_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpoitem>) WHERE matkl = <ls_item>-category_code  AND zztext100 = <ls_item>-ztext100 .
***********        ADDED ON (11-4-20)  **********
*   WA_POITEM-MATKL = <ls_ekpoitem>-MATKL.
*  WA_POITEM-EAN11  = <ls_ekpoitem>-EAN11.
*  WA_POITEM-STYLE = <ls_ekpoitem>-ZZSTYLE.
*  WA_POITEM-COLOR = <ls_ekpoitem>-ZZCOLOR.
*  WA_POITEM-MENGE = <ls_ekpoitem>-MENGE.
*  WA_POITEM-NETPR = <ls_ekpoitem>-NETPR.
*  ENDIF.
******************END(11-4-20)  ***************
**************************************ADDED ON 12.03.2020****************************
          READ TABLE it_data ASSIGNING FIELD-SYMBOL(<skn>)
          WITH KEY matnr =  <ls_ekpoitem>-matnr.
          IF sy-subrc = 0.
            wa_poitem-mrp = <skn>-kbetr.
          ENDIF.
*******************************************************************


*       WA_POITEM-NETPR = <ls_ekpoitem>-netpr.   " added on (21-2-20)  for price
          wa_poitem-netpr = <ls_item>-price.            " ADDED ON (24-2-20)
*        wa_poitem-netamt = <ls_ekpoitem>-menge * <ls_ekpoitem>-netpr .   " COMMENETED ON (24-2-20).
          wa_poitem-netamt = <ls_item>-price.        " ADDED ON (24-2-20).

*        wa_poitem-g_total =  wa_poitem-g_total + <ls_ekpoitem>-netwr .  " ADDED ON (24-2-20)
          ADD wa_poitem-netamt TO wa_poheader-total.
          ADD wa_poitem-menge TO wa_poheader-tot_qty.
*        lv_total1  = wa_poitem-netamt  + lv_total1 .      " commenetd on (6-3-20)   for amount in wrds mistake
*        wa_poitem-menge = <ls_ekpoitem>-menge + wa_poitem-menge.       " commeneted on (10-3-20) for wrng qty


****************        commented on (10-3-20)   ********************
***        wa_poitem-menge = <LS_ITEM>-QUANTITY." + wa_poitem-menge.            " added on (10-3-20) to change  qty
***        wa_poitem-g_total = wa_poitem-menge *  wa_poitem-netpr.
***        lv_total1  = wa_poitem-g_total  + lv_total1 .           " added on (6-3-20) for amount in wrds

********************        end (10-3-20)  *********************************

*        BREAK BREDDY .

*        CLEAR: WA_MAKT, WA_MARA.

******************************************************************************

          REFRESH :it_lines[].

          CLEAR lv_name1.
          CONCATENATE lv_ebeln <ls_item>-item INTO lv_name1.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              client                  = sy-mandt
              id                      = 'F03'
              language                = 'E'
              name                    = lv_name1
              object                  = 'EKPO'
            TABLES
              lines                   = it_lines[]
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.


          LOOP AT it_lines.

            CONCATENATE it_lines-tdline wa_poitem-remarks INTO wa_poitem-remarks .
            CLEAR it_lines .

          ENDLOOP.
******************************************************************************************
*        REFRESH :IT_LINES2[].
*
*        CLEAR LV_NAME2.
*        CONCATENATE LV_EBELN <LS_ITEM>-ITEM INTO LV_NAME2.
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
**           CLIENT                  = SY-MANDT
*            ID                      = 'F07'
*            LANGUAGE                = 'E'
*            NAME                    = LV_NAME2
*            OBJECT                  = 'EKPO'
**           ARCHIVE_HANDLE          = 0
**           LOCAL_CAT               = ' '
**       IMPORTING
**           HEADER                  =
**           OLD_LINE_COUNTER        =
*          TABLES
*            LINES                   = IT_LINES2[]
*          EXCEPTIONS
*            ID                      = 1
*            LANGUAGE                = 2
*            NAME                    = 3
*            NOT_FOUND               = 4
*            OBJECT                  = 5
*            REFERENCE_CHECK         = 6
*            WRONG_ACCESS_TO_ARCHIVE = 7
*            OTHERS                  = 8.
*        IF SY-SUBRC <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        LOOP AT IT_LINES2.
*
*          CONCATENATE IT_LINES2-TDLINE WA_POITEM-STYLE INTO WA_POITEM-STYLE .
*          CLEAR IT_LINES2 .
*
*        ENDLOOP.
*
*        CLEAR : WA_MARA.
*        READ TABLE IT_MARA INTO WA_MARA WITH  KEY MATNR = <LS_EKPOITEM>-MATNR .
*        IF WA_MARA-EAN11 IS NOT INITIAL.
*          WA_POITEM-EAN11 = WA_MARA-EAN11.
*        ENDIF.
*        READ TABLE IT_MAKT1 ASSIGNING FIELD-SYMBOL(<WA_MAKT1>) WITH  KEY MATNR = WA_MARA-MATNR .
*        WA_POITEM-SIZE = WA_MARA-SIZE1.
*        IF WA_MARA-COLOR IS NOT INITIAL.
*          WA_POITEM-COLOR = WA_MARA-COLOR.
*        ELSE.
*          REFRESH :IT_LINES3[].
*
*          CLEAR LV_NAME3.
*          CONCATENATE LV_EBELN <LS_ITEM>-ITEM INTO LV_NAME3.
*          CALL FUNCTION 'READ_TEXT'
*            EXPORTING
**             CLIENT                  = SY-MANDT
*              ID                      = 'F08'
*              LANGUAGE                = 'E'
*              NAME                    = LV_NAME3
*              OBJECT                  = 'EKPO'
**             ARCHIVE_HANDLE          = 0
**             LOCAL_CAT               = ' '
**       IMPORTING
**             HEADER                  =
**             OLD_LINE_COUNTER        =
*            TABLES
*              LINES                   = IT_LINES3[]
*            EXCEPTIONS
*              ID                      = 1
*              LANGUAGE                = 2
*              NAME                    = 3
*              NOT_FOUND               = 4
*              OBJECT                  = 5
*              REFERENCE_CHECK         = 6
*              WRONG_ACCESS_TO_ARCHIVE = 7
*              OTHERS                  = 8.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*
*
*          LOOP AT IT_LINES3.
*
*            CONCATENATE IT_LINES3-TDLINE WA_POITEM-COLOR INTO WA_POITEM-COLOR .
*            CLEAR IT_LINES3 .
*
*          ENDLOOP.
*        ENDIF.




**********added by bhavani 17.09.2019***********
*
*        IF wa_lfa1-lifnr IS NOT INITIAL.
*          SELECT SINGLE
*            smtp_addr FROM adr6 INTO i_addrnumber WHERE addrnumber = wa_lfa1-adrnr .
*        ENDIF.

**********ended by bhavani 17.09.2019********
*        "



        ENDLOOP.
*      ENDIF.

*******************        added on (16-6-20)
* READ TABLE it_data ASSIGNING FIELD-SYMBOL(<wa_data>)
*          WITH KEY matnr =  <ls_ekpoitem>-matnr.
*          IF sy-subrc = 0.
*            wa_poitem-mrp = <skn>-kbetr.
*          ENDIF.
**********************end(16-6-20)
        READ TABLE it_mara INTO wa_mara INDEX 1.

        IF wa_mara-matkl IS NOT INITIAL.

          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              matkl       = wa_mara-matkl
              spras       = sy-langu
            TABLES
              o_wgh01     = it_o_wgh01
            EXCEPTIONS
              no_basis_mg = 1
              no_mg_hier  = 2
              OTHERS      = 3.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.

*      BREAK BREDDY .
        READ TABLE it_o_wgh01 INTO wa_o_wgh01 INDEX 1.
        IF sy-subrc = 0.
          wa_poheader-group_id = wa_o_wgh01-wwgha.
          CLEAR wa_o_wgh01.
        ENDIF.

*      ENDLOOP.
*      ENDLOOP.
        wa_poitem-zsl =  sl_no.


        APPEND wa_poitem TO it_poitem.
        sl_no = sl_no + 1.
        CLEAR : wa_poitem , lv_text100 , lv_priceb  .


      ENDLOOP.
***********************ADDED ON (11-4-20) ********************
    ELSE.
      READ TABLE it_t024 INTO wa_t024 INDEX 1.
      wa_poheader-group_id = wa_t024-eknam.
      BREAK clikhitha.
      LOOP AT it_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekp>) WHERE ebeln = lv_ebeln.
        IF sy-subrc = 0.
          wa_poitem-matkl = <ls_ekp>-matkl.
          wa_poitem-ean11  = <ls_ekp>-ean11.
          wa_poitem-style = <ls_ekp>-zzstyle.
          wa_poitem-color = <ls_ekp>-zzcolor.
          wa_poitem-menge = <ls_ekp>-menge.
          wa_poitem-netpr = <ls_ekp>-netpr.
        ENDIF.
        READ TABLE it_data ASSIGNING FIELD-SYMBOL(<skn1>) WITH KEY matnr =  <ls_ekp>-matnr.
*    WITH KEY matnr =  <ls_eKP>-matnr.
        IF sy-subrc = 0.
          wa_poitem-mrp = <skn1>-kbetr.
        ENDIF.
        READ TABLE it_t023t ASSIGNING FIELD-SYMBOL(<wa_t023>) WITH KEY matkl = <ls_ekp>-matkl.
        IF sy-subrc = 0.
          wa_poitem-wgbez = <wa_t023>-wgbez.
        ENDIF.
*     READ TABLE it_data ASSIGNING FIELD-SYMBOL(<skn1>)
*    WITH KEY matnr =  <ls_eKP>-matnr.
*      IF sy-subrc = 0.
*        wa_poitem-mrp = <skn1>-kbetr.
*      ENDIF.

        wa_poitem-g_total = wa_poitem-menge * wa_poitem-netpr.
        lv_total1  = wa_poitem-g_total + lv_total1.
        wa_poitem-zsl =  sl_no.
        APPEND wa_poitem TO it_poitem.
        sl_no = sl_no + 1.
*      lv_total1  = WA_POITEM-g_total.
        CLEAR : wa_poitem .
      ENDLOOP.

      DATA : lv_amt2 TYPE pc207-betrg.
      lv_amt2  = lv_total1.
      CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
        EXPORTING
          amt_in_num         = lv_amt2
        IMPORTING
          amt_in_words       = lv_words
        EXCEPTIONS
          data_type_mismatch = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
        EXPORTING
          input_string  = lv_words
        IMPORTING
          output_string = lv_words.
    ENDIF.

******************      added on (15-6-20)

    IF wa_lfa1-lifnr IS NOT INITIAL.
      SELECT SINGLE
        smtp_addr FROM adr6 INTO i_addrnumber WHERE addrnumber = wa_lfa1-adrnr .
    ENDIF.
*******************      end(15-6-20)


*******************   END(11-4-20)   *******************************
*********************ADDED ON 13.03.2020*************************
    READ TABLE it_poitem  WITH KEY from_size = 'SET' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.

      LOOP AT it_poitem ASSIGNING FIELD-SYMBOL(<itm1>) WHERE from_size = 'SET'.
        <itm1>-from_size = ' '.
        <itm1>-to_size   = ' '.
      ENDLOOP.

      DATA: lv_size TYPE char10.
      SELECT matnr,matkl FROM ekpo INTO TABLE @DATA(i_ekp) WHERE ebeln = @lv_ebeln.
      SELECT matnr,matkl,size1 FROM mara INTO TABLE @DATA(i_mar) FOR ALL ENTRIES IN @i_ekp WHERE matnr = @i_ekp-matnr.

      LOOP AT i_mar ASSIGNING FIELD-SYMBOL(<mar>).
        LOOP AT it_poitem ASSIGNING FIELD-SYMBOL(<itm>) WHERE matkl = <mar>-matkl.
          CONCATENATE <mar>-size1 <itm>-from_size INTO <itm>-from_size SEPARATED BY ','.
          CLEAR lv_size.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

*************************************************************************













    DATA : lv_amt TYPE pc207-betrg.
    lv_amt  = lv_total1.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = lv_amt
      IMPORTING
        amt_in_words       = lv_words
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        input_string  = lv_words
      IMPORTING
        output_string = lv_words.
******************************************************END OF PO CREATION**********************************************************
*****************************************SATRT OF PO RETURN DECLARATION*****************************************************************

*    "
*    if p_ebeln is INITIAL.
    SELECT SINGLE
  ebeln
  bsart
*  ERNAM
  aedat
      ernam
  lifnr
  bedat
  knumv
   FROM ekko INTO wa_ekko_pr WHERE ebeln = lv_ebeln.


    SELECT
      ebeln
      ebelp
      werks
      matnr
      mwskz
      menge
      netpr
      peinh
      netwr
      bukrs
      retpo
      ean11
      FROM ekpo INTO TABLE it_ekpo_pr WHERE ebeln = lv_ebeln AND retpo = 'X'.

    SELECT
      matnr
      ean11 FROM mara INTO TABLE it_mara_pr
            FOR ALL ENTRIES IN it_ekpo_pr
            WHERE matnr = it_ekpo_pr-matnr.

*********************ADDED ON  (18-3-20) FOR DEBIT NOTE IN RETURN PO (S)  *************************
    SELECT ebeln
           ebelp
           belnr
           bewtp FROM ekbe INTO TABLE it_ekbe
           FOR ALL ENTRIES IN it_ekpo_pr
           WHERE ebeln = it_ekpo_pr-ebeln AND ebelp = it_ekpo_pr-ebelp AND bewtp ='Q'.

    READ TABLE it_ekbe INTO wa_ekbe INDEX 1.

******************  END(18-3--20)   ************************

*      READ TABLE it_ekpo_pr INTO wa_ekpo_pr INDEX 1.
    SELECT ebeln
           ebelp
           mblnr
           charg
           matnr
           FROM mseg INTO TABLE it_mseg_pr
*         FOR ALL ENTRIES IN it_ekko_pr
           WHERE ebeln = lv_ebeln    " it_ekko_pr-ebeln
           AND   xauto = ' '.

***************     ADDED ON (17-3-20)    FOR RETURN PO SELLING PRICE  **********
    SELECT  kappl
           kschl
           matnr
           charg
           datbi
           knumh FROM a511 INTO TABLE it_a511
           FOR ALL ENTRIES IN it_mseg_pr
           WHERE charg = it_mseg_pr-charg AND kschl = 'ZKP0' AND matnr = it_mseg_pr-matnr AND datbi GE sy-datum.

    SELECT knumh
           kopos
           kschl
           kbetr FROM konp INTO TABLE it_konp_pr
           FOR ALL ENTRIES IN it_a511
           WHERE knumh = it_a511-knumh.


******************      END(17-3-20)  ************************
    READ TABLE it_ekpo_pr INTO wa_ekpo_pr INDEX 1.

    SELECT SINGLE
      ebeln
      ebelp
      mblnr
      charg                     " added on (17-3-20) for barcode field
      FROM mseg INTO wa_mseg_pr WHERE ebeln = lv_ebeln.

    IF wa_mseg_pr IS NOT INITIAL.

      SELECT SINGLE
        mblnr
        bldat
        FROM mkpf INTO wa_mkpf_pr WHERE mblnr = wa_mseg_pr-mblnr.

    ENDIF.



    IF it_ekpo_pr IS NOT INITIAL.

      SELECT * FROM a003 INTO TABLE @DATA(it_a003) FOR ALL ENTRIES IN @it_ekpo_pr WHERE mwskz = @it_ekpo_pr-mwskz.

    ENDIF.

    IF it_a003 IS NOT INITIAL.

      SELECT * FROM konp INTO TABLE @DATA(it_konp) FOR ALL ENTRIES IN @it_a003 WHERE knumh = @it_a003-knumh.

    ENDIF.

*      SELECT QR_CODE EBELN MATNR WERKS MWSKZ_P NETPR_GP FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM_PR
*                                                                  FOR ALL ENTRIES IN IT_EKPO_PR
*                                                                  WHERE MATNR = IT_EKPO_PR-MATNR AND WERKS = IT_EKPO_PR-WERKS.

*    ENDIF.

*    "
*    READ TABLE IT_ZINW_T_ITEM_PR INTO WA_ITEM_PR INDEX 1.
    IF it_ekpo_pr IS NOT INITIAL.

      SELECT
        qr_code
        ebeln
        trns
        lr_no
        bill_num
        bill_date
        act_no_bud
*      GPRO_USER
        mblnr
        mblnr_103
        return_po
        FROM zinw_t_hdr INTO TABLE it_zinw_t_hdr_pr FOR ALL ENTRIES IN it_ekpo_pr WHERE return_po = it_ekpo_pr-ebeln.
    ENDIF.

    READ TABLE it_zinw_t_hdr_pr INTO wa_zinw_t_hdr_pr INDEX 1.
    IF wa_zinw_t_hdr_pr IS NOT INITIAL.

      SELECT SINGLE
      ebeln
      bsart
      aedat
        ernam
      lifnr
      bedat
      knumv
       FROM ekko INTO wa_ekko1_pr WHERE ebeln = wa_zinw_t_hdr_pr-ebeln.

      SELECT SINGLE
        inwd_doc
        qr_code
        status_field
        status_value
        description
        created_date
        created_time
        created_by FROM zinw_t_status INTO wa_zinw_t_status_pr WHERE qr_code = wa_zinw_t_hdr_pr-qr_code .
    ENDIF.



    IF wa_ekpo_pr IS NOT INITIAL.
      SELECT SINGLE
          bukrs
          gstin
          FROM j_1bbranch INTO wa_j_1bbranch_pr WHERE bukrs = wa_ekpo_pr-bukrs.

      SELECT SINGLE
        werks
        name1
        stras
        ort01
        land1
        adrnr
        FROM t001w INTO wa_t001w_pr WHERE werks = wa_ekpo_pr-werks.

      SELECT
    matnr
    spras
    maktx
    FROM makt INTO TABLE it_makt_pr FOR ALL ENTRIES IN it_ekpo_pr WHERE matnr = it_ekpo_pr-matnr.
    ENDIF.

    IF wa_t001w_pr IS NOT INITIAL.
      SELECT SINGLE
        adrc~addrnumber,
        adrc~name1,
        adrc~city1,
        adrc~street,
        adrc~str_suppl1,
        adrc~str_suppl2,
        adrc~country,
        adrc~langu,
        adrc~region,
        adrc~post_code1
        FROM adrc INTO @wa_adrc_pr WHERE addrnumber = @wa_t001w_pr-adrnr.



      SELECT SINGLE
        addrnumber
        smtp_addr
        FROM adr6 INTO wa_adr6_pr WHERE addrnumber = wa_t001w_pr-adrnr.

      SELECT SINGLE
        adrnr
        name1
        sortl
        FROM kna1 INTO wa_kna1_pr WHERE adrnr = wa_t001w_pr-adrnr.
    ENDIF.


    IF wa_adrc_pr IS NOT INITIAL.

      SELECT SINGLE spras
             land1
             bland
             bezei FROM t005u INTO wa_t005u_pr WHERE bland = wa_adrc_pr-region AND land1 = wa_adrc_pr-country AND spras = sy-langu.
      SELECT SINGLE
             spras
             land1
             landx FROM t005t INTO wa_t005t_pr WHERE land1 = wa_adrc_pr-country AND spras = sy-langu.


    ENDIF.


    IF wa_ekko_pr IS NOT INITIAL.

      SELECT SINGLE
       lifnr
       land1
       name1
       ort01
       regio
       stras
       stcd3
       adrnr
       FROM lfa1 INTO wa_lfa1_pr WHERE lifnr = wa_ekko_pr-lifnr.

      SELECT SINGLE
              ebeln
              vgabe
              belnr
              budat FROM ekbe INTO wa_ekbe_pr WHERE ebeln = wa_ekko_pr-ebeln AND vgabe = '2'.


    ENDIF.

    SELECT
      knumv
      kposn
      stunr
      zaehk
      kschl
      FROM konv INTO TABLE it_konv_pr FOR ALL ENTRIES IN it_ekko_pr WHERE knumv = it_ekko_pr-knumv.

    IF wa_lfa1_pr IS NOT INITIAL.

      SELECT SINGLE
      adrc~addrnumber,
      adrc~name1,
      adrc~city1,
      adrc~street,
      adrc~str_suppl1,
      adrc~str_suppl2,
      adrc~country,
      adrc~langu,
      adrc~region,
      adrc~post_code1
      FROM adrc INTO @wa_adrc1_pr WHERE addrnumber = @wa_lfa1_pr-adrnr.

    ENDIF.

    IF wa_adrc1_pr IS NOT INITIAL.

      SELECT SINGLE spras
             land1
             bland
             bezei FROM t005u INTO wa_t005u1_pr WHERE bland = wa_adrc1_pr-region AND land1 = wa_adrc1_pr-country AND spras = sy-langu.
      SELECT SINGLE
             spras
             land1
             landx FROM t005t INTO wa_t005t1_pr WHERE land1 = wa_adrc1_pr-country AND spras = sy-langu.


    ENDIF.


    wa_header-city1       = wa_adrc_pr-city1.
    wa_header-street       = wa_adrc_pr-street.
    wa_header-str_suppl1   = wa_adrc_pr-str_suppl1.
    wa_header-str_suppl2   = wa_adrc_pr-str_suppl2.
    wa_header-post_code1   = wa_adrc_pr-post_code1.
    wa_header-bezei        = wa_t005u_pr-bezei.
    wa_header-landx        = wa_t005t_pr-landx.
    IF wa_ekko1_pr-bsart = 'ZOSP'.
      wa_header-mblnr       = wa_zinw_t_hdr_pr-mblnr.
*    WA_HEADER-GPRO_USER      = WA_ZINW_T_HDR-GPRO_USER.

    ELSEIF wa_ekko1_pr-bsart = 'ZLOP'.
      wa_header-mblnr   = wa_zinw_t_hdr_pr-mblnr_103.
*    WA_HEADER-GPRO_USER      = WA_ZINW_T_HDR-GPRO_USER.

    ENDIF.

    wa_header-gpro_user = wa_zinw_t_status_pr-created_by.
*    "
    LOOP AT it_ekpo_pr INTO wa_ekpo_pr.
      lv_sl = lv_sl + 1.
      wa_final-sl = lv_sl.

*    WA_FINAL-MWSKZ = WA_EKPO-MWSKZ.
      wa_final-menge = wa_ekpo_pr-menge.
      wa_final-netpr = wa_ekpo_pr-netpr.
      wa_final-netwr = wa_ekpo_pr-netwr.
      wa_final-ean11_pr = wa_ekpo_pr-ean11.


      IF vendor_return_po = 'X' OR vendor_debit_note = 'X'.
        IF wa_final-ean11_pr IS NOT INITIAL.
          SELECT SINGLE knumh FROM a502 INTO @DATA(lv_knumh) WHERE matnr = @wa_ekpo_pr-matnr AND lifnr = @wa_ekko_pr-lifnr
                                                             AND kschl = 'PB00' AND datbi GE @sy-datum.
          SELECT SINGLE kbetr FROM konp INTO wa_final-netpr  WHERE knumh = lv_knumh.

          SELECT SINGLE knumh FROM a515 INTO @DATA(lv_knumh1) WHERE  kschl = 'ZMRP'
                                                      AND   matnr = @wa_ekpo_pr-matnr AND datbi GE @sy-datum.
          SELECT SINGLE kbetr FROM konp INTO wa_final-mrp_r  WHERE knumh = lv_knumh1.

          SELECT SINGLE knumh FROM a406 INTO @DATA(lv_knumh2) WHERE  kschl = 'ZEAN'
                                                      AND   matnr = @wa_ekpo_pr-matnr AND werks = @wa_ekpo_pr-werks AND datbi GE @sy-datum.
          SELECT SINGLE kbetr FROM konp INTO wa_final-kbetr  WHERE knumh = lv_knumh2.

        ENDIF.
      ENDIF.

      READ TABLE it_makt_pr INTO wa_makt_pr WITH KEY matnr = wa_ekpo_pr-matnr.
      IF sy-subrc = 0.
        wa_final-maktx = wa_makt_pr-maktx.
      ENDIF.
*********      added on (17-3-20)   for barcode field in return po   *********
      IF wa_final-ean11_pr IS INITIAL  AND vendor_return_po = 'X' OR  vendor_debit_note = 'X'.
        READ TABLE it_mseg_pr INTO wa_mseg_pr WITH KEY ebeln = lv_ebeln ebelp = wa_ekpo_pr-ebelp.
        IF sy-subrc = 0.
          SELECT SINGLE b1_batch FROM zb1_s4_map INTO @DATA(lv_batch) WHERE s4_batch = @wa_mseg_pr-charg.
          IF lv_batch IS NOT INITIAL.
            wa_final-ean11_pr = lv_batch.
            SELECT SINGLE amount FROM zb1_s_price INTO wa_final-kbetr WHERE b1_batch = lv_batch.
          ELSE.
            wa_final-ean11_pr = wa_mseg_pr-charg.
          ENDIF.
        ENDIF .

        SELECT SINGLE knumh FROM a515 INTO @DATA(lv_knumh3) WHERE  kschl = 'ZMRP'
                                                    AND   matnr = @wa_mseg_pr-matnr AND datbi GE @sy-datum.
        SELECT SINGLE kbetr FROM konp INTO wa_final-mrp_r  WHERE knumh = lv_knumh3.

***************************************************************************************************
        READ TABLE it_a511 INTO wa_a511 WITH KEY charg = wa_mseg_pr-charg  matnr = wa_mseg_pr-matnr kschl = 'ZKP0'.
        READ TABLE it_konp_pr  INTO wa_konp_pr WITH KEY knumh = wa_a511-knumh.
        IF sy-subrc = 0 AND wa_final-kbetr IS INITIAL.
          wa_final-kbetr = wa_konp_pr-kbetr.
        ENDIF .

      ENDIF.

      wa_final-sel_tot = wa_final-kbetr * wa_final-menge .
********************      end (17-3-20)    &******************************
*      READ TABLE IT_ZINW_T_ITEM_PR ASSIGNING FIELD-SYMBOL(<WA_ITEM>) WITH KEY  MATNR = WA_EKPO_PR-MATNR WERKS = WA_EKPO_PR-WERKS.
*
*      IF SY-SUBRC = 0.
*
*        WA_FINAL-NETPR_GP = <WA_ITEM>-NETPR_GP.
*
*      ENDIF.
      LOOP AT it_a003 ASSIGNING FIELD-SYMBOL(<wa_a003>) WHERE mwskz = wa_ekpo_pr-mwskz.
        IF <wa_a003>-kschl = 'JIIG'.
          lv_hed = 'IGST(%)'.
          lv_val = 'IGST Value'.
          READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konp>) WITH KEY knumh = <wa_a003>-knumh.
          IF sy-subrc = 0.
            lv_per =  <wa_konp>-kbetr / 10 .                        """""| && | { '%' } |.
            wa_final-percentage =  lv_per .
            lv_tax = ( <wa_konp>-kbetr * wa_ekpo_pr-netwr ) / 1000.
            ADD lv_tax TO wa_final-netpr_gp.
            wa_header-netpr_t = wa_header-netpr_t + wa_final-netpr_gp .
*            EXIT.
          ENDIF.
        ELSEIF <wa_a003>-kschl = 'JICG' OR <wa_a003>-kschl = 'JISG'.
          CLEAR : lv_hed , lv_val.
          READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konp1>) WITH KEY knumh = <wa_a003>-knumh.
          lv_hed = 'CGST/SGST(%)'.
          lv_val = 'CGST/SGST Val'.
          IF sy-subrc = 0.
            CLEAR: lv_tax,lv_per,wa_header-netpr_t.
            lv_per =  <wa_konp1>-kbetr / 10 .
*            ADD LV_PER TO WA_FINAL-PERCENTAGE.
            wa_final-percentage =  lv_per .
            lv_s = '/'.                           """""| && | { '/' } |.
            lv_tax = ( <wa_konp1>-kbetr * wa_ekpo_pr-netwr ) / 1000.
            ADD lv_tax TO wa_final-netpr_gp.

            wa_final-net_gp  = wa_final-netpr_gp / 2.     " ADDEED ON (18-3-20)

            wa_header-netpr_t = wa_header-netpr_t + wa_final-netpr_gp .
          ENDIF.
        ENDIF.

      ENDLOOP.
      READ TABLE it_mara_pr ASSIGNING FIELD-SYMBOL(<ls_mara_pr>) WITH KEY matnr = wa_ekpo_pr-matnr.
      IF sy-subrc = 0.

        wa_final-ean11 = <ls_mara_pr>-ean11.

      ENDIF.
*      "

      wa_header-toqty = wa_final-toqty + wa_final-menge.
      wa_header-tamount = wa_header-tamount + wa_final-netwr.
      wa_header-tamt = wa_header-tamount + wa_header-netpr_t.


      APPEND wa_final TO it_final.
      CLEAR : wa_final.
    ENDLOOP.
*      ENDLOOP.

    DATA: lv_amt1     TYPE pc207-betrg,
          wa_amt(100) TYPE c.
    lv_amt1 = wa_header-tamt.

    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = lv_amt1
      IMPORTING
        amt_in_words       = wa_amt
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        input_string  = wa_amt
*       SEPARATORS    = ' -.,;:'
      IMPORTING
        output_string = wa_amt.

    wa_header-p_name1   = wa_kna1_pr-name1 .
    wa_header-p_land1   = wa_t001w_pr-land1 .
    wa_header-werks     = wa_t001w_pr-werks.
    wa_header-p_name1     = wa_t001w_pr-name1.
    wa_header-v_stcd3   = wa_lfa1_pr-stcd3 .
    wa_header-mblnr     = wa_mseg_pr-mblnr.
    wa_header-bldat     = wa_mkpf_pr-bldat.
    wa_header-bedat     = wa_ekko_pr-bedat.
    wa_header-ernam_r   = wa_ekko_pr-ernam.
    wa_header-belnr     = wa_ekbe-belnr.

    wa_header-gstin     = wa_j_1bbranch_pr-gstin.
    wa_header-smtp_addr = wa_adr6_pr-smtp_addr.
    wa_header-trns      = wa_zinw_t_hdr_pr-trns.
    wa_header-lr_no     = wa_zinw_t_hdr_pr-lr_no.
    wa_header-act_no_bud     = wa_zinw_t_hdr_pr-act_no_bud .
*  WA_HEADER-NO_BUD    = WA_ZINW_T_HDR-NO_BUD.
    wa_header-bill_num  = wa_zinw_t_hdr_pr-bill_num.
    wa_header-bill_date = wa_zinw_t_hdr_pr-bill_date.
    wa_header-ebeln     = wa_ekpo_pr-ebeln.
    wa_header-aedat     = wa_ekko_pr-aedat.
    wa_header-v_name1   = wa_lfa1_pr-name1 .
    wa_header-street_v         = wa_adrc1_pr-street.
    wa_header-str_suppl2_v     = wa_adrc1_pr-str_suppl2.
    wa_header-str_suppl1_v     = wa_adrc1_pr-str_suppl1.
    wa_header-city1_v          = wa_adrc1_pr-city1.
    wa_header-post_code1_v       = wa_adrc1_pr-post_code1.
    wa_header-bezei_v        = wa_t005u1_pr-bezei.
    wa_header-landx_v      = wa_t005t1_pr-landx.
    wa_header-inv_no     = wa_ekbe_pr-belnr.
    wa_header-inv_dt     = wa_ekbe_pr-budat.
    DATA : lv_heading(100) TYPE c,
           lv_ref_po(30)   TYPE c,
           lv_bill_d(30)   TYPE c,
           p_aedat(10)     TYPE c.
    CLEAR : po_text.
    po_text = wa_header-ebeln.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = 'F01'
        language                = 'E'
        name                    = po_text
        object                  = 'EKKO'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
* IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = po_lines[]
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT po_lines.
      CONCATENATE po_lines-tdline lv_po_text INTO lv_po_text .
      CLEAR po_lines .
    ENDLOOP.


*********************END OF RETURN PO***********************************************************************************
********************************************************start of service po************************************************************************
*    "
    DATA : wa_ekpo_s1 TYPE ekpo.
    DATA : it_ekpo_s TYPE TABLE OF ekpo.
*    DATA : IT_EKPO_S TYPE TABLE OF  EKKO.

    SELECT SINGLE * FROM zinw_t_hdr INTO  @DATA(wa_header_s) WHERE service_po = @lv_ebeln.
    IF wa_header_s IS NOT INITIAL.
      SELECT SINGLE ekko~ebeln , ekko~lifnr , ekko~ernam , ekko~aedat FROM ekko INTO @DATA(wa_ekko_s) WHERE ebeln = @wa_header_s-service_po.
      SELECT ekpo~ebeln , ekpo~ebelp , ekpo~packno , ekpo~werks , ekpo~mwskz , ekpo~netwr FROM ekpo INTO CORRESPONDING FIELDS OF TABLE  @it_ekpo_s WHERE ebeln = @wa_header_s-service_po.
      SELECT SINGLE zinw_t_status~qr_code , zinw_t_status~status_field , zinw_t_status~status_value , zinw_t_status~created_date  FROM zinw_t_status INTO @DATA(wa_status) WHERE qr_code = @wa_header_s-qr_code AND status_field = 'QR02'.
      SELECT SINGLE ekko~ebeln , ekko~lifnr  FROM ekko INTO @DATA(wa_ekko1_s) WHERE ebeln = @wa_header_s-ebeln.
    ENDIF.

    IF wa_ekko_s IS NOT INITIAL.

      SELECT SINGLE lfa1~lifnr , lfa1~adrnr , lfa1~name1 , lfa1~ort01 , lfa1~stcd3 FROM lfa1 INTO @DATA(wa_vendor) WHERE lifnr = @wa_ekko_s-lifnr.

    ENDIF.

    IF wa_ekko1_s IS NOT INITIAL.

      SELECT SINGLE lfa1~lifnr , lfa1~adrnr , lfa1~name1 , lfa1~ort01 , lfa1~stcd3 FROM lfa1 INTO @DATA(wa_vendor1) WHERE lifnr = @wa_ekko1_s-lifnr.

    ENDIF.

    IF it_ekpo_s IS NOT INITIAL.

      SELECT esll~packno , esll~introw , esll~package , esll~sub_packno FROM esll INTO TABLE  @DATA(it_esll)
      FOR ALL ENTRIES IN @it_ekpo_s WHERE packno = @it_ekpo_s-packno.

    ENDIF.

    READ TABLE it_ekpo_s INTO wa_ekpo_s1 INDEX 1.
    IF wa_ekpo_s1 IS NOT INITIAL.
      SELECT SINGLE t001w~werks , t001w~adrnr FROM t001w INTO @DATA(wa_t001w_s) WHERE werks = @wa_ekpo_s1-werks.
      SELECT SINGLE lfa1~stcd3 FROM lfa1 INTO @wa_hdr-gstinp WHERE werks = @wa_ekpo_s1-werks.
    ENDIF.

    IF it_esll IS NOT INITIAL.

      SELECT esll~packno , esll~introw , esll~srvpos , esll~package , esll~sub_packno , esll~menge , esll~netwr , esll~mwskz , esll~tbtwr , esll~ktext1  FROM esll
      INTO TABLE  @DATA(it_esll1)
      FOR ALL ENTRIES IN @it_esll WHERE packno = @it_esll-sub_packno.

    ENDIF.
    IF it_ekpo_s IS NOT INITIAL.

      SELECT * FROM a003 INTO TABLE @DATA(it_a003_s) FOR ALL ENTRIES IN @it_ekpo_s WHERE mwskz = @it_ekpo_s-mwskz.

    ENDIF.

    IF it_a003_s IS NOT INITIAL.

      SELECT * FROM konp INTO TABLE @DATA(it_konp_s) FOR ALL ENTRIES IN @it_a003_s WHERE knumh = @it_a003_s-knumh.

    ENDIF.


    lv_ven = wa_vendor-adrnr.
    lv_shp = wa_t001w_s-adrnr.
    wa_hdr-lr_no      = wa_header_s-lr_no.
    wa_hdr-act_no_bud = wa_header_s-act_no_bud.
    wa_hdr-name       = wa_vendor-name1.
    wa_hdr-city       = wa_vendor-ort01.
    wa_hdr-transporter = wa_vendor-lifnr.
    wa_hdr-bill_num   = wa_header_s-bill_num.
    wa_hdr-bill_dat   = wa_header_s-bill_date.
    wa_hdr-gate_entry = wa_ekko_s-aedat.
    wa_hdr-po_no      = wa_header_s-ebeln.
    wa_hdr-spo_no     = lv_ebeln.
    wa_hdr-qr_code    = wa_header_s-qr_code.
    wa_hdr-lr_date     = wa_header_s-lr_date.
    wa_hdr-created_by = wa_ekko_s-ernam.
    wa_hdr-aedat = wa_ekko_s-aedat.
    wa_hdr-stcd3      = wa_vendor-stcd3.
    wa_hdr-vendor     = wa_vendor1-lifnr.
    wa_hdr-ven_name     = wa_vendor1-name1.

    LOOP AT it_ekpo_s ASSIGNING FIELD-SYMBOL(<wa_ekpo_s>).

      w_final-sevice_po = <wa_ekpo_s>-ebeln.
      w_final-lr_no     = wa_header_s-lr_no.
      READ TABLE it_esll ASSIGNING FIELD-SYMBOL(<wa_esll>) WITH KEY packno = <wa_ekpo_s>-packno.

      LOOP AT it_esll1 ASSIGNING FIELD-SYMBOL(<wa_esll1>) WHERE  packno = <wa_esll>-sub_packno .

        w_final-gross_value = <wa_esll1>-tbtwr.
        w_final-menge = <wa_esll1>-menge.
        w_final-netwr = w_final-gross_value * w_final-menge.
        w_final-sort_text = <wa_esll1>-ktext1.
        wa_hdr-lv_tot = wa_hdr-lv_tot + w_final-netwr.
        wa_hdr-qty_t  = wa_hdr-qty_t  + w_final-menge.

        APPEND w_final TO t_final.
        CLEAR : w_final.

      ENDLOOP.

      LOOP AT it_a003_s ASSIGNING FIELD-SYMBOL(<wa_a003_s>) WHERE mwskz = <wa_ekpo_s>-mwskz.
        IF <wa_a003_s>-kschl = 'JIIG'.
          READ TABLE it_konp_s ASSIGNING FIELD-SYMBOL(<wa_konp_s>) WITH KEY knumh = <wa_a003_s>-knumh.
          IF sy-subrc = 0.
            DATA(lv_tax_s) = ( <wa_konp_s>-kbetr * <wa_ekpo_s>-netwr ) / 1000.
            ADD lv_tax_s TO wa_hdr-gst.
*            EXIT.
          ENDIF.
        ELSEIF <wa_a003_s>-kschl = 'JICG' OR <wa_a003_s>-kschl = 'JISG'.
          IF sy-subrc = 0.
            CLEAR: lv_tax_s.
            lv_tax = ( <wa_konp_s>-kbetr * <wa_ekpo_s>-netwr ) / 1000.
            ADD lv_tax TO wa_hdr-gst.

          ENDIF.
        ENDIF.

        wa_hdr-net_total = wa_hdr-gst + wa_hdr-lv_tot.

      ENDLOOP.

    ENDLOOP.
    DATA : lv_amount TYPE pc207-betrg.
    DATA : lv_w(100) TYPE c.
    lv_amount = wa_hdr-net_total.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = lv_amount
      IMPORTING
        amt_in_words       = lv_w
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FI_CONVERT_FIRSTCHARS_TOUPPER'
      EXPORTING
        input_string  = lv_w
*       SEPARATORS    = ' -.,;:'
      IMPORTING
        output_string = lv_w.
    SELECT * FROM tvarvc INTO TABLE  @DATA(it_tvarvc) WHERE name = 'ZZPO_MAIL'.

*****************************************************end of service po*******************************************************************
    BREAK breddy .
** For Reg PO & Packing List
    IF reg_po IS NOT INITIAL.
      lv_heading = 'PURCHASE ORDER'.
      p_aedat  = sy-datum .

*      "
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          input  = p_aedat
        IMPORTING
          output = p_aedat.


*****************************************END OF PO_RETURN DECLRATION*****************************************************************************

*      "
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZPURCHASE_ORDER_FORM'
        IMPORTING
          fm_name            = fmname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*      BREAK SAMBURI.

      IF print_prieview IS NOT INITIAL.
        ls_outputop-tddest  = 'LP01'.
      ELSE.
        ls_ctrlop-getotf = abap_true.
        ls_ctrlop-no_dialog = 'X'.
        ls_ctrlop-langu = sy-langu.

        ls_outputop = is_output_options.
        ls_outputop-tdnoprev = abap_true.
        ls_outputop-tddest  = 'LP01'.
      ENDIF.



*      LS_CTRLOP-GETOTF = ABAP_TRUE.
*      LS_CTRLOP-NO_DIALOG = 'X'.
*      LS_CTRLOP-LANGU = SY-LANGU.
*
*      LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
*      LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
*      LS_OUTPUTOP-TDDEST  = 'LP01'.

      CALL FUNCTION fmname
        EXPORTING
          control_parameters   = ls_ctrlop
          output_options       = ls_outputop
          wa_poheader          = wa_poheader
          lv_ebeln             = lv_ebeln
          lv_adrc              = lv_adrc
          lv_adrc1             = lv_adrc1
          lv_adrc2             = lv_adrc2
          lv_words             = lv_words
          lv_gstin_v           = lv_gstin_v
          lv_gstin_c           = lv_gstin_c
          lv_heading           = lv_heading
          lv_billd             = lv_billd
          lv_rpo               = lv_rpo
          lv_ref_po            = lv_ref_po
          lv_bill_d            = lv_bill_d
          lv_ername            = lv_ername
          po_qr                = lv_ebeln
          lv_code              = lv_code
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        TABLES
          it_poitem            = it_poitem
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.
**           Implement suitable error handling here
      ENDIF.

*      ELSE.
      IF print_prieview IS INITIAL.
        lt_otf = ls_job_output_info-otfdata.

*      BREAK-POINT.
        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
            max_linewidth         = 132
          IMPORTING
            bin_filesize          = ls_bin_filesize
            bin_file              = lv_otf
          TABLES
            otf                   = lt_otf[]
            lines                 = lt_lines[]
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4.

*      ENDIF.

        CALL METHOD cl_document_bcs=>xstring_to_solix
          EXPORTING
            ip_xstring = lv_otf
          RECEIVING
            rt_solix   = lt_pdf_data[].

        TRY.
            REFRESH main_text.

*-------- create persistent send request ------------------------
            send_request = cl_bcs=>create_persistent( ).

            CLEAR ls_main_text.
            ls_main_text = 'To,'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = 'All Concerned' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = 'Sub: Purchase Order & Packing List release/amendment'.
            APPEND ls_main_text TO main_text.

            ls_text3 =  | GROUP  : { wa_poheader-group_id } | .
            CLEAR ls_main_text.
            ls_main_text =   ls_text3 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'The following Purchase Order & Packing List is released/amendment. Please take necessary action:' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.
            ls_text =  | VENDOR NAME  : { wa_poheader-ad_name } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            ls_main_text =   ls_text .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            ls_text1 =  | PURCHASE ORDER NO  : { lv_ebeln  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            ls_main_text =   ls_text1 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            ls_text2 =  | PO. APPROVED DATE  : { p_aedat  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            ls_main_text =   ls_text2 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            ls_main_text =  'REMARKS : PO Created'   .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'From.' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'PurchaseDept.' .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'clarifications contact TSG/MKTG.dept.' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND ls_main_text TO main_text.

          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.

        ENDTRY.

        CONCATENATE 'Purchase Order' lv_ebeln  '.pdf' INTO lv_doc_subject.

        TRY .
            document = cl_document_bcs=>create_document(
                i_type    = 'HTM'
                i_text    = main_text
                i_subject = lv_doc_subject ).
          CATCH cx_document_bcs .

        ENDTRY.

        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject
                                        i_att_content_hex = lt_pdf_data ).

          CATCH cx_document_bcs.
        ENDTRY.
      ENDIF.
*    "
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZPACKING_FORM'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          fm_name            = fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      CLEAR :
      ls_document_output_info,
      ls_job_output_info,
      ls_job_output_options.


      CALL FUNCTION fm_name
        EXPORTING
          control_parameters   = ls_ctrlop
          output_options       = ls_outputop
          wa_poheader          = wa_poheader
          lv_ebeln             = lv_ebeln
          lv_adrc              = lv_adrc
          lv_adrc1             = lv_adrc1
          lv_adrc2             = lv_adrc2
          lv_words             = lv_words
          lv_gstin_v           = lv_gstin_v
          lv_gstin_c           = lv_gstin_c
*         LV_HEADING           = LV_HEADING
          po_qr                = wa_poheader-po_qr
          lv_code              = lv_code
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        TABLES
          it_poitem            = it_poitem
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.
*           Implement suitable error handling here
      ENDIF.
*      ENDIF.


*      ELSE.
*      CLEAR :LS_BIN_FILESIZE,
*             LV_OTF,
*             LT_OTF,
*             LT_LINES.
      IF print_prieview IS INITIAL.
        lt_otf1 = ls_job_output_info-otfdata.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
            max_linewidth         = 132
          IMPORTING
            bin_filesize          = ls_bin_filesize1
            bin_file              = lv_otf1
          TABLES
            otf                   = lt_otf1[]
            lines                 = lt_lines1[]
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4.

*      ENDIF.

*            TRY .
*          DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
*              I_TYPE    = 'HTM'
*              I_TEXT    = MAIN_TEXT
*              I_SUBJECT = LV_DOC_SUBJECT1 ).
*        CATCH CX_DOCUMENT_BCS .
*
*      ENDTRY.

        CALL METHOD cl_document_bcs=>xstring_to_solix
          EXPORTING
            ip_xstring = lv_otf1
          RECEIVING
            rt_solix   = lt_pdf_data1[].


        CLEAR lv_doc_subject1.
        CONCATENATE 'Packing List' lv_ebeln  '.pdf' INTO lv_doc_subject1.

        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject1
                                        i_att_content_hex = lt_pdf_data1 ).

          CATCH cx_document_bcs.
        ENDTRY.
        TRY.
*     add document object to send request
            send_request->set_document( document ).

*** Start of Changes By Suri : 21.08.2019
            v_send_request = cl_sapuser_bcs=>create( sy-uname ).
*            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( conv SYST_UNAME('SUPERSTORESPO') ).
*** End of Changes By Suri : 21.08.2019

            CALL METHOD send_request->set_sender
              EXPORTING
                i_sender = v_send_request.
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'suri.amburi@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'anuanilmehta@yahoo.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.

*            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            CLEAR I_ADDRESS_STRING.
            IF sy-mandt = 800.
**** START OF CHANGES BY SURI : 18.11.2019
**** Sending Mail to Vendor for Specific Groups
*--> Commented_needed for all groups -> sjena <- 06.02.2020 14:31:14
***            IF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
***                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
***                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.
***************************              commeneted on (16-2-20),     ***********************************
              CLEAR : i_address_string.
****                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
              recipient = cl_cam_address_bcs=>create_internet_address( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019  uncommented on CL:
              send_request->add_recipient( recipient ).
****            ENDIF.
********************************************    end   *******************************************
*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC>).
*              I_ADDRESS_STRING = <WA_TVARVC>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.
*
*            BREAK BREDDY .
*********ADDED BY BHAVANI 17.09.2019*********
*            CLEAR : I_ADDRESS_STRING.
*
*--> Un-Commented Vendor Recipient Email -> sjena <- 07.02.2020 13:50:13
              IF i_addrnumber IS NOT INITIAL.
                recipient = cl_cam_address_bcs=>create_internet_address( i_addrnumber ).
                send_request->add_recipient( recipient ).
              ENDIF.
*********ENDED BY BHAVANI 17.09.2019*********
***           Start Of Changes By Suri : 21.02.2020
              SELECT DISTINCT email FROM zgroup_ven INTO TABLE @DATA(lt_email) WHERE class = @wa_poheader-group_id.
              DELETE lt_email WHERE email IS INITIAL.
              LOOP AT lt_email ASSIGNING FIELD-SYMBOL(<ls_email>).
                i_addrnumber = <ls_email>-email.
                recipient    = cl_cam_address_bcs=>create_internet_address( i_addrnumber ).
                send_request->add_recipient( recipient ).
              ENDLOOP.
*********Added by Priyanka For Agent Email
              SELECT DISTINCT aemail FROM zgroup_ven INTO TABLE @DATA(lt_email1) WHERE class = @wa_poheader-group_id AND lifnr = @wa_lfa1-lifnr.
              DELETE lt_email1 WHERE aemail IS INITIAL.
              LOOP AT lt_email1 ASSIGNING FIELD-SYMBOL(<ls_email1>).
                i_addrnumber = <ls_email1>-aemail.
                recipient    = cl_cam_address_bcs=>create_internet_address( i_addrnumber ).
                send_request->add_recipient( recipient ).
              ENDLOOP.

***           End Of Changes By Priyanka : 29.02.2020
***           End Of Changes By Suri : 21.02.2020
            ENDIF.
**** Start of Changes By Suri : 21.08.2019
**** Sending Mail to Vendor for Specific Groups
*            IF WA_POHEADER-GROUP_ID = 'COSMETICS'  OR WA_POHEADER-GROUP_ID = 'FOOTWARE' OR WA_POHEADER-GROUP_ID = 'FOOTWARE1' OR
*               WA_POHEADER-GROUP_ID = 'FOOTWARE_1' OR WA_POHEADER-GROUP_ID = 'BAGS'     OR WA_POHEADER-GROUP_ID = 'BAGS1'     OR
*               WA_POHEADER-GROUP_ID = 'MOBILES'.
*              CLEAR : I_ADDRESS_STRING.
*              SELECT SINGLE SMTP_ADDR INTO I_ADDRESS_STRING FROM ADR6 WHERE ADDRNUMBER = WA_LFA1-ADRNR.
*              IF I_ADDRESS_STRING IS NOT INITIAL.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
*                SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              ENDIF.
*            ELSEIF WA_POHEADER-GROUP_ID = 'SAREE' .
*              CLEAR : I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*
*            ENDIF.
**** End of Changes By Suri : 21.08.2019
*
******added by bhavani
*
*            IF WA_POHEADER-GROUP_ID = 'FOOTWARE'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Pothi3080@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'babushanmugam1987@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'TOYS' OR   WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Prakash.arikrish@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Augustin@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'FURNITURE' OR WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'jaichandran@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' .
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Chermananu1982@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MOBILES' OR WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'WATCHES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'elect@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADEN' OR WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'murugan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'INNERWARE' OR WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'JUSTBORN' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'pkannan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'thangaduraivo8@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'kmannanmaha@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.
***********Ended by bhavani
*** End of Changes By Suri : 18.11.2019

*     ---------- send document ---------------------------------------
            sent_to_all = send_request->send( i_with_error_screen = 'X' ).

            COMMIT WORK.

            IF sent_to_all IS INITIAL.
              MESSAGE i500(sbcoms).
            ELSE.
              es_msg = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.
        ENDTRY.
      ENDIF.
****************************************************PO return****************************************************
*      "
      CLEAR : lv_heading.
      CLEAR : p_aedat.
    ELSEIF return_po IS NOT INITIAL.

      lv_heading = 'PURCHASE ORDER'.
      p_aedat  = sy-datum .

*      "
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          input  = p_aedat
        IMPORTING
          output = p_aedat.

      IF print_prieview IS NOT INITIAL.
        ls_outputop-tddest  = 'LP01'.
      ELSE.
        ls_ctrlop-getotf = abap_true.
        ls_ctrlop-no_dialog = 'X'.
        ls_ctrlop-langu = sy-langu.

        ls_outputop = is_output_options.
        ls_outputop-tdnoprev = abap_true.
        ls_outputop-tddest  = 'LP01'.
      ENDIF.

      READ TABLE it_ekpo_pr INTO wa_ekpo_pr WITH KEY retpo = 'X'.
      IF sy-subrc = 0.
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZMM_PURCHASE_RETURN_F1'
          IMPORTING
            fm_name            = fm_name
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        CLEAR :
        ls_document_output_info,
        ls_job_output_info,
        ls_job_output_options.


        CALL FUNCTION fm_name
          EXPORTING
            control_parameters   = ls_ctrlop
            output_options       = ls_outputop
            wa_header            = wa_header
            wa_amt               = wa_amt
            lv_hed               = lv_hed
            lv_val               = lv_val
            lv_per               = lv_per
            lv_s                 = lv_s
            lv_po_text           = lv_po_text
          IMPORTING
            document_output_info = ls_document_output_info
            job_output_info      = ls_job_output_info
            job_output_options   = ls_job_output_options
          TABLES
            it_final             = it_final
          EXCEPTIONS
            formatting_error     = 1
            internal_error       = 2
            send_error           = 3
            user_canceled        = 4
            OTHERS               = 5.
        IF sy-subrc <> 0.

* Implement suitable error handling here
        ENDIF.
      ENDIF.

      IF print_prieview IS INITIAL.
        lt_otf2 = ls_job_output_info-otfdata.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
            max_linewidth         = 132
          IMPORTING
            bin_filesize          = ls_bin_filesize1
            bin_file              = lv_otf2
          TABLES
            otf                   = lt_otf2[]
            lines                 = lt_lines2[]
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4.
*        ENDIF.

        CALL METHOD cl_document_bcs=>xstring_to_solix
          EXPORTING
            ip_xstring = lv_otf2
          RECEIVING
            rt_solix   = lt_pdf_data2[].
*      ENDIF.
*    ENDIF.
*      "
        TRY.
            REFRESH main_text.

*-------- create persistent send request ------------------------
            send_request = cl_bcs=>create_persistent( ).

            CLEAR ls_main_text.
            ls_main_text = 'To,'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = 'All Concerned' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = 'Sub: Return Purchase Order release/amendment'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'The following Return Purchase Order is released/amendment. Please take necessary action:' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.
            ls_text =  | VENDOR NAME  : { wa_poheader-ad_name } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            ls_main_text =   ls_text .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            ls_text1 =  | RETURN PURCHASE ORDER NO  : { lv_ebeln  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            ls_main_text =   ls_text1 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            ls_text2 =  | PO. APPROVED DATE  : { p_aedat  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            ls_main_text =   ls_text2 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            ls_main_text =  'REMARKS : Returned Po Created'   .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'From.' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'PurchaseDept.' .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'clarifications contact TSG/MKTG.dept.' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND ls_main_text TO main_text.

          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.

        ENDTRY.

        CLEAR lv_doc_subject2.
        CONCATENATE 'Return PO' lv_ebeln  '.pdf' INTO lv_doc_subject2.

        TRY .
            document = cl_document_bcs=>create_document(
                i_type    = 'HTM'
                i_text    = main_text
                i_subject = lv_doc_subject2 ).
          CATCH cx_document_bcs .

        ENDTRY.

        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject2
                                        i_att_content_hex = lt_pdf_data2 ).

          CATCH cx_document_bcs.
        ENDTRY.

        TRY.
*-------- create persistent send request ------------------------
            send_request = cl_bcs=>create_persistent( ).
*     add document object to send request
            send_request->set_document( document ).


            v_send_request = cl_sapuser_bcs=>create( sy-uname ).

            CALL METHOD send_request->set_sender
              EXPORTING
                i_sender = v_send_request.
*        BREAK SAMBURI.
*"
*        LOOP AT LT_RECLIST INTO LS_RECLIST.
*          I_ADDRESS_STRING = LS_RECLIST.
*      RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'suri.amburi@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*        RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*        SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*        CLEAR I_ADDRESS_STRING.
*        ENDLOOP.
*
*            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'dummyposap@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            CLEAR I_ADDRESS_STRING.

**** START OF CHANGES BY SURI : 18.11.2019
**** Sending Mail to Vendor for Specific Groups

*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC2>).
*              I_ADDRESS_STRING = <WA_TVARVC2>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.

*--> Commented - Needed for all groups -> sjena <- 06.02.2020 14:31:44
***            IF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
***                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
***                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.

*****************************commeneted on (16-2-20)   ***********************************
            CLEAR : i_address_string.
****                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
            recipient = cl_cam_address_bcs=>create_internet_address( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
            send_request->add_recipient( recipient ).
****            ENDIF.
**************************     end (16-2-20)   ************************************************
*** End of Changes By Suri : 18.11.2019

*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'anuanilmehta@yahoo.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.

*          LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC1>).
*            I_ADDRESS_STRING = <WA_TVARVC1>-LOW.
*            RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*            SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            CLEAR I_ADDRESS_STRING.
*          ENDLOOP.

*     ---------- send document ---------------------------------------
            sent_to_all = send_request->send( i_with_error_screen = 'X' ).

            COMMIT WORK.

            IF sent_to_all IS INITIAL.
              MESSAGE i500(sbcoms).
            ELSE.
*        MESSAGE s022(so).
              es_msg = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.
        ENDTRY.


      ENDIF.

************************************************************************************************************
******************************************ADDED BY SKN******************************************************************
      CLEAR : lv_heading.
      CLEAR : p_aedat.
    ELSEIF vendor_return_po IS NOT INITIAL.

*      lv_heading = 'Vendor Return'.
*      p_aedat  = sy-datum .

*      "
*      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
*        EXPORTING
*          input  = p_aedat
*        IMPORTING
*          output = p_aedat.

*      IF print_prieview IS NOT INITIAL.
*        ls_outputop-tddest  = 'LP01'.
*      ELSE.
*        ls_ctrlop-getotf = abap_true.
*        ls_ctrlop-no_dialog = 'X'.
*        ls_ctrlop-langu = sy-langu.
*
*        ls_outputop = is_output_options.
*        ls_outputop-tdnoprev = abap_true.
*        ls_outputop-tddest  = 'LP01'.
*      ENDIF.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZMM_PURCHASE_RETURN'
        IMPORTING
          fm_name            = fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*        CLEAR :
*        ls_document_output_info,
*        ls_job_output_info,
*        ls_job_output_options.

      CALL FUNCTION fm_name
        EXPORTING
*         control_parameters   = ls_ctrlop
*         output_options       = ls_outputop
          wa_header            = wa_header
          wa_amt               = wa_amt
          lv_hed               = lv_hed
          lv_val               = lv_val
          lv_per               = lv_per
          lv_s                 = lv_s
          lv_po_text           = lv_po_text
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        TABLES
          it_final             = it_final
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.

* Implement suitable error handling here
      ENDIF.
*    IF print_prieview IS INITIAL.
*        lt_otf2 = ls_job_output_info-otfdata.
*
*        CALL FUNCTION 'CONVERT_OTF'
*          EXPORTING
*            format                = 'PDF'
*            max_linewidth         = 132
*          IMPORTING
*            bin_filesize          = ls_bin_filesize1
*            bin_file              = lv_otf2
*          TABLES
*            otf                   = lt_otf2[]
*            lines                 = lt_lines2[]
*          EXCEPTIONS
*            err_max_linewidth     = 1
*            err_format            = 2
*            err_conv_not_possible = 3
*            err_bad_otf           = 4.
**        ENDIF.
*
*        CALL METHOD cl_document_bcs=>xstring_to_solix
*          EXPORTING
*            ip_xstring = lv_otf2
*          RECEIVING
*            rt_solix   = lt_pdf_data2[].
**      ENDIF.
**    ENDIF.
**      "
*        TRY.
*            REFRESH main_text.
*
**-------- create persistent send request ------------------------
*            send_request = cl_bcs=>create_persistent( ).
*
*            CLEAR ls_main_text.
*            ls_main_text = 'To,'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text = '<BR>'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text = 'All Concerned' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text = '<BR>'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text = '<BR>'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
**            ls_main_text = 'Sub: Return Purchase Order release/amendment'.
*            ls_main_text = 'Sub: Vendor Return'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>'.
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  'The following Return Purchase Order is released/amendment. Please take necessary action:' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*            ls_text =  | VENDOR NAME  : { wa_poheader-ad_name } | .
*            CLEAR ls_main_text.
**      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
**      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
**        LS_MAIN_TEXT =   'VENDOR NAME : ' .
*            ls_main_text =   ls_text .
*            APPEND ls_main_text TO main_text.
*
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            ls_text1 =  | RETURN PURCHASE ORDER NO  : { lv_ebeln  } | .
*            CLEAR ls_main_text.
**      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
*            ls_main_text =   ls_text1 .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            ls_text2 =  | PO. APPROVED DATE  : { p_aedat  } | .
*            CLEAR ls_main_text.
**      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
*            ls_main_text =   ls_text2 .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
**      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
*            ls_main_text =  'REMARKS : Returned Po Created'   .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  'From.' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  'PurchaseDept.' .
*            APPEND ls_main_text TO main_text.
*
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
*            APPEND ls_main_text TO main_text.
*
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  'clarifications contact TSG/MKTG.dept.' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '<BR>' .
*            APPEND ls_main_text TO main_text.
*
*            CLEAR ls_main_text.
*            ls_main_text =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
*            APPEND ls_main_text TO main_text.
*
*          CATCH cx_bcs INTO bcs_exception.
*            MESSAGE i865(so) WITH bcs_exception->error_type.
*
*        ENDTRY.
*
*        CLEAR lv_doc_subject2.
*        CONCATENATE 'Return PO' lv_ebeln  '.pdf' INTO lv_doc_subject2.
*
*        TRY .
*            document = cl_document_bcs=>create_document(
*                i_type    = 'HTM'
*                i_text    = main_text
*                i_subject = lv_doc_subject2 ).
*          CATCH cx_document_bcs .
*
*        ENDTRY.
*
*        TRY.
*            document->add_attachment( i_attachment_type = 'BIN'
*                                        i_attachment_subject = lv_doc_subject2
*                                        i_att_content_hex = lt_pdf_data2 ).
*
*          CATCH cx_document_bcs.
*        ENDTRY.
*
*        TRY.
**-------- create persistent send request ------------------------
*            send_request = cl_bcs=>create_persistent( ).
**     add document object to send request
*            send_request->set_document( document ).
*
*
*            v_send_request = cl_sapuser_bcs=>create( sy-uname ).
*
*            CALL METHOD send_request->set_sender
*              EXPORTING
*                i_sender = v_send_request.
*
*
******************************commeneted on (16-2-20)   ***********************************
*            CLEAR : i_address_string.
*****                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
*            recipient = cl_cam_address_bcs=>create_internet_address( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
*            send_request->add_recipient( recipient ).
*
**     ---------- send document ---------------------------------------
*            sent_to_all = send_request->send( i_with_error_screen = 'X' ).
*
*            COMMIT WORK.
*
*            IF sent_to_all IS INITIAL.
*              MESSAGE i500(sbcoms).
*            ELSE.
**        MESSAGE s022(so).
*              es_msg = 'Email triggered successfully' ."TYPE 'S'.
*            ENDIF.
*
**   ------------ exception handling ----------------------------------
**   replace this rudimentary exception handling with your own one !!!
*          CATCH cx_bcs INTO bcs_exception.
*            MESSAGE i865(so) WITH bcs_exception->error_type.
*        ENDTRY.
*
*
*      ENDIF.

**************************************************VENDOR DEBIT NOTE***************
    ELSEIF  vendor_debit_note = 'X'.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZMM_DEBITNOTE'
        IMPORTING
          fm_name            = fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*        CLEAR :
*        ls_document_output_info,
*        ls_job_output_info,
*        ls_job_output_options.

      CALL FUNCTION fm_name
        EXPORTING
*         control_parameters   = ls_ctrlop
*         output_options       = ls_outputop
          wa_header            = wa_header
          wa_amt               = wa_amt
          lv_hed               = lv_hed
          lv_val               = lv_val
          lv_per               = lv_per
          lv_s                 = lv_s
          lv_po_text           = lv_po_text
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        TABLES
          it_final             = it_final
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.

* Implement suitable error handling here
      ENDIF.



***************************************************************************************
*****************************************END OF PO_RETURN DECLRATION*****************************************************************************
*      "
*********************************START OF TATKAL PO*********************************************
    ELSEIF tatkal_po IS NOT INITIAL.

      CLEAR : p_aedat,it_poitem,wa_poitem,wa_poheader-zuname ,wa_poheader-gstinp , wa_poheader-po_qr , wa_poheader-potype .                    ""WA_POITEM,WA_POHEADER.
      lv_ref_po = 'Reference PO :'.
      lv_bill_d  = 'Bill Date :'.
      lv_heading = 'PURCHASE ORDER'.
      p_aedat  = sy-datum .
      wa_poheader-po_qr = lv_ebeln .
*      "
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          input  = p_aedat
        IMPORTING
          output = p_aedat.

*      IF LV_EBELN IS NOT INITIAL.
*        SELECT EKKO~EBELN EKKO~BUKRS EKKO~AEDAT EKKO~BEDAT  EKKO~LIFNR FROM EKKO  INTO  CORRESPONDING FIELDS OF TABLE IT_EKKO
*          WHERE EBELN = LV_EBELN .
*
**        ELSE.
**           SELECT * FROM ZINW_T_HDR INTO  @DATA(WA_ZINW_T_HDR) WHERE TAT_PO = LV_EBELN .            """TATKAL PO
*      ENDIF.
*      IF IT_EKKO IS NOT INITIAL.
*        SELECT  EKPO~EBELN , EKPO~EBELP , EKPO~MENGE , EKPO~WERKS  , EKPO~MATNR , EKPO~MEINS , EKPO~MATKL , EKPO~NETPR , EKPO~ZZSET_MATERIAL  ,
*          EKPO~WRF_CHARSTC2 FROM EKPO INTO TABLE  @IT_EKPO WHERE EBELN = @LV_EBELN.
*
*      ENDIF.
*
*      READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
*      READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN = LV_EBELN.
*
*      SELECT SINGLE NAME1, ADRNR , WERKS, STCD3 INTO @DATA(WA_LFA1) FROM LFA1
*        WHERE LIFNR = @WA_EKKO-LIFNR.
*      IF IT_EKPO IS NOT INITIAL.
*        SELECT SINGLE T001W~ADRNR  FROM T001W INTO @DATA(LV_PADRNR) WHERE WERKS = @WA_EKPO-WERKS.
*      ENDIF.
*
*      IF WA_EKKO IS NOT INITIAL.
*        SELECT SINGLE T001~BUKRS , T001~ADRNR FROM T001 INTO @DATA(WA_T001) WHERE BUKRS = @WA_EKKO-BUKRS.
*        SELECT SINGLE J_1BBRANCH~BUKRS, J_1BBRANCH~GSTIN FROM J_1BBRANCH INTO @DATA(WA_J_1BBRANCH) WHERE BUKRS = @WA_EKKO-BUKRS.
*
*      ENDIF.
*      LV_ADRC = WA_LFA1-ADRNR.
*      LV_ADRC1 = LV_PADRNR.
*      LV_ADRC2 = WA_T001-ADRNR.
*
**    ENDIF.
*
*      SELECT MARA~MATNR  MARA~MATKL  MARA~ZZPO_ORDER_TXT  MARA~SIZE1 MARA~COLOR FROM MARA INTO CORRESPONDING FIELDS OF TABLE IT_MARA FOR ALL ENTRIES IN IT_EKPO WHERE MATNR = IT_EKPO-MATNR .
*      SELECT T023T~MATKL , T023T~WGBEZ , T023T~WGBEZ60 FROM T023T INTO TABLE @DATA(IT_T023T) FOR ALL ENTRIES IN @IT_EKPO WHERE MATKL = @IT_EKPO-MATKL.
*      SELECT * FROM MAKT INTO TABLE IT_MAKT
*        FOR ALL ENTRIES IN PO_ITEM
*        WHERE MATNR = PO_ITEM-MATNR AND SPRAS EQ SY-LANGU.
*
*      WA_POHEADER-AD_NAME = WA_LFA1-NAME1.
*      WA_POHEADER-LIFNR = HEADER-VENDOR.
*      WA_POHEADER-AEDAT =  WA_EKKO-AEDAT  .
*      WA_POHEADER-ZUNAME = IM_HEADER-ZUNAME.
*      LV_GSTIN_V = WA_LFA1-STCD3.
*      LV_GSTIN_C = WA_J_1BBRANCH-GSTIN.
**    WA_POHEADER-REF_PO =  WA_ZINW_T_HDR-EBELN.                             ""TATKAL PO
**    WA_POHEADER-BILL_TAT =  WA_ZINW_T_HDR-BILL_DATE.                      ""TATKAL PO BILL DATE
*      SELECT SINGLE EKET~EBELN , EKET~EINDT FROM EKET INTO @DATA(WA_EKET) WHERE EBELN = @LV_EBELN.
*      WA_POHEADER-DEL_BY = WA_EKET-EINDT.
*
*      SELECT STPO~STLNR,
*             STPO~IDNRK,
*             STPO~POSNR,
*             STPO~MENGE,
*             MAST~MATNR,
*             MAST~WERKS,
*             MAST~STLAL,
*             MARA~SIZE1
*             INTO TABLE @DATA(IT_SIZE)
*             FROM STPO AS STPO
*             INNER JOIN MAST AS MAST ON STPO~STLNR = MAST~STLNR
*             INNER JOIN MARA AS MARA ON MARA~MATNR = STPO~IDNRK
*             FOR ALL ENTRIES IN @IT_MARA
*             WHERE STPO~IDNRK = @IT_MARA-MATNR.


*          LOOP AT IT_EKPO INTO WA_EKPO.
**      "
*      IF WA_EKPO-ZZSET_MATERIAL IS NOT INITIAL.
*        DATA(IT_EKPO_SET) = IT_EKPO.
*        DELETE IT_EKPO_SET WHERE ZZSET_MATERIAL <> WA_EKPO-ZZSET_MATERIAL.
*        SORT IT_EKPO_SET BY ZZSET_MATERIAL.
*        DESCRIBE TABLE IT_EKPO_SET LINES DATA(LV_LINES_SET).
*        DELETE ADJACENT DUPLICATES FROM IT_EKPO_SET COMPARING ZZSET_MATERIAL.
*        READ TABLE IT_EKPO_SET INTO WA_EKPO_SET WITH KEY ZZSET_MATERIAL = WA_EKPO-ZZSET_MATERIAL.
*        READ TABLE IT_POITEM WITH KEY MATNR = WA_EKPO-ZZSET_MATERIAL TRANSPORTING NO FIELDS .
*        IF SY-SUBRC <> 0.
*          WA_POITEM-MATNR = WA_EKPO_SET-ZZSET_MATERIAL .
*          WA_POITEM-MENGE = WA_EKPO_SET-MENGE.
*          WA_POITEM-MT_GRP = WA_EKPO_SET-MATKL.
*          LV_POITEM = LV_POITEM + 10.
*          WA_POITEM-EBELP = LV_POITEM.
*          WA_POITEM-NETPR = WA_EKPO_SET-NETPR * LV_LINES_SET.
*          WA_POITEM-NETAMT  = WA_POITEM-NETPR * WA_POITEM-MENGE.
*          ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*
*          LOOP AT IT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPO>) WHERE ZZSET_MATERIAL = WA_EKPO_SET-ZZSET_MATERIAL.
*            IF WA_POITEM-SIZE IS INITIAL.
*              WA_POITEM-SIZE = <LS_EKPO>-WRF_CHARSTC2 .
*            ELSE.
*              WA_POITEM-SIZE = WA_POITEM-SIZE && '-' && <LS_EKPO>-WRF_CHARSTC2 .
*            ENDIF.
**          CONCATENATE  WA_POITEM-SIZE '-'  WA_EKPO_set-WRF_CHARSTC2  INTO  WA_POITEM-SIZE .
*          ENDLOOP.
*          CLEAR: WA_MARA.
**          READ TABLE IT_MAKT INTO WA_MAKT WITH  KEY MATNR = WA_PO_ITEM-MATNR .
*          READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T1>) WITH KEY MATKL = WA_EKPO-MATKL.
*          IF SY-SUBRC = 0 AND WA_POITEM-WGBEZ IS INITIAL  .
*            WA_POITEM-WGBEZ = <WA_T023T1>-WGBEZ60.
*          ENDIF.
*************************END SET******************************
      "
      SELECT SINGLE  ekko~ebeln ekko~bukrs ekko~aedat ekko~bedat ekko~lifnr ekko~user_name ekko~bsart ekko~user_name ekko~ernam ekko~bsart
       FROM ekko INTO CORRESPONDING FIELDS OF wa_ekko_p
       WHERE ebeln = lv_ebeln AND bsart = 'ZTAT' .

      IF wa_ekko_p IS NOT INITIAL.
        SELECT
         ebeln
         ebelp
         menge
         werks
         matnr
         meins
         matkl
         netpr
         netwr
         zzset_material
         wrf_charstc2    FROM ekpo INTO TABLE it_ekpo_p
                          WHERE ebeln = lv_ebeln.

        SELECT SINGLE * FROM zinw_t_hdr INTO @DATA(wa_zinw_t_hdr_t) WHERE tat_po = @wa_ekko_p-ebeln.
      ENDIF.
      READ TABLE it_ekpo_p INTO wa_ekpo_p INDEX 1.
      IF wa_ekpo_p IS NOT INITIAL.
        SELECT SINGLE lfa1~stcd3 FROM lfa1 INTO @wa_poheader-gstinp WHERE werks = @wa_ekpo_p-werks.
      ENDIF.
      IF wa_zinw_t_hdr_t IS NOT INITIAL.

        SELECT * FROM zinw_t_item INTO TABLE it_zinw_t_item_p
                 WHERE ebeln = wa_zinw_t_hdr_t-ebeln.

        SELECT mara~matnr  mara~matkl  mara~zzpo_order_txt  mara~size1 mara~color mara~ean11 FROM mara INTO CORRESPONDING FIELDS OF TABLE it_mara FOR ALL ENTRIES IN it_ekpo_p WHERE matnr = it_ekpo_p-matnr .
        IF it_mara IS NOT INITIAL.

          SELECT
            matnr
            maktx FROM makt INTO TABLE it_makt FOR ALL ENTRIES IN it_mara WHERE matnr =  it_mara-matnr.

        ENDIF.
        SELECT t023t~matkl , t023t~wgbez , t023t~wgbez60 FROM t023t INTO TABLE @DATA(it_t023t_t) FOR ALL ENTRIES IN @it_ekpo_p WHERE matkl = @it_ekpo_p-matkl.

      ENDIF.
      lv_billd = wa_zinw_t_hdr_t-bill_date.
      lv_rpo   = wa_zinw_t_hdr_t-ebeln.
      lv_ername = wa_ekko_p-ernam.
*      IF WA_EKKO_P-USER_NAME IS INITIAL.
      wa_poheader-zuname = lv_ername .
      wa_poheader-inwd_doc = wa_zinw_t_hdr_t-inwd_doc.
      wa_poheader-bill_text = 'Bill No :'.
      wa_poheader-bill_num  = wa_zinw_t_hdr_t-bill_num.
      wa_poheader-potype    = wa_ekko_p-bsart .
      CLEAR : sl_no.
      LOOP AT it_ekpo_p INTO wa_ekpo_p.      "" WA_ZINW_T_ITEM_P-EBELN AND MATNR = WA_ZINW_T_ITEM_P-MATNR  .

        sl_no = sl_no + 1.
        wa_poitem-zsl = sl_no.

*
        wa_poitem-mt_grp = wa_ekpo_p-matkl.
        wa_poitem-menge = wa_ekpo_p-menge.
        wa_poitem-netpr = wa_ekpo_p-netpr.
        wa_poitem-mt_grp = wa_ekpo_p-matkl.
        wa_poitem-netamt  = wa_ekpo_p-netpr * wa_ekpo-menge.
        ADD wa_poitem-netamt TO wa_poheader-total.

        lv_poitem = lv_poitem + 10.
        wa_poitem-ebelp = lv_poitem.


        CLEAR : wa_ekko_p .
        READ TABLE it_ekko_p INTO wa_ekko_p WITH KEY ebeln = lv_ebeln bsart = 'ZTAT'  .
*        READ TABLE IT_EKPO_P INTO WA_EKPO_P WITH KEY EBELN = WA_ZINW_T_ITEM_P-EBELN MATNR = WA_ZINW_T_ITEM_P-MATNR .
        IF sy-subrc = 0.
          wa_poheader-bsart =  wa_ekko_p-bsart .
        ENDIF.
        READ TABLE it_zinw_t_item_p  INTO wa_zinw_t_item_p WITH KEY ebeln = wa_zinw_t_hdr_t-ebeln matnr = wa_ekpo_p-matnr.                ""WA_ZINW_T_ITEM_P-EBELN MATNR = WA_ZINW_T_ITEM_P-MATNR .
*        IF SY-SUBRC = 0.
*          WA_POITEM-MT_GRP = WA_EKPO_P-MATKL.
*          WA_POITEM-MENGE = WA_EKPO_P-MENGE.
*          WA_POITEM-NETPR = WA_EKPO_P-NETPR.
*          WA_POITEM-MT_GRP = WA_EKPO_P-MATKL.
*          WA_POITEM-NETAMT  = WA_EKPO_P-NETPR * WA_EKPO-MENGE.
*          ADD WA_POITEM-NETAMT TO WA_POHEADER-TOTAL.
*
*          LV_POITEM = LV_POITEM + 10.
*          WA_POITEM-EBELP = LV_POITEM.
**
*        ENDIF.

*        READ TABLE IT_ZINW_T_HDR INTO WA_ZINW_T_HDR WITH KEY TAT_PO = WA_EKKO_P-EBELN.
*        IF SY-SUBRC = 0.
*
*          LV_BILLD = WA_ZINW_T_HDR-BILL_DATE.
*          LV_RPO   = WA_ZINW_T_HDR-EBELN.
*
*        ENDIF.
        READ TABLE it_t023t_t ASSIGNING FIELD-SYMBOL(<wa_t023t_t>) WITH KEY matkl = wa_ekpo_p-matkl.
        IF sy-subrc = 0.
          wa_poitem-wgbez = <wa_t023t_t>-wgbez60.
          wa_poitem-matkl = <wa_t023t_t>-matkl.
        ENDIF.
        REFRESH :it_lines[].


        REFRESH :it_lines[].
        CLEAR lv_name1.
        CONCATENATE wa_zinw_t_item_p-ebeln wa_zinw_t_item_p-ebelp INTO lv_name1.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = 'F03'
            language                = 'E'
            name                    = lv_name1
            object                  = 'EKPO'
          TABLES
            lines                   = it_lines[]
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        LOOP AT it_lines.

          CONCATENATE it_lines-tdline wa_poitem-remarks INTO wa_poitem-remarks .
          CLEAR it_lines .

        ENDLOOP.

        REFRESH :it_lines2[].

        CLEAR lv_name1.
        CONCATENATE wa_zinw_t_item_p-ebeln wa_zinw_t_item_p-ebelp INTO lv_name2.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = 'F07'
            language                = 'E'
            name                    = lv_name2
            object                  = 'EKPO'
*           ARCHIVE_HANDLE          = 0
*           LOCAL_CAT               = ' '
*       IMPORTING
*           HEADER                  =
*           OLD_LINE_COUNTER        =
          TABLES
            lines                   = it_lines2[]
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.


        LOOP AT it_lines2.

          CONCATENATE it_lines2-tdline wa_poitem-style INTO wa_poitem-style .
          CLEAR it_lines2 .

        ENDLOOP.
        CLEAR : wa_mara.
        READ TABLE it_mara INTO wa_mara WITH  KEY matnr = wa_ekpo_p-matnr .
        IF wa_mara-ean11 IS NOT INITIAL.
          wa_poitem-ean11 =  wa_mara-ean11.
        ENDIF.

        CLEAR :wa_poheader-group_id .
        IF wa_mara-matkl IS NOT INITIAL .
          CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
            EXPORTING
              matkl       = wa_mara-matkl
              spras       = sy-langu
            TABLES
              o_wgh01     = it_o_wgh01
            EXCEPTIONS
              no_basis_mg = 1
              no_mg_hier  = 2
              OTHERS      = 3.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
        READ TABLE it_o_wgh01 INTO wa_o_wgh01 INDEX 1.
        IF sy-subrc = 0.
          wa_poheader-group_id = wa_o_wgh01-wwgha.
          CLEAR wa_o_wgh01.
        ENDIF.
        READ TABLE it_makt INTO wa_makt WITH KEY matnr = wa_mara-matnr .
        IF sy-subrc = 0.
          wa_poitem-maktx = wa_makt-maktx.
        ENDIF.

        wa_poitem-size = wa_mara-size1.
        IF wa_mara-color IS NOT INITIAL.
          wa_poitem-color = wa_mara-color.
        ELSE.

          REFRESH :it_lines3[].

          CLEAR lv_name1.
          CONCATENATE wa_zinw_t_item_p-ebeln wa_zinw_t_item_p-ebelp INTO lv_name3.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
*             CLIENT                  = SY-MANDT
              id                      = 'F08'
              language                = 'E'
              name                    = lv_name3
              object                  = 'EKPO'
*             ARCHIVE_HANDLE          = 0
*             LOCAL_CAT               = ' '
*       IMPORTING
*             HEADER                  =
*             OLD_LINE_COUNTER        =
            TABLES
              lines                   = it_lines3[]
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.


          LOOP AT it_lines3.

            CONCATENATE it_lines3-tdline wa_poitem-color INTO wa_poitem-color .
            CLEAR it_lines3 .

          ENDLOOP.

          APPEND wa_poitem TO it_poitem.
          CLEAR : wa_poitem.

        ENDIF.

      ENDLOOP.
*      IF  WA_EKKO_P-bsart = 'ztat'.
      wa_poheader-text = 'GRPO Inward :'.
*      ENDIF.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZPURCHASE_ORDER_FORM'
        IMPORTING
          fm_name            = fmname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


      IF print_prieview IS NOT INITIAL.
        ls_outputop-tddest  = 'LP01'.
      ELSE.
        ls_ctrlop-getotf = abap_true.
        ls_ctrlop-no_dialog = 'X'.
        ls_ctrlop-langu = sy-langu.

        ls_outputop = is_output_options.
        ls_outputop-tdnoprev = abap_true.
        ls_outputop-tddest  = 'LP01'.
      ENDIF.



      "
*      LS_CTRLOP-GETOTF = ABAP_TRUE.
*      LS_CTRLOP-NO_DIALOG = 'X'.
*      LS_CTRLOP-LANGU = SY-LANGU.
*
*      LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
*      LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
*      LS_OUTPUTOP-TDDEST  = 'LP01'.
      CLEAR : lv_heading.
      lv_heading = 'TATKAL PURCHASE ORDER FOR EXCESS RECIEVED'.
      CALL FUNCTION fmname
        EXPORTING
          control_parameters   = ls_ctrlop
          output_options       = ls_outputop
          wa_poheader          = wa_poheader
          lv_ebeln             = lv_ebeln
          lv_adrc              = lv_adrc
          lv_adrc1             = lv_adrc1
          lv_adrc2             = lv_adrc2
          lv_words             = lv_words
          lv_gstin_v           = lv_gstin_v
          lv_gstin_c           = lv_gstin_c
          lv_heading           = lv_heading
          lv_billd             = lv_billd
          lv_rpo               = lv_rpo
          lv_ref_po            = lv_ref_po
          lv_bill_d            = lv_bill_d
          lv_ername            = lv_ername
          po_qr                = lv_ebeln
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        TABLES
          it_poitem            = it_poitem
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.
**           Implement suitable error handling here
      ENDIF.

*      ELSE.
      IF print_prieview IS INITIAL.
        lt_otf = ls_job_output_info-otfdata.

*      BREAK-POINT.
        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
            max_linewidth         = 132
          IMPORTING
            bin_filesize          = ls_bin_filesize
            bin_file              = lv_otf
          TABLES
            otf                   = lt_otf[]
            lines                 = lt_lines[]
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4.

*      ENDIF.

        CALL METHOD cl_document_bcs=>xstring_to_solix
          EXPORTING
            ip_xstring = lv_otf
          RECEIVING
            rt_solix   = lt_pdf_data[].

        TRY.
            REFRESH main_text1.

*-------- create persistent send request ------------------------
            send_request = cl_bcs=>create_persistent( ).

            CLEAR ls_main_text1.
            ls_main_text1 = 'To,'.
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 = '<BR>'.
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 = 'All Concerned' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 = '<BR>'.
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 = '<BR>'.
            APPEND ls_main_text TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 = 'Sub: Tatkal Purchase Order'.
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>'.
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>'.
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  'The following Tatkal Purchase Order ,Please take necessary action:' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.
            ls_text =  | VENDOR NAME  : { wa_poheader-ad_name } | .
            CLEAR ls_main_text1.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            ls_main_text1 =   ls_text1 .
            APPEND ls_main_text1 TO main_text1.


            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            ls_text1 =  | TATKAL ORDER NO  : { lv_ebeln  } | .
            CLEAR ls_main_text1.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            ls_main_text1 =   ls_text1 .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            ls_text2 =  | PO. APPROVED DATE  : { p_aedat  } | .
            CLEAR ls_main_text1.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            ls_main_text1 =   ls_text2 .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            ls_main_text1 =  'REMARKS :Tatkal PO Created'   .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  'From.' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  'PurchaseDept.' .
            APPEND ls_main_text1 TO main_text1.


            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND ls_main_text1 TO main_text1.


            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  'clarifications contact TSG/MKTG.dept.' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '<BR>' .
            APPEND ls_main_text1 TO main_text1.

            CLEAR ls_main_text1.
            ls_main_text1 =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND ls_main_text1 TO main_text1.

          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.

        ENDTRY.
*    CLEAR :LV_DOC_SUBJECT3.
        CONCATENATE 'Tatkal Purchase Order' lv_ebeln  '.pdf' INTO lv_doc_subject.

        TRY .
            document = cl_document_bcs=>create_document(
                i_type    = 'HTM'
                i_text    = main_text1
                i_subject = lv_doc_subject ).
          CATCH cx_document_bcs .
        ENDTRY.
        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject
                                        i_att_content_hex = lt_pdf_data ).

          CATCH cx_document_bcs.
        ENDTRY.
        TRY.

*     add document object to send request
            send_request->set_document( document ).
**** Start of Changes By Suri : 21.08.2019
            v_send_request = cl_sapuser_bcs=>create( sy-uname ).
*            V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( conv SYST_UNAME('SUPERSTORESPO') ).
**** End of Changes By Suri : 21.08.2019

            CALL METHOD send_request->set_sender
              EXPORTING
                i_sender = v_send_request.
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'dummyposap@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'anuanilmehta@yahoo.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.
*
*          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*          SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*          CLEAR I_ADDRESS_STRING.

**** START OF CHANGES BY SURI : 18.11.2019
**** Sending Mail to Vendor for Specific Groups

*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC2>).
*              I_ADDRESS_STRING = <WA_TVARVC2>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
**          RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(I_ADDRESS_STRING).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.

*--> Commented - Needed for all groups -> sjena <- 06.02.2020 14:32:13
***            IF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
***                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
***                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.
            CLEAR : i_address_string.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
*****************************            commeneted on (16-2-20)    *******************************
            recipient = cl_cam_address_bcs=>create_internet_address( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
            send_request->add_recipient( recipient ).
****************************            end(16-2-20)  ************************************************
***            ENDIF.

*** End of Changes By Suri : 18.11.2019
**** START OF CHANGES BY SURI : 21.08.2019
**** Sending Mail to Vendor for Specific Groups
*            IF WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE1'OR WA_POHEADER-GROUP_ID = 'COSMETICS' OR
*               WA_POHEADER-GROUP_ID = 'FOOTWARE' OR WA_POHEADER-GROUP_ID = 'FOOTWARE1' OR WA_POHEADER-GROUP_ID = 'FOOTWARE_1' OR
*               WA_POHEADER-GROUP_ID = 'BAGS' OR WA_POHEADER-GROUP_ID = 'BAGS1' OR WA_POHEADER-GROUP_ID = 'MOBILES' OR
*               WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREDYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLREADY' .
*              CLEAR : I_ADDRESS_STRING.
*              SELECT SINGLE SMTP_ADDR INTO I_ADDRESS_STRING FROM ADR6 WHERE ADDRNUMBER = WA_LFA1-ADRNR.
*              IF I_ADDRESS_STRING IS NOT INITIAL.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
*                SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              ENDIF.
*            ENDIF.
**** End of Changes By Suri : 21.08.2019
*     ---------- send document ---------------------------------------
            sent_to_all = send_request->send( i_with_error_screen = 'X' ).

            COMMIT WORK.

            IF sent_to_all IS INITIAL.
              MESSAGE i500(sbcoms).
            ELSE.
              es_msg = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.
        ENDTRY.
      ENDIF.

***********service po********
    ELSEIF service_po IS NOT INITIAL.


      p_aedat  = sy-datum .
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          input  = p_aedat
        IMPORTING
          output = p_aedat.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZMM_SERVICE_PO_FORM'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          fm_name            = fmname1
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF print_prieview IS NOT INITIAL.
        ls_outputop-tddest  = 'LP01'.
      ELSE.
        ls_ctrlop-getotf = abap_true.
        ls_ctrlop-no_dialog = 'X'.
        ls_ctrlop-langu = sy-langu.

        ls_outputop = is_output_options.
        ls_outputop-tdnoprev = abap_true.
        ls_outputop-tddest  = 'LP01'.
      ENDIF.

      CALL FUNCTION fmname1
        EXPORTING
          control_parameters   = ls_ctrlop
          output_options       = ls_outputop
          lv_ven               = lv_ven
          lv_shp               = lv_shp
          wa_hdr               = wa_hdr
          lv_w                 = lv_w
          qr_code              = wa_hdr-qr_code
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        TABLES
          t_final              = t_final
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*      ELSE.
      IF print_prieview IS INITIAL.
        lt_otf4 = ls_job_output_info-otfdata.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
            max_linewidth         = 132
          IMPORTING
            bin_filesize          = ls_bin_filesize4
            bin_file              = lv_otf4
          TABLES
            otf                   = lt_otf4[]
            lines                 = lt_lines4[]
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4.
*      ENDIF.



        CALL METHOD cl_document_bcs=>xstring_to_solix
          EXPORTING
            ip_xstring = lv_otf4
          RECEIVING
            rt_solix   = lt_pdf_data4[].
*    ENDIF.


        TRY.
            REFRESH main_text.

*-------- create persistent send request ------------------------
            send_request = cl_bcs=>create_persistent( ).

            CLEAR ls_main_text.
            ls_main_text = 'To,'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = 'All Concerned' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text = 'Sub: Service Purchase Order release/amendment'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'The following Service Purchase Order is released/amendment. Please take necessary action:' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.
            ls_text =  | VENDOR NAME  : { wa_poheader-ad_name } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
            ls_main_text =   ls_text .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            ls_text1 =  | SERVICE PURCHASE ORDER NO  : { lv_ebeln  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            ls_main_text =   ls_text1 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            ls_text2 =  | PO. APPROVED DATE  : { p_aedat  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PO. APPROVED DATE'  : { WA_POHEADER-AEDAT }| .
            ls_main_text =   ls_text2 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'REMARKS'  : { WA_POITEM-REMARKS }| .
            ls_main_text =  'REMARKS : Service Po Created'   .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'From.' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'PurchaseDept.' .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
            APPEND ls_main_text TO main_text.


            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'clarifications contact TSG/MKTG.dept.' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>' .
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
            APPEND ls_main_text TO main_text.

          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.

        ENDTRY.


        CLEAR lv_doc_subject4.
        CONCATENATE 'Service Purchase Order' lv_ebeln  '.pdf' INTO lv_doc_subject4.

        TRY .
            document = cl_document_bcs=>create_document(
                i_type    = 'HTM'
                i_text    = main_text
                i_subject = lv_doc_subject4 ).
          CATCH cx_document_bcs .

        ENDTRY.
        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject4
                                        i_att_content_hex = lt_pdf_data4 ).

          CATCH cx_document_bcs.
        ENDTRY.

        TRY.
*-------- create persistent send request ------------------------
            send_request = cl_bcs=>create_persistent( ).
*     add document object to send request
            send_request->set_document( document ).


            v_send_request = cl_sapuser_bcs=>create( sy-uname ).

            CALL METHOD send_request->set_sender
              EXPORTING
                i_sender = v_send_request.

*** Start of Changes By Suri : 21.08.2019
*** Sending Mail to Vendor for Specific Groups
*            LOOP AT IT_TVARVC ASSIGNING FIELD-SYMBOL(<WA_TVARVC3>).
*              I_ADDRESS_STRING = <WA_TVARVC3>-LOW.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*            ENDLOOP.

*--> Commented - Needed for all groups -> sjena <- 06.02.2020 14:37:26
***            IF WA_POHEADER-GROUP_ID = 'COSMETICS'  OR WA_POHEADER-GROUP_ID = 'FOOTWARE' OR WA_POHEADER-GROUP_ID = 'FOOTWARE1' OR
***               WA_POHEADER-GROUP_ID = 'FOOTWARE_1' OR WA_POHEADER-GROUP_ID = 'BAGS'     OR WA_POHEADER-GROUP_ID = 'BAGS1'     OR
***               WA_POHEADER-GROUP_ID = 'MOBILES'.
****                CLEAR : I_ADDRESS_STRING.
****                SELECT SINGLE SMTP_ADDR INTO I_ADDRESS_STRING FROM ADR6 WHERE ADDRNUMBER = WA_LFA1-ADRNR.
****                IF I_ADDRESS_STRING IS NOT INITIAL.
****                  RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING ).
****                  SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
****                ENDIF.
***            ELSEIF WA_POHEADER-GROUP_ID = 'SAREE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADE' OR WA_POHEADER-GROUP_ID = 'SILK' OR
***                   WA_POHEADER-GROUP_ID = 'CHUDIMATERIAL' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'BOYSREADYMADE' OR
***                   WA_POHEADER-GROUP_ID = 'INNERWEAR'.
            CLEAR : i_address_string.
*                RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'SANKARDURAI2009@GMAIL.COM' ).
***********************************            commented on (16-2-20)      *******************************************
            recipient = cl_cam_address_bcs=>create_internet_address( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
            send_request->add_recipient( recipient ).
*******************            end(16-2-20)   ****************************************
***            ENDIF.
** End of Changes By Suri : 21.08.2019


******added by bhavani
*
*            IF WA_POHEADER-GROUP_ID = 'FOOTWARE'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Pothi3080@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'COSMETICS' OR  WA_POHEADER-GROUP_ID = 'IMITATION'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Sudar@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF WA_POHEADER-GROUP_ID = 'TOYS' OR   WA_POHEADER-GROUP_ID = 'GIFTSANDFLOWERS' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Prakash.arikrish@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
**            ELSEIF  WA_POHEADER-GROUP_ID = 'CONSUMABLES' .
**              CLEAR I_ADDRESS_STRING.
**              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Augustin@saravanastores.net' )."( I_ADDRESS_STRING ).
**              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'FURNITURE' OR WA_POHEADER-GROUP_ID = 'BIGAPPLIANCES' OR WA_POHEADER-GROUP_ID = 'SMALLAPPLIANCES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'jaichandran@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' .
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'Chermananu1982@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MOBILES' OR WA_POHEADER-GROUP_ID = 'ELECTRONICS' OR WA_POHEADER-GROUP_ID = 'WATCHES'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'elect@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE' OR WA_POHEADER-GROUP_ID = 'GIRLSREADYMADE' OR WA_POHEADER-GROUP_ID = 'LADIESREADYMADEN' OR WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'.
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'murugan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'INNERWARE' OR WA_POHEADER-GROUP_ID = 'RIDEONSANDCYCLES' OR WA_POHEADER-GROUP_ID = 'JUSTBORN' .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'pkannan@saravanastores.net' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'BOYSREDYMADE'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'thangaduraivo8@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*
*            ELSEIF  WA_POHEADER-GROUP_ID = 'MENSREADYMADEN'  .
*              CLEAR I_ADDRESS_STRING.
*              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'kmannanmaha@gmail.com' )."( I_ADDRESS_STRING ).
*              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*            ENDIF.
************Ended by bhavani

*     ---------- send document ---------------------------------------
            sent_to_all = send_request->send( i_with_error_screen = 'X' ).

            COMMIT WORK.

            IF sent_to_all IS INITIAL.
              MESSAGE i500(sbcoms).
            ELSE.
*        MESSAGE s022(so).
              es_msg = 'Email triggered successfully' ."TYPE 'S'.
            ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
