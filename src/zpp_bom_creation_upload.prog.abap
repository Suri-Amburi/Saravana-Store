*&---------------------------------------------------------------------*
*& Report ZPP_BOM_CREATION_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPP_BOM_CREATION_UPLOAD.


INCLUDE zpp_bom_creation_upload_top.
INCLUDE zpp_bom_creation_upload_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

AT SELECTION-SCREEN ON p_file.
  PERFORM check_file_path.

AT SELECTION-SCREEN.
  PERFORM set_background_job.

START-OF-SELECTION.
  IF pv_bg = 'X'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  INCLUDE zpp_bom_creation_upload_rout.
  INCLUDE zpp_bom_creation_upload_forms.
