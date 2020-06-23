*----------------------------------------------------------------------*
*       FORM SELECT_CLASS_TYPE
*----------------------------------------------------------------------*
*       Check/select class type if called from object transaction.
*       If necessary change class type read from memory.
*----------------------------------------------------------------------*
form select_classtype
     using    value(p_classtype)
     changing p_table
              p_ptable
              p_change_subsc_act
              p_dynpro_header
              p_cancel.

  data:
        l_batchi   like sy-binpt,      " BINPT aktiv
        l_exit(1),
        l_flag(1),
        l_obtab    like tcla-obtab,
        ls_tcla    like tcla.                                  "2355402


  if rmclf-klart is initial and
     sy-binpt    is initial.
*-- Klassenart könnte auch über Parameter übergeben werden ...
    get parameter id c_param_kar field rmclf-klart.
    if not rmclf-klart is initial.
      l_flag  = kreuz.
    endif.
  endif.

* Moved 2355402 down one block...                              "2366399

  if syst-binpt is initial and sokcode ne okwech and
    ( p_classtype = space and rmclf-klart <> space ).
*   Is imported table appropriate to class type from memory ?

    select single obtab from tcla into l_obtab
                        where klart = rmclf-klart
                          and obtab = p_table.
    if sy-dbcnt = 0.
      select single obtab from tclao into l_obtab
                          where klart = rmclf-klart
                            and obtab = p_table.
      if sy-dbcnt = 0.
        clear rmclf-klart.
      endif.
    endif.
    clear tcla.
    clear tclao.
  endif.

* try to determine class type:
* copy from TCLA, if OBTAB exist exactly once
  if p_classtype   is initial     and
     rmclf-klart   is initial     and
     p_table       is not initial and                          "2452723
     syst-binpt    is initial.                                 "2452723
    select * from tcla into ls_tcla where obtab = p_table.
*     Copy KLART, if we have just one entry
*     Otherwise clear RMCLF again and exit
      if rmclf-klart is initial.
        rmclf-klart = ls_tcla-klart.
        l_flag      = 'X'.
      else.
        clear: rmclf-klart, l_flag.
        exit.
      endif.
    endselect.
  endif.

  if syst-binpt = kreuz or
    ( not rmclf-klart is initial and sokcode ne okwech ) .
*----------------------------------------------------------------------
*-- Es wird eine Existenzprüfung gemacht, wenn
*-- 1) Batch-Input
*-- 2) Klassenart nicht initial und kein KLassenartenwechsel
*-- 3) vom Objekt kommend (Materialstamm) ist tcla noch nicht bekannt
*---   und wird in chk_existence gesetzt.
*----------------------------------------------------------------------
    if syst-binpt = kreuz  .
*-- ... Batchinput aktiv und kein Dialog möglich!
      if sokcode = okwech.
        clear rmclf-klart.
      endif.
      l_batchi = kreuz.
      clear p_dynpro_header.
    endif.
    perform chk_existence using l_batchi
                                l_flag
                       changing l_exit
                                p_ptable
                                p_table.
    if not tcla-aediezuord is initial.
*     display aennr when from master data TC
      p_change_subsc_act = kreuz.
    endif.

  else.
*-- Keine Existenzprüfung: Auch Dialog bzw. KLassenartenwechsel mgl.

    if not rmclf-klart is initial and sokcode = okwech.
*--   Klassenart angegeben und Wechsel wird durchgeführt
      l_flag = kreuz.
    else.
      clear l_flag.
    endif.
    perform chk_with_dialogue using    space        " class type
                                       l_flag
                              changing p_cancel
                                       l_exit
                                       p_ptable
                                       p_table.
*   clear tcltt-obtxt.                              " 4.6C
*   clear pm_header.                                " 4.6B
*   Wechsel Klassenart: wenn pm-header nicht gelöscht wird,
*   dann auch nicht tcltt-obtxt (sonst d5xx_dynnr falsch).
  endif.
  if not l_exit is initial.
    exit.
  endif.
  sobtab = p_table .

endform.                               " select_classtype
