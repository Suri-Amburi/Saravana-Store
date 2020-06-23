*---------------------------------------------------------------------*
*       FORM OKB_AEBL                                                  *
*---------------------------------------------------------------------*
*       Änderungsbelege anzeigen                                      *
*---------------------------------------------------------------------*
form okb_aebl.

  data: obj_eq_inob.
  data: objnr        like kssk-objek.
  data: tab          like tcla-obtab.

  if g_appl = konst_w or
     g_zuord = c_zuord_4 .
    zeile = zeile + index_neu - 1.
    if g_appl ne konst_w.
      read table g_obj_indx_tab index zeile.
      zeile = zeile - index_neu + 1.
      if syst-subrc ne 0.
        leave screen.
      endif.
      read table klastab index g_obj_indx_tab-index.
      if syst-subrc ne 0.
        leave screen.
      endif.
    else.
      read table klastab index zeile.
      zeile = zeile - index_neu + 1.
      if syst-subrc ne 0.
        leave screen.
      endif.
    endif.
    if klastab-mafid = mafidk.
      objnr = klastab-objek.
      tab   = 'KLAH'.
    else.
      if klastab-cuobj is initial.
        objnr = klastab-objek.
        tab   = klastab-obtab.
      else.
        objnr       = klastab-cuobj.
        tab         = klastab-obtab.
        obj_eq_inob = kreuz.
      endif.
    endif.
  else.
    objnr       = rmclf-objek.
    if mafid = mafidk.
      tab = 'KLAH'.
    else.
      tab = sobtab.
    endif.
  endif.

  call function 'CTMS_CLASS_OBJECT_DDB'
       exporting
            class                    = rmclf-clasn
            classtype                = rmclf-klart
            objectid                 = sobtab
            object                   = rmclf-objek
            key_date                 = rmclf-datuv1
       exceptions
            not_found                = 1
            no_allocation_to_classes = 2
            others                   = 3.

  call function 'CLLA_CHANGE_DOC_CLASSIFICATION'
       exporting
            object       = objnr
            classtype    = rmclf-klart
            object_type  = tab
            obj_eq_cuobj = obj_eq_inob
       exceptions
            no_data      = 1
            others       = 2.

  if sy-subrc = 1 and sy-binpt = space.
    message s686.
  endif.

endform.                               "  okb_aebl
