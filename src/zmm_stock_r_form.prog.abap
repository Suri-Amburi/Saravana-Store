*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_R_FORM
*&---------------------------------------------------------------------*


***SELECT * FROM edid4 AS edid4
***  INNER JOIN edidc AS edidc ON edid4~docnum = edidc~docnum
***  WHERE edidc~status <> '53' AND edid4~segnam = 'E1WPU02' INTO TABLE @DATA(it_edid4).


DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
it_named_seltabs = VALUE #( ( name = 'CREDAT' dref = REF #( s_date[] ) )
                           )

                           iv_client_field = 'MANDT'
                            ) .

zcl_stock=>get_output_prd(
EXPORTING
lv_select     = lv_select
IMPORTING
et_final_data = it_edid4
).

LOOP AT it_edid4  INTO wa_edid4.

*  wa_final-docnum = wa_edid4-edid4-docnum.
**  wa_final-docnum = wa_edid4-edid4-docnum.
**  wa_final-matnr  = wa_edid4-edid4-sdata+121(40).
**  wa_final-charg  = wa_edid4-edid4-sdata+29(15).
**  wa_final-qty    = wa_edid4-edid4-sdata+45(35).
**  wa_final-uom    = wa_edid4-edid4-sdata+116(5).
**  wa_final-werks1 = wa_edid4-edidc-rcvprn.

  wa_final-docnum = wa_edid4-docnum.
  wa_final-matnr  = wa_edid4-sdata+121(40).
  wa_final-charg  = wa_edid4-sdata+29(15).
  wa_final-qty    = wa_edid4-sdata+45(35).
  wa_final-uom    = wa_edid4-sdata+116(5).
  wa_final-werks1 = wa_edid4-rcvprn.

  APPEND wa_final TO it_final.
  CLEAR wa_final.

ENDLOOP.

DATA(it_final1) = it_final.
SORT it_final1 BY matnr charg werks1.
DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING matnr charg werks1.
DATA v_index TYPE sy-tabix.
LOOP AT it_final1 INTO DATA(wa_final1).

**  READ TABLE it_final INTO DATA(wa_final2) WITH KEY matnr = wa_final1-matnr charg = wa_final1-charg  werks1 = wa_final1-werks1 BINARY SEARCH.
**  IF sy-subrc = 0.
**    v_index = sy-tabix.

  LOOP AT it_final INTO DATA(wa_final2) WHERE matnr = wa_final1-matnr AND charg = wa_final1-charg AND werks1 = wa_final1-werks1. "from v_index."
**
**      IF wa_final2-matnr <> wa_final1-matnr AND wa_final2-charg <> wa_final1-charg AND wa_final2-werks1 <> wa_final1-werks1.
**        EXIT.
**      ENDIF.

    wa_final3-qty    = wa_final3-qty + wa_final2-qty.
    wa_final3-docnum = wa_final2-docnum.
    wa_final3-matnr  = wa_final2-matnr .
    wa_final3-charg  = wa_final2-charg .
    wa_final3-uom    = wa_final2-uom.
    wa_final3-werks1 = wa_final2-werks1.
  ENDLOOP.
**  ENDIF.

  APPEND wa_final3 TO it_final3.
  CLEAR :wa_final3." , wa_final2, wa_final1.

ENDLOOP.

**SELECT matnr, werks, lgort, charg, clabs FROM mchb INTO TABLE @DATA(it_mchb)
**  FOR ALL ENTRIES IN @it_final3
**  WHERE matnr = @it_final3-matnr AND werks = @it_final3-werks1 AND charg = @it_final3-charg.
**DATA: lv_matnr1 TYPE mchb-matnr,
**      lv_werks TYPE mchb-werks,
**      lv_charg TYPE mchb-charg,
**      lv_clabs TYPE mchb-clabs.
**SELECT
**  matnr,
**  werks,
**  lgort,
**  charg,
**  clabs
**  FROM mchb INTO TABLE @DATA(it_mchb)
**  FOR ALL ENTRIES IN @it_final3
**  WHERE matnr = @it_final3-matnr AND werks = @it_final3-werks1 AND charg = @it_final3-charg.
**
**SELECT
**  matnr,
**  werks,
**  lgort,
**  labst
**  FROM mard INTO TABLE @DATA(it_mard)
**  FOR ALL ENTRIES IN @it_final3
**WHERE matnr = @it_final3-matnr AND werks = @it_final3-werks1 .

LOOP AT it_final3 INTO wa_final3.

  wa_final4-qty    = wa_final3-qty.
  wa_final4-docnum = wa_final3-docnum.
  wa_final4-matnr  = wa_final3-matnr .
  wa_final4-charg  = wa_final3-charg .
  wa_final4-uom    = wa_final3-uom.
  wa_final4-werks1 = wa_final3-werks1.

*******  READ TABLE it_mchb INTO DATA(wa_mchb) WITH KEY matnr = wa_final3-matnr  werks = wa_final3-werks1  charg = wa_final3-charg.
*******  IF sy-subrc = 0.
*******    wa_final4-qty1 = wa_mchb-clabs.
*******  ELSE.
*******    READ TABLE it_mard INTO DATA(wa_mard) WITH KEY matnr = wa_final3-matnr werks = wa_final3-werks1 .
*******    IF sy-subrc = 0.
*******      wa_final4-qty1 = wa_mard-labst.
*******    ENDIF.
*******  ENDIF.

  CLEAR: lv_matnr, lv_werks, lv_lgort, lv_charg,lv_clabs.

  SELECT SINGLE matnr werks lgort charg clabs FROM mchb INTO (lv_matnr, lv_werks, lv_lgort, lv_charg,lv_clabs)
  WHERE matnr = wa_final3-matnr AND werks = wa_final3-werks1 AND charg = wa_final3-charg.

  IF lv_matnr IS INITIAL.
    SELECT SINGLE matnr werks lgort labst FROM mard INTO (lv_matnr, lv_werks,lv_lgort,lv_clabs)
    WHERE matnr = wa_final3-matnr AND werks = wa_final3-werks1 .
  ENDIF.


  wa_final4-qty1 = lv_clabs.


***  READ TABLE it_mchb INTO DATA(wa_mchb) WITH KEY matnr = wa_final3-matnr werks = wa_final3-werks1 charg = wa_final3-charg.
***  IF sy-subrc = 0.
***    wa_final4-qty1 = wa_mchb-clabs.
***  ENDIF.

  IF wa_final4-qty GT wa_final4-qty1.

    wa_final4-remarks = 'Move Stock to System'.

  ENDIF.

*  IF wa_final4-remarks IS NOT INITIAL.
  APPEND wa_final4 TO it_final4.
*  ENDIF.
  CLEAR wa_final4.

ENDLOOP.





*SELECT * FROM edid4
*  FOR ALL ENTRIES IN @it_doc
*  WHERE  docnum = @it_doc-docnum AND segnam = 'E1WPU02'
*  INTO TABLE @DATA(it_edid4).



*****LOOP AT it_doc INTO DATA(wa_doc).
*****
******  READ TABLE it_edid4 INTO DATA(wa_edid4) WITH KEY docnum = wa_doc-docnum.
******  IF sy-subrc = 0.
*****
*******    DATA(lv_matnr1) = wa_edid4-sdata+121(40).
*******    DATA(lv_batch1) = wa_edid4-sdata+29(15).
*******    DATA(qty1)      = wa_edid4-sdata+45(35).
*******    DATA(uom1)      = wa_edid4-sdata+116(5).
*****
*******1.QUALARTNR  4           0+(4)
*******2.artnr      25          4+(25)
*******3.AKTIONSNR batch 15     29+(15)
*******4.  1                    44+(1)
*******5.quantity 35            45+(35)
*******6.1                      80+(1)
*******7. uom 35                81+(35)
*******8.5                      116+(5)
*******9.material long 40       121+(40)
******    wa_final-docnum = wa_edid4-docnum.
******    wa_final-matnr = wa_edid4-sdata+121(40).
******    wa_final-charg = wa_edid4-sdata+29(15).
******    wa_final-qty   = wa_edid4-sdata+45(35).
******    wa_final-uom   = wa_edid4-sdata+116(5).
******
******  ENDIF.
*****
*******  SELECT SINGLE matnr werks lgort charg clabs FROM mchb INTO ( lv_mat_mchb, lv_werks_mchb, lv_lgort_mchb, lv_charg_mchb, lv_qty_mchb )
*******    WHERE matnr = lv_matnr1 AND charg = lv_batch1.
*****
*****  SELECT SINGLE matnr werks lgort charg clabs FROM mchb INTO ( wa_final-matnr1, wa_final-werks1, wa_final-lgort1, wa_final-charg1, wa_final-qty1 )
*****  WHERE matnr = wa_final-matnr AND charg =  wa_final-charg.
*****
*****  APPEND wa_final TO it_final.
*****  CLEAR wa_final.
*****
*****ENDLOOP.

****DELETE it_final WHERE docnum IS INITIAL.

**wa_fcat-col_pos   =  1.
**wa_fcat-fieldname = 'DOCNUM'.
**wa_fcat-tabname   = 'IT_FINAL4'.
**wa_fcat-seltext_l = 'IDOC No'.
**wa_fcat-outputlen =  10.
**APPEND wa_fcat TO it_fcat.
**CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'MATNR'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'Material'.
wa_fcat-outputlen =  20.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'WERKS1'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'Plant'.
wa_fcat-outputlen =  10.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'CHARG'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'Batch'.
wa_fcat-outputlen =  10.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'QTY'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'Quantity'.
wa_fcat-outputlen =  10.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'UOM'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'UOM'.
wa_fcat-outputlen =  10.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'QTY1'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'Available Qty'.
wa_fcat-outputlen =  10.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

wa_fcat-col_pos   =  1.
wa_fcat-fieldname = 'REMARKS'.
wa_fcat-tabname   = 'IT_FINAL4'.
wa_fcat-seltext_l = 'Remarks'.
wa_fcat-outputlen =  10.
APPEND wa_fcat TO it_fcat.
CLEAR wa_fcat.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
*   I_INTERFACE_CHECK       = ' '
*   I_BYPASSING_BUFFER      = ' '
*   I_BUFFER_ACTIVE         = ' '
*   IT_EVENTS               = T_EVENTS
    i_callback_program      = sy-repid
    i_callback_user_command = 'USER_COMMAND'
    i_callback_top_of_page  = 'TOP-OF-PAGE '
    is_layout               = wa_layout
    it_fieldcat             = it_fcat[]
*   I_DEFAULT               = 'X'
    i_save                  = 'X'
  TABLES
    t_outtab                = it_final4
  EXCEPTIONS
    program_error           = 1
    OTHERS                  = 2.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

FORM top-of-page.

*  *ALV Header declarations
  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        lv_name1      TYPE name1,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        lv_top(255)   TYPE c.

  wa_header-typ  = 'H'.
  wa_header-info = 'Super Saravana Stores(IDOC Error Report) '.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Date: '.

  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.

ENDFORM.

FORM user_command USING  sy-ucomm rs_selfield TYPE slis_selfield.
  CASE sy-ucomm.
    WHEN '&IC1'.
      READ TABLE it_final4 ASSIGNING FIELD-SYMBOL(<ls_final4>) INDEX rs_selfield-tabindex.
      IF sy-subrc = 0.

        PERFORM get_idoc USING <ls_final4>-matnr <ls_final4>-werks1 <ls_final4>-charg rs_selfield-tabindex.
        CALL SCREEN '9000' .
      ENDIF.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IDOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FINAL4>_MATNR
*&      --> <LS_FINAL4>_WERKS1
*&      --> <LS_FINAL4>_CHARG
*&      --> RS_SELFIELD_TABINDEX
*&---------------------------------------------------------------------*
FORM get_idoc  USING   i_matnr i_werks1 i_charg i_tabix.
  BREAK ppadhy.
  LOOP AT it_final INTO DATA(w_final) WHERE matnr = i_matnr
    AND werks1 = i_werks1 AND charg = i_charg. .

    w_final5-docnum = w_final-docnum.
    w_final5-matnr  = w_final-matnr.
    w_final5-charg  = w_final-charg.
    w_final5-werks1 = w_final-werks1.
    w_final5-qty    = w_final-qty.
    w_final5-uom    = w_final-uom.

    APPEND w_final5 TO it_final5.
    CLEAR w_final5.

  ENDLOOP.

  IF container IS INITIAL.
    PERFORM setup_alv.
  ENDIF.

  PERFORM fill_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SETUP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setup_alv .

  IF container IS NOT BOUND.
    CREATE OBJECT container
      EXPORTING
        container_name = 'CONTAINER'.

    CREATE OBJECT grid
      EXPORTING
        i_parent = container.

    CALL METHOD grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.

  ENDIF.

ENDFORM.

FORM fill_grid .

  REFRESH lt_fieldcat.
  DATA: wa_fc  TYPE  lvc_s_fcat.
*  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .

  lw_layo-zebra = abap_true .
  lw_layo-cwidth_opt = abap_true .

  wa_fc-col_pos   = '1'.
  wa_fc-fieldname = 'DOCNUM'.
  wa_fc-tabname   = 'IT_FINAL5'.
  wa_fc-scrtext_l = 'IDoc Number'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '2'.
  wa_fc-fieldname = 'MATNR'.
  wa_fc-tabname   = '1T_FINAL5'.
  wa_fc-scrtext_l = 'Material'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '3'.
  wa_fc-fieldname = 'CHARG'.
  wa_fc-tabname   = '1T_FINAL5'.
  wa_fc-scrtext_l = 'Batch'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '4'.
  wa_fc-fieldname = 'WERKS1'.
  wa_fc-tabname   = '1T_FINAL5'.
  wa_fc-scrtext_l = 'Plant'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '4'.
  wa_fc-fieldname = 'QTY'.
  wa_fc-tabname   = '1T_FINAL5'.
  wa_fc-scrtext_l = 'Quantity'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '4'.
  wa_fc-fieldname = 'UOM'.
  wa_fc-tabname   = '1T_FINAL5'.
  wa_fc-scrtext_l = 'Unit of Measure'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

**DATA: GR_EVENT TYPE REF TO EVENT_CLASS.
***** Create Object for event_receiver.
**  IF GR_EVENT IS NOT BOUND.
**    CREATE OBJECT GR_EVENT.
**  ENDIF.


  IF grid IS BOUND.

    IF lt_exclude IS INITIAL.
      PERFORM exclude_tb_functions CHANGING lt_exclude.
    ENDIF.



    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding          = lt_exclude
        is_layout                     = lw_layo
      CHANGING
        it_outtab                     = it_final5[]
        it_fieldcatalog               = lt_fieldcat
*       IT_SORT                       = IT_SORT[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
    ENDIF.

    CALL METHOD grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

    CALL METHOD grid->set_toolbar_interactive.
  ENDIF.

ENDFORM.

FORM exclude_tb_functions  CHANGING lt_exclude TYPE ui_functions.

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
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ZSTATUS'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  DATA:  ok_code      TYPE sy-ucomm.
  ok_code = sy-ucomm.
  BREAK ppadhy.
  CASE ok_code.
    WHEN 'BACK'.
      REFRESH it_final5.
      LEAVE TO SCREEN 0.

    WHEN 'CANCEL'.
      REFRESH it_final5.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      REFRESH it_final5.
      LEAVE TO SCREEN 0.


    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
