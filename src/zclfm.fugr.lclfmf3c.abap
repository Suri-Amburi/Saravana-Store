*---------------------------------------------------------------------*
*       FORM LOESCHEN_MARK                                            *
*---------------------------------------------------------------------*
*       Loeschen markierte Eintraege aus klastab
*---------------------------------------------------------------------*
form loeschen_mark.
  data: l_aennr like rmclf-aennr .
  data: l_date  like rmclf-datuv1.                              "897241
  data: stabix like syst-tabix.

  refresh ikssk.
  loop at klastab where markupd = kreuz.
    zeile = syst-tabix.
    read table allkssk with key
                            objek = klastab-objek
                            clint = pm_clint
                            klart = rmclf-klart
                            mafid = klastab-mafid.
    stabix = syst-tabix.
    check syst-subrc = 0.
    if allkssk-vbkz ne c_insert.
*+  if allkssk-database = kreuz.
      l_date = sy-datum.                                        "897241
      perform check_structure using rmclf-klart
                                    rmclf-clasn
                                    allkssk-clint
                                    allkssk-objek
                                    allkssk-oclint
                                    syst-subrc
                                    l_aennr
                                    l_date.                     "897241
      if syst-subrc > 0.
        inkonsi = kreuz.
        message s554.
        clear klastab-markupd.
        modify klastab.
        leave screen.
      endif.
    endif.
    delete klastab.
    cn_mark = cn_mark - 1.

    if allkssk-vbkz = c_insert.
      clear allkssk-objek.
      clear allkssk-vbkz.
      modify allkssk index stabix.
      loop at allausp where objek = klastab-objek
                        and klart = rmclf-klart
                        and mafid = mafidk.
        clear allausp-objek.
        modify allausp.
      endloop.

    else.
      allkssk-vbkz = c_delete.
      modify allkssk index stabix.
      loop at allausp where objek = klastab-objek
                        and klart = rmclf-klart
                        and mafid = mafidk.
        allausp-delkz = kreuz.
        modify allausp.
      endloop.
      del_counter = del_counter + 1.
      perform delete_database using allkssk space.
    endif.

    anzzeilen    = anzzeilen - 1.
    rmclf-pagpos = anzzeilen.
  endloop.

endform.                    "loeschen_mark
