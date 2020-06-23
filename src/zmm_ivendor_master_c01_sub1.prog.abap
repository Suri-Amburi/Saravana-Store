*&---------------------------------------------------------------------*
*& Include          ZMM_IVENDOR_MASTER_C01_SUB
*&---------------------------------------------------------------------*
  PERFORM get_data CHANGING ta_flatfile.
  PERFORM upload_vendor.
*  PERFORM upload_vendor1.
  PERFORM display_data.
