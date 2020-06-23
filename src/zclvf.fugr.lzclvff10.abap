*---------------------------------------------------------------------*
*       FORM PFLEGEN_ALL_TABS                                         *
*---------------------------------------------------------------------*
*       Alle Verbuchungssätze abschicken.                             *
*---------------------------------------------------------------------*
form pflegen_all_tabs
     tables  p_ausptab structure rmclausp
     using   p_add_kz
             value(p_called_from_cu)
             after_obj_create.

  data: l_tabix like sy-tabix.
*
* KSSK Verändern bei Änderungsnummer
  describe table v1kssk lines syst-tfill.
  if syst-tfill ne 0.
    perform find_kssk_max_adzhl using space.
  endif.

*--------------------------------------------
*   call BADI to signal classification change
    cl_clf_dep_fields=>adjust_dependent_fields(
      CHANGING
        ct_kssk_insert = hkssk[]
        ct_kssk_update = vkssk[] ).

    if not gv_num_badi_clf_update_impl is initial.
      call badi gr_badi_clf_update->before_update
        exporting
          it_kssk_insert    = hkssk[]
          it_kssk_update    = vkssk[].
    endif.
*--------------------------------------------

* KSSK Hinzufügen
  describe table hkssk lines syst-tfill.
  if syst-tfill ne 0.
    insert kssk from table hkssk.
    if syst-subrc ne 0.
      message a585 with tabkssk.
    endif.
  endif.
* KSSK Verändern
  describe table vkssk lines syst-tfill.
  if syst-tfill ne 0.
    update kssk from table vkssk.
    if syst-subrc ne 0.
      message a586 with tabkssk.
    endif.
  endif.

* Fortschreiben Materialstamm
  lcl_material=>update( after_obj_create ).                            "  1984597

*-- LOOP über die LAUSP und prüfen, ob der jeweilige Eintrag auch in
*-- einer der anderen Tabellen vorkommt. Wenn ja: Aus LAUSP löschen

  loop at lausp.
    l_tabix = sy-tabix.
*-- Zunächst nachschauen, ob bereits in G_AUSP_DEL enthalten
    if not g_ausp_already_del is initial.
      read table g_ausp_del with key objek = lausp-objek
                                atinn = lausp-atinn
                                atzhl = lausp-atzhl
                                mafid = lausp-mafid
                                klart = lausp-klart
                                adzhl = lausp-adzhl.
      if sy-subrc is initial.
        delete lausp index l_tabix.
        continue.
      endif.
    endif.
*-- ... dann HAUSP lesen
    read table hausp with key objek = lausp-objek
                              atinn = lausp-atinn
                              atzhl = lausp-atzhl
                              mafid = lausp-mafid
                              klart = lausp-klart
                              adzhl = lausp-adzhl.
    if not sy-subrc is initial.
*-- Auch VAUSP nachlesen
      read table vausp with key objek = lausp-objek
                                atinn = lausp-atinn
                                atzhl = lausp-atzhl
                                mafid = lausp-mafid
                                klart = lausp-klart
                                adzhl = lausp-adzhl.
      if sy-subrc is initial.
        delete lausp index l_tabix.
*-- Änderungsbelegeinträge dazu ebenfalls löschen, da nun überflüssig
        read table abausp with key objek = lausp-objek
                                   atinn = lausp-atinn
                                   atzhl = lausp-atzhl
                                   mafid = lausp-mafid
                                   kz    = loeschen .
        if sy-subrc is initial.
          delete abausp index sy-tabix.
        endif.
      endif.
    else.
      delete lausp index l_tabix.
*-- Änderungsbelegeinträge dazu ebenfalls löschen, da nun überflüssig
      read table abausp with key objek = lausp-objek
                                 atinn = lausp-atinn
                                 atzhl = lausp-atzhl
                                 mafid = lausp-mafid
                                 kz    = loeschen .
      if sy-subrc is initial.
        delete abausp index sy-tabix.
      endif.
    endif.
  endloop.

*-- Sonderlogik eh&s
  if not p_add_kz    is initial.
    call function 'FUNCTION_EXISTS'
      exporting
        funcname           = 'C14K_AUSP_ADD_UPD'
      exceptions
        function_not_exist = 1
        others             = 2.

    if sy-subrc is initial.
      call function 'C14K_AUSP_ADD_UPD'
        tables
          x_allausp_tab  = p_ausptab
          x_ins_ausp_tab = hausp
          x_upd_ausp_tab = vausp
          x_del_ausp_tab = lausp.
    endif.
  endif.

* AUSP Hinzufügen
  perform fuellen_view_ausp_from_hausp.
  perform insert_ausp.

* AUSP Verändern
  perform fuellen_view_ausp_from_vausp.
  perform update_ausp.

* AUSP Löschen
  describe table lausp lines syst-tfill.
  if syst-tfill ne 0.
*-- Doppelte Einträge aus LAUSP entfernen!
    sort lausp by objek atinn atzhl mafid klart adzhl .
    delete adjacent duplicates from lausp comparing
                    objek atinn atzhl mafid klart adzhl .

*--------------------------------------------
*   call BADI to signal classification change
    cl_clf_dep_fields=>adjust_dependent_fields(
      CHANGING
        ct_ausp_delete = lausp[] ).

    if not gv_num_badi_clf_update_impl is initial.
      call badi gr_badi_clf_update->before_update
        exporting
          it_ausp_delete = lausp[].
    endif.
*--------------------------------------------

    delete ausp from table lausp.
    if syst-subrc ne 0.
*     if called from configuration, just ignore missing
*     database entries, because we wanted to delete them anyway.
      if p_called_from_cu is initial.
        message a587 with tabausp.
      endif.
    endif.
  endif.

*-- Einfügen in Index-Tabelle der Änderungsnummern
  read table g_claennr_tab index 1.
  if sy-subrc is initial.
    insert claennr from table g_claennr_tab
                        accepting duplicate keys .
  endif.

endform.                    "pflegen_all_tabs

*---------------------------------------------------------------------*
*       FORM FIND_KSSK_MAX_ADZHL                                      *
*---------------------------------------------------------------------*
*       Bestimmen MAX_ADZHL                                           *
*---------------------------------------------------------------------*
form find_kssk_max_adzhl using delete type c.
*
  data: l_subrc like sy-subrc.
*
  data  : begin of ks,
            objek like kssk-objek,
            mafid like kssk-mafid,
            klart like kssk-klart,
            clint like kssk-clint,
            adzhl like kssk-adzhl.
  data  : end   of ks.
*
  loop at v1kssk.
    if not delete is initial.          "komme vom löschen
      perform lesen_kssk using l_subrc.
      if l_subrc = 1.
        append vkssk.
        continue.
      endif.
      v1kssk = vkssk.
    endif.
    select objek mafid klart clint max( adzhl )
      from kssk
      into (ks-objek,ks-mafid,ks-klart,ks-clint,ks-adzhl)
      where mafid =  v1kssk-mafid
        and klart =  v1kssk-klart
        and objek =  v1kssk-objek
        and clint le v1kssk-clint
        and clint ge v1kssk-clint
      group by objek mafid klart clint.
      exit.
    endselect.
    if syst-subrc = 0.
      v1kssk-adzhl = ks-adzhl + 1.
    endif.
    hkssk = v1kssk.
    append hkssk.
  endloop.
endform.                    "find_kssk_max_adzhl

*---------------------------------------------------------------------*
*       FORM LESEN_KSSK                                               *
*---------------------------------------------------------------------*
*       Lesen KSSK                                                    *
*---------------------------------------------------------------------*
form lesen_kssk using return like syst-subrc.
*
  data : rc like syst-subrc.
  data : begin of zkssk occurs 0.
          include structure kssk.
  data : end   of zkssk.
*
  call function 'CLSE_SELECT_KSSK_0'
    exporting
      clint          = v1kssk-clint
      klart          = v1kssk-klart
      mafid          = v1kssk-mafid
      objek          = v1kssk-objek
      neclint        = space
      key_date       = xdatuv
    tables
      exp_kssk       = zkssk
    exceptions
      no_entry_found = 01.
  if syst-subrc = 0.
    read table zkssk index 1.
    vkssk       = zkssk.
    vkssk-aennr = xaennr.
    if not g_effectivity_used is initial.
      vkssk-datuv = g_effectivity_date.
    else.
      vkssk-datuv = xdatuv.
    endif.
    vkssk-lkenz = kreuz.               "löschen KSSK
    if not zkssk-aennr is initial and zkssk-aennr = xaennr.
      rc = 1.                     "Änderungsnummer im Satz nicht initial
    else.                              "und gleich neuer
      rc = 0.
    endif.
    return = rc.
  else.
*-- nichts gefunden : RC = 0 setzen
    clear return.
  endif.

endform.                    "lesen_kssk

*&---------------------------------------------------------------------*
*&      Form  PFLEGEN_CLAENNR
*&---------------------------------------------------------------------*
*       Fügt Einträge in Tabelle G_CLAENNR_ATB ein
*----------------------------------------------------------------------*
form pflegen_claennr using p_klart like kssk-klart
                           p_clint like kssk-clint .

  check not g_effectivity_used is initial.
  g_claennr_tab-mandt = sy-mandt .
  g_claennr_tab-klart = p_klart .
  g_claennr_tab-clint = p_clint .
  g_claennr_tab-aennr = xaennr.
  append g_claennr_tab.

endform.                               " PFLEGEN_CLAENNR

*&---------------------------------------------------------------------*
*&      Form  fill_redun
*&---------------------------------------------------------------------*
*       Setups table redun:
*       Parameters of all class types used when updating.
*----------------------------------------------------------------------*
form fill_redun
     using value(p_klart)
           value(p_obtab).

  select single * from tcla
                  where klart = p_klart.

* for class/class
  move-corresponding tcla to redun.
  clear redun-obtab.
  redun-redun = abap_true.  " always store ref.char.values redundantly
  append redun.

* for class/object
  refresh iklart.
  clear redun.
  call function 'CLOB_SELECT_TABLE_FOR_CLASSTYP'
    exporting
      classtype      = p_klart
    tables
      itable         = iklart
    exceptions
      no_table_found = 1
      others         = 2.
  loop at iklart.
    move-corresponding iklart to redun.
    redun-klart    = p_klart.
    redun-konfobj  = tcla-konfobj.
    redun-ausp_new = tcla-ausp_new.
    redun-ausp_gen = tcla-ausp_gen.
    append redun.
  endloop.

  sort redun by klart obtab.
  read table redun with key klart = p_klart
                            obtab = p_obtab
                            binary search.

endform.                               " fill_redun

* Begin Correction 27.01.2004 0701214 *******************
*---------------------------------------------------------------------*
*       FORM FLAG_EHS_MOD_ACTIVE_SET                                  *
*---------------------------------------------------------------------*
FORM FLAG_EHS_MOD_ACTIVE_SET "#EC CALLED
* Purpose: Form to set the global flag G_FLG_EHS_MOD_ACTIVE (see the
*          comments at its declaration) via external PERFORM's (see
*          also note 701214).
     USING
        VALUE(I_FLAG_EHS_MOD_ACTIVE) TYPE C.
*       new value of the flag

* Function body -------------------------------------------------------
  G_FLG_EHS_MOD_ACTIVE = I_FLAG_EHS_MOD_ACTIVE.

ENDFORM.
* End Correction 27.01.2004 0701214 *********************



* function module UPDATE_MATERIAL_CLASSIFICATION               v 1984597
* and DDIC structure PRE03
* are available only in SAP_APPL not in SAP_ABA
* -> encapsulate dynamic processing of structure and function call

CLASS lcl_material IMPLEMENTATION.

  METHOD class_constructor.

    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING    funcname           = mc_upd_mat_clf
      EXCEPTIONS   function_not_exist = 1
                   OTHERS             = 2.

    IF sy-subrc IS INITIAL.
      TRY.
        CREATE DATA mattab TYPE TABLE OF (mc_pre03).
        CREATE DATA matrow TYPE (mc_pre03).
      CATCH cx_sy_create_data_error.
      ENDTRY.
    ENDIF.

  ENDMETHOD. " class_constructor

  METHOD add.

    FIELD-SYMBOLS: <mattab> TYPE STANDARD TABLE,
                   <matrow> TYPE any,
                   <matnr>  TYPE any.

    CHECK NOT mattab IS INITIAL.

    ASSIGN mattab->* TO <mattab>.
    ASSIGN matrow->* TO <matrow>.
    ASSIGN COMPONENT mc_matnr OF STRUCTURE <matrow> TO <matnr>.

    CLEAR <matrow>.
    <matnr> = p_material.

    IF m_sorted IS INITIAL.
      APPEND <matrow> TO <mattab>.
    ELSE.
      READ TABLE <mattab> WITH KEY (mc_matnr) = <matnr> BINARY SEARCH
        TRANSPORTING NO FIELDS.
      CASE sy-subrc.
        WHEN 4.
          INSERT <matrow> INTO <mattab> INDEX sy-tabix.
        WHEN 8.
          APPEND <matrow> TO <mattab>.
      ENDCASE.
    ENDIF.

  ENDMETHOD. " add

  METHOD sort.

    FIELD-SYMBOLS <mattab> TYPE STANDARD TABLE.

    CHECK NOT mattab IS INITIAL.

    ASSIGN mattab->* TO <mattab>.
    SORT <mattab> BY (mc_matnr).
    m_sorted = 'X'.

  ENDMETHOD. " sort

  METHOD update.

    FIELD-SYMBOLS <mattab> TYPE STANDARD TABLE.

    CHECK NOT mattab IS INITIAL.

    ASSIGN mattab->* TO <mattab>.
    IF NOT <mattab>[] IS INITIAL.
      CALL FUNCTION mc_upd_mat_clf
        EXPORTING
          after_mat_create = after_mat_create
        TABLES
          matnr_tab        = <mattab>.
    ENDIF.

  ENDMETHOD. " update

ENDCLASS.                                                     "^ 1984597
