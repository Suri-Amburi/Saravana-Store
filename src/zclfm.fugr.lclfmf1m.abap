*§-----------------------------------------------------------------*
*        Form  STATUS_CHECK                                        *
*
* Checks consistency of allocation object/class - class.
* Sets classif. status cl_status_neu depending on
* result of ctms_ddb_check.
*------------------------------------------------------------------*
form status_check using i_klart.

  data: l_read_from_db(1) value 'X'.

  data: l_tabix like sy-tabix.
  data: begin of l_ghclx occurs 0.
          include structure ghcl.
  data: end of l_ghclx.
*-- Lokale SOBTAB (muß auch für KLASSE-KLASSE-Zuordnung genutzt werden)
  data: l_sobtab       like tcla-obtab.
  data: begin of lt_chars occurs 0.
          include structure api_char.
  data: end   of lt_chars.
  data: l_multi_class like tcla-mfkls.


  l_sobtab = sobtab.
  if mafid = mafidk.
*-- Klasse-zu-Klasse Zuordnung
    l_sobtab = c_klah .
  endif.

  read table iklart with key klart = i_klart.
  if sy-subrc is initial.
    l_multi_class = iklart-mfkls.
  else.
    read table redun with key obtab = sobtab.
    l_multi_class = redun-mfkls.
  endif.

*  if not l_multi_class is initial.                             "908388
    loop at ghcli where klart =  i_klart
                    and clas2 ne pm_class
                    and objek =  pm_objek
                    and delkz =  space.
      l_tabix = sy-tabix .
*-- Abgleich mit GHCLI-Löschsätzen
      read table ghcli with key klart = i_klart
                                clas2 = ghcli-clas2
                                objek = pm_objek
                                delkz = kreuz  binary search.
      if sy-subrc is initial.
*-- Aus beiden wieder löschen
        delete ghcli index sy-tabix.
        delete ghcli index l_tabix.
      else.
        move-corresponding ghcli to l_ghclx.
        append l_ghclx.
      endif.
    endloop.
    describe table l_ghclx lines l_tabix.
    if l_tabix gt 0 .

      call function 'CLHI_DDB_SET_MULTIPLE_CLASSES'
           tables
                new_multiple_classes = l_ghclx
           exceptions
                others               = 1.
    endif.
    refresh l_ghclx.
    loop at ghcli where klart =  i_klart
                    and clas2 ne pm_class
                    and objek =  pm_objek
                    and delkz =  kreuz .
      move-corresponding ghcli to l_ghclx.
      append l_ghclx.
    endloop.
    if sy-subrc is initial.

      call function 'CLHI_DDB_DEL_MULTIPLE_CLASSES'
           tables
                del_multiple_classes = l_ghclx
           exceptions
                others               = 1.
    endif.
*  endif.                                                       "908388

  read table delcl with key objek = pm_objek
                            klart = i_klart
                            mafid = mafid.
  if sy-subrc > 0.
    loop at allausp transporting no fields
                    where  objek =  pm_objek
                      and  klart =  i_klart
                      and  mafid =  mafid
                      and  statu <> space .
      exit.
    endloop.
  endif.

  if sy-subrc is initial.
*-- Puffer schon gefüllt: Nicht nachlesen von DB
    clear l_read_from_db.
  else.
    l_read_from_db = kreuz.
  endif.

  call function 'CTMS_CLASS_OBJECT_DDB'
       exporting
            class                    = pm_class
            classtype                = i_klart
            status                   = pm_status
            objectid                 = l_sobtab
            object                   = pm_objek
            key_date                 = rmclf-datuv1
            display                  = kreuz
            set_values_from_db       = l_read_from_db
            i_tabs_active            = kreuz                   "1447247
       exceptions
            not_found                = 1
            no_allocation_to_classes = 2
            others                   = 3.

  check syst-subrc = 0.
  if klas_pruef = konst_e or klas_pruef = konst_w
*-- ... auch, wenn g_consistency_chk gesetzt ist!!
     or not g_consistency_chk is initial.

    refresh sel.
    clear sel.
    loop at allausp where objek eq pm_objek
                      and klart eq i_klart
                      and mafid eq mafid
                      and statu ne loeschen.
      move-corresponding allausp to sel.
      append sel.
    endloop.
    read table sel index 1.
    if syst-subrc = 0.
      call function 'CTMS_DDB_OPEN'
           tables
                imp_selection = sel
           exceptions
                others        = 1.
    endif.
  endif.

  call function 'CTMS_DDB_SET_CHANGE_MODE'  .

  call function 'CTMS_DDB_CHECK'
       exceptions
            inconsistency  = 1
            incomplete     = 2
            verification   = 3
            not_assigned   = 4
            another_object = 5
            other_objects  = 6
            others         = 7.

  CLEAR g_consistency_chk.                                     "1415118
  if g_consistency_chk is initial.
*-- New with 31I
*-- Message ausgeben
    case sy-subrc.
      when 1.
*       if sy-binpt is initial.
        if sy-binpt is initial and g_from_api is initial       "1436346
          AND gv_no_message IS INITIAL.                        "1436346
          message id syst-msgid type syst-msgty number syst-msgno
                with syst-msgv1.
        endif.
        cl_status_neu = cl_statusus.
      when 2 or 4.
*           Muss-Merkmale zur Klasse existieren.
*       if sy-binpt is initial.
        if sy-binpt is initial and g_from_api is initial       "1436346
          AND gv_no_message IS INITIAL.                        "1436346
          message i500 with pm_objek.
        endif.
        cl_status_neu = cl_statusus.

      when 5 .
*       if sy-binpt is initial.
        if sy-binpt is initial and g_from_api is initial       "1436346
          AND gv_no_message IS INITIAL.                        "1436346
          perform clear_praus_error_level(saplctms).           "1747640
          message id syst-msgid type syst-msgty number syst-msgno
                with syst-msgv1.
        endif.
* change status accordingly                              "begin 1436346
        IF klas_pruef = konst_e.
          cl_status_neu = cl_statusus.
        ENDIF.                                             "end 1436346

      when 6.
*       if sy-binpt is initial.
        if sy-binpt is initial and g_from_api is initial       "1436346
          AND gv_no_message IS INITIAL.                        "1436346
          perform clear_praus_error_level(saplctms).           "1747640
          message id syst-msgid type syst-msgty number syst-msgno
                  with pm_objek .
        endif.
* change status accordingly                              "begin 1436346
        IF klas_pruef = konst_e.
          cl_status_neu = cl_statusus.
        ENDIF.                                             "end 1436346

    endcase.

    CLEAR gv_no_message.                                       "1436346

  else.
*-- ... nur Status setzen
    if not sy-subrc is initial.
      if sy-subrc eq 1 and
         sy-binpt is initial.
        message id syst-msgid type 'S' number syst-msgno
                with syst-msgv1.
      endif.
* identical classification found
      if sy-subrc ne 5 and sy-subrc ne 6.
        cl_status_neu = cl_statusus.
      else.
* check identical classification with error message
        if klas_pruef = konst_e.
          cl_status_neu = cl_statusus.
        endif.
      endif.
      if sy-subrc eq 2 or
         sy-subrc eq 4 .
*       'Muss-Merkmale zur Klasse existieren.'
        if sy-binpt is initial.
          message s500 with pm_objek.
        endif.
        cl_status_neu = cl_statusus.
      endif .
    endif.
    clear  g_consistency_chk.
  endif.

endform.
