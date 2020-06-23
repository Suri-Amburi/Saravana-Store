*----------------------------------------------------------------------*
*       FORM EXCLUDE_FUNCTIONS
*----------------------------------------------------------------------*
*       Ausschließen von FCODEs
*       ex_pfstatus:  CL24/25
*       ex_pfstatus1: CL20/22, object
*----------------------------------------------------------------------*
form exclude_functions using value(i_obj_chg_serv)
                             value(i_no_change_type)
                             value(i_multi_obj)
                             value(i_no_f8)
                             value(i_no_f11)
                             value(i_obj_navigation)
                             value(no_new_entries)
                             value(i_show).
  data: l_tcla like tcla,
        l_tclao like tclao.

  if g_46_ta <> space.
    refresh ex_pfstatus.
    refresh ex_pfstatus1.

    if g_zuord = c_zuord_0.
      ex_pfstatus1-func = ok_cls_stack.
      append ex_pfstatus1.
      if i_multi_obj = space.
        ex_pfstatus1-func = okobwe.    " change object type
        append ex_pfstatus1.
      endif.
    endif.

    if i_show <> space or
       rmclf-klart eq '022' or
       rmclf-klart eq '023' .
      ex_pfstatus1-func = okneuz.
      append ex_pfstatus1.
    endif.


    if i_show <> space.
      ex_pfstatus1-func = okloes.
      append ex_pfstatus1.
      ex_pfstatus1-func = oksave.
      append ex_pfstatus1.
      ex_pfstatus1-func = okstat.
      append ex_pfstatus1.
      ex_pfstatus1-func = okstcl.
      append ex_pfstatus1.
      ex_pfstatus1-func = okrele.
      append ex_pfstatus1.
    endif.

    if change_subsc_act is initial.
*--   Verarbeitung ohne Änderungsnummer
      ex_pfstatus1-func = okaedi.      "Änderungsnummer
      append ex_pfstatus1.
      ex_pfstatus1-func = okaeda.      "Änderungsdienstdaten
      append ex_pfstatus1.
    endif.

    if g_zuord = space.
*--   vom Objekt kommend: Ermittlung der klassenarten zu sobtab
      select * from tcla into l_tcla     up to 2 rows
                   where obtab = sobtab.
      endselect.
      if syst-dbcnt < 2.
        x2 = syst-dbcnt.
        select * from tclao into l_tclao up to 2 rows
                     where obtab = sobtab.
        endselect.
        x2 = x2 + syst-dbcnt.
        if x2 < 2.
*--       Es gibt nur eine KLassenart: Kein Wechsel möglich
          ex_pfstatus1-func = okwech.
          append ex_pfstatus1.
        endif.
      endif.

      if not i_no_f11 is initial.
        ex_pfstatus1-func = oksave.    "kein F11 Sichern möglich
        append ex_pfstatus1.
      endif.
      if not i_no_change_type is initial.
        ex_pfstatus1-func = okwech.
        append ex_pfstatus1.
      endif.
    endif.

    if clhier is initial.
*-- Keine Hierarchie erlaubt
      ex_pfstatus1-func = okhcla.
      append ex_pfstatus1.
      ex_pfstatus1-func = okhclg.
      append ex_pfstatus1.
      ex_pfstatus1-func = okucla.
      append ex_pfstatus1.
      ex_pfstatus1-func = okuclg.
      append ex_pfstatus1.
      ex_pfstatus1-func = okxcla.
      append ex_pfstatus1.
      ex_pfstatus1-func = okxclg.
      append ex_pfstatus1.
    endif.

    if claeblg is initial.
*--   Keine Änderungsbelege zugelassen
      ex_pfstatus1-func  = okaebl.
      append ex_pfstatus1.
    endif.

* Tabelle mit Fcodes für Bewertung
    ex_pfstatus1v[] = ex_pfstatus1[].
    ex_pfstatus1v-func = ok_acus.
    append ex_pfstatus1v.
    ex_pfstatus1v-func = ok_acmg.
    append ex_pfstatus1v.
    ex_pfstatus1v-func = ok_defv.
    append ex_pfstatus1v.
    ex_pfstatus1v-func = ok_vsch.
    append ex_pfstatus1v.
    ex_pfstatus1v-func = ok_view.
    append ex_pfstatus1v.
    ex_pfstatus1v-func = ok_trce.
    append ex_pfstatus1v.
    ex_pfstatus1v-func = ok_trac.
    append ex_pfstatus1v.

  endif.                               " g_46_ta active

  check g_46_ta is initial.

*-------------------------------------------------------------------

* PF-Status-Funktionen löschen
  refresh ex_pfstatus.
  refresh ex_pfstatus1.

  if i_obj_navigation is initial.
*-- Objektnavigation (durch den Aufrufer)
    ex_pfstatus1-func = ok_first.
    append ex_pfstatus1.
    ex_pfstatus1-func = ok_last .
    append ex_pfstatus1.
    ex_pfstatus1-func = ok_next .
    append ex_pfstatus1.
    ex_pfstatus1-func = ok_prev .
    append ex_pfstatus1.
  endif.

  if  g_zuord = c_zuord_0.
*-- Objekt zu Klassen
    ex_pfstatus1-func = okwech.        "kein F7 wechseln Klassenart
    append ex_pfstatus1.
    ex_pfstatus1-func = okaedi.        "Änderungsnummer
    append ex_pfstatus1.
    if not no_new_entries is initial.
      ex_pfstatus1-func = okneuz.      "Neue Einträge
      append ex_pfstatus1.
    endif.
  else.
*-- ... sonst: Ermittlung der KLassenarten zu SOBTAB
    select klart from tcla into tcla-klart up to 2 rows
                 where obtab = sobtab.
    endselect.
    if syst-dbcnt < 2.
      x2 = syst-dbcnt.
      select klart from tclao into tcla-klart up to 2 rows
        where obtab = sobtab.
      endselect.
      x2 = x2 + syst-dbcnt.
      if x2 < 2.
*-- Es gibt nur eine KLassenart: Kein Wechsel möglich
        ex_pfstatus1-func = okwech.
        append ex_pfstatus1.
      endif.
    endif.

*-- Wenn Baustein nicht über CL20: NEZU ist nicht möglich!!!
    ex_pfstatus1-func = oknezu.        "Andere Zuordnung nicht möglich
    append ex_pfstatus1.

    if change_subsc_act is initial.
*-- Verarbeitung ohne Änderungsnummer
      ex_pfstatus1-func = okaedi.      "Änderungsnummer
      append ex_pfstatus1.
      ex_pfstatus1-func = okaeda.      "Änderungsdienstdaten
      append ex_pfstatus1.
    else.
*-- ... mit Änderungsdienst
      if not rmclf-aennr1 is initial or i_obj_chg_serv = kreuz.
*-- Falls Änderungsdienst über Objekt gesteuert: FCODE nicht erlaubt
        ex_pfstatus1-func = okaedi.    "Änderungsnummer
        append ex_pfstatus1.
      endif.
    endif.
  endif.

  if not i_no_f8 is initial.
    ex_pfstatus1-func = okwei1.        "kein F8 Weiter möglich
    append ex_pfstatus1.
  endif.
  if not i_no_f11 is initial.
    ex_pfstatus1-func = oksave.        "kein F11 Sichern möglich
    append ex_pfstatus1.
  endif.
  if not i_no_change_type is initial.
    ex_pfstatus1-func = okwech.        "kein wechseln Klassenart
    append ex_pfstatus1.
  endif.

  if clhier is initial.
*-- Keine Hierarchie erlaubt
    ex_pfstatus1-func = okhcla.
    append ex_pfstatus1.
    ex_pfstatus1-func = okhclg.
    append ex_pfstatus1.
    ex_pfstatus1-func = okucla.
    append ex_pfstatus1.
    ex_pfstatus1-func = okuclg.
    append ex_pfstatus1.
    ex_pfstatus1-func = okxcla.
    append ex_pfstatus1.
    ex_pfstatus1-func = okxclg.
    append ex_pfstatus1.
  endif.
  if claeblg is initial.
*-- Keine Änderungsbelege zugelassen
    ex_pfstatus1-func = okaebl.
    append ex_pfstatus1.
  endif.

  if multi_class is initial.
*-- Keine Mehrfachklassifizierung: Blockmarkieren etc. abklemmen
    ex_pfstatus1-func = okbloc.
    append ex_pfstatus1.
    ex_pfstatus1-func = okmade.
    append ex_pfstatus1.
    ex_pfstatus1-func = okmall.
    append ex_pfstatus1.
  endif.

*-- Zusätzliche EXCLUDEs bei Anzeige
  check not i_show is initial.
  ex_pfstatus1-func = okloes.
  append ex_pfstatus1.
  ex_pfstatus1-func = okneuz.
  append ex_pfstatus1.
  ex_pfstatus1-func = oksave.
  append ex_pfstatus1.
  ex_pfstatus1-func = okklas.
  append ex_pfstatus1.
  ex_pfstatus1-func = okstat.
  append ex_pfstatus1.
  ex_pfstatus1-func = okstcl.
  append ex_pfstatus1.
  ex_pfstatus1-func = okrele.
  append ex_pfstatus1.
  ex_pfstatus1-func = okmein.
  append ex_pfstatus1.

endform.
