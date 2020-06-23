*&---------------------------------------------------------------------*
*&      Form  ok_NEUZ
*&---------------------------------------------------------------------*
*       Called if new objects or classes are to be allocated.
*       cl24: Change subscreen:
*             overview -> subset (objects or classes).
*             Save klastab.
*             Gather new objects in klastab.
*             Retransfer them to klastab when returning to
*             overview screen.
*----------------------------------------------------------------------*
form ok_neuz.

  data: l_lines like sy-tabix,
        l_obtab like rmclf-obtab.


  check classif_status <> c_display.

  perform authority_check_classify
          using    sokcode
                   kreuz
                   space                                       "1847519
          changing g_subrc.
  if g_subrc <> 0.
    exit.
  endif.

  clear fname.
  case g_zuord.
    when c_zuord_4.
      if g_sel_changed <> space.
*       code AL_CREATE: adding only new allocations:
*       prevent calling existing alloc's from database.
*       clfm_objects_cl never called until now.
*       redun possibly set in set-klart.
        clear g_sel_changed.
        refresh redun.
        g_only_new_entries = kreuz.
        perform call_clfm_function
                using c_change.
      endif.

      if g_obj_scr <> space or g_cls_scr <> space.
*       already in screen for sel. object: just add empty lines
        rmclf-pagpos = rmclf-paganz.
        clear fname.
        if rmclf-paganz is initial.
          index_neu = 1.
          zeile = 1.
        else.
          index_neu    = rmclf-paganz.
          zeile = 2.
        endif.
      else.

        clear anzzeilen.
        pag_page     = 1.
        pag_pages    = 1.
        index_neu    = 1.
        if zeile = 0.                  "Einfügen der neuen Zu-
          describe table klastab lines zeile.
          message s515.
          altzeile = zeile + index_neu - 1.    "merken Cursorpos
          read table klastab index altzeile.    "lesen klastab
          altzeile = altzeile + 1.     "merken Cursorpos
          szaehl = klastab-zaehl.
          hzaehl = klastab-zaehl + 100.
          szeile = altzeile.
          xzeile = altzeile.
        else.
          altzeile = zeile + index_neu - 1.    "merken Cursorpos
          read table klastab index altzeile.    "lesen klastab
          szeile = altzeile.
          xzeile = altzeile.
          hzaehl = klastab-zaehl.      "merken Zähler
          if altzeile = 1.             "Cursor auf 1.Zeile pos.
            szaehl = 0.
            altzeile = 0.
          else.                        "nein
            altzeile = altzeile - 1.   "vorheriger Eintrag in klastab
            read table klastab index altzeile.  "lesen
            szaehl = klastab-zaehl.
          endif.
        endif.

*       select object type to be listed
        perform select_alloc_objtype
                using    multi_obj
                changing l_obtab.

        zeile = 0.
        clear rmclf-paganz.
        rmclf-pagpos = 0.
        if not l_obtab is initial.
*         new subscreen for objects
          sokcode      = okeint.
          sobtab       = redun-obtab.
          g_cls_scr    = space.
          g_obj_scr    = kreuz.
          if g_alloc_dynlg is initial.
            g_alloc_dynnr = dynp1612.
          else.
            g_alloc_dynnr = dynp1512.
          endif.
        else.
*         new subscreen for classes
          if multi_obj = kreuz.
            sobtab = pobtab.
          endif.
          if clhier is initial.
            message e571 with rmclf-klart.
          endif.
          g_cls_scr    = kreuz.
          g_obj_scr    = space.
          if g_alloc_dynlg is initial.
            g_alloc_dynnr = dynp1610.
          else.
            g_alloc_dynnr = dynp1510.
          endif.
        endif.

*       build new klastab: subset of overview
*       - save current klastab
*       - new objects in klastab
*       - klastab changed -> update index table
        g_klastab_sav[] = klastab[].
        if g_obj_scr is initial.
*         classes
          mafid = mafidk.
          delete klastab where obtab <> space.
        else.
*         objects
          mafid = mafido.
          delete klastab where obtab <> sobtab.
        endif.
        perform rebuild_obji.
      endif.

* object to classes , class to classes , from object
    when others.
      if multi_class <> kreuz.         "Mehrfachklassifi. erlaubt
        message s528.                  "NEIN ---> EXIT
      else.
        clear anzzeilen.
        clear rmclf-paganz.
        pag_page     = 1.
        pag_pages    = 1.
        rmclf-pagpos = 0.
        index_neu    = 1.
      endif.
  endcase.

* create empty lines for table controls
* Für die weitere Bearbeitung wird OK-Code wie bei
* "Neue Einträge" (EINT) gesetzt. Siehe PBO-module !
  clear klastab.
  sokcode = okeint.
  clear zeile.

  leave screen.

endform.                               " ok_NEUZ
