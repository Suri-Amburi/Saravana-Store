*&---------------------------------------------------------------------*
*& Include          SAPMZGRPO_EVE
*&---------------------------------------------------------------------*

  CLASS cl_event_skn DEFINITION DEFERRED.

  DATA: g_verifier TYPE REF TO cl_event_skn.

  CLASS cl_event_skn DEFINITION.

    PUBLIC SECTION.
      DATA: error_in_data TYPE c.
      METHODS: toolbar  FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive.
      METHODS: toolbar1  FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive.
      METHODS: user_command FOR EVENT after_user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
      METHODS: update FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed.
  ENDCLASS.

CLASS cl_event_skn IMPLEMENTATION.

    METHOD toolbar.
      DATA: mt_toolbar TYPE stb_button.
      CLEAR mt_toolbar.
      mt_toolbar-butn_type = 0.
      mt_toolbar-function  = 'BT_DISP'.
      mt_toolbar-text      = 'DISPLAY'.
      mt_toolbar-quickinfo = 'DISPLAY'.
      APPEND mt_toolbar TO e_object->mt_toolbar.
    ENDMETHOD.

    METHOD toolbar1.
      DATA: mt_toolbar1 TYPE stb_button.
      CLEAR mt_toolbar1.
      mt_toolbar1-butn_type = 0.
      mt_toolbar1-function  = 'BT_POST'.
      mt_toolbar1-text      = 'POST'.
      mt_toolbar1-quickinfo = 'POST'.
      APPEND mt_toolbar1 TO e_object->mt_toolbar.
    ENDMETHOD.

    METHOD user_command.
      CASE e_ucomm.
        WHEN 'BT_DISP'.
            PERFORM display.
*        WHEN 'BT_POST'.
*            PERFORM post.
        WHEN OTHERS.
      ENDCASE.
    ENDMETHOD.

  METHOD update.

 DATA: lv_stlnr TYPE stpo-stlnr,
       lv_menge TYPE menge_d,
       lv_rqty  TYPE menge_d,
       lv_oqty  TYPE menge_d,
       lv_sum  TYPE menge_d,
       lv_sum1  TYPE menge_d.


  LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<good>).
   CASE <good>-fieldname.
   WHEN 'MENGE'.
    CALL METHOD er_data_changed->get_cell_value
      EXPORTING
        i_row_id    =  <good>-row_id
        i_fieldname =  'MENGE'
      IMPORTING
        e_value     =  lv_menge.

    CALL METHOD er_data_changed->get_cell_value
      EXPORTING
        i_row_id    =  <good>-row_id
        i_fieldname =  'STLNR'
      IMPORTING
        e_value     =  lv_stlnr.

      READ TABLE gt_stpo ASSIGNING FIELD-SYMBOL(<st>) WITH KEY stlnr = lv_stlnr.
       IF sy-subrc = 0 .
         lv_rqty = lv_menge * <st>-menge.   "" container 2 required qtty
       ENDIF.

***         CALL METHOD er_data_changed->modify_cell
***           EXPORTING
***             i_row_id    =     <good>-row_id
***             i_fieldname =     'RMENGE'
***             i_value     =     lv_rqty.


      READ TABLE gt_item1 ASSIGNING FIELD-SYMBOL(<it>) WITH KEY matnr = <st>-idnrk.
       IF sy-subrc = 0 .
      CLEAR : lv_sum.
***************************************************************
      LOOP AT gt_item2 ASSIGNING FIELD-SYMBOL(<it1>) . "WHERE RMENGE IS NOT INITIAL.
       IF sy-tabix = <good>-row_id.
        lv_sum  =  lv_rqty + lv_sum .
       ELSE.
        lv_sum  = lv_sum + <it1>-rmenge .
       ENDIF.
      ENDLOOP.

         <it>-omenge =   <it>-menge - lv_sum .
         <it>-cmenge =   <it>-menge - <it>-omenge.
        IF  <it>-omenge < '0' .
*         <it>-cmenge =  <it>-cmenge - lv_rqty.
*         <it>-omenge = <it>-omenge  + lv_rqty.
           CALL METHOD er_data_changed->add_protocol_entry
                 EXPORTING
                     i_msgid = '0K' i_msgno = '000' i_msgty = 'E'
                     i_msgv1 = 'Exceeding Quantity'
                     i_fieldname = 'MENGE'
                     i_row_id = <good>-row_id.
                    error_in_data = 'X'.
       ELSE.
                      CALL METHOD er_data_changed->modify_cell
           EXPORTING
             i_row_id    =     <good>-row_id
             i_fieldname =     'RMENGE'
             i_value     =     lv_rqty.
       ENDIF.
     ENDIF.

  READ TABLE gt_item3 ASSIGNING FIELD-SYMBOL(<it3>) WITH KEY stlnr = lv_stlnr .
    IF sy-subrc = 0.
      <it3>-menge  = lv_menge.
      <it3>-rmenge = lv_rqty.
   ENDIF.

       CLEAR : lv_rqty,lv_menge,lv_sum.
     CALL METHOD grid1->refresh_table_display.
   ENDCASE.
 ENDLOOP.

  ENDMETHOD.

  ENDCLASS.

****************************************************************************
*         <it>-cmenge =  <it>-cmenge + lv_rqty.
*         <it>-omenge =  <it>-cmenge - lv_rqty.
**************************************************************************
