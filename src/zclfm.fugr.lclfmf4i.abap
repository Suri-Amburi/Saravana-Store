*&---------------------------------------------------------------------*
*&      Form  ok_weit
*&---------------------------------------------------------------------*
*       Called after ok_weit. Only CL** transactions.
*       Go back to overview screen.
*----------------------------------------------------------------------*
form ok_weit.

  check not g_cl_ta is initial.        " only CL** transactions
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
*       - clear's and perform in this oreder !
      clear g_cls_scr.
      clear g_obj_scr.
      perform recover_klastab using g_cls_scr g_obj_scr.
      describe table klastab lines rmclf-paganz.
      anzzeilen = rmclf-paganz.
      if reorgflag = kreuz.
        perform sort_save.
      endif.

      if g_alloc_dynlg is initial.
        g_alloc_dynnr = dynp1611.      " overview subscreen
      else.
        g_alloc_dynnr = dynp1511.      " overview subscreen
      endif.
      leave screen.

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
  endcase.                             " case g_zuord

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

endform.                               " ok_weit
