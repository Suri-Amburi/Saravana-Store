*------------------------------------------------------------------*
*        FORM REF_ALLOCATIONS                                      *
*------------------------------------------------------------------*
*  Allocations of reference object now in ikssk.
*  Copy them for the new object: fill allkssk.
*
*  Note:
*  If the user does not have the authority to maintain
*  all classes of the reference object, he may not see all
*  valuations of this object. -> reduce allausp.
*------------------------------------------------------------------*
form ref_allocations
     using     p_table
               p_new_object
               p_ref_object
               p_ref_datuv
               p_ref_aennr
               p_class
               p_uom_check                                     "2378933
     changing  p_internal_obj_number
               p_same_classify.

  data:
        l_klart        like tcla-klart,
        l_multi_class  like sy-batch,
        l_excl_class   like sy-batch,
        l_ref_objek    like kssk-objek,
        l_subrc        like sy-subrc,
        l_tabix        like sy-tabix.

  data: begin of lt_class occurs 0,
          klart      like klah-klart,
          clint      like klah-clint,
          class      like klah-class,
        end   of lt_class.
  DATA:                                                        "1167642
    lv_smsgv TYPE sy-msgv1.                                    "1167642
*     Chargenklassifizierung prüfen                            "2131753
  data: lv_class like  rmclf-class,                            "2131753
       lv_p_class like  rmclf-class.                           "2131753


  sort ikssk by klart.
  loop at ikssk.
*                                                       "Begin  2131753
* Check for batch class types - is batch classifications exists?
*    if ikssk-klart ='022' or                                  "2238516
*       ikssk-klart = '023'.                                   "2238516
    if ( ikssk-klart ='022'  or                                "2238516
       ikssk-klart = '023' ) and                               "2238516
       p_class is initial and                                  "2396832
      ( p_table =  tabmara or                                  "2396832
        p_table = 'MCH1' or                                    "2396832
        p_table = 'MCHA' ).                                    "2396832

       rmclf-klart = ikssk-klart.
* class in template
      call function 'CLMA_CLASS_READ'
      exporting
          classnumber     = ikssk-clint
      importing
           classname       = lv_p_class
      exceptions
           class_not_found = 1
           others          = 2.
* check if material batch is clasified
      call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
        exporting
          rmclfstru      = rmclf
          table          = p_table
          init_test      = kreuz
        importing
          rmclfstru      = rmclf
        tables
          lengthtab      = laengtab
        exceptions
          tclo_not_found = 1.
      if syst-subrc = 1.
        message e521 with p_table.
      endif.
      try.
       call function 'CLFC_BATCH_ALLOCATION_TO_CLASS'
         exporting
           material            = rmclf-matnr
           classtype           = ikssk-klart
           i_ignore_matmaster  = kreuz
         importing
           class               = lv_class
         exceptions
*          wrong_function_call = 1
           no_class_found      = 2
           no_classtype_found  = 3
           others              = 5.
        catch cx_sy_dyn_call_param_not_found
              cx_sy_dyn_call_illegal_func.
          message e001(cl) with 'CLFC_BATCH_ALLOCATION_TO_CLASS'.
      endtry.
* if material batch is classified with an other class - donot copy
* batch classification.
      if lv_class is not initial and not lv_class = lv_p_class.
          message w188
                  with ikssk-klart
                       lv_p_class
                       rmclf-matnr
                       lv_class.
          continue.
      endif.
    endif.                                                 "End 2131753

*-- read class master
    clear no_datum.
    clear no_status.
    clear no_classify.
    clear klah-class.
    klah-vondt = rmclf-datuv1.
    call function 'CLMA_CLASS_EXIST'
      exporting
        classtype             = ikssk-klart
        class                 = klah-class
        classify_activity     = tcd_stat
        classnumber           = ikssk-clint
        language              = sy-langu
        description_only      = space
        mode                  = mode                  " K
        date                  = klah-vondt
      importing
        class_description     = rmclf-ktext
        not_valid             = no_datum
        no_active_status      = no_status
        no_authority_classify = no_classify
        ret_code              = l_subrc
        xklah                 = klah
      exceptions
        no_valid_sign         = 20.

    check sy-subrc ne 20.
    if l_subrc = 2.
      if sy-calld is initial and
         sy-binpt is initial.
        message w503 with ikssk-klart klah-class.
*       'class does not exist'
      endif.
      l_excl_class = kreuz.
      continue.
    endif.
    if not no_classify is initial.
      if sy-calld is initial and
         sy-binpt is initial.
        message w532 with klah-class.
*       'no authority'
      endif.
      l_excl_class = kreuz.
      continue.
    endif.
    if not no_status is initial.
      if sy-calld is initial and
         sy-binpt is initial.
        message w116 with klah-class.
*       'no class status'.
      endif.
      l_excl_class = kreuz.
      continue.
    endif.
    if not no_datum is initial.
      if sy-calld is initial and
         sy-binpt is initial.
        message w530 with  ikssk-klart klah-class.
*       'class not valid'.
      endif.
      l_excl_class = kreuz.
      continue.
    endif.
    lt_class-klart = ikssk-klart.
    lt_class-clint = klah-clint.
    lt_class-class = klah-class.
    append lt_class to lt_class.
    data: lv_obj type matnr.
*    if ( P_TABLE = 'MARA' ) and ( P_UOM_CHECK = kreuz ). "2378933 + Begin 2304282
    if P_TABLE = 'MARA'                                  "Begin 2304282
      and ( P_UOM_CHECK = kreuz )                      "+ Begin 2304282
      and not klah-meins is initial.                           "2450327
      lv_obj = p_new_object.
      perform unit_check using lv_obj
                             klah-meins
                             l_subrc.
      if l_subrc > 0.
        message e071 with klah-meins rmclf-matnr
            raising CLASS_NOT_VALID.
      endif.
    endif.                                                 "End 2304282

    CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'          "begin 1141804
      EXPORTING
        iv_enqmode           = 'S'
        iv_klart             = ikssk-klart
        IV_CLASS             = klah-class
        IV_MAFID             = mafido
        IV_OBJEK             = p_new_object
      EXCEPTIONS
        FOREIGN_LOCK         = 1
        SYSTEM_FAILURE       = 2.
    case sy-subrc.                                         "end 1141804
      WHEN 1.                                            "begin 1167642
        IF sy-msgv1 IS INITIAL.
*         "classification not possible at the moment"
          MESSAGE s517
                  RAISING foreign_lock.
        ELSE.
*         "class type & : class & locked by user &"
          lv_smsgv = sy-msgv1.
          MESSAGE s518
                  WITH ikssk-klart
                       klah-class
                       lv_smsgv
                  RAISING foreign_lock.
        ENDIF.                                             "end 1167642
        exit.
      when 2.
        message e519.
    endcase.
    rmclf-class = klah-class.

*-- do once for every class type
*   fill ALLAUSP: character valuations of ALL classes
    if ikssk-klart <> l_klart.
      l_klart     = ikssk-klart.
      rmclf-klart = ikssk-klart.
      read table iklart with key ikssk-klart binary search.
      if sy-subrc = 0.
*       flag change management
        change_subsc_act = iklart-aediezuord.
        l_multi_class    = iklart-mfkls.
      endif.

      read table klartino with key ikssk-klart binary search.
      if sy-subrc > 0.
*       single object class type
        clear klartino-cuobj.
        clear inobj.
      else.
*       multiple object class type
*       create new object number (inob-CUOBJ)
        call function 'CUOB_GET_NUMBER'
          exporting
            class_type       = ikssk-klart
            object_id        = p_new_object
            table            = p_table
          importing
            object_number    = inobj
          exceptions
            lock_problem     = 01
            object_not_found = 02.
        if sy-subrc > 0.
          call function 'CUOB_GET_NEW_NUMBER'
            exporting
              class_type    = ikssk-klart
              object_id     = p_new_object
              table         = p_table
              with_commit   = space
            importing
              object_number = inobj
            exceptions
              lock_problem  = 01.

*       Object already exists. Check if ALLKSSK is prepared properly.
        else.                                                  "1406930
          read table allkssk with key cuobj = inobj            "1406930
                     transporting no fields.                   "1406930
          if sy-subrc <> 0.                                    "1406930
            call function 'CLAP_DDB_GET_CLASSIFICATION'        "1406930
                 exporting                                     "1406930
                      OBJECT = p_new_object                    "1406930
                      OBTAB  = p_table                         "1406930
                 EXCEPTIONS                                    "1406930
                      others = 1.                              "1406930
            if sy-subrc <> 0.                                  "1406930
              "Ignore                                          "1406930
            endif.                                             "1406930
          endif.                                               "1406930

        endif.
      endif.

      perform ref_klassifizieren using p_table
                                       p_new_object
                                       p_ref_object
                                       klartino-cuobj
                                       p_ref_datuv
                                       p_ref_aennr
                                       l_tabix.
    endif.

*-----------------------------------------------------------------
*   fill allkssk

    read table allkssk with key objek = p_new_object
                                clint = ikssk-clint
                                klart = ikssk-klart
                                mafid = ikssk-mafid.
*   if sy-subrc > 0.                                           "1126294
    if sy-subrc = 0.                                           "1126294
      p_internal_obj_number = allkssk-cuobj.                   "1126294
    else.                                                      "1126294
      clear ikssk-aennr.
      clear ikssk-adzhl.                            "968564
      clear allkssk.
      move-corresponding ikssk to allkssk.

*      if klah-praus = konst_e and                              "1747640
*         l_tabix > 0.                                          "1747640
**     equal classifications in same class not allowed          "1747640
**     (flag KLAH-PRAUS):  set status = incomplete              "1747640
*        p_same_classify = ikssk-klart.                         "1747640
*        perform lesen_tclc using ikssk-klart.                  "1747640
*        allkssk-statu = cl_statusus.                           "1747640
*      endif.                                                   "1747640

      allkssk-objek = p_new_object.
      allkssk-class = klah-class.
      allkssk-kschl = rmclf-ktext.
      allkssk-sicht = klah-sicht.
      allkssk-praus = klah-praus.
      allkssk-vwstl = klah-vwstl.
      allkssk-obtab = p_table.
      allkssk-vbkz  = c_insert.          " new allocation !
      if not inobj is initial.
        allkssk-cuobj = inobj.
        if p_internal_obj_number is initial.
          pm_inobj              = inobj.
          p_internal_obj_number = inobj.
        endif.
      endif.
      if allkssk-zaehl is initial.
        PERFORM allkssk_zaehl_set                        "begin 1143722
                    USING
                       allkssk-objek
                       allkssk-klart
                       allkssk-mafid
                    CHANGING
                       allkssk-zaehl.                      "end 1143722
      endif.

      if rmclf-aennr1 is not initial and                 "begin 1339722
         tcla-aediezuord is not initial.                       "1848167
*       allow copy of classification with change number.
*       behaviour can be suppressed by calling CLFM_OBJECT_CLASSIFICATION
*       with parameter OBJ_HAS_CHANGE_SERVICE = space
        allkssk-aennr = rmclf-aennr1.
        allkssk-datuv = rmclf-datuv1.
      endif.                                               "end 1339722

      append allkssk.

      if not l_multi_class is initial.
*     collect multiple classifications in GHCLI
*     (used in CTMS, character value assigmnment)
        ghcli-klart = allkssk-klart.
        ghcli-clas2 = allkssk-class.
        ghcli-objek = allkssk-objek.
        ghcli-clin2 = allkssk-clint.
        ghcli-cltx2 = allkssk-kschl.
        ghcli-mklas = kreuz.
        ghcli-delkz = space.
        append ghcli.
      endif.
    endif.
  endloop.                             " ikssk

*  if p_same_classify <> space.                                "1747640
*    if sy-calld is initial and                                "1747640
*       sy-binpt is initial.                                   "1747640
*      message w818(c1) with p_ref_object.                     "1747640
**     'object with same classification exists'                "1747640
*    endif.                                                    "1747640
*  endif.                                                      "1747640
  refresh ikssk.
  sort ghcli by klart clas2 objek delkz .
  sort allkssk by objek clint klart mafid.

* remember copied class assigments to keep them                v 2355069
* if a CANCEL is processed after further changes
* ALLAUSP is already covered
  gt_log_allkssk[] = allkssk[].                               "^ 2355069

*--------------------------------------------------------------
* reduce allausp if classes are excluded for above reasons:
* reduced authority, ...
* 1. setup viewk: only characteristics of allowed classes.
* 2. delete allausp entries if allausp-atinn not in viewk.

  if l_excl_class <> space.
    loop at lt_class.
      rmclf-klart = lt_class-klart.
      perform build_viewtab using lt_class-clint
                                  lt_class-class.
    endloop.
    sort viewk by klart class merkm.
***++++++++++++++++++++++++++++++++++++++++++++++++++begin note 1495267
DATA: BEGIN OF GHCL OCCURS 0.
            INCLUDE STRUCTURE GHCL.
DATA: END   OF GHCL.
DATA: BEGIN of viewk2 occurs 0,
        klart like klah-klart,
        class like klah-class,
        merkm like ksml-imerk,
        omerk like ksml-omerk,
        posnr like ksml-posnr,
        abtei like ksml-abtei,
        udeff like ksml-dptxt,
        loekz like kssk-lkenz,
        udefm like ksml-imerk.
DATA: END   of viewk2.

  loop at lt_class.
       CALL FUNCTION 'CLHI_STRUCTURE_CLASSES'
        EXPORTING
             I_KLART              = allausp-KLART
             I_CLASS              = lt_class-class
             I_DATE               = sy-datum
             I_OBJECT             = allkssk-objek
             I_OBJ_ID             = allkssk-MAFID
             I_LANGUAGE           = ' '
             i_no_classification  = ' '
             I_BUP                = 'X'
             I_TDWN               = ' '
             I_BATCH              = 'X'
             I_ENQUEUE            = 'X'


             I_INCLUDING_TEXT     = ' '
             I_SORT_BY_CLASS      = ' '
             I_CALLED_BY_CLASSIFY = 'X'
             I_STRUCTURED_LIST    = ' '
             I_NO_OBJECTS         = ' '
        TABLES
*            INDEX                = KVI
             DATEN                = GHCL
            EXP_KLAH             = IKLAH
        EXCEPTIONS
             OTHERS               = 1.

    delete IKLAH where class = lt_class-class.
      loop at iklah.
     select klart clint imerk from ksml appending table viewk2
                              where  clint = iklah-clint.
   endloop.
   sort viewk2 by klart class merkm.
  endloop.

    loop at allausp.
      read table viewk with key klart = allausp-klart
                                merkm = allausp-atinn.
      if sy-subrc > 0.
*       delete allausp.                                        "1968271
* if the allowed class has inherited characteritstics they must be
*shown in classification.
         read table viewk2 with key klart = allausp-klart
                                    merkm = allausp-atinn.
         if sy-subrc > 0.
            delete allausp.
        endif.
**++++++++++++++++++++++++++++++++++++++++++++++++++++end note 1495267
      endif.
    endloop.
  endif.

* - classification has now been copied from reference object   v 1828096
* - classification of target object is available
*   only in memory for now
* - set flags to make this data known to CLSE function modules
*   e.g. necessary for complete processing of dependencies at classes
*        if multiple classes are assigned

  CALL FUNCTION 'CLSE_CLFM_BUF_FLAGS'
    EXPORTING
      I_AUSP_FLG = 'X'
      I_KSSK_FLG = 'X'.

* these flags will be cleared during initialization with
* CLAP_DDB_INIT_CLASSIFICATION after the current classification
* has been saved, see subroutine INSERT_CLASSIFICATION
                                                              "^ 1828096

endform.                               " ref_allocations

*------------------------------------------------------------------*
*        FORM REF_KLASSIFIZIEREN                                   *
*------------------------------------------------------------------*
*  Read valuations of reference object.
*  Create new valuations for the new object: table allausp.
*------------------------------------------------------------------*
form ref_klassifizieren using p_table   like inob-obtab
                              new_objek like kssk-objek
                              ref_objek like kssk-objek
                              ref_cuobj like inob-cuobj
                              ref_datum like rmclf-datuv1
                              ref_aennr like rmclf-aennr1
                              cnt_ausp  like syst-tfill.

  data: l_objek  like ausp-objek.
  data: iausp    like ausp occurs 0 with header line.

  field-symbols:
    <l_ausp> like rmclausp.

* 1. take temporary valuations if existing
  loop at allausp assigning <l_ausp>
                  where objek = ref_objek
                    and klart = rmclf-klart
                    and mafid = mafido.
    if <l_ausp>-statu <> loeschen.
*     extra 'if' because of sy-subrc of loop
      move-corresponding <l_ausp> to iausp.
      append iausp.
    endif.
  endloop.

  if sy-subrc > 0.
*   2. else get valuations from DB
    if ref_cuobj is initial.
      l_objek = ref_objek.
    else.
      l_objek = ref_cuobj.
    endif.
    call function 'CLFM_SELECT_AUSP'
      exporting
        mafid              = mafido
        classtype          = rmclf-klart
        object             = l_objek
        key_date           = ref_datum
        i_aennr            = ref_aennr
        with_change_number = change_subsc_act
      tables
        exp_ausp           = iausp
      exceptions
        no_values          = 01.
    if sy-subrc = 0.
      cnt_ausp = 1.
    else.
      clear cnt_ausp.
    endif.
  endif.

  delete allausp where objek = new_objek                       "2384747
                   and klart = rmclf-klart                     "2384747
                   and mafid = mafido.                         "2384747

  loop at iausp.
    clear iausp-aennr.
    read table allausp with key
                            objek = new_objek
                            atinn = iausp-atinn
                            atzhl = iausp-atzhl
                            klart = iausp-klart
                            mafid = mafido binary search.
    move-corresponding iausp to allausp.
    allausp-objek = new_objek.
    allausp-statu = hinzu.
    allausp-updat = space.
    allausp-delkz = space.
    allausp-obtab = p_table.
    clear allausp-aennr.
    clear allausp-datuv.
    if inobj is initial.
      clear allausp-cuobj.
    else.
      allausp-cuobj = inobj.
    endif.

    case syst-subrc.
      when 0.
        modify allausp index syst-tabix.
      when 4.
        insert allausp index syst-tabix.
      when 8.
        append allausp.
    endcase.
  endloop.

endform.                               " ref_klassifizieren
