*§-----------------------------------------------------------------*
*        FORM LESEN_KSSK_INDEX                                     *
*------------------------------------------------------------------*
*        Lesen Zuordnungen zur Klasse (CL24)                       *
*        Form wird aufgerufen aus OBJECTS_CLASSIFICATION           *
*        oder WWS_CLASSIFICATION                                   *
*------------------------------------------------------------------*
form lesen_kssk_index
     using  wwstyp  type c
            wgrflag type c.

*-- l_auth_msg_obj: Ausgabe einer Message erforderlich
*-- l_no_auth_obj:  Nicht in klastab/ALLKSSK usw. übernehmen
  data  : l_auth_msg_obj  like rmclobtx-no_authority,
          l_no_auth_obj   like rmclobtx-no_authority.
  data  : l_first_rec.
  data  : l_tabelle like tcla-obtab.
  data  : l_smafid  like kssk-mafid.

  data  : begin of l_iswor occurs 0.
          include structure swor.
  data  : end   of l_iswor.

  data  : begin of l_iinob occurs 0.
          include structure rinob1.
  data  : end   of l_iinob.

  data  : l_obj1 like rmclobtx occurs 0 with header line.

  ranges: rstatu for kssk-statu.

* g_only_new_entries:
* = x  : cl24 in mode to insert only new entries.
*        allocations as in overview screen not desired now.
* space: Check whether new entries already exist.
*        Entries selected here will be appended to
*        already existing entries in allkssk/klastab.

  if g_only_new_entries is initial.
    describe table allkssk lines sy-tfill.
    if sy-tfill = 0.
*     <> 0: entries selected here will be appended to
*     already existing entries in allkssk/klastab.
      refresh klastab.
      refresh obj.
    endif.
    refresh iklah.
    clear   iklah.
  else.
    exit.
  endif.

*-- Zuordnungen zur Klasse werden gelesen
  call function 'CLSE_SELECT_KSSK_0'
       exporting
            mafid          = l_smafid
            klart          = rmclf-klart
            clint          = pm_clint
            refresh        = kreuz
            key_date       = rmclf-datuv1
       tables
            exp_kssk       = ikssk
       exceptions
            no_entry_found = 1.
  if syst-calld = kreuz.
    import rstatu from memory id 'RCCLSTA1STATUS'.
  endif.

  loop at ikssk.
    if syst-calld = kreuz.
      if not ikssk-statu in rstatu.
*-- ... falls rstatu durch obigen Import gefüllt
        delete ikssk.
        continue.
      endif.
    endif.
    if ikssk-mafid = mafidk.
      iklah-clint = ikssk-objek.
      append iklah.
    else.
      if multi_obj = kreuz.
        if ikssk-objek co '0123456789 '.
          l_iinob-cuobj = ikssk-objek.
          append l_iinob.
        else.
*-- ... O-HA: eine Inkonsistenz der DB wird einfach übergangen!
          delete ikssk.
        endif.
      else.
        obj-objek = ikssk-objek.
        append obj.
      endif.
    endif.
  endloop.

  describe table iklah lines syst-tfill.
  if syst-tfill ne 0.
    call function 'CLSE_SELECT_KLAH'
         tables
              imp_exp_klah   = iklah
         exceptions
              no_entry_found = 04.
    sort iklah by clint.
    loop at iklah.
      if wwstyp = kreuz.
*-- Sondercoding WWS
*-- ... es darf bei diesem Aufruf (aus ...CLASSIFICATION_H_H) nur
*-- zugeordnete Klassen mit WWSKZ = "0" geben.
        if iklah-wwskz ne '0'.
          wgrflag  = kreuz.
          exit.
        endif.
      endif.
      if classif_status ne drei.
        CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode           = 'E'
            iv_klart             = iklah-klart
            IV_CLASS             = iklah-class
          EXCEPTIONS
            FOREIGN_LOCK         = 1
            SYSTEM_FAILURE       = 2.
        case sy-subrc.                                     "end 1141804
          when 1.
            message e517.
          when 2.
            message e519.
        endcase.
      endif.
      l_iswor-mandt = sy-mandt.
      l_iswor-clint = iklah-clint.
      l_iswor-spras = syst-langu.
      l_iswor-klpos = eins.
      append l_iswor.
    endloop.
*-- Sonderlogik Retail
    if wgrflag  = kreuz.
*-- ... es gibt andere Zuordnungen: FORM verlassen
      exit.
    endif.
    call function 'CLSE_SELECT_SWOR'
         tables
              imp_exp_swor   = l_iswor
         exceptions
              no_entry_found = 04.
    sort l_iswor by clint.
  endif.

*----------------------------------------------------------------------
* Objekte checken: Kommentartext holen
*
  if multi_obj = kreuz.
    describe table l_iinob    lines syst-tfill.
  else.
    describe table obj      lines syst-tfill.
  endif.
  if syst-tfill ne 0.
    if multi_obj = kreuz.
      call function 'CUOB_GET_SOME_OBJECTS'
           tables
                objects = l_iinob.
      sort l_iinob by obtab.
      loop at l_iinob where obtab ne space
                      and obtab ne 'PBKO'
                      and obtab ne 'KMAT_NST'
                      and obtab ne 'KONDH'.
        if g_cl_ta <> space.
*         class transaction: remove objects with 'tracl' = x.
          read table redun with key obtab = l_iinob-obtab.
          if sy-subrc > 0.
            delete l_iinob.
            continue .
          endif.
        endif.

        if l_first_rec is initial.
          l_first_rec = kreuz.
          l_tabelle = l_iinob-obtab.
        else.
          if l_tabelle <> l_iinob-obtab.
            call function 'CLOCH_OBJECT_CHECK'
                 exporting
                      i_obtab          = l_tabelle
                      date_of_change   = rmclf-datuv1
                      i_auth_chk       = g_auth_obj_chk
                 tables
                      otab             = l_obj1
                 exceptions
                      foreign_lock     = 1
                      object_not_found = 2
                      system_failure   = 3
                      others           = 4.
            case sy-subrc.
              when 1.
                message e525 with syst-msgv1.
              when 2.
                message e504.
              when 3.
                message e519.
            endcase.
            append lines of l_obj1 to obj.
            clear   l_obj1.
            refresh l_obj1.
            l_tabelle = l_iinob-obtab.
          endif.
        endif.
        l_obj1-objek = l_iinob-objek.
        append l_obj1.
      endloop.
      sort l_iinob by cuobj.

*     letzten Block von Objekten prüfen
      if not l_obj1[] is initial.
        call function 'CLOCH_OBJECT_CHECK'
             exporting
                  i_obtab          = l_tabelle
                  date_of_change   = rmclf-datuv1
                  i_auth_chk       = g_auth_obj_chk
             tables
                  otab             = l_obj1
             exceptions
                  foreign_lock     = 1
                  object_not_found = 2
                  system_failure   = 3
                  others           = 4.
        append lines of l_obj1 to obj.
        sort obj by objek.
      endif.

    else.
*     multobj = ' '
      call function 'CLOCH_OBJECT_CHECK'
           exporting
                i_obtab          = sobtab
                date_of_change   = rmclf-datuv1
                i_auth_chk       = kreuz
           tables
                otab             = obj
           exceptions
                foreign_lock     = 1
                object_not_found = 2
                system_failure   = 3
                others           = 4.
      case sy-subrc.
        when 1.
          message e525 with syst-msgv1.
        when 2.
          message e504.
        when 3.
          message e519.
      endcase.

    endif.
  endif.

*----------------------------------------------------------------------
* Alle Zuordnungen gelesen, klastab etc aufbauen
*
  loop at ikssk.
    clear l_no_auth_obj .
    clear allkssk-oclint.
    clear allkssk.
    clear klastab.
    move-corresponding ikssk to allkssk.
    if ikssk-mafid = mafidk.
*-- Klasse-Klasse
      read table iklah with key
                            mandt = syst-mandt
                            clint = ikssk-objek binary search.
      if syst-subrc = 0.
        allkssk-objek   = iklah-class.
        allkssk-objtype = text-300.
        read table l_iswor with key
                              mandt = syst-mandt
                              clint = ikssk-objek binary search.
        if syst-subrc = 0.
          allkssk-kschl = l_iswor-kschl.
        else.
          clear allkssk-kschl.
        endif.
      else.
        continue.
      endif.
      allkssk-oclint = iklah-clint.

    else.
*-- Klasse-Objekt
      if multi_obj = kreuz.
        l_iinob-cuobj = allkssk-objek.
        read table l_iinob with key l_iinob-cuobj binary search.
        if sy-subrc > 0 or l_iinob-obtab = 'PBKO'.
          continue.
        endif.
        read table obj with key l_iinob-objek binary search.
        check syst-subrc = 0.
*-- Abfrage Berechtigung
        if obj-no_authority   is initial.
          allkssk-kschl = obj-obtxt.
          allkssk-cuobj = l_iinob-cuobj.
          allkssk-objek = l_iinob-objek.
          allkssk-obtab = l_iinob-obtab.
          read table redun with key l_iinob-obtab binary search.
          if syst-subrc eq 0.
            allkssk-objtype = redun-objtype.
          else.
            clear allkssk-objtype.
          endif.
        else.
          l_no_auth_obj  = kreuz.
          l_auth_msg_obj = kreuz.
        endif.
      else.
        read table obj with key allkssk-objek binary search.
        if syst-subrc = 0.
*-- Abfrage Berechtigung
          if obj-no_authority   is initial.
            allkssk-kschl = obj-obtxt.
*-- <length> kann leer sein
            allkssk-objtype = <length>.
            allkssk-obtab   = sobtab.
          else.
            l_no_auth_obj  = kreuz.
            l_auth_msg_obj = kreuz.
          endif.
        else.
          clear allkssk-kschl.
*-- <length> kann leer sein
          allkssk-objtype = <length>.
          allkssk-obtab   = sobtab.
        endif.
      endif.
    endif.

    check l_no_auth_obj  is initial.
    allkssk-clint    = pm_clint.
    allkssk-klart    = rmclf-klart.
    allkssk-class    = rmclf-clasn.
    allkssk-vbkz     = space.
    allkssk-sicht    = g_sicht_akt.
    allkssk-vwstl    = pm_vwstl.
    append allkssk.
    move-corresponding allkssk to klastab.
    klastab-index_tab = sy-tabix.      " hier wegen WWS
    append klastab.
  endloop.

  if not l_auth_msg_obj is initial
     and sy-binpt is initial
     and sy-calld is initial .
    message w647.
  endif.
  refresh ikssk.

endform.
