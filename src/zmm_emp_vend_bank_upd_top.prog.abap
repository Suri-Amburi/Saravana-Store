*&---------------------------------------------------------------------*
*& Include          ZMM_EMP_VEND_BANK_UPD_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : slis .

*--> Excel_template -> sjena <- 18.05.2019 19:58:06
TYPES: BEGIN OF ty_flatfile,
         lifnr(10) TYPE c,
         banks(3)  TYPE c,
         bankl(15) TYPE c,
         bankn(18) TYPE c,
       END OF ty_flatfile .

*--> Log_data_for_output -> sjena <- 18.05.2019 20:16:52
TYPES : BEGIN OF ty_log,
          sno     TYPE int4,
          lifnr   TYPE lifnr,
          message TYPE bapi_msg,
        END OF ty_log .

DATA : slogt TYPE TABLE OF ty_log WITH HEADER LINE .

DATA:fname TYPE localfile,
     ename TYPE char4.

DATA : sbusinesspartner TYPE bapibus1006_head-bpartner,
       sbankdetailid    TYPE bapibus1006_head-bankdetailid,
       sbankdetaildata  TYPE bapibus1006_bankdetail,
       sreturn          TYPE TABLE OF bapiret2 WITH HEADER LINE.

DATA : supl_data TYPE TABLE OF ty_flatfile WITH HEADER LINE.

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

*--> GUI_Declaration -> sjena <- 18.05.2019 20:59:07\\
DATA: curline(10), maxline(10),
      perc        TYPE i, text TYPE text100,
      lv_count    TYPE i,
      lv_count01  TYPE i.
