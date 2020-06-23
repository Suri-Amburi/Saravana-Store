*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ALV_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_grid .
CREATE OBJECT container
    EXPORTING
     container_name = 'CONTAINER'.

  CREATE OBJECT grid
    EXPORTING
      i_parent   = container.

  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error = 1
      OTHERS = 2.

      gs_f4-fieldname = 'SSTCODE'.
      gs_f4-register = 'X'.
      gs_f4-chngeafter = 'X'.
      gs_f4-getbefore = 'X'.
      APPEND gs_f4 TO gt_f4.


  CALL METHOD grid->register_f4_for_fields
    EXPORTING
      it_f4 = gt_f4.


  CREATE OBJECT g_verifier.
  SET HANDLER g_verifier->toolbar FOR grid.
  SET HANDLER g_verifier->f4 FOR grid.
  SET HANDLER g_verifier->update FOR grid.

PERFORM exclude_tb_function CHANGING it_exclude.
PERFORM fill_grid1.
PERFORM fill_grid2.
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
*  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
*  APPEND ls_exclude TO lt_exclude.
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
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
*  APPEND ls_exclude TO lt_exclude.
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
*& Form FILL_GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_grid1 .
REFRESH lt_fieldcat.
 PERFORM fc USING:
  '01'  'CCODE'     'IT_ITEM'  'Cat.Code'  'Cat.Code'  'Cat.Code'    'X' '' '10'  ''  '' '' ''
   CHANGING lt_fieldcat,
  '02'  'SSTCODE'   'IT_ITEM'  'SST.Code'  'SST.Code'  'SST.Code'    'X' '' '10'  'X'  '' '' ''
  CHANGING lt_fieldcat,
  '03'  'SSTDESC'   'IT_ITEM'  'SST.Desc'  'SST.Desc'  'SST.Desc'    ''  '' '15'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '04'  'BATCH'     'IT_ITEM'  'Batch'     'Batch'     'Batch'       'X' '' '10'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '05'  'BRAND'     'IT_ITEM'  'Brand'     'Brand'     'Brand'       'X' '' '5'   ''  '' '' ''
  CHANGING lt_fieldcat,
  '06'  'GROUP'     'IT_ITEM'  'Group'     'Group'     'Group'       'X' '' '10'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '07'  'LIFNR'     'IT_ITEM'  'Vendor'    'Vendor'    'Vendor'      'X' '' '10'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '08'  'PERNR'     'IT_ITEM'  'Emp.No'    'Emp.No'    'Emp.No'      'X' '' '10'  'X'  'PA0001' 'PERNR' ''
   CHANGING lt_fieldcat,
  '09'  'NAME'      'IT_ITEM'  'Emp.Name'  'Emp.Name'  'Emp.Name'    'X' '' '15'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '10'  'DATEF'     'IT_ITEM'  'Date Fm'   'Date From' 'Date From'  'X' '' '10'  ''  'MKPF' 'BUDAT' ''
  CHANGING lt_fieldcat,
  '11'  'DATET'     'IT_ITEM'  'Date To'   'Date To'   'Date To'     'X' '' '10'  ''  'MKPF' 'BUDAT' ''
  CHANGING lt_fieldcat,
  '12'  'MON'       'IT_ITEM'  'Mon'       'Mon'       'Mon'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '13'  'TUE'       'IT_ITEM'  'Tue'       'Tue'       'Tue'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '14'  'WED'       'IT_ITEM'  'Wed'       'Wed'       'Wed'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
   '15'  'THU'      'IT_ITEM'  'Thu'       'Thu'       'Thu'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '16'   'FRI'      'IT_ITEM'  'Fri'       'Fri'       'Fri'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '17'   'SAT'      'IT_ITEM'  'Sat'       'Sat'       'Sat'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '18'   'SUN'      'IT_ITEM'  'Sun'       'Sun'       'Sun'         'X' '' '03'  ''  '' '' ''
  CHANGING lt_fieldcat,
  '19'  'TARPC'     'IT_ITEM'  'Target(pc)' 'Target(pc)' 'Target(pc)' 'X' '' '10'  ''  'MSEG' 'MENGE' ''
  CHANGING lt_fieldcat,
  '20'  'TARVAL'    'IT_ITEM'  'Tar(val)'  'Target(val)' 'Target(val)' 'X' '' '10'  ''  'MSEG' 'MENGE' ''
  CHANGING lt_fieldcat,
  '21'  'INCEPC'     'IT_ITEM'  'Ince(pc)'  'Incen(pc)' 'Incentive(pc)' 'X' '' '10'  ''  'MSEG' 'MENGE' ''
  CHANGING lt_fieldcat,
  '22'  'INCEVAL'    'IT_ITEM'  'Ince(val)' 'Incen(val)' 'Incentive(val)' 'X' '' '10'  ''  'MSEG' 'MENGE' ''
  CHANGING lt_fieldcat,
  '23'  'DOCNO'      'IT_ITEM'  'Doc No'    'Doc No'     'Doc No'  'X' '' '10'  ''  ' ' ' ' ''
  CHANGING lt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FC
*&---------------------------------------------------------------------*
*& text
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

  IF wa_fcat-fieldname  = 'MON' OR wa_fcat-fieldname = 'TUE' OR wa_fcat-fieldname = 'WED' OR wa_fcat-fieldname = 'THU'
     OR wa_fcat-fieldname = 'FRI'  OR wa_fcat-fieldname = 'SAT' OR wa_fcat-fieldname = 'SUN'.
     wa_fcat-checkbox = 'X'.
  ENDIF.

  APPEND wa_fcat TO lt_fieldcat.
  CLEAR wa_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_GRID2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_grid2 .

 lw_layo-frontend = 'X'.
 lw_layo-stylefname = 'STYLE'.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = lw_layo
      it_toolbar_excluding          = it_exclude
    CHANGING
      it_outtab                     = it_item
      it_fieldcatalog               = lt_fieldcat
*      IT_SORT                       = LT_SORT
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4 .

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

CALL METHOD grid->set_ready_for_input
  EXPORTING
  i_ready_for_input = 1.

  CALL METHOD grid->set_toolbar_interactive.


ENDFORM.
*&---------------------------------------------------------------------*
*& Module LOGO_DISP OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE logo_disp OUTPUT.
IF picture IS NOT BOUND.
    CALL METHOD cl_gui_cfw=>flush.
    CREATE OBJECT:
   logo EXPORTING container_name = 'LOGO',
   picture EXPORTING parent = logo.

    CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
      EXPORTING
        p_object       = 'GRAPHICS'
        p_name         = 'ZSARVANA_LOGO'
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
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete .
  REFRESH : row_ind.
  CALL METHOD grid->get_selected_rows
    IMPORTING
      et_index_rows = row_ind.
  LOOP AT row_ind  ASSIGNING FIELD-SYMBOL(<row>).
    READ TABLE it_item ASSIGNING FIELD-SYMBOL(<item>) INDEX <row>-index.
      IF sy-subrc = 0.
        UPDATE zincentive      SET del_ind = 'X' WHERE docno = <item>-docno.
        UPDATE zincentive_item SET del_ind = 'X' WHERE docno = <item>-docno.
        DELETE it_item WHERE docno = <item>-docno.
        CALL METHOD grid->refresh_table_display.
      ENDIF.
  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form COPY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM copy .

  REFRESH : row_ind,it_item1.
  CALL METHOD grid->get_selected_rows
    IMPORTING
      et_index_rows = row_ind.
  LOOP AT row_ind  ASSIGNING FIELD-SYMBOL(<row>).
    READ TABLE it_item ASSIGNING FIELD-SYMBOL(<item>) INDEX <row>-index.
      IF sy-subrc = 0.
         MOVE-CORRESPONDING <item> TO wa_item1.
         APPEND wa_item1 TO it_item1.
         CLEAR wa_item1.
      ENDIF.
  ENDLOOP.
       REFRESH: it_item.
        it_item = it_item1.
      CALL METHOD grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .
DATA: number  TYPE char10,
      lv_item TYPE posnr.

SELECT * FROM zincentive INTO TABLE @DATA(it_ince) WHERE werks = @lv_werks AND del_ind <> 'X'.
 CLEAR: number, lv_item.
 LOOP AT it_item ASSIGNING FIELD-SYMBOL(<item>).
     lv_item = '000010'.
     CLEAR number.
     CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr                   = '01'
          object                        = 'ZINCENTIVE'
       IMPORTING
         number                        = number
       EXCEPTIONS
         interval_not_found            = 1
         number_range_not_intern       = 2
         object_not_found              = 3
         quantity_is_0                 = 4
         quantity_is_not_1             = 5
         interval_overflow             = 6
         buffer_overflow               = 7
         OTHERS                        = 8                .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
   IF <item>-ccode IS NOT INITIAL AND <item>-sstcode IS NOT INITIAL.
       wa_addf-mandt = sy-mandt. wa_addf-docno = number. wa_addf-werks = lv_werks. wa_addf-matkl = <item>-ccode.
       wa_addf-matnr = <item>-sstcode. wa_addf-maktx = <item>-sstdesc. wa_addf-charg = <item>-batch.
       wa_addf-brand = <item>-brand. wa_addf-group1 = <item>-group. wa_addf-lifnr = <item>-lifnr.
       wa_addf-pernr = <item>-pernr. wa_addf-name = <item>-name. wa_addf-datef = <item>-datef.
       wa_addf-datet = <item>-datet. wa_addf-monday = <item>-mon. wa_addf-tuesday = <item>-tue. wa_addf-wednesday = <item>-wed.
       wa_addf-thursday = <item>-thu. wa_addf-friday = <item>-fri. wa_addf-saturday = <item>-sat.wa_addf-sunday = <item>-sun.
       wa_addf-tar_pc = <item>-tarpc. wa_addf-tar_val = <item>-tarval. wa_addf-ince_pc = <item>-incepc.
       wa_addf-ince_val = <item>-inceval. wa_addf-ernam = sy-uname. wa_addf-erdat = sy-datum.

       MODIFY zincentive FROM wa_addf.
       CLEAR wa_addf.

       wa_addf1-mandt    = sy-mandt.
       wa_addf1-docno    = number.
       wa_addf1-doc_item = lv_item.
       wa_addf1-werks = lv_werks. wa_addf1-matkl = <item>-ccode.
       wa_addf1-matnr = <item>-sstcode. wa_addf1-maktx = <item>-sstdesc. wa_addf1-charg = <item>-batch.
       wa_addf1-brand = <item>-brand. wa_addf1-group1 = <item>-group. wa_addf1-lifnr = <item>-lifnr.
       wa_addf1-pernr = <item>-pernr. wa_addf1-name = <item>-name. wa_addf1-datef = <item>-datef.
       wa_addf1-datet = <item>-datet. wa_addf1-monday = <item>-mon. wa_addf1-tuesday = <item>-tue. wa_addf1-wednesday = <item>-wed.
       wa_addf1-thursday = <item>-thu. wa_addf1-friday = <item>-fri. wa_addf1-saturday = <item>-sat.wa_addf1-sunday = <item>-sun.
       wa_addf1-tar_pc = <item>-tarpc. wa_addf1-tar_val = <item>-tarval. wa_addf1-ince_pc = <item>-incepc.
       wa_addf1-ince_val = <item>-inceval. wa_addf1-ernam = sy-uname. wa_addf1-erdat = sy-datum.

       MODIFY zincentive_item FROM wa_addf1.
       CLEAR wa_addf1.

  ELSEIF <item>-ccode IS NOT INITIAL AND <item>-sstcode IS INITIAL.

      SELECT a~matnr,a~matkl,a~brand_id,b~maktx FROM mara AS a INNER JOIN makt AS b ON a~matnr = b~matnr
                                     INTO TABLE @DATA(it_mara) WHERE a~matkl = @<item>-ccode AND b~spras = @sy-langu.

       wa_addf-mandt = sy-mandt. wa_addf-docno = number. wa_addf-werks = lv_werks. wa_addf-matkl = <item>-ccode.
       wa_addf-matnr = <item>-sstcode. wa_addf-maktx = <item>-sstdesc. wa_addf-charg = <item>-batch.
       wa_addf-brand = <item>-brand. wa_addf-group1 = <item>-group. wa_addf-lifnr = <item>-lifnr.
       wa_addf-pernr = <item>-pernr. wa_addf-name = <item>-name. wa_addf-datef = <item>-datef.
       wa_addf-datet = <item>-datet. wa_addf-monday = <item>-mon. wa_addf-tuesday = <item>-tue. wa_addf-wednesday = <item>-wed.
       wa_addf-thursday = <item>-thu. wa_addf-friday = <item>-fri. wa_addf-saturday = <item>-sat.wa_addf-sunday = <item>-sun.
       wa_addf-tar_pc = <item>-tarpc. wa_addf-tar_val = <item>-tarval. wa_addf-ince_pc = <item>-incepc.
       wa_addf-ince_val = <item>-inceval. wa_addf-ernam = sy-uname. wa_addf-erdat = sy-datum.

       MODIFY zincentive FROM wa_addf.
       CLEAR wa_addf.

    LOOP AT it_mara ASSIGNING FIELD-SYMBOL(<mara>).
       wa_addf1-mandt    = sy-mandt.
       wa_addf1-docno    = number.
       wa_addf1-doc_item = lv_item.
       wa_addf1-werks = lv_werks. wa_addf1-matkl = <item>-ccode.
       wa_addf1-matnr = <mara>-matnr. wa_addf1-maktx = <mara>-maktx. wa_addf1-charg = <item>-batch.
       wa_addf1-brand = <mara>-brand_id. wa_addf1-group1 = <item>-group. wa_addf1-lifnr = <item>-lifnr.
       wa_addf1-pernr = <item>-pernr. wa_addf1-name = <item>-name. wa_addf1-datef = <item>-datef.
       wa_addf1-datet = <item>-datet. wa_addf1-monday = <item>-mon. wa_addf1-tuesday = <item>-tue. wa_addf1-wednesday = <item>-wed.
       wa_addf1-thursday = <item>-thu. wa_addf1-friday = <item>-fri. wa_addf1-saturday = <item>-sat.wa_addf1-sunday = <item>-sun.
       wa_addf1-tar_pc = <item>-tarpc. wa_addf1-tar_val = <item>-tarval. wa_addf1-ince_pc = <item>-incepc.
       wa_addf1-ince_val = <item>-inceval. wa_addf1-ernam = sy-uname. wa_addf1-erdat = sy-datum.

       MODIFY zincentive_item FROM wa_addf1.
       CLEAR wa_addf1.
       lv_item = lv_item + 10.
    ENDLOOP.
 ENDIF.

 ENDLOOP.
ENDFORM.
