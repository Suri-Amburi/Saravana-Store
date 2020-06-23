*---------------------------------------------------------------------*
*       FORM FUELLEN_ALE_TAB                                          *
*---------------------------------------------------------------------*
*       Der Pointer für ALE wird zusammengestellt                     *
*---------------------------------------------------------------------*
form fuellen_ale_tab using objekt like kssk-objek
                           obtab  like inob-obtab
                           mafid  like kssk-mafid
                           klart  like kssk-klart
                           aennr  like kssk-aennr.

  data:
    l_tabix                  type sy-tabix,
    l_ale_fldname            type bdi_chptr-fldname,
    l_dont_write_pointer     like rctmv-mark.  "kein Änderungspointer

  clear g_tabkey .
  g_tabkey-mafid  = mafid.
  g_tabkey-klart  = klart.
  g_tabkey-objek  = objekt.
  g_tabkey-aennr  = aennr.
  l_ale_fldname   = g_ale_datuv.

  read table ale_stru with key
                      tabname = obtab                       "153368
                      tabkey  = g_tabkey
                      fldname = l_ale_fldname
                      transporting no fields
                      binary search.
  if sy-subrc > 0.
    l_tabix = sy-tabix.
    clear ale_stru.
    ale_stru-tabname = obtab.
    ale_stru-tabkey  = g_tabkey.
    ale_stru-fldname = l_ale_fldname.
    ale_stru-cdobjcl = 'CLASSIF'.
*   cdchgid: used as flag to create change pointer once
    ale_stru-cdchgid = kreuz.

*   Nicht ausführen bei Klassenarten 13,14,29,36,40
    if not klart eq '013' and                               "31I
       not klart eq '014' and                               "31I
       not klart eq '029' and                               "31I
       not klart eq '036' and                               "31I
       not klart eq '040' .                                 "31I

      call function 'OPEN_FI_PERFORM_00004005_E'
           exporting
                i_classtype          = klart
                i_object             = objekt
                i_alloctype          = mafid
           importing
                e_dont_write_pointer = l_dont_write_pointer.
      if l_dont_write_pointer is initial.
        insert ale_stru into ale_stru index l_tabix.
      endif.
    endif.
  endif.

* BW
  read table gt_ale_stru_clbw with key
                              tabname = obtab               "153368
                              tabkey  = g_tabkey
                              fldname = l_ale_fldname
                              transporting no fields
                              binary search.
  if sy-subrc > 0.                     "   note: 323412
    insert ale_stru into gt_ale_stru_clbw index syst-tabix.
  endif.

endform.                    "fuellen_ale_tab

*---------------------------------------------------------------------*
*       FORM SCHREIBEN_ALE_TAB                                        *
*---------------------------------------------------------------------*
*       Der Pointer für ALE wird geschrieben                          *
*---------------------------------------------------------------------*
form schreiben_ale_pointer.

  data:
    l_funcname         like rs38l-name,
    mestyp             like edidc-mestyp   value 'CLFMAS',
    obtab              like tcla-obtab,"table of object
*--- table for objects in ALE-listings (used in ALE function)
    object_id          like clal_obj occurs 0 with header line,
    lt_ale_stru        like bdi_chptr occurs 0 with header line,
    lt_ale_stru_clbw   like bdi_chptr occurs 0 with header line.

*--- table for objects in ALE-listings
  data: begin of t_objects occurs 0,
          klart like kssk-klart,
          obtab like tcla-obtab,
          objek like kssk-objek,
        end of   t_objects.

  ranges:
    r_tcla for tcla-klart.

* CLFMAS
  loop at ale_stru where cdchgid = kreuz.
*   entry not used yet
    clear ale_stru-cdchgid.
    modify ale_stru transporting cdchgid.
    append ale_stru to lt_ale_stru.
  endloop.
  if sy-subrc = 0.
    call function 'CHANGE_POINTERS_CREATE_DIRECT'
         exporting
              message_type          = mestyp
         tables
              t_cp_data             = lt_ale_stru
         exceptions
              number_range_problems = 1
              others                = 2.
    if sy-subrc > 0.
      message a085(b1).
    endif.
  endif.

* R/3 with plug in system -> BW
  l_funcname = 'CTBW_BW_CHANGE_POINTERS'.
  call function 'FUNCTION_EXISTS'
       exporting
            funcname           = l_funcname
       exceptions
            function_not_exist = 1
            others             = 2.
  if sy-subrc > 0.
*   CRM -> BW
    l_funcname = 'PRBW_BW_CHANGE_POINTERS'.
    call function 'FUNCTION_EXISTS'
      exporting
        funcname           = l_funcname
      exceptions
        function_not_exist = 1
        others             = 2.
  endif.
  if sy-subrc = 0.
    loop at gt_ale_stru_clbw where cdchgid = kreuz.
      clear gt_ale_stru_clbw-cdchgid.
      modify gt_ale_stru_clbw transporting cdchgid.
      append gt_ale_stru_clbw to lt_ale_stru_clbw.
    endloop.
    if sy-subrc = 0.
      call function l_funcname
           tables
                it_ale_stru = lt_ale_stru_clbw
           exceptions
                others      = 1.
    endif.
  endif.

* ALE listing
  clear r_tcla.
  r_tcla-option = 'EQ'.
  r_tcla-sign   = 'I'.
  select klart from tcla into r_tcla-low
               where migration eq 'X'.
    append r_tcla.
  endselect.

  if sy-subrc = 0.

*--- copy objects for ALE listings
    loop at lt_ale_stru.
      g_tabkey = lt_ale_stru-tabkey.
      if g_tabkey-klart in r_tcla and
         g_tabkey-mafid = mafido.
        t_objects-klart = g_tabkey-klart.
        t_objects-obtab = lt_ale_stru-tabname.
        t_objects-objek = g_tabkey-objek.
        append t_objects.
      endif.
    endloop.

*--- write change pointers for ALE listings
    sort t_objects by obtab.
    clear obtab.
    loop at t_objects.
      if t_objects-obtab ne obtab.
        if not obtab is initial.

*... write change pointers for table OBTAB
          call function 'OBJECT_CREATE_CHANGE_POINTERS'
               exporting
                    object                = obtab
               tables
                    objectid              = object_id
               exceptions
                    object_not_supported  = 1
                    objectid_not_found    = 2
                    number_range_problems = 3
                    others                = 4.
        endif.                         " NOT OBTAB IS INITIAL
        refresh object_id.
      endif.                           " T_OBJECTS-OBTAB NE OBTAB

*... copy OBJEK
      obtab            = t_objects-obtab.
      object_id-object = t_objects-objek.
      append object_id.

    endloop.                           " AT T_OBJECTS.

*--- write change pointers for last table
    read table object_id index 1.
    if sy-subrc is initial.
      call function 'OBJECT_CREATE_CHANGE_POINTERS'
           exporting
                object                = obtab
           tables
                objectid              = object_id
           exceptions
                object_not_supported  = 1
                objectid_not_found    = 2
                number_range_problems = 3
                others                = 4.
    endif.                             " SY-SUBRC IS INITIAL
  endif.

endform.                    "schreiben_ale_pointer

*---------------------------------------------------------------------*
*       FORM SCHREIBEN_AEBELEG.                                       *
*---------------------------------------------------------------------*
*       Die Änderungsbelege werden geschrieben.                       *
*---------------------------------------------------------------------*
form schreiben_aebeleg.

  read table abkssk index 1.
  if syst-subrc = 0.
    perform aebeleg_ka.
  endif.
  read table abausp index 1.
  if syst-subrc = 0.
    perform aebeleg_a.
  endif.

endform.                    "schreiben_aebeleg

*---------------------------------------------------------------------*
*       FORM AEBELG_KA                                                *
*---------------------------------------------------------------------*
*       Die Änderungsbelege für KSSK und AUSP                         *
*---------------------------------------------------------------------*
form aebeleg_ka.

  data: begin of labkssk occurs 20.
          include structure vabkssk.
  data: end of labkssk.
*
  sort abkssk by objek.
  sort abausp by objek.
  tcode    = syst-tcode.
  utime    = syst-uzeit.
  udate    = syst-datum.
  username = syst-uname.
  upd_abkssk = konst_u.
  upd_abausp = konst_u.
  read table yabkssk index 1.
  if syst-subrc = 0.
    labkssk[] = yabkssk[].
    refresh yabkssk.
    sort labkssk by objek mafid clint.
  endif.

  loop at abkssk.
    on change of abkssk-objek.
      if syst-tabix > 1.
        objectid = objid.
        perform schreiben_doc.
        upd_abausp = konst_u.                                  "2538356
      endif.
      objid-objek = abkssk-objek.
      objid-mafid = abkssk-mafid.
*     loop: ausp changes get same objectid as kssk changes.
*     Then the change docs are displayed in one block (CLLA).
      loop at abausp where objek = abkssk-objek.
        if not abausp-atflv is initial.
*         write unit to change doc
*         interval: unit of 1. value (1 unit possible in cdpos)
          abausp-t006msehi = abausp-atawe.
        elseif not abausp-atflb is initial.
          abausp-t006msehi = abausp-ataw1.
        endif.
        case abausp-kz.
          when hinzu.
            clear abausp-kz.
            append abausp to xabausp.
            clear yabausp.
            if not abausp-atwrt is initial.
              yabausp-atcod = abausp-atcod.
            endif.
            yabausp-objek = abausp-objek.
            yabausp-mafid = abausp-mafid.
            yabausp-atinn = abausp-atinn.
            yabausp-atzhl = abausp-atzhl.
            append yabausp.
          when konst_i.
            clear abausp-kz.
            append abausp to xabausp.
          when konst_d.
            clear abausp-kz.
            append abausp to yabausp.
          when loeschen.
            clear abausp-kz.
            append abausp to yabausp.
            clear xabausp.
            if not abausp-atwrt is initial.
              xabausp-atcod = abausp-atcod.
            endif.
            xabausp-objek = abausp-objek.
            xabausp-mafid = abausp-mafid.
            xabausp-atinn = abausp-atinn.
            xabausp-atzhl = abausp-atzhl.
            append xabausp.
        endcase.
        delete abausp.
      endloop.
      if syst-subrc > 0.
        clear upd_abausp.
      endif.
    endon.

    if abkssk-kz = hinzu.
      abkssk-kz  = konst_i.
      append abkssk to xabkssk.
    else.
      clear abkssk-kz.
      append abkssk to xabkssk.
    endif.
    read table labkssk with key objek = abkssk-objek
                                mafid = abkssk-mafid
                                clint = abkssk-clint binary search.
    if syst-subrc = 0.
      append labkssk to yabkssk.
    endif.
  endloop.

  objectid = objid.
  perform schreiben_doc.

endform.                    "aebeleg_ka

*---------------------------------------------------------------------*
*       FORM AEBELG_A                                                 *
*---------------------------------------------------------------------*
*       Die Änderungsbelege für AUSP                                  *
*---------------------------------------------------------------------*
form aebeleg_a.

  sort abausp by objek.
  tcode    = syst-tcode.
  utime    = syst-uzeit.
  udate    = syst-datum.
  username = syst-uname.
  clear upd_abkssk.
  upd_abausp = konst_u.

  loop at abausp.
    on change of abausp-objek.
      if syst-tabix > 1.
        objectid = objid.
        perform schreiben_doc.
      endif.
    endon.
    objid-objek = abausp-objek.
    objid-mafid = abausp-mafid.
    if not abausp-atflv is initial.
*     write unit to change doc
*     interval: unit of 1. value (1 unit possible in cdpos)
      abausp-t006msehi = abausp-atawe.
    elseif not abausp-atflb is initial.
      abausp-t006msehi = abausp-ataw1.
    endif.
    case abausp-kz.
      when hinzu.
        clear abausp-kz.
        append abausp to xabausp.
        clear yabausp.
        if not abausp-atwrt is initial.
          yabausp-atcod = abausp-atcod.
        endif.
        yabausp-objek = abausp-objek.
        yabausp-mafid = abausp-mafid.
        yabausp-atinn = abausp-atinn.
        yabausp-atzhl = abausp-atzhl.
        append yabausp.
      when konst_i.
        clear abausp-kz.
        append abausp to xabausp.
      when konst_d.
        clear abausp-kz.
        append abausp to yabausp.
      when loeschen.
        clear abausp-kz.
        append abausp to yabausp.
        clear xabausp.
        if not abausp-atwrt is initial.
          xabausp-atcod = abausp-atcod.
        endif.
        xabausp-objek = abausp-objek.
        xabausp-mafid = abausp-mafid.
        xabausp-atinn = abausp-atinn.
        xabausp-atzhl = abausp-atzhl.
        append xabausp.
    endcase.
  endloop.
  objectid = objid.
  perform schreiben_doc.

endform.                    "aebeleg_a

*---------------------------------------------------------------------*
*       FORM SCHREIBEN_DOC.                                           *
*---------------------------------------------------------------------*
*       Die Änderungsbelege werden geschrieben.                       *
*---------------------------------------------------------------------*
form schreiben_doc.

  data:
    l_flag          type xfeld.

  sort xabausp.                                             "172609
  delete adjacent duplicates                                "172609
         from xabausp                                       "172609
         comparing all fields.                              "172609

  sort yabausp.                                             "172609
  delete adjacent duplicates                                "172609
         from yabausp                                       "172609
         comparing all fields.                              "172609

  call function 'CLASSIFY_WRITE_DOCUMENT'
    exporting
      objectid              = objectid
      tcode                 = tcode
      utime                 = utime
      udate                 = udate
      username              = username
      planned_change_number = planned_change_number
      no_change_pointers    = l_flag
      upd_abausp            = upd_abausp
      upd_abkssk            = upd_abkssk
    tables
      xabausp               = xabausp
      yabausp               = yabausp
      xabkssk               = xabkssk
      yabkssk               = yabkssk
    exceptions
      others                = 1.
  clear xabkssk.
  refresh xabkssk.
  clear yabkssk.
  refresh yabkssk.
  clear xabausp.
  refresh xabausp.
  clear yabausp.
  refresh yabausp.
endform.                    "schreiben_doc
