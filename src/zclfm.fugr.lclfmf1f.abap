*&---------------------------------------------------------------------*
*&      Form  ALLAUSP_NEW
*&---------------------------------------------------------------------*
*       Die Tabelle SEL wird in die Tabelle ALLAUSP nach der Logik
*       "eingemischt", daß es keine (!) zukünftigen Löschsätze
*       geben muss.
*----------------------------------------------------------------------*
*       Gobale Tabellen: SEL und ALLAUSP
*----------------------------------------------------------------------*

form allausp_new.

  data: l_subrc like sy-subrc,
        l_tabix like sy-tabix.

*-- sel: Sortierung so, daß zunächst die gelöschten bearbeitet werden,
*-- anschl. die hinzugefügten - wg. Wiederverwendung der ATZHL
  sort sel by atinn statu descending atzhl descending.

* ALLAUSP has not the sort order as it would be necessary      v 2174518
* for processing with setting AUSP_NEW
* and could herein not permanently be kept in sorted state,
* -> improve performance by:
*    - work only on data of currently processed object, see PM_OBJEK
*    - thereafter sort this subset
*    - reintegrate this subset to ALLAUSP

  DATA: l_ausp_back   LIKE TABLE OF allausp WITH HEADER LINE,
        l_cnt_sel     TYPE i,
        l_cnt_ausp    TYPE i,
        l_obj_start   TYPE sy-tabix,
        l_obj_end     TYPE sy-tabix.


  DESCRIBE TABLE sel     LINES l_cnt_sel.
  DESCRIBE TABLE allausp LINES l_cnt_ausp.
  IF l_cnt_sel >= 5 AND l_cnt_ausp >= 1000.

*   backup of valuations
    l_ausp_back[] =  allausp[].
    CLEAR allausp[].

*   start of subset ...
    READ TABLE l_ausp_back WITH KEY objek = pm_objek
      TRANSPORTING NO FIELDS BINARY SEARCH.

*   the start index is needed even if no valuations exist
*   to be able to insert valuations that still will be created
    l_obj_start = sy-tabix.
    IF sy-subrc IS INITIAL.

*     ... end of subset ...
      LOOP AT l_ausp_back FROM l_obj_start WHERE objek = pm_objek.
        AT END OF objek.
          l_obj_end = sy-tabix.
        ENDAT.
      ENDLOOP.

*     ... move subset for processing of valuations to ALLAUSP
      APPEND LINES OF l_ausp_back FROM l_obj_start TO l_obj_end
        TO allausp.
      DELETE l_ausp_back FROM l_obj_start TO l_obj_end.

    ENDIF.
  ENDIF.                                                      "^ 2174518

  loop at sel.

    if sel-attab <> space.
*     attab: master or text table, e.g. MARA or MAKT
      read table redun with key obtab = sobtab.
      if redun-redun = space.
*       do not take over ref. characteristics
        clear sel-statu.
        modify sel transporting statu.
        continue.
      endif.
    endif.

    case sel-statu.
*----------------------- Hinzu --------------------*
      when hinzu .
*--     Wert echt neu oder geändert
        perform allausp_new_fill.

      when loeschen .
*----------------------- Loeschen  -----------------*
*-- Nach Satz in ALLAUSP suchen
        read table allausp with key
                          objek = pm_objek
                          atinn = sel-atinn
                          atzhl = sel-atzhl
                          klart = rmclf-klart
                          mafid = mafid .
        if sy-subrc = 0.
          if sel-atzhl is initial and sel-statu <> loeschen.   "1126765
            if allausp-statu <> loeschen .
*             Nur aus ALLAUSP löschen
              delete allausp index sy-tabix.
            endif.
          else.
            allausp-statu = loeschen .
            if g_zuord eq c_zuord_4 and tcd_stat eq kreuz.
              if allausp-updat is initial.
                allausp-updat = kreuz.
              endif.
            endif.
            modify allausp index sy-tabix.
          endif.
        else.
*         Kein Eintrag in allausp: Löschsatz aus sel übernehmen.
*         Möglich, wenn von CACL_* kommend !
*         Achtung: sel mit statu <> ' ' enthält KEINE aennr !
*         Diese wird im Verbucher hinzugefügt.
          move-corresponding sel to allausp.
          allausp-objek = pm_objek.
          allausp-klart = rmclf-klart.
          allausp-mafid = mafid.
          allausp-delkz = space.
          allausp-obtab = sobtab.
          allausp-statu = loeschen.
          if not pm_inobj is initial.
            allausp-cuobj = pm_inobj.
          endif.
          append allausp.
        endif.

      when others   .
*----------------------- Nichts passiert/geändert --------------*
        read table allausp with key
                                objek = pm_objek
                                atinn = sel-atinn
                                atzhl = sel-atzhl
                                klart = rmclf-klart
                                mafid = mafid .
        if sy-subrc > 0.
          l_subrc = sy-subrc.
          l_tabix = sy-tabix.
          clear allausp.
          move-corresponding sel to allausp.
          allausp-objek = pm_objek.
          allausp-klart = rmclf-klart.
          allausp-mafid = mafid.
          allausp-obtab = sobtab.
          if not pm_inobj is initial.
            allausp-cuobj = pm_inobj.
          endif.
          if g_zuord eq c_zuord_4 and tcd_stat eq kreuz.
            if allausp-updat is initial.
              allausp-updat = kreuz.
            endif.
          endif.
          if l_tabix gt 0 .
            insert allausp index l_tabix .
          else.
            append allausp.
          endif.
        endif.

    endcase.
  endloop.

*-- wieder "normal" sortieren
  sort sel by atinn atzhl .
  sort allausp by objek atinn atzhl klart mafid.

  IF NOT l_ausp_back[] IS INITIAL.                            "v 2174518
*   reintegrate processed subset
    INSERT LINES OF allausp INTO l_ausp_back INDEX l_obj_start.
    allausp[] = l_ausp_back[].
  ENDIF.                                                      "^ 2174518

endform.                               " ALLAUSP_NEW
