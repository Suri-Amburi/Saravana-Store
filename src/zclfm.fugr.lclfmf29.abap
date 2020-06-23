*------------------------------------------------------------------*
*        FORM DELETE_DATABASE                                      *
*------------------------------------------------------------------*
*        Von der Datenbank zu löschende KSSK und AUSP-Sätze        *
*        Aufbauen der Tabelle DELCL.                               *
*        Rel 4.6: multi_class = x komplett neu.                    *
*------------------------------------------------------------------*
form delete_database
     using value(p_allkssk)     structure rmclkssk
           value(p_other_class) like      klah-class.

  data:
      l_objek         like rmclf-objek,
      l_obtab         like rmclf-obtab,
      l_klart         like klah-klart,
      l_subrc         like sy-subrc,
      l_txttab        like tclo-txttab,
      l_valid_class   like klah-class.
  data:
      lt_cabn         like cabn occurs 0 with header line,
      lt_chars        like api_ch_att occurs 0 with header line,
      lt_valid_chars  like api_char occurs 0 with header line.

  ranges:
    r_cabn            for cabn-atinn.
  field-symbols:
      <lf_alloc>      type rmclkssk.


  assign p_allkssk to <lf_alloc>.
  l_klart = rmclf-klart.
  l_objek = <lf_alloc>-objek.

  if multi_class is initial and
     clhier is initial      and
     p_allkssk-vbkz <> c_insert.
*   Custonizing: keine Mehrfachklassifizierung, keine Hierarchie.
*   Merkmale nur in der aktuellen Klasse !
    loop at viewk where klart = l_klart
                    and class = <lf_alloc>-class.
      perform fuellen_delcl using viewk-merkm <lf_alloc>.
    endloop.

  else.
*   1. get valid class from other allocation:
*      if available from DB, else from temp. allocation

    if g_zuord = c_zuord_4.
      if p_other_class = space.
        loop at ghcli where klart =  l_klart
                        and clas2 <> pm_class.
          l_valid_class = ghcli-clas2.
          exit.
        endloop.
      else.
        l_valid_class = p_other_class.
      endif.
    else.
*     cl20, cl22
      loop at allkssk where class <> pm_class
*         class isn't valid if OBJEK has been cleared             918491
                        and objek <> space                     "  918491
                        and klart =  l_klart
                        and vbkz  <> c_delete.
        l_valid_class = allkssk-class.
        exit.
      endloop.
      if sy-subrc > 0.
        loop at ghcli where klart =  l_klart
                        and clas2 <> pm_class
                        and delkz =  space.
          l_valid_class = ghcli-clas2.
          exit.
        endloop.
      endif.
*     reposition allkssk
      read table allkssk with key class = pm_class
                                  klart = l_klart.
    endif.

    if l_valid_class is initial.
*     no multiple allocation, but inheritance possible
      l_valid_class = <lf_alloc>-class.
    endif.

*   --------------------------------------------------------
*   get valuations remaining valid

    if l_valid_class <> space.

      if not multi_class is initial.
        perform ddb_multiple_classes
                using l_klart
                      l_valid_class
                      l_objek.
      endif.
      if <lf_alloc>-mafid = mafido.
        l_obtab = <lf_alloc>-obtab.
      else.
        l_obtab = c_klah.
      endif.

      call function 'CTMS_CLASS_OBJECT_DDB'
           exporting
*              BATCH                    = ' '
               class                    = l_valid_class
               classtype                = l_klart
               status                   = pm_status
               language                 = sy-langu
               objectid                 = l_obtab
               object                   = l_objek
               display                  = kreuz
               key_date                 = rmclf-datuv1
               set_values_from_db       = space
               application              = space
*              appl_instance            =
*              profile                  =
*              additional_objectid      =
*              additional_object        =
*              readonly                 = ' '
*              udef_rst                 =
*              i_load_customizing       = ' '
*              i_tabs_active            = ' '
*           importing
*              instance                 =
*           tables
*              buff_kssk                =
*              buff_ausp                =
           exceptions
               not_found                = 1
               no_allocation_to_classes = 2
               others                   = 3.

      if sy-subrc = 0.
*       get valid characteristics of selected object:
        call function 'CTMS_DDB_CHAR_HAS_ATTRIBUTES'
             exporting
                  excl_knowledge      = space
                  excl_documents      = space
             tables
                  imp_characteristics = lt_valid_chars
                  exp_attributes      = lt_chars.

      endif.

    endif.                             " l_valid_class

*   ------------------------------------------------------------
*   Now write valuations to be deleted to table delcl / allausp.

*     note 709442
      read table allausp with key objek = l_objek
                                  klart = l_klart
                                  mafid = <lf_alloc>-mafid
                                  transporting no fields.
      if sy-subrc <> 0.
        perform classify.
      endif.
      if l_valid_class = <lf_alloc>-class.
*       delete all valuations of object
        loop at allausp where objek = l_objek
                          and klart = l_klart
                          and mafid = <lf_alloc>-mafid.
          read table lt_chars with key
                                   atinn = allausp-atinn.
          if sy-subrc = 0.
*           remove reference characteristics
            if not lt_chars-attab is initial.
              if redun-redun is initial.                    " 610483
                allausp-statu = hinzu.
              endif.
            endif.
          endif.
          case allausp-statu.
            when space.
              allausp-statu = loeschen.
              modify allausp transporting statu.
            when hinzu.
              delete allausp.
            when loeschen.
*             keep flag
          endcase.
        endloop.

      else.
*       exclude valuations used in other allocations
        loop at allausp where objek = l_objek
                          and klart = l_klart
                          and mafid = <lf_alloc>-mafid.
          read table lt_chars with key
                                   atinn = allausp-atinn.
          l_subrc = sy-subrc.
          if l_subrc > 0.
*           characteristic not in buffer: read characteristic master
            refresh r_cabn.
            r_cabn-low = allausp-atinn.
            append r_cabn.
            call function 'CLSE_SELECT_CABN'
                 exporting
                      key_date       = rmclf-datuv1
                 tables
                      in_cabn        = r_cabn
                      t_cabn         = lt_cabn
                 exceptions
                      no_entry_found = 1
                      others         = 2.
            if sy-subrc = 0.
              read table lt_cabn index 1.
              if sy-subrc = 0.
                if lt_cabn-attab <> space.
                  if lt_cabn-attab = l_obtab or
                     lt_cabn-attab = l_txttab.
                    if redun-redun is initial.
*                     exclude ref. characteristic
                      delete allausp.
                      l_subrc = 0.
                    endif.
                  else.
                    select single txttab from tclo
                                         into l_txttab
                                         where obtab = l_obtab.
                    if sy-subrc = 0 and
                       l_txttab = lt_cabn-attab.
                      if redun-redun is initial.
*                       exclude ref. characteristic
                        delete allausp.
                        l_subrc = 0.
                      endif.
                    endif.
                  endif.
                endif.
              endif.
            endif.
          endif.
          if l_subrc > 0.
            case allausp-statu.
              when space.
                allausp-statu = loeschen.
                modify allausp transporting statu.
              when hinzu.
                delete allausp.
              when loeschen.
*               keep flag
            endcase.
          endif.
        endloop.
      endif.

*     delete allocation itself, if on DB
      if <lf_alloc>-vbkz <> c_insert.
        clear delcl-merkm.
        perform fuellen_delcl using delcl-merkm <lf_alloc>.
      endif.
  endif.                               " multi_classif

  sort delcl by mafid klart objek clint merkm.

endform.                               " delete_database
