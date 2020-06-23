*§-----------------------------------------------------------------*
*        FORM LOESCHEN                                             *
*------------------------------------------------------------------*
*        Prüfen, ob Zuordnung gelöscht werden kann und setzen      *
*        Löschkennzeichen in ALLKSSK,ALLAUSP und VIEW              *
*        War die Zuordnung schon in der Datenbank, dann wird       *
*        die Tabelle DELCL fortgeschrieben                         *
*------------------------------------------------------------------*
form loeschen.
* note 412682

  data:
      l_allkssk         like rmclkssk,
      l_class           like klah-class,
      l_clint           like kssk-clint,
      l_matnr           type matnr,
      l_objek           like kssk-objek,
      l_other_class     like klah-class,
      l_subrc           like sy-subrc,
      l_tabix           like sy-tabix,
      l_check_function  type rs38l-name.
  data:
      lv_rcuobn_temp    type rcuobn.

  data:
      lo_obj_alloc_del  type ref to cacl_object_allocation_del,
      ls_class          type klah,
      lt_class_del      type tt_klah,
      lt_message        type symsg_tab,
      lv_failed         type boole_d.


* allkssk, klastab is already positioned in form 'auswahl' !
* g_entries_new is now initial

  clear   iklah.
  refresh iklah.
  clear delcl-delkssk.
  read table allkssk index klastab-index_tab.
  l_tabix   = sy-tabix.
  l_allkssk = allkssk.

* Update CTM about change of class assignment                  "2360038
  CALL FUNCTION 'CTMS_DELETE_MEMORY'                           "2360038
    EXPORTING                                                  "2360038
      OBJECT        = allkssk-objek.                           "2360038

* Materialzuordnungen: CHECK ob Klasse als Material in Stueckliste
  if g_zuord = c_zuord_4 or
     ( ( g_zuord eq c_zuord_0  or  g_zuord eq space )
         and g_appl ne konst_w ) .
    read table iklart with key klart = l_allkssk-klart.
    if not iklart-varklart is initial.
      l_check_function = 'CLEX_CU_READ_TCUOS'.
      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = l_check_function
        exceptions
          function_not_exist = 1
          others             = 2.
      if sy-subrc is initial.
        call function l_check_function
          exporting
            i_table   = sobtab
          exceptions
            not_found = 1
            others    = 2.
        if not sy-subrc is initial.
          call function l_check_function
            exporting
              i_table   = allkssk-obtab
            exceptions
              not_found = 1
              others    = 2.
        endif.
      endif.

      if sy-subrc is initial.
        if allkssk-vbkz <> c_insert.
          l_check_function = 'CUCP_CHECK_DEL_OBJ_CLASS_CONF'.
          call function 'FUNCTION_EXISTS'
            exporting
              funcname           = l_check_function
            exceptions
              function_not_exist = 1
              others             = 2.
          if sy-subrc is initial.
            " allkssk-objek contains variant configration key
            " MFLE type conversion needed
            lv_rcuobn_temp = allkssk-objek.
            call function l_check_function
              exporting
                cucp_var_class_type       = allkssk-klart
                cucp_root_object_key      = lv_rcuobn_temp  "allkssk-objek " MFLE type conversion
                cucp_root_object_table    = sobtab
                cucp_datuv                = rmclf-datuv1
                cucp_aennr                = rmclf-aennr1
              exceptions
                deletion_allowed          = 1
                deletion_allowed_with_ecm = 2
                others                    = 3.
            case sy-subrc.
              when '0'.
                message s572.
                leave screen.
              when '2'.
                message w576 with rmclf-aennr1 rmclf-datuv1.
              when others.
            endcase.
          endif.
        endif.
      endif.
    endif.                             " varklart

    if sobtab = tabmara and allkssk-vwstl = kreuz.
      l_check_function = 'CLEX_BOM_CHECK_USAGE_OF_MAT'.
      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = l_check_function
        exceptions
          function_not_exist = 1
          others             = 2.
      if sy-subrc is initial.
        l_objek = allkssk-objek.
        if g_zuord = c_zuord_4.
          l_class = rmclf-clasn.
        else.
          l_class = allkssk-class.
        endif.
        call function l_check_function
          exporting
            p_class  = l_class
            p_klart  = rmclf-klart
            p_object = l_objek
          exceptions
            not_used = 1
            others   = 2.
        if sy-subrc is initial.
          message s551 with l_objek l_class.
          set screen syst-dynnr.
          leave screen.
        endif.
      endif.
    endif.

*   batch material: deletion allowed ?                           830440
    if ( allkssk-klart = '023' or
         allkssk-klart = '022' ) and
         allkssk-obtab = tabmara.
      l_matnr = allkssk-objek.
      try.
          call function 'CLFC_BATCH_ALLOCATION_TO_CLASS'    "#EC EXISTS
               exporting
                   material            = l_matnr
                   classtype           = allkssk-klart
                   i_ignore_matmaster  = kreuz
               importing
                   class               = l_class
               exceptions
*                   wrong_function_call = 1
                   no_class_found      = 2
                   no_classtype_found  = 3
                   others              = 5.
          if sy-subrc <> 2.
            message s551 with l_matnr allkssk-class.
            leave screen.
          endif.
        catch cx_sy_dyn_call_param_not_found
              cx_sy_dyn_call_illegal_func.
      endtry.
    endif.
  endif.                               " g_zuord

*--------------------------------------------------------------------*
* object specific check

  if allkssk-mafid = mafido and allkssk-vbkz <> c_insert.
    get badi lo_obj_alloc_del
      filters
        object_type = allkssk-obtab.

    if cl_badi_query=>number_of_implementations( lo_obj_alloc_del ) <> 0.
      clear: lt_class_del.

      " set class to be assigned
      refresh iklah.
      clear   iklah.
      iklah-clint = allkssk-clint.
      append iklah to lt_class_del.
      call function 'CLSE_SELECT_KLAH'
        tables
          imp_exp_klah   = lt_class_del
        exceptions
          no_entry_found = 04.

      call badi lo_obj_alloc_del->before_object_alloc_del
        exporting
          iv_object_type     = allkssk-obtab
          iv_object_key      = allkssk-objek
          iv_class_type      = allkssk-klart
          it_class           = lt_class_del
          iv_change_no       = rmclf-aennr
          iv_valid_from_date = rmclf-datuv1
        changing
          ct_message         = lt_message
          cv_failed          = lv_failed.

      if lv_failed = abap_true.
        read table lt_message into data(ls_message) with key msgty = 'E'.
        if sy-subrc = 0.
          message id     ls_message-msgid
                  type   'S'
                  number ls_message-msgno
                  with   ls_message-msgv1
                         ls_message-msgv2
                         ls_message-msgv3
                         ls_message-msgv4.
        else.
          message s551 with allkssk-objek allkssk-class.
        endif.
        leave screen.
      endif.
    endif.
  endif.

*-------------------------------------------------------------------
* beteiligte Objekte sperren
* viewk ist in 'auswahl' aufgebaut

  if g_zuord = c_zuord_4 and
     tcd_stat = kreuz    and
     not multi_class is initial.

*   no locks, if no characteristics used in class type
*   if g_no_chars is initial.                                   "1059170
*     MULTOBJ isn't relevant if MAFID = K                       v 935440
*     -> changed sequence of the if statements
      if allkssk-mafid = mafidk.
        ikssk-objek = allkssk-oclint.
      else.
        if multi_obj = kreuz.
          ikssk-objek = allkssk-cuobj.
        else.
          ikssk-objek = allkssk-objek.
        endif.
      endif.                                                   "^ 935440
      call function 'CLSE_SELECT_KSSK_0'
        exporting
          clint          = allkssk-clint
          klart          = rmclf-klart
          mafid          = klastab-mafid
          objek          = ikssk-objek
          neclint        = kreuz
          key_date       = rmclf-datuv1
        tables
          exp_kssk       = ikssk
        exceptions
          no_entry_found = 01.
      if syst-subrc = 0.
        refresh iklah.
        clear   iklah.
        loop at ikssk.                 "Merkmale lesen zu den anderen
          iklah-clint = ikssk-clint.
          append iklah.
        endloop.
        if multi_obj = kreuz.
          append lines of ikssk to xkssk.
        endif.
        call function 'CLSE_SELECT_KLAH'
          tables
            imp_exp_klah   = iklah
          exceptions
            no_entry_found = 04.

        sort iklah by mandt clint.
        loop at ikssk.
          read table iklah with key
                                mandt = ikssk-mandt
                                clint = ikssk-clint binary search.
*         Sperren Beziehung Objekt - Klasse
          CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'    "begin 1141804
            EXPORTING
              iv_enqmode           = 'E'
              iv_klart             = rmclf-klart
              IV_CLASS             = iklah-class
              IV_MAFID             = ikssk-mafid
              IV_OBJEK             = klastab-objek
            EXCEPTIONS
              FOREIGN_LOCK         = 1
              SYSTEM_FAILURE       = 2.
          case sy-subrc.                                   "end 1141804
            when 1.
              message s533.
              set screen syst-dynnr.
              leave screen.
            when 2.
              message s533.
              set screen syst-dynnr.
              leave screen.
          endcase.
          if l_other_class = space.
*           used in delete_database: saves fetching ikssk again.
            l_other_class = iklah-class.
          endif.
        endloop.
      endif.
*   endif.                                            "1059170
  endif.

*-------------------------------------------------------------
* check if class may be deleted from hierarchy

  read table allkssk index l_tabix.
  if sy-subrc = 0 and allkssk-vbkz <> c_insert.
    if allkssk-mafid = mafidk.
      perform check_structure using rmclf-klart
                                    allkssk-class
                                    allkssk-clint
                                    allkssk-objek
                                    allkssk-oclint
                                    l_subrc
                                    rmclf-aennr1
                                    rmclf-datuv1.        "897241
      if l_subrc > 0.
        inkonsi = kreuz.
        if l_subrc = 2.
          message s572.
        else.
          message s554.
        endif.
        leave screen.
      endif.
      read table allkssk index l_tabix.
    endif.
  endif.

  if g_zuord <> c_zuord_4.
    l_objek = rmclf-objek.
    l_clint = allkssk-clint.
  else.
    l_objek = allkssk-objek.
    l_clint = pm_clint.
  endif.

*------------------------------------------------------------
* Löschsatz in GHCLI aufnehmen, löschen

  read table ghcli with key klart = allkssk-klart
                            clas2 = allkssk-class
                            objek = allkssk-objek
                            delkz = space         binary search.
  if syst-subrc = 0.
    delete ghcli index sy-tabix.
  endif.
  if allkssk-vbkz = c_insert.
*   CTMS-CLHI may not find this temp. allocation as existing !
    clear allkssk-objek.
    clear allkssk-cuobj.
  else.
    ghcli-mklas = kreuz.
    ghcli-klart = rmclf-klart.
    ghcli-clas2 = allkssk-class.
    ghcli-clin2 = allkssk-clint.
    ghcli-cltx2 = allkssk-kschl.
    ghcli-objek = allkssk-objek.
    ghcli-delkz = kreuz.
    append ghcli.
    sort ghcli by klart clas2 objek delkz.
    allkssk-vbkz = c_delete.
  endif.
  modify allkssk index l_tabix.

  if g_no_chars is initial.
    perform delete_database
            using l_allkssk              " l_allkssk !!
                  l_other_class.
  else.
*   possible in CL24N
    if l_allkssk-vbkz <> c_insert.
      clear delcl-merkm.
      perform fuellen_delcl using delcl-merkm l_allkssk.
    endif.
  endif.

  if g_zuord = c_zuord_0 or
     g_zuord = space .
    aenderflag = kreuz.
    if standardclass = allkssk-class.
      clear standardclass.
    endif.
  endif.

*--------------------------------------------------------------

  if g_zuord = c_zuord_4.
    if allkssk-vbkz <> c_insert.
*     allocations on DB
      loop at allausp where objek = l_objek
                        and klart = allkssk-klart
                        and mafid = allkssk-mafid.
        allausp-delkz = kreuz.
        modify allausp transporting delkz.
      endloop.
    else.
      if not l_allkssk-cuobj is initial.
        clear pm_inobj.
        clear inobj.
        call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
          exporting
            object_id = l_allkssk-cuobj.
      endif.
    endif.

  else.
*   CL20, CL22, object transaction
    if allkssk-vbkz <> c_insert.
      loop at allausp where objek = l_objek
                        and klart = allkssk-klart
                        and mafid = allkssk-mafid
                        and statu <> space.
        read table delcl with key mafid = allkssk-mafid
                                  klart = allkssk-klart
                                  objek = l_objek
                                  clint = l_clint
                                  merkm = allausp-atinn.
        if syst-subrc = 0.
          allausp-delkz = kreuz.
          modify allausp transporting delkz.
        endif.
      endloop.

    else.
      if not l_allkssk-cuobj is initial and
         ( g_zuord = c_zuord_0 or
           g_zuord = space ).
        loop at allkssk transporting no fields
                        where cuobj = l_allkssk-cuobj.
          exit.
        endloop.
        if syst-subrc > 0.
          clear pm_inobj.
          clear inobj.
          call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
            exporting
              object_id = l_allkssk-cuobj.
        endif.
      endif.

    endif.
  endif.                               " g_zuord

*------------------------------------------------------------

  delete klastab index g_klastab_akt_index.
  if klastab[] is initial.
    clear rmclf-pagpos.
  endif.
  rmclf-paganz = rmclf-paganz - 1.
  anzzeilen    = rmclf-paganz.

endform.                               " loeschen
