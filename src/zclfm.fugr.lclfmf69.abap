*----------------------------------------------------------------------*
*       FORM CHK_EXISTENCE
*----------------------------------------------------------------------*
*       Prüft die Existenz einer Klassenart
*----------------------------------------------------------------------*
*  -->  I_BATCH_I   Kennzeichen, ob Batch-Input aktiv
*       I_FLAG      KLassenart durch Parameter übergeben
*  <--  E_EXIT      Form durch EXIT verlassen
*----------------------------------------------------------------------*
form chk_existence using     value(i_batchi)
                             value(i_flag)
                changing     e_exit
                             e_ptable
                             e_table.

  data: l_dynpros(1),
        l_intklart    like tcla-intklart,
        l_okcode      like sy-ucomm,
        l_ptable      like tclao-obtab,
        l_subrc       like sy-subrc,
        l_typetext    like rmclf-artxt.

  if not i_flag is initial.
*-- Klassenart kam aus Memory
    sobtab = e_table.
  endif.
  call function 'CLCA_PROCESS_CLASSTYPE'
       exporting
            classtype     = rmclf-klart
            mode          = zwei
            dynpros       = space
            batchi        = i_batchi
            table         = e_table
            ptable        = e_ptable
       importing
            classtype     = rmclf-klart
            typetext      = rmclf-artxt
            multi_classif = multi_class
            mult_obj      = multi_obj
            imptcla       = tcla
            interntype    = l_intklart
            table         = e_table
            ptable        = e_ptable
            ok_abbr       = l_okcode
       exceptions
            not_found     = 1
            no_auth_klart = 2
            others        = 3.
  l_subrc = sy-subrc.

*-- Auswertung nach Aufruf
  if syst-binpt = kreuz  .
*-- ... für Batch-Input
    clear l_okcode.
    if rmclf-klart is initial.
      e_exit = kreuz.
      exit.
    else.
*-- Noch prüfen bzw. nachlesen, falls TCLA nicht gefült ist
      if tcla-klart is initial.
        select single * from tcla
          where klart = rmclf-klart.
      endif.
    endif.

  else.
*-- ... sonst
    if not i_flag  is initial.
*-- Wert kam über Parameter
      clear l_okcode.
      if l_intklart = kreuz.
        message s556 with rmclf-klart.
        clear rmclf-klart.
        set parameter id c_param_kar field space.
        e_exit = kreuz.
        exit.
      endif.
*-- Nach dem vorherigen Aufruf der CLCA kann entweder SOBTAB <> TABLE
*-- oder eine Exception ausgelöst sein
      if sobtab ne e_table or
         not l_subrc is initial.
        if sobtab ne e_table.
*         andere Tabelle durch CHECK ermittelt
          e_table = sobtab.
          clear sobtab.
        else.
*-- Exception ausgelöst!
*-- Tabellen sind gleich, aber Returncode aus CHECK
          if l_subrc = 1 or l_subrc = 2.
            clear sobtab.
            if l_subrc = 1.
              message s014 with rmclf-klart. "Klassenart nicht in TCLA
              clear rmclf-klart.       "die Klassenart ermitteln
            else.
              message s545 with rmclf-klart  "Berechtigung Klassenart
                                raising no_auth_klart.
            endif.
          endif.
        endif.

        call function 'CLCA_PROCESS_CLASSTYPE'
             exporting
                  classtype     = rmclf-klart
                  mode          = zwei
                  dynpros       = kreuz
                  batchi        = i_batchi
                  table         = e_table
                  ptable        = l_ptable
             importing
                  classtype     = rmclf-klart
                  typetext      = rmclf-artxt
                  multi_classif = multi_class
                  mult_obj      = multi_obj
                  imptcla       = tcla
                  interntype    = l_intklart
                  table         = e_table
                  ptable        = l_ptable
                  ok_abbr       = l_okcode
             exceptions
                  not_found     = 1
                  no_auth_klart = 2
                  others        = 3.
        l_subrc = sy-subrc.

        clear l_ptable.
        if l_okcode = okabbr.
          clear : okcode,sokcode.
          e_exit = kreuz.
          exit.
        endif.
        if l_subrc = 2.
          message s546 raising no_auth_klart.
          e_exit = kreuz.
          exit.
        endif.
        if rmclf-klart is initial.
          e_exit = kreuz.
          exit.
        endif.
      endif.
    else.
*-- Wert kam über Schnittstelle
      clear l_okcode.
      if l_subrc = 1 or l_subrc = 2.
        if l_subrc = 1.
          message s014 with rmclf-klart.   "Klassenart nicht in TCLA
          clear rmclf-klart.
          e_exit = kreuz.
          exit.
        else.
          message s545 with rmclf-klart"Berechtigung Klassenart
                        raising no_auth_klart.
          clear rmclf-klart.                                   "2160455
          e_exit = kreuz.
          exit.
        endif.
      endif.
    endif.
  endif.

endform.
