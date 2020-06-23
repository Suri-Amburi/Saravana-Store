*---------------------------------------------------------------------*
*       FORM OK_AEBL                                                  *
*---------------------------------------------------------------------*
*       Änderungsbelege anzeigen                                      *
*---------------------------------------------------------------------*
form ok_aebl.

  data:
    l_obj_eq_inob,
    l_class        like klah-class,
    l_idx          like sy-stepl,
    l_objnr        like kssk-objek,
    l_tab          like tcla-obtab,
    l_language     like sy-langu,
    l_user_param   type clprof.

  if not g_val-objek is initial.
*   first save previous value assignment
    perform close_prev_value_assmnt changing g_subrc.
  endif.
  clear antwort.

  if g_zuord = c_zuord_4 or
     g_appl  = konst_w.
    if cn_mark > 0.
*     Es gibt Markierungen
      if cn_mark > 1.
*       Es gibt mehrere Markierungen
        message s482.
        exit.
      endif.
      clear cn_mark.
      clear fname.
      clear markzeile1.
      loop at klastab where markupd = kreuz.
        clear klastab-markupd.
        modify klastab.
        l_idx = sy-tabix.
      endloop.
    else.
      l_idx = index_neu + zeile - 1.
    endif.
    perform auswahl using antwort l_idx.
    if antwort = space.
      l_objnr = klastab-objek.
      l_class = allkssk-class.
    else.
      message s501.
      exit.
    endif.
  else.
    l_idx = index_neu + zeile - 1.
    if l_idx > 0.
      perform auswahl using antwort l_idx.
    else.
      read table allkssk with key objek = rmclf-objek
                                  klart = rmclf-klart
                                  mafid = mafid.
    endif.
    l_objnr = rmclf-objek.
    l_class = allkssk-class.
  endif.

    if mafid = mafidk.
      l_tab = 'KLAH'.
    else.
      l_tab = sobtab.
  endif.

* characteristic names: language dependent or neutral
  call function 'CLPR_GET_USER_DATA'
       importing
            e_clprof = l_user_param.
  if l_user_param-nchart is initial.
    l_language = sy-langu.
  else.
    clear l_language.
  endif.

* setup CTMS
  call function 'CTMS_CLASS_OBJECT_DDB'
       exporting
            class                    = l_class
            classtype                = rmclf-klart
            language                 = l_language
            objectid                 = l_tab
            object                   = l_objnr
            display                  = kreuz
              key_date                 = rmclf-datuv1
         EXCEPTIONS
              not_found                = 1
              no_allocation_to_classes = 2
              others                   = 3.

  call function 'CLLA_CHANGE_DOC_CLASSIFICATION'
       EXPORTING
            object       = l_objnr
            classtype    = rmclf-klart
            object_type  = l_tab
            obj_eq_cuobj = l_obj_eq_inob
       EXCEPTIONS
            no_data      = 1
            others       = 2.
  if sy-subrc = 1.
    message s686.
  endif.

* recall current valuation
  if g_val-objek is initial.
    call function 'CTMS_DDB_INIT'.
  else.
    if g_zuord = c_zuord_4.
      read table klastab with key objek = g_val-objek.
    else.
      read table allkssk with key class = g_val-class.
    endif.
    perform auswahl using antwort sy-tabix.
    perform classify.
  endif.

endform.                               "  ok_aebl
