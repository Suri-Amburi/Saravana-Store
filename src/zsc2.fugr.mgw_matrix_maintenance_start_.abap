function MGW_MATRIX_MAINTENANCE_START_.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
* The following call function is only available in
* a retail addon system .
  data: addon_fb4 like rs38l-name.


  if rmmw1-attyp <> attyp_samm or
     rmmw1-varnr <> space      or
     rmmw2-only_var = x.
    message s256(00).
  else.
*   Existens der Matrix prüfen
    addon_fb4 = 'MGW_CALL_MATRIX_MAINTENANCE'.
    call function 'FUNCTION_EXISTS'
      exporting
        funcname           = addon_fb4
      exceptions
        function_not_exist = 1
        others             = 2.
    if sy-subrc = 0.
*     Matrix aufrufen
      call function addon_fb4
        exporting
          i_fname   = cursor_field_matrix
          i_line    = cursor_field_line
          i_dynnr   = cursor_field_dynnr
          i_repid   = cursor_field_repid
          i_neuflag = neuflag
          i_aktyp   = t130m-aktyp.
    else.
      message s256(00).
    endif.
  endif.

  clear: cursor_field_matrix, cursor_field_line,
         cursor_field_dynnr,  cursor_field_repid.

endfunction.
