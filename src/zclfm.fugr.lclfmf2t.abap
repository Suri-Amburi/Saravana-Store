*------------------------------------------------------------------*
*        FORM HELP_F4_STATUS                                       *
*------------------------------------------------------------------*
*        F4 auf dem Feld Status                                    *
*------------------------------------------------------------------*
*
form help_f4_status
     using value(p_classifstatus).
*
  data: l_display(1),
        feldname1   like help_info-fieldname value 'STATU',
        tabelle     like help_info-tabname   value 'TCLC',
        tab         like help_info-tabname   value 'RMCLF',
        feldname2   like help_info-fieldname value 'STATTXT'.
*
  data: begin of felder occurs 3.
          include structure help_value.
  data: end of felder.
*
  data: begin of werte occurs 3,
          text(100).
  data: end of werte.
*

  felder-tabname    = tab.
  felder-fieldname  = feldname1.
  felder-selectflag = kreuz.
  append felder.
  felder-tabname    = tab.
  felder-fieldname  = feldname2.
  felder-selectflag = space.
  append felder.

* loop at itclc.
  loop at xtclc where klart     = rmclf-klart
                  and unvollsts = space.
    werte-text = xtclc-statu.
    append werte.
    werte-text = xtclc-stattxt.
    append werte.
  endloop.
  if p_classifstatus = c_display.
    l_display = kreuz.
  endif.

  call function 'HELP_VALUES_GET_WITH_TABLE'
       exporting
            display                   = l_display
            fieldname                 = feldname1
            tabname                   = tabelle
       importing
            select_value              = rmclf-statu
       tables
            fields                    = felder
            valuetab                  = werte
       exceptions
            field_not_in_ddic         = 1
            more_then_one_selectfield = 2
            no_selectfield            = 3.
  if syst-subrc ne 0.
    exit.
  endif.
  cl_status_neu = rmclf-statu.

endform.
