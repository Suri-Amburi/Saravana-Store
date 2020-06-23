*------------------------------------------------------------------*
*        FORM OK_INKONSI.                                        *
*------------------------------------------------------------------*
*        Inkonsistenzen beim Löschen Zuordnung festgestellt.       *
*------------------------------------------------------------------*

form ok_inkonsi.

  data: inob_lesen.
  data: inobj      like inob-cuobj.
  data: tabelle    like tclao-obtab.
  data: sindex     like index_neu.
  data: sanzzeilen like anzzeilen.
  data: sobject    like kssk-objek.
  data: xobject    like kssk-objek.
  data: xclass     like klah-class.
  data: begin of xatinn,
          atnam like iatinn-atnam,
          class like iatinn-class,
          mafid like iatinn-mafid,
          objek like iatinn-objek.
  data: end   of xatinn.

  sanzzeilen = anzzeilen.
  describe table iatinn lines anzzeilen.
  syst-tfill = anzzeilen.
  check syst-tfill > 0.
  if syst-tfill > 5.
    syst-tfill = 5.
  endif.
  x2 = 2 * syst-tfill + 7.
  sobject = rmclf-objek.
  xobject = rmcbc-objek.
  xclass  = rmcbc-class.
  if g_appl  = konst_w.
    move text-501 to rmcbc-class.
    move text-501 to rmcbc-objek.
  else.
    if tcltt-obtxt is initial.
      select single * from tcltt
        where spras = syst-langu
          and obtab = sobtab.
    endif.
    move text-500 to rmcbc-class.
    search tcltt-obtxt for '. .'.
    move tcltt-obtxt to rmcbc-objek(syst-fdpos).
    syst-fdpos = syst-fdpos + 1.
    move '/'         to rmcbc-objek+syst-fdpos(1).
    syst-fdpos = syst-fdpos + 2.
    move text-500    to rmcbc-objek+syst-fdpos(6).
  endif.
* Doppelte Einträge werden entfernt
  delete adjacent duplicates from iatinn comparing atnam class
                                                   mafid objek.
  if multi_obj is initial.
    select single * from tcla
      where klart = rmclf-klart.
    if tcla-multobj = kreuz.
      inob_lesen = kreuz.
      refresh redun.
      call function 'CLOB_SELECT_TABLE_FOR_CLASSTYP'
           EXPORTING
                classtype      = rmclf-klart
                spras          = syst-langu
           TABLES
                itable         = redun
           EXCEPTIONS
                no_table_found = 01.
    endif.
  else.
    inob_lesen = kreuz.
  endif.
  tabelle = sobtab.
  loop at iatinn where mafid = mafido.
    if inob_lesen = kreuz.
      inobj = iatinn-objek.
      call function 'CUOB_GET_OBJECT'
           EXPORTING
                object_number = inobj
           IMPORTING
                object_id     = iatinn-objek
                table         = tabelle
           EXCEPTIONS
                not_found     = 01.
      read table redun with key tabelle binary search.
      if syst-subrc = 0.
        iatinn-objtyp = redun-objtype.
      endif.
    else.
      iatinn-objtyp = tcltt-obtxt.
    endif.
    call function 'CLCV_CONV_EXIT'
         EXPORTING
              ex_object      = iatinn-objek
              table          = tabelle
         IMPORTING
              im_object      = iatinn-objek
         EXCEPTIONS
              tclo_not_found = 01.
    modify iatinn.
  endloop.
  sindex = index_neu.
  call screen 603 starting at 5 5
                  ending   at 79 x2.
  rmclf-objek = sobject.
  rmcbc-objek = xobject.
  rmcbc-class = xclass.
  index_neu   = sindex.
  anzzeilen   = sanzzeilen.
endform.                               " ok_inkonsi
