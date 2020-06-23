*&---------------------------------------------------------------------*
*&      Form  RELEASE_MARKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form release_marked
     using l_changed.

  data: l_msg_flg      like rmclf-kreuz,
        l_count        type n,
        l_tabix        like sy-tabix,
        l_tabix_1      like sy-tabix.

  clear l_changed.
  clear l_msg_flg .
  clear l_count.
  clear cn_mark.
  clear fname.
  clear markzeile1.

  loop at klastab where markupd = kreuz.
*       and  statu <> cl_statusf.
    read table allkssk index klastab-index_tab.
    if allkssk-statu <> cl_statusf.

*-- .. Kandidat für autom. freigabe gefunden
      l_tabix = klastab-index_tab.
      perform kssk_freigabe using allkssk.
      if allkssk-statu = cl_statusf.
*--     .. status jetzt auf "freigegeben": MODIFY
        modify allkssk index l_tabix.
        l_changed = kreuz.
        kssk_update = kreuz .
      else.
        l_count = l_count + 1.
        l_msg_flg = kreuz.
      endif.
    endif.
  endloop.

  if sy-subrc <> 0.
    message s234.                             " 'No line marked.'
  endif.

  if not l_msg_flg is initial.
    message s498 with l_count.
  endif.

endform.                               " RELEASE_MARKED
