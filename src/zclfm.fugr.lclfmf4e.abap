*&---------------------------------------------------------------------*
*&      Form  OK_CODE_MAIN
*&---------------------------------------------------------------------*
*       gets all ok codes of CLFM.
*----------------------------------------------------------------------*
form ok_code_main.

  data: l_okcode2  like okcode,
        l_okcode3  like okcode.


* 1. check change of object

  if g_sel_changed = space.

    clear g_ok_exit.

*   check double click: bend ok-code depending on field
    if okcode = okausw.
      get cursor field fname area g_tcname.

      if g_tcname = space.
*       double click in selection screen
        case fname.
          when c_fld_clasn.
            okcode = ok_obj_disp.
          when c_fld_aennr.
            okcode = okaedi.
        endcase.
      elseif g_tcname = c_char_subscreen.
*       double click in char subscreen
        okcode = ok_char_ausw.
      endif.

    elseif okcode = space.
*     object assignments(s) not processed in subscreen
      if sokcode = okeint.
        perform ok_eint.
      endif.
    endif.

  else.
    if okcode is initial.
*     new object, 'enter' pushed: cl_status=change as default.
      okcode = ok_clfm_change.
    endif.

  endif.

*-----------------------------------------------------------------
* 2. ok codes for allocations

  perform ok_code
          using    okcode
          changing l_okcode2.

* 3. ok codes for value assignment

  if l_okcode2 <> space.
    perform ok_code_values
            using    l_okcode2
            changing l_okcode3.
  endif.

  clear okcode.
* don't clear sokcode:  used in PBO part and
*               when reentering CLFM_OBJECT_CL. (object trans.)

endform.                               " OK_CODE_MAIN
