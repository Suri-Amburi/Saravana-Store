*---------------------------------------------------------------------*
*       FORM OKB_FILT                                                  *
*---------------------------------------------------------------------*
*       OK-Codemodul filtern                                          *
*---------------------------------------------------------------------*
form okb_filt.

  data: sindex       like index_neu.
  data: sanzzeilen   like anzzeilen.


  sanzzeilen = anzzeilen.
  describe table tabausw lines anzzeilen.
  if anzzeilen = 0.
    loop at redun.
      tabausw-zaehl = syst-tabix.
      tabausw-obtyp = redun-objtype.
      tabausw-kreuz = kreuz.
      tabausw-texto = redun-obtxt.
      append tabausw.
    endloop.
    describe table tabausw lines anzzeilen.
  else.
    sort tabausw by zaehl.
  endif.
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
  anzzeilen = sanzzeilen.
  sokcode = okfilt.
endform.
