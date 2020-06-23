*----------------------------------------------------------------------*
***INCLUDE LWSOTF02 .
*----------------------------------------------------------------------*


*"----------------------------------------------------------------------
* INSERT WLK1
*"----------------------------------------------------------------------
form insert_wlk1 using i_wlk1 structure wlk1.
*                      INT_WLK1 STRUCTURE WLK1.

  data : ins_type(1).
  data: i_wlk1_u type wlk1_u.                               " TC 4.6C
  move-corresponding i_wlk1 to i_wlk1_u.                    " TC 4.6C
  clear wint_pos.
  ins_type = 'I'.
*  PERFORM SAVE_WLK1 USING I_WLK1                              " TC 4.6C
  perform save_wlk1 using i_wlk1_u                          " TC 4.6C
                          ins_type
                          wint_pos
                          s_wsor_ctrl.
*                         I_WLK1.
endform.                    "insert_wlk1

*"----------------------------------------------------------------------
* UPDATE WLK1
*"----------------------------------------------------------------------
*FORM UPDATE_WLK1 USING I_WLK1 STRUCTURE WLK1.                 " TC 4.6C
form update_wlk1 using i_wlk1_u structure wlk1_u.           " TC 4.6C
*                      INT_WLK1 STRUCTURE WLK1.
  data : upd_type(1).
  upd_type = 'U'.
*  PERFORM SAVE_WLK1 USING I_WLK1                              " TC 4.6C
  perform save_wlk1 using i_wlk1_u                          " TC 4.6C
                          upd_type
                          wint_pos
                          s_wsor_ctrl.
*                         I_WLK1.
endform.                    "update_wlk1

*"----------------------------------------------------------------------
* DELETE WLK1
*"----------------------------------------------------------------------
form delete_wlk1 using i_wlk1 structure wlk1.

  data : del_type(1).
  data: i_wlk1_u type wlk1_u.                               " TC 4.6C
  data: i_zeitraum_erhalten like wtdy-typ01.

* begin del. note No. 553475
*  CALL FUNCTION 'LISTING_PARAMETER_SET'
*    CHANGING
**     P_AUSLIST_STATUS               =
*      P_ZEITRAUM_ERHALTEN            = i_zeitraum_erhalten
**     P_IGNORE_MVKE_CHECK            =
**     P_IGNORE_MARC_MBEW_CHECK       =
*            .

  move-corresponding i_wlk1 to i_wlk1_u.                    " TC 4.6C
*  if i_zeitraum_erhalten ne 'X' or
*    i_wlk1-datbi >= sy-datum.
  del_type = 'D'.
*  PERFORM SAVE_WLK1 USING I_WLK1                              " TC 4.6C
  perform save_wlk1 using i_wlk1_u                          " TC 4.6C
                          del_type
                          wint_pos
                          s_wsor_ctrl.
*                         I_WLK1.
*  endif.
* end del. note No. 553475
endform.                    "delete_wlk1

*---------------------------------------------------------------------*
*       FORM SAVE_WLK1                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  WLK1                                                          *
*  -->  SAVE_TYPE                                                     *
*  -->  WINT_POS                                                      *
*  -->  INT_WLK1                                                      *
*---------------------------------------------------------------------*
*FORM SAVE_WLK1  USING WLK1 STRUCTURE WLK1                    " TC 4.6C
form save_wlk1  using wlk1 structure wlk1_u                 " TC 4.6C
                      save_type
                      wint_pos structure wint_pos
                      s_wsor_ctrl structure wsor_ctrl.
*                     INT_WLK1 STRUCTURE WLK1.

************************************************************************
*! Ergänzung Th. Collet 12.12.97     !!!!!!!!!!!!!!!!!!!!!!!!!11!!     *
* Meiner Meinung werden die beiden Parameter WINT_POS und INT_WLK1
** nicht benötigt. Da sie jedoch in vielen Fällen aufgerufen werden,
*
* entferne ich sie momentan noch nicht.                                *
* Wenn WLK1_change modifiert wird, dann können die beiden Parameter
** ebenfalls entfernt werden.
*
* HALT: in int_wlk1 steht der neue WLK1 - Eintrag
*
*                                                                      *
************************************************************************

  data : begin of com1.
      include structure com_wlk1.
  data : end of com1.
  data: i_mara like mara.
  data: h_wlk1 type wlk1.

  if twpa-likon = space.   "bei 'X' keine Listungs-Konditionen anlegen

    wint_pos-sposi = wlk1-artnr.

* Neuerung: nicht sofortiges Wegschreiben der Listungskondition, sondern
* aufheben in einer internen Tabelle
* diese Tabelle wird dann beim COMMIT tatsächlich physisch ausgegeben
* es ist von hier aus noch die Ansteuerung des Anlegens von MAxx-
* Segmenten zu veranlassen
* dazu ist ebenfalls die Tabelle COM_WLK1 zu nutzen
    if wlk1-datab > wlk1-datbi.
      wlk1-datab = wlk1-datbi.
    endif.
    if wlk1-datae is initial.                               " TCO 4.6B
      wlk1-datae = sy-datum.                                " TCO 4.6B
    endif.                                                  " TCO 4.6B
    if wint_pos-datuv > wint_pos-datub.
      wint_pos-datuv = wint_pos-datub.
    endif.
    if not ( wlk1-artnr is initial ).
      move-corresponding wint_pos to com_wlk1.
      move-corresponding wlk1 to com_wlk1.
* begin ins hbo 28.09.00
* füllen von satnr für alle Varianten mit dem Sammelartikel, für alle
* anderen Artikel mit dem artnr. Dies ist notwendig, um in der
* parallelen Verbuchung die Pakete richtig zu packen.
* Die mara MUß gelesen werden, es genügt nicht nur die Felder strnr
* und strli der wlk1 zu betrachten, da beim Lot die Komponenten
* srli = 'X' gesetzt haben, aber gleichzeitig Varianten sind!!

      if com_wlk1-artnr <> com_wlk1-strnr.
        call function 'MARA_SINGLE_READ'
          exporting
            matnr             = com_wlk1-artnr
          importing
            wmara             = i_mara
          exceptions
            lock_on_material  = 1
            lock_system_error = 2
            wrong_call        = 3
            not_found         = 4
            others            = 5.
        if sy-subrc = 0.
          if i_mara-attyp = c_variante.
            com_wlk1-satnr = i_mara-satnr.
          else.
            com_wlk1-satnr = com_wlk1-artnr.
          endif. "        if i_mara-attyp = c_variante.
        endif.                         " if sy-subrc = 0.
      else. "if com_wlk1-artnr <> com_wlk1-strnr.
        com_wlk1-satnr = com_wlk1-artnr.
      endif.
* end ins hbo 28.09.00

      com_wlk1-pflkn_w = wlk1-pflkn.
      com_wlk1-ursac_w = wlk1-ursac.
      com_wlk1-negat_w = wlk1-negat.
      com_wlk1-save_type = save_type.
      "X9
      if save_type = 'I' and com_wlk1-lfdnr = 0.
        com_wlk1-lfdnr = 1.
      endif.
      if com_wlk1-quell is initial.
        call function 'ASS_CHECK_APPLICATION_AREA'
          importing
            tcode  = so-tcode
            wappl  = so-subrc
          exceptions
            others = 1.
        case so-subrc.
          when 1.
            com_wlk1-quell = '3'.
          when 2.
            com_wlk1-quell = '2'.
          when 3.
            com_wlk1-quell = '4'.
          when 4.
            com_wlk1-quell = '1'.
          when 5.
            com_wlk1-quell = '5'.
          when 6.
            com_wlk1-quell = '6'.
        endcase.
      endif.
      com_wlk1-mandt = sy-mandt.
      com_wlk1-datbi_old = wlk1-datbi_old.
      read table com_wlk1 into com1 with key
                 save_type = com_wlk1-save_type
                 filia     = com_wlk1-filia
                 artnr     = com_wlk1-artnr
                 vrkme     = com_wlk1-vrkme
                 datbi     = com_wlk1-datbi
                 lfdnr     = com_wlk1-lfdnr
                 ursac_w   = com_wlk1-ursac_w "softkey - necessary for deletions, or if several listing conditions are to be updated in an IDOC
           binary search.
      if sy-subrc = 0.
        "in insert case security check: logical key and physical key
        if com_wlk1-save_type = 'I'.
          perform change_lfdnr changing com_wlk1
                                        com1
                                        sy-subrc
                                        sy-tabix.
        endif.
      endif.
      if sy-subrc <> 0.
        h_tabix = sy-tabix.            " INSERT
        com_wlk1-zeiger = 0.
        insert com_wlk1 index h_tabix. " INSERT
* die Daten werden in den Puffer geschrieben
        if save_type = 'I'.
          move-corresponding com_wlk1 to buffer_wlk1.
          move com_wlk1-ursac_w to buffer_wlk1-ursac.
          perform buffer_wlk1_insert_entry(saplwsol) using buffer_wlk1.
        elseif save_type = 'U'.        " COLLETT 4.5B
          move-corresponding com_wlk1 to buffer_wlk1.     " COLLETT 4.5B
          move com_wlk1-ursac_w to buffer_wlk1-ursac.     " COLLETT 4.5B

          if com_wlk1-datbi <> com_wlk1-datbi_old.
            " change datbi -> delete old buffer entry
            " and insert new entry with new datbi
            move-corresponding com_wlk1 to h_wlk1.
            h_wlk1-datbi = com_wlk1-datbi_old.
            h_wlk1-ursac = com_wlk1-ursac_w.
            perform buffer_wlk1_delete_entry(saplwsol) using h_wlk1.
          endif.

          perform buffer_wlk1_insert_entry(saplwsol)      " COLLETT 4.5B
                  using buffer_wlk1.   " COLLETT 4.5B
        elseif save_type = 'D'.
          move-corresponding com_wlk1 to buffer_wlk1.
          move com_wlk1-ursac_w to buffer_wlk1-ursac.
          perform buffer_wlk1_delete_entry(saplwsol)      " COLLETT 4.5B
                  using buffer_wlk1.   " COLLETT 4.5B
        endif.

* dafür sorgen, daß beim COMMIT die Ausgabe erfolgt
*        if q_com_wlk1 is initial.
        perform wlk1_aus on commit.
        q_com_wlk1 = 'X'.
*        endif.
      endif.
    endif.
  endif.
endform.                                                    "save_wlk1

*---------------------------------------------------------------------*
*       FORM WLK1_AUS                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* change    history   Author  note
*  ID        date
*  @001@    10/07/02   hbo   560811
*----------------------------------------------------------------------
form wlk1_aus.                         "Aufruf ON COMMIT

  data: h_com_wlk1 like com_wlk1 occurs 0 with header line. " 4.5B
  data: h_satnr like wlk1-strnr,
        h_artnr like wlk1-artnr.
  data: anz_gesamt_artikel like sy-tabix,
        anz_artikel        like sy-tabix,
        z1                 like sy-tabix.
  data: anz_lines       type i,
        it_package_info type package_info occurs 1 with header line.

  if g_upd_mode = upd_mode_rop                              " TC 366691
  or g_upd_mode = upd_mode_par.                             " TC 366691
    call function 'LISTING_PARALLEL_PARAMETER_GET'
      importing
        es_wsor_ctrl       = s_wsor_ctrl
      exceptions
        parameters_not_set = 1
        others             = 2.
    if sy-subrc <> 0.
      s_wsor_ctrl-parallel = 'X'.
      if s_wsor_ctrl-server_grp is initial.                 " TC 366691
        s_wsor_ctrl-server_grp = c_srvergrp_default.        " TC 366691
      endif.
      if s_wsor_ctrl-max_tasks = 0 or s_wsor_ctrl-max_tasks = ''.
        s_wsor_ctrl-max_tasks = 5.                          " TC 366691
      endif.
      if s_wsor_ctrl-max_artikel = 0 or s_wsor_ctrl-max_artikel = ''.
        s_wsor_ctrl-max_artikel = 100.                      " TC 366691
      endif.
    endif.

  endif.                                                    " TC 366691

  if  s_wsor_ctrl-parallel = 'X'.
    " initialize server group for asynchronous tasks
    perform tasks_server_group_init using s_wsor_ctrl.
    " parallele Verbuchung
    perform update_parallel tables com_wlk1
                            using s_wsor_ctrl.

    clear com_wlk1.
    refresh com_wlk1.

    exit.
  endif.

  if sy-batch is initial.
* Sortierkriterium artnr
    sort com_wlk1 ascending by artnr.
    call function 'WLK1_CHANGE_MATERIAL' in update task
      exporting
        p_create_change_document = create_change_document
        iv_upd_task              = 'X'                    "note 1304304
      tables
        pt_com_wlk1              = com_wlk1.
  else.
    if sy-tcode = 'MM41' or
       g_upd_mode is initial or        " COLLETT 4.6A
       sy-tcode = 'MM42'.
* Sortierkriterium artnr
      sort com_wlk1 ascending by artnr.

* note 1304304: if article dialog maintenance is active, then execute
* WLK1_CHANGE_MATERIAL also in update task mode to don't destroy the
* classification buffer!
      data: lv_mat_maintenance.
      call function 'MATERIAL_GET_MAT_MAINTENANCE'
        importing
          iv_mat_maintenance = lv_mat_maintenance.

      if lv_mat_maintenance = 'X'.
        call function 'WLK1_CHANGE_MATERIAL' in update task
          exporting
            p_create_change_document = create_change_document
            iv_upd_task              = 'X'
          tables
            pt_com_wlk1              = com_wlk1.
      else.
        call function 'WLK1_CHANGE_MATERIAL'
          exporting
            p_create_change_document = create_change_document
          tables
            pt_com_wlk1              = com_wlk1.
      endif.
    else.
* Sortierkriterien für com_wlk1 nach wlk1-Key und strnr
      sort com_wlk1 ascending by satnr artnr.
      clear h_satnr.
      clear h_artnr.
      clear z1.
      anz_lines = 0.
      it_package_info-pnumber = 1.
      append it_package_info.

      loop at com_wlk1.
        h_tabix = sy-tabix.
* begin change hbo 28.09.00
* falls der Artikel eine Variante ist -> lese alle Varianten und den
* Sammelartikel (falls vorhanden -> bei Lot z.B. fehlt er) in dasselbe
* Paket ein: Alle Varianten und der Sammelartikel haben im Feld satnr
* den Sammelartikel stehen.
        if com_wlk1-satnr <> h_satnr.
          if z1 >= 1000 .
            it_package_info-anzlines = anz_lines.
            modify it_package_info index 1.
            perform verbuchen tables h_com_wlk1.
            refresh h_com_wlk1.
            clear anz_lines.
            clear z1.
            it_package_info-pnumber = it_package_info-pnumber + 1.
            modify it_package_info index 1.
          endif.
          h_satnr = com_wlk1-satnr.
        endif.
        if com_wlk1-artnr <> h_artnr.
          add 1 to z1.
          h_artnr = com_wlk1-artnr.
        endif.
        com_wlk1-zeiger = it_package_info-pnumber.
        "hier keinesfalls Index nutzen, da dieser durch
        "return_info verändert sein kann!
        modify com_wlk1 from com_wlk1 index h_tabix.
        move-corresponding com_wlk1 to h_com_wlk1.
        append h_com_wlk1.
        anz_lines = anz_lines + 1.
      endloop.                         "LOOP AT com_wlk1.

      if z1 > 0.
        perform verbuchen tables h_com_wlk1.
        refresh h_com_wlk1.
      endif.
      wait until snd_jobs = 0.                              " TCO 4.6B
    endif.

  endif.


* ELSE.
*   CLEAR z1.                          " 4.5B
*   LOOP AT com_wlk1.                  " 4.5B
*     ON CHANGE OF com_wlk1-artnr.     " 4.5B
*       ADD 1 TO z1.                   " 4.5B
*
*       IF com_wlk1-artnr = com_wlk1-strnr.
*         CLEAR semaphore.
*         IF z1 > 1000.                " 4.5B
*
**          perform verbuchen tables h_com_wlk1.
*
*          CALL FUNCTION 'WLK1_CHANGE_MATERIAL_RFC'               " 4.5B
*               STARTING NEW TASK 'WLK1'                          " 4.5B
*               DESTINATION IN GROUP DEFAULT                      " 4.5B
*               PERFORMING return_info ON END OF TASK             " 4.5B
*                 TABLES               " 4.5B
*                    pt_com_wlk1 = h_com_wlk1                     " 4.5B
*                 exceptions           " 4.5B
*                    communication_failure = 1                    " 4.5B
*                    system_failure        = 2.                   " 4.5B
*           IF sy-subrc = 0.           " 4.5B
*            WAIT UNTIL semaphore = 'X'.                          " 4.5B
*           ENDIF.                     " 4.5B
*           REFRESH h_com_wlk1.        " 4.5B
*           CLEAR z1.                  " 4.5B
*         ENDIF.                       " 4.5B
*       ENDIF.                         " 4.5B
*     ENDON.                           " 4.5B
*    MOVE-CORRESPONDING com_wlk1 TO h_com_wlk1.                   " 4.5B
*     APPEND h_com_wlk1.               " 4.5B
*   ENDLOOP.                           " 4.5B

*   CLEAR semaphore.                   " 4.5B
*   CALL FUNCTION 'WLK1_CHANGE_MATERIAL_RFC'                 " 4.5B
*        STARTING NEW TASK 'WLK1'      " 4.5B
*        DESTINATION IN GROUP DEFAULT  " 4.5B
*        PERFORMING return_info ON END OF TASK                 " 4.5B
*        TABLES                        " 4.5B
*             pt_com_wlk1 = h_com_wlk1 " INSERT 4.5B
*        EXCEPTIONS                    " 4.5B
*             communication_failure = 1" 4.5B
*             system_failure        = 2.                 " 4.5B
*   IF sy-subrc = 0.                   " 4.5B
*     WAIT UNTIL semaphore = 'X'.      " 4.5B
*   ENDIF.                             " 4.5B
*
* ENDIF.

  clear com_wlk1.
  refresh com_wlk1.

endform.                                                    "wlk1_aus

*&---------------------------------------------------------------------*
*&      Form  CHECK_WRS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INT_WLK1_FILIA  text                                       *
*----------------------------------------------------------------------*
form check_wrs1 using    shop.
  call function 'WRS1_SINGLE_READ'
    exporting
      asort           = shop
*     SPRAS           =
    importing
      wrs1_out        = wrs1
*     WRST_OUT        =
    exceptions
      no_record_found = 1
      spras_not_found = 2
      others          = 3.
  if sy-subrc = 0.
*    IF wrs1-kzlik = 'X'.
*      sy-subrc = 0.
*    ELSE.
*      sy-subrc = 1.                    "keine List.-Kond.
*    ENDIF.
  else.
    "wenn kein WRS1-Segment gefunden --> keine LIKON !
    sy-subrc = 1.
  endif.
endform.                               " CHECK_WRS1


*"----------------------------------------------------------------------
*  Änderungsbelege schreiben WLK1
*"----------------------------------------------------------------------

form belege_wlk1 using
                 *wlk1 structure wlk1
                 wlk1 structure wlk1
                 save_type.
* die Ausgabe der Belege erfolgt jetzt in Form WLK1_AUS_SAVETYPE
* es wird hier nur der jeweils alte Beleginhalt gemerkt in Tabelle

* move wlk1 to wlk_neu.
* move *wlk1 to wlk_alt.
* case save_type.
*   when 'I'.
*     "es wird der Änderungsbeleg geschrieben für Hinzufügen
*     move-corresponding wlk1 to com_wlk1_belege.
*     append com_wlk1_belege.
*   when 'D'.
*     "es wird der Änderungsbeleg geschrieben für Löschen
*     move-corresponding dwlk1 to com_wlk1_belege.
*     append com_wlk1_belege.
*   when 'U'.
**    if not ( dwlk1-filia is initial ).
*       move-corresponding dwlk1 to com_wlk1_belege.
*       append com_wlk1_belege.
**    endif.
* endcase.
endform.                    "belege_wlk1

*---------------------------------------------------------------------*
*       FORM UPGRADE_OLD_TO_NEW_WLK1                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT_NEW_WLK1                                                   *
*  -->  PT_DEL_WLK1                                                   *
*  -->  P_NEW_WLK1                                                    *
*---------------------------------------------------------------------*
form  upgrade_old_to_new_wlk1          " TABLES P_ACT_WLK1
                              tables pt_new_wlk1 structure wlk1
                                     pt_del_wlk1 structure wlk1
                              using  p_new_wlk1 like wlk1.

  data:  pt_act_wlk1 like wlk1 occurs 0 with header line.
  data: ht_skopf type skopf_matnr occurs 0 with header line.

  select * from wlk1 into table pt_act_wlk1
       where filia = p_new_wlk1-filia and
             artnr = p_new_wlk1-artnr and
             vrkme = p_new_wlk1-vrkme.


  loop at pt_act_wlk1.
    if pt_act_wlk1-ursac = space or
       pt_act_wlk1-strli <> ' '  or
       pt_act_wlk1-anzal > '001'.
      refresh ht_skopf.
      perform read_all_skopf tables ht_skopf
                             using pt_act_wlk1-filia
                                   pt_act_wlk1-artnr
                                   pt_act_wlk1-vrkme
                                   pt_act_wlk1-datab
                                   pt_act_wlk1-datbi
                                   pt_act_wlk1-anzal
                                   pt_act_wlk1-strli.

      perform fill_new_wlk1_table tables ht_skopf
                                         pt_new_wlk1
                                  using pt_act_wlk1.
    else.
      move-corresponding pt_act_wlk1 to pt_new_wlk1.
      append pt_new_wlk1.
    endif.
  endloop.

  sort pt_new_wlk1 ascending by filia
                                artnr
                                ursac
                                datab.

  perform reduce_wlk1 tables pt_new_wlk1.
  pt_del_wlk1[] = pt_act_wlk1[].

* Jetzt wurden die bestehenden Sätze auf das neue Verfahren
* geändert. Nun muß nur noch die aktuelle Listungskondition geändert
* werden.
  read table pt_new_wlk1 with key
            filia = p_new_wlk1-filia   "hardkey
            artnr = p_new_wlk1-artnr
            vrkme = p_new_wlk1-vrkme

            ursac = p_new_wlk1-ursac   "softkey
            strnr = p_new_wlk1-strnr.
  if sy-subrc = 0.
    pt_new_wlk1-datab = p_new_wlk1-datab.
    pt_new_wlk1-pflkn = p_new_wlk1-pflkn.
    pt_new_wlk1-datae = sy-datum.      "Verwaltung
    pt_new_wlk1-datbi = p_new_wlk1-datbi.
    modify pt_new_wlk1 index sy-tabix.
  else.
    move-corresponding p_new_wlk1 to pt_new_wlk1.
    append pt_new_wlk1.
  endif.

endform.                    "upgrade_old_to_new_wlk1


*---------------------------------------------------------------------*
*       FORM READ_ALL_SKOPF                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_HT_SKOPF                                                    *
*  -->  P_FILIA                                                       *
*  -->  P_MATNR                                                       *
*  -->  P_VRKME                                                       *
*  -->  P_DATAB                                                       *
*  -->  P_DATBI                                                       *
*  -->  P_ANZAL                                                       *
*  -->  P_STRLI                                                       *
*---------------------------------------------------------------------*
form read_all_skopf tables   p_ht_skopf type t_skopf_matnr
                    using    p_filia
                             p_matnr
                             p_vrkme
                             p_datab
                             p_datbi
                             p_anzal
                             p_strli.

  data: z1 like sy-tabix.
  data: ht_mara like pre03 occurs 0 with header line.
  data: ht_struct_material like rmgw2wu occurs 0 with header line.
  data: material_kennung.

  perform material_read_2(saplwsoc) using  p_matnr sy-datum mara.
  if mara-attyp = '02'.
    material_kennung = variante.
  else.
    if not p_strli is initial.
      material_kennung = komponente.
    else.
      material_kennung = einzelmaterial.
    endif.
  endif.

  case material_kennung.

    when einzelmaterial.

* Artikel ist nicht als Komponente gelistet
      select p~skopf p~sposi into (p_ht_skopf-skopf, p_ht_skopf-matnr)
              from wsop as p inner join  wsof as f     "#EC CI_BUFFJOIN
            on p~skopf = f~skopf
          where p~sposi    = p_matnr and
                f~filiale  = p_filia and
                p~datuv   <= p_datab and
                f~datub   >= p_datbi and
                p~datuv   <= p_datab and
                f~datub   >= p_datbi.

        append p_ht_skopf.

      endselect.

      describe table p_ht_skopf lines z1.

      if z1 = p_anzal.                                      "ok
      else.
* Artikel kann über Profilbaustein gelistet werden.
        perform material_read_2(saplwsoc)
                                using    p_matnr sy-datum mara.
        perform wsoh_read_matkl(saplwsoc) using  p_filia mara-matkl
                                       changing wsoh        " COLLETT 99
                                                sy-subrc.   " COLLETT 99
        if sy-subrc = 0.
          move wsoh-skopf to  p_ht_skopf-skopf.
          move p_matnr    to  p_ht_skopf-matnr.
          append p_ht_skopf.
          z1 = z1 + 1.
        endif.
*       IF Z1 <> P_ANZAL.
*         WRITE: 'Inkonsistenz bei WLK1-Anzal für ', P_FILIA, P_MATNR.
*       ENDIF.
      endif.

    when variante.

* Variante:
* Die Variante kann über den Sammelartikel oder über ein strukturierten
* Artikel gelistet werden

* Lesen des Sammelartikels
      move mara-satnr to ht_mara-matnr.
      append ht_mara.

* In der 4.0-Schiene kann die Variante selbst gelistet sein
      move mara-matnr to ht_mara-matnr.
      append ht_mara.

* Bestimmen aller strukturierten Materialien für Komponente
      call function 'MGW0_WHERE_USED_COMPONENTS'
        exporting
          mgw0_matnr          = p_matnr
        tables
          structured_articles = ht_struct_material
        exceptions
          others              = 1.
      loop at ht_struct_material.
        move ht_struct_material-matnr to ht_mara-matnr.
        append ht_mara.
      endloop.

* Überprüfen, in welchen Köpfen der Artikel bzw. SA gelistet sind.
      select p~skopf p~sposi into (p_ht_skopf-skopf, p_ht_skopf-matnr)
                from wsop as p inner join  wsof as f   "#EC CI_BUFFJOIN
              on p~skopf = f~skopf
                for all entries in ht_mara
            where p~sposi    = ht_mara-matnr and
                  f~filiale  = p_filia and
                  p~datuv   <= p_datab and
                  f~datub   >= p_datbi and
                  p~datuv   <= p_datab and
                  f~datub   >= p_datbi.

        append p_ht_skopf.

      endselect.

      describe table p_ht_skopf lines z1.

      if z1 = p_anzal.                                      "ok
      else.
* Der Artikel kann nur über den SA in einen Profilbaustein reingerutscht
* sein.
        perform material_read_2(saplwsoc)
                using mara-satnr sy-datum mara.
        perform wsoh_read_matkl(saplwsoc) using p_filia mara-matkl
                                          changing wsoh     " COLLETT 99
                                                   sy-subrc." COLLETT 99
        if sy-subrc = 0.
          read table p_ht_skopf with key skopf = wsoh-skopf.
          if sy-subrc <> 0.
            move wsoh-skopf to  p_ht_skopf-skopf.
            move mara-matnr to  p_ht_skopf-matnr.
            append p_ht_skopf.
            z1 = z1 + 1.
          endif.
        endif.
*       IF Z1 <> P_ANZAL.
*         WRITE: 'Inkonsistenz bei WLK1-Anzal für ', P_FILIA, P_MATNR.
*       ENDIF.
      endif.

    when komponente.

* Der Artikel ist als Komponente eines strukturierten Artikels
* gelistet, kann aber auch selbst gelistet sein.

* Bestimmen aller strukturierten Materialien für Komponente
      call function 'MGW0_WHERE_USED_COMPONENTS'
        exporting
          mgw0_matnr          = p_matnr
        tables
          structured_articles = ht_struct_material
        exceptions
          others              = 1.
      loop at ht_struct_material.
        move ht_struct_material-matnr to ht_mara-matnr.
        append ht_mara.
      endloop.

* Der Artikel kann auch selbst gelistet sein.
      move mara-matnr to ht_mara-matnr.
      append ht_mara.

* Überprüfen, in welchen Köpfen der Artikel bzw. SA gelistet sind.
      select p~skopf p~sposi into (p_ht_skopf-skopf, p_ht_skopf-matnr)
                from wsop as p inner join  wsof as f   "#EC CI_BUFFJOIN
              on p~skopf = f~skopf
                for all entries in ht_mara
            where p~sposi    = ht_mara-matnr and
                  f~filiale  = p_filia and
                  p~datuv   <= p_datab and
                  f~datub   >= p_datbi and
                  p~datuv   <= p_datab and
                  f~datub   >= p_datbi.

        append p_ht_skopf.

      endselect.

      describe table p_ht_skopf lines z1.

      if z1 = p_anzal.                                      "ok
      else.
* Artikel kann über Profilbaustein gelistet werden.
        perform wsoh_read_matkl(saplwsoc) using    p_filia mara-matkl
                                        changing wsoh       " COLLETT 99
                                                 sy-subrc.  " COLLETT 99
        if sy-subrc = 0.
          move wsoh-skopf to  p_ht_skopf-skopf.
          move p_matnr    to  p_ht_skopf-matnr.
          append p_ht_skopf.
          z1 = z1 + 1.
        endif.
*       IF Z1 <> P_ANZAL.
*         WRITE: 'Inkonsistenz bei WLK1-Anzal für ', P_FILIA, P_MATNR.
*       ENDIF.
      endif.

  endcase.

endform.                               " READ_ALL_SKOPF

*&---------------------------------------------------------------------*
*&      Form  FILL_NEW_WLK1_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_HT_SKOPF  text                                             *
*      -->P_PRT_WLK1  text                                             *
*----------------------------------------------------------------------*
form fill_new_wlk1_table tables   p_ht_skopf type t_skopf_matnr
                                  pt_new_wlk1   structure wlk1
                         using    p_wlk1 like wlk1.

  loop at p_ht_skopf.

    move p_wlk1 to pt_new_wlk1.
    pt_new_wlk1-ursac = p_ht_skopf-skopf.
    pt_new_wlk1-anzal = 1.
    clear pt_new_wlk1-strli.
*   IF PT_NEW_WLK1-STRLI IS INITIAL.
    pt_new_wlk1-strnr = p_ht_skopf-matnr.
*   ENDIF.
    append pt_new_wlk1.

  endloop.

endform.                               " FILL_NEW_WLK1_TABLE

*&------------------------------------------------------------------
*&      Form  REDUCE_WLK1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ALL_WLK1  text                                             *
*----------------------------------------------------------------------*
form reduce_wlk1 tables   p_all_wlk1 structure wlk1.

  data: p_all_wlk1_copy like wlk1 occurs 0 with header line.
  data: new_wlk1 like wlk1.
  data: h_ursac      like wlk1-ursac,
        h_datbiplus1 like wlk1-datbi.
  data: h_lfdnr like wlk1-lfdnr.

  clear new_wlk1.
  h_lfdnr = 1.
  p_all_wlk1_copy[] = p_all_wlk1[].
  clear p_all_wlk1. refresh p_all_wlk1.
  loop at p_all_wlk1_copy.

    if p_all_wlk1_copy-ursac <> new_wlk1-ursac or
       ( not p_all_wlk1_copy-strnr is initial and
         p_all_wlk1_copy-strnr <> new_wlk1-strnr ).

      if not new_wlk1 is initial.
        move new_wlk1 to p_all_wlk1.
        clear p_all_wlk1-anzal.
        p_all_wlk1-lfdnr = h_lfdnr.
        add 1 to h_lfdnr.
        if p_all_wlk1-strnr is initial.
          p_all_wlk1-strnr = p_all_wlk1-artnr.
        endif.
        append p_all_wlk1.
      endif.
      move p_all_wlk1_copy to new_wlk1.


    else.                              " IF P_ALL_WLK1-URSAC = H_URSAC.


      h_datbiplus1 = new_wlk1-datbi + 1.
      if p_all_wlk1_copy-datab = h_datbiplus1.
        new_wlk1-datbi = p_all_wlk1_copy-datbi.
      else.
*         WRITE: / 'REDUCE Inkonsistenz bei WLK1-Anzal für ',
*                   NEW_WLK1-FILIA, NEW_WLK1-ARTNR.
      endif.
    endif.
  endloop.


  if not new_wlk1 is initial.
    move new_wlk1 to p_all_wlk1.
    p_all_wlk1-lfdnr = h_lfdnr.
    clear p_all_wlk1-anzal.
    if p_all_wlk1-strnr is initial.
      p_all_wlk1-strnr = p_all_wlk1-artnr.
    endif.
*   MOVE NEW_WLK1 TO P_ALL_WLK1.
    append p_all_wlk1.
  endif.


endform.                               " REDUCE_WLK1



*---------------------------------------------------------------------*
*       FORM RETURN_INFO                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TASKNAME                                                      *
*---------------------------------------------------------------------*
form return_info using taskname.
  data: return    like sy-subrc,
        anz_lines type i.
  data: it_package_info type package_info occurs 1 with header line.
  data: ht_com_wlk1 like com_wlk1 occurs 0 with header line.
*  RECEIVE RESULTS FROM FUNCTION 'RFC_SYSTEM_INFO'
*      IMPORTING  rfcsi_export = info
*      EXCEPTIONS
*         communication_failure = 1
*         system_failure        = 2.
*  ret_subrc = sy-subrc.                "Setzen von RET_SUBRC
*  semaphore = 'X'.                     "Zurücksetzen der Semaphore

  receive results from function 'WLK1_CHANGE_MATERIAL_RFC'
      importing  return = return
      tables     it_package_info = it_package_info
      exceptions
         communication_failure = 1
         system_failure        = 2
         resource_failure      = 3.

  snd_jobs = snd_jobs - 1.
  if sy-subrc = 2
  or (  sy-subrc = 0 and return = 0 ).
*!!! Fehler -> lese Daten mit zeiger = taskname aus pt_com_wlk1 =
* com_wlk1 und starte Verbuchung lokal, schreibe message,
* daß ein rfc mit Name taskname lokal verbucht wurde. Dies sollte man
* auch tun, wenn ein rfc für den WLK1_CHANGE_MATERIAL_RFC nicht geklappt
* hat.
* füllen von h_com_wlk1 mit den Datensätzen des fehlgeschlagenen Pakets
* und Verbuchen
    refresh ht_com_wlk1.
*      clear anz_lines.
    loop at com_wlk1 where zeiger = taskname.
* in case of sy-subrc = 2, the it_package_info is empty!!
      anz_lines = anz_lines + 1.
      ht_com_wlk1 = com_wlk1.
      append ht_com_wlk1.
    endloop.

* asynchronous mode, NO!! update task, because no commit work follows!
    if sy-batch is initial.
      call function 'WLK1_CHANGE_MATERIAL'
        exporting
          p_create_change_document = create_change_document
        tables
          pt_com_wlk1              = ht_com_wlk1.
    else.
* synchronous mode
      call function 'WLK1_CHANGE_MATERIAL'
        exporting
          p_create_change_document = create_change_document
        tables
          pt_com_wlk1              = ht_com_wlk1.
    endif.

* in case of sy-subrc = 2, the it_package_info is empty!!
*        read table it_package_info index 1.
    message s746 with taskname
                    anz_lines.

  elseif sy-subrc = 1.
* Schreibe message, daß task return nicht funktioniert hat
    message s747 with taskname.
  elseif sy-subrc = 3.
    message s749 with taskname.
  endif.                               "if sy-subrc = 0.

endform.                    "return_info


*---------------------------------------------------------------------*
*       FORM VERBUCHEN                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  HT_COM_WLK1                                                   *
*---------------------------------------------------------------------*
form verbuchen tables ht_com_wlk1 structure com_wlk1.

  data: it_package_info type package_info occurs 1 with header line.

* it_package_info wird hier nicht gefüllt, Übergabe ist aber evtl.
* notwendig, damit return info korrekt ausgeführt wird
  do.

    wait until snd_jobs < jobs.

    call function 'WLK1_CHANGE_MATERIAL_RFC'
      starting new task taskname
      destination in group default
      performing return_info on end of task
      exporting
        p_create_change_document = create_change_document
      tables
        pt_com_wlk1              = ht_com_wlk1
        it_package_info          = it_package_info
      exceptions
        resource_failure         = 3
        communication_failure    = 1 message msg_text
        system_failure           = 2 message msg_text. "#EC ENHOK
    case sy-subrc.
      when '0'.
        add 1 to taskname.
        add 1 to snd_jobs.
        exit.
      when others.
        wait until snd_jobs < jobs.
*       CALL FUNCTION 'WLK1_CHANGE_MATERIAL'
*            TABLES
*            PT_COM_WLK1         = HT_COM_WLK1.
*       exit.
    endcase.

  enddo.


endform.                    "verbuchen



*---------------------------------------------------------------------*
*       FORM update_parallel                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  pt_com_wlk1                                                   *
*  -->  S_WSOR_CTRL                                                   *
* anz_artikel Anzahl der Artikel je Task; wird innerhalb eines
* erlaubten Bereichs bestimmt
* anz_gesamt_artikel Gesamtzahl der zu verbuchenden einfachen oder
*                    srtukturierten Artikel. Zur Verbuchung eines
*                    strukturierten Artikels müssen u.U. meherere
*                    Komponenten verbucht werden.
* Um Sperrprobleme zu verhindern, müssen Pakete mit einem Sammelartikel
* auch alle seine Varianten enthalten und mit einer artnr alle
* auch alle Datensätze mit gleicher artnr und verschiedener strnr.
*---------------------------------------------------------------------*
* hbo/4.7: Neucodierung!

form update_parallel
         tables pt_com_wlk1 structure com_wlk1
         using s_wsor_ctrl structure wsor_ctrl.


  data: h_com_wlk1 like com_wlk1 occurs 0 with header line.
  data: h_artnr like wlk1-artnr,
        h_satnr like wlk1-strnr.
  data: anz_gesamt_artikel like sy-tabix,
        ges_tabix          like sy-tabix,
        anz_artikel        like sy-tabix,
        z1                 like sy-tabix.

  data: anz_min_artikel type i value 20, " je Task mind. 20 Artikel
        anz_lines       type i,
        anz_max_lines   type i value 1000. " max. Anzahl Verbuchungssätze
  "(Kombinationen Artikel/Filiale) je Task
*  DATA: package_number TYPE int4.
  data: it_package_info type package_info occurs 1 with header line.

* --- begin of insert, setting locks ---
  data: p_skopf     like wsoh-skopf,
        p_laygr     like wlmv-laygr,
        pi_wlmv     like wlmv,
        it_wsoh     like wsoh occurs 0 with header line,
        pi_com_wlk1 like com_wlk1,
        wa_com_wlk1 like com_wlk1.

  data: skopf_alt like wsoh-skopf,              "ins note 616196
        it_wlmv   like wlmv occurs 1 with header line. "ins note 616196

*begin del note 616196
*  READ TABLE pt_com_wlk1 INTO pi_com_wlk1 INDEX 1.
*  IF sy-subrc = 0.
*    p_skopf = pi_com_wlk1-ursac_w.
*  ENDIF.
*end del note 616196

* --- end of insert, setting locks ---

* Sortierkriterien für com_wlk1 nach satnr und artnr
* In Satnr steht bei allen Artikeln außer bei Varianten stets die artnr
* Bei Varianten steht dort der Sammelartikel
  call function 'LISTING_PARALLEL_PARAMETER_GET'
    importing
      ev_max_lines       = anz_max_lines
    exceptions
      parameters_not_set = 1
      others             = 2
    .
  if sy-subrc <> 0.
    anz_max_lines = 1000.
  endif.

  sort pt_com_wlk1 ascending by satnr artnr.

  clear z1.
  clear h_artnr.
  clear anz_gesamt_artikel.

  loop at pt_com_wlk1.
    if pt_com_wlk1-artnr <> h_artnr.
      add 1 to anz_gesamt_artikel.
      h_artnr = pt_com_wlk1-artnr.
    endif.
  endloop.

  anz_artikel = ( anz_gesamt_artikel div s_wsor_ctrl-max_tasks ).

* Begrenzung Artikel je Task
  if anz_artikel > s_wsor_ctrl-max_artikel.
    anz_artikel = s_wsor_ctrl-max_artikel.
  endif.
* Die minimale Anzahl der Artikel darf nicht größer sein,
* als die vom Benutzer vorgegebene maximale Anzahl der Artikel
* je Task.
  if anz_min_artikel > s_wsor_ctrl-max_artikel.
    anz_min_artikel  = s_wsor_ctrl-max_artikel.
  endif.
* Verhinderung, daß zu wenig Artikel je Task verbucht werden
  if anz_artikel <  anz_min_artikel.
    anz_artikel  =  anz_min_artikel.
  endif.

  clear h_satnr.
  clear h_artnr.
  clear z1.
  anz_lines = 0.
  it_package_info-pnumber = 1.
  append it_package_info.
  loop at pt_com_wlk1 into wa_com_wlk1.
    h_tabix = sy-tabix.
* begin change hbo 28.09.00
* falls der Artikel eine Variante ist -> lese alle Varianten und den
* Sammelartikel (falls vorhanden -> bei Lot z.B. fehlt er) in dasselbe
* Paket ein: Alle Varianten und der Sammelartikel haben im Feld satnr
* den Sammelartikel stehen.
* beachte: Arbeiten mit Arbeitsbereich, da in der return_info wieder
* über pt_com_wlk1 geloopt und dabei die Kopfzeile verändert werden
* kann!!
    if wa_com_wlk1-satnr <> h_satnr.
      if z1 >= anz_artikel or anz_lines >= anz_max_lines.
        it_package_info-anzlines = anz_lines.
        modify it_package_info index 1.
        perform verbuchen_par tables h_com_wlk1
                                     it_package_info
                              using s_wsor_ctrl.
        refresh h_com_wlk1.
        clear anz_lines.
        clear z1.
        it_package_info-pnumber = it_package_info-pnumber + 1.
        modify it_package_info index 1.
      endif.
      h_satnr = wa_com_wlk1-satnr.
    endif.
    if wa_com_wlk1-artnr <> h_artnr.
      add 1 to z1.
      h_artnr = wa_com_wlk1-artnr.
    endif.
    wa_com_wlk1-zeiger = it_package_info-pnumber.
    "hier keinesfalls Index nutzen, da dieser durch
    "return_info verändert sein kann!
    modify pt_com_wlk1 from wa_com_wlk1 index h_tabix.
    move-corresponding wa_com_wlk1 to h_com_wlk1.
    append h_com_wlk1.
    anz_lines = anz_lines + 1.
  endloop.


* hbo/4.7  IF z1 > 0.
  clear ges_tabix.
  describe table h_com_wlk1 lines ges_tabix.
  if ges_tabix > 0.
* read table h_com_wlk1 index 1 transporting no fields.
* if sy-subrc = 0. "h_com_wlk1 ist nicht leer
    if g_upd_mode = upd_mode_rop.                           " TC 414974
      it_package_info-anzlines = ges_tabix.                " Gesamtanzahl der prozessierten Artikel
      modify it_package_info index 1.                      " Gesamtanzahl der prozessierten Artikel
      perform verbuchen_par tables h_com_wlk1               " TC 414974
                                   it_package_info          " TC 414974
                            using s_wsor_ctrl.              " TC 414974
    elseif sy-batch is initial.                             " TC 414974
*      CALL FUNCTION 'WLK1_CHANGE_MATERIAL' IN UPDATE TASK
      call function 'WLK1_CHANGE_MATERIAL'  "chg 616196
        exporting
          p_create_change_document = create_change_document
        tables
          pt_com_wlk1              = h_com_wlk1.
    else.
      call function 'WLK1_CHANGE_MATERIAL'
        exporting
          p_create_change_document = create_change_document
        tables
          pt_com_wlk1              = h_com_wlk1.
    endif.
    refresh h_com_wlk1.
  endif.

* wait for the last process
  wait until snd_jobs = 0.

* --- begin of insert, setting locks ---
* dequeue layout module version and assortment module
  check g_upd_mode = upd_mode_rop.                          " TC 366691

*begin ins note 616196
  sort pt_com_wlk1 by ursac_w.
  loop at pt_com_wlk1.
    if skopf_alt <> pt_com_wlk1-ursac_w and not pt_com_wlk1-ursac_w is
      initial.
      it_wsoh-skopf = pt_com_wlk1-ursac_w.
      skopf_alt     = pt_com_wlk1-ursac_w.
      append it_wsoh to it_wsoh.
    endif.
  endloop.
  if not it_wsoh[] is initial.
    select laygr from wsoh
           into corresponding fields of table it_wlmv
             for all entries in it_wsoh
             where skopf = it_wsoh-skopf.
  endif.
  loop at it_wlmv where not laygr is initial.
*end ins note 616196

*begin del note 616196
*  IF NOT p_skopf IS INITIAL.
*    SELECT SINGLE laygr FROM wsoh
*           INTO CORRESPONDING FIELDS OF pi_wlmv
*           WHERE skopf = p_skopf.
*    IF NOT pi_wlmv-laygr IS INITIAL.                        " TC 366691
*      p_laygr = pi_wlmv-laygr.
*      SELECT * FROM wsoh INTO TABLE it_wsoh WHERE laygr = p_laygr.
*end del note 616196

*  dequeue layout module version
    call function 'DEQUEUE_EWLMV'
      exporting
        mode_wlmv    = 'E'
        mandt        = sy-mandt
*       laygr        = p_laygr "del note 616196
        laygr        = it_wlmv-laygr
*       laymod_ver   =
        x_laygr      = ' '
        x_laymod_ver = ' '
        _scope       = '3'
        _synchron    = ' '
        _collect     = ' '.
  endloop. "ins note 616196
*  dequeue assortment module
  loop at it_wsoh.
    call function 'WWS_DEQUEUE_WSOH'
      exporting
*       SPERRMODUS = 'E'
        skopf = it_wsoh-skopf.
  endloop.
*    ENDIF.                             "if sy-subrc = 0.
*  ENDIF.                               "IF NOT P_SKOPF IS INITIAL.
* --- end of insert, setting locks ---

endform.                    "update_parallel


*---------------------------------------------------------------------*
*       FORM VERBUCHEN_PAR                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  HT_COM_WLK1                                                   *
*---------------------------------------------------------------------*
form verbuchen_par tables ht_com_wlk1 structure com_wlk1
                          it_package_info structure package_info
                    using s_wsor_ctrl structure wsor_ctrl.

  data: excp_flag(1) type c.           "Anzahl der RESOURCE_FAILURE .
  data: tmp_max_tasks like wsor_ctrl-max_tasks.

* Name der Task zuweisen
  read table it_package_info index 1.
  taskname = it_package_info-pnumber.

* Initialisierung von tmp_max_tasks
  tmp_max_tasks = s_wsor_ctrl-max_tasks.

  do.
    wait until snd_jobs < tmp_max_tasks.
* Obergrenze wieder auf S_WSOR_CTRL-MAX_TASKS hochsetzen
    if tmp_max_tasks < s_wsor_ctrl-max_tasks.
      tmp_max_tasks = s_wsor_ctrl-max_tasks.
    endif.
* asynchronous mode, new task
    if s_wsor_ctrl-server_grp = c_srvergrp_default.         " TC 366691
      call function 'WLK1_CHANGE_MATERIAL_RFC'              " TC 366691
         starting new task taskname                         " TC 366691
         destination in group default                       " TC 366691
         performing return_info on end of task              " TC 366691
         exporting                                          " TC 366691
           p_create_change_document = create_change_document
         tables                                             " TC 366691
              pt_com_wlk1 = ht_com_wlk1                     " TC 366691
              it_package_info = it_package_info
         exceptions                                         " TC 366691
              resource_failure      = 3                     " TC 366691
              communication_failure = 1 message msg_text    " TC 366691
              system_failure        = 2 message msg_text.   "#EC ENHOK
                                                            " TC 366691
    else.                                                   " TC 366691
      call function 'WLK1_CHANGE_MATERIAL_RFC'
        starting new task taskname
        destination in group s_wsor_ctrl-server_grp
        performing return_info on end of task
        exporting
          p_create_change_document = create_change_document
        tables
          pt_com_wlk1              = ht_com_wlk1
          it_package_info          = it_package_info
        exceptions
          resource_failure         = 3
          communication_failure    = 1 message msg_text
          system_failure           = 2 message msg_text. "#EC ENHOK
    endif.                                                  " TC 366691
    case sy-subrc.
      when 0.
        message s745 with it_package_info-pnumber
                          it_package_info-anzlines.
        add 1 to taskname.
        add 1 to snd_jobs.
        exit.

      when 1 or 2.
        message s743 with it_package_info-pnumber
                          it_package_info-anzlines.
* asynchronous mode, update task
        if sy-batch is initial.
          "no update task! HB 614438
          call function 'WLK1_CHANGE_MATERIAL'  "chg HB 614438
            exporting
              p_create_change_document = create_change_document
            tables
              pt_com_wlk1              = ht_com_wlk1.
        else.
* synchronous mode
          call function 'WLK1_CHANGE_MATERIAL'
            exporting
              p_create_change_document = create_change_document
            tables
              pt_com_wlk1              = ht_com_wlk1.
        endif.
        exit.
      when 3.
* Ressourcenprobleme
* setze tmp_max_tasks herab auf Anzahl der aktuell laufenden RFC's
        if snd_jobs > 0.
          tmp_max_tasks = snd_jobs.
        endif.
    endcase.
  enddo.

endform.                    "verbuchen_par

*&---------------------------------------------------------------------*
*&      Form  TASK_RETURN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_COM_WLK1  text
*      -->P_=  text
*      -->P_HT_COM_WLK1  text
*      -->P_EXCEPTIONS  text
*      -->P_RESOURCE_FAILURE  text
*      -->P_=  text
*      -->P_3  text
*      -->P_COMMUNICATION_FAILURE  text
*      -->P_=  text
*      -->P_1  text
*      -->P_MESSAGE  text
*      -->P_MSG_TEXT  text
*      -->P_SYSTEM_FAILURE  text
*      -->P_=  text
*      -->P_2  text
*      -->P_MESSAGE  text
*      -->P_MSG_TEXT  text
*----------------------------------------------------------------------*
*form task_return. "tables   p_pt_com_wlk1 structure com_wlk1
*                        "  p_= structure =
*                        "  p_ht_com_wlk1 structure com_wlk1
*                        "  p_exceptions structure exceptions
*                        "  p_resource_failure structure
*resource_failure
*                        "  p_= structure =
*                        "  p_3 structure 3
*                        " p_communication_failure structure
*communicatio
*                        "  p_= structure =
*                        "  p_1 structure 1
*                        "  p_message structure message
*                        "  p_msg_text structure msg_text
*                        "  p_system_failure structure system_failure
*                        "  p_= structure =
*                        "  p_2 structure 2
*                        "  p_message structure message
*                        "  p_msg_text structure msg_text.
*
*endform.                    " TASK_RETURN


form task_return using pi_task_name.
endform.                    "task_return

*&---------------------------------------------------------------------*
*&      Form  TASKS_SERVER_GROUP_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_WSOR_CTRL  text
*----------------------------------------------------------------------*
form tasks_server_group_init using    ps_wsor_ctrl type wsor_ctrl.

  statics: init like wdl_flag-xfeld.

  data: pi_max_pbt_wps  type i,
        pi_free_pbt_wps type i,
                lv_trys type i.

* check server group and maximum tasks
  check ps_wsor_ctrl-parallel = x.
  check ps_wsor_ctrl-server_grp ne c_srvergrp_default.      " TC 366691
  check not ps_wsor_ctrl-server_grp is initial.

  do.
  call function 'SPBT_INITIALIZE'
    exporting
      group_name                     = ps_wsor_ctrl-server_grp
    importing
      max_pbt_wps                    = pi_max_pbt_wps
      free_pbt_wps                   = pi_free_pbt_wps
    exceptions
      invalid_group_name             = 1
      internal_error                 = 2
      pbt_env_already_initialized    = 3
      currently_no_resources_avail   = 4
      no_pbt_resources_found         = 5
      cant_init_different_pbt_groups = 6
      others                         = 7.


  case sy-subrc.

   when 0.
    init = x.
* Weglassen, da max_tasks sonst an die Serverauslastung zum Zeit-
* punkt der Initialisierung fest angepaßt wird.
* In der Form update_parallel wird max_tasks dauernd angepaßt wird
* an die aktuelle Serverauslastung.
*    IF ps_wsor_ctrl-max_tasks > pi_free_pbt_wps.
*      ps_wsor_ctrl-max_tasks = pi_free_pbt_wps.
*    ENDIF.
    if ps_wsor_ctrl-max_tasks is initial.
      ps_wsor_ctrl-max_tasks = pi_free_pbt_wps.
    endif.
    exit. "from do.

   when 3.
     exit. "from do.

   when 4.
         if lv_trys > 5.
      sy-msgty = 'E'.
    else.
      lv_trys = lv_trys + 1.
      sy-msgty = 'I'.
    endif.
    message id sy-msgid type sy-msgty number sy-msgno with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    wait up to 300 seconds.

   when others.
*   no message if already initialized
    if init = x.
    if sy-msgty = 'X'.
      sy-msgty = 'E'.
    endif.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    exit. "from do.
    endif.
    endcase.
  enddo.

endform.                               " TASKS_SERVER_GROUP_INIT
*&---------------------------------------------------------------------*
*&      Form  handle_empty_article
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* change    history   Author  note
*  ID        date
*  @001@    10/09/02   hbo   561631
*----------------------------------------------------------------------
* Änderung hbo 15.03.00
* Leergutartikel sollen nicht mehr als Komponenten gelistet werden
* sondern nur noch als Einzelartikel: Änderung zentral an dieser
* einen Stelle.
* Behandelung eines Leergutartikels:
* Die Listung muß immer als Einzelartikel (strnr = artnr) erfolgen.
* Nur auf das Ändern als Einzelartikel darf reagiert werden.
* Taucht dennoch eine Listung als Komponente auf, wird eine Info
* ausgegeben, daß dies nicht so sein sollte.


form handle_empty_article tables int_wlk1 structure  wlk1
                          using function like wtdy-typ01
                                so-subrc like sy-subrc.

* data definition
  data: i_mara  like mara,
        h_artnr like wlk1-artnr,
        h_subrc like sy-subrc,
        index   type i.

  data: tmp_wlk1     like wlk1 occurs 0 with header line,
        wlk1_results like wlk1 occurs 0 with header line,
        i_wlk1_del   like wlk1 occurs 0 with header line
        .


  sort int_wlk1 by artnr filia.
  clear h_artnr.
  clear h_subrc.


  loop at int_wlk1.
    if int_wlk1-artnr <> h_artnr.
      h_artnr = int_wlk1-artnr.
* Prüfen ob Artikel Leergutartikel ist
      call function 'MARA_SINGLE_READ'
        exporting
          matnr             = int_wlk1-artnr
        importing
          wmara             = i_mara
        exceptions
          lock_on_material  = 1
          lock_system_error = 2
          wrong_call        = 3
          not_found         = 4
          others            = 5.
      if sy-subrc <> 0.
        continue.
      endif.
* hier darf NICHT das Feld mlgut abgefragt werden und davon abhängig
* attyp auf c_leergut umgesetzt werden, sonst wird auch das Vollgut als
* Leergut klassifiziert.
      call function 'ASSORTMENT_CHECK_ATTYP'
        exporting
          attyp              = i_mara-attyp
          mtart              = i_mara-mtart
*         MTART              = ' '
        exceptions
          generic_article    = 1
          structured_article = 2
          variant_article    = 3
          value_article      = 4
          empty_article      = 5
          others             = 6.
      h_subrc = sy-subrc.
    endif.                             "if int_wlk1-artnr <> h_artnr.
* Nur für Leergutartikel weiter prüfen
    if h_subrc = 5.

      if function = 1 or function = 2.
* Modus Ändern oder Modus anlegen
        if int_wlk1-strnr = int_wlk1-artnr.
          "alles OK, hier soll ganz normal eine Listung
          " des Leerguts als Einzelartikel geändert werden
        else.
          " Versuch, ein Leergut als Komponente zu ändern
          " oder anzulegen
          clear tmp_wlk1.
          clear wlk1_results.
          refresh wlk1_results.
*         Überprüfe, ob es sich um einen Pfandartikel handelt,
*         der im Rahmen einer Aktion gelistet werden soll.
          if not int_wlk1-aktio is initial.           "begin note 646689
            tmp_wlk1-filia = int_wlk1-filia.
            tmp_wlk1-artnr = int_wlk1-artnr.
            tmp_wlk1-datab = int_wlk1-datab.

            call function 'WLK1_READ_MULTIPLE_FUNCTIONS'
              exporting
                wlk1_single_select = tmp_wlk1
                function           = 'H'
              tables
                wlk1_results       = wlk1_results
              exceptions
                no_rec_found       = 1
                others             = 2.                 "end note 646689

*         Pfandartikel soll nicht im Rahmen einer Aktion
*         gelistet werden.
          else.
            tmp_wlk1-filia = int_wlk1-filia.
            tmp_wlk1-artnr = int_wlk1-artnr.
            tmp_wlk1-ursac = int_wlk1-ursac.
* betrachte nur wlk1-Sätze mit gleicher Ursache
* Aufruf wlk1_read_multiple_functions mit "Z": filia, artnr,ursac
            call function 'WLK1_READ_MULTIPLE_FUNCTIONS'
              exporting
                wlk1_single_select = tmp_wlk1
                function           = 'Z'
              tables
                wlk1_results       = wlk1_results
              exceptions
                no_rec_found       = 1
                others             = 2.
          endif.
          if sy-subrc = 0.
            "Leergut ist für das Sortiment schon gelistet
* nur ein Leergut je Filiale und Artikel darf gelistet werden
            "suche Listungskondition mit kleinstem datab
* Problem: aus insert-Fall kann update-Fall werden
* Problem: was passiert, wenn int_wlk1 geändert wurde?
            clear i_wlk1_del.
            refresh i_wlk1_del.
            perform change_int_wlk1 tables wlk1_results
                                           i_wlk1_del
                                           int_wlk1
                                     using function
                                     .
          else.
            "Wenn noch kein wlk1-Satz auf der Datenbank steht, alles OK,
            "dann wird Satz angelegt werden mit strnr = artnr und
            " datbi = max_datum.
            int_wlk1-strnr = int_wlk1-artnr.
            int_wlk1-strli = ''.
            int_wlk1-datbi = max_datum.
* begin ins hbo note 561631
* unordinary solution, because no suitable field in
* int_wlk1 available. This date is checked in the include
* LWSO5F11 in the form ERMITTELN_SEGMENTE .
            if so-subrc = '4'.
              "only if call from article master data
              int_wlk1-datae = '11111111'.
            endif.
* end ins hbo note 561631
            modify int_wlk1.
          endif.                       "IF sy-subrc = 0.
        endif. "          IF int_wlk1-strnr = int_wlk1-artnr.
      else.

        "if function = 3
        if int_wlk1-strnr = int_wlk1-artnr.
          "alles OK, hier soll ganz normal eine Listung
          " des Leerguts als Einzelartikel geändert werden
        else.
** sollte überflüssig sein, da bestimmt schon früher geprüft
          " Versuch, ein Leergut als Komponente zu löschen
          clear tmp_wlk1.
          clear wlk1_results.
          refresh wlk1_results.
          tmp_wlk1-filia = int_wlk1-filia.
          tmp_wlk1-artnr = int_wlk1-artnr.
*          tmp_wlk1-strnr = int_wlk1-strnr. del note 612640
          call function 'WLK1_READ_MULTIPLE_FUNCTIONS'
            exporting
              wlk1_single_select = tmp_wlk1
              function           = 'K'
            tables
              wlk1_results       = wlk1_results
            exceptions
              no_rec_found       = 1
              others             = 2.
          if sy-subrc = 0.
            loop at wlk1_results where strnr <> int_wlk1-strnr.
              delete wlk1_results index sy-tabix.
            endloop.
            read table wlk1_results index 1 transporting no fields.
            if sy-subrc = 0.
              "alles ok
            else.
              delete int_wlk1.
            endif.
          else.
            delete int_wlk1.
          endif.
** sollte überflüssig sein
        endif. "IF int_wlk1-strnr = int_wlk1-artnr.
      endif.                           "If function = 1 or 2
    endif.                             "IF sy-subrc = 5.
  endloop.

endform.                               " handle_empty_article
*&---------------------------------------------------------------------*
*&      Form  change_int_wlk1
*&---------------------------------------------------------------------*
*  Ermittele den Satz mit kleinstem datab aus p_wlk1_results und
*  vergleiche ihn mit p_int_wlk1, die restlichen Sätze aus wlk1_results
*  sollen gelöscht werden
*----------------------------------------------------------------------*
*      -->P_WLK1_RESULTS  text
*      -->P_I_WLK1_DEL  text
*      <--P_INT_WLK1  text
*      -->P_FUNCTION  text
*----------------------------------------------------------------------*

form change_int_wlk1 tables   p_wlk1_results structure iwlk1
                              p_i_wlk1_del structure iwlk1
                              p_int_wlk1 structure iwlk1
                     using    p_function
                     .

  data: h_wlk1 like wlk1.

  clear h_wlk1.

* Suche kleinstes datab in p_wlk1_results
  loop at p_wlk1_results.
    if h_wlk1 is initial.
      h_wlk1 = p_wlk1_results.
    endif.
    if p_wlk1_results-datab < h_wlk1-datab.
      h_wlk1 = p_wlk1_results.
    endif.
  endloop.

* Falls Satz auf Datenbank kleineres datab als p_int_wlk1,
* datbi = max_datum und strnr = artnr hat, braucht nichts geändert
* zu werden, ansonsten wird in p_int_wlk1 der entsprechend
* zu ändernde Satz geschrieben

  if h_wlk1-datab <= p_int_wlk1-datab.
    if h_wlk1-datbi = max_datum
    and h_wlk1-strnr = h_wlk1-artnr.
* aktuelle Kopfzeile löschen
      delete p_int_wlk1.
    else.
* p_int_wlk1 verändern
      p_int_wlk1 = h_wlk1.
      p_int_wlk1-datbi = max_datum.
      p_int_wlk1-strnr = h_wlk1-artnr.
      p_int_wlk1-strli = ''.                           " Note 882148
      modify p_int_wlk1.
* Satz aus p_wlk1_results herauslöschen
      loop at p_wlk1_results.
        if p_wlk1_results = h_wlk1.
          delete p_wlk1_results.
          exit.
        endif.
      endloop.
    endif.
  else.
    p_int_wlk1-datbi = max_datum.
    p_int_wlk1-strnr = h_wlk1-artnr.
    p_int_wlk1-strli = ''.                             " Note 882148
    modify p_int_wlk1.
  endif.

* Korrektur: alle restlichen Sätze auf der DB mit strnr = artnr
* in zu löschende Tabelle schreiben
  loop at p_wlk1_results.
    if p_wlk1_results-strnr <> p_wlk1_results-artnr.
      p_i_wlk1_del = p_wlk1_results.
      append p_i_wlk1_del.
    endif.
  endloop.


endform.                               " change_int_wlk1
*&---------------------------------------------------------------------*
*&      Form  SET_CHANGE_DOCU
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

form set_change_docu.

  create_change_document = 'X'.

endform.                    "set_change_docu
*&---------------------------------------------------------------------*
*&      Form  DELETE_WLK1_ENTRIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DWLK1  text
*      -->P_I_ZEITRAUM_ERHALTEN  text
*      -->P_I_AUSLIST_STATUS  text
*      -->P_I_ONLY_WSEX  text
*----------------------------------------------------------------------*
form delete_wlk1_entries  using    dwlk1 structure wlk1
                                   i_zeitraum_erhalten type wtdy-typ01
                                   i_auslist_status type wtdy-typ01
                                   i_only_wsex type wtdy-typ01
                          .

  data: i_changed(1).
* GB 1041766
*  IF ( I_ZEITRAUM_ERHALTEN EQ 'X' or
*                   ( I_AUSLIST_STATUS EQ 'X' AND
*                     I_ONLY_WSEX NE 'X' ) ).
* WLK1-Eintrag erhalten
  if i_zeitraum_erhalten eq 'X' or
     i_auslist_status    eq 'X'.
* GB 1041766
    clear i_changed.
    if dwlk1-datbi >= sy-datum.
      move-corresponding dwlk1 to dwlk1_u.
      dwlk1_u-datbi = sy-datum - 1.
      dwlk1_u-datbi_old = dwlk1-datbi.
      i_changed = 'X'.
    endif.
    if dwlk1-sstat ne '5' and
       i_auslist_status eq 'X' and
*    GB 1041766
*       I_ONLY_WSEX NE 'X'.
*    Auslistungsstatus '5' in Abhängigkeit von Parameter
*    P_ONLY_WSEX des BAdI's LIST_DISCONTINUATION setzen
*    (Voraussetzung: die Parameter P_AUSLIST_STATUS und
*    P_ZEITRAUM_ERHALTEN sind ebenfalls gesetzt !)
     ( i_only_wsex is initial    or "für alle TA's
     ( i_only_wsex eq 'X'       and "oder nur für diese Auslistungs-TA's
     ( sy-tcode eq 'WSE1'        or "konzernweite Auslistung
       sy-tcode eq 'WSE2'        or "Lieferantenartikelauslistung
       sy-tcode eq 'WSE3'        or "Materialauslistung VTlinie
       sy-tcode eq 'WSE4'        or "Materialwerksauslistung
       sy-tcode eq 'WSE5'        or "Fehlerprotokoll Auslistung
       sy-tcode eq 'WSE6'        or "Materialauslistung für Sortiment
       sy-tcode eq 'WRF_DIS_SEL' or "Artikelauslistung  sais.Beschaffung
       sy-tcode eq 'WRF_DIS_MON'    "Auslistungsmonitor sais.Beschaffung
     ) ) ).
*    GB 1041766
      if i_changed = 'X'.
        dwlk1_u-sstat = '5'.
      else.
        move-corresponding dwlk1 to dwlk1_u.
        dwlk1_u-sstat = '5'.
        clear dwlk1_u-datbi_old.
        i_changed = 'X'.
      endif.
    endif.
    if i_changed = 'X'.
      dwlk1_u-datae = sy-datum.                          " Note 817904
      perform update_wlk1 using dwlk1_u.
      "ELSE.
      "do nothing!
    endif.
  else.
    perform delete_wlk1 using dwlk1.
  endif.

endform.                    " DELETE_WLK1_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  change_lfdnr
*&---------------------------------------------------------------------*
*       security check: logical key and physical key
* If logical key doesn't exist, a new lfdnr is taken.
*----------------------------------------------------------------------*
*      <--P_COM_WLK1  text
*----------------------------------------------------------------------*
form change_lfdnr  changing p_com_wlk1 structure com_wlk1
                            com1 structure com_wlk1
                            sy-subrc type sy-subrc
                            sy-tabix type sy-tabix.

  data h_lfndr type wlk1-lfdnr.

* read logical key
  read table com_wlk1 into com1 with key
           filia = p_com_wlk1-filia
           artnr = p_com_wlk1-artnr
           ursac_w = p_com_wlk1-ursac_w
           strnr = p_com_wlk1-strnr
           .
  if sy-subrc <> 0.
    p_com_wlk1-lfdnr = p_com_wlk1-lfdnr + 1.
    do.
      read table com_wlk1 into com1 with key
                   save_type = p_com_wlk1-save_type
                   filia     = p_com_wlk1-filia
                   artnr     = p_com_wlk1-artnr
                   vrkme     = p_com_wlk1-vrkme
                   datbi     = p_com_wlk1-datbi
                   lfdnr     = p_com_wlk1-lfdnr
             binary search.
      if sy-subrc <> 0.
        exit.
      else.
        p_com_wlk1-lfdnr = p_com_wlk1-lfdnr + 1.
      endif.
    enddo.
    "else.
    "entry with logical key is already in table
  endif.

endform.                    " change_lfdnr
