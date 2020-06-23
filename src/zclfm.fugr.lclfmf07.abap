*&---------------------------------------------------------------------*
*&      Form  OKB_UEB_BILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_ueb_bild .

  if g_cl_ta is initial.               " Objekttransaktion
    perform beenden.
  else.                                " in CL2* - Transaktion
    pag_page     = 1.
    pag_pages    = 1.
    rmclf-pagpos = 1.
    index_neu    = 1.
    zeile = 0.

    case g_zuord.
      when c_zuord_4.
*       objects of a class
*       counter action to ok_neuz (subset screen):
*       - rebuild saved klastab
*       - klastab changed -> update index table
        klastab[] = g_klastab_sav[].
        perform rebuild_obji.
        clear g_cls_scr.
        clear g_obj_scr.
        describe table klastab lines rmclf-paganz.
        anzzeilen = rmclf-paganz.
        if reorgflag = kreuz.
          perform sort_save.
        endif.
        if anzzeilen > 0.
          set screen dy511.
        else.
          clear anzzeilen.
          clear rmclf-paganz.
          pag_page     = 1.
          pag_pages    = 1.
          rmclf-pagpos = 0.
          index_neu    = 1.
          if g_obj_scr is initial.
            clear klastab.
            do anzloop times.
              append klastab.
            enddo.
          endif.
          leave screen.
        endif.

      when others.
*       Menue:   'Mat. zu Klassen' , 'Klasse zu Klassen'
        loop at klastab.
          check klastab-index_tab gt 0 .
          read table allkssk index klastab-index_tab.
          if allkssk-vbkz eq c_insert.
            perform rekursion_pruefen using
                    allkssk-class rmclf-clasn sy-subrc .
            if sy-subrc eq 1.
              message e513 with allkssk-klart allkssk-class.
            endif.
          endif.
          g_clint = pm_clint.
          clear klastab-markupd.
          clear klastab-statuaen.
          klastab-lock  = kreuz.
          modify klastab index g_klastab_akt_index.
          pm_clint = g_clint .
        endloop.
        describe table klastab lines rmclf-paganz.
        anzzeilen = rmclf-paganz.

        if anzzeilen > 0.
          set screen dy500.
        else.
          clear klastab.
          if multi_class is initial.
            append klastab.
          else.
            do 20 times.
              append klastab.
            enddo.
          endif.
          clear anzzeilen.
          clear rmclf-paganz.
          rmclf-pagpos = 0.
          leave screen.
        endif.
    endcase.                           " case g_zuord

    clear: save_objek,
           save_clint.
    loop at klastab.
      if klastab-stdcl = kreuz.
        save_objek = rmclf-objek.
        save_clint = klastab-clint.
        standardclass = klastab-objek.
      endif.
    endloop.
    if g_zuord = c_zuord_0 or g_zuord = c_zuord_2 .
      loop at allkssk where objek = rmclf-objek
                        and klart = rmclf-klart.
        if allkssk-objek = save_objek and
           allkssk-clint = save_clint.
          allkssk-stdcl = kreuz.
          modify allkssk index syst-tabix.
          exit.
        endif.
      endloop.
    endif.
    clear klastab.
    leave screen.
  endif.

endform.                               " OKB_UEB_BILD
