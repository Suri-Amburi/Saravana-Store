*&---------------------------------------------------------------------*
*& Include          ZSD_INVOICE_IDOC_U_P01
*&---------------------------------------------------------------------*


START-OF-SELECTION.
  PERFORM initialization.
  IF sy-batch EQ ' '.
    PERFORM get_data_xls TABLES gt_file  .
    IF p_bg = c_x.
      PERFORM load_data_app TABLES gt_file.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

*** Upload Data
  PERFORM upload_data TABLES gt_file[].
  PERFORM display_data.
