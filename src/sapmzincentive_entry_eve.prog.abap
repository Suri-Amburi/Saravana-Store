*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_EVE
*&---------------------------------------------------------------------*

CLASS: cl_event_skn DEFINITION DEFERRED.

DATA: g_verifier TYPE REF TO cl_event_skn.

CLASS cl_event_skn DEFINITION.

PUBLIC SECTION.
DATA: error_in_data TYPE c.

METHODS: update       FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed.
METHODS: toolbar      FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive.
METHODS: user_command FOR EVENT after_user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
METHODS: f4           FOR EVENT onf4 OF cl_gui_alv_grid IMPORTING
                      sender
                      e_fieldname
                      e_fieldvalue
                      es_row_no
                      er_event_data
                      et_bad_cells
                      e_display.

  PRIVATE SECTION.
ENDCLASS.

CLASS cl_event_skn IMPLEMENTATION.

METHOD update.
DATA: lv_matnr TYPE matnr,
      lv_maktx TYPE maktx,
      lv_pernr TYPE persno,
      lv_sname TYPE sname,
      lv_ccode TYPE matkl.

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
      SELECT SINGLE matkl FROM mara INTO lv_ccode WHERE matnr = lv_matnr.

        CALL METHOD er_data_changed->modify_cell
          EXPORTING
           i_row_id    = <good>-row_id
           i_fieldname = 'SSTDESC'
           i_value     =  lv_maktx.
          CLEAR: lv_matnr, lv_maktx.

        CALL METHOD er_data_changed->modify_cell
          EXPORTING
           i_row_id    = <good>-row_id
           i_fieldname = 'CCODE'
           i_value     =  lv_ccode.
          CLEAR: lv_matnr, lv_maktx,lv_ccode.
ENDIF.
      WHEN 'PERNR'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'PERNR'
          IMPORTING
            e_value     =  lv_pernr.

      SELECT SINGLE sname FROM pa0001 INTO lv_sname WHERE pernr = lv_pernr.

        CALL METHOD er_data_changed->modify_cell
          EXPORTING
           i_row_id    = <good>-row_id
           i_fieldname = 'SSTDESC'
           i_value     =  lv_maktx.
          CLEAR: lv_pernr, lv_sname.

      WHEN 'CCODE' OR 'SSTCODE'.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    =  <good>-row_id
            i_fieldname =  'CCODE'
          IMPORTING
            e_value     =  lv_ccode.

        SELECT SINGLE clint FROM klah INTO @DATA(lv_clint)  WHERE class = @lv_ccode.
        SELECT SINGLE clint FROM kssk INTO @DATA(lv_clint1) WHERE objek = @lv_clint.
        SELECT SINGLE class FROM klah INTO @DATA(lv_class)  WHERE clint = @lv_clint1.

        CALL METHOD er_data_changed->modify_cell
          EXPORTING
           i_row_id    = <good>-row_id
           i_fieldname = 'GROUP'
           i_value     =  lv_class.
          CLEAR: lv_ccode,lv_clint,lv_clint1,lv_class.

    WHEN 'GROUP'.



   ENDCASE.
  ENDLOOP.


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

METHOD f4.
DATA: lv_fnam TYPE dynfnam.
FIELD-SYMBOLS:<itab> TYPE lvc_t_modi.
DATA:it_f41 TYPE TABLE OF dfies,
     it_ret TYPE TABLE OF ddshretval,
     ls_modi TYPE lvc_s_modi.

 lv_fnam = e_fieldname.

  CASE lv_fnam.
    WHEN 'SSTCODE'.
      SELECT a~matnr,a~matkl,a~brand_id,b~maktx FROM mara AS a INNER JOIN makt AS b ON a~matnr = b~matnr
                                     INTO TABLE @DATA(it_mara) FOR ALL ENTRIES IN @it_item
                                     WHERE a~matkl = @it_item-ccode AND b~spras = @sy-langu.

    READ TABLE it_item ASSIGNING FIELD-SYMBOL(<row>) INDEX es_row_no-row_id.
     DELETE it_mara   WHERE matkl <> <row>-ccode.
     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
              EXPORTING
                retfield               = 'MATNR'
                dynpprog               = sy-repid
                dynpnr                 = sy-dynnr
                dynprofield            = lv_fnam
                window_title           = 'Materials'
                value_org              = 'S'
              TABLES
                value_tab              = it_mara
                field_tab              = it_f41
                return_tab             = it_ret
             EXCEPTIONS
               parameter_error        = 1
               no_values_found        = 2
               OTHERS                 = 3.
            IF sy-subrc <> 0.
*     IMPLEMENT SUITABLE ERROR HANDLING HERE
            ELSE.
              ASSIGN er_event_data->m_data->* TO <itab>.
              ls_modi-row_id = es_row_no-row_id.
              ls_modi-fieldname = e_fieldname.
              READ TABLE it_ret ASSIGNING FIELD-SYMBOL(<ret>) INDEX 1.
              IF sy-subrc = 0.
                ls_modi-value = <ret>-fieldval.
              ENDIF.
              APPEND ls_modi TO <itab>.
******************************************************************************************************
              ls_modi-row_id = es_row_no-row_id.
              ls_modi-fieldname = 'SSTDESC'.
              READ TABLE it_ret INTO <ret>  INDEX 1.
              IF sy-subrc = 0.
                READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<mar>) WITH KEY matnr = <ret>-fieldval.
                ls_modi-value = <mar>-maktx.
              ENDIF.
              APPEND ls_modi TO <itab>.
*********************************************************************************************************
              ls_modi-row_id = es_row_no-row_id.
              ls_modi-fieldname = 'BRAND'.
              READ TABLE it_ret INTO <ret>  INDEX 1.
              IF sy-subrc = 0.
                READ TABLE it_mara INTO <mar>  WITH KEY matnr = <ret>-fieldval.
                ls_modi-value = <mar>-brand_id.
              ENDIF.
              APPEND ls_modi TO <itab>.
********************************************************************************************************
            ENDIF.
  ENDCASE.
             er_event_data->m_event_handled = 'X'.
ENDMETHOD.

ENDCLASS.
