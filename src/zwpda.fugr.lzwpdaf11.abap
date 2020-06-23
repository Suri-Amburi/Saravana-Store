*----------------------------------------------------------------------*
*   INCLUDE LWPDAF11                                                   *
*----------------------------------------------------------------------*
* FORM-Routinen für Pointeranalyse.
************************************************************************


************************************************************************
form wrgp_pointer_analyse
          tables pit_pointer      structure bdcp
                 pit_filia_group  structure gt_filia_group
                 pet_ot1_f_wrgp   structure gt_ot1_f_wrgp
                 pet_ot2_wrgp     structure gt_ot2_wrgp.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabelle PET_OT2_WRGP (filialunabhängig).
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER     : Tabelle der zu analysierenden Änderungspointer.

* PIT_FILIA_GROUP : Tabelle für Filialkonstanten der Gruppe.

* PET_OT1_F_WRGP  : Warengruppen: Objekttabelle 1, filialabhängig.

* PET_OT2_WRGP    : Warengruppen: Objekttabelle 2, filialunabhängig.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_upd_flag  like gt_ot1_f_wrgp-upd_flag,
        h_index     like sy-tabix,
        h_tabix     like sy-tabix,
        not_found.

* Zum Komprimieren von Tabelle PET_OT1_F_WRGP.
  data: begin of i_key3,
          filia like pet_ot1_f_wrgp-filia,
          matkl like pet_ot1_f_wrgp-matkl.
  data: end of i_key3.

* Zum Komprimieren von Tabelle PET_OT1_F_WRGP.
  data: begin of i_key4.
          include structure i_key3.
  data: end of i_key4.

  data: begin of t_wrf6 occurs 2.
          include structure wrf6.
  data: end of t_wrf6.

  refresh: pet_ot2_wrgp, pet_ot1_f_wrgp.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_wbasiswg
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Warengruppenänderungen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_wbasiswg.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_wbasiswg.

      clear: pet_ot2_wrgp.

      case pit_pointer-tabname.
*       Änderungen in Tabelle T023T: Warengruppenbezeichnungen
        when 'T023T'.
*         Warengruppe wurde neu eingefügt oder Bezeichnung geändert.
          if pit_pointer-cdchgid <> c_del.
*           Falls das TABKEY-Feld gefüllt ist.
            if not pit_pointer-tabkey is initial.
              t023t = pit_pointer-tabkey.

*           Falls kein TABKEY-Feld gefüllt ist.
*           (Dies sollte eigentlich nicht vorkommen.)
            else. " pit_pointer-tabkey is initial.
              t023t-mandt = sy-mandt.
              t023t-spras = pit_filia_group-spras.
              t023t-matkl = pit_pointer-cdobjid.
            endif. " pit_pointer-cdchgid <> c_del.

*           Fülle Objekttabelle 2 (filialunabhängig).
            pet_ot2_wrgp-matkl     = t023t-matkl.
            pet_ot2_wrgp-spras     = t023t-spras.
            pet_ot2_wrgp-timestamp = pit_pointer-cretime.
            append pet_ot2_wrgp.
          endif.                         " PIT_POINTER-CDCHGID <> C_DEL.
      endcase.                           " PIT_POINTER-TABNAME.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_betrieb
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen der Zuordnungen Filiale <--> Warengruppe.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_betrieb.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_betrieb.

      clear: pet_ot1_f_wrgp.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WRF6: Zuordng. Filiale <--> Warengruppen.
        when 'WRF6'.
*         Falls eine Warengruppe einer Filiale zugeordnet wurde.
          if pit_pointer-cdchgid = c_insert.
*           Zuordnung wurde neu eingefügt.
            if pit_pointer-fldname = 'KEY'.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls eine Filiale dieser Gruppe betroffen ist.
              if sy-subrc = 0.
*               Fülle Objekttabelle 1 (filialabhängig).
                pet_ot1_f_wrgp-filia     = pit_filia_group-filia.
                pet_ot1_f_wrgp-matkl     = wrf6-matkl.
                pet_ot1_f_wrgp-timestamp = pit_pointer-cretime.
                clear: pet_ot1_f_wrgp-upd_flag.
                append pet_ot1_f_wrgp.
              endif. " sy-subrc = 0.
            endif.                     " PIT_POINTER-FLDNAME = 'KEY'.

*         Falls das WDAUS-Flag der Zuordnung Filiale <--> Warengruppe
*         verändert wurde.
          elseif pit_pointer-cdchgid = c_update.
*           WDAUS-Flag wurde verändert.
            if pit_pointer-fldname = 'WDAUS'.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist.
*             oder grundsätzlich alle Warengruppen an diese Filiale
*            versendet werden sollen, dann weiter zum nächsten Pointer.
              if sy-subrc <> 0 or pit_filia_group-sallmg <> space.
                continue.
              endif. " sy-subrc <> 0 or pit_filia_group-sallmg <> space.

*             Besorge alten WDAUS-Wert
              clear: mara.
              perform old_value_get
                      using  pit_pointer
                             mara-ean11  " --> nur wegen Kompatibilität
                             not_found.  "     des Parameters

*             Falls WDAUS-Flag vorher nicht gesetzt war.
              if mara-ean11 = space.
*               Fülle Objekttabelle 1 (filialabhängig).
                pet_ot1_f_wrgp-filia     = pit_filia_group-filia.
                pet_ot1_f_wrgp-matkl     = wrf6-matkl.
                pet_ot1_f_wrgp-timestamp = pit_pointer-cretime.
                pet_ot1_f_wrgp-upd_flag  = c_del.
                append pet_ot1_f_wrgp.

*             Falls WDAUS-Flag vorher gesetzt war.
              else. " mara-ean11 <> space.
*               Fülle Objekttabelle 1 (filialabhängig).
                pet_ot1_f_wrgp-filia     = pit_filia_group-filia.
                pet_ot1_f_wrgp-matkl     = wrf6-matkl.
                pet_ot1_f_wrgp-timestamp = pit_pointer-cretime.
                clear: pet_ot1_f_wrgp-upd_flag.
                append pet_ot1_f_wrgp.

              endif. " mara-ean11 = space.
            endif. " pit_pointer-fldname = 'WDAUS'.

*         Falls eine Zuordnung Filiale <--> Warengruppe gelöscht wurde.
          elseif pit_pointer-cdchgid = c_erase.
*           Zuordnung wurde gelöscht.
            if pit_pointer-fldname = 'WDAUS'.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls eine Filiale dieser Gruppe betroffen ist.
              if sy-subrc = 0.
*               Fülle Objekttabelle 1 (filialabhängig).
                pet_ot1_f_wrgp-filia     = pit_filia_group-filia.
                pet_ot1_f_wrgp-matkl     = wrf6-matkl.
                pet_ot1_f_wrgp-timestamp = pit_pointer-cretime.
                pet_ot1_f_wrgp-upd_flag  = c_del.
                append pet_ot1_f_wrgp.
              endif. " sy-subrc <> 0.
            endif.                     " pit_pointer-fldname = 'WDAUS'.
          endif.                       " pit_pointer-cdchgid = c_insert.

      endcase.                         " PIT_POINTER-TABNAME.
    endloop.                           " AT PIT_POINTER
  endif. " sy-subrc = 0.

* Komprimierung Stufe 1:
* Falls für eine Filiale die gleiche Warengruppe zugeordnet und
* und später wieder gelöscht wurde (oder umgekehrt), dann darf
* kein Versenden stattfinden und alle gegensätzlichen Einträge aus
* der OT1, die diese Filiale / Warengruppe betreffen müssen
* gelöscht werden.
  sort pet_ot1_f_wrgp by filia matkl timestamp.

  clear: i_key3, i_key4.
  read table pet_ot1_f_wrgp index 1.
  move-corresponding pet_ot1_f_wrgp to i_key3.
  loop at pet_ot1_f_wrgp.
    move-corresponding pet_ot1_f_wrgp to i_key4.
    if h_index = 0.
      h_upd_flag = pet_ot1_f_wrgp-upd_flag.
      h_index    = sy-tabix.
    endif. " h_index = 0.

    if i_key3 <> i_key4.
      i_key3 = i_key4.
      if h_index > 0.
        h_upd_flag = pet_ot1_f_wrgp-upd_flag.
        h_index    = sy-tabix.
      endif. " h_index > 0.
    else.
      if h_index < sy-tabix.
        if h_upd_flag <> pet_ot1_f_wrgp-upd_flag.
          delete pet_ot1_f_wrgp.
          delete pet_ot1_f_wrgp index h_index.
          clear: h_index.
        endif. " h_upd_flag <> pet_ot1_f_wrgp-upd_flag.
      endif. " h_index < sy-tabix.
    endif.                             " I_KEY3 <> I_KEY4.
  endloop.                             " AT pet_ot1_f_wrgp

************************************************************************
* Funktionsexit für kundendefinierte Änderungszeigeranalyse.
  call customer-function '012'
       tables
            pit_filia_group  = pit_filia_group
            pit_pointer      = pit_pointer
            pet_ot1_f_wrgp   = pet_ot1_f_wrgp
            pet_ot2_wrgp     = pet_ot2_wrgp.
************************************************************************

* Komprimierung Stufe 2:
* Lösche doppelte Einträge aus PET_OT1_F_WRGP.
  sort pet_ot1_f_wrgp by filia matkl timestamp descending.
  delete adjacent duplicates from pet_ot1_f_wrgp
                  comparing filia matkl.

* Lösche doppelte Einträge aus PET_OT2_WRGP.
  sort pet_ot2_wrgp by matkl spras timestamp descending.
  delete adjacent duplicates from pet_ot2_wrgp
                  comparing matkl spras.


endform.                               " WRGP_POINTER_ANALYSE


*eject
************************************************************************
form artstm_ean_pointer_analyse
     tables pit_pointer        structure bdcp
            pit_wind           structure gt_wind
            pit_filia_group    structure gt_filia_group
            pit_kondart        structure gt_kondart
            pit_kondart_gesamt structure twpek
            pet_artdel         structure gt_artdel
            pet_ot1_f_artstm   structure gt_ot1_f_artstm
            pet_ot2_artstm     structure gt_ot2_artstm
            pet_ot1_f_ean      structure gt_ot1_f_ean
            pet_ot2_ean        structure gt_ot2_ean
            pet_reorg_pointer  structure bdicpident
            pet_rfcdest        structure gt_rfcdest
     using  pi_erstdat         like syst-datum
            pi_datp3           like syst-datum
            pi_datp4           like syst-datum
            pi_pointer_reorg   like wpstruc-modus
            pi_wind            like wpstruc-cond_index
            pi_parallel        like wpstruc-parallel
            pi_server_group    like wpstruc-servergrp
            pi_taskname        like wpstruc-counter6.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabellen PET_OT1_F_ARTSTM (filialabhängig)
* und PET_OT2_ARTSTM, PET_OT2_EAN (filialunabhängig).
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER       : Tabelle der zu analysierenden Änderungspointer.

* PIT_WIND          : Tabelle der Konditionspointer, falls PI_WIND
*                     gesetzt ist.
* PIT_FILIA_GROUP   : Tabelle für Filialkonstanten der Gruppe.

* PIT_KONDART       : Tabelle mit POS-relevanten Konditionsarten.

* PIT_KONDART_GESAMT: Tabelle aler unterschiedlichen Konditionsarten
*                     aller Filialen. Wird nur bei Pointer-Reorg
*                     gefüllt.
* PET_ARTDEL        : Tabelle für zu löschende Artikel.

* PET_OT1_F_ARTSTM  : Artikelstamm: Objekttabelle 1, filialabhängig.

* PET_OT2_ARTSTM    : Artikelstamm: Objekttabelle 2, filialunabhängig.

* PET_OT1_F_EAN     : EAN-Referenzen: Objekttabelle 1, filialabhängig.

* PET_OT2_EAN       : EAN-Referenzen: Objekttabelle 2, filialunabhängig.

* PET_REORG_POINTER : Tabelle der reorganisierbaren Pointer-ID's.
*
* PET_RFCDEST           : Tabelle der abgebrochenen parallelen Tasks
*
* PI_ERSTDAT        : Datum: jetziges Versenden.

* PI_DATP3          : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4          : Datum: jetziges Versenden + Vorlaufzeit.

* PI_POINTER_REORG  : = 'X', wenn Pointer-Reorg erwünscht, sonst SPACE.

* PI_WIND           : Die Konditionsanalyse solle über
*                     Konditionsbelegindex erfolgen.
* PI_PARALLEL       : = 'X', wenn Parallelverarbeitung erwünscht,
*                            sonst SPCACE.
* PI_SERVER_GROUP   : Name der Server-Gruppe für
*                     Parallelverarbeitung.
* PI_TASKNAME       : Identifiziernder Name des aktuellen Tasks.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************


  TYPES: BEGIN OF marc_key,
          mandt TYPE mandt,
          matnr TYPE matnr,
          werks TYPE werks_d,
        END OF marc_key,

        BEGIN OF wlk2_key,
          mandt TYPE mandt,
          matnr TYPE matnr,
          vkorg TYPE w_vkorg,
          vtweg TYPE w_vtweg,
          werks TYPE w_werks,
        END OF wlk2_key,

        BEGIN OF dwlk2_key,
          vkorg TYPE w_vkorg,
          vtweg TYPE w_vtweg,
          werks TYPE w_werks,
        END OF dwlk2_key,

        BEGIN OF mvke_key,
          mandt TYPE mandt,
          matnr TYPE matnr,
          vkorg TYPE vkorg,
          vtweg TYPE vtweg,
        END OF mvke_key,

        BEGIN OF dmvke_key,
          vkorg TYPE vkorg,
          vtweg TYPE vtweg,
        END OF dmvke_key,


        BEGIN OF wlk1_key,
          mandt TYPE mandt,
          filia TYPE asort,
          artnr TYPE matnr,
          vrkme TYPE vrkme,
          datbi TYPE datbi,
          lfdnr TYPE lfdnr,
        END OF wlk1_key.

  data: i_wlk1 type wlk1_key,
        i_wlk2 type wlk2_key.


  data: h_init,
        h_datum      like sy-datum,
        h_group      like gt_filia_group-group,
        tabix        like sy-tabix,
        h_tabix      like sy-tabix,
        returncode   like sy-subrc,
        found        like wpmara-chgflag,
        not_found    like wpmara-chgflag,
        h_readindex  like sy-tabix,
        h_mtxid(2)   type n,
        h_aenderungstyp.

* Zum Komprimieren von Tabelle PET_OT1_F_ARTSTM (Stufe 1).
  data: begin of i_key5,
          filia like pet_ot1_f_artstm-filia,
          artnr like pet_ot1_f_artstm-artnr,
          vrkme like pet_ot1_f_artstm-vrkme.
  data: end of i_key5.

* Zum Komprimieren von Tabelle PET_OT1_F_ARTSTM (Stufe 1).
  data: begin of i_key6.
          include structure i_key5.
  data: end of i_key6.

* Zum Komprimieren von Tabelle PET_OT2_ARTSTM (Stufe 1).
  data: begin of i_key7,
          artnr      like pet_ot2_artstm-artnr,
          vrkme      like pet_ot2_artstm-vrkme,
          mamt_spras like pet_ot2_artstm-mamt_spras.
  data: end of i_key7.

* Zum Komprimieren von Tabelle PET_OT2_ARTSTM (Stufe 1).
  data: begin of i_key8.
          include structure i_key7.
  data: end of i_key8.

* Zum suchen von Einträgen in Konditionsartentabelle.
  data: begin of i_key9.
          include structure gt_kondart.
  data: end of i_key9.

* Zum Komprimieren von Tabelle PET_OT2_EAN (Stufe 1).
  data: begin of i_key10,
          artnr like pet_ot2_ean-artnr,
          vrkme like pet_ot2_ean-vrkme.
  data: end of i_key10.

* Zum Komprimieren von Tabelle PET_OT2_EAN (Stufe 1).
  data: begin of i_key11.
          include structure i_key10.
  data: end of i_key11.

  data: t_filia_matnr like gt_filia_matnr_buf occurs 0 with header line.


* Temporärtabelle für Filialen.
  data: begin of t_filia occurs 5,
          filia like t001w-werks.
  data: end of t_filia.

* Temporärtabelle für filialabhängige Änderungen.
  data: begin of t_ot1 occurs 0.
          include structure gt_ot1_f_artstm.
  data: end of t_ot1.

* Tabelle für alle Artikelnummern, die einer bestimmten
* Warengruppe zugeordnet sind.
  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.

* Temporärtabelle für Materialnummern.
  data: begin of t_matnr2 occurs 0.
          include structure gt_matnr.
  data: end of t_matnr2.

* Temporärtabelle für zukünftige MARM-Daten.
  data: begin of t_marm occurs 10.
          include structure marm.
  data: end of t_marm.

* Tabelle zum zwischenspeichern von Konditionsarten.
  data: begin of t_kondart occurs 10.
          include structure wpkschl.
  data: end of t_kondart.

* Tabelle für WLK2-Sätze.
  data: begin of t_wlk2 occurs 1.
          include structure wlk2.
  data: end of t_wlk2.

* Für Konditionsintervalle.
  data: begin of t_periods occurs 5.
          include structure val_period.
  data: end of t_periods.

  data: begin of t_wrf6 occurs 2.
          include structure wrf6.
  data: end of t_wrf6.

* Tabelle für alle zugehörigen MARM-Daten
  data: begin of t_marm_data  occurs 0.
          include structure gt_marm_buf.
  data: end of t_marm_data.

* Tabelle für Nutzer eines Sortiments
  data: begin of t_assortment_users occurs 0.
          include structure wrsz.
  data: end of t_assortment_users.


* Temporärtabelle mit den Daten einer Filiale.
  data: begin of t_filia_group_temp occurs 0.
          include structure gt_filia_group.
  data: end of t_filia_group_temp.

  data: max_datum like sy-datum value '99991231'.

  DATA: lt_pointer_articles TYPE pre03_tab.
  DATA: lv_last_processed_index TYPE sy-tabix.
  DATA: lv_size_pointer TYPE i.
  DATA: lt_pointer_package TYPE STANDARD TABLE OF bdcp.
  DATA: lv_package_size  TYPE pos_max_idoc_size.
*--- the WIND analysis is called in the update mode of the
*--- POS-download:
  DATA: lv_mode              TYPE wjdposmode VALUE 'U'.
  DATA: lr_mode              TYPE REF TO data.

  FIELD-SYMBOLS <ls_pointer> TYPE bdcp.

* Bestimme die Nummer der gerade  bearbeiteten Filialgruppe.
  read table pit_filia_group index 1.
  h_group = pit_filia_group-group.

  refresh: pet_ot1_f_artstm, pet_ot2_artstm, pet_ot2_ean,
           pet_ot1_f_ean.

* Vorbereitung der Konditionsanalyse parallel, falls erwünscht.
  perform artstm_condpt_analyse_prepare
          tables pit_pointer
                 pit_wind
                 pit_filia_group
                 pit_kondart
                 pit_kondart_gesamt
                 pet_ot1_f_artstm
                 pet_ot2_artstm
                 pet_reorg_pointer
                 pet_rfcdest
          using  pi_wind            " Flag, ob WIND benutzt werden soll
                 pi_erstdat
                 pi_datp3
                 pi_datp4
                 pi_pointer_reorg
                 pi_parallel
                 pi_server_group
                 pi_taskname
                 g_snd_jobs_cnd.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_mat_full
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*-- size of pit_pointer
    lv_size_pointer = lines( pit_pointer ).

*--- get the package size; set "PIV_MODE" at first because this
*--- field is needed within sub routine GET_PACKAGE_SIZE:
      TRY.
          GET REFERENCE OF lv_mode INTO lr_mode.
          cl_wrt_form_parameter=>get_instance( iv_initialize = abap_true )->add( iv_name = 'PIV_MODE'
                                                                                 i_data  = lr_mode ).
        CATCH cx_wrt_form_parameter_error  ##no_handler.
      ENDTRY.
    PERFORM get_package_size CHANGING lv_package_size.
      cl_wrt_form_parameter=>get_instance( )->refresh( ).

*--- now the packaging of the Pointer-entries starts; consider that the
*--- loop is not entered if PIT_POINTER is empty:
    WHILE lv_last_processed_index < lv_size_pointer.
      PERFORM get_pointer_pckg_for_download TABLES pit_pointer
                                                   lt_pointer_package
                                            USING  lv_size_pointer
                                                   h_tabix
                                                   lv_package_size
                                         CHANGING  lv_last_processed_index.
*--- process the next package:
*   Betrachte Materialstammänderungen.
      LOOP AT lt_pointer_package ASSIGNING <ls_pointer>.
*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
        IF <ls_pointer>-cdobjcl <> c_objcl_mat_full.
          EXIT.
        ENDIF. " <ls_pointer>-cdobjcl <> c_objcl_mat_full.

      clear: pet_ot1_f_artstm, pet_ot2_artstm, pet_ot2_ean.

        CASE <ls_pointer>-tabname.
*       Änderungen in Tabelle MARA: Materialstamm
          WHEN 'MARA'.
            mara-matnr = <ls_pointer>-cdobjid.

*         Material soll geändert oder eingefügt werden.
            IF <ls_pointer>-cdchgid = c_update OR
               <ls_pointer>-cdchgid = c_insert.

              IF <ls_pointer>-fldname <> 'EAN11'.
*             Bestimme alle Verkaufsmengeneinheiten des Artikels
*             aus Tabelle MARM, die eine EAN besitzen.
              refresh: t_matnr2.
              append mara-matnr to t_matnr2.
              perform marm_select tables t_matnr2
                                         gt_vrkme
                                  using  'X'   ' '   ' '.

*           Die Haupt-EAN zur Basismengeneinheit hat sich geändert.
              ELSEIF <ls_pointer>-fldname = 'EAN11'.
                h_datum = <ls_pointer>-acttime(8).

*             Falls das Aktivierungsdatum des Pointers Heute oder
*             älter ist, dann lese die MARA-Daten direkt von DB.
              if h_datum <= sy-datum.
*               Besorge Basismengeneinheit des Artikels.
                perform mara_select using mara
                                          mara-matnr.
*             Falls das Aktivierungsdatum des Pointers in der
*             Zukunft liegt, dann bestimme die MARA-Daten zu diesem
*             Datum.
              else. " h_datum > sy-datum.
*               Besorge Basismengeneinheit des Artikels zum
*               zukünftigen Datum.
                perform mat_by_date_get tables t_marm
                                        using  mara
                                               mara-matnr
                                               ' '        " pi_vrkme
                                               h_datum
                                               'X'        " pi_get_mara
                                               ' '        " pi_get_marm
                                               found.
              endif. " h_datum = sy-datum.

*             Falls MARA-Daten gelesen werden konnten.
              if mara-matnr <> space.
                refresh: gt_vrkme.
                clear:   gt_vrkme.
                gt_vrkme-meinh = mara-meins.
                append gt_vrkme.

*               Besorge alte Haupt-EAN, falls nötig.
                h_datum = h_datum - 1.

*               Falls die Änderung in der Vergangenheit liegt, dann
*               bestimme alte EAN aus Änderungsbeleg, falls nötig.
                if h_datum < sy-datum.
*                 Prüfe, ob alte EAN bereits gemerkt wurde.
                  clear: gt_old_ean.
                  read table gt_old_ean with key
                             artnr = mara-matnr
                             vrkme = mara-meins
                             datum = sy-datum
                             binary search.

*                 Die alte EAN wurde noch nicht zwischengespeichert.
                  if sy-subrc <> 0.
                    tabix = sy-tabix.

*                   Besorge alte Haupt-EAN aus Änderungsbeleg.
                    perform old_value_get
                                  USING <ls_pointer>
                                      gt_old_ean-ean11
                                      not_found.

*                   Falls die alte EAN ermittelt werden konnte und
*                   sie <> SPACE ist.
                    if not_found = space.
*                     Abspeichern der EAN zur späteren Analyse.
                      gt_old_ean-artnr = mara-matnr.
                      gt_old_ean-vrkme = mara-meins.
                      gt_old_ean-datum = sy-datum.

*                     Besorge alten EAN-Typ aus Änderungsbeleg.
                        gi_pointer         = <ls_pointer>.
                      gi_pointer-fldname = 'NUMTP'.

                      perform old_value_get
                                  using gi_pointer
                                        gt_old_ean-numtp
                                        not_found.

                      insert gt_old_ean index tabix.
                    endif. " not_found = space.
                  endif. " sy-subrc <> 0.
                endif. " h_datum < sy-datum.
              endif.                     " mara-matnr <> space.
              ENDIF. " <ls_pointer>-fldname <> 'EAN11'.

*           Fülle Objekttabelle 2 (filialunabhängig).
              pet_ot2_artstm-datum      = <ls_pointer>-acttime(8).
            pet_ot2_artstm-artnr      = mara-matnr.
            clear: pet_ot2_artstm-upd_flag.

*           Merken, das der Pointer aufgrund einer
*           Materialstammänderung erzeugt wurde.
            pet_ot2_artstm-aetyp_sort = c_mat_sort_index.

*           Falls das POS-System keine zeitliche Verwaltung
*           von Daten kann, muß neu Initialisiert werden.
              IF <ls_pointer>-acttime(8) < pi_datp3 AND
               pit_filia_group-zvdat = space.
              pet_ot2_artstm-init = 'X'.
*           Falls das POS-System eine zeitliche Verwaltung
*           von Daten kann.
              ELSE. " <ls_pointer>-ACTTIME(8) >= PI_DATP3.
                CLEAR: pet_ot2_artstm-init.
              ENDIF. " <ls_pointer>-ACTTIME(8) < PI_DATP3...

*           Falls das Aktivierungsdatum des Pointers in der
*           Vergangenheit liegt, dann muß immer Initialisiert
*           werden.
              IF <ls_pointer>-acttime(8) < pi_erstdat.
                pet_ot2_artstm-init  = 'X'.
                pet_ot2_artstm-datum = pi_erstdat.
              ENDIF. " <ls_pointer>-ACTTIME(8) < PI_ERSTDAT.

            loop at gt_vrkme.
              pet_ot2_artstm-vrkme = gt_vrkme-meinh.
              append pet_ot2_artstm.

*             Gilt zum Teil auch für EAN-Referenzen.
                IF <ls_pointer>-fldname = 'EAN11'.
                  MOVE-CORRESPONDING pet_ot2_artstm TO pet_ot2_ean.
                  APPEND pet_ot2_ean.
                ENDIF.                " <ls_pointer>-FLDNAME = 'EAN11'.
              ENDLOOP.                  " AT GT_VRKME.
            ENDIF.                      " <ls_pointer>-CDCHGID = C_INSERT.

*       Änderungen in Tabelle MARM: Verkaufsmengeneinheiten
        when 'DMARM'.
*         Falls Verkaufsmengeneinheit nicht gelöscht wurde.
*         (Löschen wird nicht berücksichtigt)
            IF <ls_pointer>-cdchgid <> c_erase.
              marm-matnr = <ls_pointer>-cdobjid.
              marm-meinh = <ls_pointer>-tabkey.

*           Falls die Haupt-EAN geändert wurde oder werden soll.
              IF <ls_pointer>-fldname = 'EAN11'.
*             Besorge alte Haupt-EAN, falls nötig.
                h_datum = <ls_pointer>-acttime(8).
              h_datum = h_datum - 1.

*             Falls die Änderung in der Vergangenheit liegt, dann
*             bestimme alte EAN aus Änderungsbeleg, falls nötig.
              if h_datum < sy-datum.
*               Prüfe, ob alte EAN bereits gemerkt wurde.
                clear: gt_old_ean.
                read table gt_old_ean with key
                           artnr = marm-matnr
                           vrkme = marm-meinh
                           datum = sy-datum
                           binary search.

*               Die alte EAN wurde noch nicht zwischengespeichert.
                if sy-subrc <> 0.
                  tabix = sy-tabix.

*                 Besorge alte Haupt-EAN aus Änderungsbeleg.
                  perform old_value_get
                                USING <ls_pointer>
                                    gt_old_ean-ean11
                                    not_found.

*                 Falls die alte EAN ermittelt werden konnte und
*                 sie <> SPACE ist.
                  if not_found = space.
*                   Abspeichern der EAN zur späteren Analyse.
                    gt_old_ean-artnr = marm-matnr.
                    gt_old_ean-vrkme = marm-meinh.
                    gt_old_ean-datum = sy-datum.

*                   Besorge alten EAN-Typ aus Änderungsbeleg.
                      gi_pointer         = <ls_pointer>.
                    gi_pointer-fldname = 'NUMTP'.

                    perform old_value_get
                                using gi_pointer
                                      gt_old_ean-numtp
                                      not_found.

                    insert gt_old_ean index tabix.
                  endif. " not_found = space.
                endif. " sy-subrc <> 0.
              endif. " h_datum < sy-datum.
              ENDIF. " <ls_pointer>-fldname = 'EAN11'.

*           Fülle Objekttabelle 2 (filialunabhängig).
              pet_ot2_artstm-datum    = <ls_pointer>-acttime(8).
            pet_ot2_artstm-artnr    = marm-matnr.
            pet_ot2_artstm-vrkme    = marm-meinh.
            clear: pet_ot2_artstm-upd_flag.

*           Merken, das der Pointer aufgrund einer
*           Materialstammänderung erzeugt wurde.
            pet_ot2_artstm-aetyp_sort = c_mat_sort_index.

*           Falls das POS-System keine zeitliche Verwaltung
*           von Daten kann, muß neu Initialisiert werden.
              IF <ls_pointer>-acttime(8) < pi_datp3 AND
               pit_filia_group-zvdat = space.
              pet_ot2_artstm-init = 'X'.
*           Falls das POS-System eine zeitliche Verwaltung
*           von Daten kann.
              ELSE. " <ls_pointer>-ACTTIME(8) >= PI_DATP3.
                CLEAR: pet_ot2_artstm-init.
              ENDIF. " <ls_pointer>-ACTTIME(8) < PI_DATP3...

*           Falls das Aktivierungsdatum des Pointers in der
*           Vergangenheit liegt, dann muß immer Initialisiert
*           werden.
              IF <ls_pointer>-acttime(8) < pi_erstdat.
                pet_ot2_artstm-init  = 'X'.
                pet_ot2_artstm-datum = pi_erstdat.
              ENDIF. " <ls_pointer>-ACTTIME(8) < PI_ERSTDAT.

            append pet_ot2_artstm.

*           Gilt auch für EAN-Referenzen.
            move-corresponding pet_ot2_artstm to pet_ot2_ean.
            append pet_ot2_ean.
            ENDIF.                    " <ls_pointer>-CDCHGID <> C_ERASE.

*       Änderungen in Tabelle MEAN: EAN-Referenzen.
        when 'DMEAN'.
*         Jede Änderung der EAN ist eine POS-relevante Änderung.
            mean-matnr = <ls_pointer>-cdobjid.
            mean-meinh = <ls_pointer>-tabkey(3).
            mean-ean11 = <ls_pointer>-tabkey+3.

*         Fülle Objekttabelle 2 (filialunabhängig).
            pet_ot2_ean-datum    = <ls_pointer>-acttime(8).
          pet_ot2_ean-artnr    = mean-matnr.
          pet_ot2_ean-vrkme    = mean-meinh.
          clear: pet_ot2_ean-upd_flag.

*         Falls das POS-System keine zeitliche Verwaltung
*         von Daten kann, muß neu Initialisiert werden.
            IF <ls_pointer>-acttime(8) < pi_datp3 AND
             pit_filia_group-zvdat = space.
            pet_ot2_ean-init = 'X'.
*         Falls das POS-System eine zeitliche Verwaltung
*         von Daten kann.
            ELSE. " <ls_pointer>-ACTTIME(8) >= PI_DATP3.
              CLEAR: pet_ot2_ean-init.
            ENDIF. " <ls_pointer>-ACTTIME(8) < PI_DATP3...

*         Falls das Aktivierungsdatum des Pointers in der
*         Vergangenheit liegt, dann muß immer Initialisiert werden.
            IF <ls_pointer>-acttime(8) < pi_erstdat.
              pet_ot2_ean-init  = 'X'.
              pet_ot2_ean-datum = pi_erstdat.
            ENDIF. " <ls_pointer>-ACTTIME(8) < PI_ERSTDAT.

          append pet_ot2_ean.

*         Merken, ob zusätzliche EAN's zu dieser VRKME eingefügt
*         oder gelöscht wurden (nur für schon aktive Änderungen).
            h_datum = <ls_pointer>-acttime(8).
          if h_datum <= sy-datum.
*           prüfe, ob schon ein ein Satz für diese VRKME gespeichert
*           wurde.
            clear: gt_ean_change.
            read table gt_ean_change with key
                 artnr = mean-matnr
                 vrkme = mean-meinh
                 binary search.

            tabix = sy-tabix.

*           Falls bereits ein Satz existiert, dann muß er aktualisiert
*           werden.
            if sy-subrc = 0.
*             Falls eine zusätzliche EAN gelöscht wurden
                IF <ls_pointer>-cdchgid = c_erase.
                gt_ean_change-change = gt_ean_change-change - 1.
                modify gt_ean_change index tabix.
*             Falls eine zusätzliche EAN eingefügt wurden
                ELSEIF <ls_pointer>-cdchgid = c_insert.
                  gt_ean_change-change = gt_ean_change-change + 1.
                  MODIFY gt_ean_change INDEX tabix.
                ENDIF. " <ls_pointer>-cdchgid = c_erase.

*           Falls noch kein Satz existiert, dann muß er erzeugt werden.
            else. " sy-subrc <> 0.
              gt_ean_change-artnr = mean-matnr.
              gt_ean_change-vrkme = mean-meinh.

*             Falls eine zusätzliche EAN gelöscht wurden
                IF <ls_pointer>-cdchgid = c_erase.
                  gt_ean_change-change = gt_ean_change-change - 1.
*             Falls eine zusätzliche EAN eingefügt wurden
                ELSEIF <ls_pointer>-cdchgid = c_insert.
                  gt_ean_change-change = gt_ean_change-change + 1.
                ENDIF. " <ls_pointer>-cdchgid = c_erase.

              insert gt_ean_change index tabix.
            endif. " sy-subrc = 0.
          endif. " h_datum <= sy-datum.

*         Falls Sonderlöschsätze beim Löschen einer zusätzlichen EAN
*         erzeugt werden sollen.
          if not pit_filia_group-ean_del is initial.
*           Falls eine zusätzliche EAN gelöscht wurde.
              IF <ls_pointer>-cdchgid = c_erase.
*             Falls die alte EAN ermittelt werden konnte und
*             sie <> SPACE ist.
              if mean-ean11 <> space.
*               Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                read table gt_zus_ean_del with key
                     artnr = mean-matnr
                     vrkme = mean-meinh
                     datum = h_datum
                     ean   = mean-ean11
                     binary search.

                if sy-subrc <> 0.
                  tabix = sy-tabix.

*                 Abspeichern der EAN zur späteren Analyse.
                  gt_zus_ean_del-artnr = mean-matnr.
                  gt_zus_ean_del-vrkme = mean-meinh.
                  gt_zus_ean_del-datum = h_datum.
                  gt_zus_ean_del-ean   = mean-ean11.
                  insert gt_zus_ean_del index tabix.
                endif. " sy-subrc <> 0.

*               Erzeuge Löschmerker in Objekttabelle2
*               (filialunabhängig).
                clear: pet_ot2_ean.
                pet_ot2_ean-artnr    = mean-matnr.
                pet_ot2_ean-vrkme    = mean-meinh.
                pet_ot2_ean-datum    = h_datum.
*               Kein 'C_DEL' als Trigger dafür, das es sich um eine
*               zusätliche EAN handelt, damit man sie von den normalen
*               Löschsätzen unterscheiden kann.
                pet_ot2_ean-upd_flag = c_erase.
                append pet_ot2_ean.

*               Prüfe, ob alte EAN bereits gemerkt wurde.
                clear: gt_old_ean.
                read table gt_old_ean with key
                           artnr = mean-matnr
                           vrkme = mean-meinh
                           datum = h_datum
                           ean11 = mean-ean11
                           binary search.

*               Die alte EAN wurde noch nicht zwischengespeichert.
                if sy-subrc <> 0.
                  tabix = sy-tabix.

*                 Abspeichern der EAN zur späteren Analyse.
                  gt_old_ean-artnr = mean-matnr.
                  gt_old_ean-vrkme = mean-meinh.
                  gt_old_ean-datum = h_datum.
                  gt_old_ean-ean11 = mean-ean11.

*                 Besorge alten EAN-Typ aus Änderungsbeleg.
                    gi_pointer         = <ls_pointer>.
                  gi_pointer-fldname = 'EANTP'.

                  perform old_value_get
                              using gi_pointer
                                    gt_old_ean-numtp
                                    not_found.

                  insert gt_old_ean index tabix.
                endif. " sy-subrc <> 0.
              endif. " mean-ean11 <> space.
              ENDIF. " <ls_pointer>-cdchgid = c_erase.
          endif. " not pit_filia_group-ean_del is initial.

*       Änderungen in Tabelle MAKT: Texte zum Artikel
        when 'DMAKT'.
*         Falls Texte nicht gelöscht wurden.
*         (Löschen wird nicht berücksichtigt)
            IF <ls_pointer>-cdchgid <> c_erase.
              makt-matnr = <ls_pointer>-cdobjid.
              makt-spras = <ls_pointer>-tabkey.

*           Bestimme alle Verkaufsmengeneinheiten des Artikels
*           aus Tabelle MARM, die eine EAN besitzen.
            refresh: t_matnr.
            append makt-matnr to t_matnr.
            perform marm_select tables t_matnr
                                       gt_vrkme
                                using  'X'   ' '   ' '.

*           Fülle Objekttabelle 2 (filialunabhängig).
              pet_ot2_artstm-datum      = <ls_pointer>-acttime(8).
            pet_ot2_artstm-artnr      = makt-matnr.
            pet_ot2_artstm-mamt_spras = makt-spras.
            clear: pet_ot2_artstm-upd_flag.

*           Merken, das der Pointer aufgrund einer
*           Materialstammänderung erzeugt wurde.
            pet_ot2_artstm-aetyp_sort = c_mat_sort_index.

*           Falls das POS-System keine zeitliche Verwaltung
*           von Daten kann, muß neu Initialisiert werden.
              IF <ls_pointer>-acttime(8) < pi_datp3 AND
               pit_filia_group-zvdat = space.
              pet_ot2_artstm-init = 'X'.
*           Falls das POS-System eine zeitliche Verwaltung
*           von Daten kann.
              ELSE. " <ls_pointer>-ACTTIME(8) >= PI_DATP3.
                CLEAR: pet_ot2_artstm-init.
              ENDIF.                 " <ls_pointer>-ACTTIME(8) < PI_DATP3.

*           Falls das Aktivierungsdatum des Pointers in der
*           Vergangenheit liegt, dann muß immer Initialisiert werden.
              IF <ls_pointer>-acttime(8) < pi_erstdat.
                pet_ot2_artstm-init  = 'X'.
                pet_ot2_artstm-datum = pi_erstdat.
              ENDIF. " <ls_pointer>-ACTTIME(8) < PI_ERSTDAT.

*           PET_OT2_ARTSTM-UPD_FLAG = <ls_pointer>-CDCHGID.
            loop at gt_vrkme.
              pet_ot2_artstm-vrkme = gt_vrkme-meinh.
              append pet_ot2_artstm.
            endloop.                     " AT GT_VRKME.
            ENDIF.                     " <ls_pointer>-CDCHGID <> C_ERASE.

*       Änderungen in Tabelle MAMT: Texte zum Artikel
        when 'DMAMT'.
*         Falls Texte nicht gelöscht wurden.
            mamt-matnr = <ls_pointer>-cdobjid.
            mamt+21    = <ls_pointer>-tabkey.
          h_mtxid    = mamt-mtxid.

*         Falls die Kurztext-ID POS-relevant ist.
          if h_mtxid < 10 or h_mtxid > 49.
*           Fülle objekttabelle 2 (filialunabhängig).
              pet_ot2_artstm-datum      = <ls_pointer>-acttime(8).
            pet_ot2_artstm-artnr      = mamt-matnr.
            pet_ot2_artstm-vrkme      = mamt-meinh.
            pet_ot2_artstm-mamt_spras = mamt-spras.
            clear: pet_ot2_artstm-upd_flag.

*           Merken, das der Pointer aufgrund einer
*           Materialstammänderung erzeugt wurde.
            pet_ot2_artstm-aetyp_sort = c_mat_sort_index.

*           Falls das POS-System keine zeitliche Verwaltung
*           von Daten kann, muß neu Initialisiert werden.
              IF <ls_pointer>-acttime(8) < pi_datp3 AND
               pit_filia_group-zvdat = space.
              pet_ot2_artstm-init = 'X'.
*           Falls das POS-System eine zeitliche Verwaltung
*           von Daten kann.
              ELSE. " <ls_pointer>-ACTTIME(8) >= PI_DATP3.
                CLEAR: pet_ot2_artstm-init.
              ENDIF.               " <ls_pointer>-ACTTIME(8) < PI_DATP3.

*           Falls das Aktivierungsdatum des Pointers in der
*           Vergangenheit liegt, dann muß immer Initialisiert werden.
              IF <ls_pointer>-acttime(8) < pi_erstdat.
                pet_ot2_artstm-init  = 'X'.
                pet_ot2_artstm-datum = pi_erstdat.
              ENDIF. " <ls_pointer>-ACTTIME(8) < PI_ERSTDAT.

            append pet_ot2_artstm.
          endif. " h_mtxid < 10 or h_mtxid > 49.
        ENDCASE.                           " <ls_pointer>-TABNAME
      ENDLOOP.                             " AT <ls_pointer>
    ENDWHILE.

*--- set flag, that mara buffer is filled:
      g_mara_buf_filled = 'X'.

  ENDIF. " sy-subrc = 0.

*Sort pit_pointer before BINARY SEARCH          "Note 2656653
  SORT pit_pointer BY cdobjcl tabname ASCENDING.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_mat_full
       tabname = 'DWLK2'
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte WLK2-Änderungen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-tabname <> 'DWLK2'.
        exit.
      endif. " pit_pointer-tabname <> 'DWLK2'.

      clear: pet_ot1_f_artstm, pet_ot2_artstm, wlk2, dwlk2.

*     Fülle den Schlüssel für WLK2.
      dwlk2 = pit_pointer-tabkey(10).
      move-corresponding dwlk2 to wlk2.
      wlk2-matnr = pit_pointer-cdobjid.
      wlk2-mandt = sy-mandt.

*     Falls die falsche Vertriebslinie betroffen ist.
      if pit_filia_group-vkorg <> wlk2-vkorg  or
         pit_filia_group-vtweg <> wlk2-vtweg.
*       Gehe weiter zum nächsten Satz.
        continue.
      endif. " pit_filia_group-vkorg <> wlk2-vkorg  or ...

*     Falls das Bewirtschaftungsende nicht verändert wurde.
      if pit_pointer-fldname <> 'VKBIS'.
*       Analyse des WLK2-Pointers für Artikelstammsätze.
        perform wlk2_pointer_analyse
                     tables pet_ot1_f_artstm
                            pet_ot2_artstm
                            pit_filia_group
                     using  pit_pointer
                            pi_erstdat
                            h_group.
      endif. " pit_pointer-fldname <> 'VKBIS'.

*     Falls das Bewirtschaftungsende verändert wurde.
      if pit_pointer-fldname = 'VKBIS' or
         pit_pointer-fldname = 'KEY'.
*       Falls Filiale bekannt.
        if not wlk2-werks is initial.
*         Prüfe, ob diese Filiale in der gerade
*         bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*         dürfen berücksichtigt werden.
          read table pit_filia_group with key
               group = h_group
               filia = wlk2-werks
               binary search.

*         Falls diese Filiale nicht in der gerade betrachteten
*         Filialgruppe enthalten ist, dann weiter zum
*         nächsten Satz.
          if sy-subrc <> 0.
            continue.
          endif.      " SY-SUBRC <> 0.
        endif. " not wlk2-werks is initial.

*       Gelöschte WLK2-Daten werden nicht berücksichtigt.
        if pit_pointer-cdchgid <> c_del.
*         Lese betroffenen WLK2-Satz.
          refresh: t_wlk2.
          call function 'WLK2_READ'
            EXPORTING
              wlk2             = wlk2
            TABLES
              wlk2_input       = t_wlk2
            EXCEPTIONS
              no_rec_found     = 01
              key_not_complete = 02.

          read table t_wlk2 index 1.

*         Falls das Bewirtschaftungsende nicht im Bereich
*         bis PI_DATP3 liegt, dann weiter zum nächsten Satz.
          if t_wlk2-vkbis >= pi_datp3.
            continue.
          endif. " t_wlk2-vkbis >= pi_datp3.
*         Bestimme alle Verkaufsmengeneinheiten des Artikels
*         aus Tabelle MARM, die eine EAN besitzen.
          refresh: t_matnr.
          append t_wlk2-matnr to t_matnr.
          perform marm_select tables t_matnr
                                     gt_vrkme
                              using  'X'   ' '   ' '.

*         Prüfe, ob VRKME's gefunden wurden.
          read table gt_vrkme index 1.

*         Falls keine VRKME's gefunden wurden.
          if sy-subrc <> 0.
*           Weiter zum nächsten Objekt.
            continue.
          endif. " sy-subrc <> 0.

*         Schleife über alle gefundenenen Verkaufsmengeneinheiten.
          loop at gt_vrkme.
*           Prüfe, ob EAN bereits gemerkt wurde.
            h_datum = t_wlk2-vkbis + 1.

            if h_datum < pi_erstdat.
              h_datum = pi_erstdat.
            endif. " h_datum < pi_erstdat.

            read table pet_artdel with key
                 artnr = gt_vrkme-matnr
                 vrkme = gt_vrkme-meinh
                 datum = h_datum
                 binary search.

            tabix = sy-tabix.

*           Falls die zugehörige EAN noch nicht gemerkt wurde, dann
*           besorge EAN.
            if sy-subrc <> 0.
*             Besorge die Haupt-EAN vom Vortag des Löschens.
              perform ean_by_date_get
                      using gt_vrkme-matnr  gt_vrkme-meinh
                            t_wlk2-vkbis    g_loesch_ean
                            g_returncode.

*             Falls eine EAN gefunden wurde, dann erzeuge
*             Lösch-Eintrag.
              if g_returncode = 0 and g_loesch_ean <> space.
                pet_artdel-artnr = gt_vrkme-matnr.
                pet_artdel-vrkme = gt_vrkme-meinh.
                pet_artdel-ean   = g_loesch_ean.
                pet_artdel-datum = h_datum.
                insert pet_artdel index tabix.

*             Falls keine EAN gefunden wurde, dann weiter
*             zum nächsten Satz.
              else. " g_returncode <> 0 or g_loesch_ean = space.
                continue.
              endif. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
            endif. " sy-subrc <> 0.

*           Falls der T_WLK2-Satz Gültigkeit auf Konzern- oder
*           auf Vertriebslinienebene (dieser Vertriebslinie) hat.
            if  t_wlk2-vkorg = space  or
              ( t_wlk2-werks = space                  and
                t_wlk2-vkorg = pit_filia_group-vkorg  and
                t_wlk2-vtweg = pit_filia_group-vtweg ).

*             Fülle Objekttabelle 2 (filialunabhängig).
              clear: pet_ot2_artstm.
              pet_ot2_artstm-artnr    = gt_vrkme-matnr.
              pet_ot2_artstm-vrkme    = gt_vrkme-meinh.
              pet_ot2_artstm-datum    = h_datum.
              pet_ot2_artstm-wlk2     = c_vertriebslinie.
              pet_ot2_artstm-upd_flag = c_del.
              append pet_ot2_artstm.

*             Gilt auch für EAN-Referenzen.
              move-corresponding pet_ot2_artstm to pet_ot2_ean.
              append pet_ot2_ean.

*           Falls Filiale bekannt und dieser Vertriebslinie
*           zugehörig.
            elseif t_wlk2-werks <> space                 and
                   t_wlk2-vkorg = pit_filia_group-vkorg  and
                   t_wlk2-vtweg = pit_filia_group-vtweg.

*             Fülle Objekttabelle 1 (filialabhängig).
              clear: pet_ot1_f_artstm.
              pet_ot1_f_artstm-filia    = t_wlk2-werks.
              pet_ot1_f_artstm-artnr    = gt_vrkme-matnr.
              pet_ot1_f_artstm-vrkme    = gt_vrkme-meinh.
              pet_ot1_f_artstm-datum    = h_datum.
              pet_ot1_f_artstm-upd_flag = c_del.
              append pet_ot1_f_artstm.

*             Gilt auch für EAN-Referenzen.
              move-corresponding pet_ot1_f_artstm to pet_ot1_f_ean.
              append pet_ot1_f_ean.
            endif.                       " T_WLK2-VKORG = SPACE OR ...
          endloop. " at gt_vrkme
        endif. " pit_pointer-cdchgid <> c_del.
      endif. " pit_pointer-fldname = 'VKBIS' or ...
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.


* Änderungen bezüglich  n:m Zuordnung (WRSZ-Pointer)
  perform wrsz_pointer_analyse
          tables t_filia_matnr
                 pit_pointer
                 pit_filia_group
          using  pi_erstdat.

* Auflösen der Rohdaten.
  clear: pet_ot1_f_artstm, pet_ot1_f_ean.

  clear: i_key10, i_key11.
  loop at t_filia_matnr.
    move t_filia_matnr-matnr to i_key11-artnr.

    if i_key10 <> i_key11.
      i_key10 = i_key11.

*     Bestimme alle Verkaufsmengeneinheiten des Artikels
*     aus Tabelle MARM, die eine EAN besitzen.
      refresh: t_matnr.
      t_matnr-matnr = t_filia_matnr-matnr.
      append t_matnr.

      perform marm_select tables t_matnr
                                 gt_vrkme
                          using  'X'   ' '   ' '.
    endif. " i_key10 <> i_key11.

    loop at gt_vrkme.
*     Besorge die WERKS-Nummer.
      if pit_filia_group-kunnr <> t_filia_matnr-locnr.
        read table pit_filia_group with key
             kunnr = t_filia_matnr-locnr
             binary search.
      endif. " pit_filia_group-kunnr <> t_filia_matnr-locnr.

      pet_ot1_f_artstm-filia = pit_filia_group-filia.
      pet_ot1_f_artstm-artnr = gt_vrkme-matnr.
      pet_ot1_f_artstm-vrkme = gt_vrkme-meinh.
      pet_ot1_f_artstm-init  = 'X'.
      pet_ot1_f_artstm-datum = pi_erstdat.
      append pet_ot1_f_artstm.

*     Gilt auch für EAN-Referenzen.
      append pet_ot1_f_artstm to pet_ot1_f_ean.
    endloop. " at gt_vrkme.
  endloop. " at t_filia_matnr.

* B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
     AND gs_twpa-marc_chk IS NOT INITIAL.
                  PERFORM marc_pointer_analyse
                           TABLES pet_ot1_f_artstm
                                  pet_ot1_f_ean
                                  pet_artdel
                                  pit_filia_group
                                  pit_pointer
                           USING  pi_erstdat.
*     Resortieren der Filialgruppentabelle.
        SORT pit_filia_group BY group filia.
  ELSE.
* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_wlk1
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
*   Umsortieren der Filialgruppentabelle.
      SORT pit_filia_group BY group kunnr.

      h_tabix = sy-tabix.

*   Umsortieren der Filialgruppentabelle.
    sort pit_filia_group by group kunnr.

*   Betrachte Neulistungen von Artikeln.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_wlk1.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_wlk1.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WLK1: Listungskonditionen,
*       Materialstamm.
        when 'WLK1'.
*         Nur Neulistungen müssen überprüft werden.
          if pit_pointer-cdchgid = c_insert  or
             pit_pointer-fldname = 'SSTAT'.
            refresh: t_ot1.
            clear: pet_ot1_f_artstm,  pet_ot1_f_ean, t_ot1, i_wlk1.

*           Fülle den Schlüssel für WLK1.
            i_wlk1 = pit_pointer-tabkey.

*           Besorge die Filialen welche dieses Sortiment nutzen.
            refresh: t_assortment_users.
            call function 'ASSORTMENT_GET_USERS_OF_1ASORT'
              EXPORTING
                asort              = i_wlk1-filia
                valid_per_date     = sy-datum
                date_to            = max_datum
              TABLES
                assortment_users   = t_assortment_users
              EXCEPTIONS
                no_asort_to_select = 1
                no_user_found      = 2
                others             = 3.

            if sy-subrc <> 0.
              continue.
            endif.

*           Prüfe, welche Filialen in der gerade
*           bearbeiteten Filialgruppe vorkommen.
            refresh: t_filia_group_temp.
            loop at t_assortment_users.
*             Prüfe, ob diese Filiale in der gerade
*             bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*             dürfen berücksichtigt werden.
              read table pit_filia_group with key
                   group = h_group
                   kunnr = t_assortment_users-locnr
                   binary search.

*             Diese Filiale muß  berücksichtigt werden.
              if sy-subrc = 0.
                append pit_filia_group to t_filia_group_temp.
              endif. " sy-subrc = 0.
            endloop. " at t_assortment_users.

*           Prüfe, ob noch eine Filiale aus dieser Gruppe übrig
*           geblieben ist.
            read table t_filia_group_temp index 1.

*           Falls keine Filiale aus dieser Gruppe übrig geblieben ist,
*           keine weitere Aufbereitung nötig.
            if sy-subrc <> 0.
              continue.
            endif. " sy-subrc <> 0.

*           Analyse des WLK1-Pointers.
            perform wlk1_pointer_analyse
                         tables t_ot1
                                pet_artdel
                                t_filia_group_temp
                         using  pit_pointer
                                pi_erstdat.

*           Übernahme der Daten in Ausgabetabellen.
            append lines of t_ot1 to pet_ot1_f_artstm.
            append lines of t_ot1 to pet_ot1_f_ean.
          endif. " pit_pointer-cdchgid = c_insert.
      endcase.                           " PIT_POINTER-TABNAME
    endloop.                             " AT PIT_POINTER

    if sy-subrc = 0.
*     Resortieren der Filialgruppentabelle.
      sort pit_filia_group by group filia.
    endif. " sy-subrc = 0.
  endif. " sy-subrc = 0.

  ENDIF. " E: new listing check logic => Note 1982796
* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_betrieb
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen in den Zuordnungen Filiale <--> Warengruppe.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_betrieb.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_betrieb.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WRF6: Zuordng. Filiale <-->
*       Warengruppen.
        when 'WRF6'.
*         Falls eine Warengruppe einer Filiale zugeordnet wurde.
          if pit_pointer-cdchgid = c_insert.
*           Zuordnung wurde neu eingefügt.
            if pit_pointer-fldname = 'KEY'.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = wrf6-locnr
                  pi_warengruppe = wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist aber
*             von der Versendung ausgeschlossen werden soll, dann
*             müssen zu allen Artikelnummern die dieser Warengruppe
*             zugeordnet sind Löschsätze erzeugt werden.
              if sy-subrc = 0 and t_wrf6-wdaus <> space.
*               Besorge zunächst alle Artikelnummern, die dieser
*               Warengruppe zugeordnet sind.
                perform mara_by_matkl_select tables t_matnr
                                             using  t_wrf6-matkl.

*               Besorge die zugehörigen Verkaufsmengeneinheiten
*               und Haupt-EAN's.
                perform marm_select tables t_matnr
                                           t_marm_data
                                    using  'X'   ' '   ' '.

                loop at t_marm_data.
*                 Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                  read table pet_artdel with key
                       artnr = t_marm_data-matnr
                       vrkme = t_marm_data-meinh
                       datum = pi_erstdat
                       binary search.

*                 Falls noch kein Löschmerker erzeugt wurde.
                  if sy-subrc <> 0.
                    tabix = sy-tabix.

*                   Prüfe, ob EAN bereits gemerkt wurde.
                    clear: gt_old_ean.
                    read table gt_old_ean with key
                               artnr = t_marm_data-matnr
                               vrkme = t_marm_data-meinh
                               datum = pi_erstdat
                               binary search.

*                   Falls die EAN noch nicht zwischengespeichert wurde,
*                   dann nehme die aktuelle EAN aus DB.
                    if sy-subrc <> 0.
                      pet_artdel-ean = t_marm_data-ean11.

*                   Falls die EAN schon zwischengespeichert wurde
*                   d.h. eine EAN-Änderung vor Einfügen der Zuordnung
*                   Filial <--> Warengruppe stattgefunden hat, dann
*                   übernehme die alte EAN.
                    else. " sy-subrc = 0.
                      pet_artdel-ean = gt_old_ean-ean11.
                    endif. " sy-subrc <> 0.

*                   Abspeichern des Schlüssels zum Aufbau des
*                   Löschsatzes.
                    pet_artdel-artnr = t_marm_data-matnr.
                    pet_artdel-vrkme = t_marm_data-meinh.
                    pet_artdel-datum = pi_erstdat.
                    insert pet_artdel index tabix.
                  endif. " sy-subrc <> 0.            PET_ARTDEL

*                 Fülle Objekttabelle 1 (filialabhängig).
                  clear: pet_ot1_f_artstm.
                  pet_ot1_f_artstm-filia    = pit_filia_group-filia.
                  pet_ot1_f_artstm-artnr    = t_marm_data-matnr.
                  pet_ot1_f_artstm-vrkme    = t_marm_data-meinh.
                  pet_ot1_f_artstm-datum    = pi_erstdat.
                  pet_ot1_f_artstm-upd_flag = c_del.
                  append pet_ot1_f_artstm.

*                 Gilt auch für EAN-Referenzen.
                  move-corresponding pet_ot1_f_artstm to pet_ot1_f_ean.
                  append pet_ot1_f_ean.
                endloop. " at t_marm_data.
              endif. " sy-subrc = 0 and t_wrf6-wdaus <> space.
            endif.                       " PIT_POINTER-FLDNAME = 'KEY'.

*         Falls das WDAUS-Flag der Zuordnung Filiale <--> Warengruppe
*         verändert wurde.
          elseif pit_pointer-cdchgid = c_update.
*           WDAUS-Flag wurde verändert.
            if pit_pointer-fldname = 'WDAUS'.

              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = wrf6-locnr
                  pi_warengruppe = wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist.
              if sy-subrc = 0.
*               Besorge zunächst alle Artikelnummern, die dieser
*               Warengruppe zugeordnet sind.
                perform mara_by_matkl_select tables t_matnr
                                             using  t_wrf6-matkl.

*               Besorge die zugehörigen Verkaufsmengeneinheiten
*               und Haupt-EAN's.
                perform marm_select tables t_matnr
                                           t_marm_data
                                    using  'X'   ' '   ' '.

                loop at t_marm_data.

                  clear: pet_ot1_f_artstm.

*                 Falls die Warengruppe dieser Filiale zugeordnet ist
*                 aber von der Versendung ausgeschlossen werden soll,
*                 dann müssen zu allen Artikelnummern die dieser
*                 Warengruppe zugeordnet sind Löschsätze erzeugt
*                 werden.
                  if t_wrf6-wdaus <> space.
*                   Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                    read table pet_artdel with key
                         artnr = t_marm_data-matnr
                         vrkme = t_marm_data-meinh
                         datum = pi_erstdat
                         binary search.

*                   Falls noch kein Löschmerker erzeugt wurde.
                    if sy-subrc <> 0.
                      tabix = sy-tabix.

*                     Prüfe, ob EAN bereits gemerkt wurde.
                      clear: gt_old_ean.
                      read table gt_old_ean with key
                                 artnr = t_marm_data-matnr
                                 vrkme = t_marm_data-meinh
                                 datum = pi_erstdat
                                 binary search.

*                     Falls die EAN noch nicht zwischengespeichert
*                     wurde, dann nehme die aktuelle EAN aus DB.
                      if sy-subrc <> 0.
                        pet_artdel-ean = t_marm_data-ean11.

*                     Falls die EAN schon zwischengespeichert wurde
*                     d.h. eine EAN-Änderung vor Einfügen der Zuordnung
*                     Filial <--> Warengruppe stattgefunden hat, dann
*                     übernehme die alte EAN.
                      else. " sy-subrc = 0.
                        pet_artdel-ean = gt_old_ean-ean11.
                      endif. " sy-subrc <> 0.

*                     Abspeichern des Schlüssels zum Aufbau des
*                     Löschsatzes.
                      pet_artdel-artnr = t_marm_data-matnr.
                      pet_artdel-vrkme = t_marm_data-meinh.
                      pet_artdel-datum = pi_erstdat.
                      insert pet_artdel index tabix.
                    endif. "  sy-subrc <> 0.               PET_ARTDEL

*                   Setze Löschmerker zum späteren Löschen.
                    pet_ot1_f_artstm-upd_flag = c_del.

*                 Falls die Warengruppe dieser Filiale zugeordnet ist
*                 und nicht mehr von der Versendung ausgeschlossen
*                 wird, dann müssen alle Artikel die dieser
*                 Warengruppe zugeordnet sind neu initialisiert werden.
                  else. " t_wrf6-wdaus = space.
*                   Setze Initialisierungsmerker zum späteren
*                   Initialisieren.
                    pet_ot1_f_artstm-init = 'X'.

*                   Merken, das der Pointer aufgrund einer
*                   Materialinitialisierung erzeugt wurde.
                    pet_ot1_f_artstm-aetyp_sort = c_init_sort_index.

                  endif. " t_wrf6-wdaus <> space.

*                 Fülle die restlichen Felder in Objekttabelle 1
*                 (filialabhängig).
                  pet_ot1_f_artstm-filia = pit_filia_group-filia.
                  pet_ot1_f_artstm-artnr = t_marm_data-matnr.
                  pet_ot1_f_artstm-vrkme = t_marm_data-meinh.
                  pet_ot1_f_artstm-datum = pi_erstdat.
                  append pet_ot1_f_artstm.

*                 Gilt auch für EAN-Referenzen.
                  move-corresponding pet_ot1_f_artstm to pet_ot1_f_ean.
                  append pet_ot1_f_ean.
                endloop. " at t_marm_data.
              endif. " sy-subrc = 0.

*           Falls sich die Betriebspreisliste verändert hat.
            elseif pit_pointer-fldname = 'PLTYP_P'.
*             Übernehme den Schlüssel in Tabellenstruktur WRF6.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = wrf6-locnr
                  pi_warengruppe = wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist.
              if sy-subrc = 0.
*               Falls die Warengruppe an diese Filiale versendet wird.
                if t_wrf6-wdaus = space.
*                 Besorge zunächst alle Artikelnummern, die dieser
*                 Warengruppe zugeordnet sind.
                  perform mara_by_matkl_select tables t_matnr
                                               using  t_wrf6-matkl.

*                 Besorge die zugehörigen Verkaufsmengeneinheiten
*                 und Haupt-EAN's.
                  perform marm_select tables t_matnr
                                             t_marm_data
                                      using  'X'   ' '   ' '.

                  loop at t_marm_data.
                    clear: pet_ot1_f_artstm.

*                   Setze Initialisierungsmerker zum späteren
*                   Initialisieren.
                    pet_ot1_f_artstm-init = 'X'.

*                   Merken, das der Pointer aufgrund einer
*                   Materialinitialisierung erzeugt wurde.
                    pet_ot1_f_artstm-aetyp_sort = c_init_sort_index.

*                   Fülle die restlichen Felder in Objekttabelle 1
*                   (filialabhängig).
                    pet_ot1_f_artstm-filia = pit_filia_group-filia.
                    pet_ot1_f_artstm-artnr = t_marm_data-matnr.
                    pet_ot1_f_artstm-vrkme = t_marm_data-meinh.
                    pet_ot1_f_artstm-datum = pi_erstdat.
                    append pet_ot1_f_artstm.

*                   Gilt auch für EAN-Referenzen.
                    move-corresponding pet_ot1_f_artstm to
                                       pet_ot1_f_ean.
                    append pet_ot1_f_ean.
                  endloop. " at t_marm_data.
                endif. " t_wrf6-wdaus = space.
              endif. " sy-subrc = 0.
            endif.                    " PIT_POINTER-FLDNAME = 'WDAUS'.
          endif.                 " pit_pointer-cdchgid = c_insert.

      endcase.                           " PIT_POINTER-TABNAME.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.

*{   INSERT         XB4K002882                                        1
* WRF_POSOUT
  PERFORM call_badi_mtgp_analyse_pointer
               tables pit_pointer
                      pit_filia_group
                      pet_ot1_f_artstm
                      pet_ot2_artstm
               using  pi_erstdat
                      pi_datp3
                      pi_datp4.

* WRF_POSOUT
*}   INSERT

************************************************************************
* Einsammeln des parallelen Tasks.
  wait until g_rcv_jobs_cnd >= g_snd_jobs_cnd.
************************************************************************

* Übernehme die Daten der fehlerhaften Tasks in Ausgabetabelle.
  loop at gt_rfcdest_cnd.
    append gt_rfcdest_cnd to pet_rfcdest.
  endloop. " at gt_rfcdest_cnd.

************************************************************************


* Prüfe, ob Fehler bei der parallelen Verarbeitung auftraten.
  read table gt_error_tasks_cnd index 1.

* Falls Fehler bei der parallelen Verarbeitung auftraten.
  if sy-subrc = 0.
*   Nochmalige Konditionsanalyse. Diesmal seriell.
    perform artstm_condpt_analyse_prepare
            tables pit_pointer
                   pit_wind
                   pit_filia_group
                   pit_kondart
                   pit_kondart_gesamt
                   pet_ot1_f_artstm
                   pet_ot2_artstm
                   pet_reorg_pointer
                   pet_rfcdest
            using  pi_wind
                   pi_erstdat
                   pi_datp3
                   pi_datp4
                   pi_pointer_reorg
                   ' '                   " pi_parallel
                   ' '                   " pi_server_group
                   pi_taskname
                   g_snd_jobs_cnd.

  endif. " sy-subrc = 0.

* Falls Parallelverarbeitung.
  if not pi_parallel is initial.
    loop at gt_rfcdest_cnd.
      append gt_rfcdest_cnd to pet_rfcdest.
    endloop. " at gt_rfcdest_cnd.

    loop at gt_reorg_pointer.
      append gt_reorg_pointer to pet_reorg_pointer.
    endloop. " at gt_reorg_pointer.
  endif. " not pi_parallel is initial.


************************************************************************
* Funktionsexit für kundendefinierte Änderungszeigeranalyse.
  call customer-function '009'
       exporting
            pi_erstdat       = pi_erstdat
            pi_datp4         = pi_datp4
       tables
            pit_filia_group  = pit_filia_group
            pit_pointer      = pit_pointer
            pet_ot1_f_artstm = pet_ot1_f_artstm
            pet_ot2_artstm   = pet_ot2_artstm.
************************************************************************


* Sortieren der Daten.
  sort pet_ot1_f_artstm by  filia artnr vrkme aetyp_sort.
  sort pet_ot2_artstm   by        artnr vrkme aetyp_sort.

* Bestimme Änderungstyp und merke ihn im ersten Satz eines jeden Keys.
  clear: i_key5, i_key6, h_aenderungstyp, h_readindex.
  loop at pet_ot1_f_artstm
       where upd_flag <> c_del.
    move-corresponding pet_ot1_f_artstm to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      h_aenderungstyp = pet_ot1_f_artstm-aetyp_sort.
      h_readindex     = sy-tabix.
    else. " i_key5 = i_key6
*     Falls der Änderungstyp noch potentiell änderbar ist, dann
*     prüfe weiter.
      if h_aenderungstyp > c_all_sort_index.
*       Falls der Änderungstyp auf 'ALL' zu ändern ist.
        if pet_ot1_f_artstm-aetyp_sort > h_aenderungstyp and
           pet_ot1_f_artstm-aetyp_sort = c_mat_sort_index.
*         Ändere den ersten Satz für diesen Schlüssel.
          read table pet_ot1_f_artstm index h_readindex.
          pet_ot1_f_artstm-aetyp_sort = c_all_sort_index.
          modify pet_ot1_f_artstm index h_readindex.

          h_aenderungstyp = c_all_sort_index.
        endif. " pet_ot1_f_artstm-aetyp_sort > h_aenderungstyp.
      endif. " h_aenderungstyp > c_all_sort_index.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT1_F_ARTSTM.

* Übertrage den gemerkten Änderungstyp auf alle übrigen
* Einträge desselben Schlüssels.
  clear: i_key5, i_key6.
  loop at pet_ot1_f_artstm.
    move-corresponding pet_ot1_f_artstm to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      h_aenderungstyp = pet_ot1_f_artstm-aetyp_sort.

    elseif i_key5 = i_key6 and
           h_aenderungstyp <> pet_ot1_f_artstm-aetyp_sort.
      pet_ot1_f_artstm-aetyp_sort = h_aenderungstyp.
      modify pet_ot1_f_artstm.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT pet_ot1_f_artstm.

* Bestimme Änderungstyp und merke in im ersten Satz eines jeden Keys.
  clear: i_key5, i_key6, h_aenderungstyp, h_readindex.
  loop at pet_ot2_artstm
       where upd_flag <> c_del.
    move-corresponding pet_ot2_artstm to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      h_aenderungstyp = pet_ot2_artstm-aetyp_sort.
      h_readindex     = sy-tabix.
    else. " i_key5 = i_key6
*     Falls der Änderungstyp noch potentiell änderbar ist, dann
*     prüfe weiter.
      if h_aenderungstyp > c_all_sort_index.
*       Falls der Änderungstyp auf 'ALL' zu ändern ist.
        if pet_ot2_artstm-aetyp_sort > h_aenderungstyp and
           pet_ot2_artstm-aetyp_sort = c_mat_sort_index.
*         Ändere den ersten Satz für diesen Schlüssel.
          read table pet_ot2_artstm index h_readindex.
          pet_ot2_artstm-aetyp_sort = c_all_sort_index.
          modify pet_ot2_artstm index h_readindex.

          h_aenderungstyp = c_all_sort_index.
        endif. " pet_ot2_artstm-aetyp_sort > h_aenderungstyp.
      endif. " h_aenderungstyp > c_all_sort_index.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT2_ARTSTM.

* Übertrage den gemerkten Änderungstyp auf alle übrigen
* Einträge desselben Schlüssels.
  clear: i_key5, i_key6.
  loop at pet_ot2_artstm.
    move-corresponding pet_ot2_artstm to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      h_aenderungstyp = pet_ot2_artstm-aetyp_sort.

    elseif i_key5 = i_key6 and
           h_aenderungstyp <> pet_ot2_artstm-aetyp_sort.
      pet_ot2_artstm-aetyp_sort = h_aenderungstyp.
      modify pet_ot2_artstm.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT pet_ot2_artstm.


* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Sortieren der Daten.
  sort pet_ot1_f_artstm by  filia artnr vrkme init descending datum
                                  upd_flag.
  sort pet_ot2_artstm   by        artnr vrkme mamt_spras
                                  init descending datum upd_flag
                                  wlk2 descending.
  sort pet_ot1_f_ean    by  filia artnr vrkme init descending datum
                                  upd_flag.
  sort pet_ot2_ean      by        artnr vrkme init descending datum
                                  upd_flag.

* Lösche überflüssige Einträge aus Tabelle PET_OT1_F_ARTSTM.
  clear: i_key5, i_key6, h_init, h_datum.
  loop at pet_ot1_f_artstm
       where upd_flag <> c_del
       and   attyp    =  space.
    move-corresponding pet_ot1_f_artstm to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      clear: h_init.
      if pet_ot1_f_artstm-init <> space.
        h_init = 'X'.
        h_datum = pet_ot1_f_artstm-datum.
      endif.                           " PET_OT1_F_ARTSTM-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key5 = i_key6 and h_init <> space and
           pet_ot1_f_artstm-datum >= h_datum.
      delete pet_ot1_f_artstm.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT1_F_ARTSTM.

* Lösche überflüssige Einträge aus Tabelle PET_OT2_ARTSTM.
  clear: i_key7, i_key8, h_init, h_datum.
  loop at pet_ot2_artstm
       where upd_flag <> c_del
       and   attyp    =  space.
    move-corresponding pet_ot2_artstm to i_key8.
    if i_key7 <> i_key8.
      i_key7 = i_key8.
      clear: h_init.
      if pet_ot2_artstm-init <> space.
        h_init = 'X'.
        h_datum = pet_ot2_artstm-datum.
      endif.                           " PET_OT2_ARTSTM-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden, mit Ausnahme von Löschsätzen.
    elseif i_key7 = i_key8 and h_init <> space and
           pet_ot2_artstm-datum >= h_datum.
      delete pet_ot2_artstm.
    endif.                             " I_KEY7 <> I_KEY8.
  endloop.                             " AT PET_OT2_ARTSTM.

* Lösche überflüssige Einträge aus Tabelle PET_OT1_F_EAN.
  clear: i_key5, i_key6, h_init, h_datum.
  loop at pet_ot1_f_ean
       where upd_flag <> c_del.
    move-corresponding pet_ot1_f_ean to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      clear: h_init.
      if pet_ot1_f_ean-init <> space.
        h_init = 'X'.
        h_datum = pet_ot1_f_ean-datum.
      endif.                           " PET_OT1_F_EAN-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key5 = i_key6 and h_init <> space and
           pet_ot1_f_ean-datum >= h_datum.
      delete pet_ot1_f_ean.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT1_F_EAN.

* Lösche überflüssige Einträge aus Tabelle PET_OT2_EAN.
  clear: i_key10, i_key11, h_init, h_datum.
  loop at pet_ot2_ean
       where upd_flag = space.
    move-corresponding pet_ot2_ean to i_key8.
    if i_key10 <> i_key11.
      i_key10 = i_key11.
      clear: h_init.
      if pet_ot2_ean-init <> space.
        h_init = 'X'.
        h_datum = pet_ot2_ean-datum.
      endif.                           " PET_OT2_EAN-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden, mit Ausnahme von Löschsätzen.
    elseif i_key10 = i_key11 and h_init <> space and
           pet_ot2_ean-datum >= h_datum.
      delete pet_ot2_ean.
    endif.                             " I_KEY10 <> I_KEY11.
  endloop.                             " AT PET_OT2_EAN.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT1_F_ARTSTM.
  delete adjacent duplicates from pet_ot1_f_artstm
         comparing all fields.

* Lösche doppelte Einträge aus PET_OT2_ARTSTM.
  delete adjacent duplicates from pet_ot2_artstm
                  comparing all fields.

* Lösche doppelte Einträge aus PET_OT1_F_EAN.
  delete adjacent duplicates from pet_ot1_f_ean
         comparing all fields.

* Lösche doppelte Einträge aus PET_OT2_EAN.
  delete adjacent duplicates from pet_ot2_ean
                  comparing all fields.


endform.                               " ARTSTM_EAN_POINTER_ANALYSE


*eject
************************************************************************
form sets_pointer_analyse
     tables pit_pointer     structure bdcp
            pit_filia_group structure gt_filia_group
            pet_artdel      structure gt_artdel
            pet_ot1_f_sets  structure gt_ot1_f_sets
            pet_ot2_sets    structure gt_ot2_sets
     using  pi_erstdat      like syst-datum
            pi_datp3        like syst-datum
            pi_datp4        like syst-datum.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabellen PET_OT1_F_SETS (filialabhängig)
* und PET_OT2_SETS (filialunabhängig).
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER     : Tabelle der zu analysierenden Änderungspointer.

* PIT_FILIA_GROUP : Tabelle für Filialkonstanten der Gruppe.

* PET_ARTDEL      : Tabelle für zu löschende Artikel.

* PET_OT1_F_SETS  : Set-Zuordnungen: Objekttabelle 1, filialabhängig.

* PET_OT2_SETS    : Set-Zuordnungen: Objekttabelle 2, filialunabhängig.

* PI_ERSTDAT      : Datum: jetziges Versenden.

* PI_DATP3        : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4        : Datum: jetziges Versenden + Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  types:  BEGIN OF wlk1_key,
             mandt TYPE mandt,
             filia TYPE asort,
             artnr TYPE matnr,
             vrkme TYPE vrkme,
             datbi TYPE datbi,
             lfdnr TYPE lfdnr,
           END OF wlk1_key,

    BEGIN OF wrf6_key,
             mandt TYPE mandt,
             LOCNR TYPE kunnr,
             MATKL TYPE MATKL,

           END OF wrf6_key.


  data: i_wrf6 type wrf6_key.
  data: i_wlk1 type wlk1_key.


  data: h_init,
        h_delete,
        h_datum  like sy-datum,
        h_datum2 like sy-datum,
        h_group  like gt_filia_group-group,
        tabix    like sy-tabix,
        h_tabix  like sy-tabix,
        found.

* Zum Komprimieren von Tabelle PET_OT1_F_SETS (Stufe 1).
  data: begin of i_key5,
          filia like pet_ot1_f_sets-filia,
          artnr like pet_ot1_f_sets-artnr,
          vrkme like pet_ot1_f_sets-vrkme.
  data: end of i_key5.

* Zum Komprimieren von Tabelle PET_OT1_F_SETS (Stufe 1).
  data: begin of i_key6.
          include structure i_key5.
  data: end of i_key6.

* Zum Komprimieren von Tabelle PET_OT2_SETS (Stufe 1).
  data: begin of i_key7,
          artnr like pet_ot2_sets-artnr,
          vrkme like pet_ot2_sets-vrkme.
  data: end of i_key7.

* Zum Komprimieren von Tabelle PET_OT2_SETS (Stufe 1).
  data: begin of i_key8.
          include structure i_key7.
  data: end of i_key8.

  data: t_filia_matnr like gt_filia_matnr_buf occurs 0
                                              with header line.

* Temporärtabelle für Filialen.
  data: begin of t_filia occurs 5,
          filia like t001w-werks.
  data: end of t_filia.

* Temporärtabelle für filialabhängige Änderungen.
  data: begin of t_ot1 occurs 0.
          include structure gt_ot1_f_sets.
  data: end of t_ot1.

* Tabelle für Zugriff auf übergeordnete Baugruppen (SETS)
  data: begin of t_sets occurs 5.
          include structure stpov.
  data: end of t_sets.

* Tabelle für übergeordnete Baugruppen (SETS)
  data: begin of t_matcat occurs 5.
          include structure cscmat.
  data: end of t_matcat.

* Kopftabelle für Set-Artikel
  data: begin of t_mast occurs 5.
          include structure mast.
  data: end of t_mast.

* Kopftabelle für Set-Artikel
  data: begin of t_mastb occurs 5.
          include structure mastb.
  data: end of t_mastb.

* Positionstabelle für Set-Artikel
  data: begin of t_stpo occurs 5.
          include structure stpob.
  data: end of t_stpo.

* Dummy-Tabelle. Wird nur als Übergabeparameter verwendet.
  data: begin of t_equicat occurs 1.
          include structure cscequi.
  data: end of t_equicat.

* Dummy-Tabelle. Wird nur als Übergabeparameter verwendet.
  data: begin of t_kndcat occurs 1.
          include structure cscknd.
  data: end of t_kndcat.

* Dummy-Tabelle. Wird nur als Übergabeparameter verwendet.
  data: begin of t_stdcat occurs 1.
          include structure cscstd.
  data: end of t_stdcat.

* Dummy-Tabelle. Wird nur als Übergabeparameter verwendet.
  data: begin of t_tplcat occurs 1.
          include structure csctpl.
  data: end of t_tplcat.

  data: begin of t_wrf6 occurs 2.
          include structure wrf6.
  data: end of t_wrf6.

* Tabelle für alle Artikelnummern, die einer bestimmten
* Warengruppe zugeordnet sind.
  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.

* Tabelle für alle zugehörigen MARM-Daten
  data: begin of t_marm_data  occurs 0.
          include structure gt_marm_buf.
  data: end of t_marm_data.

* Tabelle für WLK2-Sätze.
  data: begin of t_wlk2 occurs 1.
          include structure wlk2.
  data: end of t_wlk2.

* Tabelle für Nutzer eines Sortiments
  data: begin of t_assortment_users occurs 0.
          include structure wrsz.
  data: end of t_assortment_users.

* Temporärtabelle mit den Daten einer Filiale.
  data: begin of t_filia_group_temp occurs 0.
          include structure gt_filia_group.
  data: end of t_filia_group_temp.


* Bestimme die Nummer der gerade  bearbeiteten Filialgruppe.
  read table pit_filia_group index 1.
  h_group = pit_filia_group-group.

  data: max_datum like sy-datum value '99991231'.

  refresh: pet_ot1_f_sets, pet_ot2_sets.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_mat_full
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Materialstammänderungen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_mat_full.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_mat_full.

      clear: pet_ot2_sets.

      case pit_pointer-tabname.
*       Änderungen in Tabelle MARA: Materialstamm
        when 'MARA'.
*         Material soll geändert werden.
          if pit_pointer-cdchgid = c_update.
            mara-matnr = pit_pointer-cdobjid.

*           Die Haupt-EAN zur Basismengeneinheit hat sich geändert.
            if pit_pointer-fldname = 'EAN11'.
*             Besorge die MARA-Daten des Artikels.
              perform mara_select using mara
                                        mara-matnr.

              if mara-matnr <> space.
*               Falls der Artikel ein Set-Artikel ist, dann erzeuge
*               Lösch-Eintrag für alte EAN und übernehme Artikel in
*               Objekttabelle.
                if mara-attyp = c_setartikel.

*                 Bestimme die Set-Intervalle, auf die sich die
*                 Änderung bezieht.
                  h_datum = pit_pointer-acttime(8).
                  refresh: gt_set_komp.
                  call function 'MGW0_COMPONENTS'
                    EXPORTING
                      mgw0_article        = mara-matnr
                      mgw0_date_from      = h_datum
                      mgw0_date_to        = pi_datp4
                      mgw0_plant          = '    '
                      mgw0_structure_type = c_settype
                    TABLES
                      mgw0_components     = gt_set_komp
                    EXCEPTIONS
                      not_found           = 01.

*                 Daten sortieren.
                  sort gt_set_komp by datuv.

                  loop at gt_set_komp.
*                   Das Set-Intervall liegt innerhalb des Betrachtungs-
*                   zeitraums (ab Materialänderung gerechnet)
*                   und muß deshalb berücksichtigt werden.
                    if gt_set_komp-datuv <= pi_datp4  and
                       gt_set_komp-datub >= pit_pointer-acttime(8).
*                     Falls der Beginn des Intervalls vor dem Zeitpunkt
*                     der Materialänderung liegt, dann setze ihn auf
*                     diesen Zeitpunkt.
                      if gt_set_komp-datuv < pit_pointer-acttime(8).
                        gt_set_komp-datuv = pit_pointer-acttime(8).
                      endif.

*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_sets-datum = gt_set_komp-datuv.
                      pet_ot2_sets-artnr = mara-matnr.
                      pet_ot2_sets-vrkme = mara-meins.
                      clear: pet_ot2_sets-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if gt_set_komp-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                        pet_ot2_sets-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.
                        clear: pet_ot2_sets-init.
                      endif. " GT_SET_KOMP-DATUV < PI_DATP3 AND ...

*                     Falls das Beginndatum des Zeitraums in der
*                     Vergangenheit liegt, dann muß immer
*                     Initialisiert werden.
                      if gt_set_komp-datuv < pi_erstdat.
                        pet_ot2_sets-init  = 'X'.
                        pet_ot2_sets-datum = pi_erstdat.
                      endif.         " GT_SET_KOMP-DATUV < PI_ERSTDAT

*                     Merken des ersten Gültigkeitsdatums des Sets.
                      if sy-tabix = 1.
                        h_datum2 = pet_ot2_sets-datum.
                      endif. " sy-tabix = 1.

                      append pet_ot2_sets.

                    endif. " GT_SET_KOMP-DATUV <= PI_DATP4  and ...
                  endloop.               " AT GT_SET_KOMP.

*                 Falls Komponenten gefunden wurden.
                  if sy-subrc = 0.
*                   Besorge alte Haupt-EAN, falls nötig.
                    h_datum = pit_pointer-acttime(8).
                    h_datum = h_datum - 1.

*                   Falls die Änderung in der Vergangenheit liegt, dann
*                   bestimme alte EAN aus Änderungsbeleg, falls nötig.
                    if h_datum < sy-datum.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      clear: gt_old_ean_set.
                      read table gt_old_ean_set with key
                                 artnr = mara-matnr
                                 vrkme = mara-meins
                                 datum = h_datum2
                                 binary search.

*                    Die alte EAN wurde noch nicht zwischengespeichert.
                      if sy-subrc <> 0.
                        tabix = sy-tabix.

*                       Besorge alte Haupt-EAN aus Änderungsbeleg.
                        perform old_value_get
                                    using pit_pointer
                                          gt_old_ean_set-ean11
                                          found.

*                       Falls die alte EAN ermittelt werden konnte und
*                       sie <> SPACE ist.
                        if found = space.
*                         Abspeichern der EAN zur späteren Analyse.
                          gt_old_ean_set-artnr = mara-matnr.
                          gt_old_ean_set-vrkme = mara-meins.
                          gt_old_ean_set-datum = h_datum2.

*                         Besorge alten EAN-Typ aus Änderungsbeleg.
                          gi_pointer         = pit_pointer.
                          gi_pointer-fldname = 'NUMTP'.

                          perform old_value_get
                                      using gi_pointer
                                            gt_old_ean_set-numtp
                                            found.

                          insert gt_old_ean_set index tabix.
                        endif. " found = space.
                      endif. " sy-subrc <> 0.
                    endif. " h_datum < sy-datum.
                  endif. " sy-subrc = 0.
                endif.                   " MARA-ATTYP = C_SETARTIKEL.

*               Prüfe, ob der Artikel eine Stckl-Komponente ist.
                refresh: t_sets.
                h_datum = pit_pointer-acttime(8).
                call function 'CS_WHERE_USED_MAT'
                     exporting
                          datub                  = pi_datp4
                          datuv                  = h_datum
                          matnr                  = mara-matnr
                          postp                  = ' '
                          retcode_only           = ' '
                          stlan                  = ' '
                          werks                  = ' '
*                    IMPORTING
*                   TOPMAT                     =
                     tables
                          wultb                  = t_sets
                          matcat                 = t_matcat
                          equicat                = t_equicat  " Dummy
                          kndcat                 = t_kndcat   " Dummy
                          stdcat                 = t_stdcat   " Dummy
                          tplcat                 = t_tplcat   " Dummy
                     exceptions
                          call_invalid               = 01
                          material_not_found         = 02
                          no_where_used_rec_found    = 03
                          no_where_used_rec_selected = 04
                          no_where_used_rec_valid    = 05.

                sort t_matcat by index.

*               Falls der Artikel Teil einer Mat.-Stückliste ist.
                if sy-subrc = 0.
*                 Überprüfe die übergeordneten Artikel.
                  loop at t_sets
                       where bmtyp = c_mat_stlty.
*                   Das Set-Intervall liegt innerhalb des Betrachtungs-
*                   zeitraums (ab Materialänderung gerechnet)
*                   und muß deshalb berücksichtigt werden.
                    if t_sets-datuv <= pi_datp4  and
                       t_sets-datub >= pit_pointer-acttime(8).
*                     Falls der Beginn des Intervalls vor dem Zeitpunkt
*                     der Materialänderung liegt, dann setze ihn auf
*                     diesen Zeitpunkt.
                      if t_sets-datuv < pit_pointer-acttime(8).
                        t_sets-datuv = pit_pointer-acttime(8).
                      endif. " T_SETS-DATUV < PIT_POINTER-ACTTIME(8).

*                     Besorge übergeordnete Materialnummer.
                      read table t_matcat index t_sets-ttidx.

*                     Besorge die Basismengeneinheit des Artikels.
                      perform mara_select using mara
                                                t_matcat-matnr.

*                     Nur Set-Artikel werden berücksichtigt.
                      if mara-matnr <> space and
                         mara-attyp = c_setartikel.
*                       Fülle Objekttabelle 2 (filialunabhängig).
                        pet_ot2_sets-vrkme = mara-meins.
                        pet_ot2_sets-datum = t_sets-datuv.
                        pet_ot2_sets-artnr = t_matcat-matnr.
                        clear: pet_ot2_sets-upd_flag.

*                       Falls das POS-System keine zeitliche Verwaltung
*                       von Daten kann, muß neu Initialisiert werden.
                        if t_sets-datuv < pi_datp3 and
                          pit_filia_group-zvdat = space.
                          pet_ot2_sets-init = 'X'.
*                       Falls das POS-System eine zeitliche Verwaltung
*                       von Daten kann.
                        else.            " T_SETS-DATUV >= PI_DATP3.
                          clear: pet_ot2_sets-init.
                        endif.           " T_SETS-DATUV < PI_DATP3...

*                       Falls das Beginndatum des Zeitraums in der
*                       Vergangenheit liegt, dann muß immer
*                       Initialisiert werden.
                        if t_sets-datuv < pi_erstdat.
                          pet_ot2_sets-init  = 'X'.
                          pet_ot2_sets-datum = pi_erstdat.
                        endif.           " T_SETS-DATUV < PI_ERSTDAT

                        append pet_ot2_sets.
                      endif.  " mara-matnr <> space and ...
                    endif. " GT_SET_KOMP-DATUV <= PI_DATP4  AND ...
                  endloop.             " AT T_SETS.
                endif.                 " SY-SUBRC = 0.
              endif.                   " mara-matnr <> space.
            endif.                     " PIT_POINTER-FLDNAME = 'EAN11'.
          endif.                       " PIT_POINTER-CDCHGID = C_UPDATE.

*       Änderungen der Haupt-EAN in Tabelle MARM.
        when 'DMARM'.
*         Material soll geändert werden.
          if pit_pointer-cdchgid = c_update.
            marm-matnr = pit_pointer-cdobjid.
            marm-meinh = pit_pointer-tabkey.

*           Die Haupt-EAN zur Mengeneinheit hat sich geändert.
            if pit_pointer-fldname = 'EAN11'.
*             Besorge die MARA-Daten des Artikels.
              perform mara_select using mara
                                        marm-matnr.

              if mara-matnr <> space.
*               Falls der Artikel ein Set-Artikel ist, dann erzeuge
*               Lösch-Eintrag für alte EAN und übernehme Artikel in
*               Objekttabelle.
                if mara-attyp = c_setartikel.
*                 Bestimme die Set-Intervalle, auf die sich die
*                 Änderung bezieht.
                  refresh: gt_set_komp.
                  h_datum = pit_pointer-acttime(8).
                  call function 'MGW0_COMPONENTS'
                    EXPORTING
                      mgw0_article        = marm-matnr
                      mgw0_date_from      = h_datum
                      mgw0_date_to        = pi_datp4
                      mgw0_plant          = '    '
                      mgw0_structure_type = c_settype
                    TABLES
                      mgw0_components     = gt_set_komp
                    EXCEPTIONS
                      not_found           = 01.

*                 Daten sortieren.
                  sort gt_set_komp by datuv.

                  loop at gt_set_komp.
*                  Das Set-Intervalls liegt innerhalb des Betrachtungs-
*                   zeitraums (ab Materialänderung gerechnet)
*                   und muß deshalb berücksichtigt werden.
                    if gt_set_komp-datuv <= pi_datp4  and
                       gt_set_komp-datub >= pit_pointer-acttime(8).
*                     Falls der Beginn des Intervalls vor dem Zeitpunkt
*                     der Materialänderung liegt, dann setze ihn auf
*                     diesen Zeitpunkt.
                      if gt_set_komp-datuv < pit_pointer-acttime(8).
                        gt_set_komp-datuv = pit_pointer-acttime(8).
                      endif.

*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_sets-datum = gt_set_komp-datuv.
                      pet_ot2_sets-artnr = marm-matnr.
                      pet_ot2_sets-vrkme = marm-meinh.
                      clear: pet_ot2_sets-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if gt_set_komp-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                        pet_ot2_sets-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.
                        clear: pet_ot2_sets-init.
                      endif. " GT_SET_KOMP-DATUV < PI_DATP3 AND ...

*                     Falls das Beginndatum des Zeitraums in der
*                     Vergangenheit liegt, dann muß immer
*                     Initialisiert werden.
                      if gt_set_komp-datuv < pi_erstdat.
                        pet_ot2_sets-init  = 'X'.
                        pet_ot2_sets-datum = pi_erstdat.
                      endif.         " GT_SET_KOMP-DATUV < PI_ERSTDAT

*                     Merken des ersten Gültigkeitsdatums des Sets.
                      if sy-tabix = 1.
                        h_datum2 = pet_ot2_sets-datum.
                      endif. " sy-tabix = 1.

                      append pet_ot2_sets.

                    endif. " GT_SET_KOMP-DATUV <= PI_DATP4  AND ...
                  endloop.               " AT GT_SET_KOMP.

*                 Falls Komponenten gefunden wurden.
                  if sy-subrc = 0.
*                   Besorge alte Haupt-EAN, falls nötig.
                    h_datum = pit_pointer-acttime(8).
                    h_datum = h_datum - 1.

*                   Falls die Änderung in der Vergangenheit liegt, dann
*                   bestimme alte EAN aus Änderungsbeleg, falls nötig.
                    if h_datum < sy-datum.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      clear: gt_old_ean_set.
                      read table gt_old_ean_set with key
                                 artnr = marm-matnr
                                 vrkme = marm-meinh
                                 datum = h_datum2
                                 binary search.

*                    Die alte EAN wurde noch nicht zwischengespeichert.
                      if sy-subrc <> 0.
                        tabix = sy-tabix.

*                       Besorge alte Haupt-EAN aus Änderungsbeleg.
                        perform old_value_get
                                    using pit_pointer
                                          gt_old_ean_set-ean11
                                          found.

*                       Falls die alte EAN ermittelt werden konnte und
*                       sie <> SPACE ist.
                        if found = space.
*                         Abspeichern der EAN zur späteren Analyse.
                          gt_old_ean_set-artnr = marm-matnr.
                          gt_old_ean_set-vrkme = marm-meinh.
                          gt_old_ean_set-datum = h_datum2.

*                         Besorge alten EAN-Typ aus Änderungsbeleg.
                          gi_pointer         = pit_pointer.
                          gi_pointer-fldname = 'NUMTP'.

                          perform old_value_get
                                      using gi_pointer
                                            gt_old_ean_set-numtp
                                            found.

                          insert gt_old_ean_set index tabix.
                        endif. " found = space.
                      endif. " sy-subrc <> 0.
                    endif. " h_datum < sy-datum.
                  endif. " sy-subrc = 0.
                endif.                   " MARA-ATTYP = C_SETARTIKEL.

*               Prüfe, ob der Artikel Teil einer Stückliste ist.
                refresh: t_sets.
                h_datum = pit_pointer-acttime(8).
                call function 'CS_WHERE_USED_MAT'
                     exporting
                          datub                  = pi_datp4
                          datuv                  = h_datum
                          matnr                  = marm-matnr
                          postp                  = ' '
                          retcode_only           = ' '
                          stlan                  = ' '
                          werks                  = ' '
*                    IMPORTING
*                   TOPMAT                     =
                     tables
                          wultb                  = t_sets
                          matcat                 = t_matcat
                          equicat                = t_equicat  " Dummy
                          kndcat                 = t_kndcat   " Dummy
                          stdcat                 = t_stdcat   " Dummy
                          tplcat                 = t_tplcat   " Dummy
                     exceptions
                          call_invalid               = 01
                          material_not_found         = 02
                          no_where_used_rec_found    = 03
                          no_where_used_rec_selected = 04
                          no_where_used_rec_valid    = 05.

                sort t_matcat by index.

*               Falls der Artikel Teil einer Stückliste ist.
                if sy-subrc = 0.
*                 Überprüfe die übergeordneten Artikel.
                  loop at t_sets
                       where bmtyp = c_mat_stlty.
*                  Das Set-Intervalls liegt innerhalb des Betrachtungs-
*                   zeitraums (ab Materialänderung gerechnet)
*                   und muß deshalb berücksichtigt werden.
                    if t_sets-datuv <= pi_datp4  or
                       t_sets-datub >= pit_pointer-acttime(8).
*                     Falls der Beginn des Intervalls vor dem Zeitpunkt
*                     der Materialänderung liegt, dann setze ihn auf
*                     diesen Zeitpunkt.
                      if t_sets-datuv < pit_pointer-acttime(8).
                        t_sets-datuv = pit_pointer-acttime(8).
                      endif. " T_SETS-DATUV < PIT_POINTER-ACTTIME(8).

*                     Besorge übergeordnete Materialnummer.
                      read table t_matcat index t_sets-ttidx.

*                     Besorge die Basismengeneinheit des Artikels.
                      perform mara_select using mara
                                                t_matcat-matnr.

                      if mara-matnr <> space and
                         mara-attyp = c_setartikel.
*                       Fülle Objekttabelle 2 (filialunabhängig).
                        pet_ot2_sets-vrkme = mara-meins.
                        pet_ot2_sets-datum = t_sets-datuv.
                        pet_ot2_sets-artnr = t_matcat-matnr.
                        clear: pet_ot2_sets-upd_flag.

*                       Falls das POS-System keine zeitliche Verwaltung
*                       von Daten kann, muß neu Initialisiert werden.
                        if t_sets-datuv < pi_datp3 and
                          pit_filia_group-zvdat = space.
                          pet_ot2_sets-init = 'X'.
*                       Falls das POS-System eine zeitliche Verwaltung
*                       von Daten kann.
                        else.            " T_SETS-DATUV >= PI_DATP3.
                          clear: pet_ot2_sets-init.
                        endif.           " T_SETS-DATUV < PI_DATP3...

*                       Falls das Beginndatum des Zeitraums in der
*                       Vergangenheit liegt, dann muß immer
*                       Initialisiert werden.
                        if t_sets-datuv < pi_erstdat.
                          pet_ot2_sets-init  = 'X'.
                          pet_ot2_sets-datum = pi_erstdat.
                        endif.           " T_SETS-DATUV < PI_ERSTDAT

                        append pet_ot2_sets.
                      endif.  " mara-matnr <> space and ...
                    endif. " GT_SET_KOMP-DATUV <= PI_DATP4  AND ...
                  endloop.             " AT T_SETS.
                endif.                 " SY-SUBRC = 0.
              endif.                   " mara-matnr <> space.
            endif.                     " PIT_POINTER-FLDNAME = 'EAN11'.
          endif.                       " PIT_POINTER-CDCHGID = C_UPDATE.

      endcase.                         " PIT_POINTER-TABNAME
    endloop.                           " AT PIT_POINTER
  endif. " sy-subrc = 0.

  clear: h_tabix.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_stue
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.
  else. " sy-subrc <> 0.
*   Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
    read table pit_pointer with key
         cdobjcl = c_objcl_stue_v
         binary search
         transporting no fields.

*   Falls zu diesem Änderungsbelegobjekt Werte existieren.
    if sy-subrc = 0.
      h_tabix = sy-tabix.
    endif. " sy-subrc = 0.
  endif. " sy-subrc = 0.

* Falls zu einem dieser Änderungsbelegobjekte Werte existieren.
  if h_tabix > 0.
*   Betrachte Stücklistenänderungen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_stue    and
         pit_pointer-cdobjcl <> c_objcl_stue_v.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_stue  and...

      clear: pet_ot2_sets.

      case pit_pointer-tabname.
*       Änderungen in Tabelle MAST: Materialstücklisten.
        when 'MAST'.
          mast = pit_pointer-tabkey(36).   " Unicode enabling

*         Prüfe, ob es sich um einen Set-Artikel handelt.
          perform mara_select using mara
                                    mast-matnr.

*         Falls es sich um einen Set-Artikel handelt.
          if mara-matnr <> space and mara-attyp = c_setartikel.
*           Besorge den Gültigkeitsbeginn der Stückliste.
            clear: stko.
            select datuv from  stko
                   into (stko-datuv)
                   where  stlty       = c_mat_stlty
                   and    stlnr       = mast-stlnr
                   and    stlal       = mast-stlal
                   and    stkoz       = 1.
              exit.
            endselect. " from  stko

            if sy-subrc = 0.
              pet_ot2_sets-datum = stko-datuv.
            else.                        " SY-SUBRC = 0.
              pet_ot2_sets-datum = pi_erstdat.
            endif.                       " SY-SUBRC = 0.

*          Der Gültigkeitsbeginn der Stückliste muß kleiner oder gleich
*           PI_DATP4 sein.
            if pet_ot2_sets-datum <= pi_datp4.
*             Falls eine Stückliste angelegt werden soll.
              if pit_pointer-cdchgid = c_insert.
*               Fülle Objekttabelle 2 (filialunabhängig).
                clear: pet_ot2_sets-upd_flag.
                pet_ot2_sets-artnr = mara-matnr.
                pet_ot2_sets-vrkme = mara-meins.

*               Falls das POS-System keine zeitliche Verwaltung
*               von Daten kann, muß neu Initialisiert werden.
                if pet_ot2_sets-datum < pi_datp3  and
                    pit_filia_group-zvdat = space.
                  pet_ot2_sets-init = 'X'.
*             Falls das POS-System eine zeitliche Verwaltung
*             von Daten kann.
                else.                  " PET_OT2_SETS-DATUM >= PI_DATP3.
                  clear: pet_ot2_sets-init.
                endif. " PET_OT2_SETS-DATUM < PI_DATP3...

*               Falls der Gültigkeitsbeginn der Stückliste in der
*               Vergangenheit liegt, dann muß immer Initialisiert
*               werden.
                if pet_ot2_sets-datum < pi_erstdat.
                  pet_ot2_sets-init  = 'X'.
                  pet_ot2_sets-datum = pi_erstdat.
                endif. " PET_OT2_SETS-DATUM < PI_ERSTDAT.

                append pet_ot2_sets.

*             Falls eine Stückliste gelöscht werden soll.
              else.                  " PIT_POINTER-CDCHGID = C_DEL.
*               Falls der Gültigkeitsbeginn der Stückliste in der
*               Vergangenheit liegt, dann lösche ab heute.
                if pet_ot2_sets-datum < pi_erstdat.
                  pet_ot2_sets-datum = pi_erstdat.
                endif. " PET_OT2_SETS-DATUM < PI_ERSTDAT.

*               Prüfe, ob alte EAN bereits gemerkt wurde.
                read table pet_artdel with key
                     artnr = mara-matnr
                     vrkme = mara-meins
                     datum = pet_ot2_sets-datum
                     binary search.

                tabix = sy-tabix.

*               Falls die zugehörige EAN noch nicht gemerkt wurde, dann
*               besorge EAN.
                if sy-subrc <> 0.
*                Bestimme die H-EAN vom Vortag des Löschens. Mit dieser
*                 Lösch-EAN muß der Löschsatz aufbereitet werden.
                  h_datum = pet_ot2_sets-datum  - 1.

*                 Falls die Änderung in der Vergangenheit liegt, dann
*                 prüfe, ob Haupt-EAN bis Heute geändert wurde.
                  if h_datum < sy-datum.
*                   Prüfe, ob alte EAN bereits gemerkt wurde.
                    clear: gt_old_ean.
                    read table gt_old_ean with key
                               artnr = mara-matnr
                               vrkme = mara-meins
                               datum = sy-datum
                               binary search.

                    if sy-subrc = 0.
                      g_loesch_ean = gt_old_ean-ean11.

*                   Falls die Haupt-EAN nicht verändert wurde,
*                   dann besorge aktuelle EAN aus MARA
                    else. " sy-subrc = 0.
                      g_loesch_ean = mara-ean11.
                    endif. " sy-subrc = 0.

*                 Falls die Änderung in der Zukunft liegt, dann
*                 hole Haupt-EAN vom Vortag des Löschens.
                  else. " h_datum >= sy-datum.
                    perform ean_by_date_get
                                using mara-matnr  mara-meins
                                      h_datum     g_loesch_ean
                                      g_returncode.
                  endif. " h_datum < sy-datum.

*                Merken der Lösch-EAN und erzeugen Lösch-Eintrag in OT.
                  if g_returncode = 0 and g_loesch_ean <> space.
                    pet_artdel-artnr = mara-matnr.
                    pet_artdel-vrkme = mara-meins.
                    pet_artdel-ean   = g_loesch_ean.
                    pet_artdel-datum = pet_ot2_sets-datum.
                    insert pet_artdel index tabix.
                  endif. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
                endif.                   " SY-SUBRC <> 0.

*               Prüfe, ob Lösch-Einrag schon existiert.
                h_datum = pet_ot2_sets-datum.
                read table pet_ot2_sets with key
                     artnr    = mara-matnr
                     vrkme    = mara-meins
                     init     = space
                     upd_flag = c_del
                     datum    = h_datum.

*               Falls die Lösch-EAN noch nicht gemerkt wurde, dann
*               merke Lösch-EAN.
                if sy-subrc <> 0.
*                 Erzeuge Lösch-Eintrag in Objekttabelle 2
*                 (filialunabhängig).
                  pet_ot2_sets-artnr    = mara-matnr.
                  pet_ot2_sets-vrkme    = mara-meins.
                  pet_ot2_sets-datum    = h_datum.
                  pet_ot2_sets-upd_flag = c_del.
                  clear: pet_ot2_sets-init.
                  append pet_ot2_sets.
                endif.                   " SY-SUBRC <> 0.
              endif.                  " PIT_POINTER-CDCHGID = C_INSERT.
            endif.                   " PET_OT2_SETS-DATUM <= PI_DATP4.
          endif.  " mara-matnr <> space and mara-attyp = c_setartikel

*       Änderungen in Tabelle STPO: Stücklistenpositionen.
        when 'STPO'.
*         Stücklistenposition soll verändert werden.
          if pit_pointer-cdchgid = c_update.
            refresh: t_stpo, t_mast.
            clear:   t_stpo, t_mast.
            t_stpo = pit_pointer-tabkey(28).
            append t_stpo.

*           Falls es sich bei der Stückliste um eine Materialstückliste
*           handelt, so muß sie berücksichtigt werden.
            if t_stpo-stlty = c_mat_stlty.
*             Bestimme das Gültigkeitsbeginn der Stückliste.
              call function 'STRUC_ART_SELECT_BOM'
                EXPORTING
                  date_from    = pi_erstdat
                  date_to      = pi_datp4
                  struc_stlan  = c_set_stlan
                TABLES
                  struc_stpo   = t_stpo
                  struc_mast   = t_mast
                EXCEPTIONS
                  invalid_key  = 1
                  no_bom_found = 2
                  others       = 3.

              if sy-subrc = 0.
                read table t_stpo index 1.

*               Der Gültigkeitsbeginn der Stückliste muß <=
*               PI_DATP4 sein.
                if t_stpo-datuv <= pi_datp4.
*                 Das kleinste Versendedatum ist PI_ERSTDAT.
                  if t_stpo-datuv < pi_erstdat.
                    t_stpo-datuv = pi_erstdat.
                  endif.                 " T_STPO-DATUV < PI_ERSTDAT.

                  read table t_mast index 1.

*                 Prüfe, ob es sich um einen Set-Artikel handelt und
*                 besorge Basismengeneinheit des Artikels.
                  perform mara_select using mara
                                            t_mast-matnr.

*                 Falls es sich um einen Set-Artikel handelt.
                  if  mara-matnr <> space and mara-attyp = c_setartikel.
*                   Fülle Objekttabelle 2 (filialunabhängig).
                    pet_ot2_sets-datum = t_stpo-datuv.
                    pet_ot2_sets-artnr = t_mast-matnr.
                    pet_ot2_sets-vrkme = mara-meins.
                    clear: pet_ot2_sets-upd_flag.

*                   Falls das POS-System keine zeitliche Verwaltung
*                   von Daten kann, muß neu Initialisiert werden.
                    if t_stpo-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                      pet_ot2_sets-init = 'X'.
*                   Falls der Zeitraum jetzt beginnt, dann
*                   muß immer Initialisiert werden.
                    elseif t_stpo-datuv = pi_erstdat.
                      pet_ot2_sets-init = 'X'.
*                   Falls das POS-System eine zeitliche Verwaltung
*                   von Daten kann.
                    else.                " T_STPO-DATUV >= PI_DATP3.
                      clear: pet_ot2_sets-init.
                    endif.               " T_STPO-DATUV < PI_DATP3...

                    append pet_ot2_sets.

                  endif.               " mara-matnr <> space and ...
                endif.                 " T_STPO-DATUV <= PI_DATP4.
              endif.                   " SY-SUBRC = 0.
            endif.                     " T_STPO-STLTY = C_MAT_STLTY.
          endif.                       " PIT_POINTER-CDCHGID = C_UPDATE.

*       Einfügen und Löschen von Stücklistenpositionen.
        when 'CSBOM'.
*         Stücklistenposition soll eingefügt oder gelöscht werden.
          if pit_pointer-cdobjcl = c_objcl_stue_v.
            csbom = pit_pointer-cdobjid+3.

*           Falls es sich bei der Stückliste um ein Materialstückliste
*           handelt.
            if csbom-stlty = c_mat_stlty.
*             Der Gültigkeitsbeginn der Stückliste muß kleiner oder
*             gleich PI_DATP4 sein.
              if csbom-datuv <= pi_datp4.

*               Das kleinste Versendedatum ist PI_ERSTDAT.
                if csbom-datuv < pi_erstdat.
                  csbom-datuv = pi_erstdat.
                endif.                   " CSBOM-DATUV < PI_ERSTDAT.

*               Bestimme den zugehörigen Artikel in Tabelle MAST.
                refresh: t_mastb.
                clear:   t_mastb.
                t_mastb-stlnr = csbom-stlnr.
                t_mastb-stlal = csbom-stlal.
                t_mastb-stlan = c_set_stlan.
                append t_mastb.
                call function 'READ_MAST'
                  TABLES
                    wa              = t_mastb
                  EXCEPTIONS
                    key_incomplete  = 1
                    key_invalid     = 2
                    no_record_found = 3
                    others          = 4.

*               Nur, wenn Stückliste nicht gelöscht wurde muß reagiert
*               werden.
                if sy-subrc = 0.

                  read table t_mastb index 1.

*                 Prüfe, ob es sich um einen Set-Artikel handelt und
*                 besorge Basismengeneinheit des Artikels.
                  perform mara_select using mara
                                            t_mastb-matnr.

*                 Falls es sich um einen Set-Artikel handelt.
                  if mara-matnr <> space and mara-attyp = c_setartikel.
*                   Falls Positionen eingefügt oder gelöscht wurden.
                    if csbom-csdel = space.
*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_sets-datum = csbom-datuv.
                      pet_ot2_sets-artnr = t_mastb-matnr.
                      pet_ot2_sets-vrkme = mara-meins.
                      clear: pet_ot2_sets-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if csbom-datuv < pi_datp3 and
                         pit_filia_group-zvdat = space.
                        pet_ot2_sets-init = 'X'.
*                     Falls das Zeitraum jetzt beginnt, dann
*                     muß immer Initialisiert werden.
                      elseif csbom-datuv = pi_erstdat.
                        pet_ot2_sets-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.                " CSBOM-DATUV >= PI_DATP3.
                        clear: pet_ot2_sets-init.
                      endif.               " CSBOM-DATUV < PI_DATP3...

                      append pet_ot2_sets.

*                   Falls Stckl. ganz oder ab einem Datum gelöscht
*                   wurde.
                    elseif csbom-csdel <> space.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      read table pet_artdel with key
                           artnr = t_mastb-matnr
                           vrkme = mara-meins
                           datum = csbom-datuv.

*                     Falls die zugehörige EAN noch nicht
*                     gemerkt wurde, dann besorge EAN.
                      if sy-subrc <> 0.
*                       Bestimme die EAN vom Vortag des Löschens.
*                       Mit dieser Lösch-EAN muß der Löschsatz
*                       aufbereitet werden.
                        h_datum = csbom-datuv - 1.

*                       Falls die Änderung in der Vergangenheit liegt,
*                       dann prüfe, ob Haupt-EAN bis Heute geändert
*                       wurde.
                        if h_datum < sy-datum.
*                         Prüfe, ob alte EAN bereits gemerkt wurde.
                          clear: gt_old_ean.
                          read table gt_old_ean with key
                                     artnr = mara-matnr
                                     vrkme = mara-meins
                                     datum = sy-datum
                                     binary search.

                          if sy-subrc = 0.
                            g_loesch_ean = gt_old_ean-ean11.

*                         Falls die Haupt-EAN nicht verändert wurde,
*                         dann besorge aktuelle EAN aus MARA
                          else. " sy-subrc = 0.
                            g_loesch_ean = mara-ean11.
                          endif. " sy-subrc = 0.

*                       Falls die Änderung in der Zukunft liegt, dann
*                       hole Haupt-EAN vom Vortag des Löschens.
                        else. " h_datum >= sy-datum.
                          perform ean_by_date_get
                                      using t_mastb-matnr  mara-meins
                                            h_datum        g_loesch_ean
                                            g_returncode.
                        endif. " h_datum < sy-datum.

*                       Merken der Lösch-EAN und erzeugen
*                       Lösch-Eintrag in OT.
                        if g_returncode = 0 and g_loesch_ean <> space.
                          pet_artdel-artnr = t_mastb-matnr.
                          pet_artdel-vrkme = mara-meins.
                          pet_artdel-ean   = g_loesch_ean.
                          pet_artdel-datum = csbom-datuv.
                          append pet_artdel.
                        endif. " G_RETURNCODE = 0 AND ...
                      endif.             " SY-SUBRC <> 0.

*                     Prüfe, ob Lösch-Einrag schon existiert.
                      h_datum = csbom-datuv.
                      read table pet_ot2_sets with key
                           artnr    = t_mastb-matnr
                           vrkme    = mara-meins
                           init     = space
                           upd_flag = c_del
                           datum    = h_datum.

*                    Falls die Lösch-EAN noch nicht gemerkt wurde, dann
*                     merke Lösch-EAN.
                      if sy-subrc <> 0.
*                       Erzeuge Lösch-Eintrag in Objekttabelle 2
*                       (filialunabhängig).
                        pet_ot2_sets-artnr    = t_mastb-matnr.
                        pet_ot2_sets-vrkme    = mara-meins.
                        pet_ot2_sets-datum    = h_datum.
                        pet_ot2_sets-upd_flag = c_del.
                        clear: pet_ot2_sets-init.
                        append pet_ot2_sets.
                      endif.             " SY-SUBRC <> 0.
                    endif.               " CSBOM-CSDEL = SPACE.
                  endif. " mara-matnr <> space and ...
                endif.                   " SY-SUBRC = 0.
              endif.                     " CSBOM-DATUV <= PI_DATP4.
            endif.    " CSBOM-STLTY = C_MAT_STLTY.
          endif. " PIT_POINTER-CDOBJCL = C_OBJCL_STUE_V AND ...
      endcase.                           " PIT_POINTER-TABNAME
    endloop.                             " AT PIT_POINTER
  endif. " h_tabix > 0.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_mat_full
       tabname = 'DWLK2'
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen in Tabelle WLK2: Bewirtschaftungszeitraum.
    loop at pit_pointer from h_tabix.

*     Zum nächsten Eintrag, wenn nicht relevant.
      if pit_pointer-fldname <> 'VKBIS'   and
         pit_pointer-fldname <> 'KEY'.
        continue.
      endif. " pit_pointer-fldname <> 'VKBIS' ...

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-tabname <> 'DWLK2'.
        exit.
      endif. " pit_pointer-tabname <> 'DWLK2'.

      clear: pet_ot1_f_sets, pet_ot2_sets, wlk2, dwlk2.

*     Fülle den Schlüssel für WLK2.
      dwlk2 = pit_pointer-tabkey(10).
      move-corresponding dwlk2 to wlk2.
      wlk2-matnr = pit_pointer-cdobjid.
      wlk2-mandt = sy-mandt.

*     Falls die falsche Vertriebslinie betroffen ist.
      if pit_filia_group-vkorg <> wlk2-vkorg  or
         pit_filia_group-vtweg <> wlk2-vtweg.
*       Gehe weiter zum nächsten Satz.
        continue.
      endif. " pit_filia_group-vkorg <> wlk2-vkorg  or ...

*     Falls Filiale bekannt.
      if not wlk2-werks is initial.
*       Prüfe, ob diese Filiale in der gerade
*       bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*       dürfen berücksichtigt werden.
        read table pit_filia_group with key
             group = h_group
             filia = wlk2-werks
             binary search.

*       Falls diese Filiale nicht in der gerade betrachteten
*       Filialgruppe enthalten ist, dann weiter zum
*       nächsten Satz.
        if sy-subrc <> 0.
          continue.
        endif.      " SY-SUBRC <> 0.
      endif. " not wlk2-werks is initial.

*     Besorge die MARA-Daten des Artikels.
      perform mara_select using mara
                                wlk2-matnr.

*     Falls der Artikel kein Setartikel ist dann weiter zum
*     nächsten Satz.
      if mara-attyp <> c_setartikel.
        continue.
      endif. " mara-attyp <> c_setartikel.

*     Gelöschte WLK2-Daten werden nicht berücksichtigt.
      if pit_pointer-cdchgid <> c_del.
*       Lese betroffenen WLK2-Satz.
        refresh: t_wlk2.
        call function 'WLK2_READ'
          EXPORTING
            wlk2             = wlk2
          TABLES
            wlk2_input       = t_wlk2
          EXCEPTIONS
            no_rec_found     = 01
            key_not_complete = 02.

        read table t_wlk2 index 1.

*       Falls das Bewirtschaftungsende nicht im Bereich
*       bis PI_DATP3 liegt, dann weiter zum nächsten Satz.
        if t_wlk2-vkbis >= pi_datp3.
          continue.
        endif. " t_wlk2-vkbis >= pi_datp3.

*       Bestimme alle Verkaufsmengeneinheiten des Artikels
*       aus Tabelle MARM, die eine EAN besitzen.
        refresh: t_matnr.
        append t_wlk2-matnr to t_matnr.
        perform marm_select tables t_matnr
                                   gt_vrkme
                            using  'X'   ' '   ' '.

*       Prüfe, ob VRKME's gefunden wurden.
        read table gt_vrkme index 1.

*       Falls keine VRKME's gefunden wurden.
        if sy-subrc <> 0.
*         Weiter zum nächsten Objekt.
          continue.
        endif. " sy-subrc <> 0.

*       Schleife über alle gefundenenen Verkaufsmengeneinheiten.
        loop at gt_vrkme.
*         Prüfe, ob EAN bereits gemerkt wurde.
          h_datum = t_wlk2-vkbis + 1.

          if h_datum < pi_erstdat.
            h_datum = pi_erstdat.
          endif. " h_datum < pi_erstdat.

          read table pet_artdel with key
               artnr = gt_vrkme-matnr
               vrkme = gt_vrkme-meinh
               datum = h_datum
               binary search.

          tabix = sy-tabix.

*         Falls die zugehörige EAN noch nicht gemerkt wurde, dann
*         besorge EAN.
          if sy-subrc <> 0.
*           Besorge die Haupt-EAN vom Vortag des Löschens.
            perform ean_by_date_get
                    using gt_vrkme-matnr  gt_vrkme-meinh
                          t_wlk2-vkbis    g_loesch_ean
                          g_returncode.

*           Falls eine EAN gefunden wurde, dann erzeuge
*           Lösch-Eintrag.
            if g_returncode = 0 and g_loesch_ean <> space.
              pet_artdel-artnr = gt_vrkme-matnr.
              pet_artdel-vrkme = gt_vrkme-meinh.
              pet_artdel-ean   = g_loesch_ean.
              pet_artdel-datum = h_datum.
              insert pet_artdel index tabix.

*           Falls keine EAN gefunden wurde, dann weiter
*           zum nächsten Satz.
            else. " g_returncode <> 0 or g_loesch_ean = space.
              continue.
            endif. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
          endif. " sy-subrc <> 0.

*         Falls der T_WLK2-Satz Gültigkeit auf Konzern- oder
*         auf Vertriebslinienebene (dieser Vertriebslinie) hat.
          if  t_wlk2-vkorg = space  or
            ( t_wlk2-werks = space                  and
              t_wlk2-vkorg = pit_filia_group-vkorg  and
              t_wlk2-vtweg = pit_filia_group-vtweg ).

*           Fülle Objekttabelle 2 (filialunabhängig).
            clear: pet_ot2_sets.
            pet_ot2_sets-artnr    = gt_vrkme-matnr.
            pet_ot2_sets-vrkme    = gt_vrkme-meinh.
            pet_ot2_sets-datum    = h_datum.
            pet_ot2_sets-wlk2     = c_vertriebslinie.
            pet_ot2_sets-upd_flag = c_del.
            append pet_ot2_sets.

*         Falls Filiale bekannt und dieser Vertriebslinie
*         zugehörig.
          elseif t_wlk2-werks <> space                 and
                 t_wlk2-vkorg = pit_filia_group-vkorg  and
                 t_wlk2-vtweg = pit_filia_group-vtweg.

*           Fülle Objekttabelle 1 (filialabhängig).
            clear: pet_ot1_f_sets.
            pet_ot1_f_sets-filia    = t_wlk2-werks.
            pet_ot1_f_sets-artnr    = gt_vrkme-matnr.
            pet_ot1_f_sets-vrkme    = gt_vrkme-meinh.
            pet_ot1_f_sets-datum    = h_datum.
            pet_ot1_f_sets-upd_flag = c_del.
            append pet_ot1_f_sets.
          endif.                       " T_WLK2-VKORG = SPACE OR ...
        endloop. " at gt_vrkme.
      endif. " pit_pointer-cdchgid <> c_del.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.


* Änderungen bezüglich  n:m Zuordnung (WRSZ-Pointer)
  perform wrsz_pointer_analyse
          tables t_filia_matnr
                 pit_pointer
                 pit_filia_group
          using  pi_erstdat.

* Auflösen der Rohdaten.
  clear: pet_ot1_f_sets.

  clear: i_key7, i_key8.
  loop at t_filia_matnr.
    move t_filia_matnr-matnr to i_key8-artnr.

*   Besorge die MARA-Daten des Artikels.
    mara-matnr = t_filia_matnr-matnr.
    perform mara_select using mara
                              mara-matnr.

*   Falls der Artikel kein Set-Artikel ist, dann
*   ignoriere ihn.
    if mara-attyp <> c_setartikel.
      continue.
    endif. " mara-attyp <> c_setartikel.

    if i_key7 <> i_key8.
      i_key7 = i_key8.

*     Bestimme alle Verkaufsmengeneinheiten des Artikels
*     aus Tabelle MARM, die eine EAN besitzen.
      refresh: t_matnr.
      t_matnr-matnr = t_filia_matnr-matnr.
      append t_matnr.

      perform marm_select tables t_matnr
                                 gt_vrkme
                          using  'X'   ' '   ' '.
    endif. " i_key7 <> i_key8.

    loop at gt_vrkme.
*     Besorge die WERKS-Nummer.
      if pit_filia_group-kunnr <> t_filia_matnr-locnr.
        read table pit_filia_group with key
             kunnr = t_filia_matnr-locnr
             binary search.
      endif. " pit_filia_group-kunnr <> t_filia_matnr-locnr.

      pet_ot1_f_sets-filia = pit_filia_group-filia.
      pet_ot1_f_sets-artnr = gt_vrkme-matnr.
      pet_ot1_f_sets-vrkme = gt_vrkme-meinh.
      pet_ot1_f_sets-init  = 'X'.
      pet_ot1_f_sets-datum = pi_erstdat.
      append pet_ot1_f_sets.
    endloop. " at gt_vrkme.
  endloop. " at t_filia_matnr.


* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_wlk1
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Umsortieren der Filialgruppentabelle.
    sort pit_filia_group by group kunnr.

*   Betrachte Neulistungen von Artikeln.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_wlk1.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_wlk1.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WLK1: Listungskonditionen, Materialstamm.
        when 'WLK1'.
*         Nur Neulistungen müssen überprüft werden.
          if pit_pointer-cdchgid = c_insert.
            refresh: t_ot1.
            clear: pet_ot1_f_sets, t_ot1, i_wlk1.

*           Fülle den Schlüssel für WLK1.
            i_wlk1 = pit_pointer-tabkey.

*           Besorge die Filialen welche dieses Sortiment nutzen.
            refresh: t_assortment_users.
            call function 'ASSORTMENT_GET_USERS_OF_1ASORT'
                 exporting
                      asort                      = i_wlk1-filia
                      valid_per_date         = sy-datum
                      date_to                   = max_datum
                 tables
                      assortment_users           = t_assortment_users
                 exceptions
                      no_asort_to_select         = 1
                      no_user_found              = 2
                      others                     = 3.

            if sy-subrc <> 0.
              continue.
            endif.

*           Prüfe, welche Filialen in der gerade
*           bearbeiteten Filialgruppe vorkommen
            refresh: t_filia_group_temp.
            loop at t_assortment_users.
*             Prüfe, ob diese Filiale in der gerade
*             bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*             dürfen berücksichtigt werden.
              read table pit_filia_group with key
                   group = h_group
                   kunnr = t_assortment_users-locnr
                   binary search.

*             Diese Filiale muß berücksichtigt werden.
              if sy-subrc = 0.
                append pit_filia_group to t_filia_group_temp.
              endif. " sy-subrc = 0.
            endloop. " at t_assortment_users.

*           Prüfe, ob noch eine Filiale aus dieser Gruppe übrig
*           geblieben ist.
            read table t_filia_group_temp index 1.

*           Falls keine Filiale aus dieser Gruppe übrig geblieben ist,
*           keine weitere Aufbereitung nötig.
            if sy-subrc <> 0.
              continue.
            endif. " sy-subrc <> 0.

*           Restauriere Schlüssel für WLK1.
            i_wlk1 = pit_pointer-tabkey.

*           Besorge die MARA-Daten des Artikels.
            perform mara_select using mara
                                      i_wlk1-artnr.

            if mara-matnr <> space.
*             Falls der Artikel ein Set-Artikel ist.
              if mara-attyp = c_setartikel.
*               Analyse des WLK1-Pointers.
                perform wlk1_pointer_analyse
                             tables t_ot1
                                    pet_artdel
                                    t_filia_group_temp
                             using  pit_pointer
                                    pi_erstdat.

*               Übernahme der Daten in Ausgabetabellen.
                append lines of t_ot1 to pet_ot1_f_sets.
              endif. " mara-attyp = c_setartikel.
            endif. " mara-matnr <> space.
          endif. " pit_pointer-cdchgid = c_insert.
      endcase.                           " PIT_POINTER-TABNAME
    endloop.                             " AT PIT_POINTER

    if sy-subrc = 0.
*     Resortieren der Filialgruppentabelle.
      sort pit_filia_group by group filia.
    endif. " sy-subrc = 0.
  endif. " sy-subrc = 0.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_betrieb
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen in den Zuordnungen Filiale <--> Warengruppe.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_betrieb.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_betrieb.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WRF6: Zuordng. Filiale <--> Warengruppen.
        when 'WRF6'.
*         Falls eine Warengruppe einer Filiale zugeordnet wurde.
          if pit_pointer-cdchgid = c_insert.
*           Zuordnung wurde neu eingefügt.
            if pit_pointer-fldname = 'KEY'.
              i_wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = i_wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = i_wrf6-locnr
                  pi_warengruppe = i_wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist aber
*             von der Versendung ausgeschlossen werden soll, dann
*             müssen zu allen Nachzugsartikeln die dieser Warengruppe
*             zugeordnet sind Löschsätze erzeugt werden.
              if sy-subrc = 0 and t_wrf6-wdaus <> space.
*               Besorge zunächst alle Artikelnummern, die dieser
*               Warengruppe zugeordnet sind.
                perform mara_by_matkl_select tables t_matnr
                                             using  t_wrf6-matkl.

*               Besorge die zugehörigen Verkaufsmengeneinheiten
*               und Haupt-EAN's.
                perform marm_select tables t_matnr
                                           t_marm_data
                                    using  'X'   ' '   ' '.

                loop at t_marm_data.
*                 Prüfe, ob es sich bei dem Artikel um einen
*                 Nachzugsartikel handelt.
                  perform mara_select using mara
                                            t_marm_data-matnr.

*                 Falls es nicht sich um einen Setartikel handelt,
*                 dann weiter zur nächsten Artikelnummer.
                  if mara-attyp <> c_setartikel.
                    continue.
                  endif. "  mara-attyp <> c_setartikel.

*                 Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                  read table pet_artdel with key
                       artnr = t_marm_data-matnr
                       vrkme = t_marm_data-meinh
                       datum = pi_erstdat
                       binary search.

*                 Falls noch kein Löschmerker erzeugt wurde.
                  if sy-subrc <> 0.
                    tabix = sy-tabix.

*                   Prüfe, ob EAN bereits gemerkt wurde.
                    clear: gt_old_ean_set.
                    read table gt_old_ean_set with key
                               artnr = t_marm_data-matnr
                               vrkme = t_marm_data-meinh
                               datum = pi_erstdat
                               binary search.

*                   Falls die EAN noch nicht zwischengespeichert wurde,
*                   dann nehme die aktuelle EAN aus DB.
                    if sy-subrc <> 0.
                      pet_artdel-ean = t_marm_data-ean11.

*                   Falls die EAN schon zwischengespeichert wurde
*                   d.h. eine EAN-Änderung vor Einfügen der Zuordnung
*                   Filial <--> Warengruppe stattgefunden hat, dann
*                   übernehme die alte EAN.
                    else. " sy-subrc = 0.
                      pet_artdel-ean = gt_old_ean_set-ean11.
                    endif. " sy-subrc <> 0.

*                   Abspeichern des Schlüssels zum Aufbau des
*                   Löschsatzes.
                    pet_artdel-artnr = t_marm_data-matnr.
                    pet_artdel-vrkme = t_marm_data-meinh.
                    pet_artdel-datum = pi_erstdat.
                    insert pet_artdel index tabix.
                  endif. " sy-subrc <> 0.            PET_ARTDEL

*                 Fülle Objekttabelle 1 (filialabhängig).
                  clear: pet_ot1_f_sets.
                  pet_ot1_f_sets-filia    = pit_filia_group-filia.
                  pet_ot1_f_sets-artnr    = t_marm_data-matnr.
                  pet_ot1_f_sets-vrkme    = t_marm_data-meinh.
                  pet_ot1_f_sets-datum    = pi_erstdat.
                  pet_ot1_f_sets-upd_flag = c_del.
                  append pet_ot1_f_sets.

                endloop. " at t_marm_data.
              endif. " sy-subrc = 0 and t_wrf6-wdaus <> space.
            endif.                       " PIT_POINTER-FLDNAME = 'KEY'.

*         Falls das WDAUS-Flag der Zuordnung Filiale <--> Warengruppe
*         verändert wurde.
          elseif pit_pointer-cdchgid = c_update.
*           WDAUS-Flag wurde verändert.
            if pit_pointer-fldname = 'WDAUS'.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = wrf6-locnr
                  pi_warengruppe = wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist.
              if sy-subrc = 0.
*               Besorge zunächst alle Artikelnummern, die dieser
*               Warengruppe zugeordnet sind.
                perform mara_by_matkl_select tables t_matnr
                                             using  t_wrf6-matkl.

*               Besorge die zugehörigen Verkaufsmengeneinheiten
*               und Haupt-EAN's.
                perform marm_select tables t_matnr
                                           t_marm_data
                                    using  'X'   ' '   ' '.

                loop at t_marm_data.
*                 Prüfe, ob es sich bei dem Artikel um einen
*                 Setartikel handelt.
                  perform mara_select using mara
                                            t_marm_data-matnr.

*                 Falls es nicht sich um einen Nachzugsartikel handelt,
*                 dann weiter zur nächsten Artikelnummer.
                  if mara-attyp <> c_setartikel.
                    continue.
                  endif. "  mara-attyp <> c_setartikel.

                  clear: pet_ot1_f_sets.

*                 Falls die Warengruppe dieser Filiale zugeordnet ist
*                 aber von der Versendung ausgeschlossen werden soll,
*                 dann müssen zu allen Artikelnummern die dieser
*                 Warengruppe zugeordnet sind Löschsätze erzeugt
*                 werden.
                  if t_wrf6-wdaus <> space.
*                   Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                    read table pet_artdel with key
                         artnr = t_marm_data-matnr
                         vrkme = t_marm_data-meinh
                         datum = pi_erstdat
                         binary search.

*                   Falls noch kein Löschmerker erzeugt wurde.
                    if sy-subrc <> 0.
                      tabix = sy-tabix.

*                     Prüfe, ob EAN bereits gemerkt wurde.
                      clear: gt_old_ean_set.
                      read table gt_old_ean_set with key
                                 artnr = t_marm_data-matnr
                                 vrkme = t_marm_data-meinh
                                 datum = pi_erstdat
                                 binary search.

*                     Falls die EAN noch nicht zwischengespeichert
*                     wurde, dann nehme die aktuelle EAN aus DB.
                      if sy-subrc <> 0.
                        pet_artdel-ean = t_marm_data-ean11.

*                     Falls die EAN schon zwischengespeichert wurde
*                     d.h. eine EAN-Änderung vor Einfügen der Zuordnung
*                     Filial <--> Warengruppe stattgefunden hat, dann
*                     übernehme die alte EAN.
                      else. " sy-subrc = 0.
                        pet_artdel-ean = gt_old_ean_set-ean11.
                      endif. " sy-subrc <> 0.

*                     Abspeichern des Schlüssels zum Aufbau des
*                     Löschsatzes.
                      pet_artdel-artnr = t_marm_data-matnr.
                      pet_artdel-vrkme = t_marm_data-meinh.
                      pet_artdel-datum = pi_erstdat.
                      insert pet_artdel index tabix.
                    endif. "  sy-subrc <> 0.               PET_ARTDEL

*                   Setze Löschmerker zum späteren Löschen.
                    pet_ot1_f_sets-upd_flag = c_del.

*                 Falls die Warengruppe dieser Filiale zugeordnet ist
*                 und nicht mehr von der Versendung ausgeschlossen
*                 wird, dann müssen alle Artikel die dieser
*                 Warengruppe zugeordnet sind neu initialisiert werden.
                  else. " t_wrf6-wdaus = space.
*                   Setze Initialisierungsmerker zum späteren
*                   Initialisieren.
                    pet_ot1_f_sets-init = 'X'.
                  endif. " t_wrf6-wdaus <> space.

*                 Fülle die restlichen Felder in Objekttabelle 1
*                 (filialabhängig).
                  pet_ot1_f_sets-filia = pit_filia_group-filia.
                  pet_ot1_f_sets-artnr = t_marm_data-matnr.
                  pet_ot1_f_sets-vrkme = t_marm_data-meinh.
                  pet_ot1_f_sets-datum = pi_erstdat.
                  append pet_ot1_f_sets.

                endloop. " at t_marm_data.
              endif. " sy-subrc = 0.
            endif.                    " PIT_POINTER-FLDNAME = 'WDAUS'.
          endif.                 " pit_pointer-cdchgid = c_insert.

      endcase.                           " PIT_POINTER-TABNAME.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.

************************************************************************
* Funktionsexit für kundendefinierte Änderungszeigeranalyse.
  call customer-function '010'
       exporting
            pi_erstdat       = pi_erstdat
            pi_datp4         = pi_datp4
       tables
            pit_filia_group  = pit_filia_group
            pit_pointer      = pit_pointer
            pet_ot1_f_sets   = pet_ot1_f_sets
            pet_ot2_sets     = pet_ot2_sets.
************************************************************************

* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Sortieren der Daten.
  sort pet_ot1_f_sets by  filia artnr vrkme init descending datum
                                upd_flag.
  sort pet_ot2_sets   by        artnr vrkme init descending datum
                                upd_flag.

* Lösche überflüssige Einträge aus Tabelle PET_OT1_F_SETS.
  clear: i_key5, i_key6, h_init, h_datum.
  loop at pet_ot1_f_sets
       where upd_flag = space.
    move-corresponding pet_ot1_f_sets to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      clear: h_init.
      if pet_ot1_f_sets-init <> space.
        h_init = 'X'.
        h_datum = pet_ot1_f_sets-datum.
      endif.                           " PET_OT1_F_SETS-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key5 = i_key6 and h_init <> space and
           pet_ot1_f_sets-datum >= h_datum.
      delete pet_ot1_f_sets.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT1_F_SETS.

* Lösche überflüssige Einträge aus Tabelle PET_OT2_SETS.
  clear: i_key7, i_key8, h_init, h_datum.
  loop at pet_ot2_sets
       where upd_flag = space.
    move-corresponding pet_ot2_sets to i_key8.
    if i_key7 <> i_key8.
      i_key7 = i_key8.
      clear: h_init.
      if pet_ot2_sets-init <> space.
        h_init = 'X'.
        h_datum = pet_ot2_sets-datum.
      endif.                           " PET_OT2_SETS-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden, mit Ausnahme von Löschsätzen.
    elseif i_key7 = i_key8 and h_init <> space and
           pet_ot2_sets-datum >= h_datum.
      delete pet_ot2_sets.
    endif.                             " I_KEY7 <> I_KEY8.
  endloop.                             " AT PET_OT2_SETS.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT1_F_SETS.
  delete adjacent duplicates from pet_ot1_f_sets
         comparing all fields.

* Lösche doppelte Einträge aus PET_OT2_SETS.
  delete adjacent duplicates from pet_ot2_sets
         comparing all fields.

* Komprimierung Stufe 3: Berücksichtige Löscheinträge.
* Sortieren der Daten.
  sort pet_ot2_sets by artnr vrkme upd_flag descending datum.

* Lösche überflüssige Einträge aus Tabelle PET_OT2_SETS.
  clear: i_key7, i_key8, h_delete, h_datum.
  loop at pet_ot2_sets.
    move-corresponding pet_ot2_sets to i_key8.
    if i_key7 <> i_key8.
      i_key7 = i_key8.
      clear: h_delete.
      if pet_ot2_sets-upd_flag <> space.
        h_delete = 'X'.
        h_datum = pet_ot2_sets-datum.
      endif.                           " PET_OT2_SETS-UPD_FLAG <> SPACE.
*   Falls bereits eine Löschung der Stückliste ab einem Datum
*   stattfinden soll, dann kann zum selben Zeitpunkt oder später kein
*   Satz verschickt werden.
    elseif i_key7 = i_key8 and h_delete <> space and
           pet_ot2_sets-datum >= h_datum.
      delete pet_ot2_sets.
    endif.                             " I_KEY7 <> I_KEY8.
  endloop.                             " AT PET_OT2_SETS.

* Resortieren der Daten.
  sort pet_ot2_sets by artnr vrkme datum.


endform.                               " ARTSTM_SETS_POINTER_ANALYSE


*eject
************************************************************************
form nart_pointer_analyse
     tables pit_pointer     structure bdcp
            pit_filia_group structure gt_filia_group
            pet_artdel      structure gt_artdel
            pet_ot1_f_nart  structure gt_ot1_f_nart
            pet_ot2_nart    structure gt_ot2_nart
     using  pi_erstdat      like syst-datum
            pi_datp3        like syst-datum
            pi_datp4        like syst-datum.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabellen PET_OT1_F_NART (filialabhängig)
* und PET_OT2_NART (filialunabhängig).
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER     : Tabelle der zu analysierenden Änderungspointer.

* PIT_FILIA_GROUP : Tabelle für Filialkonstanten der Gruppe.

* PET_ARTDEL      : Tabelle für zu löschende Artikel.

* PET_OT1_F_NART  : Nachzugsartikel: Objekttabelle 1, filialabhängig.

* PET_OT2_NART    : Nachzugsartikel: Objekttabelle 2, filialunabhängig.

* PI_ERSTDAT      : Datum: jetziges Versenden.

* PI_DATP3        : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4        : Datum: jetziges Versenden + Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  types:  BEGIN OF wlk1_key,
           mandt TYPE mandt,
           filia TYPE asort,
           artnr TYPE matnr,
           vrkme TYPE vrkme,
           datbi TYPE datbi,
           lfdnr TYPE lfdnr,
         END OF wlk1_key,

  BEGIN OF wrf6_key,
           mandt TYPE mandt,
           LOCNR TYPE kunnr,
           MATKL TYPE MATKL,

         END OF wrf6_key.


  data: i_wrf6 type wrf6_key.
  data: i_wlk1 type wlk1_key.



  data: h_init,
        h_datum  like sy-datum,
        h_datum2 like sy-datum,
        tabix    like sy-tabix,
        h_tabix  like sy-tabix,
        h_group  like gt_filia_group-group,
        found.


* Zum Komprimieren von Tabelle PET_OT1_F_NART (Stufe 1).
  data: begin of i_key5,
          filia like pet_ot1_f_nart-filia,
          artnr like pet_ot1_f_nart-artnr,
          vrkme like pet_ot1_f_nart-vrkme.
  data: end of i_key5.

* Zum Komprimieren von Tabelle PET_OT1_F_NART (Stufe 1).
  data: begin of i_key6.
          include structure i_key5.
  data: end of i_key6.

* Zum Komprimieren von Tabelle PET_OT2_NART (Stufe 1).
  data: begin of i_key7,
          artnr like pet_ot2_nart-artnr,
          vrkme like pet_ot2_nart-vrkme.
  data: end of i_key7.

* Zum Komprimieren von Tabelle PET_OT2_NART (Stufe 1).
  data: begin of i_key8.
          include structure i_key7.
  data: end of i_key8.

  data: t_filia_matnr like gt_filia_matnr_buf occurs 0
                                              with header line.

* Temporärtabelle für Filialen.
  data: begin of t_filia occurs 5,
          filia like t001w-werks.
  data: end of t_filia.

* Temporärtabelle für filialabhängige Änderungen.
  data: begin of t_ot1 occurs 0.
          include structure gt_ot1_f_artstm.
  data: end of t_ot1.

* Tabelle für Zugriff auf übergeordnete Baugruppen (Nachzugsartikel)
  data: begin of t_nart occurs 5.
          include structure rmgw2wu.
  data: end of t_nart.

* Tabelle für übergeordnete Baugruppen (Nachzugsartikel)
  data: begin of t_matcat occurs 5.
          include structure cscmat.
  data: end of t_matcat.

* Tabelle für alle Artikelnummern.
  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.

* Kopftabelle für Nachzugsartikel
  data: begin of t_mast occurs 5.
          include structure mast.
  data: end of t_mast.

* Kopftabelle für Nachzugsartikel
  data: begin of t_mastb occurs 5.
          include structure mastb.
  data: end of t_mastb.

* Positionstabelle für Nachzugsartikel.
  data: begin of t_stpo occurs 5.
          include structure stpob.
  data: end of t_stpo.

* Tabelle für Stücklistenalternativen.
  data: begin of t_stas occurs 5.
          include structure stas.
  data: end of t_stas.

  data: begin of t_wrf6 occurs 2.
          include structure wrf6.
  data: end of t_wrf6.

* Tabelle für alle zugehörigen MARM-Daten
  data: begin of t_marm_data  occurs 0.
          include structure gt_marm_buf.
  data: end of t_marm_data.

* Tabelle für WLK2-Sätze.
  data: begin of t_wlk2 occurs 1.
          include structure wlk2.
  data: end of t_wlk2.

* Tabelle für Nutzer eines Sortiments
  data: begin of t_assortment_users occurs 0.
          include structure wrsz.
  data: end of t_assortment_users.

* Temporärtabelle mit den Daten einer Filiale.
  data: begin of t_filia_group_temp occurs 0.
          include structure gt_filia_group.
  data: end of t_filia_group_temp.

  data: max_datum like sy-datum value '99991231'.

* Bestimme die Nummer der gerade bearbeiteten Filialgruppe.
  read table pit_filia_group index 1.
  h_group = pit_filia_group-group.

  refresh: pet_ot1_f_nart, pet_ot2_nart.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_mat_full
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Materialstammänderungen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_mat_full.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_mat_full.

      clear: pet_ot2_nart.

      case pit_pointer-tabname.
*       Änderungen in Tabelle MARA: Materialstamm
        when 'MARA'.
*         Material soll geändert werden.
          if pit_pointer-cdchgid = c_update.
            mara-matnr = pit_pointer-cdobjid.

*           Die Haupt-EAN zur Basismengeneinheit hat sich geändert.
            if pit_pointer-fldname = 'EAN11'.
*             Besorge die MARA-Daten des Artikels.
              perform mara_select using mara
                                        mara-matnr.

              if mara-matnr <> space.
*               Falls der Artikel ein Nachzugsartikel ist, dann erzeuge
*               Lösch-Eintrag für alte EAN und übernehme Artikel in
*               Objekttabelle.
                if mara-mlgut <> space.
*                 Bestimme die Intervalle, auf die sich die
*                 Änderung bezieht.
                  refresh: gt_nart_komp.
                  h_datum = pit_pointer-acttime(8).
                  call function 'MGW0_PACKAGING_COMPONENTS'
                    EXPORTING
                      mgw0_article    = mara-matnr
                      mgw0_date_from  = h_datum
                      mgw0_date_to    = pi_datp4
                      mgw0_plant      = '    '
                      mgw0_unit       = mara-meins
                    TABLES
                      mgw0_components = gt_nart_komp
                    EXCEPTIONS
                      not_found       = 01.

                  loop at gt_nart_komp.
*                   Das Intervall liegt innerhalb des Betrachtungs-
*                   zeitraums (ab Materialänderung gerechnet)
*                   und muß deshalb berücksichtigt werden.
                    if gt_nart_komp-datuv <= pi_datp4  and
                       gt_nart_komp-datub >= pit_pointer-acttime(8).
*                     Falls der Beginn des Intervalls vor dem Zeitpunkt
*                     der Materialänderung liegt, dann setze ihn auf
*                     diesen Zeitpunkt.
                      if gt_nart_komp-datuv < pit_pointer-acttime(8).
                        gt_nart_komp-datuv = pit_pointer-acttime(8).
                      endif.

*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_nart-datum = gt_nart_komp-datuv.
                      pet_ot2_nart-artnr = mara-matnr.
                      pet_ot2_nart-vrkme = mara-meins.
                      clear: pet_ot2_nart-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if gt_nart_komp-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                        pet_ot2_nart-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.
                        clear: pet_ot2_nart-init.
                      endif. " GT_NART_KOMP-DATUV < PI_DATP3 AND ...

*                     Falls das Beginndatum des Zeitraums in der
*                     Vergangenheit liegt, dann muß immer
*                     Initialisiert werden.
                      if gt_nart_komp-datuv < pi_erstdat.
                        pet_ot2_nart-init  = 'X'.
                        pet_ot2_nart-datum = pi_erstdat.
                      endif.         " GT_NART_KOMP-DATUV < PI_ERSTDAT

*                     Merken des ersten Gültigkeitsdatums des Sets.
                      if sy-tabix = 1.
                        h_datum2 = pet_ot2_nart-datum.
                      endif. " sy-tabix = 1.

                      append pet_ot2_nart.

                    endif. " GT_NART_KOMP-DATUV <= PI_DATP4  and ...
                  endloop.               " AT GT_NART_KOMP.

*                 Falls Komponenten gefunden wurden.
                  if sy-subrc = 0.
*                   Besorge alte Haupt-EAN, falls nötig.
                    h_datum = pit_pointer-acttime(8).
                    h_datum = h_datum - 1.

*                   Falls die Änderung in der Vergangenheit liegt, dann
*                   bestimme alte EAN aus Änderungsbeleg, falls nötig.
                    if h_datum < sy-datum.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      clear: gt_old_ean_nart.
                      read table gt_old_ean_nart with key
                                 artnr = mara-matnr
                                 vrkme = mara-meins
                                 datum = h_datum2
                                 binary search.

*                    Die alte EAN wurde noch nicht zwischengespeichert.
                      if sy-subrc <> 0.
                        tabix = sy-tabix.

*                       Besorge alte Haupt-EAN aus Änderungsbeleg.
                        perform old_value_get
                                    using pit_pointer
                                          gt_old_ean_nart-ean11
                                          found.

*                       Falls die alte EAN ermittelt werden konnte und
*                       sie <> SPACE ist.
                        if found = space.
*                         Abspeichern der EAN zur späteren Analyse.
                          gt_old_ean_nart-artnr = mara-matnr.
                          gt_old_ean_nart-vrkme = mara-meins.
                          gt_old_ean_nart-datum = h_datum2.

*                         Besorge alten EAN-Typ aus Änderungsbeleg.
                          gi_pointer         = pit_pointer.
                          gi_pointer-fldname = 'NUMTP'.

                          perform old_value_get
                                      using gi_pointer
                                            gt_old_ean_nart-numtp
                                            found.

                          insert gt_old_ean_nart index tabix.
                        endif. " found = space.
                      endif. " sy-subrc <> 0.
                    endif. " h_datum < sy-datum.
                  endif. " sy-subrc = 0.
                endif.                   " MARA-MLGUT <> SPACE.

*               Prüfe, ob der Artikel eine Stckl-Komponente ist.
                refresh: t_nart.
                h_datum = pit_pointer-acttime(8).

                call function 'MGW0_WHERE_USED_COMPONENTS'
                  EXPORTING
                    mgw0_matnr          = mara-matnr
                    mgw0_datuv          = h_datum
                    mgw0_datub          = pi_datp4
                    mgw0_stlan          = ' '
                    mgw0_werks          = ' '
                    mgw0_postp          = ' '
                  TABLES
                    structured_articles = t_nart.

*               Überprüfe die übergeordneten Artikel.
                loop at t_nart.
*                 Das Intervall liegt innerhalb des Betrachtungs-
*                 zeitraums (ab Materialänderung gerechnet)
*                 und muß deshalb berücksichtigt werden.
                  if t_nart-datuv <= pi_datp4  and
                     t_nart-datub >= pit_pointer-acttime(8).
*                   Falls der Beginn des Intervalls vor dem Zeitpunkt
*                   der Materialänderung liegt, dann setze ihn auf
*                   diesen Zeitpunkt.
                    if t_nart-datuv < pit_pointer-acttime(8).
                      t_nart-datuv = pit_pointer-acttime(8).
                    endif. " T_NART-DATUV < PIT_POINTER-ACTTIME(8).

*                   Besorge die Basismengeneinheit des Artikels.
                    perform mara_select using mara
                                              t_nart-matnr.

*                   Nur Nachzugsartikel werden berücksichtigt.
                    if mara-matnr <> space and mara-mlgut <> space.
*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_nart-vrkme = t_nart-meins.
                      pet_ot2_nart-datum = t_nart-datuv.
                      pet_ot2_nart-artnr = t_nart-matnr.
                      clear: pet_ot2_nart-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if t_nart-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                        pet_ot2_nart-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.              " T_NART-DATUV >= PI_DATP3.
                        clear: pet_ot2_nart-init.
                      endif.             " T_NART-DATUV < PI_DATP3...

*                     Falls das Beginndatum des Zeitraums in der
*                     Vergangenheit liegt, dann muß immer
*                     Initialisiert werden.
                      if t_nart-datuv < pi_erstdat.
                        pet_ot2_nart-init  = 'X'.
                        pet_ot2_nart-datum = pi_erstdat.
                      endif.             " T_NART-DATUV < PI_ERSTDAT

                      append pet_ot2_nart.
                    endif. " mara-matnr <> space and mara-mlgut <> space
                  endif. " GT_NART_KOMP-DATUV <= PI_DATP4  AND ...
                endloop.               " AT T_NART.
              endif.                   " mara-matnr <> space
            endif.                     " PIT_POINTER-FLDNAME = 'EAN11'.
          endif.                       " PIT_POINTER-CDCHGID = C_UPDATE.

*       Änderungen der Haupt-EAN in Tabelle MARM.
        when 'DMARM'.
*         Material soll geändert werden.
          if pit_pointer-cdchgid = c_update.
            marm-matnr = pit_pointer-cdobjid.
            marm-meinh = pit_pointer-tabkey.

*           Die Haupt-EAN zur Mengeneinheit hat sich geändert.
            if pit_pointer-fldname = 'EAN11'.
*             Besorge die MARA-Daten des Artikels.
              perform mara_select using mara
                                        marm-matnr.

              if mara-matnr <> space.
*               Falls der Artikel ein Nachzugsartikel ist, dann erzeuge
*               Lösch-Eintrag für alte EAN und übernehme Artikel in
*               Objekttabelle.
                if mara-mlgut <> space.
*                 Bestimme die Intervalle, auf die sich die
*                 Änderung bezieht.
                  refresh: gt_nart_komp.
                  h_datum = pit_pointer-acttime(8).
                  call function 'MGW0_PACKAGING_COMPONENTS'
                    EXPORTING
                      mgw0_article    = marm-matnr
                      mgw0_date_from  = h_datum
                      mgw0_date_to    = pi_datp4
                      mgw0_plant      = '    '
                      mgw0_unit       = marm-meinh
                    TABLES
                      mgw0_components = gt_nart_komp
                    EXCEPTIONS
                      not_found       = 01.

                  loop at gt_nart_komp.
*                   Das Intervall liegt innerhalb des Betrachtungs-
*                   zeitraums (ab Materialänderung gerechnet)
*                   und muß deshalb berücksichtigt werden.
                    if gt_nart_komp-datuv <= pi_datp4  and
                       gt_nart_komp-datub >= pit_pointer-acttime(8).
*                     Falls der Beginn des Intervalls vor dem Zeitpunkt
*                     der Materialänderung liegt, dann setze ihn auf
*                     diesen Zeitpunkt.
                      if gt_nart_komp-datuv < pit_pointer-acttime(8).
                        gt_nart_komp-datuv = pit_pointer-acttime(8).
                      endif.

*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_nart-datum = gt_nart_komp-datuv.
                      pet_ot2_nart-artnr = marm-matnr.
                      pet_ot2_nart-vrkme = marm-meinh.
                      clear: pet_ot2_nart-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if gt_nart_komp-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                        pet_ot2_nart-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.
                        clear: pet_ot2_nart-init.
                      endif. " GT_NART_KOMP-DATUV < PI_DATP3 AND ...

*                     Falls das Beginndatum des Zeitraums in der
*                     Vergangenheit liegt, dann muß immer
*                     Initialisiert werden.
                      if gt_nart_komp-datuv < pi_erstdat.
                        pet_ot2_nart-init  = 'X'.
                        pet_ot2_nart-datum = pi_erstdat.
                      endif.           " GT_NART_KOMP-DATUV < PI_ERSTDAT

*                     Merken des ersten Gültigkeitsdatums des Sets.
                      if sy-tabix = 1.
                        h_datum2 = pet_ot2_nart-datum.
                      endif. " sy-tabix = 1.

                      append pet_ot2_nart.

                    endif. " GT_SET_KOMP-DATUV <= PI_DATP4  AND ...
                  endloop.               " AT GT_SET_KOMP.

*                 Falls Komponenten gefunden wurden.
                  if sy-subrc = 0.
*                   Besorge alte Haupt-EAN, falls nötig.
                    h_datum = pit_pointer-acttime(8).
                    h_datum = h_datum - 1.

*                   Falls die Änderung in der Vergangenheit liegt, dann
*                   bestimme alte EAN aus Änderungsbeleg, falls nötig.
                    if h_datum < sy-datum.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      clear: gt_old_ean_nart.
                      read table gt_old_ean_nart with key
                                 artnr = marm-matnr
                                 vrkme = marm-meinh
                                 datum = h_datum2
                                 binary search.

*                    Die alte EAN wurde noch nicht zwischengespeichert.
                      if sy-subrc <> 0.
                        tabix = sy-tabix.

*                       Besorge alte Haupt-EAN aus Änderungsbeleg.
                        perform old_value_get
                                    using pit_pointer
                                          gt_old_ean_nart-ean11
                                          found.

*                       Falls die alte EAN ermittelt werden konnte und
*                       sie <> SPACE ist.
                        if found = space.
*                         Abspeichern der EAN zur späteren Analyse.
                          gt_old_ean_nart-artnr = marm-matnr.
                          gt_old_ean_nart-vrkme = marm-meinh.
                          gt_old_ean_nart-datum = h_datum2.

*                         Besorge alten EAN-Typ aus Änderungsbeleg.
                          gi_pointer         = pit_pointer.
                          gi_pointer-fldname = 'NUMTP'.

                          perform old_value_get
                                      using gi_pointer
                                            gt_old_ean_nart-numtp
                                            found.

                          insert gt_old_ean_nart index tabix.
                        endif. " found = space.
                      endif. " sy-subrc <> 0.
                    endif. " h_datum < sy-datum.
                  endif. " sy-subrc = 0.
                endif.                   " MARA-MLGUT <> SPACE.

*               Prüfe, ob der Artikel Teil einer Stückliste ist.
                refresh: t_nart.
                h_datum = pit_pointer-acttime(8).
                call function 'MGW0_WHERE_USED_COMPONENTS'
                  EXPORTING
                    mgw0_matnr          = marm-matnr
                    mgw0_datuv          = h_datum
                    mgw0_datub          = pi_datp4
                    mgw0_stlan          = ' '
                    mgw0_werks          = ' '
                    mgw0_postp          = ' '
                  TABLES
                    structured_articles = t_nart.

*               Überprüfe die übergeordneten Artikel.
                loop at t_nart.
*                 Das Intervall liegt innerhalb des Betrachtungs-
*                 zeitraums (ab Materialänderung gerechnet)
*                 und muß deshalb berücksichtigt werden.
                  if t_nart-datuv <= pi_datp4  or
                     t_nart-datub >= pit_pointer-acttime(8).
*                   Falls der Beginn des Intervalls vor dem Zeitpunkt
*                   der Materialänderung liegt, dann setze ihn auf
*                   diesen Zeitpunkt.
                    if t_nart-datuv < pit_pointer-acttime(8).
                      t_nart-datuv = pit_pointer-acttime(8).
                    endif. " T_NART-DATUV < PIT_POINTER-ACTTIME(8).

*                   Besorge die Basismengeneinheit des Artikels.
                    perform mara_select using mara
                                              t_nart-matnr.

*                   Nur Nachzugsartikel werden berücksichtigt.
                    if mara-matnr <> space and mara-mlgut <> space.
*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_nart-vrkme = t_nart-meins.
                      pet_ot2_nart-datum = t_nart-datuv.
                      pet_ot2_nart-artnr = t_nart-matnr.
                      clear: pet_ot2_nart-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if t_nart-datuv < pi_datp3 and
                        pit_filia_group-zvdat = space.
                        pet_ot2_nart-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.              " T_NART-DATUV >= PI_DATP3.
                        clear: pet_ot2_nart-init.
                      endif.             " T_NART-DATUV < PI_DATP3...

*                     Falls das Beginndatum des Zeitraums in der
*                     Vergangenheit liegt, dann muß immer
*                     Initialisiert werden.
                      if t_nart-datuv < pi_erstdat.
                        pet_ot2_nart-init  = 'X'.
                        pet_ot2_nart-datum = pi_erstdat.
                      endif.             " T_NART-DATUV < PI_ERSTDAT

                      append pet_ot2_nart.
                    endif. " mara-matnr <> space and mara-mlgut <> space
                  endif. " GT_NART_KOMP-DATUV <= PI_DATP4  AND ...
                endloop.               " AT T_NART.
              endif.                  " mara-matnr <> space.
            endif.                     " PIT_POINTER-FLDNAME = 'EAN11'.
          endif.                       " PIT_POINTER-CDCHGID = C_UPDATE.

      endcase.                         " PIT_POINTER-TABNAME
    endloop.                           " AT PIT_POINTER
  endif. " sy-subrc = 0.

  clear: h_tabix.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_stue
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.
  else. " sy-subrc <> 0.
*   Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
    read table pit_pointer with key
         cdobjcl = c_objcl_stue_v
         binary search
         transporting no fields.

*   Falls zu diesem Änderungsbelegobjekt Werte existieren.
    if sy-subrc = 0.
      h_tabix = sy-tabix.
    endif. " sy-subrc = 0.
  endif. " sy-subrc = 0.

* Falls zu einem dieser Änderungsbelegobjekte Werte existieren.
  if h_tabix > 0.
*   Betrachte Stücklistenänderungen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_stue    and
         pit_pointer-cdobjcl <> c_objcl_stue_v.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_stue  and...

      clear: pet_ot2_nart.

      case pit_pointer-tabname.
*       Änderungen in Tabelle MAST: Materialstücklisten.
        when 'MAST'.
          mast = pit_pointer-tabkey(36).   " Unicode enabling

*         Prüfe, ob es sich um einen Nachzugsartikel handelt.
          perform mara_select using mara
                                    mast-matnr.

*         Falls es sich um einen Nachzugs-Artikel handelt.
          if mara-matnr <> space and mara-mlgut <> space.
*           Besorge den Gültigkeitsbeginn der Stückliste.
            clear: stko.
            select datuv from  stko
                   into (stko-datuv)
                   where  stlty       = c_mat_stlty
                   and    stlnr       = mast-stlnr
                   and    stlal       = mast-stlal
                   and    stkoz       = 1.
              exit.
            endselect. " from  stko


            if sy-subrc = 0.
              pet_ot2_nart-datum = stko-datuv.
            else.                          " SY-SUBRC = 0.
              pet_ot2_nart-datum = pi_erstdat.
            endif.                         " SY-SUBRC = 0.

*          Der Gültigkeitsbeginn der Stückliste muß kleiner oder gleich
*           PI_DATP4 sein.
            if pet_ot2_nart-datum <= pi_datp4.
*             Falls eine Stückliste angelegt werden soll.
              if pit_pointer-cdchgid = c_insert.
*               Besorge Mengeneinheit des Nachzugsartikels.
                if t415b-matnr <> mast-matnr or
                   t415b-stlan <> mast-stlan or
                   t415b-stlal <> mast-stlal.

                  select * from t415b
                         where matnr =  mast-matnr
                         and   stlan =  mast-stlan
                         and   stlal =  mast-stlal.
                    exit.
                  endselect.                 " * FROM T415B
                endif. " t415b-matnr <> mast-matnr or ...

*               Fülle Objekttabelle 2 (filialunabhängig).
                pet_ot2_nart-artnr = mara-matnr.
                pet_ot2_nart-vrkme = t415b-basme.
                clear: pet_ot2_nart-upd_flag.

*               Falls das POS-System keine zeitliche Verwaltung
*               von Daten kann, muß neu Initialisiert werden.
                if pet_ot2_nart-datum < pi_datp3 and
                  pit_filia_group-zvdat = space.
                  pet_ot2_nart-init = 'X'.
*               Falls das POS-System eine zeitliche Verwaltung
*               von Daten kann.
                else.               " PET_OT2_NART-DATUM >= PI_DATP3.
                  clear: pet_ot2_nart-init.
                endif. " PET_OT2_NART-DATUM < PI_DATP3...

*               Falls der Gültigkeitsbeginn der Stückliste in der
*               Vergangenheit liegt, dann muß immer Initialisiert
*               werden.
                if pet_ot2_nart-datum < pi_erstdat.
                  pet_ot2_nart-init  = 'X'.
                  pet_ot2_nart-datum = pi_erstdat.
                endif. " PIT_POINTER-ACTTIME(8) < PI_ERSTDAT.

                append pet_ot2_nart.

*             Falls eine Stückliste gelöscht werden soll.
              else.                    " PIT_POINTER-CDCHGID = C_DEL.
*               Besorge Mengeneinheit des Nachzugsartikels.
                if t415b-matnr <> mast-matnr or
                   t415b-stlan <> mast-stlan or
                   t415b-stlal <> mast-stlal.

                  select * from t415b
                         where matnr =  mast-matnr
                         and   stlan =  mast-stlan
                         and   stlal =  mast-stlal.
                    exit.
                  endselect.                 " * FROM T415B
                endif. " t415b-matnr <> mast-matnr or ...

                if sy-subrc = 0.
*                 Falls der Gültigkeitsbeginn der Stückliste in der
*                 Vergangenheit liegt, dann lösche ab heute.
                  if pet_ot2_nart-datum < pi_erstdat.
                    pet_ot2_nart-datum = pi_erstdat.
                  endif. " PET_OT2_NART-DATUM < PI_ERSTDAT.

*                 Prüfe, ob alte EAN bereits gemerkt wurde.
                  read table pet_artdel with key
                       artnr = mara-matnr
                       vrkme = t415b-basme
                       datum = pet_ot2_nart-datum
                       binary search.

                  tabix = sy-tabix.

*                 Falls die zugehörige EAN noch nicht gemerkt wurde,
*                 dann besorge EAN.
                  if sy-subrc <> 0.
*                  Bestimme die EAN vom Vortag des Löschens. Mit dieser
*                   Lösch-EAN muß der Löschsatz aufbereitet werden.
                    h_datum = pet_ot2_nart-datum  - 1.

*                   Falls die Änderung in der Vergangenheit liegt, dann
*                   prüfe, ob Haupt-EAN bis Heute geändert wurde.
                    if h_datum < sy-datum.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      clear: gt_old_ean.
                      read table gt_old_ean with key
                                 artnr = mara-matnr
                                 vrkme = t415b-basme
                                 datum = sy-datum
                                 binary search.

                      if sy-subrc = 0.
                        g_loesch_ean = gt_old_ean-ean11.

*                     Falls die Haupt-EAN nicht verändert wurde,
*                     dann besorge aktuelle EAN.
                      else. " sy-subrc = 0.
*                       Falls es sich um die Basismengeneinheit
*                       handelt, dann hole Daten aus MARA.
                        if mara-meins = t415b-basme.
                          g_loesch_ean = mara-ean11.
*                       Falls es sich nicht um die Basismengen-
*                       einheit handelt, dann hole Daten aus MARM.
                        else. " mara-meins <> t415b-basme.
                          refresh: t_matnr.
                          perform marm_select tables t_matnr
                                                     t_marm_data
                                              using  'X'
                                                     mara-matnr
                                                     t415b-basme.
                          read table t_marm_data index 1.
                          g_loesch_ean = t_marm_data-ean11.
                        endif. " mara-meins = t415b-basme.
                      endif. " sy-subrc = 0.

*                   Falls die Änderung in der Zukunft liegt, dann
*                   hole Haupt-EAN vom Vortag des Löschens.
                    else. " h_datum >= sy-datum.
                      perform ean_by_date_get
                                  using mara-matnr  t415b-basme
                                        h_datum     g_loesch_ean
                                        g_returncode.
                    endif. " h_datum < sy-datum.

*                   Merken der Lösch-EAN und erzeugen Lösch-Eintrag
*                   in OT.
                    if g_returncode = 0 and g_loesch_ean <> space.
                      pet_artdel-artnr = mara-matnr.
                      pet_artdel-vrkme = t415b-basme.
                      pet_artdel-ean   = g_loesch_ean.
                      pet_artdel-datum = pet_ot2_nart-datum.
                      insert pet_artdel index tabix.
                    endif. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
                  endif.                   " SY-SUBRC <> 0.

*                 Prüfe, ob Lösch-Einrag schon existiert.
                  h_datum = pet_ot2_nart-datum.
                  read table pet_ot2_nart with key
                       artnr    = mara-matnr
                       vrkme    = t415b-basme
                       init     = space
                       upd_flag = c_del
                       datum    = h_datum.

*                 Falls die Lösch-EAN noch nicht gemerkt wurde, dann
*                 merke Lösch-EAN.
                  if sy-subrc <> 0.
*                   Erzeuge Lösch-Eintrag in Objekttabelle 2
*                   (filialunabhängig).
                    pet_ot2_nart-artnr    = mara-matnr.
                    pet_ot2_nart-vrkme    = t415b-basme.
                    pet_ot2_nart-datum    = h_datum.
                    pet_ot2_nart-upd_flag = c_del.
                    clear: pet_ot2_nart-init.
                    append pet_ot2_nart.
                  endif.                   " SY-SUBRC <> 0.
                endif.                     " SY-SUBRC = 0.  T415B
              endif.               " PIT_POINTER-CDCHGID = C_INSERT.
            endif.                 " PET_OT2_NART-DATUM <= PI_DATP4.
          endif.          " mara-matnr <> space and mara-mlgut <> space.

*       Änderungen in Tabelle STPO: Stücklistenpositionen.
        when 'STPO'.
*         Stücklistenposition soll verändert werden.
          if pit_pointer-cdchgid = c_update.
            refresh: t_stpo, t_mast.
            clear:   t_stpo, t_mast.
            t_stpo = pit_pointer-tabkey(28).
            append t_stpo.

*           Falls es sich bei der Stückliste um eine Materialstückliste
*           handelt, so muß sie berücksichtigt werden.
            if t_stpo-stlty = c_mat_stlty.
*             Bestimme den Gültigkeitsbeginn der Stückliste.
              call function 'STRUC_ART_SELECT_BOM'
                EXPORTING
                  date_from    = pi_erstdat
                  date_to      = pi_datp4
                  struc_stlan  = c_nart_stlan
                TABLES
                  struc_stpo   = t_stpo
                  struc_mast   = t_mast
                EXCEPTIONS
                  invalid_key  = 1
                  no_bom_found = 2
                  others       = 3.

              if sy-subrc = 0.
                read table t_stpo index 1.

*               Der Gültigkeitsbeginn der Stückliste muß kleiner
*               PI_DATP4 sein.
                if t_stpo-datuv <= pi_datp4.

*                 Das kleinste Versendedatum ist PI_ERSTDAT.
                  if t_stpo-datuv < pi_erstdat.
                    t_stpo-datuv = pi_erstdat.
                  endif.                 " T_STPO-DATUV < PI_ERSTDAT.

                  read table t_mast index 1.

*                 Prüfe, ob es sich um einen Nachzugsartikel handelt.
                  perform mara_select using mara
                                            t_mast-matnr.

*                 Falls es sich um einen Nachzugsartikel handelt.
                  if mara-matnr <> space and mara-mlgut <> space.
*                   Besorge alle Stücklistenalternativen, in denen
*                   diese Position verwendet wird.
                    select * from stas into table t_stas
                           where stlty = t_stpo-stlty
                           and   stlnr = t_stpo-stlnr
                           and   stlkn = t_stpo-stlkn.

                    loop at t_stas.   " Es sollte nur einen Satz geben.
*                     Besorge die, dieser Alternative zugeordnete,
*                     Verkaufsmengeneinheit.
                      if t415b-matnr <> mara-matnr   or
                         t415b-stlan <> t_mast-stlan or
                         t415b-stlal <> t_stas-stlal.

                        select * from t415b
                               where matnr =  mara-matnr
                               and   stlan =  t_mast-stlan
                               and   stlal =  t_stas-stlal.
                          exit.
                        endselect.                 " * FROM T415B
                      endif. " t415b-matnr <> mara-matnr or ...

*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_nart-datum = t_stpo-datuv.
                      pet_ot2_nart-artnr = t_mast-matnr.
                      pet_ot2_nart-vrkme = t415b-basme.
                      clear: pet_ot2_nart-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if t_stpo-datuv < pi_datp3 and
                          pit_filia_group-zvdat = space.
                        pet_ot2_nart-init = 'X'.
*                     Falls das Zeitraum jetzt beginnt, dann
*                     muß immer Initialisiert werden.
                      elseif t_stpo-datuv = pi_erstdat.
                        pet_ot2_nart-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.                " T_STPO-DATUV >= PI_DATP3.
                        clear: pet_ot2_nart-init.
                      endif.               " T_STPO-DATUV < PI_DATP3...

                      append pet_ot2_nart.
                    endloop.               " AT T_STAS.
                  endif.   " mara-matnr <> space and mara-mlgut <> ...
                endif.               " T_STPO-DATUV <= PI_DATP4.
              endif.                 " SY-SUBRC = 0.
            endif.                   " T_STPO-STLTY = C_MAT_STLTY.
          endif.                     " PIT_POINTER-CDCHGID = C_UPDATE.

*       Einfügen und Löschen von Stücklistenpositionen.
        when 'CSBOM'.
*         Stücklistenposition soll eingefügt oder gelöscht werden.
          if pit_pointer-cdobjcl = c_objcl_stue_v.
            csbom = pit_pointer-cdobjid+3.

*           Falls es sich bei der Stückliste um ein Materialstückliste
*           handelt.
            if csbom-stlty = c_mat_stlty.
*             Der Gültigkeitsbeginn der Stückliste muß kleiner
*             PI_DATP4 sein.
              if csbom-datuv <= pi_datp4.

*               Das kleinste Versendedatum ist PI_ERSTDAT.
                if csbom-datuv < pi_erstdat.
                  csbom-datuv = pi_erstdat.
                endif.                   " CSBOM-DATUV < PI_ERSTDAT.

*               Bestimme den zugehörigen Artikel in Tabelle MAST.
                refresh: t_mastb.
                clear:   t_mastb.
                t_mastb-stlnr = csbom-stlnr.
                t_mastb-stlal = csbom-stlal.
                t_mastb-stlan = c_nart_stlan.
                append t_mastb.
                call function 'READ_MAST'
                  TABLES
                    wa              = t_mastb
                  EXCEPTIONS
                    key_incomplete  = 1
                    key_invalid     = 2
                    no_record_found = 3
                    others          = 4.

*               Nur, wenn Stückliste nicht gelöscht wurde muß reagiert
*               werden.
                if sy-subrc = 0.
                  read table t_mastb index 1.

*                 Prüfe, ob es sich um einen Nachzugsartikel handelt.
                  perform mara_select using mara
                                            t_mastb-matnr.

*                 Falls es sich um einen Nachzugsartikel handelt.
                  if mara-matnr <> space and mara-mlgut <> space.
*                   Besorge die, dieser Alternative zugeordnete,
*                   Verkaufsmengeneinheit.
                    if t415b-matnr <> mara-matnr   or
                       t415b-stlan <> t_mastb-stlan or
                       t415b-stlal <> csbom-stlal.

                      select * from t415b
                             where matnr =  mara-matnr
                             and   stlan =  t_mastb-stlan
                             and   stlal =  csbom-stlal.
                        exit.
                      endselect.                 " * FROM T415B
                    endif. " t415b-matnr <> mara-matnr or ...

*                   Falls Positionen eingefügt oder gelöscht wurden.
                    if csbom-csdel = space.
*                     Fülle Objekttabelle 2 (filialunabhängig).
                      pet_ot2_nart-datum = csbom-datuv.
                      pet_ot2_nart-artnr = t_mastb-matnr.
                      pet_ot2_nart-vrkme = t415b-basme.
                      clear: pet_ot2_nart-upd_flag.

*                     Falls das POS-System keine zeitliche Verwaltung
*                     von Daten kann, muß neu Initialisiert werden.
                      if csbom-datuv < pi_datp3 and
                         pit_filia_group-zvdat = space.
                        pet_ot2_nart-init = 'X'.
*                     Falls das Zeitraum jetzt beginnt, dann
*                     muß immer Initialisiert werden.
                      elseif csbom-datuv = pi_erstdat.
                        pet_ot2_nart-init = 'X'.
*                     Falls das POS-System eine zeitliche Verwaltung
*                     von Daten kann.
                      else.                " CSBOM-DATUV >= PI_DATP3.
                        clear: pet_ot2_nart-init.
                      endif.               " CSBOM-DATUV < PI_DATP3...

                      append pet_ot2_nart.

*                   Falls Stckl. ganz oder ab einem Datum
*                   gelöscht wurde.
                    elseif csbom-csdel <> space.
*                     Prüfe, ob alte EAN bereits gemerkt wurde.
                      read table pet_artdel with key
                           artnr = t_mastb-matnr
                           vrkme = t415b-basme
                           datum = csbom-datuv
                           binary search.

                      tabix = sy-tabix.

*                     Falls die zugehörige EAN noch nicht
*                     gemerkt wurde, dann besorge EAN.
                      if sy-subrc <> 0.
*                       Bestimme die EAN vom Vortag des Löschens.
*                       Mit dieser Lösch-EAN muß der Löschsatz
*                       aufbereitet werden.
                        h_datum = csbom-datuv - 1.

*                       Falls die Änderung in der Vergangenheit
*                       liegt, dann prüfe, ob Haupt-EAN bis Heute
*                       geändert wurde.
                        if h_datum < sy-datum.
*                         Prüfe, ob alte EAN bereits gemerkt wurde.
                          clear: gt_old_ean.
                          read table gt_old_ean with key
                                     artnr = mara-matnr
                                     vrkme = t415b-basme
                                     datum = sy-datum
                                     binary search.

                          if sy-subrc = 0.
                            g_loesch_ean = gt_old_ean-ean11.

*                         Falls die Haupt-EAN nicht verändert wurde,
*                         dann besorge aktuelle EAN.
                          else. " sy-subrc <> 0.
*                           Falls es sich um die Basismengeneinheit
*                           handelt, dann hole Daten aus MARA.
                            if mara-meins = t415b-basme.
                              g_loesch_ean = mara-ean11.
*                           Falls es sich nicht um die Basismengen-
*                           einheit handelt, dann hole Daten aus MARM.
                            else. " mara-meins <> t415b-basme.
                              refresh: t_matnr.
                              perform marm_select tables t_matnr
                                                         t_marm_data
                                                  using  'X'
                                                         mara-matnr
                                                         t415b-basme.
                              read table t_marm_data index 1.

                              g_loesch_ean = t_marm_data-ean11.
                            endif. " mara-meins = t415b-basme.
                          endif. " sy-subrc = 0.

*                       Falls die Änderung in der Zukunft liegt, dann
*                       hole Haupt-EAN vom Vortag des Löschens.
                        else. " h_datum >= sy-datum.
                          perform ean_by_date_get
                                      using t_mastb-matnr  t415b-basme
                                            h_datum        g_loesch_ean
                                            g_returncode.
                        endif. " h_datum < sy-datum.

*                       Merken der Lösch-EAN und erzeugen
*                       Lösch-Eintrag in OT.
                        if g_returncode = 0 and g_loesch_ean <> space.
                          pet_artdel-artnr = t_mastb-matnr.
                          pet_artdel-vrkme = t415b-basme.
                          pet_artdel-ean   = g_loesch_ean.
                          pet_artdel-datum = csbom-datuv.
                          insert pet_artdel index tabix.
                        endif. " G_RETURNCODE = 0 AND ...
                      endif.             " SY-SUBRC <> 0.

*                     Prüfe, ob Lösch-Einrag schon existiert.
                      h_datum = csbom-datuv.
                      read table pet_ot2_nart with key
                           artnr    = t_mastb-matnr
                           vrkme    = t415b-basme
                           init     = space
                           upd_flag = c_del
                           datum    = h_datum.

*                    Falls die Lösch-EAN noch nicht gemerkt wurde, dann
*                     merke Lösch-EAN.
                      if sy-subrc <> 0.
*                       Erzeuge Lösch-Eintrag in Objekttabelle 2
*                       (filialunabhängig).
                        pet_ot2_nart-artnr    = t_mastb-matnr.
                        pet_ot2_nart-vrkme    = t415b-basme.
                        pet_ot2_nart-datum    = h_datum.
                        pet_ot2_nart-upd_flag = c_del.
                        clear: pet_ot2_nart-init.
                        append pet_ot2_nart.
                      endif.             " SY-SUBRC <> 0.
                    endif.               " CSBOM-CSDEL = SPACE.
                  endif.  " mara-matnr <> space and mara-mlgut ...
                endif.                   " SY-SUBRC = 0.
              endif.                     " CSBOM-DATUV <= PI_DATP4.
            endif.                       " CSBOM-STLTY = C_MAT_STLTY
          endif. " PIT_POINTER-CDOBJCL = C_OBJCL_STUE_V

      endcase.                           " PIT_POINTER-TABNAME
    endloop.                             " AT PIT_POINTER
  endif. " h_tabix > 0.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_mat_full
       tabname = 'DWLK2'
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen in Tabelle WLK2: Bewirtschaftungszeitraum.
    loop at pit_pointer from h_tabix.

*     Zum nächsten Eintrag, wenn nicht relevant.
      if pit_pointer-fldname <> 'VKBIS'   and
         pit_pointer-fldname <> 'KEY'.
        continue.
      endif. " pit_pointer-fldname <> 'VKBIS' ...

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-tabname <> 'DWLK2'.
        exit.
      endif. " pit_pointer-tabname <> 'DWLK2'.

      clear: pet_ot1_f_nart, pet_ot2_nart, wlk2, dwlk2.

*     Fülle den Schlüssel für WLK2.
      dwlk2 = pit_pointer-tabkey(10).
      move-corresponding dwlk2 to wlk2.
      wlk2-matnr = pit_pointer-cdobjid.
      wlk2-mandt = sy-mandt.

*     Falls die falsche Vertriebslinie betroffen ist.
      if pit_filia_group-vkorg <> wlk2-vkorg  or
         pit_filia_group-vtweg <> wlk2-vtweg.
*       Gehe weiter zum nächsten Satz.
        continue.
      endif. " pit_filia_group-vkorg <> wlk2-vkorg  or ...

*     Falls Filiale bekannt.
      if not wlk2-werks is initial.
*       Prüfe, ob diese Filiale in der gerade
*       bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*       dürfen berücksichtigt werden.
        read table pit_filia_group with key
             group = h_group
             filia = wlk2-werks
             binary search.

*       Falls diese Filiale nicht in der gerade betrachteten
*       Filialgruppe enthalten ist, dann weiter zum
*       nächsten Satz.
        if sy-subrc <> 0.
          continue.
        endif.      " SY-SUBRC <> 0.
      endif. " not wlk2-werks is initial.

*     Besorge die MARA-Daten des Artikels.
      perform mara_select using mara
                                wlk2-matnr.

*     Falls der Artikel kein Nachzugsartikel ist dann weiter zum
*     nächsten Satz.
      if mara-mlgut = space.
        continue.
      endif. " mara-mlgut = space.

*     Gelöschte WLK2-Daten werden nicht berücksichtigt.
      if pit_pointer-cdchgid <> c_del.
*       Lese betroffenen WLK2-Satz.
        refresh: t_wlk2.
        call function 'WLK2_READ'
          EXPORTING
            wlk2             = wlk2
          TABLES
            wlk2_input       = t_wlk2
          EXCEPTIONS
            no_rec_found     = 01
            key_not_complete = 02.

        read table t_wlk2 index 1.

*       Falls das Bewirtschaftungsende nicht im Bereich
*       bis PI_DATP3 liegt, dann weiter zum nächsten Satz.
        if t_wlk2-vkbis >= pi_datp3.
          continue.
        endif. " t_wlk2-vkbis >= pi_datp3.

*       Bestimme alle Verkaufsmengeneinheiten des Artikels
*       aus Tabelle MARM, die eine EAN besitzen.
        refresh: t_matnr.
        append t_wlk2-matnr to t_matnr.
        perform marm_select tables t_matnr
                                   gt_vrkme
                            using  'X'   ' '   ' '.

*       Prüfe, ob VRKME's gefunden wurden.
        read table gt_vrkme index 1.

*       Falls keine VRKME's gefunden wurden.
        if sy-subrc <> 0.
*         Weiter zum nächsten Objekt.
          continue.
        endif. " sy-subrc <> 0.

*       Schleife über alle gefundenenen Verkaufsmengeneinheiten.
        loop at gt_vrkme.
*         Prüfe, ob EAN bereits gemerkt wurde.
          h_datum = t_wlk2-vkbis + 1.

          if h_datum < pi_erstdat.
            h_datum = pi_erstdat.
          endif. " h_datum < pi_erstdat.

          read table pet_artdel with key
               artnr = gt_vrkme-matnr
               vrkme = gt_vrkme-meinh
               datum = h_datum
               binary search.

          tabix = sy-tabix.

*         Falls die zugehörige EAN noch nicht gemerkt wurde, dann
*         besorge EAN.
          if sy-subrc <> 0.
*           Besorge die Haupt-EAN vom Vortag des Löschens.
            perform ean_by_date_get
                    using gt_vrkme-matnr  gt_vrkme-meinh
                          t_wlk2-vkbis    g_loesch_ean
                          g_returncode.

*           Falls eine EAN gefunden wurde, dann erzeuge
*           Lösch-Eintrag.
            if g_returncode = 0 and g_loesch_ean <> space.
              pet_artdel-artnr = gt_vrkme-matnr.
              pet_artdel-vrkme = gt_vrkme-meinh.
              pet_artdel-ean   = g_loesch_ean.
              pet_artdel-datum = h_datum.
              insert pet_artdel index tabix.

*           Falls keine EAN gefunden wurde, dann weiter
*           zum nächsten Satz.
            else. " g_returncode <> 0 or g_loesch_ean = space.
              continue.
            endif. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
          endif. " sy-subrc <> 0.

*         Falls der T_WLK2-Satz Gültigkeit auf Konzern- oder
*         auf Vertriebslinienebene (dieser Vertriebslinie) hat.
          if  t_wlk2-vkorg = space  or
            ( t_wlk2-werks = space                  and
              t_wlk2-vkorg = pit_filia_group-vkorg  and
              t_wlk2-vtweg = pit_filia_group-vtweg ).

*           Fülle Objekttabelle 2 (filialunabhängig).
            clear: pet_ot2_nart.
            pet_ot2_nart-artnr    = gt_vrkme-matnr.
            pet_ot2_nart-vrkme    = gt_vrkme-meinh.
            pet_ot2_nart-datum    = h_datum.
            pet_ot2_nart-wlk2     = c_vertriebslinie.
            pet_ot2_nart-upd_flag = c_del.
            append pet_ot2_nart.

*         Falls Filiale bekannt und dieser Vertriebslinie
*         zugehörig.
          elseif t_wlk2-werks <> space                 and
                 t_wlk2-vkorg = pit_filia_group-vkorg  and
                 t_wlk2-vtweg = pit_filia_group-vtweg.

*           Fülle Objekttabelle 1 (filialabhängig).
            clear: pet_ot1_f_nart.
            pet_ot1_f_nart-filia    = t_wlk2-werks.
            pet_ot1_f_nart-artnr    = gt_vrkme-matnr.
            pet_ot1_f_nart-vrkme    = gt_vrkme-meinh.
            pet_ot1_f_nart-datum    = h_datum.
            pet_ot1_f_nart-upd_flag = c_del.
            append pet_ot1_f_nart.
          endif.                 " T_WLK2-VKORG = SPACE OR ...
        endloop. " at gt_vrkme.
      endif. " pit_pointer-cdchgid <> c_del.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.


* Änderungen bezüglich  n:m Zuordnung (WRSZ-Pointer)
  perform wrsz_pointer_analyse
          tables t_filia_matnr
                 pit_pointer
                 pit_filia_group
          using  pi_erstdat.

* Auflösen der Rohdaten.
  clear: pet_ot1_f_nart.

  clear: i_key7, i_key8.
  loop at t_filia_matnr.
    move t_filia_matnr-matnr to i_key8-artnr.

*   Besorge die MARA-Daten des Artikels.
    mara-matnr = t_filia_matnr-matnr.
    perform mara_select using mara
                              mara-matnr.

*   Falls der Artikel kein Nachzugsartikel ist, dann
*   ignoriere den Einrag.
    if mara-mlgut is initial.
      continue.
    endif. " mara-mlgut is initial.

    if i_key7 <> i_key8.
      i_key7 = i_key8.

*     Bestimme alle Verkaufsmengeneinheiten des Artikels
*     aus Tabelle MARM, die eine EAN besitzen.
      refresh: t_matnr.
      t_matnr-matnr = t_filia_matnr-matnr.
      append t_matnr.

      perform marm_select tables t_matnr
                                 gt_vrkme
                          using  'X'   ' '   ' '.
    endif. " i_key7 <> i_key8.

    loop at gt_vrkme.
*     Besorge die WERKS-Nummer.
      if pit_filia_group-kunnr <> t_filia_matnr-locnr.
        read table pit_filia_group with key
             kunnr = t_filia_matnr-locnr
             binary search.
      endif. " pit_filia_group-kunnr <> t_filia_matnr-locnr.

      pet_ot1_f_nart-filia = pit_filia_group-filia.
      pet_ot1_f_nart-artnr = gt_vrkme-matnr.
      pet_ot1_f_nart-vrkme = gt_vrkme-meinh.
      pet_ot1_f_nart-init  = 'X'.
      pet_ot1_f_nart-datum = pi_erstdat.
      append pet_ot1_f_nart.
    endloop. " at gt_vrkme.
  endloop. " at t_filia_matnr.


* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_wlk1
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Umsortieren der Filialgruppentabelle.
    sort pit_filia_group by group kunnr.

*   Betrachte Neulistungen von Artikeln.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_wlk1.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_wlk1.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WLK1: Listungskonditionen,
*       Materialstamm.
        when 'WLK1'.
*         Nur Neulistungen müssen überprüft werden.
          if pit_pointer-cdchgid = c_insert.
            refresh: t_ot1.
            clear: pet_ot1_f_nart, t_ot1, i_wlk1.

*           Fülle den Schlüssel für WLK1.
            i_wlk1 = pit_pointer-tabkey.

*           Besorge die Filialen welche dieses Sortiment nutzen.
            refresh: t_assortment_users.
            call function 'ASSORTMENT_GET_USERS_OF_1ASORT'
              EXPORTING
                asort              = i_wlk1-filia
                valid_per_date     = sy-datum
                date_to            = max_datum
              TABLES
                assortment_users   = t_assortment_users
              EXCEPTIONS
                no_asort_to_select = 1
                no_user_found      = 2
                others             = 3.

            if sy-subrc <> 0.
              continue.
            endif.

*           Prüfe, welche Filialen in der gerade
*           bearbeiteten Filialgruppe vorkommen
            refresh: t_filia_group_temp.
            loop at t_assortment_users.
*             Prüfe, ob diese Filiale in der gerade
*             bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*             dürfen berücksichtigt werden.
              read table pit_filia_group with key
                   group = h_group
                   kunnr = t_assortment_users-kunnr
                   binary search.

*             Diese Filiale muß  berücksichtigt werden.
              if sy-subrc = 0.
                append pit_filia_group to t_filia_group_temp.
              endif. " sy-subrc = 0.
            endloop. " at t_assortment_users.

*           Prüfe, ob noch eine Filiale aus dieser Gruppe übrig
*           geblieben ist, die berücksichtigt werden muß.
            read table t_filia_group_temp index 1.

*           Falls keine Filiale aus dieser Gruppe übrig geblieben ist,
*           keine weitere Aufbereitung nötig.
            if sy-subrc <> 0.
              continue.
            endif. " sy-subrc <> 0.

*           Restauriere Schlüssel für WLK1.
            i_wlk1 = pit_pointer-tabkey.

*           Besorge die MARA-Daten des Artikels.
            perform mara_select using mara
                                      i_wlk1-artnr.

            if mara-matnr <> space.
*             Falls der Artikel ein Nachzugsartikel ist.
              if mara-mlgut <> space.
*               Analyse des WLK1-Pointers.
                perform wlk1_pointer_analyse
                             tables t_ot1
                                    pet_artdel
                                    t_filia_group_temp
                             using  pit_pointer
                                    pi_erstdat.

*               Übernahme der Daten in Ausgabetabellen.
                append lines of t_ot1 to pet_ot1_f_nart.
              endif. " mara-mlgut <> space.
            endif. " mara-matnr <> space.
          endif. " pit_pointer-cdchgid = c_insert.
      endcase.                           " PIT_POINTER-TABNAME
    endloop.                             " AT PIT_POINTER

    if sy-subrc = 0.
*     Resortieren der Filialgruppentabelle.
      sort pit_filia_group by group filia.
    endif. " sy-subrc = 0.
  endif. " sy-subrc = 0.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_betrieb
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen in den Zuordnungen Filiale <--> Warengruppe.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_betrieb.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_betrieb.

      case pit_pointer-tabname.
*       Änderungen in Tabelle WRF6: Zuordng. Filiale <--> Warengruppen.
        when 'WRF6'.
*         Falls eine Warengruppe einer Filiale zugeordnet wurde.
          if pit_pointer-cdchgid = c_insert.
*           Zuordnung wurde neu eingefügt.
            if pit_pointer-fldname = 'KEY'.
              i_wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = i_wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = i_wrf6-locnr
                  pi_warengruppe = i_wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist aber
*             von der Versendung ausgeschlossen werden soll, dann
*             müssen zu allen Nachzugsartikeln die dieser Warengruppe
*             zugeordnet sind Löschsätze erzeugt werden.
              if sy-subrc = 0 and t_wrf6-wdaus <> space.
*               Besorge zunächst alle Artikelnummern, die dieser
*               Warengruppe zugeordnet sind.
                perform mara_by_matkl_select tables t_matnr
                                             using  t_wrf6-matkl.

*               Besorge die zugehörigen Verkaufsmengeneinheiten
*               und Haupt-EAN's.
                perform marm_select tables t_matnr
                                           t_marm_data
                                    using  'X'   ' '   ' '.

                loop at t_marm_data.
*                 Prüfe, ob es sich bei dem Artikel um einen
*                 Nachzugsartikel handelt.
                  perform mara_select using mara
                                            t_marm_data-matnr.

*                 Falls es nicht sich um einen Nachzugsartikel handelt,
*                 dann weiter zur nächsten Artikelnummer.
                  if mara-mlgut = space.
                    continue.
                  endif. "  mara-mlgut = space.

*                 Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                  read table pet_artdel with key
                       artnr = t_marm_data-matnr
                       vrkme = t_marm_data-meinh
                       datum = pi_erstdat
                       binary search.

*                 Falls noch kein Löschmerker erzeugt wurde.
                  if sy-subrc <> 0.
                    tabix = sy-tabix.

*                   Prüfe, ob EAN bereits gemerkt wurde.
                    clear: gt_old_ean_nart.
                    read table gt_old_ean_nart with key
                               artnr = t_marm_data-matnr
                               vrkme = t_marm_data-meinh
                               datum = pi_erstdat
                               binary search.

*                   Falls die EAN noch nicht zwischengespeichert wurde,
*                   dann nehme die aktuelle EAN aus DB.
                    if sy-subrc <> 0.
                      pet_artdel-ean = t_marm_data-ean11.

*                   Falls die EAN schon zwischengespeichert wurde
*                   d.h. eine EAN-Änderung vor Einfügen der Zuordnung
*                   Filial <--> Warengruppe stattgefunden hat, dann
*                   übernehme die alte EAN.
                    else. " sy-subrc = 0.
                      pet_artdel-ean = gt_old_ean_nart-ean11.
                    endif. " sy-subrc <> 0.

*                   Abspeichern des Schlüssels zum Aufbau des
*                   Löschsatzes.
                    pet_artdel-artnr = t_marm_data-matnr.
                    pet_artdel-vrkme = t_marm_data-meinh.
                    pet_artdel-datum = pi_erstdat.
                    insert pet_artdel index tabix.
                  endif. " sy-subrc <> 0.            PET_ARTDEL

*                 Fülle Objekttabelle 1 (filialabhängig).
                  clear: pet_ot1_f_nart.
                  pet_ot1_f_nart-filia    = pit_filia_group-filia.
                  pet_ot1_f_nart-artnr    = t_marm_data-matnr.
                  pet_ot1_f_nart-vrkme    = t_marm_data-meinh.
                  pet_ot1_f_nart-datum    = pi_erstdat.
                  pet_ot1_f_nart-upd_flag = c_del.
                  append pet_ot1_f_nart.

                endloop. " at t_marm_data.
              endif. " sy-subrc = 0 and t_wrf6-wdaus <> space.
            endif.                       " PIT_POINTER-FLDNAME = 'KEY'.

*         Falls das WDAUS-Flag der Zuordnung Filiale <--> Warengruppe
*         verändert wurde.
          elseif pit_pointer-cdchgid = c_update.
*           WDAUS-Flag wurde verändert.
            if pit_pointer-fldname = 'WDAUS'.
              wrf6 = pit_pointer-tabkey.

*             Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*             betrifft.
              read table pit_filia_group with key
                         kunnr = wrf6-locnr.

*             Falls keine Filiale dieser Gruppe betroffen ist, dann
*             weiter zum nächsten Pointer.
              if sy-subrc <> 0.
                continue.
              endif. " sy-subrc <> 0.

*             Prüfe, ob das Versenden der Warengruppe an diese Filiale
*             erlaubt ist.
              call function 'PLANT_ALL_MATERIAL_GROUP_GET'
                EXPORTING
                  pi_filiale     = i_wrf6-locnr
                  pi_warengruppe = i_wrf6-matkl
                TABLES
                  pe_t_wrf6      = t_wrf6
                EXCEPTIONS
                  no_wrf6_record = 01
                  no_wrgp_found  = 02.

              read table t_wrf6 index 1.

*             Falls die Warengruppe dieser Filiale zugeordnet ist.
              if sy-subrc = 0.
*               Besorge zunächst alle Artikelnummern, die dieser
*               Warengruppe zugeordnet sind.
                perform mara_by_matkl_select tables t_matnr
                                             using  t_wrf6-matkl.

*               Besorge die zugehörigen Verkaufsmengeneinheiten
*               und Haupt-EAN's.
                perform marm_select tables t_matnr
                                           t_marm_data
                                    using  'X'   ' '   ' '.

                loop at t_marm_data.
*                 Prüfe, ob es sich bei dem Artikel um einen
*                 Nachzugsartikel handelt.
                  perform mara_select using mara
                                            t_marm_data-matnr.

*                 Falls es nicht sich um einen Nachzugsartikel handelt,
*                 dann weiter zur nächsten Artikelnummer.
                  if mara-mlgut = space.
                    continue.
                  endif. "  mara-mlgut = space.

                  clear: pet_ot1_f_nart.

*                 Falls die Warengruppe dieser Filiale zugeordnet ist
*                 aber von der Versendung ausgeschlossen werden soll,
*                 dann müssen zu allen Artikelnummern die dieser
*                 Warengruppe zugeordnet sind Löschsätze erzeugt
*                 werden.
                  if t_wrf6-wdaus <> space.
*                   Prüfe, ob Löschmerker schon einmal erzeugt wurde.
                    read table pet_artdel with key
                         artnr = t_marm_data-matnr
                         vrkme = t_marm_data-meinh
                         datum = pi_erstdat
                         binary search.

*                   Falls noch kein Löschmerker erzeugt wurde.
                    if sy-subrc <> 0.
                      tabix = sy-tabix.

*                     Prüfe, ob EAN bereits gemerkt wurde.
                      clear: gt_old_ean_nart.
                      read table gt_old_ean_nart with key
                                 artnr = t_marm_data-matnr
                                 vrkme = t_marm_data-meinh
                                 datum = pi_erstdat
                                 binary search.

*                     Falls die EAN noch nicht zwischengespeichert
*                     wurde, dann nehme die aktuelle EAN aus DB.
                      if sy-subrc <> 0.
                        pet_artdel-ean = t_marm_data-ean11.

*                     Falls die EAN schon zwischengespeichert wurde
*                     d.h. eine EAN-Änderung vor Einfügen der Zuordnung
*                     Filial <--> Warengruppe stattgefunden hat, dann
*                     übernehme die alte EAN.
                      else. " sy-subrc = 0.
                        pet_artdel-ean = gt_old_ean_nart-ean11.
                      endif. " sy-subrc <> 0.

*                     Abspeichern des Schlüssels zum Aufbau des
*                     Löschsatzes.
                      pet_artdel-artnr = t_marm_data-matnr.
                      pet_artdel-vrkme = t_marm_data-meinh.
                      pet_artdel-datum = pi_erstdat.
                      insert pet_artdel index tabix.
                    endif. "  sy-subrc <> 0.               PET_ARTDEL

*                   Setze Löschmerker zum späteren Löschen.
                    pet_ot1_f_nart-upd_flag = c_del.

*                 Falls die Warengruppe dieser Filiale zugeordnet ist
*                 und nicht mehr von der Versendung ausgeschlossen
*                 wird, dann müssen alle Artikel die dieser
*                 Warengruppe zugeordnet sind neu initialisiert werden.
                  else. " t_wrf6-wdaus = space.
*                   Setze Initialisierungsmerker zum späteren
*                   Initialisieren.
                    pet_ot1_f_nart-init = 'X'.
                  endif. " t_wrf6-wdaus <> space.

*                 Fülle die restlichen Felder in Objekttabelle 1
*                 (filialabhängig).
                  pet_ot1_f_nart-filia = pit_filia_group-filia.
                  pet_ot1_f_nart-artnr = t_marm_data-matnr.
                  pet_ot1_f_nart-vrkme = t_marm_data-meinh.
                  pet_ot1_f_nart-datum = pi_erstdat.
                  append pet_ot1_f_nart.

                endloop. " at t_marm_data.
              endif. " sy-subrc = 0.
            endif.                    " PIT_POINTER-FLDNAME = 'WDAUS'.
          endif.                 " pit_pointer-cdchgid = c_insert.

      endcase.                           " PIT_POINTER-TABNAME.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.

************************************************************************
* Funktionsexit für kundendefinierte Änderungszeigeranalyse.
  call customer-function '011'
       exporting
            pi_erstdat       = pi_erstdat
            pi_datp4         = pi_datp4
       tables
            pit_filia_group  = pit_filia_group
            pit_pointer      = pit_pointer
            pet_ot1_f_nart   = pet_ot1_f_nart
            pet_ot2_nart     = pet_ot2_nart.
************************************************************************


* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Sortieren der Daten.
  sort pet_ot1_f_nart by  filia artnr vrkme init descending datum
                                upd_flag.
  sort pet_ot2_nart   by        artnr vrkme init descending datum
                                upd_flag.

* Lösche überflüssige Einträge aus Tabelle PET_OT1_F_NART.
  clear: i_key5, i_key6, h_init, h_datum.
  loop at pet_ot1_f_nart
       where upd_flag <> c_del.
    move-corresponding pet_ot1_f_nart to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
      clear: h_init.
      if pet_ot1_f_nart-init <> space.
        h_init = 'X'.
        h_datum = pet_ot1_f_nart-datum.
      endif.                           " PET_OT1_F_NART-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key5 = i_key6 and h_init <> space and
           pet_ot1_f_nart-datum >= h_datum.
      delete pet_ot1_f_nart.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT1_F_NART.

* Lösche überflüssige Einträge aus Tabelle PET_OT2_NART.
  clear: i_key7, i_key8, h_init, h_datum.
  loop at pet_ot2_nart
       where upd_flag <> c_del.
    move-corresponding pet_ot2_nart to i_key8.
    if i_key7 <> i_key8.
      i_key7 = i_key8.
      clear: h_init.
      if pet_ot2_nart-init <> space.
        h_init = 'X'.
        h_datum = pet_ot2_nart-datum.
      endif.                           " PET_OT2_NART-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden, mit Ausnahme von Löschsätzen.
    elseif i_key7 = i_key8 and h_init <> space and
           pet_ot2_nart-datum >= h_datum.
      delete pet_ot2_nart.
    endif.                             " I_KEY7 <> I_KEY8.
  endloop.                             " AT PET_OT2_NART.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT1_F_NART.
  delete adjacent duplicates from pet_ot1_f_nart
         comparing all fields.

* Lösche doppelte Einträge aus PET_OT2_NART.
  delete adjacent duplicates from pet_ot2_nart
         comparing all fields.


endform.                               " ARTSTM_NART_POINTER_ANALYSE


*eject
************************************************************************
form pers_pointer_analyse
          tables pit_pointer     structure bdcp
                 pit_filia_group structure gt_filia_group
                 pet_ot1_k_pers  structure gt_ot1_k_pers
                 pet_ot2_pers    structure gt_ot2_pers.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabelle PET_OT2_PERS (filialunabhängig).
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER     : Tabelle der zu analysierenden Änderungspointer.

* PIT_FILIA_GROUP : Tabelle für Filialkonstanten der Gruppe.

* PET_OT1_K_PERS  : Personendaten: Objekttabelle 1,
*                   Kreditkontrollbereichsabhängig.
* PET_OT2_PERS    : Personendaten: Objekttabelle 2, filialunabhängig.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  types:  BEGIN OF knbk_key,
            mandt TYPE mandt,
            KUNNR TYPE KUNNR,
            BANKS TYPE BANKS,
            BANKL TYPE BANKL,
            BANKN TYPE BANKN,
          END OF knbk_key.


  data: i_knbk type knbk_key.


  data: h_tabix like sy-tabix.

* Zum Zwischenspeichern von Daten aus KNBK.
  data: begin of t_knbk occurs 10.
          include structure knbk.
  data: end of t_knbk.

* Zum Zwischenspeichern von Daten aus VCKUN.
  data: begin of t_vckun occurs 2.
          include structure vckun.
  data: end of t_vckun.


  refresh: pet_ot2_pers, pet_ot1_k_pers.

* Betrachte Personenstammänderungen.
  loop at pit_pointer
       where cdobjcl = c_objcl_debi
       or    cdobjcl = c_objcl_klim.

    clear: pet_ot2_pers, pet_ot1_k_pers.

    case pit_pointer-tabname.
*     Änderungen in Tabelle KNA1: Kundenstamm.
      when 'KNA1'.
        kna1-kunnr = pit_pointer-cdobjid.

*       Fülle Objekttabelle 2 (filialunabhängig).
        pet_ot2_pers-kunnr = kna1-kunnr.

*       Falls Kundennummer gelöscht wurde, wird dies extra vermerkt.
        if pit_pointer-cdchgid = c_erase.
          pet_ot2_pers-upd_flag = c_del.
        endif.                      " PIT_POINTER-CDCHGID = C_ERASE

        append pet_ot2_pers.

*     Änderungen in Tabelle KNKA: Kundenstamm Gesamtkreditlimit.
      when 'KNKA'.
        knka-kunnr = pit_pointer-cdobjid.

*       Fülle Objekttabelle 2 (filialunabhängig).
        pet_ot2_pers-kunnr = knka-kunnr.

*       Setze Merker, daß Gesamtkreditlimit verändert wurde.
        pet_ot2_pers-upd_flag = c_gklim.
        append pet_ot2_pers.

*     Änderungen in Tabelle KNKK: Kundenstamm Einzelkreditlimit.
      when 'KNKK'.
        knkk = pit_pointer-tabkey(17).   " Unicode enabling

*       Prüfe, ob die Änderung eine Filiale dieser Filialgruppe
*       betrifft.
        loop at pit_filia_group
             where kkber = knkk-kkber.
          exit.
        endloop. " at pit_filia_group

*       Falls keine Filiale dieser Gruppe betroffen ist, dann
*       weiter zum nächsten Pointer.
        if sy-subrc <> 0.
          continue.
        endif. " sy-subrc <> 0.

*       Fülle Objekttabelle 1 (Kreditkontrollbereichsabhängig)
        pet_ot1_k_pers-kunnr = knkk-kunnr.
        pet_ot1_k_pers-kkber = knkk-kkber.
        append pet_ot1_k_pers.

*     Änderungen in Tabelle KNBK: Kundenstamm Bankverbindungen.
      when 'KNBK'.
*       Falls eine Bankverbindung eingefügt wurde.
        if pit_pointer-cdchgid = c_insert.
          i_knbk = pit_pointer-tabkey.

*         Fülle Objekttabelle 2 (filialunabhängig).
          pet_ot2_pers-kunnr = i_knbk-kunnr.
          append pet_ot2_pers.

*       Falls eine Bankverbindung gelöscht wurde.
        elseif pit_pointer-cdchgid = c_erase.
          i_knbk = pit_pointer-tabkey.

*         Fülle Objekttabelle 2 (filialunabhängig).
          pet_ot2_pers-kunnr = i_knbk-kunnr.
          append pet_ot2_pers.

        endif. " pit_pointer-cdchgid = c_insert.

    endcase.                           " PIT_POINTER-TABNAME.
  endloop.                             " AT PIT_POINTER

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_bank
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen der Bankanschriften.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_bank.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_bank.

*     Nur Änderungen der Bankanschriften, nicht jedoch das Anlegen
*     und Löschen muß berücksichtigt werden.
      if pit_pointer-cdchgid = c_update.

        case pit_pointer-tabname.
*         Änderungen in Tabelle KNA1: Kundenstamm.
          when 'BNKA'.
            bnka = pit_pointer-tabkey.

*           Besorge alle Kundennummern, die diese Bankanschrift
*           verwenden aus KNBK.
            select * from knbk into table t_knbk
                   where banks = bnka-banks
                   and   bankl = bnka-bankl.            "#EC CI_NOFIRST

*           Falls Zuordnungen zum Kundenstamm gefunden wurden.
            if sy-subrc = 0.
*             Lösche alle doppelten Kundennummern aus interner Tabelle.

              sort t_knbk by kunnr.
              delete adjacent duplicates from t_knbk
                              comparing kunnr.

*             Übernehme alle gefundenen Kundennummern.
              loop at t_knbk.
*               Fülle Objekttabelle 2 (filialunabhängig).
                clear: pet_ot2_pers.
                pet_ot2_pers-kunnr = t_knbk-kunnr.
                append pet_ot2_pers.
              endloop.                             " AT t_knbk.
            endif. " sy-subrc = 0.

        endcase.                           " PIT_POINTER-TABNAME.
      endif. " pit_pointer-cdchgid = c_update.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.

* Bestimme, ob zu diesem Änderungsbelegobjekt Werte existieren.
  read table pit_pointer with key
       cdobjcl = c_objcl_credit
       binary search
       transporting no fields.

* Falls zu diesem Änderungsbelegobjekt Werte existieren.
  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Betrachte Änderungen der Kreditkarteninformationen.
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-cdobjcl <> c_objcl_credit.
        exit.
      endif. " pit_pointer-cdobjcl <> c_objcl_credit.

      case pit_pointer-tabname.
*       Änderungen in Tabelle VCKUN: Zuordnung Kunde-Kreditkarte.
        when 'VCKUN'.
*         Änderungen der Zuordnung Kunde-Kreditkarte haben keine
*         Bedeutung. Nur Einfügen oder Löschen muß berücksichtigt
*         werden.
          if pit_pointer-cdchgid = c_insert or
             pit_pointer-cdchgid = c_del.
            vckun = pit_pointer-tabkey.

*           Fülle Objekttabelle 2 (filialunabhängig).
            clear: pet_ot2_pers.
            pet_ot2_pers-kunnr = vckun-kunnr.
            append pet_ot2_pers.
          endif. " pit_pointer-cdchgid = c_insert or ...

*       Änderungen in Tabelle VCNUM: Kreditkartenstamm.
        when 'VCNUM'.
          vckun-kunnr = pit_pointer-cdobjid.

*         Fülle Objekttabelle 2 (filialunabhängig).
          clear: pet_ot2_pers.
          pet_ot2_pers-kunnr = vckun-kunnr.
          append pet_ot2_pers.

      endcase.                         " PIT_POINTER-TABNAME.
    endloop.                             " AT PIT_POINTER
  endif. " sy-subrc = 0.

************************************************************************
* Funktionsexit für kundendefinierte Änderungszeigeranalyse.
  call customer-function '013'
       tables
            pit_filia_group  = pit_filia_group
            pit_pointer      = pit_pointer
            pet_ot1_k_pers   = pet_ot1_k_pers
            pet_ot2_pers     = pet_ot2_pers.
************************************************************************

* Lösche doppelte Einträge aus PET_OT2_PERS.
  sort pet_ot2_pers by kunnr upd_flag.
  delete adjacent duplicates from pet_ot2_pers
         comparing all fields.

* Lösche doppelte Einträge aus PET_OT1_K_PERS.
  sort pet_ot1_k_pers by kkber kunnr.
  delete adjacent duplicates from pet_ot1_k_pers
         comparing all fields.


endform.                               " PERS_POINTER_ANALYSE


*eject
************************************************************************
form ot3_generate_wrgp
     tables  pit_ot1_f_wrgp         structure gt_ot1_f_wrgp
             pit_ot2_wrgp           structure gt_ot2_wrgp
             pet_ot3_wrgp           structure gt_ot3_wrgp
             pxt_independence_check structure gt_independence_check
     using   pi_filia_group         structure gt_filia_group.
************************************************************************
* FUNKTION:
* Übernehme die Daten aus Objekttabelle OT1 und OT2 nach PET_OT3_WRGP.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT1_F_WRGP        : Warengruppen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_WRGP          : Warengruppen: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_WRGP          : Warengruppen: Objekttabelle 3,
*                         filialabhängig.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_index like sy-tabix.

* Zum Komprimieren von Tabelle PET_OT3_WRGP.
  data: begin of i_key1,
          matkl like gt_ot2_wrgp-matkl.
  data: end of i_key1.


* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_wrgp.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  read table pxt_independence_check with key
       filia = pi_filia_group-filia
       binary search.

  h_index = sy-tabix.

* Falls die Filiale kopierbar ist, d.h. nur filialunabhängige Daten hat.
  if pxt_independence_check-wrgp <> space.
*   Prüfe, ob es bereits eine Kopiermutter für die Warengruppen
*   dieser Filiale gibt.
    loop at pxt_independence_check
         where filia <  pi_filia_group-filia
         and   wrgp  <> space
         and   ok    <> space.
      exit.
    endloop. " at pxt_independence_check

*   Falls eine Kopiermutter existiert, dann braucht nicht weiter
*   aufbereitet zu werden.
    if sy-subrc = 0.
*     Weitere Aufbereitung verlassen.
      exit.
    endif. " sy-subrc = 0.
  endif. " pxt_independence_check-wrgp <> space.

* Übernahme der Daten aus PIT_OT1_F_WRGP.
  loop at pit_ot1_f_wrgp
       where filia = pi_filia_group-filia.
    move-corresponding pit_ot1_f_wrgp to pet_ot3_wrgp.
    append pet_ot3_wrgp.
  endloop.                             " AT PIT_OT1_F_WRGP.

* Übernahme der Daten aus PIT_OT2_WRGP.
  loop at pit_ot2_wrgp
       where spras = space
       or    spras = pi_filia_group-spras.
    move-corresponding pit_ot2_wrgp to pet_ot3_wrgp.
    append pet_ot3_wrgp.
  endloop.                             " AT PIT_OT2_WRGP.


* Lösche doppelte Einträge aus PET_OT3_WRGP.
  sort pet_ot3_wrgp by matkl upd_flag descending.
  delete adjacent duplicates from pet_ot3_wrgp
                  comparing matkl.


endform.                               " OT3_GENERATE_WRGP


*eject
************************************************************************
form ot3_generate_artstm
     tables pit_kondart            structure gt_kondart
            pxt_ot1_f_artstm       structure gt_ot1_f_artstm
            pxt_ot2_artstm         structure gt_ot2_artstm
            pet_ot3_artstm         structure gt_ot3_artstm
            pit_ot1_f_ean          structure gt_ot1_f_ean
            pit_ot2_ean            structure gt_ot2_ean
            pit_ot1_f_nart         structure gt_ot1_f_nart
            pit_ot2_nart           structure gt_ot2_nart
            pet_wlk2               structure gt_wlk2
            pxt_independence_check structure gt_independence_check
            pxt_artdel             structure gt_artdel
            pxt_matnr              structure wpmatnr
            pit_filter_segs        structure gt_filter_segs
     using  pi_filia_group         structure gt_filia_group
            pi_erstdat             like syst-datum
            pi_datp3               like syst-datum
            pi_datp4               like syst-datum.
************************************************************************
* FUNKTION:
* Besorge alle sich ändernden Gültigkeitsstände einer Filiale, die
* noch nicht durch die Pointeranalyse übernommen wurden und
* erzeuge filialabhängige Objekttabelle PET_OT3_ARTSTM. Ferner
* werden die Objekttabellen OT1 und OT2 in OT3 zusammengemischt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_KONDART           : Tabelle mit POS-relevanten Konditionsarten.

* PXT_OT1_F_ARTSTM:       Artikelstamm: Objekttabelle 1,
*                         filialabhängig.
* PXT_OT2_ARTSTM        : Artikelstamm: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3. Alle
*                         potentiell aufzubereitenden Artikel.
* PIT_OT1_F_EAN         : EAN-Referenzen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_EAN           : EAN-Referenzen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT1_F_NART        : N-Artikel: Objekttabelle 1, filialabhängig.

* PIT_OT2_NART          : N-Artikel: Objekttabelle 2, filialunabhängig.

* PET_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_ARTDEL            : Tabelle für zu löschende Artikel

* PXT_MATNR             : Tabelle aller zu betrachtenen Artikel

* PIT_FILTER_SEGS       : Liste aller für den POS-Download nicht
*                         benötigten Segmente.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: jetziges Versenden + Vorlaufzeit.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_init,
        h_delete,
        h_index    like sy-tabix,
        h_tabix    like sy-tabix,
        h_skip,
        h_found,
        counter    type i,
        returncode like sy-subrc,
        h_datum    like sy-datum,
        h_readindex  like sy-tabix,
        h_aenderungstyp,
        h_kond_analyse value 'X', " Flag, ob Kond. anal. werden müssen
        h_natr_analyse value 'X'. " Flag, ob Natrab.anal. werden müssen

* Zum Komprimieren von Tabelle PET_OT3_ARTSTM (Stufe 1).
  data: begin of i_key1,
          artnr like pet_ot3_artstm-artnr,
          vrkme like pet_ot3_artstm-vrkme.
  data: end of i_key1.

* Zum Komprimieren von Tabelle PET_OT3_ARTSTM (Stufe 1).
  data: begin of i_key2.
          include structure i_key1.
  data: end of i_key2.

* Nur zum Komprimieren der Daten aus PET_OT3_ARTSTM.
  data: begin of i_key3,
          artnr like gt_ot3_artstm-artnr,
          vrkme like gt_ot3_artstm-vrkme,
          datum like gt_ot3_artstm-datum,
          init  like gt_ot3_artstm-init.
  data: end of i_key3.

* Nur zum Komprimieren der Daten aus PET_OT3_ARTSTM.
  data: begin of i_key4.
          include structure i_key3.
  data: end of i_key4.

* Tabelle für Materialnummern aus WLK2.
  data: begin of t_wlk2_matnr occurs 1000.
          include structure gt_filia_wlk2_buf.
  data: end of t_wlk2_matnr.

* Zwischenpuffer für wlk2-Sätze.
  data: begin of t_wlk2 occurs 1000.
          include structure gt_wlk2.
  data: end of t_wlk2.

* Zweiter Zwischenpuffer für Materialnummern aus WLK2.
  data: begin of t_matnr occurs 1000.
          include structure gt_matnr_marm_buf.
  data: end of t_matnr.

* Tabelle für alle zugehörigen MARM-Daten.
  data: begin of t_marm_data  occurs 1000.
          include structure gt_marm_buf.
  data: end of t_marm_data.

  DATA: BEGIN OF t_matnr_data OCCURS 1000.            " Note 1982796
          INCLUDE STRUCTURE gt_matnr.
  DATA: END OF t_matnr_data.

  DATA: BEGIN OF lt_ot3_artstm OCCURS 200.
          INCLUDE STRUCTURE wpaot3.
  DATA: END OF lt_ot3_artstm.

  FIELD-SYMBOLS <ls_ot3_artstm1> type wpaot3.

  FIELD-SYMBOLS <ls_ot3_artstm2> type wpaot3.

* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_artstm, gt_kondart_flag.
  clear:   pet_ot3_artstm, gt_kondart_flag.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  read table pxt_independence_check with key
       filia = pi_filia_group-filia
       binary search.

  h_index = sy-tabix.

* Falls jede Änderung eines Nachzugsartikels auch zur Aufbereitung
* des gleichnamigen Artikels führen soll
  if not pi_filia_group-foa_art is initial.
*   Übernehme Nachzugsartikeländerungen in Artikelstamm-Tabellen.
    loop at pit_ot2_nart
         where upd_flag = space.
      clear: pxt_ot2_artstm.
      move-corresponding pit_ot2_nart to pxt_ot2_artstm.

*     Der Artikel darf nur geändert aber nicht gelöscht werden.
*     clear: pxt_ot2_artstm-upd_flag.
      append pxt_ot2_artstm.
    endloop.                             " at pit_ot2_nart.

    loop at pit_ot1_f_nart
         where upd_flag = space.

      clear: pxt_ot1_f_artstm.
      move-corresponding pit_ot1_f_nart to pxt_ot1_f_artstm.

*     Der Artikel darf nur geändert aber nicht gelöscht werden.
*     clear: pxt_ot1_f_artstm-upd_flag.
      append pxt_ot1_f_artstm.
    endloop.                             " at pit_ot1_f_nart.

*   Falls eine mögliche Kopiermutter vorliegt.
    if sy-subrc = 0 and pxt_independence_check-artstm <> space.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-artstm.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc = 0 and pxt_independence_check-artstm <> space.

  endif. " not pi_filia_group-foa_art is initial.

* Falls jede Änderung einer zus. EAN auch zur Aufbereitung
* des zugehörigen Artikels führen soll.
  if not pi_filia_group-ean_art is initial.
*   Übernehme Nachzugsartikeländerungen in Artikelstamm-Tabellen.
    loop at pit_ot2_ean
         where upd_flag = space.

      clear: pxt_ot2_artstm.
      move-corresponding pit_ot2_ean to pxt_ot2_artstm.

*     Der Artikel darf nur geändert aber nicht gelöscht werden.
*     clear: pxt_ot2_artstm-upd_flag.
      append pxt_ot2_artstm.
    endloop.                             " at pit_ot2_ean.

    loop at pit_ot1_f_ean
         where upd_flag = space.

      clear: pxt_ot1_f_artstm.
      move-corresponding pit_ot1_f_ean to pxt_ot1_f_artstm.

*     Der Artikel darf nur geändert aber nicht gelöscht werden.
*     clear: pxt_ot1_f_artstm-upd_flag.
      append pxt_ot1_f_artstm.
    endloop.                             " at pit_ot1_f_ean.

*   Falls eine mögliche Kopiermutter vorliegt.
    if sy-subrc = 0 and pxt_independence_check-artstm <> space.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-artstm.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc = 0 and pxt_independence_check-artstm <> space.

  endif. " not pi_filia_group-ean_art is initial.

* Prüfe, Konditionsanalyse überhaupt nötig ist und wenn ja, ob
* auch Naturalrabatte analysiert werden sollen.
  loop at pit_filter_segs.
    case pit_filter_segs-segtyp.
      when c_e1wpa04_name.
        clear: h_kond_analyse.
      when c_e1wpa09_name.
        clear: h_natr_analyse.
    endcase.                           " PIT_FILTER_SEGS-SEGTYP
  endloop.                             " PIT_FILTER_SEGS

* Übernehme alle POS-relevanten Konditionsarten für diese
* Filiale aus PIT_KONDART.
  refresh: gt_kondart_flag.
  clear:   gt_kondart_flag.
  loop at pit_kondart
       where locnr = pi_filia_group-kunnr.
    move-corresponding pit_kondart to gt_kondart_flag.
    append gt_kondart_flag.
  endloop.                   "  PIT_KONDART

* Falls Konditionsanalyse nötig ist
  if not h_kond_analyse is initial or
     not h_natr_analyse is initial.

*   Falls die Daten noch nicht ermittelt wurden.
    if g_condint_scanned is initial.
*     Prüfe Gültigkeitsänderungen von Konditionen, die nicht durch
*     Änderungspointer gemeldet wurden.
      call function 'POS_CONDITION_CHANGES_CHECK_2'
        EXPORTING
          pi_vkorg               = pi_filia_group-vkorg
          pi_vtweg               = pi_filia_group-vtweg
          pi_filia               = pi_filia_group-filia
          pi_datab               = pi_datp3
          pi_datbi               = pi_datp4
          pi_mode                = c_pos_mode
          pi_erstdat             = pi_erstdat
          pi_spras               = pi_filia_group-spras
          pi_natrab_analyse      = h_natr_analyse
          pi_kond_analyse        = h_kond_analyse
        TABLES
          pet_ot3_artstm         = pet_ot3_artstm
          pit_ot1_f_artstm       = pxt_ot1_f_artstm
          pit_ot2_artstm         = pxt_ot2_artstm
          pit_kondart            = gt_kondart_flag
          pxt_independence_check = pxt_independence_check
        EXCEPTIONS
          no_record_listed       = 1.

*     Übernehme alle Artikel aus den Objekttabelle 3 in eine
*     interne Tabelle.
*     Übernehme Artikel von der Konditionsanalyse.
      loop at pet_ot3_artstm.
        append pet_ot3_artstm-artnr to pxt_matnr.
        APPEND pet_ot3_artstm-artnr TO t_matnr_data.  " Note 1982796
      endloop. " at pet_ot3_artstm.

*     Falls alle Konditionsintervalle filialunabhängig gepflegt sind,
*     dann übernehme das Analysergebnis in internen Puffer.
      if not pi_filia_group-prices_siteindep is initial  and
             pi_filia_group-prices_in_a071   is initial.

        gt_ot3_artstm_buf[] = pet_ot3_artstm[].

*       Merken, daß Analyse bereits stattgefunden hat.
        g_condint_scanned = 'X'.
      endif. " not pi_filia_group-prices_siteindep is initial.

*   Falls die Daten bereits ermittelt wurden.
    else.
*     Übernehme Ergebnis aus internem Puffer.
      pet_ot3_artstm[] = gt_ot3_artstm_buf[].

*     Übernehme alle Artikel aus den Objekttabelle 3 in eine
*     interne Tabelle.
*     Übernehme Artikel von der Konditionsanalyse.
      loop at pet_ot3_artstm.
        append pet_ot3_artstm-artnr to pxt_matnr.
        APPEND pet_ot3_artstm-artnr TO t_matnr_data.  " Note 1982796
      endloop. " at pet_ot3_artstm.
    endif. " g_condint_scanned is initial.
  endif. " not h_kond_analyse is initial or

* Prüfe, ob potentielle Versendeartikel vorliegen.
  read table pxt_matnr index 1.

* Falls keine Artikel gefunden wurden.
  if sy-subrc <> 0.
*   Prüfe, ob zusätzliche Versendeartikel durch Konditionsanalyse
*   festgestellt wurden.
    read table pet_ot3_artstm index 1.

*   Falls keine Artikel gefunden wurden.
    if sy-subrc <> 0.
*     Falls eine mögliche Kopiermutter vorliegt.
      if pxt_independence_check-artstm <> space.
*       Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
        read table pxt_independence_check index h_index.
        clear: pxt_independence_check-artstm.
        modify pxt_independence_check index h_index.
      endif. " pxt_independence_check-artstm <> space.

*     Keine weitere Aufbereitung nötig.
      exit.
    endif. " sy-subrc <> 0.

* Falls Artikel gefunden wurden.
  else. " sy-subrc = 0.
* B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
     AND gs_twpa-marc_chk IS NOT INITIAL.
     IF t_matnr_data[] IS NOT INITIAL.
       MOVE-CORRESPONDING pi_filia_group TO gi_filia_const.
        h_datum = pi_filia_group-datab - 1.
      CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
        EXPORTING
          ip_access_type         = '2'    " WLK2 access with Art/Store
          ip_prefetch_data       = 'X'
          ip_vkorg               = pi_filia_group-vkorg
          ip_vtweg               = pi_filia_group-vtweg
          ip_filia               = pi_filia_group-filia
          ip_date_from           = h_datum
          ip_date_to             = pi_datp4
           is_filia_const        = gi_filia_const
        TABLES
          pit_matnr       = t_matnr_data
          pet_wlk2        = t_wlk2.
       APPEND LINES OF t_wlk2 TO pet_wlk2.
       CLEAR t_wlk2. REFRESH t_wlk2.
       SORT pet_wlk2 DESCENDING BY matnr ASCENDING
                                   vkorg
                                   vtweg
                                   werks.
     ENDIF.
   ELSE.

*   Setze untere Intervallgrenzen des Betrachtungszeitraums.
*   Anmerkung: Bei einer Auslistung wird das BIS-Datum des
*   Bewirtschaftungszeitraums auf Gestern gesetzt. Damit der Artikel
*   nicht herausgefiltert wird wird die untere Intervallgrenze auf den
*   Vortag des letzten Versendens gesetzt (Zeitpunkt P1 - 1).
    h_datum = pi_filia_group-datab - 1.

*   Führe notwendige Prüfungen durch und besorge die zugehörigen
*   WLK2-Daten.
    call function 'WLK2_MATERIAL_FOR_FILIA'
      EXPORTING
        pi_vkorg        = pi_filia_group-vkorg
        pi_vtweg        = pi_filia_group-vtweg
        pi_filia        = pi_filia_group-filia
        pi_datab        = h_datum
        pi_datbi        = pi_datp4
      TABLES
        wlk2_input      = pet_wlk2
        pit_matnr       = pxt_matnr
      EXCEPTIONS
        werks_not_found = 01
        no_wlk2         = 02
        no_wlk2_listing = 03.

  endif. " sy-subrc <> 0.
  ENDIF. " Note 1982796
* Bestimme alle Objekte, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht und solche deren
* Bewirtschaftungszeitraum innerhalb des Betrachtungszeitraums endet.
  perform wlk2_intervals_check
          tables t_marm_data
                 t_wlk2
                 pet_wlk2
                 pxt_independence_check
                 pet_ot3_artstm
                 pxt_artdel
          using  pi_filia_group     c_mestype_artstm
                 pi_datp3           pi_datp4
                 h_index.

* Übernahme der gefundenen Objekte nach OT3.
  clear: i_key1, i_key2.
  loop at t_marm_data.
    clear: pet_ot3_artstm.
    move t_marm_data-matnr to i_key2-artnr.

    if i_key1 <> i_key2.
      i_key1 = i_key2.

*     Besorge das Aktivierungsdatum aus t_wlk2.
      read table t_wlk2 with key
           matnr = t_marm_data-matnr
           binary search.
    endif. " i_key1 <> i_key2.

    pet_ot3_artstm-artnr = t_marm_data-matnr.
    pet_ot3_artstm-vrkme = t_marm_data-meinh.
    pet_ot3_artstm-datum = t_wlk2-vkdab.

*   Merken, das der Satz aufgrund einer
*   Materialinitialisierung erzeugt wurde.
    pet_ot3_artstm-aetyp_sort = c_init_sort_index.

*   Falls das Aktivierungsdatum in der Vergangenheit
*   liegt, dann muß immer Initialisiert werden.
    if t_wlk2-vkdab < pi_erstdat.
      pet_ot3_artstm-init  = 'X'.
      pet_ot3_artstm-datum = pi_erstdat.
    endif. " t_wlk2-vkdab < PI_ERSTDAT.

    append pet_ot3_artstm.
  endloop. " at t_marm_data

* Ermitteln der Anzahl der gefundenen Objekte
  sort pet_ot3_artstm by artnr vrkme.
  clear: i_key1, i_key2.
  loop at pet_ot3_artstm.
    move-corresponding pet_ot3_artstm to i_key2.
    if i_key1 <> i_key2.
*     Aktualisiere zugehörige statistische Zählvariable.
      add 1 to gi_stat_counter-artstm_zus.

      i_key1 = i_key2.
    endif. " i_key1 <> i_key2.
  endloop. " at pet_ot3_artstm.

* Übernahme der Daten aus PIT_OT2_ARTSTM.
  clear: i_key1, i_key2.
  loop at pxt_ot2_artstm
       where mamt_spras = space
       or    mamt_spras = pi_filia_group-spras.

    move-corresponding pxt_ot2_artstm to i_key2.
    clear: h_skip.
    clear: h_found.  "OSS 928176

*   Falls dieser Satz durch WLK2-Analyse und durch Änderung auf
*   Vertriebslinienebene entstanden ist.
    if pxt_ot2_artstm-wlk2 <> space.
*     Prüfe zunächst, ob in PET_WLK2 filialabhängige
*     WLK2-Sätze existieren.
      read table pet_wlk2 with key
           matnr   = pxt_ot2_artstm-artnr
           binary search.

*     Falls ein Eintrag gefunden wurde.
      if sy-subrc = 0.
*       Merke die gefundene Tabellenzeile.
        h_tabix = sy-tabix.

        loop at pet_wlk2  from h_tabix.
*         Abbruchbedingung für Schleife setzen.
          if pet_wlk2-matnr <> pxt_ot2_artstm-artnr.
            exit.
          endif.

          if pet_wlk2-orghier = c_filiale.
*           Falls diese Filiale eine potentielle Kopiermutter für den
*           Artikelstamm ist.
            if pxt_independence_check-artstm <> space.
*             Vermerke in Filialcopytabelle, daß diese Filiale keine
*             Kopiermutter für den Artikelstamm sein kann.
              clear: pxt_independence_check-artstm.
              modify pxt_independence_check index h_index.
            endif. " pxt_independence_check-artstm <> space.

*           Setze Flag zum überspringen der restlichen Analyse für
*           diesen Satz in PIT_OT2_ARTSTM.
            h_skip = 'X'.

*           Schleife verlassen.
            exit.
          endif. " pxt_wlk2-orghier = c_filiale.
        endloop.                           " AT PET_WLK2
      endif. " sy-subrc = 0.

*     Falls keine filialabhängigen WLK2-Sätze in PET_WLK2
*     gefunden wurden, dann prüfe auf DB.
*     if sy-subrc <> 0.
*       Falls zu diesem Artikel filialabhängige
*       WLK2-Sätze existieren.
*       select * from wlk2
*              where matnr = pxt_ot2_artstm-artnr
*              and   vkorg = pi_filia_group-vkorg
*              and   vtweg = pi_filia_group-vtweg
*              and   werks = pi_filia_group-filia.

*         Falls diese Filiale eine potentielle Kopiermutter für den
*         Artikelstamm ist.
*         if pxt_independence_check-artstm <> space.
*           Vermerke in Filialcopytabelle, daß diese Filiale keine
*           Kopiermutter für den Artikelstamm sein kann.
*           clear: pxt_independence_check-artstm.
*           modify pxt_independence_check index h_index.
*         endif. " pxt_independence_check-artstm <> space.

*         Setze Flag zum überspringen der restlichen Analyse für
*         diesen Satz in PIT_OT2_ARTSTM.
*         h_skip = 'X'.

*         Select-Schleife verlassen.
*         exit.
*       endselect. " * from wlk2
*     endif. " sy-subrc <> 0.

*     Weiter zum nächsten Satz, falls nötig.
      if h_skip <> space.
*       Falls Statistikvariablen aktualisiert werden müssen.
        if i_key1 <> i_key2.
*         Aktualisiere zugehörige statistische Zählvariable.
          add 1 to gi_stat_counter-artstm_bew.

          i_key1 = i_key2.
        endif. " i_key1 <> i_key2.

        continue.
      endif. " h_skip <> space.

*     Falls kein filialabhängiger WLK2-Satz gefunden wurde und der
*     Satz in PIT_OT2_ARTSTM auf einen WLK2-Satz auf Konzernebene
*     verweist, dann prüfe, ob es einen WLK2-Satz auf
*     Vertriebslinienebene gibt, der den Konzernsatz überdeckt.
*     In diesem Fall braucht der Satz in OT2 nicht in OT3 übernommen
*     zu werden.
      if pxt_ot2_artstm-wlk2 = c_konzern.
*       Prüfe zunächst, ob in PET_WLK2 vertriebslinienabhängige
*       WLK2-Sätze existieren.
        read table pet_wlk2 with key
             matnr   = pxt_ot2_artstm-artnr
             binary search.

*       Falls ein Eintrag gefunden wurde.
        if sy-subrc = 0.
*         Merke die gefundene Tabellenzeile.
          h_tabix = sy-tabix.

          loop at pet_wlk2  from h_tabix.
*           Abbruchbedingung für Schleife setzen.
            if pet_wlk2-matnr <> pxt_ot2_artstm-artnr.
              exit.
            endif.

            if pet_wlk2-orghier = c_vertriebslinie.
*             Falls diese Filiale eine potentielle Kopiermutter für den
*             Artikelstamm ist.
              if pxt_independence_check-artstm <> space.
*               Vermerke in Filialcopytabelle, daß diese Filiale keine
*               Kopiermutter für den Artikelstamm sein kann.
                clear: pxt_independence_check-artstm.
                modify pxt_independence_check index h_index.
              endif. " pxt_independence_check-artstm <> space.

*             Setze Flag zum überspringen der restlichen Analyse für
*             diesen Satz in PIT_OT2_ARTSTM.
              h_skip = 'X'.

*             Schleife verlassen.
              exit.
            endif. " pxt_wlk2-orghier = c_vertriebslinie.
          endloop.                           " AT PET_WLK2
        endif. " sy-subrc = 0.

*       Falls keine vertriebslinienabhängigen WLK2-Sätze in PET_WLK2
*       gefunden wurden, dann prüfe auf DB.
*       if sy-subrc <> 0.
*         Falls zu diesem Artikel vertriebslinienabhängige
*         WLK2-Sätze existieren.
*         select * from wlk2
*                where matnr = pxt_ot2_artstm-artnr
*                and   vkorg = pi_filia_group-vkorg
*                and   vtweg = pi_filia_group-vtweg
*                and   werks = space.

*           Setze Flag zum überspringen der restlichen Analyse für
*           diesen Satz in PIT_OT2_ARTSTM.
*           h_skip = 'X'.

*           Select-Schleife verlassen.
*           exit.
*         endselect. " * from wlk2
*       endif. " sy-subrc <> 0.

*       Weiter zum nächsten Satz, falls nötig.
        if h_skip <> space.
*         Falls Statistikvariablen aktualisiert werden müssen.
          if i_key1 <> i_key2.
*           Aktualisiere zugehörige statistische Zählvariable.
            add 1 to gi_stat_counter-artstm_bew.

            i_key1 = i_key2.
          endif. " i_key1 <> i_key2.

          continue.
        endif. " h_skip <> space.
      endif. " pit_ot2_artstm-wlk2 = c_konzern.
    endif. " pit_ot2_artstm-wlk2 <> space.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pet_wlk2 with key
         matnr = pxt_ot2_artstm-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pet_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pet_wlk2-matnr <> pxt_ot2_artstm-artnr.
          exit.
        endif.
        if pet_wlk2-vkdab <= pi_datp4    and
           pet_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet, ein Sammelartikel oder eine Variante
*   ist, dann wird er übernommen.
    if not h_found is initial or pxt_ot2_artstm-attyp <> space.
      move-corresponding pxt_ot2_artstm to pet_ot3_artstm.
      append pet_ot3_artstm.

*   Falls der Artikel nicht gelistet ist...
    else. " sy-subrc <> 0 and pit_ot2_artstm-attyp = space ...
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key1 <> i_key2.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-artstm_bew.

        i_key1 = i_key2.
      endif. " i_key1 <> i_key2.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PXT_OT2_ARTSTM.

* Übernahme der Daten aus PIT_OT1_F_ARTSTM.
  clear: i_key1, i_key2.
  loop at pxt_ot1_f_artstm
       where filia = pi_filia_group-filia.
    move-corresponding pxt_ot1_f_artstm to i_key2.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pet_wlk2 with key
         matnr = pxt_ot1_f_artstm-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pet_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pet_wlk2-matnr <> pxt_ot1_f_artstm-artnr.
          exit.
        endif.
        if pet_wlk2-vkdab <= pi_datp4    and
           pet_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet, ein Sammelartikel oder eine Variante ist
*   oder es sich um einen Löschsatz handelt, dann wird er übernommen.
    if  not h_found is initial or  pxt_ot1_f_artstm-attyp <> space  or
       (    h_found is initial and pxt_ot1_f_artstm-upd_flag <> space ).
      move-corresponding pxt_ot1_f_artstm to pet_ot3_artstm.
      append pet_ot3_artstm.

*   Falls der Artikel nicht gelistet ist...
    else. " h_found is initial and pxt_ot1_f_artstm-attyp = space...
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key1 <> i_key2.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-artstm_bew.

        i_key1 = i_key2.
      endif. " i_key1 <> i_key2.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PXT_OT1_F_ARTSTM

* Berücksichtige Preisänderungen für Sammelartikel und Varianten,
* die Preismaterial für andere Varianten sind.
  perform pmata_check
          tables pet_ot3_artstm
                 gt_ot3_pmata
                 pet_wlk2
          using  pi_filia_group
                 pi_datp4.

* Sortieren der Daten.
  sort pet_ot3_artstm by  artnr vrkme aetyp_sort.

* Bestimme Änderungstyp und merke ihn im ersten Satz eines jeden Keys.
  clear: i_key1, i_key2, h_aenderungstyp, h_readindex.
  loop at pet_ot3_artstm
       where upd_flag <> c_del.
    move-corresponding pet_ot3_artstm to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      h_aenderungstyp = pet_ot3_artstm-aetyp_sort.
      h_readindex     = sy-tabix.
    else. " i_key1 = i_key2
*     Falls der Änderungstyp noch potentiell änderbar ist, dann
*     prüfe weiter.
      if h_aenderungstyp > c_all_sort_index.
*       Falls der Änderungstyp auf 'ALL' zu ändern ist.
        if pet_ot3_artstm-aetyp_sort > h_aenderungstyp and
           pet_ot3_artstm-aetyp_sort = c_mat_sort_index.
*         Ändere den ersten Satz für diesen Schlüssel.
          read table pet_ot3_artstm index h_readindex.
          pet_ot3_artstm-aetyp_sort = c_all_sort_index.
          modify pet_ot3_artstm index h_readindex.

          h_aenderungstyp = c_all_sort_index.
        endif. " pet_ot3_artstm-aetyp_sort > h_aenderungstyp.
      endif. " h_aenderungstyp > c_all_sort_index.
    endif.                             " I_KEY1 <> I_KEY2.
  endloop.                             " AT PET_OT3_ARTSTM.

* Übertrage den gemerkten Änderungstyp auf alle übrigen
* Einträge desselben Schlüssels.
  clear: i_key1, i_key1.
  loop at pet_ot3_artstm.
    move-corresponding pet_ot3_artstm to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      h_aenderungstyp = pet_ot3_artstm-aetyp_sort.

    elseif i_key1 = i_key2 and
           h_aenderungstyp <> pet_ot3_artstm-aetyp_sort.
      pet_ot3_artstm-aetyp_sort = h_aenderungstyp.
      modify pet_ot3_artstm.
    endif.                             " I_KEY1 <> I_KEY2.
  endloop.                             " AT pet_ot3_artstm.


* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Löscheinträge werden nicht berücksichtigt.
* Sortieren der Daten.
  sort pet_ot3_artstm by artnr vrkme init descending datum.

* Lösche überflüssige Einträge aus Tabelle PET_OT3_ARTSTM.
  clear: i_key1, i_key2, h_init, h_datum.
  loop at pet_ot3_artstm
       where upd_flag <> c_del.
    move-corresponding pet_ot3_artstm to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      clear: h_init.
      if pet_ot3_artstm-init <> space.
        h_init = 'X'.
        h_datum = pet_ot3_artstm-datum.
      endif.                           " PET_OT3_ARTSTM-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key1 = i_key2 and h_init <> space and
           pet_ot3_artstm-datum >= h_datum.
      delete pet_ot3_artstm.
    endif.                             " I_KEY1 <> I_KEY2.
  endloop.                             " AT PET_OT3_ARTSTM.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT3_ARTSTM.
  clear: i_key3, i_key4.
  loop at pet_ot3_artstm
       where upd_flag <> c_del.
    move-corresponding pet_ot3_artstm to i_key4.
    if i_key3 <> i_key4.
      i_key3 = i_key4.
    else.
      delete pet_ot3_artstm.
    endif.                             " I_KEY3 <> I_KEY4.
  endloop.                             " AT PET_OT3_ARTSTM.

* Komprimierung Stufe 3: Lösche überflüssige Einträge.

* Sortieren der Daten.
* sort pet_ot3_artstm by artnr vrkme upd_flag descending datum.

* Falls sowohl Änderungs- als auch Löscheinträge erzeugt wurden,
* dann haben die Löscheinträge Priorität, d. h. die Änderungssätze
* werden gelöscht.
* clear: i_key1, i_key2, h_delete, h_datum.
* loop at pet_ot3_artstm.
*   move-corresponding pet_ot3_artstm to i_key2.
*   if i_key1 <> i_key2.
*     i_key1 = i_key2.
*     clear: h_delete.
*     if pet_ot3_artstm-upd_flag = c_del.
*       h_delete = 'X'.
*       h_datum = pet_ot3_artstm-datum.
*     endif.                           " PET_OT3_ARTSTM-INIT <> SPACE.
*   Falls bereits eine Löschung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum gleich
*   dem Löschdatum ist aus der internen Tabelle gelöscht, da sie durch
*   die Löschung überschrieben werden.
*   elseif i_key1 = i_key2 and h_delete <> space and
*          pet_ot3_artstm-datum = h_datum.
*     delete pet_ot3_artstm.
*   endif.                             " I_KEY1 <> I_KEY2.
* endloop.                             " AT PET_OT3_ARTSTM.

* Sortieren der Daten.
  sort pet_ot3_artstm by artnr vrkme init descending datum.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-artstm <> space.
*   Gibt es überhaupt Änderungen für diesen IDOC-Typ ?
    read table pet_ot3_artstm index 1.

*   Falls überhaupt keine Artikelstammdaten geändert wurden, dann werden
*   auch keine versendet und das Kopiermutter-Flag muß zurückge-
*   nommen werden.
    if sy-subrc <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-artstm.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc <> 0.
  endif. " pxt_independence_check-artstm <> space.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-artstm <> space.
*   Besorge alle filialabhängigen WLK2-Artikel im
*   Betrachtungszeitraum.
    perform filia_wlk2_matnr_get
            tables t_wlk2_matnr
            using  pi_filia_group.

*   Prüfe, ob irgendwelche WLK2-Intervalle filialabhängig sind.
    perform filia_wlk2_check
                    tables t_wlk2_matnr
                           pet_ot3_artstm
                    using  pi_filia_group
                           returncode.

*   Falls Filialabhängige WLK2-Daten gefunden wurden.
    if returncode <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-artstm.
      modify pxt_independence_check index h_index.
    endif. " returncode <> 0.
  endif. " pxt_independence_check-artstm <> space.

  if pxt_independence_check-artstm <> space.
*   Prüfe, ob irgendwelche Konditionsintervalle filialabhängig sind
    perform kondition_independence_check
                      tables pet_ot3_artstm
                             pxt_independence_check
                             gt_kondart_flag
                      using  pi_filia_group
                             pi_erstdat
                             pi_datp4.
  endif. " pxt_independence_check-artstm <> space.

* Due to the performance optimization note 1896123 which splits the contect into a fixed size,
* pet_ot3_artstm should be sorted in a way variants are located below its generic article.
* If not, variants will not be included in the IDOC since generic article is used to find its variants within the same pacakge.
  loop at pet_ot3_artstm assigning <ls_ot3_artstm1>
       where pmata = space.
    move <ls_ot3_artstm1> to lt_ot3_artstm.
    append lt_ot3_artstm.
    if <ls_ot3_artstm1>-attyp = '01'.
      loop at pet_ot3_artstm assigning <ls_ot3_artstm2>
           where pmata = <ls_ot3_artstm1>-artnr
             and vrkme = <ls_ot3_artstm1>-vrkme
             and datum = <ls_ot3_artstm1>-datum
             and ( init  = <ls_ot3_artstm1>-init or init = 'X' ).
        move <ls_ot3_artstm2> to lt_ot3_artstm.
        append lt_ot3_artstm.
      endloop.
    endif.
  endloop.

  pet_ot3_artstm[] = lt_ot3_artstm[].

* Nummeriere die Objektgruppen.
  clear: counter, i_key1, i_key2.
  loop at pet_ot3_artstm.
    move-corresponding pet_ot3_artstm to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      add 1 to counter.
    endif.                             " I_KEY1 <> I_KEY2.

    pet_ot3_artstm-number = counter.
    modify pet_ot3_artstm.
  endloop.                             " AT PET_OT3_ARTSTM


endform.                               " OT3_GENERATE_ARTSTM


*eject
************************************************************************
form ot3_generate_ean
     tables pxt_ot1_f_ean          structure gt_ot1_f_ean
            pxt_ot2_ean            structure gt_ot2_ean
            pet_ot3_ean            structure gt_ot3_ean
            pit_ot3_artstm         structure gt_ot3_artstm
            pxt_wlk2               structure gt_wlk2
            pxt_independence_check structure gt_independence_check
            pxt_artdel             structure gt_artdel
            pit_matnr              structure wpmatnr
     using  pi_filia_group         structure gt_filia_group
            pi_erstdat             like syst-datum
            pi_datp3               like syst-datum
            pi_datp4               like syst-datum.
************************************************************************
* FUNKTION:
* Erzeuge filialabhängige Objekttabelle PET_OT3_EAN. Ferner
* werden die Objekttabellen OT1 und OT2 in OT3 zusammengemischt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_OT1_F_EAN         : EAN-Referenzen: Objekttabelle 1,
*                         filialabhängig.
* PXT_OT2_EAN           : EAN-Referenzen: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3. Alle
*                         potentiell aufzubereitenden Artikel.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PXT_WLK2              : Gesammelte Bewirtschatungszeiträume der
*                         Filiale.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_MATNR             : Tabelle aller zu betrachtenen Artikel

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: jetziges Versenden + Vorlaufzeit.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_init,
        h_skip,
        h_delete,
        h_found,
        h_lines    type i,
        h_index    like sy-tabix,
        h_tabix    like sy-tabix,
        counter    type i,
        returncode like sy-subrc,
        h_datum    like sy-datum.

* Zum Komprimieren von Tabelle PET_OT3_EAN (Stufe 1).
  data: begin of i_key1,
          artnr like pet_ot3_ean-artnr,
          vrkme like pet_ot3_ean-vrkme.
  data: end of i_key1.

* Zum Komprimieren von Tabelle PET_OT3_EAN (Stufe 1).
  data: begin of i_key2.
          include structure i_key1.
  data: end of i_key2.

* Nur zum Komprimieren der Daten aus PET_OT3_EAN.
  data: begin of i_key3,
          artnr like gt_ot3_ean-artnr,
          vrkme like gt_ot3_ean-vrkme,
          datum like gt_ot3_ean-datum,
          init  like gt_ot3_ean-init.
  data: end of i_key3.

* Nur zum Komprimieren der Daten aus PET_OT3_EAN.
  data: begin of i_key4.
          include structure i_key3.
  data: end of i_key4.

* Tabelle für Materialnummern aus WLK2.
  data: begin of t_wlk2_matnr occurs 1000.
          include structure gt_filia_wlk2_buf.
  data: end of t_wlk2_matnr.

* Zwischenpuffer für wlk2-Sätze.
  data: begin of t_wlk2 occurs 1000.
          include structure gt_wlk2.
  data: end of t_wlk2.

* Zweiter Zwischenpuffer für Materialnummern aus WLK2.
  data: begin of t_matnr occurs 1000.
          include structure gt_matnr_marm_buf.
  data: end of t_matnr.

* Tabelle für alle zugehörigen MARM-Daten
  data: begin of t_marm_data  occurs 1000.
          include structure gt_marm_buf.
  data: end of t_marm_data.

* Tabelle für WLK1-Daten.
  data: begin of t_wlk1 occurs 0.
          include structure wlk1.
  data: end of t_wlk1.

* Strukur für WLK1-Daten.
  data: begin of i_wlk1.
          include structure wlk1.
  data: end of i_wlk1.


* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_ean.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  read table pxt_independence_check with key
       filia = pi_filia_group-filia
       binary search.

  h_index = sy-tabix.

* Falls jede Artikelstammänderung zu einer Aufbereitung
* der zugehörigen zusätzlichen EAN's führen soll.
  if not pi_filia_group-ean_art is initial.
*   Übernehme (möglicherweise) filialabhängige Artikelstammänderungen
*   in EAN-Tabellen.
    loop at pit_ot3_artstm
         where upd_flag = space.
      clear: pxt_ot1_f_ean.
      move-corresponding pit_ot3_artstm to pxt_ot1_f_ean.
      pxt_ot1_f_ean-filia = pi_filia_group-filia.
      append pxt_ot1_f_ean.
    endloop. " at pit_ot3_artstm.

*   Falls eine mögliche Kopiermutter vorliegt.
    if sy-subrc = 0  and
       pxt_independence_check-ean <> space.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-ean.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc = 0 and pxt_independence_check-ean <> space.
  endif. " not pi_filia_group-ean_art is initial.

* Prüfe, ob Artikel innerhalb des Zeitintervalls
* PI_ERSTDAT und PI_DATP4 von dieser Filiale der
* Gruppe bewirtschaftet werden.
  read table pxt_wlk2 index 1.

* Falls interne Bewirtschaftungstabelle nicht gefüllt ist, dann
* besorge Bewirtschaftungen von DB.
  if sy-subrc <> 0 or pxt_wlk2-werks <> pi_filia_group-filia.
*   Prüfe, ob potentielle Versendeartikel vorliegen.
    read table pit_matnr index 1.

*   Falls keine Artikel gefunden wurden.
    if sy-subrc <> 0.
*     Falls eine mögliche Kopiermutter vorliegt.
      if pxt_independence_check-ean <> space.
*       Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
        read table pxt_independence_check index h_index.
        clear: pxt_independence_check-ean.
        modify pxt_independence_check index h_index.
      endif. " pxt_independence_check-ean <> space.

*     Keine weitere Aufbereitung nötig.
      exit.
    endif. " sy-subrc <> 0.
* B: New listing check logic => Note 1982796
   IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
      AND gs_twpa-marc_chk IS NOT INITIAL.

   ELSE.
*   Setze untere Intervallgrenzen des Betrachtungszeitraums.
*   Anmerkung: Bei einer Auslistung wird das BIS-Datum des
*   Bewirtschaftungszeitraums auf Gestern gesetzt. Damit der Artikel
*   nicht herausgefiltert wird, wird die untere Intervallgrenze auf den
*   Vortag des letzten Versendens gesetzt (Zeitpunkt P1 - 1).
    h_datum = pi_filia_group-datab - 1.

*   Führe notwendige Prüfungen durch und besorge die zugehörigen
*   WLK2-Daten.
    call function 'WLK2_MATERIAL_FOR_FILIA'
      EXPORTING
        pi_vkorg        = pi_filia_group-vkorg
        pi_vtweg        = pi_filia_group-vtweg
        pi_filia        = pi_filia_group-filia
        pi_datab        = h_datum
        pi_datbi        = pi_datp4
      TABLES
        wlk2_input      = pxt_wlk2
        pit_matnr       = pit_matnr
      EXCEPTIONS
        werks_not_found = 01
        no_wlk2         = 02
        no_wlk2_listing = 03.

  endif.   " sy-subrc <> 0 or pxt_wlk2-werks <> pi_filia_group-filia.
 ENDIF.
* Prefetch für MARA-Puffer, falls nötig.
  perform mara_prefetch tables pxt_wlk2.

* Bestimme alle Objekte, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht.
  perform wlk2_intervals_check
          tables t_marm_data
                 t_wlk2
                 pxt_wlk2
                 pxt_independence_check
                 pet_ot3_ean
                 pxt_artdel
          using  pi_filia_group     c_mestype_ean
                 pi_datp3           pi_datp4
                 h_index.

* Übernahme der gefundenen Objekte nach OT3.
  clear: i_key1, i_key2.
  loop at t_marm_data.
    clear: pet_ot3_ean.
    move t_marm_data-matnr to i_key2-artnr.

    if i_key1 <> i_key2.
      i_key1 = i_key2.

*     Besorge das Aktivierungsdatum aus t_wlk2.
      read table t_wlk2 with key
           matnr = t_marm_data-matnr
           binary search.
    endif. " i_key1 <> i_key2.

    pet_ot3_ean-artnr = t_marm_data-matnr.
    pet_ot3_ean-vrkme = t_marm_data-meinh.
    pet_ot3_ean-datum = t_wlk2-vkdab.

*   Falls das Aktivierungsdatum in der Vergangenheit
*   liegt, dann muß immer Initialisiert werden.
    if t_wlk2-vkdab < pi_erstdat.
      pet_ot3_ean-init  = 'X'.
      pet_ot3_ean-datum = pi_erstdat.
    endif. " t_wlk2-vkdab < PI_ERSTDAT.

    append pet_ot3_ean.
  endloop. " at t_marm_data

* Merken der Anzahl der gefundenen Objekte
  describe table pet_ot3_ean lines h_lines.
  add h_lines to gi_stat_counter-ean_zus.

* Übernahme der Daten aus PIT_OT2_EAN.
  clear: i_key1, i_key2.
  loop at pxt_ot2_ean.

    move-corresponding pxt_ot2_ean to i_key2.
    clear: h_skip.
    clear: h_found.  "OSS 928176

*   Falls dieser Satz durch WLK2-Analyse und durch Änderung auf
*   Vertriebslinienebene entstanden ist.
    if pxt_ot2_ean-wlk2 <> space.
*     Prüfe zunächst, ob in PXT_WLK2 filialabhängige
*     WLK2-Sätze existieren.
      read table pxt_wlk2 with key
           matnr = pxt_ot2_ean-artnr
           binary search.

*     Falls ein Eintrag gefunden wurde.
      if sy-subrc = 0.
*       Merke die gefundene Tabellenzeile.
        h_tabix = sy-tabix.

        loop at pxt_wlk2  from h_tabix.
*         Abbruchbedingung für Schleife setzen.
          if pxt_wlk2-matnr <> pxt_ot2_ean-artnr.
            exit.
          endif.

          if pxt_wlk2-orghier = c_filiale.
*           Falls diese Filiale eine potentielle Kopiermutter für die
*           EAN-Referenzen.
            if pxt_independence_check-ean <> space.
*             Vermerke in Filialcopytabelle, daß diese Filiale keine
*             Kopiermutter für die EAN-Referenzen sein kann.
              clear: pxt_independence_check-ean.
              modify pxt_independence_check index h_index.
            endif. " pxt_independence_check-ean <> space.

*           Setze Flag zum überspringen der restlichen Analyse für
*           diesen Satz in PIT_OT2_EAN.
            h_skip = 'X'.

*           Schleife verlassen.
            exit.
          endif. " pxt_wlk2-orghier = c_filiale.
        endloop.                           " AT PET_WLK2
      endif. " sy-subrc = 0.

*     Weiter zum nächsten Satz, falls nötig.
      if h_skip <> space.
*       Falls Statistikvariablen aktualisiert werden müssen.
        if i_key1 <> i_key2.
*         Aktualisiere zugehörige statistische Zählvariable.
          add 1 to gi_stat_counter-ean_bew.

          i_key1 = i_key2.
        endif. " i_key1 <> i_key2.

        continue.
      endif. " h_skip <> space.
    endif. " pit_ot2_ean-wlk2 <> space.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pxt_wlk2 with key
         matnr = pxt_ot2_ean-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pxt_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pxt_wlk2-matnr <> pxt_ot2_ean-artnr.
          exit.
        endif.
        if pxt_wlk2-vkdab <= pi_datp4    and
           pxt_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet, dann wird er übernommen.
    if not h_found is initial.
      move-corresponding pxt_ot2_ean to pet_ot3_ean.
      append pet_ot3_ean.

*   Falls der Artikel nicht gelistet ist.
    else. " h_found is initial
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key1 <> i_key2.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-ean_bew.

        i_key1 = i_key2.
      endif. " i_key1 <> i_key2.
    endif.                             " not h_found is initial.
  endloop.                             " AT PIT_OT2_EAN.

* Übernahme der Daten aus PXT_OT1_F_EAN.
  clear: i_key1, i_key2.
  loop at pxt_ot1_f_ean
       where filia = pi_filia_group-filia.
    move-corresponding pxt_ot1_f_ean to i_key2.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pxt_wlk2 with key
         matnr = pxt_ot1_f_ean-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pxt_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pxt_wlk2-matnr <> pxt_ot1_f_ean-artnr.
          exit.
        endif.
        if pxt_wlk2-vkdab <= pi_datp4    and
           pxt_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PXT_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet ist oder es sich um einen Löschsatz
*   handelt dann wird er übernommen.
    if   not h_found is initial or
       (     h_found is initial and pxt_ot1_f_ean-upd_flag <> space ).
      move-corresponding pxt_ot1_f_ean to pet_ot3_ean.
      append pet_ot3_ean.

*   Falls der Artikel nicht gelistet und auch kein Löschsatz ist.
    else. " h_found is initial...
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key1 <> i_key2.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-ean_bew.

        i_key1 = i_key2.
      endif. " i_key1 <> i_key2.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PXT_OT1_F_EAN

* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Löscheinträge werden nicht berücksichtigt.
* Sortieren der Daten.
  sort pet_ot3_ean by artnr vrkme init descending datum.

* Lösche überflüssige Einträge aus Tabelle PET_OT3_EAN.
  clear: i_key1, i_key2, h_init, h_datum.
  loop at pet_ot3_ean
       where upd_flag = space.
    move-corresponding pet_ot3_ean to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      clear: h_init.
      if pet_ot3_ean-init <> space.
        h_init = 'X'.
        h_datum = pet_ot3_ean-datum.
      endif.                           " PET_OT3_EAN-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key1 = i_key2 and h_init <> space and
           pet_ot3_ean-datum >= h_datum.
      delete pet_ot3_ean.
    endif.                             " I_KEY1 <> I_KEY2.
  endloop.                             " AT PET_OT3_EAN.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT3_EAN.
  clear: i_key3, i_key4.
  loop at pet_ot3_ean
       where upd_flag = space.
    move-corresponding pet_ot3_ean to i_key4.
    if i_key3 <> i_key4.
      i_key3 = i_key4.
    else.
      delete pet_ot3_ean.
    endif.                             " I_KEY3 <> I_KEY4.
  endloop.                             " AT PET_OT3_EAN.

* Komprimierung Stufe 3: Lösche überflüssige Einträge.

* Sortieren der Daten.
* sort pet_ot3_ean by artnr vrkme upd_flag descending datum.

* Falls sowohl Änderungs- als auch Löscheinträge erzeugt wurden,
* dann haben die Löscheinträge Priorität, d. h. die Änderungssätze
* werden gelöscht.
* clear: i_key1, i_key2, h_delete, h_datum.
* loop at pet_ot3_ean
*      where upd_flag <> c_erase.
*   move-corresponding pet_ot3_ean to i_key2.
*   if i_key1 <> i_key2.
*     i_key1 = i_key2.
*     clear: h_delete.
*     if pet_ot3_ean-upd_flag = c_del.
*       h_delete = 'X'.
*       h_datum = pet_ot3_ean-datum.
*     endif.                           " PET_OT3_EAN-INIT <> SPACE.
*   Falls bereits eine Löschung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter oder gleich
*   dem Löschdatum ist aus der internen Tabelle gelöscht, da sie durch
*   die Löschung überschrieben werden.
*   elseif i_key1 = i_key2 and h_delete <> space and
*          pet_ot3_ean-datum >= h_datum.
*     delete pet_ot3_ean.
*   endif.                             " I_KEY1 <> I_KEY2.
* endloop.                             " AT PET_OT3_EAN.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-ean <> space.
*   Gibt es überhaupt Änderungen für diesen IDOC-Typ ?
    read table pet_ot3_ean index 1.

*   Falls überhaupt keine EAN-Referenzen geändert wurden, dann werden
*   auch keine versendet und das Kopiermutter-Flag muß zurückge-
*   nommen werden.
    if sy-subrc <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-ean.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc <> 0.
  endif. " pxt_independence_check-ean <> space.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-ean <> space.
*   Besorge alle filialabhängigen WLK2-Daten im
*   Betrachtungszeitraum.
    perform filia_wlk2_matnr_get
            tables t_wlk2_matnr
            using  pi_filia_group.

*   Prüfe, ob irgendwelche WLK2-Intervalle filialabhängig sind.
    perform filia_wlk2_check
                    tables t_wlk2_matnr
                           pet_ot3_ean
                    using  pi_filia_group
                           returncode.

*   Falls Filialabhängige WLK2-Daten gefunden wurden.
    if returncode <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-ean.
      modify pxt_independence_check index h_index.
    endif. " returncode <> 0.
  endif. " pxt_independence_check-ean <> space.

* Sortieren der Daten.
  sort pet_ot3_ean by artnr vrkme init descending datum.

* Nummeriere die Objektgruppen.
  clear: counter, i_key1, i_key2.
  loop at pet_ot3_ean.
    move-corresponding pet_ot3_ean to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      add 1 to counter.
    endif.                             " I_KEY1 <> I_KEY2.

    pet_ot3_ean-number = counter.
    modify pet_ot3_ean.
  endloop.                             " AT PET_OT3_EAN


endform.                               " OT3_GENERATE_EAN


*eject
************************************************************************
form ot3_generate_sets
     tables pit_ot1_f_sets         structure gt_ot1_f_sets
            pit_ot2_sets           structure gt_ot2_sets
            pet_ot3_sets           structure gt_ot3_sets
            pxt_wlk2               structure gt_wlk2
            pxt_independence_check structure gt_independence_check
            pxt_artdel             structure gt_artdel
            pit_matnr              structure wpmatnr
     using  pi_filia_group         structure gt_filia_group
            pi_erstdat             like syst-datum
            pi_datp3               like syst-datum
            pi_datp4               like syst-datum.
************************************************************************
* FUNKTION:
* Besorge all sich ändernden Gültigkeitsstände einer Filiale, die
* noch nicht durch die Pointeranalyse übernommen wurden und
* erzeuge filialabhängige Objekttabelle PET_OT3_SETS. Außerdem
* werden die Objekttabellen OT1 und OT2 in OT3 zusammengemischt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT1_F_SETS        : Set-Artikel: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_SETS          : Set-Artikel: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_SETS          : Set-Artikel: Objekttabelle 3.

* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PXT_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_MATNR             : Tabelle aller zu betrachtenen Artikel

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: jetziges Versenden + Vorlaufzeit.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: just_init,    " Flag, ob Obj. bereits initialisiert werden soll
        h_init,
        h_skip,
        h_delete,
        h_index    like sy-tabix,
        h_tabix    like sy-tabix,
        h_found,
        counter    type i,
        returncode like sy-subrc,
        h_datum    like sy-datum.

* Nur zum Komprimieren der Daten aus PET_OT3_SETS.
  data: begin of i_key5,
          artnr like gt_ot3_sets-artnr,
          vrkme like gt_ot3_sets-vrkme,
          datum like gt_ot3_sets-datum,
          init  like gt_ot3_sets-init.
  data: end of i_key5.

* Nur zum Komprimieren der Daten aus PET_OT3_SETS.
  data: begin of i_key6.
          include structure i_key5.
  data: end of i_key6.

* Zum Komprimieren von Tabelle PET_OT3_SETS (Stufe 1).
  data: begin of i_key8,
          artnr like pet_ot3_sets-artnr,
          vrkme like pet_ot3_sets-vrkme.
  data: end of i_key8.

* Zum Komprimieren von Tabelle PET_OT3_SETS (Stufe 1).
  data: begin of i_key9.
          include structure i_key8.
  data: end of i_key9.

* Tabelle für Materialnummern aus WLK2.
  data: begin of t_wlk2_matnr occurs 1000.
          include structure gt_filia_wlk2_buf.
  data: end of t_wlk2_matnr.

* Zwischenpuffer für wlk2-Sätze.
  data: begin of t_wlk2 occurs 1000.
          include structure gt_wlk2.
  data: end of t_wlk2.

* Zweiter Zwischenpuffer für Materialnummern aus WLK2.
  data: begin of t_matnr occurs 1000.
          include structure gt_matnr_marm_buf.
  data: end of t_matnr.

* Tabelle für alle zugehörigen MARM-Daten
  data: begin of t_marm_data  occurs 1000.
          include structure gt_marm_buf.
  data: end of t_marm_data.


* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_sets.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  read table pxt_independence_check with key
       filia = pi_filia_group-filia
       binary search.

  h_index = sy-tabix.

* Prüfe, ob Artikel innerhalb des Zeitintervalls
* PI_ERSTDAT und PI_DATP4 von dieser Filiale der
* Gruppe bewirtschaftet werden.
  read table pxt_wlk2 index 1.

* Falls interne Bewirtschaftungstabelle nicht gefüllt ist, dann
* besorge Bewirtschaftungen von DB.
  if sy-subrc <> 0 or pxt_wlk2-werks <> pi_filia_group-filia.
*   Prüfe, ob potentielle Versendeartikel vorliegen.
    read table pit_matnr index 1.

*   Falls keine Artikel gefunden wurden.
    if sy-subrc <> 0.
*     Falls eine mögliche Kopiermutter vorliegt.
      if pxt_independence_check-sets <> space.
*       Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
        read table pxt_independence_check index h_index.
        clear: pxt_independence_check-sets.
        modify pxt_independence_check index h_index.
      endif. " pxt_independence_check-sets <> space.

*     Keine weitere Aufbereitung nötig.
      exit.
    endif. " sy-subrc <> 0.

* B: New listing check logic => Note 1982796
   IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
      AND gs_twpa-marc_chk IS NOT INITIAL.
   ELSE.
*   Setze untere Intervallgrenzen des Betrachtungszeitraums.
*   Anmerkung: Bei einer Auslistung wird das BIS-Datum des
*   Bewirtschaftungszeitraums auf Gestern gesetzt. Damit der Artikel
*   nicht herausgefiltert wird wird die untere Intervallgrenze auf den
*   Vortag des letzten Versendens gesetzt (Zeitpunkt P1 - 1).
    h_datum = pi_filia_group-datab - 1.

*   Führe notwendige Prüfungen durch und besorge die zugehörigen
*   WLK2-Daten.
    call function 'WLK2_MATERIAL_FOR_FILIA'
      EXPORTING
        pi_vkorg        = pi_filia_group-vkorg
        pi_vtweg        = pi_filia_group-vtweg
        pi_filia        = pi_filia_group-filia
        pi_datab        = h_datum
        pi_datbi        = pi_datp4
      TABLES
        wlk2_input      = pxt_wlk2
        pit_matnr       = pit_matnr
      EXCEPTIONS
        werks_not_found = 01
        no_wlk2         = 02
        no_wlk2_listing = 03.
  endif. " sy-subrc <> 0 or pxt_wlk2-werks <> pi_filia_group-filia.
 ENDIF.
* Prefetch für MARA-Puffer, falls nötig.
  perform mara_prefetch tables pxt_wlk2.

* Übernehme alle Artikel, die innerhalb des Zeitintervalls
* PI_DATP3 und PI_DATP4 bewirtschaftet werden und hier eine
* Änderung der Set-Zuordnungen erfahren in Tabelle PET_OT3_SETS.
* loop at pxt_wlk2
*      where vkdab <= pi_datp4
*      and   vkbis >  pi_datp3.

*   Zukünftige Änderungen sind nicht möglich, daher diesbzgl. keine
*   Analyse.
*   exit.

*   Prüfe, ob es sich um einen Set-Artikel handelt.
*   perform mara_select using mara
*                             pxt_wlk2-matnr.

*   Falls es sich um einen Set-Artikel handelt.
*   if mara-matnr <> space and mara-attyp = c_setartikel.
*     clear: pet_ot3_sets.

*     Prüfe, ob dieses Objekt bereits initialisiert werden soll.
*     just_init = 'X'.
*     read table pit_ot1_f_sets with key
*          filia = pi_filia_group-filia
*          artnr = pxt_wlk2-matnr
*          vrkme = mara-meins
*          init  = 'X'
*          binary search.

*     if sy-subrc <> 0.
*       read table pit_ot2_sets with key
*            artnr = pxt_wlk2-matnr
*            vrkme = mara-meins
*            init  = 'X'
*            binary search.

*       Objekt soll nicht initialisiert werden. Es muß also weiter
*       überprüft werden.
*       if sy-subrc <> 0.
*         clear: just_init.
*       endif.                       " SY-SUBRC <> 0.
*     endif.                         " SY-SUBRC <> 0.

*     Falls Objekt weiter überprüft werden soll.
*     if just_init = space.
*       if pi_datp3 < pi_datp4.
*         h_datum = pi_datp3 + 1.

*         Bestimme die Intervallgrenzen des SETS im Zeitintervall
*         PI_DATP3 und PI_DATP4.
*         refresh: gt_set_komp.
*         call function 'MGW0_COMPONENTS'
*              exporting
*                   mgw0_article        = pxt_wlk2-matnr
*                   mgw0_date_from      = h_datum
*                   mgw0_date_to        = pi_datp4
*                   mgw0_plant          = '    '
*                   mgw0_structure_type = c_settype
*              tables
*                   mgw0_components     = gt_set_komp
*              exceptions
*                   not_found           = 01.

*         loop at gt_set_komp.
*           Nur die DATAB-Zeitpunkte des Set-Intervalls
*           müssen berücksichtigt werden.
*           if gt_set_komp-datuv >= h_datum.
*             Falls die Gültigkeit des Sets bereits abgelaufen
*             ist, dann braucht auch nicht versendet zu werden.
*             if gt_set_komp-datub < pi_erstdat.
*               continue.
*             endif. " gt_set_komp-datub < pi_erstdat.

*             Fülle Objekttabelle 3 (filialabhängig).
*             pet_ot3_sets-artnr = pxt_wlk2-matnr.
*             pet_ot3_sets-vrkme = mara-meins.
*             clear: pet_ot3_sets-upd_flag.
*             clear: pet_ot3_sets-init.

*             Das kleinste Versendedatum ist immer PI_ERSTDAT.
*             if gt_set_komp-datuv < pi_erstdat.
*               pet_ot3_sets-datum = pi_erstdat.
*             else. " gt_set_komp-datuv >= pi_erstdat.
*               pet_ot3_sets-datum = gt_set_komp-datuv.
*             endif. " gt_set_komp-datub < pi_erstdat.

*             append pet_ot3_sets.
*           endif.                     " GT_SET_KOMP-DATUV >= H_DATUM
*         endloop.                     " AT GT_SET_KOMP.
*       endif. " pi_datp3 < pi_datp4.
*     endif.                         " JUST_INIT = SPACE.
*   endif.        " mara-matnr <> space and mara-attyp = c_setartikel.
* endloop.                             " AT PXT_WLK2.

* Bestimme alle Objekte, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht.
  perform wlk2_intervals_check
          tables t_marm_data
                 t_wlk2
                 pxt_wlk2
                 pxt_independence_check
                 pet_ot3_sets
                 pxt_artdel
          using  pi_filia_group     c_mestype_set
                 pi_datp3           pi_datp4
                 h_index.

* Übernahme der gefundenen Objekte nach OT3.
  clear: i_key8, i_key9.
  loop at t_marm_data.
    clear: pet_ot3_sets.
    move t_marm_data-matnr to i_key9-artnr.

    if i_key8 <> i_key9.
      i_key8 = i_key9.

*     Besorge die MARA-Daten des Artikels.
      perform mara_select using mara
                                t_marm_data-matnr.

*     Falls der Artikel kein Setartikel ist
      if mara-attyp <> c_setartikel.
*       Weiter zum nächsten Satz.
        continue.
      endif. " mara-attyp <> c_setartikel.

*     Besorge das Aktivierungsdatum aus t_wlk2.
      read table t_wlk2 with key
           matnr = t_marm_data-matnr
           binary search.
    endif. " i_key8 <> i_key9.

    pet_ot3_sets-artnr = t_marm_data-matnr.
    pet_ot3_sets-vrkme = t_marm_data-meinh.
    pet_ot3_sets-datum = t_wlk2-vkdab.

*   Falls das Aktivierungsdatum in der Vergangenheit
*   liegt, dann muß immer Initialisiert werden.
    if t_wlk2-vkdab < pi_erstdat.
      pet_ot3_sets-init  = 'X'.
      pet_ot3_sets-datum = pi_erstdat.
    endif. " t_wlk2-vkdab < PI_ERSTDAT.

    append pet_ot3_sets.
  endloop. " at t_marm_data

* Ermitteln der Anzahl der gefundenen Objekte.
  sort pet_ot3_sets by artnr vrkme.
  clear: i_key8, i_key9.
  loop at pet_ot3_sets.
    move-corresponding pet_ot3_sets to i_key9.
    if i_key8 <> i_key9.
*     Aktualisiere zugehörige statistische Zählvariable.
      add 1 to gi_stat_counter-sets_zus.

      i_key8 = i_key9.
    endif. " i_key8 <> i_key9.
  endloop. " at pet_ot3_sets.

* Übernahme der Daten aus PIT_OT2_SETS.
  clear: i_key8, i_key9.
  loop at pit_ot2_sets.

    move-corresponding pit_ot2_sets to i_key9.
    clear: h_skip.
    clear: h_found.  "OSS 928176
*   Falls dieser Satz durch WLK2-Analyse und durch Änderung auf
*   Vertriebslinienebene entstanden ist.
    if pit_ot2_sets-wlk2 <> space.
*     Prüfe zunächst, ob in PXT_WLK2 filialabhängige
*     WLK2-Sätze existieren.
      read table pxt_wlk2 with key
           matnr = pit_ot2_sets-artnr
           binary search.

*     Falls ein Eintrag gefunden wurde.
      if sy-subrc = 0.
*       Merke die gefundene Tabellenzeile.
        h_tabix = sy-tabix.

        loop at pxt_wlk2  from h_tabix.
*         Abbruchbedingung für Schleife setzen.
          if pxt_wlk2-matnr <> pit_ot2_sets-artnr.
            exit.
          endif.

          if pxt_wlk2-orghier = c_filiale.
*           Falls diese Filiale eine potentielle Kopiermutter für die
*           EAN-Referenzen.
            if pxt_independence_check-sets <> space.
*             Vermerke in Filialcopytabelle, daß diese Filiale keine
*             Kopiermutter für die EAN-Referenzen sein kann.
              clear: pxt_independence_check-sets.
              modify pxt_independence_check index h_index.
            endif. " pxt_independence_check-sets <> space.

*           Setze Flag zum überspringen der restlichen Analyse für
*           diesen Satz in PIT_OT2_EAN.
            h_skip = 'X'.

*           Schleife verlassen.
            exit.
          endif. " pxt_wlk2-orghier = c_filiale.
        endloop.                           " AT PXT_WLK2
      endif. " sy-subrc = 0.

*     Weiter zum nächsten Satz, falls nötig.
      if h_skip <> space.
*       Falls Statistikvariablen aktualisiert werden müssen.
        if i_key8 <> i_key9.
*         Aktualisiere zugehörige statistische Zählvariable.
          add 1 to gi_stat_counter-sets_bew.

          i_key8 = i_key9.
        endif. " i_key8 <> i_key9.

        continue.
      endif. " h_skip <> space.
    endif. " pit_ot2_sets-wlk2 <> space.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pxt_wlk2 with key
         matnr = pit_ot2_sets-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pxt_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pxt_wlk2-matnr <> pit_ot2_sets-artnr.
          exit.
        endif.
        if pxt_wlk2-vkdab <= pi_datp4    and
           pxt_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet, dann wird er übernommen.
    if not h_found is initial.
      move-corresponding pit_ot2_sets to pet_ot3_sets.
      append pet_ot3_sets.

*   Falls der Artikel nicht gelistet und auch kein Löschsatz ist.
    else. " h_found is initial.
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key8 <> i_key9.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-sets_bew.

        i_key8 = i_key9.
      endif. " i_key8 <> i_key9.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PIT_OT2_SETS.

* Übernahme der Daten aus PIT_OT1_F_SETS.
  clear: i_key8, i_key9.
  loop at pit_ot1_f_sets
       where filia = pi_filia_group-filia.
    move-corresponding pit_ot1_f_sets to i_key9.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pxt_wlk2 with key
         matnr = pit_ot1_f_sets-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pxt_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pxt_wlk2-matnr <> pit_ot1_f_sets-artnr.
          exit.
        endif.
        if pxt_wlk2-vkdab <= pi_datp4    and
           pxt_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet ist oder es sich um einen Löschsatz
*   handelt dann wird er übernommen.
    if not h_found is initial or
      (    h_found is initial and pit_ot1_f_sets-upd_flag <> space ).
      move-corresponding pit_ot1_f_sets to pet_ot3_sets.
      append pet_ot3_sets.

*   Falls der Artikel nicht gelistet und auch kein Löschsatz ist.
    else. " h_found is initial...
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key8 <> i_key9.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-sets_bew.

        i_key8 = i_key9.
      endif. " i_key8 <> i_key9.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PIT_OT1_F_SETS


* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Löscheinträge werden nicht berücksichtigt.
* Sortieren der Daten.
  sort pet_ot3_sets by artnr vrkme init descending datum.

* Lösche überflüssige Einträge aus Tabelle PET_OT3_SETS.
  clear: i_key8, i_key9, h_init, h_datum.
  loop at pet_ot3_sets
       where upd_flag <> c_del.
    move-corresponding pet_ot3_sets to i_key9.
    if i_key8 <> i_key9.
      i_key8 = i_key9.
      clear: h_init.
      if pet_ot3_sets-init <> space.
        h_init = 'X'.
        h_datum = pet_ot3_sets-datum.
      endif.                           " PET_OT3_SETS-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key8 = i_key9 and h_init <> space and
           pet_ot3_sets-datum >= h_datum.
      delete pet_ot3_sets.
    endif.                             " I_KEY8 <> I_KEY9.
  endloop.                             " AT PET_OT3_SETS.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT3_SETS.
  clear: i_key5, i_key6.
  loop at pet_ot3_sets
       where upd_flag <> c_del.
    move-corresponding pet_ot3_sets to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
    else.
      delete pet_ot3_sets.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT3_SETS.

* Komprimierung Stufe 3: Lösche überflüssige Einträge.

* Sortieren der Daten.
* sort pet_ot3_sets by artnr vrkme upd_flag descending datum.

* Falls sowohl Änderungs- als auch Löscheinträge erzeugt wurden,
* dann haben die Löscheinträge Priorität, d. h. die Änderungssätze
* werden gelöscht.
* clear: i_key8, i_key9, h_delete, h_datum.
* loop at pet_ot3_sets.
*   move-corresponding pet_ot3_sets to i_key9.
*   if i_key8 <> i_key9.
*     i_key8 = i_key9.
*     clear: h_delete.
*     if pet_ot3_sets-upd_flag = c_del.
*       h_delete = 'X'.
*       h_datum = pet_ot3_sets-datum.
*     endif.                           " PET_OT3_SETS-INIT <> SPACE.
*   Falls bereits eine Löschung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter oder gleich
*   dem Löschdatum ist aus der internen Tabelle gelöscht, da sie durch
*   die Löschung überschrieben werden.
*   elseif i_key8 = i_key9 and h_delete <> space and
*          pet_ot3_sets-datum >= h_datum.
*     delete pet_ot3_sets.
*   endif.                             " I_KEY8 <> I_KEY9.
* endloop.                             " AT PET_OT3_SETS.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-sets <> space.
*   Gibt es überhaupt Änderungen für diesen IDOC-Typ ?
    read table pet_ot3_sets index 1.

*   Falls überhaupt keine Set-Zuordnungen geändert wurden, dann werden
*   auch keine versendet und das Kopiermutter-Flag muß zurückge-
*   nommen werden.
    if sy-subrc <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-sets.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc <> 0.
  endif. " pxt_independence_check-sets <> space.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-sets <> space.
*   Besorge alle filialabhängigen WLK2-Daten im
*   Betrachtungszeitraum.
    perform filia_wlk2_matnr_get
            tables t_wlk2_matnr
            using  pi_filia_group.

*   Prüfe, ob irgendwelche WLK2-Intervalle filialabhängig sind.
    perform filia_wlk2_check
                    tables t_wlk2_matnr
                           pet_ot3_sets
                    using  pi_filia_group
                           returncode.

*   Falls Filialabhängige WLK2-Daten gefunden wurden.
    if returncode <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-sets.
      modify pxt_independence_check index h_index.
    endif. " returncode <> 0.
  endif. " pxt_independence_check-sets <> space.

* Sortieren der Daten.
  sort pet_ot3_sets by artnr vrkme init descending datum.

* Nummeriere die Objektgruppen.
  clear: counter, i_key8, i_key9.
  loop at pet_ot3_sets.
    move-corresponding pet_ot3_sets to i_key9.
    if i_key8 <> i_key9.
      i_key8 = i_key9.
      add 1 to counter.
    endif.                             " I_KEY8 <> I_KEY9.

    pet_ot3_sets-number = counter.
    modify pet_ot3_sets.
  endloop.                             " AT PET_OT3_SETS


endform.                               " OT3_GENERATE_SETS


*eject
************************************************************************
form ot3_generate_nart
     tables pxt_ot1_f_nart         structure gt_ot1_f_nart
            pxt_ot2_nart           structure gt_ot2_nart
            pet_ot3_nart           structure gt_ot3_nart
            pit_ot3_artstm         structure gt_ot3_artstm
            pxt_wlk2               structure gt_wlk2
            pxt_independence_check structure gt_independence_check
            pxt_artdel             structure gt_artdel
            pit_matnr              structure wpmatnr
     using  pi_filia_group         structure gt_filia_group
            pi_erstdat             like syst-datum
            pi_datp3               like syst-datum
            pi_datp4               like syst-datum.
************************************************************************
* FUNKTION:
* Besorge all sich ändernden Gültigkeitsstände einer Filiale, die
* noch nicht durch die Pointeranalyse übernommen wurden und
* erzeuge filialabhängige Objekttabelle PET_OT3_NART. Außerdem
* werden die Objekttabellen OT1 und OT2 in OT3 zusammengemischt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_OT1_F_NART        : N-Artikel: Objekttabelle 1, filialabhängig.

* PXT_OT2_NART          : N-Artikel: Objekttabelle 2, filialunabhängig.

* PET_OT3_NART          : N-Artikel: Objekttabelle 3.

* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3. Alle
*                         potentiell aufzubereitenden Artikel.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PXT_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_MATNR             : Tabelle aller zu betrachtenen Artikel

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: jetziges Versenden + Vorlaufzeit.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: just_init,    " Flag, ob Obj. bereits initialisiert werden soll
        h_init,
        h_skip,
        h_delete,
        h_index    like sy-tabix,
        h_tabix    like sy-tabix,
        h_found,
        h_dummy,
        counter    type i,
        returncode like sy-subrc,
        h_datum    like sy-datum.


* Nur zum Komprimieren der Daten aus PET_OT3_NART.
  data: begin of i_key5,
          artnr like gt_ot3_nart-artnr,
          vrkme like gt_ot3_nart-vrkme,
          datum like gt_ot3_nart-datum,
          init  like gt_ot3_nart-init.
  data: end of i_key5.

* Nur zum Komprimieren der Daten aus PET_OT3_NART.
  data: begin of i_key6.
          include structure i_key5.
  data: end of i_key6.

* Zum Komprimieren von Tabelle PET_OT3_NART (Stufe 1).
  data: begin of i_key8,
          artnr like pet_ot3_nart-artnr,
          vrkme like pet_ot3_nart-vrkme.
  data: end of i_key8.

* Zum Komprimieren von Tabelle PET_OT3_NART (Stufe 1).
  data: begin of i_key9.
          include structure i_key8.
  data: end of i_key9.

* Tabelle zum Zwischenspeichern von Konditionsintervallen.
  data: begin of t_periods occurs 60.
          include structure gt_periods.
  data: end of t_periods.

* Tabelle für Materialnummern aus WLK2.
  data: begin of t_wlk2_matnr occurs 1000.
          include structure gt_filia_wlk2_buf.
  data: end of t_wlk2_matnr.

* Zwischenpuffer für wlk2-Sätze.
  data: begin of t_wlk2 occurs 1000.
          include structure gt_wlk2.
  data: end of t_wlk2.

* Zweiter Zwischenpuffer für Materialnummern aus WLK2.
  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.

* Tabelle für alle zugehörigen MARM-Daten
  data: begin of t_marm_data  occurs 1000.
          include structure gt_marm_buf.
  data: end of t_marm_data.


* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_nart.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  read table pxt_independence_check with key
       filia = pi_filia_group-filia
       binary search.

  h_index = sy-tabix.

* Falls jede Änderung eines Nachzugsartikels auch zur Aufbereitung
* des gleichnamigen Artikels führen soll.
  if not pi_filia_group-foa_art is initial.
*   Übernehme (möglicherweise) filialabhängige Artikelstammänderungen
*   Nachzugsartikel-Tabellen.
    clear: h_dummy.
    loop at pit_ot3_artstm
         where upd_flag = space.
*     Prüfe, ob es sich um einen Nachzugsartikel handelt.
      perform mara_select using mara
                                pit_ot3_artstm-artnr.

*     Falls es sich um einen Nachzugsartikel handelt.
      if mara-matnr <> space and mara-mlgut <> space.
        h_dummy = 'X'.
        clear: pxt_ot1_f_nart.
        move-corresponding pit_ot3_artstm to pxt_ot1_f_nart.
        pxt_ot1_f_nart-filia = pi_filia_group-filia.
        append pxt_ot1_f_nart.
      endif. " mara-matnr <> space and mara-mlgut <> space.
    endloop. " at pit_ot3_artstm.

*   Falls eine mögliche Kopiermutter vorliegt.
    if h_dummy <> space and pxt_independence_check-nart <> space.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-nart.
      modify pxt_independence_check index h_index.
    endif. " h_dummy <> space and ...

  endif. " not pi_filia_group-foa_art is initial.

* Prüfe, ob Artikel innerhalb des Zeitintervalls
* PI_ERSTDAT und PI_DATP4 von dieser Filiale der
* Gruppe bewirtschaftet werden.
  read table pxt_wlk2 index 1.

* Falls interne Bewirtschaftungstabelle nicht gefüllt ist, dann
* besorge Bewirtschaftungen von DB.
  if sy-subrc <> 0 or pxt_wlk2-werks <> pi_filia_group-filia.
*   Prüfe, ob potentielle Versendeartikel vorliegen.
    read table pit_matnr index 1.

*   Falls keine Artikel gefunden wurden.
    if sy-subrc <> 0.
*     Falls eine mögliche Kopiermutter vorliegt.
      if pxt_independence_check-nart <> space.
*       Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
        read table pxt_independence_check index h_index.
        clear: pxt_independence_check-nart.
        modify pxt_independence_check index h_index.
      endif. " pxt_independence_check-nart <> space.

*     Keine weitere Aufbereitung nötig.
      exit.
    endif. " sy-subrc <> 0.
* B: New listing check logic => Note 1982796
   IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
      AND gs_twpa-marc_chk IS NOT INITIAL.
   ELSE.
*   Setze untere Intervallgrenzen des Betrachtungszeitraums.
*   Anmerkung: Bei einer Auslistung wird das BIS-Datum des
*   Bewirtschaftungszeitraums auf Gestern gesetzt. Damit der Artikel
*   nicht herausgefiltert wird, wird die untere Intervallgrenze auf den
*   Vortag des letzten Versendens gesetzt (Zeitpunkt P1 - 1).
    h_datum = pi_filia_group-datab - 1.

*   Führe notwendige Prüfungen durch und besorge die zugehörigen
*   WLK2-Daten.
    call function 'WLK2_MATERIAL_FOR_FILIA'
      EXPORTING
        pi_vkorg        = pi_filia_group-vkorg
        pi_vtweg        = pi_filia_group-vtweg
        pi_filia        = pi_filia_group-filia
        pi_datab        = h_datum
        pi_datbi        = pi_datp4
      TABLES
        wlk2_input      = pxt_wlk2
        pit_matnr       = pit_matnr
      EXCEPTIONS
        werks_not_found = 01
        no_wlk2         = 02
        no_wlk2_listing = 03.
  endif. " sy-subrc <> 0 or pxt_wlk2-werks <> pi_filia_group-filia.
 ENDIF.
* Prefetch für MARA-Puffer, falls nötig.
  perform mara_prefetch tables pxt_wlk2.

* Übernehme alle Nachzugsartikel, die innerhalb des Zeitintervalls
* PI_DATP3 und PI_DATP4 bewirtschaftet werden und eine
* Änderung erfahren haben in Tabelle PET_OT3_NART.
* clear: pet_ot3_nart.
* loop at pxt_wlk2
*      where vkdab <= pi_datp4
*      and   vkbis >  pi_datp3.

************************************************************************
* Solange Nachzugsartikel noch nicht für die Zukunft geändert werden
* können, ist diese Schleife nicht nötig. --> Schleife verlassen.
*exit.
************************************************************************

*   Prüfe, ob es sich um einen Nachzugsartikel handelt.
*   perform mara_select using mara
*                             pxt_wlk2-matnr.

*   Falls es sich um einen Nachzugsartikel handelt.
*   if mara-matnr <> space and mara-mlgut <> space.
*     clear: pet_ot3_nart.
*     refresh: t_matnr.
*     append pxt_wlk2-matnr to t_matnr.
*     perform marm_select tables t_matnr
*                                gt_vrkme
*                         using  'X'   ' '   ' '.
*     Bestimme alle Verkaufsmengeneinheiten des Artikels
*     aus Tabelle MARM, die eine EAN besitzen.
*     refresh: gt_vrkme.
*     clear:   gt_vrkme.
*     select * from  marm
*            into corresponding fields of table gt_vrkme
*            where matnr  = pxt_wlk2-matnr
*            and   ean11 <> space.

*     Schleife über alle Verkaufsmengeneinheiten.
*     loop at gt_vrkme.
*       Prüfe, ob dieses Objekt bereits initialisiert werden soll.
*       just_init = 'X'.
*       read table pxt_ot1_f_nart with key
*            filia = pi_filia_group-filia
*            artnr = pxt_wlk2-matnr
*            vrkme = gt_vrkme-meinh
*            init  = 'X'
*            binary search.

*       if sy-subrc <> 0.
*         read table pxt_ot2_nart with key
*              artnr = pxt_wlk2-matnr
*              vrkme = gt_vrkme-meinh
*              init  = 'X'
*              binary search.

*         Objekt soll nicht initialisiert werden. Es muß also weiter
*         überprüft werden.
*         if sy-subrc <> 0.
*           clear: just_init.
*         endif.                     " SY-SUBRC <> 0.
*       endif.                       " SY-SUBRC <> 0.

*       Falls Objekt weiter überprüft werden soll.
*       if just_init = space.
*         if pi_datp3 < pi_datp4.
*           h_datum = pi_datp3 + 1.

*           Bestimme die Intervallgrenzen des Nachzugsartikels
*           im Zeitintervall PI_DATP3 und PI_DATP4.
*           refresh: gt_nart_komp.
*           call function 'MGW0_PACKAGING_COMPONENTS'
*                exporting
*                     mgw0_article    = pxt_wlk2-matnr
*                     mgw0_date_from  = h_datum
*                     mgw0_date_to    = pi_datp4
*                     mgw0_plant      = '    '
*                     mgw0_unit       = gt_vrkme-meinh
*                tables
*                     mgw0_components = gt_nart_komp
*                exceptions
*                     not_found       = 01.

*           loop at gt_nart_komp.
*             Nur die DATAB-Zeitpunkte des N-Artikel-Intervalls
*             müssen berücksichtigt werden.
*             if gt_nart_komp-datuv >= h_datum.
*               Falls die Gültigkeit des Nachzugsart. bereits
*               abgelauen ist, dann braucht auch nicht versendet
*               zu werden.
*               if gt_nart_komp-datub < pi_erstdat.
*                 continue.
*               endif. " gt_nart_komp-datub < pi_erstdat.

*               Fülle Objekttabelle 3 (filialabhängig).
*               pet_ot3_nart-artnr = pxt_wlk2-matnr.
*               pet_ot3_nart-vrkme = gt_vrkme-meinh.
*               clear: pet_ot3_nart-upd_flag.
*               clear: pet_ot3_nart-init.

*               Das kleinste Versendedatum ist immer PI_ERSTDAT.
*               if gt_nart_komp-datuv < pi_erstdat.
*                 pet_ot3_nart-datum = pi_erstdat.
*               else. " gt_nart_komp-datuv >= pi_erstdat.
*                 pet_ot3_nart-datum = gt_nart_komp-datuv.
*               endif. " gt_nart_komp-datuv < pi_erstdat.

*               append pet_ot3_nart.
*             endif.                   " GT_SET_KOMP-DATUV >= H_DATUM
*           endloop.                   " AT GT_SET_KOMP.
*         endif. " pi_datp3 < pi_datp4.
*       endif.                       " JUST_INIT = SPACE.
*     endloop.                       " AT GT_VRKME.
*   endif.               " mara-matnr <> space and mara-mlgut <> space.
* endloop.                             " AT PXT_WLK2.

* Bestimme alle Objekte, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht.
  perform wlk2_intervals_check
          tables t_marm_data
                 t_wlk2
                 pxt_wlk2
                 pxt_independence_check
                 pet_ot3_nart
                 pxt_artdel
          using  pi_filia_group     c_mestype_nart
                 pi_datp3           pi_datp4
                 h_index.

* Übernahme der gefundenen Objekte nach OT3.
  clear: i_key8, i_key9.
  loop at t_marm_data.
    clear: pet_ot3_nart.
    move t_marm_data-matnr to i_key9-artnr.

    if i_key8 <> i_key9.
      i_key8 = i_key9.

*     Besorge die MARA-Daten des Artikels.
      perform mara_select using mara
                                t_marm_data-matnr.

*     Falls der Artikel kein Nachzugsartikel ist.
      if mara-mlgut = space.
*       Weiter zum nächsten Satz.
        continue.
      endif. " mara-mlgut = space.

*     Besorge das Aktivierungsdatum aus t_wlk2.
      read table t_wlk2 with key
           matnr = t_marm_data-matnr
           binary search.
    endif. " i_key8 <> i_key9.

    pet_ot3_nart-artnr = t_marm_data-matnr.
    pet_ot3_nart-vrkme = t_marm_data-meinh.
    pet_ot3_nart-datum = t_wlk2-vkdab.

*   Falls das Aktivierungsdatum in der Vergangenheit
*   liegt, dann muß immer Initialisiert werden.
    if t_wlk2-vkdab < pi_erstdat.
      pet_ot3_nart-init  = 'X'.
      pet_ot3_nart-datum = pi_erstdat.
    endif. " t_wlk2-vkdab < PI_ERSTDAT.

    append pet_ot3_nart.
  endloop. " at t_marm_data

* Ermitteln der Anzahl der gefundenen Objekte
  sort pet_ot3_nart by artnr vrkme.
  clear: i_key8, i_key9.
  loop at pet_ot3_nart.
    move-corresponding pet_ot3_nart to i_key9.
    if i_key8 <> i_key9.
*     Aktualisiere zugehörige statistische Zählvariable.
      add 1 to gi_stat_counter-nart_zus.

      i_key8 = i_key9.
    endif. " i_key8 <> i_key9.
  endloop. " at pet_ot3_nart.

* Übernahme der Daten aus PIT_OT2_NART.
  clear: i_key8, i_key9.
  loop at pxt_ot2_nart.

    move-corresponding pxt_ot2_nart to i_key9.
    clear: h_skip.
    clear: h_found.  "OSS 928176

*   Falls dieser Satz durch WLK2-Analyse und durch Änderung auf
*   Vertriebslinienebene entstanden ist.
    if pxt_ot2_nart-wlk2 <> space.
*     Prüfe zunächst, ob in PXT_WLK2 filialabhängige
*     WLK2-Sätze existieren.
      read table pxt_wlk2 with key
           matnr = pxt_ot2_nart-artnr
           binary search.

*     Falls ein Eintrag gefunden wurde.
      if sy-subrc = 0.
*       Merke die gefundene Tabellenzeile.
        h_tabix = sy-tabix.

        loop at pxt_wlk2  from h_tabix.
*         Abbruchbedingung für Schleife setzen.
          if pxt_wlk2-matnr <> pxt_ot2_nart-artnr.
            exit.
          endif.

          if pxt_wlk2-orghier = c_filiale.
*           Falls diese Filiale eine potentielle Kopiermutter für die
*           EAN-Referenzen.
            if pxt_independence_check-nart <> space.
*             Vermerke in Filialcopytabelle, daß diese Filiale keine
*             Kopiermutter für die EAN-Referenzen sein kann.
              clear: pxt_independence_check-nart.
              modify pxt_independence_check index h_index.
            endif. " pxt_independence_check-NART <> space.

*           Setze Flag zum überspringen der restlichen Analyse für
*           diesen Satz in PIT_OT2_EAN.
            h_skip = 'X'.

*           Schleife verlassen.
            exit.
          endif. " pxt_wlk2-orghier = c_filiale.
        endloop.                           " AT PXT_WLK2
      endif. " sy-subrc = 0.

*     Weiter zum nächsten Satz, falls nötig.
      if h_skip <> space.
*       Falls Statistikvariablen aktualisiert werden müssen.
        if i_key8 <> i_key9.
*         Aktualisiere zugehörige statistische Zählvariable.
          add 1 to gi_stat_counter-nart_bew.

          i_key8 = i_key9.
        endif. " i_key8 <> i_key9.

        continue.
      endif. " h_skip <> space.
    endif. " pxt_ot2_nart-wlk2 <> space.

*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pxt_wlk2 with key
         matnr = pxt_ot2_nart-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pxt_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pxt_wlk2-matnr <> pxt_ot2_nart-artnr.
          exit.
        endif.
        if pxt_wlk2-vkdab <= pi_datp4    and
           pxt_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet, dann wird er übernommen.
    if not h_found is initial.

      move-corresponding pxt_ot2_nart to pet_ot3_nart.
      append pet_ot3_nart.

*   Falls der Artikel nicht gelistet und auch kein Löschsatz ist.
    else. " h_found is initial
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key8 <> i_key9.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-nart_bew.

        i_key8 = i_key9.
      endif. " i_key8 <> i_key9.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PXT_OT2_NART.

* Übernahme der Daten aus PIT_OT1_F_NART.
  clear: i_key8, i_key9.
  loop at pxt_ot1_f_nart
       where filia = pi_filia_group-filia.
    move-corresponding pxt_ot1_f_nart to i_key9.
*   Prüfe, ob der Artikel innerhalb des Zeitintervalls PI_ERSTDAT
*   und PI_DATP4 bewirtschaftet wird.
    read table pxt_wlk2 with key
         matnr = pxt_ot1_f_nart-artnr
         binary search.

*   Falls ein Eintrag gefunden wurde.
    if sy-subrc = 0.
*     Merke die gefundene Tabellenzeile.
      h_tabix = sy-tabix.

      clear: h_found.
      loop at pxt_wlk2  from h_tabix.
*       Abbruchbedingung für Schleife setzen.
        if pxt_wlk2-matnr <> pxt_ot1_f_nart-artnr.
          exit.
        endif.
        if pxt_wlk2-vkdab <= pi_datp4    and
           pxt_wlk2-vkbis >= pi_erstdat.
*         Bewirtschaftung bestätigt --> Schleife beenden.
          h_found = 'X'.
          exit.
        endif.
      endloop.                           " AT PET_WLK2
    endif. " sy-subrc = 0.

*   Falls der Artikel gelistet ist oder es sich um einen Löschsatz
*   handelt dann wird er übernommen.
    if   not h_found is initial or
       (     h_found is initial and pxt_ot1_f_nart-upd_flag <> space ).
      move-corresponding pxt_ot1_f_nart to pet_ot3_nart.
      append pet_ot3_nart.

*   Falls der Artikel nicht gelistet und auch kein Löschsatz ist.
    else. " h_found is initial...
*     Falls Statistikvariablen aktualisiert werden müssen.
      if i_key8 <> i_key9.
*       Aktualisiere zugehörige statistische Zählvariable.
        add 1 to gi_stat_counter-nart_bew.

        i_key8 = i_key9.
      endif. " i_key8 <> i_key9.
    endif.                             " SY-SUBRC = 0.
  endloop.                             " AT PXT_OT1_F_NART


* Komprimierung Stufe 1: Berücksichtige Initialisierungen.
* Löscheinträge werden nicht berücksichtigt.
* Sortieren der Daten.
  sort pet_ot3_nart by artnr vrkme init descending datum.

* Lösche überflüssige Einträge aus Tabelle PET_OT3_NART.
  clear: i_key8, i_key9, h_init, h_datum.
  loop at pet_ot3_nart
       where upd_flag <> c_del.
    move-corresponding pet_ot3_nart to i_key9.
    if i_key8 <> i_key9.
      i_key8 = i_key9.
      clear: h_init.
      if pet_ot3_nart-init <> space.
        h_init = 'X'.
        h_datum = pet_ot3_nart-datum.
      endif.                           " PET_OT3_NART-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    elseif i_key8 = i_key9 and h_init <> space and
           pet_ot3_nart-datum >= h_datum.
      delete pet_ot3_nart.
    endif.                             " I_KEY8 <> I_KEY9.
  endloop.                             " AT PET_OT3_NART.

* Komprimierung Stufe 2: Lösche doppelte Einträge.
* Lösche doppelte Einträge aus PET_OT3_NART.
  clear: i_key5, i_key6.
  loop at pet_ot3_nart
       where upd_flag <> c_del.
    move-corresponding pet_ot3_nart to i_key6.
    if i_key5 <> i_key6.
      i_key5 = i_key6.
    else.
      delete pet_ot3_nart.
    endif.                             " I_KEY5 <> I_KEY6.
  endloop.                             " AT PET_OT3_NART.

* Komprimierung Stufe 3: Lösche überflüssige Einträge.

* Sortieren der Daten.
* sort pet_ot3_nart by artnr vrkme upd_flag descending datum.

* Falls sowohl Änderungs- als auch Löscheinträge erzeugt wurden,
* dann haben die Löscheinträge Priorität, d. h. die Änderungssätze
* werden gelöscht.
* clear: i_key8, i_key9, h_delete, h_datum.
* loop at pet_ot3_nart.
*   move-corresponding pet_ot3_nart to i_key9.
*   if i_key8 <> i_key9.
*     i_key8 = i_key9.
*     clear: h_delete.
*     if pet_ot3_nart-upd_flag = c_del.
*       h_delete = 'X'.
*       h_datum = pet_ot3_nart-datum.
*     endif.                           " PET_OT3_NART-INIT <> SPACE.
*   Falls bereits eine Löschung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter oder gleich
*   dem Löschdatum ist aus der internen Tabelle gelöscht, da sie durch
*   die Löschung überschrieben werden.
*   elseif i_key8 = i_key9 and h_delete <> space and
*          pet_ot3_nart-datum >= h_datum.
*     delete pet_ot3_nart.
*   endif.                             " I_KEY8 <> I_KEY9.
* endloop.                             " AT PET_OT3_NART.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-nart <> space.
*   Gibt es überhaupt Änderungen für diesen IDOC-Typ ?
    read table pet_ot3_nart index 1.

*   Falls überhaupt keine Nachzugsartikel geändert wurden, dann werden
*   auch keine versendet und das Kopiermutter-Flag muß zurückge-
*   nommen werden.
    if sy-subrc <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-nart.
      modify pxt_independence_check index h_index.
    endif. " sy-subrc <> 0.
  endif. " pxt_independence_check-nart <> space.

* Falls eine mögliche Kopiermutter vorliegt.
  if pxt_independence_check-nart <> space.
*   Besorge alle filialabhängigen WLK2-Daten im
*   Betrachtungszeitraum.
    perform filia_wlk2_matnr_get
            tables t_wlk2_matnr
            using  pi_filia_group.

*   Prüfe, ob irgendwelche WLK2-Intervalle filialabhängig sind.
    perform filia_wlk2_check
                    tables t_wlk2_matnr
                           pet_ot3_nart
                    using  pi_filia_group
                           returncode.

*   Falls Filialabhängige WLK2-Daten gefunden wurden.
    if returncode <> 0.
*     Sorge dafür, daß diese Filiale keine weitere Kopiermutter wird.
      read table pxt_independence_check index h_index.
      clear: pxt_independence_check-nart.
      modify pxt_independence_check index h_index.
    endif. " returncode <> 0.
  endif. " pxt_independence_check-nart <> space.

* Sortieren der Daten.
  sort pet_ot3_nart by artnr vrkme init descending datum.

* Nummeriere die Objektgruppen.
  clear: counter, i_key8, i_key9.
  loop at pet_ot3_nart.
    move-corresponding pet_ot3_nart to i_key9.
    if i_key8 <> i_key9.
      i_key8 = i_key9.
      add 1 to counter.
    endif.                             " I_KEY8 <> I_KEY9.

    pet_ot3_nart-number = counter.
    modify pet_ot3_nart.
  endloop.                             " AT PET_OT3_NART


endform.                               " OT3_GENERATE_NART


*eject
************************************************************************
form ot3_generate_pers
     tables  pit_ot1_k_pers         structure gt_ot1_k_pers
             pit_ot2_pers           structure gt_ot2_pers
             pet_ot3_pers           structure gt_ot3_pers
             pxt_independence_check structure gt_independence_check
     using   pi_filia_group         structure gt_filia_group.
************************************************************************
* FUNKTION:
* Übernehme die Daten aus den Objekttabellen OT1 und OT2
* nach PET_OT3_PERS.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT1_K_PERS        : Personendaten: Objekttabelle 1,
*                         Kreditkontrollbereichsabhängig.
* PIT_OT2_PERS          : Personendaten: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_PERS          : Personendaten: Objekttabelle 3,
*                         filialabhängig.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_kkber  like  t001-kkber,
        h_index  like  sy-tabix,
        h_count1 type i,
        h_count2 type i.

* Zum Komprimieren von Tabelle PET_OT3_PERS.
  data: begin of i_key1,
          kunnr like gt_ot3_pers-kunnr.
  data: end of i_key1.

* Zum Komprimieren von Tabelle PET_OT3_PERS.
  data: begin of i_key2.
          include structure i_key1.
  data: end of i_key2.


* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_pers.

* Besorge zugehörigen Satz in Filialcopy-Tabelle und merke,
* ob diese Filiale Kreditkontrollbereichsabhängige Daten
* enthält.
  read table pxt_independence_check with key
       filia = pi_filia_group-filia
       binary search.

  h_index = sy-tabix.
  h_kkber = pxt_independence_check-kkber.

  if pxt_independence_check-pers <> space.
*   Prüfe, ob es bereits eine Kopiermutter für die Personendaten
*   dieser Filiale gibt.
    loop at pxt_independence_check
         where filia <  pi_filia_group-filia
         and   vkorg =  pi_filia_group-vkorg
         and   vtweg =  pi_filia_group-vtweg
         and   kkber =  h_kkber
         and   pers  <> space
         and   ok    <> space.
      exit.
    endloop. " at pxt_independence_check

*   Falls eine Kopiermutter existiert, dann braucht nicht weiter
*   aufbereitet zu werden.
    if sy-subrc = 0.
*     Weitere aufbereitung verlassen.
      exit.
    endif. " sy-subrc = 0.
  endif. " pxt_independence_check-pers <> space.

* Prüfe, ob pit_ot2_pers Daten enthält.
  read table pit_ot2_pers index 1.

* Falls pit_ot2_pers Daten enthält, dann müssen diese
* übernommen werden.
  if sy-subrc = 0.
*   Besorge alle Kundennummern, die in PET_OT2_PERS vorkommen und zur
*   Vertriebsschiene der Filiale gehören.
    select kunnr from knvv
           into (knvv-kunnr)
           for all entries in pit_ot2_pers
           where kunnr = pit_ot2_pers-kunnr
           and   vkorg = pi_filia_group-vkorg
           and   vtweg = pi_filia_group-vtweg
           and   spart = pi_filia_group-spart.

*###  Möglichkeit der
*     Pufferung, wenn VKORG und VTWEG für die nächste Filiale identisch.
*     und keine 'K'-Einträge in pit_ot2_pers.

*     Prüfe, ob dieser Eintrag in pit_ot2_pers durch Änderung des
*     Gesamtkreditlimits zustande kam.
      read table pit_ot2_pers with key
                 kunnr    = knvv-kunnr
                 upd_flag = c_gklim
                 binary search.

*     Falls dieser Eintrag in pit_ot2_pers durch Änderung des
*     Gesamtkreditlimits zustande kam.
      if sy-subrc = 0.
*       Prüfe, ob es bereits ein Einzelkreditlimit für diese KUNNR und
*       dem KKBER dieser Filiale gibt. In diesem Fall braucht die
*       Änderung nicht berücksichtigt zu werden.
        select klimk    from  knkk
               into (knkk-klimk)
               where kunnr = knvv-kunnr
               and   kkber = pi_filia_group-kkber.
          exit.
        endselect. " from  knkk

*       Falls es kein Einzelkreditlimit gibt, dann muß die Änderung
*       berücksichtigt werden.
        if sy-subrc <> 0 or
           ( sy-subrc = 0 and knkk-klimk is initial ).
          pet_ot3_pers-kunnr = knvv-kunnr.
          append pet_ot3_pers.
        endif. " sy-subrc <> 0 or ...

*     Falls dieser Eintrag in pit_ot2_pers nicht durch Änderung des
*     Gesamtkreditlimits zustande kam, dann wird er übernommen.
      else. " sy-subrc <> 0.
        pet_ot3_pers-kunnr = knvv-kunnr.
        append pet_ot3_pers.
      endif. " sy-subrc <> 0.        READ TABLE
    endselect.                           " * FROM KNVV

    sort pet_ot3_pers by kunnr.
  endif. " sy-subrc = 0.

* Aktualisiere statistische Zählvariable.
  describe table pit_ot2_pers lines h_count1.
  describe table pet_ot3_pers lines h_count2.
  gi_stat_counter-pers_gklim = h_count1 - h_count2.

***************************************
* Bei Lösch-Pointern für KNA1 muß auch ein KNVV-Lösch-Pointer erzeugt
* werden, damit festgestellt werden kann zu welcher Vertriebsschiene
* die gelöschte Kundennummer gehörte. PET_OT2_PERS muß dann noch um die
* Felder VKORG und VTWEG erweitert werden.
***************************************

* Übernahme aller Kundennummern aus PIT_OT1_K_PERS, deren
* Kreditkontrollbereich mit dem der gerade bearbeiteten
* Filiale übereinstimmen.
  loop at pit_ot1_k_pers
       where kkber = pi_filia_group-kkber.

    pet_ot3_pers-kunnr = pit_ot1_k_pers-kunnr.
    append pet_ot3_pers.

  endloop.                             " AT PIT_OT2_WRGP.

* Komprimierung Stufe 1:
* Lösche doppelte Einträge aus PET_OT3_PERS.
  sort pet_ot3_pers by kunnr.
  clear: i_key1, i_key2.
  loop at pet_ot3_pers
       where upd_flag <> c_del.
    move-corresponding pet_ot3_pers to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
    else.
      delete pet_ot3_pers.
    endif.                             " I_KEY1 <> I_KEY2.
  endloop.                             " AT PET_OT3_PERS.


endform.                               " OT3_GENERATE_PERS


* eject
************************************************************************
form wlk2_pointer_analyse
     tables pxt_ot1_f_artstm structure gt_ot1_f_artstm
            pxt_ot2_artstm   structure gt_ot2_artstm
            pit_filia_group  structure gt_filia_group
     using  pi_pointer       structure bdcp
            pi_erstdat       like syst-datum
            pi_group         like gt_filia_group-group.
************************************************************************
* FUNKTION:                                                            *
* Analyse des WLK2-Pointers für Artikelstammsätze.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_OT1_F_ARTSTM: Artikelstamm: Objekttabelle 1, filialabhängig.

* PXT_OT2_ARTSTM  : Artikelstamm: Objekttabelle 2, filialunabhängig.

* PIT_FILIA_GROUP : Tabelle für Filialkonstanten der Gruppe.

* PI_POINTER      : Der zu analysierende Änderungspointer.

* PI_ERSTDAT      : Datum: jetziges Versenden.

* PI_GROUP        : Filialgruppe, die gerade bearbeitet wird.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle für WLK2-Sätze.
  data: begin of t_wlk2 occurs 1.
          include structure wlk2.
  data: end of t_wlk2.

* Tabelle für Materialnummern.
  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.


* Gelöschte WLK2-Daten werden nicht berücksichtigt.
  if pi_pointer-cdchgid <> c_del.
*   Lese betroffenen WLK2-Satz.
    call function 'WLK2_READ'
      EXPORTING
        wlk2             = wlk2
      TABLES
        wlk2_input       = t_wlk2
      EXCEPTIONS
        no_rec_found     = 01
        key_not_complete = 02.

    read table t_wlk2 index 1.

*   Bestimme alle Verkaufsmengeneinheiten des Artikels
*   aus Tabelle MARM, die eine EAN besitzen.
    refresh: t_matnr.
    append t_wlk2-matnr to t_matnr.
    perform marm_select tables t_matnr
                               gt_vrkme
                        using  'X'   ' '   ' '.

*   Prüfe, ob VRKME's gefunden wurden.
    read table gt_vrkme index 1.

*   Falls keine VRKME's gefunden wurden.
    if sy-subrc <> 0.
*     WLK2-Analyse verlassen.
      exit.
    endif. " sy-subrc <> 0.

*   Falls der T_WLK2-Satz Gültigkeit auf Konzern- oder
*   auf Vertriebslinienebene (dieser Vertriebslinie) hat.
    if  t_wlk2-vkorg = space  or
      ( t_wlk2-werks = space                  and
        t_wlk2-vkorg = pit_filia_group-vkorg  and
        t_wlk2-vtweg = pit_filia_group-vtweg ).
*     Fülle Objekttabelle 2 (filialunabhängig).
      pxt_ot2_artstm-datum = pi_pointer-acttime(8).
      pxt_ot2_artstm-artnr = t_wlk2-matnr.
      pxt_ot2_artstm-init  = 'X'.
      clear: pxt_ot2_artstm-upd_flag.

*     Merken, das der Pointer aufgrund einer
*     Materialstammänderung erzeugt wurde.
      pxt_ot2_artstm-aetyp_sort = c_mat_sort_index.

      if t_wlk2-vkorg = space.
        pxt_ot2_artstm-wlk2  = c_konzern.
      else. " t_wlk2-werks = space
        pxt_ot2_artstm-wlk2  = c_vertriebslinie.
      endif. " t_wlk2-vkorg = space

*     Falls das Aktivierungsdatum des Pointers in der
*     Vergangenheit liegt, dann setze auf Versendedatum.
      if pi_pointer-acttime(8) < pi_erstdat.
        pxt_ot2_artstm-datum = pi_erstdat.
      endif. " PI_POINTER-ACTTIME(8) < PI_ERSTDAT.

      loop at gt_vrkme.
        pxt_ot2_artstm-vrkme = gt_vrkme-meinh.
        append pxt_ot2_artstm.
      endloop.                   " AT GT_VRKME.

*   Falls Filiale bekannt und dieser Vertriebslinie
*   zugehörig.
    elseif t_wlk2-werks <> space                 and
           t_wlk2-vkorg = pit_filia_group-vkorg  and
           t_wlk2-vtweg = pit_filia_group-vtweg.
*     Prüfe, ob diese Filiale in der gerade
*     bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*     dürfen berücksichtigt werden.
      read table pit_filia_group with key
           group = pi_group
           filia = t_wlk2-werks
           binary search.

      if sy-subrc = 0.
*       Fülle Objekttabelle 1 (filialabhängig).
        pxt_ot1_f_artstm-datum = pi_pointer-acttime(8).
        pxt_ot1_f_artstm-artnr = t_wlk2-matnr.
        pxt_ot1_f_artstm-filia = t_wlk2-werks.
        pxt_ot1_f_artstm-init  = 'X'.
        clear: pxt_ot1_f_artstm-upd_flag.

*       Merken, das der Pointer aufgrund einer
*       Materialstammänderung erzeugt wurde.
        pxt_ot1_f_artstm-aetyp_sort = c_mat_sort_index.

*       Falls das Aktivierungsdatum des Pointers in der
*       Vergangenheit liegt, dann setze auf Versendedatum.
        if pi_pointer-acttime(8) < pi_erstdat.
          pxt_ot1_f_artstm-datum = pi_erstdat.
        endif. " PI_POINTER-ACTTIME(8) < PI_ERSTDAT.

        loop at gt_vrkme.
          pxt_ot1_f_artstm-vrkme = gt_vrkme-meinh.
          append pxt_ot1_f_artstm.
        endloop.                 " AT GT_VRKME.
      endif.                     " SY-SUBRC = 0.
    endif.                       " T_WLK2-VKORG = SPACE OR ...
  endif.                         " PIT_POINTER-CDCHGID <> c_del.


endform. " wlk2_pointer_analyse

* eject
************************************************************************
form wrsz_pointer_analyse
     tables pet_filia_matnr  structure gt_filia_matnr_buf
            pit_pointer      structure bdcp
            pit_filia_group  structure gt_filia_group
     using  pi_erstdat       like      syst-datum.
************************************************************************
* FUNKTION:                                                            *
* Analyse von Änderungen in der Zuordnung: Filiale zu Sortiment.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_FILIA_MATNR : Aufzubereitende Artikel pro Filiale.
*
* PIT_POINTER     : Tabelle der zu Analysierenden Änderungspointer.
*
* PIT_FILIA_GROUP : Konstanten einer Gruppe von Filialen.
*
* PI_ERSTDAT      : Datum: jetziges Versenden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_tabix      like sy-tabix,
        h_tabix2     like sy-tabix,
        h_refwerks   type werks_ref,
        h_dummy,
        h_dummy2.

* Struktur zur Aufnahme von WRSZ-Daten
  data: i_wrsz like wrsz.

* Tabelle zur Aufnahme von WRSZ-Daten
  data: t_wrsz  like wrsz  occurs 0 with header line,
        t_wrefa type wrefa occurs 0 with header line,
        t_matnr type pre03 occurs 0 with header line.

* Tabelle für Abhängigkeit Sortiment zu Filiale
  data: begin of t_asort_filia occurs 0,
          asort like wrsz-asort,
          locnr like wrsz-locnr,
          ref   like wpstruc-modus.
  data: end of t_asort_filia.


* Initialisiere Ausgabetabelle.
  refresh: pet_filia_matnr.
  clear:   pet_filia_matnr.

* Prüfe, ob diese Analyse bereits stattgefunden hat.
  read table pit_filia_group index 1.

  read table gt_filia_matnr_buf with key
       locnr = pit_filia_group-kunnr
       binary search.

* Falls diese Analyse bereits für diese Filialgruppe
* stattgefunden hat, dann übernehme Pufferdaten.
  if sy-subrc = 0.
    pet_filia_matnr[] = gt_filia_matnr_buf[].

*   Unterprogramm verlassen.
    exit.
  endif.

* Analysiere Änderungen bezüglich  n:m Zuordnung (WRSZ-Pointer)
  read table pit_pointer with key
       cdobjcl = c_objcl_wrs1
       tabname = 'WRSZ'
       binary search
       transporting no fields.

  if sy-subrc = 0.
    h_tabix = sy-tabix.

*   Kommuliere WRSZ-Pointer
    loop at pit_pointer from h_tabix.

*     Verlassen der Schleife, wenn letzter relevante Eintrag
*     gelesen wurde.
      if pit_pointer-tabname <> 'WRSZ'.
        exit.
      endif. " pit_pointer-tabname <> 'WRSZ'.

*     Übernehme Schlüssel in WRSZ.
      wrsz = pit_pointer-tabkey(18).

      call function 'WRSZ_SINGLE_READ'
        EXPORTING
          asort           = wrsz-asort
          lfdnr           = wrsz-lfdnr
        IMPORTING
          wrsz_out        = i_wrsz
        EXCEPTIONS
          no_record_found = 1
          others          = 2.

      if sy-subrc <> 0.
*       Ein Eintrag muss an einem Tag angelegt und wieder
*       gelöscht worden sein.
        continue.
      endif.

*     Falls der Pointer auf eine "Löschung" eines WRSZ-Satzes
*     hindeutet, deren Anlage vor mehr als einen Tag stattfand.
      if pit_pointer-cdchgid = 'U' and
         pit_pointer-fldname = 'DATBI'.

*       Prüfe, ob der WRSZ-Eintrag schon gespeichert wurde.
        read table t_wrsz with key
             asort = i_wrsz-asort
             lfdnr = i_wrsz-lfdnr
             binary search.

        h_tabix2 = sy-tabix.

*       Falls der WRSZ-Eintrag schon gespeichert wurde,
*       dann bedeutet das, dass seit dem letzten Download zuerst
*       eine Zuordnung angelegt wurde, die jetzt wieder gelöscht
*       werden soll.
*       ==> in diesem Falle ist ein Download nicht erfordelich, d. h.
*           der bereits gespeicherte Eintrag kann wieder gelöscht
*           werden.
        if sy-subrc = 0.
          delete t_wrsz index h_tabix2.
          continue.
*       Falls der WRSZ-Eintrag noch nicht gespeichert wurde,
*       dann bedeutet das nur, dass eine Zuordnung wieder gelöscht
*       werden soll.
*       ==> in diesem Falle ist ein Download ebenfalls nicht
*           erforderlich.
        else. " sy-subrc <> 0
          continue.
        endif. " sy-subrc = 0.

*     Falls der Pointer auf eine Neuanlage eines WRSZ-Satzes
*     hindeutet.
      elseif pit_pointer-cdchgid = 'I' and
             pit_pointer-fldname = 'KEY'.
*       Übernehme Eintrag in Zwischentabelle, falls nötig.
        read table t_wrsz with key
             asort = i_wrsz-asort
             lfdnr = i_wrsz-lfdnr
             binary search.

        if sy-subrc <> 0.
          t_wrsz = i_wrsz.
          insert t_wrsz index sy-tabix.
        endif. " sy-subrc <> 0.
      endif. " pit_pointer-cdchgid = 'U' and ...
    endloop. " at pit_pointer from h_tabix.
  endif." sy-subrc = 0.

* Sortieren der Daten.
  sort t_wrsz          by locnr.
  sort pit_filia_group by kunnr.

* Weitere Komprimierung: Lösche alle nicht relevanten
* Filialeinträge in t_wrsz.
  loop at t_wrsz.
    clear: h_dummy.

*   Prüfe, ob die Filiale in dieser Zuordnung in dieser
*   Filialgruppe vorkommt.
    read table pit_filia_group with key
         kunnr = t_wrsz-locnr
         binary search.

*   Falls die Filiale in dieser Zuordnung in dieser
*   Filialgruppe vorkommt, dann Eintrag merken.
    if sy-subrc = 0.
      clear: t_asort_filia.
      t_asort_filia-asort = t_wrsz-asort.
      t_asort_filia-locnr = t_wrsz-locnr.
      append t_asort_filia.

*     Merken, dass ein Eintrag übernommen wurde.
      h_dummy = 'X'.
    endif. " sy-subrc = 0.

    h_refwerks = t_wrsz-locnr.

*   Prüfe ob es noch weitere Filialen gibt, für die diese Filiale
*   eine Referenzfiliale darstellt.
    call function 'READ_WERKS_FOR_REFWERKS'
      EXPORTING
        group_type      = c_sortiment
        ref_werks       = h_refwerks
      TABLES
        tab_werks       = t_wrefa
      EXCEPTIONS
        no_plants_found = 1
        others          = 2.

*   Übernehme die gefundenen Einträge, falls nötig.
    loop at t_wrefa.
*     Prüfe, ob die Filiale in dieser Zuordnung in dieser
*     Filialgruppe vorkommt.
      read table pit_filia_group with key
           filia = t_wrefa-werks.

*     Falls die Filiale in dieser Zuordnung in dieser
*     Filialgruppe vorkommt, dann Eintrag merken.
      if sy-subrc = 0.
        clear: gt_asort_filia.
        t_asort_filia-asort = t_wrsz-asort.
        t_asort_filia-locnr = pit_filia_group-kunnr.
        t_asort_filia-ref   = 'X'.
        append t_asort_filia.

*       Merken, dass ein Eintrag übernommen wurde.
        h_dummy2 = 'X'.
      endif. " sy-subrc = 0.
    endloop. " at t_wrefa.

*   Falls weder diese Filiale noch Referenzfilialen übernommen
*   wurden, dann kann der Eintrag gelöscht werden.
    if h_dummy is initial and h_dummy2 is initial.
      delete t_wrsz.
    endif. " h_dummy is initial and h_dummy2 is initial.
  endloop. " at t_wrsz.

* Initialisiere Puffertabelle.
  refresh: gt_filia_matnr_buf.
  clear:   gt_filia_matnr_buf.

* Analysiere die relevanten Einträge.
  loop at t_asort_filia.
    refresh: t_matnr.
    clear:   t_matnr.
    call function 'FIND_ARTICLES_FOR_STORES'
      EXPORTING
        locnr       = t_asort_filia-locnr
        vlfkz       = c_filia_type
        asort       = t_asort_filia-asort
        date_from   = pi_erstdat
        date_to     = pi_erstdat
      TABLES
        tab_matnr   = t_matnr
      EXCEPTIONS
        wrong_locnr = 1
        others      = 2.

*   Übernehme die gefundenen Artikel in interne Tabelle.
    gt_filia_matnr_buf-locnr = t_asort_filia-locnr.
    loop at t_matnr.
      gt_filia_matnr_buf-matnr = t_matnr-matnr.
      append gt_filia_matnr_buf.
    endloop." at t_matnr.
  endloop. " at t_asort_filia.

* Sortieren der Daten.
  sort gt_filia_matnr_buf by matnr locnr.

* Übernehme die Daten in Ausgabetabelle.
  pet_filia_matnr[] = gt_filia_matnr_buf[].


endform. " wrsz_pointer_analyse

* eject
************************************************************************
form wlk1_pointer_analyse
     tables pet_ot1          structure gt_ot1_f_artstm
            pxt_artdel       structure gt_artdel
            pit_filia_group  structure gt_filia_group
     using  pi_pointer       structure bdcp
            pi_erstdat       like syst-datum.
************************************************************************
* FUNKTION:                                                            *
* Analyse von Änderungen in den Listungskonditionen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_OT1         : Objekttabelle 1, filialabhängig.
*
* PXT_ARTDEL      : Tabelle für zu löschende Artikel.
*
* PIT_FILIA_GROUP : Konstanten einer Gruppe von Filialen.
*
* PI_POINTER      : Der zu analysierende Änderungspointer.
*
* PI_ERSTDAT      : Datum: jetziges Versenden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  types:  BEGIN OF wlk1_key,
           mandt TYPE mandt,
           filia TYPE asort,
           artnr TYPE matnr,
           vrkme TYPE vrkme,
           datbi TYPE datbi,
           lfdnr TYPE lfdnr,
         END OF wlk1_key.

  data: is_wlk1 type wlk1_key.


  data: tabix like sy-tabix.

* Tabelle für Materialnummern.
  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.

* Tabelle für WLK1-Daten.
  data: begin of t_wlk1 occurs 0.
          include structure wlk1.
  data: end of t_wlk1.

  data: t_filia_group_temp like gt_filia_group occurs 0
                                with header line.

* Strukur für WLK1-Daten.
  data: begin of i_wlk1.
          include structure wlk1.
  data: end of i_wlk1.


* Rücksetze Ausgabetabelle.
  refresh: pet_ot1.

* Prüfe, ob diese Neulistung durch eine Aktionslistung zustande kam.
  clear: i_wlk1.
  is_wlk1 = pi_pointer-tabkey.
  move-corresponding is_wlk1 to i_wlk1.


  call function 'WLK1_READ_MULTIPLE_FUNCTIONS'
    EXPORTING
      wlk1_single_select = i_wlk1
      function           = 'C'
    TABLES
      wlk1_results       = t_wlk1
    EXCEPTIONS
      no_rec_found       = 1
      others             = 2.

  if sy-subrc = 0.
*   Falls eine Neulistung durch eine Aktionslistung zustande kam,
*   dann ignoriere den Satz.
    read table t_wlk1 index 1.
    if     pi_pointer-cdchgid = c_insert  and
       not t_wlk1-aktio is initial.
      exit.
    endif. " not t_wlk1-aktio is initial.

* Falls der Listungseintrag nicht mehr existiert, dann
* ignoriere den Pointer.
  else. " sy-subrc <> 0.
    exit.
  endif. "  sy-subrc = 0.

* Falls die Verkaufsmengeneinheitheit nicht bekannt ist.
  if t_wlk1-vrkme is initial.
*   Bestimme alle Verkaufsmengeneinheiten des Artikels
*   aus Tabelle MARM, die eine EAN besitzen.
    refresh: t_matnr.
    t_matnr-matnr = t_wlk1-artnr.
    append t_matnr.

    perform marm_select tables t_matnr
                               gt_vrkme
                        using  'X'   ' '   ' '.

* Falls die Verkaufsmengeneinheitheit bekannt ist.
  else. " t_wlk1-vrkme is not initial.
*   Prüfe, ob die Verkaufsmengeneinheit des Artikels
*   eine EAN besitzt.
    refresh: t_matnr.
    perform marm_select tables t_matnr
                               gt_vrkme
                        using  'X'   t_wlk1-artnr t_wlk1-vrkme.

  endif. " t_wlk1-vrkme is initial.

* Prüfe, ob VRKME's gefunden wurden.
  read table gt_vrkme index 1.

* Falls keine VRKME's gefunden wurden.
  if sy-subrc <> 0.
*   WLK1-Analyse verlassen.
    exit.
  endif. " sy-subrc <> 0.

* Falls eine normale Einlistung stattgefunden hat, dann muß
* initialisiert werden.
  if t_wlk1-sstat is initial.
*   Vorbesetzen einiger Feldinhalte der Ausgabetabelle.
    clear: pet_ot1.
    pet_ot1-datum = pi_pointer-acttime(8).
    pet_ot1-artnr = t_wlk1-artnr.
    pet_ot1-init  = 'X'.
    clear: pet_ot1-upd_flag.

*   Falls das Aktivierungsdatum des Pointers in der
*   Vergangenheit liegt, dann setze auf Versendedatum.
    if pi_pointer-acttime(8) < pi_erstdat.
      pet_ot1-datum = pi_erstdat.
    endif. " PI_POINTER-ACTTIME(8) < PI_ERSTDAT.

*   Fülle Objekttabelle 1 (filialabhängig).
    loop at pit_filia_group.
      pet_ot1-filia = pit_filia_group-filia.

*     Merken, das der Pointer aufgrund einer
*     Materialstammänderung erzeugt wurde.
      pet_ot1-aetyp_sort = c_mat_sort_index.

*     Falls das Aktivierungsdatum des Pointers in der
*     Vergangenheit liegt, dann setze auf Versendedatum.
      if pi_pointer-acttime(8) < pi_erstdat.
        pet_ot1-datum = pi_erstdat.
      endif. " PI_POINTER-ACTTIME(8) < PI_ERSTDAT.

      loop at gt_vrkme.
        pet_ot1-vrkme = gt_vrkme-meinh.
        append pet_ot1.
      endloop.                 " AT GT_VRKME.
    endloop. " at pit_filia_group.

* Falls eine Auslistung mit der Absicht die Daten von den POS-Systemen
* zu löschen stattgefunden hat, dann Löschsatz antriggern.
  elseif  t_wlk1-sstat = '5'   and      " Vom POS-System löschen
          t_wlk1-datbi <= pi_erstdat.

*   Prüfe, ob die n:m-Zuordnung aktiv ist.
    clear: twpa.
    call function 'TWPA_SINGLE_READ'
      IMPORTING
        wtwpa     = twpa
      EXCEPTIONS
        not_found = 1
        others    = 2.

*   Falls die n:m-Zuordnung aktiv ist.
    if not twpa-asmas is initial.
      read table gt_vrkme index 1.

*     Überprüfe die Listungen der einzelnen Sortimentsnutzer
*     (Filialen)
      refresh: t_filia_group_temp.
      clear:   t_filia_group_temp.
      loop at pit_filia_group.
*       Besorge die Listungen des Artikels bzgl. dieser Filiale
        call function 'LISTING_CHECK'
             exporting
                  pi_article      = gt_vrkme-matnr
*           pi_vrkme        = gt_vrkme-meinh
                  pi_datab        = pi_erstdat
                  pi_datbi        = pi_erstdat
                  pi_filia        = pit_filia_group-filia
                  pi_vkorg        = pit_filia_group-vkorg
                  pi_vtweg        = pit_filia_group-vtweg
                  pi_mode         = c_pos_mode
             tables
                  pet_bew_kond   = gt_listung
             exceptions
                  kond_not_found  = 01
                  vrkme_not_found = 02
                  vkdat_not_found = 03.

*       Prüfe, ob der Artikel gelistet ist.
        read table gt_listung index 1.

*       Falls der Artikel gelistet ist (z. B. über ein anderes
*       Sortiment einer m:n-Zuordnung, dann ist ein Löschsatz
*       nicht notwendig.
*       ==> Status 5 ignorieren, weiter zur nächsten Filiale.
        if sy-subrc = 0.
          continue.

*       Falls der Artikel nicht mehr gelistet ist, dann ist
*       ein Löschsatz notwendig.
*       ==> Status 5 berücksichtigen.
        else. " sy-subrc <> 0.
          append pit_filia_group to t_filia_group_temp.
        endif. " sy-subrc = 0.
      endloop. " at pit_filia_group.

*     Prüfe, ob noch Filialen zu berücksichtigen sind.
      read table t_filia_group_temp index 1.

*     Falls keine Filialen mehr zu berücksichtigen sind, dann
*     Routine verlassen.
      if sy-subrc <> 0.
        exit.
      endif. " sy-subrc <> 0.

*   Falls die n:m-Zuordnung nicht aktiv ist.
    else. " twpa-asmas is initial.
      t_filia_group_temp[] = pit_filia_group[].
    endif. " not twpa-asmas is initial.

    loop at gt_vrkme.
      read table pxt_artdel with key
           artnr = gt_vrkme-matnr
           vrkme = gt_vrkme-meinh
           datum = pi_erstdat
           binary search.

      tabix = sy-tabix.

*     Falls die zugehörige EAN noch nicht gemerkt wurde, dann
*     besorge EAN.
      if sy-subrc <> 0.
*       Besorge die Haupt-EAN vom Vortag des Löschens.
        perform ean_by_date_get
                using gt_vrkme-matnr  gt_vrkme-meinh
                      pi_erstdat      g_loesch_ean
                      g_returncode.

*       Falls eine EAN gefunden wurde, dann erzeuge
*       Lösch-Eintrag.
        if g_returncode = 0 and g_loesch_ean <> space.
          pxt_artdel-artnr = gt_vrkme-matnr.
          pxt_artdel-vrkme = gt_vrkme-meinh.
          pxt_artdel-ean   = g_loesch_ean.
          pxt_artdel-datum = pi_erstdat.
          insert pxt_artdel index tabix.

*       Falls keine EAN gefunden wurde, dann weiter
*       zum nächsten Satz.
        else. " g_returncode <> 0 or g_loesch_ean = space.
          continue.
        endif. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
      endif. " sy-subrc <> 0.

*     Fülle Objekttabelle 1 (filialabhängig).
      clear: pet_ot1.
      pet_ot1-artnr = gt_vrkme-matnr.
      pet_ot1-vrkme = gt_vrkme-meinh.
      pet_ot1-datum = pi_erstdat.
      pet_ot1-upd_flag = c_del.

      loop at t_filia_group_temp.
        pet_ot1-filia = t_filia_group_temp-filia.
        append pet_ot1.
      endloop. " at t_filia_group_temp.
    endloop.                 " AT GT_VRKME.
  endif. " t_wlk1-sstat <> '5'.

endform. " wlk1_pointer_analyse


*eject
************************************************************************
form promreb_pointer_analyse
             tables pit_pointer        structure bdcp
                    pit_filia_group    structure gt_filia_group
                    pet_ot1_f_promreb  structure gt_ot1_f_promreb
                    pet_ot2_promreb    structure gt_ot2_promreb
             using  pi_erstdat         like syst-datum
                    pi_datp3           like syst-datum
                    pi_datp4           like syst-datum.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabellen PET_OT2_PROMO (filialunabhängig)und
* PET_OT1_F_PROMO (filialabhängig)
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER       : Tabelle der zu analysierenden Änderungspointer.

* PIT_FILIA_GROUP   : Tabelle für Filialkonstanten der Gruppe.

* PET_OT1_F_PROMREB : Aktionsrabatte: Objekttabelle 1, filialabhängig.

* PET_OT2_PROMREB   : Aktionsrabatte: Objekttabelle 2, filialunabhängig.

* PI_ERSTDAT        : Datum: jetziges Versenden.

* PI_DATP3          : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4          : Datum: jetziges Versenden + Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_group  like gt_filia_group-group,
        h_vtweg  like gt_filia_group-vtweg,
        h_ref_vtweg_found.

* Zum übernehmen von Feldinhalten aus Änderungszeiger (Feld TABKEY).
  data: begin of i_tabkey,
          vkorg   like wpstruc-vkorg,
          vtweg   like wpstruc-vtweg,
          filia   like t001w-werks,
          pltyp   like wrf6-pltyp_p,
          matkl   like t023-matkl,
          wghier1 like wwgd-class1,
          wghier2 like wwgd-class1.
  data: end of i_tabkey.

* Zum übernehmen von Feldinhalten aus Änderungszeiger (Feld CDOBJID).
  data: begin of i_cdobjid,
*          aktnr   like wakr-aktnr,
          aktnr   type WAKTION,
*          posnr   like wakr-posnr,
          posnr type REB_POSNR,
*          datab   like wakr-reb_datefr,
*          datbi   like wakr-reb_dateto.
          datab type REB_DATEFR,
          datbi type REB_DATEto.
  data: end of i_cdobjid.

* Tabellen
  data: t_short_wrf6 like wpos_short_wrf6 occurs 0 with header line,
        t_kunnr      like wkunnr          occurs 0 with header line,
        t_filabh     like wpromodep       occurs 0 with header line,
        t_filunab    like wpromoindep     occurs 0 with header line.


* Bestimme die Nummer der gerade  bearbeiteten Filialgruppe.
  read table pit_filia_group index 1.
  h_group = pit_filia_group-group.

* Rücksetzte Ausgabetabellen.
  refresh: pet_ot2_promreb, pet_ot1_f_promreb.

* Besorge Referenzvertriebsweg, falls möglich.
  clear: tvkov.
  call function 'TVKOV_SINGLE_READ'
    EXPORTING
      tvkov_vkorg = pit_filia_group-vkorg
      tvkov_vtweg = pit_filia_group-vtweg
    IMPORTING
      wtvkov      = tvkov
    EXCEPTIONS
      not_found   = 1
      others      = 2.

* Merken, falls ein Referenzvertriebsweg gefunden wurde.
  if sy-subrc = 0.
    h_ref_vtweg_found = 'X'.
  endif. " sy-subrc = 0.

* Betrachte Aktionsrabattänderungen.
  loop at pit_pointer
       where cdobjcl = c_objcl_promo_rebate.

    clear: pet_ot1_f_promreb, pet_ot2_promreb.

*   Aufschlüsseln der Feldinhalte.
    i_tabkey  = pit_pointer-tabkey.
    i_cdobjid = pit_pointer-cdobjid.

*   Falls falsche Verkaufsorganisation, dann weiter zum nächsten
*   Pointer.
    if i_tabkey-vkorg <> pit_filia_group-vkorg.
      continue.
    endif. " i_tabkey-vkorg <> pit_filia_group-vkorg.

*   Falls es der falsche Vertriebsweg ist aber ein Referenzvertriebsweg
*   vorliegt, dann überprüfe den Referenzvertriebsweg.
    if i_tabkey-vtweg <> pit_filia_group-vtweg and
       not h_ref_vtweg_found is initial.
*     Falls der Referenzvertriebsweg nicht mit dem Quell-VTWEG
*     übereinstimmt, dann weiter zum nächsten Pointer.
      if i_tabkey-vtweg <> tvkov-vtwko.
        continue.
      endif. " i_tabkey-vtweg <> tvkov-vtwko.
    endif. " i_tabkey-vtweg <> pit_filia_group-vtweg and ...

*   Falls das Gültigkeitsintervall außerhalb des Betrachtungszeitraums
*   liegt, dann weiter zum nächsten Pointer.
    if i_cdobjid-datab > pi_datp4 or
       i_cdobjid-datbi < pi_erstdat.
      continue.
    endif. " i_cdobjid-datab >= pi_datp4 or...

*   Falls der Gültigkeitsbeginn in der Vergangenheit liegt,
*   dann setzte ihn auf Beginn 'jetziges Versenden'.
    if i_cdobjid-datab < pi_erstdat.
      i_cdobjid-datab = pi_erstdat.
    endif. " i_cdobjid-datab < pi_erstdat.

*   Falls Filialunabhängigkeit besteht, dann übernahme in
*   filialunabhängige Objekttabelle.
    if i_tabkey-filia is initial  and
       i_tabkey-pltyp is initial.

      clear: pet_ot2_promreb.
      pet_ot2_promreb-aktnr    = i_cdobjid-aktnr.
      pet_ot2_promreb-posnr    = i_cdobjid-posnr.
      pet_ot2_promreb-datum    = i_cdobjid-datab.
      pet_ot2_promreb-upd_flag = pit_pointer-cdchgid.
      append pet_ot2_promreb.

*   Falls Filialabhängigkeit besteht, dann übernahme in
*   filialabhängige Objekttabelle.
    else. " not i_tabkey-filia is initial  or ...
*     Falls Empfänger schon bekannt.
      if not i_tabkey-filia is initial.
*       Prüfe, ob diese Filiale in der gerade
*       bearbeiteten Filialgruppe vorkommt. Nur solche Sätze
*       dürfen berücksichtigt werden.
        read table pit_filia_group with key
             group = h_group
             filia = i_tabkey-filia
             binary search.

*       Diese Filiale muß  berücksichtigt werden.
        if sy-subrc = 0.
          clear: pet_ot1_f_promreb.
          pet_ot1_f_promreb-kunnr    = pit_filia_group-kunnr.
          pet_ot1_f_promreb-aktnr    = i_cdobjid-aktnr.
          pet_ot1_f_promreb-posnr    = i_cdobjid-posnr.
          pet_ot1_f_promreb-datum    = i_cdobjid-datab.
          pet_ot1_f_promreb-upd_flag = pit_pointer-cdchgid.
          append pet_ot1_f_promreb.
        endif. " sy-subrc = 0.

*     Falls Empfänger noch ermittelt werden muß.
      else." not i_tabkey-pltyp is initial.

        clear: pet_ot1_f_promreb.
        pet_ot1_f_promreb-aktnr    = i_cdobjid-aktnr.
        pet_ot1_f_promreb-posnr    = i_cdobjid-posnr.
        pet_ot1_f_promreb-datum    = i_cdobjid-datab.
        pet_ot1_f_promreb-upd_flag = pit_pointer-cdchgid.

*       Ermitteln der betroffenen Empfänger
        call function 'KUNNR_BY_PLTYP_GET_WRF6'
          EXPORTING
            pi_pltyp       = i_tabkey-pltyp
          TABLES
            pet_short_wrf6 = t_short_wrf6
          EXCEPTIONS
            others         = 1.

*       Prüfe, welche Empfänger in der aktuellen Filialgruppe vorkommen.
        loop at t_short_wrf6.
          pet_ot1_f_promreb-kunnr  = t_short_wrf6-locnr.
          append pet_ot1_f_promreb.
        endloop. " at t_short_wrf6.

      endif. " not i_tabkey-filia is initial.
    endif. " i_tabkey-werks is initial  and
  endloop. " at pit_pointer

***************  Intervallscanner  *************************************
  loop at pit_filia_group.
    append pit_filia_group-kunnr to t_kunnr.
  endloop. " at pit_filia_group.

* Falls kein Referenzvertriebsweg vorliegt.
  if h_ref_vtweg_found is initial.
    h_vtweg = pit_filia_group-vtweg.
* Falls ein Referenzvertriebsweg vorliegt.
  else. " not h_ref_vtweg_found is initial.
    h_vtweg = tvkov-vtwko.
  endif.

  if pi_datp3 < pi_datp4. "note 672279 , HFe 20.10.03

* Prüfe, ob irgendwelche Aktionsrabatte aus der Zukunft kommend in
* den aktuellen Aufbereitungszeitraum hineinlaufen.
    call function 'PROMOTION_REBATE_START_FIND'
      EXPORTING
        pi_vkorg                 = pit_filia_group-vkorg
        pi_vtweg                 = h_vtweg
        pi_datab                 = pi_datp3
        pi_datbi                 = pi_datp4
      TABLES
        pi_t_kunnr               = t_kunnr
        pe_t_filabh              = t_filabh
        pe_t_filunabh            = t_filunab
      EXCEPTIONS
        wrong_input              = 1
        no_promotion_found       = 2
        unknown_activation_level = 3
        others                   = 4.
  endif.
* Falls Daten gefunden wurden.

  if sy-subrc = 0 and ( pi_datp3 < pi_datp4 ). "note 672279
*   Übernehme filialabhängige Daten.
    loop at t_filabh.
      clear: pet_ot1_f_promreb.
      pet_ot1_f_promreb-kunnr    = t_filabh-kunnr.
      pet_ot1_f_promreb-aktnr    = t_filabh-aktnr.
      pet_ot1_f_promreb-posnr    = t_filabh-posnr.
      pet_ot1_f_promreb-datum    = t_filabh-reb_datefr.
      append pet_ot1_f_promreb.
    endloop. " at t_filabh.

*   Übernehme filialunabhängige Daten.
    loop at t_filunab.
      clear: pet_ot2_promreb.
      pet_ot2_promreb-aktnr    = t_filunab-aktnr.
      pet_ot2_promreb-posnr    = t_filunab-posnr.
      pet_ot2_promreb-datum    = t_filunab-reb_datefr.
      append pet_ot2_promreb.
    endloop. " at t_filunab.

  endif. " sy-subrc = 0



************************************************************************
* Funktionsexit für kundendefinierte Änderungszeigeranalyse.
  call customer-function '017'
       exporting
            pi_erstdat        = pi_erstdat
            pi_datp4          = pi_datp4
       tables
            pit_filia_group   = pit_filia_group
            pit_pointer       = pit_pointer
            pet_ot1_f_promreb = pet_ot1_f_promreb
            pet_ot2_promreb   = pet_ot2_promreb.
************************************************************************

* Komprimierung:
* Lösche doppelte Einträge aus PET_OT1_F_PROMREB.
  sort pet_ot1_f_promreb by kunnr aktnr posnr datum upd_flag.
  delete adjacent duplicates from pet_ot1_f_promreb
                  comparing kunnr aktnr posnr datum upd_flag.

* Lösche doppelte Einträge aus PET_OT2_PROMREB.
  sort pet_ot2_promreb by aktnr posnr datum upd_flag.
  delete adjacent duplicates from pet_ot2_promreb
                  comparing aktnr posnr datum upd_flag.


endform.                               " WRGP_POINTER_ANALYSE


*eject
************************************************************************
form ot3_generate_promreb
     tables pit_ot1_f_promreb      structure gt_ot1_f_promreb
            pit_ot2_promreb        structure gt_ot2_promreb
            pet_ot3_promreb        structure gt_ot3_promreb
     using  pi_filia_group         structure gt_filia_group.
************************************************************************
* FUNKTION:
* Erzeuge filialabhängige Objekttabelle PET_OT3_PROMREB. Ferner
* werden die Objekttabellen OT1 und OT2 in OT3 zusammengemischt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT1_F_PROMREB     : Aktionsrabatte: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_PROMREB       : Aktionsrabatte: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_PROMREB       : Aktionsrabatte: Objekttabelle 3.

* PI_FILIA_GROUP        : Daten der aktuellen Filiale.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: counter type i.

* Zum Komprimieren von Tabelle PET_OT3_PROMREB (Stufe 1).
  data: begin of i_key1,
          aktnr like pet_ot3_promreb-aktnr,
          posnr like pet_ot3_promreb-posnr.
  data: end of i_key1.

* Zum Komprimieren von Tabelle PET_OT3_PROMREB (Stufe 1).
  data: begin of i_key2.
          include structure i_key1.
  data: end of i_key2.


* Rücksetze Objekttabelle 3.
  refresh: pet_ot3_promreb.

* Übernahme der Daten aus PIT_OT2_PROMREB.
  loop at pit_ot2_promreb.
    move-corresponding pit_ot2_promreb to pet_ot3_promreb.
    append pet_ot3_promreb.
  endloop. " at pit_ot2_promreb.

* Übernahme der Daten aus PIT_OT1_F_PROMREB.
  loop at pit_ot1_f_promreb
       where kunnr = pi_filia_group-kunnr.
    move-corresponding pit_ot1_f_promreb to pet_ot3_promreb.
    append pet_ot3_promreb.
  endloop. " at pit_ot1_f_promreb.


* Komprimierung:
* Lösche doppelte Einträge aus PET_OT3_PROMREB.
  sort pet_ot3_promreb by aktnr posnr datum upd_flag.
  delete adjacent duplicates from pet_ot3_promreb
                  comparing aktnr posnr datum upd_flag.

* Nummeriere die Objektgruppen.
  clear: counter, i_key1, i_key2.
  loop at pet_ot3_promreb.
    move-corresponding pet_ot3_promreb to i_key2.
    if i_key1 <> i_key2.
      i_key1 = i_key2.
      add 1 to counter.
    endif.                             " I_KEY1 <> I_KEY2.

    pet_ot3_promreb-number = counter.
    modify pet_ot3_promreb.
  endloop.                             " at pet_ot3_promreb


endform.                               " OT3_GENERATE_EAN
