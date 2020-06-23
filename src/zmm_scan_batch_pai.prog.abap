*&---------------------------------------------------------------------*
*& Include          ZMM_SCAN_BATCH_PAI
*&---------------------------------------------------------------------*

MODULE user_command_9000 INPUT.
  DATA(ok_code) = ok_9000.
  CLEAR :  ok_9000.
  CASE ok_code.
    WHEN c_save.
      PERFORM save_data.
    WHEN c_back OR c_cancel.
      LEAVE TO SCREEN 0.
    WHEN c_exit.
      LEAVE PROGRAM.
    WHEN c_enter OR c_space.
      PERFORM scan_batch.
  ENDCASE.
ENDMODULE.
