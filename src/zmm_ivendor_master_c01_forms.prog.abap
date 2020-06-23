*&---------------------------------------------------------------------*
*& Include          ZMM_IVENDOR_MASTER_C01_FORMS
*&---------------------------------------------------------------------*
FORM get_filename  CHANGING fp_p_file TYPE localfile.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      file_table              = li_filetable
      rc                      = lv_return_code
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE   li_filetable INTO lx_filetable INDEX 1.
  fp_p_file = lx_filetable-filename.


  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TA_FLATFILE  text
*----------------------------------------------------------------------*
FORM get_data  CHANGING ta_flatfile TYPE ta_t_flatfile.

  DATA : li_temp   TYPE TABLE OF alsmex_tabline,
         lw_temp   TYPE alsmex_tabline,
         lw_intern TYPE  kcde_cells,
         li_intern TYPE STANDARD TABLE OF kcde_cells,
         lv_index  TYPE i,
         i_type    TYPE truxs_t_text_data.

*  IF ename EQ 'XLSX' OR ename EQ 'XLS'.
*
*    REFRESH ta_flatfile[].

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
*     I_LINE_HEADER        =
      i_tab_raw_data       = i_type
      i_filename           = p_file
    TABLES
      i_tab_converted_data = ta_flatfile[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  DELETE ta_flatfile FROM 1 TO 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  ELSE.
*    MESSAGE e398(00) WITH 'Invalid File Type'.
*  ENDIF.

  IF ta_flatfile IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_vendor .


  DATA:it_ret1          TYPE TABLE OF bapiret2,

       it_vendors       TYPE vmds_ei_extern_t,
       wa_vendors       TYPE vmds_ei_extern,

       lt_bank          TYPE cvis_ei_bankdetail_t,
       bank             TYPE cvis_ei_cvi_bankdetail,

       it_company       TYPE vmds_ei_company_t,
       wa_company       TYPE vmds_ei_company,

       wa_company_data  TYPE vmds_ei_vmd_company,

       lt_dunn          TYPE vmds_ei_dunning_t,
       dunn             TYPE vmds_ei_dunning,

       lt_tax           TYPE vmds_ei_wtax_type_t,
       tax              TYPE vmds_ei_wtax_type,

       it_company_data  TYPE vmds_ei_vmd_company,
       ls_purchase_data TYPE vmds_ei_vmd_purchasing,

       it_purchase      TYPE vmds_ei_purchasing_t,
       wa_purchase      TYPE vmds_ei_purchasing,
       it_partner_func  TYPE vmds_ei_functions_t,
       wa_partner_func  TYPE vmds_ei_functions,

       data_correct     TYPE vmds_ei_main,
       msg_correct      TYPE cvis_message,
       data_defect      TYPE vmds_ei_main,
       msg_defect       TYPE cvis_message,
       git_final        TYPE vmds_ei_main,
       wa_retu          TYPE bapiret2,
       ret              TYPE bapiret2_t,

       lv_date(8).

  TYPES:BEGIN OF ty_but000,
          partner	 TYPE bu_partner,
          bu_sort1 TYPE bu_sort1,
        END OF ty_but000,
        ty_t_but000 TYPE TABLE OF ty_but000.

  DATA:it_but000 TYPE ty_t_but000,
       wa_but000 TYPE ty_but000.



  LOOP AT ta_flatfile ASSIGNING <fs_flatfile>.

  SELECT SINGLE lifnr FROM lfa1 INTO @DATA(lv_lifnr) WHERE stcd3 = @<fs_flatfile>-taxnumxl.

   IF lv_lifnr IS INITIAL.


    IF <fs_flatfile> IS ASSIGNED.
      TRANSLATE <fs_flatfile>-sort1 TO UPPER CASE.

      partner = <fs_flatfile>-bu_partner.
      partnercategory = '2'.    " Organization
      partnergroup    = <fs_flatfile>-creation_group. " Externel No. or Internel No.

      centraldata-title_key            = <fs_flatfile>-title_medi.
      centraldata-searchterm1          = <fs_flatfile>-sort1.
*      centraldata-partnertype          = <fs_flatfile>-bpkind.
      centraldata-dataorigintype       = <fs_flatfile>-source.


      centraldataorganization-name1 = <fs_flatfile>-name_org1.
      centraldataorganization-name2 = <fs_flatfile>-name_org2.
      centraldataorganization-name3 = <fs_flatfile>-name_org3.
      centraldataorganization-name4 = <fs_flatfile>-name_org4.

      addressdata-street     = <fs_flatfile>-street.
      addressdata-str_suppl1 = <fs_flatfile>-str_suppl1.
      addressdata-str_suppl2 = <fs_flatfile>-str_suppl2.
      addressdata-str_suppl3 = <fs_flatfile>-str_suppl3.
      addressdata-postl_cod1 = <fs_flatfile>-post_code1.
      addressdata-house_no   = <fs_flatfile>-house_num1.
      addressdata-city       = <fs_flatfile>-city1.
      addressdata-country    = <fs_flatfile>-country.
      addressdata-region     = <fs_flatfile>-region.
      addressdata-langu      = <fs_flatfile>-langu.
*      addressdata-transpzone = <fs_flatfile>-transpzone.


      wa_telefondata-telephone = <fs_flatfile>-tel_number.
      wa_telefondata-extension = <fs_flatfile>-tel_extens.
      APPEND wa_telefondata TO it_telefondata.
      CLEAR wa_telefondata.

      wa_telefondata-telephone = <fs_flatfile>-mob_number.
      wa_telefondata-r_3_user  = 3.
      APPEND wa_telefondata TO it_telefondata.
      CLEAR wa_telefondata.

*
      wa_faxdata-fax       = <fs_flatfile>-fax_number.
      APPEND wa_faxdata TO it_faxdata.
      CLEAR wa_faxdata.

      wa_e_maildata-e_mail = <fs_flatfile>-smtp_addr.
      APPEND wa_e_maildata TO it_e_maildata.
      CLEAR wa_e_maildata.

      CALL FUNCTION 'BAPI_BUPA_FS_CREATE_FROM_DATA2'
        EXPORTING
          businesspartnerextern   = partner
          partnercategory         = partnercategory
          partnergroup            = partnergroup
          centraldata             = centraldata
          centraldataperson       = centraldataperson
          centraldataorganization = centraldataorganization
          centraldatagroup        = centraldatagroup
          addressdata             = addressdata
        IMPORTING
          businesspartner         = partner
        TABLES
          telefondata             = it_telefondata
          faxdata                 = it_faxdata
          e_maildata              = it_e_maildata
          return                  = it_return.

      IF partner IS NOT INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        REFRESH:it_ret1.
        CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
          EXPORTING
            businesspartner             = partner
            businesspartnerrolecategory = 'FLVN00'
            validfromdate               = sy-datum
            validuntildate              = '99991231'
          TABLES
            return                      = it_ret1.


        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        REFRESH:it_ret1.

        CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
          EXPORTING
            businesspartner             = partner
            businesspartnerrolecategory = 'FLVN01'
            validfromdate               = sy-datum
            validuntildate              = '99991231'
          TABLES
            return                      = it_ret1.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        DATA:ev_lifnr TYPE lifnr.

        REFRESH:it_ret1.
*BREAK-POINT.

        READ TABLE it_return INTO wa_return WITH KEY type = 'S'.

        wa_display-id      = wa_return-type.
        wa_display-role    = '000000'.
        wa_display-bp_num  = partner.
******added by bhavani*****
        wa_display-lifnr = partner.
        wa_display-sort = <fs_flatfile>-sort1.
***********************************************
        wa_display-message = wa_return-message.

        APPEND wa_display TO it_display.
        CLEAR:wa_display,wa_return.

*********************************************************
        WAIT UP TO 1 SECONDS.
*        DATA :EV_LIFNR TYPE  LIFNR,
        DATA:  es_error TYPE  cvis_message.
*
*          CALL METHOD vmd_ei_api=>get_number
*            EXPORTING
*              iv_ktokk = <fs_flatfile>-creation_group "'ZDOM'
*            IMPORTING
*              ev_lifnr = ev_lifnr
*              es_error = es_error.

        ev_lifnr = partner.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ev_lifnr
          IMPORTING
            output = ev_lifnr.

*************************************************************
*break breddy.
        wa_vendors-header-object_task = 'M'.
        wa_vendors-header-object_instance = ev_lifnr.

        wa_vendors-central_data-central-data-ktokk       = <fs_flatfile>-creation_group. "'ZDOM'.      "Vendor account group  0001
        wa_vendors-central_data-central-data-konzs       = <fs_flatfile>-konzs.
        wa_vendors-central_data-central-data-sperz       = <fs_flatfile>-sperz.
        wa_vendors-central_data-central-data-plkal       = <fs_flatfile>-calendarid.
        wa_vendors-central_data-central-data-fityp        = <fs_flatfile>-fityp.
        wa_vendors-central_data-central-data-fiskn        = <fs_flatfile>-fiskn.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_vendors-central_data-central-data-fiskn
          IMPORTING
            output = wa_vendors-central_data-central-data-fiskn.




        IF NOT wa_vendors-central_data-central-data-konzs  IS INITIAL.
          wa_vendors-central_data-central-datax-konzs        = 'X'.
        ENDIF.
        IF NOT wa_vendors-central_data-central-data-sperz IS INITIAL.
          wa_vendors-central_data-central-datax-sperz        = 'X'.
        ENDIF.
        IF NOT wa_vendors-central_data-central-data-plkal  IS INITIAL.
          wa_vendors-central_data-central-datax-plkal        = 'X'.
        ENDIF.

        IF NOT wa_vendors-central_data-central-data-fityp IS INITIAL.
          wa_vendors-central_data-central-datax-fityp        = 'X'.
        ENDIF.
        IF NOT wa_vendors-central_data-central-data-fiskn IS INITIAL.
          wa_vendors-central_data-central-datax-fiskn        = 'X'.
        ENDIF.


        wa_company-task                    = 'M'.
        wa_company-data_key-bukrs = <fs_flatfile>-bukrs.

*          wa_company_DATA-CURRENT_STATE = 'X'.

        wa_company-data-akont = <fs_flatfile>-akont.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_company-data-akont
          IMPORTING
            output = wa_company-data-akont.
        wa_company-data-lnrze = <fs_flatfile>-lnrze.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_company-data-lnrze
          IMPORTING
            output = wa_company-data-lnrze.
        wa_company-data-zuawa = <fs_flatfile>-zuawa.
*      wa_company-data-begru = <fs_flatfile>-begru.
*        wa_company-data-fdgrv = <fs_flatfile>-fdgrv.
*      wa_company-data-frgrp = <fs_flatfile>-frgrp.
*        wa_company-data-qsskz = <fs_flatfile>-qsskz.

*        wa_company-data-qland = <fs_flatfile>-qland.
*        wa_company-data-qsrec = <fs_flatfile>-qsrec.
        wa_company-data-qsznr = <fs_flatfile>-qsznr.
*        wa_company-data-qszdt = <fs_flatfile>-qszdt.
*
*        CLEAR lv_date.
*        CONCATENATE <fs_flatfile>-qszdt+6(4) <fs_flatfile>-qszdt+3(2) <fs_flatfile>-qszdt+0(2) INTO lv_date.
*        wa_company-data-qszdt = lv_date.
*        CLEAR lv_date.
*      wa_company-data-qsbgr = <fs_flatfile>-qsbgr.
        wa_company-data-xausz = <fs_flatfile>-xausz.
        wa_company-data-zterm = <fs_flatfile>-zterm.
        wa_company-data-guzte = <fs_flatfile>-guzte.
*      wa_company-data-togru = <fs_flatfile>-togru.
        wa_company-data-reprf = <fs_flatfile>-reprf.
        wa_company-data-zwels = <fs_flatfile>-zwels.
        wa_company-data-zahls = <fs_flatfile>-zahls.
*      wa_company-data-lnrzb = <fs_flatfile>-lnrzb.
*      wa_company-data-webtr = <fs_flatfile>-webtr.
        wa_company-data-xverr = <fs_flatfile>-xverr.
*      wa_company-data-xedip = <fs_flatfile>-xedip.
*      wa_company-data-togrr = <fs_flatfile>-togrr.
        IF wa_company-data-akont IS NOT INITIAL.
          wa_company-datax-akont = 'X'.
        ENDIF.
        IF NOT wa_company-data-lnrze IS INITIAL.
          wa_company-datax-lnrze = 'X'.
        ENDIF.
        IF NOT wa_company-data-zuawa IS INITIAL.
          wa_company-datax-zuawa = 'X'.
        ENDIF.
*        wa_company-datax-begru = 'X'.
        IF NOT wa_company-data-fdgrv IS INITIAL.
          wa_company-datax-fdgrv = 'X'.
        ENDIF.
*        wa_company-datax-frgrp = 'X'.
        IF NOT wa_company-data-qsskz IS INITIAL.
          wa_company-datax-qsskz = 'X'.
        ENDIF.
        IF NOT wa_company-data-qland IS INITIAL.
          wa_company-datax-qland = 'X'.
        ENDIF.
        IF NOT wa_company-data-qsrec IS INITIAL.
          wa_company-datax-qsrec = 'X'.
        ENDIF.
        IF NOT wa_company-data-qsrec IS INITIAL.
          wa_company-datax-qsznr = 'X'.
        ENDIF.
*        wa_company-datax-qszdt = 'X'.
*        wa_company-datax-qsbgr = 'X'.
        IF NOT wa_company-data-xausz IS INITIAL.
          wa_company-datax-xausz = 'X'.
        ENDIF.
        IF NOT wa_company-data-zterm IS INITIAL.
          wa_company-datax-zterm = 'X'.
        ENDIF.
        IF NOT wa_company-data-guzte IS INITIAL.
          wa_company-datax-guzte = 'X'.
        ENDIF.
*        wa_company-datax-togru = 'X'.
        IF NOT wa_company-data-reprf IS INITIAL.
          wa_company-datax-reprf = 'X'.
        ENDIF.
        IF NOT wa_company-data-zwels IS INITIAL.
          wa_company-datax-zwels = 'X'.
        ENDIF.
        IF NOT wa_company-data-zahls IS INITIAL.
          wa_company-datax-zahls = 'X'.
        ENDIF.
*        wa_company-datax-lnrzb = 'X'.
*        wa_company-datax-webtr = 'X'.
        IF NOT wa_company-data-xverr IS INITIAL.
          wa_company-datax-xverr = 'X'.
        ENDIF.
****************************

        IF NOT <fs_flatfile>-witht IS INITIAL.
          tax-task           = 'M'.
        ENDIF.

        tax-data_key-witht = <fs_flatfile>-witht.""""added by thippesh
        tax-data-wt_withcd = <fs_flatfile>-wt_withcd.
        tax-data-wt_subjct = <fs_flatfile>-wt_subjct.
        tax-data-qsrec     = <fs_flatfile>-qsrec1.

        IF NOT tax-data-wt_withcd IS INITIAL.
          tax-datax-wt_withcd = 'X'.
        ENDIF.
        IF NOT tax-data-wt_subjct IS INITIAL.
          tax-datax-wt_subjct = 'X'.
        ENDIF.
        IF NOT tax-data-wt_wtstcd IS  INITIAL.
          tax-datax-wt_wtstcd = 'X'.
        ENDIF.
        IF NOT tax-data-qsrec  IS INITIAL.
          tax-datax-qsrec     = 'X'.
        ENDIF.

        IF NOT tax IS INITIAL.
          APPEND tax TO lt_tax[].
          CLEAR tax.
        ENDIF.

        IF NOT <fs_flatfile>-witht1 IS INITIAL.
          tax-task           = 'M'.
        ENDIF.

        tax-data_key-witht = <fs_flatfile>-witht1.
        tax-data-wt_withcd = <fs_flatfile>-wt_withcd1.
        tax-data-wt_subjct = <fs_flatfile>-wt_subjct1.
        tax-data-qsrec     = <fs_flatfile>-qsrec2.

        IF NOT tax-data-wt_withcd IS INITIAL.
          tax-datax-wt_withcd = 'X'.
        ENDIF.
        IF NOT tax-data-wt_subjct IS INITIAL.
          tax-datax-wt_subjct = 'X'.
        ENDIF.
        IF NOT tax-data-wt_wtstcd IS INITIAL.
          tax-datax-wt_wtstcd = 'X'.
        ENDIF.
        IF NOT tax-data-qsrec  IS INITIAL.
          tax-datax-qsrec     = 'X'.
        ENDIF.

        IF NOT tax IS INITIAL.
          APPEND tax TO lt_tax[].
          CLEAR tax.
        ENDIF.
        IF lt_tax IS NOT INITIAL.
          wa_company-wtax_type-wtax_type = lt_tax[].
        ENDIF.
        """""""""""""""""""end of changes
        APPEND wa_company TO it_company.
*          it_company_data-CURRENT_STATE = 'X'.
        it_company_data-company = it_company[].
        wa_vendors-company_data = it_company_data.
*********
        wa_purchase-task                   = 'M'.
        wa_purchase-data_key-ekorg = <fs_flatfile>-ekorg.

*          wa_purchase-CURRENT_STATE = 'X'.
*******
        wa_purchase-data-zterm          = <fs_flatfile>-zterm.
        wa_purchase-data-waers          = <fs_flatfile>-waers.
*      wa_purchase-data-minbw          = <fs_flatfile>-minbw.
        wa_purchase-data-inco1          = <fs_flatfile>-inco1.
        wa_purchase-data-inco2_l        = <fs_flatfile>-inco2_l.
        wa_purchase-data-inco3_l        = <fs_flatfile>-inco3_l.
        wa_purchase-data-verkf          = <fs_flatfile>-verkf.
        wa_purchase-data-telf1          = <fs_flatfile>-telf1.
        wa_purchase-data-lfabc          = <fs_flatfile>-lfabc.
        wa_purchase-data-vsbed          = <fs_flatfile>-vsbed.
        wa_purchase-data-webre          = <fs_flatfile>-webre.
        wa_purchase-data-nrgew          = <fs_flatfile>-nrgew.
        wa_purchase-data-lebre          = <fs_flatfile>-lebre.
*      wa_purchase-data-vendor_rma_req = <fs_flatfile>-vendor_rma_req.
*      wa_purchase-data-prfre          = <fs_flatfile>-prfre.
*      wa_purchase-data-boind          = <fs_flatfile>-boind.
*      wa_purchase-data-blind          = <fs_flatfile>-blind.
*      wa_purchase-data-xersr          = <fs_flatfile>-xersr.
        wa_purchase-data-kzabs          = <fs_flatfile>-kzabs.
*        wa_purchase-data-expvz          = <fs_flatfile>-expvz.
        wa_purchase-data-ekgrp          = <fs_flatfile>-ekgrp.
***        wa_purchase-data-plifz          = <fs_flatfile>-plifz."comented on 30/11/2018
*      wa_purchase-data-agrel          = <fs_flatfile>-agrel.
*      wa_purchase-data-loevm          = <fs_flatfile>-loevm.
        wa_purchase-data-kalsk          = <fs_flatfile>-kalsk.
*      wa_purchase-data-kzaut          = <fs_flatfile>-kzaut.
*      wa_purchase-data-xersy          = <fs_flatfile>-xersy.
*        wa_purchase-data-meprf          = <fs_flatfile>-meprf.
*      wa_purchase-data-sperm          = <fs_flatfile>-sperm.
        wa_purchase-data-bstae          = <fs_flatfile>-bstae.
*      wa_purchase-data-kzret          = <fs_flatfile>-kzret.
*      wa_purchase-data-aubel          = <fs_flatfile>-aubel.
*      wa_purchase-data-hscabs         = <fs_flatfile>-hscabs.
*      wa_purchase-data-xersy          = <fs_flatfile>-xersy1.
        wa_purchase-data-mrppp          = <fs_flatfile>-mrppp.
*      wa_purchase-data-lipre          = <fs_flatfile>-lipre.
*      wa_purchase-data-liser          = <fs_flatfile>-liser.
*****
        IF NOT wa_purchase-data-zterm  IS INITIAL.
          wa_purchase-datax-zterm          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-waers  IS INITIAL.
          wa_purchase-datax-waers          = 'X'.
        ENDIF.

*        wa_purchase-datax-minbw          = 'X'.

        IF NOT wa_purchase-data-inco1  IS INITIAL.
          wa_purchase-datax-inco1          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-inco2_l  IS INITIAL.
          wa_purchase-datax-inco2_l        = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-inco3_l  IS INITIAL.
          wa_purchase-datax-inco3_l        = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-verkf  IS INITIAL.
          wa_purchase-datax-verkf          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-telf1  IS INITIAL.
          wa_purchase-datax-telf1          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-lfabc  IS INITIAL.
          wa_purchase-datax-lfabc          = 'X'.
        ENDIF.
        IF NOT  wa_purchase-data-vsbed   IS INITIAL.
          wa_purchase-datax-vsbed          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-webre  IS INITIAL.
          wa_purchase-datax-webre          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-nrgew   IS INITIAL.
          wa_purchase-datax-nrgew          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-lebre  IS INITIAL.
          wa_purchase-datax-lebre          = 'X'.
        ENDIF.
*         wa_purchase-datax-vendor_rma_req = 'X'.
*        wa_purchase-datax-prfre          = 'X'.
*        wa_purchase-datax-boind          = 'X'.
*        wa_purchase-datax-blind          = 'X'.
*        wa_purchase-datax-xersr          = 'X'.
        IF NOT wa_purchase-data-kzabs  IS INITIAL.
          wa_purchase-datax-kzabs          = 'X'.
        ENDIF.

*         wa_purchase-datax-expvz          = 'X'.
        IF NOT wa_purchase-data-ekgrp  IS INITIAL.
          wa_purchase-datax-ekgrp          = 'X'.
        ENDIF.
        IF NOT wa_purchase-data-plifz   IS INITIAL.
          wa_purchase-datax-plifz          = 'X'.
        ENDIF.
*        wa_purchase-datax-agrel          = 'X'.
*        wa_purchase-datax-loevm          = 'X'.
        IF NOT wa_purchase-data-kalsk  IS INITIAL.
          wa_purchase-datax-kalsk          = 'X'.
        ENDIF.

*        wa_purchase-datax-kzaut          = 'X'.
*        wa_purchase-datax-xersy          = 'X'.
        IF NOT wa_purchase-data-meprf  IS INITIAL.
          wa_purchase-datax-meprf          = 'X'.
        ENDIF.

*        wa_purchase-datax-sperm          = 'X'.
        IF NOT wa_purchase-data-bstae  IS INITIAL.
          wa_purchase-datax-bstae          = 'X'.
        ENDIF.

*        wa_purchase-datax-kzret          = 'X'.
*        wa_purchase-datax-aubel          = 'X'.
*        wa_purchase-datax-hscabs         = 'X'.
*        wa_purchase-datax-xersy          = 'X'.
        IF NOT wa_purchase-data-mrppp  IS INITIAL.
          wa_purchase-datax-mrppp          = 'X'.
        ENDIF.

*        wa_purchase-datax-lipre          = 'X'.
*        wa_purchase-datax-liser          = 'X'.
*****
************
***  Start of Changes By Suri : 13.08.2019

*** Get all mandatory partner functions
        CALL METHOD vmd_ei_api_check=>get_mand_partner_functions
          EXPORTING
            iv_ktokk = <fs_flatfile>-creation_group
          IMPORTING
            et_parvw = DATA(lt_parvw).
        REFRESH : it_partner_func[].
        LOOP AT lt_parvw ASSIGNING FIELD-SYMBOL(<ls_parvw>).
          wa_partner_func-task           = 'M'.
          wa_partner_func-data_key-parvw = <ls_parvw>-parvw.
          wa_partner_func-data-partner   = partner.
          wa_partner_func-datax-partner  = 'X'.
          APPEND wa_partner_func TO it_partner_func[].
          CLEAR wa_partner_func.
        ENDLOOP.
***  End of Changes By Suri : 13.08.2019

***        wa_partner_func-task = 'M'.
***        wa_partner_func-data_key-parvw = 'WL'."<fs_flatfile>-parvw4.
***        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
***        wa_partner_func-datax-partner   = 'X'.
***        APPEND wa_partner_func TO it_partner_func[].
***        CLEAR wa_partner_func.
        wa_purchase-functions-functions  = it_partner_func[].
        APPEND wa_purchase TO it_purchase.
*          ls_purchase_data-CURRENT_STATE = 'X'.
        ls_purchase_data-purchasing = it_purchase[].
        wa_vendors-purchasing_data = ls_purchase_data.
        APPEND wa_vendors TO it_vendors.

        git_final-vendors = it_vendors.

        vmd_ei_api=>initialize( ).
*BREAK breddy.

        CALL METHOD vmd_ei_api=>maintain_bapi
          EXPORTING
*           iv_test_run              = SPACE
            iv_collect_messages      = 'X'   "SPACE
            is_master_data           = git_final
          IMPORTING
            es_master_data_correct   = data_correct
            es_message_correct       = msg_correct
            es_master_data_defective = data_defect
            es_message_defective     = msg_defect.
*BREAK breddy.
        IF msg_defect-is_error IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          DATA:wa_bp001      TYPE bp001,
               wa_j_1imovend TYPE j_1imovend.
          SELECT SINGLE * FROM bp001 INTO wa_bp001 WHERE partner = partner.
          IF sy-subrc = 0.
            wa_bp001-calendarid = <fs_flatfile>-calendarid.
            MODIFY bp001 FROM wa_bp001.
            CLEAR wa_bp001.
          ENDIF.

          CLEAR lv_date.
          CONCATENATE <fs_flatfile>-found_dat+6(4) <fs_flatfile>-found_dat+3(2) <fs_flatfile>-found_dat+0(2) INTO lv_date.

          UPDATE but000 SET bpext     = <fs_flatfile>-bpext
                            found_dat = lv_date
                      WHERE partner = partner.

          ""added by THB for tax cat and number
*          data:wa_taxnum TYPE DFKKBPTAXNUM.
*
*          wa_taxnum-partner =  partner.
*          wa_taxnum-TAXTYPE = <fs_flatfile>-TAXTYPE.
*          wa_taxnum-TAXTYPE = <fs_flatfile>-TAXNUMXL.
*          MODIFY DFKKBPTAXNUM FROM wa_taxnum.

**to update identification tab for tax category and tax number* edited by thippesh*******
          PERFORM identifi_taxcat_taxnum.
          PERFORM bank_detail.
**************end************************************************************************
          CLEAR lv_date.
          CONCATENATE <fs_flatfile>-j_1ipanvaldt+6(4) <fs_flatfile>-j_1ipanvaldt+3(2) <fs_flatfile>-j_1ipanvaldt+0(2) INTO lv_date.

          UPDATE lfa1 SET profs        = <fs_flatfile>-profs
                          j_1iexcd     = <fs_flatfile>-j_1iexcd
                          j_1iexrn     = <fs_flatfile>-j_1iexrn
                          j_1iexrg     = <fs_flatfile>-j_1iexrg
                          j_1iexdi     = <fs_flatfile>-j_1iexdi
                          j_1iexco     = <fs_flatfile>-j_1iexco
                          j_1ivtyp     = <fs_flatfile>-j_1ivtyp
                          j_1i_customs = <fs_flatfile>-j_1i_customs
                          j_1iexcive   = <fs_flatfile>-j_1iexcive
                          j_1issist    = <fs_flatfile>-j_1issist
                          j_1ivencre   = <fs_flatfile>-j_1ivencre
                          j_1icstno    = <fs_flatfile>-j_1icstno
                          j_1ilstno    = <fs_flatfile>-j_1ilstno
                          j_1isern     = <fs_flatfile>-j_1isern
                          j_1ipanno    = <fs_flatfile>-j_1ipanno
                          ven_class    = <fs_flatfile>-ven_class
                          j_1ipanvaldt = lv_date
                          zzvendor_type = <fs_flatfile>-vendor_type     " Suri : 25.10.2019
                          zzvendor_per = <fs_flatfile>-vendor_per       " Suri : 25.10.2019
                          zztemp_vendor = <fs_flatfile>-temp_vendor     " Suri : 30.12.2019
                    WHERE lifnr = ev_lifnr.

          LOOP AT it_display INTO wa_display WHERE bp_num  = partner.

            wa_display-lifnr = ev_lifnr.
            wa_display-sort = <fs_flatfile>-sort1.
            MODIFY it_display FROM wa_display TRANSPORTING lifnr sort.

          ENDLOOP.


        ELSE.
          ret[] = msg_defect-messages[].
          LOOP AT ret INTO wa_retu.
            wa_display-id      = wa_retu-type.
            wa_display-role    = '000000'.
            wa_display-message = wa_retu-message.
            APPEND wa_display TO it_display.
            CLEAR:wa_display,wa_retu.
          ENDLOOP.
        ENDIF.

      ELSE.

        LOOP AT it_return INTO wa_return WHERE type = 'E'.
          wa_display-id      = wa_return-type.
          wa_display-bp_num  = partner.
          wa_display-message = wa_return-message.
          wa_display-sort = <fs_flatfile>-sort1.
          APPEND wa_display TO it_display.
          CLEAR:wa_display,wa_return.
        ENDLOOP.

      ENDIF.

      CLEAR:partnercategory,partnergroup,centraldata,centraldataperson,centraldataorganization,centraldatagroup,addressdata,ev_lifnr,partner,
            wa_vendors-header,wa_vendors-central_data-central,wa_company, wa_company-data,it_company,wa_company,it_company_data,wa_purchase,
            wa_vendors-company_data,wa_purchase-data,it_purchase,ls_purchase_data-purchasing,ls_purchase_data,wa_vendors-purchasing_data,
            it_vendors,git_final-vendors,git_final,data_correct,msg_correct,data_defect,msg_defect,lv_date.

      REFRESH:it_telefondata,it_faxdata,it_e_maildata,it_return,git_final-vendors,it_company,it_vendors,it_purchase.

    ENDIF.

**************************************************************************
ELSEIF lv_lifnr IS NOT INITIAL.
          wa_display-id      = 'E'.
          wa_display-bp_num  = <fs_flatfile>-bu_partner.
          DATA(lv_text) = 'GSTIN NUMBER ALREADY EXIST FOR VENDOR' && lv_lifnr .
          wa_display-message = lv_text .
          wa_display-sort = <fs_flatfile>-sort1.
          APPEND wa_display TO it_display.
          CLEAR:wa_display.

ENDIF.
CLEAR lv_lifnr.
ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data .

  DATA :lwa_layout TYPE slis_layout_alv,
        wa_fcat    TYPE slis_fieldcat_alv,
        it_fcat    TYPE slis_t_fieldcat_alv.

  wa_fcat-fieldname = 'ID'.
  wa_fcat-seltext_m = 'Type'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'ROLE'.
  wa_fcat-seltext_m = 'BP role'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'BP_NUM'.
  wa_fcat-seltext_m = 'Business Partner'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'LIFNR'.
  wa_fcat-seltext_m = 'Vendor Number'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'SORT'.
  wa_fcat-seltext_m = 'Search Term'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'MESSAGE'.
  wa_fcat-seltext_m = 'Message'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  lwa_layout-zebra = 'X'.
  lwa_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS                   =
      is_layout     = lwa_layout
      it_fieldcat   = it_fcat
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
      i_default     = 'X'
      i_save        = 'X'
*     IS_VARIANT    =
*     IT_EVENTS     =
*     IT_EVENT_EXIT =
*     IS_PRINT      =
*     IS_REPREP_ID  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK  =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab      = it_display
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_CUSTOMER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_customer  USING par TYPE but000-partner.
* SALES AND DISTRIBUTION
  BREAK urampur.
  DATA:lv_vkorg    TYPE vkorg,
       lv_vtweg    TYPE vtweg,
       lv_spart    TYPE spart,
       knvv_app_di TYPE knvv_app_di,
       it_knvi     TYPE TABLE OF knvi_app_di,
       it_ret      TYPE TABLE OF bus0msg1,
       wa_knvi     TYPE  knvi_app_di.
  .


  lv_vkorg  = <fs_flatfile>-vkorg.
  lv_vtweg  = <fs_flatfile>-vtweg.
  lv_spart  = <fs_flatfile>-spart.

  knvv_app_di-bzirk = <fs_flatfile>-bzirk.
  knvv_app_di-konda = <fs_flatfile>-konda.                          " Price Group
  knvv_app_di-kalks = <fs_flatfile>-kalks.                          " Cust.Pric.Procedure
  knvv_app_di-lprio = <fs_flatfile>-lprio.                          " Delivery Priority
  knvv_app_di-vsbed = <fs_flatfile>-vsbed1.                          " Shipping conditions
  knvv_app_di-waers_knvv = <fs_flatfile>-waers.                          " Shipping conditions

  wa_knvi-aland = 'IN'.
  wa_knvi-tatyp = 'JOCG'.
  wa_knvi-taxkd = <fs_flatfile>-taxkd1.                          " Tax classification
  wa_knvi-chind_knvi = 'I'.
  APPEND wa_knvi TO it_knvi.
  CLEAR wa_knvi.


  wa_knvi-aland = 'IN'.
  wa_knvi-tatyp = 'JOIG'.
  wa_knvi-taxkd = <fs_flatfile>-taxkd2.                          " Tax classification
  wa_knvi-chind_knvi = 'I'.
  APPEND wa_knvi TO it_knvi.
  CLEAR wa_knvi.

  wa_knvi-aland = 'IN'.
  wa_knvi-tatyp = 'JOSG'.
  wa_knvi-taxkd = <fs_flatfile>-taxkd3.                          " Tax classification
  wa_knvi-chind_knvi = 'I'.
  APPEND wa_knvi TO it_knvi.
  CLEAR wa_knvi.


  wa_knvi-aland = 'IN'.
  wa_knvi-tatyp = 'JOUG'.
  wa_knvi-taxkd = <fs_flatfile>-taxkd4.                          " Tax classification
  wa_knvi-chind_knvi = 'I'.
  APPEND wa_knvi TO it_knvi.
  CLEAR wa_knvi.

  wa_knvi-aland = 'IN'.
  wa_knvi-tatyp = 'JCOS'.
  wa_knvi-taxkd = <fs_flatfile>-taxkd5.                          " Tax classification
  wa_knvi-chind_knvi = 'I'.
  APPEND wa_knvi TO it_knvi.
  CLEAR wa_knvi.





*        i_bpext = <fs_flatfile>-bpext.
**************************************************
  REFRESH it_return.

  CALL FUNCTION 'FICU_BUPA_DARK_MAINTAIN_INTERN'
    EXPORTING
      i_aktyp    = '02'        "01 Create, 02  Change, 03  Display & 06  Delete
      i_xupdtask = 'X'
      i_xcommit  = 'X'
      i_partner  = par
*     i_bpext    = i_bpext
      i_type     = '2'
*     i_bpkind   = lv_bpkind
      i_role1    = 'FLCU01'
      i_vkorg    = lv_vkorg
      i_vtweg    = lv_vtweg
      i_spart    = lv_spart
      i_knvv     = knvv_app_di
    TABLES
      t_knvi     = it_knvi
      t_message  = it_ret.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form IDENTIFI_TAXCAT_TAXNUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM identifi_taxcat_taxnum .
  DATA:it_terun TYPE TABLE OF bapiret2.
  DATA:ld_taxtype   TYPE bapibus1006tax-taxtype,
       ld_taxnumber TYPE bapibus1006tax-taxnumber.

*SELECT SINGLE partner FROM DFKKBPTAXNUM INTO wa_taxnum WHERE partner  = partner.
*
*if wa_taxnum IS INITIAL.

  ld_taxtype   = <fs_flatfile>-taxtype.
  ld_taxnumber = <fs_flatfile>-taxnumxl.

  CALL FUNCTION 'BAPI_BUPA_TAX_ADD'
    EXPORTING
      businesspartner = partner
      taxtype         = ld_taxtype
      taxnumber       = ld_taxnumber
    TABLES
      return          = it_terun.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  REFRESH:it_terun.CLEAR:ld_taxtype,ld_taxnumber.
*ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BANK_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bank_detail .
  DATA:it_terun TYPE TABLE OF bapiret2.
  DATA:wa_bankdetail TYPE bapibus1006_bankdetail.


  wa_bankdetail-bank_ctry  = <fs_flatfile>-banks.
  wa_bankdetail-bank_key   = <fs_flatfile>-bankl.
  wa_bankdetail-bank_acct  = <fs_flatfile>-bankn.

  CALL FUNCTION 'BAPI_BUPA_BANKDETAIL_ADD'
    EXPORTING
      businesspartner = partner
      bankdetailid    = '0001'
      bankdetaildata  = wa_bankdetail
*   IMPORTING
*     BANKDETAILIDOUT =
    TABLES
      return          = it_terun.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  .
  CLEAR:wa_bankdetail.REFRESH:it_terun.
ENDFORM.
