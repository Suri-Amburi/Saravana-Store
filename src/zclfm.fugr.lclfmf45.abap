*&---------------------------------------------------------------------*
*&      Form  SET_TCODE_TYPE
*&---------------------------------------------------------------------*
*       Determines type of transaction
*       g_cl_ta: - transaction in class system (cl*)
*                - call CLFM_OBJECT_CLSSSIF from object transaction
*       g_46_ta: old/new transactions >= Rel. 4.6
*----------------------------------------------------------------------*
form set_tcode_type.

  check g_cl_ta is initial.            " already passed ?

  if sy-calld = kreuz.
*   call transaction ... skip first screen
    clear g_flag.
    get parameter id c_param_acty field g_flag.
    set parameter id c_param_acty field space.
  endif.

  if not sy-binpt is initial.
*   select include screen
    call function 'CLTB_GET_FUNCTIONS'
      exporting
        i_obtab           = space                " correct in BI !
      importing
        e_function_import = tclfm-fbs_import
        e_function_export = tclfm-fbs_export
        e_function_pool   = tclfm-repid
      exceptions
        not_found         = 1
        others            = 2.
    pm_header-report = tclfm-repid.
    g_prog_object    = tclfm-repid.
  endif.

  case sy-tcode.

*-- allocations: object to classes
    when tcode_1obj.
      g_zuord       = c_zuord_0.
      g_cl_ta       = kreuz.
      g_46_ta       = kreuz.
      cl_status     = c_display.
      g_sel_changed = kreuz.
      g_alloc_dynnr = dynp1500.        " dynpro class list
      g_alloc_dynlg = kreuz.
      perform setup_table_expfstatus1 using cl_status.
      if g_flag = c_display.
        okcode = ok_clfm_display.
      endif.

*-- allocations: class to classes
    when tcode_1cls.
      g_zuord       = c_zuord_2.
      g_cl_ta       = kreuz.
      g_46_ta       = kreuz.
      cl_status     = c_display.
      g_sel_changed = kreuz.           " passed only once
      g_alloc_dynnr = dynp1500.        " dynpro class list
      g_alloc_dynlg = kreuz.
      if g_flag = c_display.
        okcode = ok_clfm_display.
      endif.

*-- allocations: objects of a class
    when tcode_nobj or 'CL64'.
      g_zuord       = c_zuord_4.
      g_cl_ta       = kreuz.
      g_46_ta       = kreuz.
      cl_status     = c_display.
      g_sel_changed = kreuz.           " passed only once
      g_alloc_dynnr = dynp1511.        " overview dynpro
      g_alloc_dynlg = kreuz.
      if g_flag = c_display.
        okcode = ok_all_disp.
      endif.

*+++++++ old +++++++++++++++++++++++++++++++++++++++++++++++++

    when tcodecl20.
      g_zuord     = c_zuord_0.
      g_cl_ta     = kreuz.
      g_46_ta     = space.
      cl_status   = c_change.

    when tcodecl21.
      g_zuord     = c_zuord_0.
      g_cl_ta     = kreuz.
      g_46_ta     = space.
      cl_status   = c_display.

*-- allocations: class to classes
    when tcodecl22.
      g_zuord    = c_zuord_2.
      g_cl_ta    = kreuz.
      g_46_ta    = space.
      cl_status  = c_change.

    when tcodecl23.
      g_zuord    = c_zuord_2.
      g_cl_ta    = kreuz.
      g_46_ta    = space.
      cl_status  = c_display.

    when tcodecl24.
      g_zuord    = c_zuord_4.
      g_cl_ta    = kreuz.
      g_46_ta    = space.
      cl_status  = c_change.

    when tcodecl25.
      g_zuord    = c_zuord_4.
      g_cl_ta    = kreuz.
      g_46_ta    = space.
      cl_status  = c_display.

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    when others.
*     object transactions
      g_zuord       = space.
      cl_status     = c_display.
      g_46_ta       = kreuz.
      g_main_dynnr  = 0.
      g_alloc_dynnr = dynp1600.
      g_alloc_dynlg = space.

  endcase.

  g_value_dynnr = c_dynnr_ctms.

  if sy-tcode(2) = 'CU'.
    g_appl = konst_c.
  endif.

* batch input: use old dynpros from rel. < 4.6
* if not sy-binpt is initial.                     "1057796
  if not sy-binpt is initial and                  "1057796
     not classif_status = '3'.                    "1057796
    g_46_ta = space.
  endif.

endform.                               " SET_TCODE_TYPE
