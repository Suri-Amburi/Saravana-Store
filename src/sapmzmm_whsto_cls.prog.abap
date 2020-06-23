*&---------------------------------------------------------------------*
*& Include          SAPMZMM_WHSTO_CLS
*&---------------------------------------------------------------------*
*Class definition for ALV toolbar
*CLASS: lcl_alv_toolbar DEFINITION DEFERRED.
*Declaration for toolbar buttons
*---------------------------------------------------------------------*
*       CLASS lcl_alv_toolbar DEFINITION
*---------------------------------------------------------------------*
*       ALV event handler
*---------------------------------------------------------------------*
CLASS slcl_alv_toolbar DEFINITION.
  PUBLIC SECTION.

    DATA : ty_toolbar TYPE stb_button.
*Constructor
    METHODS: constructor
      IMPORTING
        io_alv_grid TYPE REF TO cl_gui_alv_grid,
*Event for toolbar
      on_toolbar
      FOR EVENT toolbar
          OF  cl_gui_alv_grid
        IMPORTING
          e_object.
ENDCLASS.                    "lcl_alv_toolbar DEFINITION
*---------------------------------------------------------------------*
* Data declarations for ALV
DATA: c_alv_toolbar        TYPE REF TO slcl_alv_toolbar,           "Alv toolbar
      c_alv_toolbarmanager TYPE REF TO cl_alv_grid_toolbar_manager.  "Toolbar manager
*       CLASS lcl_alv_toolbar IMPLEMENTATION
*---------------------------------------------------------------------*
*       ALV event handler
*---------------------------------------------------------------------*
*FORM clv_alv_toolbar.
CLASS slcl_alv_toolbar IMPLEMENTATION.
  METHOD constructor.
*CREATE alv toolbar manager instance
    CREATE OBJECT c_alv_toolbarmanager
      EXPORTING
        io_alv_grid = io_alv_grid.
  ENDMETHOD.                    "constructor
  METHOD on_toolbar.
    CALL METHOD c_alv_toolbarmanager->reorganize
      EXPORTING
        io_alv_toolbar = e_object.
  ENDMETHOD.                    "on_toolbar
ENDCLASS.                    "lcl_alv_toolbar IMPLEMENTATION


"added by sjena on 21.12.2018 17:37:11

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA: g_event_receiver TYPE REF TO lcl_event_receiver.

**************************************************************
* LOCAL CLASS Definition
**************************************************************
*�4.Define and implement event handler to handle event DATA_CHANGED.
*
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS: handle_data_changed
                FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed ,
*--Double click control
***      handle_double_click
***                  FOR EVENT double_click OF cl_gui_alv_grid
***      importing e_row ,
*--Hotspot click control
***      handle_hotspot_click
***                  FOR EVENT hotspot_click OF cl_gui_alv_grid
***        IMPORTING e_row_id e_column_id es_row_no ,
**-> User_command -> sjena <- 11.05.2019 12:21:43
      handle_user_command
                  FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm ,

      handle_on_f4

      FOR EVENT onf4 OF cl_gui_alv_grid

        IMPORTING e_fieldname

                  es_row_no

                  er_event_data.


*  fieldname:       fieldname of table for the corresponding column
*  (old/new value): ckeck with value of GT_OUTTAB or MT_GOOD_CELLS.
*  !        : the value is valid if the condition  holds.
*.......................................................................
***    TYPES: ddshretval_table TYPE TABLE OF ddshretval.
***    METHODS: my_f4 FOR EVENT onf4 OF cl_gui_alv_grid
***              IMPORTING et_bad_cells
***                        es_row_no
***                        er_event_data
***                        e_display
***                        e_fieldname      .

  PRIVATE SECTION.
* This flag is set if any error occured in one of the
* following methods:
    DATA: error_in_data TYPE c.

    DATA : error_data TYPE REF TO cl_alv_changed_data_protocol .
* Methods to modularize event handler method handle_data_changed:
*
    METHODS: check_menge
      IMPORTING
        entr_data  TYPE lvc_s_modi
        chngd_data TYPE REF TO cl_alv_changed_data_protocol.
*....................................................................
* This is a suggestion how you could comment your checks in each method:
*.....
* CHECK: fieldname(old/new value) ! fieldname(old/new value)
* IF NOT: (What to tell the user is wrong about the input)
*......
* Remarks:
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_data_changed.

    DATA: ls_good TYPE lvc_s_modi.
    DATA: ls_error TYPE lvc_s_modi.



    error_in_data = space.
*--> Check_for_mandatory_entries.  -> sjena <- 19.07.2019 15:53:10
    DATA : smsg TYPE string .


*--> Check_inserted_rows -> sjena <- 01.06.2019 19:44:56
    DELETE er_data_changed->mt_good_cells WHERE value IS INITIAL OR value = space .
    CHECK er_data_changed->mt_good_cells IS NOT INITIAL .
    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
      CASE ls_good-fieldname.
* check if column MENGE of this row was changed
        WHEN 'MENGE'.
          CALL METHOD check_menge
            EXPORTING
              entr_data  = ls_good
              chngd_data = er_data_changed.
      ENDCASE .
    ENDLOOP .

    IF error_in_data IS INITIAL.
***      PERFORM get_cell_details .
    ENDIF.

*�7.Display application log if an error has occured.
    IF error_in_data EQ 'X'.
      CALL METHOD er_data_changed->display_protocol.
    ENDIF.
  ENDMETHOD.

* --------------------------------------------------------------------
  METHOD check_menge.

*...................................................

    DATA: entrd_menge TYPE menge_d,
          entrd_nends TYPE lvc_s_modi.

*      DATA: ls_good TYPE lvc_s_modi.
    DATA : smsg TYPE string.
* Get new cell value to check it.
* (In this case: Generic Merge).

    CALL METHOD chngd_data->get_cell_value
      EXPORTING
        i_row_id    = entr_data-row_id
        i_fieldname = entr_data-fieldname
      IMPORTING
        e_value     = entrd_menge.
    IF entrd_menge IS  NOT INITIAL.
* existence check: Does the desgn exists?
*      PERFORM get_matdtls .

      READ TABLE xsto_itm INTO DATA(temp) INDEX entr_data-row_id.
      IF sy-subrc IS INITIAL.
* In case of error, create a protocol entry in the application log.
* Possible values for message type ('i_msgty'):
*
*    'A': Abort (Stop sign)
*    'E': Error (red LED)
*    'W': Warning (yellow LED)
*    'I': Information (green LED)
*
        temp-menge = entrd_menge.
        SELECT SINGLE clabs FROM mchb INTO @DATA(sclabs)
           WHERE matnr = @temp-matnr
          AND werks = @xsto_hdr-swerks
          AND lgort = 'FG01'.

        IF temp-menge > sclabs.
****          temp-icon = sred.
          smsg  = sclabs - temp-menge.

          CALL METHOD chngd_data->add_protocol_entry
            EXPORTING
              i_msgid     = '0K'
              i_msgno     = '000'
              i_msgty     = 'E'
              i_msgv1     = 'Qty Exceeded' "#EC NOTEXT     "MSG
              i_msgv2     = smsg
*             i_msgv3     = 'E' "exitstiert nicht
              i_fieldname = entr_data-fieldname
              i_row_id    = entr_data-row_id.

          error_in_data = abap_true.
          EXIT. "designed does not exit, so we're finished here!
        ELSE.
***          temp-icon = sgreen.
***          MODIFY xsto_itm FROM temp INDEX entr_data-row_id TRANSPORTING icon menge.
***          PERFORM scontainer .
        ENDIF.
      ELSE.
      ENDIF.
    ELSE.

    ENDIF.


* Check if other relevant fields of this row have been changed, too.
***    READ TABLE chngd_data->mt_good_cells INTO entrd_nends
***    WITH KEY row_id    = entr_data-row_id
***    fieldname = 'DESGN'.
***    IF sy-subrc IS INITIAL.
***
***    ENDIF.

  ENDMETHOD.                           " check_QTY
*------------------------------------------------------*

*--Handle User Command

  METHOD handle_user_command ..
***    CASE e_ucomm.
***      WHEN upack.
***      WHEN dele.
***      WHEN OTHERS.
***    ENDCASE.

  ENDMETHOD .

  METHOD handle_on_f4.

***    PERFORM handle_on_f4
***
***      USING e_fieldname
***
***            es_row_no
***
***            er_event_data.

  ENDMETHOD.


ENDCLASS.
************************************************************
