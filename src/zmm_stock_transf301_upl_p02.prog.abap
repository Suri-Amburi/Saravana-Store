*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
***  IF sy-batch = space.
  PERFORM get_data CHANGING gt_file.
  CHECK gt_file IS NOT INITIAL.
  PERFORM stock_transf USING gt_file CHANGING gt_msg.
  CHECK gt_msg IS NOT INITIAL.
  PERFORM display_data USING gt_msg .
***  ENDIF.
