*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_MAIN  OUTPUT
*&---------------------------------------------------------------------*
*       modify main screen with selection fields/icons
*----------------------------------------------------------------------*
module modify_screen_main output.

  loop at screen.

    if screen-group2 = 'SEL'.
      if g_sel_changed = space.
*      selection fields gray when inside trx
        screen-input  = '0'.
        screen-output = '1'.
        modify screen.
      endif.
    endif.
    if screen-group2 = 'DIS'  and
       ( classif_status = c_display or classif_status = space ).
*     some icons gray
      screen-input = '0'.
      modify screen.
    endif.

*   CALL BADI BADI_RETAIL_GENERIC_ART_CLASSF
*   This internal single implementation BADI is only relevant in case of a retail generic article
*   The retail specific implementaion is located in S4CORE
    try.
        get badi gr_ret_gen_art_badi.

        if gr_ret_gen_art_badi is bound.
*         Method PREVENT_ADD_ASSGMT prevents the assignment of add. classes to a generic article
          call badi gr_ret_gen_art_badi->prevent_add_assgmt
            exporting
              is_rmclf  = rmclf
            changing
              cs_screen = screen.
        endif.

      catch cx_badi_not_implemented
            cx_badi_multiply_implemented
            cx_sy_dyn_call_illegal_method
            cx_badi_unknown_error.
    endtry.

*-- ICON dark if no multiple classification (e.g. batch)
    if screen-name = 'ICON_NEWALLOC' and
       tcla-mfkls is initial and
       g_zuord    <> c_zuord_4.
      screen-input = '0'.
      modify screen.
    endif.

    if screen-name = 'ICON_SELECTOBJ'.
      if g_zuord = c_zuord_2.
        screen-invisible = '1'.
        modify screen.
      elseif g_zuord = c_zuord_4.
        if g_cls_scr <> space  or
           g_obj_scr <> space.
          screen-input  = '0'.
          screen-output = '1'.
          modify screen.
        endif.
      endif.
    endif.

    if screen-name = 'G_ICON_SIZEADJ'.
      if g_alloc_dynlg = space.
*       short form
        call function 'ICON_CREATE'
          exporting
            name                  = 'ICON_EXPAND'
          importing
            result                = g_icon_sizeadj
          exceptions
            icon_not_found        = 1
            outputfield_too_short = 2
            others                = 3.
      else.
*       long form
        call function 'ICON_CREATE'
          exporting
            name                  = 'ICON_COLLAPSE'
          importing
            result                = g_icon_sizeadj
          exceptions
            icon_not_found        = 1
            outputfield_too_short = 2
            others                = 3.
      endif.
    endif.

  endloop.

endmodule.                             " MODIFY_SCREEN_MAIN  OUTPUT
