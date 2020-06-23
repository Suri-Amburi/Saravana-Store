FUNCTION zfm_agent_vendor_mail.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LV_QR_CODE) TYPE  ZINW_T_HDR-QR_CODE
*"     VALUE(RETURN_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(TATKAL_PO) TYPE  CHAR1 OPTIONAL
*"     VALUE(GRPO) TYPE  CHAR1 OPTIONAL
*"     VALUE(AGENT) TYPE  CHAR1 OPTIONAL
*"     VALUE(VENDOR) TYPE  CHAR1 OPTIONAL
*"     VALUE(PRINT_PREVIEW) TYPE  CHAR1 OPTIONAL
*"----------------------------------------------------------------------

  IF lv_qr_code IS NOT INITIAL.
    TYPES : BEGIN OF ty_ekpo,
              ebeln          TYPE ekpo-ebeln,
              ebelp          TYPE ekpo-ebelp,
              menge          TYPE ekpo-menge,
              werks          TYPE  ekpo-werks,
              matnr          TYPE  ekpo-matnr,
              meins          TYPE ekpo-meins,
              matkl          TYPE ekpo-matkl,
              netpr          TYPE  ekpo-netpr,
              zzset_material TYPE ekpo-zzset_material,
              wrf_charstc2   TYPE ekpo-wrf_charstc2,
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
           END OF ty_ekpo_pr.

    TYPES: BEGIN OF ty_ekko_pr,
             ebeln TYPE ebeln,                               "Purchasing Document Number
             bsart TYPE esart,
             aedat TYPE erdat,
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
             mblnr TYPE mblnr,                                "RETURN NO./DOCUMENT NO.
           END OF ty_mseg_pr.

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
             lifnr      TYPE lifnr,
             trns       TYPE ztrans,                               "TRANSPORTER
             lr_no      TYPE zlr,                                   "LR NO
             bill_num   TYPE zbill_num,                             "vendor invoice number
             bill_date  TYPE zbill_dat,                            "vendor invoice date
             act_no_bud TYPE zno_bud,
             mblnr      TYPE mblnr,
             mblnr_103  TYPE mblnr,
             return_po  TYPE ebeln,
             tat_po     TYPE ebeln,
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



    DATA : wa_zinw_t_status_pr TYPE ty_zinw_t_status_pr.
    DATA: it_ekko_pr        TYPE TABLE OF ty_ekko_pr,
          it_ekko1_pr       TYPE TABLE OF ty_ekko_pr,
          wa_ekko_pr        TYPE ty_ekko_pr,
          wa_ekko1_pr       TYPE ty_ekko_pr,
          it_ekpo_pr        TYPE  TABLE OF  ty_ekpo_pr,
          wa_ekpo_pr        TYPE ty_ekpo_pr,
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

    DATA :lv_hed(15) TYPE c,
          lv_val(15) TYPE c,
          lv_per     TYPE kbetr,
          lv_tax(6)  TYPE c,
*          LV_PER     TYPE char100,
          lv_s(01)   TYPE c VALUE '/'.


    DATA : po_lines        TYPE TABLE OF tline WITH HEADER LINE,
           po_text         TYPE thead-tdname,
           lv_po_text(100) TYPE c.
**************************END OF PO RETURN TYPES*********************************************************
******************START OF DECLARATION PO CREATE***********************************************************
    TYPES : BEGIN OF ty_makt ,
              matnr TYPE makt-matnr,
              maktx TYPE makt-maktx,
            END OF ty_makt .
    DATA: wa_ekko          TYPE ekko,
          lv_adrc          TYPE ad_addrnum,
          lv_ven           TYPE adrnr,
          lv_shp           TYPE adrnr,
          lv_adrc1         TYPE adrnr,
          lv_adrc2         TYPE adrnr,
          it_poitem        TYPE TABLE OF zpoitem,
          wa_poitem        TYPE zpoitem,
          wa_poheader      TYPE zpoheader,
*          WA_LFA1       TYPE LFA1,
          it_ekko          TYPE TABLE OF ekko,
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
          wa_o_wgh01       TYPE wgh01.
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
***************************************************END OF MAIL****************************************************************************************

*****************************************SATRT OF PO RETURN DECLARATION*****************************************************************

*    BREAK BREDDY.
*    if p_ebeln is INITIAL.

    SELECT
            qr_code
            ebeln
            lifnr
            trns
            lr_no
            bill_num
            bill_date
            act_no_bud
*      GPRO_USER
            mblnr
            mblnr_103
            return_po
            tat_po
            FROM zinw_t_hdr INTO TABLE it_zinw_t_hdr_pr WHERE qr_code = lv_qr_code.
*    ENDIF.
*
*    SELECT SINGLE
*  EBELN
*  BSART
*  AEDAT
*  LIFNR
*  BEDAT
*  KNUMV
*   FROM EKKO INTO WA_EKKO_PR WHERE EBELN = LV_EBELN.
    IF it_zinw_t_hdr_pr IS NOT INITIAL.
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
        FROM ekpo INTO TABLE it_ekpo_pr FOR ALL ENTRIES IN it_zinw_t_hdr_pr WHERE ebeln = it_zinw_t_hdr_pr-return_po." AND RETPO = 'X'.
    ENDIF.
    SELECT
      matnr
      ean11 FROM mara INTO TABLE it_mara_pr
            FOR ALL ENTRIES IN it_ekpo_pr
            WHERE matnr = it_ekpo_pr-matnr.

    READ TABLE it_ekpo_pr INTO wa_ekpo_pr INDEX 1.

    SELECT SINGLE
      ebeln
      mblnr
      FROM mseg INTO wa_mseg_pr WHERE ebeln = wa_ekpo_pr-ebeln.

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

*    BREAK BREDDY.
*    READ TABLE IT_ZINW_T_ITEM_PR INTO WA_ITEM_PR INDEX 1.
*    IF IT_EKPO_PR IS NOT INITIAL.


*        IF IT_ZINW_T_HDR_PR IS NOT INITIAL.
*
*          SELECT
*
*        ENDIF.




    READ TABLE it_zinw_t_hdr_pr INTO wa_zinw_t_hdr_pr INDEX 1.
    IF wa_zinw_t_hdr_pr IS NOT INITIAL.

      SELECT SINGLE
      ebeln
      bsart
      aedat
      lifnr
      bedat
      knumv
       FROM ekko INTO wa_ekko1_pr WHERE ebeln = wa_zinw_t_hdr_pr-return_po.

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


    IF wa_ekko1_pr IS NOT INITIAL.

      SELECT SINGLE
       lifnr
       land1
       name1
       ort01
       regio
       stras
       stcd3
       adrnr
       FROM lfa1 INTO wa_lfa1_pr WHERE lifnr = wa_ekko1_pr-lifnr.

      SELECT SINGLE
              ebeln
              vgabe
              belnr
              budat FROM ekbe INTO wa_ekbe_pr WHERE ebeln = wa_ekko1_pr-ebeln AND vgabe = '2'.


    ENDIF.

    SELECT ebeln
           bsart
           aedat
           lifnr
           bedat
           knumv
    FROM ekko
    INTO TABLE it_ekko_pr
    FOR ALL ENTRIES IN it_zinw_t_hdr_pr
    WHERE ebeln = it_zinw_t_hdr_pr-return_po.

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
    wa_poheader-ad_name = wa_lfa1_pr-name1.
    wa_poheader-lifnr = wa_lfa1_pr-lifnr.
    wa_poheader-aedat =  wa_ekko1_pr  .

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
*    BREAK BREDDY.
    LOOP AT it_ekpo_pr INTO wa_ekpo_pr.
      lv_sl = lv_sl + 1.
      wa_final-sl = lv_sl.

*    WA_FINAL-MWSKZ = WA_EKPO-MWSKZ.
      wa_final-menge = wa_ekpo_pr-menge.
      wa_final-netpr = wa_ekpo_pr-netpr.
      wa_final-netwr = wa_ekpo_pr-netwr.

      READ TABLE it_makt_pr INTO wa_makt_pr WITH KEY matnr = wa_ekpo_pr-matnr.
      IF sy-subrc = 0.
        wa_final-maktx = wa_makt_pr-maktx.
      ENDIF.
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
            wa_header-netpr_t = wa_header-netpr_t + wa_final-netpr_gp .
          ENDIF.
        ENDIF.

      ENDLOOP.
      READ TABLE it_mara_pr ASSIGNING FIELD-SYMBOL(<ls_mara_pr>) WITH KEY matnr = wa_ekpo_pr-matnr.
      IF sy-subrc = 0.

        wa_final-ean11 = <ls_mara_pr>-ean11.

      ENDIF.
*      BREAK BREDDY.
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
    wa_header-bedat     = wa_ekko1_pr-bedat.
    wa_header-gstin     = wa_j_1bbranch_pr-gstin.
    wa_header-smtp_addr = wa_adr6_pr-smtp_addr.
    wa_header-trns      = wa_zinw_t_hdr_pr-trns.
    wa_header-lr_no     = wa_zinw_t_hdr_pr-lr_no.
    wa_header-act_no_bud     = wa_zinw_t_hdr_pr-act_no_bud .
*  WA_HEADER-NO_BUD    = WA_ZINW_T_HDR-NO_BUD.
    wa_header-bill_num  = wa_zinw_t_hdr_pr-bill_num.
    wa_header-bill_date = wa_zinw_t_hdr_pr-bill_date.
    wa_header-ebeln     = wa_ekpo_pr-ebeln.
    wa_header-aedat     = wa_ekko1_pr-aedat.
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

****************************************************PO return****************************************************
*      BREAK BREDDY.
    CLEAR : lv_heading.
    CLEAR : p_aedat.
    IF return_po IS NOT INITIAL.

      lv_heading = 'PURCHASE ORDER'.
      p_aedat  = sy-datum .

*      BREAK BREDDY.
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          input  = p_aedat
        IMPORTING
          output = p_aedat.

      IF print_preview IS NOT INITIAL.
        ls_outputop-tddest  = 'LP01'.
      ELSE.
        ls_ctrlop-getotf = abap_true.
        ls_ctrlop-no_dialog = 'X'.
        ls_ctrlop-langu = sy-langu.

        ls_outputop = is_output_options.
        ls_outputop-tdnoprev = abap_true.
        ls_outputop-tddest  = 'LP01'.
      ENDIF.

      READ TABLE it_ekpo_pr INTO wa_ekpo_pr WITH KEY ebeln = wa_zinw_t_hdr_pr-return_po .
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

      IF print_preview IS INITIAL.
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
            ls_main_text = 'Sub: DEBIT MEMO , CREDIT MEMO, GRPO SUMMARY'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  '<BR>'.
            APPEND ls_main_text TO main_text.

            CLEAR ls_main_text.
            ls_main_text =  'The following Return,Tatkal Purchase Order is released/amendment and GRPO summary . Please take necessary action:' .
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

            ls_text1 =  | RETURN PURCHASE ORDER NO  : { wa_zinw_t_hdr_pr-return_po  } | .
            CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'PURCHASE ORDER NO'  : { LV_EBELN }| .
            ls_main_text =   ls_text1 .
            APPEND ls_main_text TO main_text.

            CLEAR ls_text1.

            ls_text1 =  | TATKAL PURCHASE ORDER NO  : { wa_zinw_t_hdr_pr-tat_po  } | .
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
            ls_main_text =  'REMARKS : Returned Po and Tatkal Created'   .
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
        CONCATENATE 'RETURN_PO' wa_zinw_t_hdr_pr-return_po '.pdf' INTO lv_doc_subject2.

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
                                        i_att_content_hex = lt_pdf_data ).

          CATCH cx_document_bcs.
        ENDTRY.
*      SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
**     add document object to send request
*            SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).
*     CLEAR : LT_PDF_DATA ,
*             LT_OTF.

      ENDIF.



*     ENDIF.
    ENDIF.
*****************************************END OF PO_RETURN DECLRATION*****************************************************************************
*      BREAK BREDDY.
*********************************START OF TATKAL PO*********************************************
    IF tatkal_po IS NOT INITIAL.

      CLEAR : p_aedat,it_poitem,wa_poitem,wa_poheader-zuname ,wa_poheader-gstinp , wa_poheader-po_qr , wa_poheader-potype .                    ""WA_POITEM,WA_POHEADER.
      lv_ref_po = 'Reference PO :'.
      lv_bill_d  = 'Bill Date :'.
      lv_heading = 'PURCHASE ORDER'.
      p_aedat  = sy-datum .
      READ TABLE it_zinw_t_hdr_pr INTO wa_zinw_t_hdr_pr WITH KEY qr_code = lv_qr_code.
      IF sy-subrc EQ 0.
        wa_poheader-po_qr = wa_zinw_t_hdr_pr-tat_po .
      ENDIF.
*      BREAK BREDDY.
      CALL FUNCTION 'CONVERSION_EXIT_GDATE_OUTPUT'
        EXPORTING
          input  = p_aedat
        IMPORTING
          output = p_aedat.


      SELECT SINGLE  ekko~ebeln ekko~bukrs ekko~aedat ekko~bedat ekko~lifnr ekko~user_name ekko~bsart ekko~user_name ekko~ernam ekko~bsart
       FROM ekko INTO CORRESPONDING FIELDS OF wa_ekko_p
       WHERE ebeln = wa_zinw_t_hdr_pr-tat_po." AND BSART = 'ZTAT' .

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
         zzset_material
         wrf_charstc2    FROM ekpo INTO TABLE it_ekpo_p
                          WHERE ebeln = wa_zinw_t_hdr_pr-tat_po.

        SELECT SINGLE * FROM zinw_t_hdr INTO @DATA(wa_zinw_t_hdr_t) WHERE qr_code = @lv_qr_code."TAT_PO = @WA_EKKO_P-EBELN.
        SELECT SINGLE name1, adrnr , werks, stcd3 , lifnr INTO @DATA(wa_lfa1) FROM lfa1 WHERE lifnr = @wa_ekko_p-lifnr.
        SELECT SINGLE j_1bbranch~bukrs, j_1bbranch~gstin FROM j_1bbranch INTO @DATA(wa_j_1bbranch) WHERE bukrs = @wa_ekko_p-bukrs.
      ENDIF.
      READ TABLE it_ekpo_p INTO wa_ekpo_p INDEX 1.
      IF wa_ekpo_p IS NOT INITIAL.
        SELECT SINGLE lfa1~stcd3 FROM lfa1 INTO @wa_poheader-gstinp WHERE werks = @wa_ekpo_p-werks.
        SELECT SINGLE t001w~adrnr  FROM t001w INTO @DATA(lv_padrnr) WHERE werks = @wa_ekpo_p-werks.
      ENDIF.

      lv_adrc = wa_lfa1-adrnr.
      lv_adrc1 = lv_padrnr.
      lv_adrc2 = lv_padrnr.
      IF wa_zinw_t_hdr_t IS NOT INITIAL.

        SELECT * FROM zinw_t_item INTO TABLE it_zinw_t_item_p
                 WHERE ebeln = wa_zinw_t_hdr_t-tat_po.

        SELECT mara~matnr  mara~matkl  mara~zzpo_order_txt  mara~size1 mara~color mara~ean11 FROM mara INTO CORRESPONDING FIELDS OF TABLE it_mara FOR ALL ENTRIES IN it_ekpo_p WHERE matnr = it_ekpo_p-matnr .
        IF it_mara IS NOT INITIAL.

          SELECT
            matnr
            maktx FROM makt INTO TABLE it_makt FOR ALL ENTRIES IN it_mara WHERE matnr =  it_mara-matnr.

        ENDIF.
        SELECT t023t~matkl , t023t~wgbez , t023t~wgbez60 FROM t023t INTO TABLE @DATA(it_t023t_t) FOR ALL ENTRIES IN @it_ekpo_p WHERE matkl = @it_ekpo_p-matkl.

      ENDIF.
      lv_billd = wa_zinw_t_hdr_t-bill_date.
      lv_rpo   = wa_zinw_t_hdr_t-tat_po.
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
        wa_poitem-netamt  = wa_ekpo_p-netpr * wa_ekpo_p-menge.
        ADD wa_poitem-netamt TO wa_poheader-total.

        lv_poitem = lv_poitem + 10.
        wa_poitem-ebelp = lv_poitem.


        CLEAR : wa_ekko_p .
        READ TABLE it_ekko_p INTO wa_ekko_p INDEX 1."WITH KEY EBELN = WA_ZINW_T_HDR_PR-EBELN." BSART = 'ZTAT'  .
*        READ TABLE IT_EKPO_P INTO WA_EKPO_P WITH KEY EBELN = WA_ZINW_T_ITEM_P-EBELN MATNR = WA_ZINW_T_ITEM_P-MATNR .
        IF sy-subrc = 0.
          wa_poheader-bsart =  wa_ekko_p-bsart .
        ENDIF.
        READ TABLE it_zinw_t_item_p  INTO wa_zinw_t_item_p WITH KEY ebeln = wa_zinw_t_hdr_t-tat_po matnr = wa_ekpo_p-matnr.                ""WA_ZINW_T_ITEM_P-EBELN MATNR = WA_ZINW_T_ITEM_P-MATNR .

        READ TABLE it_t023t_t ASSIGNING FIELD-SYMBOL(<wa_t023t_t>) WITH KEY matkl = wa_ekpo_p-matkl.
        IF sy-subrc = 0.
          wa_poitem-wgbez = <wa_t023t_t>-wgbez60.
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
      lv_gstin_v = wa_lfa1-stcd3.

      DATA : lv_amt TYPE pc207-betrg.
      lv_amt  = wa_poheader-total.
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


      IF print_preview IS NOT INITIAL.
        ls_outputop-tddest  = 'LP01'.
      ELSE.
        ls_ctrlop-getotf = abap_true.
        ls_ctrlop-no_dialog = 'X'.
        ls_ctrlop-langu = sy-langu.

        ls_outputop = is_output_options.
        ls_outputop-tdnoprev = abap_true.
        ls_outputop-tddest  = 'LP01'.
      ENDIF.

      CLEAR : lv_heading.
      lv_heading = 'TATKAL PURCHASE ORDER FOR EXCESS RECIEVED'.
      CALL FUNCTION fmname
        EXPORTING
          control_parameters   = ls_ctrlop
          output_options       = ls_outputop
          wa_poheader          = wa_poheader
          lv_ebeln             = wa_zinw_t_hdr_pr-ebeln
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
          po_qr                = wa_zinw_t_hdr_pr-ebeln
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
      IF print_preview IS INITIAL.
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
        CONCATENATE 'TATKAL_PO' wa_zinw_t_hdr_pr-tat_po '.pdf' INTO lv_doc_subject1.

        IF main_text IS INITIAL.
          TRY.
*            REFRESH MAIN_TEXT.

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
              ls_main_text = 'Sub: TATKAL PO'.
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  '<BR>'.
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  '<BR>'.
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  'The following Tatkal Purchase Order is released/amendment . Please take necessary action:' .
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

              ls_text1 =  | TATKAL PURCHASE ORDER NO  : { wa_zinw_t_hdr_pr-tat_po  } | .
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
              ls_main_text =  'REMARKS : Tatkal PO Created'   .
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

*        CLEAR LV_DOC_SUBJECT2.
*        CONCATENATE 'RETURN_PO' WA_ZINW_T_HDR_PR-EBELN '.pdf' INTO LV_DOC_SUBJECT2.
          TRY .
              document = cl_document_bcs=>create_document(
                  i_type    = 'HTM'
                  i_text    = main_text
                  i_subject = lv_doc_subject1 ).
            CATCH cx_document_bcs .

          ENDTRY.

        ENDIF.

        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject1
                                        i_att_content_hex = lt_pdf_data1 ).

          CATCH cx_document_bcs.
        ENDTRY.


      ENDIF.

    ENDIF.

**************************************************GRPO_SUMMARY**************************************************************
    IF grpo IS NOT INITIAL.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZMM_GRPO_FORM'
        IMPORTING
          fm_name            = fmname1
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF print_preview IS NOT INITIAL.
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
          lv_qr_code           = lv_qr_code
        IMPORTING
          document_output_info = ls_document_output_info
          job_output_info      = ls_job_output_info
          job_output_options   = ls_job_output_options
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.
**           Implement suitable error handling here
      ENDIF.

      IF print_preview IS INITIAL.
        lt_otf2 = ls_job_output_info-otfdata.

*      BREAK-POINT.
        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
            max_linewidth         = 132
          IMPORTING
            bin_filesize          = ls_bin_filesize
            bin_file              = lv_otf2
          TABLES
            otf                   = lt_otf2[]
            lines                 = lt_lines[]
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4.

*      ENDIF.

        CALL METHOD cl_document_bcs=>xstring_to_solix
          EXPORTING
            ip_xstring = lv_otf2
          RECEIVING
            rt_solix   = lt_pdf_data2[].

        TRY.


          CATCH cx_bcs INTO bcs_exception.
            MESSAGE i865(so) WITH bcs_exception->error_type.

        ENDTRY.

        CLEAR lv_doc_subject2.
        CONCATENATE 'GRPO_SUMMARY' '.pdf' INTO lv_doc_subject2.

        IF main_text IS INITIAL.
          TRY.
*            REFRESH MAIN_TEXT.

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
              ls_main_text = 'Sub: GRPO SUMMARY'.
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  '<BR>'.
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  '<BR>'.
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  'The following is the GRPO summary please check the attachment.' .
              APPEND ls_main_text TO main_text.

              CLEAR ls_main_text.
              ls_main_text =  '<BR>' .
              APPEND ls_main_text TO main_text.

              .
              CLEAR ls_main_text.
*      LS_MAIN_TEXT =  | 'VENDOR NAME'  : { WA_POHEADER-AD_NAME } | .
*      LS_MAIN_TEXT =  | { 'VENDOR NAME : ' } | && | { WA_POHEADER-AD_NAME } | .
*        LS_MAIN_TEXT =   'VENDOR NAME : ' .
              ls_main_text =   ls_text .
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

*        CLEAR LV_DOC_SUBJECT2.
*        CONCATENATE 'RETURN_PO' WA_ZINW_T_HDR_PR-EBELN '.pdf' INTO LV_DOC_SUBJECT2.
          TRY .
              document = cl_document_bcs=>create_document(
                  i_type    = 'HTM'
                  i_text    = main_text
                  i_subject = lv_doc_subject2 ).
            CATCH cx_document_bcs .

          ENDTRY.

        ENDIF.

*        TRY .
*            DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
*                I_TYPE    = 'HTM'
*                I_TEXT    = MAIN_TEXT
*                I_SUBJECT = LV_DOC_SUBJECT2 ).
*          CATCH CX_DOCUMENT_BCS .
*
*        ENDTRY.

        TRY.
            document->add_attachment( i_attachment_type = 'BIN'
                                        i_attachment_subject = lv_doc_subject2
                                        i_att_content_hex = lt_pdf_data2 ).

          CATCH cx_document_bcs.
        ENDTRY.
*        SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
**     add document object to send request
*            SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).
*        CLEAR : LT_PDF_DATA ,
*             LT_OTF.

      ENDIF.


***********************************************************************************************************************************
    ENDIF.
    IF agent IS NOT INITIAL.

      send_request = cl_bcs=>create_persistent( ).
*     add document object to send request
      send_request->set_document( document ).
      v_send_request = cl_sapuser_bcs=>create( sy-uname ).
      CALL METHOD send_request->set_sender
        EXPORTING
          i_sender = v_send_request.

***   Start Of Changes By Suri : 23.03.2020 : 13:20:00
      SELECT SINGLE klah~class
              INTO @DATA(lv_group)
              FROM klah AS klah
              INNER JOIN kssk AS kssk  ON kssk~clint = klah~clint
              INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
              INNER JOIN ekpo AS ekpo  ON klah1~class = ekpo~matkl
              WHERE klah~klart = '026' AND ekpo~ebeln = @wa_zinw_t_hdr_pr-ebeln.
      IF sy-subrc  IS INITIAL.
        SELECT DISTINCT aemail FROM zgroup_ven INTO TABLE @DATA(lt_email) WHERE class = @lv_group AND lifnr = @wa_zinw_t_hdr_pr-lifnr.
        DELETE lt_email WHERE aemail IS INITIAL.
        LOOP AT lt_email ASSIGNING FIELD-SYMBOL(<ls_email>).
          i_addrnumber = <ls_email>-aemail.
          recipient    = cl_cam_address_bcs=>create_internet_address( i_addrnumber ).
          send_request->add_recipient( recipient ).
        ENDLOOP.
      ENDIF.
***   End Of Changes By Suri : 23.03.2020 : 13:20:00
      TRY.
          sent_to_all = send_request->send( i_with_error_screen = 'X' ).
          COMMIT WORK.

          IF sent_to_all IS INITIAL.
            MESSAGE i500(sbcoms).
          ELSE.
            es_msg = 'Email triggered successfully' ."TYPE 'S'.
            MESSAGE s846(so) WITH es_msg.
          ENDIF.
        CATCH cx_bcs INTO bcs_exception.
          MESSAGE i865(so) WITH bcs_exception->error_type.
      ENDTRY.

    ENDIF.

    IF vendor IS NOT INITIAL.
      TRY.
          send_request = cl_bcs=>create_persistent( ).
*     add document object to send request
          send_request->set_document( document ).

          v_send_request = cl_sapuser_bcs=>create( sy-uname ).

          CALL METHOD send_request->set_sender
            EXPORTING
              i_sender = v_send_request.
          CLEAR : i_address_string.
          recipient = cl_cam_address_bcs=>create_internet_address( 'VR@SARAVANASTORES.NET' ).     " 18.11.2019
          send_request->add_recipient( recipient ).
          sent_to_all = send_request->send( i_with_error_screen = 'X' ).
          COMMIT WORK.
          IF sent_to_all IS INITIAL.
            MESSAGE i500(sbcoms).
          ELSE.
*        MESSAGE s022(so).
            es_msg = 'Email triggered successfully' ."TYPE 'S'.
            MESSAGE s846(so) WITH es_msg.
          ENDIF.

        CATCH cx_bcs INTO bcs_exception.
          MESSAGE i865(so) WITH bcs_exception->error_type.
      ENDTRY.

    ENDIF.

  ENDIF.
ENDFUNCTION.
