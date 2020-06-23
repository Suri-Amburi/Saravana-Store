*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  IF sy-batch = space.
    PERFORM get_data CHANGING gt_file.
  ELSE.
    PERFORM background_job.
  ENDIF.
