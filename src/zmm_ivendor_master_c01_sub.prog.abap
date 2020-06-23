*&---------------------------------------------------------------------*
*& Include          ZMM_IVENDOR_MASTER_C01_SUB
*&---------------------------------------------------------------------*
  PERFORM get_data CHANGING ta_flatfile.
  PERFORM upload_vendor.
  PERFORM display_data.
