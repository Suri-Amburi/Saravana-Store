*&---------------------------------------------------------------------*
*& Include          ZMM_STOCK_TRANSF_T02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD_T01
*&---------------------------------------------------------------------*
TYPES  :BEGIN OF ty_file,
*--> Header Data -> sjena <- 13.02.2020 1:48:32 PM
          doc_date   TYPE zdoc_date,
          pstng_date TYPE zpos_date,
          gate_pass  TYPE char10,
*--> Item Data -> sjena <- 13.02.2020 1:49:29 PM
          matnr      TYPE  matnr,
          plant      TYPE werks_d,
          stge_loc   TYPE lgort_d,
          batch      TYPE  char40,  "charg_d,
          move_type  TYPE bwart,
          quantity   TYPE char20,
          uom        TYPE char5,
          move_plant TYPE umwrk,
          move_stloc TYPE umlgo,
*          move_batch TYPE umcha,
        END OF ty_file,

        st_file TYPE STANDARD TABLE OF ty_file.


*** File Structure
DATA:
  gt_file   TYPE TABLE OF ty_file,

  gt_file01 TYPE TABLE OF ty_file,
  gw_file01 TYPE ty_file,
  fname     TYPE localfile,
  ename     TYPE char4.


CONSTANTS :
  c_x(1) VALUE 'X',
  c_s(1) VALUE 'S',
  c_e(1) VALUE 'E'.

TYPES : BEGIN OF ty_msg,
          matnr     TYPE  matnr,
          plant     TYPE werks_d,
          stge_loc  TYPE  lgort_d,
          batch     TYPE charg_d,
          move_type TYPE  bwart,
          mblnr     TYPE mblnr,
          mjahr     TYPE mjahr,
          msg       TYPE zmsg,
        END OF ty_msg   ,
        st_msg TYPE STANDARD TABLE OF ty_msg.

DATA : gt_msg   TYPE TABLE OF ty_msg,
       gw_msg   TYPE ty_msg,
       gt_msg01 TYPE TABLE OF ty_msg.  "Message Log

*--> Output_alv_factory_data -> sjena <- 18.05.2019 20:23:11
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
