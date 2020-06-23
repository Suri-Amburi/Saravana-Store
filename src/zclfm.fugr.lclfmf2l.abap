*------------------------------------------------------------------*
*       FILL_TABLES
*------------------------------------------------------------------*
* Create new allocation.
*  - CL20N, master data:  object / class
*  - CL22N:               class / class
*  - CL24N:               class / class
*------------------------------------------------------------------*
form fill_tables.

  data:
    l_superior_class like klah-class,
    l_sub_class      like klah-class,
    l_clint          like klah-clint,
    l_object         like kssk-objek,
    l_subrc          like sy-subrc.

  data:
    lo_obj_alloc_add type ref to cacl_object_allocation_add,
    ls_class         type klah,
    lt_class_add     type tt_klah,
    lt_class_alloc   type tt_klah,
    lt_message       type symsg_tab,
    lv_failed        type boole_d.

  field-symbols:
    <ls_kssk>        type rmclkssk.


  data: lr_ret_gen_art_badi type ref to badi_retail_generic_art_classf.

  if rmclf-class is initial.
    exit.
  endif.
  if mafid = mafido.
*   if material has classified batch: take that class
    perform chk_batch using    sobtab
                               space
                      changing rmclf-class.
    clear suppressd.
  endif.
  if rmclf-class ca '*'.
    get parameter id c_param_kla field klah-class.
    submit rmcllist and return
                    with klasse = rmclf-class
                    with art    = rmclf-klart.
    get parameter id c_param_kla field rmclf-class.
*   reset set/get parameter
    set parameter id c_param_kla field klah-class.
    clear klah-class.
    if rmclf-class ca '*'.
      exit.
    endif.
  endif.

  pm_class = rmclf-class.

  clear no_datum.
  clear no_status.
  clear no_classify.
  clear klah-clint.
  if rmclf-datuv1 is initial.
    klah-vondt = syst-datum.
  else.
    klah-vondt = rmclf-datuv1.
  endif.
  call function 'CLMA_CLASS_EXIST'
    exporting
      classtype             = rmclf-klart
      class                 = pm_class
      classify_activity     = tcd_stat
      classnumber           = klah-clint
      language              = syst-langu
      description_only      = space
      mode                  = mode
      date                  = klah-vondt
    importing
      class_description     = rmclf-kltxt
      not_valid             = no_datum
      no_active_status      = no_status
      no_authority_classify = no_classify
      ret_code              = l_subrc
      xklah                 = klah
    exceptions
      no_valid_sign         = 20
      others                = 21.

  if l_subrc = 2.
*   class not found
    message e503 with rmclf-klart pm_class.
  endif.
  if syst-subrc = 20.
*   class contains invalid characters
    message e013 with 'Klasse'(500).
  endif.
  if no_classify = kreuz.
*   no authorization to use class for classification
    message e532 with pm_class.
  endif.
  if no_status = kreuz.
*   the status of class does not allow allocation
    message e531 with rmclf-klart pm_class.
  endif.
  if no_datum = kreuz.
*   class not valid today
    message e530 with rmclf-klart pm_class.
  endif.
  if not klah-katalog is initial.
*   class refers to external catalog
    message e574 with rmclf-class klah-katalog.
  endif.

  if g_zuord = c_zuord_2.                                   "1847519
    perform authority_check_classify                        "1847519
            using    ok_clfm_change                         "1847519
                     kreuz                                  "1847519
                     kreuz                                  "1847519
            changing g_subrc.                               "1847519
    check g_subrc = 0.                                      "1847519
  endif.                                                    "1847519
*-- object/class -----------------------------------------------------
  if mafid = mafido.

    "--- start of object specific check ----------------------
    get badi lo_obj_alloc_add
      filters
        object_type = sobtab.

    if cl_badi_query=>number_of_implementations( lo_obj_alloc_add ) <> 0.
      clear: lt_class_add, lt_class_alloc.

      " set class to be assigned
      append klah to lt_class_add.

      " collect existing class assignments
      clear ls_class.
      loop at allkssk assigning <ls_kssk>
        where obtab = sobtab
          and objek = rmclf-objek
          and klart = rmclf-klart
          and mafid = mafido
          and vbkz  <> c_delete.

        ls_class-clint = <ls_kssk>-clint.
        append ls_class to lt_class_alloc.
      endloop.

      if lt_class_alloc is not initial.
        call function 'CLSE_SELECT_KLAH'
           tables
             imp_exp_klah         = lt_class_alloc
           exceptions
             no_entry_found       = 1
             others               = 2.
        assert sy-subrc = 0.
      endif.

      call badi lo_obj_alloc_add->before_object_alloc_add
        exporting
          iv_object_type     = sobtab
          iv_object_key      = rmclf-objek
          iv_class_type      = rmclf-klart
          it_class           = lt_class_add
          it_class_alloc     = lt_class_alloc
          iv_change_no       = rmclf-aennr
          iv_valid_from_date = rmclf-datuv1
        changing
          ct_message         = lt_message
          cv_failed          = lv_failed.

      if lv_failed = abap_true.
        read table lt_message into data(ls_message) with key msgty = 'E'.
        if sy-subrc = 0.
          message id     ls_message-msgid
                  type   ls_message-msgty
                  number ls_message-msgno
                  with   ls_message-msgv1
                         ls_message-msgv2
                         ls_message-msgv3
                         ls_message-msgv4.
        else.
          message e736.
        endif.
      endif.
    endif.

    "--- end of object specific check ------------------------

    if klah-meins <> space and klah-meins <> rmclf-meins.
      perform unit_check using rmclf-matnr
                               klah-meins
                               l_subrc.
      if l_subrc > 0.
        message e071 with klah-meins rmclf-matnr.
      endif.
    endif.
    if klah-vwstl = kreuz.
*     check use in BOM
      if classif_status <> ein.
        call function 'FUNCTION_EXISTS'
          exporting
            funcname           = 'CS_RC_RECURSIVITY_CHECK'
          exceptions
            function_not_exist = 1
            others             = 2.
        if sy-subrc is initial.
          perform rek_stueckliste
                  using init  rmclf-klart
                        pm_class  rmclf-matnr
                        space  l_subrc." subclass = space !
          if l_subrc <> 0.
            init = kreuz.
            message e550 with rmclf-klart pm_class rmclf-matnr.
          endif.
        endif.
      endif.
    endif.

*-- class/class ----------------------------------------------------
  else.
    clear l_subrc.
    clear rmclf-matnr.
    if g_zuord = 4.
      l_superior_class = rmclf-clasn.
      l_sub_class      = pm_class.
      if not g_only_new_entries is initial.
*       classes/objects not loaded into overview screen
*       -> search for allocation in database
        l_object = klah-clint.
        l_clint  = g_main_object.
        call function 'CLSE_SELECT_KSSK_0'
          exporting
            clint          = l_clint
            klart          = rmclf-klart
            mafid          = mafidk
            objek          = l_object
            neclint        = space
            key_date       = rmclf-datuv1
          tables
            exp_kssk       = ikssk
          exceptions
            no_entry_found = 01
            others         = 02.
        if sy-subrc = 0.
*         allocation already exists
          refresh ikssk.
          message e127 with l_sub_class l_superior_class rmclf-klart.
        endif.
      endif.

    else.
      l_superior_class = pm_class.
      l_sub_class      = rmclf-clasn.
    endif.

    if klah-vwstl = space.
      if pm_vwstl = kreuz.
        message e552 with rmclf-class.
      endif.
    else.
      if pm_vwstl = space.
        message e552 with rmclf-clasn.
      endif.
    endif.

*   check cycles in class hierarchy
    if l_superior_class = l_sub_class.
      l_subrc = 1.
    else.
      perform rekursion_pruefen
              using l_superior_class
                    l_sub_class
                    l_subrc.
    endif.
    if l_subrc > 0.
*     new class causes recursiveness
      message e513 with rmclf-klart pm_class.
    endif.

*   check use in BOM
    if klah-vwstl = kreuz.
      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = 'CS_RC_RECURSIVITY_CHECK'
        exceptions
          function_not_exist = 1
          others             = 2.
      if sy-subrc is initial.
        perform rek_stueckliste
                using init  rmclf-klart
                      l_superior_class  rmclf-matnr
                      l_sub_class  l_subrc.
        if l_subrc > 0.
          init = kreuz.
          message e550 with rmclf-klart l_superior_class stueli.
        endif.
      endif.
    endif.
  endif.                               " mafid

* CALL BADI BADI_RETAIL_GENERIC_ART_CLASSF
* This internal single implementation BADI is only relevant in case of a retail generic article
* The retail specific implementaion is loated in S4CORE
  try.
      get badi lr_ret_gen_art_badi.

      if lr_ret_gen_art_badi is bound.
*       Method CHECK_INPUT_FOR_RETAIL executes additional retail checks to ensure data consistency
        call badi lr_ret_gen_art_badi->check_input_for_retail
          exporting
            is_rmclf         = rmclf
            i_superior_class = l_superior_class
            i_sub_class      = l_sub_class
            i_assignment_typ = g_zuord.
      endif.

    catch cx_badi_not_implemented
          cx_badi_multiply_implemented
          cx_sy_dyn_call_illegal_method
          cx_badi_unknown_error.
  endtry.

*---------------------------------------------------------------------
* create entries in internal tables
  perform aufbauen_allkssk_view changing l_subrc.
  if l_subrc > 0.
    exit.
  endif.

  if g_46_ta <> space.
*   cl20/22n: if klastab empty okcode 'neuz' not necessary !
    sokcode = okeint.
    if okcode = space or
       okcode = okausw.
    else.
*     user did not press ENTER
      if g_zuord <> c_zuord_4.
        pm_objek  = rmclf-objek.
        pm_status = cl_statusf.
*       pm_inobj is set
        perform classify.
      endif.
    endif.
  endif.

endform.                               " fill_tables


*------------------------------------------------------------------*
*        FORM AUFBAUEN_ALLKSSK_VIEW                                *
*------------------------------------------------------------------*
*        New allocations class/object -> class.
*        Fill tables ALLKSSK, KLASTAB.
*
*        p_return = O: Zuordnung angelegt.
*                 = 1: Zuordnung angelegen nicht erlaubt.
*------------------------------------------------------------------*
form aufbauen_allkssk_view
     changing p_return.

  data:
    l_newkssk    like rmclkssk,
    l_inob_init  like inob-cuobj,
    l_used_aennr like rmclf-aennr1,
    l_clint_new  like kssk-objek, " objek !
    l_subrc      like sy-subrc,
    l_tabix      like sy-tabix.

* KLAH contains now header data of added class

  p_return = 0.
  l_clint_new = klah-clint.

  if g_zuord = c_zuord_4.
*-- CL24N: es wird eine neue Klasse (als untergeordnete) zugewiesen:
*-- G_MAIN_OBJECT ist clint der übergeordneten Klasse.
*   Wenn Änderungsdienst erlaubt:
*   gibt es schon eine Zuordnung mit Änderungsnummer ?

    read table redun with key obtab = space binary search.
    if redun-aediezuord = kreuz.
      if rmclf-aennr1 is initial.
        perform check_kssk_count using
                                 l_clint_new   rmclf-klart
                                 mafidk        sobtab
                                 l_inob_init   syst-subrc.
        if syst-subrc > 0.
          message w562.
          g_display_values = kreuz.
          p_return = 1.
          exit.
        endif.
      else.
*       classification with other change number, but same date ?
        if g_effectivity_used is initial .
          select aennr from kssk
                       into l_used_aennr up to 1 rows
                       where objek =  l_clint_new
                         and mafid =  mafidk
                         and klart =  rmclf-klart
                         and clint =  g_main_object
                         and datuv =  rmclf-datuv1
                         and aennr ne rmclf-aennr1.
          endselect.
          if sy-subrc = 0.
            message e182 with l_used_aennr.
          endif.
        endif.
      endif.
    endif.                             " aediezuord

    call function 'CLEN_ENQUEUE_CLASSIFICATION'          "begin 1141804
      exporting
        iv_enqmode     = 'E'
        iv_klart       = rmclf-klart
        iv_class       = rmclf-class
      exceptions
        foreign_lock   = 1
        system_failure = 2.
    case sy-subrc.                                         "end 1141804
      when 1.
        l_newkssk-objek = syst-msgv1.
        message e518 with rmclf-klart rmclf-class l_newkssk-objek.
      when 2.
        message e519.
    endcase.

    l_newkssk-objek  = rmclf-class.
    l_newkssk-clint  = g_main_object.
    l_newkssk-klart  = rmclf-klart.
    l_newkssk-mafid  = mafidk.
    l_newkssk-class  = rmclf-clasn.
    l_newkssk-kschl  = rmclf-kltxt.
    l_newkssk-statu  = cl_statusf.
    l_newkssk-sicht  = g_sicht_akt.    " view of sup. class
    l_newkssk-lock   = kreuz.
    l_newkssk-praus  = klah-praus.
    l_newkssk-vwstl  = pm_vwstl.
*   obtab: initial
*   cuobj: initial
*   oclint: from subclass
    l_newkssk-oclint = l_clint_new.
    perform allkssk_zaehl_set                            "begin 1143722
                using
                   l_newkssk-objek
                   l_newkssk-klart
                   l_newkssk-mafid
                changing
                   l_newkssk-zaehl.                        "end 1143722
    read table allkssk with key
                            objek = rmclf-class
                            mafid = mafid.
    if sy-subrc > 0.
*     add new allocation
      l_newkssk-vbkz = c_insert.
      append l_newkssk to allkssk.
      l_tabix = sy-tabix.
      read table klastab with key objek = space.
    else.
*     update allocation: D -> U
      if allkssk-vbkz <> c_delete.
        message e507 with rmclf-klart rmclf-class.
      endif.
      l_tabix = sy-tabix.
      l_newkssk-vbkz = c_update.
      modify allkssk from l_newkssk index l_tabix.
      loop at delcl where mafid = l_newkssk-mafid
                      and klart = l_newkssk-klart
                      and objek = l_newkssk-objek
                      and clint = l_newkssk-clint .
        delete delcl.
      endloop.
    endif.

    read table klastab with key objek = space.
    if sy-subrc = 0.
      move-corresponding l_newkssk to klastab.
      klastab-index_tab = l_tabix.
      insert klastab index sy-tabix.
      g_allkssk_akt_index = sy-tabix.
    endif.

*   GHCLI: table for multiple classification
    read table ghcli with key klart = l_newkssk-klart
                              clas2 = l_newkssk-class
                              objek = l_newkssk-objek
                              binary search.
    if sy-subrc = 0.
      ghcli-delkz = space.
      modify ghcli index sy-tabix.
    else.
      clear ghcli.
      ghcli-mklas = kreuz.
      ghcli-klart = l_newkssk-klart.
      ghcli-clas2 = l_newkssk-class.
      ghcli-clin2 = l_newkssk-clint.
      ghcli-cltx2 = l_newkssk-kschl.
      ghcli-objek = l_newkssk-objek.
      append ghcli.
      sort ghcli by klart clas2 objek delkz.
    endif.
    clear ghcli.
    aenderflag   = kreuz.
    rmclf-paganz = rmclf-paganz + 1.
    anzzeilen    = rmclf-paganz.

*   rebuild index_tab
    perform recover_klastab
            using g_cls_scr g_obj_scr.

  else.
*----------------------------------------------------------------------
*-- CL20N, CL22N, master data transaction: add class
    call function 'CLEN_ENQUEUE_CLASSIFICATION'          "begin 1141804
      exporting
        iv_enqmode     = 'S'
        iv_klart       = rmclf-klart
        iv_class       = rmclf-class
        iv_mafid       = mafid
        iv_objek       = rmclf-objek
      exceptions
        foreign_lock   = 1
        system_failure = 2.
    case sy-subrc.                                         "end 1141804
      when 1.
        if syst-msgv1 is initial.      " msgv1 = user
          message e517.
        else.
          l_newkssk-objek = syst-msgv1.
          message e518 with rmclf-klart rmclf-class l_newkssk-objek.
        endif.
      when 2.
        message e519.
    endcase.

    if multi_obj = kreuz and mafid = mafido.
      if inobj is initial.
*       INOB-cuobj number existing ?
        call function 'CUOB_GET_NUMBER'
          exporting
            class_type       = rmclf-klart
            object_id        = rmclf-objek
            table            = sobtab
          importing
            object_number    = inobj
          exceptions
            lock_problem     = 1
            object_not_found = 2
            others           = 3.
        if sy-subrc <> 0.
*         ... no : get new one
          call function 'CUOB_GET_NEW_NUMBER'
            exporting
              class_type    = rmclf-klart
              object_id     = rmclf-objek
              table         = sobtab
              with_commit   = space
            importing
              object_number = inobj
            exceptions
              lock_problem  = 01.
        endif.
      endif.
      pm_inobj = inobj.
    endif.

    l_newkssk-objek  = rmclf-objek.
    l_newkssk-clint  = l_clint_new.
    l_newkssk-klart  = rmclf-klart.
    l_newkssk-mafid  = mafid.
    l_newkssk-class  = rmclf-class.
    l_newkssk-kschl  = rmclf-kltxt.
    l_newkssk-statu  = cl_statusf.
    l_newkssk-sicht  = klah-sicht.
    l_newkssk-lock   = kreuz.
    l_newkssk-praus  = klah-praus.
    l_newkssk-vwstl  = klah-vwstl.
    l_newkssk-obtab  = sobtab.
    if multi_obj = kreuz and mafid = mafido.
      l_newkssk-cuobj = inobj.
    endif.
    if mafid = mafidk.
*     oclint: from subclass
      l_newkssk-oclint = pm_clint.
    endif.
    perform allkssk_zaehl_set                            "begin 1143722
                using
                   l_newkssk-objek
                   l_newkssk-klart
                   l_newkssk-mafid
                changing
                   l_newkssk-zaehl.                        "end 1143722
    read table allkssk with key
                            objek = rmclf-objek
                            clint = l_clint_new
                            klart = rmclf-klart
                            mafid = mafid.
    if sy-subrc > 0.
*     add new allocation
      l_newkssk-vbkz = c_insert.
      append l_newkssk to allkssk.
      l_tabix = sy-tabix.
    else.
*     update allocation: D -> U
      if allkssk-vbkz <> c_delete.
        message e507 with rmclf-klart rmclf-class.
      endif.
      l_tabix = sy-tabix.
      l_newkssk-vbkz = c_update.
      modify allkssk from l_newkssk index l_tabix.
      loop at delcl where  mafid = l_newkssk-mafid
                      and  klart = l_newkssk-klart
                      and  objek = l_newkssk-objek
                      and  clint = l_newkssk-clint .
        delete delcl.
      endloop.
      clear delcl .
    endif.

    move-corresponding l_newkssk to klastab.
    klastab-index_tab = l_tabix.
    append klastab.
    g_allkssk_akt_index = l_tabix.

*   GHCLI: table for multiple classification
    read table ghcli with key klart = l_newkssk-klart
                              clas2 = l_newkssk-class
                              objek = l_newkssk-objek
                              binary search.
    if sy-subrc = 0.
      ghcli-delkz = space.
      modify ghcli index sy-tabix.
    else.
      clear ghcli.
      ghcli-mklas = kreuz.
      ghcli-klart = l_newkssk-klart.
      ghcli-clas2 = l_newkssk-class.
      ghcli-clin2 = l_newkssk-clint.
      ghcli-cltx2 = l_newkssk-kschl.
      ghcli-objek = l_newkssk-objek.
      append ghcli.
      sort ghcli by klart clas2 objek delkz.
    endif.
    clear ghcli.
    aenderflag   = kreuz.
    rmclf-paganz = rmclf-paganz + 1.
    anzzeilen    = rmclf-paganz.

    perform build_viewtab using l_newkssk-clint
                                l_newkssk-class.
  endif.

endform.                               "aufbauen_allkssk_view
