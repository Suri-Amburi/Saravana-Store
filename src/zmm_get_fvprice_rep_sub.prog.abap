*&---------------------------------------------------------------------*
*& Include          ZMM_GET_FVPRICE_REP_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
*FORM get_filename  CHANGING p_p_file.

**ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_DATE
*&      <-- XFV_PRLIST[]
*&---------------------------------------------------------------------*
FORM get_data  USING    p_date
               CHANGING xfv_prlist TYPE stfv_prlist.

  DATA : xa515   TYPE TABLE OF a515 WITH HEADER LINE. "Weigh Scale Item Access sequence table

  DATA yfv_prlist TYPE ty_file.

***  CONSTANTS : c_zWSI(4) TYPE c VALUE 'ZWSI'. "Weighing Scale  "
  CONSTANTS : c_zSMP(4) TYPE c VALUE 'ZSMP'. "Weighing Scale

  CONSTANTS : c_kg TYPE kmein VALUE 'KG',
              c_ea TYPE kmein VALUE 'EA'.

  "Get price list for access sequence
  SELECT a~matnr AS bc01,
         b~kbetr AS price,
         b~kmein,
***         CASE
***           WHEN b~kmein = c_kg THEN 0
***           WHEN b~kmein = c_ea THEN 1
***         ELSE 0 END AS status,
         c~maktx
                 INTO TABLE @DATA(gt_fvpr) FROM A406 AS a
                 INNER JOIN konp AS b ON ( b~knumh = a~knumh )
                 INNER JOIN makt AS c ON ( c~spras = @sy-langu AND c~matnr = a~matnr )
                 WHERE a~kschl = @c_zsmp AND a~datbi >= @p_date and b~LOEVM_KO = @space.  " Suri : New Acc. Seq Table : 07.03.2020

  CHECK gt_fvpr IS NOT INITIAL.
  LOOP AT gt_fvpr INTO DATA(gw_fvpr).
    MOVE-CORRESPONDING gw_fvpr TO yfv_prlist.
    yfv_prlist-plu_code = sy-tabix.
    IF gw_fvpr-kmein = c_ea.
      yfv_prlist-status = 1.
    ELSE.
      yfv_prlist-status = 0.
    ENDIF.
    APPEND yfv_prlist TO xfv_prlist .
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_PRLIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> XFV_PRLIST[]
*&---------------------------------------------------------------------*
FORM display_prlist  USING    xfv_prlist TYPE stfv_prlist.
*--> output_alv_factory_data -> sjena <- 18.05.2019 20:23:11
  DATA : lr_alv TYPE REF TO cl_salv_table,
         it_raw TYPE truxs_t_text_data.

*   local data
  DATA: lo_dock TYPE REF TO cl_gui_docking_container,
        lo_cont TYPE REF TO cl_gui_container,
        lo_alv  TYPE REF TO cl_salv_table.

  DATA: lo_cols TYPE REF TO cl_salv_columns.
  DATA: lo_events TYPE REF TO cl_salv_events_table.
  DATA: lr_functions TYPE REF TO cl_salv_functions.
  DATA: lo_h_label TYPE REF TO cl_salv_form_label,
        lo_h_flow  TYPE REF TO cl_salv_form_layout_flow,
        lo_header  TYPE REF TO cl_salv_form_layout_grid,
        lr_layout  TYPE REF TO salv_s_layout.


** Declaration for Global Display Settings
  DATA : gr_display TYPE REF TO cl_salv_display_settings,
         lv_title   TYPE lvc_title.

** declaration for ALV Columns
  DATA : gr_columns    TYPE REF TO cl_salv_columns_table,
         gr_column     TYPE REF TO cl_salv_column,
         lt_column_ref TYPE salv_t_column_ref,
         ls_column_ref TYPE salv_s_column_ref.

** Declaration for Aggregate Function Settings
  DATA : gr_aggr    TYPE REF TO cl_salv_aggregations.

** Declaration for Sort Function Settings
  DATA : gr_sort    TYPE REF TO cl_salv_sorts.

** Declaration for Table Selection settings
  DATA : gr_select  TYPE REF TO cl_salv_selections.

** Declaration for Top of List settings
  DATA : gr_content TYPE REF TO cl_salv_form_element.

  DATA: lo_layout TYPE REF TO cl_salv_layout,
*            lf_variant TYPE slis_vari,
        ls_key    TYPE salv_s_layout_key.

  TRY.
      cl_salv_table=>factory(
  EXPORTING
  list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
*    r_container    =     " Abstract Container for GUI Controls
*    container_name =
        IMPORTING
        r_salv_table   = lr_alv   " Basis Class Simple ALV Tables
        CHANGING
        t_table        = xfv_prlist[]
                                ).

      lo_cols = lr_alv->get_columns( ).

*    *   set the Column optimization
      lo_cols->set_optimize( 'X' ).
      gr_display = lr_alv->get_display_settings( ).
      gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

** header object
*      CREATE OBJECT lo_header.
*      lo_h_label = lo_header->create_label( row = 1 column = 1 ).
*      lo_h_label->set_text( 'Incomplete Pallet Carton Details' ).
*      lr_alv->set_top_of_list( lo_header ).

*      GET layout object
      DATA: lo_column TYPE REF TO cl_salv_column.
      DATA: lo_aggrs TYPE REF TO cl_salv_aggregations.
*      lo_aggrs = lo_alv->get_aggregations( ). "get aggregations
*   Change the properties of the Columns SEQ_NO
      TRY.
          lo_column = lo_cols->get_column( 'PLU_CODE' ).
          lo_column->set_long_text( 'PLU_CODE' ).
          lo_column->set_medium_text( 'PLU_CODE' ).
          lo_column->set_short_text('PLU_CODE').
*      LO_COLUMN->SET_OUTPUT_LENGTH( 10 ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

*   Change the properties of the Columns SEQ_NO
      TRY.
          lo_column = lo_cols->get_column( 'BC01' ).
          lo_column->set_long_text( 'Barcode No.' ).
          lo_column->set_medium_text( 'Barcode No.' ).
          lo_column->set_short_text('Barc. No.').
*      LO_COLUMN->SET_OUTPUT_LENGTH( 10 ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

*   change the properties of the columns seq_no
      TRY.
          lo_column = lo_cols->get_column( 'STATUS' ).
          lo_column->set_long_text( 'Status' ).
          lo_column->set_medium_text( 'Status' ).
          lo_column->set_short_text('Status').
*      LO_COLUMN->SET_OUTPUT_LENGTH( 10 ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.


      lo_layout = lr_alv->get_layout( ).
*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
      ls_key-report = sy-repid.
      lo_layout->set_key( ls_key ).
*   2. Remove Save layout the restriction.
*    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

*      CALL METHOD lr_alv->set_screen_status(
*        EXPORTING
*          report        = sy-repid
*          pfstatus      = 'PF_STAT'
*          set_functions = lr_alv->c_functions_all ).

    CATCH cx_salv_msg.    "
  ENDTRY .
  lr_alv->display( ).
ENDFORM.
