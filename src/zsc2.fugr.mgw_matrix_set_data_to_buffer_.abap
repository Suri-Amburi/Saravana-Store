FUNCTION MGW_MATRIX_SET_DATA_TO_BUFFER_.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FIELD) LIKE  T130F-FNAME OPTIONAL
*"     REFERENCE(I_DYNNR) LIKE  SY-DYNNR OPTIONAL
*"     REFERENCE(I_REPID) LIKE  SY-REPID OPTIONAL
*"     REFERENCE(I_TABIX) LIKE  SY-TABIX OPTIONAL
*"--------------------------------------------------------------------
  check cursor_field_matrix is initial.

* Übernahme Cursordaten aus kundenspezifischen Programmen
  cursor_field_matrix = i_field.
  cursor_field_dynnr  = i_dynnr.
  cursor_field_repid  = i_repid.
  cursor_field_line   = i_tabix.

ENDFUNCTION.
