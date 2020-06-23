*&---------------------------------------------------------------------*
*& Include          SAPMZMM_SUBCON_SALES_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form DISP_LOGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disp_logo .
  IF picture IS NOT BOUND.
    CALL METHOD cl_gui_cfw=>flush.
    CREATE OBJECT:
   scont01 EXPORTING container_name = 'CC_LG',
   picture EXPORTING parent = scont01.

    CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
      EXPORTING
        p_object       = 'GRAPHICS'
        p_name         = 'ZSARAVANA_LG'
        p_id           = 'BMAP'
        p_btype        = 'BCOL'
      RECEIVING
        p_bmp          = l_graphic_xstr
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM scontainer .
  IF scont IS INITIAL.
    REFRESH: xfcat, xsort.
    IF lt_fcat[] IS INITIAL.
      PERFORM prepare_fcatlog .
    ENDIF.

    ls_layo-zebra       = 'X'.
**    ls_layo-stylefname = 'STYLE'.
**    ls_layo-cwidth_opt  = 'X'.
    ls_layo-no_toolbar  = space.
    ls_layo-grid_title  = title.
    ls_layo-sel_mode    = sel_mode.
    x-report = sy-repid .

***    PERFORM exclude_toolbar .
    IF lt_toolbar_excluding IS INITIAL.
***      lt_toolbar_excluding = VALUE #( ( cl_gui_alv_grid=>mc_fc_excl_all ) ).
      lt_toolbar_excluding =  VALUE #(   ( cl_gui_alv_grid=>mc_fc_loc_insert_row    )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste         )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy          )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy_row      )
                          ( cl_gui_alv_grid=>mc_fc_loc_cut           )
                          ( cl_gui_alv_grid=>mc_fc_loc_undo          )
                          ( cl_gui_alv_grid=>mc_fc_loc_append_row    )
                          ( cl_gui_alv_grid=>mc_fc_print             )
                          ( cl_gui_alv_grid=>mc_fc_loc_move_row      )
                          ( cl_gui_alv_grid=>mc_fc_find_more         )
                          ( cl_gui_alv_grid=>mc_fc_sum               )
                          ( cl_gui_alv_grid=>mc_fc_average           )
                          ( cl_gui_alv_grid=>mc_fc_maximum           )
                          ( cl_gui_alv_grid=>mc_fc_minimum           )
                          ( cl_gui_alv_grid=>mc_fc_detail           )
                         ).
    ENDIF.
    CREATE OBJECT scont EXPORTING container_name = cont.
    CREATE OBJECT sgrid EXPORTING i_parent = scont.
***    PERFORM grid_input USING 1 .
    PERFORM register_events .
    CALL METHOD sgrid->set_table_for_first_display
      EXPORTING
        is_layout            = ls_layo
***        i_structure_name = 'ZMIRO01'
        is_variant           = x
        i_save               = 'A'
        i_default            = 'X'
        it_toolbar_excluding = lt_toolbar_excluding[]
      CHANGING
        it_outtab            = xsubcon_itm[]
        it_fieldcatalog      = lt_fcat[]
*       it_sort              = xsort[]
*       IT_FILTER            = XFILT[]
      .
*Create object of the event class and setting handler for double click
***    CREATE OBJECT seventr.
***    SET HANDLER seventr->handle_hotspot_click FOR sgrid.
  ELSE.
    DATA ls_stable TYPE lvc_s_stbl.

    ls_stable-row = abap_true.
    ls_stable-col = abap_true.
    CALL METHOD sgrid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcatlog .
  DATA: wa_fc  TYPE  lvc_s_fcat.
  DATA : sno TYPE int4 .
  DATA: lo_struct_descr TYPE REF TO cl_abap_structdescr,
        lv_abs_name     TYPE dd02l-tabname,
        lv_pos          TYPE i VALUE 0.
  IF fieldcat[] IS INITIAL.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       I_BUFFER_ACTIVE        =
        i_structure_name       = 'ZSUBCON_ITMS'
*       I_CLIENT_NEVER_DISPLAY = 'X'
*       I_BYPASSING_BUFFER     =
*       I_INTERNAL_TABNAME     =
      CHANGING
        ct_fieldcat            = fieldcat[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
*    implement suitable error handling here
    ENDIF.

***    DELETE fieldcat WHERE fieldname = 'STATUS' .
    DELETE fieldcat WHERE fieldname = 'MANDT' .
  ENDIF.
  CLEAR lv_pos .
  CLEAR ls_fcat.
**-> Fieldcat_position -> sjena <- 10.05.2019 03:21:51
****  ls_fcat-fieldname = 'STATUS' .
****  ls_fcat-seltext = 'Status' .                              "#EC NOTEXT
****  CLEAR ls_fcat-tech .
****  ls_fcat-scrtext_m = 'Status' .                            "#EC NOTEXT
****  ls_fcat-scrtext_s = 'Status' .                            "#EC NOTEXT
****  ADD 1 TO lv_pos .
****  ls_fcat-col_pos = lv_pos .
****  ls_fcat-icon = abap_true.
****  ls_fcat-emphasize = 'C3' .
****  ls_fcat-outputlen = '4' .
****  ls_fcat-just = 'C' .
****  APPEND  ls_fcat TO lt_fcat  .
****  CLEAR ls_fcat .
  LOOP AT fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN 'ICON'.
        ls_fcat-icon = abap_true.
        ls_fcat-emphasize = 'C3'.
        ls_fcat-outputlen = 6.
      WHEN 'MENGE'.
        ls_fcat-outputlen = 10 .
        ls_fcat-edit = abap_true .
      WHEN 'MATNR' .
        ls_fcat-outputlen = 14.
      WHEN 'MAKTX' .
        ls_fcat-outputlen = 20.
      WHEN 'LABST' OR 'STPRS' OR 'VERPR' OR 'REQ_QTY' OR 'CLABS' .
        ls_fcat-outputlen = 9.
*      WHEN
    ENDCASE.

    IF sdisp = abap_true.
      CLEAR ls_fcat-edit .
    ENDIF.

    IF ls_fcat-fieldname = 'REQ_QTY'.
      ls_fcat-scrtext_l = ls_fcat-scrtext_m = ls_fcat-scrtext_s =  'Req.Qty.'.
    ENDIF.
    IF ls_fcat-tech <> abap_true.
      ADD 1 TO lv_pos .
      ls_fcat-col_pos = lv_pos.
      APPEND ls_fcat TO lt_fcat.
      CLEAR ls_fcat.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_EVENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_events .
  FREE g_event_receiver .
  CREATE OBJECT g_event_receiver.
  SET HANDLER g_event_receiver->handle_on_f4 FOR sgrid.
  SET HANDLER g_event_receiver->handle_data_changed FOR sgrid.
****  SET HANDLER g_event_receiver->handle_double_click FOR sgrid. "commented by sjena on 22.12.2018 23:31:20
****  SET HANDLER g_event_receiver->handle_hotspot_click FOR sgrid.
  SET HANDLER g_event_receiver->handle_user_command FOR sgrid .
  " Set


*--> Commented_as_added_buttons_separately_for_User_friendly_inputs -> sjena <- 18.05.2019 13:23:19
*CREATE alv event handler
  CREATE OBJECT c_alv_toolbar
    EXPORTING
      io_alv_grid = sgrid.
* Register event handler
****  SET HANDLER c_alv_toolbar->on_toolbar FOR sgrid.


*  registering the EDIT Event

  CALL METHOD sgrid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.                                 " IF SY-SUBRC NE 0
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GENERATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- SEBELN
*&---------------------------------------------------------------------*
FORM generate_po  CHANGING sebeln TYPE ebeln.
  "Generate Subcontracting PO
  DATA:
    header         LIKE bapimepoheader,
    headerx        LIKE bapimepoheaderx,
    item           TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
    itemx          TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
    poschedule     TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
    poschedulex    TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
    pocomponents   TYPE TABLE OF bapimepocomponent WITH HEADER LINE,
    pocomponentsx  TYPE TABLE OF  bapimepocomponentx WITH HEADER LINE,
    extensionin    TYPE TABLE OF bapiparex,
    ls_extensionin TYPE bapiparex,
    return         TYPE TABLE OF bapiret2,
    bapi_te_po     TYPE bapi_te_mepoheader,
    bapi_te_pox    TYPE bapi_te_mepoheaderx,
    lv_item        TYPE ebelp,
    lv_schd_line   TYPE etenr.

  REFRESH : item           ,
            itemx          ,
            poschedule     ,
            poschedulex    ,
            pocomponents   ,
            pocomponentsx  ,
            extensionin    ,
            return.

  CLEAR : header          ,
          headerx         ,
          ls_extensionin  ,
          bapi_te_po      ,
          bapi_te_pox     ,
          lv_item         ,
          lv_schd_line    .

  CHECK sebeln IS INITIAL.
  header-comp_code    = '1000'.
  header-creat_date   = sy-datum.
  header-vendor       = '0000200012'.
  header-doc_type     = 'NB' . " 'ZPRO'."c_zpro.
  header-langu        = sy-langu.
  header-purch_org    = '1000'.
  header-pur_group    = 'P01'.
  header-pmnttrms     = '0001'.
  header-item_intvl   = '00010'.
  header-exch_rate    = 1.
  header-currency     = header-currency_iso  = xsubcon_hdr-waers.

  headerx-comp_code   = abap_true .
  headerx-creat_date  = abap_true .
  headerx-vendor      = abap_true .
  headerx-doc_type    = abap_true .
  headerx-langu       = abap_true .
  headerx-purch_org   = abap_true .
  headerx-pur_group   = abap_true .
  headerx-pmnttrms    = abap_true .
  headerx-item_intvl  = abap_true .
  headerx-exch_rate   = 1.
  headerx-currency    = headerx-currency_iso  = xsubcon_hdr-waers.

****  ls_extensionin-structure = 'BAPI_TE_MEPOHEADER'.
****  bapi_te_po-po_number = ' '.
****  bapi_te_po-approver1 = xsubcon_hdr-packing_head .  " Packing Dep Head
****  ls_extensionin-valuepart1 = bapi_te_po.
****  APPEND ls_extensionin TO extensionin.
****  CLEAR ls_extensionin.
****
****  ls_extensionin-structure = 'BAPI_TE_MEPOHEADERX'.
****  bapi_te_pox-po_number = ' '.
****  bapi_te_pox-approver1 = 'X'.
****  ls_extensionin-valuepart1 = bapi_te_pox.
****  APPEND ls_extensionin TO extensionin.
****  CLEAR ls_extensionin.

  REFRESH : item, itemx.
  lv_item = 10.
  lv_schd_line = 1.

  item-po_item         = lv_item.
  item-item_cat        = 'L'.
  item-material        = item-ematerial = item-material_long  = item-ematerial_long = xsubcon_hdr-matnr.
  item-plant           = xsubcon_hdr-werks.
  item-quantity        = xsubcon_hdr-menge.
  item-po_unit         = item-po_unit_iso = item-orderpr_un = item-orderpr_un_iso = xsubcon_hdr-meins.
  item-stge_loc        = 'FG01'.
  item-gr_pr_time      = 0.
  item-weightunit      = 'KG'.  "xsubcon_hdr-meins.
  item-weightunit_iso  = 'KGM'. "xsubcon_hdr-meins.
  item-producttype     = 1.
  item-prnt_price      = abap_true.
  item-info_upd        = 'C'.
  item-free_item       = abap_true.
  item-price_unit      = 1.
  item-conv_num1       = item-conv_den1  = 1.
  item-price_date      = sy-datum.

  itemx-po_item        = lv_item.
  itemx-item_cat       = abap_true.
  itemx-material       = itemx-ematerial  = itemx-material_long  = itemx-ematerial_long = abap_true.
  itemx-plant          = abap_true.
  itemx-quantity       = abap_true.
  itemx-po_unit        = itemx-po_unit_iso = itemx-orderpr_un = itemx-orderpr_un_iso = abap_true.
  itemx-stge_loc       = abap_true.
  itemx-gr_pr_time     = abap_true.
  itemx-weightunit     = abap_true.
  itemx-weightunit_iso = abap_true.
  itemx-producttype    = abap_true.
  itemx-period_ind_expiration_date  = abap_true.
  itemx-prnt_price     = abap_true.
  itemx-info_upd       = abap_true.
  itemx-free_item      = abap_true.
  itemx-price_unit     = abap_true.
  itemx-conv_num1      = abap_true.
  itemx-price_date     = abap_true.
  APPEND : item, itemx.
  CLEAR : itemx , item.
*** Schedule Line Items
  poschedule-po_item       = lv_item.
  poschedule-sched_line    = lv_schd_line.
  poschedule-delivery_date = sy-datum.
  poschedule-quantity      = xsubcon_hdr-menge.

*** Schedule Line Items Update Flag
  poschedulex-po_item       = lv_item.
  poschedulex-sched_line    = lv_schd_line.
  poschedulex-po_itemx      = abap_true.
  poschedulex-sched_linex   = abap_true.
  poschedulex-delivery_date = abap_true.
  poschedulex-quantity      = abap_true.
  APPEND : poschedule , poschedulex .
  CLEAR : poschedule, poschedulex.

  DATA : lv_item_no TYPE rspos VALUE 1.
***   PO Components
  LOOP AT xsubcon_itm .

    pocomponents-po_item        = lv_item.
    pocomponents-sched_line     =  lv_schd_line.
    pocomponents-item_no = |{ lv_item_no ALPHA = IN }| .
    pocomponents-material       = xsubcon_itm-matnr.
    pocomponents-entry_quantity = xsubcon_itm-menge * xsubcon_hdr-menge.
    pocomponents-entry_uom      = xsubcon_itm-meins.
    pocomponents-entry_uom_iso  = xsubcon_itm-meins."'KGM'.
    pocomponents-plant          = xsubcon_itm-werks.
    pocomponents-req_date       = sy-datum.
    pocomponents-item_cat       = 'L'.
    pocomponents-req_quan       = xsubcon_itm-menge.
    pocomponents-base_uom       = xsubcon_itm-meins.
    pocomponents-base_uom_iso   = xsubcon_itm-meins."'KGM'.
    pocomponents-change_id      = 'I'.

***   PO Components Update Flag
    pocomponentsx-po_item        = lv_item.
    pocomponentsx-sched_line     = lv_schd_line.
    pocomponentsx-item_no = |{ lv_item_no ALPHA = IN }| .
    pocomponentsx-po_itemx       = abap_true.
    pocomponentsx-sched_linex    = pocomponentsx-item_nox = abap_true.
    pocomponentsx-material       = abap_true.
    pocomponentsx-entry_quantity = abap_true.
    pocomponentsx-entry_uom      = abap_true.
    pocomponentsx-entry_uom_iso  = abap_true.
    pocomponentsx-plant          = abap_true.
    pocomponentsx-req_date       = abap_true.
    pocomponentsx-item_cat       = abap_true.
    pocomponentsx-req_quan       = abap_true.
    pocomponentsx-base_uom       = abap_true.
    pocomponentsx-base_uom_iso   = abap_true.
    pocomponentsx-change_id      = abap_true.

    APPEND : pocomponents , pocomponentsx.
    CLEAR : pocomponents , pocomponentsx.
    ADD 1 TO lv_item_no.
  ENDLOOP.
  CLEAR : lv_item_no.
***    lv_schd_line = lv_schd_line + 1.
***      lv_item = lv_item + 10.

  CHECK item[] IS NOT INITIAL AND pocomponents[] IS NOT INITIAL.
*** Return PO Creation
  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader         = header
      poheaderx        = headerx
    IMPORTING
      exppurchaseorder = sebeln
    TABLES
      return           = return
      poitem           = item
      poitemx          = itemx
      poschedule       = poschedule
      poschedulex      = poschedulex
      extensionin      = extensionin
      pocomponents     = pocomponents
      pocomponentsx    = pocomponentsx.

  READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ELSE.
    ssubrc = 4.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_541
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- SSUBRC
*&---------------------------------------------------------------------*
FORM goods_movement_541  CHANGING ssubrc TYPE sy-subrc
                          xsubcon_hdr_mblnr_541  TYPE mblnr
                          xsubcon_hdr_mjahr_541  TYPE mjahr.
*** BAPI Structure Declaration
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    ls_status       TYPE zinw_t_status,
    c_mvt_06(2)     VALUE '06',
    c_541           TYPE bwart VALUE '541'.

  REFRESH : lt_bapiret  ,
            lt_gmvt_item.

  CLEAR : ls_gmvt_header ,
          ls_gmvt_item   ,
          ls_gmvt_headret,ls_status.
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  DATA : lv_open_qty TYPE menge_d.
  DATA : lv_act_qty TYPE menge_d.

  CHECK xsubcon_itm[] IS NOT INITIAL.
  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @sebeln.
  IF sy-subrc = 0.
****    SELECT DISTINCT mchb~matnr, mchb~charg, mchb~clabs, mast~matnr AS po_matnr ,stpo~meins, stpo~menge INTO TABLE @DATA(lt_mchb)
****           FROM mchb AS mchb INNER JOIN stpo AS stpo ON stpo~idnrk = mchb~matnr
****           INNER JOIN mast AS mast ON mast~stlnr = stpo~stlnr
****           INNER JOIN mseg AS mseg ON mseg~matnr = mchb~matnr AND mseg~charg = mchb~charg
****           FOR ALL ENTRIES IN @lt_ekpo
****           WHERE mast~matnr = @lt_ekpo-matnr AND mchb~clabs > 0 AND mseg~werks = @xsubcon_hdr-werks AND mseg~mblnr = @xsubcon_hdr-mblnr_b_101.
***    IF sy-subrc = 0.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
    ls_gmvt_header-pstng_date       = '20200331'."sy-datum.
    ls_gmvt_header-doc_date         = sy-datum.
    ls_gmvt_header-pr_uname         = sy-uname.
    ls_gmvt_header-ver_gr_gi_slip   = 1.

*** Looping the PO details.
    LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_item>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS
      LOOP AT xsubcon_itm.
        ls_gmvt_item-move_mat  = ls_gmvt_item-material  = ls_gmvt_item-material_long = ls_gmvt_item-move_mat_long = xsubcon_itm-matnr.
        ls_gmvt_item-move_type = c_541.
        ls_gmvt_item-po_number = <ls_item>-ebeln.
        ls_gmvt_item-po_item   = <ls_item>-ebelp.
        ls_gmvt_item-prod_date = sy-datum.
        ls_gmvt_item-vendor    = '0000200012'.
        ls_gmvt_item-plant     = ls_gmvt_item-move_plant = xsubcon_hdr-werks.
        ls_gmvt_item-stge_loc  = 'FG01'.
        ls_gmvt_item-entry_uom = xsubcon_itm-meins.
        ls_gmvt_item-entry_uom_iso = xsubcon_itm-meins."'KGM'.
        ls_gmvt_item-batch     = ls_gmvt_item-val_type = ls_gmvt_item-move_batch = ls_gmvt_item-move_val_type = xsubcon_itm-charg.

***   Quantity Converstion
***        lv_act_qty = ( <ls_item>-menge - lv_open_qty ) * xsubcon_itm-menge.
***        IF xsubcon_itm-clabs GE lv_act_qty.
***          ls_gmvt_item-entry_qnt = lv_act_qty.
***          APPEND ls_gmvt_item TO lt_gmvt_item.
***          CLEAR ls_gmvt_item.
***          EXIT.
***        ELSE.
        ls_gmvt_item-entry_qnt = xsubcon_itm-menge * xsubcon_hdr-menge.
***        lv_open_qty = lv_open_qty + ls_gmvt_item-entry_qnt .
        APPEND ls_gmvt_item TO lt_gmvt_item.
        CLEAR ls_gmvt_item.
***        ENDIF.
      ENDLOOP.
    ENDLOOP.
*** Call the BAPI FM for GR posting
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = ls_gmvt_header
        goodsmvt_code    = c_mvt_06
      IMPORTING
        goodsmvt_headret = ls_gmvt_headret
      TABLES
        goodsmvt_item    = lt_gmvt_item
        return           = lt_bapiret.

    READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = se.
    IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      xsubcon_hdr_mblnr_541 = ls_gmvt_headret-mat_doc.
      xsubcon_hdr_mjahr_541 = ls_gmvt_headret-doc_year.
    ELSE.
*** Roll Back if any error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ssubrc = 4.
      MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
      <ls_ret>-message_v3 <ls_ret>-message_v4.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- SSUBRC
*&      <-- XSUBCON_HDR_MBLNR_101
*&      <-- XSUBCON_HDR_MJAHR101
*&---------------------------------------------------------------------*
FORM goods_movement_101  CHANGING ssubrc TYPE sy-subrc
                                  xsubcon_hdr_mblnr_101 TYPE mblnr
                                  xsubcon_hdr_mjahr_101 TYPE mjahr
                                  xsubcon_hdr_charg.

  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    c_101           TYPE bwart VALUE '101',
    c_543           TYPE bwart VALUE '543'.

  DATA  : szcon_rec_t TYPE zcon_rec_t.
  CLEAR : szcon_rec_t.
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  CLEAR  : ls_gmvt_header   ,
           ls_gmvt_item     ,
           ls_gmvt_headret  ,
           lv_line_id.
  REFRESH : lt_bapiret ,
            lt_gmvt_item.

  ls_gmvt_header-pstng_date = '20200331'. "sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 3.
  lv_line_id = '000001'.

  ls_gmvt_item-material  = ls_gmvt_item-material_long = xsubcon_hdr-matnr.
  ls_gmvt_item-move_type = c_101.
  ls_gmvt_item-plant     = xsubcon_hdr-werks.
  ls_gmvt_item-po_number = sebeln.
  ls_gmvt_item-po_item   = '00010'.
  ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = xsubcon_hdr-menge.
  ls_gmvt_item-entry_uom = ls_gmvt_item-entry_uom_iso = ls_gmvt_item-orderpr_un = ls_gmvt_item-orderpr_un_iso = xsubcon_hdr-meins.
  ls_gmvt_item-prod_date = sy-datum.
  ls_gmvt_item-mvt_ind   = 'B'.

  ls_gmvt_item-vendor    = '0000200012'.
  ls_gmvt_item-stge_loc  = 'FG01'.
  ls_gmvt_item-line_id   = lv_line_id.
  APPEND ls_gmvt_item TO lt_gmvt_item.
  CLEAR ls_gmvt_item.
  lv_line_id = lv_line_id + 1.
  LOOP AT xsubcon_itm.
    ls_gmvt_item-material  = ls_gmvt_item-material_long = xsubcon_itm-matnr.
    ls_gmvt_item-move_type = c_543.
    ls_gmvt_item-plant     = xsubcon_hdr-werks.
    ls_gmvt_item-po_number = sebeln.
    ls_gmvt_item-po_item   = sebelp.
    ls_gmvt_item-entry_qnt = xsubcon_itm-menge.
    ls_gmvt_item-entry_uom = xsubcon_itm-meins. " KG
    ls_gmvt_item-entry_uom_iso = xsubcon_itm-meins."'KGM' ."xsubcon_itm-MEINS.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type = xsubcon_itm-charg.

    ls_gmvt_item-vendor   = '0000200012'.
    ls_gmvt_item-spec_stock = 'O'.
    ls_gmvt_item-line_id = lv_line_id.
    ls_gmvt_item-parent_id = lv_line_id - 1 .

    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.

  CHECK lt_gmvt_item IS NOT INITIAL.
*** CALL the bapi fm for gr posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = '01'
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = se.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    xsubcon_hdr_mblnr_101 = ls_gmvt_headret-mat_doc.
    xsubcon_hdr_mjahr_101 = ls_gmvt_headret-doc_year.
BREAK SNAHAK.
    MESSAGE 'Successfully Posted' TYPE ss.
    SELECT SINGLE charg FROM matdoc INTO xsubcon_hdr_charg
      WHERE mblnr = ls_gmvt_headret-mat_doc
      AND mjahr = ls_gmvt_headret-doc_year.
    "Update Condition Record Table
    szcon_rec_t-kschl = 'ZKP0'.
    szcon_rec_t-batch  = xsubcon_hdr_charg.
    szcon_rec_t-werks = xsubcon_hdr-werks.
    szcon_rec_t-vrkme = xsubcon_hdr-meins.
    szcon_rec_t-matnr = xsubcon_hdr-matnr.
    szcon_rec_t-mat_cat = 01.
    szcon_rec_t-kbetr = xsubcon_hdr-sprice.
    szcon_rec_t-konwa = xsubcon_hdr-waers.
    INSERT zcon_rec_t FROM szcon_rec_t. "Insert record for condition upload
    COMMIT WORK AND WAIT.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ssubrc = 4.
    PERFORM reverse_gm USING xsubcon_hdr-mblnr_541 xsubcon_hdr-mjahr_541.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_LABEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- SSUBRC
*&---------------------------------------------------------------------*
FORM print_label  CHANGING ssubrc TYPE sy-subrc.
***  SUBMIT ztp3_lable AND RETURN WITH p_mblnr = xsubcon_hdr-mblnr_101 WITH p_prov = abap_true.
******  FORM
***  SUBMIT zmm_contract_po WITH p_ebeln = sebeln AND RETURN.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDT_ITEMQTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE updt_itemqty INPUT.
  CHECK xsubcon_hdr-menge IS NOT INITIAL AND xsubcon_itm[] IS NOT INITIAL.
  LOOP AT xsubcon_itm.
    xsubcon_itm-req_qty = ( xsubcon_itm-menge * xsubcon_hdr-menge ).
    IF xsubcon_itm-req_qty > xsubcon_itm-clabs.
      xsubcon_itm-icon = sred.
    ELSE.
      xsubcon_itm-icon = sgreen.
    ENDIF.
    MODIFY xsubcon_itm INDEX sy-tabix TRANSPORTING icon req_qty .
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form REVERSE_GM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> XSUBCON_HDR_MBLNR_541
*&      --> XSUBCON_HDR_MJAHR_541
*&---------------------------------------------------------------------*
FORM reverse_gm  USING    xsubcon_hdr_mblnr_541 TYPE mblnr
                          xsubcon_hdr_mjahr_541 TYPE mjahr.

  DATA : lt_return  TYPE TABLE OF bapiret2,
         ls_headert TYPE bapi2017_gm_head_ret.
  REFRESH : lt_return.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument = xsubcon_hdr_mblnr_541
      matdocumentyear  = xsubcon_hdr_mjahr_541
*     GOODSMVT_PSTNG_DATE       =
*     GOODSMVT_PR_UNAME         =
*     DOCUMENTHEADER_TEXT       =
    IMPORTING
      goodsmvt_headret = ls_headert
    TABLES
      return           = lt_return
*     GOODSMVT_MATDOCITEM       =
    .

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.
***  IF lt_return IS INITIAL .

  MESSAGE 'Failed to do GR reveresed 541 doc with' && ls_headert-mat_doc TYPE si DISPLAY LIKE se.
****  ENDIF.
ENDFORM.
