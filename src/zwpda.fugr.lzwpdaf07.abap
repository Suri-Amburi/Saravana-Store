*-------------------------------------------------------------------
***INCLUDE LWPDAF07 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Wechselkurse.
************************************************************************


************************************************************************
form wkurs_download
     tables pit_filter_segs structure gt_filter_segs
     using  pi_filia        like wpfilia-filia
            pi_express      like wpstruc-modus
            pi_loeschen     like wpstruc-modus
            pi_mode         like wpstruc-modus
            pi_datum_ab     like wpstruc-datum
            pi_datum_bis    like wpstruc-datum
            pi_vkorg        like wpstruc-vkorg
            pi_vtweg        like wpstruc-vtweg
            pi_filia_const  like gi_filia_const
            pi_dldnr        like wdls-dldnr
            pi_erstdat      like syst-datum.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Wechselkurse.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PI_FILIA       : Filiale, an die verschickt werden soll.
*
* PI_EXPRESS     := 'X', wenn sofort versendet werden soll, sonst SPACE.
*
* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                     sollen, sonst SPACE.
* PI_MODE        : 'I': Init, 'A' = direkte Anf., 'U': Änderungsfall,
*                  'R': Restartfall.
* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.
*
* PI_DATUM_BIS   : Ende des Betrachtungszeitraums.
*
* PI_VKORG       : Verkaufsorganisation.
*
* PI_VTWEG       : Vertriebsweg.
*
* PI_FILIA_CONST : Filialkonstanten.
*
* PI_DLDNR       : Downloadnummer der Status-Kopfzeile.
*
* PI_ERSTDAT     : Beginndatum des Downloads.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: e1wpc01 value 'X', " Flag, ob Segm. E1WPC01 vers. werden muß
        e1wpc02 value 'X',
        h_datab like sy-datum,
        h_datbi like sy-datum.


* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  g_current_doctype = c_idoctype_cur.

* Prüfe, welche Artikelstammsegmente versendet werden müssen
  loop at pit_filter_segs.

    case pit_filter_segs-segtyp.
      when c_e1wpc01_name.
        clear: e1wpc01.
      when c_e1wpc02_name.
        clear: e1wpc02.
    endcase.                           " PIT_FILTER_SEGS-SEGTYP

  endloop.                             " PIT_FILTER_SEGS

* Es müssen Wechselkurse versendet werden.
  if e1wpc01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    clear: g_segment_counter, g_new_position, g_status_pos.

*   Falls Initialisierungsfall, direkte Anforderung oder Restart.
    if pi_mode <> c_change_mode.
*     Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
      perform time_range_get using h_datab   h_datbi
                                   pi_filia_const-vzeit
                                   pi_filia_const-fabkl
                                   g_datab       g_datbis
                                   pi_erstdat.

*     Erzeuge Tabelle mit Arbeitstagen, falls nötig.
      perform workdays_get tables gt_workdays
                           using  g_datab  g_datbis
                                  pi_filia_const-fabkl.
*   Falls Änderungsfall.
    else.
      g_datab  = pi_datum_ab.
      g_datbis = pi_datum_bis.
    endif. " pi_mode <> c_change_mode.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    clear: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-doctyp = c_idoctype_cur.

*   Fall Restart-Modus.
    if pi_mode = c_restart_mode.
      gi_status_pos-rspos  = 'X'.
    endif. " pi_mode = c_restart_mode.

*   Schreibe Status-Positionszeile.
    perform status_write_pos using ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Rücksetzen Fehler-Zähler.
    clear: g_err_counter.

*   Besorge Wechselkurse und bereite IDOC auf.
    call function 'MASTERIDOC_CREATE_DLPWKURS'
         exporting
*###          pi_ermod           = pi_filia_const-ermod
              pi_erstdat         = pi_erstdat
              pi_dldnr           = pi_dldnr
              px_dldlfdnr        = g_dldlfdnr
              pi_vkorg           = pi_vkorg
              pi_vtweg           = pi_vtweg
              pi_filia           = pi_filia
*             pi_kunnr           = pi_filia_const-kunnr
*             pi_spart           = pi_filia_const-spart
              pi_datum_ab        = g_datab
              pi_datum_bis       = g_datbis
              pi_express         = pi_express
              pi_loeschen        = pi_loeschen
              pi_mode            = pi_mode
              pi_e1wpc02         = e1wpc02
*             pi_spras           = pi_filia_const-spras
              px_segment_counter = g_segment_counter
*             pi_waers           = pi_filia_const-waers
              pi_filia_const     = pi_filia_const
         importing
              px_segment_counter = g_segment_counter
         tables
              pit_workdays       = gt_workdays
         changing
              pxt_idoc_data      = gt_idoc_data
         exceptions
              download_exit      = 1.

*   Es sind Fehler beim Download aufgetreten'
    if sy-subrc = 1.
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      if pi_mode <> c_change_mode.
        raise download_exit.
*     Falls Änderungsfall.
      else.
        raise error_code_1.
      endif. " pi_mode <> c_change_mode.
    endif.                             " SY-SUBRC = 1.

*   Erzeuge letztes IDOC, falls nötig.
    if g_segment_counter > 0.
      perform idoc_create using  gt_idoc_data
                                 g_mestype_cur
                                 c_idoctype_cur
                                 g_segment_counter
                                 g_err_counter
                                 ' '   " 'Firstkey'
                                 ' '   " 'Lastkey'
                                 pi_dldnr    g_dldlfdnr
                                 pi_filia
                                 pi_filia_const.

    endif.                             " G_SEGMENT_COUNTER > 0.

*   Schreibe Fehlermeldungen auf Datenbank, falls nötig.
    if g_init_log <> space.
      perform appl_log_write_to_db.
    endif.                             " G_INIT_LOG <> SPACE.

*   Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*   auf OK.
    if g_status = 0.
*     Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
      clear: gi_status_header.
      gi_status_header-dldnr = pi_dldnr.
      gi_status_header-gesst = c_status_ok.

*     Schreibe Status-Kopfzeile.
      perform status_write_head using  'X'  gi_status_header  pi_dldnr
                                            g_returncode.
    endif.                             " G_STATUS = 0.
  endif.                               " E1WPC01 <> SPACE.


endform.                               " WKURS_DOWNLOAD


*eject
************************************************************************
form wkursdata_get_and_analyse
     tables pet_wkurs      structure gt_wkurs_data
            pxt_orgtab     structure gt_orgtab_wkurs
     using  pi_filia_const like wpfilconst
            pi_vkorg       like wpstruc-vkorg
            pi_vtweg       like wpstruc-vtweg
            pi_datab       like syst-datum
            pi_datbi       like syst-datum
            pi_filia       like t001w-werks
            pi_mode        like wpstruc-modus
   changing value(pe_fehlercode) like syst-subrc
            pi_dldnr       like wdls-dldnr
            pi_dldlfdnr    like wdlsp-lfdnr
            pi_erstdat     like syst-datum
            pi_loeschen    like wpstruc-modus
            pi_segment_counter like g_segment_counter.
************************************************************************
* FUNKTION:
* Lese die Daten für Download Wechselkurse im Zeitintervall
* PI_DATAB - PI_DATBI, analysiere diese und fülle Organisationstabelle.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_WKURS    : Tabelle der Wechselkurse
*
* PXT_ORGTAB   : Organisationstabelle für Wechselkurse.
*
* PI_FILIA_CONST: Filialkonstanten.
*
* PI_VKORG     : Verkaufsorganisation der Selektion.
*
* PI_VTWEG     : Vertriebsweg der Selektion.
*
* PI_DATAB     : Beginndatum der Selektion.
*
* PI_DATBI     : Endedatum der Selektion.
*
* PI_FILIA     : Filiale.
*
* PI_MODE      : Download-Modus.
*
* PE_FEHLERCODE: > 0, wenn Datenbeschaffung mißlungen, sonst '0'.
*
* PI_DLDNR     : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_ERSTDAT   : Erstelldatum der Status-Kopfzeile.
*
* PI_LOESCHEN  : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                       sollen, sonst SPACE.
* PI_SEGMENT_COUNTER: Segmentzähler.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: readindex  type i,
        key1       like gt_wkurs_data-zwaehrung,
        key2       like gt_wkurs_data-zwaehrung,
        h_datum    like sy-datum,
        incl_first_record value ' '.

* Falls Initialisierungsfall, direkte Anforderung oder Restart.
  if pi_mode <> c_change_mode.
    incl_first_record = 'X'.
  endif. "  pi_mode <> c_change_mode.

* Besorge Wechselkursdaten.
  call function 'POS_RATE_OF_EXCHANGE_GET_2'
       exporting
            pi_datab                    = pi_datab
            pi_datbi                    = pi_datbi
            pi_loeschen                 = pi_loeschen
            pi_filia_const              = pi_filia_const
       tables
            pet_rates_of_exchange       = pet_wkurs
       exceptions
            keine_gewichtsfaktoren      = 01
            keine_hauswaehrung_gefunden = 02
            keine_wechselkurse_gefunden = 03
            kein_kommunikationsprofil   = 04.

* Falls Initialisierungsfall, direkte Anforderung oder Restart.
  if pi_mode <> c_change_mode.
    if sy-subrc <> 0.
*     Zwischenspeichern des Returncodes.
      pe_fehlercode = sy-subrc.

*     Falls Fehlerprotokollierung erwünscht.
      if pi_filia_const-ermod = space.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        if g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          clear: gi_errormsg_header.
          gi_errormsg_header-object        = c_applikation.
          gi_errormsg_header-subobject     = c_subobject.
          gi_errormsg_header-extnumber     = pi_dldnr.
          gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
          gi_errormsg_header-aluser        = sy-uname.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          perform appl_log_init_with_header  using gi_errormsg_header.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        endif.                           " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        write pi_datab to g_datum1 dd/mm/yyyy.
        write pi_datbi to g_datum2 dd/mm/yyyy.

        clear: gi_message.
        gi_message-msgty     = c_msgtp_warning.
        gi_message-msgid     = c_message_id.
        gi_message-probclass = c_probclass_weniger_wichtig.
        case pe_fehlercode.
          when '1'.
*           'Keine Gewichtsfaktoren der Wechselkurse für Filiale &
*            gepflegt'.
            gi_message-msgno     = '137'.
            gi_message-msgv1     = pi_filia.
          when '2'.
*           'Keine Währung für Filiale &, Vkorg. &, Vtweg.ale &
*            und Sparte & gepflegt
            gi_message-msgno     = '134'.
            gi_message-msgv1     = pi_filia_const-kunnr.
            gi_message-msgv2     = pi_vkorg.
            gi_message-msgv3     = pi_vtweg.
            gi_message-msgv4     = pi_filia_const-spart.
          when '3'.
*           'Keine Wechselkurse für Filiale & im Zeitintervall
*            & bis & gefunden'.
            gi_message-msgno     = '135'.
            gi_message-msgv1     = pi_filia.
            gi_message-msgv2     = g_datum1.
            gi_message-msgv3     = g_datum2.
        endcase.                         " PE_FEHLERCODE

*       Schreibe Fehlerzeile.
        clear: g_object_key.
        perform appl_log_write_single_message using  gi_message.

      endif.                             " PI_FILIA_CONST-ERMOD = SPACE.

*     Ändern der Status-Kopfzeile, falls nötig.
      if g_status < 2.                   " 'Benutzerhinweis'
        clear: gi_status_header.
        gi_status_header-dldnr = pi_dldnr.
        gi_status_header-gesst = c_status_benutzerhinweis.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        perform status_write_head using  'X'  gi_status_header  pi_dldnr
                                         g_returncode.
*       Aktualisiere Aufbereitungsstatus.
        g_status =  2.                  " 'Benutzerhinweis'

      endif. " G_STATUS < 2.  " 'Benutzerhinweis'

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      clear: gi_status_pos.
      gi_status_pos-dldnr  = pi_dldnr.
      gi_status_pos-lfdnr  = pi_dldlfdnr.
      gi_status_pos-anloz  = g_err_counter.
      gi_status_pos-anseg  = pi_segment_counter.
*     GI_STATUS_POS-STKEY  = G_FIRSTKEY.
*     GI_STATUS_POS-LTKEY  = G_FIRSTKEY.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      if g_status_pos < 2.                   " 'Benutzerhinweis'
        gi_status_pos-gesst = c_status_benutzerhinweis.

        g_status_pos = 2.                    " 'Benutzerhinweis'
      endif. " g_status_pos < 2.             " 'Benutzerhinweis'

*     Schreibe Status-Positionszeile.
      perform status_write_pos using 'X' gi_status_pos  pi_dldlfdnr
                                         g_returncode.

*     Falls Fehlerprotokollierung erwünscht.
      if pi_filia_const-ermod = space.
*       Verlassen der Aufbereitung, falls Einlesefehler.
        exit.
*     Falls Abbruch bei Fehler erwünscht.
      else.                         " PI_FILIA_CONST-ERMOD <> SPACE.
*       Abbruch des Downloads.
        raise download_exit.
      endif.                        " PI_FILIA_CONST-ERMOD = SPACE.
    endif.                               " SY-SUBRC <> 0.

* Falls Änderungsfall.
  else. " if pi_mode = c_change_mode
    if sy-subrc <> 0.
*     Zwischenspeichern des Returncodes.
      pe_fehlercode = sy-subrc.

*     Weitere Aufbereitung verlassen.
      exit.
    endif. " sy-subrc <> 0.

*   Falls zu einer Währung mehrere Intervalle existieren, die älter
*   sind als PI_ERSTDAT, dann darf nur das Intervall berücksichtigt
*   werden, welches dem Stand von PI_ERSTDAT entspricht. Alle übrigen
*   müssen gelöscht werden.
    sort pet_wkurs by zwaehrung datab descending.
    h_datum = pi_erstdat.
    clear: key1, key2.
    loop at pet_wkurs
      where datab <= h_datum.
      key2 = pet_wkurs-zwaehrung.
      if key1 <> key2.
        key1 = key2.
        pet_wkurs-datab = h_datum.
        modify pet_wkurs.
      else.                            " KEY1 = KEY2.
        delete pet_wkurs.
      endif.                           " KEY1 <> KEY2.
    endloop.                           " AT PET_WKURS.
  endif. "  pi_mode <> c_change_mode.

* Falls Löschmodus aktiv, dann weitere Aufbereitung nicht nötig.
  if pi_loeschen <> space.
    exit.
  endif. " pi_loeschen <> space.

  sort pet_wkurs by datab zwaehrung.
  loop at pet_wkurs.
*   Das Feld DATAB muß den Wert PI_DATAB haben, da dieser
*   Satz in jedem Fall versendet wird.
    if pet_wkurs-datab < pi_datab.
      pet_wkurs-datab = pi_datab.
      modify pet_wkurs.
    endif.                             " PET_WKURS-DATUM < PI_DATAB

*   Falls Änderungsfall.
    if pi_mode = c_change_mode.
*     Jeder Satz muß in der Org.Tabelle vermerkt werden
      readindex = pet_wkurs-datab - pi_erstdat + 1.
*   Falls Initialisierungsfall, direkte Anforderung oder Restart.
    else.
*     Jeder Satz muß in der Org.Tabelle vermerkt werden
      readindex = pet_wkurs-datab - pi_datab + 1.
    endif. " PI_MODE = C_CHANGE_MODE

    read table pxt_orgtab index readindex.
    pxt_orgtab-change = 'X'.

    modify pxt_orgtab index readindex.
  endloop.                             " AT PET_WKURS.

  sort pet_wkurs by datab zwaehrung.

endform.                               " WKURSDATA_GET_AND_ANALYSE


*eject.
************************************************************************
form idoc_dataset_wkurs_append
     tables pit_wkurs      structure gt_wkurs_data
            pit_orgtab     structure gt_orgtab_wkurs
     using  pxt_idoc_data  type short_edidd
            pi_datum       like syst-datum
            px_segcnt      like g_segment_counter
            pi_loeschen    like wpstruc-modus
            pi_e1wpc02     like wpstruc-modus
            pi_filia       like t001w-werks
            pe_fehlercode  like syst-subrc
            pi_dldnr       like wdls-dldnr
            pi_dldlfdnr    like wdlsp-lfdnr
            pi_filia_const like wpfilconst.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_WKURS    : Tabelle der Wechselkurse
*
* PIT_ORGTAB   : Organisationstabelle für Wechselkurse.
*
* PXT_IDOC_DATA: IDOC-Daten der Struktur EDIDD (Tabelle an die die
*                IDOC-Sätze angefügt werden).
* PI_DATUM     : Datum für das die Daten aufbereitet werden sollen.
*
* PX_SEGCNT    : Segment-Zähler.
*
* PI_LOESCHEN  : = 'X', wenn Löschmodus aktiv.
*
* PI_E1WPC02   : = 'X', wenn Segment E1WPC02 aufbereitet werden soll.
*
* PI_FILIA     : Filiale, an die versendet werden soll.
*
* PE_FEHLERCODE: > 0, wenn Fehler beim Umsetzen der Daten.

* PI_DLDNR     : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_FILIA_CONST : Filialkonstanten.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: e1wpc02_cnt type i,
        seg_local_cnt type i.


* Rücksetze Returncode.
  clear: pe_fehlercode, e1wpc02_cnt.

* Rücksetze Temporärtabelle für IDOC-Daten.
  refresh: gt_idoc_data_temp.

* Rücksetze lokalen Segmentzähler.
  clear: seg_local_cnt.

* Aufbereitung ID-Segment.
  read table pit_wkurs index 1.
  clear: e1wpc01.
  e1wpc01-filiale    = pi_filia_const-kunnr.
  e1wpc01-aktivdatum = pi_datum.
  e1wpc01-aenddatum  = '00000000'.
  e1wpc01-aenderer   = ' '.
  e1wpc01-waehrung   = pit_wkurs-waehrung.

* Falls Löschmodus aktiv.
  if pi_loeschen <> space.
    e1wpc01-aendkennz  = c_delete.
* Falls Löschmodus nicht aktiv.
  else.
    e1wpc01-aendkennz  = c_modi.
  endif.                               " PI_LOESCHEN <> SPACE.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpc01_name.
  gt_idoc_data_temp-sdata  = e1wpc01.
  append gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  add 1 to seg_local_cnt.

* Es müssen Stammdaten übertragen werden, da kein Löschmodus aktiv ist.
  if pi_loeschen = space.

*   Falls Segment E1WPC02 Wechselkurse Stammdaten gefüllt werden muß
    if pi_e1wpc02 <> space.
*     Besorge die Wechselkurs-Stammdaten für Datum PI_DATUM.
      clear: e1wpc02_cnt.
      loop at pit_wkurs
        where datab <= pi_datum
        and   datbi >= pi_datum.

*       Aktualisiere Zähler für Stammdaten.
        add 1 to e1wpc02_cnt.

        clear: e1wpc02.
        e1wpc02-zwaehrung  = pit_wkurs-zwaehrung.
        e1wpc02-bezeich    = pit_wkurs-bezeich.
        e1wpc02-wsymbol    = pit_wkurs-wsymbol.
        e1wpc02-kurs       = pit_wkurs-kurs.
        condense e1wpc02-kurs.
        e1wpc02-kurs_m     = pit_wkurs-kurs_m.
        condense e1wpc02-kurs_m.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpc02_name.
        gt_idoc_data_temp-sdata  = e1wpc02.
        append gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        add 1 to seg_local_cnt.

      endloop.                         " AT PIT_WKURS
    endif.                             " PI_E1WPC02 <> SPACE.
  endif.                               " PI_LOESCHEN = SPACE.

*********************************************************************
***********************   U S E R - E X I T  ************************
  call customer-function '006'
       exporting
            pi_e1wpc02_cnt     = e1wpc02_cnt
            px_segment_counter = px_segcnt
            pi_seg_local_cnt   = seg_local_cnt
            pi_dldnr           = pi_dldnr
            pi_dldlfdnr        = pi_dldlfdnr
            pi_ermod           = pi_filia_const-ermod
            pi_firstkey        = g_firstkey
            px_init_log        = g_init_log
            px_status          = g_status
            px_status_pos      = g_status_pos
            px_err_counter     = g_err_counter
       importing
            px_init_log        = g_init_log
            px_status          = g_status
            px_status_pos      = g_status_pos
            pe_fehlercode      = pe_fehlercode
            px_err_counter     = g_err_counter
            pi_seg_local_cnt   = seg_local_cnt
       tables
            pxt_idoc_data_temp = gt_idoc_data_temp
            PIT_IDOC_DATA      = gt_idoc_data_dummy
       changing
            PIT_IDOC_DATA_new  = PXT_IDOC_DATA.

* Falls Umsetzfehler auftraten.
  if pe_fehlercode <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    if pi_filia_const-ermod = space.
*     Fülle allgemeinen Objektschlüssel.
      g_object_key = c_whole_idoc.

*     Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
      perform error_object_write.

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
      exit.
*   Falls Abbruch bei Fehler erwünscht.
    else.                              " PI_FILIA_CONST-ERMOD <> SPACE.
*     Abbruch des Downloads.
      raise download_exit.
    endif.                             " PI_FILIA_CONST-ERMOD = SPACE.

* Falls Umschlüsselung fehlerfrei.
  else.                                " PE_FEHLERCODE = 0.
*   Übernehme die IDOC-Daten aus Temporärtabelle.
    perform idoc_data_assume tables  gt_idoc_data_temp
                             using   pxt_idoc_data
                                     px_segcnt
                                     seg_local_cnt.

  endif.                               " PE_FEHLERCODE <> 0.

*********************************************************************


endform.                               " IDOC_DATASET_WKURS_APPEND
