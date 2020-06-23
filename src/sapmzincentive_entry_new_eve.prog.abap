*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_NEW_EVE
*&---------------------------------------------------------------------*
CLASS: cl_event_skn DEFINITION DEFERRED.

DATA: g_verifier TYPE REF TO cl_event_skn.

CLASS cl_event_skn DEFINITION.

PUBLIC SECTION.
DATA: error_in_data TYPE c.
***METHODs: enter
METHODS: update       FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed.
METHODS: toolbar      FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive.
METHODS: user_command FOR EVENT after_user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
*METHODS: f4           FOR EVENT onf4 OF cl_gui_alv_grid IMPORTING
*                      sender
*                      e_fieldname
*                      e_fieldvalue
*                      es_row_no
*                      er_event_data
*                      et_bad_cells
*                      e_display.

  PRIVATE SECTION.
ENDCLASS.

CLASS cl_event_skn IMPLEMENTATION.

METHOD update.
DATA: lv_matnr TYPE matnr.
DATA: lt_edit  TYPE TABLE OF  lvc_s_styl ,
      ls_edit  TYPE  lvc_s_styl,
      lv_maktx TYPE maktx,
      lv_ccode TYPE matkl,
      lv_batch TYPE charg_d,
      lv_brand TYPE char10,
      lv_group TYPE char10,
      lv_lifnr TYPE lifnr.


*FIELD-SYMBOLS: <fs> TYPE table. " Output table
*IF er_data_changed->mt_inserted_rows IS INITIAL.
****LOOP AT er_data_changed->mt_inserted_rows INTO DATA(sw_insrows).
****        READ TABLE er_data_changed->mp_mod_rows INTO DATA(sw_modrows) INDEX sw_insrows-row_id.
*        IF <fs> IS ASSIGNED.
*          REFRESH <fs> .
*        ENDIF.
*        ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
*        IF <fs> IS ASSIGNED.
*        LOOP AT <fs> INTO wa_item .
*          DATA(stabix) = sy-tabix.
*          IF wa_item-ccode IS NOT INITIAL.
*            REFRESH : lt_edit.
*            ls_edit-fieldname = 'SSTCODE'.
*            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
*            INSERT ls_edit INTO TABLE lt_edit.
*            CLEAR ls_edit.
*
****            ls_edit-fieldname = 'CCODE'.
****            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
****            INSERT ls_edit INTO TABLE lt_edit.
****            CLEAR ls_edit.
*
*            ls_edit-fieldname = 'BATCH'.
*            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
*            INSERT ls_edit INTO TABLE lt_edit.
*            CLEAR ls_edit.
*
*            ls_edit-fieldname = 'GROUP'.
*            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
*            INSERT ls_edit INTO TABLE lt_edit.
*            CLEAR ls_edit.
*
*            ls_edit-fieldname = 'BRAND'.
*            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
*            INSERT ls_edit INTO TABLE lt_edit.
*            CLEAR ls_edit.
*            CLEAR : wa_item-style.
*           INSERT LINES OF lt_edit INTO TABLE wa_item-style.
*             IF wa_item-style IS NOT INITIAL.
*
*              MODIFY <fs> INDEX stabix FROM wa_item." TRANSPORTING style .
*          ENDIF.
*          ENDIF.
*        ENDLOOP.
*        ENDIF.
*        ENDIF.
******         CALL METHOD grid->refresh_table_display.
***        ENDIF.
****        PERFORM fill_insdata .
***      ENDLOOP.
**      CALL METHOD grid->refresh_table_display
*        EXPORTING
*          is_stable      =                  " With Stable Rows/Columns
*          i_soft_refresh =                  " Without Sort, Filter, etc.
*        EXCEPTIONS
*          finished       = 1                " Display was Ended (by Export)
*          others         = 2
        .
*      IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*      IF er_data_changed->mt_inserted_rows IS INITIAL.

  LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<good>).

   CASE <good>-fieldname.
     WHEN 'SSTCODE'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'SSTCODE'
          IMPORTING
            e_value     =  lv_matnr.
    IF lv_matnr IS NOT INITIAL.
         SELECT SINGLE maktx FROM makt INTO lv_maktx WHERE matnr = lv_matnr AND spras = sy-langu.
          CALL METHOD er_data_changed->modify_cell
              EXPORTING
               i_row_id    = <good>-row_id
               i_fieldname = 'SSTDESC'
               i_value     =  lv_maktx.
               CLEAR: lv_matnr, lv_maktx.

            REFRESH : lt_edit.
            ls_edit-fieldname = 'CCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BATCH'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BRAND'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'GROUP'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'LIFNR'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            INSERT LINES OF lt_edit INTO TABLE wa_item-style.
             IF wa_item-style IS NOT INITIAL.
              MODIFY it_item INDEX <good>-row_id FROM wa_item TRANSPORTING style .
            ENDIF.

            DATA ls_stable TYPE lvc_s_stbl.

              ls_stable-row = abap_true.
              ls_stable-col = abap_true.
*
          CALL METHOD grid->refresh_table_display
            EXPORTING
              is_stable      = ls_stable                 " With Stable Rows/Columns
***              i_soft_refresh =                  " Without Sort, Filter, etc.
            EXCEPTIONS
              finished       = 1                " Display was Ended (by Export)
              OTHERS         = 2
            .
          IF sy-subrc <> 0.
*           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF..
     ENDIF.

    WHEN 'CCODE'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'CCODE'
          IMPORTING
            e_value     =  lv_ccode.
    IF lv_ccode IS NOT INITIAL.
            REFRESH : lt_edit.
            ls_edit-fieldname = 'SSTCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BATCH'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BRAND'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'GROUP'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'LIFNR'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.
           INSERT LINES OF lt_edit INTO TABLE wa_item-style.
           IF wa_item-style IS NOT INITIAL.
            MODIFY it_item INDEX  <good>-row_id FROM wa_item TRANSPORTING style .
           ENDIF.

          CALL METHOD grid->refresh_table_display.
     ENDIF.

 WHEN 'BATCH'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'BATCH'
          IMPORTING
            e_value     =  lv_batch.
    IF lv_batch IS NOT INITIAL.
            REFRESH : lt_edit.
            ls_edit-fieldname = 'SSTCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'CCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BRAND'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'GROUP'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'LIFNR'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

           INSERT LINES OF lt_edit INTO TABLE wa_item-style.
             IF wa_item-style IS NOT INITIAL.
              MODIFY it_item INDEX <good>-row_id FROM wa_item TRANSPORTING style .
            ENDIF.

          CALL METHOD grid->refresh_table_display.
     ENDIF.

 WHEN 'BRAND'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'BRAND'
          IMPORTING
            e_value     =  lv_brand.
    IF lv_brand IS NOT INITIAL.
            REFRESH : lt_edit.
            ls_edit-fieldname = 'SSTCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'CCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BATCH'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'GROUP'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'LIFNR'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

           INSERT LINES OF lt_edit INTO TABLE wa_item-style.
             IF wa_item-style IS NOT INITIAL.
              MODIFY it_item INDEX <good>-row_id FROM wa_item TRANSPORTING style .
            ENDIF.

          CALL METHOD grid->refresh_table_display.
     ENDIF.
WHEN 'GROUP'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'GROUP'
          IMPORTING
            e_value     =  lv_group.
    IF lv_group IS NOT INITIAL.
            REFRESH : lt_edit.
            ls_edit-fieldname = 'SSTCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'CCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BATCH'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BRAND'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'LIFNR'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

           INSERT LINES OF lt_edit INTO TABLE wa_item-style.
           IF wa_item-style IS NOT INITIAL.
             MODIFY it_item INDEX <good>-row_id FROM wa_item TRANSPORTING style .
           ENDIF.
          CALL METHOD grid->refresh_table_display.
     ENDIF.
WHEN 'LIFNR'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'LIFNR'
          IMPORTING
            e_value     =  lv_lifnr.
    IF lv_lifnr IS NOT INITIAL.
            REFRESH : lt_edit.
            ls_edit-fieldname = 'SSTCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'CCODE'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BATCH'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'GROUP'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

            ls_edit-fieldname = 'BRAND'.
            ls_edit-style = cl_gui_alv_grid=>mc_style_disabled  .
            INSERT ls_edit INTO TABLE lt_edit.
            CLEAR ls_edit.

           INSERT LINES OF lt_edit INTO TABLE wa_item-style.
             IF wa_item-style IS NOT INITIAL.
              MODIFY it_item INDEX <good>-row_id FROM wa_item TRANSPORTING style .
            ENDIF.
          CALL METHOD grid->refresh_table_display.
     ENDIF.
   ENDCASE.
   CLEAR: lv_matnr, lv_maktx, lv_ccode, lv_brand, lv_group, lv_lifnr, lv_batch.
  ENDLOOP.
  CLEAR:wa_item-style. ", <good>.

ENDMETHOD.

METHOD toolbar.
  DATA: mt_toolbar TYPE stb_button.
  CLEAR mt_toolbar.
    mt_toolbar-butn_type = 0.
    mt_toolbar-function = 'BT_NEW'.
    mt_toolbar-icon = '@0Y@'.
    mt_toolbar-text = 'New Entry'.
    mt_toolbar-quickinfo = 'New Entry'.
    APPEND mt_toolbar TO e_object->mt_toolbar.
    CLEAR mt_toolbar.

    mt_toolbar-butn_type = 0.
    mt_toolbar-function = 'BT_DELETE'.
    mt_toolbar-icon = '@11@'.
    mt_toolbar-text = 'Del Entry'.
    mt_toolbar-quickinfo = 'Del Entry'.
    APPEND mt_toolbar TO e_object->mt_toolbar.
    CLEAR mt_toolbar.

    mt_toolbar-butn_type = 0.
    mt_toolbar-function = 'BT_COPY'.
    mt_toolbar-icon = '@14@'.
    mt_toolbar-text = 'Copy Entry'.
    mt_toolbar-quickinfo = 'Copy Entry'.
    APPEND mt_toolbar TO e_object->mt_toolbar.
    CLEAR mt_toolbar.

ENDMETHOD.

METHOD user_command.
 CASE e_ucomm.
  WHEN 'BT_NEW'.
      REFRESH: it_item.
      CALL METHOD grid->refresh_table_display.
  WHEN 'BT_DELETE'.
     PERFORM delete.
  WHEN 'BT_COPY'.
     PERFORM copy.
  WHEN OTHERS.


 ENDCASE.
ENDMETHOD.

*METHOD f4.
*DATA: lv_fnam TYPE dynfnam.
*FIELD-SYMBOLS:<itab> TYPE lvc_t_modi.
*DATA:it_f41 TYPE TABLE OF dfies,
*     it_ret TYPE TABLE OF ddshretval,
*     ls_modi TYPE lvc_s_modi.
*
* lv_fnam = e_fieldname.
*
*  CASE lv_fnam.
*    WHEN 'SSTCODE'.
*      SELECT a~matnr,a~matkl,a~brand_id,b~maktx FROM mara AS a INNER JOIN makt AS b ON a~matnr = b~matnr
*                                     INTO TABLE @DATA(it_mara) FOR ALL ENTRIES IN @it_item
*                                     WHERE a~matkl = @it_item-ccode AND b~spras = @sy-langu.
*
*    READ TABLE it_item ASSIGNING FIELD-SYMBOL(<row>) INDEX es_row_no-row_id.
*     DELETE it_mara   WHERE matkl <> <row>-ccode.
*     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*              EXPORTING
*                retfield               = 'MATNR'
*                dynpprog               = sy-repid
*                dynpnr                 = sy-dynnr
*                dynprofield            = lv_fnam
*                window_title           = 'Materials'
*                value_org              = 'S'
*              TABLES
*                value_tab              = it_mara
*                field_tab              = it_f41
*                return_tab             = it_ret
*             EXCEPTIONS
*               parameter_error        = 1
*               no_values_found        = 2
*               OTHERS                 = 3.
*            IF sy-subrc <> 0.
**     IMPLEMENT SUITABLE ERROR HANDLING HERE
*            ELSE.
*              ASSIGN er_event_data->m_data->* TO <itab>.
*              ls_modi-row_id = es_row_no-row_id.
*              ls_modi-fieldname = e_fieldname.
*              READ TABLE it_ret ASSIGNING FIELD-SYMBOL(<ret>) INDEX 1.
*              IF sy-subrc = 0.
*                ls_modi-value = <ret>-fieldval.
*              ENDIF.
*              APPEND ls_modi TO <itab>.
*******************************************************************************************************
*              ls_modi-row_id = es_row_no-row_id.
*              ls_modi-fieldname = 'SSTDESC'.
*              READ TABLE it_ret INTO <ret>  INDEX 1.
*              IF sy-subrc = 0.
*                READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<mar>) WITH KEY matnr = <ret>-fieldval.
*                ls_modi-value = <mar>-maktx.
*              ENDIF.
*              APPEND ls_modi TO <itab>.
**********************************************************************************************************
*              ls_modi-row_id = es_row_no-row_id.
*              ls_modi-fieldname = 'BRAND'.
*              READ TABLE it_ret INTO <ret>  INDEX 1.
*              IF sy-subrc = 0.
*                READ TABLE it_mara INTO <mar>  WITH KEY matnr = <ret>-fieldval.
*                ls_modi-value = <mar>-brand_id.
*              ENDIF.
*              APPEND ls_modi TO <itab>.
*********************************************************************************************************
*            ENDIF.
*  ENDCASE.
*             er_event_data->m_event_handled = 'X'.
*ENDMETHOD.

ENDCLASS.
