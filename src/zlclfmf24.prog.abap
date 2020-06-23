*------------------------------------------------------------------*
*        FORM INSERT_CLASSIFICATION                                *
*        (performed on commit)                                     *
*------------------------------------------------------------------*
*        Update allocations and characteristic value assignments.
*
*        This form is also called in CLAP_DDB_SAVE_CLASSIFICATION.
*        Then structure rmclf is mostly empty !
*------------------------------------------------------------------*
form insert_classification.

  data:
    l_klart       like kssk-klart,
    l_objek       like kssk-objek,
    l_from_cl     like tcla-tracl.
  data:
    lt_dispo      like gt_dispo occurs 0 with header line.
  field-symbols:
    <lf_kssk>     like allkssk.

  data:
    l_after_obj_create  type boole_d.

* ensure final call to exit                                      2241496
  perform cust_exit_post USING 'X'.                           "  2241496

* Interne Nummernvergabe: vor dem Sichern muss die endgültige
* Objektnummer mit SET_OBJECTS gesetzt werden. Sonst kommen Sätze mit
* KSSK-OBJEK = interne Nummer auf die Datenbank.
  if not interne_nummer is initial.
    read table allkssk index 1.
    if sy-subrc = 0.
      message s539.
      exit.
    endif.
  endif.

* necessary to delete ?
* adjust internal tables relating to DELOB
  if delcl[] is initial.
    perform check_delob_all_tabs.
  else.
    if g_delete_classif_flg is initial.
      clap_init = kreuz.
      perform delete_classification.
    endif.
  endif.

* set classification view in material master
  if g_cl_ta = kreuz.
*   CL2* transactions
    l_from_cl = kreuz.
  else.
    clear l_from_cl.
    if g_from_api = kreuz or g_appl = konst_c.
      l_from_cl = kreuz.
    endif.
    loop at allausp transporting no fields
                    where statu <> space.
      exit.
    endloop.
    if sy-subrc > 0.
      loop at allkssk transporting no fields
                      where vbkz <> space.
        exit.
      endloop.
      if sy-subrc > 0.
        exit.
      endif.
    endif.
  endif.

*---------------------------------------------------------------------
* Automatic release

  loop at allkssk assigning <lf_kssk>.
    if <lf_kssk>-objek is initial.
*     delete entry 'marked' as invalid
      delete allkssk index sy-tabix.
    ELSE.                                                     "v 2320029
      IF <lf_kssk>-klart <> l_klart.
        l_klart = <lf_kssk>-klart.
*       get customized status -> xtclc, cl_status...
        PERFORM lesen_tclc USING l_klart.
      ENDIF.

      if <lf_kssk>-statu <> cl_statusf and                    "^ 2320029
           <lf_kssk>-vbkz  <> c_delete.

      read table xtclc transporting no fields
                       with key klart     = l_klart
                                statu     = <lf_kssk>-statu
                                clautorel = kreuz.
      if sy-subrc = 0.
*         candidate for auto. release
        perform kssk_freigabe using <lf_kssk>.
      endif.
    endif.
    ENDIF.                                                    "  2320029
  endloop.

*---------------------------------------------------------------------
* BTE interface
* Supply all: changed and unchanged data
* After status is updated, before class name is exchanged
  perform open_fi_sfa.

* class/class allocations: exchange class name -> clint
* all transactions except CL20N, (retail: generic materials !)
  if g_zuord <> c_zuord_0.
    clear l_objek.
    loop at allkssk assigning <lf_kssk>.
      if  <lf_kssk>-mafid = mafidk.
        if l_objek <> <lf_kssk>-objek.
          loop at allausp where mafid = <lf_kssk>-mafid
                            and klart = <lf_kssk>-klart
                            and objek = <lf_kssk>-objek.
            allausp-objek = <lf_kssk>-oclint.
            modify allausp transporting objek.
          endloop.
        endif.
        l_objek         = <lf_kssk>-objek.
        <lf_kssk>-objek = <lf_kssk>-oclint.
      endif.
    endloop.
  endif.

  if allkssk-obtab = tabmara or allkssk-obtab = tabmarc.
*   Wg. Effectivity müssen bei Material MARA oder MARC
*   Dispo-Sätze vor dem Verbuchungsbaustein erstellt werden.
    perform create_dispo_records
            tables allausp
                   allkssk
                   viewk
                   lt_dispo
            using  rmclf-datuv1
                   rmclf-aennr1.
  endif.

*---------------------------------------------------------------------
* call update functions

  if all_multi_obj <> space.
    call function 'CUOB_COMMIT_WORK'
         exporting
              on_commit = space.
  endif.

* Determine whether we are right after the object creation
  case sobtab.
    when 'MARA'.
      if lcl_material=>has_original( ) eq abap_false.
        l_after_obj_create = abap_true.
      endif.
    when others.
  endcase.
*--> Changed to custom to refresh local data of FG -> sjena <- 01.02.2020 01:01:19
  if g_no_upd_task is initial.
    call function 'ZCLVF_VB_INSERT_CLASSIFICATION' in update task
         exporting
              called_from_cl        = l_from_cl
              object                = objekt
              table                 = sobtab
              date_of_change        = rmclf-datuv1
              change_service_number = rmclf-aennr1
              after_obj_create      = l_after_obj_create
         tables
              kssktab               = allkssk
              ausptab               = allausp
              i_mdcp                = lt_dispo.
  else.
*   not in update task
    call function 'ZCLVF_VB_INSERT_CLASSIFICATION'
         exporting
              called_from_cl        = l_from_cl
              object                = objekt
              table                 = sobtab
              date_of_change        = rmclf-datuv1
              change_service_number = rmclf-aennr1
              after_obj_create      = l_after_obj_create
         tables
              kssktab               = allkssk
              ausptab               = allausp
              i_mdcp                = lt_dispo.
  endif.

* Initialisieren CLFM Puffer.
* Nicht, wenn Einträge in DELOB: evtl. kommt noch
* delete_obj_classification (on commit).

  g_no_upd_task_chg = kreuz.
  clear objekt.
  if delob[] is initial.
    call function 'ZCLAP_DDB_INIT_CLASSIFICATION'.
* reset buffer data for CLO0                   "1602754
    CALL FUNCTION 'CLO0_DDB_INIT'   .          "1602754
  else.
    refresh allkssk.
    refresh allausp.
    clear hzaehl.           "1325467
  endif.

endform.                               " insert_classification

class lcl_material implementation.

  method has_original.
    data:
          matrow        type ref to data,
          ls_allkssk    like allkssk.
    field-symbols:
          <matrow>      type any,
          <matnr>       type any.

    call function 'FUNCTION_EXISTS'
        exporting
          funcname           = 'MARA_SINGLE_READ_ORIGINAL'
      .

      if sy-subrc is initial.
        try.
          create data matrow type ('MARA').
        catch cx_sy_create_data_error.
          return.
        endtry.

        assign matrow->* to <matrow>.
        assign component 'MATNR' of structure <matrow> to <matnr>.

        loop at allkssk into ls_allkssk.
          if ls_allkssk-objek is not initial.
            <matnr>        = ls_allkssk-objek.
            exit.
          endif.
        endloop.

        call function 'MARA_SINGLE_READ_ORIGINAL'
          exporting
            matnr             = <matnr>
          importing
            o_mara            = <matrow>
          exceptions
            lock_on_material  = 1
            lock_system_error = 2
            wrong_call        = 3
            not_found         = 4
            others            = 5.

        if sy-subrc <> 0.
          return.
        endif.

        if <matrow> is not initial.
          rv_exists  = abap_true.
        endif.

      endif.

  endmethod.

endclass.
