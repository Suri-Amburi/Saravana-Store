*&---------------------------------------------------------------------*
*& Include          ZMM_IVENDOR_MASTERR_C01_SUB
*&---------------------------------------------------------------------*
 PERFORM GET_DATA CHANGING TA_FLATFILE.
  PERFORM UPLOAD_VENDOR.
  PERFORM DISPLAY_DATA.
