*&---------------------------------------------------------------------*
*& Include          SAPMZ_LOCAL_PURCH_GR_T01
*&---------------------------------------------------------------------*
TYPE-POOLS : slis .
TYPES: BEGIN OF ty_item,
         mandt    TYPE zinw_t_item-mandt,
         qr_code  TYPE zinw_t_item-qr_code,
         ebeln    TYPE zinw_t_item-ebeln,
         ebelp    TYPE zinw_t_item-ebelp,
         matnr    TYPE zinw_t_item-matnr,
         lgort    TYPE zinw_t_item-lgort,
         werks    TYPE zinw_t_item-werks,
         maktx    TYPE zinw_t_item-maktx,
         matkl    TYPE zinw_t_item-matkl,
         menge    TYPE zinw_t_item-menge,
         menge_p  TYPE zinw_t_item-menge_p,
         meins    TYPE zinw_t_item-meins,
         open_qty TYPE zinw_t_item-open_qty,
         netpr_p  TYPE zinw_t_item-netpr_p,
         steuc    TYPE zinw_t_item-steuc,
         netpr_gp TYPE zinw_t_item-netpr_gp,
         netwr_p  TYPE zinw_t_item-netwr_p,
         margn    TYPE zinw_t_item-margn,
         menge_s  TYPE zinw_t_item-menge_s,
         netpr_s  TYPE zinw_t_item-netpr_s,
*         MWSKZ_S  TYPE ZINW_T_ITEM-MWSKZ_S,
         netpr_gs TYPE zinw_t_item-netpr_gs,
         netwr_s  TYPE zinw_t_item-netwr_s,
         mat_cat  TYPE zinw_t_item-mat_cat,
         act_qty  TYPE zinw_t_item-menge_s,
         charg    TYPE charg_d,
         bwtar    TYPE bwtar_d,
         lfbnr    TYPE lfbnr,
         lfpos    TYPE lfpos,
         sjahr    TYPE mjahr,
       END OF ty_item.

DATA :
  gs_hdr    TYPE zinw_t_hdr,
  gt_item_t TYPE TABLE OF zinw_t_item,
  gt_item   TYPE TABLE OF ty_item,
  gs_item   TYPE ty_item,
  lv_budat  TYPE mkpf-budat.

FIELD-SYMBOLS :
  <gs_item_t> TYPE zinw_t_item,
  <gs_item>   TYPE ty_item.

DATA:
  container    TYPE REF TO cl_gui_custom_container,
  grid         TYPE REF TO cl_gui_alv_grid,
  gt_exclude   TYPE ui_functions,
  gs_layo      TYPE lvc_s_layo,
  gt_fieldcat  TYPE lvc_t_fcat,
  ok_9000      TYPE sy-ucomm,
  gv_qr        TYPE zqr_code,
  gv_mblnr_103 TYPE mblnr,
  gv_subrc     TYPE sy-subrc,
  gv_mode(1)   VALUE 'E'.

CONSTANTS :
  c_save(4)      VALUE 'SAVE',
  c_back         TYPE syucomm    VALUE 'BACK',
  c_exit         TYPE syucomm    VALUE 'EXIT',
  c_cancel       TYPE syucomm  VALUE 'CANCEL',
  c_refresh      TYPE syucomm VALUE 'REF',
  c_zlop(4)      VALUE 'ZLOP',
  c_108(3)       VALUE '108',
  c_109(3)       VALUE '109',
  c_x(1)         VALUE 'X',
  c_mvt_ind_b(1) VALUE 'B',
  c_mvt_01(2)    VALUE '01',
  c_c(2)         VALUE 'E',
  c_d(2)         VALUE 'D',
  c_qr_code(7)   VALUE 'QR_CODE',
  c_04(4)        VALUE '04',
  c_qr04(4)      VALUE 'QR04',
  c_soe(4)       VALUE 'SOE',
  c_se01(4)      VALUE 'SE01',
  c_01(4)        VALUE '01'.

*** Event Class
CLASS event_class DEFINITION DEFERRED.
DATA: gr_event TYPE REF TO event_class.

*** Event Handeler Class
CLASS event_class DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_data_changed
                FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.
ENDCLASS.

*** Class Implemntation
CLASS event_class IMPLEMENTATION.
  METHOD handle_data_changed.
    DATA : error_in_data(1).
    LOOP AT er_data_changed->mt_mod_cells ASSIGNING FIELD-SYMBOL(<x_mod_cells>).
      READ TABLE gt_item ASSIGNING <gs_item> INDEX <x_mod_cells>-row_id.
      IF sy-subrc = 0.
        REPLACE ALL OCCURRENCES OF ',' IN <x_mod_cells>-value WITH ''.
        IF <gs_item>-menge_p < <x_mod_cells>-value.
          CALL METHOD er_data_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'ZMSG_CLS'
              i_msgty     = 'E'
              i_msgno     = '004'
              i_fieldname = <x_mod_cells>-fieldname
              i_row_id    = <x_mod_cells>-row_id.
          error_in_data = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
*** Refreshing Table Data
    IF grid IS BOUND.
      DATA: is_stable TYPE lvc_s_stbl, lv_lines TYPE int2.
      is_stable = 'XX'.
      IF grid IS BOUND.
        CALL METHOD grid->refresh_table_display
          EXPORTING
            is_stable = is_stable               " With Stable Rows/Columns
          EXCEPTIONS
            finished  = 1                       " Display was Ended (by Export)
            OTHERS    = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.

*** Display Errors
    IF error_in_data IS NOT INITIAL .
      CALL METHOD er_data_changed->display_protocol( ).
    ELSE.
*** Refreshing Main Screen
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = c_refresh.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
