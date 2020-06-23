*&---------------------------------------------------------------------*
*& Include          ZPP_BOM_CREATION_UPLOAD_ROUT
*&---------------------------------------------------------------------*

IF sy-batch = ' '.
  PERFORM get_data CHANGING git_file.
ENDIF.

PERFORM process_data USING git_file.
PERFORM field_catlog.
PERFORM display_output.
