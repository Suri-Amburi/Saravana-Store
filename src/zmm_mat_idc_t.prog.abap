*&---------------------------------------------------------------------*
*& Report ZMM_MAT_IDC_T
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_MAT_IDC_T NO STANDARD PAGE HEADING.


INCLUDE ZMM_MAT_IDC_T_TOP.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_FILE TYPE STRING."rlgrap-filename.
SELECTION-SCREEN END OF BLOCK B1.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
perform get_filename changing p_file.
start-of-selection.
perform get_data changing ta_flatfile.
perform upload_service.
end-of-selection.
perform display_data.

INCLUDE ZMM_MAT_IDC_T_form.
