*&---------------------------------------------------------------------*
*& Include          SAPMZ_FV_PROCESS_T01
*&---------------------------------------------------------------------*

*** Types
TYPES :
*** PO Header Details
  BEGIN OF ty_hdr,
    mblnr_b_101      TYPE mblnr,
    menge            TYPE menge_d,
    meins            TYPE meins,
    ebeln            TYPE ebeln,
    lifnr            TYPE lifnr,
    name1            TYPE name1_gp,
    lgort            TYPE lgort_d,
    werks            TYPE werks_d,
    mblnr_101        TYPE mblnr,
    mblnr_541        TYPE mblnr,
    mblnr_543        TYPE mblnr,
    cond_rec(1),
    print(1),
    packing_head(20),
  END OF ty_hdr,

*** PO item Details
  BEGIN OF ty_item,
    ebelp   TYPE ebelp,
    matnr   TYPE matnr,
    maktx   TYPE maktx,
*    menge   TYPE menge_d,
    menge   TYPE int4,
    meins   TYPE meins,
    netpr_s TYPE bprei,
  END OF ty_item,


*** GRPO item Details
  BEGIN OF ty_mseg,
    mblnr TYPE mblnr,
    ebelp TYPE ebelp,
    matnr TYPE matnr,
    maktx TYPE maktx,
    menge TYPE menge_d,
    meins TYPE meins,
  END OF ty_mseg.

*** Table Declerations
DATA :
  gt_item     TYPE STANDARD TABLE OF ty_item,
  gs_item     TYPE ty_item,
  gt_mseg     TYPE STANDARD TABLE OF ty_mseg,
  gs_hdr      TYPE ty_hdr,
  gt_exclude  TYPE ui_functions,
  gs_layo     TYPE lvc_s_layo,
  gt_fieldcat TYPE lvc_t_fcat,
  bdcdata     TYPE bdcdata    OCCURS 0 WITH HEADER LINE,
  messtab     TYPE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

*** Object References
DATA :
  gr_container TYPE REF TO cl_gui_custom_container,
  gr_grid      TYPE REF TO cl_gui_alv_grid.

*** Event Class
CLASS event_class DEFINITION DEFERRED.
DATA :
  gr_event TYPE REF TO event_class.

*** Data Declerations
DATA :
  ok_9001      TYPE sy-ucomm,
  ok_9100      TYPE sy-ucomm,
  gv_bsart     TYPE esart,
  gv_ebeln     TYPE ebeln,
  gv_subrc     TYPE sy-subrc,
  gv_mblnr_101 TYPE mblnr,
  gv_mblnr_541 TYPE mblnr.

*** Field Symbols
FIELD-SYMBOLS :
  <gs_item> TYPE ty_item.

CONSTANTS:
  c_back         TYPE sy-ucomm VALUE 'BACK',
  c_cancel       TYPE sy-ucomm VALUE 'CANCEL',
  c_exit         TYPE sy-ucomm VALUE 'EXIT',
  c_save         TYPE sy-ucomm VALUE 'SAVE',
  c_stock        TYPE sy-ucomm VALUE 'STOCK',
  c_clear        TYPE sy-ucomm VALUE 'CLEAR',
  c_x(1)         VALUE 'X',
  c_e(1)         VALUE 'E',
  c_s(1)         VALUE 'S',
  c_mvt_ind_b(1) VALUE 'B',
  c_mvt_01(2)    VALUE '01',
  c_mvt_06(2)    VALUE '06',
  c_101(3)       VALUE '101',
  c_541(3)       VALUE '541',
  c_543(3)       VALUE '543',
  c_zkp0(4)      VALUE 'ZKP0',
  c_zpro(4)      VALUE 'ZPRO'.

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
    DATA : is_stable   TYPE lvc_s_stbl, lv_lines TYPE int2,
           lv_field    TYPE lvc_fname,
           lv_error(1).
    LOOP AT er_data_changed->mt_mod_cells ASSIGNING FIELD-SYMBOL(<x_mod_cells>).
      READ TABLE gt_item ASSIGNING <gs_item> INDEX <x_mod_cells>-row_id.
      CHECK sy-subrc = 0.
***     Material Validation
      CLEAR : lv_field.
      CASE <x_mod_cells>-fieldname.
        WHEN 'MATNR'.
          SELECT SINGLE mara~meins, makt~maktx INTO ( @<gs_item>-meins, @<gs_item>-maktx )
            FROM mara AS mara INNER JOIN makt AS makt ON makt~matnr = mara~matnr
            WHERE mara~matnr = @<x_mod_cells>-value.
          IF sy-subrc <> 0.
            lv_field = 'MATNR'.
            CALL METHOD er_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZMSG_CLS'
                i_msgty     = 'E'
                i_msgno     = '085'
                i_fieldname = lv_field
                i_row_id    = <x_mod_cells>-row_id.
            CLEAR : <x_mod_cells>-value.
            lv_error = 'X'.
            EXIT.
          ELSE.
            <gs_item>-matnr = <x_mod_cells>-value.
          ENDIF.
        WHEN 'MENGE'.
          CHECK <gs_item>-matnr IS NOT INITIAL.
          <gs_item>-menge = <x_mod_cells>-value.
      ENDCASE.

*** Stock Validation
      IF <gs_item>-matnr IS NOT INITIAL AND <gs_item>-menge IS NOT INITIAL.
        SELECT SINGLE mard~matnr, mard~labst, mast~matnr AS po_matnr ,stpo~meins, stpo~menge INTO @DATA(ls_mard)
               FROM mard AS mard INNER JOIN stpo AS stpo ON stpo~idnrk = mard~matnr
               INNER JOIN mast AS mast ON mast~stlnr = stpo~stlnr
               WHERE  mast~matnr = @<gs_item>-matnr AND mard~labst > 0.
        IF sy-subrc = 0.
          IF ls_mard-labst GE <gs_item>-menge * ls_mard-menge.
***         For Additing Lines
            LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE matnr IS INITIAL.
              DATA(lv_add_item) = c_x.
            ENDLOOP.
            IF lv_add_item IS INITIAL.
              APPEND INITIAL LINE TO gt_item ASSIGNING <ls_item>.
            ENDIF.

            <ls_item>-meins = 'EA'.
            CALL METHOD gr_grid->refresh_table_display
              EXPORTING
                is_stable = is_stable        " With Stable Rows/Columns
              EXCEPTIONS
                finished  = 1                " Display was Ended (by Export)
                OTHERS    = 2.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ELSE.
            lv_field = 'MENGE'.
            CALL METHOD er_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZMSG_CLS'
                i_msgty     = 'E'
                i_msgno     = '086'
                i_fieldname = lv_field
                i_row_id    = <x_mod_cells>-row_id.
            CLEAR : <x_mod_cells>-value, <gs_item>-menge.
            lv_error = 'X'.
            EXIT.
          ENDIF.
        ELSE.
          lv_field = 'MENGE'.
          CALL METHOD er_data_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'ZMSG_CLS'
              i_msgty     = 'E'
              i_msgno     = '086'
              i_fieldname = lv_field
              i_row_id    = <x_mod_cells>-row_id.
          CLEAR : <x_mod_cells>-value, <gs_item>-menge.
          lv_error = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_error IS INITIAL.
*** Event is triggered when data is changed in the output
      is_stable = 'XX'.
*** Refreshing Data with Cusrsor Hold
      IF gr_grid IS BOUND.
        CALL METHOD gr_grid->refresh_table_display
          EXPORTING
            is_stable = is_stable        " With Stable Rows/Columns
          EXCEPTIONS
            finished  = 1                " Display was Ended (by Export)
            OTHERS    = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
