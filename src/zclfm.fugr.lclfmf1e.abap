*&---------------------------------------------------------------------*
*&      Form  ALLAUSP_NEW_FILL
*&---------------------------------------------------------------------*
*       Diese Form füllt die Workarea ALLAUSP unter Verwendung von SEL
*       Darf nur innerhalb ALLAUSP_NEW verwendet werden
*----------------------------------------------------------------------*
*  SEL-Eintrag muß positioniert sein
*----------------------------------------------------------------------*
form allausp_new_fill.

  data:
    l_adzhl         like ausp-adzhl,
    l_atzhl         like ausp-adzhl,
    l_aennr         like ausp-aennr,
    l_statu         like kssk-statu,
    new_atzhl       type i,
    p_subrc         like sy-subrc,
    p_tabix         like sy-tabix.
  field-symbols:
    <lf_ausp>       like allausp.

* Search existing entry in ALLAUSP

  if not sel-atzhl is initial.
    read table allausp assigning <lf_ausp>
                       with key
                      objek = pm_objek
                      atinn = sel-atinn
                      atzhl = sel-atzhl
                      klart = rmclf-klart
                       mafid = mafid
                       statu = hinzu.
    p_subrc = sy-subrc.
    p_tabix = sy-tabix.
    if sy-subrc is initial.
      l_atzhl = <lf_ausp>-atzhl.
      l_adzhl = <lf_ausp>-adzhl.
      l_aennr = <lf_ausp>-aennr.
      l_statu = <lf_ausp>-statu.
    else.                                                      "2564203
      l_atzhl = 1.                                             "2564203
      l_statu = hinzu.                                         "2564203
    endif.

  else.
    if sel-atein is initial.
*     Merkmal mehrwertig
*     ATZHL: bei mehrwertigen Merkmalen wird mit 2 begonnen!
*     Löschsatz nicht überschreiben für Änd.dienst: in VB lkenz = X.
      p_subrc = 8.
      p_tabix = 0.
      new_atzhl = 2.
      loop at allausp assigning <lf_ausp>
                      where objek = pm_objek
                        and atinn = sel-atinn
                        and klart = rmclf-klart
                        and mafid = mafid.
        if new_atzhl < <lf_ausp>-atzhl.
*         gap found: take this new_atzhl
          p_tabix = sy-tabix.
          exit.
        else.
          if new_atzhl = <lf_ausp>-atzhl.
            new_atzhl = new_atzhl + 1.
          endif.
        endif.
      endloop.
      if new_atzhl < 1000.
        l_atzhl = new_atzhl.
      else.
        clear l_atzhl.
      endif.
      sel-atzhl = l_atzhl.
      l_statu   = hinzu.

    else.
*     Merkmal einwertig
*     ADZHL initial: Flag für VB, wie neuer ATZHL zu vergeben ist.
      read table allausp assigning <lf_ausp>
                         with key
                        objek = pm_objek
                        atinn = sel-atinn
                        klart = rmclf-klart
                              mafid = mafid.
      p_subrc = sy-subrc.
      p_tabix = sy-tabix.
      if sy-subrc = 0.
        if <lf_ausp>-statu = loeschen.
*         statu = L:
          p_tabix = 0.
          read table allausp assigning <lf_ausp>
                             with key
                       objek = pm_objek
                       atinn = sel-atinn
                       klart = rmclf-klart
                       mafid = mafid
                                  statu = hinzu.
          p_subrc = sy-subrc.
          p_tabix = sy-tabix.
          if sy-subrc = 0.
*           L- und H-Satz: H-Satz überschreiben
            l_adzhl = <lf_ausp>-adzhl.
            l_atzhl = <lf_ausp>-atzhl.
            l_aennr = <lf_ausp>-aennr.
          else.
*           nur L-Satz vorhanden: H-Satz hinzufügen
            l_atzhl = 1.
          endif.
        elseif <lf_ausp>-statu = hinzu.
*         nur H-Satz , z.B. in MM01 mit Vorlage:
*         H-Satz wurde nochmal geändert: Satz überschreiben
          l_atzhl = <lf_ausp>-atzhl.
        endif.
      else.
*       H-Satz mit neuem atzhl hinzufügen
        l_atzhl = 1.
      endif.
      sel-atzhl = l_atzhl.
      l_statu   = hinzu.
    endif.                             " sel-atein
  endif.

* add new entry to allausp or overwrite
  if l_atzhl > 0.
    clear allausp.
    move-corresponding sel to allausp.
    allausp-adzhl = l_adzhl.
    allausp-atzhl = l_atzhl.
    allausp-statu = l_statu.
    if not l_aennr is initial.
*     AENNR nicht überschreiben, da die alte noch im VB gebraucht wird
      allausp-aennr = l_aennr.
    endif.
    allausp-objek = pm_objek.
    allausp-klart = rmclf-klart.
    allausp-mafid = mafid.
    allausp-obtab = sobtab.
    if pm_inobj is initial.
      clear allausp-cuobj.
    else.
      allausp-cuobj = pm_inobj.
    endif.

    if p_subrc is initial.
*     overwrite existing entry
      modify allausp index p_tabix.
    else.
      clear allausp-aennr.
      if p_tabix > 0.
        insert allausp index p_tabix.
      else.
        append allausp.
      endif.
    endif.
*   update atzhl, adzhl
    modify sel.
  else.
    delete sel. "#EC *
  endif.

endform.                               " ALLAUSP_NEW_FILL
