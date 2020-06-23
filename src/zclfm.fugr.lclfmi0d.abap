*------------------------------------------------------------------*
*       MODULE CHECK_STATUS INPUT                                  *
*------------------------------------------------------------------*
*       Klassifizierungsstatus ändern
*       Dynpros  *500, *505, *510, *511, *512
*------------------------------------------------------------------*
*  check classification status
*
*  Rel. 4.6 .. :
*      We are now in allocation subscreen.
*      If both evaluation and status are changed,
*      necessary error popup's (missing must evaluations)
*      cannot be opened by CTMS.
*      So the evaluation-close (in form close_prev_value_ass)
*      may not be called now:
*      If user pressed enter in status imput field or the
*      scrollbar, okcode is empty and this event can be bend
*      to menue event 'STAT' (proecessed in main screen).
*      If user generated other events (save, ausw, ..)
*      the evaluation-close with the status check
*      is called elsewhere in the main screen.
*------------------------------------------------------------------*
module check_status input.


  if g_46_ta <> space.                                   "note 1624600
    if okcode is initial or
      ( okcode = oksave and sy-datar <> space ).
*     1. 'ENTER' pressed in status input field.
*     2. status changed, no 'ENTER', then 'SAVE'.
*     save rmclf-statu, bend ok_code:
*     new status it will be processed in dynpro loops.
      g_clfy_status_new = rmclf-statu.
      okcode = okstat.
      exit.                                              "note 1578958
    endif.
  endif.

*  check g_46_ta = space.                                 note 1474369


* Lesen Klassifizierungsstatus - Tabelle TCLC
  clear sokcode.
  check not rmclf-statu is initial.
  check not allkssk-statu is initial.

  if rmclf-statu = cl_statusus or      "Status unvollst. System
     rmclf-statu = cl_statuslv.        "Status löschvormerkung
    message e542 with rmclf-statu.     "darf nur vom System gesetzt
  endif.                               "werden
  read table xtclc with key mandt = sy-mandt
                            klart = rmclf-klart
                            statu = rmclf-statu binary search.
  if not sy-subrc is initial.
    perform lesen_tclc using rmclf-klart.
    read table xtclc with key mandt = sy-mandt
                              klart = rmclf-klart
                              statu = rmclf-statu binary search.
    if not sy-subrc is initial.
      message e540 with rmclf-statu.
    endif.
  endif.
  if syst-subrc = 0.
    check rmclf-statu ne allkssk-statu.
    ssytabix = syst-tabix.
    if not Xtclc-frei is initial.
      allkssk-statu = xtclc-statu.
    endif.
    if not xtclc-gesperrt is initial.
      allkssk-statu = xtclc-statu.
    endif.
    if not xtclc-unvollstm is initial.
      allkssk-statu = xtclc-statu.
    endif.
    if tcd_stat eq kreuz.
      if g_zuord eq c_zuord_4.
        pm_objek = allkssk-objek.
        pm_class = rmclf-clasn.
        pm_inobj = allkssk-cuobj.
        mafid    = allkssk-mafid.
        if allkssk-statu eq cl_statusf.
          if klas_pruef = konst_e or klas_pruef = konst_w.
            clear g_consistency_chk.
          else.
            g_consistency_chk = kreuz.
          endif.
          clear cl_status_neu.
          perform status_check using allkssk-klart.
          if not cl_status_neu is initial .
            message w500 with pm_objek .
            allkssk-statu = cl_status_neu.
          endif.
        endif.
      else.
        pm_objek = rmclf-objek.
        pm_class = allkssk-class.
        pm_inobj = inobj.
        if allkssk-statu eq cl_statusf.
          if allkssk-praus = konst_e or
             allkssk-praus = konst_w.
            clear g_consistency_chk.
          else.
            g_consistency_chk = kreuz.
          endif.
          clear cl_status_neu.
          perform status_check using allkssk-klart.
          if not cl_status_neu is initial .
            message w500 with pm_objek.
            allkssk-statu = cl_status_neu.
          endif.
        endif.
      endif.
    endif.

    if not allkssk-vbkz eq c_insert.
      allkssk-vbkz = c_update.
    endif.
*   index has to be determined newly
    read table allkssk with key objek = allkssk-objek
                            transporting no fields.
    if sy-subrc = 0.
      modify allkssk index sy-tabix..
    endif.
  endif.

endmodule.
