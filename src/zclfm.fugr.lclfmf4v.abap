*&---------------------------------------------------------------------*
*&      Form  ok_SAVE
*&---------------------------------------------------------------------*
*       Saves all changes.
*       Transaction will be restarted.
*----------------------------------------------------------------------*
form ok_save.

  data: l_subrc type sy-subrc.

* first save previous value assignment
  perform close_prev_value_assmnt changing l_subrc.

* set flag for user exit
  g_save_called = c_save.

  perform save_all changing l_subrc.
  clear g_save_called.

  if l_subrc = 0.
    if g_cl_ta is initial.
      set screen dy000.
      leave screen.
    else.
      export sokcode to MEMORY ID 'WWSCL24'.                   "2688521
      leave.                             " leave in call mode
      leave to transaction sy-tcode.     " leave in dialog mode
    endif.
  endif.

endform.                               " OK_SAVE
