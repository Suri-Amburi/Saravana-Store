*---------------------------------------------------------------------*
*       FORM OK_FILT                                                  *
*---------------------------------------------------------------------*
*       OK-Codemodul filtern                                          *
*---------------------------------------------------------------------*
form ok_filt.

  data: sindex       like index_neu.
  data: l_anzzeilen  like anzzeilen.

  if classif_status <> space.
    l_anzzeilen = anzzeilen.
    perform setup_table_tabausw using anzzeilen.

    if anzzeilen > 10.
      x2 = 10 + 7.
    else.
      x2 = anzzeilen + 7.
    endif.
    sindex = index_neu.
    index_neu = 1.
    call screen 604 starting at 5 5
                    ending   at 45 x2.
    sort tabausw by obtyp.
    if sokcode ne okabbr.
      perform rebuild_obji.
    endif.
    index_neu = sindex.
    anzzeilen = l_anzzeilen.
    sokcode = okfilt.
  endif.

endform.
