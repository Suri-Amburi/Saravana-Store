*&---------------------------------------------------------------------*
*&      Form  OPEN_FI_SFA
*&---------------------------------------------------------------------*
*  Für die Übertragung der Daten in SFA wird die OPEN-FI-Schnittstelle
*  genutzt.
*----------------------------------------------------------------------*
form open_fi_sfa.

  data: l_allkssk_tab like  rmclkssk occurs 0 with header line,
        l_allausp_tab like  rmclausp occurs 0 with header line,
        l_fmrc_tab    like  fmrfc    occurs 0 .

  field-symbols:
    <l_ausp>          type  rmclausp.

  check g_open_fi_sfa is initial.
  g_open_fi_sfa = kreuz.
*-- Abfrage, ob OPEN-FI aktiv
  call function 'BF_FUNCTIONS_FIND'
       exporting
            i_event       = '00004002'
       tables
            t_fmrfc       = l_fmrc_tab
       exceptions
            nothing_found = 1
            others        = 2.

  check sy-subrc is initial.

*-- Gültige Einträge in L_ALLAUSP_TAB ermitteln
  l_allkssk_tab[] = allkssk[].
  l_allausp_tab[] = allausp[].

*-- DELCL-Einträge als ALLKSSK-VBKZ=D anhängen
  loop at delcl.
    read table l_allkssk_tab transporting no fields
               with key objek = delcl-objek
                        clint = delcl-clint
                        klart = delcl-klart
                        mafid = delcl-mafid
                        vbkz  = c_delete.
    if sy-subrc > 0.
      move-corresponding delcl to l_allkssk_tab.
      l_allkssk_tab-vbkz = c_delete.
      append l_allkssk_tab .
    endif.
  endloop.

* only changed objects
  loop at l_allkssk_tab where vbkz  = space
                          and mafid = mafido.

*   Check whether we have at least one assignment for the      "2045076
*   same object with changes                                   "2045076
    loop at allkssk where objek = l_allkssk_tab-objek          "2045076
                      and klart = l_allkssk_tab-klart          "2045076
                      and mafid = l_allkssk_tab-mafid          "2045076
                      and vbkz  <> space.                      "2045076
      exit.                                                    "2045076
    endloop.                                                   "2045076
    if sy-subrc = 0.                                           "2045076
      continue.                                                "2045076
    endif.                                                     "2045076

    loop at l_allausp_tab assigning <l_ausp>
                          where objek = l_allkssk_tab-objek
                            and klart = l_allkssk_tab-klart
                            and mafid = l_allkssk_tab-mafid
                            and statu <> space.
      exit.
    endloop.
    if sy-subrc > 0.
      loop at l_allausp_tab assigning <l_ausp>
                            where objek = l_allkssk_tab-objek
                              and klart = l_allkssk_tab-klart
                              and mafid = l_allkssk_tab-mafid.
        delete l_allausp_tab.
      endloop.
      delete l_allkssk_tab.
    endif.
  endloop.

  sort l_allausp_tab by objek atinn atzhl mafid klart
                        statu .        "Space, H oder L

  delete adjacent duplicates from l_allausp_tab comparing
                                  objek atinn atzhl mafid klart .

  call function 'OPEN_FI_PERFORM_00004002_E'
       exporting
            i_ecm_no         = rmclf-aennr1
       tables
            i_delob_tab      = delob
            i_allocation_tab = l_allkssk_tab
            i_value_tab      = l_allausp_tab.

endform.                               " OPEN_FI_SFA
