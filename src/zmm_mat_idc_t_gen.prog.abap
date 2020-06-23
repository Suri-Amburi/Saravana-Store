*&---------------------------------------------------------------------*
*& Report ZMM_MAT_IDC_T
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_MAT_IDC_T_GEN NO STANDARD PAGE HEADING.


INCLUDE ZMM_MAT_IDC_T_TOP.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_FILE TYPE STRING."rlgrap-filename.
PARAMETERS : P_RAD1 RADIOBUTTON GROUP RB1.
PARAMETERS : P_RAD2 RADIOBUTTON GROUP RB1.
*PARAMETERS : P_RAD3 RADIOBUTTON GROUP RB1.
SELECTION-SCREEN END OF BLOCK B1.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
perform get_filename changing p_file.
start-of-selection.
perform get_data changing ta_flatfile.
perform upload_service.
end-of-selection.
perform display_data.

INCLUDE ZMM_MAT_IDC_T_form.
