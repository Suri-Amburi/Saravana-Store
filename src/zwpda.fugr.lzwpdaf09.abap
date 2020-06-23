*-------------------------------------------------------------------
***INCLUDE LWPDAF09 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Personendaten.
************************************************************************


************************************************************************
form pers_download
     tables pit_filter_segs structure gt_filter_segs
            pit_kunnr       structure wppdot3
     using  pi_filia_const  structure gi_filia_const
            pi_filia        like wpfilia-filia
            pi_express      like wpstruc-modus
            pi_loeschen     like wpstruc-modus
            pi_mode         like wpstruc-modus
            pi_datum_ab     like wpstruc-datum
            pi_debug        like wpstruc-modus
            pi_pdat         like wpstruc-modus
            pi_vkorg        like wpstruc-vkorg
            pi_vtweg        like wpstruc-vtweg.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Personendaten.                              *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PIT_KUNNR      : Liste der zu übertragenden Kundennummern, falls
*                  PI_MODE = 'A' und PI_PDAT = 'X'.
* PI_FILIA_CONST : Feldleiste mit Filialkonstanten.
*
* PI_FILIA       : Filiale, an die verschickt werden soll.
*
* PI_EXPRESS     : = 'X', wenn sofort versendet werden soll,
*                  sonst SPACE.
* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                  sollen, sonst SPACE.
* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'D' = direkte
*                     Anforderung, 'R': Restart.
* PI_DATUM_AB    : = Beginn des Betrachtungszeitraums.
*
* PI_DEBUG       : = 'X', wenn Status-Positionszeile ständig
*                  aktualisiert werden soll, sonst SPACE.
* PI_VKORG       : Verkaufsorganisation.
*
* PI_VTWEG       : Vertriebsweg.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: e1wpp01    value 'X', " Flag, ob Segm. E1WPP01 vers. werden muß
        e1wpp02    value 'X',
        e1wpp03    value 'X',
        e1wpp04    value 'X',
        e1wpp05    value 'X',
        e1edk28    value 'X',
        e1wpp07    value 'X',
        h_datum    like sy-datum,
        fehlercode like sy-subrc,
        pdat_lines type i,
        special_numbers.


* Prüfe, welche Personendatensegmente versendet werden müssen
  loop at pit_filter_segs.

    case pit_filter_segs-segtyp.
      when c_e1wpp01_name.
        clear: e1wpp01.
      when c_e1wpp02_name.
        clear: e1wpp02.
      when c_e1wpp03_name.
        clear: e1wpp03.
      when c_e1wpp04_name.
        clear: e1wpp04.
      when c_e1wpp05_name.
        clear: e1wpp05.
      when c_e1edk28_name.
        clear: e1edk28.
      when c_e1wpp07_name.
        clear: e1wpp07.
    endcase.                           " PIT_FILTER_SEGS-SEGTYP

  endloop.                             " AT PIT_FILTER_SEGS

* Es müssen Personendaten versendet werden.
  if e1wpp01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    clear: g_segment_counter, g_new_position, special_numbers,
           g_status_pos.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

    if pi_datum_ab is initial.
      g_aktivdat = g_erstdat.
    else.
      g_aktivdat = pi_datum_ab.
    endif.                             " PI_DATUM_AB = '00000000'.

*   Falls ein Fabrikkalender existiert.
    if pi_filia_const-fabkl <> space.
*     Besorge das Datum des Versendetages über Fabrikkalender.
      call function 'DATE_CONVERT_TO_FACTORYDATE'
           exporting
                correct_option             = c_vorzeichen
                date                       = g_aktivdat
                factory_calendar_id        = pi_filia_const-fabkl
           importing
                date                       = h_datum
           exceptions
                date_after_range           = 01
                date_before_range          = 02
                date_invalid               = 03
                factory_calendar_not_found = 04.

      if sy-subrc = 0.
        g_aktivdat = h_datum.
      endif.                           " SY-SUBRC = 0.
    endif.                             " PI_FILIA_CONST-FABKL  <> SPACE.

*   Falls direkte Anforderung, prüfe, ob Personendatentabelle
*   Daten enthält.
    if pi_pdat <> space.
      clear: pdat_lines.
      describe table pit_kunnr lines pdat_lines.
    endif.                             " PI_PDAT <> SPACE.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    clear: gi_status_pos.
    gi_status_pos-dldnr  = g_dldnr.
    gi_status_pos-doctyp = c_idoctype_pers.

*   Fall Restart-Modus.
    if pi_mode = c_restart_mode.
      gi_status_pos-rspos  = 'X'.
    endif. " pi_mode = c_restart_mode.

*   Schreibe Status-Positionszeile.
    perform status_write_pos using ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.
*   Rücksetzen Fehler-Zähler.
    clear: g_err_counter, g_firstkey.

*   Falls Direkte Anforderung oder Restart mit definierten
*   Kundennummern.
    if pi_pdat <> space and pdat_lines > 0.
      special_numbers = 'X'.
    endif. " PI_PDAT <> SPACE AND PDAT_LINES > 0.

*   Besorgen der Stammdaten zum versenden.
    call function 'POS_PERSONAL_DATA_GET'
         exporting
              pi_only_special_numbers   = special_numbers
              pi_spart                  = pi_filia_const-spart
              pi_spras                  = pi_filia_const-spras
              pi_vkorg                  = pi_vkorg
              pi_vtweg                  = pi_vtweg
              pi_kkber                  = pi_filia_const-kkber
              pi_loeschen               = pi_loeschen
              pi_e1wpp02                = e1wpp02
              pi_e1wpp03                = e1wpp03
              pi_e1wpp05                = e1wpp05
              pi_e1edk28                = e1edk28
         importing
              pe_returncode             = fehlercode
         tables
              pet_persdata              = gt_pers_data
              pet_credit_card_data      = gt_credit_card_data
              pet_bank_data             = gt_bank_data
              pit_kunnr                 = pit_kunnr
         exceptions
              keine_stammdaten_gefunden = 01.

*   Falls Daten gefunden wurden.
    if sy-subrc = 0.
*     Prüfe, ob überhaupt Kreditkarten oder Bankverbindungen
*     im System gepflegt sind.
      case fehlercode.
*       Falls keine Kreditkarten gepflegt sind, dann tue so als
*       wäre das Kreditkartensegment reduziert worden.
        when 1.
          clear: e1wpp05.
*       Falls keine Bankverbindungen gepflegt sind, dann tue so als
*       wäre das Bankverbindungsegment reduziert worden.
        when 2.
          clear: e1edk28.
*       Falls weder Kreditkarten noch Bankverbindungen gepflegt
*       sind, dann tue so als seien beide Segmente reduziert worden.
        when 3.
          clear: e1wpp05, e1edk28.
      endcase. " fehlercode.

*     Initialisierungsfall, direkte Anforderung oder Restart.
*     (alle Personendaten übertragen)
      if pi_mode = c_init_mode or
         ( pi_pdat <> space and pdat_lines = 0 ).

*       Schleife über alle Personendaten.
        loop at gt_pers_data.
*         Merke 'Firstkey'.
          if g_new_firstkey <> space.
            g_firstkey = gt_pers_data-persnr.
            clear: g_new_firstkey.
          endif.                       " G_NEW_FIRSTKEY <> SPACE.

          call function 'MASTERIDOC_CREATE_DLPPERS'
               exporting
                    pi_debug             = pi_debug
*###                pi_ermod             = pi_filia_const-ermod
                    pi_persdat           = gt_pers_data
                    pi_aktivdat          = g_aktivdat
                    pi_dldnr             = g_dldnr
                    px_dldlfdnr          = g_dldlfdnr
                    pi_filia             = pi_filia
                    pi_express           = pi_express
                    pi_loeschen          = pi_loeschen
                    pi_mode              = pi_mode
                    pi_e1wpp02           = e1wpp02
                    pi_e1wpp03           = e1wpp03
*                   PI_E1WPP04           = E1WPP04
                    pi_e1wpp05           = e1wpp05
                    pi_e1edk28           = e1edk28
*                   PI_E1WPP07           = E1WPP07
                    px_segment_counter   = g_segment_counter
                    pi_filia_const       = pi_filia_const
               importing
                    px_segment_counter   = g_segment_counter
               tables
                    pit_credit_card_data = gt_credit_card_data
                    pit_bank_data        = gt_bank_data
               changing
                    pxt_idoc_data        = gt_idoc_data
               exceptions
                    download_exit         = 1.

*         Es sind Fehler beim Download aufgetreten'
          if sy-subrc = 1.
            raise download_exit.
          endif.                       " SY-SUBRC = 1.

        endloop.                       " AT GT_PERS_DATA.

*       Erzeuge letztes IDOC, falls nötig .
        if g_segment_counter > 0.
          perform idoc_create using  gt_idoc_data
                                     g_mestype_pers
                                     c_idoctype_pers
                                     g_segment_counter
                                     g_err_counter
                                     g_firstkey
                                     gt_pers_data-persnr
                                     g_dldnr
                                     g_dldlfdnr
                                     pi_filia
                                     pi_filia_const.

        endif.                         " G_SEGMENT_COUNTER > 0

*     Direkte Anforderung mit vorselektierten Kundennummern.
      elseif pi_pdat <> space and pdat_lines > 0.
*       Schleife über alle aufzubereitenden Kundennummern.
        loop at pit_kunnr.
*         Falls nötig, erzeuge Löschsatz.
          if pit_kunnr-upd_flag <> space.
*           Merke 'Firstkey'.
            if g_new_firstkey <> space.
              g_firstkey = pit_kunnr-kunnr.
              clear: g_new_firstkey.
            endif.                           " G_NEW_FIRSTKEY <> SPACE.

*           Erzeuge Datensatz zum löschen.
            perform pers_delete using pit_kunnr-kunnr
                                      g_aktivdat
                                      pi_filia_const-ermod
                                      pi_filia_const-kunnr
                                      gt_idoc_data
                                      g_returncode
                                      g_dldnr    g_dldlfdnr
                                      g_segment_counter.

*           Weiter zur nächsten Kundennummer.
            continue.
          endif. " pit_kunnr-upd_flag <> space.

*         Besorge die Daten zu dieser Kundennummer.
          read table gt_pers_data with key
               persnr = pit_kunnr-kunnr
               binary search.

*         Falls die Kundennummer nicht für diese Filiale aufbereitet
*         werden soll, dann weiter zur nächsten Kundennummer.
          if sy-subrc <> 0.
*           Aktualisiere Zählvariable für ignorierte Objekte für
*           spätere Statistikausgabe.
            add 1 to gi_stat_counter-pers_ign.

*           Weiter zum nächsten Satz.
            continue.
          endif. " sy-subrc <> 0.

*         Merke 'Firstkey'.
          if g_new_firstkey <> space.
            g_firstkey = gt_pers_data-persnr.
            clear: g_new_firstkey.
          endif.                       " G_NEW_FIRSTKEY <> SPACE.

          call function 'MASTERIDOC_CREATE_DLPPERS'
               exporting
                    pi_debug             = pi_debug
*###                pi_ermod             = pi_filia_const-ermod
                    pi_persdat           = gt_pers_data
                    pi_aktivdat          = g_aktivdat
                    pi_dldnr             = g_dldnr
                    px_dldlfdnr          = g_dldlfdnr
                    pi_filia             = pi_filia
                    pi_express           = pi_express
                    pi_loeschen          = pi_loeschen
                    pi_mode              = pi_mode
                    pi_e1wpp02           = e1wpp02
                    pi_e1wpp03           = e1wpp03
*                   PI_E1WPP04           = E1WPP04
                    pi_e1wpp05           = e1wpp05
                    pi_e1edk28           = e1edk28
*                   PI_E1WPP07           = E1WPP07
                    px_segment_counter   = g_segment_counter
                    pi_filia_const       = pi_filia_const
               importing
                    px_segment_counter   = g_segment_counter
               tables
                    pit_credit_card_data = gt_credit_card_data
                    pit_bank_data        = gt_bank_data
               changing
                    pxt_idoc_data        = gt_idoc_data
               exceptions
                    download_exit        = 1.

*         Es sind Fehler beim Download aufgetreten'
          if sy-subrc = 1.
            raise download_exit.
          endif.                       " SY-SUBRC = 1.
        endloop.                       " AT PIT_KUNNR.

*       Erzeuge letztes IDOC, falls nötig .
        if g_segment_counter > 0.
          perform idoc_create using  gt_idoc_data
                                     g_mestype_pers
                                     c_idoctype_pers
                                     g_segment_counter
                                     g_err_counter
                                     g_firstkey
                                     pit_kunnr-kunnr
                                     g_dldnr
                                     g_dldlfdnr
                                     pi_filia
                                     pi_filia_const.

        endif.                         " G_SEGMENT_COUNTER > 0
      endif.                           " PI_MODE = C_INIT_MODE OR  ...

*   Falls keine Daten gefunden wurden.
    else.                              " SY-SUBRC <> 0.
*     Falls Fehlerprotokollierung erwünscht.
      if pi_filia_const-ermod = space.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        if g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          clear: gi_errormsg_header.
          gi_errormsg_header-object        = c_applikation.
          gi_errormsg_header-subobject     = c_subobject.
          gi_errormsg_header-extnumber     = g_dldnr.
          gi_errormsg_header-extnumber+14  = g_dldlfdnr.
          gi_errormsg_header-aluser        = sy-uname.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          perform appl_log_init_with_header
                  using gi_errormsg_header.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        endif.                         " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        clear: gi_message.
        gi_message-msgty     = c_msgtp_warning.
        gi_message-msgid     = c_message_id.
        gi_message-probclass = c_probclass_weniger_wichtig.
*       'Keine Kundendaten für Verkaufsorganisation &
*        Vertriebsweg & gepflegt'.
        gi_message-msgno     = '143'.
        gi_message-msgv1     = pi_vkorg.
        gi_message-msgv2     = pi_vtweg.

*       Schreibe Fehlerzeile.
        clear: g_object_key.
        perform appl_log_write_single_message  using gi_message.

      endif.                           " PI_FILIA_CONST-ERMOD = SPACE.

*     Ändern der Status-Kopfzeile, falls nötig.
      if g_status < 2.                   " 'Benutzerhinweis'
*       Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
        clear: gi_status_header.
        gi_status_header-dldnr = g_dldnr.
        gi_status_header-gesst = c_status_benutzerhinweis.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        perform status_write_head using  'X'     gi_status_header
                                         g_dldnr g_returncode.

*       Aktualisiere Aufbereitungsstatus.
        g_status = 2.                  " 'Benutzerhinweis'
      endif. " G_STATUS < 2.  " 'Benutzerhinweis'

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      clear: gi_status_pos.
      gi_status_pos-dldnr  = g_dldnr.
      gi_status_pos-lfdnr  = g_dldlfdnr.
      gi_status_pos-anloz  = g_err_counter.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      if g_status_pos < 2.                   " 'Benutzerhinweis'
        gi_status_pos-gesst = c_status_benutzerhinweis.

        g_status_pos = 2.                    " 'Benutzerhinweis'
      endif. " g_status_pos < 2.             " 'Benutzerhinweis'

*     Schreibe Status-Positionszeile.
      perform status_write_pos using 'X' gi_status_pos  g_dldlfdnr
                                         g_returncode.

*     Schreibe Fehlermeldungen auf Datenbank.
      perform appl_log_write_to_db.

*     Falls Fehlerprotokollierung erwünscht.
      if pi_filia_const-ermod = space.
*       Verlassen der Aufbereitung für Warengruppen-IDOC's.
        exit.
*     Falls Abbruch bei Fehler erwünscht.
      else.                            " PI_FILIA_CONST-ERMOD <> SPACE.
*       Abbruch des Downloads.
        raise download_exit.
      endif.                           " PI_FILIA_CONST-ERMOD = SPACE.

    endif. " sy-subrc = 0 (Personendaten lesen)

*   Schreibe Fehlermeldungen auf Datenbank, falls nötig.
    if g_init_log <> space.
      perform appl_log_write_to_db.
    endif.                             " G_INIT_LOG <> SPACE.

*   Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*   auf OK.
    if g_status = 0.
*     Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
      clear: gi_status_header.
      gi_status_header-dldnr = g_dldnr.
      gi_status_header-gesst = c_status_ok.

*     Schreibe Status-Kopfzeile.
      perform status_write_head using  'X'      gi_status_header
                                       g_dldnr  g_returncode.
    endif.                             " G_STATUS = 0.
  endif.                               " E1WPP01 <> SPACE.


endform.                               " PERS_DOWNLOAD


*eject
************************************************************************
form pers_download_change_mode
     tables pit_filter_segs structure gt_filter_segs
            pit_ot3_pers    structure gt_ot3_pers
            pit_workdays    structure gt_workdays
     using  pi_filia_group  structure gt_filia_group
            pi_erstdat      like syst-datum
            pi_mode         like wpstruc-modus
            pi_dldnr        like wdls-dldnr
            pi_mestype      like edimsg-mestyp.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Personendaten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS : Liste aller für den POS-Download nicht benötigten
*                   Segmente.
* PIT_OT3_PERS    : Personendaten: Objekttabelle 3, filialabhängig.
*
* PIT_WORKDAYS    : Tabelle der Arbeitstage des Betrachtungszeitraums.
*
* PI_FILIA_GROUP  : Daten einer Filiale der Filialgruppe.
*
* PI_ERSTDAT      : Beginndatum des Downloads.
*
* PI_MODE         : = 'U', wenn Update-Modus, 'R' = Restart-Modus.
*
* PI_DLDNR        : Downloadnummer für Statusverfolgung.
*
* PI_MESTYPE      : Zu verwendender Nachrichtentyp
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: e1wpp01    value 'X', " Flag, ob Segm. E1WPP01 vers. werden muß
        e1wpp02    value 'X',
        e1wpp03    value 'X',
        e1wpp04    value 'X',
        e1wpp05    value 'X',
        e1edk28    value 'X',
        e1wpp07    value 'X',
        fehlercode like sy-subrc,
        h_datum    like sy-datum,
        h_loeschen.

* Feldleiste für Filialkonstanten.
  data: begin of i_filia_const.
          include structure wpfilconst.
  data: end of i_filia_const.

  data: begin of t_kunnr occurs 1.
          include structure wppdot3.
  data: end of t_kunnr.


* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  g_current_doctype = c_idoctype_pers.

* Übernehme Filialkonstanten in andere Feldleiste.
  move-corresponding pi_filia_group to i_filia_const.

* Prüfe, welche Personendatensegmente versendet werden müssen.
  loop at pit_filter_segs.

    case pit_filter_segs-segtyp.
      when c_e1wpp01_name.
        clear: e1wpp01.
      when c_e1wpp02_name.
        clear: e1wpp02.
      when c_e1wpp03_name.
        clear: e1wpp03.
      when c_e1wpp04_name.
        clear: e1wpp04.
      when c_e1wpp05_name.
        clear: e1wpp05.
      when c_e1edk28_name.
        clear: e1edk28.
      when c_e1wpp07_name.
        clear: e1wpp07.
    endcase.                           " PIT_FILTER_SEGS-SEGTYP

  endloop.                             " AT PIT_FILTER_SEGS

* Es müssen Personendaten versendet werden.
  if e1wpp01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    clear: g_segment_counter, g_new_position, g_status_pos.

*   Rücksetzen Fehler-Zähler.
    clear: g_err_counter, g_firstkey.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Vorbesetzen Aktivierungsdatum.
    g_aktivdat = pi_erstdat.

*   Besorge das Datum des Versendetages.
    perform next_workday_get tables pit_workdays
                             using  g_aktivdat
                                    h_datum.

    g_aktivdat = h_datum.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    clear: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-doctyp = c_idoctype_pers.

*   Schreibe Status-Positionszeile.
    perform status_write_pos using ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Übernehme alle nicht zu löschenden Kundennummern in eine andere
*   interne Tabelle Struktur.
    refresh: gt_pers_data, t_kunnr.
    loop at pit_ot3_pers
      where upd_flag <> c_del.
      append pit_ot3_pers to t_kunnr.
    endloop.                           " AT PIT_OT3_PERS.

*   Falls Daten übernommen wurden
    if sy-subrc = 0.
*     Besorgen der Stammdaten zum versenden.
      call function 'POS_PERSONAL_DATA_GET'
           exporting
                pi_only_special_numbers   = 'X'
                pi_spart                  = pi_filia_group-spart
                pi_spras                  = pi_filia_group-spras
                pi_vkorg                  = pi_filia_group-vkorg
                pi_vtweg                  = pi_filia_group-vtweg
                pi_kkber                  = pi_filia_group-kkber
                pi_e1wpp02                = e1wpp02
                pi_e1wpp03                = e1wpp03
                pi_e1wpp05                = e1wpp05
                pi_e1edk28                = e1edk28
           importing
                pe_returncode             = fehlercode
           tables
                pet_persdata              = gt_pers_data
                pet_credit_card_data      = gt_credit_card_data
                pet_bank_data             = gt_bank_data
                pit_kunnr                 = t_kunnr
           exceptions
                keine_stammdaten_gefunden = 01.

*     Prüfe, ob überhaupt Kreditkarten oder Bankverbindungen
*     im System gepflegt sind.
      case fehlercode.
*       Falls keine Kreditkarten gepflegt sind, dann tue so als
*       wäre das Kreditkartensegment reduziert worden.
        when 1.
          clear: e1wpp05.
*       Falls keine Bankverbindungen gepflegt sind, dann tue so als
*       wäre das Bankverbindungsegment reduziert worden.
        when 2.
          clear: e1edk28.
*       Falls weder Kreditkarten noch Bankverbindungen gepflegt
*       sind, dann tue so als seien beide Segmente reduziert worden.
        when 3.
          clear: e1wpp05, e1edk28.
      endcase. " fehlercode.
    endif.                             " SY-SUBRC = 0.

*   Schleife über alle Kundenstammänderungen.
    loop at pit_ot3_pers.
      clear: gt_pers_data, h_loeschen.

*     Falls die Kundennummer gelöscht wurde.
      if pit_ot3_pers-upd_flag = c_del.
*       Setze Löschmerker für Fehlerobjekttabelle WDLSO.
        g_object_delete = 'X'.

*       Setze Löschmerker für Aufbereitung.
        h_loeschen = 'X'.
        gt_pers_data-persnr = pit_ot3_pers-kunnr.

*     Falls die Kundennummer nicht gelöscht wurde.
      else.                            " PIT_OT3_PERS-UPD_FLAG <> C_DEL.
*       Rücksetze Löschmerker für Fehlerobjekttabelle WDLSO.
        clear: g_object_delete.

*       Rücksetze Löschmerker für Aufbereitung.
        clear: h_loeschen.

*       Besorge die Daten zu dieser Kundennummer.
        read table gt_pers_data with key
             persnr = pit_ot3_pers-kunnr
             binary search.

*       Falls die Kundennummer nicht für diese Filiale aufbereitet
*       werden soll, dann nächsten Eintrag.
        if sy-subrc <> 0.
*         Aktualisiere Zählvariable für ignorierte Objekte für
*         spätere Statistikausgabe.
          add 1 to gi_stat_counter-pers_ign.

*         Weiter zum nächsten Satz.
          continue.
        endif. " sy-subrc <> 0.

      endif.                           " PIT_OT3_PERS-UPD_FLAG = C_DEL.

*     Merke 'Firstkey'.
      if g_new_firstkey <> space.
        g_firstkey = gt_pers_data-persnr.
        clear: g_new_firstkey.
      endif.                           " G_NEW_FIRSTKEY <> SPACE.

      call function 'MASTERIDOC_CREATE_DLPPERS'
           exporting
                pi_debug             = ' '
*###            pi_ermod             = pi_filia_group-ermod
                pi_persdat           = gt_pers_data
                pi_aktivdat          = g_aktivdat
                pi_dldnr             = pi_dldnr
                px_dldlfdnr          = g_dldlfdnr
                pi_filia             = pi_filia_group-filia
                pi_express           = ' '
                pi_loeschen          = h_loeschen
                pi_mode              = pi_mode
                pi_e1wpp02           = e1wpp02
                pi_e1wpp03           = e1wpp03
*               PI_E1WPP04           = E1WPP04
                pi_e1wpp05           = e1wpp05
                pi_e1edk28           = e1edk28
*               PI_E1WPP07           = E1WPP07
                px_segment_counter   = g_segment_counter
                pi_filia_const       = i_filia_const
           importing
                px_segment_counter   = g_segment_counter
           tables
                pit_credit_card_data = gt_credit_card_data
                pit_bank_data        = gt_bank_data
           changing
                pxt_idoc_data        = gt_idoc_data
           exceptions
                download_exit        = 1.

*     Es sind Fehler beim Download aufgetreten'
      if sy-subrc = 1.
        raise error_code_1.
      endif.                           " SY-SUBRC = 1.

    endloop.                           " AT PIT_OT3_PERS.

*   Erzeuge letztes IDOC, falls nötig .
    if g_segment_counter > 0.
      perform idoc_create using  gt_idoc_data
                                 pi_mestype
                                 c_idoctype_pers
                                 g_segment_counter
                                 g_err_counter
                                 g_firstkey
                                 gt_pers_data-persnr
                                 pi_dldnr    g_dldlfdnr
                                 pi_filia_group-filia
                                 i_filia_const.

    endif.                             " G_SEGMENT_COUNTER > 0

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
  endif.                               " E1WPP01 <> SPACE.


endform.                               " PERS_DOWNLOAD_CHANGE_MODE


*eject.
************************************************************************
form idoc_dataset_pers_append
     tables   pit_bank_data         structure gt_bank_data
              pit_credit_card_data  structure gt_credit_card_data
     using    pi_persdat            structure gt_pers_data
              pi_datum              like syst-datum
              px_segcnt             like g_segment_counter
              pi_loeschen           like wpstruc-modus
              pi_e1wpp02            like wpstruc-modus
              pi_e1wpp03            like wpstruc-modus
              pi_e1wpp04            like wpstruc-modus
              pi_e1wpp05            like wpstruc-modus
              pi_e1edk28            like wpstruc-modus
              pi_e1wpp07            like wpstruc-modus
              pi_filia              like t001w-werks
     changing pxt_idoc_data         type short_edidd
              value(pe_fehlercode)  like g_returncode
              pi_dldnr              like wdls-dldnr
              pi_dldlfdnr           like wdlsp-lfdnr
              pi_filia_const        like wpfilconst.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:

* PIT_BANK_DATA: Bankverbindungen aller Kundennummern.
*
* PET_CREDIT_CARD_DATA: Kreditkarteninformationen aller Kundennummern.

* PI_PERSDAT   : Daten einer Kundennummer.
*
* PI_DATUM     : Datum für das die Daten aufbereitet werden sollen.
*
* PX_SEGCNT    : Segment-Zähler.
*
* PI_LOESCHEN  : = 'X', wenn Löschmodus aktiv.
*
* PI_E1WPP02   : = 'X', wenn Segment E1WPP02 aufbereitet werden soll.
*
* PI_E1WPP03   : = 'X', wenn Segment E1WPP03 aufbereitet werden soll.
*
* PI_E1WPP04   : = 'X', wenn Segment E1WPP04 aufbereitet werden soll.
*
* PI_E1WPP05   : = 'X', wenn Segment E1WPP05 aufbereitet werden soll.
*
* PI_E1EDK28   : = 'X', wenn Segment E1EDK28 aufbereitet werden soll.
*
* PI_E1WPP07   : = 'X', wenn Segment E1WPP07 aufbereitet werden soll.
*
* PI_FILIA     : Filiale, an die versendet werden soll.

* PXT_IDOC_DATA: IDOC-Daten der Struktur EDIDD (Tabelle an die die
*                IDOC-Sätze angefügt werden).
* PE_FEHLERCODE: > 0, wenn Fehler beim Umsetzen der Daten.

* PI_DLDNR     : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_FILIA_CONST: Filialkonstanten.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: seg_local_cnt type i,
        e1wpp05_cnt   type i,
        e1edk28_cnt   type i.


* Rücksetze Returncode.
  clear: pe_fehlercode.

* Rücksetze Temporärtabelle für IDOC-Daten.
  refresh: gt_idoc_data_temp.

* Rücksetze lokalen Segmentzähler.
  clear: seg_local_cnt.

* Aufbereitung ID-Segment.
  clear: e1wpp01.
  e1wpp01-filiale    = pi_filia_const-kunnr.
  e1wpp01-aktivdatum = pi_datum.
  e1wpp01-aenddatum  = '00000000'.
  e1wpp01-aenderer   = ' '.
  e1wpp01-qualifier  = c_qualifier.
  e1wpp01-persnr     = pi_persdat-persnr.

* Falls Löschmodus aktiv.
  if pi_loeschen <> space.
    e1wpp01-aendkennz  = c_delete.
* Falls Löschmodus nicht aktiv.
  else.
    e1wpp01-aendkennz  = c_modi.
  endif.                               " PI_LOESCHEN <> SPACE.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpp01_name.
  gt_idoc_data_temp-sdata  = e1wpp01.
  append gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  add 1 to seg_local_cnt.

* Es müssen Stammdaten übertragen werden, da kein Löschmodus aktiv ist.
  if pi_loeschen = space.
*   Falls Segment E1WPP02 Personendaten Stammdaten gefüllt werden muß.
    if pi_e1wpp02 <> space.
*     Fehler, falls das Kreditlimit nicht gepflegt wurde
      if pi_persdat-kredlimit = space.
*       Falls Fehlerprotokollierung erwünscht.
        if pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          if g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            clear: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = pi_dldnr.
            gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            perform appl_log_init_with_header  using gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          endif.                           " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          clear: gi_message.
          gi_message-msgty     = c_msgtp_warning.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_weniger_wichtig.
*         'Gesamtkreditlimit für Kundennummer & nicht im Kundenstamm
*          gepflegt'
          gi_message-msgno     = '144'.
          gi_message-msgv1     = pi_persdat-persnr.

*         Schreibe Fehlerzeile für Application-Log und WDLSO.
          clear: g_object_key.
          perform appl_log_write_single_message using  gi_message.
        endif.                          " PI_FILIA_CONST-ERMOD = SPACE

*       Ändern der Status-Kopfzeile, falls nötig.
        if g_status < 2.                   " 'Benutzerhinweis'
          clear: gi_status_header.
          gi_status_header-dldnr = pi_dldnr.
          gi_status_header-gesst = c_status_benutzerhinweis.

*         Korrigiere Status-Kopfzeile auf "Fehlerhaft".
          perform status_write_head using  'X'  gi_status_header
                                           pi_dldnr  g_returncode.

*         Aktualisiere Aufbereitungsstatus.
          g_status = 2.                   " 'Hinweis'

        endif. " g_status < 2.                   " 'Benutzerhinweis'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        clear: gi_status_pos.
        gi_status_pos-dldnr  = pi_dldnr.
        gi_status_pos-lfdnr  = pi_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.
        gi_status_pos-anseg  = px_segcnt.
        gi_status_pos-stkey  = g_firstkey.
        gi_status_pos-ltkey  = pi_persdat-persnr.

*       Aktualisiere Aufbereitungsstatus für Positionszeile,
*       falls nötig.
        if g_status_pos < 2.                   " 'Benutzerhinweis'
          gi_status_pos-gesst = c_status_benutzerhinweis.

          g_status_pos = 2.                    " 'Benutzerhinweis'
        endif. " g_status_pos < 2.                   " 'Benutzerhinweis'

*       Schreibe Status-Positionszeile.
        perform status_write_pos using 'X' gi_status_pos  pi_dldlfdnr
                                           g_returncode.
      endif.  " pi_persdat-kredlimit = space.

*     Falls überhaupt Daten zum Füllen des Segments vorhanden sind.
      if not pi_persdat-name is initial or
         not pi_persdat-kredlimit is initial.
*       Aufbereitung Segment Personendaten Stammdaten.
        clear: e1wpp02.
        e1wpp02-name        = pi_persdat-name.
        e1wpp02-geburtstag  = '00000000'.
        e1wpp02-kredlimit   = pi_persdat-kredlimit.
        condense e1wpp02-kredlimit.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpp02_name.
        gt_idoc_data_temp-sdata  = e1wpp02.
        append gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        add 1 to seg_local_cnt.
      endif. " not pit_persdat-name is initial ...
    endif.                             " PI_E1WPP02 <> SPACE.

*   Falls Segment E1WPP03 Adressen gefüllt werden muß.
    if pi_e1wpp03 <> space.
*     Aufbereitung Segment Adressen.
      clear: e1wpp03.
      e1wpp03-plz         = pi_persdat-plz.
      e1wpp03-ort         = pi_persdat-ort.
      e1wpp03-strasse     = pi_persdat-strasse.
      e1wpp03-telefon     = pi_persdat-telefon.
      e1wpp03-fax         = pi_persdat-fax.
      e1wpp03-bemerkung   = pi_persdat-bemerkung.
      e1wpp03-firma       = pi_persdat-firma.

*     Falls dieses Segment Daten enhält.
      if not e1wpp03 is initial.
*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpp03_name.
        gt_idoc_data_temp-sdata  = e1wpp03.
        append gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        add 1 to seg_local_cnt.
      endif. " not e1wpp03 is initial.
    endif.                             " PI_E1WPP03 <> SPACE.

*   Falls Segment E1WPP04 Konditionen gefüllt werden muß.
    if pi_e1wpp04 <> space.
************************************************************************
* Derzeit nicht geplant.
************************************************************************
    endif.                             " PI_E1WPP04 <> SPACE.

*   Falls Segment E1WPP05 Kreditkarten gefüllt werden muß.
    if pi_e1wpp05 <> space.
*     Initialisiere Zähler für Kreditkarteninfo.
      clear: e1wpp05_cnt.

*     Aufbereitung Segment Kreditkarteninformationen.
      loop at pit_credit_card_data
           where kunnr = pi_persdat-persnr.

*       Aktualisiere Zähler für Kreditkarteninfo.
        add 1 to e1wpp05_cnt.

        clear: e1wpp05.
        e1wpp05-kartennr   = pit_credit_card_data-kartennr.
        e1wpp05-zahlart    = pit_credit_card_data-zahlart.
        e1wpp05-kartentyp  = pit_credit_card_data-kartentyp.
        e1wpp05-gueltvon   = pit_credit_card_data-gueltvon.
        e1wpp05-gueltbis   = pit_credit_card_data-gueltbis.
        e1wpp05-sperre     = pit_credit_card_data-sperre.
        e1wpp05-sperrgrund = pit_credit_card_data-sperrgrund.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpp05_name.
        gt_idoc_data_temp-sdata  = e1wpp05.
        append gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        add 1 to seg_local_cnt.
      endloop. " at pit_credit_card_data

*     Hinweis, falls keine Kreditkarteninformation gepflegt wurde
      if sy-subrc <> 0.
*       Falls Fehlerprotokollierung erwünscht.
        if pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          if g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            clear: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = pi_dldnr.
            gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            perform appl_log_init_with_header  using gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          endif.                           " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          clear: gi_message.
          gi_message-msgty     = c_msgtp_warning.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_weniger_wichtig.
*         'Keine Kreditkarteninformationen für Kundennummer &
*          gepflegt'.
          gi_message-msgno     = '151'.
          gi_message-msgv1     = pi_persdat-persnr.

*         Schreibe Fehlerzeile.
          clear: g_object_key.
          perform appl_log_write_single_message using  gi_message.
        endif.                         " PI_FILIA_CONST-ERMOD = SPACE.

*       Ändern der Status-Kopfzeile, falls nötig.
        if g_status < 2.                   " 'Benutzerhinweis'
          clear: gi_status_header.
          gi_status_header-dldnr = pi_dldnr.
          gi_status_header-gesst = c_status_benutzerhinweis.

*         Korrigiere Status-Kopfzeile auf "Fehlerhaft".
          perform status_write_head using  'X'  gi_status_header
                                           pi_dldnr  g_returncode.

*         Aktualisiere Aufbereitungsstatus.
          g_status = 2.                   " 'Hinweis'

        endif. " G_STATUS < 2.  " 'Hinweis'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        clear: gi_status_pos.
        gi_status_pos-dldnr  = pi_dldnr.
        gi_status_pos-lfdnr  = pi_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.
        gi_status_pos-anseg  = px_segcnt.
        gi_status_pos-stkey  = g_firstkey.
        gi_status_pos-ltkey  = pi_persdat-persnr.

*       Aktualisiere Aufbereitungsstatus für Positionszeile,
*       falls nötig.
        if g_status_pos < 2.                   " 'Benutzerhinweis'
          gi_status_pos-gesst = c_status_benutzerhinweis.

          g_status_pos = 2.                    " 'Benutzerhinweis'
        endif. " g_status_pos < 2.             " 'Benutzerhinweis'

*       Schreibe Status-Positionszeile.
        perform status_write_pos using 'X' gi_status_pos  pi_dldlfdnr
                                           g_returncode.

      endif.  "  sy-subrc <> 0.
    endif.                             " PI_E1WPP05 <> SPACE.

*   Falls Segment E1EDK28 Bankverbindungen gefüllt werden muß.
    if pi_e1edk28 <> space.
*     Initialisiere Zähler für Bankverbindungen.
      clear: e1edk28_cnt.

*     Aufbereitung Segment Bankverbindungen.
      loop at pit_bank_data
           where kunnr = pi_persdat-persnr.

*       Aktualisiere Zähler für Bankverbindungen.
        add 1 to e1edk28_cnt.

        clear: e1edk28.
        e1edk28-bcoun = pit_bank_data-bcoun.
        e1edk28-brnum = pit_bank_data-brnum.
        e1edk28-bname = pit_bank_data-bname.
        e1edk28-baloc = pit_bank_data-baloc.
        e1edk28-acnum = pit_bank_data-acnum.
        e1edk28-acnam = pit_bank_data-acnam.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1edk28_name.
        gt_idoc_data_temp-sdata  = e1edk28.
        append gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        add 1 to seg_local_cnt.
      endloop. " at pit_bank_data.

*     Hinweis, falls keine Bankverbindungen gepflegt wurde
      if sy-subrc <> 0.
*       Falls Fehlerprotokollierung erwünscht.
        if pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          if g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            clear: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = pi_dldnr.
            gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            perform appl_log_init_with_header  using gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          endif.                           " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          clear: gi_message.
          gi_message-msgty     = c_msgtp_warning.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_weniger_wichtig.
*         'Keine Bankverbindung für Kundennummer & gepflegt'.
          gi_message-msgno     = '150'.
          gi_message-msgv1     = pi_persdat-persnr.

*         Schreibe Fehlerzeile.
          clear: g_object_key.
          perform appl_log_write_single_message using  gi_message.
        endif.                           " PI_FILIA_CONST-ERMOD = SPACE

*       Ändern der Status-Kopfzeile, falls nötig.
        if g_status < 2.                   " 'Benutzerhinweis'
          clear: gi_status_header.
          gi_status_header-dldnr = pi_dldnr.
          gi_status_header-gesst = c_status_benutzerhinweis.

*         Korrigiere Status-Kopfzeile auf "Fehlerhaft".
          perform status_write_head using  'X'  gi_status_header
                                           pi_dldnr  g_returncode.

*         Aktualisiere Aufbereitungsstatus.
          g_status = 2.                   " 'Hinweis'

        endif. " G_STATUS < 2.  " 'Hinweis'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        clear: gi_status_pos.
        gi_status_pos-dldnr  = pi_dldnr.
        gi_status_pos-lfdnr  = pi_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.
        gi_status_pos-anseg  = px_segcnt.
        gi_status_pos-stkey  = g_firstkey.
        gi_status_pos-ltkey  = pi_persdat-persnr.

*       Aktualisiere Aufbereitungsstatus für Positionszeile,
*       falls nötig.
        if g_status_pos < 2.                   " 'Benutzerhinweis'
          gi_status_pos-gesst = c_status_benutzerhinweis.

          g_status_pos = 2.                    " 'Benutzerhinweis'
        endif. " g_status_pos < 2.             " 'Benutzerhinweis'

*       Schreibe Status-Positionszeile.
        perform status_write_pos using 'X' gi_status_pos  pi_dldlfdnr
                                           g_returncode.

      endif.  "  sy-subrc <> 0.
    endif.                             " PI_E1EDK28 <> SPACE.

*   Falls Segment E1WPP07 Klassifizierung gefüllt werden muß.
    if pi_e1wpp07 <> space.
************************************************************************
* Nicht zu Rel. 3.0 geplant.
************************************************************************
    endif.                             " PI_E1WPP07 <> SPACE.

  endif.                               " PI_LOESCHEN = SPACE.


*********************************************************************
***********************   U S E R - E X I T  ************************
  call customer-function '008'
       exporting
            pi_e1wpp05_cnt     = e1wpp05_cnt
            pi_e1edk28_cnt     = e1edk28_cnt
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
            pi_loeschen        = PI_LOESCHEN
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
      g_object_key = pi_persdat-persnr.

*     Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
      perform error_object_write.

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
      exit.
*   Falls Abbruch bei Fehler erwünscht.
    else.                              " PI_ERMOD <> SPACE.
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

endform.                               " IDOC_DATASET_PERS_APPEND


* eject.
************************************************************************
form pers_delete
     using  pi_kunnr       like  wppdot3-kunnr
            pi_datum       like  gt_ot3_ean-datum
            pi_ermod       like  gt_filia_group-ermod
            pi_filia_kunnr like  gt_filia_group-kunnr
   changing pxt_idoc_data  type  short_edidd
            value(pe_fehlercode) like syst-subrc
            pi_dldnr       like wdls-dldnr
            pi_dldlfdnr    like wdlsp-lfdnr
            px_segcnt      like g_segment_counter.
************************************************************************
* FUNKTION:
* Erzeuge Löschsatz für Kundennummer PI_KUNNR.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_DATUM      : Versendedatum
*
* PI_ERMOD      : = SPACE, wenn Fehlerprotokollierung erwünscht, sonst
*                 'X'.
* PI_FILIA_KUNNR : Kundennummer der Filiale.

* PXT_IDOC_DATA : Tabelle der IDOC-Daten.
*
* PE_FEHLERCODE : = '1', wenn Datenumsetzung mißlungen, sonst '0'.
*
* PI_DLDNR      : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR   : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PX_SEGCNT     : Segmentzähler.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: seg_local_cnt type i,
        e1wpp05_cnt   type i value 0,
        e1edk28_cnt   type i value 0,
        l_delete      like wpstruc-modus.


* Rücksetze Temporärtabelle für IDOC-Daten.
  refresh: gt_idoc_data_temp.

* Rücksetze Fehlercode.
  clear: pe_fehlercode.

* Aufbereitung ID-Segment.
  clear: e1wpp01.
  e1wpp01-filiale    = pi_filia_kunnr.
  e1wpp01-aktivdatum = pi_datum.
  e1wpp01-aenddatum  = '00000000'.
  e1wpp01-aenderer   = ' '.
  e1wpp01-qualifier  = c_qualifier.
  e1wpp01-persnr     = pi_kunnr.
  e1wpp01-aendkennz  = c_delete.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpp01_name.
  gt_idoc_data_temp-sdata  = e1wpp01.
  append gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  add 1 to seg_local_cnt.

* set local parameter
  l_delete = 'X'.
*********************************************************************
***********************   U S E R - E X I T  ************************
  call customer-function '008'
       exporting
            pi_e1wpp05_cnt     = e1wpp05_cnt
            pi_e1edk28_cnt     = e1edk28_cnt
            px_segment_counter = px_segcnt
            pi_seg_local_cnt   = seg_local_cnt
            pi_dldnr           = pi_dldnr
            pi_dldlfdnr        = pi_dldlfdnr
            pi_ermod           = pi_ermod
            pi_firstkey        = g_firstkey
            px_init_log        = g_init_log
            px_status          = g_status
            px_status_pos      = g_status_pos
            px_err_counter     = g_err_counter
            pi_loeschen        = l_delete
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
    if pi_ermod = space.
*     Fülle allgemeinen Objektschlüssel.
      g_object_key    = pi_kunnr.
      g_object_delete = 'X'.

*     Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
      perform error_object_write.

*     Rücksetze Löschkennzeichen für Fehlerobjekttabelle WDLSO.
      clear: g_object_delete.

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
      exit.
*   Falls Abbruch bei Fehler erwünscht.
    else.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      raise download_exit.
    endif.                             " PI_ERMOD = SPACE.

* Falls Umschlüsselung fehlerfrei.
  else.                                " PE_FEHLERCODE = 0.
*   Übernehme die IDOC-Daten aus Temporärtabelle.
    perform idoc_data_assume tables  gt_idoc_data_temp
                             using   pxt_idoc_data
                                     px_segcnt
                                     seg_local_cnt.

  endif.                               " PE_FEHLERCODE <> 0.
*********************************************************************


endform.                               " pers_delete


*eject
************************************************************************
form pers_change_mode_prepare
     tables pit_ot3_pers           structure gt_ot3_pers
            pit_filter_segs        structure gt_filter_segs
            pit_workdays           structure gt_workdays
            pxt_kunnr_credit       structure gt_kunnr_credit_buf
            pxt_kunnr_bank         structure gt_kunnr_bank_buf
            pxt_credit_data        structure gt_credit_data_buf
            pxt_bank_data          structure gt_bank_data_buf
            pxt_master_idocs       structure gt_master_idocs
            pit_independence_check structure gt_independence_check
            pxt_rfcdest            structure gt_rfcdest
            pxt_wdlsp_buf          structure gt_wdlsp_buf
            pxt_wdlso_parallel     structure gt_wdlso_parallel
     using  pi_filia_group         structure gt_filia_group
            px_independence_check  structure gt_independence_check
            px_stat_counter        structure gi_stat_counter
            pi_idoctype            like edimsg-idoctyp
            pi_mestype             like edimsg-mestyp
            pi_dldnr               like g_dldnr
            pi_erstdat             like syst-datum
            pi_mode                like wpstruc-modus
            pi_parallel            like wpstruc-parallel
            pi_server_group        like wpstruc-servergrp
            px_taskname            like wpstruc-counter6
            px_snd_jobs            like wpstruc-counter6.
************************************************************************
* FUNKTION:
* IDOC-Aufbereitung der Personendaten.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Aufbereitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT3_PERS          : Personendaten: Objekttabelle 3.
*
* PIT_FILTER_SEGS       : Reduzierinformationen.
*
* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PXT_KUNNR_CREDIT      : Kundennummern für Kreditkarteninformationen.
*
* PXT_KUNNR_BANK        : Kundennummern für Bankdaten.
*
* PXT_CREDIT_DATA       : Kreditkarteninformationen.
*
* PXT_BANK_DATA         : Bankdaten.
*
* PXT_MASTER_IDOCS      : Tabelle der kopierfähigen IDOC's
*
* PIT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_RFCDEST           : Tabelle der fehlerhaften Tasks
*
* PXT_WDLSP_BUF         : Tabelle der erzeugten Status-Positionszeilen.
*
* PXT_WDLSO_PARALLEL    : Tabelle der nachzubereitenden fehlerhaften
*                         Objekte.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
*
* PX_INDEPENDENCE_CHECK : Tabellenkopfzeile der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PX_STAT_COUNTER       : Feldleiste für Statistikinformationen.
*
* PI_IDOCTYPE           : Name der Original Zwischenstruktur.
*
* PI_MESTYPE            : Zu verwendender Nachrichtentyp für
*                         Objekt Warengruppen.
* PI_DLDNR              : Downloadnummer
*
* PI_ERSTDAT            : Datum: jetziges Versenden.
*
* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.
*
* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erwünscht,
*                                sonst SPCACE.
* PI_SERVER_GROUP       : Name der Server-Gruppe für
*                         Parallelverarbeitung.
* PX_TASKNAME           : Identifiziernder Name des aktuellen Tasks.
*
* PX_SND_JOBS           : Anzahl der gestarteten parallelen Tasks.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Feldleiste für Statistikinformation.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Falls nicht parallelisiert werden soll.
  if pi_parallel is initial.
*   IDOC-Aufbereitung der Personendaten.
    call function 'POS_PERS_CHG_MODE_PREPARE'
         exporting
              pi_filia_group         = pi_filia_group
              pi_idoctype            = pi_idoctype
              pi_mestype             = pi_mestype
              pi_dldnr               = pi_dldnr
              pi_erstdat             = pi_erstdat
              pi_mode                = pi_mode
              pi_parallel            = pi_parallel
              pi_independence_check  = px_independence_check
         importing
              pe_independence_check  = px_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pit_ot3_pers           = pit_ot3_pers
              pit_filter_segs        = pit_filter_segs
              pit_workdays           = pit_workdays
              pit_master_idocs       = pxt_master_idocs
              pit_independence_check = pit_independence_check.

*   Aktualisiere Statisktikinformation.
    px_stat_counter-pers_ign = i_stat_counter-pers_ign.

* Falls  parallelisiert werden soll.
  else. " not pi_parallel is initial.
*   Setze neuen Tasknamen.
    add 1 to px_taskname.

*   Übernehme Variablen für Wiederaufsetzen im Fehlerfalle in
*   interne Tabelle.
    clear: gt_task_variables.
    gt_task_variables-taskname = px_taskname.
    gt_task_variables-mestype  = pi_mestype.
    append gt_task_variables.

*   IDOC-Aufbereitung der Artikelstammdaten in parallelem Task.
    call function 'POS_PERS_CHG_MODE_PREPARE'
         starting new task px_taskname
         destination in group pi_server_group
         performing return_pers_chg_mode_prepare on end of task
         exporting
              pi_filia_group         = pi_filia_group
              pi_idoctype            = pi_idoctype
              pi_mestype             = pi_mestype
              pi_dldnr               = pi_dldnr
              pi_erstdat             = pi_erstdat
              pi_mode                = pi_mode
              pi_parallel            = pi_parallel
              pi_independence_check  = px_independence_check
         tables
              pit_ot3_pers           = pit_ot3_pers
              pit_filter_segs        = pit_filter_segs
              pit_workdays           = pit_workdays
              pit_master_idocs       = pxt_master_idocs
              pit_independence_check = pit_independence_check
              pxt_kunnr_credit       = pxt_kunnr_credit
              pxt_credit_data        = pxt_credit_data
              pxt_kunnr_bank         = pxt_kunnr_bank
              pxt_bank_data          = pxt_bank_data
         exceptions
              communication_failure  = 1
              system_failure         = 2
              resource_failure       = 3.

*   Falls eine Parallelverarbeitung gerade nicht möglich ist, dann
*   dann arbeite sequentiell.
    if sy-subrc <> 0.
*     Falls Probleme mit dem Zielsystem auftraten.
      if sy-subrc <> 3.
        clear: pxt_rfcdest.

*       Aktualisiere Fehlertabelle für Zielsysteme.
        pxt_rfcdest-subrc = sy-subrc.
        call function 'SPBT_GET_PP_DESTINATION'
             importing
                  rfcdest = pxt_rfcdest-rfcdest.

*       Aktualisiere System-Zeitstempel
        commit work.

        pxt_rfcdest-datum    = sy-datum.
        pxt_rfcdest-uzeit    = sy-uzeit.
        pxt_rfcdest-no_start = 'X'.
        pxt_rfcdest-filia    = pi_filia_group-filia.
        append pxt_rfcdest.
      endif. " sy-subrc <> 3.

*   IDOC-Aufbereitung der Personendaten.
    call function 'POS_PERS_CHG_MODE_PREPARE'
         exporting
              pi_filia_group         = pi_filia_group
              pi_idoctype            = pi_idoctype
              pi_mestype             = pi_mestype
              pi_dldnr               = pi_dldnr
              pi_erstdat             = pi_erstdat
              pi_mode                = pi_mode
              pi_parallel            = pi_parallel
              pi_independence_check  = px_independence_check
         importing
              pe_independence_check  = px_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pit_ot3_pers           = pit_ot3_pers
              pit_filter_segs        = pit_filter_segs
              pit_workdays           = pit_workdays
              pit_master_idocs       = pxt_master_idocs
              pit_independence_check = pit_independence_check.

*   Aktualisiere Statisktikinformation.
    px_stat_counter-pers_ign = i_stat_counter-pers_ign.

*   Falls eine Parallelverarbeitung möglich ist.
    else. " sy-subrc = 0.
*     Bestimme die verwendetet Destination.
      call function 'SPBT_GET_PP_DESTINATION'
           importing
                rfcdest = gt_rfc_indicator-rfcdest.

*     Merken der gestarteten Destination.
      gt_rfc_indicator-taskname = px_taskname.
      append gt_rfc_indicator.

*     Aktualisiere die Anzahl der parallelen Tasks
      add 1 to px_snd_jobs.
    endif. " sy-subrc <> 0.

  endif. " pi_parallel is initial.


endform. " pers_change_mode_prepare
