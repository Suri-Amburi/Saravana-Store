*&---------------------------------------------------------------------*
*&      Module  DISPLAY_VALUES  OUTPUT
*&---------------------------------------------------------------------*
*       Classification is called by an object transaction.
*       1. Open valuation subscreen at once and display data.
*       2. Dialog is suppressed: process first entry in allkssk.
*          (e.g. when called from CO modules )
*----------------------------------------------------------------------*
module enter_value_assign output.

  if g_cl_ta is initial.
*   if zeile = 0.
    loop at klastab where objek <> space.
      exit.
    endloop.
    if sy-subrc = 0.
      call function 'CTMS_DDB_HAS_CLASS'
           exceptions
                ddb_has_no_class = 1
                others           = 2.
      if sy-subrc > 0.
*       only when PBO is passed for first time !
        clear g_flag.
        perform auswahl using g_flag 1." line 1
        clear g_subrc.
*       perform auth_check_class_maint                         "1697240
*                    using   pm_clint                          "1697240
*                            pm_class                          "1697240
*                            tcd_stat                          "1697240
*                            'S'       " msg type              "1697240
*                   changing g_subrc.                          "1697240
        if g_subrc is initial.
          perform classify.
        endif.
      endif.
    endif.
  endif.

endmodule.                             " ENTER_VALUE_ASSIGN  OUTPUT
