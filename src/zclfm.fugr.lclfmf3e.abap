*&---------------------------------------------------------------------*
*&      Form  READ_SELECTED_LINE
*       get class name in selected line
*&---------------------------------------------------------------------*
*      <--  p_class         name of selected class
*----------------------------------------------------------------------*
form read_selected_line
     changing p_class   like klah-class.

  data: l_idx like sy-stepl.

  clear p_class.
  if cn_mark > 0.
*-- Es gibt Markierungen
    clear cn_mark.
    index_neu = 1.
*-- Der erste Eintrag wird gesetzt
    antwort = kreuz.
    loop at klastab where markupd = kreuz.
*     Markierungen werden zurückgenommen
      clear klastab-markupd.
      modify klastab.
      l_idx = sy-tabix.
      perform auswahl using antwort l_idx.
    endloop.
  else.
    if zeile = 0.
      if fname = c_fld_clasn.
*       cl22/24n: class in selection area
        p_class = rmclf-clasn.
        exit.
      else.
        message s501.
        leave screen.
      endif.
    else.
*--   Keine Markierungen: mit ZEILE Index in klastab berechnen
      l_idx = index_neu + zeile - 1.
      perform auswahl using antwort l_idx.
      if antwort = kreuz.
        message s501.
        leave screen.
      endif.
    endif.
  endif.

  if g_zuord = c_zuord_4.
    if klastab-obtab is initial.
      p_class = klastab-objek.
    endif.
  else.
    p_class = allkssk-class.
  endif.

endform.                               " READ_SELECTED_LINE
