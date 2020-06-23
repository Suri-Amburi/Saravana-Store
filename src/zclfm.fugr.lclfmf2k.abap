form build_viewtab using clint  like ksml-clint
                         klasse type c.

  data: l_subrc like sy-subrc,
        l_atinn_udef like ksml-imerk,                       "45A
        l_atinn like tatinn occurs 0 with header line.

  read table viewk with key
                        klart = rmclf-klart
                        class = klasse
                        transporting no fields.
  if sy-subrc > 0.
    clear   iksml.
    refresh iksml.
    iksml-clint = clint.
    append iksml.

    if rmclf-datuv1 is initial.
      iksml-datuv = syst-datum.
    else.
      iksml-datuv = rmclf-datuv1.
    endif.
    call function 'CLSE_SELECT_KSML'
         exporting
              key_date       = iksml-datuv
              i_aennr        = rmclf-aennr1
         tables
              imp_exp_ksml   = iksml
         exceptions
              no_entry_found = 04.
    if syst-subrc = 0.
      loop at iksml.
        if not iksml-imerk is initial.
          read table viewk with key
                                klart = rmclf-klart
                                class = klasse
                                merkm = iksml-imerk binary search.
          if syst-subrc > 0.
            viewk-klart = rmclf-klart.
            viewk-class = klasse.
            viewk-merkm = iksml-imerk.
            viewk-posnr = iksml-posnr.
            viewk-omerk = iksml-omerk.
            viewk-abtei = iksml-abtei.
            viewk-udeff = iksml-dptxt.
            clear viewk-udefm .
            insert viewk index syst-tabix.
            if viewk-udeff = 'X'.
*           Udef auflösen: für die spätere Suche in allausp müssen
*           in viewk die Basismerkmale mit den atinn's aus AUSP
*           verwendet werden, nicht die imerk's aus KSML !
*-- Merken, welche ATINN das UDEF selber hatte und im u.g. Merkmal halte
              l_atinn_udef = iksml-imerk.
              perform expand_udef
                      tables l_atinn
                      using  iksml-imerk   l_subrc.
              loop at l_atinn.
                read table viewk with key
                                 klart = rmclf-klart
                                 class = klasse
                                 merkm = l_atinn-atinn  binary search.
                if sy-subrc > 0.
                  viewk-merkm = l_atinn-atinn.
                  clear viewk-udeff.
                  viewk-udefm = l_atinn_udef.
                  append viewk.
                endif.
              endloop.
            endif.
          endif.
        endif.
      endloop.
    else.
      read table viewk with key
                            klart = rmclf-klart
                            class = klasse
                            merkm = space binary search.
      clear viewk.
      viewk-klart = rmclf-klart.
      viewk-class = klasse.
      if syst-subrc > 0.
        insert viewk index syst-tabix.
      endif.
    endif.
  endif.

endform.                               " build_viewtab
