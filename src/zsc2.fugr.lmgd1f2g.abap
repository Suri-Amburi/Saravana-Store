*----------------------------------------------------------------------*
*   INCLUDE LMGD1F2G                                                   *
*----------------------------------------------------------------------*


form sort_meinh.
*                changing meinh type standard table of structure smeinh.

  data: sort_tab type standard table of smeinh.
  data: wa_meinh type smeinh.
  data: n_meinh type smeinh.
  data: hmeinh type standard table of smeinh.
  data: insert_index like sy-tabix.
  data: counter type i.
  data: line type i.
  data: doppeleintrag(1) type c.

*  check me_fehlerflg is initial.               " Kein Doppeleintrag !!!
*                                   "funktioniert nur leider nicht immer


* Basismengeneinheit
  read table meinh with key kzbme = x into wa_meinh.
  check sy-subrc = 0.
  append wa_meinh to sort_tab.

  loop at sort_tab into wa_meinh.
    insert_index = sy-tabix + 1.
    refresh hmeinh.
*   Abgeleitete ME bestimmen
    loop at meinh into n_meinh where mesub = wa_meinh-meinh.
       check N_MEINH-MEINH NE WA_MEINH-MEINH.      "bme nicht nochmal
       append n_meinh to hmeinh.
    endloop.
*   Abgeleitete ME werden nach azsub sortiert und hinter wa_meinh
*   eingefügt
* note 326372
    sort hmeinh by azsub ascending meinh.
    insert lines of hmeinh into sort_tab index insert_index.
    wa_meinh-kzsub = x.
*   kzsub kennzeichnet die gefundenen MEs, muss nicht wieder zurückge-
*   setzt werden, da meinh unten geloescht wird.
*   Problem: Bei Doppeleintraegen wird falsch modifiziert
    read table meinh with key meinh = wa_meinh-meinh.
    counter = 0.
    loop at meinh where meinh = wa_meinh-meinh.
      counter = counter + 1.
      line = sy-tabix.
    endloop.
    if counter = 1.
      modify meinh from wa_meinh index line.
    else.
      doppeleintrag = x.
      exit.
    endif.
  endloop.

* nicht gefundene MEs (mesub ist initial oder falsch definiert)anhaengen
  if doppeleintrag is initial.
    loop at meinh into wa_meinh where kzsub is initial.
        append wa_meinh to sort_tab.
    endloop.
    refresh meinh.
    meinh[] = sort_tab.
  else.
* sind Eintraege doppelt, wird nicht sortierte meinh zurueckgegeben
    loop at meinh into wa_meinh where kzsub = x.
        clear wa_meinh-kzsub.
        modify meinh from wa_meinh.
    endloop.
  endif.
endform.
