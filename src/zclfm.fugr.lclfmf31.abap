*---------------------------------------------------------------------*
*       FORM CHECK_KSSK_COUNT                                         *
*---------------------------------------------------------------------*
*       Prüfe ob schon mit Änderungsnummer gepfegt                    *
*---------------------------------------------------------------------*
form check_kssk_count using p_objekt like kssk-objek
                            p_klart like rmclklart-klart
                            p_mafid like kssk-mafid
                            p_tab   like tcla-obtab
                            p_inobnr like inob-cuobj
                            p_rc     like syst-subrc.
  data: l_inob like inob-cuobj,
        l_rc1 like syst-subrc.

  if not p_tab is initial.
    sobtab = p_tab.
  endif.

  kssk-objek = p_objekt.
  if not multi_obj is initial and
     p_mafid ne mafidk .
    if p_inobnr is initial.
      call function 'CUOB_GET_NUMBER'
           EXPORTING
                class_type       = p_klart
                object_id        = p_objekt
                table            = sobtab
           IMPORTING
                object_number    = l_inob
           EXCEPTIONS
                lock_problem     = 01
                object_not_found = 02.
      if syst-subrc = 2.
        clear p_rc.
        exit.
      endif.
      kssk-objek = l_inob.
      clear l_inob.
    else.
      kssk-objek = p_inobnr.
    endif.
  endif.
  clear l_rc1.
*-- Für Effectivity ist keine weitere Programmierung erforderlich,
*-- da hier nur auf Verwendung einer Änderungsnummer abgefragt wird.
  data: l_objek like kssk-objek.                              "  1013856
  select objek into l_objek from kssk up to 1 rows            "  1013856
    where objek eq kssk-objek
      and mafid eq p_mafid
      and klart eq p_klart
      and aennr ne space.
  endselect.
  if syst-dbcnt = 0.
    select objek into l_objek from ausp up to 1 rows          "  1013856
      where objek eq kssk-objek
        and mafid eq p_mafid
        and klart eq p_klart
        and aennr ne space.
    endselect.
    if syst-dbcnt > 0.
      l_rc1 = 4.
    endif.
  else.
    l_rc1 = 4.
  endif.
  p_rc = l_rc1.
endform.
