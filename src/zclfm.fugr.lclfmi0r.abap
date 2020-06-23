*---------------------------------------------------------------------*
*       MODULE FUELLEN_OBJ                                            *
*---------------------------------------------------------------------*
*       Neue Warengruppenhierarchien zuordnen                         *
*---------------------------------------------------------------------*
module fuellen_obj.
  rmclf-class = rmclf-wghie1.
  read table klastab with key rmclf-class.
  if syst-subrc = 0.
    message s507 with rmclf-klart rmclf-class.
    exit.
  endif.
  clear klah-clint.
  clear no_datum.
  clear no_status.
  clear no_classify.
  clear klastab.
  pm_class = rmclf-class.
  if rmclf-datuv1 is initial.
    klah-vondt = syst-datum.
  else.
    klah-vondt = rmclf-datuv1.
  endif.
  call function 'CLMA_CLASS_EXIST'
       exporting
            classtype             = rmclf-klart
            class                 = pm_class
            classify_activity     = tcd_stat
            classnumber           = klah-clint
            language              = syst-langu
            description_only      = space
            mode                  = mode
            date                  = klah-vondt
       importing
            class_description     = rmclf-ktext
            not_valid             = no_datum
            no_active_status      = no_status
            no_authority_classify = no_classify
            ret_code              = g_l_subrc
            xklah                 = klah
       exceptions
            no_valid_sign         = 20.
  if syst-subrc = 20.
    message e013 with 'Klasse'(500).
  endif.
  if g_l_subrc eq 2.
    if rmclf-class is initial.
      exit.
    endif.
    message e503 with rmclf-klart pm_class.
  endif.
  if syst-tcode = tcodeclw1.
    if klah-wwskz ne '0'.
      message e557.
    endif.
  endif.
  if rmclf-class = rmclf-clasn.
    message e513 with rmclf-klart rmclf-class.
  endif.
  if tcla-mfkls is initial.
    select count(*) from kssk up to 1 rows
      where mafid eq mafidk
        and klart eq rmclf-klart
        and objek eq klah-clint
        and clint ne pm_clint.
    if syst-dbcnt > 0.
      message e528.
    endif.
  endif.
  CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'            "begin 1141804
    EXPORTING
      iv_enqmode           = 'E'
      iv_klart             = rmclf-klart
      IV_CLASS             = rmclf-class
    EXCEPTIONS
      FOREIGN_LOCK         = 1
      SYSTEM_FAILURE       = 2.
  case sy-subrc.                                           "end 1141804
    when 1.
      syst-msgv4 = syst-msgv1.
      message e518 with rmclf-klart rmclf-class syst-msgv4.
    when 2.
      message e519.
  endcase.
  anzzeilen = anzzeilen + 1.
*-- Füllen ALLKSSK, anschl. KLASTAB
  clear allkssk.
  allkssk-objek    = pm_class.
  allkssk-oclint   = klah-clint.
  allkssk-clint    = pm_clint.
  allkssk-klart    = rmclf-klart.
  allkssk-zaehl    = anzzeilen.
  allkssk-mafid    = mafidk.
  allkssk-kschl    = rmclf-ktext.
  allkssk-class    = pm_class.
  allkssk-statu    = cl_statusf.
  allkssk-lock     = kreuz.
  allkssk-obtab    = sobtab.
  allkssk-vbkz     = c_insert.
  append allkssk.
  describe table allkssk lines sy-tfill.
  klastab-index_tab = sy-tfill.
  move-corresponding allkssk to klastab.
  append klastab.

  rmclf-pagpos = anzzeilen.
  okcode = 'EINT'.              " geändert  ST 4.6A
endmodule.
