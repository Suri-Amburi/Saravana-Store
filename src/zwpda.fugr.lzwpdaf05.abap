*-------------------------------------------------------------------
***INCLUDE LWPDAF05 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Nachzugsartikel.
************************************************************************


************************************************************************
FORM nart_download
     TABLES pit_filter_segs STRUCTURE gt_filter_segs
            pit_artikel     STRUCTURE wpart
            pit_art_equal   STRUCTURE wpart
     USING  pi_filia_const  STRUCTURE gi_filia_const
            pi_vkorg        LIKE wpstruc-vkorg
            pi_vtweg        LIKE wpstruc-vtweg
            pi_filia        LIKE wpfilia-filia
            pi_express      LIKE wpstruc-modus
            pi_loeschen     LIKE wpstruc-modus
            pi_mode         LIKE wpstruc-modus
            pi_datum_ab     LIKE wpstruc-datum
            pi_datum_bis    LIKE wpstruc-datum
            pi_nart         LIKE wpstruc-modus
            pi_debug        LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Beginn des Downloads der Nachzugsartikel.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PIT_ARTIKEL    : Liste der zu übertragenden Nachzugsartikel, falls
*                  PI_MODE = 'A' und PI_NART = 'X'.
* PIT_ART_EQUAL  : Liste der Artikel mit SELECT-OPTION = 'EQUAL',
*                  falls PI_MODE = 'A' und PI_NART = 'X'.
* PI_FILIA_CONST : Feldleiste mit Filialkonstanten.

* PI_VKORG       : Verkaufsorganisation.

* PI_VTWEG       : Vertriebsweg.

* PI_FILIA       : Filiale, an die verschickt werden soll.

* PI_EXPRESS     := 'X', wenn sofort versendet werden soll, sonst SPACE.

* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                        sollen, sonst SPACE.
* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'A' = direkte
*                        Anforderung, 'R' = Restart.
* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.

* PI_DATUM_BIS   : Ende des Betrachtungszeitraums.

* PI_NART        : = 'X', wenn Nachzugsartikel übertragen werden sollen
*                  (kann nur bei direkter Anforderung gesetzt sein).
* PI_DEBUG       : = 'X', wenn Status-Positionszeile ständig
*                         aktualisiert werden soll, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: e1wpn01           VALUE 'X', " Flag, ob Segm. E1WPN01 vers. werden muß
        e1wpn02           VALUE 'X',
        nart_lines        TYPE i,
        vrkme             LIKE marm-meinh,
        h_ean             LIKE wpdel-ean,
        no_article_listed VALUE 'X'.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

  DATA: BEGIN OF t_vrkme OCCURS 10,
          vrkme LIKE wlk1-vrkme.
  DATA: END OF t_vrkme.

  DATA: BEGIN OF t_wrf6 OCCURS 2.
      INCLUDE STRUCTURE wrf6.
  DATA: END OF t_wrf6.

  DATA: BEGIN OF t_nart OCCURS 500.
      INCLUDE STRUCTURE gt_nart_buf.
  DATA: END OF t_nart.

  DATA: lt_articles TYPE pre03_tab.                   " Note 1982796


* Schreibe alle, für den Download Stücklisten (Sets und
* Nachzugsartikel) benötigten, Tabellenfelder in eine
* interne Tabelle.
  PERFORM stckl_fieldtab_fill TABLES gt_field_tab.

* Prüfe, welche Artikelstammsegmente versendet werden müssen
  LOOP AT pit_filter_segs.

    CASE pit_filter_segs-segtyp.
      WHEN c_e1wpn01_name.
        CLEAR: e1wpn01.
      WHEN c_e1wpn02_name.
        CLEAR: e1wpn02.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

* Es müssen Artikelstammdaten versendet werden.
  IF e1wpn01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: g_segment_counter, g_new_position, g_status_pos.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
    PERFORM time_range_get USING pi_datum_ab          pi_datum_bis
                                 pi_filia_const-vzeit
                                 pi_filia_const-fabkl
                                 g_datab              g_datbis
                                 g_erstdat.

*   Erzeuge Tabelle mit Arbeitstagen, falls nötig.
    PERFORM workdays_get TABLES gt_workdays
                         USING  g_datab  g_datbis
                                pi_filia_const-fabkl.

*   Falls direkte Anforderung oder Restart-Modus, prüfe, ob
*   Artikeltabelle Nachzugsartikel enhält.
    IF pi_nart <> space.
      CLEAR: nart_lines.
      READ TABLE pit_artikel WITH KEY
           arttyp = c_narttyp
           BINARY SEARCH.

      IF sy-subrc = 0.
        nart_lines = 1.
      ENDIF.                           " SY-SUBRC = 0.
    ENDIF.                             " PI_NART <> SPACE.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = g_dldnr.
    gi_status_pos-doctyp = c_idoctype_nart.

*   Fall Restart-Modus.
    IF pi_mode = c_restart_mode.
      gi_status_pos-rspos  = 'X'.
    ENDIF. " pi_mode = c_restart_mode.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Rücksetzen Fehler-Zähler.
    CLEAR: g_err_counter, g_firstkey.

*   Initialisierungsfall oder direkte Anforderung oder Restart-Modus
*   (alle Nachzugsartikel übertragen).
    IF pi_mode = c_init_mode OR ( pi_nart <> space AND nart_lines = 0 ).
*     Besorge alle Nachzugsartikel aus Tabelle MARA.
      PERFORM nart_select
              TABLES t_nart.
* B: New listing check logic => Note 1982796
      IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
         AND gs_twpa-marc_chk IS NOT INITIAL.
        LOOP AT t_nart
           WHERE matkl <> space.
          APPEND t_nart-matnr TO lt_articles.
        ENDLOOP.
        CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
          EXPORTING
            ip_access_type   = '2'
            ip_prefetch_data = 'X'
            ip_vkorg         = pi_vkorg
            ip_vtweg         = pi_vtweg
            ip_filia         = pi_filia
            ip_date_from     = g_datab
            ip_date_to       = g_datbis
            is_filia_const   = gi_filia_const
          TABLES
            pit_matnr        = lt_articles
            pet_wlk2         = gt_wlk2.
      ENDIF. " E: New listing check logic => Note 1982796
      LOOP AT t_nart
           WHERE matkl <> space.
*       Prüfe, ob die Warengruppe dieser Filiale zugeordnet ist.
        CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
          EXPORTING
            pi_filiale     = pi_filia_const-kunnr
            pi_warengruppe = t_nart-matkl
          TABLES
            pe_t_wrf6      = t_wrf6
          EXCEPTIONS
            no_wrf6_record = 01
            no_wrgp_found  = 02.

        READ TABLE t_wrf6 INDEX 1.

*       Falls die Warengruppe dieser Filiale zugeordnet ist aber
*       von der Versendung ausgeschlossen werden soll, dann
*       weiter zur nächsten Artikelnummer.
        IF sy-subrc = 0 AND t_wrf6-wdaus <> space.
          CONTINUE.
        ENDIF. " sy-subrc = 0 and t_wrf6-wdaus <> space.

* B: New listing check logic => Note 1982796
        IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
           AND gs_twpa-marc_chk IS NOT INITIAL.
          PERFORM pos_listing_get TABLES gt_wlk2
                                          gt_listung
                                  USING   pi_vkorg
                                          pi_vtweg
                                          pi_filia
                                          t_nart-matnr.
        ELSE.
*       Besorge alle Listungen des Artikels bzgl. dieser Filiale
*       für alle Verkaufsmengeneinheiten.
          CALL FUNCTION 'LISTING_CHECK'
            EXPORTING
              pi_article      = t_nart-matnr
              pi_datab        = g_datab
              pi_datbi        = g_datbis
              pi_filia        = pi_filia
              pi_vkorg        = pi_vkorg
              pi_vtweg        = pi_vtweg
              pi_mode         = c_pos_mode
              pi_ignore_excl  = 'X'
            TABLES
              pet_bew_kond    = gt_listung
            EXCEPTIONS
              kond_not_found  = 01
              vrkme_not_found = 02
              vkdat_not_found = 03.
        ENDIF. " Note 1982796
*       Besorge alle gelisteten Verkaufsmengeneinheiten zum Artikel.
        REFRESH: t_vrkme.
        CLEAR: vrkme.
        LOOP AT gt_listung.
          IF gt_listung-vrkme <> vrkme.
            vrkme = gt_listung-vrkme.
            APPEND gt_listung-vrkme TO t_vrkme.
          ENDIF.                       " GT_LISTUNG-VRKME <> VRKME
        ENDLOOP.                       " AT GT_LISTUNG.

*       Falls Verkaufsmengeneinheiten zum Artikel gefunden wurden,
*       die im Betrachtungszeitraum gelistet sind.
        IF sy-subrc = 0.
*         Merken, daß wenigstens ein Nachzugsartikel gelistet ist.
          CLEAR: no_article_listed.

*         Schleife über alle Verkaufsmengeneinheiten.
          LOOP AT t_vrkme.
*           Merke 'Firstkey'.
            IF g_new_firstkey <> space.
              i_key-matnr = t_nart-matnr.
              i_key-vrkme = t_vrkme.
              g_firstkey = i_key.
              CLEAR: g_new_firstkey.
            ENDIF.                     " G_NEW_FIRSTKEY <> SPACE.

*           Besorge Artikeldaten und bereite IDOC auf.
            CALL FUNCTION 'MASTERIDOC_CREATE_DLPNART'
              EXPORTING
                pi_debug           = pi_debug
*###                  pi_ermod           = pi_filia_const-ermod
                pi_dldnr           = g_dldnr
                px_dldlfdnr        = g_dldlfdnr
                pi_filia           = pi_filia
                pi_artnr           = t_nart-matnr
                pi_vrkme           = t_vrkme-vrkme
                pi_datum_ab        = g_datab
                pi_datum_bis       = g_datbis
                pi_express         = pi_express
                pi_loeschen        = pi_loeschen
                pi_mode            = pi_mode
                pi_e1wpn02         = e1wpn02
                px_segment_counter = g_segment_counter
                pi_filia_const     = pi_filia_const
              IMPORTING
                px_segment_counter = g_segment_counter
              TABLES
                pit_listung        = gt_listung
                pit_ot3_nart       = gt_ot3_nart
                pit_workdays       = gt_workdays
              CHANGING
                pxt_idoc_data      = gt_idoc_data
              EXCEPTIONS
                download_exit      = 1.

*           Es sind Fehler beim Download aufgetreten'
            IF sy-subrc = 1.
              RAISE download_exit.
            ENDIF.                     " SY-SUBRC = 1.

          ENDLOOP.                     " AT T_VRKME.

        ENDIF.                         " SY-SUBRC = 0.
      ENDLOOP. " at t_nart.

*     Falls Tabelle MARA nicht gelesen werden konnte.
      IF sy-subrc <> 0.
*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          IF g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            CLEAR: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = g_dldnr.
            gi_errormsg_header-extnumber+14  = g_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            PERFORM appl_log_init_with_header
                    USING gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          ENDIF.                       " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          CLEAR: gi_message.
          gi_message-msgty     = c_msgtp_warning.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_weniger_wichtig.
*         'Keine Nachzugsartikel im Materialstamm gepflegt'
          gi_message-msgno = '147'.

*         Schreibe Fehlerzeile.
          CLEAR: g_object_key.
          PERFORM appl_log_write_single_message  USING gi_message.

        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*       Ändern der Status-Kopfzeile, falls nötig.
        IF g_status < 2.                   " 'Benutzerhinweis'
*         Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
          CLEAR: gi_status_header.
          gi_status_header-dldnr = g_dldnr.
          gi_status_header-gesst = c_status_benutzerhinweis.

*         Korrigiere Status-Kopfzeile auf "Fehlerhaft".
          PERFORM status_write_head USING  'X'  gi_status_header
                                                g_dldnr g_returncode.

*         Aktualisiere Aufbereitungsstatus.
          g_status = 2.                  " 'Benutzerhinweis'
        ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        CLEAR: gi_status_pos.
        gi_status_pos-dldnr  = g_dldnr.
        gi_status_pos-lfdnr  = g_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.

*       Aktualisiere Aufbereitungsstatus für Positionszeile,
*       falls nötig.
        IF g_status_pos < 2.                   " 'Benutzerhinweis'
          gi_status_pos-gesst = c_status_benutzerhinweis.

          g_status_pos = 2.                    " 'Benutzerhinweis'
        ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'

*       Schreibe Status-Positionszeile.
        PERFORM status_write_pos USING 'X' gi_status_pos  g_dldlfdnr
                                           g_returncode.

*       Schreibe Fehlermeldungen auf Datenbank.
        PERFORM appl_log_write_to_db.

*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Verlassen der Aufbereitung für Artikelstamm-IDOC's.
          EXIT.
*       Falls Abbruch bei Fehler erwünscht.
        ELSE.                          " PI_FILIA_CONST-ERMOD <> SPACE.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*     Falls kein einziger Nachzugsartikel für diese Filiale gelistet
*     ist oder von der Versendung für diese Filiale ausgeschlossen
*     wurde (über die Zuordnung Filiale <--> Warengruppe),
*     dann Hinweis.
      ELSEIF no_article_listed <> space.
*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          IF g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            CLEAR: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = g_dldnr.
            gi_errormsg_header-extnumber+14  = g_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            PERFORM appl_log_init_with_header
                    USING gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          ENDIF.                       " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          WRITE g_datab  TO g_datum1 DD/MM/YYYY.
          WRITE g_datbis TO g_datum2 DD/MM/YYYY.

          CLEAR: gi_message.
          gi_message-msgty     = c_msgtp_warning.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_weniger_wichtig.
*         'Kein Nachzugsartikel im Intervall & bis & bewirtschaftet
*          oder nicht versendbar'.
          gi_message-msgno     = '124'.
          gi_message-msgv1     = g_datum1.
          gi_message-msgv2     = g_datum2.

*         Schreibe Fehlerzeile.
          CLEAR: g_object_key.
          PERFORM appl_log_write_single_message  USING gi_message.

        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*       Ändern der Status-Kopfzeile, falls nötig.
        IF g_status < 2.                   " 'Benutzerhinweis'
*         Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
          CLEAR: gi_status_header.
          gi_status_header-dldnr = g_dldnr.
          gi_status_header-gesst = c_status_benutzerhinweis.

*         Korrigiere Status-Kopfzeile auf "Fehlerhaft".
          PERFORM status_write_head USING  'X'  gi_status_header
                                                g_dldnr g_returncode.

*         Aktualisiere Aufbereitungsstatus.
          g_status = 2.                  " 'Benutzerhinweis'
        ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        CLEAR: gi_status_pos.
        gi_status_pos-dldnr  = g_dldnr.
        gi_status_pos-lfdnr  = g_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.

*       Aktualisiere Aufbereitungsstatus für Positionszeile,
*       falls nötig.
        IF g_status_pos < 2.                   " 'Benutzerhinweis'
          gi_status_pos-gesst = c_status_benutzerhinweis.

          g_status_pos = 2.                    " 'Benutzerhinweis'
        ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'

*       Schreibe Status-Positionszeile.
        PERFORM status_write_pos USING 'X' gi_status_pos  g_dldlfdnr
                                           g_returncode.

*       Falls Abbruch bei Fehler erwünscht.
        IF pi_filia_const-ermod <> space.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.
      ENDIF.                           " SY-SUBRC <> 0. MARA-Select

*     Erzeuge letztes IDOC, falls nötig .
      IF g_segment_counter > 0.
*       Bestimme 'Lastkey'.
        i_key-matnr = t_nart-matnr.
        i_key-vrkme = t_vrkme-vrkme.

        PERFORM idoc_create USING  gt_idoc_data
                                   g_mestype_nart
                                   c_idoctype_nart
                                   g_segment_counter
                                   g_err_counter
                                   g_firstkey
                                   i_key
                                   g_dldnr
                                   g_dldlfdnr
                                   pi_filia
                                   pi_filia_const.

      ENDIF.                           " G_SEGMENT_COUNTER > 0.

*   Direkte Anforderung mit vorselektierten Nachzugsartikeln
*   oder Restart-Modus.
    ELSEIF pi_nart <> space AND nart_lines > 0.
*     Schleife über alle selektierten Artikel.
* B: New listing check logic => Note 1982796
      IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
         AND gs_twpa-marc_chk IS NOT INITIAL.
        LOOP AT pit_artikel
           WHERE arttyp = c_narttyp.
          APPEND pit_artikel-matnr TO lt_articles.
        ENDLOOP.
        CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
          EXPORTING
            ip_access_type   = '2'
            ip_prefetch_data = 'X'
            ip_vkorg         = pi_vkorg
            ip_vtweg         = pi_vtweg
            ip_filia         = pi_filia
            ip_date_from     = g_datab
            ip_date_to       = g_datbis
            is_filia_const   = gi_filia_const
          TABLES
            pit_matnr        = lt_articles
            pet_wlk2         = gt_wlk2.
      ENDIF. " E: New listing check logic => Note 1982796

      LOOP AT pit_artikel
           WHERE arttyp = c_narttyp.
*       Falls nötig, erzeuge Löschsatz für alte EAN.
        IF pit_artikel-loekz <> space.
*         Merken, daß wenigstens ein Artikel versendet wurde.
          CLEAR: no_article_listed.

*         Merke 'Firstkey'.
          IF g_new_firstkey <> space.
            i_key-matnr = pit_artikel-matnr.
            i_key-vrkme = pit_artikel-vrkme.
            g_firstkey = i_key.
            CLEAR: g_new_firstkey.
          ENDIF.                     " G_NEW_FIRSTKEY <> SPACE.

*         Erzeuge Datensatz zum löschen der alten EAN.
          h_ean = pit_artikel-ean11.
          PERFORM nart_delete USING pit_artikel-matnr
                                    pit_artikel-vrkme
                                    h_ean
                                    g_datab
                                    pi_filia_const-ermod
                                    pi_filia_const-kunnr
                                    gt_idoc_data
                                    g_returncode
                                    g_dldnr    g_dldlfdnr
                                    g_segment_counter.

*         Weiter zum nächsten Artikel.
          CONTINUE.
        ENDIF. " pit_artikel-loekz <> space.

*       Besorge die MARA-Daten des Artikels.
        PERFORM mara_select USING mara pit_artikel-matnr.

*       Warengruppe ist immer Pflicht.
        IF mara-matkl = space.
          CONTINUE.
        ENDIF. " mara-matkl = space.

*       Prüfe, ob die Warengruppe dieser Filiale zugeordnet ist.
        CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
          EXPORTING
            pi_filiale     = pi_filia_const-kunnr
            pi_warengruppe = mara-matkl
          TABLES
            pe_t_wrf6      = t_wrf6
          EXCEPTIONS
            no_wrf6_record = 01
            no_wrgp_found  = 02.

        READ TABLE t_wrf6 INDEX 1.

*       Falls die Warengruppe dieser Filiale zugeordnet ist aber
*       von der Versendung ausgeschlossen werden soll, dann
*       weiter zur nächsten Artikelnummer.
        IF sy-subrc = 0 AND t_wrf6-wdaus <> space.
          CONTINUE.
        ENDIF. " sy-subrc = 0 and t_wrf6-wdaus <> space.

* B: New listing check logic => Note 1982796
        IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
           AND gs_twpa-marc_chk IS NOT INITIAL.
          PERFORM pos_listing_get TABLES   gt_wlk2
                                           gt_listung
                                   USING   pi_vkorg
                                           pi_vtweg
                                           pi_filia
                                           pit_artikel-matnr.

        ELSE.
*       Besorge alle Listungen des Artikels bzgl. dieser Filiale
          CALL FUNCTION 'LISTING_CHECK'
            EXPORTING
              pi_article      = pit_artikel-matnr
              pi_vrkme        = pit_artikel-vrkme
              pi_datab        = g_datab
              pi_datbi        = g_datbis
              pi_filia        = pi_filia
              pi_vkorg        = pi_vkorg
              pi_vtweg        = pi_vtweg
              pi_mode         = c_pos_mode
            TABLES
              pet_bew_kond    = gt_listung
            EXCEPTIONS
              kond_not_found  = 01
              vrkme_not_found = 02
              vkdat_not_found = 03.
        ENDIF.
*       Besorge alle gelisteten Verkaufsmengeneinheiten zum Artikel.
        REFRESH: t_vrkme.
        CLEAR: vrkme.
        LOOP AT gt_listung.
          IF gt_listung-vrkme <> vrkme.
            vrkme = gt_listung-vrkme.
            APPEND gt_listung-vrkme TO t_vrkme.
          ENDIF.                       " GT_LISTUNG-VRKME <> VRKME
        ENDLOOP.                       " AT GT_LISTUNG.

*       Falls Verkaufsmengeneinheiten zum Artikel gefunden wurden,
*       die im Betrachtungszeitraum gelistet sind.
        IF sy-subrc = 0.
*         Merken, daß wenigstens ein Artikel gelistet ist.
          CLEAR: no_article_listed.

*         Schleife über alle Verkaufsmengeneinheiten.
          LOOP AT t_vrkme.
*           Merke 'Firstkey'.
            IF g_new_firstkey <> space.
              i_key-matnr = pit_artikel-matnr.
              i_key-vrkme = t_vrkme.
              g_firstkey  = i_key.
              CLEAR: g_new_firstkey.
            ENDIF.                     " G_NEW_FIRSTKEY <> SPACE.

*           Besorge Artikeldaten und bereite IDOC auf.
            CALL FUNCTION 'MASTERIDOC_CREATE_DLPNART'
              EXPORTING
                pi_debug           = pi_debug
*###                  pi_ermod           = pi_filia_const-ermod
                pi_dldnr           = g_dldnr
                px_dldlfdnr        = g_dldlfdnr
                pi_filia           = pi_filia
                pi_artnr           = pit_artikel-matnr
                pi_vrkme           = t_vrkme-vrkme
                pi_datum_ab        = g_datab
                pi_datum_bis       = g_datbis
                pi_express         = pi_express
                pi_loeschen        = pi_loeschen
                pi_mode            = pi_mode
                pi_e1wpn02         = e1wpn02
                px_segment_counter = g_segment_counter
                pi_filia_const     = pi_filia_const
              IMPORTING
                px_segment_counter = g_segment_counter
              TABLES
                pit_listung        = gt_listung
                pit_ot3_nart       = gt_ot3_nart
                pit_workdays       = gt_workdays
              CHANGING
                pxt_idoc_data      = gt_idoc_data
              EXCEPTIONS
                download_exit      = 1.

*           Es sind Fehler beim Download aufgetreten'
            IF sy-subrc = 1.
              RAISE download_exit.
            ENDIF.                     " SY-SUBRC = 1.

          ENDLOOP.                     " AT T_VRKME.

*       Falls der Artikel nicht in diesem Intervall gelistet ist.
        ELSE.                          " sy-subrc <> 0.
*         Prüfe, ob der Artikel bei direkter Anforderung mit
*         SELECT-OPTION = 'EQUAL' eingegeben wurde.
          READ TABLE pit_art_equal WITH KEY
               arttyp = c_narttyp
               matnr  = pit_artikel-matnr
               BINARY SEARCH.

*         Der Artikel wurde mit SELECT-OPTION 'EQUAL' eingegeben, d.h.
*         Fehlermeldung ist erforderlich.
          IF sy-subrc = 0 OR pi_mode = c_restart_mode.
*           Falls Fehlerprotokollierung erwünscht.
            IF pi_filia_const-ermod = space.
*             Falls noch keine Initialisierung des Fehlerprotokolls.
              IF g_init_log = space.
*               Aufbereitung der Parameter zum schreiben des Headers des
*               Fehlerprotokolls.
                CLEAR: gi_errormsg_header.
                gi_errormsg_header-object        = c_applikation.
                gi_errormsg_header-subobject     = c_subobject.
                gi_errormsg_header-extnumber     = g_dldnr.
                gi_errormsg_header-extnumber+14  = g_dldlfdnr.
                gi_errormsg_header-aluser        = sy-uname.

*               Initialisiere Fehlerprotokoll und erzeuge Header.
                PERFORM appl_log_init_with_header
                        USING gi_errormsg_header.

*               Merke, daß Fehlerprotokoll initialisiert wurde.
                g_init_log = 'X'.
              ENDIF.                   " G_INIT_LOG = SPACE.

*             Bereite Parameter zum schreiben der Fehlerzeile auf.
              WRITE g_datab  TO g_datum1 DD/MM/YYYY.
              WRITE g_datbis TO g_datum2 DD/MM/YYYY.

              CLEAR: gi_message.
              gi_message-msgty     = c_msgtp_error.
              gi_message-msgid     = c_message_id.
              gi_message-probclass = c_probclass_sehr_wichtig.
*             'Das Material & wird nicht im Intervall & bis &'.
*              bewirtschaftet'
              gi_message-msgno     = '116'.
              gi_message-msgv1     = pit_artikel-matnr.
              gi_message-msgv2     = g_datum1.
              gi_message-msgv3     = g_datum2.

*             Schreibe Fehlerzeile für Application-Log und WDLSO.
              g_object_key = pit_artikel-matnr.
              PERFORM appl_log_write_single_message  USING gi_message.

            ENDIF.                     " PI_FILIA_CONST-ERMOD = SPACE.

*           Ändern der Status-Kopfzeile, falls nötig.
            IF g_status < 3.                   " 'Fehlende Daten'
*             Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
              CLEAR: gi_status_header.
              gi_status_header-dldnr = g_dldnr.
              gi_status_header-gesst = c_status_fehlende_daten.

*             Korrigiere Status-Kopfzeile auf "Fehlerhaft".
              PERFORM status_write_head
                      USING  'X'  gi_status_header  g_dldnr
                                  g_returncode.

*             Atualisiere Aufbereitungsstatus.
              g_status = 3.              " 'Fehlende Daten
            ENDIF. " g_status < 3.                   " 'Fehlende Daten'

*           Aufbereiten der Parameter zum Ändern der
*           Status-Positionszeile.
            CLEAR: gi_status_pos.
            gi_status_pos-dldnr  = g_dldnr.
            gi_status_pos-lfdnr  = g_dldlfdnr.
            gi_status_pos-anloz  = g_err_counter.

*           Aktualisiere Aufbereitungsstatus für Positionszeile,
*           falls nötig.
            IF g_status_pos < 3.                   " 'Fehlende Daten'
              gi_status_pos-gesst = c_status_fehlende_daten.

              g_status_pos = 3.                    " 'Fehlende Daten'
            ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*           Schreibe Status-Positionszeile.
            PERFORM status_write_pos USING   'X' gi_status_pos
                                             g_dldlfdnr
                                             g_returncode.

*           Falls Abbruch bei Fehler erwünscht.
            IF pi_filia_const-ermod <> space.
*             Abbruch des Downloads.
              RAISE download_exit.
            ENDIF.                     " PI_FILIA_CONST-ERMOD = SPACE.

          ENDIF.                       " SY-SUBRC <> 0.
        ENDIF.                         " SY-SUBRC = 0.
      ENDLOOP.                         " AT PIT_ARTIKEL.

*     Falls kein einziger Artikel für diese Filiale gelistet
*     ist oder von der Versendung für diese Filiale ausgeschlossen
*     wurde (über die Zuordnung Filiale <--> Warengruppe),
*     dann Fehlermeldung.
      IF no_article_listed <> space  AND pi_mode <> c_restart_mode.
*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          IF g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            CLEAR: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = g_dldnr.
            gi_errormsg_header-extnumber+14  = g_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            PERFORM appl_log_init_with_header
                    USING gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          ENDIF.                       " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          WRITE g_datab  TO g_datum1 DD/MM/YYYY.
          WRITE g_datbis TO g_datum2 DD/MM/YYYY.

          CLEAR: gi_message.
          gi_message-msgty     = c_msgtp_error.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_sehr_wichtig.
*         'Kein Nachzugsartikel im Intervall & bis & bewirtschaftet
*          oder nicht versendbar'.
          gi_message-msgno     = '124'.
          gi_message-msgv1     = g_datum1.
          gi_message-msgv2     = g_datum2.

*         Schreibe Fehlerzeile für Application-Log und WDLSO.
          g_object_key = c_whole_idoc.
          PERFORM appl_log_write_single_message  USING gi_message.

        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*       Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
        CLEAR: gi_status_header.
        gi_status_header-dldnr = g_dldnr.
        gi_status_header-gesst = c_status_fehlende_idocs.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM status_write_head USING  'X'      gi_status_header
                                         g_dldnr  g_returncode.

*       Aktualisiere Aufbereitungsstatus.
        g_status = 4.                  " 'Fehlende IDOC's'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        CLEAR: gi_status_pos.
        gi_status_pos-dldnr  = g_dldnr.
        gi_status_pos-lfdnr  = g_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.
        gi_status_pos-gesst  = c_status_fehlende_idocs.

*       Aktualisiere Aufbereitungsstatus für Positionen.
        g_status_pos = 4.              " 'Fehlende IDOC's'

*       Schreibe Status-Positionszeile.
        PERFORM status_write_pos USING 'X' gi_status_pos  g_dldlfdnr
                                           g_returncode.

*       Falls Abbruch bei Fehler erwünscht.
        IF pi_filia_const-ermod <> space.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.
      ENDIF.                           " no_article_listed <> space.

*     Erzeuge letztes IDOC, falls nötig .
      IF g_segment_counter > 0.
*       Bestimme 'Lastkey'.
        i_key-matnr = pit_artikel-matnr.
        i_key-vrkme = t_vrkme-vrkme.

        PERFORM idoc_create USING  gt_idoc_data
                                   g_mestype_nart
                                   c_idoctype_nart
                                   g_segment_counter
                                   g_err_counter
                                   g_firstkey
                                   i_key
                                   g_dldnr
                                   g_dldlfdnr
                                   pi_filia
                                   pi_filia_const.

      ENDIF.                           " G_SEGMENT_COUNTER > 0.
    ENDIF. " PI_MODE = C_INIT_MODE OR ( PI_NART <> SPACE ...

*   Schreibe Fehlermeldungen auf Datenbank, falls nötig.
    IF g_init_log <> space.
      PERFORM appl_log_write_to_db.
    ENDIF.                             " G_INIT_LOG <> SPACE.

*   Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*   auf OK.
    IF g_status = 0.
*     Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
      CLEAR: gi_status_header.
      gi_status_header-dldnr = g_dldnr.
      gi_status_header-gesst = c_status_ok.

*     Schreibe Status-Kopfzeile.
      PERFORM status_write_head USING  'X'      gi_status_header
                                       g_dldnr  g_returncode.
    ENDIF.                             " G_STATUS = 0.
  ENDIF.                               " E1WPN01 <> SPACE.


ENDFORM.                               " NART_DOWNLOAD


*eject.
************************************************************************
FORM nart_download_change_mode
     TABLES pit_artdel             STRUCTURE gt_artdel
            pit_filter_segs        STRUCTURE gt_filter_segs
            pit_ot3_nart           STRUCTURE gt_ot3_nart
            pit_workdays           STRUCTURE gt_workdays
     USING  pi_filia_group         STRUCTURE gt_filia_group
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_dldnr               LIKE wdls-dldnr
            pi_mestype             LIKE edimsg-mestyp.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Nachzugsartikel.                            *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_FILTER_SEGS       : Liste aller für den POS-Download nicht
*                         benötigten Segmente.
* PIT_OT3_NART          : Nachzugsartikel: Objekttabelle 3.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_DLDNR              : Downloadnummer für Statusverfolgung.

* PI_MESTYPE            : Zu verwendender Nachrichtentyp für
*                         Objekt Nachzugsartikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: e1wpn01       VALUE 'X', " Flag, ob Segm. E1WPN01 vers. werden muß
        e1wpn02       VALUE 'X',
        nart_lines    TYPE i,
        number        TYPE i,
        nr_of_groups  TYPE i,
        h_tabix       LIKE sy-tabix,
        h_fist_record.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Feldleiste für Filialkonstanten.
  DATA: BEGIN OF i_filia_const.
      INCLUDE STRUCTURE wpfilconst.
  DATA: END OF i_filia_const.

  DATA: BEGIN OF t_vrkme OCCURS 10,
          vrkme LIKE wlk1-vrkme.
  DATA: END OF t_vrkme.

  DATA: BEGIN OF t_ot3_nart_temp OCCURS 15.
      INCLUDE STRUCTURE gt_ot3_nart.
  DATA: END OF t_ot3_nart_temp.

  DATA: BEGIN OF t_wrf6 OCCURS 2.
      INCLUDE STRUCTURE wrf6.
  DATA: END OF t_wrf6.

* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  g_current_doctype = c_idoctype_nart.

* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING pi_filia_group TO i_filia_const.


* Schreibe alle, für den Download Stücklisten (Sets und
* Nachzugsartikel) benötigten, Tabellenfelder in eine
* interne Tabelle.
  PERFORM stckl_fieldtab_fill TABLES gt_field_tab.

* Prüfe, welche Artikelstammsegmente versendet werden müssen.
  LOOP AT pit_filter_segs.

    CASE pit_filter_segs-segtyp.
      WHEN c_e1wpn01_name.
        CLEAR: e1wpn01.
      WHEN c_e1wpn02_name.
        CLEAR: e1wpn02.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

* Es müssen Nachzugsartikel versendet werden.
  IF e1wpn01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: g_segment_counter, g_new_position, g_status_pos.

*   Rücksetzen Fehler-Zähler.
    CLEAR: g_err_counter, g_firstkey.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-doctyp = c_idoctype_nart.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Bestimme die Anzahl der zu versendenden Nachzugsartikel.
    DESCRIBE TABLE pit_ot3_nart LINES nart_lines.
    READ TABLE pit_ot3_nart INDEX nart_lines.
    nr_of_groups = pit_ot3_nart-number.

*   Schleife über alle Objekte dieser Filialgruppe.
    CLEAR: number, g_returncode.
    WHILE number < nr_of_groups.
      ADD 1 TO number.

*     Besorge die zur Variablen NUMBER gehörende Artikelnummer.
      READ TABLE pit_ot3_nart WITH KEY
           number = number
           BINARY SEARCH.

*     Merken der Tabellenzeile.
      h_tabix = sy-tabix.

*     Besorge die MARA-Daten des Nachzugsartikels.
      PERFORM mara_select USING mara pit_ot3_nart-artnr.

*     Warengruppe ist immer Pflicht.
      IF mara-matkl = space.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-nart_ign.

*       Weiter zum nächsten Satz.
        CONTINUE.
      ENDIF. " mara-matkl = space.

*     Extrahiere die Daten zu einem Nachzugsartikel in temporäre Tabelle
*     und bestimme Grenzwerte für spätere Selektion der Daten.
      REFRESH: t_ot3_nart_temp.
      CLEAR: g_datmin, g_datmax.
      h_fist_record = 'X'.
      LOOP AT pit_ot3_nart  FROM h_tabix.

*       Abbruchbedingungbedingung für Schleife setzen.
        IF pit_ot3_nart-number <> number.
          EXIT.
        ENDIF. " pit_ot3_nart-number <> number.

        IF h_fist_record <> space.
          CLEAR: h_fist_record.
*         Merke Firstkey, falls nötig.
          IF g_new_firstkey <> space.
            i_key-matnr = pit_ot3_nart-artnr.
            i_key-vrkme = pit_ot3_nart-vrkme.
            g_firstkey = i_key.
            CLEAR: g_new_firstkey.
          ENDIF.                       " G_NEW_FIRSTKEY <> SPACE.

          g_datmin   = pit_ot3_nart-datum.
          g_datmax   = pit_ot3_nart-datum.
*         Falls Initialisiert werden soll, müssen die Daten bis zum
*         Ende der Vorlaufzeit selektiert werden.
          IF pit_ot3_nart-init <> space.
            g_datmax = pi_datp4.
          ENDIF.                       " PIT_OT3_NART-INIT <> SPACE.
        ELSE.                          " SY-INDEX > 1.
          IF pit_ot3_nart-datum < g_datmin.
            g_datmin = pit_ot3_nart-datum.
          ELSEIF pit_ot3_nart-datum > g_datmax.
            g_datmax = pit_ot3_nart-datum.
          ENDIF.                       " PIT_OT3_NART-DATUM < G_DATMIN.
        ENDIF.                         " H_FIST_RECORD <> SPACE.

*       Falls nötig, erzeuge Löschsatz.
        IF pit_ot3_nart-upd_flag = c_del.
*         Besorge alte EAN aus Zusatztabelle PIT_ARTDEL.
          READ TABLE pit_artdel WITH KEY
               artnr = pit_ot3_nart-artnr
               vrkme = pit_ot3_nart-vrkme
               datum = pit_ot3_nart-datum
               BINARY SEARCH.

*         Falls eine EAN existiert.
          IF sy-subrc = 0.
*           Erzeuge Datensatz zum löschen der alten EAN.
            PERFORM nart_delete USING pit_ot3_nart-artnr
                                      pit_ot3_nart-vrkme
                                      pit_artdel-ean
                                      pit_ot3_nart-datum
                                      pi_filia_group-ermod
                                      pi_filia_group-kunnr
                                      gt_idoc_data
                                      g_returncode
                                      pi_dldnr    g_dldlfdnr
                                      g_segment_counter.
          ENDIF. " sy-subrc = 0.

        ELSE.                          " PIT_OT3_NART-UPD_FLAG <> C_DEL.
*         Übernehme Datensatz in Temporärtabelle.
          APPEND pit_ot3_nart TO t_ot3_nart_temp.
        ENDIF.                         " PIT_OT3_NART-UPD_FLAG = C_DEL.
      ENDLOOP.                         " AT PIT_OT3_NART.

*     Prüfe, ob Einträge in PIT_OT3_SETS_TEMP vorhanden sind.
      READ TABLE t_ot3_nart_temp INDEX 1.

*     Falls keine Einträge in PIT_OT3_NART_TEMP vorhanden sind,
*     dann starte mit der nächsten Gruppe.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.                           " SY-SUBRC <> 0.

*     Prüfe, ob die Warengruppe dieser Filiale zugeordnet ist.
      CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
        EXPORTING
          pi_filiale     = pi_filia_group-kunnr
          pi_warengruppe = mara-matkl
        TABLES
          pe_t_wrf6      = t_wrf6
        EXCEPTIONS
          no_wrf6_record = 01
          no_wrgp_found  = 02.

      READ TABLE t_wrf6 INDEX 1.

*     Falls die Warengruppe dieser Filiale zugeordnet ist aber
*     von der Versendung ausgeschlossen werden soll, dann
*     weiter zur nächsten Artikelnummer.
      IF sy-subrc = 0 AND t_wrf6-wdaus <> space.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-nart_ign.

*       Weiter zum nächsten Satz.
        CONTINUE.
      ENDIF. " sy-subrc = 0 and t_wrf6-wdaus <> space.

*     Besorge die Listungen dieser VRKME des Artikels
*     bzgl. dieser Filiale
      PERFORM pos_listing_check
                  TABLES gt_wlk2
                         gt_listung
                  USING  pi_filia_group
                         t_ot3_nart_temp-artnr
                         t_ot3_nart_temp-vrkme
                         g_datmin
                         pi_datp4.

*     Besorge die Listungen dieser VRKME des Artikels
*     bzgl. dieser Filiale
*     call function 'LISTING_CHECK'
*          exporting
*               pi_article      = t_ot3_nart_temp-artnr
*               pi_vrkme        = t_ot3_nart_temp-vrkme
*               pi_datab        = g_datmin
*               pi_datbi        = pi_datp4
*               pi_filia        = pi_filia_group-filia
*               pi_vkorg        = pi_filia_group-vkorg
*               pi_vtweg        = pi_filia_group-vtweg
*          tables
*               pet_bew_kond   = gt_listung
*          exceptions
*               kond_not_found  = 01
*               vrkme_not_found = 02
*               vkdat_not_found = 03.

      READ TABLE gt_listung INDEX 1.

      IF sy-subrc = 0.
*       Besorge Artikeldaten und bereite IDOC auf.
        CALL FUNCTION 'MASTERIDOC_CREATE_DLPNART'
          EXPORTING
            pi_debug           = ' '
*###              pi_ermod           = pi_filia_group-ermod
            pi_dldnr           = pi_dldnr
            px_dldlfdnr        = g_dldlfdnr
            pi_filia           = pi_filia_group-filia
            pi_artnr           = t_ot3_nart_temp-artnr
            pi_vrkme           = t_ot3_nart_temp-vrkme
            pi_datbi_list      = pi_datp4
            pi_datum_ab        = g_datmin
            pi_datum_bis       = g_datmax
            pi_express         = ' '
            pi_loeschen        = ' '
            pi_mode            = pi_mode
            pi_e1wpn02         = e1wpn02
            px_segment_counter = g_segment_counter
            pi_filia_const     = i_filia_const
          IMPORTING
            px_segment_counter = g_segment_counter
          TABLES
            pit_listung        = gt_listung
            pit_ot3_nart       = t_ot3_nart_temp
            pit_workdays       = pit_workdays
          CHANGING
            pxt_idoc_data      = gt_idoc_data
          EXCEPTIONS
            download_exit      = 1.

*       Es sind Fehler beim Download aufgetreten'
        IF sy-subrc <> 0.
*         Abbruch des Downloads.
          RAISE error_code_1.
        ENDIF.                         " SY-SUBRC = 1.
*     Falls der Artikel nich in dieser Filiale bewirtschaftet wird.
      ELSE.                            " SY-SUBRC <> 0.

*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-nart_ign.
      ENDIF.                           " SY-SUBRC = 0.
    ENDWHILE.                          " NUMBER < NR_OF_GROUPS.

*   Erzeuge letztes IDOC, falls nötig .
    IF g_segment_counter > 0.
*     Bestimme 'Lastkey'.
      i_key-matnr = t_ot3_nart_temp-artnr.
      i_key-vrkme = t_ot3_nart_temp-vrkme.

      PERFORM idoc_create USING  gt_idoc_data
                                 pi_mestype
                                 c_idoctype_nart
                                 g_segment_counter
                                 g_err_counter
                                 g_firstkey
                                 i_key
                                 pi_dldnr     g_dldlfdnr
                                 pi_filia_group-filia
                                 i_filia_const.

    ENDIF.                             " G_SEGMENT_COUNTER > 0.

*   Schreibe Fehlermeldungen auf Datenbank, falls nötig.
    IF g_init_log <> space.
      PERFORM appl_log_write_to_db.
    ENDIF.                             " G_INIT_LOG <> SPACE.

*   Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*   auf OK.
    IF g_status = 0.
*     Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
      CLEAR: gi_status_header.
      gi_status_header-dldnr = pi_dldnr.
      gi_status_header-gesst = c_status_ok.

*     Schreibe Status-Kopfzeile.
      PERFORM status_write_head USING  'X'  gi_status_header  pi_dldnr
                                            g_returncode.
    ENDIF.                             " G_STATUS = 0.
  ENDIF.                               " E1WPN01 <> SPACE.


ENDFORM.                               " NART_DOWNLOAD_CHANGE_MODE


* eject.
************************************************************************
FORM nart_delete
     USING  pi_artnr       LIKE      gt_ot3_nart-artnr
            pi_vrkme       LIKE      gt_ot3_nart-vrkme
            pi_ean         LIKE      wpdel-ean
            pi_datum       LIKE      gt_ot3_nart-datum
            pi_ermod       LIKE      gt_filia_group-ermod
            pi_kunnr       LIKE      gt_filia_group-kunnr
   CHANGING pxt_idoc_data  TYPE short_edidd
            VALUE(pe_fehlercode) LIKE syst-subrc
            pi_dldnr       LIKE wdls-dldnr
            pi_dldlfdnr    LIKE wdlsp-lfdnr
            px_segcnt      LIKE g_segment_counter.
************************************************************************
* FUNKTION:
* Erzeuge Löschsatz für Artikel mit veralteter EAN.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_ARTNR      : Artikenummer.

* PI_VRKME      : Verkaufsmengeneinheit.

* PI_EAN        : EAN.

* PI_DATUM      : Versendedatum

* PI_ERMOD      : = SPACE, wenn Fehlerprotokollierung erwünscht, sonst
*                 'X'.
* PI_KUNNR      : Kundennummer der Filiale.

* PXT_IDOC_DATA : Tabelle der IDOC-Daten.

* PE_FEHLERCODE : = '1', wenn Datenumsetzung mißlungen, sonst '0'.

* PI_DLDNR      : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR   : Laufende Nr. der Positionszeile für Statusverfolgung.

* PX_SEGCNT     : Segmentzähler.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: seg_local_cnt TYPE i,
        e1wpn02_cnt   TYPE i VALUE 0,
        h_numtp       LIKE  marm-numtp.

  DATA: t_matnr LIKE gt_matnr    OCCURS 0 WITH HEADER LINE,
        t_marm  LIKE gt_marm_buf OCCURS 0 WITH HEADER LINE.


* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: gt_idoc_data_temp.

* Rücksetze Fehlercode.
  CLEAR: pe_fehlercode.

* Aufbereitung ID-Segment.
  CLEAR: e1wpn01.
  e1wpn01-filiale    = pi_kunnr.
  e1wpn01-aktivdatum = pi_datum.
  e1wpn01-aenderer   = ' '.
  e1wpn01-aenddatum  = '00000000'.

*  e1wpn01-artikelnr_long  = pi_artnr.
  cl_matnr_chk_mapper=>convert_on_output(
     EXPORTING
       iv_matnr40                   =     pi_artnr
     IMPORTING
       ev_matnr18                   =     e1wpn01-artikelnr
       ev_matnr40                   =     e1wpn01-artikelnr_long
     EXCEPTIONS
       excp_matnr_invalid_input     = 1
       excp_matnr_not_found         = 2
       OTHERS                       = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* E1WPN01-POSME      = pi_vrkme.    " ### vielleicht später aktivieren
  e1wpn01-aendkennz  = c_delete.

* Besorge EAN-Typ.
* Prüfe zunächst, ob es sich um eine alte EAN handelt.
  LOOP AT gt_old_ean_nart
       WHERE artnr = pi_artnr
       AND   vrkme = pi_vrkme
       AND   ean11 = pi_ean.
    EXIT.
  ENDLOOP. " at gt_old_ean_nart

* Falls es sich um eine alte EAN handelt und sich der EAN-Typ
* geändert hat.
  IF sy-subrc = 0 AND NOT gt_old_ean_nart-numtp IS INITIAL.
    h_numtp = gt_old_ean_nart-numtp.

* Falls es sich nicht um eine alte EAN handelt oder der EAN-Typ
* unverändert geblieben ist.
  ELSE. " sy-subrc <> 0 ...
*   Besorge EAN-Typ.
    PERFORM marm_select
            TABLES t_matnr
                   t_marm
            USING  'X'             " pi_with_ean
                   pi_artnr        " pi_matnr
                   pi_vrkme.       " pi_meinh

    READ TABLE t_marm INDEX 1.

    h_numtp = t_marm-numtp.
  ENDIF. " sy-subrc = 0.

* Ausgabekonvertierung für EAN.
  CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
    EXPORTING
      input   = pi_ean
      ean_typ = h_numtp
    IMPORTING
      output  = e1wpn01-eanverbr.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpn01_name.
  gt_idoc_data_temp-sdata  = e1wpn01.
  APPEND gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  ADD 1 TO seg_local_cnt.

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '005'
    EXPORTING
      pi_e1wpn02_cnt     = e1wpn02_cnt
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
      pi_vrkme           = pi_vrkme
    IMPORTING
      px_init_log        = g_init_log
      px_status          = g_status
      px_status_pos      = g_status_pos
      pe_fehlercode      = pe_fehlercode
      px_err_counter     = g_err_counter
      pi_seg_local_cnt   = seg_local_cnt
    TABLES
      pxt_idoc_data_temp = gt_idoc_data_temp
      pit_idoc_data      = gt_idoc_data_dummy
    CHANGING
      pit_idoc_data_new  = pxt_idoc_data.

* Falls Umsetzfehler auftraten.
  IF pe_fehlercode <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    IF pi_ermod = space.
*     Falls der Satz zum heutigen Datum gelöscht werden soll.
      IF pi_datum <= sy-datum.
*       Fülle allgemeinen Objektschlüssel.
        CLEAR: gi_object_key.
        gi_object_key-matnr = pi_artnr.
        gi_object_key-vrkme = pi_vrkme.
        gi_object_key-ean11 = pi_ean.
        g_object_key        = gi_object_key.
        g_object_delete     = 'X'.

*       Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
        PERFORM error_object_write.

*       Rücksetze Löschkennzeichen für Fehlerobjekttabelle WDLSO.
        CLEAR: g_object_delete.
      ENDIF. " pi_datum <= sy-datum.

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " pi_ermod <> SPACE.
*     Abbruch des Downloads.
      RAISE error_code_1.
    ENDIF.                             " pi_ermod = SPACE.

* Falls Umschlüsselung fehlerfrei.
  ELSE.                                " PE_FEHLERCODE = 0.
*   Übernehme die IDOC-Daten aus Temporärtabelle.
    PERFORM idoc_data_assume TABLES  gt_idoc_data_temp
                             USING   pxt_idoc_data
                                     px_segcnt
                                     seg_local_cnt.

  ENDIF.                               " PE_FEHLERCODE <> 0.
*********************************************************************


ENDFORM.                               " NART_DELETE


*eject
************************************************************************
FORM nartdata_get_and_analyse
     TABLES pet_imarm         STRUCTURE gt_imarm
            pit_field_tab     STRUCTURE gt_field_tab
            pxt_orgtab        STRUCTURE gt_orgtab_nart
            pit_listung       STRUCTURE gt_listung
            pit_ot3           STRUCTURE gt_ot3_nart
            pet_nart_komp     STRUCTURE gt_nart_komp
            pet_nart_komp_ean STRUCTURE gt_nart_komp_ean
     USING  pi_artnr          LIKE wlk1-artnr
            pi_vrkme          LIKE wlk1-vrkme
            pi_datab          LIKE syst-datum
            pi_datbi          LIKE syst-datum
            pi_mode           LIKE wpstruc-modus
   CHANGING VALUE(pe_fehlercode) LIKE syst-subrc
            pi_dldnr          LIKE wdls-dldnr
            pi_dldlfdnr       LIKE wdlsp-lfdnr
            pi_ermod          LIKE twpfi-ermod
            pi_segment_counter LIKE g_segment_counter
            pi_initdat        LIKE syst-datum
            pe_ean            LIKE marm-ean11
            pi_loeschen      LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Lese die Daten für Download Nachzugsartikel im Zeitintervall
* PI_DATAB - PI_DATBI, analysiere diese und fülle Organisationstabelle.
* Im Änderungs- oder Restart-Fall werden auch die Tabellen
* PIT_LISTUNG und PIT_OT3 analysiert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_IMARM        : Tabelle für MARM-Daten.

* PIT_FIELD_TAB    : POS-relevante Felder der Materialstammtabellen.

* PXT_ORGTAB       : Organisationstabelle für Set-Zuordnungen.

* PIT_LISTUNG      : Listungen des Nachzugsartikels.

* PIT_OT3          : Nachzugsartikel: Objekttabelle 3.

* PET_NART_KOMP    : Tabelle für Nachzugsartikel-Komponenten

* PET_NART_KOMP_EAN: Tabelle für Haupt-EAN's der
*                    Nachzugsartikel-Komponenten.
* PI_ARTNR         : Material der Selektion.

* PI_VRKME         : Verkaufsmengeneinheit der Selektion.

* PI_DATAB         : Beginndatum der Selektion.

* PI_DATBI         : Endedatum der Selektion.

* PI_MODE          : Download-Modus.

* PE_FEHLERCODE    : > 0, wenn Datenbeschaffung mißlungen, sonst '0'.

* PI_DLDNR         : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR      : Laufende Nr. der Positionszeile für
*                    Statusverfolgung.
* PI_ERMOD         : = 'X', wenn Downloadabbruch bei Fehler erwünscht.

* PI_SEGMENT_COUNTER: Segmentzähler.

* PI_INITDAT      : Datum, ab wann initialisiert werden soll. Ist nur
*                   für Änderungs- und Restart-Fall relevant.
* PE_EAN          : Haupt-EAN der jeweiligen Verkaufsmengeneinheit des
*                   Artikels.
* PI_LOESCHEN     : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                          sollen, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: readindex                   TYPE i,
        h_datum                     LIKE sy-datum,
        lv_is_multi_lvl_struc_art   TYPE abap_bool,
        ls_multi_lvl_struc_art      TYPE mepoitem,
        lt_mixed_display_components TYPE cl_struc_art_multi_lvl_generic=>tt_components,
        ls_mixed_display_component  TYPE cl_struc_art_multi_lvl_generic=>ts_component,
        ls_pet_nart_komp            LIKE pet_nart_komp,
        lv_loopcounter              TYPE i,
        lv_lines                    TYPE i,
        no_record_found_marm.


  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

  DATA: BEGIN OF i_key1,
          idnrk LIKE stpob-idnrk,
          meins LIKE stpob-meins.
  DATA: END OF i_key1.

  DATA: BEGIN OF i_key2.
      INCLUDE STRUCTURE i_key1.
  DATA: END OF i_key2.

* Für Haupt-EAN-Auswertung der Positionen.
  DATA: BEGIN OF t_position OCCURS 20,
          matnr LIKE marm-matnr,
          meinh LIKE marm-meinh.
  DATA: END OF t_position.

* Zum zwischenspeichern der Haupt-EAN-Änderungen der Positionen.
  DATA: BEGIN OF t_marm OCCURS 10.
      INCLUDE STRUCTURE gt_imarm.
  DATA: END OF t_marm.

* Nur als Dummy für FB-Aufruf.
  DATA: BEGIN OF t_mara OCCURS 1.
      INCLUDE STRUCTURE gt_imara.
  DATA: END OF t_mara.


* Initialisieren der Datentabellen
  REFRESH: pet_imarm, t_mara.
  CLEAR:   pet_imarm, t_mara, pxt_orgtab, pe_fehlercode.

* Merken des aktuellen Schlüssels.
  i_key-matnr = pi_artnr.
  i_key-vrkme = pi_vrkme.

* Füllen des Tabellenschlüssels.
  pet_imarm-mandt = sy-mandt.
  pet_imarm-matnr = pi_artnr.
  pet_imarm-meinh = pi_vrkme.
  APPEND pet_imarm.


* Die Tabellen MARA, MAKT, MAMT, MVKE und MEAN werden nicht benötigt.

* ### zukünftige Änderung.
* Besorge Material-Stammdaten.
* call function 'MATERIAL_CHANGE_DOCUMENTATION'
*      exporting
*           date_from            = pi_datab
*           date_to              = pi_datbi
*           explosion            = 'X'
*           indicator            = 'X'
*      importing
*           no_record_found_marm = no_record_found_marm
*      tables
*           jmara                = t_mara
*           jmarm                = pet_imarm
*           change_field_tab     = pit_field_tab
*      exceptions
*           wrong_date_relation  = 01.

  CALL FUNCTION 'POS_MATERIAL_GET'
    EXPORTING
      pi_datab             = pi_datab
      marm_ean_check       = 'X'
    IMPORTING
      no_record_found_marm = no_record_found_marm
    TABLES
      p_t_cmara            = t_mara
      p_t_cmarm            = pet_imarm
    EXCEPTIONS
      OTHERS               = 01.

  IF no_record_found_marm <> space.
*   Setze Fehlercode auf fehlerhaft.
    pe_fehlercode = 1.

*   Falls Fehlerprotokollierung erwünscht.
    IF pi_ermod = space.
*     Falls noch keine Initialisierung des Fehlerprotokolls.
      IF g_init_log = space.
*       Aufbereitung der Parameter zum schreiben des Headers des
*       Fehlerprotokolls.
        CLEAR: gi_errormsg_header.
        gi_errormsg_header-object        = c_applikation.
        gi_errormsg_header-subobject     = c_subobject.
        gi_errormsg_header-extnumber     = pi_dldnr.
        gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
        gi_errormsg_header-aluser        = sy-uname.

*       Initialisiere Fehlerprotokoll und erzeuge Header.
        PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*       Merke, daß Fehlerprotokoll initialisiert wurde.
        g_init_log = 'X'.
      ENDIF.                           " G_INIT_LOG = SPACE.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      CLEAR: gi_message.
      gi_message-msgty     = c_msgtp_error.
      gi_message-msgid     = c_message_id.
      gi_message-probclass = c_probclass_sehr_wichtig.
*     'Die Verk.ME & zum Material & ist nicht im Materialstamm
*     gepflegt'.
      gi_message-msgno     = '120'.
      gi_message-msgv1     = pi_vrkme.
      gi_message-msgv2     = pi_artnr.

*     Schreibe Fehlerzeile für Application-Log und WDLSO.
      g_object_key = i_key.
      PERFORM appl_log_write_single_message USING  gi_message.

    ENDIF.                             " PI_ERMOD = SPACE.

*   Ändern der Status-Kopfzeile, falls nötig.
    IF g_status < 3.                   " 'Fehlende Daten'
      CLEAR: gi_status_header.
      gi_status_header-dldnr = pi_dldnr.
      gi_status_header-gesst = c_status_fehlende_daten.

*     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
      PERFORM status_write_head USING  'X'  gi_status_header  pi_dldnr
                                       g_returncode.
*     Aktualisiere Aufbereitungsstatus.
      g_status = 3.                    " 'Fehlende Daten'

    ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-lfdnr  = pi_dldlfdnr.
    gi_status_pos-anloz  = g_err_counter.
    gi_status_pos-anseg  = pi_segment_counter.
    gi_status_pos-stkey  = g_firstkey.
    gi_status_pos-ltkey  = i_key.

*   Aktualisiere Aufbereitungsstatus für Positionszeile,
*   falls nötig.
    IF g_status_pos < 3.                   " 'Fehlende Daten'
      gi_status_pos-gesst = c_status_fehlende_daten.

      g_status_pos = 3.                    " 'Fehlende Daten'
    ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                       g_returncode.

*   Falls Fehlerprotokollierung erwünscht.
    IF pi_ermod = space.
*     Verlassen der Aufbereitung, falls Einlesefehler.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_ERMOD = SPACE.
  ENDIF.                               " NO_RECORD_FOUND_MARM <> SPACE.



* Analysiere Materialstammdaten und ergänze Org.Tabelle.

* Falls Änderungsfall.
  IF pi_mode = c_change_mode.
*   Übernehme Versendezeitpunkte aus Tabelle PIT_OT3, falls nötig.
    LOOP AT pit_ot3
      WHERE init = space.
      readindex = pit_ot3-datum - pi_datab.
      ADD 1 TO readindex.
      READ TABLE pxt_orgtab INDEX readindex.
      pxt_orgtab-change = 'X'.
      MODIFY pxt_orgtab INDEX readindex.
    ENDLOOP.                           " AT PIT_OT3.

*   Übernehme Versendezeitpunkte aus Listungstabelle, falls nötig.
    IF pi_initdat <> space.
      LOOP AT pit_listung
           WHERE vrkme = pi_vrkme.
        IF pi_initdat <= pit_listung-datab.
          readindex = pit_listung-datab - pi_datab.
          ADD 1 TO readindex.
          READ TABLE pxt_orgtab INDEX readindex.
          pxt_orgtab-change = 'X'.
          MODIFY pxt_orgtab INDEX readindex.
        ELSEIF pi_initdat = g_erstdat          AND
               pit_listung-datab < pi_initdat.
          READ TABLE pxt_orgtab INDEX 1.
          pxt_orgtab-change = 'X'.
          MODIFY pxt_orgtab INDEX 1.
        ENDIF. " PI_INITDAT <= PIT_LISTUNG-DATAB.
      ENDLOOP.                         " AT PIT_LISTUNG.
    ENDIF.                             " PI_INITDAT <> SPACE.
  ENDIF. " PI_MODE = C_CHANGE_MODE

* Analysieren Daten aus MARM.
  LOOP AT pet_imarm.
*   Das Datum für den ersten Satz darf nicht initial sein.
    IF pet_imarm-datum < pi_datab.
      pet_imarm-datum = pi_datab.
      MODIFY pet_imarm.
    ENDIF.                             " PET_IMARM-DATUM < pi_datab.

    IF sy-tabix = 1.
*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Prüfe, ob die erste EAN bereits gemerkt wurde.
        READ TABLE gt_old_ean_nart WITH KEY
                   artnr = pet_imarm-matnr
                   vrkme = pet_imarm-meinh
                   datum = pet_imarm-datum
                   BINARY SEARCH.

        IF sy-subrc = 0.
          pe_ean = gt_old_ean_nart-ean11.

*       Die alte EAN wurde noch nicht zwischengespeichert d. h.,
*       wenn eine Haupt-EAN-Änderung stattfinden soll, dann kann
*       dies nur in der Zukunft passieren, denn sonst wäre ein
*       Eintrag vorhanden (siehe EAN-Analyse für Änderungsfall).
*       Daher übernehme die EAN vom Vortag der ersten Änderung.
        ELSE.                          " if sy-subrc <> 0.
          h_datum = pet_imarm-datum - 1.

*         Falls eine zukünftige EAN-Änderung stattfinden kann.
          IF h_datum >= sy-datum.
*           Lese zukünftige EAN vom Vortag der ersten Änderung.
*           Mit dieser Lösch-EAN muß der Löschsatz aufbereitet werden.
            PERFORM ean_by_date_get
                        USING pet_imarm-matnr  pet_imarm-meinh
                              h_datum          g_loesch_ean
                              g_returncode.

*           Falls vorher schon eine EAN vorhanden war.
            IF g_loesch_ean <> space.
              pe_ean = g_loesch_ean.
*           Falls vorher noch keine EAN vorhanden war, dann kein
*           Lösch-Satz.
            ELSE.                      " g_loesch_ean = space.
              pe_ean = pet_imarm-ean11.
            ENDIF.                     " g_loesch_ean <> space.

*         Es soll zum Tag der ersten Änderung keine Haupt-EAN-Änd.
*         stattfinden. Daher Behandlung wie Initialisierungfall.
          ELSE.                        " h_datum < sy-datum.
*           Speichere Haupt-EAN dieser Verkaufsmengeneinheit.
            pe_ean = pet_imarm-ean11.
          ENDIF.                       " h_datum >= sy-datum.
        ENDIF.                         " sy-subrc = 0.

*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      ELSE.
*       Speichere Haupt-EAN dieser Verkaufsmengeneinheit.
        pe_ean = pet_imarm-ean11.
      ENDIF. " pi_mode = c_change_mode


*     Vermerke 1. Satz in Org.Tabelle
      READ TABLE pxt_orgtab INDEX 1.
      pxt_orgtab-marm  = 'X'.

*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
        IF pi_initdat <> space AND pi_initdat <= pet_imarm-datum.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMARM-DATUM.
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      ELSE.
*       Vermerke in Org.Tabelle, daß der erste Satz
*       versendet werden soll.
        pxt_orgtab-change = 'X'.
      ENDIF. " PI_MODE = C_CHANGE_MODE

      MODIFY pxt_orgtab INDEX 1.

*     Falls Löschmodus aktiv, dann weitere Aufbereitung nicht nötig.
      IF pi_loeschen <> space.
        EXIT.
      ENDIF. " pi_loeschen <> space.

    ELSE.                              " SY-TABIX > 1.
*     Falls eine POS-relevante Änderung gefunden wurde, so wird
*     dies in der Org.Tabelle vermerkt.
      IF pet_imarm-chgflag <> space.
        readindex = pet_imarm-datum - pi_datab.
        ADD 1 TO readindex.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-marm  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_imarm-datum.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMARM-DATUM.
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Falls eine POS-relevante Änderung gefunden wurde, so wird
*         dies in der Org.Tabelle vermerkt.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX readindex.
      ENDIF.                           " PET_IMARM-CHGFLAG <> SPACE.
    ENDIF.                             " SY-TABIX = 1.
  ENDLOOP.                             " AT PET_IMARM.

* Falls Löschmodus aktiv, dann weitere Aufbereitung nicht nötig.
  IF pi_loeschen <> space.
    EXIT.
  ENDIF. " pi_loeschen <> space.

  REFRESH: pet_nart_komp.
  CLEAR:   pet_nart_komp.


"Check if article is a Multi Level Structured Article
  lv_is_multi_lvl_struc_art = cl_struc_art_multi_lvl_generic=>get_single_instance( )->is_multi_lvl_struc_art(
            iv_matnr = pi_artnr
            iv_erfme = pi_vrkme
  ).

"Determination of empties for MSA differs from full products
  IF lv_is_multi_lvl_struc_art = abap_true.

    ls_multi_lvl_struc_art-matnr = pi_artnr.
    ls_multi_lvl_struc_art-meins = pi_vrkme.
    CALL METHOD cl_struc_art_multi_lvl_generic=>if_struc_art_multi_lvl~explode_struc_art_multi_lvl(
      EXPORTING
        is_struc_art  = ls_multi_lvl_struc_art
      CHANGING
        ct_components = lt_mixed_display_components
                        ).

    "Sum up amounts of same empties

    LOOP AT lt_mixed_display_components INTO DATA(ls_tmp)
        GROUP BY ( empty = ls_tmp-empty )
        ASCENDING
        REFERENCE INTO DATA(empty_group).

      LOOP AT GROUP empty_group ASSIGNING FIELD-SYMBOL(<empty_member>).
        ADD <empty_member>-emp_quant TO ls_pet_nart_komp-menge.
        ls_pet_nart_komp-meins = <empty_member>-emp_uom.
      ENDLOOP.
      ls_pet_nart_komp-idnrk = empty_group->empty.
      ls_pet_nart_komp-datub = pi_datab.

      APPEND ls_pet_nart_komp TO pet_nart_komp.
      CLEAR ls_pet_nart_komp.
    ENDLOOP.

  ELSE.
* Besorge Nachzugsartikel-Komponenten für Vollgut aus Tabelle STPO.
    CALL FUNCTION 'MGW0_PACKAGING_COMPONENTS'
      EXPORTING
        mgw0_article    = pi_artnr
        mgw0_date_from  = pi_datab
        mgw0_date_to    = pi_datbi
        mgw0_plant      = ' '
        mgw0_unit       = pi_vrkme
      TABLES
        mgw0_components = pet_nart_komp
      EXCEPTIONS
        not_found       = 01.

  ENDIF.

  IF sy-subrc <> 0.
*   Zwischenspeichern des Returncodes.
    pe_fehlercode = sy-subrc.

*   Falls Initialisierungsfall, direkte Anforderung oder Restart.
*   if pi_mode <> c_change_mode.
*     Im Initialisierungsfall bzw. bei der direkten Anforderung kann es
*     vorkommen, daß zu einem als Nachzugsartikel gekennzeichneten
*     Artikel keine Komponenten existieren. Dies kommt daher, weil das
*     Kennzeichen lediglich aussagt, daß dieser Artikel ein
*     Nachzugsartikel sein kann aber nicht muß.
*     exit.
*   endif. "pi_mode <> c_change_mode.

*   Falls Fehlerprotokollierung erwünscht.
    IF pi_ermod = space.
*     Falls noch keine Initialisierung des Fehlerprotokolls.
      IF g_init_log = space.
*       Aufbereitung der Parameter zum schreiben des Headers des
*       Fehlerprotokolls.
        CLEAR: gi_errormsg_header.
        gi_errormsg_header-object        = c_applikation.
        gi_errormsg_header-subobject     = c_subobject.
        gi_errormsg_header-extnumber     = pi_dldnr.
        gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
        gi_errormsg_header-aluser        = sy-uname.

*       Initialisiere Fehlerprotokoll und erzeuge Header.
        PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*       Merke, daß Fehlerprotokoll initialisiert wurde.
        g_init_log = 'X'.
      ENDIF.                           " G_INIT_LOG = SPACE.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      CLEAR: gi_message.
      gi_message-msgty     = c_msgtp_warning.
      gi_message-msgid     = c_message_id.
      gi_message-probclass = c_probclass_weniger_wichtig.
*     'Keine Komponenten für Nachgzugsart. & und Verk.einh. & gepflegt'
      gi_message-msgno     = '130'.
      gi_message-msgv1     = pi_artnr.
      gi_message-msgv2     = pi_vrkme.

*     Schreibe Fehlerzeile.
      CLEAR: g_object_key.
      PERFORM appl_log_write_single_message USING  gi_message.

    ENDIF.                             " PI_ERMOD = SPACE.

*   Ändern der Status-Kopfzeile, falls nötig.
    IF g_status < 2.                   " 'Benutzerhinweis'
      CLEAR: gi_status_header.
      gi_status_header-dldnr = pi_dldnr.
      gi_status_header-gesst = c_status_benutzerhinweis.

*     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
      PERFORM status_write_head USING  'X'  gi_status_header  pi_dldnr
                                       g_returncode.
*     Aktualisiere Aufbereitungsstatus.
      g_status = 2.                    " 'Benutzerhinweis'

    ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'

*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-lfdnr  = pi_dldlfdnr.
    gi_status_pos-anloz  = g_err_counter.
    gi_status_pos-anseg  = pi_segment_counter.
    gi_status_pos-stkey  = g_firstkey.
    gi_status_pos-ltkey  = i_key.

*   Aktualisiere Aufbereitungsstatus für Positionszeile,
*   falls nötig.
    IF g_status_pos < 2.                   " 'Benutzerhinweis'
      gi_status_pos-gesst = c_status_benutzerhinweis.

      g_status_pos = 2.                    " 'Benutzerhinweis'
    ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                       g_returncode.

*   Falls Fehlerprotokollierung erwünscht.
    IF pi_ermod = space.
*     Verlassen der Aufbereitung, falls Einlesefehler.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_ERMOD = SPACE.
  ENDIF.                               " SY-SUBRC <> 0.


* Analysieren Daten aus STPO.

  SORT pet_nart_komp BY datuv.
  LOOP AT pet_nart_komp.
*   Das Feld DATUV muß >= PI_DATAB sein haben, damit Konsistenz
*   zur Org.-Tabelle besteht.
    IF pet_nart_komp-datuv < pi_datab.
      pet_nart_komp-datuv = pi_datab.
      MODIFY pet_nart_komp.
    ENDIF.                             " PET_NART_KOMP-DATUV < PI_DATAB.

*   Vermerke in Org.Tabelle das Lesen des ersten Satzes.
    readindex = pet_nart_komp-datuv - pi_datab.
    ADD 1 TO readindex.
    READ TABLE pxt_orgtab INDEX readindex.
    pxt_orgtab-stpo  = 'X'.

*   Falls Änderungsfall.
    IF pi_mode = c_change_mode.
*     Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
      IF pi_initdat <> space AND pi_initdat <= pet_nart_komp-datuv.
        pxt_orgtab-change = 'X'.
      ENDIF.                           " PI_INITDAT <> SPACE AND ...
*   Falls Initialisierungsfall, direkte Anforderung oder Restart.
    ELSE.
*     Vermerke in Org.Tabelle, daß der erste Satz
*     versendet werden soll.
      pxt_orgtab-change = 'X'.
    ENDIF. " PI_MODE = C_CHANGE_MODE

    MODIFY pxt_orgtab INDEX readindex.

  ENDLOOP.                             " AT PET_NART_KOMP.

* Übernehme alle unterschiedlichen Positionen in interne Tabelle.
  SORT pet_nart_komp BY idnrk meins datuv.
  REFRESH: t_position.
  CLEAR: i_key1, i_key2, t_position.
  LOOP AT pet_nart_komp.
    i_key2-idnrk = pet_nart_komp-idnrk.
    i_key2-meins = pet_nart_komp-meins.

    IF i_key1 <> i_key2.
      i_key1 = i_key2.
      t_position-matnr = pet_nart_komp-idnrk.
      t_position-meinh = pet_nart_komp-meins.
      APPEND t_position.
    ENDIF.                             " I_KEY1 <> I_KEY2.
  ENDLOOP.                             " AT PET_NART_KOMP.

* Resortiere Positionsdaten.
  SORT pet_nart_komp BY datuv.

* Rücksetze Tabelle der Haupt-EAN's der Set-Komponenten.
  REFRESH: pet_nart_komp_ean.
  CLEAR:   pet_nart_komp_ean.

* Besorge alle nötigen Haupt-EAN-Änderungen der NART-Komponenten.
  LOOP AT t_position.
*   Rücksetze interne Tabelle.
    REFRESH: t_marm, t_mara.
    CLEAR:   t_marm, t_mara.

*   Füllen des Tabellenschlüssels.
    t_marm-mandt = sy-mandt.
    t_marm-matnr = t_position-matnr.
    t_marm-meinh = t_position-meinh.
    APPEND t_marm.

* ### zukünftige Änderung.
*   Besorge Material-Stammdaten bzgl. der Haupt-EAN-Änderung.
*   call function 'MATERIAL_CHANGE_DOCUMENTATION'
*        exporting
*             date_from            = pi_datab
*             date_to              = pi_datbi
*             explosion            = 'X'
*             indicator            = 'X'
*        importing
*             no_record_found_marm = no_record_found_marm
*        tables
*             jmara                = t_mara
*             jmarm                = t_marm
*             change_field_tab     = pit_field_tab
*        exceptions
*             wrong_date_relation  = 01.

    CALL FUNCTION 'POS_MATERIAL_GET'
      EXPORTING
        marm_ean_check       = 'X'
      IMPORTING
        no_record_found_marm = no_record_found_marm
      TABLES
        p_t_cmara            = t_mara
        p_t_cmarm            = t_marm
      EXCEPTIONS
        OTHERS               = 01.

*   Analysieren Daten aus MARM und speichere diese für spätere
*   Aufbereitung.
    LOOP AT t_marm.
*     Das Datum darf nicht < PI_DATAB sein.
      IF t_marm-datum < pi_datab.
        t_marm-datum = pi_datab.
        MODIFY t_marm.
      ENDIF.                         " T_MARM-DATUM < pi_datab.

      IF sy-tabix = 1.
*       Vermerke 1. Satz in Org.Tabelle
        readindex = t_marm-datum - pi_datab.
        ADD 1 TO readindex.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-marm  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= t_marm-datum.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= T_MARM-DATUM.
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Vermerke in Org.Tabelle, daß der erste Satz
*         versendet werden soll.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX readindex.

      ELSE.                            " SY-TABIX > 1.
*       Falls eine POS-relevante Änderung gefunden wurde, so wird
*       dies in der Org.Tabelle vermerkt.
        IF t_marm-chgflag <> space.
          readindex = t_marm-datum - pi_datab.
          ADD 1 TO readindex.
          READ TABLE pxt_orgtab INDEX readindex.
          pxt_orgtab-marm  = 'X'.

*         Falls Änderungsfall.
          IF pi_mode = c_change_mode.
*           Falls initialisiert werden soll, vermerke dies in
*           Org.Tabelle.
            IF pi_initdat <> space AND pi_initdat <= t_marm-datum.
              pxt_orgtab-change = 'X'.
            ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= T_MARM-DATUM.
*         Falls Initialisierungsfall, direkte Anforderung oder Restart.
          ELSE.
*           Falls eine POS-relevante Änderung gefunden wurde, so wird
*           dies in der Org.Tabelle vermerkt.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_MODE = C_CHANGE_MODE

          MODIFY pxt_orgtab INDEX readindex.
        ENDIF.                         " T_MARM-CHGFLAG <> SPACE.
      ENDIF.                           " SY-TABIX = 1.

*     Zwischenspeichern der relevanten MARM-Daten für spätere
*     Aufbereitung.
      pet_nart_komp_ean-datab = t_marm-datum.
      pet_nart_komp_ean-matnr = t_marm-matnr.
      pet_nart_komp_ean-meins = t_marm-meinh.
      pet_nart_komp_ean-ean11 = t_marm-ean11.
      pet_nart_komp_ean-numtp = t_marm-numtp.
      APPEND pet_nart_komp_ean.

    ENDLOOP.                           " AT T_MARM.
  ENDLOOP.                             " AT T_POSITION.

* Sortieren der relevanten MARM-Daten der Set-Komponenten.
  SORT pet_nart_komp_ean BY matnr meins datab DESCENDING.


ENDFORM.                               " NARTDATA_GET_AND_ANALYSE


*eject.
************************************************************************
FORM idoc_dataset_nart_append
     TABLES pit_imarm         STRUCTURE gt_imarm
            pit_nart_komp     STRUCTURE gt_nart_komp
            pit_nart_komp_ean STRUCTURE gt_nart_komp_ean
            pit_orgtab        STRUCTURE gt_orgtab_nart
            pit_field_tab     STRUCTURE gt_field_tab
     USING  pxt_idoc_data     TYPE short_edidd
            pi_datum          LIKE syst-datum
            px_segcnt         LIKE g_segment_counter
            pi_loeschen       LIKE wpstruc-modus
            pi_e1wpn02        LIKE wpstruc-modus
            pi_filia          LIKE t001w-werks
            pe_fehlercode     LIKE syst-subrc
            pi_dldnr          LIKE wdls-dldnr
            pi_dldlfdnr       LIKE wdlsp-lfdnr
            pi_filia_const    LIKE wpfilconst
            px_ean            LIKE marm-ean11.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_IMARM        : Tabelle mit MARM-Daten.

* PIT_NART_KOMP    : Tabelle für Set-Komponenten.

* PIT_NART_KOMP_EAN: Tabelle für Haupt-EAN's der
*                    Nachzugsartikel-Komponenten.
* PIT_ORGTAB       : Organisationstabelle für Artikelstamm.

* PIT_FIELD_TAB    : POS-relevante Felder der Materialstammtabellen.

* PXT_IDOC_DATA    : IDOC-Daten der Struktur EDIDD (Tabelle an die die
*                    IDOC-Sätze angefügt werden).
* PI_DATUM         : Datum für das die Daten aufbereitet werden sollen.

* PX_SEGCNT        : Segment-Zähler.

* PI_LOESCHEN      : = 'X', wenn Löschmodus aktiv.

* PI_E1WPN02       : = 'X', wenn Segment E1WPN02 aufbereitet werden soll

* PI_FILIA         : Filiale, an die versendet werden soll.

* PE_FEHLERCODE    : > 0, wenn Fehler auftraten.

* PI_DLDNR         : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR      : Laufende Nr. der Positionszeile für
*                    Statusverfolgung.
* PI_FILIA_CONST   : Filialkonstanten.

* PX_EAN           : Haupt-EAN zur Verkaufsmengeneinheit des Artikels.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: lese_datum    LIKE sy-datum,
        e1wpn02_cnt   TYPE i,
        fehlercode    LIKE sy-subrc,
        h_returncode  LIKE sy-subrc,
        seg_local_cnt TYPE i,
        h_numtp       LIKE  marm-numtp.

  DATA: BEGIN OF i_kond_key1,
          kschl LIKE komv-kschl,
          datab LIKE sy-datum.
  DATA: END OF i_kond_key1.

  DATA: BEGIN OF i_kond_key2,
          kschl LIKE komv-kschl,
          datab LIKE sy-datum.
  DATA: END OF i_kond_key2.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Zum lesen der Haupt-EAN einer Nachzugsartikel-Komponente.
  DATA: BEGIN OF t_marm OCCURS 1.
      INCLUDE STRUCTURE gt_imarm.
  DATA: END OF t_marm.

* Nur als Dummy-Tabelle. Wird nicht benötigt.
  DATA: BEGIN OF t_mara OCCURS 1.
      INCLUDE STRUCTURE gt_imara.
  DATA: END OF t_mara.

* Rücksetze Returncode.
  CLEAR: pe_fehlercode, e1wpn02_cnt.

* Besorge für PI_DATUM das Zugriffsdatum auf die zugehörigen MARM-Daten.
  CLEAR: lese_datum.
  LOOP AT pit_orgtab
    WHERE datum <= pi_datum
    AND   marm  <> space.
*   Merke des Datum für Zugriff auf MARM-Daten.
    lese_datum = pit_orgtab-datum.
    EXIT.
  ENDLOOP.                             " AT PIT_ORGTAB

* Besorge die zugehörigen MARA-Daten. Die Daten stehen in der
* Kopfzeile von PIT_IMARA.
  LOOP AT pit_imarm
    WHERE datum = lese_datum.
    EXIT.
  ENDLOOP.                             " AT PIT_IMARM

* Setze Objektschlüssel.
  i_key-matnr = pit_imarm-matnr.
  i_key-vrkme = pit_imarm-meinh.

* Falls sich die Haupt-EAN verändert hat, muß der Satz mit der
* alten Haupt-EAN gelöscht werden.
  IF pit_imarm-ean11 <> px_ean.
*   Falls eine Haupt-EAN erst gelöscht und dann wieder eingefügt
*   wurde, so muß kein Lösch-Satz für die gelöschte
*   Haupt-EAN aufbereitet werden.
    IF px_ean <> space.
*     Rücksetze Temporärtabelle für IDOC-Daten.
      REFRESH: gt_idoc_data_temp.

*     Rücksetze lokalen Segmentzähler.
      CLEAR: seg_local_cnt.

*     Aufbereitung ID-Segment zum löschen.
      CLEAR: e1wpn01.
      e1wpn01-filiale    = pi_filia_const-kunnr.
      e1wpn01-aendkennz  = c_delete.
      e1wpn01-aktivdatum = pi_datum.
      e1wpn01-aenddatum  = '00000000'.
      e1wpn01-aenderer   = ' '.

*      e1wpn01-artikelnr_long  = pit_imarm-matnr.
      cl_matnr_chk_mapper=>convert_on_output(
         EXPORTING
           iv_matnr40               = pit_imarm-matnr
         IMPORTING
           ev_matnr18               = e1wpn01-artikelnr
           ev_matnr40               = e1wpn01-artikelnr_long
         EXCEPTIONS
           excp_matnr_invalid_input = 1
           excp_matnr_not_found     = 2
           OTHERS                   = 3 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*     E1WPN01-POSME      = PIT_IMARM-MEINH.    ### aktivieren

*     Besorge EAN-Typ.
*     Prüfe zunächst, ob es sich um eine alte EAN handelt.
      LOOP AT gt_old_ean_nart
           WHERE artnr = pit_imarm-matnr
           AND   vrkme = pit_imarm-meinh
           AND   ean11 = px_ean.
        EXIT.
      ENDLOOP. " at gt_old_ean_nart

*     Falls es sich um eine alte EAN handelt und sich der EAN-Typ
*     geändert hat.
      IF sy-subrc = 0 AND NOT gt_old_ean_nart-numtp IS INITIAL.
        h_numtp = gt_old_ean_nart-numtp.

*     Falls es sich nicht um eine alte EAN handelt oder der EAN-Typ
*     unverändert geblieben ist.
      ELSE. " sy-subrc <> 0 ...
        h_numtp = pit_imarm-numtp.

      ENDIF. " sy-subrc = 0.

*     Ausgabekonvertierung für EAN.
      CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
        EXPORTING
          input   = px_ean
          ean_typ = h_numtp
        IMPORTING
          output  = e1wpn01-eanverbr.

*     Erzeuge temporären IDOC-Segmentsatz.
      gt_idoc_data_temp-segnam = c_e1wpn01_name.
      gt_idoc_data_temp-sdata  = e1wpn01.
      APPEND gt_idoc_data_temp.

*     aktualisiere Segmentzähler und Haupt-EAN.
      ADD 1 TO seg_local_cnt.
      px_ean = pit_imarm-ean11.

*********************************************************************
***********************   U S E R - E X I T  ************************
      CALL CUSTOMER-FUNCTION '005'
        EXPORTING
          pi_e1wpn02_cnt     = e1wpn02_cnt
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
          pi_vrkme           = i_key-vrkme
          pi_marm            = pit_imarm
          pi_filia_const     = pi_filia_const
        IMPORTING
          px_init_log        = g_init_log
          px_status          = g_status
          px_status_pos      = g_status_pos
          pe_fehlercode      = pe_fehlercode
          px_err_counter     = g_err_counter
          pi_seg_local_cnt   = seg_local_cnt
        TABLES
          pxt_idoc_data_temp = gt_idoc_data_temp
          pit_idoc_data      = gt_idoc_data_dummy
        CHANGING
          pit_idoc_data_new  = pxt_idoc_data.

*     Falls Umsetzfehler auftraten.
      IF pe_fehlercode <> 0.
*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Falls der Satz zum heutigen Datum gelöscht werden soll.
          IF pi_datum <= sy-datum.
*           Fülle allgemeinen Objektschlüssel.
            CLEAR: gi_object_key.
            gi_object_key-matnr = pit_imarm-matnr.
            gi_object_key-vrkme = pit_imarm-meinh.
            gi_object_key-ean11 = px_ean.
            g_object_key        = gi_object_key.
            g_object_delete     = 'X'.

*           Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
            PERFORM error_object_write.

*           Rücksetze Löschkennzeichen für Fehlerobjekttabelle WDLSO.
            CLEAR: g_object_delete.
          ENDIF. " pi_datum <= sy-datum.

*         Verlassen der Aufbereitung für dieses Datum.
          EXIT.
*       Falls Abbruch bei Fehler erwünscht.
        ELSE.                          " PI_FILIA_CONST-ERMOD <> SPACE.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*     Falls Umschlüsselung fehlerfrei.
      ELSE.                            " PE_FEHLERCODE = 0.
*       Übernehme die IDOC-Daten aus Temporärtabelle.
        PERFORM idoc_data_assume TABLES  gt_idoc_data_temp
                                 USING   pxt_idoc_data
                                         px_segcnt
                                         seg_local_cnt.

      ENDIF.                           " PE_FEHLERCODE <> 0.

*********************************************************************
    ENDIF.                             " PX_EAN <> SPACE.
  ENDIF.                               " PIT_IMARM-EAN11 <> PX_EAN.

* Falls EAN gelöscht wurde.
  IF pit_imarm-ean11 = space.
*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Falls noch keine Initialisierung des Fehlerprotokolls.
      IF g_init_log = space.
*       Aufbereitung der Parameter zum schreiben des Headers des
*       Fehlerprotokolls.
        CLEAR: gi_errormsg_header.
        gi_errormsg_header-object        = c_applikation.
        gi_errormsg_header-subobject     = c_subobject.
        gi_errormsg_header-extnumber     = pi_dldnr.
        gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
        gi_errormsg_header-aluser        = sy-uname.

*       Initialisiere Fehlerprotokoll und erzeuge Header.
        PERFORM appl_log_init_with_header
                USING gi_errormsg_header.

*       Merke, daß Fehlerprotokoll initialisiert wurde.
        g_init_log = 'X'.
      ENDIF.                           " G_INIT_LOG = SPACE.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      WRITE pi_datum TO g_datum1 DD/MM/YYYY.

      CLEAR: gi_message.
      gi_message-msgty     = c_msgtp_warning.
      gi_message-msgid     = c_message_id.
      gi_message-probclass = c_probclass_weniger_wichtig.
*     'Keine EAN für Material & und Verk.einh.
*     zum Datum & gepflegt'
      gi_message-msgno     = '125'.
      gi_message-msgv1     = i_key-matnr.
      gi_message-msgv2     = i_key-vrkme.
      gi_message-msgv3     = g_datum1.

*     Schreibe Fehlerzeile.
      CLEAR: g_object_key.
      PERFORM appl_log_write_single_message USING  gi_message.

    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.

*   Ändern der Status-Kopfzeile, falls nötig.
    IF g_status < 2.                   " 'Benutzerhinweis'.
      CLEAR: gi_status_header.
      gi_status_header-dldnr = pi_dldnr.
      gi_status_header-gesst = c_status_benutzerhinweis.

*     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
      PERFORM status_write_head USING  'X'  gi_status_header
                                       pi_dldnr  h_returncode.
*     Aktualisiere Aufbereitungsstatus.
      g_status = 2.                    " 'Benutzerhinweis'.

    ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'.

*   Aufbereiten der Parameter zum Ändern der
*   Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-lfdnr  = pi_dldlfdnr.
    gi_status_pos-anloz  = g_err_counter.
    gi_status_pos-anseg  = px_segcnt.
    gi_status_pos-stkey  = g_firstkey.
    gi_status_pos-ltkey  = i_key.

*   Aktualisiere Aufbereitungsstatus für Positionszeile,
*   falls nötig.
    IF g_status_pos < 2.                   " 'Benutzerhinweis'
      gi_status_pos-gesst = c_status_benutzerhinweis.

      g_status_pos = 2.                    " 'Benutzerhinweis'
    ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                       h_returncode.

*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Verlassen der Aufbereitung für dieses Datum
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_FILIA_CONST-ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.
  ENDIF.                               " PIT_IMARM-EAN11 = SPACE.

* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: gt_idoc_data_temp.

* Rücksetze lokalen Segmentzähler.
  CLEAR: seg_local_cnt.

* Aufbereitung ID-Segment.
  CLEAR: e1wpn01.
  e1wpn01-filiale    = pi_filia_const-kunnr.
  e1wpn01-aktivdatum = pi_datum.
  e1wpn01-aenddatum  = '00000000'.
  e1wpn01-aenderer   = ' '.
  e1wpn01-eanverbr   = pit_imarm-ean11.
*  e1wpn01-artikelnr_long  = pit_imarm-matnr.
  cl_matnr_chk_mapper=>convert_on_output(
   EXPORTING
     iv_matnr40               = pit_imarm-matnr
   IMPORTING
     ev_matnr18               = e1wpn01-artikelnr
     ev_matnr40               = e1wpn01-artikelnr_long
   EXCEPTIONS
     excp_matnr_invalid_input = 1
     excp_matnr_not_found     = 2
     OTHERS                   = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* E1WPN01-POSME      = PIT_IMARM-MEINH.          ### aktivieren

* Ausgabekonvertierung für EAN.
  CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
    EXPORTING
      input   = pit_imarm-ean11
      ean_typ = pit_imarm-numtp
    IMPORTING
      output  = e1wpn01-eanverbr.

* Falls Löschmodus aktiv.
  IF pi_loeschen <> space.
    e1wpn01-aendkennz  = c_delete.
* Falls Löschmodus nicht aktiv.
  ELSE.
    e1wpn01-aendkennz  = c_modi.
  ENDIF.                               " PI_LOESCHEN <> SPACE.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpn01_name.
  gt_idoc_data_temp-sdata  = e1wpn01.
  APPEND gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  ADD 1 TO seg_local_cnt.

* Es müssen Stammdaten übertragen werden, da kein Löschmodus aktiv ist.
  IF pi_loeschen = space.
*   Falls Segment E1WPS02 (Set-Komponenten) gefüllt werden muß.
    IF pi_e1wpn02 <> space.
*     Besorge die für PI_DATUM gültigen Set-Komponenten.
      CLEAR: e1wpn02_cnt, fehlercode.

* Hinweis 778862
      SORT pit_nart_komp_ean BY matnr meins ean11 DESCENDING.
      DELETE ADJACENT DUPLICATES FROM pit_nart_komp_ean
      COMPARING matnr meins.


      LOOP AT pit_nart_komp
        WHERE datuv <= pi_datum
        AND   datub >= pi_datum.

*       Besorge die Haupt-EAN zur Komponente.
        CLEAR: pit_nart_komp_ean.
        LOOP AT pit_nart_komp_ean
             WHERE matnr =  pit_nart_komp-idnrk
             AND   meins =  pit_nart_komp-meins
             AND   datab <= pi_datum.
          EXIT.
        ENDLOOP.                       " AT PIT_NART_KOMP_EAN.

*       Falls eine Haupt-EAN zur Komponente vorhanden ist.
        IF sy-subrc = 0 AND pit_nart_komp_ean-ean11 <> space.
*         Fülle Segment E1WPN02.
          CLEAR: e1wpn02.
*          e1wpn02-artikelnr_long  = pit_nart_komp-idnrk.
          cl_matnr_chk_mapper=>convert_on_output(
            EXPORTING
              iv_matnr40               = pit_nart_komp-idnrk
            IMPORTING
              ev_matnr18               = e1wpn02-artikelnr
              ev_matnr40               = e1wpn02-artikelnr_long
            EXCEPTIONS
              excp_matnr_invalid_input = 1
              excp_matnr_not_found     = 2
           OTHERS                   = 3 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          e1wpn02-menge      = pit_nart_komp-menge.
          CONDENSE e1wpn02-menge.

*         Ausgabekonvertierung für EAN.
          CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
            EXPORTING
              input   = pit_nart_komp_ean-ean11
              ean_typ = pit_nart_komp_ean-numtp
            IMPORTING
              output  = e1wpn02-ean.

*         Erzeuge temporären IDOC-Segmentsatz.
          gt_idoc_data_temp-segnam = c_e1wpn02_name.
          gt_idoc_data_temp-sdata  = e1wpn02.
          APPEND gt_idoc_data_temp.

*         aktualisiere Segmentzähler.
          ADD 1 TO seg_local_cnt.
          ADD 1 TO e1wpn02_cnt.

*       Falls keine Haupt-EAN zur Komponente vorhanden ist.
        ELSE. " SY-SUBRC <> 0 OR PIT_NART_KOMP_EAN-EAN11 = SPACE.
*         Merken, daß ein Fehler auftrat.
          fehlercode = 1.

*         Falls Fehlerprotokollierung erwünscht.
          IF pi_filia_const-ermod = space.
*           Falls noch keine Initialisierung des Fehlerprotokolls.
            IF g_init_log = space.
*             Aufbereitung der Parameter zum schreiben des Headers des
*             Fehlerprotokolls.
              CLEAR: gi_errormsg_header.
              gi_errormsg_header-object        = c_applikation.
              gi_errormsg_header-subobject     = c_subobject.
              gi_errormsg_header-extnumber     = pi_dldnr.
              gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
              gi_errormsg_header-aluser        = sy-uname.

*             Initialisiere Fehlerprotokoll und erzeuge Header.
              PERFORM appl_log_init_with_header
                      USING gi_errormsg_header.

*             Merke, daß Fehlerprotokoll initialisiert wurde.
              g_init_log = 'X'.
            ENDIF.                     " G_INIT_LOG = SPACE.

*           Bereite Parameter zum schreiben der Fehlerzeile auf.
            WRITE pi_datum TO g_datum1 DD/MM/YYYY.

            CLEAR: gi_message.
            gi_message-msgty     = c_msgtp_error.
            gi_message-msgid     = c_message_id.
            gi_message-probclass = c_probclass_sehr_wichtig.
*           'Keine EAN für Material & und Verk.einh. & zum
*            Datum & gepflegt'
            gi_message-msgno     = '125'.
            gi_message-msgv1     = pit_nart_komp-idnrk.
            gi_message-msgv2     = pit_nart_komp-meins.
            gi_message-msgv3     = g_datum1.

*           Schreibe Fehlerzeile für Application-Log und WDLSO.
            g_object_key = i_key.
            PERFORM appl_log_write_single_message USING  gi_message.

          ENDIF.                       " PI_FILIA_CONST-ERMOD = SPACE.

*         Ändern der Status-Kopfzeile, falls nötig.
          IF g_status < 3.             " 'Fehlende Daten'
            CLEAR: gi_status_header.
            gi_status_header-dldnr = pi_dldnr.
            gi_status_header-gesst = c_status_fehlende_daten.

*           Korrigiere Status-Kopfzeile auf "Fehlerhaft".
            PERFORM status_write_head USING  'X'  gi_status_header
                                             pi_dldnr  h_returncode.
*           Aktualisiere Aufbereitungsstatus.
            g_status = 3.              " 'Fehlende Daten'

          ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*         Aufbereiten der Parameter zum Ändern der
*         Status-Positionszeile.
          CLEAR: gi_status_pos.
          gi_status_pos-dldnr  = pi_dldnr.
          gi_status_pos-lfdnr  = pi_dldlfdnr.
          gi_status_pos-anloz  = g_err_counter.
          gi_status_pos-anseg  = px_segcnt.
          gi_status_pos-stkey  = g_firstkey.
          gi_status_pos-ltkey  = i_key.

*         Aktualisiere Aufbereitungsstatus für Positionszeile,
*         falls nötig.
          IF g_status_pos < 3.                   " 'Fehlende Daten'
            gi_status_pos-gesst = c_status_fehlende_daten.

            g_status_pos = 3.                    " 'Fehlende Daten'
          ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*         Schreibe Status-Positionszeile.
          PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                             h_returncode.

*         Falls Fehlerprotokollierung erwünscht.
          IF pi_filia_const-ermod = space.
*           Verlassen der Aufbereitung für dieses Datum.
            EXIT.
*         Falls Abbruch bei Fehler erwünscht.
          ELSE.                        " PI_FILIA_CONST-ERMOD <> SPACE.
*           Abbruch des Downloads.
            RAISE download_exit.
          ENDIF.                       " PI_FILIA_CONST-ERMOD = SPACE.
        ENDIF.                         " T_MARM-EAN11 <> SPACE.
      ENDLOOP.                         " AT PIT_NART_KOMP

*     Falls Fehler innerhalb der Schleife auftraten, wird
*     die Aufbereitung für dieses Datum abgebrochen.
      IF NOT fehlercode IS INITIAL.
        EXIT.
      ENDIF.                           " NOT FEHLERCODE IS INITIAL.

*     Falls keine Nachzugsartikelkomponenten für diesen
*     Zeitpunkt existieren.
      IF sy-subrc <> 0.
*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          IF g_init_log = space.
*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            CLEAR: gi_errormsg_header.
            gi_errormsg_header-object        = c_applikation.
            gi_errormsg_header-subobject     = c_subobject.
            gi_errormsg_header-extnumber     = pi_dldnr.
            gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
            gi_errormsg_header-aluser        = sy-uname.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          ENDIF.                       " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          WRITE pi_datum TO g_datum1 DD/MM/YYYY.

          CLEAR: gi_message.
          gi_message-msgty     = c_msgtp_error.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_sehr_wichtig.
*         'Keine Komp. für Nachzugsartikel & und Verk.einh. &
*         zum Datum & gepflegt'
          gi_message-msgno     = '132'.
          gi_message-msgv1     = i_key-matnr.
          gi_message-msgv2     = i_key-vrkme.
          gi_message-msgv3     = g_datum1.

*         Schreibe Fehlerzeile für Application-Log und WDLSO.
          g_object_key = i_key.
          PERFORM appl_log_write_single_message USING  gi_message.

        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*       Ändern der Status-Kopfzeile, falls nötig.
        IF g_status < 3.               " 'Fehlende Daten'
          CLEAR: gi_status_header.
          gi_status_header-dldnr = pi_dldnr.
          gi_status_header-gesst = c_status_fehlende_daten.

*         Korrigiere Status-Kopfzeile auf "Fehlerhaft".
          PERFORM status_write_head USING  'X'  gi_status_header
                                           pi_dldnr  h_returncode.
*         Aktualisiere Aufbereitungsstatus.
          g_status = 3.                " 'Fehlende Daten'

        ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        CLEAR: gi_status_pos.
        gi_status_pos-dldnr  = pi_dldnr.
        gi_status_pos-lfdnr  = pi_dldlfdnr.
        gi_status_pos-anloz  = g_err_counter.
        gi_status_pos-anseg  = px_segcnt.
        gi_status_pos-stkey  = g_firstkey.
        gi_status_pos-ltkey  = i_key.

*       Aktualisiere Aufbereitungsstatus für Positionszeile,
*       falls nötig.
        IF g_status_pos < 3.                   " 'Fehlende Daten'
          gi_status_pos-gesst = c_status_fehlende_daten.

          g_status_pos = 3.                    " 'Fehlende Daten'
        ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*       Schreibe Status-Positionszeile.
        PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                           h_returncode.

*       Falls Fehlerprotokollierung erwünscht.
        IF pi_filia_const-ermod = space.
*         Verlassen der Aufbereitung für dieses Datum.
          EXIT.
*       Falls Abbruch bei Fehler erwünscht.
        ELSE.                          " PI_FILIA_CONST-ERMOD <> SPACE.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.
      ENDIF.                           " SY-SUBRC <> 0.
    ENDIF.                             " PI_E1WPS02 <> SPACE.
  ENDIF.                               " PI_LOESCHEN = SPACE

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '005'
    EXPORTING
      pi_e1wpn02_cnt     = e1wpn02_cnt
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
      pi_vrkme           = i_key-vrkme
      pi_marm            = pit_imarm
      pi_filia_const     = pi_filia_const
    IMPORTING
      px_init_log        = g_init_log
      px_status          = g_status
      px_status_pos      = g_status_pos
      pe_fehlercode      = pe_fehlercode
      px_err_counter     = g_err_counter
      pi_seg_local_cnt   = seg_local_cnt
    TABLES
      pit_nart_komp      = pit_nart_komp
      pxt_idoc_data_temp = gt_idoc_data_temp
      pit_idoc_data      = gt_idoc_data_dummy
    CHANGING
      pit_idoc_data_new  = pxt_idoc_data.

* Falls Umsetzfehler auftraten.
  IF pe_fehlercode <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Fülle allgemeinen Objektschlüssel.
      CLEAR: gi_object_key.
      gi_object_key-matnr = pit_imarm-matnr.
      gi_object_key-vrkme = pit_imarm-meinh.
      g_object_key = gi_object_key.

*     Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
      PERFORM error_object_write.

*     Verlassen der Aufbereitung für dieses Datum.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_FILIA_CONST-ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.

* Falls Umschlüsselung fehlerfrei.
  ELSE.                                " PE_FEHLERCODE = 0.
*   Übernehme die IDOC-Daten aus Temporärtabelle.
    PERFORM idoc_data_assume TABLES  gt_idoc_data_temp
                             USING   pxt_idoc_data
                                     px_segcnt
                                     seg_local_cnt.

  ENDIF.                               " PE_FEHLERCODE <> 0.

*********************************************************************


ENDFORM.                               " IDOC_DATASET_NART_APPEND


*eject
************************************************************************
FORM nart_change_mode_prepare
     TABLES pit_ot3_nart           STRUCTURE gt_ot3_nart
            pit_filter_segs        STRUCTURE gt_filter_segs
            pit_workdays           STRUCTURE gt_workdays
            pit_artdel             STRUCTURE gt_artdel
            pit_mara_buf           STRUCTURE gt_mara_buf
            pit_marm_buf           STRUCTURE gt_marm_buf
            pit_old_ean_nart       STRUCTURE gt_old_ean_nart
            pxt_master_idocs       STRUCTURE gt_master_idocs
            pit_independence_check STRUCTURE gt_independence_check
            pxt_rfcdest            STRUCTURE gt_rfcdest
            pxt_wdlsp_buf          STRUCTURE gt_wdlsp_buf
            pxt_wdlso_parallel     STRUCTURE gt_wdlso_parallel
            pit_wlk2               STRUCTURE gt_wlk2
     USING  pi_filia_group         STRUCTURE gt_filia_group
            px_independence_check  STRUCTURE gt_independence_check
            px_stat_counter        STRUCTURE gi_stat_counter
            pi_idoctype            LIKE edimsg-idoctyp
            pi_mestype             LIKE edimsg-mestyp
            pi_dldnr               LIKE g_dldnr
            pi_erstdat             LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_parallel            LIKE wpstruc-parallel
            pi_server_group        LIKE wpstruc-servergrp
            px_taskname            LIKE wpstruc-counter6
            px_snd_jobs            LIKE wpstruc-counter6.
************************************************************************
* FUNKTION:
* IDOC-Aufbereitung der Nachzugsartikel.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Aufbereitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT3_NART          : Set-Zuordnungen: Objekttabelle 3.

* PIT_FILTER_SEGS       : Reduzierinformationen.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PIT_ARTDEL            : Tabelle der zu löschenden Artikel

* PIT_MARA_BUF          : MARA-Puffer.

* PIT_MARM_BUF          : MARM-Puffer.

* PIT_OLD_EAN_NART      : Puffer für Haupt-EAN's.

* PXT_MASTER_IDOCS      : Tabelle der kopierfähigen IDOC's

* PIT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_RFCDEST           : Tabelle der fehlerhaften Tasks

* PXT_WDLSP_BUF         : Tabelle der erzeugten Status-Positionszeilen.

* PXT_WDLSO_PARALLEL    : Tabelle der nachzubereitenden fehlerhaften
*                         Objekte.
* PIT_WLK2              : Gesammelte Bewirtschatungszeiträume der
*                         Filiale.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PX_INDEPENDENCE_CHECK : Tabellenkopfzeile der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PX_STAT_COUNTER       : Feldleiste für Statistikinformationen.

* PI_IDOCTYPE           : Name der Original Zwischenstruktur.

* PI_MESTYPE            : Zu verwendender Nachrichtentyp für
*                         Objekt Nachzugsartikel.
* PI_DLDNR              : Downloadnummer

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP4              : Datum: Heute + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erwünscht,
*                                sonst SPCACE.
* PI_SERVER_GROUP       : Name der Server-Gruppe für
*                         Parallelverarbeitung.
* PX_TASKNAME           : Identifiziernder Name des aktuellen Tasks.

* PX_SND_JOBS           : Anzahl der gestarteten parallelen Tasks.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Feldleiste für Statistikinformation.
  DATA: BEGIN OF i_stat_counter.
      INCLUDE STRUCTURE gi_stat_counter.
  DATA: END OF i_stat_counter.


* Falls nicht parallelisiert werden soll.
  IF pi_parallel IS INITIAL.
*   IDOC-Aufbereitung der Nachzugsartikel.
    CALL FUNCTION 'POS_NART_CHG_MODE_PREPARE'
      EXPORTING
        pi_filia_group         = pi_filia_group
        pi_idoctype            = pi_idoctype
        pi_mestype             = pi_mestype
        pi_dldnr               = pi_dldnr
        pi_erstdat             = pi_erstdat
        pi_datp4               = pi_datp4
        pi_mode                = pi_mode
        pi_parallel            = pi_parallel
        pi_independence_check  = px_independence_check
      IMPORTING
        pe_independence_check  = px_independence_check
        pe_stat_counter        = i_stat_counter
      TABLES
        pit_ot3_nart           = pit_ot3_nart
        pit_filter_segs        = pit_filter_segs
        pit_workdays           = pit_workdays
        pit_artdel             = pit_artdel
        pit_master_idocs       = pxt_master_idocs
        pit_independence_check = pit_independence_check
        pit_wlk2               = pit_wlk2.

*   Aktualisiere Statisktikinformation.
    px_stat_counter-nart_ign = i_stat_counter-nart_ign.

* Falls  parallelisiert werden soll.
  ELSE. " not pi_parallel is initial.
*   Setze neuen Tasknamen.
    ADD 1 TO px_taskname.

*   Übernehme Variablen für Wiederaufsetzen im Fehlerfalle in
*   interne Tabelle.
    CLEAR: gt_task_variables.
    gt_task_variables-taskname = px_taskname.
    gt_task_variables-mestype  = pi_mestype.
    APPEND gt_task_variables.

*   IDOC-Aufbereitung der EAN-Referenzen in parallelem Task.
    CALL FUNCTION 'POS_NART_CHG_MODE_PREPARE'
      STARTING NEW TASK px_taskname
      DESTINATION IN GROUP pi_server_group
      PERFORMING return_nart_chg_mode_prepare ON END OF TASK
      EXPORTING
        pi_filia_group         = pi_filia_group
        pi_idoctype            = pi_idoctype
        pi_mestype             = pi_mestype
        pi_dldnr               = pi_dldnr
        pi_erstdat             = pi_erstdat
        pi_datp4               = pi_datp4
        pi_mode                = pi_mode
        pi_parallel            = pi_parallel
        pi_independence_check  = px_independence_check
      TABLES
        pit_ot3_nart           = pit_ot3_nart
        pit_filter_segs        = pit_filter_segs
        pit_workdays           = pit_workdays
        pit_master_idocs       = pxt_master_idocs
        pit_independence_check = pit_independence_check
        pit_artdel             = pit_artdel
        pit_mara_buf           = pit_mara_buf
        pit_marm_buf           = pit_marm_buf
        pit_old_ean_nart       = pit_old_ean_nart
        pit_wlk2               = pit_wlk2
      EXCEPTIONS
        communication_failure  = 1
        system_failure         = 2
        resource_failure       = 3.

*   Falls eine Parallelverarbeitung gerade nicht möglich ist, dann
*   dann arbeite sequentiell.
    IF sy-subrc <> 0.
*     Falls Probleme mit dem Zielsystem auftraten.
      IF sy-subrc <> 3.
        CLEAR: pxt_rfcdest.

*       Aktualisiere Fehlertabelle für Zielsysteme.
        pxt_rfcdest-subrc = sy-subrc.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
          IMPORTING
            rfcdest = pxt_rfcdest-rfcdest.

*       Aktualisiere System-Zeitstempel
        COMMIT WORK.

        pxt_rfcdest-datum    = sy-datum.
        pxt_rfcdest-uzeit    = sy-uzeit.
        pxt_rfcdest-no_start = 'X'.
        pxt_rfcdest-filia    = pi_filia_group-filia.
        APPEND pxt_rfcdest.
      ENDIF. " sy-subrc <> 3.

*     IDOC-Aufbereitung der Nachzugsartikel sequentiell.
      CALL FUNCTION 'POS_NART_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = pi_idoctype
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_parallel            = pi_parallel
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_nart           = pit_ot3_nart
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-nart_ign = i_stat_counter-nart_ign.

*   Falls eine Parallelverarbeitung möglich ist.
    ELSE. " sy-subrc = 0.
*     Bestimme die verwendetet Destination.
      CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        IMPORTING
          rfcdest = gt_rfc_indicator-rfcdest.

*     Merken der gestarteten Destination.
      gt_rfc_indicator-taskname = px_taskname.
      APPEND gt_rfc_indicator.

*     Aktualisiere die Anzahl der parallelen Tasks
      ADD 1 TO px_snd_jobs.
    ENDIF. " sy-subrc <> 0.

  ENDIF. " pi_parallel is initial.


ENDFORM. " nart_change_mode_prepare
