*&---------------------------------------------------------------------*
*&      Form  OK_al_step
*&---------------------------------------------------------------------*
*       Steps through list of allocations
*       and shows value assignments each time.
*       Selected line is marked. When stepping the marked line
*       keeps its position whereas the list scrolls up.
*
*       Start in 1. marked line or the line that has the cursor.
*----------------------------------------------------------------------*
form ok_al_step.

  data:
    l_idx   like sy-stepl,     "index to klastab entry to be evaluated
    l_tabix like sy-tabix.

* first save previous value assignment
  perform close_prev_value_assmnt changing g_subrc.

  if cn_mark = 0.
*   no marking, start stepping from line with cursor.
    if zeile = 0.
      message s501.
      leave screen.
    else.
      l_idx = index_neu + zeile - 1.
    endif.

  else.
*   marking exists: go to next entry in klastab
    loop at klastab assigning <gf_klas>
                    where markupd = kreuz.
      clear <gf_klas>-markupd.
      modify klastab from <gf_klas> index sy-tabix.
      l_tabix = sy-tabix.
      exit.
    endloop.
    cn_mark = cn_mark - 1.

    if sokcode = ok_al_step_dn.
*     step downwards
      l_idx = l_tabix + 1.
      read table klastab index l_idx transporting no fields.
      if sy-subrc = 0.
        index_neu = l_tabix.
      else.
*       end of list: go to top
        l_idx = 1.
        index_neu = 1.
      endif.

    else.
*     step upwards
      l_idx = l_tabix - 1.
      if l_idx = 0.
*       top of list: go to bottom
        describe table klastab lines sy-tfill.
        l_idx = sy-tfill.
        index_neu = sy-tfill - 1.
      elseif l_idx = 1.
*       1. line of list
        index_neu = 1.
      else.
        index_neu = l_idx - 1.
      endif.
    endif.
  endif.
  rmclf-pagpos = index_neu.

  g_clint = pm_clint.
  perform auswahl using antwort l_idx.
  if antwort = kreuz.
    message s501.
    leave screen.
  endif.
  perform classify.
  pm_clint = g_clint .

* mark current line.
  klastab-markupd = kreuz.
  modify klastab index g_klastab_akt_index transporting markupd.
  cn_mark = cn_mark + 1.

endform.                               " ok_al_step

