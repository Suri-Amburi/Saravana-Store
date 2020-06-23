*&---------------------------------------------------------------------*
*& Include          SAPMZGR_101_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SETUP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setup_alv .

  CREATE OBJECT container
    EXPORTING
      container_name = 'CONTAINER1'.

  CREATE OBJECT grid
    EXPORTING
      i_parent = container.

  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  PERFORM exclude_tb_function CHANGING it_exclude.

  lw_layo-frontend = 'X'.
  lw_layo-zebra    = 'X'.
  REFRESH lt_fieldcat.
  DATA: wa_fc  TYPE  lvc_s_fcat.

  wa_fc-col_pos    = 1.
  wa_fc-fieldname  = 'SL'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_s  = 'Serial No'.
  wa_fc-outputlen  = '05'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos    = 2.
  wa_fc-fieldname  = 'CC'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_l  = 'Category Code'.
  wa_fc-outputlen  = '15'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos    = 3.
  wa_fc-fieldname  = 'MATNR'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_s  = 'Material'.
  wa_fc-outputlen  = '15'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos    = 4.
  wa_fc-fieldname  = 'MAKTX'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_l  = 'Description'.
  wa_fc-outputlen  = '25'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos    = 5.
  wa_fc-fieldname  = 'EAN'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_s  = 'EAN'.
  wa_fc-outputlen  = '18'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos    = 6.
  wa_fc-fieldname  = 'QTY'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_s  = 'Quantity'.
  wa_fc-outputlen  = '10'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos    = 7.
  wa_fc-fieldname  = 'UOM'.
  wa_fc-tabname    = 'IT_ITEM'.
  wa_fc-scrtext_s  = 'UOM'.
  wa_fc-outputlen  = '8'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = lw_layo
      it_toolbar_excluding          = it_exclude
    CHANGING
      it_outtab                     = it_item
      it_fieldcatalog               = lt_fieldcat
*     IT_SORT                       = LT_SORT
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

ENDFORM.

FORM exclude_tb_function CHANGING lt_exclude TYPE ui_functions.

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

FORM save.

  IF gv_bwart EQ c_101 OR gv_bwart EQ c_109 .

    ls_goodsmvt_header-pstng_date = '20200229'.  "sy-datum.
    ls_goodsmvt_header-doc_date   = sy-datum.
    ls_goodsmvt_header-header_txt = lv_gr.
    ls_goodsmvt_code-gm_code      = '04'.

    LOOP AT it_item INTO wa_item.

      lw_goodsmvt_item-material_long = lw_goodsmvt_item-move_mat_long = wa_item-matnr.    "+22(18).
      lw_goodsmvt_item-plant         = lv_from.
      lw_goodsmvt_item-move_type     = c_303.
      lw_goodsmvt_item-entry_qnt     = wa_item-qty.
      lw_goodsmvt_item-move_plant    = lv_to.
      lw_goodsmvt_item-stge_loc      = wa_item-lgort.
      lw_goodsmvt_item-batch         = lw_goodsmvt_item-move_batch = wa_item-charg.


      APPEND lw_goodsmvt_item TO li_goodsmvt_item.
      CLEAR: lw_goodsmvt_item.

    ENDLOOP.

    IF li_goodsmvt_item IS NOT INITIAL.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_goodsmvt_header
          goodsmvt_code    = ls_goodsmvt_code
        IMPORTING
          materialdocument = gv_matdoc303
        TABLES
          goodsmvt_item    = li_goodsmvt_item
          return           = li_return.
    ENDIF.

    IF gv_matdoc303 IS NOT INITIAL.
      lv_matdoc = gv_matdoc303.
      WAIT UP TO 1 SECONDS.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      CONCATENATE 'Material Document Created ' gv_matdoc303 INTO lv_msg SEPARATED BY space.
      MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'S'.
      REFRESH: it_item.

    ELSE.
      READ TABLE li_return INTO lw_return WITH KEY type ='E'.

      IF  sy-subrc = 0.

*      MESSAGE lw_return-message TYPE 'E' DISPLAY LIKE 'I'.
        CALL FUNCTION 'MESSAGES_INITIALIZE'
          EXCEPTIONS
            log_not_active       = 1
            wrong_identification = 2
            OTHERS               = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        LOOP AT li_return INTO lw_return WHERE type = 'E'.

          CALL FUNCTION 'MESSAGE_STORE'
            EXPORTING
              arbgb                  = lw_return-id
*             EXCEPTION_IF_NOT_ACTIVE       = 'X'
              msgty                  = lw_return-type
              msgv1                  = lw_return-message_v1
              msgv2                  = lw_return-message_v2
              msgv3                  = lw_return-message_v3
              msgv4                  = lw_return-message_v4
              txtnr                  = lw_return-number
*             ZEILE                  = ' '
*           IMPORTING
*             ACT_SEVERITY           =
*             MAX_SEVERITY           =
            EXCEPTIONS
              message_type_not_valid = 1
              not_active             = 2
              OTHERS                 = 3.
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
      ENDIF.
    ENDIF.

  ELSEIF gv_bwart = c_303.

    ls_goodsmvt_header-pstng_date =  '20200229'. "sy-datum.
    ls_goodsmvt_header-doc_date   = sy-datum.
    ls_goodsmvt_header-header_txt = lv_gr.
    ls_goodsmvt_code-gm_code      = '04'.

    LOOP AT it_item INTO wa_item.

      lw_goodsmvt_item-material_long = lw_goodsmvt_item-move_mat_long = wa_item-matnr.
      lw_goodsmvt_item-plant         = lv_to.
      lw_goodsmvt_item-move_type     = c_305.
      lw_goodsmvt_item-entry_qnt     = wa_item-qty.
*      lw_goodsmvt_item-move_plant    = lv_to.
      lw_goodsmvt_item-stge_loc      = wa_item-lgort.
      lw_goodsmvt_item-batch         = lw_goodsmvt_item-move_batch = wa_item-charg.

      APPEND lw_goodsmvt_item TO li_goodsmvt_item.
      CLEAR: lw_goodsmvt_item.

    ENDLOOP.

    IF li_goodsmvt_item IS NOT INITIAL.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_goodsmvt_header
          goodsmvt_code    = ls_goodsmvt_code
        IMPORTING
          materialdocument = gv_matdoc305
        TABLES
          goodsmvt_item    = li_goodsmvt_item
          return           = li_return.
    ENDIF.

    IF gv_matdoc305 IS NOT INITIAL.
      lv_matdoc = gv_matdoc305.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
**
**      CONCATENATE 'Material Document Created ' gv_matdoc305 INTO lv_msg SEPARATED BY space.
**      MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'S'.
      REFRESH: it_item.

    ELSE.
      READ TABLE li_return INTO lw_return WITH KEY type ='E'.

      IF  sy-subrc = 0.

*      MESSAGE lw_return-message TYPE 'E' DISPLAY LIKE 'I'.
        CALL FUNCTION 'MESSAGES_INITIALIZE'
          EXCEPTIONS
            log_not_active       = 1
            wrong_identification = 2
            OTHERS               = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        LOOP AT li_return INTO lw_return WHERE type = 'E'.

          CALL FUNCTION 'MESSAGE_STORE'
            EXPORTING
              arbgb                  = lw_return-id
*             EXCEPTION_IF_NOT_ACTIVE       = 'X'
              msgty                  = lw_return-type
              msgv1                  = lw_return-message_v1
              msgv2                  = lw_return-message_v2
              msgv3                  = lw_return-message_v3
              msgv4                  = lw_return-message_v4
              txtnr                  = lw_return-number
*             ZEILE                  = ' '
*           IMPORTING
*             ACT_SEVERITY           =
*             MAX_SEVERITY           =
            EXCEPTIONS
              message_type_not_valid = 1
              not_active             = 2
              OTHERS                 = 3.
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
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.

FORM print.
  BREAK ppadhy.
  SELECT SINGLE mjahr FROM mseg INTO @DATA(lv_mjahr) WHERE mblnr = @lv_matdoc.

  IF lv_matdoc IS NOT INITIAL.
    SUBMIT zmm_transfer_order WITH p_mblnr = lv_matdoc  AND RETURN.
  ELSE.
    MESSAGE 'Enter Gr No' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL'OR 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SAVE'.
      PERFORM save.

      SELECT SINGLE mjahr FROM mseg INTO @DATA(lv_mjahr) WHERE mblnr = @lv_matdoc.

      IF gv_matdoc303 IS NOT INITIAL.
        PERFORM popup.
      ENDIF.
      PERFORM refresh.
**    WHEN 'PRINT'.
**      PERFORM print.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_101 .
  BREAK ppadhy .
  DATA: lv_text(10) TYPE c.
  SELECT
    mblnr,
    mjahr,
    zeile,
    matnr,
    werks,
    menge,
    meins,
    bwart,
    lgort,
    charg,
    bktxt,
    smbln,
    smblp,
    shkzg
    FROM matdoc INTO TABLE @DATA(lt_matdoc) WHERE bktxt = @lv_gr .

  IF lt_matdoc IS NOT INITIAL.
    SELECT
      mblnr,
      mjahr,
      zeile,
      matnr,
      werks,
      menge,
      meins,
      bwart,
      lgort,
      charg,
      bktxt,
      smbln,
      smblp,
      shkzg
      FROM matdoc INTO TABLE @DATA(it_matdoc1)
      FOR ALL ENTRIES IN @lt_matdoc
      WHERE mblnr = @lt_matdoc-mblnr AND shkzg = 'S'.
  ENDIF.

  DATA: cnt(02)  TYPE c,
        cnt1(02) TYPE c.

  LOOP AT it_matdoc1 ASSIGNING FIELD-SYMBOL(<w_matdoc1>) .
    IF <w_matdoc1>-bwart = '303'.
      cnt = cnt + 1.
    ELSEIF <w_matdoc1>-bwart = '304'.
      cnt1 = cnt1 + 1.
    ENDIF.
  ENDLOOP.

  IF it_matdoc1 IS NOT INITIAL.

    IF cnt IS NOT INITIAL AND cnt1 IS INITIAL.
      MESSAGE '303 already done for this GR' TYPE 'E'.
    ENDIF.

    IF cnt >= cnt1 OR cnt = cnt1 ." or cnt1 IS INITIAL.
      PERFORM select.
    ELSE.
      MESSAGE '303 already done for this GR' TYPE 'E'.
    ENDIF.
  ELSE.
    PERFORM select.
  ENDIF.

ENDFORM.

FORM get_303.

*  SELECT mblnr, bktxt FROM matdoc INTO TABLE @data(it_matdoc)

  SELECT
     mblnr,
     mjahr,
     zeile,
     matnr,
     werks,
     menge,
     meins,
     bwart,
     lgort,
     charg,
     bktxt,
     smbln,
     smblp,
     shkzg
     FROM matdoc INTO TABLE @DATA(lt_matdoc) WHERE bktxt = @lv_gr.

  IF lt_matdoc IS NOT INITIAL.
    SELECT
      mblnr,
      mjahr,
      zeile,
      matnr,
      werks,
      menge,
      meins,
      bwart,
      lgort,
      charg,
      bktxt,
      smbln,
      smblp,
      shkzg
      FROM matdoc INTO TABLE @DATA(it_matdoc1)
      FOR ALL ENTRIES IN @lt_matdoc
      WHERE mblnr = @lt_matdoc-mblnr AND shkzg = 'S'.
  ENDIF.

  DATA: cnt2(02) TYPE c,
        cnt3(02) TYPE c.
  DATA lv_length TYPE i . "variable to store length
  LOOP AT it_matdoc1 ASSIGNING FIELD-SYMBOL(<w_matdoc1>) .
    IF <w_matdoc1>-bwart = '305'.
      cnt2 = cnt2 + 1.
    ELSEIF <w_matdoc1>-bwart = '306'.
      cnt3 = cnt3 + 1.
    ENDIF.
  ENDLOOP.

  lv_length = strlen( cnt3 ).
  IF lv_length = 1..

    cnt3 = 0 && cnt3.

  ENDIF.

  IF it_matdoc1 IS NOT INITIAL.

    IF cnt2 IS NOT INITIAL AND cnt3 IS INITIAL.
      MESSAGE '305 already done for this GR' TYPE 'E'.
    ENDIF.
    CONDENSE cnt2.
    CONDENSE cnt3.

    IF cnt2 >= cnt3 OR cnt2 = cnt3 ." or cnt1 IS INITIAL.
      PERFORM select1.
    ELSE.
      MESSAGE '305 already done for this GR' TYPE 'E'.
    ENDIF.
  ELSE.
    PERFORM select1.
  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4 INPUT.

  TYPES: BEGIN OF ty_f4,
           werks TYPE werks_d,
         END OF ty_f4.

  DATA: it_f4 TYPE TABLE OF ty_f4,
        wa_f4 TYPE ty_f4.

  SELECT werks FROM t001w INTO TABLE it_f4 WHERE werks LIKE 'S%'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'LV_TO'
      value_org       = 'S'
    TABLES
      value_tab       = it_f4
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDMODULE.

FORM select.
  BREAK ppadhy.
  IF gv_bwart = c_109.
    SELECT
         matdoc~key1,
         matdoc~key2,
         matdoc~key3,
         matdoc~key4,
         matdoc~key5,
         matdoc~key6,
         matdoc~mblnr,
         matdoc~mjahr,
         matdoc~zeile,
         matdoc~matnr,
         matdoc~werks,
         matdoc~menge,
         matdoc~meins,
         matdoc~bwart,
         matdoc~lgort,
         matdoc~charg,
         matdoc~bktxt,
         matdoc~lbbsa_sid,
         mara~ean11,
         mara~matkl,
         makt~maktx
         FROM matdoc AS matdoc
         INNER JOIN mara AS mara ON matdoc~matnr = mara~matnr
         INNER JOIN makt AS makt ON matdoc~matnr = makt~matnr
         WHERE matdoc~bwart = @c_109  AND matdoc~mblnr = @lv_gr AND matdoc~lbbsa_sid = '01'
         INTO TABLE @DATA(it_doc).

    LOOP AT it_doc INTO DATA(wa_doc).

      wa_item-sl    = sy-tabix.
      wa_item-cc    = wa_doc-matkl.
      wa_item-matnr = wa_doc-matnr.
      wa_item-ean   = wa_doc-ean11.
      wa_item-qty   = wa_doc-menge.
      wa_item-uom   = wa_doc-meins.
      wa_item-maktx = wa_doc-maktx.
      wa_item-lgort = wa_doc-lgort.
      wa_item-charg = wa_doc-charg.

      gv_bwart = wa_doc-bwart.
      lv_from  = wa_doc-werks.

      APPEND wa_item TO it_item.
      CLEAR wa_item.

    ENDLOOP.

  ELSEIF gv_bwart = c_101.

    SELECT
        matdoc~key1,
        matdoc~key2,
        matdoc~key3,
        matdoc~key4,
        matdoc~key5,
        matdoc~key6,
        matdoc~mblnr,
        matdoc~mjahr,
        matdoc~zeile,
        matdoc~matnr,
        matdoc~werks,
        matdoc~menge,
        matdoc~meins,
        matdoc~bwart,
        matdoc~lgort,
        matdoc~charg,
        matdoc~bktxt,
        matdoc~lbbsa_sid,
        mara~ean11,
        mara~matkl,
        makt~maktx
        FROM matdoc AS matdoc
        INNER JOIN mara AS mara ON matdoc~matnr = mara~matnr
        INNER JOIN makt AS makt ON matdoc~matnr = makt~matnr
        WHERE matdoc~bwart = @c_101 AND matdoc~mblnr = @lv_gr
        INTO TABLE @DATA(lt_doc).

    LOOP AT lt_doc INTO DATA(w_doc).

      wa_item-sl    = sy-tabix.
      wa_item-cc    = w_doc-matkl.
      wa_item-matnr = w_doc-matnr.
      wa_item-ean   = w_doc-ean11.
      wa_item-qty   = w_doc-menge.
      wa_item-uom   = w_doc-meins.
      wa_item-maktx = w_doc-maktx.
      wa_item-lgort = w_doc-lgort.
      wa_item-charg = w_doc-charg.

      gv_bwart = w_doc-bwart.
      lv_from  = w_doc-werks.

      APPEND wa_item TO it_item.
      CLEAR wa_item.

    ENDLOOP.


  ENDIF.


  CALL METHOD grid->refresh_table_display.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_109
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_109 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh .

  BREAK ppadhy.
  REFRESH it_item.
  REFRESH li_return.
  CLEAR :lv_gr , lv_from, lv_to , lv_matdoc.
  CALL METHOD grid->refresh_table_display.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM popup .

  DATA: lv_text   TYPE char200,
        lv_answer TYPE c.
  lv_text = 'Do you want to Print the Form ?'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'            "pop up for confirmation
    EXPORTING
      titlebar              = 'Warning'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = lv_text
      text_button_1         = 'YES'
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'NO'
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = 'X'
*     USERDEFINED_F1_HELP   = ' '
      start_column          = 25
      start_row             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = lv_answer
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF lv_answer = 1.      "if yes
    PERFORM print.   "changing pricing condition in vk12
  ELSEIF lv_answer = 2.  "if no
*            PERFORM APPROVE_COST.
  ENDIF.

ENDFORM.

FORM select1.

  SELECT
   matdoc~mblnr,
   matdoc~mjahr,
   matdoc~zeile,
   matdoc~matnr,
   matdoc~werks,
   matdoc~menge,
   matdoc~meins,
   matdoc~bwart,
   matdoc~lgort,
   matdoc~charg,
   matdoc~shkzg,
   matdoc~bktxt,
   mara~ean11,
   mara~matkl,
   makt~maktx
   FROM matdoc AS matdoc
   INNER JOIN mara AS mara ON matdoc~matnr = mara~matnr AND matdoc~bwart = @c_303 AND matdoc~mblnr = @lv_gr AND shkzg = 'H'
   INNER JOIN makt AS makt ON matdoc~matnr = makt~matnr INTO TABLE @DATA(it_doc).

  LOOP AT it_doc INTO DATA(wa_doc).

    wa_item-sl    = sy-tabix.
    wa_item-cc    = wa_doc-matkl.
    wa_item-matnr = wa_doc-matnr.
    wa_item-ean   = wa_doc-ean11.
    wa_item-qty   = wa_doc-menge.
    wa_item-uom   = wa_doc-meins.
    wa_item-maktx = wa_doc-maktx.
    wa_item-lgort = wa_doc-lgort.
    wa_item-charg = wa_doc-charg.

    gv_bwart = wa_doc-bwart.
    lv_from  = wa_doc-werks.

    APPEND wa_item TO it_item.
    CLEAR wa_item.

  ENDLOOP.

  CALL METHOD grid->refresh_table_display.

ENDFORM.
