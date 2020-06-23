*§-----------------------------------------------------------------*
*        FORM SORT_SAVE                                            *
*------------------------------------------------------------------*
*        Sichern der Umsortierungen                                *
*------------------------------------------------------------------*
form sort_save.
*>>>> Absolut nicht klar, was hier getrieben wird. Das REORGFLAG
*>>>> bestimmt offenbar die Logik, wie umnummeriert wird.
  data: cnt_select   type i.

  case reorgflag.
    when kreuz.
      cnt_select = 1.
      loop at klastab.
        klastab-zaehl = cnt_select * 100.
        if klastab-markupd = kreuz.
          clear klastab-markupd.
          modify klastab.
        endif.
        read table allkssk index klastab-index_tab .
        allkssk-zaehl = klastab-zaehl.
*>>> VBKZ setzen!!
        if allkssk-vbkz ne c_insert.
          allkssk-vbkz = c_update.
          modify allkssk index klastab-index_tab .
        endif.
        cnt_select = cnt_select + 1.
      endloop.
    when konst_z.
      loop at klastab where markupd = konst_y.
*+      ssytabix = klastab-zeile.
        read table allkssk index klastab-index_tab .
        allkssk-zaehl = klastab-zaehl.
*>>> Abbildung auf ALLKSSK-VBKZ: UPDATE setzen oder INSERT lassen
        if allkssk-vbkz ne c_insert .
          allkssk-vbkz = c_update.
          modify allkssk index klastab-index_tab .
        endif.
      endloop.
      loop at klastab.
        ssytabix = syst-tabix.
        clear klastab-markupd.
        read table allkssk index klastab-index_tab .
        allkssk-zaehl = ssytabix * 100.
*>>> Abbildung auf ALLKSSK-VBKZ: UPDATE setzen oder INSERT lassen
        if allkssk-vbkz ne c_insert .
          allkssk-vbkz = c_update.
          modify allkssk index klastab-index_tab .
        endif.
      endloop.
    when konst_y.
      loop at klastab where markupd = konst_y.
*+      ssytabix = klastab-zeile.
        read table allkssk index klastab-index_tab .
        allkssk-zaehl = klastab-zaehl.
*>>> Abbildung auf ALLKSSK-VBKZ: UPDATE setzen oder INSERT lassen
        if allkssk-vbkz ne c_insert .
          allkssk-vbkz = c_update.
          modify allkssk index klastab-index_tab .
        endif.
      endloop.
  endcase.
  clear reorgflag.
endform.
