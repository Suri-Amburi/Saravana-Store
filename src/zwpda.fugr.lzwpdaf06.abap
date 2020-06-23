
*-------------------------------------------------------------------
* FORM-Routinen für Download EAN-Referenzen.
************************************************************************


************************************************************************
FORM ean_download
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
            pi_ean          LIKE wpstruc-modus
            pi_debug        LIKE wpstruc-modus.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der EAN-Referenzen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PIT_ARTIKEL    : Liste der zu übertragenden EAN-Referenzen, falls
*                  PI_MODE = 'A' und PI_EAN = 'X'.
* PIT_ART_EQUAL  : Liste der Artikel mit SELECT-OPTION = 'EQUAL',
*                  falls PI_MODE = 'A' und PI_EAN = 'X'.
* PI_FILIA_CONST : Feldleiste mit Filialkonstanten.

* PI_VKORG       : Verkaufsorganisation.

* PI_VTWEG       : Vertriebsweg.

* PI_FILIA       : Filiale, an die verschickt werden soll.

* PI_EXPRESS     := 'X', wenn sofort versendet werden soll, sonst SPACE.

* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                     sollen, sonst SPACE.
* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'A' = direkte
*                     Anforderung, 'R' = Restart.
* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.

* PI_DATUM_BIS   : Ende des Betrachtungszeitraums.

* PI_EAN         : = 'X', wenn EAN-Referenzen übertragen werden sollen
*                  (kann nur bei direkter Anforderung gesetzt sein).
* PI_DEBUG       : = 'X', wenn Status-Positionszeile ständig
*                         aktualisiert werden soll, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: e1wpe01           VALUE 'X', " Flag, ob Segm. E1WPE01 vers. werden muß
        e1wpe02           VALUE 'X',
        ean_lines         TYPE i,
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

  DATA: BEGIN OF t_matnr OCCURS 0.
      INCLUDE STRUCTURE gt_matnr.
  DATA: END OF t_matnr.

  DATA: BEGIN OF t_marm OCCURS 0.
      INCLUDE STRUCTURE gt_marm_buf.
  DATA: END OF t_marm.

  DATA: BEGIN OF t_wrf6 OCCURS 2.
      INCLUDE STRUCTURE wrf6.
  DATA: END OF t_wrf6.

  DATA: lt_articles TYPE pre03_tab.                     " Note 1982796

* Schreibe alle, für den Download EAN-Referenzen benötigten,
* Tabellenfelder in eine interne Tabelle.
  PERFORM ean_fieldtab_fill TABLES gt_field_tab.

* Prüfe, welche Artikelstammsegmente versendet werden müssen
  LOOP AT pit_filter_segs.

    CASE pit_filter_segs-segtyp.
      WHEN c_e1wpe01_name.
        CLEAR: e1wpe01.
      WHEN c_e1wpe02_name.
        CLEAR: e1wpe02.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

* Es müssen EAN-Referenzen versendet werden.
  IF e1wpe01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: g_segment_counter, g_new_position, g_status_pos.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
    IF gv_time_rg_wrkdays_get_flag = abap_false.
      PERFORM time_range_get USING pi_datum_ab          pi_datum_bis
                                 pi_filia_const-vzeit
                                 pi_filia_const-fabkl
                                 g_datab
                                 g_datbis
                                 g_erstdat.

*   Erzeuge Tabelle mit Arbeitstagen, falls nötig.
      PERFORM workdays_get TABLES gt_workdays
                           USING  g_datab  g_datbis
                                  pi_filia_const-fabkl.
    ENDIF.

*   Falls direkte Anforderung oder Restart-Modus, prüfe, ob
*   Artikeltabelle EAN-Daten enhält.
    IF pi_ean <> space.
      CLEAR: ean_lines.
      READ TABLE pit_artikel WITH KEY
           arttyp = c_eantyp
           BINARY SEARCH.

      IF sy-subrc = 0.
        ean_lines = 1.
      ENDIF.                           " SY-SUBRC = 0.
    ENDIF.                             " PI_EAN <> SPACE.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = g_dldnr.
    gi_status_pos-doctyp = c_idoctype_ean.

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
*   (alle Artikel übertragen).
    IF pi_mode = c_init_mode OR ( pi_ean <> space AND ean_lines = 0 ).
*     Besorge alle Artikel, die innerhalb des Betrachtungszeitraums
*     von Filiale PI_FILIA bewirtschaftet werden.
      IF gv_no_articles_found = abap_false.
        PERFORM listed_articles_get TABLES gt_wlk2
                                  USING  pi_vkorg  pi_vtweg
                                         pi_filia  g_datab
                                         g_datbis.
      ENDIF.

*     Schleife über alle gelisteten Artikel
      LOOP AT gt_wlk2.
*       Besorge die MARA-Daten des Artikels.
        PERFORM mara_select USING mara gt_wlk2-matnr.

*       Warengruppe ist immer Pflicht.
        IF mara-matkl = space.
*         Weiter mit nächstem Satz.
          CONTINUE.
        ENDIF. " mara-matkl = space.

*       Falls dieser Artikeltyp nicht in der Kasse gebraucht wird.
        IF ( mara-attyp = c_wrgp_wertartikel       AND
             pi_filia_const-mcat_art IS INITIAL )  OR
             mara-attyp = c_wrgp_hier_wertart      OR
             mara-attyp = c_wrgp_vorlageart.
*         Weiter mit nächstem Satz.
          CONTINUE.
        ENDIF. " ( mara-attyp = c_wrgp_wertartikel and ...

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

*       Besorge die Verkaufsmengeneinheiten des Artikels, die eine
*       EAN besitzen.
        REFRESH: t_matnr.
        APPEND gt_wlk2-matnr TO t_matnr.
        PERFORM marm_select
                TABLES t_matnr
                       t_marm
                USING  'X'                  " pi_with_ean
                       ' '                  " pi_matnr
                       ' '.                 " pi_meinh

*       Erzeuge Listungstabelle.
        PERFORM gt_listung_fill
                TABLES t_marm
                       gt_listung
                USING  gt_wlk2.

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
              i_key-matnr = gt_wlk2-matnr.
              i_key-vrkme = t_vrkme.
              g_firstkey = i_key.
              CLEAR: g_new_firstkey.
            ENDIF.                     " G_NEW_FIRSTKEY <> SPACE.

*           Besorge Artikeldaten und bereite IDOC auf.
            CALL FUNCTION 'MASTERIDOC_CREATE_DLPEAN'
              EXPORTING
                pi_debug           = pi_debug
*###                  pi_ermod           = pi_filia_const-ermod
                pi_dldnr           = g_dldnr
                px_dldlfdnr        = g_dldlfdnr
                pi_filia           = pi_filia
                pi_artnr           = gt_wlk2-matnr
                pi_vrkme           = t_vrkme-vrkme
                pi_datum_ab        = g_datab
                pi_datum_bis       = g_datbis
                pi_express         = pi_express
                pi_loeschen        = pi_loeschen
                pi_mode            = pi_mode
                pi_e1wpe02         = e1wpe02
                px_segment_counter = g_segment_counter
                pi_filia_const     = pi_filia_const
              IMPORTING
                px_segment_counter = g_segment_counter
              TABLES
                pit_listung        = gt_listung
                pit_ot3_ean        = gt_ot3_ean
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
      ENDLOOP. " at gt_wlk2.

*     Falls keine Artikel für diese Filiale gelistet sind.
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
          gi_message-msgty     = c_msgtp_error.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_sehr_wichtig.
*         'In der Filiale &V1& wird kein Material bewirtschaftet'
          gi_message-msgno     = '149'.
          gi_message-msgv1     = pi_filia.

*         Schreibe Fehlerzeile für Application-Log und WDLSO.
          g_object_key = c_whole_idoc.
          PERFORM appl_log_write_single_message  USING gi_message.

        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*       Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
        CLEAR: gi_status_header.
        gi_status_header-dldnr = g_dldnr.
        gi_status_header-gesst = c_status_fehlende_idocs.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM status_write_head USING  'X'       gi_status_header
                                         g_dldnr   g_returncode.

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

*     Falls kein einziger Artikel für diese Filiale gelistet
*     ist oder von der Versendung für diese Filiale ausgeschlossen
*     wurde (über die Zuordnung Filiale <--> Warengruppe),
*     dann Fehlermeldung.
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
          gi_message-msgty     = c_msgtp_error.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_sehr_wichtig.
*         'Kein Material im Intervall & bis & bewirtschaftet
*          oder nicht versendbar'.
          gi_message-msgno     = '123'.
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
      ENDIF.                           " SY-SUBRC <> 0. MARA-Select

*     Erzeuge letztes IDOC, falls nötig .
      IF g_segment_counter > 0.
*       Bestimme 'Lastkey'.
        i_key-matnr = mara-matnr.
        i_key-vrkme = t_vrkme-vrkme.

        PERFORM idoc_create USING  gt_idoc_data
                                   g_mestype_ean
                                   c_idoctype_ean
                                   g_segment_counter
                                   g_err_counter
                                   g_firstkey
                                   i_key
                                   g_dldnr
                                   g_dldlfdnr
                                   pi_filia
                                   pi_filia_const.

      ENDIF.                           " G_SEGMENT_COUNTER > 0.

*   Direkte Anforderung mit vorselektierten Artikeln.
*   oder Restart-Modus.
    ELSEIF pi_ean <> space AND ean_lines > 0.
*     Schleife über alle selektierten Artikel.
* B: New listing check logic => Note 1982796
      IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
         AND gs_twpa-marc_chk IS NOT INITIAL.
        LOOP AT pit_artikel
             WHERE arttyp = c_eantyp.
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
        WHERE arttyp = c_eantyp.
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
          PERFORM ean_delete USING pit_artikel-matnr
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
*         Weiter mit nächstem Satz.
          CONTINUE.
        ENDIF. " mara-matkl = space.

*       Falls dieser Artikeltyp nicht in der Kasse gebraucht wird.
        IF ( mara-attyp = c_wrgp_wertartikel       AND
             pi_filia_const-mcat_art IS INITIAL )  OR
             mara-attyp = c_wrgp_hier_wertart      OR
             mara-attyp = c_wrgp_vorlageart.
*         Weiter mit nächstem Satz.
          CONTINUE.
        ENDIF. " ( mara-attyp = c_wrgp_wertartikel and ...

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
          PERFORM pos_listing_get TABLES gt_wlk2
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
              pi_ignore_excl  = 'X'
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
              g_firstkey = i_key.
              CLEAR: g_new_firstkey.
            ENDIF.                     " G_NEW_FIRSTKEY <> SPACE.

*           Besorge Artikeldaten und bereite IDOC auf.
            CALL FUNCTION 'MASTERIDOC_CREATE_DLPEAN'
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
                pi_e1wpe02         = e1wpe02
                px_segment_counter = g_segment_counter
                pi_filia_const     = pi_filia_const
              IMPORTING
                px_segment_counter = g_segment_counter
              TABLES
                pit_listung        = gt_listung
                pit_ot3_ean        = gt_ot3_ean
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
               arttyp = c_eantyp
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
*             Aufbereiten der Parameter zum Ändern der
*             Status-Kopfzeile.
              CLEAR: gi_status_header.
              gi_status_header-dldnr = g_dldnr.
              gi_status_header-gesst = c_status_fehlende_daten.

*             Korrigiere Status-Kopfzeile auf "Fehlerhaft".
              PERFORM status_write_head
                      USING  'X'  gi_status_header  g_dldnr
                                g_returncode.

*             Atualisiere Aufbereitungsstatus.
              g_status = 3.              " 'Fehlende Daten
            ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

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
            PERFORM status_write_pos USING 'X'        gi_status_pos
                                           g_dldlfdnr g_returncode.

*           Falls Abbruch bei Fehler erwünscht.
            IF pi_filia_const-ermod <> space.
*             Abbruch des Downloads.
              RAISE download_exit.
            ENDIF.                     " PI_FILIA_CONST-ERMOD = SPACE.

          ENDIF.                       " SY-SUBRC <> 0.
        ENDIF.                         " SY-SUBRC = 0.   keine Listung
      ENDLOOP.                         " AT PIT_ARTIKEL.

*     Falls kein einziger Artikel für diese Filiale gelistet
*     ist oder von der Versendung für diese Filiale ausgeschlossen
*     wurde (über die Zuordnung Filiale <--> Warengruppe),
*     dann Fehlermeldung.
      IF no_article_listed <> space AND pi_mode <> c_restart_mode.
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
*         'Kein Material im Intervall & bis & bewirtschaftet
*          oder nicht versendbar'.
          gi_message-msgno     = '123'.
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
                                   g_mestype_ean
                                   c_idoctype_ean
                                   g_segment_counter
                                   g_err_counter
                                   g_firstkey
                                   i_key
                                   g_dldnr
                                   g_dldlfdnr
                                   pi_filia
                                   pi_filia_const.

      ENDIF.                           " G_SEGMENT_COUNTER > 0.
    ENDIF. " PI_MODE = C_INIT_MODE OR ( PI_EAN <> SPACE ...

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
      PERFORM status_write_head USING  'X'  gi_status_header  g_dldnr
                                            g_returncode.
    ENDIF.                             " G_STATUS = 0.
  ENDIF.                               " E1WPE01 <> SPACE.


ENDFORM.                               " EAN_DOWNLOAD


*eject.
************************************************************************
FORM ean_download_change_mode
     TABLES pit_artdel             STRUCTURE gt_artdel
            pit_filter_segs        STRUCTURE gt_filter_segs
            pit_ot3_ean            STRUCTURE gt_ot3_ean
            pit_workdays           STRUCTURE gt_workdays
     USING  pi_filia_group         STRUCTURE gt_filia_group
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_dldnr               LIKE wdls-dldnr
            pi_mestype             LIKE edimsg-mestyp.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der EAN-Referenzen.                             *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_FILTER_SEGS       : Liste aller für den POS-Download nicht
*                         benötigten Segmente.
* PIT_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_DLDNR              : Downloadnummer für Statusverfolgung.

* PI_MESTYPE            : Zu verwendender Nachrichtentyp
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: e1wpe01       VALUE 'X', " Flag, ob Segm. E1WPE01 vers. werden muß
        e1wpe02       VALUE 'X',
        ean_lines     TYPE i,
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

  DATA: BEGIN OF t_ot3_ean_temp OCCURS 0.
      INCLUDE STRUCTURE gt_ot3_ean.
  DATA: END OF t_ot3_ean_temp.

  DATA: BEGIN OF t_wrf6 OCCURS 2.
      INCLUDE STRUCTURE wrf6.
  DATA: END OF t_wrf6.


* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  g_current_doctype = c_idoctype_ean.

* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING pi_filia_group TO i_filia_const.

* Schreibe alle, für den Download EAN-Referenzen benötigten,
* Tabellenfelder in eine interne Tabelle.
  PERFORM ean_fieldtab_fill TABLES gt_field_tab.

* Prüfe, welche Artikelstammsegmente versendet werden müssen.
  LOOP AT pit_filter_segs.

    CASE pit_filter_segs-segtyp.
      WHEN c_e1wpe01_name.
        CLEAR: e1wpe01.
      WHEN c_e1wpe02_name.
        CLEAR: e1wpe02.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

* Es müssen EAN-Referenzen übertragen werden.
  IF e1wpe01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: g_segment_counter, g_new_position, g_status_pos.

*   Rücksetzen Fehler-Zähler.
    CLEAR: g_err_counter, g_firstkey.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-doctyp = c_idoctype_ean.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Bestimme die Anzahl der zu versendenden Artikel.
    DESCRIBE TABLE pit_ot3_ean LINES ean_lines.
    READ TABLE pit_ot3_ean INDEX ean_lines.
    nr_of_groups = pit_ot3_ean-number.

*   Schleife über alle Objekte dieser Filialgruppe.
    CLEAR: number, g_returncode.
    WHILE number < nr_of_groups.
      ADD 1 TO number.

*     Besorge die zur Variablen NUMBER gehörende Artikelnummer.
      READ TABLE pit_ot3_ean WITH KEY
           number = number
           BINARY SEARCH.

*     Merken der Tabellenzeile.
      h_tabix = sy-tabix.

*     Besorge die MARA-Daten des Artikels.
      PERFORM mara_select USING mara pit_ot3_ean-artnr.

*     Warengruppe ist immer Pflicht.
      IF mara-matkl = space.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-ean_ign.

*       Weiter zum nächsten Satz.
        CONTINUE.
      ENDIF. " mara-matkl = space.

*     Falls dieser Artikeltyp nicht in der Kasse gebraucht wird.
      IF ( mara-attyp = c_wrgp_wertartikel   AND
           pi_filia_group-mcat_art IS INITIAL )        OR
           mara-attyp = c_wrgp_hier_wertart  OR
           mara-attyp = c_wrgp_vorlageart.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-ean_ign.

*       Weiter mit nächstem Satz.
        CONTINUE.
      ENDIF. " ( mara-attyp = c_wrgp_wertartikel and ...

*     Extrahiere die Daten zu einem Artikel in temporäre Tabelle
*     und bestimme Grenzwerte für spätere Selektion der Daten.
      REFRESH: t_ot3_ean_temp.
      CLEAR: g_datmin, g_datmax.
      h_fist_record = 'X'.
      LOOP AT pit_ot3_ean  FROM h_tabix.

*       Abbruchbedingungbedingung für Schleife setzen.
        IF pit_ot3_ean-number <> number.
          EXIT.
        ENDIF. " pit_ot3_ean-number <> number.

        IF h_fist_record <> space.
          CLEAR: h_fist_record.
*         Merke Firstkey, falls nötig.
          IF g_new_firstkey <> space.
            i_key-matnr = pit_ot3_ean-artnr.
            i_key-vrkme = pit_ot3_ean-vrkme.
            g_firstkey = i_key.
            CLEAR: g_new_firstkey.
          ENDIF.                       " G_NEW_FIRSTKEY <> SPACE.

          g_datmin   = pit_ot3_ean-datum.
          g_datmax   = pit_ot3_ean-datum.
*         Falls Initialisiert werden soll, müssen die Daten bis zum
*         Ende der Vorlaufzeit selektiert werden.
          IF pit_ot3_ean-init <> space.
            g_datmax = pi_datp4.
          ENDIF.                       " PIT_OT3_EAN-INIT <> SPACE.
        ELSE.                          " SY-INDEX > 1.
          IF pit_ot3_ean-datum < g_datmin.
            g_datmin = pit_ot3_ean-datum.
          ELSEIF pit_ot3_ean-datum > g_datmax.
            g_datmax = pit_ot3_ean-datum.
          ENDIF.                       " PIT_OT3_EAN-DATUM < G_DATMIN.
        ENDIF.                         " H_FIST_RECORD <> SPACE.

*       Falls nötig, erzeuge Löschsatz.
        IF pit_ot3_ean-upd_flag = c_del  OR
           pit_ot3_ean-upd_flag = c_erase.

*         Falls Löschen aufgrund einer Haupt-EAN Änderung.
          IF pit_ot3_ean-upd_flag = c_del.
*** Anmerkung: Hier ist eine Listungsprüfung nicht erwünscht, denn
*   diese Bedingung kann nur durchlaufen werden, wenn die WLK2
*   ausläuft oder eine Auslistung (WLK1 mit Status 5) stattgefunden hat.
*   In beiden Fällen wäre eine Listungsprüfung negativ und würde zu
*   zum ignorieren des Löschsatzes führen, der aber gerade
*   Aufgrund der auslaufenden Listung gesendet werden muß.

*           Besorge alte EAN aus Zusatztabelle PIT_ARTDEL.
            READ TABLE pit_artdel WITH KEY
                       artnr = pit_ot3_ean-artnr
                       vrkme = pit_ot3_ean-vrkme
                       datum = pit_ot3_ean-datum
                       BINARY SEARCH.

*           Falls eine EAN existiert.
            IF sy-subrc = 0.
*             Erzeuge Datensatz zum löschen der alten EAN.
              PERFORM ean_delete USING pit_ot3_ean-artnr
                                       pit_ot3_ean-vrkme
                                       pit_artdel-ean
                                       pit_ot3_ean-datum
                                       pi_filia_group-ermod
                                       pi_filia_group-kunnr
                                       gt_idoc_data
                                       g_returncode
                                       pi_dldnr    g_dldlfdnr
                                       g_segment_counter.
            ENDIF. " sy-subrc = 0.

*         Falls Löschen aufgrund eines Löschens einer zusätzlichen EAN.
          ELSE. " pit_ot3_ean-upd_flag = c_erase.
* **** Anmerkung: Listungprüfung erforderlich, damit nicht Löschsätze
*      an Filialen gesendet werden in denen der Artikel gar nicht
*      gelistet ist.

*           Besorge die Listungen dieser VRKME des Artikels
*           bzgl. dieser Filiale
            PERFORM pos_listing_check
                        TABLES gt_wlk2
                               gt_listung
                        USING  pi_filia_group
                               pit_ot3_ean-artnr
                               pit_ot3_ean-vrkme
                               g_datmin
                               pi_datp4.

*           Prüfe, ob dieser Artikel in dieser Filiale
*           gelistet ist.
            READ TABLE gt_listung INDEX 1.

*           Falls dieser Artikel nicht in dieser Filiale
*           gelistet ist.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF. " sy-subrc <> 0.

*           Bestimme Aufsetzpunkt für Schleife.
            READ TABLE gt_zus_ean_del WITH KEY
                 artnr = pit_ot3_ean-artnr
                 vrkme = pit_ot3_ean-vrkme
                 datum = pit_ot3_ean-datum
                 BINARY SEARCH
                 TRANSPORTING NO FIELDS.

*           Falls zu diesem Änderungsbelegobjekt Werte existieren.
            IF sy-subrc = 0.
              h_tabix = sy-tabix.

*             Besorge alte zusätzliche EAN aus Tabelle GT_ZUS_EAN_DEL.
              LOOP AT gt_zus_ean_del  FROM h_tabix.

*               Abbruchbedingung für Schleife setzen.
                IF gt_zus_ean_del-artnr <> pit_ot3_ean-artnr  OR
                   gt_zus_ean_del-vrkme <> pit_ot3_ean-vrkme  OR
                   gt_zus_ean_del-datum <> pit_ot3_ean-datum.
                  EXIT.
                ENDIF.

*               Erzeuge Datensatz zum löschen der alten EAN.
                PERFORM ean_delete USING pit_ot3_ean-artnr
                                         pit_ot3_ean-vrkme
                                         gt_zus_ean_del-ean
                                         pit_ot3_ean-datum
                                         pi_filia_group-ermod
                                         pi_filia_group-kunnr
                                         gt_idoc_data
                                         g_returncode
                                         pi_dldnr    g_dldlfdnr
                                         g_segment_counter.
              ENDLOOP. " at gt_zus_ean_del
            ENDIF. " sy-subrc = 0.
          ENDIF. " pit_ot3_ean-upd_flag = c_del or ...

*       Kein Löschsatz nötig.
        ELSE.
*         Übernehme Datensatz in Temporärtabelle.
          APPEND pit_ot3_ean TO t_ot3_ean_temp.
        ENDIF.              " PIT_OT3_EAN-UPD_FLAG = C_DEL or ...
      ENDLOOP.                         " AT PIT_OT3_EAN.

*     Prüfe, ob Einträge in PIT_OT3_SETS_TEMP vorhanden sind.
      READ TABLE t_ot3_ean_temp INDEX 1.

*     Falls keine Einträge in PIT_OT3_EAN_TEMP vorhanden sind,
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
        ADD 1 TO gi_stat_counter-ean_ign.

*       Weiter zum nächsten Satz.
        CONTINUE.
      ENDIF. " sy-subrc = 0 and t_wrf6-wdaus <> space.

*     Besorge die Listungen dieser VRKME des Artikels
*     bzgl. dieser Filiale
      PERFORM pos_listing_check
                  TABLES gt_wlk2
                         gt_listung
                  USING  pi_filia_group
                         t_ot3_ean_temp-artnr
                         t_ot3_ean_temp-vrkme
                         g_datmin
                         pi_datp4.

*     Besorge die Listungen dieser VRKME des Artikels
*     bzgl. dieser Filiale
*     call function 'LISTING_CHECK'
*          exporting
*               pi_article      = t_ot3_ean_temp-artnr
*               pi_vrkme        = t_ot3_ean_temp-vrkme
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
        CALL FUNCTION 'MASTERIDOC_CREATE_DLPEAN'
          EXPORTING
            pi_debug           = ' '
*###              pi_ermod           = pi_filia_group-ermod
            pi_dldnr           = pi_dldnr
            px_dldlfdnr        = g_dldlfdnr
            pi_filia           = pi_filia_group-filia
            pi_artnr           = t_ot3_ean_temp-artnr
            pi_vrkme           = t_ot3_ean_temp-vrkme
            pi_datbi_list      = pi_datp4
            pi_datum_ab        = g_datmin
            pi_datum_bis       = g_datmax
            pi_express         = ' '
            pi_loeschen        = ' '
            pi_mode            = pi_mode
            pi_e1wpe02         = e1wpe02
            px_segment_counter = g_segment_counter
            pi_filia_const     = i_filia_const
          IMPORTING
            px_segment_counter = g_segment_counter
          TABLES
            pit_listung        = gt_listung
            pit_ot3_ean        = t_ot3_ean_temp
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
        ADD 1 TO gi_stat_counter-ean_ign.
      ENDIF.                           " SY-SUBRC = 0.
    ENDWHILE.                          " NUMBER < NR_OF_GROUPS.

*   Erzeuge letztes IDOC, falls nötig.
    IF g_segment_counter > 0.
*     Bestimme 'Lastkey'.
      i_key-matnr = t_ot3_ean_temp-artnr.
      i_key-vrkme = t_ot3_ean_temp-vrkme.

      PERFORM idoc_create USING  gt_idoc_data
                                 pi_mestype
                                 c_idoctype_ean
                                 g_segment_counter
                                 g_err_counter
                                 g_firstkey
                                 i_key
                                 pi_dldnr    g_dldlfdnr
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
  ENDIF.                               " E1WPE01 <> SPACE.


ENDFORM. " ean_download_change_mode


*eject.
************************************************************************
FORM ean_fieldtab_fill TABLES pet_field_tab STRUCTURE gt_field_tab.
************************************************************************
* FUNKTION:
* Schreibe alle, für den Download EAN-Referenzen benötigten,
* Tabellenfelder in eine interne Tabelle. Diese Tabelle wird für den
* Aufruf des Funktionsbausteins MATERIAL_HISTORY_READ benötigt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_FIELD_TAB: Tabelle, die mit den Feldnamen gefüllt wird.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

  REFRESH: pet_field_tab.

  pet_field_tab-tname = 'MARA'.
  pet_field_tab-fname = 'EAN11'.
  APPEND pet_field_tab.

  pet_field_tab-tname = 'MARM'.
  pet_field_tab-fname = 'EAN11'.
  APPEND pet_field_tab.

  pet_field_tab-tname = 'MEAN'.
  pet_field_tab-fname = 'EAN11'.
  APPEND pet_field_tab.

ENDFORM.                               " EAN_FIELDTAB_FILL


*eject
************************************************************************
FORM eandata_get_and_analyse
     TABLES pet_imarm     STRUCTURE gt_imarm
            pet_imean     STRUCTURE gt_imean
            pit_field_tab STRUCTURE gt_field_tab
            pxt_orgtab    STRUCTURE gt_orgtab_ean
            pit_listung   STRUCTURE gt_listung
            pit_ot3       STRUCTURE gt_ot3_ean
     USING  pi_artnr      LIKE wlk1-artnr
            pi_vrkme      LIKE wlk1-vrkme
            pi_datab      LIKE syst-datum
            pi_datbi      LIKE syst-datum
            pi_mode       LIKE wpstruc-modus
   CHANGING VALUE(pe_fehlercode) LIKE syst-subrc
            pi_dldnr      LIKE wdls-dldnr
            pi_dldlfdnr   LIKE wdlsp-lfdnr
            pi_ermod      LIKE twpfi-ermod
            pi_segment_counter LIKE g_segment_counter
            pi_initdat    LIKE syst-datum
            pe_ean        LIKE marm-ean11
            pi_loeschen   LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Lese die Daten für Download EAN-Referenzen im Zeitintervall
* PI_DATAB - PI_DATBI, analysiere diese und fülle Organisationstabelle.
* Im Änderungs- oder Restart-Fall werden auch die Tabellen
* PIT_LISTUNG und PIT_OT3 analysiert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_IMARM    : Tabelle für MARM-Daten.

* PET_IMEAN    : Tabelle für MEAN-Daten.

* PIT_FIELD_TAB: POS-relevante Felder der Materialstammtabellen.

* PXT_ORGTAB   : Organisationstabelle für EAN-Referenzen

* PIT_LISTUNG  : Listungen des Artikels.

* PIT_OT3      : EAN-Referenzen: Objekttabelle 3.

* PI_ARTNR     : Material der Selektion.

* PI_VRKME     : Verkaufsmengeneinheit der Selektion.

* PI_DATAB     : Beginndatum der Selektion.

* PI_DATBI     : Endedatum der Selektion.

* PI_MODE      : Download-Modus.

* PE_FEHLERCODE: > 0, wenn Datenbeschaffung mißlungen, sonst '0'.

* PI_DLDNR     : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.

* PI_ERMOD     : = 'X', wenn Downloadabbruch bei Fehler erwünscht.

* PI_SEGMENT_COUNTER: Segmentzähler.

* PI_INITDAT  : Datum, ab wann initialisiert werden soll. Ist nur
*               für Änderungs- und Restart-Fall relevant.
* PE_EAN      : Haupt-EAN der jeweiligen Verkaufsmengeneinheit des
*               Artikels.
* PI_LOESCHEN : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                      sollen, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: readindex            TYPE i,
        h_datum              LIKE sy-datum,
        h_counter            TYPE i,
        fehlercode           LIKE sy-subrc,
        h_versenden,
        h_found1             LIKE wpmara-chgflag,
        h_found2             LIKE wpmara-chgflag,
        no_record_found_marm,
        no_record_found_mean,
        h_mean_read.


  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Zur Bestimmung der ersten zu merkenden EAN für Änderungsfall.
  DATA: BEGIN OF t_marm OCCURS 1.
      INCLUDE STRUCTURE wpmarm.
  DATA: END OF t_marm.

* Zum zählen von EAN-Referenzen.
  DATA: BEGIN OF t_mean OCCURS 1.
      INCLUDE STRUCTURE wpmean.
  DATA: END OF t_mean.

* Initialisieren der Merker.
  CLEAR:   pxt_orgtab, pe_fehlercode, g_last_ean_number.

* Merken des aktuellen Schlüssels.
  i_key-matnr = pi_artnr.
  i_key-vrkme = pi_vrkme.

  PERFORM ean_matdata_get
              TABLES   pet_imarm
                       pet_imean
                       pit_field_tab
              USING    pi_artnr    pi_vrkme
                       pi_datab    pi_datbi    pi_mode
                       no_record_found_marm    no_record_found_mean
              CHANGING fehlercode.

* Falls Fehler auftraten.
  IF fehlercode <> 0 OR no_record_found_marm <> space OR
     no_record_found_mean <> space.
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

      IF fehlercode = 1.
*       'Material & nicht im Materialstamm gepflegt'.
        gi_message-msgno     = '119'.
        gi_message-msgv1     = pi_artnr.
      ELSEIF no_record_found_marm <> space.
*       'Die Verk.ME & zum Material & ist nicht im Materialstamm
*       gepflegt'.
        gi_message-msgno     = '120'.
        gi_message-msgv1     = pi_vrkme.
        gi_message-msgv2     = pi_artnr.
      ELSEIF no_record_found_mean <> space.
*       'Keine EAN-Referenzen zum Material & für Verk.einh. &
*        gepflegt'.
        gi_message-msgno     = '133'.
        gi_message-msgv1     = pi_artnr.
        gi_message-msgv2     = pi_vrkme.
      ENDIF.                           " NO_RECORD_FOUND_MARM <> SPACE.

*     Setze Fehlercode auf fehlerhaft.
      pe_fehlercode = 1.

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
  ENDIF.   " fehlercode <> 0 or no_record_found_marm <> space or


* Analysiere Daten und ergänze Org.Tabelle.

* Falls Änderungsfall.
  IF pi_mode = c_change_mode.
*   Übernehme Versendezeitpunkte aus Tabelle PIT_OT3, falls nötig.
    LOOP AT pit_ot3
      WHERE init = space.
      readindex = pit_ot3-datum - pi_datab + 1.
      READ TABLE pxt_orgtab INDEX readindex.
      pxt_orgtab-change = 'X'.
      MODIFY pxt_orgtab INDEX readindex.
    ENDLOOP.                           " AT PIT_OT3.

*   Übernehme Versendezeitpunkte aus Listungstabelle, falls nötig.
    IF pi_initdat <> space.
      LOOP AT pit_listung
           WHERE vrkme = pi_vrkme.
        IF pi_initdat <= pit_listung-datab.
          readindex = pit_listung-datab - pi_datab + 1.
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
  ENDIF. " pi_mode = c_change_mode.

* Analysieren Daten aus MARM.
  LOOP AT pet_imarm.
*   Das Datum für den ersten Satz darf nicht initial sein.
    IF pet_imarm-datum < pi_datab.
      pet_imarm-datum = pi_datab.
      MODIFY pet_imarm.
    ENDIF.                           " pet_imarm-datum < pi_datab.

*   Sonderbehandlung für den Tag der ersten Änderung.
    IF sy-tabix = 1.
*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Prüfe, ob PX_EAN bereits gemerkt wurde.
        READ TABLE gt_old_ean WITH KEY
                   artnr = pet_imarm-matnr
                   vrkme = pet_imarm-meinh
                   datum = pet_imarm-datum
                   ean11 = pet_imarm-ean11 " OSS note 603808
                   BINARY SEARCH.

        IF sy-subrc = 0.
          pe_ean = gt_old_ean-ean11.

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
            PERFORM ean_matdata_get
                        TABLES   t_marm
                                 t_mean
                                 pit_field_tab
                        USING    pi_artnr    pi_vrkme
                                 h_datum     h_datum     pi_mode
                                 h_found1    h_found2
                        CHANGING fehlercode.

*           Merken, daß Tabelle t_mean bereits gelesen wurde.
            h_mean_read = 'X'.

            READ TABLE t_marm INDEX 1.
            pe_ean = t_marm-ean11.

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
      ENDIF. " pi_mode = c_change_mode.

*     Vermerke in Org.Tabelle das Lesen des ersten Satzes.
      READ TABLE pxt_orgtab INDEX 1.
      pxt_orgtab-marm  = 'X'.

*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
        IF pi_initdat <> space AND pi_initdat <= pet_imarm-datum AND
           pet_imarm-chgflag <> space.
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
        readindex = pet_imarm-datum - pi_datab + 1.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-marm  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_imarm-datum.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMARM-DATUM
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

* Analysieren Daten aus MEAN.
  CLEAR: h_datum, h_counter.
  LOOP AT pet_imean.
*   Das Datum für den ersten Satz darf nicht initial sein.
    IF pet_imean-datum < pi_datab.
      pet_imean-datum = pi_datab.
      MODIFY pet_imean.
    ENDIF.                             " pet_imean-datum < pi_datab.

*   Vermerke in Org.Tabelle das Lesen des ersten Satzes.
    IF sy-tabix = 1.
      READ TABLE pxt_orgtab INDEX 1.
      pxt_orgtab-mean   = 'X'.

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

*     Merken des 1. Versendedatums in Hilfsvariable.
      h_datum = pet_imean-datum.
    ENDIF.                             " SY-TABIX = 1.

    IF pet_imean-datum = h_datum.
*     Aktualisiere EAN-Zähler, falls nötig.
      IF pet_imean-ean11 <> space.
        ADD 1 TO h_counter.
      ENDIF.                           " pet_imean-ean11 <> space.
    ELSE.                              " PET_IMEAN-DATUM <> H_DATUM.
*     Aktualisiere EAN-Zähler in Org.Tabelle.
      readindex = h_datum - pi_datab + 1.
      READ TABLE pxt_orgtab INDEX readindex.
      pxt_orgtab-mean_cnt = h_counter.
      MODIFY pxt_orgtab INDEX readindex.

*     Falls Löschmodus aktiv, dann weitere Aufbereitung nicht nötig.
      IF pi_loeschen <> space.
        EXIT.
      ENDIF. " pi_loeschen <> space.

*     Jede Ändererung in Tabelle MEAN ist eine POS-relevante Änderung
*     und muß daher in der Org.Tabelle vermerkt werden.
      readindex = pet_imean-datum - pi_datab + 1.
      READ TABLE pxt_orgtab INDEX readindex.
      pxt_orgtab-mean  = 'X'.

*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
        IF pi_initdat <> space AND pi_initdat <= pet_imean-datum.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMEAN-DATUM.
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      ELSE.
*       Falls eine POS-relevante Änderung gefunden wurde, so wird
*       dies in der Org.Tabelle vermerkt.
        pxt_orgtab-change = 'X'.
      ENDIF. " PI_MODE = C_CHANGE_MODE

      MODIFY pxt_orgtab INDEX readindex.

*     Rücksetze H_DATUM.
      h_datum = pet_imean-datum.

*     Aktualisiere EAN-Zähler.
      IF pet_imean-ean11 <> space.
*       Rücksetze EAN-Zähler.
        h_counter = 1.
      ELSE.                            " pet_imean-ean11 = space.
*       Rücksetze EAN-Zähler.
        CLEAR: h_counter.
      ENDIF.                           " pet_imean-ean11 <> space.
    ENDIF.                             " PET_IMEAN-DATUM = H_DATUM.
  ENDLOOP.                             " AT PET_IMEAN.

* Aktualisiere EAN-Zähler in Org.Tabelle.
  readindex = h_datum - pi_datab + 1.
  READ TABLE pxt_orgtab INDEX readindex.
  pxt_orgtab-mean_cnt = h_counter.
  MODIFY pxt_orgtab INDEX readindex.

* Falls Änderungsfall.
  IF pi_mode = c_change_mode.
*   Bestimme die Anzahl der zuletzt versendeten EAN's, falls nötig.
    IF pe_ean <> space.
      READ TABLE pet_imarm  INDEX 1.
      READ TABLE pxt_orgtab INDEX 1.

*     Prüfe, ob die Anzahl der EAN's bis einschließlich SY-DATUM
*     verändert wurde.
      READ TABLE gt_ean_change WITH KEY
                 artnr = pet_imarm-matnr
                 vrkme = pet_imarm-meinh
                 BINARY SEARCH.

*     Falls die EAN-Anzahl bis SY-DATUM verändert wurde.
      IF sy-subrc = 0.
*       Berechne die Anzahl der zuletzt verarbeiteten EAN's.
        g_last_ean_number = pxt_orgtab-mean_cnt -
                            gt_ean_change-change.

*     Bis SY-DATUM wurden keine EAN's verändert d. h., wenn eine
*     EAN-Änderung stattfinden soll, dann kann dies nur in der Zukunft
*     passieren, denn sonst wäre ein Eintrag vorhanden (siehe
*     EAN-Analyse für Änderungsfall, MEAN-Änderungen).
*     Daher bestimme die Anzahl der EAN's vom Vortag der ersten
*     Änderung.
      ELSE.                          " if sy-subrc <> 0.
        h_datum = pet_imarm-datum - 1.

*       Falls eine zukünftige EAN-Änderung stattfinden kann.
        IF h_datum >= sy-datum.
*         Falls MEAN-Daten nachgelesen werden müssen.
          IF h_mean_read = space.
*           Lese zukünftige EAN vom Vortag der ersten Änderung.
            PERFORM ean_matdata_get
                        TABLES   t_marm
                                 t_mean
                                 pit_field_tab
                        USING    pi_artnr    pi_vrkme
                                 h_datum     h_datum     pi_mode
                                 h_found1    h_found2
                        CHANGING fehlercode.
          ENDIF. " h_mean_read = space.

*         Bestimme die Anzahl der zuletzt verarbeiteten EAN's.
          DESCRIBE TABLE t_mean LINES g_last_ean_number.

*       Es soll zum Tag der ersten Änderung keine EAN-Änderung
*       stattfinden, d. h. die Anzahl der EAN's hat sich nicht
*       verändert.
        ELSE.                        " h_datum < sy-datum.
*         Übernehme die Anzahl der zuletzt verarbeiteten EAN's.
*         aus ORGTAB.
          g_last_ean_number = pxt_orgtab-mean_cnt.
        ENDIF.                       " h_datum >= sy-datum.
      ENDIF.                         " sy-subrc = 0.
    ENDIF. " pe_ean <> space.
  ENDIF. " pi_mode = c_change_mode

* Prüfe die jeweilige Anzahl der gefundenen EAN's und korrigiere
* eventuell Org.Tabelle.
  h_counter = 1.
  CLEAR: h_versenden.
  LOOP AT pxt_orgtab.
*   Falls eine Änderung in Tabelle MEAN erfolgt ist.
    IF pxt_orgtab-mean <> space.
*     Prüfe, ob mehr als eine EAN für dieses Datum vorhanden ist.
      IF pxt_orgtab-mean_cnt > h_counter.
        h_counter = pxt_orgtab-mean_cnt.
      ENDIF. " PXT_ORGTAB-MEAN_CNT > H_COUNTER.

*     Falls bei früheren Datümern bisher nur jeweils eine
*     EAN vorhanden war.
      IF h_counter = 1.
*       Falls keine Änderung der Haupt-EAN erfolgt ist, so braucht
*       kein Satz für dieses Datum aufbereitet zu werden.
        IF pxt_orgtab-marm = space.
          CLEAR: pxt_orgtab-change.
          MODIFY pxt_orgtab.
        ENDIF.                         " PXT_ORGTAB-MARM = SPACE.
      ENDIF.                           " H_COUNTER = 1.
    ENDIF.                             " PXT_ORGTAB-MEAN <> SPACE.

*   Falls wenigstens einmal versendet werden soll, so wird dies
*   durch die Hilfsvariable H_VERSENDEN gemerkt.
    IF h_counter > 1.
      h_versenden = 'X'.
    ENDIF.                             " H_COUNTER > 1

    pxt_orgtab-versenden = h_versenden.
    MODIFY pxt_orgtab.
  ENDLOOP.                             " AT PXT_ORGTAB

* Falls Initialisierungsfall, direkte Anforderung oder Restart.
  IF pi_mode <> c_change_mode.
*   Falls nur jeweils eine EAN vorhanden ist, so braucht für diesen
*   Artikel und diese Verkaufsmengeneinheit überhaupt keine
*   Aufbereitung stattzufinden.
    IF h_counter = 1.
      pe_fehlercode = 1.
    ENDIF.                               " H_COUNTER = 1.
  ENDIF. " pi_mode <> c_change_mode


ENDFORM.                               " EANDATA_GET_AND_ANALYSE


*eject.
************************************************************************
FORM idoc_dataset_ean_append
     TABLES pit_imarm      STRUCTURE gt_imarm
            pit_imean      STRUCTURE gt_imean
            pit_orgtab     STRUCTURE gt_orgtab_ean
     USING  pxt_idoc_data  TYPE short_edidd
            pi_datum       LIKE syst-datum
            px_segcnt      LIKE g_segment_counter
            pi_loeschen    LIKE wpstruc-modus
            pi_e1wpe02     LIKE wpstruc-modus
            pi_filia       LIKE t001w-werks
            pe_fehlercode  LIKE syst-subrc
            pi_dldnr       LIKE wdls-dldnr
            pi_dldlfdnr    LIKE wdlsp-lfdnr
            pi_filia_const LIKE wpfilconst
            px_ean         LIKE marm-ean11
            pi_mode        LIKE wpstruc-modus
            pi_datab_slct  LIKE syst-datum
            pi_vzeit_temp  LIKE syst-index.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_IMARM    : Tabelle mit MARM-Daten.

* PIT_IMEAN    : Tabelle mit MEAN-Daten.

* PIT_ORGTAB   : Organisationstabelle für Artikelstamm.

* PXT_IDOC_DATA: IDOC-Daten der Struktur EDIDD (Tabelle an die die
*                IDOC-Sätze angefügt werden).
* PI_DATUM     : Datum für das die Daten aufbereitet werden sollen.

* PX_SEGCNT    : Segment-Zähler.

* PI_LOESCHEN  : = 'X', wenn Löschmodus aktiv.

* PI_E1WPE02   : = 'X', wenn Segment E1WPE02 aufbereitet werden soll.

* PI_FILIA     : Filiale, an die versendet werden soll.

* PE_FEHLERCODE: > 0, wenn Fehler beim Umsetzen der Daten.

* PI_DLDNR     : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.

* PI_FILIA_CONST : Filialkonstanten.

* PX_EAN       : Haupt-EAN zur Verkaufsmengeneinheit des Artikels.

* PI_MODE      : Download-Modus.

* PI_DATAB_SLCT: Beginn der Listung innerhalb des Betrachtungszeitraums

* PI_VZEIT_TEMP: Daraus resultierende Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: lese_datum    LIKE sy-datum,
        lese_datum2   LIKE sy-datum,
        h_datum       LIKE sy-datum,
        e1wpe02_cnt   TYPE i,
        h_versenden   VALUE 'X',
        readindex     LIKE sy-tabix,
        seg_local_cnt TYPE i,
        h_returncode  LIKE sy-subrc,
        h_numtp       LIKE marm-numtp.

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


* Rücksetze Returncode.
  CLEAR: pe_fehlercode, e1wpe02_cnt.

* Besorge für PI_DATUM das Zugriffsdatum auf die zugehörigen MARM-Daten.
  CLEAR: lese_datum.
  LOOP AT pit_orgtab
    WHERE datum <= pi_datum
    AND   marm  <> space.
*   Merke des Datum für Zugriff auf MARM-Daten.
    lese_datum = pit_orgtab-datum.
    EXIT.
  ENDLOOP.                             " AT PIT_ORGTAB

* Besorge für PI_DATUM das Zugriffsdatum auf die
* zugehörigen MEAN-Daten.
  CLEAR: lese_datum2.
  LOOP AT pit_orgtab
    WHERE datum <= pi_datum
    AND   mean  <> space.
*   Merke des Datum für Zugriff auf MEAN-Daten.
    lese_datum2 = pit_orgtab-datum.
    EXIT.
  ENDLOOP.                             " AT PIT_ORGTAB

* Besorge die zugehörigen MARM-Daten. Die Daten stehen in der
* Kopfzeile von PIT_IMARM.
  LOOP AT pit_imarm
    WHERE datum = lese_datum.
    EXIT.
  ENDLOOP.                             " AT PIT_IMARM

* Setze Objektschlüssel.
  i_key-matnr = pit_imarm-matnr.
  i_key-vrkme = pit_imarm-meinh.

* Falls Änderungsfall.
  IF pi_mode = c_change_mode.
*   Falls es sich um das erste Änderungsdatum handelt.
    IF pi_datum = pi_datab_slct.
*     Falls beim letzten Mal EAN-Rererenzen versendet wurden.
      IF g_last_ean_number > 1.
*       Bestimme die Anzahl der EAN'S für dieses Datum.
        readindex = lese_datum2 - pi_datab_slct.
        readindex = pi_vzeit_temp - readindex.
        READ TABLE pit_orgtab INDEX readindex.

*       Falls sich die Haupt-EAN verändert hat, muß der
*       Satz mit der alten Haupt-EAN gelöscht werden.
        IF pit_imarm-ean11 <> px_ean OR pit_orgtab-mean_cnt <= 1.
*         Der neue Satz darf nur aufbereitet werden, wenn mehr als
*         eine EAN für dieses Datum vorhanden ist.
          IF pit_orgtab-mean_cnt <= 1.
*           Der neu Satz darf nicht aufbereitet werden.
            CLEAR: h_versenden.

*           Merken des zuletzt nicht aufbereiteten Satzes.
            g_last_record = readindex.
          ENDIF. " pit_orgtab-mean_cnt <= 1

*         Rücksetze Temporärtabelle für IDOC-Daten.
          REFRESH: gt_idoc_data_temp.

*         Rücksetze lokalen Segmentzähler.
          CLEAR: seg_local_cnt.

*         Aufbereitung ID-Segment zum löschen.
          CLEAR: e1wpe01.
          e1wpe01-filiale    = pi_filia_const-kunnr.
          e1wpe01-aendkennz  = c_delete.
          e1wpe01-aktivdatum = pi_datum.
          e1wpe01-aenddatum  = '00000000'.
          e1wpe01-aenderer   = ' '.
*          e1wpe01-artikelnr_long  = pit_imarm-matnr.
          cl_matnr_chk_mapper=>convert_on_output(
            EXPORTING
              iv_matnr40                   =     pit_imarm-matnr
            IMPORTING
              ev_matnr18                   =     e1wpe01-artikelnr
              ev_matnr40                   =     e1wpe01-artikelnr_long
            EXCEPTIONS
              excp_matnr_invalid_input     = 1
              excp_matnr_not_found         = 2
              OTHERS                       = 3 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          e1wpe01-posme      = pit_imarm-meinh.

*         Besorge EAN-Typ.
*         Prüfe zunächst, ob es sich um eine alte EAN handelt.
          LOOP AT gt_old_ean
               WHERE artnr = pit_imarm-matnr
               AND   vrkme = pit_imarm-meinh
               AND   ean11 = px_ean.
            EXIT.
          ENDLOOP. " at gt_old_ean

*        Falls es sich um eine alte EAN handelt und sich der EAN-Typ
*        geändert hat.
          IF sy-subrc = 0 AND NOT gt_old_ean-numtp IS INITIAL.
            h_numtp = gt_old_ean-numtp.

*        Falls es sich nicht um eine alte EAN handelt oder der EAN-Typ
*        unverändert geblieben ist.
          ELSE. " sy-subrc <> 0 ...
            h_numtp = pit_imarm-numtp.

          ENDIF. " sy-subrc = 0.

*         Ausgabekonvertierung für EAN.
          CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
            EXPORTING
              input   = px_ean
              ean_typ = h_numtp
            IMPORTING
              output  = e1wpe01-hauptean.

*         Erzeuge temporären IDOC-Segmentsatz.
          gt_idoc_data_temp-segnam = c_e1wpe01_name.
          gt_idoc_data_temp-sdata  = e1wpe01.
          APPEND gt_idoc_data_temp.

*         aktualisiere Segmentzähler und Haupt-EAN.
          ADD 1 TO seg_local_cnt.
          px_ean = pit_imarm-ean11.

*********************************************************************
***********************   U S E R - E X I T  ************************
          CALL CUSTOMER-FUNCTION '003'
            EXPORTING
              pi_e1wpe02_cnt     = e1wpe02_cnt
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

*         Falls Umsetzfehler auftraten.
          IF pe_fehlercode <> 0.
*           Falls Fehlerprotokollierung erwünscht.
            IF pi_filia_const-ermod = space.
*             Falls der Satz zum heutigen Datum gelöscht werden soll.
              IF pi_datum <= sy-datum.
*               Fülle allgemeinen Objektschlüssel.
                CLEAR: gi_object_key.
                gi_object_key-matnr = pit_imarm-matnr.
                gi_object_key-vrkme = pit_imarm-meinh.
                gi_object_key-ean11 = px_ean.
                g_object_key        = gi_object_key.
                g_object_delete     = 'X'.

*               Ergänze Fehlerobjekttabelle um einen zusätzlichen
*               Eintrag.
                PERFORM error_object_write.

*               Rücksetze Löschkennzeichen für Fehlerobjekttabelle
*               WDLSO.
                CLEAR: g_object_delete.
              ENDIF. " pi_datum <= sy-datum.

*             Verlassen der Aufbereitung dieser Basiswarengruppe.
              EXIT.
*           Falls Abbruch bei Fehler erwünscht.
            ELSE.                        " PI_ERMOD <> SPACE.
*             Abbruch des Downloads.
              RAISE download_exit.
            ENDIF.                       " PI_FILIA_CONST-ERMOD = SPACE.

*         Falls Umschlüsselung fehlerfrei.
          ELSE.                          " PE_FEHLERCODE = 0.
*           Übernehme die IDOC-Daten aus Temporärtabelle.
            PERFORM idoc_data_assume TABLES  gt_idoc_data_temp
                                     USING   pxt_idoc_data
                                             px_segcnt
                                             seg_local_cnt.

          ENDIF.                         " PE_FEHLERCODE <> 0.
************************************************************************

        ENDIF.  " pit_imarm-ean11 <> px_ean or pit_orgtab-mean_cnt <= 1.
*     Falls beim letzten Mal keine EAN-Rererenzen versendet wurden.
      ELSE. " g_last_ean_number <= 1.
*       Stelle sicher, daß kein Löschsatz aufbereitet wird.
        px_ean = pit_imarm-ean11.
      ENDIF. " g_last_ean_number > 1.
    ENDIF.                               " pi_datum = pi_datab_slct.
  ENDIF. " pi_mode = c_change_mode.

* Falls sich die Haupt-EAN verändert hat, muß der
* Satz mit der alten Haupt-EAN gelöscht werden.
  IF pit_imarm-ean11 <> px_ean.
*   Falls eine Haupt-EAN erst gelöscht und dann wieder eingefügt
*   wurde, so muß kein Lösch-Satz für die gelöschte
*   Haupt-EAN aufbereitet werden.
    IF px_ean <> space.

*     Prüfe ob schon vorher ein Satz aufbereitet wurde.
      h_datum = pi_datum - 1.
      readindex = h_datum - pi_datab_slct.
      readindex = pi_vzeit_temp - readindex.
      READ TABLE pit_orgtab INDEX readindex.

*     Falls schon vorher ein Satz aufbereitet wurde.
      IF pit_orgtab-versenden <> space.
*       Prüfe, ob der zu löschende Satz auch vorher aufbereitet
*       wurde.
        READ TABLE pit_orgtab INDEX g_last_record.

*       Falls durch den Beginn einer Listung zusätzliche Sätze
*       aufbereitet wurden, kann G_LAST_RECORD den falschen
*       Wert haben. Daher bestimme die zuletzt betrachtete Anzahl
*       von EAN's.
        IF pit_orgtab-mean_cnt = 0.
          h_datum = pit_orgtab-datum.
          LOOP AT pit_orgtab
               WHERE datum    < h_datum
               AND   mean_cnt > 0.
            EXIT.
          ENDLOOP.                     " at pit_orgtab
        ENDIF.                         " pit_orgtab-mean_cnt = 0.

*       Falls der zu löschende Satz auch vorher aufbereitet wurde.
        IF pit_orgtab-mean_cnt > 1.
*         Der neue Satz darf nur aufbereitet werden, wenn mehr als
*         eine EAN für dieses Datum vorhanden ist.
          readindex = lese_datum2 - pi_datab_slct.
          readindex = pi_vzeit_temp - readindex.
          READ TABLE pit_orgtab INDEX readindex.
          IF pit_orgtab-mean_cnt <= 1.
*           Der neu Satz darf nicht aufbereitet werden.
            CLEAR: h_versenden.

*           Merken des zuletzt nicht aufbereiteten Satzes.
            g_last_record = readindex.
          ENDIF.                       " PIT_ORGTAB-MEAN_CNT <= 1.

*         Rücksetze Temporärtabelle für IDOC-Daten.
          REFRESH: gt_idoc_data_temp.

*         Rücksetze lokalen Segmentzähler.
          CLEAR: seg_local_cnt.

*         Aufbereitung ID-Segment zum löschen.
          CLEAR: e1wpe01.
          e1wpe01-filiale    = pi_filia_const-kunnr.
          e1wpe01-aendkennz  = c_delete.
          e1wpe01-aktivdatum = pi_datum.
          e1wpe01-aenddatum  = '00000000'.
          e1wpe01-aenderer   = ' '.
*          e1wpe01-artikelnr_long  = pit_imarm-matnr.
          cl_matnr_chk_mapper=>convert_on_output(
           EXPORTING
             iv_matnr40                   =     pit_imarm-matnr
           IMPORTING
             ev_matnr18                   =     e1wpe01-artikelnr
             ev_matnr40                   =     e1wpe01-artikelnr_long
           EXCEPTIONS
             excp_matnr_invalid_input     = 1
             excp_matnr_not_found         = 2
             OTHERS                       = 3 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          e1wpe01-posme      = pit_imarm-meinh.

*         Ausgabekonvertierung für EAN.
          CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
            EXPORTING
              input   = px_ean
              ean_typ = pit_imarm-numtp
            IMPORTING
              output  = e1wpe01-hauptean.

*         Erzeuge temporären IDOC-Segmentsatz.
          gt_idoc_data_temp-segnam = c_e1wpe01_name.
          gt_idoc_data_temp-sdata  = e1wpe01.
          APPEND gt_idoc_data_temp.

*         aktualisiere Segmentzähler und Haupt-EAN.
          ADD 1 TO seg_local_cnt.
          px_ean = pit_imarm-ean11.

*********************************************************************
***********************   U S E R - E X I T  ************************
          CALL CUSTOMER-FUNCTION '003'
            EXPORTING
              pi_e1wpe02_cnt     = e1wpe02_cnt
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

*         Falls Umsetzfehler auftraten.
          IF pe_fehlercode <> 0.
*           Falls Fehlerprotokollierung erwünscht.
            IF pi_filia_const-ermod = space.
*             Falls der Satz zum heutigen Datum gelöscht werden soll.
              IF pi_datum <= sy-datum.
*               Fülle allgemeinen Objektschlüssel.
                CLEAR: gi_object_key.
                gi_object_key-matnr = pit_imarm-matnr.
                gi_object_key-vrkme = pit_imarm-meinh.
                gi_object_key-ean11 = px_ean.
                g_object_key        = gi_object_key.
                g_object_delete     = 'X'.

*               Ergänze Fehlerobjekttabelle um einen
*               zusätzlichen Eintrag.
                PERFORM error_object_write.

*               Rücksetze Löschkennzeichen für Fehlerobjekttabelle
*               WDLSO.
                CLEAR: g_object_delete.
              ENDIF. " pi_datum <= sy-datum.

*             Verlassen der Aufbereitung dieser Basiswarengruppe.
              EXIT.
*           Falls Abbruch bei Fehler erwünscht.
            ELSE.                      " PI_ERMOD <> SPACE.
*             Abbruch des Downloads.
              RAISE download_exit.
            ENDIF.                     " PI_FILIA_CONST-ERMOD = SPACE.

*         Falls Umschlüsselung fehlerfrei.
          ELSE.                        " PE_FEHLERCODE = 0.
*           Übernehme die IDOC-Daten aus Temporärtabelle.
            PERFORM idoc_data_assume TABLES  gt_idoc_data_temp
                                     USING   pxt_idoc_data
                                             px_segcnt
                                             seg_local_cnt.

          ENDIF.                       " PE_FEHLERCODE <> 0.

************************************************************************
        ELSE.                          " pit_orgtab-mean_cnt = 1.
*         Aktualisiere zuletzt verwendete Haupt-EAN.
          px_ean = pit_imarm-ean11.
        ENDIF.                         " pit_orgtab-mean_cnt > 1.
      ELSE.                            " PIT_ORGTAB-VERSENDEN = SPACE.
*       Aktualisiere zuletzt verwendete Haupt-EAN.
        px_ean = pit_imarm-ean11.
      ENDIF.                           " PIT_ORGTAB-VERSENDEN <> SPACE.

*   Prüfe, ob der neue Satz aufbereitet werden muß.
    ELSE.                              " PX_EAN = SPACE.
* Siehe Hinweis 217120:
*     Der neue Satz darf nur aufbereitet werden, wenn mehr als
*     eine EAN für dieses Datum vorhanden ist.
*     if pit_orgtab-datum <> pi_datum.
*       readindex = pi_datum - pi_datab_slct.
*       readindex = pi_vzeit_temp - readindex.
*       read table pit_orgtab index readindex.
*     endif.                           " pit_orgtab-datum <> pi_datum.
*break roth.
      IF pit_orgtab-mean_cnt <= 1.
*       Der neu Satz darf nicht aufbereitet werden.
        CLEAR: h_versenden.

*       Merken des zuletzt nicht aufbereiteten Satzes.
        g_last_record = readindex.
      ELSE.                            " pit_orgtab-mean_cnt > 1.
*       Aktualisiere zuletzt verwendete Haupt-EAN.
        px_ean = pit_imarm-ean11.
      ENDIF.                           " PIT_ORGTAB-MEAN_CNT <= 1.
    ENDIF.                             " PX_EAN <> SPACE.
  ENDIF.                               " PIT_IMARM-EAN11 <> PX_EAN.

* Falls EAN gelöscht oder nicht angelegt wurde.
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
*     'Keine EAN für Material & und Vrkme &
*     zum Datum & gepflegt'
      gi_message-msgno     = '125'.
      gi_message-msgv1     = i_key-matnr.
      gi_message-msgv2     = i_key-vrkme.
      gi_message-msgv3     = g_datum1.


*     Schreibe Fehlerzeile für Application-Log und WDLSO.
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
    IF g_status_pos < 2.                   " 'Benutzerhinweis'.
      gi_status_pos-gesst = c_status_benutzerhinweis.

      g_status_pos = 2.                    " 'Benutzerhinweis'.
    ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                       h_returncode.

*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Verlassen der Aufbereitung für dieses Datum
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.
  ENDIF.                               " PIT_IMARM-EAN11 = SPACE.

* Falls nicht weiter aufbereitet werden muß, dann verlassen der
* Aufbereitung für dieses Datum.
  IF h_versenden = space.
    EXIT.
  ELSE.                                " H_versenden <> space.
*   Prüfe, ob der Satz aufbereitet werden soll.
    IF pit_orgtab-datum <> pi_datum.
      readindex = pi_datum - pi_datab_slct.
      readindex = pi_vzeit_temp - readindex.
      READ TABLE pit_orgtab INDEX readindex.
    ELSE.                              " pit_orgtab-datum = pi_datum.
      readindex = pi_datum - pi_datab_slct.
      readindex = pi_vzeit_temp - readindex.
    ENDIF.                             " pit_orgtab-datum <> pi_datum.

*   Merken des zuletzt nicht aufbereiteten Satzes.
    g_last_record = readindex.

*   Falls der Satz zu wenig EAN's zum aufbereiten enthält, dann
*   verlasse Aufbereitung.
    IF pit_orgtab-versenden = space.
      EXIT.
    ENDIF.                             " pit_orgtab-versenden = space.
  ENDIF.                               " H_VERSENDEN = SPACE.

* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: gt_idoc_data_temp.

* Rücksetze lokalen Segmentzähler.
  CLEAR: seg_local_cnt.

* Aufbereitung ID-Segment.
  CLEAR: e1wpe01.
  e1wpe01-filiale    = pi_filia_const-kunnr.
  e1wpe01-aktivdatum = pi_datum.
  e1wpe01-aenddatum  = '00000000'.
  e1wpe01-aenderer   = ' '.
*  e1wpe01-artikelnr_long  = pit_imarm-matnr.

  cl_matnr_chk_mapper=>convert_on_output(
   EXPORTING
     iv_matnr40                   =     pit_imarm-matnr
   IMPORTING
     ev_matnr18                   =     e1wpe01-artikelnr
     ev_matnr40                   =     e1wpe01-artikelnr_long
   EXCEPTIONS
     excp_matnr_invalid_input     = 1
     excp_matnr_not_found         = 2
     OTHERS                       = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  e1wpe01-posme      = pit_imarm-meinh.

* Ausgabekonvertierung für EAN.
  CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
    EXPORTING
      input   = pit_imarm-ean11
      ean_typ = pit_imarm-numtp
    IMPORTING
      output  = e1wpe01-hauptean.

* Falls Löschmodus aktiv.
  IF pi_loeschen <> space.
    e1wpe01-aendkennz  = c_delete.
* Falls Löschmodus nicht aktiv.
  ELSE.
    e1wpe01-aendkennz  = c_modi.
  ENDIF.                               " PI_LOESCHEN <> SPACE.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpe01_name.
  gt_idoc_data_temp-sdata  = e1wpe01.
  APPEND gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  ADD 1 TO seg_local_cnt.

* Es müssen Stammdaten übertragen werden, da kein Löschmodus aktiv ist.
  IF pi_loeschen = space.
*   Falls Segment E1WPE02 (EAN-Referenzen) gefüllt werden muß.
    IF pi_e1wpe02 <> space.

*     Fülle Segment E1WPE02.
      CLEAR: e1wpe02, e1wpe02_cnt.

*     Besorge die zugehörigen MEAN-Daten. Die Daten stehen in der
*     Tabelle PIT_IMEAN.
      LOOP AT pit_imean
        WHERE datum =  lese_datum2
        AND   ean11 <> pit_imarm-ean11.

*       Ausgabekonvertierung für EAN.
        CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
          EXPORTING
            input   = pit_imean-ean11
            ean_typ = pit_imean-eantp
          IMPORTING
            output  = e1wpe02-ean.

*       Aktualisiere Zähler für EAN-Referenzen.
        ADD 1 TO e1wpe02_cnt.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpe02_name.
        gt_idoc_data_temp-sdata  = e1wpe02.
        APPEND gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        ADD 1 TO seg_local_cnt.

      ENDLOOP.                         " AT PIT_IMEAN

    ENDIF.                             " PI_E1WPE02 <> SPACE.
  ENDIF.                               " PI_LOESCHEN = SPACE.

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '003'
    EXPORTING
      pi_e1wpe02_cnt     = e1wpe02_cnt
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
      pit_mean           = pit_imean
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

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
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


ENDFORM.                               " IDOC_DATASET_EAN_APPEND


* eject.
************************************************************************
FORM ean_delete
     USING  pi_artnr       LIKE  gt_ot3_ean-artnr
            pi_vrkme       LIKE  gt_ot3_ean-vrkme
            pi_ean         LIKE  wpdel-ean
            pi_datum       LIKE  gt_ot3_ean-datum
            pi_ermod       LIKE  gt_filia_group-ermod
            pi_kunnr       LIKE  gt_filia_group-kunnr
   CHANGING pxt_idoc_data  TYPE  short_edidd
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
        e1wpe02_cnt   TYPE i VALUE 0.

  DATA: t_matnr LIKE gt_matnr    OCCURS 0 WITH HEADER LINE,
        t_marm  LIKE gt_marm_buf OCCURS 0 WITH HEADER LINE,
        h_numtp LIKE marm-numtp.

* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: gt_idoc_data_temp.

* Rücksetze Fehlercode.
  CLEAR: pe_fehlercode, h_numtp.

* Aufbereitung ID-Segment.
  CLEAR: e1wpe01.
  e1wpe01-filiale    = pi_kunnr.
  e1wpe01-aktivdatum = pi_datum.
  e1wpe01-aenddatum  = ' '.
  e1wpe01-aenderer   = '00000000'.
*  e1wpe01-artikelnr_long  = pi_artnr.
  cl_matnr_chk_mapper=>convert_on_output(
   EXPORTING
     iv_matnr40                   =     pi_artnr
   IMPORTING
     ev_matnr18                   =     e1wpe01-artikelnr
     ev_matnr40                   =     e1wpe01-artikelnr_long
   EXCEPTIONS
     excp_matnr_invalid_input     = 1
     excp_matnr_not_found         = 2
     OTHERS                       = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  e1wpe01-posme      = pi_vrkme.
  e1wpe01-aendkennz  = c_delete.

* Besorge EAN-Typ.
* Prüfe zunächst, ob es sich um eine alte EAN handelt.
  LOOP AT gt_old_ean
       WHERE artnr = pi_artnr
       AND   vrkme = pi_vrkme
       AND   ean11 = pi_ean.
    EXIT.
  ENDLOOP. " at gt_old_ean

* Falls es sich um eine alte EAN handelt und sich der EAN-Typ
* geändert hat.
  IF sy-subrc = 0 AND NOT gt_old_ean-numtp IS INITIAL.
    h_numtp = gt_old_ean-numtp.

* Falls es sich nicht um eine alte EAN handelt oder der EAN-Typ
* unverändert geblieben ist.
  ELSE. " sy-subrc <> 0 ...
*   Besorge aktuellen Nummerntyp.
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
      output  = e1wpe01-hauptean.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpe01_name.
  gt_idoc_data_temp-sdata  = e1wpe01.
  APPEND gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  ADD 1 TO seg_local_cnt.


*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '003'
    EXPORTING
      pi_e1wpe02_cnt     = e1wpe02_cnt
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

*     Verlassen der Aufbereitung.
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


ENDFORM.                               " EAN_DELETE


* eject.
************************************************************************
FORM ean_matdata_get
     TABLES pet_imarm     STRUCTURE gt_imarm
            pet_imean     STRUCTURE gt_imean
            pit_field_tab STRUCTURE gt_field_tab
     USING  pi_artnr      LIKE mara-matnr
            pi_vrkme      LIKE marm-meinh
            pi_datab      LIKE syst-datum
            pi_datbi      LIKE syst-datum
            pi_mode       LIKE wpstruc-modus
   CHANGING pe_found_marm LIKE wpmara-chgflag
            pe_found_mean LIKE wpmara-chgflag
            VALUE(pe_fehlercode) LIKE syst-subrc.
************************************************************************
* FUNKTION:
* Besorge Material-Stammdaten für den Download EAN-Referenzen aus
* internen Puffer oder von DB.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_IMARM    : Tabelle für MARM-Daten.

* PET_IMEAN    : Tabelle für MEAN-Daten.

* PIT_FIELD_TAB: POS-relevante Felder der Materialstammtabellen.

* PI_VRKME     : Verkaufsmengeneinheit der Selektion.

* PI_DATAB     : Beginndatum der Selektion.

* PI_DATBI     : Endedatum der Selektion.

* PI_MODE      : Download-Modus.

* PE_FOUND_MARM: = 'X', wenn keine MARM-Daten gefunden, sonst SPACE

* PE_FOUND_MEAN: = 'X', wenn keine MEAN-Daten gefunden, sonst SPACE

* PE_FEHLERCODE: > 0, wenn keine MARA-Daten gefunden, sonst '0'.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: readindex LIKE sy-tabix,
        datab     LIKE sy-datum,
        datbi     LIKE sy-datum,
        h_datum   LIKE sy-datum,
        h_dummy.

* Nur als Dummy für FB-Aufruf.
  DATA: BEGIN OF t_mara OCCURS 1.
      INCLUDE STRUCTURE gt_imara.
  DATA: END OF t_mara.


* Initialisieren der Ausgabetabellen
  REFRESH: pet_imarm, pet_imean, t_mara.
  CLEAR:   pet_imarm, pet_imean, t_mara.

* Rücksetze Fehlermerker.
  CLEAR: pe_found_marm, pe_found_mean, pe_fehlercode.

* Falls ein neuer Artikel gelesen werden muß
  IF pi_artnr <> g_artnr_buf_ean.
*   Merken des neuen Artikel in globaler Variable.
    g_artnr_buf_ean = pi_artnr.

*   ### nur bei zukünftigen Artikeländerungen erforderlich.
*   Falls Initialisierungsfall, direkte Anforderung oder Restart.
*   if pi_mode <> c_change_mode.
*     Besorge die Intervallgrenzen des Betrachtungszeitraums.
*     datab = g_datab.
*     datbi = g_datbis.

*   Falls Änderungsfall.
*   else. " PI_MODE = C_CHANGE_MODE
*     Besorge die untere Grenze des Betrachtungszeitraums.
*     read table gt_workdays index 1.
*     datab = gt_workdays-datum.

*     Besorge die obere Grenze des Betrachtungszeitraums.
*     describe table gt_workdays lines readindex.
*     read table gt_workdays index readindex.
*     datbi = gt_workdays-datum.
*   endif. " pi_mode <> c_change_mode.

*   Initialisieren der Puffertabellen
    REFRESH: gt_imarm_buf, gt_imean_buf.
    CLEAR:   gt_imarm_buf, gt_imean_buf.

*   Füllen der einzelnen Tabellenschlüssel.
    t_mara-mandt = sy-mandt.
    t_mara-matnr = pi_artnr.
    APPEND t_mara.

    gt_imarm_buf-mandt = sy-mandt.
    gt_imarm_buf-matnr = pi_artnr.
    APPEND gt_imarm_buf.

    gt_imean_buf-mandt = sy-mandt.
    gt_imean_buf-matnr = pi_artnr.
    APPEND gt_imean_buf.

* ### zukünftige Änderung
*   Besorge Material-Stammdaten.
*   call function 'MATERIAL_CHANGE_DOCUMENTATION'
*        exporting
*             date_from            = datab
*             date_to              = datbi
*             explosion            = 'X'
*             indicator            = 'X'
*        importing
*             no_record_found_marm = pe_found_marm
*             no_record_found_makt = pe_found_mean
*        tables
*             jmara                = t_mara
*             jmarm                = gt_imarm_buf
*             jmean                = gt_imean_buf
*             change_field_tab     = pit_field_tab
*        exceptions
*             no_record_found_mara = 01
*             wrong_date_relation  = 02.

    CALL FUNCTION 'POS_MATERIAL_GET'
      EXPORTING
        pi_datab             = pi_datab
        marm_ean_check       = 'X'
        pi_exception_mode    = 'X'
      IMPORTING
        no_record_found_marm = pe_found_marm
        no_record_found_makt = pe_found_mean
      TABLES
        p_t_cmara            = t_mara
        p_t_cmarm            = gt_imarm_buf
        p_t_cmean            = gt_imean_buf
      EXCEPTIONS
        no_record_found_mara = 01
        OTHERS               = 02.

*   Falls Fehler auftraten.
    IF sy-subrc <> 0 OR pe_found_marm <> space OR
       pe_found_mean <> space.

*     Zwischenspeichern des Returncodes, falls nötig.
      IF sy-subrc <> 0.
        pe_fehlercode = 1.
      ENDIF. " sy-subrc <> 0.

*     Merken, daß beim nächsten mal der interne Puffer neu
*     gefüllt werden muß.
      CLEAR: g_artnr_buf_ean.

*     Routine verlassen.
      EXIT.
    ENDIF. " sy-subrc <> 0 or pe_found_marm <> space or ...

*   Pufferdaten sortieren.
    SORT gt_imarm_buf BY  meinh datum DESCENDING.
    SORT gt_imean_buf BY  meinh datum DESCENDING.

  ENDIF.                               " pi_artnr = g_artnr_buf_ean.

*******************************************
* Übernahme MARM-Daten in Ausgabetabelle.
  CLEAR: h_datum, h_dummy.
  LOOP AT gt_imarm_buf
       WHERE matnr =  pi_artnr
       AND   meinh =  pi_vrkme
       AND   datum <= pi_datbi.

    IF gt_imarm_buf-datum > pi_datab.
      pet_imarm = gt_imarm_buf.
      APPEND pet_imarm.
    ELSEIF gt_imarm_buf-datum = pi_datab.
      pet_imarm = gt_imarm_buf.
      APPEND pet_imarm.

*     Merken, daß keine noch kleineren Datümer übernommen werden
*     müssen.
      h_dummy   = 'X'.
    ELSEIF gt_imarm_buf-datum < pi_datab.
*     Falls bereits alle Daten übernommen wurden, dann
*     Routine verlassen.
      IF h_dummy <> space.
        EXIT.
*     Falls noch Daten übernommen werden müssen.
      ELSEIF h_dummy = space.
        IF gt_imarm_buf-datum >= h_datum.
          pet_imarm       = gt_imarm_buf.
          pet_imarm-datum = pi_datab.
          APPEND pet_imarm.

*         Merke das kleinste Datum, welches noch übernommen
*         werden muß.
          h_datum = gt_imarm_buf-datum.
        ELSE.                          " gt_imarm_buf-datum < h_datum.
*         Routine verlassen.
          EXIT.
        ENDIF.                         " gt_imarm_buf-datum >= h_datum.
      ENDIF.                           " h_dummy <> space.
    ENDIF.                             " gt_imarm_buf-datum > pi_datab.

  ENDLOOP.                             " at gt_imarm_buf

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
*   Zwischenspeichern des Returncodes.
    pe_found_marm = 'X'.

*   Routine verlassen.
    EXIT.
* Falls keine Fehler auftraten.
  ELSE.                                " sy-subrc = 0.
*   Sortiere Daten der Ausgabetabelle.
    SORT pet_imarm BY datum.
  ENDIF.                               " sy-subrc <> 0

*******************************************
* Übernahme MEAN-Daten in Ausgabetabelle.
  CLEAR: h_datum, h_dummy.
  LOOP AT gt_imean_buf
       WHERE matnr =  pi_artnr
       AND   meinh =  pi_vrkme
       AND   datum <= pi_datbi.

    IF gt_imean_buf-datum > pi_datab.
      pet_imean = gt_imean_buf.
      APPEND pet_imean.
    ELSEIF gt_imean_buf-datum = pi_datab.
      pet_imean = gt_imean_buf.
      APPEND pet_imean.

*     Merken, daß keine noch kleineren Datümer übernommen werden
*     müssen.
      h_dummy   = 'X'.
    ELSEIF gt_imean_buf-datum < pi_datab.
*     Falls bereits alle Daten übernommen wurden, dann
*     Routine verlassen.
      IF h_dummy <> space.
        EXIT.
*     Falls noch Daten übernommen werden müssen.
      ELSEIF h_dummy = space.
        IF gt_imean_buf-datum >= h_datum.
          pet_imean       = gt_imean_buf.
          pet_imean-datum = pi_datab.
          APPEND pet_imean.

*         Merke das kleinste Datum, welches noch übernommen
*         werden muß.
          h_datum = gt_imean_buf-datum.
        ELSE.                          " gt_imean_buf-datum < h_datum.
*         Routine verlassen.
          EXIT.
        ENDIF.                         " gt_imean_buf-datum >= h_datum.
      ENDIF.                           " h_dummy <> space.
    ENDIF.                             " gt_imean_buf-datum > pi_datab.

  ENDLOOP.                             " at gt_imean_buf

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
*   Zwischenspeichern des Returncodes.
    pe_found_mean = 'X'.

*   Routine verlassen.
    EXIT.
* Falls keine Fehler auftraten.
  ELSE.                                " sy-subrc = 0.
*   Sortiere Daten der Ausgabetabelle.
    SORT pet_imean BY datum ean11.
  ENDIF.                               " sy-subrc <> 0


ENDFORM.                               " ean_matdata_get


*eject
************************************************************************
FORM ean_change_mode_prepare
     TABLES pit_ot3_ean            STRUCTURE gt_ot3_ean
            pit_filter_segs        STRUCTURE gt_filter_segs
            pit_workdays           STRUCTURE gt_workdays
            pit_artdel             STRUCTURE gt_artdel
            pit_mara_buf           STRUCTURE gt_mara_buf
            pit_marm_buf           STRUCTURE gt_marm_buf
            pit_old_ean            STRUCTURE gt_old_ean
            pit_zus_ean_del        STRUCTURE gt_zus_ean_del
            pit_ean_change         STRUCTURE gt_ean_change
            pit_master_idocs       STRUCTURE gt_master_idocs
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
* IDOC-Aufbereitung der EAN-Referenzen.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Aufbereitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_FILTER_SEGS       : Reduzierinformationen.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PIT_ARTDEL            : Tabelle der zu löschenden Artikel

* PIT_MARA_BUF          : MARA-Puffer.

* PIT_MARM_BUF          : MARM-Puffer.

* PIT_OLD_EAN           : Puffer für Haupt-EAN's.

* PIT_ZUS_EAN_DEL       : Puffer für zusätzliche EAN-Löschsätze
*                         (Falls im Komm-profil so eingestellt)
* PIT_EAN_CHANGE        : Puffer für EAN-Änderungen.

* PIT_MASTER_IDOCS      : Tabelle der kopierfähigen IDOC's

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
*                         Objekt Warengruppen.
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
*   IDOC-Aufbereitung der EAN-Referenzen.
    CALL FUNCTION 'POS_EAN_CHG_MODE_PREPARE'
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
        pit_ot3_ean            = pit_ot3_ean
        pit_filter_segs        = pit_filter_segs
        pit_workdays           = pit_workdays
        pit_artdel             = pit_artdel
        pit_master_idocs       = pit_master_idocs
        pit_independence_check = pit_independence_check
        pit_wlk2               = pit_wlk2.

*   Aktualisiere Statisktikinformation.
    px_stat_counter-ean_ign = i_stat_counter-ean_ign.

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
    CALL FUNCTION 'POS_EAN_CHG_MODE_PREPARE'
      STARTING NEW TASK px_taskname
      DESTINATION IN GROUP pi_server_group
      PERFORMING return_ean_chg_mode_prepare ON END OF TASK
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
        pit_ot3_ean            = pit_ot3_ean
        pit_filter_segs        = pit_filter_segs
        pit_workdays           = pit_workdays
        pit_master_idocs       = pit_master_idocs
        pit_independence_check = pit_independence_check
        pit_artdel             = pit_artdel
        pit_mara_buf           = pit_mara_buf
        pit_marm_buf           = pit_marm_buf
        pit_old_ean            = pit_old_ean
        pit_zus_ean_del        = pit_zus_ean_del
        pit_ean_change         = pit_ean_change
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

*     IDOC-Aufbereitung der EAN-Referenzen sequentiell.
      CALL FUNCTION 'POS_EAN_CHG_MODE_PREPARE'
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
          pit_ot3_ean            = pit_ot3_ean
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pit_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-ean_ign = i_stat_counter-ean_ign.

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


ENDFORM. " ean_change_mode_prepare
