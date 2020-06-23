*&---------------------------------------------------------------------*
*& Include          ZMAT_UPLOAD_SUB
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN ON P_FILE.
  PERFORM CHECK_FILE_PATH.

  START-OF-SELECTION.
*BREAK NPATIL.
  PERFORM GET_DATA CHANGING IT_FILE.
  PERFORM mat_data .

  end-OF-SELECTION .

    PERFORM display .
