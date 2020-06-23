*&---------------------------------------------------------------------*
*& Include          ZMM_SCAN_BATCH_F01
*&---------------------------------------------------------------------*

FORM save_data.
  DATA : ls_batches TYPE zscan_batches.
  FIELD-SYMBOLS : <ls_batches> TYPE zscan_batches.
  IF gt_batches IS NOT INITIAL.
    LOOP AT gt_batches ASSIGNING <ls_batches>.
*** Get Next number for QR code from Number range
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZBATCH_SNO'
        IMPORTING
          number                  = <ls_batches>-sno
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDLOOP.
    MODIFY zscan_batches FROM TABLE gt_batches.
    MESSAGE 'Successfully Saved' TYPE 'S'.
    gv_mode = c_d.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCAN_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM scan_batch.
  CHECK gs_batches-scan_batch IS NOT INITIAL.
  gs_batches-createdby   = sy-uname.
  gs_batches-createdon   = sy-datum.
  gs_batches-createdtime = sy-uzeit.
  APPEND gs_batches TO gt_batches.
  MESSAGE 'Batch Scanned' TYPE 'S'.
ENDFORM.

FORM display_data.
  IF custom_container IS INITIAL .
    CREATE OBJECT custom_container
      EXPORTING
        container_name = mycontainer.
    CREATE OBJECT grid
      EXPORTING
        i_parent = custom_container.
  ENDIF.

*** Layout
  gs_layout-frontend = 'X'.
*** Batch
  IF gt_fieldcat IS INITIAL.
    APPEND VALUE #( fieldname = 'SCAN_BATCH' reptext = 'Batch' col_opt = 'X' outputlen = 20 ) TO gt_fieldcat.
  ENDIF.
*** Icons
  PERFORM exclude_icons.
  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_layout
      it_toolbar_excluding          = gt_tlbr_excl  " Excluded Toolbar Standard Functions
    CHANGING
      it_outtab                     = gt_batches
      it_fieldcatalog               = gt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM exclude_icons .

  CHECK gt_tlbr_excl IS INITIAL.
  gt_tlbr_excl = VALUE #( ( cl_gui_alv_grid=>mc_fc_loc_insert_row    )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste         )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy          )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy_row      )
                          ( cl_gui_alv_grid=>mc_fc_loc_cut           )
                          ( cl_gui_alv_grid=>mc_fc_loc_undo          )
                          ( cl_gui_alv_grid=>mc_fc_loc_append_row    )
                          ( cl_gui_alv_grid=>mc_fc_print             )
                         ).

ENDFORM.
