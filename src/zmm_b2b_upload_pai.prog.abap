*&---------------------------------------------------------------------*
*& Include          ZMM_B2B_UPLOAD_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA(ok_code) = ok_100.
  CASE ok_code.
    WHEN c_enter OR space.
      IF gv_batch IS NOT INITIAL.



        SELECT SINGLE s4_batch FROM zb1_s4_map INTO gv_batch1 WHERE b1_batch = gv_batch AND plant = gv_werks.
         IF sy-subrc = 0.
           CLEAR gv_batch.
           gv_batch = gv_batch1.
         ENDIF.

            SELECT SINGLE charg FROM mchb INTO @DATA(gv_batch2) WHERE charg = @gv_batch AND werks = @gv_werks .
*            IF sy-subrc NE 0.
             IF gv_batch2 IS INITIAL.
              MESSAGE 'Invalid Batch' TYPE 'E'.
              EXIT.
            ENDIF.

**        APPEND VALUE #( batch = gv_batch old_price = '' new_price = '' ) TO gt_data.
        PERFORM display_data.
        CLEAR gv_batch.
      ENDIF.
    WHEN c_exit.
      PERFORM exit_program.
    WHEN c_back OR c_cancel.
      LEAVE TO SCREEN 0.
    WHEN c_save.
*** Calling the check_changed_data method to trigger the data_changed  event
      DATA : wl_refresh TYPE c VALUE 'X'.
      CALL METHOD grid->check_changed_data
        CHANGING
          c_refresh = wl_refresh.
      PERFORM save_data.
    WHEN c_print.
      BREAK ppadhy.
      DATA(p_tp3) = 'X'.
      PERFORM print USING gv_mblnr p_tp3 gv_mjahr.

  ENDCASE.
  CLEAR ok_100.
ENDMODULE.
*---------------------------------------------------------------------*
*       FORM EXIT_PROGRAM                                             *
*---------------------------------------------------------------------*
FORM exit_program .
  IF custom_container IS NOT INITIAL.
    CALL METHOD custom_container->free.
    CALL METHOD cl_gui_cfw=>flush.
    IF sy-subrc NE 0.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = g_repid
          txt2  = sy-subrc
          txt1  = 'Error in Flush'(009).
    ENDIF.
  ENDIF.
  LEAVE PROGRAM.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_help INPUT.
  PERFORM get_filename  CHANGING p_file.
  PERFORM process_data.
  PERFORM prepare_fcat.
  PERFORM display_data.
ENDMODULE.
