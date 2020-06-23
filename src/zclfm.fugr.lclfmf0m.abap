*&---------------------------------------------------------------------*
*&      Form  OKB_NEUZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_neuz.

  clear fname.
  case g_zuord.
    when c_zuord_2.                    "Mehrfachklassifi. erlaubt
      if multi_class ne kreuz.         "NEIN ---> EXIT
        message s528.
      else.
        clear anzzeilen.
        clear rmclf-paganz.
        pag_page     = 1.
        pag_pages    = 1.
        rmclf-pagpos = 0.
        index_neu    = 1.
        set screen dy505.
      endif.
    when c_zuord_4.                    "Cursorpos. bestimmt das
      clear anzzeilen.
      pag_page     = 1.
      pag_pages    = 1.
      index_neu    = 1.
      if zeile = 0.                    "Einfügen der neuen Zu-
        describe table klastab lines zeile.
        message s515.
        altzeile = zeile + index_neu - 1.    "merken Cursorpos
        read table klastab index altzeile.    "lesen klastab
        altzeile = altzeile + 1.       "merken Cursorpos
        szaehl = klastab-zaehl.
        hzaehl = klastab-zaehl + 100.
        szeile = altzeile.
        xzeile = altzeile.
      else.
        altzeile = zeile + index_neu - 1.    "merken Cursorpos
        read table klastab index altzeile.    "lesen klastab
        szeile = altzeile.
        xzeile = altzeile.
        hzaehl = klastab-zaehl.        "merken Zähler
        if altzeile = 1.               "Cursor auf 1.Zeile pos.
          szaehl = 0.
          altzeile = 0.
        else.                          "nein
          altzeile = altzeile - 1.     "vorheriger Eintrag in klastab
          read table klastab index altzeile.  "lesen
          szaehl = klastab-zaehl.
        endif.
      endif.

      if g_only_class = kreuz.
        zeile = 0.
        zeile1 = 2.
        set screen dy510.
      else.
        import rmclindx from database indx(cf) id relid.
        if rmclindx-zeile1 = 0.
          describe table redun1 lines x2.
          x2 = x2 + 10.
          index_neu1 = 1.
          call screen dy602            "auswählen Klassen oder
              starting at 32 8         "Objektzuordnung
              ending   at 79 x2.
          if sokcode = okabbr.
            index_neu = rmclf-pagpos.
            clear okcode.
            leave screen.
          endif.
          read table redun1 index zeile1.
          read table redun  index redun1-index.
        else.
          zeile1 = rmclindx-zeile1.
          read table redun1 index zeile1.
          read table redun  index redun1-index.
          if multi_obj = kreuz.
            if redun-obtab is initial.
              sobtab = pobtab.
            else.
              sobtab = redun-obtab.
              if redun-dynnr2 is initial.
*               sm_dynnr        = dynp0499.
                redun-dynnr4    = dynp0499.
                d5xx_dynnr      = dynp0299.
              else.
*               sm_dynnr        = redun-dynnr4.
                d5xx_dynnr      = redun-dynnr2.
              endif.
              strlaeng = strlen( redun-obtxt ).
              assign redun-obtxt(strlaeng) to <length>.
            endif.
          endif.
        endif.

        zeile = 0.
        clear rmclf-paganz.
        rmclf-pagpos = 0.
        if not redun-obtab is initial.
          sokcode = okeint.
          sobtab  = redun-obtab.
          g_cls_scr = space.
          g_obj_scr = kreuz.
          set screen dy512.
        else.
          if multi_obj = kreuz.
            sobtab = pobtab.
          endif.
          if clhier is initial.
            message e571 with rmclf-klart.
          endif.
          g_cls_scr = kreuz.
          g_obj_scr = space.
          set screen dy510.
        endif.
      endif.

*     build new klastab: subset of overview
*     - save current klastab
*     - klastab changed -> update index table
      g_klastab_sav[] = klastab[].
      if g_obj_scr is initial.
*       classes
        delete klastab where obtab <> space.
      else.
*       objects
        delete klastab where obtab <> sobtab.
      endif.
      perform rebuild_obji.


    when others.
      if multi_class ne kreuz.         "Mehrfachklassifi. erlaubt
        message s528.                  "NEIN ---> EXIT
      else.
        clear anzzeilen.
        clear rmclf-paganz.
        pag_page     = 1.
        pag_pages    = 1.
        rmclf-pagpos = 0.
        index_neu    = 1.
        set screen dy500.
      endif.
  endcase.

* create empty lines for table controls
  clear klastab.
*-- Für die weitere Bearbeitung wird OK-Code wie bei "Neue Einträge"
*-- gesetzt
  sokcode = okeint.
  clear zeile.
  leave screen.

endform.                               " OKB_NEUZ
