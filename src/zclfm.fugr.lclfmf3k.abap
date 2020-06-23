*---------------------------------------------------------------------*
*       FORM BUILD_SEL_API                                            *
*---------------------------------------------------------------------*
*       Rebuild table sel from table allausp or database.
*       (Same algorithm as in form classify).
*---------------------------------------------------------------------*
form build_sel_api using
                   value(p_allkssk) like rmclkssk
                   p_mfkls          like sy-batch
                   p_aennr          like ausp-aennr
                   datum            like rmclf-datuv1
                   p_flags          like g_val_flags.
*
  data:
        l_datum       like ausp-datuv,
        l_klart       like tcla-klart,
        l_object      like kssk-objek, " plain text
        l_objek       like kssk-objek, " possibly cuobj number
        l_udef_rst    like sy-batch,
        l_select_ausp type c.

  data: iausp         like ausp occurs 0 with header line.


* set local variables
  l_klart  = p_allkssk-klart.
  l_object = p_allkssk-objek.
  if p_allkssk-mafid = mafidk.
    p_allkssk-obtab = c_klah.
  endif.
  l_datum = datum .
  if l_datum is initial.
    l_datum = sy-datum .
  endif.
  clear   sel.
  refresh sel.

  if p_flags-read_values is initial.
*   new allocation: valuations not existing yet
    l_udef_rst = kreuz.

  else.
*   check several tables if valuations are already read

    read table allausp with key objek = l_object
                                klart = l_klart
                                mafid = p_allkssk-mafid.
    if sy-subrc > 0.
      read table delcl with key mafid = p_allkssk-mafid
                                klart = l_klart
                                objek = l_object.
      if sy-subrc > 0.
        read table delob with key mafid = p_allkssk-mafid
                                  klart = l_klart
                                  objek = l_object.
        if sy-subrc > 0.
*       flag to read values from DB
          l_select_ausp = kreuz.
        endif.
      endif.
    endif.

*   build table sel

    if l_select_ausp is initial.
*   allausp -> sel
      loop at allausp where objek =  l_object
                        and klart =  l_klart
                        and mafid =  p_allkssk-mafid
                        and delkz =  space
                        and statu <> loeschen.
        move-corresponding allausp to sel.
        append sel.
*       be tolerant of applications using classification:
*       keep H-entries in allausp and check later in build_allausp
      endloop.

    else.
*   iausp from DB -> sel
      if p_allkssk-cuobj is initial.
        if p_allkssk-mafid = mafidk.
          l_objek = p_allkssk-oclint.
        else.
          l_objek = l_object.
        endif.
      else.
        l_objek = p_allkssk-cuobj.
      endif.
*     class type definition has already been read,              v 959222
*     but the header line may be initial -> set it
      read table IKLART with key KLART = L_KLART
        binary search.                                         "^ 959222
      call function 'CLFM_SELECT_AUSP'
        EXPORTING
          mafid              = p_allkssk-mafid
          classtype          = l_klart
          object             = l_objek
          key_date           = l_datum
          with_change_number = iklart-aediezuord
          i_aennr            = p_aennr
          i_atzhl_same_ini   = kreuz
        TABLES
          exp_ausp           = iausp
        EXCEPTIONS
          no_values          = 01.

      loop at iausp.
        clear sel.
        read table delcl with key
                              mafid = iausp-mafid
                              klart = iausp-klart
                              objek = l_object
                              merkm = iausp-atinn.
        if sy-subrc is initial.
*         don't take, if object deleted (-> in DELCL)
          continue .
        endif.
        if only_read is initial.
          if iklart-aediezuord = kreuz.
            if p_aennr <> iausp-aennr and
               iausp-datuv = l_datum.
              message e182 with iausp-aennr
                      raising change_ausp_not_allowed.
            endif.
          endif.
        endif.
        move-corresponding iausp to sel.
        append sel.

*       fill allausp
        read table allausp transporting no fields
                           with key
                                objek = l_object
                                atinn = iausp-atinn
                                atzhl = iausp-atzhl
                                klart = iausp-klart
                                mafid = mafid
                                binary search.
        clear allausp.
        move-corresponding iausp to allausp.
        if not p_allkssk-cuobj is initial.
          allausp-cuobj = iausp-objek.
        endif.
        allausp-objek = l_object.
        allausp-obtab = sobtab.
        if sy-subrc = 0.
          modify allausp index sy-tabix.
        else.
          insert allausp index sy-tabix.
        endif.
      endloop.
    endif.
  endif.                               " p_flags-read_values

* setup multiple classes in buffer
  if not p_mfkls is initial.
    perform ddb_multiple_classes
            using l_klart
                  p_allkssk-class
                  l_object.            " not l_objek !
  endif.

* note: index to allkssk can be changed in this CTMS !
  call function 'CTMS_CLASS_OBJECT_DDB'
    EXPORTING
      application              = '1'
      batch                    = kreuz
      class                    = p_allkssk-class
      classtype                = l_klart
      objectid                 = p_allkssk-obtab
      object                   = l_object
      status                   = p_allkssk-statu
      display                  = only_read
            READONLY                 = G_READONLY_CTMS        "  1026735
      key_date                 = l_datum
      set_values_from_db       = p_flags-set_values_from_db
      udef_rst                 = l_udef_rst
      language                 = p_flags-langu
      i_load_customizing       = p_flags-load_customizing
      i_tabs_active            = p_flags-tabs_active
    TABLES
      buff_kssk                = pkssk
      buff_ausp                = pausp
    EXCEPTIONS
      not_found                = 1
      no_allocation_to_classes = 2
      others                   = 3.

  if sy-subrc = 0.
*   EHS:  class type 100
    if l_klart = '100' and G_FLG_EHS_MOD_ACTIVE = 'X'. "note 701214
      call function 'FUNCTION_EXISTS'
        EXPORTING
          funcname           = 'C14K_AUSP_ADD_READ'
        EXCEPTIONS
          function_not_exist = 1
          others             = 2.

      if sy-subrc is initial.
        call function 'C14K_AUSP_ADD_READ'                  "#EC EXISTS
             exporting
                  i_class    = p_allkssk-class
                  i_klart    = l_klart
                  i_obtab    = p_allkssk-obtab
                  i_object   = l_object
                  i_key_date = l_datum
                  i_language = p_flags-langu
             tables
                  x_sel_tab  = sel.
      endif.
    endif.
    if p_flags-set_values_from_db = space.
      call function 'CTMS_DDB_OPEN'
        EXPORTING
          i_set_default_values = p_flags-set_default_values
        TABLES
          imp_selection        = sel.
    endif.

  else.
    raise class_not_found.
  endif.

endform.                    "build_sel_api
