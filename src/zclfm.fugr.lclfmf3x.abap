*&---------------------------------------------------------------------*
*&      Form  APPL_EXIT_PRE
*&---------------------------------------------------------------------*
*       Process a system internal application exit to create
*       allocations when classification is called.
*       E.g.: Equipment with material as reference object.
*----------------------------------------------------------------------*
form appl_exit_pre
     using p_exit_active.

  data:
      lt_allkssk       like rmclkssk occurs 0 with header line,
      lt_allausp       like rmclausp occurs 0 with header line.


  clear p_exit_active.
  lt_allkssk[] = allkssk[].
  lt_allausp[] = allausp[].

  call function g_fbs_exit
       importing
            e_active  = p_exit_active
       tables
            t_allkssk = lt_allkssk
            t_allausp = lt_allausp.

  if not p_exit_active is initial.
*   take over user changes into allkssk, allausp
    perform merge_allkssk_allausp
           tables allkssk
                  lt_allkssk
                  allausp
                  lt_allausp.
*   status check
    loop at allkssk where statu =  cl_statusf
                      and vbkz  <> c_delete.
      sy-tmaxl = sy-tabix mod 20.
      if sy-tmaxl = 0.
        call function 'CTMS_CONFIGURATION_INITIALIZER'.
      endif.
      pm_objek  = allkssk-objek.
      pm_class  = allkssk-class.
      pm_inobj  = allkssk-cuobj.
      pm_status = allkssk-statu.
      mafid     = allkssk-mafid.
      sobtab    = allkssk-obtab.
      g_consistency_chk = kreuz.
      clear cl_status_neu.
      perform status_check using allkssk-klart.
      if not cl_status_neu is initial.
*       set status > 1
        allkssk-statu = cl_status_neu.
        modify allkssk.
      endif.
    endloop.
    kssk_update = kreuz.
    aenderflag  = kreuz.
    perform insert_classification on commit.
  endif.

  refresh lt_allkssk.
  refresh lt_allausp.

endform.

*&---------------------------------------------------------------------*
*&      Form  CUST_EXIT_CHARCHECK
*&---------------------------------------------------------------------*
*       Process a customer exit after the characteristics
*       have been checked.
*
*       Current allocation is now in allkssk header line.
*----------------------------------------------------------------------*
form cust_exit_charcheck
     using    p_from_api
              value(p_check_rc).

  data:
      l_exit_active      like sy-batch.


  check not g_exits_active is initial. " internal debug flag

  call customer-function '003'
       exporting
               i_allkssk   = allkssk
               i_check_rc  = p_check_rc
               i_from_api  = p_from_api
               i_appl      = g_appl
      importing
               e_active    = l_exit_active.

endform.                               " cust_exit_charcheck


*&---------------------------------------------------------------------*
*&      Form  CUST_EXIT_PRE
*&---------------------------------------------------------------------*
*       Process a customer-exit to create allocations
*       when classification is called.
*       E.g. set default values.
*----------------------------------------------------------------------*
form cust_exit_pre
     using p_exit_active.

  data:
      lt_allkssk       like rmclkssk occurs 0 with header line,
      lt_allausp       like rmclausp occurs 0 with header line.


  check not g_exits_active is initial. " internal debug flag

  clear p_exit_active.
  lt_allkssk[] = allkssk[].
  lt_allausp[] = allausp[].

  call customer-function '001'
       exporting
               i_table    = sobtab
               i_rmclf    = rmclf
               i_cuobj    = pm_inobj
               i_appl     = g_appl
       importing
               e_active   = p_exit_active
       tables
               t_allkssk  = lt_allkssk
               t_allausp  = lt_allausp.

  if not p_exit_active is initial.
*   take over user changes into allkssk, allausp
    perform merge_allkssk_allausp
            tables allkssk
                   lt_allkssk
                   allausp
                   lt_allausp.
*   status check
    loop at allkssk where statu =  cl_statusf
                      and vbkz  <> c_delete.

*     Perform status check only for the current object         "2681568
*     (if such behavior is requested by user-exit)             "2681568
      if p_exit_active = 'S' and allkssk-objek <> rmclf-objek. "2681568
        continue.                                              "2681568
      endif.                                                   "2681568

      pm_objek  = allkssk-objek.
      pm_class  = allkssk-class.
      pm_inobj  = allkssk-cuobj.
      pm_status = allkssk-statu.
      mafid     = allkssk-mafid.
      sobtab    = allkssk-obtab.
      g_consistency_chk = kreuz.
      clear cl_status_neu.
      perform status_check using allkssk-klart.
      if not cl_status_neu is initial.
*       set status > 1
        allkssk-statu = cl_status_neu.
        modify allkssk.
      endif.
    endloop.
    kssk_update = kreuz.
    aenderflag  = kreuz.
    if classif_status = ein.
      perform insert_classification on commit.
    endif.
  endif.

  refresh lt_allkssk.
  refresh lt_allausp.

endform.                               " cust_exit_pre


*&---------------------------------------------------------------------*
*&      Form  CUST_EXIT_POST
*&---------------------------------------------------------------------*
*       Process a customer-exit after classification data
*       are read from database.
*----------------------------------------------------------------------*
*
*  g_save_called = c_save : called from CLAP_DDB_SAVE_CL.
*                  0      : else
*----------------------------------------------------------------------*
form cust_exit_post
  USING in_update TYPE c.                                     "  2241496

  data:
      l_dynnr         like sy-dynnr,
      l_ok_code       like sy-ucomm,
      l_exit_active   like rmclf-kreuz.
  data:
      lt_allkssk      like rmclkssk occurs 0 with header line,
      lt_allausp      like rmclausp occurs 0 with header line,
      lt_delcl        like rmcldel  occurs 0 with header line,
      lt_delob        like rmcldob  occurs 0 with header line.

  DATA: l_called TYPE c.                                      "  2241496


  check not g_exits_active is initial. " internal debug flag

* Copy global CLFM tables to local tables that may be changed
* in customer exit.
* Consistency check after customer exit

  lt_allkssk[] = allkssk[].
  lt_allausp[] = allausp[].
  lt_delcl[]   = delcl[].
  lt_delob[]   = delob[].



  IF in_update IS INITIAL.                                    "v 2241496
    l_called = g_save_called.
  ELSE.
*   call exit in INSERT_CLASSIFICATION and similar routines
*   to ensure a final call
    l_called = g_exit_upd.
  ENDIF.

  IF in_update IS INITIAL OR NOT g_exit_upd IS INITIAL.       "^ 2241496

    call customer-function '002'
       exporting
               i_rmclf    = rmclf
               i_appl     = g_appl
                 i_called   = l_called                        "  2241496
       importing
               e_active   = l_exit_active
               e_ok_code  = l_ok_code
               e_dynpro   = l_dynnr
       tables
               t_allkssk  = lt_allkssk
               t_allausp  = lt_allausp
               t_delcl    = lt_delcl
               t_delob    = lt_delob.
  ENDIF.                                                      "v 2241496

  CASE l_exit_active.
*   this flag has two meanings now

    WHEN ' '. " not active, no request for exit in update
      CLEAR g_exit_upd.

    WHEN 'N'. " not active, request for exit in update
      CLEAR l_exit_active.
      g_exit_upd = c_save_upd.

    WHEN 'A'. " active, request for exit in update
      l_exit_active = 'X'.
      g_exit_upd = c_save_upd.

    WHEN OTHERS. " active, no request for exit in update
      l_exit_active = 'X'.
      CLEAR g_exit_upd.

  ENDCASE.                                                    "^ 2241496

  if not l_exit_active is initial.
*   take over user changes into system tables
    delcl[] = lt_delcl[].
    delob[] = lt_delob[].
    perform merge_allkssk_allausp
            tables allkssk
                   lt_allkssk
                   allausp
                   lt_allausp.
*   status check
    loop at allkssk where statu =  cl_statusf
                      and vbkz  <> c_delete
                      and objek = rmclf-objek.                 "1863957
      pm_objek  = allkssk-objek.
      pm_class  = allkssk-class.
      pm_inobj  = allkssk-cuobj.
      pm_status = allkssk-statu.
      mafid     = allkssk-mafid.
      sobtab    = allkssk-obtab.
      clear cl_status_neu.
      g_consistency_chk = kreuz.
      perform status_check using allkssk-klart.
      if not cl_status_neu is initial.
*       set status > 1
        allkssk-statu = cl_status_neu.
        modify allkssk.
      endif.
    endloop.
    kssk_update = kreuz.
    aenderflag  = kreuz.
  endif.

  clear g_save_called.
  refresh: lt_allkssk,
           lt_allausp,
           lt_delcl,
           lt_delob.

  if not l_ok_code is initial.
    back_ok = l_ok_code.
  endif.
  if not l_dynnr  is initial.
    set screen l_dynnr.
    leave screen .
  endif.

endform.                               " cust_exit_post

*
*
* Begin of 1415440
*&---------------------------------------------------------------------*
*&      Form  PREPARE_RMCLF_FOR_IDOC
*&---------------------------------------------------------------------*
* Prepare RMCLF if called from IDOC  (IDOC_INPUT_CLFMAS)
form prepare_rmclf_for_idoc using iv_obtab
                                  iv_objek
                                  iv_klart
                                  iv_datuv
                                  iv_aennr.

  rmclf-objek  = iv_objek.
  rmclf-klart  = iv_klart.
  rmclf-datuv1 = iv_datuv.
  rmclf-aennr1 = iv_aennr.

  call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
    exporting
      rmclfstru      = rmclf
      table          = iv_obtab
      init_test      = kreuz
    importing
      rmclfstru      = rmclf
    tables
      lengthtab      = laengtab
    exceptions
      tclo_not_found = 1.

endform.                               " prepare_rmclf_for_idoc
* End of 1415440
