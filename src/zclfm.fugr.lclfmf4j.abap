*&---------------------------------------------------------------------*
*&      Form  ok_WECH
*&---------------------------------------------------------------------*
*       Called from object transaction: class type is to be changed.
*----------------------------------------------------------------------*
form ok_wech.

  data: l_subrc type sy-subrc.

* first save previous value assignment
  perform close_prev_value_assmnt changing l_subrc.

  perform save_all changing l_subrc.
  if l_subrc = 0.
    if g_cl_ta is initial.
      call function 'CTMS_DDB_INIT'.
      set screen dy000.
      leave screen.
    endif.
  endif.

endform.                               " ok_WECH
