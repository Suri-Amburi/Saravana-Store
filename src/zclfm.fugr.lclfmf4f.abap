*&---------------------------------------------------------------------*
*&      Form  OK_CODE_EXIT
*&---------------------------------------------------------------------*
*       Process ok-codes with exit attribut.
*       Necessity to exit here:
*       Object is changed, but does not exist: error msg in CBCM.
*       The only possibility to detect exit commands is a
*       module at exit-command, because the flag g_sel_changed
*       can only be be set later in CBCM !
*       (no 'field ... on request' possible, different input fields !)
*
*    Buttons Display or change:
*    Necessary to process here because of flag g_sel_changed.
*    If they are pressed set g_sel_changed,
*    so that check will be performed whether data are to be saved.
*----------------------------------------------------------------------*
form ok_code_exit.

  data: l_okcode2  like okcode.

  case okcode.

    when okabbr  or
         oknezu  or
         okobwe  or
         ok_cls_stack.

      g_ok_exit = kreuz.
      perform ok_code
              using    okcode
              changing l_okcode2.

    when ok_clfm_change  or
         ok_clfm_display or
         ok_all_chng     or
         ok_all_disp.

      read table allkssk index 1.
      if sy-subrc = 0.
        if classif_status = c_display.
*         1. mode changed: display -> change
        else.
*         2. mode changed: change  -> display
*         save data of old object if necessary
*         okcode = oknezu.
*         perform ok_code
*                 using    okcode
*                 changing sokcode.
*         g_sel_changed = kreuz.
        endif.
      else.
*       3. new transaction started
        g_sel_changed = kreuz.
      endif.

      if okcode = ok_clfm_change or
         okcode = ok_all_chng.
        cl_status = c_change.
      else.
        cl_status = c_display.
      endif.

  endcase.

endform.                               " OK_CODE_EXIT
