*&---------------------------------------------------------------------*
*& Include          SAPMZGRPO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ALV_GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_grid1 .
CREATE OBJECT container1
    EXPORTING
     container_name = 'CONTAINER1'.

  CREATE OBJECT grid1
    EXPORTING
      i_parent   = container1.

  CALL METHOD grid1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error = 1
      OTHERS = 2.

  CREATE OBJECT g_verifier.
  SET HANDLER g_verifier->toolbar FOR grid1.
  SET HANDLER g_verifier->user_command FOR grid1.

PERFORM exclude_tb_function CHANGING it_exclude.
PERFORM fill_1grid1.
PERFORM fill_1grid2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_1GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_1grid1 .
REFRESH lt_fieldcat1.

 PERFORM fc USING: '01'  'MATNR'     'IT_ITEM1'  'Article No'  'Article No'  'Article No'    '' '' '10'  ''  'MARA' 'MATNR' ''
                   CHANGING lt_fieldcat1,
                   '02'  'MAKTX'     'IT_ITEM1'   'Art.desc'   'Art.desc'    'Art.desc'      '' '' '16'  ''  ''     ''      ''
                   CHANGING lt_fieldcat1,
                   '03'  'CHARG'     'IT_ITEM1'   'Batch'      'Batch'       'Batch'         '' '' '10'  ''  ''     ''      ''
                   CHANGING lt_fieldcat1,
*                   '04'  'MENGE'     'IT_ITEM1'   'Qty'        'Qty'         'Qty'           '' '' '08'  ''  'MSEG' 'MENGE' ''
*                   CHANGING lt_fieldcat1,
                   '05'  'OMENGE'    'IT_ITEM1'   'Open.Qty'   'Open.Qty'    'Open.Qty'      '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat1,
                   '06'  'CMENGE'    'IT_ITEM1'   'Con Qty'    'Con Qty'     'Con Qty'       '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat1,
                   '07'  'MEINS'     'IT_ITEM1'   'UOM'        'UOM'         'UOM'           '' '' '04'  ''  ''     ''      ''
                   CHANGING lt_fieldcat1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_1GRID2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_1grid2 .
 lw_layo1-frontend = 'X'.

  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      is_layout                     = lw_layo1
      it_toolbar_excluding          = it_exclude
    CHANGING
      it_outtab                     = gt_item1
      it_fieldcatalog               = lt_fieldcat1
*      IT_SORT                       = LT_SORT
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4 .

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

CALL METHOD grid1->set_ready_for_input
  EXPORTING
  i_ready_for_input = 1.

  CALL METHOD grid1->set_toolbar_interactive.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- IT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_function   CHANGING lt_exclude TYPE ui_functions.
    DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_filter.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdata.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_help.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_load_variant.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_mb_variant.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_maximum.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_minimum.
  APPEND ls_exclude TO lt_exclude.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      <-- LT_FIELDCAT1
*&---------------------------------------------------------------------*
FORM fc USING fp_colpos    TYPE sycucol
              fp_fldnam    TYPE fieldname
              fp_tabnam    TYPE tabname
              scrtext_s    TYPE scrtext_s
              scrtext_m    TYPE scrtext_m
              scrtext_l    TYPE scrtext_l
              edit         TYPE c
              do_sum       TYPE c
              olen         TYPE char2
              f4h          TYPE ddf4avail
              reftab       TYPE lvc_rtname
              reffld       TYPE lvc_rfname
              drdn_hndl    TYPE int4
         CHANGING lt_fieldcat TYPE  lvc_t_fcat.

  DATA: wa_fcat  TYPE  lvc_s_fcat.
  wa_fcat-row_pos        = '1'.     "ROW
  wa_fcat-col_pos        = fp_colpos.     "COLUMN
  wa_fcat-fieldname      = fp_fldnam.     "FIELD NAME
  wa_fcat-tabname        = fp_tabnam.     "INTERNAL TABLE NAME
  wa_fcat-edit           = edit.
  wa_fcat-outputlen      = olen.
  wa_fcat-do_sum         = do_sum.
  wa_fcat-f4availabl     = f4h.
  wa_fcat-scrtext_s      = scrtext_s.
  wa_fcat-scrtext_m      = scrtext_m.
  wa_fcat-scrtext_l      = scrtext_l.
  wa_fcat-reptext        = scrtext_l.
  wa_fcat-just           = 'L'.
  wa_fcat-ref_table      = reftab.
  wa_fcat-ref_field      = reffld.
  wa_fcat-drdn_hndl      = drdn_hndl.

  IF wa_fcat-fieldname = 'MEINS'.
   wa_fcat-convexit = 'CUNIT'.
  ENDIF.

  APPEND wa_fcat TO lt_fieldcat.
  CLEAR wa_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_GRID2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_grid2 .
 CREATE OBJECT container2
    EXPORTING
     container_name = 'CONTAINER2'.

  CREATE OBJECT grid2
    EXPORTING
      i_parent   = container2.

  CALL METHOD grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error = 1
      OTHERS = 2.

  CREATE OBJECT g_verifier.
  SET HANDLER g_verifier->update FOR grid2.
*  SET HANDLER g_verifier->toolbar1 FOR grid2.
*  SET HANDLER g_verifier->user_command FOR grid2.

PERFORM exclude_tb_function CHANGING it_exclude.
PERFORM fill_2grid1.
PERFORM fill_2grid2.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FILL_2GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_2grid1 .
REFRESH lt_fieldcat2.

 PERFORM fc USING: '01'  'MATNR'     'IT_ITEM2'   'Article No'  'Article No'  'Article No'    '' '' '10'  ''  'MARA' 'MATNR' ''
                   CHANGING lt_fieldcat2,
                   '02'  'MAKTX'     'IT_ITEM2'   'Art.desc'   'Art.desc'    'Art.desc'      '' '' '16'  ''  ''     ''      ''
                   CHANGING lt_fieldcat2,
                   '03'  'MENGE'     'IT_ITEM2'   'Qty'        'Qty'         'Qty'           'X' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat2,
                   '04'  'MEINS'     'IT_ITEM2'   'UOM'        'UOM'         'UOM'           '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat2,
                   '05'  'RMENGE'    'IT_ITEM2'   'Req Qty'    'Req Qty'     'Req Qty'       '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat2,
                   '06'  'SELLP'     'IT_ITEM2'   'Sell Price'  'Sell Price'  'Sell Price'   '' '' '08'  ''  ' ' ' ' ''
                   CHANGING lt_fieldcat2,
                   '07'  'EANNO'     'IT_ITEM2'   'EAN No'  'EAN No'  'EAN No'   '' '' '10'  ''  ' ' ' ' ''
                   CHANGING lt_fieldcat2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_2GRID2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_2grid2 .
 lw_layo2-frontend = 'X'.
*  lw_layo2-zebra = 'X'.
  CALL METHOD grid2->set_table_for_first_display
    EXPORTING
      is_layout                     = lw_layo2
      it_toolbar_excluding          = it_exclude
    CHANGING
      it_outtab                     = gt_item2
      it_fieldcatalog               = lt_fieldcat2
*      IT_SORT                       = LT_SORT
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4 .

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

CALL METHOD grid2->set_ready_for_input
  EXPORTING
  i_ready_for_input = 1.

  CALL METHOD grid2->set_toolbar_interactive.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .

  CALL METHOD grid1->get_selected_rows
    IMPORTING
      et_index_rows = row_ind.

 DESCRIBE TABLE row_ind LINES DATA(lv_lines).

  IF lv_lines = 0.
     MESSAGE 'Select atleast one line item.' TYPE 'E'.
 ELSEIF lv_lines > '1'.
      MESSAGE 'Select one line item at a time only.' TYPE 'E'.
 ENDIF.

  READ TABLE row_ind ASSIGNING FIELD-SYMBOL(<ind>) INDEX 1.
    READ TABLE gt_item1 ASSIGNING FIELD-SYMBOL(<item>) INDEX <ind>-index.
      IF sy-subrc = 0.
        SELECT DISTINCT idnrk stlnr menge meins FROM stpo INTO TABLE gt_stpo1 WHERE idnrk = <item>-matnr.
       IF gt_stpo1 IS NOT INITIAL.
        SELECT a~matnr
               a~stlnr
               b~maktx
               c~meins  INTO CORRESPONDING FIELDS OF TABLE gt_item2 FROM mast AS a INNER JOIN makt AS b ON
                       ( a~matnr = b~matnr AND spras = sy-langu ) INNER JOIN mara AS c ON
                       ( a~matnr = c~matnr ) FOR ALL ENTRIES IN gt_stpo1
                        WHERE a~stlnr = gt_stpo1-stlnr
                        AND   c~attyp IN ( '02' , '00' ).

     SELECT kschl,knumh,matnr FROM a406 INTO TABLE @DATA(it_a406) FOR ALL ENTRIES IN @gt_item2 WHERE
               matnr = @gt_item2-matnr AND werks = 'SSVG' AND kschl = 'ZEAN' AND datbi GE @sy-datum .
     SELECT knumh,kbetr FROM konp INTO TABLE @DATA(it_konp) FOR ALL ENTRIES IN @it_a406 WHERE knumh = @it_a406-knumh.

     SELECT matnr,ean11 FROM mara INTO TABLE @DATA(it_mara) FOR ALL ENTRIES IN @gt_item2 WHERE matnr = @gt_item2-matnr.

      LOOP AT gt_item2 ASSIGNING FIELD-SYMBOL(<skn>).
       IF it_mara IS NOT INITIAL.
        READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY matnr = <skn>-matnr.
          IF sy-subrc = 0.
            <skn>-eanno = <fs>-ean11.
          ENDIF.
        ENDIF.
       IF it_a406 IS NOT INITIAL.
         READ TABLE it_a406 INTO DATA(wa_a406) WITH KEY matnr = <skn>-matnr.
         IF sy-subrc = 0.
        READ TABLE it_konp INTO DATA(wa_konp) WITH KEY knumh = wa_a406-knumh.
          IF sy-subrc = 0.
            <skn>-sellp = wa_konp-kbetr.
          ENDIF.
        ENDIF.
       ENDIF.
     ENDLOOP.


       ELSE.
         MESSAGE 'No values found' TYPE 'E'.
       ENDIF.

      ENDIF.



      APPEND LINES OF gt_item2 TO gt_item3.
      APPEND LINES OF gt_stpo1 TO gt_stpo.
    CALL METHOD grid2->refresh_table_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form POST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM post .

 DATA:lv_ans TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Warning!!'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Please check all data properly before posting!!!'
      text_button_1         = 'Confirm'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'Go Back'
      icon_button_2         = 'ICON_SYSTEM_UNDO'
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_ans
*     TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

CHECK lv_ans = '1'.
CHECK gt_item3 IS NOT INITIAL.
  gv_subrc = 0.
 PERFORM create_po.
IF gv_subrc = 0.
 PERFORM gm_541.
ENDIF.

  IF it_log IS NOT INITIAL.
    PERFORM messages.
  ENDIF.

 IF gs_hdr-ebeln IS NOT INITIAL AND gv_subrc = 0 .
   CLEAR: lv_ans.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Warning!!'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Do you want to see the job card ?'
      text_button_1         = 'YES'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'NO'
      icon_button_2         = 'ICON_SYSTEM_UNDO'
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_ans
*     TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

   IF  lv_ans = '1'.
    SUBMIT zmm_contract_po  WITH p_ebeln = gs_hdr-ebeln AND RETURN.
   ENDIF.
 ENDIF.

CLEAR: gt_item1, gt_item2, gs_hdr-ebeln,gw_mblnr,it_log,gw_budat.
CALL METHOD grid1->refresh_table_display.
CALL METHOD grid2->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_po .
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
    lw_return      TYPE bapiret2,
    bapi_te_po     TYPE bapi_te_mepoheader,
    bapi_te_pox    TYPE bapi_te_mepoheaderx,
    lv_item        TYPE ebelp,
    lv_schd_line   TYPE etenr.

  DELETE gt_item3 WHERE menge IS INITIAL.

      header-comp_code    = '1000'.
      header-creat_date   = sy-datum.
      header-vendor       = 'INTERNAL'. "    '0000200012'.
      header-doc_type     = 'ZPRO'.
      header-langu        = sy-langu.
      header-purch_org    = '1000'.
      header-pur_group    = 'P11'.
*      header-pmnttrms     = '0001'.
      header-item_intvl   = '00010'.
      header-exch_rate    = 1.
      header-currency     = header-currency_iso  = 'INR'.
      header-our_ref      = gw_mblnr.

      headerx-comp_code   = 'X' .
      headerx-creat_date  = 'X' .
      headerx-vendor      = 'X' .
      headerx-doc_type    = 'X' .
      headerx-langu       = 'X' .
      headerx-purch_org   = 'X' .
      headerx-pur_group   = 'X' .
*      headerx-pmnttrms    = 'X' .
      headerx-item_intvl  = 'X' .
      headerx-exch_rate   = 1.
      headerx-currency    = headerx-currency_iso  = 'INR'.
      headerx-our_ref      = 'X'.

      REFRESH : item, itemx.
      lv_item = 10.
      lv_schd_line = 1.
      LOOP AT gt_item3 ASSIGNING FIELD-SYMBOL(<ls_item>).
        item-po_item         = lv_item.
        item-item_cat        = 'L'.
        item-material        = item-ematerial = item-material_long  = item-ematerial_long = <ls_item>-matnr.
        item-plant           = 'SSVG'.
        item-quantity        = <ls_item>-menge.
        item-po_unit         = item-po_unit_iso = item-orderpr_un = item-orderpr_un_iso = <ls_item>-meins.
        item-stge_loc        = 'FG01'.
        item-gr_pr_time      = 0.
        item-weightunit      =  'KG'.
        item-weightunit_iso  =  'KGM'.
        item-producttype     = 1.
        item-prnt_price      = 'X'.
        item-info_upd        = 'C'.
        item-free_item       = 'X'.
        item-price_unit      = 1.
        item-conv_num1       = item-conv_den1  = 1.
        item-price_date      = sy-datum.

        itemx-po_item        = lv_item.
        itemx-item_cat       = 'X'.
        itemx-material       = itemx-ematerial  = itemx-material_long  = itemx-ematerial_long = 'X'.
        itemx-plant          = 'X'.
        itemx-quantity       = 'X'.
        itemx-po_unit        = itemx-po_unit_iso = itemx-orderpr_un = itemx-orderpr_un_iso = 'X'.
        itemx-stge_loc       = 'X'.
        itemx-gr_pr_time     = 'X'.
        itemx-weightunit     = 'X'.
        itemx-weightunit_iso = 'X'.
        itemx-producttype    = 'X'.
        itemx-period_ind_expiration_date  = 'X'.
        itemx-prnt_price     = 'X'.
        itemx-info_upd       = 'X'.
        itemx-free_item      = 'X'.
        itemx-price_unit     = 'X'.
        itemx-conv_num1      = 'X'.
        itemx-price_date     = 'X'.

*** Schedule Line Items
        poschedule-po_item       = lv_item.
        poschedule-sched_line    = lv_schd_line.
        poschedule-delivery_date = sy-datum.
        poschedule-quantity      = <ls_item>-menge.

*** Schedule Line Items Update Flag
        poschedulex-po_item       = lv_item.
        poschedulex-sched_line    = lv_schd_line.
        poschedulex-po_itemx      = 'X'.
        poschedulex-sched_linex   = 'X'.
        poschedulex-delivery_date = 'X'.
        poschedulex-quantity      = 'X'.

***   PO Components
       READ TABLE gt_stpo ASSIGNING FIELD-SYMBOL(<st>) WITH KEY stlnr = <ls_item>-stlnr .
       IF sy-subrc = 0 .
          pocomponents-po_item        = lv_item.
          pocomponents-sched_line     = pocomponents-item_no = lv_schd_line.
          pocomponents-material       = <st>-idnrk.
          pocomponents-entry_quantity = <ls_item>-rmenge .
          pocomponents-entry_uom      =  <st>-meins. "'EA'.                     "<ls_item>-meins.
          pocomponents-entry_uom_iso  =  <st>-meins. "'EA'.
          pocomponents-plant          = 'SSVG'.
          pocomponents-req_date       = sy-datum.
          pocomponents-item_cat       = 'L'.
          pocomponents-req_quan       = <ls_item>-rmenge.
          pocomponents-base_uom       = <st>-meins."'EA'.
          pocomponents-base_uom_iso   = <st>-meins."'EA'.
          pocomponents-change_id      = 'I'.

***   PO Components Update Flag
          pocomponentsx-po_item        = lv_item.
          pocomponentsx-sched_line     = pocomponentsx-item_no = lv_schd_line.
          pocomponentsx-po_itemx       = 'X'.
          pocomponentsx-sched_linex    = pocomponentsx-item_nox = 'X'.
          pocomponentsx-material       = 'X'.
          pocomponentsx-entry_quantity = 'X'.
          pocomponentsx-entry_uom      = 'X'.
          pocomponentsx-entry_uom_iso  = 'X'.
          pocomponentsx-plant          = 'X'.
          pocomponentsx-req_date       = 'X'.
          pocomponentsx-item_cat       = 'X'.
          pocomponentsx-req_quan       = 'X'.
          pocomponentsx-base_uom       = 'X'.
          pocomponentsx-base_uom_iso   = 'X'.
          pocomponentsx-change_id      = 'X'.
 ENDIF.
        APPEND : item, itemx, pocomponents , pocomponentsx, poschedule, poschedulex .
        CLEAR : itemx , item, pocomponents , pocomponentsx, poschedule, poschedulex.
        lv_item = lv_item + 10.
        lv_schd_line = lv_schd_line + 1.
      ENDLOOP.
*** Return PO Creation

      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          poheader         = header
          poheaderx        = headerx
        IMPORTING
          exppurchaseorder = gs_hdr-ebeln
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
         READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_ret1>) WITH KEY type = 'S'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
                    APPEND VALUE #( type  = <ls_ret1>-type
                            id    = <ls_ret1>-id
                            txtnr = <ls_ret1>-number
                            msgv1 = gs_hdr-ebeln ) TO it_log.
      ELSE.
        gv_subrc = 4.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          LOOP AT return INTO lw_return WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return-type
                            id    = lw_return-id
                            txtnr = lw_return-number
                            msgv1 = lw_return-message_v1
                            msgv2 = lw_return-message_v2 ) TO it_log.

          ENDLOOP.
      ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GM_541
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM gm_541 .

  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lw_return1      TYPE  bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    ls_status       TYPE zinw_t_status.
  DATA : lv_open_qty TYPE menge_d.
  DATA : lv_act_qty TYPE menge_d.

  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.


  CLEAR: gs_hdr-mblnr_541.
  REFRESH :lt_gmvt_item , lt_bapiret.
*  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @gs_hdr-ebeln.
**** FILL THE BAPI HEADER STRUCTURE DETAILS
*      ls_gmvt_header-pstng_date       = sy-datum.
*      ls_gmvt_header-doc_date         = sy-datum.
*      ls_gmvt_header-pr_uname         = sy-uname.
*      ls_gmvt_header-ver_gr_gi_slip   = 1.
*      ls_gmvt_header-ref_doc_no       = gs_hdr-ebeln.
*
*
**** Looping the PO details.
*   LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_po>).
*      LOOP AT gt_item1 ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE cmenge IS NOT INITIAL.
**** FILL THE BAPI ITEM STRUCTURE DETAILS
*          ls_gmvt_item-move_mat  = ls_gmvt_item-material  = ls_gmvt_item-material_long = ls_gmvt_item-move_mat_long = <ls_item>-matnr.
*          ls_gmvt_item-move_type = '541'.
*          ls_gmvt_item-po_number = <ls_po>-ebeln.
*          ls_gmvt_item-po_item   = <ls_po>-ebelp.
*          ls_gmvt_item-prod_date = sy-datum.
*          ls_gmvt_item-vendor    = '0000200012'.
*          ls_gmvt_item-plant     = ls_gmvt_item-move_plant = 'SSVG'.
*          ls_gmvt_item-stge_loc  = 'FG01'.
*          ls_gmvt_item-entry_uom = <ls_item>-meins.
*          ls_gmvt_item-entry_uom_iso = 'KGM'.
*          ls_gmvt_item-batch     = ls_gmvt_item-val_type = ls_gmvt_item-move_batch = ls_gmvt_item-move_val_type = <ls_item>-charg.
**          ls_gmvt_item-entry_qnt = <ls_item>-cmenge.
*          ls_gmvt_item-entry_qnt = <ls_po>-menge.
*          ls_gmvt_item-item_text = gw_mblnr.
*            APPEND ls_gmvt_item TO lt_gmvt_item.
*            CLEAR ls_gmvt_item.
*        ENDLOOP.
*      ENDLOOP.
**** Call the BAPI FM for GR posting
*      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*        EXPORTING
*          goodsmvt_header  = ls_gmvt_header
*          goodsmvt_code    = c_mvt_06
*        IMPORTING
*          goodsmvt_headret = ls_gmvt_headret
*        TABLES
*          goodsmvt_item    = lt_gmvt_item
*          return           = lt_bapiret.
*******************************************************************************************
  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @gs_hdr-ebeln.
  IF sy-subrc = 0.
    SELECT DISTINCT mchb~matnr, mchb~charg, mchb~clabs, mast~matnr AS po_matnr ,stpo~meins, stpo~menge INTO TABLE @DATA(lt_mchb)
           FROM mchb AS mchb INNER JOIN stpo AS stpo ON stpo~idnrk = mchb~matnr
           INNER JOIN mast AS mast ON mast~stlnr = stpo~stlnr
           INNER JOIN mseg AS mseg ON mseg~matnr = mchb~matnr AND mseg~charg = mchb~charg
           FOR ALL ENTRIES IN @lt_ekpo
           WHERE mast~matnr = @lt_ekpo-matnr AND mchb~clabs > 0 AND mseg~werks = 'SSVG' AND mseg~mblnr = @gw_mblnr.
    IF sy-subrc = 0.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
      ls_gmvt_header-pstng_date       = gw_budat. "sy-datum.
      ls_gmvt_header-doc_date         = sy-datum.
      ls_gmvt_header-pr_uname         = sy-uname.
      ls_gmvt_header-ver_gr_gi_slip   = 1.

*** Looping the PO details.
      LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_item>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS
        LOOP AT lt_mchb ASSIGNING FIELD-SYMBOL(<ls_mchb>) WHERE po_matnr = <ls_item>-matnr.
          ls_gmvt_item-move_mat  = ls_gmvt_item-material  = ls_gmvt_item-material_long = ls_gmvt_item-move_mat_long = <ls_mchb>-matnr.
          ls_gmvt_item-move_type = '541'.
          ls_gmvt_item-po_number = <ls_item>-ebeln.
          ls_gmvt_item-po_item   = <ls_item>-ebelp.
          ls_gmvt_item-prod_date = sy-datum.
          ls_gmvt_item-vendor    =  'INTERNAL' . " '0000200012'.
          ls_gmvt_item-plant     = ls_gmvt_item-move_plant = 'SSVG'.
          ls_gmvt_item-stge_loc  = 'FG01'.
          ls_gmvt_item-entry_uom = <ls_mchb>-meins.
          ls_gmvt_item-entry_uom_iso = 'KGM'.
          ls_gmvt_item-batch     = ls_gmvt_item-val_type = ls_gmvt_item-move_batch = ls_gmvt_item-move_val_type = <ls_mchb>-charg.

***   Quantity Converstion
          lv_act_qty = ( <ls_item>-menge - lv_open_qty ) * <ls_mchb>-menge.
          IF <ls_mchb>-clabs GE lv_act_qty.
            ls_gmvt_item-entry_qnt = lv_act_qty.
            ls_gmvt_item-item_text = gw_mblnr.
            APPEND ls_gmvt_item TO lt_gmvt_item.
            CLEAR ls_gmvt_item.
            EXIT.
          ELSE.
            ls_gmvt_item-entry_qnt = <ls_mchb>-clabs.
            lv_open_qty = lv_open_qty + ls_gmvt_item-entry_qnt .
            APPEND ls_gmvt_item TO lt_gmvt_item.
            CLEAR ls_gmvt_item.
          ENDIF.
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

************************************************************************************************
      READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
      IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        gs_hdr-mblnr_541 = ls_gmvt_headret-mat_doc.

                APPEND VALUE #( type  = 'S'
                        id    = 'MIGO'
                        txtnr = '012'
                        msgv1 = gs_hdr-mblnr_541 ) TO it_log.
      ELSE.
        REFRESH it_log.
        PERFORM delete_po.

*** Roll Back if any error.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        gv_subrc = 4.
        LOOP AT lt_bapiret INTO lw_return1 WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return1-type
                            id    = lw_return1-id
                            txtnr = lw_return1-number
                            msgv1 = lw_return1-message_v1
                            msgv2 = lw_return1-message_v2 ) TO it_log.

        ENDLOOP.
      ENDIF.
*************
  ENDIF.
 ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM messages .
CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.


    LOOP AT it_log ASSIGNING FIELD-SYMBOL(<log>).
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb = <log>-id
*         EXCEPTION_IF_NOT_ACTIVE       = 'X'
          msgty = <log>-type
          msgv1 = <log>-msgv1
          msgv2 = <log>-msgv2
          txtnr = <log>-txtnr
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDLOOP.
    CALL FUNCTION 'MESSAGES_STOP'
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'MESSAGES_SHOW'
      EXCEPTIONS
        inconsistent_range = 1
        no_messages        = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_form .
  CALL SCREEN 9000 STARTING AT 5 5 ENDING AT 50 10.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HIDE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hide .

  LOOP AT SCREEN.
    IF screen-name =  'GW_MBLNR' OR screen-name = 'GW_BUDAT'.
      screen-input  = '0' .
      screen-active = '1'.
      MODIFY SCREEN .
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_po .


  DATA: wa_purchaseorder TYPE bapimepoheader-po_number,
        it_poitem        TYPE STANDARD TABLE OF bapimepoitem,
        wa_poitem        TYPE bapimepoitem,
        it_poitemx       TYPE STANDARD TABLE OF bapimepoitemx,
        wa_poitemx       TYPE bapimepoitemx,
        it_return        TYPE TABLE OF bapiret2.

CLEAR:it_return,
      it_poitem,
      it_poitemx,
      wa_purchaseorder,
      wa_poitem,
      wa_poitemx.

  IF gs_hdr-ebeln IS NOT INITIAL.

    wa_purchaseorder = gs_hdr-ebeln.

    SELECT ebeln,ebelp FROM ekpo INTO TABLE @DATA(it_po) WHERE ebeln = @gs_hdr-ebeln.

    LOOP AT it_po ASSIGNING FIELD-SYMBOL(<po>).

      wa_poitem-po_item     = <po>-ebelp.
      wa_poitem-delete_ind  = 'X'.

      wa_poitemx-po_item     = <po>-ebelp.
      wa_poitemx-po_itemx    = 'X'.
      wa_poitemx-delete_ind  = 'X'.

      APPEND wa_poitem TO it_poitem.
      APPEND wa_poitemx TO it_poitemx.

      CLEAR: wa_poitem,wa_poitemx.

    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = wa_purchaseorder
      TABLES
        return        = it_return
        poitem        = it_poitem
        poitemx       = it_poitemx.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.


ENDFORM.
