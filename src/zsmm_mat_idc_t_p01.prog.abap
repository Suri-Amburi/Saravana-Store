*&---------------------------------------------------------------------*
*& Include          ZSMM_MAT_IDC_T_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  IF P_BG = 'X'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  IF SY-BATCH = ' '.
    PERFORM GET_DATA CHANGING TA_FLATFILE.
  ENDIF.
  PERFORM UPLOAD_SERVICE.

END-OF-SELECTION.
  PERFORM DISPLAY_DATA.
