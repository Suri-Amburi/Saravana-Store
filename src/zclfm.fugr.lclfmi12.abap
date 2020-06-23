*       Set cl_status set now for button <Return>
*       (means loading allocations in change mode).
*       Else cl_status is set in ok_code-exit.
*----------------------------------------------------------------------*
module check_change_sel input.

  g_sel_changed = kreuz.

endmodule.                             " CHECK_CHANGE_SEL  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_auth  INPUT
*&---------------------------------------------------------------------*
module check_auth input.

  check g_sel_changed <> space.

  if okcode = space.
    perform auth_check_change_mode.
  endif.

endmodule.                 " check_auth  INPUT
