*&---------------------------------------------------------------------*
*&      Form RECOVER_KLASTAB
*----------------------------------------------------------------------*
*       Rebuilds table klastab and index table
*       when new entries were added.
*       p_change: Form called for a screen that contains all objects
*                 (not only classes, mats, ...).
*                 So change of klastab / klastab_save is allowed.
*----------------------------------------------------------------------*
form recover_klastab
     using value(p_cls_scr)
           value(p_obj_scr).

  data: i like sy-tfill.
  data: lt_klastab_sav like table of g_klastab_sav.            "  867360


  loop at klastab assigning <gf_klas> where objek ne space.
    read table g_klastab_sav with key
                                  objek = <gf_klas>-objek
                                  mafid = <gf_klas>-mafid
                                  clint = <gf_klas>-clint.
    if sy-subrc is initial.
      if g_klastab_sav <> <gf_klas>.
        g_klastab_sav = <gf_klas>.
        modify g_klastab_sav index sy-tabix.
      endif.
      continue.
    else.
      move-corresponding <gf_klas> to g_klastab_sav.
*     avoid to read the appended lines                            867360
      append g_klastab_sav to lt_klastab_sav.                  "  867360
    endif.
  endloop.

  append lines of lt_klastab_sav to g_klastab_sav.             "  867360

  if p_cls_scr = space and g_obj_scr = space.
    refresh klastab.
    klastab[] = g_klastab_sav[] .
    refresh g_klastab_sav .
*   recalculate indices (nec. after deleting allocations)
    describe table klastab lines i.
    describe table allkssk lines sy-tfill.
    if i = sy-tfill.
      loop at klastab assigning <gf_klas>.
        <gf_klas>-index_tab = sy-tabix.
      endloop.
    endif.
  endif.
* klastab changed -> update index table.
  perform rebuild_obji.

endform.                               " RECOVER_KLASTAB
