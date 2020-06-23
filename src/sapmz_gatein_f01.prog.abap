*&---------------------------------------------------------------------*
*& Include          SAPMZ_GATEIN_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.
*** Get Inword Header Deatails
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_trns
    IMPORTING
      output = p_trns.

  CLEAR : gs_inwd_hdr.
  SELECT SINGLE * FROM zinw_t_hdr INTO gs_inwd_hdr WHERE lr_no = p_lr_no AND trns = p_trns AND status = c_01.
  IF sy-subrc <> 0.
    MESSAGE s011(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
    EXIT.
  ENDIF.
  SELECT SINGLE bsart FROM ekko INTO gv_bsart WHERE ebeln = gs_inwd_hdr-ebeln.
  IF gv_bsart = c_ztat OR gv_bsart = c_zlop .
    MESSAGE s033(zmsg_cls) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
    EXIT.
  ENDIF.
  IF gs_inwd_hdr IS NOT INITIAL.
    CALL SCREEN 9001.
*  ELSE.
*    MESSAGE S028(ZMSG_CLS) DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_cat .
  DATA: ls_fc   TYPE  lvc_s_fcat,
        it_sort TYPE lvc_t_sort,
        ls_sort TYPE lvc_s_sort,
        lv_pos  TYPE i VALUE 1.

  IF gt_fieldcat IS INITIAL.
    gs_layo-frontend   = c_x.
    gs_layo-zebra      = c_x.

    ls_fc-col_pos   = lv_pos.
    ls_fc-fieldname = 'INWD_DOC'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Inward Doc'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'EBELN'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-scrtext_l = 'Pur Order'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'LR_NO'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-scrtext_l = 'LR Number'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'TRNS'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-scrtext_l = 'Transporter'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'LIFNR'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Vendor'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'NAME1'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-no_zero   = c_x.
    ls_fc-outputlen = 30.
    ls_fc-scrtext_l = 'Vendor Name'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'STATUS'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-no_zero   = c_x.
    ls_fc-scrtext_l = 'Status'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'ACT_NO_BUD'.
    ls_fc-tabname   = 'GT_HDR'.
*    LS_FC-edit   = C_X.
    ls_fc-scrtext_l = 'Act Bundles'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'SMALL_BUNDLE'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-edit   = c_x.
    ls_fc-scrtext_l = 'Small Bundles'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'BIG_BUNDLE'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-edit   = c_x.
    ls_fc-scrtext_l = 'Big Bundles'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    ls_fc-col_pos   = lv_pos + 1.
    ls_fc-fieldname = 'BAY'.
    ls_fc-tabname   = 'GT_HDR'.
    ls_fc-edit      = c_x.
    ls_fc-scrtext_l = 'Bay'.
    APPEND ls_fc TO gt_fieldcat.
    CLEAR ls_fc.

    APPEND VALUE #( col_pos = lv_pos + 1 fieldname = 'POST_DATE' tabname = 'GT_HDR' datatype = 'DATS'
                   edit = c_x scrtext_l = 'Posting Date' scrtext_m = 'Posting Date' scrtext_s = 'Posting Date' f4availabl = C_X ref_table = 'SYST' ref_field = 'DATUM' ) TO gt_fieldcat.

  ELSEIF  gv_mod = c_d.
    LOOP AT gt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fcat>) WHERE edit = c_x.
      CLEAR : <ls_fcat>-edit.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data.
  REFRESH : gt_hdr.
  MOVE-CORRESPONDING gs_inwd_hdr TO gs_hdr.
  APPEND gs_hdr TO gt_hdr.

  IF gt_exclude IS INITIAL.
    PERFORM exclude_tb_functions CHANGING gt_exclude.
  ENDIF.
  IF grid IS NOT BOUND.
    CREATE OBJECT container
      EXPORTING
        container_name = mycontainer.
    CREATE OBJECT grid
      EXPORTING
        i_parent = container.
  ENDIF.
*** Create Object for event_receiver.
  IF gr_event IS NOT BOUND.
    CREATE OBJECT gr_event.
  ENDIF.

  IF grid IS BOUND.
    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        is_layout                     = gs_layo
        it_toolbar_excluding          = gt_exclude
      CHANGING
        it_outtab                     = gt_hdr
        it_fieldcatalog               = gt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
    ENDIF.
***  Refresh
    IF grid IS BOUND.
      DATA: is_stable TYPE lvc_s_stbl.
      is_stable = 'XX'.
      CALL METHOD grid->refresh_table_display
        EXPORTING
          is_stable = is_stable
        EXCEPTIONS
          finished  = 1
          OTHERS    = 2.
    ENDIF.
***  Registering the EDIT Event
    CALL METHOD grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    SET HANDLER gr_event->handle_data_changed FOR grid.
  ENDIF.
ENDFORM.


FORM exclude_tb_functions  CHANGING gt_exclude TYPE ui_functions.
  DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gt_exclude.
ENDFORM.

FORM save_data.
  PERFORM create_service_po.
  PERFORM service_entrysheet USING gs_inwd_hdr-service_po.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_LOGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_logo .
  DATA: w_lines TYPE i.
  TYPES pict_line(256) TYPE c.
  DATA :
    logo_container TYPE REF TO cl_gui_custom_container,
    editor         TYPE REF TO cl_gui_textedit,
    picture        TYPE REF TO cl_gui_picture,
    pict_tab       TYPE TABLE OF pict_line,
    url(255)       TYPE c.

  DATA: graphic_url(255).
  DATA: BEGIN OF graphic_table OCCURS 0,
          line(255) TYPE x,
        END OF graphic_table.
  DATA: l_graphic_conv TYPE i.
  DATA: l_graphic_offs TYPE i.
  DATA: graphic_size TYPE i.
  DATA: l_graphic_xstr TYPE xstring.

  CALL METHOD cl_gui_cfw=>flush.
  CREATE OBJECT:
  logo_container EXPORTING container_name = 'LOGO_CONTAINER',
  picture EXPORTING parent = logo_container.

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object = 'GRAPHICS'
      p_name   = 'ZSARVANA_LOGO'
      p_id     = 'BMAP'
      p_btype  = 'BCOL'
    RECEIVING
      p_bmp    = l_graphic_xstr.

  IF sy-subrc <> 0.
  ENDIF.
  graphic_size = xstrlen( l_graphic_xstr ).
  l_graphic_conv = graphic_size.
  l_graphic_offs = 0.
  WHILE l_graphic_conv > 255.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
    APPEND graphic_table.
    l_graphic_offs = l_graphic_offs + 255.
    l_graphic_conv = l_graphic_conv - 255.
  ENDWHILE.
  graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
  APPEND graphic_table.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'IMAGE'
      subtype  = 'X-UNKNOWN'
      size     = graphic_size
      lifetime = 'T'
    TABLES
      data     = graphic_table
    CHANGING
      url      = url.

  CALL METHOD picture->load_picture_from_url
    EXPORTING
      url = url.
  CALL METHOD picture->set_display_mode
    EXPORTING
      display_mode = picture->display_mode_fit_center.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
FORM clear .
  CLEAR :gv_mod, gs_layo, gs_inwd_hdr,gv_ebeln, gs_hdr.
  REFRESH : gt_hdr , gt_fieldcat, gt_price.
  IF grid IS BOUND.
    grid->free( ).
    CLEAR grid.
    container->free( ).
    CLEAR container.
  ENDIF.
*  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_trans .
  DATA: lt_values TYPE TABLE OF vrm_value.
  SELECT lifnr , name1 INTO TABLE @DATA(lt_trns) FROM lfa1 WHERE ktokk = 'ZTAN'.
  IF lt_trns IS NOT INITIAL.
    DELETE lt_trns WHERE lifnr = '0000100001'.
    REFRESH lt_values.
    LOOP AT lt_trns ASSIGNING FIELD-SYMBOL(<ls_trns>).
      APPEND VALUE #( key = <ls_trns>-lifnr text = <ls_trns>-name1 ) TO lt_values.
    ENDLOOP.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'P_TRNS'
        values          = lt_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_fields.
  IF r_lp IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'OP'.
        screen-input = c_x.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'LP'.
        screen-input = c_x.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_SERVICE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_service_po .
  DATA:
    lv_item(5)      VALUE  '00010',
    lv_pack_no(10)  VALUE  '0000000001',
    lv_ext_line(10) VALUE  '0000000010',
    lv_serial_no(2) VALUE  '01',
    lt_wgh01        TYPE TABLE OF wgh01.

  REFRESH : posrvaccessvalues, item, itemx, return,poservices,poaccount,poaccountx.
  CLEAR : header, headerx, ls_poservices, ls_posrvaccessvalues, ls_poaccount  ,ls_poaccountx.
  READ TABLE  gt_hdr ASSIGNING FIELD-SYMBOL(<gs_hdr>) INDEX 1.
  IF gs_inwd_hdr-status = c_02.
    MESSAGE i059(zmsg_cls).
    LEAVE LIST-PROCESSING.
  ENDIF.
*** Bay Validation
  IF <gs_hdr>-bay IS INITIAL.
    MESSAGE e095(zmsg_cls).
    EXIT.
  ENDIF.
  IF gs_inwd_hdr-act_no_bud <> ( <gs_hdr>-small_bundle + <gs_hdr>-big_bundle ).
    MESSAGE e031(zmsg_cls).
    EXIT.
  ELSE.
***  'NB'
    DATA : lv_srvpos TYPE a729-srvpos.
*** Service Materials
    SELECT * FROM tvarvc INTO TABLE @DATA(lt_act) WHERE name IN ( 'ZZSMALL_BUNDLE', 'ZZBIG_BUNDLE' ).
    SELECT SINGLE bukrs, ekorg, ekgrp FROM ekko INTO @DATA(ls_org) WHERE ebeln = @gs_inwd_hdr-ebeln.
    SELECT SINGLE matkl , werks FROM ekpo INTO @DATA(ls_ekpo) WHERE ebeln = @gs_inwd_hdr-ebeln.
*** Vandor City
    SELECT SINGLE ort01 FROM lfa1 INTO @DATA(lv_city) WHERE lifnr  = @gs_inwd_hdr-lifnr.
*** Transporter Price based on City
    SELECT a729~lifnr
       a729~srvpos
       a729~userf1_txt
       a729~knumh
       konp~kbetr
       INTO TABLE gt_price
       FROM a729 AS a729
       INNER JOIN konp AS konp ON konp~knumh = a729~knumh
       WHERE a729~lifnr = gs_inwd_hdr-trns AND userf1_txt = lv_city
       AND a729~kschl = 'PRS' AND datab LE sy-datum AND datbi GE sy-datum.
    IF sy-subrc <> 0.
      MESSAGE e037(zmsg_cls) WITH gs_inwd_hdr-trns lv_city.
    ENDIF.
*** Material Hierarchy
    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
      EXPORTING
        matkl       = ls_ekpo-matkl
        spras       = sy-langu
      TABLES
        o_wgh01     = lt_wgh01
      EXCEPTIONS
        no_basis_mg = 1
        no_mg_hier  = 2
        OTHERS      = 3.
    IF sy-subrc <> 0.
      MESSAGE e036(zmsg_cls) WITH ls_ekpo-matkl. " Hierarchy is not maintained' TYPE 'E'.
    ENDIF.
    READ TABLE lt_wgh01 ASSIGNING FIELD-SYMBOL(<ls_wgh01>) INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM zgl_acc_t INTO @DATA(ls_gl) WHERE werks = @ls_ekpo-werks AND wwgha = @<ls_wgh01>-wwgha.
      IF sy-subrc <> 0.
        MESSAGE e035(zmsg_cls) WITH ls_ekpo-werks <ls_wgh01>-wwghb.
      ENDIF.
    ENDIF.
****  Header Details
    header-comp_code    = ls_org-bukrs.
    header-doc_type     = c_doc.
    header-vendor       = gs_hdr-trns.
    header-purch_org    = ls_org-ekorg.
    header-pur_group    = ls_org-ekgrp.
    header-currency     = 'INR'.

    headerx-comp_code   = c_x.
    headerx-vendor      = c_x.
    headerx-doc_type    = c_x.
    headerx-purch_org   = c_x.
    headerx-pur_group   = c_x.
    headerx-currency    = c_x.
*
    REFRESH item.
    REFRESH itemx.
***  For Small Bundle
    IF <gs_hdr>-small_bundle IS NOT INITIAL AND <gs_hdr>-big_bundle IS NOT INITIAL.
      READ TABLE lt_act ASSIGNING FIELD-SYMBOL(<ls_act>) WITH KEY name = 'ZZSMALL_BUNDLE'.
      IF sy-subrc = 0 .
*** Main Item Data
        item-po_item        = lv_item.
        item-short_text     = 'Service PO'.
        item-plant          = ls_ekpo-werks.
        item-tax_code       = '1C'.
        item-matl_group     = ls_ekpo-matkl.
        item-item_cat       = c_9.
        item-acctasscat     = c_k.
        item-period_ind_expiration_date = c_d.
        item-pckg_no        = lv_pack_no.

*** Main Item Data Update Flags
        itemx-po_item        = lv_item.
        itemx-po_itemx       = c_x.
        itemx-short_text     = c_x.
        itemx-plant          = c_x.
        itemx-tax_code       = c_x.
        itemx-matl_group     = c_x.
        itemx-item_cat       = c_x.
        itemx-acctasscat     = c_x.
        itemx-acctasscat     = c_x.
        itemx-period_ind_expiration_date     = c_x.
        itemx-pckg_no        = c_x.
        APPEND item.
        APPEND itemx .
        CLEAR : itemx , item.

*** Account Assignment Data
        ls_poaccount-po_item     = lv_item.
        ls_poaccount-serial_no   = lv_serial_no.
        ls_poaccount-gl_account  = ls_gl-gl_account.
        ls_poaccount-costcenter  = ls_gl-costcenter.
*** Account Assignment Data Update Flags
        ls_poaccountx-po_item    = lv_item.
        ls_poaccountx-po_itemx   = c_x.
        ls_poaccountx-serial_no  = c_x.
        ls_poaccountx-gl_account = c_x.
        ls_poaccountx-costcenter = c_x.
        APPEND ls_poaccount TO poaccount.
        APPEND ls_poaccountx TO poaccountx.
        CLEAR : ls_poaccount, ls_poaccountx.

*** Serices
***   Line Item 1
        ls_poservices-pckg_no    = lv_pack_no.
        ls_poservices-line_no    = lv_pack_no.
        ls_poservices-outl_ind   = c_x.
        ls_poservices-subpckg_no = lv_pack_no + 1.
        APPEND ls_poservices TO poservices.
        CLEAR : ls_poservices.

***   Line Item 2
        CLEAR : lv_srvpos.
        lv_srvpos =  <ls_act>-low.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_srvpos
          IMPORTING
            output = lv_srvpos.
        READ TABLE gt_price ASSIGNING FIELD-SYMBOL(<ls_price>) WITH KEY srvpos = lv_srvpos lifnr = <gs_hdr>-trns.
        IF sy-subrc = 0.
          ls_poservices-pckg_no    = lv_pack_no + 1.
          ls_poservices-line_no    = lv_pack_no + 1.
          ls_poservices-ext_line   = lv_ext_line.
          ls_poservices-service    = <ls_price>-srvpos.
          ls_poservices-quantity   = <gs_hdr>-small_bundle.
          ls_poservices-base_uom   = 'AU'.
          ls_poservices-gr_price   = <ls_price>-kbetr.
          ls_poservices-short_text = 'SMALL BUNDLE'.
          APPEND ls_poservices TO poservices.
          CLEAR : ls_poservices.

*** Services Values
          ls_posrvaccessvalues-pckg_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-line_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-serno_line = lv_serial_no.
          ls_posrvaccessvalues-percentage = '100'.
          ls_posrvaccessvalues-serial_no  = lv_serial_no.
          APPEND ls_posrvaccessvalues TO posrvaccessvalues.
          CLEAR : ls_posrvaccessvalues.
        ELSE.
          MESSAGE e044(zmsg_cls) WITH <gs_hdr>-trns lv_city lv_srvpos.
        ENDIF.
      ENDIF.

      READ TABLE lt_act ASSIGNING <ls_act> WITH KEY name = 'ZZBIG_BUNDLE'.
      IF sy-subrc = 0 .
        lv_srvpos =  <ls_act>-low.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_srvpos
          IMPORTING
            output = lv_srvpos.
        READ TABLE gt_price ASSIGNING <ls_price> WITH KEY srvpos = lv_srvpos lifnr = <gs_hdr>-trns.
        IF sy-subrc = 0.
***   Line Item 3
          ls_poservices-pckg_no    = lv_pack_no + 1.
          ls_poservices-line_no    = lv_pack_no + 2.
          ls_poservices-ext_line   = lv_ext_line + 10.
          ls_poservices-service    = <ls_price>-srvpos.
          ls_poservices-quantity   = <gs_hdr>-big_bundle.
          ls_poservices-base_uom   = 'AU'.
          ls_poservices-gr_price   = <ls_price>-kbetr.
          ls_poservices-short_text = 'BIG BUNDLE'.
          APPEND ls_poservices TO poservices.
          CLEAR : ls_poservices.

*** SERVICES VALUES
          ls_posrvaccessvalues-pckg_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-line_no    = lv_pack_no + 2.
          ls_posrvaccessvalues-serno_line = lv_serial_no.
          ls_posrvaccessvalues-percentage = '100'.
          ls_posrvaccessvalues-serial_no  = lv_serial_no.
          APPEND ls_posrvaccessvalues TO posrvaccessvalues.
          CLEAR : ls_posrvaccessvalues.
        ELSE.
          MESSAGE e044(zmsg_cls) WITH <gs_hdr>-trns lv_city lv_srvpos.
        ENDIF.
      ENDIF.
    ELSEIF <gs_hdr>-small_bundle IS NOT INITIAL.
      READ TABLE lt_act ASSIGNING <ls_act> WITH KEY name = 'ZZSMALL_BUNDLE'.
      IF sy-subrc = 0 .
*** Main Item Data
        item-po_item        = lv_item.
        item-short_text     = 'Service PO'.
        item-plant          = ls_ekpo-werks.
        item-tax_code       = '1C'.
        item-matl_group     = ls_ekpo-matkl.
        item-item_cat       = c_9.
        item-acctasscat     = c_k.
        item-period_ind_expiration_date = c_d.
        item-pckg_no        = lv_pack_no.

*** Main Item Data Update Flags
        itemx-po_item        = lv_item.
        itemx-po_itemx       = c_x.
        itemx-short_text     = c_x.
        itemx-plant          = c_x.
        itemx-tax_code       = c_x.
        itemx-matl_group     = c_x.
        itemx-item_cat       = c_x.
        itemx-acctasscat     = c_x.
        itemx-acctasscat     = c_x.
        itemx-period_ind_expiration_date     = c_x.
        itemx-pckg_no        = c_x.
        APPEND item.
        APPEND itemx .
        CLEAR : itemx , item.

*** Account Assignment Data
        ls_poaccount-po_item     = lv_item.
        ls_poaccount-serial_no   = lv_serial_no.
        ls_poaccount-gl_account  = ls_gl-gl_account.
        ls_poaccount-costcenter  = ls_gl-costcenter.

*** Account Assignment Data Update Flags
        ls_poaccountx-po_item    = lv_item.
        ls_poaccountx-po_itemx   = c_x.
        ls_poaccountx-serial_no  = c_x.
        ls_poaccountx-gl_account = c_x.
        ls_poaccountx-costcenter = c_x.
        APPEND ls_poaccount TO poaccount.
        APPEND ls_poaccountx TO poaccountx.
        CLEAR : ls_poaccount, ls_poaccountx.

*** Serices
***   Line Item 1
        ls_poservices-pckg_no    = lv_pack_no.
        ls_poservices-line_no    = lv_pack_no.
        ls_poservices-outl_ind   = c_x.
        ls_poservices-subpckg_no = lv_pack_no + 1.
        APPEND ls_poservices TO poservices.
        CLEAR : ls_poservices.
***   Line Item 2
        CLEAR : lv_srvpos.
        lv_srvpos =  <ls_act>-low.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_srvpos
          IMPORTING
            output = lv_srvpos.
        READ TABLE gt_price ASSIGNING <ls_price> WITH KEY srvpos = lv_srvpos lifnr = <gs_hdr>-trns.
        IF sy-subrc = 0.
          ls_poservices-pckg_no    = lv_pack_no + 1.
          ls_poservices-line_no    = lv_pack_no + 1.
          ls_poservices-ext_line   = lv_ext_line.
          ls_poservices-service    = <ls_price>-srvpos.
          ls_poservices-quantity   = <gs_hdr>-small_bundle.
          ls_poservices-base_uom   = 'AU'.
          ls_poservices-gr_price   = <ls_price>-kbetr.
          ls_poservices-short_text = 'SMALL BUNDLE'.
          APPEND ls_poservices TO poservices.
          CLEAR : ls_poservices.

*** Services Values
          ls_posrvaccessvalues-pckg_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-line_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-serno_line = lv_serial_no.
          ls_posrvaccessvalues-percentage = '100'.
          ls_posrvaccessvalues-serial_no  = lv_serial_no.
          APPEND ls_posrvaccessvalues TO posrvaccessvalues.
          CLEAR : ls_posrvaccessvalues.
        ELSE.
          MESSAGE e044(zmsg_cls) WITH <gs_hdr>-trns lv_city lv_srvpos.
        ENDIF.
      ENDIF.
    ELSEIF <gs_hdr>-big_bundle IS NOT INITIAL.
      READ TABLE lt_act ASSIGNING <ls_act> WITH KEY name = 'ZZBIG_BUNDLE'.
      IF sy-subrc = 0 .
*** Main Item Data
        item-po_item        = lv_item.
        item-short_text     = 'Service PO'.
        item-plant          = ls_ekpo-werks.
        item-tax_code       = '1C'.
        item-matl_group     = ls_ekpo-matkl.
        item-item_cat       = c_9.
        item-acctasscat     = c_k.
        item-period_ind_expiration_date = c_d.
        item-pckg_no        = lv_pack_no.

*** Main Item Data Update Flags
        itemx-po_item        = lv_item.
        itemx-po_itemx       = c_x.
        itemx-short_text     = c_x.
        itemx-plant          = c_x.
        itemx-tax_code       = c_x.
        itemx-matl_group     = c_x.
        itemx-item_cat       = c_x.
        itemx-acctasscat     = c_x.
        itemx-acctasscat     = c_x.
        itemx-period_ind_expiration_date     = c_x.
        itemx-pckg_no        = c_x.
        APPEND item.
        APPEND itemx .
        CLEAR : itemx , item.

*** Account Assignment Data
        ls_poaccount-po_item     = lv_item.
        ls_poaccount-serial_no   = lv_serial_no.
        ls_poaccount-gl_account  = ls_gl-gl_account.
        ls_poaccount-costcenter  = ls_gl-costcenter.

*** Account Assignment Data Update Flags
        ls_poaccountx-po_item    = lv_item.
        ls_poaccountx-po_itemx   = c_x.
        ls_poaccountx-serial_no  = c_x.
        ls_poaccountx-gl_account = c_x.
        ls_poaccountx-costcenter = c_x.
        APPEND ls_poaccount TO poaccount.
        APPEND ls_poaccountx TO poaccountx.
        CLEAR : ls_poaccount, ls_poaccountx.

*** Serices
***   Line Item 1
        ls_poservices-pckg_no    = lv_pack_no.
        ls_poservices-line_no    = lv_pack_no.
        ls_poservices-outl_ind   = c_x.
        ls_poservices-subpckg_no = lv_pack_no + 1.
        APPEND ls_poservices TO poservices.
        CLEAR : ls_poservices.

***   Line Item 2
        CLEAR : lv_srvpos.
        lv_srvpos =  <ls_act>-low.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_srvpos
          IMPORTING
            output = lv_srvpos.
        READ TABLE gt_price ASSIGNING <ls_price> WITH KEY srvpos = lv_srvpos lifnr = <gs_hdr>-trns.
        IF sy-subrc = 0.
          ls_poservices-pckg_no    = lv_pack_no + 1.
          ls_poservices-line_no    = lv_pack_no + 1.
          ls_poservices-ext_line   = lv_ext_line.
          ls_poservices-service    = <ls_price>-srvpos.
          ls_poservices-quantity   = <gs_hdr>-big_bundle.
          ls_poservices-base_uom   = 'AU'.
          ls_poservices-gr_price   = <ls_price>-kbetr.
          ls_poservices-short_text = 'BIG BUNDLE'.
          APPEND ls_poservices TO poservices.
          CLEAR : ls_poservices.

*** Services Values
          ls_posrvaccessvalues-pckg_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-line_no    = lv_pack_no + 1.
          ls_posrvaccessvalues-serno_line = lv_serial_no.
          ls_posrvaccessvalues-percentage = '100'.
          ls_posrvaccessvalues-serial_no  = lv_serial_no.
          APPEND ls_posrvaccessvalues TO posrvaccessvalues.
          CLEAR : ls_posrvaccessvalues.
        ELSE.
          MESSAGE e044(zmsg_cls) WITH <gs_hdr>-trns lv_city lv_srvpos.
        ENDIF.
      ENDIF.
    ENDIF.

** PO Creation
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader          = header                 " Header Data
        poheaderx         = headerx                " Header Data (Change Parameter)
      IMPORTING
        exppurchaseorder  = gv_ebeln               " Purchasing Document Number
      TABLES
        return            = return                 " Return Parameter
        poitem            = item                   " Item Data
        poitemx           = itemx                  " Item Data (Change Parameter)
        poaccount         = poaccount              " Account Assignment Fields
        poaccountx        = poaccountx             " Account Assignment Fields (Change Parameter)
        poservices        = poservices             " External Services: Service Lines
        posrvaccessvalues = posrvaccessvalues.     " External Services: Account Assignment Distribution for Service Lines

    READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_x.

      gs_inwd_hdr-small_bundle  = <gs_hdr>-small_bundle.
      gs_inwd_hdr-big_bundle    = <gs_hdr>-big_bundle.
      gs_inwd_hdr-frt_no        = <gs_hdr>-frt_no.
      gs_inwd_hdr-frt_amt       = <gs_hdr>-frt_amt.
      gs_inwd_hdr-service_po    = gv_ebeln.
      MODIFY zinw_t_hdr FROM gs_inwd_hdr.
      COMMIT WORK.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
      <ls_ret>-message_v3 <ls_ret>-message_v4.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SERVICE_ENTRYSHEET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_INWD_HDR_SERVICE_PO
*&---------------------------------------------------------------------*
FORM service_entrysheet  USING  gs_inwd_hdr-service_po.

  DATA:
    bapi_esll        LIKE bapiesllc OCCURS 1 WITH HEADER LINE,
    po_items         TYPE bapiekpo OCCURS 0 WITH HEADER LINE,
    po_services      TYPE bapiesll OCCURS 0 WITH HEADER LINE,
    bapi_return_po   TYPE TABLE OF bapiret2,
    wa_header        TYPE bapiessrc,
    i_return         TYPE TABLE OF bapiret2,
    s_return         TYPE bapiret2,
    serial_no        LIKE bapiesknc-serial_no,
    line_no          LIKE bapiesllc-line_no,
    ws_entrysheet_no TYPE bapiessr-sheet_no,
    wa_po_header     TYPE bapiekkol,
    ls_status        TYPE zinw_t_status,
    ls_qr_add        TYPE zqr_t_add.

  IF gs_inwd_hdr-service_po IS NOT INITIAL AND gs_inwd_hdr-status = c_01.
    CALL FUNCTION 'BAPI_PO_GETDETAIL'
      EXPORTING
        purchaseorder    = gs_inwd_hdr-service_po
        items            = 'X'
        services         = 'X'
      IMPORTING
        po_header        = wa_po_header
      TABLES
        po_items         = po_items
        po_item_services = po_services
        return           = bapi_return_po.

    wa_header-po_number  = po_items-po_number.
    wa_header-po_item    = po_items-po_item.
    wa_header-short_text = 'Service Entry Sheet'.
    wa_header-acceptance = 'X'.
*** Manual input for Posting date : 01.06.2020
    IF  gt_hdr[ 1 ]-post_date IS NOT INITIAL.
      wa_header-post_date = gt_hdr[ 1 ]-post_date.
    ELSE.
      wa_header-post_date = sy-datum.
    ENDIF.

    wa_header-doc_date = sy-datum.
    wa_header-pckg_no = 1.
    serial_no = 0.
    line_no = 1.

    bapi_esll-pckg_no = 1.
    bapi_esll-line_no = line_no.
    bapi_esll-outl_level = '0'.
    bapi_esll-outl_ind = 'X'.
    bapi_esll-subpckg_no = 2.
    APPEND bapi_esll.

    LOOP AT po_services WHERE NOT short_text IS INITIAL.
      CLEAR bapi_esll.
      bapi_esll-pckg_no = 2.
      bapi_esll-line_no = line_no * 10.
      bapi_esll-service = po_services-service.
      bapi_esll-short_text = po_services-short_text.
      bapi_esll-quantity = po_services-quantity.
      bapi_esll-gr_price = po_services-gr_price.
      bapi_esll-price_unit = po_services-price_unit.
      APPEND bapi_esll.
      line_no = line_no + 1.
    ENDLOOP.

    CALL FUNCTION 'BAPI_ENTRYSHEET_CREATE'
      EXPORTING
        entrysheetheader   = wa_header
      IMPORTING
        entrysheet         = ws_entrysheet_no
      TABLES
        entrysheetservices = bapi_esll
        return             = i_return.

    READ TABLE i_return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_x.

      gs_inwd_hdr-status        = c_02.
*** Status Update
      ls_status-inwd_doc        = gs_inwd_hdr-inwd_doc.
      ls_status-qr_code         = gs_inwd_hdr-qr_code.
      ls_status-status_field    = c_qr_code.
      ls_status-status_value    = c_qr02.
      ls_status-created_by      = sy-uname.
      ls_status-created_date    = sy-datum.
      ls_status-created_time    = sy-uzeit.
      ls_status-description     = 'Gate In'.
      gv_mod = c_d.
      ls_qr_add-qr_code   = gs_inwd_hdr-qr_code.
      ls_qr_add-bay       = gt_hdr[ 1 ]-bay.
      MODIFY zinw_t_status FROM ls_status.
      MODIFY zinw_t_hdr FROM gs_inwd_hdr.
      MODIFY zqr_t_add FROM ls_qr_add.
      COMMIT WORK.
      MESSAGE s022(zmsg_cls) WITH gv_ebeln.
***   Service PO Mail
      zcl_send_mail=>service_po( i_ebeln = gv_ebeln ).
    ELSE.
      MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
      <ls_ret>-message_v3 <ls_ret>-message_v4.
    ENDIF.
  ENDIF.
ENDFORM.
