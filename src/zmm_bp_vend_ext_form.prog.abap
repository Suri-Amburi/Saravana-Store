*&---------------------------------------------------------------------*
*& Include          ZMM_BP_VEND_EXT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
form get_filename  changing fp_p_file type localfile.


  data: li_filetable    type filetable,
        lx_filetable    type file_table,
        lv_return_code  type i,
        lv_window_title type string.

  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title            = lv_window_title
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    changing
      file_table              = li_filetable
      rc                      = lv_return_code
*     USER_ACTION             =
*     FILE_ENCODING           =
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  read table   li_filetable into lx_filetable index 1.
  fp_p_file = lx_filetable-filename.


  split fp_p_file at '.' into fname ename.
  set locale language sy-langu.
  translate ename to upper case.
endform.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- TA_FLATFILE
*&---------------------------------------------------------------------*
form get_data.

  data : li_temp   type table of alsmex_tabline,
         lw_temp   type alsmex_tabline,
         lw_intern type  kcde_cells,
         li_intern type standard table of kcde_cells,
         lv_index  type i,
         i_type    type truxs_t_text_data.

*  if ename eq 'XLSX' or ename eq 'XLS'.
*
*    refresh ta_flatfile[].

    call function 'TEXT_CONVERT_XLS_TO_SAP'
      exporting
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        =
        i_tab_raw_data       = i_type
        i_filename           = p_file
      tables
        i_tab_converted_data = ta_flatfile[]
      exceptions
        conversion_failed    = 1
        others               = 2.

    delete ta_flatfile from 1 to 3.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

*  else.
*    message e398(00) with 'Invalid File Type'.
*  endif.

  if ta_flatfile is initial.
    message 'No records to upload' type 'E'.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form UPLOAD_VENDOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form upload_vendor .

  data:it_ret1          type table of bapiret2,

       it_vendors       type vmds_ei_extern_t,
       wa_vendors       type vmds_ei_extern,

       lt_bank          type cvis_ei_bankdetail_t,
       bank             type cvis_ei_cvi_bankdetail,

       it_company       type vmds_ei_company_t,
       wa_company       type vmds_ei_company,

       wa_company_data  type vmds_ei_vmd_company,

       lt_dunn          type vmds_ei_dunning_t,
       dunn             type vmds_ei_dunning,

       lt_tax           type vmds_ei_wtax_type_t,
       tax              type vmds_ei_wtax_type,

       it_company_data  type vmds_ei_vmd_company,
       ls_purchase_data type vmds_ei_vmd_purchasing,

       it_purchase      type vmds_ei_purchasing_t,
       wa_purchase      type vmds_ei_purchasing,
       it_partner_func  type vmds_ei_functions_t,
       wa_partner_func  type vmds_ei_functions,

       data_correct     type vmds_ei_main,
       msg_correct      type cvis_message,
       data_defect      type vmds_ei_main,
       msg_defect       type cvis_message,
       git_final        type vmds_ei_main,
       wa_retu          type bapiret2,
       ret              type bapiret2_t,

       lv_date(8).

  types:begin of ty_but000,
          partner	 type bu_partner,
          bu_sort1 type bu_sort1,
        end of ty_but000,
        ty_t_but000 type table of ty_but000.

  data:it_but000 type ty_t_but000,
       wa_but000 type ty_but000.



  loop at ta_flatfile assigning <fs_flatfile>.
    if <fs_flatfile> is assigned.
      translate <fs_flatfile>-sort1 to upper case.

      partner = <fs_flatfile>-bu_partner.
      partnercategory = '2'.    " Organization
      partnergroup    = <fs_flatfile>-creation_group. " Externel No. or Internel No.

      centraldata-title_key            = <fs_flatfile>-title_medi.
      centraldata-searchterm1          = <fs_flatfile>-sort1.
      centraldata-partnertype          = <fs_flatfile>-bpkind.
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
      addressdata-transpzone = <fs_flatfile>-transpzone.


      wa_telefondata-telephone = <fs_flatfile>-tel_number.
      wa_telefondata-extension = <fs_flatfile>-tel_extens.
      append wa_telefondata to it_telefondata.
      clear wa_telefondata.

      wa_telefondata-telephone = <fs_flatfile>-mob_number.
      wa_telefondata-r_3_user  = 3.
      append wa_telefondata to it_telefondata.
      clear wa_telefondata.

*
      wa_faxdata-fax       = <fs_flatfile>-fax_number.
      append wa_faxdata to it_faxdata.
      clear wa_faxdata.

      wa_e_maildata-e_mail = <fs_flatfile>-smtp_addr.
      append wa_e_maildata to it_e_maildata.
      clear wa_e_maildata.

      if <fs_flatfile>-bu_partner is initial.
        call function 'BAPI_BUPA_FS_CREATE_FROM_DATA2'
          exporting
            businesspartnerextern   = partner
            partnercategory         = partnercategory
            partnergroup            = partnergroup
            centraldata             = centraldata
            centraldataperson       = centraldataperson
            centraldataorganization = centraldataorganization
            centraldatagroup        = centraldatagroup
            addressdata             = addressdata
          importing
            businesspartner         = partner
          tables
            telefondata             = it_telefondata
            faxdata                 = it_faxdata
            e_maildata              = it_e_maildata
            return                  = it_return.

        if partner is not initial.
          call function 'BAPI_TRANSACTION_COMMIT'
            exporting
              wait = ' '.

          wait up to 2 seconds.
        endif.
      endif.


      if <fs_flatfile>-bu_partner is not initial.

        partner = <fs_flatfile>-bu_partner.

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = partner
          importing
            output = partner.


        refresh:it_ret1.
        call function 'BAPI_BUPA_ROLE_ADD_2'
          exporting
            businesspartner             = partner
            businesspartnerrolecategory = 'FLVN00'
            validfromdate               = sy-datum
            validuntildate              = '99991231'
          tables
            return                      = it_ret1.


        call function 'BAPI_TRANSACTION_COMMIT'
          exporting
            wait = ' '.

*        IF NOT it_ret1 IS INITIAL.
*        LOOP AT it_ret1 into wa_retu WHERE type = 'E'.
*        wa_display-id      = wa_retu-type.
*        wa_display-role    = '000000'.
*        wa_display-bp_num  = partner.
*        wa_display-message = wa_retu-message.
*        append wa_display to it_display.
*        clear:wa_display,wa_retu.
*        ENDLOOP.
*
*        LOOP AT it_ret1 into wa_retu WHERE type = 'S'.
*        wa_display-id      = wa_retu-type.
*        wa_display-role    = '000000'.
*        wa_display-bp_num  = partner.
*        wa_display-message = wa_retu-message.
*        append wa_display to it_display.
*        clear:wa_display,wa_retu.
*        ENDLOOP.
*        ENDIF.

        refresh:it_ret1.

        call function 'BAPI_BUPA_ROLE_ADD_2'
          exporting
            businesspartner             = partner
            businesspartnerrolecategory = 'FLVN01'
            validfromdate               = sy-datum
            validuntildate              = '99991231'
          tables
            return                      = it_ret1.

        call function 'BAPI_TRANSACTION_COMMIT'
          exporting
            wait = ' '.

*        IF NOT it_ret1 IS INITIAL.
*        LOOP AT it_ret1 into wa_retu WHERE type = 'E'.
*        wa_display-id      = wa_retu-type.
*        wa_display-role    = '000000'.
*        wa_display-bp_num  = partner.
*        wa_display-message = wa_retu-message.
*        append wa_display to it_display.
*        clear:wa_display,wa_retu.
*        ENDLOOP.
*
*        LOOP AT it_ret1 into wa_retu WHERE type = 'S'.
*        wa_display-id      = wa_retu-type.
*        wa_display-role    = '000000'.
*        wa_display-bp_num  = partner.
*        wa_display-message = wa_retu-message.
*        append wa_display to it_display.
*        clear:wa_display,wa_retu.
*        ENDLOOP.
*        ENDIF.


        refresh:it_ret1.

        LOOP AT it_return into wa_return WHERE type = 'S'.
        wa_display-id      = wa_return-type.
        wa_display-role    = '000000'.
        wa_display-bp_num  = partner.
        wa_display-message = wa_return-message.
        append wa_display to it_display.
        clear:wa_display,wa_return.
        ENDLOOP.

        LOOP AT it_return into wa_return WHERE type = 'E'.
        wa_display-id      = wa_return-type.
        wa_display-role    = '000000'.
        wa_display-bp_num  = partner.
        wa_display-message = wa_return-message.
        append wa_display to it_display.
        clear:wa_display,wa_return.
        ENDLOOP.
*        ENDIF.

*********************************************************
        wait up to 1 seconds.
        data :ev_lifnr type  lifnr,
              es_error type  cvis_message.
*
*          CALL METHOD vmd_ei_api=>get_number
*            EXPORTING
*              iv_ktokk = <fs_flatfile>-creation_group "'ZDOM'
*            IMPORTING
*              ev_lifnr = ev_lifnr
*              es_error = es_error.

        ev_lifnr = partner.

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = ev_lifnr
          importing
            output = ev_lifnr.

*************************************************************

        wa_vendors-header-object_task = 'M'.
        wa_vendors-header-object_instance = ev_lifnr.

        wa_vendors-central_data-central-data-ktokk       = <fs_flatfile>-creation_group. "'ZDOM'.      "Vendor account group  0001
        wa_vendors-central_data-central-data-konzs       = <fs_flatfile>-konzs.
        wa_vendors-central_data-central-data-sperz       = <fs_flatfile>-sperz.
        wa_vendors-central_data-central-data-plkal       = <fs_flatfile>-calendarid.
        wa_vendors-central_data-central-data-fityp        = <fs_flatfile>-fityp.
        wa_vendors-central_data-central-data-fiskn        = <fs_flatfile>-fiskn.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_vendors-central_data-central-data-fiskn
          importing
            output = wa_vendors-central_data-central-data-fiskn.




        if not wa_vendors-central_data-central-data-konzs  is initial.
          wa_vendors-central_data-central-datax-konzs        = 'X'.
        endif.
        if not wa_vendors-central_data-central-data-sperz is initial.
          wa_vendors-central_data-central-datax-sperz        = 'X'.
        endif.
        if not wa_vendors-central_data-central-data-plkal  is initial.
          wa_vendors-central_data-central-datax-plkal        = 'X'.
        endif.

        if not wa_vendors-central_data-central-data-fityp is initial.
          wa_vendors-central_data-central-datax-fityp        = 'X'.
        endif.
        if not wa_vendors-central_data-central-data-fiskn is initial.
          wa_vendors-central_data-central-datax-fiskn        = 'X'.
        endif.


        wa_company-task                    = 'M'.
        wa_company-data_key-bukrs = <fs_flatfile>-bukrs.

*          wa_company_DATA-CURRENT_STATE = 'X'.

        wa_company-data-akont = <fs_flatfile>-akont.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_company-data-akont
          importing
            output = wa_company-data-akont.
        wa_company-data-lnrze = <fs_flatfile>-lnrze.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_company-data-lnrze
          importing
            output = wa_company-data-lnrze.
        wa_company-data-zuawa = <fs_flatfile>-zuawa.
*      wa_company-data-begru = <fs_flatfile>-begru.
        wa_company-data-fdgrv = <fs_flatfile>-fdgrv.
*      wa_company-data-frgrp = <fs_flatfile>-frgrp.
        wa_company-data-qsskz = <fs_flatfile>-qsskz.

        wa_company-data-qland = <fs_flatfile>-qland.
        wa_company-data-qsrec = <fs_flatfile>-qsrec.
        wa_company-data-qsznr = <fs_flatfile>-qsznr.
*        wa_company-data-qszdt = <fs_flatfile>-qszdt.
*
*        CLEAR lv_date.
*        CONCATENATE <fs_flatfile>-qszdt+6(4) <fs_flatfile>-qszdt+3(2) <fs_flatfile>-qszdt+0(2) INTO lv_date.
*        wa_company-data-qszdt = lv_date.
*        CLEAR lv_date.
*      wa_company-data-qsbgr = <fs_flatfile>-qsbgr.
        wa_company-data-xausz = <fs_flatfile>-xausz.
*        wa_company-data-zterm = <fs_flatfile>-zterm.        "Commented by Ibrahim on 01.04.2018
*        wa_company-data-guzte = <fs_flatfile>-guzte.        "Commented by Ibrahim on 01.04.2018
*      wa_company-data-togru = <fs_flatfile>-togru.
*        wa_company-data-reprf = <fs_flatfile>-reprf.        "Commented by Ibrahim on 01.04.2018
        wa_company-data-zwels = <fs_flatfile>-zwels.
        wa_company-data-zahls = <fs_flatfile>-zahls.
*      wa_company-data-lnrzb = <fs_flatfile>-lnrzb.
*      wa_company-data-webtr = <fs_flatfile>-webtr.
        wa_company-data-xverr = <fs_flatfile>-xverr.
*      wa_company-data-xedip = <fs_flatfile>-xedip.
*      wa_company-data-togrr = <fs_flatfile>-togrr.
        if wa_company-data-akont is not initial.
          wa_company-datax-akont = 'X'.
        endif.
        if not wa_company-data-lnrze is initial.
          wa_company-datax-lnrze = 'X'.
        endif.
        if not wa_company-data-zuawa is initial.
          wa_company-datax-zuawa = 'X'.
        endif.
*        wa_company-datax-begru = 'X'.
        if not wa_company-data-fdgrv is initial.
          wa_company-datax-fdgrv = 'X'.
        endif.
*        wa_company-datax-frgrp = 'X'.
        if not wa_company-data-qsskz is initial.
          wa_company-datax-qsskz = 'X'.
        endif.
        if not wa_company-data-qland is initial.
          wa_company-datax-qland = 'X'.
        endif.
        if not wa_company-data-qsrec is initial.
          wa_company-datax-qsrec = 'X'.
        endif.
        if not wa_company-data-qsrec is initial.
          wa_company-datax-qsznr = 'X'.
        endif.
*        wa_company-datax-qszdt = 'X'.
*        wa_company-datax-qsbgr = 'X'.
        if not wa_company-data-xausz is initial.
          wa_company-datax-xausz = 'X'.
        endif.
        if not wa_company-data-zterm is initial.
          wa_company-datax-zterm = 'X'.
        endif.
        if not wa_company-data-guzte is initial.
          wa_company-datax-guzte = 'X'.
        endif.
*        wa_company-datax-togru = 'X'.
        if not wa_company-data-reprf is initial.
          wa_company-datax-reprf = 'X'.
        endif.
        if not wa_company-data-zwels is initial.
          wa_company-datax-zwels = 'X'.
        endif.
        if not wa_company-data-zahls is initial.
          wa_company-datax-zahls = 'X'.
        endif.
*        wa_company-datax-lnrzb = 'X'.
*        wa_company-datax-webtr = 'X'.
        if not wa_company-data-xverr is initial.
          wa_company-datax-xverr = 'X'.
        endif.
****************************

        if not <fs_flatfile>-witht is initial.
          tax-task           = 'M'.
        endif.

        tax-data_key-witht = <fs_flatfile>-witht.""""added by thippesh
        tax-data-wt_withcd = <fs_flatfile>-wt_withcd.
        tax-data-wt_subjct = <fs_flatfile>-wt_subjct.
        tax-data-qsrec     = <fs_flatfile>-qsrec1.

        if not tax-data-wt_withcd is initial.
          tax-datax-wt_withcd = 'X'.
        endif.
        if not tax-data-wt_subjct is initial.
          tax-datax-wt_subjct = 'X'.
        endif.
        if not tax-data-wt_wtstcd is  initial.
          tax-datax-wt_wtstcd = 'X'.
        endif.
        if not tax-data-qsrec  is initial.
          tax-datax-qsrec     = 'X'.
        endif.

        if not tax is initial.
          append tax to lt_tax[].
          clear tax.
        endif.

        if not <fs_flatfile>-witht1 is initial.
          tax-task           = 'M'.
        endif.

        tax-data_key-witht = <fs_flatfile>-witht1.
        tax-data-wt_withcd = <fs_flatfile>-wt_withcd1.
        tax-data-wt_subjct = <fs_flatfile>-wt_subjct1.
        tax-data-qsrec     = <fs_flatfile>-qsrec2.

        if not tax-data-wt_withcd is initial.
          tax-datax-wt_withcd = 'X'.
        endif.
        if not tax-data-wt_subjct is initial.
          tax-datax-wt_subjct = 'X'.
        endif.
        if not tax-data-wt_wtstcd is initial.
          tax-datax-wt_wtstcd = 'X'.
        endif.
        if not tax-data-qsrec  is initial.
          tax-datax-qsrec     = 'X'.
        endif.

        if not tax is initial.
          append tax to lt_tax[].
          clear tax.
        endif.
        if lt_tax is not initial.
          wa_company-wtax_type-wtax_type = lt_tax[].
        endif.
        """""""""""""""""""end of changes
        append wa_company to it_company.
*          it_company_data-CURRENT_STATE = 'X'.
        it_company_data-company = it_company[].
        wa_vendors-company_data = it_company_data.
*********
        wa_purchase-task                   = 'M'.
        wa_purchase-data_key-ekorg = <fs_flatfile>-ekorg.

*          wa_purchase-CURRENT_STATE = 'X'.
*******
*        wa_purchase-data-zterm          = <fs_flatfile>-zterm.                  "Commented byibrahim on 01.04
        wa_purchase-data-waers          = <fs_flatfile>-waers.
*      wa_purchase-data-minbw          = <fs_flatfile>-minbw.
*        wa_purchase-data-inco1          = <fs_flatfile>-inco1.                  "Commented byibrahim on 01.04
*        wa_purchase-data-inco2_l        = <fs_flatfile>-inco2_l.                 "Commented byibrahim on 01.04
*        wa_purchase-data-inco3_l        = <fs_flatfile>-inco3_l.                 "Commented byibrahim on 01.04
        wa_purchase-data-verkf          = <fs_flatfile>-verkf.
        wa_purchase-data-telf1          = <fs_flatfile>-telf1.
        wa_purchase-data-lfabc          = <fs_flatfile>-lfabc.
        wa_purchase-data-vsbed          = <fs_flatfile>-vsbed.
        wa_purchase-data-webre          = <fs_flatfile>-webre.
*        wa_purchase-data-nrgew          = <fs_flatfile>-nrgew.                    "Commented by Ibrahim on 01.04
        wa_purchase-data-lebre          = <fs_flatfile>-lebre.
*      wa_purchase-data-vendor_rma_req = <fs_flatfile>-vendor_rma_req.
*      wa_purchase-data-prfre          = <fs_flatfile>-prfre.
*      wa_purchase-data-boind          = <fs_flatfile>-boind.
*      wa_purchase-data-blind          = <fs_flatfile>-blind.
*      wa_purchase-data-xersr          = <fs_flatfile>-xersr.
        wa_purchase-data-kzabs          = <fs_flatfile>-kzabs.
*        wa_purchase-data-expvz          = <fs_flatfile>-expvz.
*        wa_purchase-data-ekgrp          = <fs_flatfile>-ekgrp.                   "Commented by Ibrahim on 01.04
        wa_purchase-data-plifz          = <fs_flatfile>-plifz.
*      wa_purchase-data-agrel          = <fs_flatfile>-agrel.
*      wa_purchase-data-loevm          = <fs_flatfile>-loevm.
        wa_purchase-data-kalsk          = <fs_flatfile>-kalsk.
*      wa_purchase-data-kzaut          = <fs_flatfile>-kzaut.
*      wa_purchase-data-xersy          = <fs_flatfile>-xersy.
        wa_purchase-data-meprf          = <fs_flatfile>-meprf.
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
        if not wa_purchase-data-zterm  is initial.
          wa_purchase-datax-zterm          = 'X'.
        endif.
        if not wa_purchase-data-waers  is initial.
          wa_purchase-datax-waers          = 'X'.
        endif.

*        wa_purchase-datax-minbw          = 'X'.

        if not wa_purchase-data-inco1  is initial.
          wa_purchase-datax-inco1          = 'X'.
        endif.
        if not wa_purchase-data-inco2_l  is initial.
          wa_purchase-datax-inco2_l        = 'X'.
        endif.
        if not wa_purchase-data-inco3_l  is initial.
          wa_purchase-datax-inco3_l        = 'X'.
        endif.
        if not wa_purchase-data-verkf  is initial.
          wa_purchase-datax-verkf          = 'X'.
        endif.
        if not wa_purchase-data-telf1  is initial.
          wa_purchase-datax-telf1          = 'X'.
        endif.
        if not wa_purchase-data-lfabc  is initial.
          wa_purchase-datax-lfabc          = 'X'.
        endif.
        if not  wa_purchase-data-vsbed   is initial.
          wa_purchase-datax-vsbed          = 'X'.
        endif.
        if not wa_purchase-data-webre  is initial.
          wa_purchase-datax-webre          = 'X'.
        endif.
        if not wa_purchase-data-nrgew   is initial.
          wa_purchase-datax-nrgew          = 'X'.
        endif.
        if not wa_purchase-data-lebre  is initial.
          wa_purchase-datax-lebre          = 'X'.
        endif.
*         wa_purchase-datax-vendor_rma_req = 'X'.
*        wa_purchase-datax-prfre          = 'X'.
*        wa_purchase-datax-boind          = 'X'.
*        wa_purchase-datax-blind          = 'X'.
*        wa_purchase-datax-xersr          = 'X'.
        if not wa_purchase-data-kzabs  is initial.
          wa_purchase-datax-kzabs          = 'X'.
        endif.

*         wa_purchase-datax-expvz          = 'X'.
        if not wa_purchase-data-ekgrp  is initial.
          wa_purchase-datax-ekgrp          = 'X'.
        endif.
        if not wa_purchase-data-plifz   is initial.
          wa_purchase-datax-plifz          = 'X'.
        endif.
*        wa_purchase-datax-agrel          = 'X'.
*        wa_purchase-datax-loevm          = 'X'.
        if not wa_purchase-data-kalsk  is initial.
          wa_purchase-datax-kalsk          = 'X'.
        endif.

*        wa_purchase-datax-kzaut          = 'X'.
*        wa_purchase-datax-xersy          = 'X'.
        if not wa_purchase-data-meprf  is initial.
          wa_purchase-datax-meprf          = 'X'.
        endif.

*        wa_purchase-datax-sperm          = 'X'.
        if not wa_purchase-data-bstae  is initial.
          wa_purchase-datax-bstae          = 'X'.
        endif.

*        wa_purchase-datax-kzret          = 'X'.
*        wa_purchase-datax-aubel          = 'X'.
*        wa_purchase-datax-hscabs         = 'X'.
*        wa_purchase-datax-xersy          = 'X'.
        if not wa_purchase-data-mrppp  is initial.
          wa_purchase-datax-mrppp          = 'X'.
        endif.

*        wa_purchase-datax-lipre          = 'X'.
*        wa_purchase-datax-liser          = 'X'.
*****

************        ,
        wa_partner_func-task = 'M'.
        wa_partner_func-data_key-parvw = 'BA'."<fs_flatfile>-parvw1.
        wa_partner_func-data-partner   = partner. "ev_lifnr.   "partner. "<fs_flatfile>-ktonr.
        wa_partner_func-datax-partner   = 'X'.
        append wa_partner_func to it_partner_func[].
        clear wa_partner_func.

        wa_partner_func-task = 'M'.
        wa_partner_func-data_key-parvw = 'LF'."<fs_flatfile>-parvw2.
        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
        wa_partner_func-datax-partner   = 'X'.
        append wa_partner_func to it_partner_func[].
        clear wa_partner_func.
        wa_partner_func-task = 'M'.
        wa_partner_func-data_key-parvw = 'RS'."<fs_flatfile>-parvw3.
        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
        wa_partner_func-datax-partner   = 'X'.
        append wa_partner_func to it_partner_func[].
        clear wa_partner_func.
***        wa_partner_func-task = 'M'.
***        wa_partner_func-data_key-parvw = 'WL'."<fs_flatfile>-parvw4.
***        wa_partner_func-data-partner   = partner. "<fs_flatfile>-ktonr.
***        wa_partner_func-datax-partner   = 'X'.
***        APPEND wa_partner_func TO it_partner_func[].
***        CLEAR wa_partner_func.
        wa_purchase-functions-functions  = it_partner_func[].          "Commentd by Ibrahim 01.04
        append wa_purchase to it_purchase.                             "Commentd by Ibrahim 01.04
*          ls_purchase_data-CURRENT_STATE = 'X'.
        ls_purchase_data-purchasing = it_purchase[].                   "Commentd by Ibrahim 01.04
        wa_vendors-purchasing_data = ls_purchase_data.
        append wa_vendors to it_vendors.

        git_final-vendors = it_vendors.

        vmd_ei_api=>initialize( ).

        call method vmd_ei_api=>maintain_bapi
          exporting
*           iv_test_run              = SPACE
            iv_collect_messages      = 'X'   "SPACE
            is_master_data           = git_final
          importing
            es_master_data_correct   = data_correct
            es_message_correct       = msg_correct
            es_master_data_defective = data_defect
            es_message_defective     = msg_defect.

        if msg_defect-is_error is initial.
          call function 'BAPI_TRANSACTION_COMMIT'
            exporting
              wait = ' '.

          data:wa_bp001      type bp001,
               wa_j_1imovend type j_1imovend.

          wa_display-id      = 'S'.
          wa_display-role    = '000000'.
          wa_display-bp_num = partner.
          wa_display-message = 'Partner Extended successfully'.
          append wa_display to it_display.

          select single * from bp001 into wa_bp001 where partner = partner.
          if sy-subrc = 0.
            wa_bp001-calendarid = <fs_flatfile>-calendarid.
            modify bp001 from wa_bp001.
            clear wa_bp001.
          endif.

          clear lv_date.
          concatenate <fs_flatfile>-found_dat+6(4) <fs_flatfile>-found_dat+3(2) <fs_flatfile>-found_dat+0(2) into lv_date.

          update but000 set bpext     = <fs_flatfile>-bpext
                            found_dat = lv_date
                      where partner = partner.

          ""added by THB for tax cat and number
*          data:wa_taxnum TYPE DFKKBPTAXNUM.
*
*          wa_taxnum-partner =  partner.
*          wa_taxnum-TAXTYPE = <fs_flatfile>-TAXTYPE.
*          wa_taxnum-TAXTYPE = <fs_flatfile>-TAXNUMXL.
*          MODIFY DFKKBPTAXNUM FROM wa_taxnum.

**to update identification tab for tax category and tax number* edited by thippesh*******
          perform identifi_taxcat_taxnum.
          perform bank_detail.
**************end************************************************************************
          clear lv_date.
          concatenate <fs_flatfile>-j_1ipanvaldt+6(4) <fs_flatfile>-j_1ipanvaldt+3(2) <fs_flatfile>-j_1ipanvaldt+0(2) into lv_date.

          wait up to '0.2' seconds.

          update lfa1 set profs        = <fs_flatfile>-profs
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
                    where lifnr = ev_lifnr.

*        update j_1imovend set j_1iexcd     = <fs_flatfile>-j_1iexcd
*                              j_1iexrn     = <fs_flatfile>-j_1iexrn
*                              j_1iexrg     = <fs_flatfile>-j_1iexrg
*                              j_1iexdi     = <fs_flatfile>-j_1iexdi
*                              j_1iexco     = <fs_flatfile>-j_1iexco
*                              j_1icstno    = <fs_flatfile>-j_1icstno
*                              j_1ilstno    = <fs_flatfile>-j_1ilstno
*                              j_1ipanno    = <fs_flatfile>-j_1ipanno
*                              j_1iexcive   = <fs_flatfile>-j_1iexcive
*                              j_1issist    = <fs_flatfile>-j_1issist
*                              j_1ivtyp     = <fs_flatfile>-j_1ivtyp
*                              j_1ivencre   = <fs_flatfile>-j_1ivencre
*                              j_1isern     = <fs_flatfile>-j_1isern
*                              j_1ipanvaldt = lv_date
*                              j_1i_customs = <fs_flatfile>-j_1i_customs
*                              ven_class    = <fs_flatfile>-ven_class
*                    where lifnr = ev_lifnr.

*          break-point.
          loop at it_display into wa_display.

*            wa_display-lifnr = ev_lifnr.
            wa_display-sort = <fs_flatfile>-sort1.
            modify it_display from wa_display transporting lifnr sort where bp_num = ev_lifnr .

          endloop.


        else.
          ret[] = msg_defect-messages[].
          loop at ret into wa_retu.
            wa_display-id      = wa_retu-type.
            wa_display-role    = '000000'.
            wa_display-message = wa_retu-message.
            append wa_display to it_display.
            clear:wa_display,wa_retu.
          endloop.
        endif.

      else.

        loop at it_return into wa_return where type = 'E'.
          wa_display-id      = wa_return-type.
          wa_display-bp_num  = partner.
          wa_display-message = wa_return-message.
          wa_display-sort = <fs_flatfile>-sort1.
          append wa_display to it_display.
          clear:wa_display,wa_return.
        endloop.

      endif.

      clear:partnercategory,partnergroup,centraldata,centraldataperson,centraldataorganization,centraldatagroup,addressdata,ev_lifnr,partner,
            wa_vendors-header,wa_vendors-central_data-central,wa_company, wa_company-data,it_company,wa_company,it_company_data,wa_purchase,
            wa_vendors-company_data,wa_purchase-data,it_purchase,ls_purchase_data-purchasing,ls_purchase_data,wa_vendors-purchasing_data,
            it_vendors,git_final-vendors,git_final,data_correct,msg_correct,data_defect,msg_defect,lv_date.

      refresh:it_telefondata,it_faxdata,it_e_maildata,it_return,git_final-vendors,it_company,it_vendors,it_purchase, it_partner_func.

    endif.
    wait up to 2 seconds.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form display_data .

  data :lwa_layout type slis_layout_alv,
        wa_fcat    type slis_fieldcat_alv,
        it_fcat    type slis_t_fieldcat_alv.

  wa_fcat-fieldname = 'ID'.
  wa_fcat-seltext_m = 'Type'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  append wa_fcat to it_fcat.
  clear wa_fcat.

  wa_fcat-fieldname = 'ROLE'.
  wa_fcat-seltext_m = 'BP role'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  append wa_fcat to it_fcat.
  clear wa_fcat.

  wa_fcat-fieldname = 'BP_NUM'.
  wa_fcat-seltext_m = 'Business Partner'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  append wa_fcat to it_fcat.
  clear wa_fcat.

  wa_fcat-fieldname = 'MESSAGE'.
  wa_fcat-seltext_m = 'Message'.
  wa_fcat-tabname = 'IT_DISPLAY'.
  append wa_fcat to it_fcat.
  clear wa_fcat.


  lwa_layout-zebra = 'X'.
  lwa_layout-colwidth_optimize = 'X'.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      is_layout     = lwa_layout
      it_fieldcat   = it_fcat
      i_default     = 'X'
      i_save        = 'X'
    tables
      t_outtab      = it_display
    exceptions
      program_error = 1
      others        = 2.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form IDENTIFI_TAXCAT_TAXNUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form identifi_taxcat_taxnum .

  data:it_terun type table of bapiret2,
       wa_terun type bapiret2.
  data:ld_taxtype   type bapibus1006tax-taxtype,
       ld_taxnumber type bapibus1006tax-taxnumber.

*SELECT SINGLE partner FROM DFKKBPTAXNUM INTO wa_taxnum WHERE partner  = partner.
*
*if wa_taxnum IS INITIAL.
*  break sap_abap.
  wait up to '0.2' seconds.
  ld_taxtype   = <fs_flatfile>-taxtype.
  ld_taxnumber = <fs_flatfile>-taxnumxl.

  call function 'BAPI_BUPA_TAX_ADD'
    exporting
      businesspartner = partner
      taxtype         = ld_taxtype
      taxnumber       = ld_taxnumber
    tables
      return          = it_terun.

  if sy-subrc = 0.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait = ' '.

  else.

    loop at  it_terun into wa_terun.

      wa_display-id      = wa_terun-type.
      wa_display-role    = '000000'.
      wa_display-message = wa_terun-message.
      wa_display-lifnr   = partner.
      append wa_display to it_display.
      clear:wa_display,wa_terun.
    endloop.
  endif.


  refresh:it_terun.
  clear:ld_taxtype,ld_taxnumber.

endform.
*&---------------------------------------------------------------------*
*& Form BANK_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form bank_detail .

  data:it_terun type table of bapiret2,
       wa_terun type bapiret2.
  data:wa_bankdetail type bapibus1006_bankdetail.

  wait up to '0.2' seconds.

  wa_bankdetail-bank_ctry  = <fs_flatfile>-banks.
  wa_bankdetail-bank_key   = <fs_flatfile>-bankl.
  wa_bankdetail-bank_acct  = <fs_flatfile>-bankn.

  call function 'BAPI_BUPA_BANKDETAIL_ADD'
    exporting
      businesspartner = partner
      bankdetailid    = '0001'
      bankdetaildata  = wa_bankdetail
*   IMPORTING
*     BANKDETAILIDOUT =
    tables
      return          = it_terun.

  if sy-subrc = 0.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait = ' '.

  else.

    loop at  it_terun into wa_terun.

      wa_display-id      = wa_terun-type.
      wa_display-role    = '000000'.
      wa_display-message = wa_terun-message.
      wa_display-lifnr   = partner.
      append wa_display to it_display.
      clear:wa_display,wa_terun.
    endloop.
  endif.

  clear:wa_bankdetail.refresh:it_terun.

endform.
