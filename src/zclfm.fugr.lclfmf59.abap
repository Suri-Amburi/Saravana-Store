*&---------------------------------------------------------------------*
*&      Form  ok_LOES
*&---------------------------------------------------------------------*
*       Delete object in selected line.
*----------------------------------------------------------------------*
form ok_loes.

  data: l_idx like sy-stepl.

  if syst-dynnr = dy602.
    import rmclindx from database indx(cf) id relid.
    check syst-subrc = 0.
    clear rmclindx-zeile1.
    export rmclindx to database indx(cf) id relid.
    clear zeile1.
    loop at redun where radio = punkt.
      clear redun-radio.
      modify redun.
      exit.
    endloop.
    leave screen.

  else.
*   first save previous value assignment
    g_subrc = 9.
    perform close_prev_value_assmnt changing g_subrc.

    IF NOT g_zuord IS INITIAL AND g_zuord <> c_zuord_0.       "  2442333
      perform authority_check_classify
            using    sokcode
                     kreuz
                     space                                     "1847519
            changing g_subrc.
    ELSE.                                                     "v 2442333
*     CL20N - check correct auths if multiple classes are assigned
      CLEAR iklah[].
      FIELD-SYMBOLS <klah> TYPE klah.
      LOOP AT klastab WHERE markupd = kreuz.
        APPEND INITIAL LINE TO iklah ASSIGNING <klah>.
        <klah>-clint = klastab-clint.
      ENDLOOP.

      CALL FUNCTION 'CLSE_SELECT_KLAH'
        TABLES     imp_exp_klah   = iklah
        EXCEPTIONS no_entry_found = 04.

      LOOP AT iklah.
        PERFORM authority_check_classify
          USING    sokcode kreuz space
          CHANGING g_subrc.

        IF g_subrc <> 0.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.                                                    "^ 2442333

    if g_subrc <> 0.
      exit.
    endif.

    if cn_mark > 0.
*-- Es gibt Markierungen
      clear cn_mark.
      clear fname.
      clear markzeile1.
      index_neu = 1.
*-- Der erste Eintrag wird gesetzt
      antwort = kreuz.
      loop at klastab where markupd = kreuz.
*-- Markierungen werden zurückgenommen (weshalb??)
*-- Nach Problem mit Retail: Markierung wird für WWS gelassen
        if g_appl ne konst_w.
          clear klastab-markupd.
          modify klastab.
        endif.
*--     Akt. Zeile wird gesetzt.
        l_idx = syst-tabix.
        g_clint = pm_clint.
        perform auswahl using antwort l_idx.
      if g_display_values is initial.                          "1772310
*         change number o.k.                                   "1772310
          perform classify.
*       if g_display_values is initial.                        "1772310
*         change number o.k.
          perform popup_loeschen.
        else.                                                  "1772310
          CLEAR g_display_values.                              "1772310
          leave screen.                                        "1772310
        endif.
        pm_clint = g_clint .
      endloop.
*     clear zeile.
    else.
      if klastab[] is initial.                          "begin 1484167
* --  empty allocation
         zeile = 0.
         message s501.
         leave screen.
      endif.                                              "end 1484167
      check zeile ne 0.
*--   Keine Markierungen gesetzt: mit ZEILE Index in klastab berechnen
      antwort = kreuz.
      g_clint = pm_clint.
      l_idx = index_neu + zeile - 1.
      perform auswahl using antwort l_idx.
      if g_display_values is initial.                          "1772310
*       change number o.k.
        perform classify.                                        "922037
      if antwort = kreuz.
        message s501.
        leave screen.
      endif.
*      if g_display_values is initial.                         "1772310
*       change number o.k.
        perform popup_loeschen.
      else.                                                    "1772310
        CLEAR g_display_values.                                "1772310
        leave screen.                                          "1772310
      endif.
      pm_clint = g_clint .
    endif.

*   rebuild index_tab
    perform recover_klastab
            using g_cls_scr g_obj_scr.

    if klastab[] is initial.
      perform fill_empty_klastab
              using multi_class.
    endif.

    clear g_val-objek.
    call function 'CTMS_DDB_INIT'.

    if g_zuord ne c_zuord_4.                  "note 1700433
* Begin of 900769
    l_idx = 1.
    g_clint = pm_clint.
    perform auswahl using antwort l_idx.
    if antwort = kreuz.
      leave screen.
    endif.
    perform classify.
    pm_clint = g_clint .
* End of 900769
  endif.

  endif.

endform.                               " ok_LOES
