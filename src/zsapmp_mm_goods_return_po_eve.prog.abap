*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_EVE
*&---------------------------------------------------------------------*

  CLASS cl_event_skn DEFINITION DEFERRED.

  DATA: g_verifier TYPE REF TO cl_event_skn.

CLASS cl_event_skn DEFINITION.


    PUBLIC SECTION.
      DATA: error_in_data TYPE c.
      METHODS: update FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed.

ENDCLASS.

CLASS cl_event_skn IMPLEMENTATION.

 METHOD update.

DATA: lv_dvalue TYPE verpr,
      lv_disc   TYPE verpr,
      lv_value  TYPE verpr,
      lv_charg1 TYPE char20.

 LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<good>).
   CASE <good>-fieldname.
   WHEN 'DISC'.

    CALL METHOD er_data_changed->get_cell_value
      EXPORTING
        i_row_id    =  <good>-row_id
        i_fieldname =  'DISC'
      IMPORTING
        e_value     =  lv_disc.

*     CALL METHOD er_data_changed->get_cell_value
*      EXPORTING
*        i_row_id    =  <good>-row_id
*        i_fieldname =  'DVALUE'
*      IMPORTING
*        e_value     =  lv_dvalue.

     CALL METHOD er_data_changed->get_cell_value
      EXPORTING
        i_row_id    =  <good>-row_id
        i_fieldname =  'CHARG1'
      IMPORTING
        e_value     =  lv_charg1.

      READ TABLE it_final INTO DATA(wa_fin) WITH KEY  charg1 = lv_charg1.
       IF sy-subrc = 0.
        lv_dvalue = wa_fin-value.
       ENDIF.

      IF lv_dvalue IS NOT INITIAL . " AND lv_disc IS NOT INITIAL.

        lv_value = lv_dvalue - ( lv_dvalue * lv_disc ) / 100.

        CALL METHOD er_data_changed->modify_cell
           EXPORTING
             i_row_id    =     <good>-row_id
             i_fieldname =     'DVALUE'
             i_value     =     lv_value.
     ENDIF.

 ENDCASE.
ENDLOOP.
ENDMETHOD.

ENDCLASS.
