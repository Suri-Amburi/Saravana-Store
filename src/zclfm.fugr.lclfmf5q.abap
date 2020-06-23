*&---------------------------------------------------------------------*
*&      Form  OK_AUSW
*&---------------------------------------------------------------------*
*       Read evaluation of selected line.
*       To close previous value assignment
*       call close_prev_value_assmnt first !
*
*       Consider order of form calls :
*       Before CTMS is opened for the new object, the CTMS
*       (assignments) for the previous object is to be closed.
*       For that the pm_* data are used in build_allausp.
*       At this time the pm_* data still refer to the previous object.
*       They will be updated in form auswahl.
*------------------------------------------------------------------*
form ok_ausw.

  data: l_idx   like sy-stepl,
        l_subrc like sy-subrc.

* first save previous value assignment
  perform close_prev_value_assmnt changing l_subrc.

  if cn_mark > 0.
*-- Es gibt Markierungen
    clear cn_mark.
    clear fname.
    clear markzeile1.
    loop at klastab where markupd = kreuz.
*     clear klastab-markupd.
*     modify klastab.
      l_idx = sy-tabix.
    endloop.
  else.
*-- Keine Markierungen: mit ZEILE Index für klastab berechnen
    check zeile ne 0.
    l_idx = index_neu + zeile - 1.
  endif.

  g_clint = pm_clint.
  perform auswahl using antwort l_idx.
  if antwort = kreuz.
    message s501.
    leave screen.
  endif.
  perform classify.
  pm_clint = g_clint .

endform.                               " ok_ausw
