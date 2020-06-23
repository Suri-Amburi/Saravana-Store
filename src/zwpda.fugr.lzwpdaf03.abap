*-------------------------------------------------------------------
***INCLUDE LWPDAF03 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Artikelstamm.
************************************************************************


************************************************************************
FORM artstm_download
     TABLES pit_filter_segs STRUCTURE gt_filter_segs
            pit_artikel     STRUCTURE wpart
            pit_art_equal   STRUCTURE wpart
     USING  pi_filia        LIKE wpfilia-filia
            pi_filia_const  STRUCTURE gi_filia_const
            pi_express      LIKE wpstruc-modus
            pi_loeschen     LIKE wpstruc-modus
            pi_mode         LIKE wpstruc-modus
            pi_datum_ab     LIKE wpstruc-datum
            pi_datum_bis    LIKE wpstruc-datum
            pi_vkorg        LIKE wpstruc-vkorg
            pi_vtweg        LIKE wpstruc-vtweg
            pi_art          LIKE wpstruc-modus
            pi_debug        LIKE wpstruc-modus.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads des Artikelstamms.                              *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PIT_ARTIKEL    : Liste der zu übertragenden Artikel, falls
*                  PI_MODE = 'A' und PI_ART = 'X'.
* PIT_ART_EQUAL  : Liste der Artikel mit SELECT-OPTION = 'EQUAL',
*                  falls PI_MODE = 'A' und PI_ART = 'X'.
* PI_FILIA       : Filiale, an die verschickt werden soll.

* PI_FILIA_CONST : Feldleiste mit Filialkonstanten.

* PI_EXPRESS     := 'X', wenn sofort versendet werden soll, sonst SPACE.

* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                     sollen, sonst SPACE.
* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'A' = direkte
*                     Anforderung, 'R' = Restart.
* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.

* PI_DATUM_BIS   : Ende des Betrachtungszeitraums.

* PI_VKORG       : Verkaufsorganisation.

* PI_VTWEG       : Vertriebsweg.

* PI_ART         : = 'X', wenn Artikel übertragen werden sollen
*                  (kann nur bei direkter Anforderung gesetzt sein).
* PI_DEBUG       : = 'X', wenn Status-Positionszeile ständig
*                         aktualisiert werden soll, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: e1wpa01           VALUE 'X', " Flag, ob Segm. E1WPA01 vers. werden muß
        e1wpa02           VALUE 'X',
        e1wpa03           VALUE 'X',
        e1wpa04           VALUE 'X',
        e1wpa05           VALUE 'X',
*       e1wpa06 value 'X',
        e1wpa07           VALUE 'X',
        e1wpa08           VALUE 'X',
        e1wpa09           VALUE 'X',
        e1wpa10           VALUE 'X',
        e1wpa11           VALUE 'X',
        art_lines         TYPE i,
        h_vrkme           LIKE marm-meinh,
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

  DATA: lt_articles TYPE pre03_tab.                   " Note 1982796

  "****START OF SALES PRICE MULTI OPTIMIZATION***
  DATA: ls_ot3_artstm TYPE wpaot3.
  DATA: ls_listing TYPE wpwlk1.
  DATA: lv_vrkme TYPE wlk1-vrkme.
  "****END OF SALES PRICE MULTI OPTIMIZATION***

* Schreibe alle, für den Download Artikelstamm-Stammdaten benötigten,
* Tabellenfelder in eine interne Tabelle.
  PERFORM artstm_fieldtab_fill TABLES gt_field_tab.

* Prüfe, welche Artikelstammsegmente versendet werden müssen
  LOOP AT pit_filter_segs.

    CASE pit_filter_segs-segtyp.
      WHEN c_e1wpa01_name.
        CLEAR: e1wpa01.
      WHEN c_e1wpa02_name.
        CLEAR: e1wpa02.
      WHEN c_e1wpa03_name.
        CLEAR: e1wpa03.
      WHEN c_e1wpa04_name.
        CLEAR: e1wpa04.
      WHEN c_e1wpa05_name.
        CLEAR: e1wpa05.
*     when c_e1wpa06_name.
*       clear: e1wpa06.
      WHEN c_e1wpa07_name.
        CLEAR: e1wpa07.
      WHEN c_e1wpa08_name.
        CLEAR: e1wpa08.
      WHEN c_e1wpa09_name.
        CLEAR: e1wpa09.
      WHEN c_e1wpa10_name.
        CLEAR: e1wpa10.
      WHEN c_e1wpa11_name.
        CLEAR: e1wpa11.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

* Es müssen Artikelstammdaten versendet werden.
  IF e1wpa01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: g_segment_counter, g_new_position, g_status_pos.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
    IF gv_time_rg_wrkdays_get_flag = abap_false.

      PERFORM time_range_get USING pi_datum_ab   pi_datum_bis
                                 pi_filia_const-vzeit
                                 pi_filia_const-fabkl
                                 g_datab       g_datbis  g_erstdat.

*   Erzeuge Tabelle mit Arbeitstagen, falls nötig.
      PERFORM workdays_get TABLES gt_workdays
                           USING  g_datab  g_datbis
                                  pi_filia_const-fabkl.
    ENDIF.

*   Falls direkte Anforderung oder Restart-Modus, prüfe, ob
*   Artikeltabelle Daten enhält.
    IF pi_art <> space.
      CLEAR: art_lines.
      READ TABLE pit_artikel WITH KEY
           arttyp = c_artikeltyp
           BINARY SEARCH.

      IF sy-subrc = 0.
        art_lines = 1.
      ENDIF.                           " SY-SUBRC = 0.
    ENDIF.                             " PI_ART <> SPACE.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = g_dldnr.
    gi_status_pos-doctyp = c_idoctype_artstm.

*   Fall Restart-Modus.
    IF pi_mode = c_restart_mode.
      gi_status_pos-rspos  = 'X'.
    ENDIF. " pi_mode = c_restart_mode.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Rücksetzen Fehler-Zähler.
    CLEAR: g_err_counter, g_firstkey.

*   Initialisierungsfall, direkte Anforderung oder Restart-Modus
*   (alle Artikel übertragen).
    IF pi_mode = c_init_mode OR ( pi_art <> space AND art_lines = 0 ).
*     Besorge alle Artikel, die innerhalb des Betrachtungszeitraum
*     für Filiale PI_FILIA gelistet sind.
      IF gv_no_articles_found = abap_false.
        PERFORM listed_articles_get TABLES gt_wlk2
                                  USING  pi_vkorg  pi_vtweg
                                         pi_filia  g_datab
                                         g_datbis.
      ENDIF.

*     Schleife über alle zu bewirtschaftete Artikel
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

*       Falls die Warengruppe dieser Filiale zugeordnet ist.
        IF sy-subrc = 0.
*         Falls die Warengruppe von der Versendung ausgeschlossen
*         werden soll, dann weiter zur nächsten Artikelnummer.
          IF t_wrf6-wdaus <> space.
*           Weiter zum nächsten Satz.
            CONTINUE.
          ENDIF. " t_wrf6-wdaus <> space.

*       Falls die Warengruppe nicht dieser Filiale zugeordnet ist.
        ELSE. " sy-subrc <> 0
*         Falls das Artikelstammsegment E1WPA02 aufbereitet werden soll
*         (in diesem werden WRF6-Daten übertragen), dann prüfe, ob
*         Artikel heruntergeladen werden kann
          IF NOT e1wpa02 IS INITIAL.
*           Falls kein Verkauf über alle Warengruppen, dann sollen
*           die WRF6-Daten übertragen werden. Da sie nicht vorhanden
*           sind kann der Artikel nicht aufbereitet werden.
            IF pi_filia_const-sallmg IS INITIAL.
*             Falls Fehlerprotokollierung erwünscht.
              IF pi_filia_const-ermod = space.
*               Falls noch keine Initialisierung des Fehlerprotokolls.
                IF g_init_log = space.
*                 Aufbereitung der Parameter zum schreiben des Headers
*                 des Fehlerprotokolls.
                  CLEAR: gi_errormsg_header.
                  gi_errormsg_header-object        = c_applikation.
                  gi_errormsg_header-subobject     = c_subobject.
                  gi_errormsg_header-extnumber     = g_dldnr.
                  gi_errormsg_header-extnumber+14  = g_dldlfdnr.
                  gi_errormsg_header-aluser        = sy-uname.

*                 Initialisiere Fehlerprotokoll und erzeuge Header.
                  PERFORM appl_log_init_with_header
                          USING gi_errormsg_header.

*                 Merke, daß Fehlerprotokoll initialisiert wurde.
                  g_init_log = 'X'.
                ENDIF.                       " G_INIT_LOG = SPACE.

*               Bereite Parameter zum schreiben der Fehlerzeile auf.
                CLEAR: gi_message.
                gi_message-msgty     = c_msgtp_error.
                gi_message-msgid     = c_message_id.
                gi_message-probclass = c_probclass_sehr_wichtig.
*               'Keine Zuordnung der Filiale & zur Warengruppe
*                & gepflegt'
                gi_message-msgno     = '159'.
                gi_message-msgv1     = pi_filia.
                gi_message-msgv2     = mara-matkl.
                gi_message-msgv3     = mara-matnr.

*               Schreibe Fehlerzeile für Application-Log und WDLSO.
                g_object_key = mara-matnr.
                PERFORM appl_log_write_single_message USING gi_message.

              ENDIF.           " PI_FILIA_CONST-ERMOD = SPACE.

*             Ändern der Status-Kopfzeile, falls nötig.
              IF g_status < 3.               " 'Fehlende Daten'
*               Aufbereiten der Parameter zum Ändern der
*               Status-Kopfzeile.
                CLEAR: gi_status_header.
                gi_status_header-dldnr = g_dldnr.
                gi_status_header-gesst = c_status_fehlende_daten..

*               Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                PERFORM status_write_head
                        USING  'X'     gi_status_header
                               g_dldnr g_returncode.

*               Aktualisiere Aufbereitungsstatus.
                g_status = 3.                " 'Fehlende Daten'
              ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*             Aufbereiten der Parameter zum Ändern der
*             Status-Positionszeile.
              CLEAR: gi_status_pos.
              gi_status_pos-dldnr  = g_dldnr.
              gi_status_pos-lfdnr  = g_dldlfdnr.
              gi_status_pos-anloz  = g_err_counter.
              gi_status_pos-gesst  = c_status_fehlende_idocs.

*             Aktualisiere Aufbereitungsstatus für Positionszeile,
*             falls nötig.
              IF g_status_pos < 3.                   " 'Fehlende Daten'
                gi_status_pos-gesst = c_status_fehlende_daten.

                g_status_pos = 3.                    " 'Fehlende Daten'
              ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*             Schreibe Status-Positionszeile.
              PERFORM status_write_pos USING 'X' gi_status_pos
                                             g_dldlfdnr g_returncode.

*             Falls Fehlerprotokollierung erwünscht.
              IF pi_filia_const-ermod = space.
*               Weiter zum nächsten Satz.
                CONTINUE.
*             Falls Abbruch bei Fehler erwünscht.
              ELSE.           " PI_FILIA_CONST-ERMOD <> SPACE.
*               Abbruch des Downloads.
                RAISE download_exit.
              ENDIF.          " PI_FILIA_CONST-ERMOD = SPACE.
            ENDIF. " pi_filia_const-sallmg is initial.
          ENDIF. " not e1wpa02 is initial.
        ENDIF. " sy-subrc = 0

*       Prüfe, ob es nur eine POS-relevante Verkaufsmengeneinheit gibt.
*       Besorge MVKE-Daten.
*       Besorge das jeweilige Preismaterial der Variante.
        PERFORM mvke_select
                     USING mvke
                           gt_wlk2-matnr
                           pi_vkorg
                           pi_vtweg.

*       Falls es nur eine POS-relevante Verkaufsmengeneinheit gibt.
        IF NOT mvke-vavme IS INITIAL.
*         Falls die POS-relevante Verkaufsmengeneinheit in MVKE
*         gespeichert ist.
          IF NOT mvke-vrkme IS INITIAL.
            h_vrkme = mvke-vrkme.
*         Falls die POS-relevante Verkaufsmengeneinheit in MARA
*         gespeichert ist.
          ELSE. " mvke-vrkme is initial.
            h_vrkme = mara-meins.
          ENDIF. " not mvke-vrkme is initial.

*         Prüfe auf EAN.
          PERFORM marm_select
                  TABLES t_matnr
                         t_marm
                  USING  'X'                  " pi_with_ean
                         gt_wlk2-matnr        " pi_matnr
                         h_vrkme.             " pi_meinh

*       Falls es mehrere POS-relevante Verkaufsmengeneinheit
*       geben kann.
        ELSE.  " mvke-vavme is initial.
*         Besorge die Verkaufsmengeneinheiten des Artikels, die eine
*         EAN besitzen.
          REFRESH: t_matnr.
          APPEND gt_wlk2-matnr TO t_matnr.
          PERFORM marm_select
                  TABLES t_matnr
                         t_marm
                  USING  'X'                  " pi_with_ean
                         ' '                  " pi_matnr
                         ' '.                 " pi_meinh
        ENDIF. " not mvke-vavme is initial.
*       Erzeuge Listungstabelle.
        PERFORM gt_listung_fill
                TABLES t_marm
                       gt_listung
                USING  gt_wlk2.
*       Besorge alle gelisteten Verkaufsmengeneinheiten zum Artikel.
        REFRESH: t_vrkme.
        CLEAR: h_vrkme.
        LOOP AT gt_listung.
          IF gt_listung-vrkme <> h_vrkme.
            h_vrkme = gt_listung-vrkme.
            APPEND gt_listung-vrkme TO t_vrkme.
          ENDIF.                       " GT_LISTUNG-VRKME <> H_VRKME
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
              g_firstkey  = i_key.
              CLEAR: g_new_firstkey.
            ENDIF.                     " G_NEW_FIRSTKEY <> SPACE.

            "****START OF SALES PRICE MULTI OPTIMIZATION***
            "we must do this because we cannot pass the table header line to the preread (RABAX)
            lv_vrkme = t_vrkme.

            "the sales price multi optimization is active
            IF cl_sls_price_mult_access_check=>is_sales_price_multi_active( ) = abap_true.
*             gv_vtweg is filled only for WPMI
              IF gv_vtweg IS INITIAL.
                gv_vtweg = pi_vtweg.
              ENDIF.
              CALL FUNCTION 'SALES_CONDITIONS_PREREAD'
                EXPORTING
                  iv_kvewe                     = 'A'
                  iv_kappl                     = 'V '
                  iv_incfi                     = 'X'
                  iv_datab                     = g_datab
                  iv_datbi                     = g_datbis
                  iv_matnr                     = gt_wlk2-matnr
                  iv_vkorg                     = pi_vkorg
                  iv_vrkme                     = lv_vrkme
                  iv_vtweg                     = gv_vtweg
                  iv_werks                     = pi_filia
                  iv_vorga                     = '02'
                EXCEPTIONS
                  no_bukrs_found               = 1
                  plant_not_found              = 2
                  material_invalid             = 3
                  org_structure_not_completed  = 4
                  vkorg_not_found              = 5
                  no_pos_condition_types_found = 6
                  no_condition_types_match     = 7
                  no_spart_found               = 8
                  distribution_chain_not_found = 9
                  other_error                  = 10
                  currency_not_found           = 11
                  pltyp_werks_comb_not_allowed = 12
                  pltyp_not_found              = 13
                  OTHERS                       = 14.

              IF sy-subrc = 0.
                "fill global listing table
                "Listing conditions found -> determine the relevant sales price conditions
                IF gt_listung IS NOT INITIAL.
                  READ TABLE gt_listung INTO ls_listing WITH KEY artnr = gt_wlk2-matnr vrkme = t_vrkme.

                  "also write store name into listing work area
                  IF ls_listing-filia IS INITIAL.
                    ls_listing-filia = pi_filia.
                  ENDIF.

                  "add listing work are to gt_list_cond_collect
                  APPEND ls_listing TO gt_list_cond_collect.

                ENDIF.

                "fill global ot3_artstm table
                ls_ot3_artstm-artnr = gt_wlk2-matnr.
                ls_ot3_artstm-vrkme = lv_vrkme.
                ls_ot3_artstm-datum = g_datab.

                APPEND ls_ot3_artstm TO gt_ot3_artstm_collect.

              ENDIF.
              "the sales price multi opmtimization is disabled
            ELSE.
*           Besorge Artikeldaten und bereite IDOC auf.
              CALL FUNCTION 'MASTERIDOC_CREATE_DLPART'
                EXPORTING
                  pi_debug           = pi_debug
*###                  pi_ermod               = pi_filia_const-ermod
*                 pi_sallmg          = pi_filia_const-sallmg
                  pi_dldnr           = g_dldnr
                  px_dldlfdnr        = g_dldlfdnr
                  pi_vkorg           = pi_vkorg
                  pi_vtweg           = pi_vtweg
                  pi_filia           = pi_filia
                  pi_artnr           = gt_wlk2-matnr
                  pi_vrkme           = t_vrkme-vrkme
*                 pi_vrkme           = t_marm-meinh
                  pi_datum_ab        = g_datab
                  pi_datum_bis       = g_datbis
                  pi_express         = pi_express
                  pi_loeschen        = pi_loeschen
                  pi_mode            = pi_mode
                  pi_e1wpa02         = e1wpa02
                  pi_e1wpa03         = e1wpa03
                  pi_e1wpa04         = e1wpa04
                  pi_e1wpa05         = e1wpa05
*                 pi_e1wpa06         = e1wpa06
                  pi_e1wpa07         = e1wpa07
                  pi_e1wpa08         = e1wpa08
                  pi_e1wpa09         = e1wpa09
                  pi_e1wpa10         = e1wpa10
                  pi_e1wpa11         = e1wpa11
*                 pi_vzeit           = pi_filia_const-vzeit
*                 pi_spras           = pi_filia_const-spras
                  px_segment_counter = g_segment_counter
                  pi_filia_const     = pi_filia_const
                IMPORTING
                  px_segment_counter = g_segment_counter
                TABLES
                  pit_listung        = gt_listung
*                 ###                =
*                 löschen            =
*                 pit_art_equal      = pit_art_equal
                  pit_ot3_artstm     = gt_ot3_artstm
                  pit_workdays       = gt_workdays
                CHANGING
                  pxt_idoc_data      = gt_idoc_data
                EXCEPTIONS
                  download_exit      = 1.

*           Es sind Fehler beim Download aufgetreten'
              IF sy-subrc = 1.
                RAISE download_exit.
              ENDIF.                     " SY-SUBRC = 1.
            ENDIF.                     "end of sales price multi optimizaton
            "****END OF SALES PRICE MULTI OPTIMIZATION***
          ENDLOOP.                     " AT T_VRKME
        ENDIF.                         " SY-SUBRC = 0.
      ENDLOOP. " at gt_wlk2.

*     Falls kein einziger Artikel für diese Filiale gelistet ist.
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
          gi_message-msgno     = '117'.
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
      ENDIF.                           " SY-SUBRC <> 0. WLK2-Select

      "****START OF SALES PRICE MULTI OPTIMIZATION***
      IF cl_sls_price_mult_access_check=>is_sales_price_multi_active( ) = abap_false.
*     Erzeuge letztes IDOC, falls nötig.
        IF g_segment_counter > 0.
*       Bestimme 'Lastkey'.
          i_key-matnr = mara-matnr.
          i_key-vrkme = t_vrkme-vrkme.

          PERFORM idoc_create USING  gt_idoc_data
                                     g_mestype_artstm
                                     c_idoctype_artstm
                                     g_segment_counter
                                     g_err_counter
                                     g_firstkey
                                     i_key
                                     g_dldnr
                                     g_dldlfdnr
                                     pi_filia
                                     pi_filia_const.
        ENDIF.                           " G_SEGMENT_COUNTER > 0.
      ENDIF.
      "****END OF SALES PRICE MULTI OPTIMIZATION***

*   Direkte Anforderung mit vorselektierten Artikeln
*   oder Restart-Modus.
    ELSEIF pi_art <> space AND art_lines > 0.
*   B: New listing check logic => Note 1982796
      IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
         AND gs_twpa-marc_chk IS NOT INITIAL.
* New listing logic: Read WLK2 and check MARC
        LOOP AT pit_artikel
             WHERE arttyp = c_artikeltyp.
          APPEND pit_artikel-matnr TO lt_articles.
        ENDLOOP.

        CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
          EXPORTING
            ip_access_type   = '2'     " WLK2 access with Art/Store
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
      ENDIF. " Note 1982796

*     Schleife über alle selektierten Artikel.
      LOOP AT pit_artikel
           WHERE arttyp = c_artikeltyp.
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
          PERFORM artstm_delete USING   pit_artikel-matnr
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

*       Falls die Warengruppe dieser Filiale zugeordnet ist.
        IF sy-subrc = 0.
*         Falls die Warengruppe von der Versendung ausgeschlossen
*         werden soll, dann weiter zur nächsten Artikelnummer.
          IF t_wrf6-wdaus <> space.
*           Weiter zum nächsten Satz.
            CONTINUE.
          ENDIF. " t_wrf6-wdaus <> space.

*       Falls die Warengruppe nicht dieser Filiale zugeordnet ist.
        ELSE. " sy-subrc <> 0
*         Falls das Artikelstammsegment E1WPA02 aufbereitet werden soll
*         (in diesem werden WRF6-Daten übertragen), dann prüfe, ob
*         Artikel heruntergeladen werden kann
          IF NOT e1wpa02 IS INITIAL.
*           Falls kein Verkauf über alle Warengruppen, dann sollen
*           die WRF6-Daten übertragen werden. Da sie nicht vorhanden
*           sind kann der Artikel nicht aufbereitet werden.
            IF pi_filia_const-sallmg IS INITIAL.
*             Falls Fehlerprotokollierung erwünscht.
              IF pi_filia_const-ermod = space.
*               Falls noch keine Initialisierung des Fehlerprotokolls.
                IF g_init_log = space.
*                 Aufbereitung der Parameter zum schreiben des Headers
*                 des Fehlerprotokolls.
                  CLEAR: gi_errormsg_header.
                  gi_errormsg_header-object        = c_applikation.
                  gi_errormsg_header-subobject     = c_subobject.
                  gi_errormsg_header-extnumber     = g_dldnr.
                  gi_errormsg_header-extnumber+14  = g_dldlfdnr.
                  gi_errormsg_header-aluser        = sy-uname.

*                 Initialisiere Fehlerprotokoll und erzeuge Header.
                  PERFORM appl_log_init_with_header
                          USING gi_errormsg_header.

*                 Merke, daß Fehlerprotokoll initialisiert wurde.
                  g_init_log = 'X'.
                ENDIF.                       " G_INIT_LOG = SPACE.

*               Bereite Parameter zum schreiben der Fehlerzeile auf.
                CLEAR: gi_message.
                gi_message-msgty     = c_msgtp_error.
                gi_message-msgid     = c_message_id.
                gi_message-probclass = c_probclass_sehr_wichtig.
*               'Keine Zuordnung der Filiale & zur Warengruppe
*                & gepflegt'
                gi_message-msgno     = '159'.
                gi_message-msgv1     = pi_filia.
                gi_message-msgv2     = mara-matkl.
                gi_message-msgv3     = mara-matnr.

*               Schreibe Fehlerzeile für Application-Log und WDLSO.
                g_object_key = mara-matnr.
                PERFORM appl_log_write_single_message USING gi_message.

              ENDIF.           " PI_FILIA_CONST-ERMOD = SPACE.

*             Ändern der Status-Kopfzeile, falls nötig.
              IF g_status < 3.               " 'Fehlende Daten'
*               Aufbereiten der Parameter zum Ändern der
*               Status-Kopfzeile.
                CLEAR: gi_status_header.
                gi_status_header-dldnr = g_dldnr.
                gi_status_header-gesst = c_status_fehlende_daten.

*               Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                PERFORM status_write_head
                        USING  'X'     gi_status_header
                               g_dldnr g_returncode.

*               Aktualisiere Aufbereitungsstatus.
                g_status = 3.                " 'Fehlende Daten'
              ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*             Aufbereiten der Parameter zum Ändern der
*             Status-Positionszeile.
              CLEAR: gi_status_pos.
              gi_status_pos-dldnr  = g_dldnr.
              gi_status_pos-lfdnr  = g_dldlfdnr.
              gi_status_pos-anloz  = g_err_counter.
              gi_status_pos-gesst  = c_status_fehlende_idocs.

*             Aktualisiere Aufbereitungsstatus für Positionszeile,
*             falls nötig.
              IF g_status_pos < 3.                   " 'Fehlende Daten'
                gi_status_pos-gesst = c_status_fehlende_daten.

                g_status_pos = 3.                    " 'Fehlende Daten'
              ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*             Schreibe Status-Positionszeile.
              PERFORM status_write_pos USING 'X' gi_status_pos
                                             g_dldlfdnr g_returncode.

*             Falls Fehlerprotokollierung erwünscht.
              IF pi_filia_const-ermod = space.
*               Weiter zum nächsten Satz.
                CONTINUE.
*             Falls Abbruch bei Fehler erwünscht.
              ELSE.           " PI_FILIA_CONST-ERMOD <> SPACE.
*               Abbruch des Downloads.
                RAISE download_exit.
              ENDIF.          " PI_FILIA_CONST-ERMOD = SPACE.
            ENDIF. " pi_filia_const-sallmg is initial.
          ENDIF. " not e1wpa02 is initial.
        ENDIF. " sy-subrc = 0

*   B: New listing check logic => Note 1982796
        IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
          AND gs_twpa-marc_chk IS NOT INITIAL.
          PERFORM pos_listing_get TABLES gt_wlk2
                                         gt_listung
                                  USING  pi_vkorg
                                         pi_vtweg
                                         pi_filia
                                         pit_artikel-matnr.
        ELSE.
*       Besorge alle Listungen des Artikels bzgl. dieser Filiale
***> Start of Chnage by Suri : 04.08.2019  20:00:00
***  Des : For Avoiding EAN Validations
*          CALL FUNCTION 'LISTING_CHECK'
*            EXPORTING
*              pi_article      = pit_artikel-matnr
*              pi_vrkme        = pit_artikel-vrkme
*              pi_datab        = g_datab
*              pi_datbi        = g_datbis
*              pi_filia        = pi_filia
*              pi_vkorg        = pi_vkorg
*              pi_vtweg        = pi_vtweg
*              pi_mode         = c_pos_mode
*              pi_ignore_excl  = 'X'
*            TABLES
*              pet_bew_kond    = gt_listung
*            EXCEPTIONS
*              kond_not_found  = 01
*              vrkme_not_found = 02
*              vkdat_not_found = 03.

          CALL FUNCTION 'ZZLISTING_CHECK'
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

***> End of Change by Suri : 04.08.2019  20:00:00
        ENDIF.
        IF sy-subrc = 1. " OSS note 729101
          REFRESH gt_listung. " OSS note 729101
          CLEAR gt_listung. " OSS note 729101
        ENDIF. " OSS note 729101

*       Besorge alle gelisteten Verkaufsmengeneinheiten zum Artikel.
        REFRESH: t_vrkme.
        CLEAR: h_vrkme.
        LOOP AT gt_listung.
          IF gt_listung-vrkme <> h_vrkme.
            h_vrkme = gt_listung-vrkme.
            APPEND gt_listung-vrkme TO t_vrkme.
          ENDIF.                       " GT_LISTUNG-VRKME <> H_VRKME
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

***> Start of Chnage by Suri : 04.08.2019  20:00:00
***  Des : For Avoiding EAN Validations
*           Besorge Artikeldaten und bereite IDOC auf.
*            CALL FUNCTION 'MASTERIDOC_CREATE_DLPART'
*              EXPORTING
*                PI_DEBUG           = PI_DEBUG
**###                  pi_ermod               = pi_filia_const-ermod
**               pi_sallmg          = pi_filia_const-sallmg
*                PI_DLDNR           = G_DLDNR
*                PX_DLDLFDNR        = G_DLDLFDNR
*                PI_VKORG           = PI_VKORG
*                PI_VTWEG           = PI_VTWEG
*                PI_FILIA           = PI_FILIA
*                PI_ARTNR           = PIT_ARTIKEL-MATNR
*                PI_VRKME           = T_VRKME-VRKME
*                PI_DATUM_AB        = G_DATAB
*                PI_DATUM_BIS       = G_DATBIS
*                PI_EXPRESS         = PI_EXPRESS
*                PI_LOESCHEN        = PI_LOESCHEN
*                PI_MODE            = PI_MODE
*                PI_E1WPA02         = E1WPA02
*                PI_E1WPA03         = E1WPA03
*                PI_E1WPA04         = E1WPA04
*                PI_E1WPA05         = E1WPA05
**               pi_e1wpa06         = e1wpa06
*                PI_E1WPA07         = E1WPA07
*                PI_E1WPA08         = E1WPA08
*                PI_E1WPA09         = E1WPA09
*                PI_E1WPA10         = E1WPA10
*                PI_E1WPA11         = E1WPA11
**               pi_vzeit           = pi_filia_const-vzeit
**               pi_spras           = pi_filia_const-spras
*                PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*                PI_FILIA_CONST     = PI_FILIA_CONST
*              IMPORTING
*                PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*              TABLES
*                PIT_LISTUNG        = GT_LISTUNG
**               ###                =
**               löschen            =
**               pit_art_equal      = pit_art_equal
*                PIT_OT3_ARTSTM     = GT_OT3_ARTSTM
*                PIT_WORKDAYS       = GT_WORKDAYS
*              CHANGING
*                PXT_IDOC_DATA      = GT_IDOC_DATA
*              EXCEPTIONS
*                DOWNLOAD_EXIT      = 1.

            CALL FUNCTION 'ZZMASTERIDOC_CREATE_DLPART'
              EXPORTING
                pi_debug           = pi_debug
*###                  pi_ermod               = pi_filia_const-ermod
*               pi_sallmg          = pi_filia_const-sallmg
                pi_dldnr           = g_dldnr
                px_dldlfdnr        = g_dldlfdnr
                pi_vkorg           = pi_vkorg
                pi_vtweg           = pi_vtweg
                pi_filia           = pi_filia
                pi_artnr           = pit_artikel-matnr
                pi_vrkme           = t_vrkme-vrkme
                pi_datum_ab        = g_datab
                pi_datum_bis       = g_datbis
                pi_express         = pi_express
                pi_loeschen        = pi_loeschen
                pi_mode            = pi_mode
                pi_e1wpa02         = e1wpa02
                pi_e1wpa03         = e1wpa03
                pi_e1wpa04         = e1wpa04
                pi_e1wpa05         = e1wpa05
*               pi_e1wpa06         = e1wpa06
                pi_e1wpa07         = e1wpa07
                pi_e1wpa08         = e1wpa08
                pi_e1wpa09         = e1wpa09
                pi_e1wpa10         = e1wpa10
                pi_e1wpa11         = e1wpa11
*               pi_vzeit           = pi_filia_const-vzeit
*               pi_spras           = pi_filia_const-spras
                px_segment_counter = g_segment_counter
                pi_filia_const     = pi_filia_const
              IMPORTING
                px_segment_counter = g_segment_counter
              TABLES
                pit_listung        = gt_listung
*               ###                =
*               löschen            =
*               pit_art_equal      = pit_art_equal
                pit_ot3_artstm     = gt_ot3_artstm
                pit_workdays       = gt_workdays
              CHANGING
                pxt_idoc_data      = gt_idoc_data
              EXCEPTIONS
                download_exit      = 1.

***> End of Change by Suri : 04.08.2019  20:00:00



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
               arttyp = c_artikeltyp
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
            PERFORM status_write_pos USING 'X'         gi_status_pos
                                           g_dldlfdnr  g_returncode.

*           Falls Abbruch bei Fehler erwünscht.
            IF pi_filia_const-ermod <> space.
*             Abbruch des Downloads.
              RAISE download_exit.
            ENDIF.                     " PI_FILIA_CONST-ERMOD = SPACE.

          ENDIF.                       " SY-SUBRC <> 0.
        ENDIF.                         " SY-SUBRC = 0.  keine Listung
      ENDLOOP.                         " AT PIT_ARTIKEL.

*     Falls kein einziger Artikel für diese Filiale gelistet
*     ist und/oder die Artikel von der Versendung für diese Filiale
*     ausgeschlossen wurden (über die Zuordnung
*     Filiale <--> Warengruppe), dann Fehlermeldung.
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
          gi_message-msgno     = '117'.
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
                                   g_mestype_artstm
                                   c_idoctype_artstm
                                   g_segment_counter
                                   g_err_counter
                                   g_firstkey
                                   i_key
                                   g_dldnr
                                   g_dldlfdnr
                                   pi_filia
                                   pi_filia_const.

      ENDIF.                           " G_SEGMENT_COUNTER > 0.
    ENDIF. " PI_MODE = C_INIT_MODE OR ( PI_ART <> SPACE ...

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

*     Schreibe Status-kopfzeile.
      PERFORM status_write_head USING  'X'      gi_status_header
                                       g_dldnr  g_returncode.
    ENDIF.                             " G_STATUS = 0.
  ENDIF.                               " E1WPA01 <> SPACE.


ENDFORM.                               " ARTSTM_DOWNLOAD


*eject.
************************************************************************
FORM artstm_download_change_mode
     TABLES pit_artdel      STRUCTURE gt_artdel
            pit_filter_segs STRUCTURE gt_filter_segs
            pit_ot3_artstm  STRUCTURE gt_ot3_artstm
            pit_workdays    STRUCTURE gt_workdays
     USING  pi_filia_group  STRUCTURE gt_filia_group
            pi_datp3        LIKE syst-datum
            pi_datp4        LIKE syst-datum
            pi_mode         LIKE wpstruc-modus
            pi_dldnr        LIKE wdls-dldnr
            pi_mestype      LIKE edimsg-mestyp.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads des Artikelstamms.                              *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_FILTER_SEGS       : Liste aller für den POS-Download nicht
*                         benötigten Segmente.
* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_DLDNR              : Downloadnummer für Statusverfolgung.

* PI_MESTYPE            : Zu verwendender Nachrichtentyp für
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: e1wpa01       VALUE 'X', " Flag, ob Segm. E1WPA01 vers. werden muß
        e1wpa02       VALUE 'X',
        e1wpa03       VALUE 'X',
        e1wpa04       VALUE 'X',
        e1wpa05       VALUE 'X',
*       e1wpa06   value 'X',
        e1wpa07       VALUE 'X',
        e1wpa08       VALUE 'X',
        e1wpa09       VALUE 'X',
        e1wpa10       VALUE 'X',
        e1wpa11       VALUE 'X',
        art_lines     TYPE i,
        number        LIKE gt_ot3_artstm-number,
        number1       LIKE gt_ot3_artstm-number,
        number2       LIKE gt_ot3_artstm-number,
        h_pmata       LIKE wpaot3-pmata,
        h_tabix       LIKE sy-tabix,
        h_vrkme       LIKE marm-meinh,
        nr_of_groups  TYPE i,
        h_errorcode   LIKE sy-subrc,
        h_skip_record.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Feldleiste für Filialkonstanten.
  DATA: BEGIN OF i_filia_const.
          INCLUDE STRUCTURE wpfilconst.
        DATA: END OF i_filia_const.

* Temporärtabelle für Varianten eines Preisartikels.
  DATA: BEGIN OF t_ot3_artstm OCCURS 0.
          INCLUDE STRUCTURE gt_ot3_artstm.
        DATA: END OF t_ot3_artstm.

**** new data declaration
  DATA: ls_ot3_artstm TYPE wpaot3.
  DATA: ls_filia_group TYPE wpfiliagrp.
  DATA: lt_artdel TYPE tt_artdel.
  DATA: lv_subrc LIKE sy-subrc.

* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  g_current_doctype = c_idoctype_artstm.

* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING pi_filia_group TO i_filia_const.


* Schreibe alle, für den Download Artikelstamm-Stammdaten benötigten,
* Tabellenfelder in eine interne Tabelle.
**** Wurde nur für FB MATERIAL_CHANGE_DOCUMENTATION benötigt.
* perform artstm_fieldtab_fill tables gt_field_tab.

* Prüfe, welche Artikelstammsegmente versendet werden müssen.
  LOOP AT pit_filter_segs.

    CASE pit_filter_segs-segtyp.
      WHEN c_e1wpa01_name.
        CLEAR: e1wpa01.
      WHEN c_e1wpa02_name.
        CLEAR: e1wpa02.
      WHEN c_e1wpa03_name.
        CLEAR: e1wpa03.
      WHEN c_e1wpa04_name.
        CLEAR: e1wpa04.
      WHEN c_e1wpa05_name.
        CLEAR: e1wpa05.
*     when c_e1wpa06_name.
*       clear: e1wpa06.
      WHEN c_e1wpa07_name.
        CLEAR: e1wpa07.
      WHEN c_e1wpa08_name.
        CLEAR: e1wpa08.
      WHEN c_e1wpa09_name.
        CLEAR: e1wpa09.
      WHEN c_e1wpa10_name.
        CLEAR: e1wpa10.
      WHEN c_e1wpa11_name.
        CLEAR: e1wpa11.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
  AND pi_filia_group-pricing_direct_mult_access = abap_true.
    IF pit_artdel IS NOT INITIAL.
      APPEND LINES OF pit_artdel TO lt_artdel.
    ENDIF.
  ENDIF.

* Es müssen Artikelstammdaten versendet werden.
  IF e1wpa01 <> space.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: g_segment_counter, g_new_position, g_status_pos.

*   Rücksetzen Fehler-Zähler.
    CLEAR: g_err_counter, g_firstkey.

*   Merke daß 'Firstkey' gemerkt werden muß.
    g_new_firstkey = 'X'.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-doctyp = c_idoctype_artstm.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                       g_returncode.

*   Bestimme die Anzahl der zu versendenden Artikel.
    DESCRIBE TABLE pit_ot3_artstm LINES art_lines.
    READ TABLE pit_ot3_artstm INDEX art_lines.
    nr_of_groups = pit_ot3_artstm-number.

*   Schleife über alle Objekte dieser Filiale.
    CLEAR: number, g_returncode.

    "switch and multi access optimization activated
    IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true AND pi_filia_group-pricing_direct = abap_true AND pi_filia_group-pricing_direct_mult_access = abap_true.
      "skip all articles of previous packages (if needed)
      "not first package
      IF gv_is_first_article_package = abap_false.
        number = gv_processed_art_lines.

        "increment the number of already processed articles
        gv_processed_art_lines = gv_processed_art_lines + art_lines.
        "first package
      ELSE.
        "just increment the number of already processed articles
        gv_processed_art_lines = gv_processed_art_lines + art_lines.
      ENDIF.
    ENDIF.

    "loop over the articles of this store
    "(unfortunately, the naming of the variables does not fit!)
    WHILE number < nr_of_groups.
      CLEAR: h_pmata, h_skip_record.
      ADD 1 TO number.

*     Besorge die zur Variablen NUMBER gehörende Artikelnummer.
      READ TABLE pit_ot3_artstm WITH KEY
           number = number
           BINARY SEARCH.

      lv_subrc = sy-subrc.

      "switch and multi access optimization activated
*      IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true AND pi_filia_group-pricing_direct = abap_true AND pi_filia_group-pricing_direct_mult_access = abap_true.
      IF lv_subrc <> 0.
        CONTINUE.
      ENDIF.
*      ENDIF.

*     Merken der Tabellenzeile.
      h_tabix = sy-tabix.

*     Falls der Artikel ein Preismaterial hat, dann gehe weiter
*     zum nächsten.
      IF pit_ot3_artstm-pmata <> space                   AND
         pit_ot3_artstm-pmata <> pit_ot3_artstm-artnr.
        CONTINUE.

*     Falls der Artikel ein Preismaterial ist, dann merke die
*     Artikelnummer und die Verkaufsmengeneinheit
      ELSE.
        h_pmata = pit_ot3_artstm-artnr.
        h_vrkme = pit_ot3_artstm-vrkme.
      ENDIF. " pit_ot3_artstm-pmata <> space.

*     Besorge die MARA-Daten des Artikels.
      PERFORM mara_select USING mara pit_ot3_artstm-artnr.

*     Warengruppe ist immer Pflicht.
      IF mara-matkl = space.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-artstm_ign.

*       Falls kein Preismaterial vorliegt.
        IF h_pmata = space.
*         Weiter zum nächsten Satz.
          CONTINUE.
*       Falls ein Preismaterial vorliegt.
        ELSE. " h_pmata <> space.
*         Merken, daß bei einem Preismaterial die Aufbereitung
*         unterbleiben soll.
          h_skip_record = 'X'.
        ENDIF. " h_pmata = space.
      ENDIF. " mara-matkl = space.

*     Falls dieser Artikeltyp nicht in der Kasse gebraucht wird.
      IF ( mara-attyp = c_wrgp_wertartikel       AND
           pi_filia_group-mcat_art IS INITIAL )  OR
         mara-attyp = c_wrgp_hier_wertart        OR
         mara-attyp = c_wrgp_vorlageart.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-artstm_ign.

*       Falls kein Preismaterial vorliegt.
        IF h_pmata = space.
*         Weiter zum nächsten Satz.
          CONTINUE.
*       Falls ein Preismaterial vorliegt.
        ELSE. " h_pmata <> space.
*         Merken, daß bei einem Preismaterial die Aufbereitung
*         unterbleiben soll.
          h_skip_record = 'X'.
        ENDIF. " h_pmata = space.
      ENDIF. " ( mara-attyp = c_wrgp_wertartikel and ...

*     Falls der Artikel aufbereitet werden soll.
      IF h_skip_record = space.
*       Prüfe, ob die Verkaufsmengeneinheit des Artikels
*       POS-relevant ist.
        PERFORM pos_vrkme_relevance_check
                USING  pi_filia_group-vkorg
                       pi_filia_group-vtweg
                       pit_ot3_artstm-artnr
                       pit_ot3_artstm-vrkme
                       mara-meins
                       h_errorcode.

*       Falls die Verkaufsmengeneinheit des Artikels
*       POS-relevant ist.
        IF h_errorcode IS INITIAL.
*         Artikel wird aufbereitet.

          "switch and multi access optimization activated
          IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true AND pi_filia_group-pricing_direct = abap_true AND pi_filia_group-pricing_direct_mult_access = abap_true.
            CLEAR ls_ot3_artstm.
            CLEAR ls_filia_group.

            MOVE-CORRESPONDING pit_ot3_artstm TO ls_ot3_artstm.
            MOVE-CORRESPONDING pi_filia_group TO ls_filia_group.

            "prepare the articles for iDOC creation
            CALL FUNCTION 'ARTICLE_DATA_PREPARE'
              EXPORTING
                it_artdel      = lt_artdel
                is_ot3_artstm  = ls_ot3_artstm
                is_filia_group = ls_filia_group
                is_mara        = mara
                iv_datp4       = pi_datp4
                iv_dldnr       = pi_dldnr
                iv_e1wpa02     = e1wpa02
              CHANGING
                ct_ot3_artstm  = gt_ot3_artstm_collect
                ct_listing     = gt_list_cond_collect.

            "switch not activated or multi access optimization not activated or non-direct read
          ELSE.
            PERFORM artstm_change_mode_proceed
                    TABLES pit_artdel
                           pit_filter_segs
                           pit_ot3_artstm
                           pit_workdays
                    USING  pi_filia_group    mara
                           pi_datp4          pi_mode
                           pi_dldnr          number
                           e1wpa02           e1wpa03
                           e1wpa04           e1wpa05
                           e1wpa07           e1wpa08
                           e1wpa09           e1wpa10
                           e1wpa11           h_tabix.
          ENDIF.     " end of optimization multi access

        ENDIF. " h_errorcode is initial.
      ENDIF. " h_skip_record = space.

*     Falls der Artikel ein Preismaterial ist, dann bestimme die
*     zugehörigen Varianten in PIT_OT3_ARTSTM.
      IF h_pmata <> space.
*       Schleife über alle Varianten.
        CLEAR: number1, number2, t_ot3_artstm.
        REFRESH: t_ot3_artstm.
        LOOP AT pit_ot3_artstm
             WHERE pmata = h_pmata
             AND   vrkme = h_vrkme.

*         Falls diese Variante ein Preismaterial ist und sich selbst
*         als Preismaterial eingetragen hat, dann braucht sie nicht
*         noch einmal aufbereitet zu werden.
          IF pit_ot3_artstm-pmata = pit_ot3_artstm-artnr.
            CONTINUE.
          ENDIF.

          number2 = pit_ot3_artstm-number.

*         Falls eine neue Variante gefunden wurde.
          IF number1 <> number2.
            number1 = number2.

*           Merken der Tabellenzeile.
            h_tabix = sy-tabix.

*           Besorge die MARA-Daten der Variante.
            PERFORM mara_select USING mara pit_ot3_artstm-artnr.

*           Warengruppe ist immer Pflicht.
            IF mara-matkl = space.
*             Aktualisiere Zählvariable für ignorierte Objekte für
*             spätere Statistikausgabe.
              ADD 1 TO gi_stat_counter-artstm_ign.

*             Weiter zum nächsten Satz.
              CONTINUE.
            ENDIF. " mara-matkl = space.

*           Falls dieser Artikeltyp nicht in der Kasse gebraucht wird.
            IF ( mara-attyp = c_wrgp_wertartikel       AND
                 pi_filia_group-mcat_art IS INITIAL )  OR
                 mara-attyp = c_wrgp_hier_wertart      OR
                 mara-attyp = c_wrgp_vorlageart.
*             Aktualisiere Zählvariable für ignorierte Objekte für
*             spätere Statistikausgabe.
              ADD 1 TO gi_stat_counter-artstm_ign.

*             Weiter mit nächstem Satz.
              CONTINUE.
            ENDIF. " ( mara-attyp = c_wrgp_wertartikel and ...

*           Prüfe, ob die Verkaufsmengeneinheit des Artikels
*           POS-relevant ist.
            PERFORM pos_vrkme_relevance_check
                    USING  pi_filia_group-vkorg
                           pi_filia_group-vtweg
                           pit_ot3_artstm-artnr
                           pit_ot3_artstm-vrkme
                           mara-meins
                           h_errorcode.

*           Falls die Verkaufsmengeneinheit des Artikels
*           POS-relevant ist.
            IF h_errorcode IS INITIAL.

              "switch and multi access optimization activated
              IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true AND pi_filia_group-pricing_direct = abap_true AND pi_filia_group-pricing_direct_mult_access = abap_true.
                CLEAR ls_ot3_artstm.
                CLEAR ls_filia_group.

                MOVE-CORRESPONDING pit_ot3_artstm TO ls_ot3_artstm.
                MOVE-CORRESPONDING pi_filia_group TO ls_filia_group.
                APPEND LINES OF pit_artdel TO lt_artdel.

                "prepare the articles for iDOC creation
                CALL FUNCTION 'ARTICLE_DATA_PREPARE'
                  EXPORTING
                    it_artdel      = lt_artdel
                    is_ot3_artstm  = ls_ot3_artstm
                    is_filia_group = ls_filia_group
                    is_mara        = mara
                    iv_datp4       = pi_datp4
                    iv_dldnr       = pi_dldnr
                    iv_e1wpa02     = e1wpa02
                  CHANGING
                    ct_ot3_artstm  = gt_ot3_artstm_collect
                    ct_listing     = gt_list_cond_collect.

                "switch not activated or multi access optimization not activated or non-direct read
              ELSE.
                PERFORM artstm_change_mode_proceed
                        TABLES pit_artdel
                               pit_filter_segs
                               pit_ot3_artstm
                               pit_workdays
                        USING  pi_filia_group    mara
                               pi_datp4          pi_mode
                               pi_dldnr          number2
                               e1wpa02           e1wpa03
                               e1wpa04           e1wpa05
                               e1wpa07           e1wpa08
                               e1wpa09           e1wpa10
                               e1wpa11           h_tabix.
              ENDIF.     " end of optimization multi access

            ENDIF. " h_errorcode is initial.

*           Falls es sich um die gleiche Variante handelt.
          ELSE. " number1 = number2.
*             Weiter mit nächster Variante.
            CONTINUE.
          ENDIF. " number1 <> number2.
        ENDLOOP. " at pit_ot3_artstm

      ENDIF. " h_pmata <> space.
    ENDWHILE.                          " NUMBER < NR_OF_GROUPS.

    "switch and multi access optimization activated
    IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true AND pi_filia_group-pricing_direct = abap_true AND pi_filia_group-pricing_direct_mult_access = abap_true.
      " In case of multi access there is nothing to do here
    ELSE.
*   Erzeuge letztes IDOC, falls nötig .
      IF g_segment_counter > 0.
*     Bestimme 'Lastkey'.
        i_key-matnr = pit_ot3_artstm-artnr.
        i_key-vrkme = pit_ot3_artstm-vrkme.

        PERFORM idoc_create USING  gt_idoc_data
                                   pi_mestype
                                   c_idoctype_artstm
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

    ENDIF.  " end of optimization multi access
  ENDIF.   " E1WPA01 <> SPACE.

ENDFORM. " artstm_download_change_mode


*eject.
************************************************************************
FORM listing_range_get
     TABLES pxt_listung   STRUCTURE gt_listung
     USING  pi_datum_ab   LIKE wpstruc-datum
            pi_datum_bis  LIKE wpstruc-datum
            pi_vrkme      LIKE marm-meinh
            pe_datab_temp LIKE syst-datum
            pe_datbi_temp LIKE syst-datum.
************************************************************************
* FUNKTION:
* Bestimme das Listungsintervall innerhalb des Betrachtungszeitraums.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_LISTUNG    : Listungen des Artikels.

* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.

* PI_DATUM_BIS   : Ende des Betrachtungszeitraums.

* PI_VRKME       : Verkaufsmengeneinheit des Artikels, deren
*                  Listung überprüft werden soll.
* PE_DATAB_TEMP  : Beginn der Listung innerhalb des
*                  Betrachtungszeitraums.
* PE_DATBI_TEMP  : Ende der Listung innerhalb des
*                  Betrachtungszeitraums.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Zeitliche Sortierung der Listungstabelle.
  SORT pxt_listung BY vrkme datab.
* Prüfe, ob und wenn ja, ab wann der Artikel mit dieser VRKME
* innerhalb des Betrachtungszeitraums gelistet ist. Speichern
* in DATAB_TEMP.
  LOOP AT pxt_listung
       WHERE vrkme = pi_vrkme.
    IF pxt_listung-datab <= pi_datum_ab.
      pxt_listung-datab = pi_datum_ab.
      MODIFY pxt_listung.

      pe_datab_temp = pi_datum_ab.
      EXIT.
    ELSE.
      pe_datab_temp = pxt_listung-datab.
      EXIT.
    ENDIF. " PXT_LISTUNG-DATAB <= PI_DATUM_AB.
  ENDLOOP.                             " AT PXT_LISTUNG

* Zeitliche Sortierung der Listungstabelle.
  SORT pxt_listung BY vrkme datbi DESCENDING.

* Prüfe, ob und wenn ja, bis wann der Artikel mit dieser VRKME
* innerhalb des Betrachtungszeitraums gelistet ist. Speichern
* in DATBI_TEMP.
  LOOP AT pxt_listung
       WHERE vrkme = pi_vrkme.
    IF pxt_listung-datbi >= pi_datum_bis.
      pe_datbi_temp = pi_datum_bis.
      EXIT.
    ELSE.
      pe_datbi_temp = pxt_listung-datbi.
      EXIT.
    ENDIF. " PXT_LISTUNG-DATBI >= PI_DATUM_BIS.
  ENDLOOP.                             " AT PXT_LISTUNG
* Resortiere Listungstabelle.
  SORT pxt_listung BY vrkme datab.


ENDFORM.                               " LISTING_RANGE_GET


*eject.
************************************************************************
FORM artstm_fieldtab_fill TABLES pet_field_tab STRUCTURE gt_field_tab.
************************************************************************
* FUNKTION:
* Schreibe alle, für den Download Artikelstamm-Stammdaten benötigten,
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
  CLEAR:   pet_field_tab.

  pet_field_tab-tname = 'MARA'.
  pet_field_tab-fname = 'MATKL'.
  APPEND pet_field_tab.

  pet_field_tab-fname = 'EAN11'.
  APPEND pet_field_tab.

  pet_field_tab-fname = 'PMATA'.
  APPEND pet_field_tab.

  pet_field_tab-fname = 'MHDRZ'.
  APPEND pet_field_tab.

  pet_field_tab-fname = 'MHDHB'.
  APPEND pet_field_tab.

  pet_field_tab-tname = 'MARM'.
  pet_field_tab-fname = 'EAN11'.
  APPEND pet_field_tab.

  pet_field_tab-tname = 'MAMT'.
  pet_field_tab-fname = 'MAKTM'.
  APPEND pet_field_tab.

  pet_field_tab-tname = 'MAKT'.
  pet_field_tab-fname = 'MAKTX'.
  APPEND pet_field_tab.

ENDFORM.                               " ARTSTM_FIELDTAB_FILL


*eject.
************************************************************************
FORM gt_kondart_fill TABLES pet_kondart     STRUCTURE gt_kondart
                            pit_filia_group STRUCTURE gt_filia_group.
************************************************************************
* FUNKTION:
* Schreibe alle POS-relevanten Konditionsarten für eine Filialgruppe
* in eine interne Tabelle.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KONDART      : Tabelle der POS-relevanten Konditionsarten.

* PIT_FILIA_GROUP  : Tabelle der Filialkonstanten einer Filialgruppe.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF t_kondart OCCURS 10.
*         include structure wpkartflag.
          INCLUDE STRUCTURE wpkartflag_v.
        DATA: END OF t_kondart.


  REFRESH: pet_kondart.
  LOOP AT pit_filia_group.
*   Besorge alle POS-relevanten Konditionsarten für diese Filiale
    CALL FUNCTION 'POS_CUST_ALLOWED_COND_READ'
      EXPORTING
        i_locnr               = pit_filia_group-kunnr
        i_flag_wrf1_lesen     = ' '
        i_kopro               = pit_filia_group-kopro
        i_flag_twpfi_lesen    = ' '
        i_ekoar               = pit_filia_group-ekoar
      TABLES
*       o_kschl               = t_kondart
        o_kschl_v             = t_kondart
      EXCEPTIONS
        filiale_unbekannt     = 1
        no_conditions_allowed = 2
        OTHERS                = 3.

*   Übernehme Konditionsarten in Ausgabetabelle.
    pet_kondart-filia = pit_filia_group-filia.
    pet_kondart-locnr = pit_filia_group-kunnr.
    LOOP AT t_kondart.
      MOVE-CORRESPONDING t_kondart TO pet_kondart.
      APPEND pet_kondart.
    ENDLOOP.                           " AT T_KONDART.

  ENDLOOP.                             " AT PIT_FILIA.

* Daten sortieren.
  SORT pet_kondart BY filia kschl.


ENDFORM.                               " GT_KONDART_FILL


*eject
************************************************************************
FORM matdata_get_and_analyse
     TABLES pet_imara        STRUCTURE gt_imara
            pet_imarm        STRUCTURE gt_imarm
            pet_imakt        STRUCTURE gt_imakt
            pet_imamt        STRUCTURE gt_imamt
            pxt_orgtab       STRUCTURE gt_orgtab_artstm
            pit_listung      STRUCTURE gt_listung
            pit_ot3          STRUCTURE gt_ot3_artstm
            pet_wlk2dat      STRUCTURE gt_wlk2dat
            pet_tvms         STRUCTURE gt_tvms
            pet_t134         STRUCTURE gt_t134
            pet_wrf6         STRUCTURE gt_wrf6
     USING  pi_artnr         LIKE wlk2-matnr
            pi_vkorg         LIKE wpstruc-vkorg
            pi_vtweg         LIKE wpstruc-vtweg
            pi_vrkme         LIKE wlk1-vrkme
            pi_filia_const   STRUCTURE  wpfilconst
            pi_datab         LIKE syst-datum
            pi_datbi         LIKE syst-datum
            pi_filia         LIKE t001w-werks
            pi_mode          LIKE wpstruc-modus
   CHANGING VALUE(pe_fehlercode) LIKE g_returncode
            pi_dldnr         LIKE wdls-dldnr
            pi_dldlfdnr      LIKE wdlsp-lfdnr
            pi_segment_counter LIKE g_segment_counter
            pi_initdat       LIKE syst-datum
            pe_ean           LIKE marm-ean11
            pi_e1wpa02       LIKE wpstruc-modus
            pi_e1wpa03       LIKE wpstruc-modus
            pi_e1wpa04       LIKE wpstruc-modus
            pi_loeschen      LIKE wpstruc-modus
            pe_no_price_send LIKE wpstruc-modus
            pe_pmata         LIKE mara-pmata.
************************************************************************
* FUNKTION:
* Lese die Daten für Download Artikelstamm-Stammdaten im Zeitintervall
* PI_DATAB - PI_DATBI, analysiere diese und fülle Organisationstabelle.
* Im Änderungs- oder Restart-Fall werden auch die Tabellen
* PIT_LISTUNG und PIT_OT3 analysiert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_IMARA     : Tabelle für MARA-Daten.

* PET_IMARM     : Tabelle für MARM-Daten.

* PET_IMAKT     : Tabelle für MAKT-Daten.

* PET_IMAMT     : Tabelle für MAMT-Daten.

* PXT_ORGTAB    : Organisationstabelle für Artikelstamm.

* PIT_LISTUNG   : Listungen des Artikels.

* PIT_OT3       : Artikelstamm: Objekttabelle 3.

* PET_WKL2DAT   : Tabelle für WLK2-Daten.

* PET_TVMS      : Tabelle für TVMS-Daten.

* PET_T134      : Tabelle für T134-Daten.

* PET_WRF6      : Tabelle für WRF6-Daten.

* PI_ARTNR      : Material der Selektion.

* PI_VKORG      : Verkaufsorganisation der Selektion.

* PI_VTWEG      : Vertriebsweg der Selektion.

* PI_VRKME      : Verkaufsmengeneinheit der Selektion.

* PI_FILIA_CONST: Filialkonstanten.

* PI_DATAB      : Beginndatum der Selektion.

* PI_DATBI      : Endedatum der Selektion.

* PI_FILIA      : Filiale.

* PI_MODE       : Download-Modus.

* PE_FEHLERCODE : > 0, wenn Datenbeschaffung mißlungen, sonst '0'.

* PI_DLDNR      : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR   : Laufende Nr. der Positionszeile für Statusverfolgung.

* PI_SEGMENT_COUNTER: Segmentzähler.

* PI_INITDAT   : Datum, ab wann initialisiert werden soll. Ist nur
*                für Änderungs- und Restart-Fall relevant.
* PE_EAN       : Haupt-EAN der jeweiligen Verkaufsmengeneinheit des
*                Artikels.
* PI_E1WPA02   : = 'X', wenn Segment E1WPA02 aufbereitet werden soll.

* PI_E1WPA03   : = 'X', wenn Segment E1WPA03 aufbereitet werden soll.

* PI_E1WPA04   : = 'X', wenn Segment E1WPA04 aufbereitet werden soll.

* PI_LOESCHEN  : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                       sollen, sonst SPACE.
* PE_NO_PRICE_SEND: = 'X', wenn kein Preis versendet werden soll.

* PE_PMATA     : Preismaterial des Artikels (falls vorhanden)
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: no_record_found_mara,
        no_record_found_marm,
        no_record_found_mamt,
        no_record_found_makt,
        readindex            TYPE i,
        mtart                LIKE mara-mtart,
        fehlercode           LIKE sy-subrc,
        h_datum              LIKE sy-datum,
        h_found1             LIKE wpmara-chgflag,
        h_found2             LIKE wpmara-chgflag,
        h_found3             LIKE wpmara-chgflag.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Nur Als Dummy
  DATA: BEGIN OF t_mara OCCURS 1.
          INCLUDE STRUCTURE wpmara.
        DATA: END OF t_mara.

* Nur Als Dummy
  DATA: BEGIN OF t_makt OCCURS 1.
          INCLUDE STRUCTURE wpmakt.
        DATA: END OF t_makt.

* Nur Als Dummy
  DATA: BEGIN OF t_mamt OCCURS 1.
          INCLUDE STRUCTURE wpmamt.
        DATA: END OF t_mamt.

* Zur Bestimmung der ersten zu merkenden EAN für Änderungsfall.
  DATA: BEGIN OF t_marm OCCURS 1.
          INCLUDE STRUCTURE wpmarm.
        DATA: END OF t_marm.

  DATA: BEGIN OF t_wrgp OCCURS 1.
          INCLUDE STRUCTURE wrf6.
        DATA: END OF t_wrgp.


* Initialisieren der Datentabellen
  REFRESH: pet_wrf6.
  CLEAR:   pet_wrf6.
  CLEAR:   pxt_orgtab, pe_fehlercode.

* Merken des aktuellen Schlüssels.
  i_key-matnr = pi_artnr.
  i_key-vrkme = pi_vrkme.

  PERFORM artstm_matdata_get
                 TABLES   pet_imara
                          pet_imarm
                          pet_imakt
                          pet_imamt
                 USING    pi_artnr    pi_vrkme    pi_filia_const-spras
                          pi_datab    pi_datbi    pi_mode
                          no_record_found_marm    no_record_found_makt
                          no_record_found_mamt    pi_filia_const
                          pi_e1wpa03
                 CHANGING fehlercode.

* Falls keine Artikelstammdaten gelesen werden konnten.
  IF fehlercode <> 0 OR no_record_found_marm <> space.
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
      ENDIF.  " no_record_found_mara <> space.

*     Setze Fehlercode auf fehlerhaft.
      pe_fehlercode = 1.

*     Schreibe Fehlerzeile für Application-Log und WDLSO.
      g_object_key = i_key.
      PERFORM appl_log_write_single_message USING  gi_message.

    ENDIF.                     " PI_FILIA_CONST-ERMOD = SPACE.

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
    IF pi_filia_const-ermod = space.
*     Verlassen der Aufbereitung, falls Einlesefehler.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_FILIA_CONST-_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.

* Falls keine Artikeltexte gelesen werden konnten aber
* welche versendet werden sollen.
  ELSEIF fehlercode = 0                  AND
         no_record_found_marm = space    AND
         pi_loeschen          = space    AND
         pi_e1wpa03 <> space AND  no_record_found_makt <> space.
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
        PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*       Merke, daß Fehlerprotokoll initialisiert wurde.
        g_init_log = 'X'.
      ENDIF.                           " G_INIT_LOG = SPACE.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      CLEAR: gi_message.
      gi_message-msgty     = c_msgtp_error.
      gi_message-msgid     = c_message_id.
      gi_message-probclass = c_probclass_sehr_wichtig.

*     'Keine Texte zum Mat. & für VRKME & und Sprache & im Mat.Stamm
*     gepflegt'.
      gi_message-msgno     = '121'.
      gi_message-msgv1     = pi_artnr.
      gi_message-msgv2     = pi_vrkme.
      gi_message-msgv3     = pi_filia_const-spras.

*     Setze Fehlercode auf fehlerhaft.
      pe_fehlercode = 1.

*     Schreibe Fehlerzeile für Application-Log und WDLSO.
      g_object_key = i_key.
      PERFORM appl_log_write_single_message USING  gi_message.

    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.

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
    IF pi_filia_const-ermod = space.
*     Verlassen der Aufbereitung, falls Einlesefehler.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_FILIA_CONST-ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE download_exit.
    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.
  ENDIF. " no_record_found_mara <> space or ...


* Analysiere Materialstamm-Stammdaten und ergänze Org.Tabelle.

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

* Falls Löschmodus aktiv, dann MARA-Anlyse nicht nötig.
  IF pi_loeschen = space.
*   Analysieren Daten aus MARA.
    LOOP AT pet_imara.
      IF sy-tabix = 1.
*       Merke Preismaterial.
        pe_pmata = pet_imara-pmata.

*       Zwischenspeichern der Materialart, für Zugriff auf Tabelle T134.
        mtart = pet_imara-mtart.

*       Das Datum für den ersten Satz darf nicht initial sein.
        IF pet_imara-datum < pi_datab.
          pet_imara-datum = pi_datab.
          MODIFY pet_imara.
        ENDIF.                           " PET_IMARA-DATUM < pi_datab.

*       Vermerke 1. Satz in Org.Tabelle
        READ TABLE pxt_orgtab INDEX 1.
        pxt_orgtab-mara  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_imara-datum.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMARA-DATUM.
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Vermerke in Org.Tabelle, daß der erste Satz
*         versendet werden soll.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX 1.

*       Falls Segment E1WPA02 (Artikelstamm-Stammdaten)
*       gefüllt werden muß.
        IF pi_e1wpa02 <> space.
*         Besorge zugehörige WRF6-Daten (Mehrwertsteuerflag).
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
            EXPORTING
              pi_filiale     = pi_filia_const-kunnr
              pi_warengruppe = pet_imara-matkl
            TABLES
              pe_t_wrf6      = t_wrgp
            EXCEPTIONS
              no_wrf6_record = 01
              no_wrgp_found  = 02.

*         Falls keine Lesefehler auftraten.
          IF sy-subrc = 0.
            READ TABLE t_wrgp INDEX 1.
            CLEAR: pet_wrf6.
            pet_wrf6-datum = pet_imara-datum.
            pet_wrf6-primw = t_wrgp-primw.
            APPEND pet_wrf6.

*         Falls Lesefehler auftraten.
          ELSE.                            " SY-SUBRC <> 0.
*           Falls kein Verkauf über alle Warengruppen.
            IF pi_filia_const-sallmg IS INITIAL.
*             Falls Fehlerprotokollierung erwünscht.
              IF pi_filia_const-ermod = space.
*               Falls noch keine Initialisierung des Fehlerprotokolls.
                IF g_init_log = space.
*                 Aufbereitung der Parameter zum schreiben des Headers
*                 des Fehlerprotokolls.
                  CLEAR: gi_errormsg_header.
                  gi_errormsg_header-object        = c_applikation.
                  gi_errormsg_header-subobject     = c_subobject.
                  gi_errormsg_header-extnumber     = pi_dldnr.
                  gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
                  gi_errormsg_header-aluser        = sy-uname.

*                 Initialisiere Fehlerprotokoll und erzeuge Header.
                  PERFORM appl_log_init_with_header
                          USING gi_errormsg_header.

*                 Merke, daß Fehlerprotokoll initialisiert wurde.
                  g_init_log = 'X'.
                ENDIF.                       " G_INIT_LOG = SPACE.

*               Bereite Parameter zum schreiben der Fehlerzeile auf.
                CLEAR: gi_message.
                gi_message-msgty     = c_msgtp_error.
                gi_message-msgid     = c_message_id.
                gi_message-probclass = c_probclass_sehr_wichtig.
*               'Keine Zuordnung der Filiale & zur Warengruppe
*                & gepflegt'
                gi_message-msgno     = '159'.
                gi_message-msgv1     = pi_filia.
                gi_message-msgv2     = pet_imara-matkl.
                gi_message-msgv3     = pet_imara-matnr.

*               Schreibe Fehlerzeile für Application-Log und WDLSO.
                g_object_key = i_key.
                PERFORM appl_log_write_single_message USING  gi_message.
              ENDIF.                   " PI_FILIA_CONST-ERMOD = SPACE.

*             Ändern der Status-Kopfzeile, falls nötig.
              IF g_status < 3.               " 'Fehlende Daten'
                CLEAR: gi_status_header.
                gi_status_header-dldnr = pi_dldnr.
                gi_status_header-gesst = c_status_fehlende_daten.

*               Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                PERFORM status_write_head USING  'X'  gi_status_header
                                                 pi_dldnr  g_returncode.

*               Aktualisiere Aufbereitungsstatus.
                g_status = 3.                " 'Fehlende Daten'
              ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*             Aufbereiten der Parameter zum Ändern der
*             Status-Positionszeile.
              CLEAR: gi_status_pos.
              gi_status_pos-dldnr  = pi_dldnr.
              gi_status_pos-lfdnr  = pi_dldlfdnr.
              gi_status_pos-anloz  = g_err_counter.
              gi_status_pos-anseg  = pi_segment_counter.
              gi_status_pos-stkey  = g_firstkey.
              gi_status_pos-ltkey  = i_key.

*             Aktualisiere Aufbereitungsstatus für Positionszeile,
*             falls nötig.
              IF g_status_pos < 3.                   " 'Fehlende Daten'
                gi_status_pos-gesst = c_status_fehlende_daten.

                g_status_pos = 3.                    " 'Fehlende Daten'
              ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*             Schreibe Status-Positionszeile.
              PERFORM status_write_pos USING 'X' gi_status_pos
                                             pi_dldlfdnr g_returncode.
*             Falls Abbruch bei Fehler erwünscht.
              IF pi_filia_const-ermod <> space.
*               Abbruch des Downloads.
                RAISE download_exit.
*             Falls Fehlerprotokollierung erwünscht.
              ELSE.                    " PI_FILIA_CONST-ERMOD = SPACE
*              Hier ist nichts zu tun, da bei tollerierbaren Fehler
*              kein Abrruch der Verarbeitung stattfinden soll
              ENDIF.                   " PI_FILIA_CONST-ERMOD <> SPACE.

*           Falls der Verkauf über alle Warengruppen erwünscht ist.
            ELSE. " not PI_FILIA_CONST-sallmg is initial.
*             Setze Standardmäßig das Kennzeichen für
*             'Preis incl. MwSt' auf initial.
              CLEAR: pet_wrf6.
              pet_wrf6-datum = pet_imara-datum.
              pet_wrf6-primw = t_wrgp-primw.
              APPEND pet_wrf6.

*             Falls Fehlerprotokollierung erwünscht.
              IF pi_filia_const-ermod = space.
*               Falls noch keine Initialisierung des Fehlerprotokolls.
                IF g_init_log = space.
*                 Aufbereitung der Parameter zum schreiben des Headers
*                 des Fehlerprotokolls.
                  CLEAR: gi_errormsg_header.
                  gi_errormsg_header-object        = c_applikation.
                  gi_errormsg_header-subobject     = c_subobject.
                  gi_errormsg_header-extnumber     = pi_dldnr.
                  gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
                  gi_errormsg_header-aluser        = sy-uname.

*                 Initialisiere Fehlerprotokoll und erzeuge Header.
                  PERFORM appl_log_init_with_header
                          USING gi_errormsg_header.

*                 Merke, daß Fehlerprotokoll initialisiert wurde.
                  g_init_log = 'X'.
                ENDIF.                       " G_INIT_LOG = SPACE.

*               Bereite Parameter zum schreiben der Hinweiszeile auf.
                CLEAR: gi_message.
                gi_message-msgty     = c_msgtp_warning.
                gi_message-msgid     = c_message_id.
                gi_message-probclass = c_probclass_weniger_wichtig.
*               'Keine Zuordnung der Filiale & zur Warengruppe
*                & gepflegt'
                gi_message-msgno     = '160'.
                gi_message-msgv1     = pi_filia.
                gi_message-msgv2     = pet_imara-matkl.
                gi_message-msgv3     = pet_imara-matnr.

*               Schreibe Fehlerzeile für Application-Log und WDLSO.
                CLEAR: g_object_key.
                PERFORM appl_log_write_single_message USING  gi_message.
              ENDIF.                 " PI_FILIA_CONST-ERMOD = SPACE.

*             Ändern der Status-Kopfzeile, falls nötig.
              IF g_status < 2.                   " 'Benutzerhinweis'
                CLEAR: gi_status_header.
                gi_status_header-dldnr = pi_dldnr.
                gi_status_header-gesst = c_status_benutzerhinweis.

*               Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                PERFORM status_write_head
                       USING  'X'  gi_status_header
                              pi_dldnr  g_returncode.

*               Aktualisiere Aufbereitungsstatus.
                g_status = 2.                  " 'Benutzerhinweis'
              ENDIF. " G_STATUS < 2.             " 'Benutzerhinweis'

*             Aufbereiten der Parameter zum Ändern der
*             Status-Positionszeile.
              CLEAR: gi_status_pos.
              gi_status_pos-dldnr  = pi_dldnr.
              gi_status_pos-lfdnr  = pi_dldlfdnr.
              gi_status_pos-anloz  = g_err_counter.
              gi_status_pos-anseg  = pi_segment_counter.
              gi_status_pos-stkey  = g_firstkey.
              gi_status_pos-ltkey  = i_key.

*             Aktualisiere Aufbereitungsstatus für Positionszeile,
*             falls nötig.
              IF g_status_pos < 2.              " 'Benutzerhinweis'.
                gi_status_pos-gesst = c_status_benutzerhinweis.

                g_status_pos = 2.               " 'Benutzerhinweis'.
              ENDIF. " g_status_pos < 2.       " 'Benutzerhinweis'.

*             Schreibe Status-Positionszeile.
              PERFORM status_write_pos USING 'X' gi_status_pos
                                             pi_dldlfdnr g_returncode.

*             Falls Abbruch bei Fehler erwünscht.
              IF pi_filia_const-ermod <> space.
*               Abbruch des Downloads.
                RAISE download_exit.
*             Falls Fehlerprotokollierung erwünscht.
              ELSE.                " PI_FILIA_CONST-ERMOD = SPACE.
*               Hier ist nichts zu tun, da bei tollerierbaren Fehler
*               kein Abrruch der Verarbeitung stattfinden soll
              ENDIF.               " PI_FILIA_CONST-ERMOD <> SPACE.
            ENDIF. " PI_FILIA_CONST-sallmg is initial.
          ENDIF.                           " SY-SUBRC <> 0.
        ENDIF. " pi_E1WPA02 <> space.

      ELSE.                              " SY-TABIX > 1.
*       Falls eine POS-relevante Änderung gefunden wurde, so wird
*       dies in der Org.Tabelle vermerkt.
        IF pet_imara-chgflag <> space.
          readindex = pet_imara-datum - pi_datab + 1.
          READ TABLE pxt_orgtab INDEX readindex.
          pxt_orgtab-mara  = 'X'.

*         Falls Änderungsfall.
          IF pi_mode = c_change_mode.
*           Falls initialisiert werden soll, vermerke dies
*           in Org.Tabelle.
            IF pi_initdat <> space AND pi_initdat <= pet_imara-datum.
              pxt_orgtab-change = 'X'.
            ENDIF. " PI_INITDAT <> SPACE AND ...
*         Falls Initialisierungsfalls oder direkte Anforderung.
          ELSE.
*           Falls eine POS-relevante Änderung gefunden wurde, so wird
*           dies in der Org.Tabelle vermerkt.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_MODE = C_CHANGE_MODE.

          MODIFY pxt_orgtab INDEX readindex.

*         Falls Segment E1WPA02 (Artikelstamm-Stammdaten)
*         gefüllt werden muß.
          IF pi_e1wpa02 <> space.
*           Besorge zugehörige WRF6-Daten (Mehrwertsteuerflag).
            CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
              EXPORTING
                pi_filiale     = pi_filia_const-kunnr
                pi_warengruppe = pet_imara-matkl
              TABLES
                pe_t_wrf6      = t_wrgp
              EXCEPTIONS
                no_wrf6_record = 01
                no_wrgp_found  = 02.

*           Falls keine Lesefehler auftraten.
            IF sy-subrc = 0.
              READ TABLE t_wrgp INDEX 1.
              CLEAR: pet_wrf6.
              pet_wrf6-datum = pet_imara-datum.
              pet_wrf6-primw = t_wrgp-primw.
              APPEND pet_wrf6.
*           Falls Lesefehler auftraten.
            ELSE.                          " SY-SUBRC <> 0.
*             Falls kein Verkauf über alle Warengruppen.
              IF pi_filia_const-sallmg IS INITIAL.
*               Falls Fehlerprotokollierung erwünscht.
                IF pi_filia_const-ermod = space.
*                 Falls noch keine Initialisierung des Fehlerprotokolls.
                  IF g_init_log = space.
*                   Aufbereitung der Parameter zum schreiben des Headers
*                   des Fehlerprotokolls.
                    CLEAR: gi_errormsg_header.
                    gi_errormsg_header-object        = c_applikation.
                    gi_errormsg_header-subobject     = c_subobject.
                    gi_errormsg_header-extnumber     = pi_dldnr.
                    gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
                    gi_errormsg_header-aluser        = sy-uname.

*                   Initialisiere Fehlerprotokoll und erzeuge Header.
                    PERFORM appl_log_init_with_header
                            USING gi_errormsg_header.

*                   Merke, daß Fehlerprotokoll initialisiert wurde.
                    g_init_log = 'X'.
                  ENDIF.                       " G_INIT_LOG = SPACE.

*                 Bereite Parameter zum schreiben der Fehlerzeile auf.
                  CLEAR: gi_message.
                  gi_message-msgty     = c_msgtp_error.
                  gi_message-msgid     = c_message_id.
                  gi_message-probclass = c_probclass_sehr_wichtig.
*                 'Keine Zuordnung der Filiale & zur Warengruppe
*                  & gepflegt'
                  gi_message-msgno     = '159'.
                  gi_message-msgv1     = pi_filia.
                  gi_message-msgv2     = pet_imara-matkl.
                  gi_message-msgv3     = pet_imara-matnr.

*                 Schreibe Fehlerzeile für Application-Log und WDLSO.
                  g_object_key = i_key.
                  PERFORM appl_log_write_single_message
                          USING  gi_message.
                ENDIF.                    " PI_FILIA_CONST-ERMOD = SPACE

*               Ändern der Status-Kopfzeile, falls nötig.
                IF g_status < 3.               " 'Fehlende Daten'
                  CLEAR: gi_status_header.
                  gi_status_header-dldnr = pi_dldnr.
                  gi_status_header-gesst = c_status_fehlende_daten.

*                 Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                  PERFORM status_write_head
                          USING  'X'  gi_status_header
                                 pi_dldnr  g_returncode.

*                 Aktualisiere Aufbereitungsstatus.
                  g_status = 3.                " 'Fehlende Daten'
                ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*               Aufbereiten der Parameter zum Ändern der
*               Status-Positionszeile.
                CLEAR: gi_status_pos.
                gi_status_pos-dldnr  = pi_dldnr.
                gi_status_pos-lfdnr  = pi_dldlfdnr.
                gi_status_pos-anloz  = g_err_counter.
                gi_status_pos-anseg  = pi_segment_counter.
                gi_status_pos-stkey  = g_firstkey.
                gi_status_pos-ltkey  = i_key.

*               Aktualisiere Aufbereitungsstatus für Positionszeile,
*               falls nötig.
                IF g_status_pos < 3.                   " 'Fehlende Daten'
                  gi_status_pos-gesst = c_status_fehlende_daten.

                  g_status_pos = 3.                    " 'Fehlende Daten'
                ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*               Schreibe Status-Positionszeile.
                PERFORM status_write_pos USING 'X' gi_status_pos
                                               pi_dldlfdnr g_returncode.
*               Falls Abbruch bei Fehler erwünscht.
                IF pi_filia_const-ermod <> space.
*                 Abbruch des Downloads.
                  RAISE download_exit.
*               Falls Fehlerprotokollierung erwünscht.
                ELSE.              " PI_FILIA_CONST-ERMOD = SPACE.
*                Hier ist nichts zu tun, da bei tollerierbaren Fehler
*                kein Abrruch der Verarbeitung stattfinden soll
                ENDIF.             " PI_FILIA_CONST-ERMOD <> SPACE.

*             Falls der Verkauf über alle Warengruppen erwünscht ist.
              ELSE. " not PI_FILIA_CONST-sallmg is initial.
*               Setze Standardmäßig das Kennzeichen für
*               'Preis incl. MwSt' auf initial.
                CLEAR: pet_wrf6.
                pet_wrf6-datum = pet_imara-datum.
                pet_wrf6-primw = t_wrgp-primw.
                APPEND pet_wrf6.

*               Falls Fehlerprotokollierung erwünscht.
                IF pi_filia_const-ermod = space.
*                 Falls noch keine Initialisierung des Fehlerprotokolls.
                  IF g_init_log = space.
*                   Aufbereitung der Parameter zum schreiben des Headers
*                   des Fehlerprotokolls.
                    CLEAR: gi_errormsg_header.
                    gi_errormsg_header-object        = c_applikation.
                    gi_errormsg_header-subobject     = c_subobject.
                    gi_errormsg_header-extnumber     = pi_dldnr.
                    gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
                    gi_errormsg_header-aluser        = sy-uname.

*                   Initialisiere Fehlerprotokoll und erzeuge Header.
                    PERFORM appl_log_init_with_header
                            USING gi_errormsg_header.

*                   Merke, daß Fehlerprotokoll initialisiert wurde.
                    g_init_log = 'X'.
                  ENDIF.                       " G_INIT_LOG = SPACE.

*                 Bereite Parameter zum schreiben der Hinweiszeile auf.
                  CLEAR: gi_message.
                  gi_message-msgty     = c_msgtp_warning.
                  gi_message-msgid     = c_message_id.
                  gi_message-probclass = c_probclass_weniger_wichtig.
*                 'Keine Zuordnung der Filiale & zur Warengruppe
*                  & gepflegt'
                  gi_message-msgno     = '160'.
                  gi_message-msgv1     = pi_filia.
                  gi_message-msgv2     = pet_imara-matkl.
                  gi_message-msgv3     = pet_imara-matnr.

*                 Schreibe Fehlerzeile für Application-Log und WDLSO.
                  CLEAR: g_object_key.
                  PERFORM appl_log_write_single_message
                          USING  gi_message.
                ENDIF.                 " PI_FILIA_CONST-ERMOD = SPACE.

*               Ändern der Status-Kopfzeile, falls nötig.
                IF g_status < 2.                   " 'Benutzerhinweis'
                  CLEAR: gi_status_header.
                  gi_status_header-dldnr = pi_dldnr.
                  gi_status_header-gesst = c_status_benutzerhinweis.

*                 Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                  PERFORM status_write_head
                         USING  'X'  gi_status_header
                                pi_dldnr  g_returncode.

*                 Aktualisiere Aufbereitungsstatus.
                  g_status = 2.                  " 'Benutzerhinweis'
                ENDIF. " G_STATUS < 2.             " 'Benutzerhinweis'

*               Aufbereiten der Parameter zum Ändern der
*               Status-Positionszeile.
                CLEAR: gi_status_pos.
                gi_status_pos-dldnr  = pi_dldnr.
                gi_status_pos-lfdnr  = pi_dldlfdnr.
                gi_status_pos-anloz  = g_err_counter.
                gi_status_pos-anseg  = pi_segment_counter.
                gi_status_pos-stkey  = g_firstkey.
                gi_status_pos-ltkey  = i_key.

*               Aktualisiere Aufbereitungsstatus für Positionszeile,
*               falls nötig.
                IF g_status_pos < 2.              " 'Benutzerhinweis'.
                  gi_status_pos-gesst = c_status_benutzerhinweis.

                  g_status_pos = 2.               " 'Benutzerhinweis'.
                ENDIF. " g_status_pos < 2.       " 'Benutzerhinweis'.

*               Schreibe Status-Positionszeile.
                PERFORM status_write_pos USING 'X' gi_status_pos
                                               pi_dldlfdnr g_returncode.

*               Falls Abbruch bei Fehler erwünscht.
                IF pi_filia_const-ermod <> space.
*                 Abbruch des Downloads.
                  RAISE download_exit.
*               Falls Fehlerprotokollierung erwünscht.
                ELSE.          " PI_FILIA_CONST-ERMOD = SPACE.
*                 Hier ist nichts zu tun, da bei tollerierbaren Fehler
*                 kein Abrruch der Verarbeitung stattfinden soll
                ENDIF.         " PI_FILIA_CONST-ERMOD <> SPACE.
              ENDIF. " PI_FILIA_CONST-sallmg is initial.
            ENDIF.                         " SY-SUBRC <> 0.
          ENDIF. " pi_E1WPA02 <> space.
        ENDIF.                           " PET_IMARA-CHGFLAG <> SPACE.
      ENDIF.                             " SY-TABIX = 1.
    ENDLOOP.                             " AT PET_IMARA.
  ENDIF. " pi_loeschen = space.

* Analysieren Daten aus MARM.
  LOOP AT pet_imarm.
*   Das Datum für den ersten Satz darf nicht initial sein.
    IF pet_imarm-datum < pi_datab.
      pet_imarm-datum = pi_datab.
      MODIFY pet_imarm.
    ENDIF.                           " PET_IMARM-DATUM < pi_datab.

*   Sonderbehandlung für den Tag der ersten Änderung.
    IF sy-tabix = 1.
*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Prüfe, ob die erste EAN bereits gemerkt wurde.
        READ TABLE gt_old_ean WITH KEY
                   artnr = pet_imarm-matnr
                   vrkme = pet_imarm-meinh
                   datum = pet_imarm-datum
                   BINARY SEARCH.

        IF sy-subrc = 0.
          pe_ean = gt_old_ean-ean11.

*       Die alte EAN wurde noch nicht zwischengespeichert d. h.,
*       wenn eine Haupt-EAN-Änderung stattfinden soll, dann kann
*       dies nur in der Zukunft passieren, denn sonst wäre ein
*       Eintrag vorhanden (siehe EAN-Analyse für Änderungsfall).
*       Daher übernehme die EAN vom Vortag der ersten Änderung.
        ELSE. " if sy-subrc <> 0.
          h_datum = pet_imarm-datum - 1.

*         Falls eine zukünftige EAN-Änderung stattfinden kann.
          IF h_datum >= sy-datum.
*           Lese zukünftige EAN vom Vortag der ersten Änderung.
            PERFORM artstm_matdata_get
                    TABLES   t_mara
                             t_marm
                             t_makt
                             t_mamt
                    USING    pi_artnr   pi_vrkme   pi_filia_const-spras
                             h_datum    h_datum    pi_mode
                             h_found1   h_found2   h_found3
                             pi_filia_const        pi_e1wpa03
                    CHANGING fehlercode.

*           Falls vorher schon eine EAN vorhanden war.
            IF t_marm-ean11 <> space.
              pe_ean = t_marm-ean11.
*           Falls vorher noch keine EAN vorhanden war, dann kein
*           Lösch-Satz.
            ELSE. " t_marm-ean11 = space.
              pe_ean = pet_imarm-ean11.
            ENDIF. " t_marm-ean11 <> space.

*         Es soll zum Tag der ersten Änderung keine Haupt-EAN-Änd.
*         stattfinden. Daher Behandlung wie Initialisierungfall.
          ELSE. " h_datum < sy-datum.
*           Speichere Haupt-EAN dieser Verkaufsmengeneinheit.
            pe_ean = pet_imarm-ean11.
          ENDIF. " h_datum >= sy-datum.
        ENDIF. " sy-subrc = 0.

*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      ELSE.
*       Speichere Haupt-EAN dieser Verkaufsmengeneinheit.
        pe_ean = pet_imarm-ean11.
      ENDIF. " pi_mode = c_change_mode

*     Vermerke in Org.Tabelle das Lesen des ersten Satzes.
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

* Falls Löschmodus aktiv, dann weitere Aufbereitung nicht nötig.
  IF pi_loeschen <> space.
    EXIT.
  ENDIF. " pi_loeschen <> space.

* Falls Segment E1WPA03 (Artikeltexte) gefüllt werden muß.
  IF pi_e1wpa03 <> space.
*   Analysieren Daten aus MAKT.
    LOOP AT pet_imakt.
*     Das Datum für den ersten Satz darf nicht initial sein.
      IF pet_imakt-datum < pi_datab.
        pet_imakt-datum = pi_datab.
        MODIFY pet_imakt.
      ENDIF.                             " PET_IMAKT-DATUM < pi_datab.

*     Vermerke in Org.Tabelle das Lesen des ersten Satzes.
      IF sy-tabix = 1.
        READ TABLE pxt_orgtab INDEX 1.
        pxt_orgtab-makt  = 'X'.
        MODIFY pxt_orgtab INDEX 1.
      ENDIF.                             " SY-TABIX = 1.

*     Falls eine POS-relevante Änderung gefunden wurde, so wird
*     dies in der Org.Tabelle vermerkt.
      IF pet_imakt-chgflag <> space.
        readindex = pet_imakt-datum - pi_datab + 1.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-makt  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_imakt-datum.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMAKT-DATUM.
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Falls eine POS-relevante Änderung gefunden wurde, so wird
*         dies in der Org.Tabelle vermerkt.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX readindex.
      ENDIF.                             " PET_IMAKT-CHGFLAG <> SPACE.
    ENDLOOP.                             " AT PET_IMAKT.

*   Analysieren Daten aus MAMT.
    LOOP AT pet_imamt.
*     Das Datum für den ersten Satz darf nicht initial sein.
      IF pet_imamt-datum < pi_datab.
        pet_imamt-datum = pi_datab.
        MODIFY pet_imamt.
      ENDIF.                             " PET_IMAMT-DATUM < pi_datab.

*     Vermerke in Org.Tabelle das Lesen des ersten Satzes.
      IF sy-tabix = 1.
        READ TABLE pxt_orgtab INDEX 1.
        pxt_orgtab-mamt  = 'X'.
        MODIFY pxt_orgtab INDEX 1.
      ENDIF.                             " SY-TABIX = 1.

*     Falls eine POS-relevante Änderung gefunden wurde, so wird
*     dies in der Org.Tabelle vermerkt.
      IF pet_imamt-chgflag <> space.
        readindex = pet_imamt-datum - pi_datab + 1.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-mamt  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_imamt-datum.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_IMAMT-DATUM.
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Falls eine POS-relevante Änderung gefunden wurde, so wird
*         dies in der Org.Tabelle vermerkt.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX readindex.
      ENDIF.                             " PET_IMAMT-CHGFLAG <> SPACE.
    ENDLOOP.                             " AT PET_IMAMT.
  ENDIF. " PI_E1WPA03 <> space.

  REFRESH: pet_wlk2dat, pet_tvms,  pet_t134.
  CLEAR:   pet_wlk2dat, pet_tvms,  pet_t134.

* Falls Segment E1WPA02 (Artikelstamm-Stammdaten) oder
* E1WPA04 (Konditionen) gefüllt werden muß.
  IF pi_e1wpa02 <> space OR pi_e1wpa04 <> space.
*   B: New listing check logic => Note 1982796
    IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
       AND gs_twpa-marc_chk IS NOT INITIAL.
*   New listing logic: read WLK2 dat from buffer table gt_wlk2
      READ TABLE gt_wlk2 WITH KEY
                           matnr = pi_artnr
                           vkorg = pi_vkorg
                           vtweg = pi_vtweg
                           werks = pi_filia
                        BINARY SEARCH
                        TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_wlk2 TO pet_wlk2dat.
        pet_wlk2dat-arthier = 'V'.
        APPEND pet_wlk2dat.
      ENDIF.
    ELSE.
*   Besorge Material-Stammdaten aus Tabelle WLK2.
      CALL FUNCTION 'POS_INFO_GET'
        EXPORTING
          pi_vkorg           = pi_vkorg
          pi_vtweg           = pi_vtweg
          pi_filia           = pi_filia
          pi_article         = pi_artnr
          pi_datab           = pi_datab
          pi_datbi           = pi_datbi
          pi_no_ean_check    = 'X'
        TABLES
          pet_wlk2_info      = pet_wlk2dat
        EXCEPTIONS
          vrkme_not_found    = 01
          pos_info_not_found = 02.
    ENDIF. " Note 1982796
  ENDIF. " pi_e1wpa02 <> space or pi_e1wpa04 <> SPACE.

* Falls Segment E1WPA02 (Artikelstamm-Stammdaten) gefüllt werden muß.
  IF pi_e1wpa02 <> space.
    IF sy-subrc <> 0.
*     Zwischenspeichern des Returncodes.
      pe_fehlercode = sy-subrc.

*     Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod = space.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        IF g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          CLEAR: gi_errormsg_header.
          gi_errormsg_header-object        = c_applikation.
          gi_errormsg_header-subobject     = c_subobject.
          gi_errormsg_header-extnumber     = pi_dldnr.
          gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
          gi_errormsg_header-aluser        = sy-uname.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        ENDIF.                           " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        CLEAR: gi_message.
        gi_message-msgty     = c_msgtp_error.
        gi_message-msgid     = c_message_id.
        gi_message-probclass = c_probclass_sehr_wichtig.
*       'Keine R/3-Retail Materialstammdaten für Material &,
*       Verk.einh. &'
        gi_message-msgno     = '107'.
        gi_message-msgv1     = pi_artnr.
        gi_message-msgv2     = pi_vrkme.

*       Schreibe Fehlerzeile für Application-Log und WDLSO.
        g_object_key = i_key.
        PERFORM appl_log_write_single_message USING  gi_message.

      ENDIF.             " PI_FILIA_CONST-ERMOD = SPACE.

*     Ändern der Status-Kopfzeile, falls nötig.
      IF g_status < 3.                   " 'Fehlende Daten'
        CLEAR: gi_status_header.
        gi_status_header-dldnr = pi_dldnr.
        gi_status_header-gesst = c_status_fehlende_daten.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM status_write_head USING  'X'  gi_status_header  pi_dldnr
                                         g_returncode.
*       Aktualisiere Aufbereitungsstatus.
        g_status = 3.                    " 'Fehlende Daten'

      ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      CLEAR: gi_status_pos.
      gi_status_pos-dldnr  = pi_dldnr.
      gi_status_pos-lfdnr  = pi_dldlfdnr.
      gi_status_pos-anloz  = g_err_counter.
      gi_status_pos-anseg  = pi_segment_counter.
      gi_status_pos-stkey  = g_firstkey.
      gi_status_pos-ltkey  = i_key.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      IF g_status_pos < 3.                   " 'Fehlende Daten'
        gi_status_pos-gesst = c_status_fehlende_daten.

        g_status_pos = 3.                    " 'Fehlende Daten'
      ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*     Schreibe Status-Positionszeile.
      PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                         g_returncode.

*     Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod = space.
*       Verlassen der Aufbereitung, falls Einlesefehler.
        EXIT.
*     Falls Abbruch bei Fehler erwünscht.
      ELSE.                    " PI_FILIA_CONST-ERMOD <> SPACE.
*       Abbruch des Downloads.
        RAISE download_exit.
      ENDIF.                   " PI_FILIA_CONST-ERMOD = SPACE.
    ENDIF.                               " SY-SUBRC <> 0.
  ENDIF. " pi_E1WPA02 <> space.

* Falls Segment E1WPA04 (Konditionen) gefüllt werden muß.
  IF pi_e1wpa04 <> space.
    READ TABLE pet_wlk2dat INDEX 1.

*   Falls kein Preisdownload erforderlich, da der Preis an der Kasse
*   eingegeben wird.
    IF pet_wlk2dat-prerf <> space.
      pe_no_price_send = 'X'.
    ENDIF. " pet_wlk2dat-prerf <> space.
  ENDIF. " pi_e1wpa04 <> SPACE.

* Falls Segment E1WPA02 (Artikelstamm-Stammdaten) gefüllt werden muß.
  IF pi_e1wpa02 <> space.
*   Falls Materialstatus auf Mandantenebene gepflegt wurde.
*   (hat Priorität).
    IF pet_imara-mstav NE space.
*     Besorge zugehörige TVMS-Daten.
      CALL FUNCTION 'MATERIAL_SALES_STATUS_GET'
        EXPORTING
          pi_vmsta  = pet_imara-mstav
        IMPORTING
          pe_i_tvms = tvms
        EXCEPTIONS
          no_vmsta  = 01.

*   Falls Materialstatus nicht auf Mandantenebene gepflegt wurde.
    ELSE.
*     Falls Materialstatus auch nicht auf Vertriebslinienebene
*     gepflegt wurde.
      IF pet_wlk2dat-mstav = space.
        CLEAR: tvms.

*     Falls Materialstatus auf Vertriebslinienebene gepflegt wurde.
      ELSE. " pet_wlk2dat-mstav <> space.
*       Besorge zugehörige TVMS-Daten.
        CALL FUNCTION 'MATERIAL_SALES_STATUS_GET'
          EXPORTING
            pi_vmsta  = pet_wlk2dat-mstav
          IMPORTING
            pe_i_tvms = tvms
          EXCEPTIONS
            no_vmsta  = 01.
      ENDIF. " pet_wlk2dat-mstav = space.
    ENDIF. " PET_IMARA-MSTAV NE SPACE.

*   Falls keine Lesefehler auftraten.
    IF sy-subrc = 0.
      CLEAR: pet_tvms.
      pet_tvms-datum = pet_wlk2dat-datum.
      pet_tvms-spvbc = tvms-spvbc.
      APPEND pet_tvms.

*   Falls Lesefehler auftraten.
    ELSE.                                " SY-SUBRC <> 0.
*     Zwischenspeichern des Returncodes.
      pe_fehlercode = sy-subrc.

*     Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod = space.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        IF g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          CLEAR: gi_errormsg_header.
          gi_errormsg_header-object        = c_applikation.
          gi_errormsg_header-subobject     = c_subobject.
          gi_errormsg_header-extnumber     = pi_dldnr.
          gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
          gi_errormsg_header-aluser        = sy-uname.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        ENDIF.                           " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        CLEAR: gi_message.
        gi_message-msgty     = c_msgtp_error.
        gi_message-msgid     = c_message_id.
        gi_message-probclass = c_probclass_sehr_wichtig.
*       'Material &, Verk.einh. &: Ungültiger Materialstatus &'
        gi_message-msgno     = '109'.
        gi_message-msgv1     = pi_artnr.
        gi_message-msgv2     = pi_vrkme.

*       Falls Materialstatus auf Mandantenebene gepflegt wurde.
*       (hat Priorität).
        IF pet_imara-mstav NE space.
          gi_message-msgv3 = pet_imara-mstav.
*       Falls Materialstatus auf Vertriebslinienebene gepflegt wurde.
        ELSE.
          gi_message-msgv3 = pet_wlk2dat-mstav.
        ENDIF. " pet_imara-mstav ne space.

*       Schreibe Fehlerzeile für Application-Log und WDLSO.
        g_object_key = i_key.
        PERFORM appl_log_write_single_message USING  gi_message.

      ENDIF.                 " PI_FILIA_CONST-ERMOD = SPACE.

*     Ändern der Status-Kopfzeile, falls nötig.
      IF g_status < 3.       " 'Fehlende Daten'
        CLEAR: gi_status_header.
        gi_status_header-dldnr = pi_dldnr.
        gi_status_header-gesst = c_status_fehlende_daten.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM status_write_head USING  'X'  gi_status_header
                                         pi_dldnr  g_returncode.
*       Aktualisiere Aufbereitungsstatus.
        g_status = 3.                    " 'Fehlende Daten'

      ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      CLEAR: gi_status_pos.
      gi_status_pos-dldnr  = pi_dldnr.
      gi_status_pos-lfdnr  = pi_dldlfdnr.
      gi_status_pos-anloz  = g_err_counter.
      gi_status_pos-anseg  = pi_segment_counter.
      gi_status_pos-stkey  = g_firstkey.
      gi_status_pos-ltkey  = i_key.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      IF g_status_pos < 3.                   " 'Fehlende Daten'
        gi_status_pos-gesst = c_status_fehlende_daten.

        g_status_pos = 3.                    " 'Fehlende Daten'
      ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*     Schreibe Status-Positionszeile.
      PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                         g_returncode.

*     Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod <> space.
*       Abbruch des Downloads.
        RAISE download_exit.
      ENDIF.                 " PI_FILIA_CONST-ERMOD <> SPACE.
    ENDIF.                   " SY-SUBRC <> 0.

*   Besorge zugehörige T134-Daten.
    CALL FUNCTION 'MATERIAL_TYPE_GET'
      EXPORTING
        pi_mtart  = mtart
      IMPORTING
        pe_i_t134 = t134
      EXCEPTIONS
        no_mtart  = 01.

*   Falls keine Lesefehler auftraten.
    IF sy-subrc = 0.
      CLEAR: pet_t134.
      MOVE-CORRESPONDING t134 TO pet_t134.
      pet_t134-datum = pet_wlk2dat-datum.
      APPEND pet_t134.
*   Falls Lesefehler auftraten.
    ELSE.                                " SY-SUBRC <> 0.
*     Zwischenspeichern des Returncodes.
      pe_fehlercode = sy-subrc.

*    Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod = space.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        IF g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          CLEAR: gi_errormsg_header.
          gi_errormsg_header-object        = c_applikation.
          gi_errormsg_header-subobject     = c_subobject.
          gi_errormsg_header-extnumber     = pi_dldnr.
          gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
          gi_errormsg_header-aluser        = sy-uname.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        ENDIF.                           " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        CLEAR: gi_message.
        gi_message-msgty     = c_msgtp_error.
        gi_message-msgid     = c_message_id.
        gi_message-probclass = c_probclass_sehr_wichtig.
*       'Material &, Verk.einh. &: Materialart & ist ungültig'.
        gi_message-msgno     = '108'.
        gi_message-msgv1     = pi_artnr.
        gi_message-msgv2     = pi_vrkme.
        gi_message-msgv3     = mtart.

*       Schreibe Fehlerzeile für Application-Log und WDLSO.
        g_object_key = i_key.
        PERFORM appl_log_write_single_message USING  gi_message.

      ENDIF.                   " PI_FILIA_CONST-ERMOD = SPACE.

*     Ändern der Status-Kopfzeile, falls nötig.
      IF g_status < 3.                   " 'Fehlende Daten'
        CLEAR: gi_status_header.
        gi_status_header-dldnr = pi_dldnr.
        gi_status_header-gesst = c_status_fehlende_daten.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM status_write_head USING  'X'  gi_status_header
                                         pi_dldnr  g_returncode.
*       Aktualisiere Aufbereitungsstatus.
        g_status = 3.                    " 'Fehlende Daten'

      ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      CLEAR: gi_status_pos.
      gi_status_pos-dldnr  = pi_dldnr.
      gi_status_pos-lfdnr  = pi_dldlfdnr.
      gi_status_pos-anloz  = g_err_counter.
      gi_status_pos-anseg  = pi_segment_counter.
      gi_status_pos-stkey  = g_firstkey.
      gi_status_pos-ltkey  = i_key.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      IF g_status_pos < 3.                   " 'Fehlende Daten'
        gi_status_pos-gesst = c_status_fehlende_daten.

        g_status_pos = 3.                    " 'Fehlende Daten'
      ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*     Schreibe Status-Positionszeile.
      PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                         g_returncode.

*     Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod <> space.
*       Abbruch des Downloads.
        RAISE download_exit.
      ENDIF.             " PI_FILIA_CONST-ERMOD <> SPACE.
    ENDIF.               " SY-SUBRC <> 0.

*   Vermerke in Org.Tabelle das Lesen des ersten Satzes.
    READ TABLE pxt_orgtab INDEX 1.
    pxt_orgtab-wlk2  = 'X'.

*   Falls Änderungsfall.
    IF pi_mode = c_change_mode.
*     Falls initialisiert werden soll, vermerke dies in Org.Tabelle.
      IF pi_initdat <> space AND pi_initdat <= pet_wlk2dat-datum.
        pxt_orgtab-change = 'X'.
      ENDIF. " PI_INITDAT <> SPACE AND PI_INITDAT <= PET_WLK2DAT-DATUM.
*   Falls Initialisierungsfall, direkte Anforderung oder Restart.
    ELSE.
*     Vermerke in Org.Tabelle, daß der erste Satz
*     versendet werden soll.
      pxt_orgtab-change = 'X'.
    ENDIF. " PI_MODE = C_CHANGE_MODE

    MODIFY pxt_orgtab INDEX 1.

  ENDIF. " pi_E1WPA02 <> space.


ENDFORM.                               " MATDATA_GET_AND_ANALYSE


*eject.
************************************************************************
FORM listing_check
     TABLES pit_listung  STRUCTURE gt_listung
     USING  pi_vrkme     LIKE wlk1-vrkme
            pi_datum     LIKE syst-datum
            pe_gelistet  TYPE c
            pi_mode      LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Prüfe, ob der Artikel für den Tag PI_DATUM gelistet ist. Für den
* Initialisierungsfall oder die direkte Anforderung wird noch
* zusätzlich überprüft, ob dieser Tag der Beginn einer Listung ist.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_LISTUNG: Tabelle der Listungen des Artikels.

* PI_VRKME   : Verkaufsmengeneinheit des Artikels.

* PI_DATUM   : Zu überprüfendes Datum.

* PE_GELISTET: = ' ', wenn nicht gelistet, = 'B', wenn Beginn
*                einer Listung, = 'X', wenn nur gelistet aber
*                kein Listbeginn.
* PI_MODE      : Download-Modus.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Artikel defaultmäßig auf nicht gelistet setzten.
  CLEAR: pe_gelistet.
* Prüfe, ob und wenn ja, wann der Artikel mit dieser VRKME
* zu diesem Datum gelistet ist.
  LOOP AT pit_listung
    WHERE vrkme = pi_vrkme
    AND   datab <= pi_datum
    AND   datbi >= pi_datum.

*   Wenn Beginn einer Listung.
    IF pit_listung-datab = pi_datum.
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      IF pi_mode <> c_change_mode.
        pe_gelistet = c_begin.
        EXIT.
*     Falls Änderungsfall.
      ELSE. " pi_mode = c_change_mode.
        pe_gelistet = 'X'.
        EXIT.
      ENDIF. " pi_mode <> c_change_mode.
*   Falls nur gelistet.
    ELSE.
      pe_gelistet = 'X'.
      EXIT.
    ENDIF.                             " PIT_LISTUNG-DATAB = PI_DATUM.
  ENDLOOP.                             " AT PIT_LISTUNG
ENDFORM.                               " LISTING_CHECK


*eject.
************************************************************************
FORM idoc_dataset_artstm_append
     TABLES pit_imara          STRUCTURE gt_imara
            pit_imarm          STRUCTURE gt_imarm
            pit_imakt          STRUCTURE gt_imakt
            pit_imamt          STRUCTURE gt_imamt
            pit_wlk2dat        STRUCTURE gt_wlk2dat
            pit_orgtab         STRUCTURE gt_orgtab_artstm
            pit_kond_art       STRUCTURE gt_kond_art
            pit_staff_art      STRUCTURE gt_staff_art
            pit_artsteu        STRUCTURE gt_artsteu
            pit_tvms           STRUCTURE gt_tvms
            pit_t134           STRUCTURE gt_t134
            pit_wrf6           STRUCTURE gt_wrf6
            pit_date_for_count STRUCTURE wpdate
            pit_natrab_saco    STRUCTURE gt_natrab_saco
            pit_kondn          STRUCTURE gt_kondn
            pit_kondns         STRUCTURE gt_kondns
            pit_natrab_ean     STRUCTURE gt_natrab_ean
   USING    pxt_idoc_data      TYPE short_edidd
            pi_datum           LIKE wpstruc-datum
            px_segcnt          LIKE g_segment_counter
            pi_loeschen        LIKE wpstruc-modus
            pi_e1wpa02         LIKE wpstruc-modus
            pi_e1wpa03         LIKE wpstruc-modus
            pi_e1wpa04         LIKE wpstruc-modus
            pi_e1wpa05         LIKE wpstruc-modus
            pi_e1wpa07         LIKE wpstruc-modus
            pi_e1wpa09         LIKE wpstruc-modus
            pi_e1wpa10         LIKE wpstruc-modus
            pi_e1wpa11         LIKE wpstruc-modus
            pi_filia           LIKE t001w-werks
            pe_fehlercode      LIKE syst-subrc
            pi_dldnr           LIKE wdls-dldnr
            pi_dldlfdnr        LIKE wdlsp-lfdnr
            pi_filia_const     LIKE wpfilconst
            px_ean             LIKE marm-ean11
            pi_mode            LIKE wpstruc-modus
            pi_no_price_send   LIKE wpstruc-modus
            pi_aendtyp         LIKE e1wpa01-aendtyp.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_IMARA    : Tabelle mit MARA-Daten.

* PIT_IMARM    : Tabelle mit MARM-Daten.

* PIT_IMAKT    : Tabelle mit MAKT-Daten.

* PIT_IMAMT    : Tabelle mit MATT-Daten.

* PIT_WLK2DAT  : Tabelle für WLK2-Daten.

* PIT_ORGTAB   : Organisationstabelle für Artikelstamm.

* PIT_KOND_ART : Tabelle für Konditionsdaten

* PIT_STAFF_ART: Tabelle für Konditionsstaffeldaten

* PIT_ARTSTEU  : Tabelle der Artikelsteuern.

* PIT_TVMS     : Tabelle für TVMS-Daten.

* PIT_T134     : Tabelle für T134-Daten.

* PIT_WRF6     : Tabelle für WRF6-Daten.

* PXT_IDOC_DATA: IDOC-Daten der Struktur EDIDD (Tabelle an die die
*                IDOC-Sätze angefügt werden).
* PI_DATUM     : Datum für das die Daten aufbereitet werden sollen.

* PIT_DATE_FOR_COUNT : Datümer, zu denen eine Zählaufforderung
*                      stattfinden muß.
* PIT_NATRAB_SACO    : Tabelle für SACO-Daten der Naturalrabatte.

* PIT_KONDN          : Naturalrabattpositionen.

* PIT_KONDNS         : Naturalrabattstaffeln.

* PIT_NATRAB_EAN     : Haupt-EAN-Änderungen der Zugabematerialien.

* PX_SEGCNT    : Segment-Zähler.

* PI_LOESCHEN  : = 'X', wenn Löschmodus aktiv.

* PI_E1WPA02   : = 'X', wenn Segment E1WPA02 aufbereitet werden soll.

* PI_E1WPA03   : = 'X', wenn Segment E1WPA03 aufbereitet werden soll.

* PI_E1WPA04   : = 'X', wenn Segment E1WPA04 aufbereitet werden soll.

* PI_E1WPA05   : = 'X', wenn Segment E1WPA05 aufbereitet werden soll.

* PI_E1WPA07   : = 'X', wenn Segment E1WPA07 aufbereitet werden soll.

* PI_E1WPA09   : = 'X', wenn Segment E1WPA09 aufbereitet werden soll.

* PI_E1WPA10   : = 'X', wenn Segment E1WPA10 aufbereitet werden soll.

* PI_E1WPA11   : = 'X', wenn Segment E1WPA11 aufbereitet werden soll.

* PI_FILIA     : Filiale, an die versendet werden soll.

* PE_FEHLERCODE: > 0, wenn Fehler beim Umsetzen der Daten.

* PI_DLDNR     : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.

* PI_FILIA_CONST: Filialkonstanten

* PX_EAN       : Haupt-EAN zur Verkaufsmengeneinheit des Artikels.

* PI_MODE      : Download-Modus.

* PI_NO_PRICE_SEND: = 'X', wenn kein Preis versendet werden soll.

* PI_AENDTYP   : Änderungstyp des Artikels.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: lese_datum    LIKE sy-datum,
        kschl         LIKE komv-kschl,
        e1wpa03_cnt   TYPE i,
        e1wpa04_cnt   TYPE i,
        e1wpa05_cnt   TYPE i,
*       e1wpa06_cnt   type i,
        e1wpa07_cnt   TYPE i,
        e1wpa09_cnt   TYPE i,
        e1wpa10_cnt   TYPE i,
        e1wpa11_cnt   TYPE i,
        seg_local_cnt TYPE i,
        h_returncode  LIKE sy-subrc,
        h_lfdnr       LIKE wpstruc-counter,
        h_betrag      LIKE e1wpa05-kondwert,
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

  DATA: t_kondart_grund LIKE twpek OCCURS 0 WITH HEADER LINE.

* Rücksetze Returncode.
  CLEAR: pe_fehlercode, e1wpa03_cnt, e1wpa04_cnt, e1wpa05_cnt,
         e1wpa07_cnt, e1wpa09_cnt, e1wpa10_cnt, e1wpa11_cnt.

* Besorge für PI_DATUM das Zugriffsdatum auf die zugehörigen MARA-Daten.
  CLEAR: lese_datum, seg_local_cnt.
  LOOP AT pit_orgtab
    WHERE datum <= pi_datum
    AND   mara  <> space.
*   Merke des Datum für Zugriff auf MARA-Daten.
    lese_datum = pit_orgtab-datum.
    EXIT.
  ENDLOOP.                             " AT PIT_ORGTAB

* Besorge die zugehörigen MARA-Daten. Die Daten stehen in der
* Kopfzeile von PIT_IMARA.
  LOOP AT pit_imara
    WHERE datum = lese_datum.
    EXIT.
  ENDLOOP.                             " AT PIT_IMARA

* Besorge für PI_DATUM das Zugriffsdatum auf die zugehörigen MARM-Daten.
  CLEAR: lese_datum.
  LOOP AT pit_orgtab
    WHERE datum <= pi_datum
    AND   marm  <> space.
*   Merke des Datum für Zugriff auf MARM-Daten.
    lese_datum = pit_orgtab-datum.
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

* Falls sich die Haupt-EAN verändert hat, muß der
* Satz mit der alten Haupt-EAN gelöscht werden.
***> Start of changes : Suri : 08.02.2019 : 16:00:00
***    Des : Avoiding EAN validation fro Creatinf IDOC :in WPMA T-code

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
      CLEAR: e1wpa01.
      e1wpa01-filiale    = pi_filia_const-kunnr.
      e1wpa01-aendkennz  = c_delete.
      e1wpa01-aktivdatum = pi_datum.
      e1wpa01-aenddatum  = '00000000'.
      e1wpa01-aenderer   = ' '.
*      e1wpa01-artikelnr_long  = pit_imara-matnr.
*     Outbound Mapping to be able to fill the IDOC structure correctly
      cl_matnr_chk_mapper=>convert_on_output(
        EXPORTING
          iv_matnr40                   =     pit_imara-matnr
        IMPORTING
          ev_matnr18                   =     e1wpa01-artikelnr
          ev_matnr40                   =     e1wpa01-artikelnr_long
        EXCEPTIONS
          excp_matnr_invalid_input     = 1
          excp_matnr_not_found         = 2
          OTHERS                       = 3 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      e1wpa01-posme      = pit_imarm-meinh.

*     Besorge EAN-Typ.
*     Prüfe zunächst, ob es sich um eine alte EAN handelt.
      LOOP AT gt_old_ean
           WHERE artnr = pit_imara-matnr
           AND   vrkme = pit_imarm-meinh
           AND   ean11 = px_ean.
        EXIT.
      ENDLOOP. " at gt_old_ean

*     Falls es sich um eine alte EAN handelt und sich der EAN-Typ
*     geändert hat.
      IF sy-subrc = 0 AND NOT gt_old_ean-numtp IS INITIAL.
        h_numtp = gt_old_ean-numtp.

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
          output  = e1wpa01-hauptean.

*     Erzeuge temporären IDOC-Segmentsatz.
      gt_idoc_data_temp-segnam = c_e1wpa01_name.
      gt_idoc_data_temp-sdata  = e1wpa01.
      APPEND gt_idoc_data_temp.

*     aktualisiere Segmentzähler und Haupt-EAN.
      ADD 1 TO seg_local_cnt.
      px_ean = pit_imarm-ean11.

*********************************************************************
***********************   U S E R - E X I T  ************************
      CALL CUSTOMER-FUNCTION '002'
        EXPORTING
          pi_e1wpa03_cnt     = e1wpa03_cnt
          pi_e1wpa04_cnt     = e1wpa04_cnt
          pi_e1wpa05_cnt     = e1wpa05_cnt
          pi_e1wpa07_cnt     = e1wpa07_cnt
          pi_e1wpa09_cnt     = e1wpa09_cnt
          pi_e1wpa10_cnt     = e1wpa10_cnt
          pi_e1wpa11_cnt     = e1wpa11_cnt
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
          pi_mara            = pit_imara
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
            gi_object_key-matnr = pit_imara-matnr.
            gi_object_key-vrkme = pit_imarm-meinh.
            gi_object_key-ean11 = px_ean.
            g_object_key        = gi_object_key.
            g_object_delete     = 'X'.

*           Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
            PERFORM error_object_write.

*           Rücksetze Löschkennzeichen für Fehlerobjekttabelle WDLSO.
            CLEAR: g_object_delete.
          ENDIF. " pi_datum <= sy-datum.

*         Verlassen der Aufbereitung dieser Basiswarengruppe.
          EXIT.
*       Falls Abbruch bei Fehler erwünscht.
        ELSE.                          " PI_ERMOD <> SPACE.
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

    ENDIF.                             " PX_EAN <> SPACE.                 " Suri : 02.08.2019
  ENDIF.                               " PIT_IMARM-EAN11 <> PX_EAN.       " Suri : 02.08.2019

** Falls EAN gelöscht wurde.
*  IF pit_imarm-ean11 = space.
**   Falls Fehlerprotokollierung erwünscht.
*    IF pi_filia_const-ermod = space.
**     Falls noch keine Initialisierung des Fehlerprotokolls.
*      IF g_init_log = space.
**       Aufbereitung der Parameter zum schreiben des Headers des
**       Fehlerprotokolls.
*        CLEAR: gi_errormsg_header.
*        gi_errormsg_header-object        = c_applikation.
*        gi_errormsg_header-subobject     = c_subobject.
*        gi_errormsg_header-extnumber     = pi_dldnr.
*        gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
*        gi_errormsg_header-aluser        = sy-uname.
*
**       Initialisiere Fehlerprotokoll und erzeuge Header.
*        PERFORM appl_log_init_with_header
*                USING gi_errormsg_header.
*
**       Merke, daß Fehlerprotokoll initialisiert wurde.
*        g_init_log = 'X'.
*      ENDIF.                           " G_INIT_LOG = SPACE.
*
**     Bereite Parameter zum schreiben der Fehlerzeile auf.
*      WRITE pi_datum TO g_datum1 DD/MM/YYYY.
*
*      CLEAR: gi_message.
*      gi_message-msgty     = c_msgtp_warning.
*      gi_message-msgid     = c_message_id.
*      gi_message-probclass = c_probclass_weniger_wichtig.
**     'Keine EAN für Material & und Vrkme &
**     zum Datum & gepflegt'
*      gi_message-msgno     = '125'.
*      gi_message-msgv1     = i_key-matnr.
*      gi_message-msgv2     = i_key-vrkme.
*      gi_message-msgv3     = g_datum1.
*
**     Schreibe Fehlerzeile für Application-Log und WDLSO.
*      CLEAR: g_object_key.
*      PERFORM appl_log_write_single_message USING  gi_message.
*
*    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.
*
**   Ändern der Status-Kopfzeile, falls nötig.
*    IF g_status < 2.                   " 'Benutzerhinweis'.
*      CLEAR: gi_status_header.
*      gi_status_header-dldnr = pi_dldnr.
*      gi_status_header-gesst = c_status_benutzerhinweis.
*
**     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
*      PERFORM status_write_head USING  'X'  gi_status_header
*                                       pi_dldnr  h_returncode.
**     Aktualisiere Aufbereitungsstatus.
*      g_status = 2.                    " 'Benutzerhinweis'.
*
*    ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'.
*
**   Aufbereiten der Parameter zum Ändern der
**   Status-Positionszeile.
*    CLEAR: gi_status_pos.
*    gi_status_pos-dldnr  = pi_dldnr.
*    gi_status_pos-lfdnr  = pi_dldlfdnr.
*    gi_status_pos-anloz  = g_err_counter.
*    gi_status_pos-anseg  = px_segcnt.
*    gi_status_pos-stkey  = g_firstkey.
*    gi_status_pos-ltkey  = i_key.
*
**   Aktualisiere Aufbereitungsstatus für Positionszeile,
**   falls nötig.
*    IF g_status_pos < 2.                   " 'Benutzerhinweis'.
*      gi_status_pos-gesst = c_status_benutzerhinweis.
*
*      g_status_pos = 2.                    " 'Benutzerhinweis'.
*    ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'.
*
**   Schreibe Status-Positionszeile.
*    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
*                                       h_returncode.
*
**   Falls Fehlerprotokollierung erwünscht.
*    IF pi_filia_const-ermod = space.
**     Verlassen der Aufbereitung für dieses Datum
*      EXIT.
**   Falls Abbruch bei Fehler erwünscht.
*    ELSE.                              " PI_ERMOD <> SPACE.
**     Abbruch des Downloads.
*      RAISE download_exit.
*    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.
*  ENDIF.                               " PIT_IMARM-EAN11 = SPACE.

***< End of Changes  : Suri : 02.08.2019 : 16:00:00

* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: gt_idoc_data_temp.

* Rücksetze lokalen Segmentzähler.
  CLEAR: seg_local_cnt.

* Aufbereitung ID-Segment.
  CLEAR: e1wpa01.
  e1wpa01-filiale    = pi_filia_const-kunnr.
  e1wpa01-aktivdatum = pi_datum.
  e1wpa01-aenddatum  = '00000000'.
  e1wpa01-aenderer   = ' '.
*  e1wpa01-artikelnr_long  = pit_imara-matnr.
* Outbound Mapping to be able to fill the IDOC structure correctly
  cl_matnr_chk_mapper=>convert_on_output(
    EXPORTING
      iv_matnr40                   =     pit_imara-matnr
    IMPORTING
      ev_matnr18                   =     e1wpa01-artikelnr
      ev_matnr40                   =     e1wpa01-artikelnr_long
    EXCEPTIONS
      excp_matnr_invalid_input     = 1
      excp_matnr_not_found         = 2
      OTHERS                       = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  e1wpa01-posme      = pit_imarm-meinh.

* Ausgabekonvertierung für EAN.
  CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
    EXPORTING
      input   = pit_imarm-ean11
      ean_typ = pit_imarm-numtp
    IMPORTING
      output  = e1wpa01-hauptean.

* Falls Löschmodus aktiv.
  IF pi_loeschen <> space.
    e1wpa01-aendkennz  = c_delete.
* Falls Löschmodus nicht aktiv.
  ELSE.
    e1wpa01-aendkennz  = c_modi.
    e1wpa01-aendtyp    = pi_aendtyp.
  ENDIF.                               " PI_LOESCHEN <> SPACE.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpa01_name.
  gt_idoc_data_temp-sdata  = e1wpa01.
  APPEND gt_idoc_data_temp.
* aktualisiere Segmentzähler.
  ADD 1 TO seg_local_cnt.
*** Start of Change By Suri : 08.08.2019 12:00:00
*** Description : Adding Custom Segment Details : Ivend Details
  CONSTANTS : c_cus_seg_name(11) VALUE 'ZMARA_IVEND'.
  DATA : mara_ivend TYPE zmara_ivend.
  IF gt_idoc_data_temp IS NOT INITIAL AND seg_local_cnt = 1 AND pit_imara-matnr IS NOT INITIAL.
*** Get Ivend Descriptiona and Batch Managed Check
    SELECT SINGLE mara~zzivend_desc xchpf FROM mara INTO mara_ivend WHERE matnr = pit_imara-matnr.
*** Adding at Second Postion
*    IF MARA_IVEND IS NOT INITIAL.
    gt_idoc_data_temp-segnam = c_cus_seg_name.
    IF mara_ivend-ivend_desc IS INITIAL.
      SELECT SINGLE maktx FROM makt INTO mara_ivend-ivend_desc WHERE matnr = pit_imara-matnr.
    ENDIF.
*** Start of Change By Suri : 02.12.2019 23:26:00
*** Tax Code to POS
    SELECT SINGLE konp~mwsk1
      INTO mara_ivend-tax_code FROM konp AS konp
      INNER JOIN a519 AS a519 ON a519~knumh = konp~knumh
      INNER JOIN marc AS marc ON marc~steuc = a519~steuc
      WHERE marc~matnr = pit_imara-matnr AND a519~datab LE sy-datum
      AND   a519~datbi GE sy-datum AND konp~loevm_ko = space.
*** End of Change By Suri : 02.12.2019 23:26:00

*** Start of Change By Suri : 28.12.2019 19:49:00
*** Material Hierarchy
    SELECT SINGLE klah~class
      INTO mara_ivend-group
      FROM klah AS klah
      INNER JOIN kssk AS kssk  ON kssk~clint = klah~clint
      INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
      INNER JOIN mara AS mara  ON   klah1~class = mara~matkl
      WHERE klah~klart = '026' AND mara~matnr = pit_imara-matnr.
*** End of Change By Suri : 28.12.2019 19:49:00
    gt_idoc_data_temp-sdata  = mara_ivend.
    APPEND gt_idoc_data_temp.
    EXPORT mara_ivend TO MEMORY ID 'MARA_IVEND'.
  ENDIF.
*  ENDIF.
*** End of Change By Suri : 08.08.2019 12:00:00

* Es müssen Stammdaten übertragen werden, da kein Löschmodus aktiv ist.
  IF pi_loeschen = space.
*   Falls Segment E1WPA02 (Artikelstamm-Stammdaten) gefüllt werden muß.
    IF pi_e1wpa02 <> space.
*     Besorge für PI_DATUM das Zugriffsdatum auf die
*     zugehörigen WLK2-Daten.
      CLEAR: lese_datum.
      LOOP AT pit_orgtab
        WHERE datum <= pi_datum
        AND   wlk2  <> space.
*       Merke des Datum für Zugriff auf MARM-Daten.
        lese_datum = pit_orgtab-datum.
        EXIT.
      ENDLOOP.                         " AT PIT_ORGTAB

*     Besorge die zugehörigen WLK2-Daten. Die Daten stehen in der
*     Kopfzeile von PIT_WLK2DAT.
      LOOP AT pit_wlk2dat
        WHERE datum = lese_datum.
        EXIT.
      ENDLOOP.                         " AT PIT_WLK2DAT

*     Lese zugehörige TVMS-Daten (Verkaufssperre).
      READ TABLE pit_tvms WITH KEY lese_datum.

*     Lese die zugehörigen T134-Daten (Preis drucken, Artikel anzeigen).
      READ TABLE pit_t134 WITH KEY lese_datum.

*     Lese die zugehörigen WRF6-Daten (Mehrwertsteuerflag).
      READ TABLE pit_wrf6 WITH KEY pit_imara-datum.

*     Falls keine WRF6-Daten für diesen Zeitpunkt existieren.
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
          WRITE pit_imara-datum TO g_datum1 DD/MM/YYYY.

          CLEAR: gi_message.
          gi_message-msgty     = c_msgtp_error.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_sehr_wichtig.
*         'Keine Zuordnung der Filiale & zur Warengruppe & gepflegt'.
          gi_message-msgno     = '161'.
          gi_message-msgv1     = pi_filia.
          gi_message-msgv2     = pit_imara-matkl.
          gi_message-msgv3     = g_datum1.
          gi_message-msgv4     = pit_imara-matnr.

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
        ELSE.                          " PI_ERMOD <> SPACE.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.
      ENDIF.                           " SY-SUBRC <> 0.


*     Fülle Segment E1WPA02.

      CLEAR: e1wpa02.
      e1wpa02-warengr    = pit_imara-matkl.
      e1wpa02-verpgew    = '0'.
      e1wpa02-meinpverb  = pit_wlk2dat-kwdht.
      e1wpa02-vkinperfor = pit_wlk2dat-prerf.
      e1wpa02-raberlaubt = pit_wlk2dat-rbzul.
      e1wpa02-waagenkr   = pit_wlk2dat-scagr.
      e1wpa02-mwstflag   = pit_wrf6-primw.
      e1wpa02-prdruck    = pit_t134-prdru.
      e1wpa02-artikanz   = pit_t134-aranz.
      e1wpa02-wmakg      = pit_t134-wmakg.
      e1wpa02-mhdrz      = pit_imara-mhdrz.
      e1wpa02-mhdhb      = pit_imara-mhdhb.
      CONDENSE e1wpa02-mhdrz.
      CONDENSE e1wpa02-mhdhb.

      IF NOT e1wpa02-waagenkr IS INITIAL.
        e1wpa02-waagenart  = 'X'.
      ENDIF. " not e1wpa02-waagenkr is initial.

      IF pit_tvms-spvbc = c_fehlermeldung.
        e1wpa02-verksperre = 'X'.
      ENDIF.                        " pit_tvms-spvbc = c_fehlermeldung

*     Prüfe, ob die Zählaufforderung für den Artikel gesetzt werden
*     muß.
      READ TABLE pit_date_for_count WITH KEY
           datab = pi_datum
           BINARY SEARCH.

*     Falls die Zählaufforderung für den Artikel gesetzt werden muß.
      IF sy-subrc = 0.
        e1wpa02-artcnt  = 'X'.
      ENDIF. " sy-subrc = 0.

*     Erzeuge temporären IDOC-Segmentsatz.
      gt_idoc_data_temp-segnam = c_e1wpa02_name.
      gt_idoc_data_temp-sdata  = e1wpa02.
      APPEND gt_idoc_data_temp.

*     aktualisiere Segmentzähler.
      ADD 1 TO seg_local_cnt.

    ENDIF.                             " PI_E1WPA02 <> SPACE.
*{   INSERT         XB4K001679                                        1
* WRF_POSOUT
    DATA: l_subrc LIKE sy-subrc.
    DATA: l_message LIKE gi_message.

    CLEAR: l_subrc, l_message.

    PERFORM call_badi_idoc_artstm_append
                           TABLES gt_idoc_data_temp
                            USING e1wpa01
                                  l_subrc
                                  l_message
                                  pi_filia_const-mestype_plu.

*   Falls eine Artikelhierarchie-Zuordnung gefunden wurde.
    IF l_subrc IS INITIAL.
*     aktualisiere Segmentzähler.
      ADD 1 TO seg_local_cnt.
*   Falls keine Artikelhierarchie-Zuordnung gefunden wurde.
    ELSE.
*     Falls Fehlerprotokollierung erwünscht.
      IF pi_filia_const-ermod = space.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        IF g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          CLEAR: gi_errormsg_header.
          gi_errormsg_header-object        = c_applikation.
          gi_errormsg_header-subobject     = c_subobject.
          gi_errormsg_header-extnumber     = pi_dldnr.
          gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
          gi_errormsg_header-aluser        = sy-uname.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        ENDIF.                       " G_INIT_LOG = SPACE.

        CLEAR: gi_message.
        gi_message = l_message.

*       Schreibe Fehlerzeile für Application-Log und WDLSO.
        g_object_key = i_key.
        PERFORM appl_log_write_single_message USING  gi_message.

      ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*     Ändern der Status-Kopfzeile, falls nötig.
      IF g_status < 2.                   " 'Benutzerhinweis'
*       Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
        CLEAR: gi_status_header.
        gi_status_header-dldnr = g_dldnr.
        gi_status_header-gesst = c_status_benutzerhinweis.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM status_write_head USING  'X'  gi_status_header
                                              g_dldnr g_returncode.

*       Aktualisiere Aufbereitungsstatus.
        g_status = 2.                  " 'Benutzerhinweis'
      ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      CLEAR: gi_status_pos.
      gi_status_pos-dldnr  = pi_dldnr.
      gi_status_pos-lfdnr  = pi_dldlfdnr.
      gi_status_pos-anloz  = g_err_counter.
      gi_status_pos-anseg  = px_segcnt.
      gi_status_pos-stkey  = g_firstkey.
      gi_status_pos-ltkey  = i_key.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      IF g_status_pos < 2.                   " 'Benutzerhinweis'
        gi_status_pos-gesst = c_status_benutzerhinweis.

        g_status_pos = 2.                    " 'Benutzerhinweis'
      ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'

*     Schreibe Status-Positionszeile.
      PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                         h_returncode.

    ENDIF.                           " not l_subrc is initial.

* WRF_POSOUT
*}   INSERT

*   Falls Segment E1WPA03 (Artikeltexte) gefüllt werden muß.
    IF pi_e1wpa03 <> space.
*     Besorge für PI_DATUM das Zugriffsdatum auf die
*     zugehörigen MAKT-Daten.
      CLEAR: lese_datum.
      LOOP AT pit_orgtab
        WHERE datum <= pi_datum
        AND   makt  <> space.
*       Merke des Datum für Zugriff auf MARA-Daten.
        lese_datum = pit_orgtab-datum.
        EXIT.
      ENDLOOP.                         " AT PIT_ORGTAB

*     Fülle Segment E1WPA03.
      CLEAR: e1wpa03_cnt.

*     Besorge die zugehörigen MAKT-Daten. Die Daten stehen in der
*     Tabelle PIT_IMAKT.
      LOOP AT pit_imakt
           WHERE datum = lese_datum.
*       Initialisiere Segmentstruktur.
        CLEAR: e1wpa03.

*       Übernehme die Lfdnr in eine Hilfsvariable anderer Länge.
        h_lfdnr = 1.

*       Aktualisiere Zähler für Artikeltexte.
        ADD 1 TO e1wpa03_cnt.

*       Erzeuge Langtext.
        e1wpa03-qualarttxt = c_qualarttxt_makt1.
        e1wpa03-lfdnr      = h_lfdnr.
        e1wpa03-sprascode  = pit_imakt-spras.
        e1wpa03-text       = pit_imakt-maktx.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpa03_name.
        gt_idoc_data_temp-sdata  = e1wpa03.
        APPEND gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        ADD 1 TO seg_local_cnt.

      ENDLOOP.                         " AT PIT_IMAKT

*     Besorge für PI_DATUM das Zugriffsdatum auf die
*     zugehörigen MAMT-Daten (Bon- und Etikettentexte).
      CLEAR: lese_datum.
      LOOP AT pit_orgtab
           WHERE datum <= pi_datum
           AND   mamt  <> space.
*       Merke das Datum für Zugriff auf MARA-Daten.
        lese_datum = pit_orgtab-datum.
        EXIT.
      ENDLOOP.                         " AT PIT_ORGTAB

*     Fülle Segment E1WPA03.
      CLEAR: e1wpa03, e1wpa03_cnt.

*     Besorge die zugehörigen Bon- und Etikettentexte.
*     Die Daten stehen in der Tabelle PIT_IMAMT.
      LOOP AT pit_imamt
           WHERE datum = lese_datum.
*       Initialisiere Segmentstruktur.
        CLEAR: e1wpa03.

*       Übernehme die Lfdnr in eine Hilfsvariable anderer Länge.
        h_lfdnr = pit_imamt-lfdnr.

*       Aktualisiere Zähler für Artikeltexte.
        ADD 1 TO e1wpa03_cnt.

        e1wpa03-qualarttxt   = pit_imamt-mtxid.
        e1wpa03-lfdnr        = h_lfdnr.
        e1wpa03-sprascode    = pit_imamt-spras.
        e1wpa03-text         = pit_imamt-maktm.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpa03_name.
        gt_idoc_data_temp-sdata  = e1wpa03.
        APPEND gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        ADD 1 TO seg_local_cnt.

      ENDLOOP.                         " AT PIT_IMAMT
    ENDIF.                             " PI_E1WPA03 <> SPACE.

*   Falls Segment E1WPA04 (Konditionen) gefüllt werden muß
    IF pi_e1wpa04 <> space.
*     Besorge die Grund- bzw. Vergleichspreiskonditionsarten
      PERFORM kondart_grundpreis_get
              TABLES t_kondart_grund
              USING  pi_filia_const.

      READ TABLE t_kondart_grund INDEX 1.

*     Falls Grundpreise zu beachten sind.
      IF sy-subrc = 0 AND NOT t_kondart_grund-kschl3 IS INITIAL.
*       Besorge die MARA-Daten des Artikels.
        PERFORM mara_select
                USING  mara  i_key-matnr.
      ENDIF. " sy-subrc = 0 and ...

*     Besorge die Konditionsdaten für Datum PI_DATUM.
      CLEAR: kschl, e1wpa04_cnt, e1wpa05_cnt.
***> Start of Change Suri : 06.08.2019 13:13:00
***  For Sending Segment2, Segmen3, Segment4 with avoding Prince validation
      IF pit_kond_art IS NOT INITIAL.                " Suri : 06.08.2019 13:13:00
        LOOP AT pit_kond_art
          WHERE kntyp <> c_kntyp_steuer
          AND   kntyp <> c_kntyp_agsteuer
          AND   kntyp <> c_kntyp_vsteuer
          AND   datab <= pi_datum
          AND   datbi >= pi_datum.

*       Prüfe, ob die Konditionsart einen Grund- bzw.
*       Vergleichspreis darstellt.
          READ TABLE t_kondart_grund WITH KEY
               kschl3 = pit_kond_art-kschl
               BINARY SEARCH.

*       Falls die Konditionsart einen Grund- bzw.
*       Vergleichspreis darstellt.
          IF sy-subrc = 0.
*         Falls keine Inhaltsmengeneinheit gepflegt ist,
*         gibt es keinen Grundpreis und diese Konditionsart
*         kann ignoriert werden.
            IF mara-inhme IS INITIAL.
              CONTINUE.
            ENDIF. " mara-inhme is initial.
          ENDIF. " sy-subrc = 0.

*       Aktualisiere Zähler für Konditionen
          ADD 1 TO e1wpa04_cnt.

*       Wenn neue Konditionsart, erzeuge neues Segment E1WPA04
          IF pit_kond_art-kschl <> kschl.
            kschl = pit_kond_art-kschl.

*         Fülle Segment E1WPA04.
            CLEAR: e1wpa04.
            e1wpa04-kondart    = pit_kond_art-kschl.
            e1wpa04-aktionsnr  = pit_kond_art-aktnr.
            e1wpa04-begindatum = pit_kond_art-datab.
            e1wpa04-beginnzeit = '000000'.
            e1wpa04-enddatum   = pit_kond_art-datbi.
            e1wpa04-endzeit    = '000000'.
            e1wpa04-freiverw1  = space.

*         Erzeuge temporären IDOC-Segmentsatz.
            gt_idoc_data_temp-segnam = c_e1wpa04_name.
            gt_idoc_data_temp-sdata  = e1wpa04.
            APPEND gt_idoc_data_temp.

*         aktualisiere Segmentzähler.
            ADD 1 TO seg_local_cnt.

          ENDIF.                         " PIT_KOND_ART-KSCHL <> KSCHL.

*       Falls Segment E1WPA05 (Konditionswerte) gefüllt werden muß.
          IF pi_e1wpa05 <> space.
*         Fülle Segment E1WPA05.
            CLEAR: e1wpa05.

*         Aktualisiere Zähler für Konditionswerte.
            ADD 1 TO e1wpa05_cnt.

*         Bestimme das Vorzeichen des Preises.
            IF pit_kond_art-kbetr >= 0.
              e1wpa05-vorzeichen = c_plus.
            ELSE.
              e1wpa05-vorzeichen = c_minus.
            ENDIF.                       " PIT_KOND_ART-KBETR >= 0.

*         Es wird nur der Betragswert des Preises benötigt,
*         da das Vorzeichen extra verschickt wird.
            IF pit_kond_art-kbetr < 0.
              pit_kond_art-kbetr = -1 * pit_kond_art-kbetr.
            ENDIF.                       " PIT_KOND_ART-KBETR < 0.

*         Setze Dummy-Währung für prozentuale Verarbeitung.
            IF pit_kond_art-krech = 'A'. " Prozentual
              pit_kond_art-waers = '3'.
            ENDIF.                       " PIT_KOND_ART-KRECH = 'A'.

*         Falls der Umrechnungsfaktor noch nicht berechnet wurde.
            IF g_einheit <> pit_kond_art-waers.
              g_einheit = pit_kond_art-waers.

*           Berechne Umrechnungsfaktor für Einheit.
              CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
                EXPORTING
                  currency          = pit_kond_art-waers
                IMPORTING
                  factor            = g_curr_factor
                EXCEPTIONS
                  too_many_decimals = 1
                  OTHERS            = 2.

              IF sy-subrc <> 0.
                g_curr_factor = 1.
              ENDIF. " sy-subrc <> 0.
            ENDIF. " h_einheit <> pit_kond_art-waers

*         Berücksichtige die richtige Anzahl von Dezimalstellen
            h_betrag = pit_kond_art-kbetr * g_curr_factor.
            CONDENSE h_betrag.

            IF pit_kond_art-krech = 'A'. " Prozentual
              e1wpa05-kondsatz = h_betrag.
            ELSE.                        " Betrag
              e1wpa05-kondwert = h_betrag.

*           Setze Währungsfeld.
              e1wpa05-currency = pit_kond_art-waers.
            ENDIF.                       " PIT_KOND_ART-KRECH = 'A'.

            e1wpa05-menge = pit_kond_art-kpein.
            CONDENSE e1wpa05-menge.

*         Prüfe, ob die Konditionsart einen Grund- bzw.
*         Vergleichspreis darstellt.
            READ TABLE t_kondart_grund WITH KEY
                 kschl3 = pit_kond_art-kschl
                 BINARY SEARCH.

*         Falls die Konditionsart einen Grund- bzw.
*         Vergleichspreis darstellt.
            IF sy-subrc = 0.
              e1wpa05-content_unit = pit_kond_art-kmein.
            ENDIF. " sy-subrc = 0.

*         Erzeuge temporären IDOC-Segmentsatz.
            gt_idoc_data_temp-segnam = c_e1wpa05_name.
            gt_idoc_data_temp-sdata  = e1wpa05.
            APPEND gt_idoc_data_temp.

*         aktualisiere Segmentzähler.
            ADD 1 TO seg_local_cnt.

*         Falls Segment E1WPA11 (Staffeln) gefüllt werden muß.
            IF pi_e1wpa11 <> space.
*          Aktualisiere Zähler für Staffelwerte.
              ADD 1 TO e1wpa11_cnt.

*           Übernahme von Staffeln, falls vorhanden.
              LOOP AT  pit_staff_art
                   WHERE knumh = pit_kond_art-knumh
                   AND   kopos = pit_kond_art-kopos.

*             KONP-Werte müssen nicht übernommen werden, da sie
*             bereits aufbereitet wurden.
                IF ( pit_staff_art-kstbm IS INITIAL AND
                     pit_staff_art-kzbzg = c_mengenstaffel )  OR
                   ( pit_staff_art-kstbw IS INITIAL AND
                     pit_staff_art-kzbzg = c_wertstaffel ).
                  CONTINUE.
                ENDIF. " pit_staff_art-kstbm is initial    and

*             Fülle Segment E1WPA11.
                CLEAR: e1wpa11.

*             Aktualisiere Zähler für Staffelwerte.
                ADD 1 TO e1wpa11_cnt.

*             Setze Staffelart.
                e1wpa11-scale_type = pit_staff_art-kzbzg.

*             Bestimme das Vorzeichen des Staffelbetrags.
                IF pit_staff_art-kbetr >= 0.
                  e1wpa11-sign = c_plus.
                ELSE.
                  e1wpa11-sign = c_minus.
                ENDIF.                      " pit_staff_art-kbetr >= 0.

*             Es wird nur der Betragswert des Staffelwertes benötigt,
*             da das Vorzeichen extra verschickt wird.
                IF pit_staff_art-kbetr < 0.
                  pit_staff_art-kbetr = -1 * pit_staff_art-kbetr.
                ENDIF.                      " pit_staff_art-kbetr < 0.

*             Falls der Umrechnungsfaktor noch nicht berechnet wurde.
                IF g_einheit <> pit_kond_art-waers.
                  g_einheit = pit_kond_art-waers.

*               Berechne Umrechnungsfaktor für Einheit.
                  CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
                    EXPORTING
                      currency          = pit_kond_art-waers
                    IMPORTING
                      factor            = g_curr_factor
                    EXCEPTIONS
                      too_many_decimals = 1
                      OTHERS            = 2.

                  IF sy-subrc <> 0.
                    g_curr_factor = 1.
                  ENDIF. " sy-subrc <> 0.
                ENDIF. " g_einheit <> pit_kond_art-waers

*             Berücksichtige die richtige Anzahl von Dezimalstellen
                h_betrag = pit_staff_art-kbetr * g_curr_factor.
                CONDENSE h_betrag.

                IF pit_kond_art-krech = 'A'. " Prozentual
                  e1wpa11-cond_rec = h_betrag.
                ELSE.                        " Betrag
                  e1wpa11-cond_value = h_betrag.
                ENDIF.                       " PIT_KOND_ART-KRECH = 'A'.

*             Falls es sich um eine Mengenstaffel handelt
                IF pit_staff_art-kzbzg = c_mengenstaffel.
                  e1wpa11-quantity = pit_staff_art-kstbm.
                  CONDENSE e1wpa11-quantity.

*             Falls es sich um eine Wertestaffel handelt
                ELSEIF pit_staff_art-kzbzg = c_wertstaffel.
*               Falls der Umrechnungsfaktor noch nicht
*               berechnet wurde.
                  IF g_einheit <> pit_kond_art-konws.
                    g_einheit = pit_kond_art-konws.

*                 Berechne Umrechnungsfaktor für Einheit.
                    CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
                      EXPORTING
                        currency          = pit_kond_art-konws
                      IMPORTING
                        factor            = g_curr_factor
                      EXCEPTIONS
                        too_many_decimals = 1
                        OTHERS            = 2.

                    IF sy-subrc <> 0.
                      g_curr_factor = 1.
                    ENDIF. " sy-subrc <> 0.
                  ENDIF. " g_einheit <> pit_kond_art-konws.

*               Berücksichtige die richtige Anzahl von Dezimalstellen
                  h_betrag = pit_staff_art-kstbw * g_curr_factor.
                  CONDENSE h_betrag.

                  e1wpa11-value = h_betrag.

*             Falls es sich um eine andere Staffelart handelt
                ELSE.
*               Staffel ignorieren.
                  CONTINUE.
                ENDIF. " pit_staff_art-kzbzg = c_mengenstaffel

*             Erzeuge temporären IDOC-Segmentsatz.
                gt_idoc_data_temp-segnam = c_e1wpa11_name.
                gt_idoc_data_temp-sdata  = e1wpa11.
                APPEND gt_idoc_data_temp.

*             aktualisiere Segmentzähler.
                ADD 1 TO seg_local_cnt.

              ENDLOOP. " at  pit_staff_art.
            ENDIF. " pi_e1wpa11 <> space.
          ENDIF.                         " PI_E1WPA05 <> SPACE.
        ENDLOOP.                         " PIT_KOND_ART
      ENDIF.                             " Suri  06.08.2019 13:13:00
***> Start of Change Suri : 06.08.2019 13:13:00
*     Falls keine Konditionen für diesen Zeitpunkt existieren
*     und generell Preise aufbereitet werden sollen.
      IF sy-subrc <> 0  AND pi_no_price_send = space.
*       Zwischenspeichern des Returncodes.
*       PE_FEHLERCODE = SY-SUBRC.

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
            PERFORM appl_log_init_with_header
                    USING gi_errormsg_header.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            g_init_log = 'X'.
          ENDIF.                       " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          WRITE pi_datum TO g_datum1 DD/MM/YYYY.

          CLEAR: gi_message.
          gi_message-msgty     = c_msgtp_error.
          gi_message-msgid     = c_message_id.
          gi_message-probclass = c_probclass_sehr_wichtig.
*         'Keine Konditionen für Material &, Verk.einh. &
*         für Datum & gepflegt'
          gi_message-msgno     = '118'.
          gi_message-msgv1     = pit_imara-matnr.
          gi_message-msgv2     = pit_imarm-meinh.
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

*       Aufbereiten der Parameter zum Ändern der
*       Status-Positionszeile.
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
        ELSE.                          " PI_ERMOD <> SPACE.
*         Abbruch des Downloads.
          RAISE download_exit.
        ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.
      ENDIF.     " sy-subrc <> 0  and pi_no_price_send = space.
    ENDIF.                             " PI_E1WPA04 <> SPACE.

*   Falls Segment E1WPA09 (Naturalrabatte) gefüllt werden muß.
    IF pi_e1wpa09 <> space.
*     Besorge die Konditionsdaten für Datum PI_DATUM.
      CLEAR: kschl, e1wpa09_cnt, e1wpa10_cnt.
      LOOP AT pit_natrab_saco
        WHERE datab <= pi_datum
        AND   datbi >= pi_datum.

*       Aktualisiere Zähler für Konditionen
        ADD 1 TO e1wpa09_cnt.

*       Wenn neue Konditionsart, erzeuge neues Segment E1WPA09
        IF pit_natrab_saco-kschl <> kschl.
          kschl = pit_natrab_saco-kschl.

*         Lese die zugehörigen KONDN-Daten.
          READ TABLE pit_kondn WITH KEY
               knumh = pit_natrab_saco-knumh
               BINARY  SEARCH.

*         Fülle Segment E1WPA09.
          CLEAR: e1wpa09.
          e1wpa09-cond_type  = pit_natrab_saco-kschl.
          e1wpa09-start_date = pit_natrab_saco-datab.
          e1wpa09-end_date   = pit_natrab_saco-datbi.
          e1wpa09-promot_no  = pit_kondn-knr_ak.
          e1wpa09-disc_indic = pit_kondn-knrdd.

*         Erzeuge temporären IDOC-Segmentsatz.
          gt_idoc_data_temp-segnam = c_e1wpa09_name.
          gt_idoc_data_temp-sdata  = e1wpa09.
          APPEND gt_idoc_data_temp.

*         aktualisiere Segmentzähler.
          ADD 1 TO seg_local_cnt.
        ENDIF.             " pit_natrab_saco-kschl <> kschl.

*       Falls Segment E1WPA10 (Naturalrabattstaffeln) gefüllt
*       werden muß.
        IF pi_e1wpa10 <> space.
*         Aktualisiere Zähler für Staffelwerte.
          ADD 1 TO e1wpa10_cnt.

*         Übernahme von Staffeln, falls vorhanden.
          LOOP AT pit_kondns
               WHERE knumh = pit_natrab_saco-knumh.

*           Aktualisiere Zähler für Staffelwerte.
            ADD 1 TO e1wpa10_cnt.

*           Fülle Segment E1WPA10.
            CLEAR: e1wpa10.

*           Mindestmenge für Rabattgewährung.
            e1wpa10-min_quant = pit_kondns-knrmm.
            CONDENSE e1wpa10-min_quant.

*           Menge der Drauf- oder Dreingabe.
            e1wpa10-quantity  = pit_kondns-knrnm.
            CONDENSE e1wpa10-quantity.

*           Setze Zugabematerial, falls nötig.
            IF NOT pit_kondns-knrmat IS INITIAL.
*              e1wpa10-disc_mat_long = pit_kondns-knrmat.
*             Outbound Mapping to be able to fill the IDOC structure correctly
              cl_matnr_chk_mapper=>convert_on_output(
                EXPORTING
                  iv_matnr40                   =     pit_kondns-knrmat
                IMPORTING
                  ev_matnr18                   =     e1wpa10-disc_mat
                  ev_matnr40                   =     e1wpa10-disc_mat_long
                EXCEPTIONS
                  excp_matnr_invalid_input     = 1
                  excp_matnr_not_found         = 2
                  OTHERS                       = 3 ).
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
*             Haupt-EAN für Zugabematerial.
*             Besorge die Haupt-EAN zur Komponente.
              CLEAR: pit_natrab_ean.
              LOOP AT pit_natrab_ean
                   WHERE matnr =  pit_kondns-knrmat
                   AND   meinh =  pit_kondns-knrez
                   AND   datab <= pi_datum.
                EXIT.
              ENDLOOP. " AT pit_natrab_ean

*             Falls eine Haupt-EAN zum Zugabematerial vorhanden ist.
              IF sy-subrc = 0 AND pit_natrab_ean-ean11 <> space.
*               Setze Haupt-EAN für Zugabematerial.
                e1wpa10-ean_dscmat = pit_natrab_ean-ean11.

*             Falls keine Haupt-EAN zum Zugabematerial vorhanden ist.
              ELSE.  " SY-SUBRC <> 0 OR pit_natrab_ean-ean11 = SPACE.
*               Falls Fehlerprotokollierung erwünscht.
                IF pi_filia_const-ermod = space.
*                 Falls noch keine Initialisierung des
*                 Fehlerprotokolls.
                  IF g_init_log = space.
*                   Aufbereitung der Parameter zum schreiben
*                   des Headers des Fehlerprotokolls.
                    CLEAR: gi_errormsg_header.
                    gi_errormsg_header-object        = c_applikation.
                    gi_errormsg_header-subobject     = c_subobject.
                    gi_errormsg_header-extnumber     = pi_dldnr.
                    gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
                    gi_errormsg_header-aluser        = sy-uname.

*                   Initialisiere Fehlerprotokoll und erzeuge Header.
                    PERFORM appl_log_init_with_header
                            USING gi_errormsg_header.

*                   Merke, daß Fehlerprotokoll initialisiert wurde.
                    g_init_log = 'X'.
                  ENDIF.                     " G_INIT_LOG = SPACE.

*                 Bereite Parameter zum schreiben der Fehlerzeile auf.
                  WRITE pi_datum TO g_datum1 DD/MM/YYYY.

                  CLEAR: gi_message.
                  gi_message-msgty     = c_msgtp_error.
                  gi_message-msgid     = c_message_id.
                  gi_message-probclass = c_probclass_sehr_wichtig.
*                 'Keine EAN für Zugabematerial & und Verk.einh. &
*                 Datum & gepflegt'
                  gi_message-msgno     = '127'.
                  gi_message-msgv1     = pit_kondns-knrmat.
                  gi_message-msgv2     = pit_kondns-knrez.
                  gi_message-msgv3     = g_datum1.

*                 Schreibe Fehlerzeile für Application-Log und WDLSO.
                  g_object_key = i_key.
                  PERFORM appl_log_write_single_message
                          USING  gi_message.

                ENDIF.     " PI_FILIA_CONST-ERMOD = SPACE.

*               Ändern der Status-Kopfzeile, falls nötig.
                IF g_status < 3.             " 'Fehlende Daten'
                  CLEAR: gi_status_header.
                  gi_status_header-dldnr = pi_dldnr.
                  gi_status_header-gesst = c_status_fehlende_daten.

*                 Korrigiere Status-Kopfzeile auf "Fehlerhaft".
                  PERFORM status_write_head USING  'X'
                                                   gi_status_header
                                                   pi_dldnr
                                                   h_returncode.
*                 Aktualisiere Aufbereitungsstatus.
                  g_status = 3.              " 'Fehlende Daten'
                ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*               Aufbereiten der Parameter zum Ändern der
*               Status-Positionszeile.
                CLEAR: gi_status_pos.
                gi_status_pos-dldnr  = pi_dldnr.
                gi_status_pos-lfdnr  = pi_dldlfdnr.
                gi_status_pos-anloz  = g_err_counter.
                gi_status_pos-anseg  = px_segcnt.
                gi_status_pos-stkey  = g_firstkey.
                gi_status_pos-ltkey  = i_key.

*               Aktualisiere Aufbereitungsstatus für Positionszeile,
*               falls nötig.
                IF g_status_pos < 3.      " 'Fehlende Daten'
                  gi_status_pos-gesst = c_status_fehlende_daten.

                  g_status_pos = 3.        " 'Fehlende Daten'
                ENDIF. " g_status_pos < 3.    " 'Fehlende Daten'

*               Schreibe Status-Positionszeile.
                PERFORM status_write_pos USING 'X' gi_status_pos
                                                   pi_dldlfdnr
                                                   h_returncode.

*               Falls Fehlerprotokollierung erwünscht.
                IF pi_filia_const-ermod = space.
*                 Verlassen der Aufbereitung für dieses Datum.
                  EXIT.
*               Falls Abbruch bei Fehler erwünscht.
                ELSE.          " PI_FILIA_CONST-ERMOD <> SPACE.
*                 Abbruch des Downloads.
                  RAISE download_exit.
                ENDIF.         " PI_FILIA_CONST-ERMOD = SPACE.
              ENDIF.                         " T_MARM-EAN11 <> SPACE.
            ENDIF. " not pit_kondns-knrmat is initial.

*           Zugabemenge
            e1wpa10-add_quant = pit_kondns-knrzm.
            CONDENSE e1wpa10-add_quant.

*           Mengeneinheit der Zugabemenge.
            e1wpa10-quant_unit = pit_kondns-knrez.

*           Rechenregel.
            e1wpa10-calc_rule  = pit_kondns-knrrr.

*           Erzeuge temporären IDOC-Segmentsatz.
            gt_idoc_data_temp-segnam = c_e1wpa10_name.
            gt_idoc_data_temp-sdata  = e1wpa10.
            APPEND gt_idoc_data_temp.

*           aktualisiere Segmentzähler.
            ADD 1 TO seg_local_cnt.

          ENDLOOP. " at  pit_kondns
        ENDIF. " pi_e1wpa10 <> space.
      ENDLOOP.                         " pit_natrab_saco
    ENDIF.                             " PI_E1WPA09 <> SPACE.

*   Falls Segment E1WPA07 (Artikelsteuern) gefüllt werden muß.
    IF pi_e1wpa07 <> space.
*     Rücksetze Zähler für Artikelsteuern.
      CLEAR: e1wpa07_cnt.
      LOOP AT pit_artsteu.
*       Aktualisiere Zähler für Artikelsteuern.
        ADD 1 TO e1wpa07_cnt.

*       Fülle Segment E1WPA07.
        CLEAR: e1wpa07.
        e1wpa07-mwskz = pit_artsteu-mwsk1.

*       Erzeuge temporären IDOC-Segmentsatz.
        gt_idoc_data_temp-segnam = c_e1wpa07_name.
        gt_idoc_data_temp-sdata  = e1wpa07.
        APPEND gt_idoc_data_temp.

*       aktualisiere Segmentzähler.
        ADD 1 TO seg_local_cnt.

      ENDLOOP.                         " AT PIT_ARTSTEU.
    ENDIF.                             " PI_E1WPA07 <> SPACE.

*   Falls Segment E1WPA08 (Artikelnummern) gefüllt werden muß.
*   if pi_e1wpa08 <> space.
*************************************************
**  Artikelnummern. Nicht für Rel. 3.0
*************************************************
*   endif.                             " PI_E1WPA08 <> SPACE.

  ENDIF.                               " PI_LOESCHEN = SPACE.

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '002'
    EXPORTING
      pi_e1wpa03_cnt     = e1wpa03_cnt
      pi_e1wpa04_cnt     = e1wpa04_cnt
      pi_e1wpa05_cnt     = e1wpa05_cnt
      pi_e1wpa07_cnt     = e1wpa07_cnt
      pi_e1wpa09_cnt     = e1wpa09_cnt
      pi_e1wpa10_cnt     = e1wpa10_cnt
      pi_e1wpa11_cnt     = e1wpa11_cnt
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
      pi_mara            = pit_imara
      pi_marm            = pit_imarm
      pi_wlk2            = pit_wlk2dat
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


* Falls Umsetzfehler auftraten.
  IF pe_fehlercode <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Fülle allgemeinen Objektschlüssel.
      CLEAR: gi_object_key.
      gi_object_key-matnr = pit_imara-matnr.
      gi_object_key-vrkme = pit_imarm-meinh.
      g_object_key        = gi_object_key.

*     Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
      PERFORM error_object_write.

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_ERMOD <> SPACE.
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


ENDFORM.                               " IDOC_DATASET_ARTSTM_APPEND


* eject.
************************************************************************
FORM matcond_get_and_analyse
     TABLES pet_kond               STRUCTURE gt_kond_art
            pet_staffeln           STRUCTURE gt_staff_art
            pet_artsteu            STRUCTURE gt_artsteu
            pxt_orgtab             STRUCTURE gt_orgtab_artstm
            pet_date_for_count     STRUCTURE wpdate
     USING  pi_filia_const         STRUCTURE wpfilconst
            pi_filia               LIKE t001w-werks
            pi_artnr               LIKE wlk1-artnr
            pi_vrkme               LIKE wlk1-vrkme
            pi_datab               LIKE syst-datum
            pi_datbi               LIKE syst-datum
            pi_vkorg               LIKE wpstruc-vkorg
            pi_vtweg               LIKE wpstruc-vtweg
            pi_mode                LIKE wpstruc-modus
   CHANGING VALUE(pe_fehlercode)   LIKE syst-subrc
            pi_dldnr               LIKE wdls-dldnr
            pi_dldlfdnr            LIKE wdlsp-lfdnr
            pi_segment_counter     LIKE g_segment_counter
            pi_initdat             LIKE wpstruc-datum
            pi_e1wpa04             LIKE wpstruc-modus
            pi_e1wpa05             LIKE wpstruc-modus
            pi_no_price_send       LIKE wpstruc-modus
            pi_pmata               LIKE mara-pmata.
************************************************************************
* FUNKTION:
* Lese die Daten für Download Artikelstamm-Konditionen im Zeitintervall
* PI_DATAB - PI_DATBI, analysiere diese und fülle Organisationstabelle.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KOND              : Tabelle für Konditionsdaten.

* PET_STAFFELN          : Tabelle für Konditionsstaffeldaten.

* PET_ARTSTEU           : Tabelle der Artikelsteuern.

* PXT_ORGTAB            : Organisationstabelle für Artikelstamm.

* PET_DATE_FOR_COUNT    : Datümer zu denen eine Zählaufforderung
*                         stattfinden soll.
* PI_FILIA_CONST        : Filialkonstanten.

* PI_FILIA              : Filiale.

* PI_ARTNR              : Material der Selektion.

* PI_VRKME              : Verkaufsmengeneinheit der Selektion.

* PI_DATAB              : Beginndatum der Selektion.

* PI_DATBI              : Endedatum der Selektion.

* PI_VKORG              : Verkaufsorganisation.

* PI_VTWEG              : Vertriebsweg.

* PI_MODE               : Download-Modus.

* PE_FEHLERCODE         : = '1', wenn Datenbeschaffung mißlungen,
*                         sonst '0'.
* PI_DLDNR              : Downloadnummer für Statusverfolgung.

* PI_DLDLFDNR           : Laufende Nr. der Positionszeile für
*                         Statusverfolgung.
* PI_SEGMENT_COUNTER    : Segmentzähler.

* PI_INITDAT            : Datum, ab wann initialisiert werden soll. Ist
*                         nur für Änderungs- und Restart-Fall relevant.
* PI_E1WPA04            : = 'X', wenn Segment E1WPA04 aufbereitet
*                         werden soll.
* PI_E1WPA05            : = 'X', wenn Segment E1WPA05 aufbereitet
*                         werden soll.
* PI_NO_PRICE_SEND      : = 'X', wenn kein Preis versendet
*                         werden soll.
* PI_PMATA              : Preismaterial des Artikels (falls vorhanden)
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: readindex         TYPE i,
        read_first_record LIKE wpstruc-modus,
        stock_count       LIKE sy-marky,
        fault             LIKE rvkpu-fault,
        key3              LIKE sy-datum,
        key4              LIKE sy-datum.
  DATA: h_aksch LIKE pespr-aksch.   " Aktionskonditionsart

  DATA: BEGIN OF i_pespr.
          INCLUDE STRUCTURE pespr.
        DATA: END OF i_pespr.

  DATA: BEGIN OF i_stc.
          INCLUDE STRUCTURE pistc.
        DATA: END OF i_stc.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

  DATA: BEGIN OF i_key2.
          INCLUDE STRUCTURE wpart.
        DATA: END OF i_key2.

  DATA: t_kondart_grund    LIKE twpek OCCURS 0 WITH HEADER LINE,
        t_kondart_parallel LIKE twpek OCCURS 0 WITH HEADER LINE.

  DATA lv_mode TYPE wjdposmode.
  DATA lv_pmatn TYPE pmatn.
  STATICS sv_package_size     TYPE pos_max_idoc_size.
  STATICS s_st_mat_vrkme_cond TYPE cl_pos_types=>stty_mat_vrkme_cond.


* Merken des aktuellen Schlüssels.
  i_key-matnr = pi_artnr.
  i_key-vrkme = pi_vrkme.

* Rücksetze Fehlercode.
  CLEAR: pe_fehlercode.

  IF pi_filia_const-taxes_copy = abap_true.
*--- only if the flag "Taxes_copy" is switched on, it it allowed
*--- to use the buffer to determine the conditions:
    IF sv_package_size IS INITIAL.
*--- set mode to 'I' if it is not equal to 'I' or 'U':
      lv_mode = pi_mode.
      IF lv_mode CN 'IU'.
        lv_mode = 'I'.
      ENDIF.
*--- determine the package size:
      PERFORM get_package_size_2 USING    lv_mode
                                 CHANGING sv_package_size.
    ENDIF.

    lv_pmatn = pi_pmata.
    IF lv_pmatn IS INITIAL.
      lv_pmatn = pi_artnr.
    ENDIF.

*--- determine the condition data from the buffer:
    PERFORM get_cond_data_from_buffer TABLES   pet_kond
                                               pet_staffeln
                                               pet_artsteu
                                      USING    pi_filia_const
                                               pi_filia
                                               pi_artnr
                                               pi_vrkme
                                               pi_datab
                                               pi_datbi
                                               pi_vkorg
                                               pi_vtweg
                                               pi_mode
                                               sv_package_size
                                               lv_pmatn
                                      CHANGING s_st_mat_vrkme_cond.
  ELSE.
*--- determine the condition data anyway:
    PERFORM matcond_get
            TABLES pet_kond
                   pet_staffeln
                   pet_artsteu
            USING  pi_filia_const
                   pi_filia
                   pi_artnr
                   pi_vrkme
                   pi_datab
                   pi_datbi
                   pi_vkorg
                   pi_vtweg
                   pi_mode.
  ENDIF.

* Falls Segment E1WPA04 (Konditionen) oder Segment E1WPA05
* (Konditionswerte) gefüllt werden müssen. Aus Reduzierinformatioen.
  IF pi_e1wpa04 <> space OR pi_e1wpa05 <> space.
*   Prüfe, ob ein Preis ermittelt wurde.
***> Start of change : Suri : 05.08.2019 : 15:00:00
***  Des : For Avoiding the validation on Price maintain for material
    IF pet_kond IS NOT INITIAL.                   " Suri : 05.08.2019 : 15:00:00
      LOOP AT pet_kond
        WHERE kntyp <> c_kntyp_steuer
        AND   kntyp <> c_kntyp_agsteuer
        AND   kntyp <> c_kntyp_vsteuer.
        EXIT.
      ENDLOOP.                             " AT PET_KOND
    ENDIF.                                        " Suri : 05.08.2019 : 15:00:00
***> End of change : Suri : 05.08.2019 : 15:00:00
*   Falls kein Preis gefunden wurde.
    IF sy-subrc <> 0.
*     Falls für diesen Artikel generell Preise aufbereitet
*     werden sollen,
      IF pi_no_price_send = space.
*       Zwischenspeichern des Returncodes zum überspringen dieser
*       Verkaufsmengeneinheit.
        pe_fehlercode = sy-subrc.

*     Fall ein Preis nicht generell erforderlich ist.
      ELSE. " pi_no_price_send <> space.
        REFRESH: pet_kond.
      ENDIF.          " pi_no_price_send = space.

*     Eine Verkaufsmengeneinheit soll nur dann aufbereitet werden,
*     wenn sie eine EAN und einen Preis hat. Fehlt wie in diesem
*     Falle der Preis, dann kann die Aufbereitung für diese
*     Verkaufsmengeneinheit abgebrochen werden.
      EXIT.
    ENDIF.                               " SY-SUBRC <> 0.

    SORT pet_kond BY datab kschl.
    LOOP AT pet_kond
      WHERE kntyp <> c_kntyp_steuer
      AND   kntyp <> c_kntyp_agsteuer
      AND   kntyp <> c_kntyp_vsteuer.

*     Das Feld DATAB muß den Wert PI_DATAB haben, da dieser
*     Satz in jedem Fall versendet wird.
      IF pet_kond-datab < pi_datab.
        pet_kond-datab = pi_datab.
        MODIFY pet_kond.
      ENDIF.                             " PET_KOND-DATUM < PI_DATAB.

      IF sy-tabix = 1.
*       Vermerke in Org.Tabelle das Lesen des ersten Satzes.
        readindex = pet_kond-datab - pi_datab + 1.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-kond  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies
*         in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_kond-datab.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND ...
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Vermerke in Org.Tabelle, daß der erste Satz
*         versendet werden soll.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX readindex.

      ENDIF.                             " SY-TABIX = 1.

      IF pet_kond-datab > pi_datab.
*       Jeder Satz muß in der Org.Tabelle vermerkt werden
        readindex = pet_kond-datab - pi_datab + 1.
        READ TABLE pxt_orgtab INDEX readindex.
        pxt_orgtab-kond  = 'X'.

*       Falls Änderungsfall.
        IF pi_mode = c_change_mode.
*         Falls initialisiert werden soll, vermerke dies
*         in Org.Tabelle.
          IF pi_initdat <> space AND pi_initdat <= pet_kond-datab.
            pxt_orgtab-change = 'X'.
          ENDIF. " PI_INITDAT <> SPACE AND ...
*       Falls Initialisierungsfall, direkte Anforderung oder Restart.
        ELSE.
*         Vermerke jeden Satz in Org.-Tabelle.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_MODE = C_CHANGE_MODE

        MODIFY pxt_orgtab INDEX readindex.
      ENDIF.                             " PET_KOND-DATAB > PI_DATAB.
    ENDLOOP.                             " AT PET_KOND.

*   Bestimme die Aktions- und die Verkaufskonditionsart
    CLEAR: i_pespr.
    CALL FUNCTION 'SALES_PRICE_COND_TYPE_GET'
      EXPORTING
        pi_vkorg                    = pi_vkorg
        pi_vtweg                    = pi_vtweg
        pi_werks                    = pi_filia
      IMPORTING
        pe_i_spr                    = i_pespr
*        tables
*       PET_AKSCH                   = T_AKSCH
      EXCEPTIONS
        plant_not_found             = 1
        org_structure_not_completed = 2
        vkorg_not_found             = 3
        no_calculation_type_found   = 4
        no_condition_types_found    = 5
        invalid_import              = 6
        customer_is_no_plant        = 7
        OTHERS                      = 8.

*   sort t_aksch by aksch.
*   clear: h_aksch.
*   LOOP AT PET_KOND
*        WHERE KNTYP <> C_KNTYP_STEUER
*        AND   KNTYP <> C_KNTYP_AGSTEUER
*        AND   KNTYP <> C_KNTYP_VSTEUER
*        AND   kschl <> I_PESPR-VKSCH.

*     Prüfe, ob die Konditionsart eine Aktionskonditionsart ist.
*     read t_aksch with key
*          aksch = i_pespr-aksch
*          binary search.

*     Falls die Konditionsart eine Aktionskonditionsart ist.
*     if sy-subrc = 0.
*       Merke die Aktionskonditionsart.
*       h_aksch = t_aksch.
*       exit.
*     endif. " sy-subrc = 0.

*   endLOOP. " AT PET_KOND

*   Bestimme die Sortierreihenfolge, damit die Aktionskondition
*   immer vor der Verkaufskondition steht.
*   IF I_PESPR-VKSCH > H_AKSCH.
    IF i_pespr-vksch > i_pespr-aksch.
      SORT pet_kond BY datab kschl.
    ELSE." i_pespr-vksch <= i_pespr-Aksch.
      SORT pet_kond BY datab kschl DESCENDING.
    ENDIF. " i_pespr-vksch > i_pespr-aksch.

*   Falls kein Simulationsmodus.
    IF g_simulation IS INITIAL.
*     Überprüfe die Zählaufforderung für diesen Artikel
      CLEAR: key3, key4.
      LOOP AT pet_kond
        WHERE kntyp <> c_kntyp_steuer
        AND   kntyp <> c_kntyp_agsteuer
        AND   kntyp <> c_kntyp_vsteuer
        AND ( kschl = i_pespr-vksch OR           " Verkaufskondition
              kschl = i_pespr-aksch ).           " Aktionskondition

*       Falls sich der Preis nicht geändert hat, dann keine
*       Zählaufforderung nötig.
        IF pet_kond-chgfl IS INITIAL.
          CONTINUE.
        ENDIF. " pet_kond-chgfl is initial.

        MOVE pet_kond-datab_kond TO key4.

*       Der Preis hat sich geändert und es muß zu einem neuen
*       Datum aufbereitet werden ===> Zählaufforderung prüfen.
        IF key3 <> key4.
          key4 = key3.
*       Falls zu einem Datum zwei geänderte Preise sowohl für den
*       Aktionspreis als auch für den Verkaufspreis vorliegen, dann
*       hat die Aktion Priorität und nur hier muß eine Zählaufforderung
*       überprüft werden. Ansonsten weiter zum nächsten Satz.
        ELSE. " key3 = key4.
          CONTINUE.
        ENDIF. " key3 <> key4.

        CLEAR: gi_message, i_stc.
        i_stc-werks = pi_filia.
        i_stc-vkorg = pi_vkorg.
        i_stc-vtweg = pi_vtweg.
        i_stc-matnr = pi_artnr.
        i_stc-kschl = pet_kond-kschl.
        i_stc-vkkab = pet_kond-datab_kond.
        i_stc-datab = g_erstdat.
        i_stc-vpneu = pet_kond-kbetr.
        i_stc-vrkpe = pet_kond-kpein.
        i_stc-vrkme = pet_kond-kmein.
        i_stc-vwaer = pet_kond-waers.

        CALL FUNCTION 'STOCK_COUNT_CHECK'
          EXPORTING
            pi_i_stc       = i_stc
          IMPORTING
            pe_stock_count = stock_count
            pe_fault       = fault
          EXCEPTIONS
            sy_message     = 1
            OTHERS         = 2.

*       Falls keine Fehler auftraten.
        IF sy-subrc = 0.
*         Falls der Artikel neu gezählt werden muß.
          IF NOT stock_count IS INITIAL.
*           Übernehme das Datum, zu dem eine Zählaufforderung gesetzt
*           werden soll in eine interne Tabelle.

            pet_date_for_count-datab = pet_kond-datab_kond.

*           Das Feld DATAB muß den Wert PI_DATAB haben, da dieser
*           Satz in jedem Fall versendet wird.
            IF pet_date_for_count-datab < pi_datab.
              pet_date_for_count-datab = pi_datab.
            ENDIF.         " pet_date_for_count-datab < PI_DATAB.

            APPEND pet_date_for_count.
          ENDIF. " not stock_count is initial

        ENDIF. " sy-subrc = 0.
      ENDLOOP. " at pet_kond
    ENDIF. " g_simulation is initial.

*   Umsortieren der Daten für spätere Weiterverarbeitung.
*   Zur Unterstützung der Konverter muß diesmal die Aktionskondition
*   immer nach der Verkaufskondition kommen.
    IF i_pespr-aksch < i_pespr-vksch.
      SORT pet_kond BY datab kschl DESCENDING kmein datab.
    ELSE." i_pespr-aksch >= i_pespr-vksch.
      SORT pet_kond BY datab kschl kmein datab.
    ENDIF. " i_pespr-aksch < i_pespr-vksch.

*   Besorge die Grund- bzw. Vergleichspreiskonditionsarten
    PERFORM kondart_grundpreis_get
            TABLES t_kondart_grund
            USING  pi_filia_const.

*   Besorge die Parallelpreiskonditionsarten
    PERFORM kondart_parallelpreis_get
            TABLES t_kondart_parallel
            USING  pi_filia_const.

*   Prüfe, ob eine weitere Änderung der Reihenfolge notwendig ist.
    READ TABLE t_kondart_grund INDEX 1.

    IF t_kondart_grund-kschl3 IS INITIAL.
      READ TABLE t_kondart_parallel INDEX 1.

      IF t_kondart_parallel-kschl2 IS INITIAL.
*       Die Reihenfolge muß nicht weiter geändert werden.
        EXIT.
      ENDIF. " t_kondart_parallel-kschl2 is initial.
    ENDIF. " t_kondart_grund-kschl3 is initial.

*   Ändere die Reihenfolge der Tabelleneinträge so, dass NACH jeder
*   Verkaufs- oder Aktionspreiskonditionsart die zugehörigen
*   Parallel- bzw. Grund-/Vergleichspreiskonditionsarten zur
*   Aufbereitung gelangen.
    PERFORM condition_order_change
            TABLES pet_kond
                   t_kondart_grund
                   t_kondart_parallel
            USING  i_pespr.

  ENDIF. " pi_E1WPA04 <> space or pi_E1WPA05 <> space.


ENDFORM.                               " MATCOND_GET_AND_ANALYSE


* eject.
************************************************************************
FORM mat_natrab_get_and_analyse
     TABLES pet_natrab_saco        STRUCTURE gt_natrab_saco
            pet_kondn              STRUCTURE gt_kondn
            pet_kondns             STRUCTURE gt_kondns
            pet_natrab_ean         STRUCTURE gt_natrab_ean
            pxt_orgtab             STRUCTURE gt_orgtab_artstm
     USING  pi_filia_const         STRUCTURE wpfilconst
            pi_filia               LIKE t001w-werks
            pi_artnr               LIKE wlk1-artnr
            pi_vrkme               LIKE wlk1-vrkme
            pi_datab               LIKE syst-datum
            pi_datbi               LIKE syst-datum
            pi_vkorg               LIKE wpstruc-vkorg
            pi_vtweg               LIKE wpstruc-vtweg
            pi_mode                LIKE wpstruc-modus
            pi_initdat             LIKE wpstruc-datum
            pi_no_price_send       LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Lese die Daten für Download Artikelstamm-Naturalrabatte im
* Zeitintervall PI_DATAB - PI_DATBI, analysiere diese und fülle die
* Organisationstabelle.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_NATRAB_SACO       : Tabelle für SACO-Daten der Naturalrabatte.

* PET_KONDN             : Naturalrabattpositionen.

* PET_KONDNS            : Naturalrabattstaffeln.

* PET_NATRAB_EAN        : Haupt-EAN-Änderungen der Zugabematerialien.

* PXT_ORGTAB            : Organisationstabelle für Artikelstamm.

* PI_FILIA_CONST        : Filialkonstanten.

* PI_FILIA              : Filiale.

* PI_ARTNR              : Material der Selektion.

* PI_VRKME              : Verkaufsmengeneinheit der Selektion.

* PI_DATAB              : Beginndatum der Selektion.

* PI_DATBI              : Endedatum der Selektion.

* PI_VKORG              : Verkaufsorganisation.

* PI_VTWEG              : Vertriebsweg.

* PI_MODE               : Download-Modus.

* PI_INITDAT           : Datum, ab wann initialisiert werden soll. Ist
*                        nur für Änderungs- und Restart-Fall relevant.
* PI_NO_PRICE_SEND     : = 'X', wenn kein Preis versendet
*                        werden soll (dann auch kein Naturalrabatt).
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: readindex            TYPE i,
        read_first_record    LIKE wpstruc-modus,
        no_record_found_marm.

  DATA: BEGIN OF i_key1,
          matnr LIKE marm-matnr,
          meinh LIKE marm-meinh.
  DATA: END OF i_key1.

  DATA: BEGIN OF i_key2.
          INCLUDE STRUCTURE i_key1.
        DATA: END OF i_key2.

* Für Haupt-EAN-Auswertung der Positionen.
  DATA: BEGIN OF t_keytab OCCURS 20.
          INCLUDE STRUCTURE i_key1.
        DATA: END OF t_keytab.

* Nur als Dummy für FB-Aufruf.
  DATA: BEGIN OF t_mara OCCURS 1.
          INCLUDE STRUCTURE gt_imara.
        DATA: END OF t_mara.

* Zum zwischenspeichern der Haupt-EAN-Änderungen.
  DATA: BEGIN OF t_marm OCCURS 10.
          INCLUDE STRUCTURE gt_imarm.
        DATA: END OF t_marm.


  read_first_record = 'X'.
  REFRESH: pet_natrab_saco, pet_kondn, pet_kondns.
  CLEAR:   pet_natrab_saco, pet_kondn, pet_kondns.

* Einlesen der Naturalrabattdaten.
  CALL FUNCTION 'SALES_CONDITIONS_READ'
    EXPORTING
      pi_datab                     = pi_datab
      pi_datbi                     = pi_datbi
      pi_incfi                     = read_first_record
      pi_matnr                     = pi_artnr
      pi_vrkme                     = pi_vrkme
      pi_vkorg                     = pi_vkorg
      pi_vtweg                     = pi_vtweg
      pi_werks                     = pi_filia
      pi_kvewe                     = c_natrab_vewe
      pi_kappl                     = c_natrab_appl
*     pi_kunnr                     = pi_filia_const-kunnr
      pi_scale_read                = 'X'
    TABLES
      pe_t_saco                    = pet_natrab_saco
      pe_t_kondn                   = pet_kondn
      pe_t_kondns                  = pet_kondns
    EXCEPTIONS
      no_bukrs_found               = 1
      plant_not_found              = 2
      material_not_found           = 3
      org_structure_not_completed  = 4
      vkorg_not_found              = 5
      no_pos_condition_types_found = 6
      no_condition_types_match     = 7
      OTHERS                       = 8.

* Prüfe, ob ein Naturalrabatt ermittelt wurde.
  READ TABLE pet_kondn INDEX 1.

* Falls kein Naturalrabatt gefunden wurde.
  IF sy-subrc <> 0.
    REFRESH: pet_natrab_saco.

*   Keine weitere Aufbereitung nötig.
    EXIT.
  ENDIF.                               " SY-SUBRC <> 0.

* Daten sortieren.
  SORT pet_natrab_saco BY datab kschl.
  SORT pet_kondn  BY knumh.

  LOOP AT pet_natrab_saco.
*   Das Feld DATAB muß den Wert PI_DATAB haben, da dieser
*   Satz in jedem Fall versendet wird.
    IF pet_natrab_saco-datab < pi_datab.
      pet_natrab_saco-datab = pi_datab.
      MODIFY pet_natrab_saco.
    ENDIF.                 " pet_natrab_saco-datab < pi_datab.

    IF sy-tabix = 1.
*     Vermerke in Org.Tabelle das Lesen des ersten Satzes.
      readindex = pet_natrab_saco-datab - pi_datab + 1.
      READ TABLE pxt_orgtab INDEX readindex.
      pxt_orgtab-kond  = 'X'.

*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Falls initialisiert werden soll, vermerke dies
*       in Org.Tabelle.
        IF pi_initdat <> space AND
           pi_initdat <= pet_natrab_saco-datab.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_INITDAT <> SPACE AND ...
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      ELSE.
*       Vermerke in Org.Tabelle, daß der erste Satz
*       versendet werden soll.
        pxt_orgtab-change = 'X'.
      ENDIF. " PI_MODE = C_CHANGE_MODE

      MODIFY pxt_orgtab INDEX readindex.
    ENDIF.                             " SY-TABIX = 1.

    IF pet_natrab_saco-datab > pi_datab.
*     Jeder Satz muß in der Org.Tabelle vermerkt werden
      readindex = pet_natrab_saco-datab - pi_datab + 1.
      READ TABLE pxt_orgtab INDEX readindex.
      pxt_orgtab-kond  = 'X'.

*     Falls Änderungsfall.
      IF pi_mode = c_change_mode.
*       Falls initialisiert werden soll, vermerke dies
*       in Org.Tabelle.
        IF pi_initdat <> space AND
           pi_initdat <= pet_natrab_saco-datab.
          pxt_orgtab-change = 'X'.
        ENDIF. " PI_INITDAT <> SPACE AND ...
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      ELSE.
*       Vermerke jeden Satz in Org.-Tabelle.
        pxt_orgtab-change = 'X'.
      ENDIF. " PI_MODE = C_CHANGE_MODE

      MODIFY pxt_orgtab INDEX readindex.
    ENDIF.                   " pet_natrab_saco-DATAB > PI_DATAB.
  ENDLOOP.                " AT pet_natrab_saco.

* Staffeldaten sortieren.
  SORT pet_kondns BY knrmat knrez.

* Übernehme alle unterschiedlichen Schlüssel der Zugabematerialien
* in interne Tabelle.
  REFRESH: t_keytab.
  CLEAR: i_key1, i_key2, t_keytab.
  LOOP AT pet_kondns
       WHERE knrmat <> space.

    i_key2-matnr = pet_kondns-knrmat.
    i_key2-meinh = pet_kondns-knrez.

    IF i_key1 <> i_key2.
      i_key1 = i_key2.
      APPEND i_key1 TO t_keytab.
    ENDIF.                             " I_KEY1 <> I_KEY2.
  ENDLOOP.                             " at pet_kondns.

* Rücksetze Tabelle der Haupt-EAN's der Naturalrabattstaffeln.
  REFRESH: pet_natrab_ean.
  CLEAR:   pet_natrab_ean.

* Besorge alle nötigen Haupt-EAN-Änderungen Naturalrabattstaffeln.
  LOOP AT t_keytab.
*   Rücksetze interne Tabellen.
    REFRESH: t_marm, t_mara.
    CLEAR:   t_marm, t_mara.

*   Füllen des Tabellenschlüssels.
    t_marm-mandt = sy-mandt.
    t_marm-matnr = t_keytab-matnr.
    t_marm-meinh = t_keytab-meinh.
    APPEND t_marm.

* ### zukünftige Änderung.
*     Besorge Material-Stammdaten bzgl. der Haupt-EAN-Änderung.
*     call function 'MATERIAL_CHANGE_DOCUMENTATION'
*          exporting
*               date_from            = pi_datab
*               date_to              = pi_datbi
*               explosion            = 'X'
*               indicator            = 'X'
*          importing
*               no_record_found_marm = no_record_found_marm
*          tables
*               jmara                = t_mara
*               jmarm                = t_marm
*               change_field_tab     = pit_field_tab
*          exceptions
*               wrong_date_relation  = 01.

    CALL FUNCTION 'POS_MATERIAL_GET'
      EXPORTING
        pi_datab             = pi_datab
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
*         Falls initialisiert werden soll, vermerke dies
*         in Org.Tabelle.
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
            ENDIF. " PI_INITDAT <> SPACE AND ...
*         Falls Initialisierungsfall, direkte Anforderung
*         oder Restart.
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
      pet_natrab_ean-datab = t_marm-datum.
      pet_natrab_ean-matnr = t_marm-matnr.
      pet_natrab_ean-meinh = t_marm-meinh.
      pet_natrab_ean-ean11 = t_marm-ean11.
      APPEND pet_natrab_ean.

    ENDLOOP.                           " AT T_MARM.
  ENDLOOP.                             " AT T_KEYTAB.

* Umsortieren der Daten für spätere Weiterverarbeitung.
  SORT pet_natrab_saco BY datab kschl kmein.
  SORT pet_kondns BY knumh knrpos.
  SORT pet_natrab_ean BY matnr meinh datab DESCENDING.


ENDFORM.                               " MAT_NATRAB_GET_AND_ANALYSE


* eject.
************************************************************************
FORM artstm_delete
     USING  pi_artnr       LIKE      gt_ot3_artstm-artnr
            pi_vrkme       LIKE      gt_ot3_artstm-vrkme
            pi_ean         LIKE      wpdel-ean
            pi_datum       LIKE      gt_ot3_artstm-datum
            pi_ermod       LIKE      gt_filia_group-ermod
            pi_kunnr       LIKE      gt_filia_group-kunnr
   CHANGING pxt_idoc_data  TYPE      short_edidd
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
        e1wpa03_cnt   TYPE i VALUE 0,
        e1wpa04_cnt   TYPE i VALUE 0,
        e1wpa05_cnt   TYPE i VALUE 0,
        e1wpa07_cnt   TYPE i VALUE 0,
        e1wpa09_cnt   TYPE i VALUE 0,
        e1wpa10_cnt   TYPE i VALUE 0,
        e1wpa11_cnt   TYPE i VALUE 0,
        h_numtp       LIKE marm-numtp.

  DATA: t_matnr LIKE gt_matnr    OCCURS 0 WITH HEADER LINE,
        t_marm  LIKE gt_marm_buf OCCURS 0 WITH HEADER LINE.

* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: gt_idoc_data_temp.

* Rücksetze Fehlercode.
  CLEAR: pe_fehlercode, h_numtp.

* Aufbereitung ID-Segment.
  CLEAR: e1wpa01.
  e1wpa01-filiale    = pi_kunnr.
  e1wpa01-aendkennz  = c_delete.
  e1wpa01-aktivdatum = pi_datum.
  e1wpa01-aenderer   = ' '.
  e1wpa01-aenddatum  = '00000000'.
*  e1wpa01-artikelnr_long  = pi_artnr.
* Outbound Mapping to be able to fill the IDOC structure correctly
  cl_matnr_chk_mapper=>convert_on_output(
    EXPORTING
      iv_matnr40                   =     pi_artnr
    IMPORTING
      ev_matnr18                   =     e1wpa01-artikelnr
      ev_matnr40                   =     e1wpa01-artikelnr_long
    EXCEPTIONS
      excp_matnr_invalid_input     = 1
      excp_matnr_not_found         = 2
      OTHERS                       = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  e1wpa01-posme      = pi_vrkme.

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
      output  = e1wpa01-hauptean.

* Erzeuge temporären IDOC-Segmentsatz.
  gt_idoc_data_temp-segnam = c_e1wpa01_name.
  gt_idoc_data_temp-sdata  = e1wpa01.
  APPEND gt_idoc_data_temp.

* aktualisiere Segmentzähler.
  ADD 1 TO seg_local_cnt.

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '002'
    EXPORTING
      pi_e1wpa03_cnt     = e1wpa03_cnt
      pi_e1wpa04_cnt     = e1wpa04_cnt
      pi_e1wpa05_cnt     = e1wpa05_cnt
      pi_e1wpa07_cnt     = e1wpa07_cnt
      pi_e1wpa09_cnt     = e1wpa09_cnt
      pi_e1wpa10_cnt     = e1wpa10_cnt
      pi_e1wpa11_cnt     = e1wpa11_cnt
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
    ELSE.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE error_code_1.
    ENDIF.                             " PI_ERMOD = SPACE.

* Falls Umschlüsselung fehlerfrei.
  ELSE.                                " PE_FEHLERCODE = 0.
*   Übernehme die IDOC-Daten aus Temporärtabelle.
    PERFORM idoc_data_assume TABLES  gt_idoc_data_temp
                             USING   pxt_idoc_data
                                     px_segcnt
                                     seg_local_cnt.

  ENDIF.                               " PE_FEHLERCODE <> 0.
*********************************************************************


ENDFORM.                               " ARTSTM_DELETE


* eject.
************************************************************************
FORM artstm_matdata_get
     TABLES pet_imara      STRUCTURE gt_imara
            pet_imarm      STRUCTURE gt_imarm
            pet_imakt      STRUCTURE gt_imakt
            pet_imamt      STRUCTURE gt_imamt
     USING  pi_artnr       LIKE marm-matnr
            pi_vrkme       LIKE marm-meinh
            pi_spras       LIKE t001w-spras
            pi_datab       LIKE syst-datum
            pi_datbi       LIKE syst-datum
            pi_mode        LIKE wpstruc-modus
   CHANGING pe_found_marm  LIKE wpmara-chgflag
            pe_found_makt  LIKE wpmara-chgflag
            pe_found_mamt  LIKE wpmara-chgflag
            pi_filia_const STRUCTURE  wpfilconst
            pi_e1wpa03     LIKE wpstruc-modus
            VALUE(pe_fehlercode) LIKE syst-subrc.
************************************************************************
* FUNKTION:
* Besorge Material-Stammdaten für den Download Artikelstamm aus
* internen Puffer oder von DB.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_IMARA    : Tabelle für MARA-Daten.

* PET_IMARM    : Tabelle für MARM-Daten.

* PET_IMAKT    : Tabelle für MAKT-Daten.

* PET_IMAMT    : Tabelle für MAMT-Daten.

* PI_ARTNR     : Artikelnummer der Selektion.

* PI_VRKME     : Verkaufsmengeneinheit der Selektion.

* PI_SPRAS     : Sprachenschlüssel der Selektion.

* PI_DATAB     : Beginndatum der Selektion.

* PI_DATBI     : Endedatum der Selektion.

* PI_MODE      : Download-Modus.

* PE_FOUND_MARM: = 'X', wenn keine MARM-Daten gefunden, sonst SPACE

* PE_FOUND_MAKT: = 'X', wenn keine MAKT-Daten gefunden, sonst SPACE

* PE_FOUND_MAMT: = 'X', wenn keine MAMT-Daten gefunden, sonst SPACE

* PI_FILIA_CONST: Filialkonstanten.

* PI_E1WPA03    : = 'X', wenn Segment E1WPA03 aufbereitet werden soll.

* PE_FEHLERCODE: > 0, wenn keine MARA-Daten gefunden, sonst SPACE
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: readindex  LIKE sy-tabix,
        datab      LIKE sy-datum,
        datbi      LIKE sy-datum,
        h_datum    LIKE sy-datum,
        returncode LIKE sy-subrc,
        h_dummy.


* Initialisieren der Ausgabetabellen
  REFRESH: pet_imara, pet_imarm, pet_imakt, pet_imamt.
  CLEAR:   pet_imara, pet_imarm, pet_imakt, pet_imamt.

* Rücksetze Fehlermerker.
  CLEAR: pe_found_marm, pe_found_makt, pe_found_mamt.
  CLEAR: pe_fehlercode.

* Falls ein neuer Artikel gelesen werden muß
  IF pi_artnr <> g_artnr_buf_artstm.
*   Merken des neuen Artikel in globaler Variable.
    g_artnr_buf_artstm = pi_artnr.

*   Initialisieren der Puffertabellen
    REFRESH: gt_imara_buf, gt_imarm_buf, gt_imakt_buf, gt_imamt_buf.
    CLEAR:   gt_imara_buf, gt_imarm_buf, gt_imakt_buf, gt_imamt_buf.

*   Füllen der einzelnen Tabellenschlüssel.
    gt_imara_buf-mandt = sy-mandt.
    gt_imara_buf-matnr = pi_artnr.
    APPEND gt_imara_buf.

    gt_imarm_buf-mandt = sy-mandt.
    gt_imarm_buf-matnr = pi_artnr.
    APPEND gt_imarm_buf.


*   Falls Segment E1WPA03 (Artikeltexte) gefüllt werden muß.
    IF pi_e1wpa03 <> space.
      gt_imakt_buf-mandt = sy-mandt.
      gt_imakt_buf-matnr = pi_artnr.
      gt_imakt_buf-spras = pi_spras.
      APPEND gt_imakt_buf.

*     Falls Bontexte benötigt werden.
      IF pi_filia_const-no_bontext IS INITIAL.
        gt_imamt_buf-mandt = sy-mandt.
        gt_imamt_buf-matnr = pi_artnr.
        gt_imamt_buf-spras = pi_spras.
        APPEND gt_imamt_buf.
      ENDIF. " pi_filia_const-no_bontext is initial.
    ENDIF. " pi_e1wpa03 <> space.

*   Die Tabelle MEAN wird nicht benötigt.

    CALL FUNCTION 'POS_MATERIAL_GET'
      EXPORTING
        pi_datab             = pi_datab
        marm_ean_check       = 'X'
        pi_exception_mode    = 'X'
        pi_filter_text_id    = 'X'
      IMPORTING
        no_record_found_marm = pe_found_marm
        no_record_found_makt = pe_found_makt
        no_record_found_mamt = pe_found_mamt
      TABLES
        p_t_cmara            = gt_imara_buf
        p_t_cmarm            = gt_imarm_buf
        p_t_cmakt            = gt_imakt_buf
        p_t_cmamt            = gt_imamt_buf
      EXCEPTIONS
        no_record_found_mara = 01
        OTHERS               = 02.

*   Falls Fehler auftraten.
    IF sy-subrc <> 0 OR pe_found_marm <> space OR
       pe_found_makt <> space.
*     Zwischenspeichern des Returncodes, falls nötig.
      IF sy-subrc <> 0.
        pe_fehlercode = 1.
      ENDIF. " sy-subrc <> 0.

*     Merken, daß beim nächsten mal der interne Puffer neu
*     gefüllt werden muß.
      CLEAR: g_artnr_buf_artstm.

*     Routine verlassen.
      EXIT.
    ENDIF. " pe_found_mara <> space or pe_found_marm <> space or ...

*   Pufferdaten sortieren.
    SORT gt_imara_buf BY        datum DESCENDING.
    SORT gt_imarm_buf BY  meinh datum DESCENDING.
    SORT gt_imakt_buf BY        datum DESCENDING.
    SORT gt_imamt_buf BY  meinh datum DESCENDING mtxid lfdnr.

  ENDIF.                               " pi_artnr = g_artnr_buf_artstm.

*******************************************
* Übernahme MARA-Daten in Ausgabetabelle.
  CLEAR: h_datum, h_dummy.
  LOOP AT gt_imara_buf
       WHERE matnr =  pi_artnr
       AND   datum <= pi_datbi.

    IF gt_imara_buf-datum > pi_datab.
      pet_imara = gt_imara_buf.
      APPEND pet_imara.
    ELSEIF gt_imara_buf-datum = pi_datab.
      pet_imara = gt_imara_buf.
      APPEND pet_imara.

*     Merken, daß keine noch kleineren Datümer übernommen werden
*     müssen.
      h_dummy   = 'X'.
    ELSEIF gt_imara_buf-datum < pi_datab.
*     Falls bereits alle Daten übernommen wurden, dann
*     Routine verlassen.
      IF h_dummy <> space.
        EXIT.
*     Falls noch Daten übernommen werden müssen.
      ELSEIF h_dummy = space.
        IF gt_imara_buf-datum >= h_datum.
          pet_imara       = gt_imara_buf.
          pet_imara-datum = pi_datab.
          APPEND pet_imara.

*         Merke das kleinste Datum, welches noch übernommen
*         werden muß.
          h_datum = gt_imara_buf-datum.
        ELSE.                          " gt_imara_buf-datum < h_datum.
*         Routine verlassen.
          EXIT.
        ENDIF.                         " gt_imara_buf-datum >= h_datum.
      ENDIF. " h_dummy <> space.
    ENDIF.                             " gt_imara_buf-datum > pi_datab.

  ENDLOOP.                             " at gt_imara_buf

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
*   Merken, daß keine MARA-Satz gefunden wurde.
    pe_fehlercode = 1.

*   Routine verlassen.
    EXIT.
* Falls keine Fehler auftraten.
  ELSE.                                " sy-subrc = 0.
*   Sortiere Daten der Ausgabetabelle.
    SORT pet_imara BY datum.
  ENDIF.                               " sy-subrc <> 0

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
      ENDIF. " h_dummy <> space.
    ENDIF.                             " gt_imarm_buf-datum > pi_datab.

  ENDLOOP.                             " at gt_imarm_buf

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
*   Merken, daß keine MARM-Satz gefunden wurde.
    pe_found_marm = 'X'.

*   Routine verlassen.
    EXIT.
* Falls keine Fehler auftraten.
  ELSE.                                " sy-subrc = 0.
*   Sortiere Daten der Ausgabetabelle.
    SORT pet_imarm BY datum.
  ENDIF.                               " sy-subrc <> 0

*******************************************
* Übernahme MAKT-Daten in Ausgabetabelle.
  CLEAR: h_datum, h_dummy.
  LOOP AT gt_imakt_buf
       WHERE matnr =  pi_artnr
       AND   spras =  pi_spras
       AND   datum <= pi_datbi.

    IF gt_imakt_buf-datum > pi_datab.
      pet_imakt = gt_imakt_buf.
      APPEND pet_imakt.
    ELSEIF gt_imakt_buf-datum = pi_datab.
      pet_imakt = gt_imakt_buf.
      APPEND pet_imakt.

*     Merken, daß keine noch kleineren Datümer übernommen werden
*     müssen.
      h_dummy   = 'X'.
    ELSEIF gt_imakt_buf-datum < pi_datab.
*     Falls bereits alle Daten übernommen wurden, dann
*     Routine verlassen.
      IF h_dummy <> space.
        EXIT.
*     Falls noch Daten übernommen werden müssen.
      ELSEIF h_dummy = space.
        IF gt_imakt_buf-datum >= h_datum.
          pet_imakt       = gt_imakt_buf.
          pet_imakt-datum = pi_datab.
          APPEND pet_imakt.

*         Merke das kleinste Datum, welches noch übernommen
*         werden muß.
          h_datum = gt_imakt_buf-datum.
        ELSE.                          " gt_imakt_buf-datum < h_datu
*         Routine verlassen.
          EXIT.
        ENDIF.                         " gt_imakt_buf-datum >= h_datum.
      ENDIF. " h_dummy <> space.
    ENDIF.                             " gt_imakt_buf-datum > pi_datab.

  ENDLOOP.                             " at gt_imakt_buf

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
*   Merken, daß keine MAKT-Satz gefunden wurde.
    pe_found_makt = 'X'.

*   Routine verlassen.
    EXIT.
* Falls keine Fehler auftraten.
  ELSE.                                " sy-subrc = 0.
*   Sortiere Daten der Ausgabetabelle.
    SORT pet_imakt BY datum.
  ENDIF.                               " sy-subrc <> 0

*******************************************
* Übernahme MAMT-Daten in Ausgabetabelle.
  CLEAR: h_datum, h_dummy.
  LOOP AT gt_imamt_buf
       WHERE matnr =  pi_artnr
       AND   spras =  pi_spras
       AND   meinh =  pi_vrkme
       AND   datum <= pi_datbi.

    IF gt_imamt_buf-datum > pi_datab.
      pet_imamt = gt_imamt_buf.
      APPEND pet_imamt.
    ELSEIF gt_imamt_buf-datum = pi_datab.
      pet_imamt = gt_imamt_buf.
      APPEND pet_imamt.

*     Merken, daß keine noch kleineren Datümer übernommen werden
*     müssen.
      h_dummy   = 'X'.
    ELSEIF gt_imamt_buf-datum < pi_datab.
*     Falls bereits alle Daten übernommen wurden, dann
*     Routine verlassen.
      IF h_dummy <> space.
        EXIT.
*     Falls noch Daten übernommen werden müssen.
      ELSEIF h_dummy = space.
        IF gt_imamt_buf-datum >= h_datum.
          pet_imamt       = gt_imamt_buf.
          pet_imamt-datum = pi_datab.
          APPEND pet_imamt.

*         Merke das kleinste Datum, welches noch übernommen
*         werden muß.
          h_datum = gt_imamt_buf-datum.
        ELSE. " gt_imamt_buf-datum < h_datum.
*         Routine verlassen.
          EXIT.
        ENDIF. " gt_imamt_buf-datum >= h_datum.
      ENDIF. " h_dummy <> space.
    ENDIF. " gt_imamt_buf-datum > pi_datab.

  ENDLOOP. " at gt_imamt_buf

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
*   Merken, daß keine MAMT-Satz gefunden wurde.
    pe_found_mamt = 'X'.

*   Routine verlassen.
    EXIT.
* Falls keine Fehler auftraten.
  ELSE. " sy-subrc = 0.
*   Sortiere Daten der Ausgabetabelle.
    SORT pet_imamt BY datum mtxid lfdnr.
  ENDIF. " sy-subrc <> 0


ENDFORM.                               " artstm_Matdata_get


*eject.
************************************************************************
FORM pmata_check
     TABLES pxt_ot3           STRUCTURE wpaot3
            pet_ot3_pmata     STRUCTURE gt_ot3_pmata
            pxt_wlk2          STRUCTURE gt_wlk2
     USING  pi_filia_group    STRUCTURE gt_filia_group
            pi_datp4          LIKE      syst-datum.
************************************************************************
* FUNKTION:
* Kopiert alle Sammelartikeleinträge aus OT3 in Tabelle GT_OT3_PMATA.
* Besorge die zugehörigen Varianten und füge sie in OT3 ein. Außerdem
* werden falls nötig die Felder ATTYP und PMATA in bereits bestehenden
* Einträgen aus OT3 verändert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_OT3        : Objekttabelle Nr. 3.

* PXT_WLK2       : Gesammelte Bewirtschaftungszeiträume der
*                  Filiale.
* PI_FILIA_GROUP : Daten einer Filiale der Filialgruppe.

* PET_OT3_PMATA  : Alle Sammelartikel und Varianten aus PXT_OT3.

* PI_DATP4       : Datum: jetziges Versenden + Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_init,
        h_datum LIKE sy-datum,
        h_attyp LIKE mara-attyp,
        h_pmata LIKE mara-pmata.

* Zum Komprimieren von Tabelle PXT_OT3 (Stufe 1).
  DATA: BEGIN OF i_key1,
          artnr LIKE gt_ot3_artstm-artnr,
          vrkme LIKE gt_ot3_artstm-vrkme.
  DATA: END OF i_key1.

* Zum Komprimieren von Tabelle PXT_OT3 (Stufe 1).
  DATA: BEGIN OF i_key2.
          INCLUDE STRUCTURE i_key1.
        DATA: END OF i_key2.

* Nur zum Komprimieren der Daten aus PXT_OT3.
  DATA: BEGIN OF t_pmata OCCURS 0.
          INCLUDE STRUCTURE gt_pmata_buf.
        DATA: END OF t_pmata.

* Temporärtabelle für WLK2-Einträge.
  DATA: BEGIN OF t_wlk2 OCCURS 0.
          INCLUDE STRUCTURE gt_wlk2.
        DATA: END OF t_wlk2.

* Zwischenpuffer für Materialnummern aus WLK2.
  DATA: BEGIN OF t_matnr OCCURS 0.
          INCLUDE STRUCTURE wpmatnr.
        DATA: END OF t_matnr.

* Kopiere alle Sammelartikel und Varianten (diese können ein
* Preismaterial für andere Varianten sein) in eine Sekundärtabelle.
  REFRESH: pet_ot3_pmata.
  LOOP AT pxt_ot3
       WHERE attyp <> space.
    APPEND pxt_ot3 TO pet_ot3_pmata.
  ENDLOOP.                             " AT PXT_OT3.

* Preismaterialkomprimierung Stufe 1: Berücksichtige Initialisierungen.
* Sortieren der Daten.
  SORT pet_ot3_pmata BY artnr vrkme init DESCENDING datum.

* Lösche überflüssige Einträge aus Tabelle GT_OT3_PMATA.
  CLEAR: i_key1, i_key2, h_init, h_datum.
  LOOP AT pet_ot3_pmata.
    MOVE-CORRESPONDING pet_ot3_pmata TO i_key2.
    IF i_key1 <> i_key2.
      i_key1 = i_key2.
      CLEAR: h_init.
      IF pet_ot3_pmata-init <> space.
        h_init = 'X'.
        h_datum = pet_ot3_pmata-datum.
      ENDIF.                           " pet_ot3_pmata-INIT <> SPACE.
*   Falls bereits eine Initialisierung ab einem Datum stattfinden soll,
*   dann werden alle Sätze deren Aktivierungsdatum älter als das
*   Initialisierungdatum ist gelöscht, da sie durch die Initialisierung
*   bereits berücksichtigt werden.
    ELSEIF i_key1 = i_key2 AND h_init <> space AND
           pet_ot3_pmata-datum >= h_datum.
      DELETE pet_ot3_pmata.
    ENDIF.                             " I_KEY1 <> I_KEY2.
  ENDLOOP.                             " AT pet_ot3_pmata.

* Lösche alle doppelten Einträge.
  DELETE ADJACENT DUPLICATES FROM pet_ot3_pmata
         COMPARING ALL FIELDS.

* Besorge alle Varianten zu den Sammelartikeln.
  CLEAR: i_key1, i_key2.
  REFRESH: t_pmata.
  LOOP AT pet_ot3_pmata.
    MOVE-CORRESPONDING pet_ot3_pmata TO i_key2.
    CLEAR: i_key2-vrkme.
    IF i_key1 <> i_key2.
      i_key1 = i_key2.

*     Besorge die Varianten für die dieser Artikel ein
*     Preismaterial ist.
      PERFORM varianten_get
              TABLES t_pmata
              USING  pet_ot3_pmata-artnr
                     pet_ot3_pmata-attyp
                     pi_filia_group.

    ENDIF.                             " I_KEY1 <> I_KEY2.
  ENDLOOP.                             " AT PET_OT3_PMATA.

* Sortieren der Daten.
  SORT pxt_ot3 BY artnr vrkme attyp DESCENDING.

* Übertrage den Artikeltyp (ATTYP) auf alle übrigen
* OT3-Einträge desselben Artikels.
  CLEAR: i_key1, i_key2.
  LOOP AT pxt_ot3.
    MOVE-CORRESPONDING pxt_ot3 TO i_key2.
    IF i_key1 <> i_key2.
      i_key1 = i_key2.
      CLEAR: h_attyp.
      IF pxt_ot3-attyp <> space.
        h_attyp = pxt_ot3-attyp.
      ENDIF.                         " pxt_ot3-attyp <> space.

    ELSEIF i_key1 = i_key2 AND h_attyp <> space AND
           pxt_ot3-attyp = space.
      pxt_ot3-attyp = h_attyp.
      MODIFY pxt_ot3.
    ENDIF.                             " I_KEY1 <> I_KEY2.
  ENDLOOP.                             " AT PXT_OT3.

* Übernehme die Varianten der Preismaterialien nach PXT_OT3.
  REFRESH: t_matnr.
  LOOP AT pet_ot3_pmata.
    CLEAR: pxt_ot3.
    pxt_ot3-vrkme      = pet_ot3_pmata-vrkme.
    pxt_ot3-datum      = pet_ot3_pmata-datum.
    pxt_ot3-init       = pet_ot3_pmata-init.
    pxt_ot3-pmata      = pet_ot3_pmata-artnr.
    pxt_ot3-aetyp_sort = pet_ot3_pmata-aetyp_sort.

    LOOP AT t_pmata
         WHERE pmata = pet_ot3_pmata-artnr.
      pxt_ot3-artnr = t_pmata-matnr.
      APPEND pxt_ot3.

*     Zwischenspeichern der Artikelnummer der Varianten.
      APPEND t_pmata-matnr TO t_matnr.
    ENDLOOP.                             " AT t_pmata
  ENDLOOP. " at pet_ot3_pmata.

* Sortieren der Daten.
  SORT pxt_ot3 BY artnr vrkme pmata DESCENDING.

* Übertrage das Preismaterial auf alle PMATA-Felder aller
* OT3-Einträge desselben Artikels.
  CLEAR: i_key1, i_key2.
  LOOP AT pxt_ot3.
    MOVE-CORRESPONDING pxt_ot3 TO i_key2.
    IF i_key1 <> i_key2.
      i_key1 = i_key2.
      CLEAR: h_pmata.
      IF pxt_ot3-pmata <> space.
        h_pmata = pxt_ot3-pmata.
      ENDIF.                           " pet_ot3-pmata <> space.

    ELSEIF i_key1 = i_key2 AND h_pmata <> space AND
           pxt_ot3-pmata = space.
      pxt_ot3-pmata = h_pmata.
      MODIFY pxt_ot3.
    ENDIF.                             " I_KEY1 <> I_KEY2.
  ENDLOOP.                             " AT PXT_OT3.

* Prüfe, ob WLK2-Daten aktualisiert werden müssen.
  READ TABLE t_matnr INDEX 1.

* Falls WLK2-Daten aktualisiert werden müssen.
  IF sy-subrc = 0.
* B: New listing check logic => Note 1982796
    IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
       AND gs_twpa-marc_chk IS NOT INITIAL.
      h_datum = pi_filia_group-datab - 1.
* New Lsiting logic: read WLK2 and check MARC if enries exists
      CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
        EXPORTING
          ip_access_type = '2'              " WLK2 access with Art/store
          ip_vkorg       = pi_filia_group-vkorg
          ip_vtweg       = pi_filia_group-vtweg
          ip_filia       = pi_filia_group-filia
          ip_date_from   = h_datum
          ip_date_to     = pi_datp4
          is_filia_const = gi_filia_const
        TABLES
          pit_matnr      = t_matnr
          pet_wlk2       = pxt_wlk2.
    ELSE.
*   Aktualisiere WLK2-Daten.
*   Setze untere Intervallgrenzen des Betrachtungszeitraums.
*   Anmerkung: Bei einer Auslistung wird das BIS-Datum des
*   Bewirtschaftungszeitraums auf Gestern gesetzt. Damit der Artikel
*   nicht herausgefiltert wird, wird die untere Intervallgrenze auf den
*   Vortag des letzten Versendens gesetzt (Zeitpunkt P1 - 1).
      h_datum = pi_filia_group-datab - 1.

*   Führe notwendige Prüfungen durch und besorge die zugehörigen
*   WLK2-Daten.
      CALL FUNCTION 'WLK2_MATERIAL_FOR_FILIA'
        EXPORTING
          pi_vkorg        = pi_filia_group-vkorg
          pi_vtweg        = pi_filia_group-vtweg
          pi_filia        = pi_filia_group-filia
          pi_datab        = h_datum
          pi_datbi        = pi_datp4
        TABLES
          wlk2_input      = t_wlk2
          pit_matnr       = t_matnr
        EXCEPTIONS
          werks_not_found = 01
          no_wlk2         = 02
          no_wlk2_listing = 03.


*    Übernehme zusätzliche Einträge in PXT_WLK2.
      APPEND LINES OF t_wlk2 TO  pxt_wlk2.
      SORT pxt_wlk2 DESCENDING BY matnr ASCENDING
                                  vkorg
                                  vtweg
                                  werks.

      DELETE ADJACENT DUPLICATES FROM pxt_wlk2
             COMPARING ALL FIELDS.
    ENDIF. " Note 1982796
  ENDIF. " sy-subrc = 0.


ENDFORM.                               " pmata_check


*eject.
************************************************************************
FORM varianten_get
     TABLES pxt_varianten     STRUCTURE gt_pmata_buf
     USING  pi_pmata          LIKE      mara-pmata
            pi_attyp          LIKE      mara-attyp
            pi_filia_group    STRUCTURE gt_filia_group.
************************************************************************
* FUNKTION:
* Besorgt die Varianten zu dem Preismaterial und fügt sie an die
* Tabelle PXT_VARIANTEN an.
* Mit interner Pufferung.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_VARIANTEN  : Tabelle an die die gefundenen Varianten angefügt
*                  werden.
* PI_PMATA       : Preismaterial zu dem die Varianten
*                  bestimmt werden sollen.
* PI_ATTYP       : Artikeltyp des Preismaterials.

* PI_FILIA_GROUP : Daten einer Filiale der Filialgruppe.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_tabix LIKE sy-tabix,
        h_satnr LIKE mara-satnr,
        h_pmata LIKE mara-pmata.

  DATA: BEGIN OF t_varianten OCCURS 10.
          INCLUDE STRUCTURE mara.
        DATA: END OF t_varianten.


* Prüfe, ob die Varianten bereits im internen Puffer sind.
  READ TABLE gt_pmata_buf WITH KEY
       pmata = pi_pmata
       BINARY SEARCH.

  h_tabix = sy-tabix.

* Falls die Varianten im Puffer sind, dann  kopiere sie aus Puffer
* in die Ausgabetabelle.
  IF sy-subrc = 0.
    LOOP AT gt_pmata_buf FROM h_tabix
         WHERE pmata = pi_pmata.
      APPEND gt_pmata_buf TO pxt_varianten.
    ENDLOOP. " at gt_pmata_buf

* Falls die Varianten noch nicht im Puffer sind, dann lese von DB
  ELSE. " sy-subrc = 0.
*   Falls das Preismaterial ein Sammelartikel ist.
    IF pi_attyp = c_sammelartikel.
      h_satnr = pi_pmata.
      h_pmata = pi_pmata.

*   Falls das Preismaterial eine Variante ist.
    ELSE. " pi_attyp = c_variante.
*     Besorge den zugehörigen Sammelartikel aus MARA.
      PERFORM mara_select
                   USING mara
                         pi_pmata.

*     Übernehme Sammelartikel in Hilfsvariable.
      h_satnr = mara-satnr.
      h_pmata = pi_pmata.
    ENDIF. " pi_attyp = c_sammelartikel.

*   Lese die Varianten
    CALL FUNCTION 'LESEN_VARIANTEN_ZU_SA'
      EXPORTING
        sammelartikel        = h_satnr
      TABLES
        varianten            = t_varianten
      EXCEPTIONS
        enqueue_mode_changed = 1
        lock_on_material     = 2
        lock_system_error    = 3
        wrong_call           = 4
        not_found            = 5
        no_maw1_for_mara     = 6
        lock_on_marc         = 7
        lock_on_mbew         = 8
        OTHERS               = 9.

*   Sollte eigentlich nicht vorkommen.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF. " sy-subrc <> 0.

*   Falls das Preismaterial eine Variante ist.
    IF pi_attyp = c_variante.
      LOOP AT t_varianten.
*       Besorge das jeweilige Preismaterial der Variante.
        PERFORM mvke_select
                     USING mvke
                           t_varianten-matnr
                           pi_filia_group-vkorg
                           pi_filia_group-vtweg.

*       Falls ein MVKE-Satz gefunden wurde.
        IF NOT mvke-matnr IS INITIAL.
*         Übernehme Preismaterial der Variante in interne Tabelle
          IF mvke-pmatn IS NOT INITIAL.
            t_varianten-pmata = mvke-pmatn.
            MODIFY t_varianten.
          ENDIF.
        ENDIF. " not mvke-matnr is initial.

      ENDLOOP. " at t_varianten.
    ENDIF. " pi_attyp = c_variante.

*   Sortieren der gefundenen Varianten.
    SORT t_varianten BY pmata matnr DESCENDING.

*   Übernehme alle Varianten, die auf den Preis des Preismaterials
*   verweisen.
    gt_pmata_buf-pmata  = pi_pmata.
    pxt_varianten-pmata = pi_pmata.
    LOOP AT t_varianten
         WHERE pmata = h_pmata.
*     Übernehme die Variante in den Puffer.
      gt_pmata_buf-matnr = t_varianten-matnr.
      INSERT gt_pmata_buf INDEX h_tabix.

*     Übernehme die Variante in Ausgabetabelle.
      pxt_varianten-matnr = t_varianten-matnr.
      APPEND pxt_varianten.

    ENDLOOP. " at t_varianten
  ENDIF. " sy-subrc = 0.


ENDFORM. " varianten_get


*eject.
************************************************************************
FORM artstm_change_mode_proceed
     TABLES pit_artdel      STRUCTURE gt_artdel
            pit_filter_segs STRUCTURE gt_filter_segs
            pit_ot3_artstm  STRUCTURE gt_ot3_artstm
            pit_workdays    STRUCTURE gt_workdays
     USING  pi_filia_group  STRUCTURE gt_filia_group
            pi_mara         STRUCTURE mara
            pi_datp4        LIKE syst-datum
            pi_mode         LIKE wpstruc-modus
            pi_dldnr        LIKE wdls-dldnr
            pi_number       LIKE gt_ot3_artstm-number
            pi_e1wpa02      LIKE wpstruc-modus
            pi_e1wpa03      LIKE wpstruc-modus
            pi_e1wpa04      LIKE wpstruc-modus
            pi_e1wpa05      LIKE wpstruc-modus
            pi_e1wpa07      LIKE wpstruc-modus
            pi_e1wpa08      LIKE wpstruc-modus
            pi_e1wpa09      LIKE wpstruc-modus
            pi_e1wpa10      LIKE wpstruc-modus
            pi_e1wpa11      LIKE wpstruc-modus
            pi_tabix        LIKE sy-tabix.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads des Artikelstamms.                              *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_FILTER_SEGS       : Liste aller für den POS-Download nicht
*                         benötigten Segmente.
* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_MARA               : MARA-Daten des Artikels.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_DLDNR              : Downloadnummer für Statusverfolgung.

* PI_NUMBER             : Nummer der Tabellenzeile, ab der gelesen
*                         werden soll.
* PI_E1WPA02            : = 'X', wenn Segment E1WPA02 übertragen
*                                werden soll.
* PI_E1WPA03            : = 'X', wenn Segment E1WPA03 übertragen
*                                werden soll.
* PI_E1WPA04            : = 'X', wenn Segment E1WPA04 übertragen
*                                werden soll.
* PI_E1WPA05            : = 'X', wenn Segment E1WPA05 übertragen
*                                werden soll.
* PI_E1WPA07            : = 'X', wenn Segment E1WPA07 übertragen
*                                werden soll.
* PI_E1WPA08            : = 'X', wenn Segment E1WPA08 übertragen
*                                werden soll.
* PI_E1WPA09            : = 'X', wenn Segment E1WPA09 übertragen
*                                werden soll.
* PI_E1WPA10            : = 'X', wenn Segment E1WPA11 übertragen
*                                werden soll.
* PI_E1WPA11            : = 'X', wenn Segment E1WPA10 übertragen
*                                werden soll.
* PI_TABIX              : Tabellenzeile, ab der gelesen werden soll.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_aenderungstyp LIKE e1wpa01-aendtyp,
        h_fist_record.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Feldleiste für Filialkonstanten.
  DATA: BEGIN OF i_filia_const.
          INCLUDE STRUCTURE wpfilconst.
        DATA: END OF i_filia_const.

  DATA: BEGIN OF t_art_equal OCCURS 1.
          INCLUDE STRUCTURE wpart.
        DATA: END OF t_art_equal.

  DATA: BEGIN OF t_ot3_artstm_temp OCCURS 10.
          INCLUDE STRUCTURE gt_ot3_artstm.
        DATA: END OF t_ot3_artstm_temp.

  DATA: BEGIN OF t_wrf6 OCCURS 2.
          INCLUDE STRUCTURE wrf6.
        DATA: END OF t_wrf6.

* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING pi_filia_group TO i_filia_const.


* Extrahiere die Daten zu einem Artikel in temporäre Tabelle
* und bestimme Grenzwerte für spätere Selektion der Daten.
  REFRESH: t_ot3_artstm_temp.
  CLEAR: g_datmin, g_datmax.
  h_fist_record = 'X'.

  LOOP AT pit_ot3_artstm FROM pi_tabix.

*   Exit-Bedingung.
    IF pit_ot3_artstm-number <> pi_number.
      EXIT.
    ENDIF. " pit_ot3_artstmpi-number <> pi_number.

    IF h_fist_record <> space.
      CLEAR: h_fist_record.

*     Bestimme den Änderungstyp.
      CLEAR: h_aenderungstyp.
      CASE pit_ot3_artstm-aetyp_sort.
*       Falls sowohl eine Material als auch eine Konditionsänderung
*       vorliegt.
        WHEN '1'.
          h_aenderungstyp = c_all.
*       Falls eine Konditionsänderung vorliegt.
        WHEN '2'.
          h_aenderungstyp = c_cond.
*       Falls eine Materialänderung vorliegt.
        WHEN '3'.
          h_aenderungstyp = c_matr.
      ENDCASE. " pit_ot3_artstm-aetyp_sort.

*     Merke Firstkey, falls nötig.
      IF g_new_firstkey <> space.
        i_key-matnr = pit_ot3_artstm-artnr.
        i_key-vrkme = pit_ot3_artstm-vrkme.
        g_firstkey = i_key.
        CLEAR: g_new_firstkey.
      ENDIF.                       " G_NEW_FIRSTKEY <> SPACE.

      g_datmin   = pit_ot3_artstm-datum.
      g_datmax   = pit_ot3_artstm-datum.

*     Falls Initialisiert werden soll, müssen die Daten bis zum
*     Ende der Vorlaufzeit selektiert werden.
      IF pit_ot3_artstm-init <> space.
        g_datmax = pi_datp4.
      ENDIF.                       " PIT_OT3_ARTSTM-INIT <> SPACE.
    ELSE.                          " h_fist_record = space.
      IF pit_ot3_artstm-datum < g_datmin.
        g_datmin = pit_ot3_artstm-datum.
      ELSEIF pit_ot3_artstm-datum > g_datmax.
        g_datmax = pit_ot3_artstm-datum.
      ENDIF. " PIT_OT3_ARTSTM-DATUM < G_DATMIN.
    ENDIF.                         " H_FIST_RECORD <> SPACE.

*   Falls nötig, erzeuge Löschsatz.
    IF pit_ot3_artstm-upd_flag = c_del.
*     Besorge alte EAN aus Zusatztabelle PIT_ARTDEL.
      READ TABLE pit_artdel WITH KEY
           artnr = pit_ot3_artstm-artnr
           vrkme = pit_ot3_artstm-vrkme
           datum = pit_ot3_artstm-datum
           BINARY SEARCH.

*     Falls eine EAN existiert.
      IF sy-subrc = 0.
*       Erzeuge Datensatz zum löschen der alten EAN.
        PERFORM artstm_delete USING   pit_ot3_artstm-artnr
                                      pit_ot3_artstm-vrkme
                                      pit_artdel-ean
                                      pit_ot3_artstm-datum
                                      pi_filia_group-ermod
                                      pi_filia_group-kunnr
                                      gt_idoc_data
                                      g_returncode
                                      pi_dldnr    g_dldlfdnr
                                      g_segment_counter.
      ENDIF. " sy-subrc = 0.

    ELSE. " PIT_OT3_ARTSTM-UPD_FLAG <> C_DEL.
*     Übernehme Datensatz in Temporärtabelle.
      APPEND pit_ot3_artstm TO t_ot3_artstm_temp.
    ENDIF. " PIT_OT3_ARTSTM-UPD_FLAG = C_DEL.
  ENDLOOP.                         " AT PIT_OT3_ARTSTM.

* Prüfe, ob Einträge in PIT_OT3_SETS_TEMP vorhanden sind.
  READ TABLE t_ot3_artstm_temp INDEX 1.

* Falls keine Einträge in PIT_OT3_ARTSTM_TEMP vorhanden sind,
* dann starte mit der nächsten Gruppe.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.                           " SY-SUBRC <> 0.

* Prüfe, ob die Warengruppe dieser Filiale zugeordnet ist.
  CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
    EXPORTING
      pi_filiale     = pi_filia_group-kunnr
      pi_warengruppe = pi_mara-matkl
    TABLES
      pe_t_wrf6      = t_wrf6
    EXCEPTIONS
      no_wrf6_record = 01
      no_wrgp_found  = 02.

  READ TABLE t_wrf6 INDEX 1.

* Falls die Warengruppe dieser Filiale zugeordnet ist.
  IF sy-subrc = 0.
*   Falls die Warengruppe von der Versendung ausgeschlossen werden
*   soll, dann weiter zur nächsten Artikelnummer.
    IF t_wrf6-wdaus <> space.
*     Aktualisiere Zählvariable für ignorierte Objekte für
*     spätere Statistikausgabe.
      ADD 1 TO gi_stat_counter-artstm_ign.

*     Weiter zum nächsten Satz.
      EXIT.
    ENDIF. " t_wrf6-wdaus <> space.

* Falls die Warengruppe nicht dieser Filiale zugeordnet ist.
  ELSE. " sy-subrc <> 0
*   Falls das Artikelstammsegment E1WPA02 aufbereitet werden soll
*   (in diesem werden WRF6-Daten übertragen), dann prüfe, ob
*   Artikel heruntergeladen werden kann
    IF NOT pi_e1wpa02 IS INITIAL.
*     Falls kein Verkauf über alle Warengruppen, dann sollen
*     die WRF6-Daten übertragen werden. Da sie nicht vorhanden
*     sind kann der Artikel nicht aufbereitet werden.
      IF pi_filia_group-sallmg IS INITIAL.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-artstm_ign.

*       Weiter zum nächsten Satz.
        EXIT.
      ENDIF. " pi_filia_group-sallmg is initial
    ENDIF. " not pi_e1wpa02 is initial.
  ENDIF. " sy-subrc = 0

* Besorge die Listungen dieser VRKME des Artikels
* bzgl. dieser Filiale
  PERFORM pos_listing_check
              TABLES gt_wlk2
                     gt_listung
              USING  pi_filia_group
                     t_ot3_artstm_temp-artnr
                     t_ot3_artstm_temp-vrkme
                     g_datmin
                     pi_datp4.

* Besorge die Listungen dieser VRKME des Artikels
* bzgl. dieser Filiale
* call function 'LISTING_CHECK'
*      exporting
*           pi_article      = t_ot3_artstm_temp-artnr
*           pi_vrkme        = t_ot3_artstm_temp-vrkme
*           pi_datab        = g_datmin
*           pi_datbi        = pi_datp4
*           pi_filia        = pi_filia_group-filia
*           pi_vkorg        = pi_filia_group-vkorg
*           pi_vtweg        = pi_filia_group-vtweg
*      tables
*           pet_bew_kond   = gt_listung
*      exceptions
*           kond_not_found  = 01
*           vrkme_not_found = 02
*           vkdat_not_found = 03.

  READ TABLE gt_listung INDEX 1.

  IF sy-subrc = 0.
*   Besorge Artikeldaten und bereite IDOC auf.
    CALL FUNCTION 'MASTERIDOC_CREATE_DLPART'
      EXPORTING
        pi_debug           = ' '
        pi_dldnr           = pi_dldnr
        px_dldlfdnr        = g_dldlfdnr
        pi_vkorg           = pi_filia_group-vkorg
        pi_vtweg           = pi_filia_group-vtweg
        pi_filia           = pi_filia_group-filia
        pi_artnr           = t_ot3_artstm_temp-artnr
        pi_vrkme           = t_ot3_artstm_temp-vrkme
        pi_aendtyp         = h_aenderungstyp
        pi_datbi_list      = pi_datp4
        pi_datum_ab        = g_datmin
        pi_datum_bis       = g_datmax
        pi_express         = ' '
        pi_loeschen        = ' '
        pi_mode            = pi_mode
        pi_e1wpa02         = pi_e1wpa02
        pi_e1wpa03         = pi_e1wpa03
        pi_e1wpa04         = pi_e1wpa04
        pi_e1wpa05         = pi_e1wpa05
*       pi_e1wpa06         = pi_e1wpa06
        pi_e1wpa07         = pi_e1wpa07
        pi_e1wpa08         = pi_e1wpa08
        pi_e1wpa09         = pi_e1wpa09
        pi_e1wpa10         = pi_e1wpa10
        pi_e1wpa11         = pi_e1wpa11
*       pi_vzeit           = pi_filia_group-vzeit
*       pi_spras           = pi_filia_group-spras
        px_segment_counter = g_segment_counter
        pi_filia_const     = i_filia_const
      IMPORTING
        px_segment_counter = g_segment_counter
      TABLES
        pit_listung        = gt_listung
        pit_ot3_artstm     = t_ot3_artstm_temp
        pit_workdays       = pit_workdays
      CHANGING
        pxt_idoc_data      = gt_idoc_data
      EXCEPTIONS
        download_exit      = 1.

*   Es sind Fehler beim Download aufgetreten'
    IF sy-subrc <> 0.
*     Abbruch des Downloads.
      RAISE error_code_1.
    ENDIF.                         " SY-SUBRC <> 0.

* Falls der Artikel nicht in dieser Filiale bewirtschaftet wird.
  ELSE.                            " SY-SUBRC <> 0.
*   Aktualisiere Zählvariable für ignorierte Objekte für
*   spätere Statistikausgabe.
    ADD 1 TO gi_stat_counter-artstm_ign.
  ENDIF.                           " SY-SUBRC = 0.

ENDFORM. " artstm_change_mode_proceed


*eject.
************************************************************************
FORM conditions_precheck
     TABLES pet_matnr       STRUCTURE wpmatnr
            pet_condint     STRUCTURE gt_condint
            pit_kondart     STRUCTURE wpkschl
     USING  pi_komg_must    STRUCTURE gi_komg
            pi_komg         STRUCTURE gi_komg
            pi_counter      LIKE sy-index
            pi_datab        LIKE sy-datum
            pi_datbi        LIKE sy-datum
            pi_kond_analyse LIKE wpstruc-modus.
************************************************************************
* FUNKTION:                                                            *
* Bestimme alle Artikel, bei denen potentiell eine Konditionsänderung
* vorkommen kann.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_MATNR             : Tabelle der gefundenen Artikel
*
* PET_CONDINT           : Tabelle der gefundenen Konditionsintervalle
*
* PIT_KONDART           : Tabelle der relevanten Konditionsarten

* PI_KOMG_MUST          : Feldleiste für Mußfelder bei der Analyse
*                         der Konditionstabellen.
* PI_KOMG               : Schlüsselfeldinhalte für die Analyse
*                         der Konditionstabellen.
* PI_COUNTER            : = 2, wenn auch Naturalrabattkonditionen
*                              überprüft werden sollen, sonst 1.
* PI_DATAB              : Beginn des Betrachtungszeitraums
*
* PI_DATBI              : Ende des Betrachtungszeitraums
*
* PI_KOND_ANALYSE       : = 'X', wenn normale Konditionen überprüft
*                                werden sollen.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_verwendung  LIKE t682i-kvewe,
        h_applikation LIKE t682i-kappl.

* Tabelle zum Zwischenspeichern von Konditionsintervallen.
  DATA: BEGIN OF t_periods OCCURS 0.
          INCLUDE STRUCTURE wcondint.
        DATA: END OF t_periods.


* Rücksetze interne Tabellenpuffer.
  REFRESH: pet_matnr, pet_condint.
  CLEAR:   pet_matnr, pet_condint.

  DO pi_counter TIMES.
*   Setze Hilfsvariablen für normale Konditionsanalyse, falls nötig.
    IF sy-index = 1.
*     Falls keine normale Konditionsanalyse stattfinden soll.
      IF pi_kond_analyse IS INITIAL.
*       Weiter zum nächste Analyseschritt.
        CONTINUE.
      ENDIF. " pi_kond_analyse is initial.

      h_verwendung  = c_cond_vewe.
      h_applikation = c_cond_appl.

*   Falls Analyse von Naturalrabattkonditionen erfolgen soll.
    ELSEIF sy-index = 2.
      h_verwendung   = c_natrab_vewe.
      h_applikation  = c_natrab_appl.
    ENDIF. " sy-index = 1.

*   Besorge die Intervalle aller Konditionstabellen, die als
*   Mußfelder MATNR haben, deren Schlüsselfelder mit den
*   gefüllten Feldinhalten von GI_KOMG (sofern vorhanden)
*   übereinstimmen und deren Gültigkeitsbeginn oder -ende sich
*   innerhalb des Intervalls PI_DATAB bis PI_DATBI befindet.
    REFRESH: t_periods.
    CALL FUNCTION 'WWS_CONDITION_INTERVALS_GET'
      EXPORTING
        komg_i           = pi_komg
        komg_must_i      = pi_komg_must
        datvo_i          = pi_datab
        datbi_i          = pi_datbi
        pi_generic       = 'X'
        pi_komg_must     = 'X'
        pi_keyfield_must = 'X'
        pi_only_chg      = 'X'
        kvewe_i          = h_verwendung
        kappl_i          = h_applikation
        pi_mode          = c_pos_mode
      TABLES
        pi_t_kschl       = pit_kondart
        pe_t_condint     = t_periods.

*   Daten in Ausgabetabellen übernehmen.
    LOOP AT t_periods.
      APPEND t_periods-matnr TO pet_matnr.

      pet_condint = t_periods.
      pet_condint-kvewe = h_verwendung.
      pet_condint-kappl = h_applikation.
      APPEND pet_condint.
    ENDLOOP. " at t_periods.
  ENDDO. " h_counter times.

* Daten sortieren.
  SORT pet_matnr BY matnr.

* Daten komprimieren.
  DELETE ADJACENT DUPLICATES FROM pet_matnr COMPARING matnr.


ENDFORM. " conditions_precheck


*eject.
************************************************************************
FORM wlk2_matnr_get
     TABLES pet_matnr       STRUCTURE wpmatnr
     USING  pi_vkorg        LIKE t001w-vkorg
            pi_vtweg        LIKE t001w-vtweg
            pi_filia        LIKE t001w-werks
            pi_datab        LIKE sy-datum
            pi_datbi        LIKE sy-datum.
************************************************************************
* FUNKTION:                                                            *
* Bestimme alle Artikel deren Bewirtschaftungszeitraum in den
* Betrachtungszeitraum hineinrutschen oder ihn verlassen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_MATNR             : Tabelle der gefundenen Artikel

* PI_VKORG              : Verkaufsorganisation dieser Filiale

* PI_VTWEG              : Vertriebsweg dieser Filiale

* PI_FILIA              : Aktuell berarbeitete Filiale

* PI_DATAB              : Beginn des Betrachtungszeitraums

* PI_DATBI              : Ende des Betrachtungszeitraums
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF t_wlk2 OCCURS 0.
          INCLUDE STRUCTURE wlk2.
        DATA: END OF t_wlk2.

* Besorge die Filialabhängigen Bewirtschaftungsdaten.
  SELECT * FROM wlk2 INTO TABLE t_wlk2
         WHERE vkorg = pi_vkorg
         AND   vtweg = pi_vtweg
         AND   werks = pi_filia
         AND ( ( vkdab >= pi_datab  AND
                 vkdab <= pi_datbi  )
         OR    ( vkbis >= pi_datab  AND
                 vkbis <= pi_datbi ) ).

* Besorge Vertriebslinienabhängige Bewirtschaftungsdaten.

* Falls Daten aus internen Puffer übernommen werden können.
  IF NOT g_wlk2_vl_fill IS INITIAL AND
     g_wlk2_vkorg_buf = pi_vkorg AND g_wlk2_vtweg_buf = pi_vtweg  AND
     g_wlk2_datab_buf = pi_datab AND g_wlk2_datbi_buf = pi_datbi.
*   Übernahme der Daten aus internem Puffer.
    APPEND LINES OF gt_wlk2_vl_buf TO t_wlk2.

* Falls keine Daten aus internen Puffer übernommen werden können.
  ELSE.
*   Fülle internen WLK2-Puffer auf Vertriebslinienebene.
    SELECT * FROM wlk2 INTO TABLE gt_wlk2_vl_buf
           WHERE vkorg = pi_vkorg
           AND   vtweg = pi_vtweg
           AND   werks = space
           AND ( ( vkdab >= pi_datab  AND
                   vkdab <= pi_datbi  )
           OR    ( vkbis >= pi_datab  AND
                   vkbis <= pi_datbi ) ).

*   Übernahme der Daten aus internen Puffer.
    APPEND LINES OF gt_wlk2_vl_buf TO t_wlk2.

*   Setzen der globalen Merker zum lesen aus Puffer.
    g_wlk2_vkorg_buf = pi_vkorg.
    g_wlk2_vtweg_buf = pi_vtweg.
    g_wlk2_datab_buf = pi_datab.
    g_wlk2_datbi_buf = pi_datbi.
    g_wlk2_vl_fill   = 'X'.
  ENDIF. " not g_wlk2_vl_fill is initial and

* Daten sortieren.
  SORT t_wlk2 BY matnr.

* Daten komprimieren.
  DELETE ADJACENT DUPLICATES FROM t_wlk2 COMPARING matnr.

* Daten in Ausgabetabelle übernehmen.
  LOOP AT t_wlk2.
    APPEND t_wlk2-matnr TO pet_matnr.
  ENDLOOP. " at t_wlk2.

ENDFORM. " wlk2_matnr_get


*eject
************************************************************************
FORM mtxid_check
     USING  pe_returncode   LIKE sy-subrc
            pi_mtxid        LIKE mamt-mtxid.
************************************************************************
* Prüft, ob die Kurztext-ID (aus Tabelle MAMT) POS-relevant ist.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PE_RETURNCODE: = 0, wenn POS-relevant, sonst = 1.

* PI_MTXID     : Zu überprüfende Material-Kurztext-ID.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF t_dd07v OCCURS 1.
          INCLUDE STRUCTURE dd07v.
        DATA: END OF t_dd07v.


* Falls der Puffer noch nicht gefüllt ist, dann fülle ihn.
  IF gt_mtxid_buf IS INITIAL.
*   Einlesen der Domänenfestwerte.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = c_mtxid
      TABLES
        dd07v_tab      = t_dd07v
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.

*   Übernehme Domänenfestwerte in den internen Puffer.
    REFRESH: gt_mtxid_buf.
    LOOP AT t_dd07v
         WHERE domvalue_l <> c_bontext.
      gt_mtxid_buf-mtxid = t_dd07v-domvalue_l.
      APPEND gt_mtxid_buf.
    ENDLOOP. " at t_dd07v

*   Daten sortieren
    SORT gt_mtxid_buf BY mtxid.
  ENDIF. " gt_mtxid_buf is initial.

* Falls die Kopfzeile des Puffers bereits die nötigen Daten enthält.
  IF gt_mtxid_buf-mtxid = pi_mtxid.
    pe_returncode = 1.

* Falls die Kopfzeile des Puffers nicht die nötigen Daten enthält,
* dann Suche im Puffer nach den Daten.
  ELSE.
    READ TABLE gt_mtxid_buf WITH KEY
               mtxid = pi_mtxid
               BINARY SEARCH.

*   Falls die Daten im Puffer gefunden wurden.
    IF sy-subrc = 0.
      pe_returncode = 1.

*   Falls keine Werte gefunden wurden, dann ist die Kurztext-ID
*   POS-relevant.
    ELSE. " sy-subrc <> 0.
      CLEAR: pe_returncode.
    ENDIF. " sy-subrc = 0.
  ENDIF. " gt_mtxid_buf-mtxid = pi_mtxid.


ENDFORM.                               " mtxid_check


*eject
************************************************************************
FORM artstm_change_mode_prepare
     TABLES pit_ot3_artstm         STRUCTURE gt_ot3_artstm
            pit_filter_segs        STRUCTURE gt_filter_segs
            pit_workdays           STRUCTURE gt_workdays
            pit_artdel             STRUCTURE gt_artdel
            pit_mara_buf           STRUCTURE gt_mara_buf
            pit_marm_buf           STRUCTURE gt_marm_buf
            pit_mvke_buf           STRUCTURE gt_mvke_buf
            pit_a071_matnr         STRUCTURE gt_a071_matnr
            pit_old_ean            STRUCTURE gt_old_ean
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
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_parallel            LIKE wpstruc-parallel
            pi_server_group        LIKE wpstruc-servergrp
            px_taskname            LIKE wpstruc-counter6
            px_snd_jobs            LIKE wpstruc-counter6.
************************************************************************
* FUNKTION:
* IDOC-Aufbereitung der Artikelstammdaten.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Aufbereitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PIT_FILTER_SEGS       : Reduzierinformationen.

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PIT_ARTDEL            : Tabelle der zu löschenden Artikel

* PIT_MARA_BUF          : MARA-Puffer.

* PIT_MARM_BUF          : MARM-Puffer.

* PIT_MVKE_BUF          : MVKE-Puffer.

* PIT_A071_MATNR        : Alle Artikel aus Tabelle A071

* PIT_OLD_EAN           : Puffer für Haupt-EAN's.

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
*                         Objekt Warengruppen.
* PI_DLDNR              : Downloadnummer

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

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
*   IDOC-Aufbereitung der Artikelstammdaten.
    CALL FUNCTION 'POS_ARTSTM_CHG_MODE_PREPARE'
      EXPORTING
        pi_filia_group         = pi_filia_group
        pi_idoctype            = pi_idoctype
        pi_mestype             = pi_mestype
        pi_dldnr               = pi_dldnr
        pi_erstdat             = pi_erstdat
        pi_datp3               = pi_datp3
        pi_datp4               = pi_datp4
        pi_mode                = pi_mode
        pi_parallel            = pi_parallel
        pi_independence_check  = px_independence_check
      IMPORTING
        pe_independence_check  = px_independence_check
        pe_stat_counter        = i_stat_counter
      TABLES
        pit_ot3_artstm         = pit_ot3_artstm
        pit_filter_segs        = pit_filter_segs
        pit_workdays           = pit_workdays
        pit_artdel             = pit_artdel
        pit_master_idocs       = pxt_master_idocs
        pit_independence_check = pit_independence_check
        pit_wlk2               = pit_wlk2.

*   Aktualisiere Statisktikinformation.
    px_stat_counter-artstm_ign = i_stat_counter-artstm_ign.

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

*   IDOC-Aufbereitung der Artikelstammdaten in parallelem Task.
    CALL FUNCTION 'POS_ARTSTM_CHG_MODE_PREPARE'
      STARTING NEW TASK px_taskname
      DESTINATION IN GROUP pi_server_group
      PERFORMING return_artstm_chg_mode_prepare ON END OF TASK
      EXPORTING
        pi_filia_group         = pi_filia_group
        pi_idoctype            = pi_idoctype
        pi_mestype             = pi_mestype
        pi_dldnr               = pi_dldnr
        pi_erstdat             = pi_erstdat
        pi_datp3               = pi_datp3
        pi_datp4               = pi_datp4
        pi_mode                = pi_mode
        pi_parallel            = pi_parallel
        pi_independence_check  = px_independence_check
      TABLES
        pit_ot3_artstm         = pit_ot3_artstm
        pit_filter_segs        = pit_filter_segs
        pit_workdays           = pit_workdays
        pit_master_idocs       = pxt_master_idocs
        pit_independence_check = pit_independence_check
        pit_artdel             = pit_artdel
        pit_mara_buf           = pit_mara_buf
        pit_marm_buf           = pit_marm_buf
        pit_mvke_buf           = pit_mvke_buf
        pit_a071_matnr         = pit_a071_matnr
        pit_old_ean            = pit_old_ean
        pit_wlk2               = pit_wlk2
        pit_kond_art_buf       = gt_kond_art_buf
        pit_staff_art_buf      = gt_staff_art_buf
        pit_artsteu_buf        = gt_artsteu_buf
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

*     IDOC-Aufbereitung der Artikelstammdaten sequentiell.
      CALL FUNCTION 'POS_ARTSTM_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = pi_idoctype
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_datp3               = pi_datp3
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_parallel            = ' '
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_artstm         = pit_ot3_artstm
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-artstm_ign = i_stat_counter-artstm_ign.

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


ENDFORM. " artstm_change_mode_prepare


*eject
************************************************************************
FORM pos_vrkme_relevance_check
     USING  pi_vkorg     LIKE mvke-vkorg
            pi_vtweg     LIKE mvke-vtweg
            pi_matnr     LIKE mvke-matnr
            pi_vrkme     LIKE marm-meinh
            pi_meins     LIKE mara-meins
            pe_errorcode LIKE sy-subrc.
************************************************************************
* Prüft, ob eine bestimmte Verkaufsmengeneinheit eines Artikels
* POS-relevant ist.
* ----------------------------------------------------------------------
* PARAMETER:
* PI_VKORG    : Zu untersuchende Verkaufsorganisation.

* PI_VTWEG    : Zu untersuchender Vertriebsweg.

* PI_MATNR    : Zu untersuchende Artikelnummer.

* PI_VRKME    : Zu untersuchende Verkaufsmengeneinheit.

* PI_MEINS    : Basismengeneinheit des Artikels.

* PE_ERRORCODE: > 0, wenn VRKME des Artikels nicht aufbereitet werden
*               soll, sonst 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

  CLEAR: pe_errorcode.


* Prüfe, ob es nur eine POS-relevante Verkaufsmengeneinheit gibt.
* Besorge MVKE-Daten.
* Besorge das jeweilige Preismaterial der Variante.
  PERFORM mvke_select
               USING mvke
                     pi_matnr
                     pi_vkorg
                     pi_vtweg.

* Falls es nur eine POS-relevante Verkaufsmengeneinheit gibt.
  IF NOT mvke-vavme IS INITIAL.
*   Falls die POS-relevante Verkaufsmengeneinheit in MVKE
*   gespeichert ist.
    IF NOT mvke-vrkme IS INITIAL.
*     Falls die POS-relevante VRKME nicht mit der aktuellen
*     identisch ist, dann braucht keine Aufbereitung stattfinden.
      IF mvke-vrkme <> pi_vrkme.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-artstm_ign.

        pe_errorcode = 4.
      ENDIF. " mvke-vrkme <> pi_vrkme.
*   Falls die POS-relevante Verkaufsmengeneinheit in MARA
*   gespeichert ist.
    ELSE. " mvke-vrkme is initial.
*     Falls die POS-relevante VRKME nicht mit der aktuellen
*     identisch ist, dann braucht keine Aufbereitung stattfinden.
      IF pi_meins <> pi_vrkme.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO gi_stat_counter-artstm_ign.

        pe_errorcode = 4.
      ENDIF. " mara-meins <> pi_vrkme.
    ENDIF. " not mvke-vrkme is initial.
  ENDIF. " not mvke-vavme is initial.

ENDFORM. " pos_vrkme_relevance_check


*eject
************************************************************************
FORM artstm_condpt_analyse_prepare
     TABLES pit_pointer            STRUCTURE bdcp
            pit_wind               STRUCTURE gt_wind
            pit_filia_group        STRUCTURE gt_filia_group
            pit_kondart            STRUCTURE gt_kondart
            pit_kondart_gesamt     STRUCTURE twpek
            pet_ot1_f_artstm       STRUCTURE gt_ot1_f_artstm
            pet_ot2_artstm         STRUCTURE gt_ot2_artstm
            pet_reorg_pointer      STRUCTURE bdicpident
            pet_rfcdest            STRUCTURE gt_rfcdest
     USING  pi_wind                LIKE wpstruc-cond_index
            pi_erstdat             LIKE syst-datum
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_pointer_reorg       LIKE wpstruc-modus
            pi_parallel            LIKE wpstruc-parallel
            pi_server_group        LIKE wpstruc-servergrp
            pi_taskname            LIKE wpstruc-counter6
            px_snd_jobs            LIKE wpstruc-counter6.
************************************************************************
* FUNKTION:
* Vorbereitung der Konditionsanalyse. Entscheidung, ob serieller oder
* paralleler Aufruf.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Aufbereitung in
* einem parallelen Task durchgeführt.
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
* PET_OT1_F_ARTSTM  : Artikelstamm: Objekttabelle 1, filialabhängig.

* PET_OT2_ARTSTM    : Artikelstamm: Objekttabelle 2, filialunabhängig.

* PET_REORG_POINTER : Tabelle der reorganisierbaren Pointer-ID's.

* PET_RFCDEST       : Tabelle der abgebrochenen parallelen Tasks

* PI_WIND           : = 'X', wenn Konditionsbelegindex benutzt
*                     werden soll.
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

* PX_SND_JOBS       : Anzahl der gestarteten parallelen Tasks.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: taskname LIKE wpstruc-counter6.

* Zuordnung: Filia <---> Vertriebsschiene.
  DATA: BEGIN OF t_filiagrp OCCURS 100.
          INCLUDE STRUCTURE wdl_fil.
        DATA: END OF t_filiagrp.

* Filialabhängige aufzubereitenden Daten.
  DATA: BEGIN OF t_ot1_f_artstm OCCURS 0.
          INCLUDE STRUCTURE gt_ot1_f_artstm.
        DATA: END OF t_ot1_f_artstm.

* Filialunabhängige aufzubereitenden Daten.
  DATA: BEGIN OF t_ot2_artstm OCCURS 0.
          INCLUDE STRUCTURE gt_ot2_artstm.
        DATA: END OF t_ot2_artstm.


* Fülle GT_FILIAGRP.
  REFRESH: t_filiagrp.
  CLEAR:   t_filiagrp.
  LOOP AT pit_filia_group.
    t_filiagrp-werks = pit_filia_group-filia.
    t_filiagrp-locnr = pit_filia_group-kunnr.
    t_filiagrp-vkorg = pit_filia_group-vkorg.
    t_filiagrp-vtweg = pit_filia_group-vtweg.
    t_filiagrp-pltyp = pit_filia_group-pltyp.
    APPEND t_filiagrp.
  ENDLOOP.                             " AT PIT_FILIA_GROUP.

* Falls nicht parallelisiert werden soll.
  IF pi_parallel IS INITIAL.
*   Analyse der Konditionsänderungspointer.
    CALL FUNCTION 'POS_ARTSTM_CONDPT_ANALYSE_PREP'
      EXPORTING
        pi_erstdat         = pi_erstdat
        pi_datp3           = pi_datp3
        pi_datp4           = pi_datp4
        pi_mode            = c_pos_mode
        pi_pointer_reorg   = pi_pointer_reorg
        pi_parallel        = pi_parallel
        pi_wind            = pi_wind
      TABLES
        pit_pointer        = pit_pointer
        pet_reorg_pointer  = pet_reorg_pointer
        pet_ot1_f_artstm   = t_ot1_f_artstm
        pet_ot2_artstm     = t_ot2_artstm
        pit_kondart        = pit_kondart
        pit_kondart_gesamt = pit_kondart_gesamt
        pit_filia          = t_filiagrp
        pit_wind           = pit_wind.

*   Übernehme das Ergebnis der Analyse in Ausgabetabelle.
    LOOP AT t_ot1_f_artstm.
      APPEND t_ot1_f_artstm TO pet_ot1_f_artstm.
    ENDLOOP. " at t_ot1_f_artstm

*   Übernehme das Ergebnis der Analyse in Ausgabetabelle.
    LOOP AT t_ot2_artstm.
      APPEND t_ot2_artstm TO pet_ot2_artstm.
    ENDLOOP. " at t_ot2_artstm

* Falls  parallelisiert werden soll.
  ELSE. " not pi_parallel is initial.
*   Setze neuen Tasknamen.
    taskname = pi_taskname + 1.

*   IDOC-Aufbereitung der Artikelstammdaten in parallelem Task.
    CALL FUNCTION 'POS_ARTSTM_CONDPT_ANALYSE_PREP'
      STARTING NEW TASK taskname
      DESTINATION IN GROUP pi_server_group
      PERFORMING return_condpt_analyse_prepare ON END OF TASK
      EXPORTING
        pi_erstdat            = pi_erstdat
        pi_datp3              = pi_datp3
        pi_datp4              = pi_datp4
        pi_mode               = c_pos_mode
        pi_pointer_reorg      = pi_pointer_reorg
        pi_parallel           = pi_parallel
        pi_wind               = pi_wind
      TABLES
        pit_pointer           = pit_pointer
        pit_kondart           = pit_kondart
        pit_kondart_gesamt    = pit_kondart_gesamt
        pit_filia             = t_filiagrp
        pit_wind              = pit_wind
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        resource_failure      = 3.

*   Falls eine Parallelverarbeitung gerade nicht möglich ist, dann
*   dann arbeite sequentiell.
    IF sy-subrc <> 0.
*     Falls Probleme mit dem Zielsystem auftraten.
      IF sy-subrc <> 3.
        CLEAR: pet_rfcdest.

*       Aktualisiere Fehlertabelle für Zielsysteme.
        pet_rfcdest-subrc = sy-subrc.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
          IMPORTING
            rfcdest = pet_rfcdest-rfcdest.

*       Aktualisiere System-Zeitstempel
        COMMIT WORK.

        pet_rfcdest-datum    = sy-datum.
        pet_rfcdest-uzeit    = sy-uzeit.
        pet_rfcdest-no_start = 'X'.
        APPEND pet_rfcdest.
      ENDIF. " sy-subrc <> 3.

*     Analyse der Konditionsänderungspointer sequentiell..
      CALL FUNCTION 'POS_ARTSTM_CONDPT_ANALYSE_PREP'
        EXPORTING
          pi_erstdat         = pi_erstdat
          pi_datp3           = pi_datp3
          pi_datp4           = pi_datp4
          pi_mode            = c_pos_mode
          pi_pointer_reorg   = pi_pointer_reorg
          pi_parallel        = ' '
          pi_wind            = pi_wind
        TABLES
          pit_pointer        = pit_pointer
          pet_reorg_pointer  = pet_reorg_pointer
          pet_ot1_f_artstm   = t_ot1_f_artstm
          pet_ot2_artstm     = t_ot2_artstm
          pit_kondart        = pit_kondart
          pit_kondart_gesamt = pit_kondart_gesamt
          pit_filia          = t_filiagrp
          pit_wind           = pit_wind.

*   Übernehme das Ergebnis der Analyse in Ausgabetabelle.
      LOOP AT t_ot1_f_artstm.
        APPEND t_ot1_f_artstm TO pet_ot1_f_artstm.
      ENDLOOP. " at t_ot1_f_artstm

*   Übernehme das Ergebnis der Analyse in Ausgabetabelle.
      LOOP AT t_ot2_artstm.
        APPEND t_ot2_artstm TO pet_ot2_artstm.
      ENDLOOP. " at t_ot2_artstm

*   Falls eine Parallelverarbeitung möglich ist.
    ELSE. " sy-subrc = 0.
*     Bestimme die verwendetet Destination.
      CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        IMPORTING
          rfcdest = gt_rfc_indicator_cnd-rfcdest.

*     Merken der gestarteten Destination.
      gt_rfc_indicator_cnd-taskname = taskname.
      APPEND gt_rfc_indicator_cnd.

*     Aktualisiere die Anzahl der parallelen Tasks
      ADD 1 TO px_snd_jobs.
    ENDIF. " sy-subrc <> 0.

  ENDIF. " pi_parallel is initial.


ENDFORM. " artstm_condpt_analyse_prepare


* eject.
************************************************************************
FORM matcond_get
     TABLES pet_kond               STRUCTURE gt_kond_art
            pet_staffeln           STRUCTURE gt_staff_art
            pet_artsteu            STRUCTURE gt_artsteu
     USING  pi_filia_const         STRUCTURE wpfilconst
            pi_filia               LIKE t001w-werks
            pi_artnr               LIKE wlk1-artnr
            pi_vrkme               LIKE wlk1-vrkme
            pi_datab               LIKE syst-datum
            pi_datbi               LIKE syst-datum
            pi_vkorg               LIKE wpstruc-vkorg
            pi_vtweg               LIKE wpstruc-vtweg
            pi_mode                LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Besorge die Konditionen und Steuerkennzeichen zu diesem
* Artikelstammsatz im Zeitintervall PI_DATAB - PI_DATBI.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KOND              : Tabelle für Konditionsdaten.

* PET_STAFFELN          : Tabelle für Konditionsstaffeldaten.

* PET_ARTSTEU           : Tabelle der Artikelsteuern.

* PI_FILIA_CONST        : Filialkonstanten.

* PI_FILIA              : Filiale.

* PI_ARTNR              : Material der Selektion.

* PI_VRKME              : Verkaufsmengeneinheit der Selektion.

* PI_DATAB              : Beginndatum der Selektion.

* PI_DATBI              : Endedatum der Selektion.

* PI_VKORG              : Verkaufsorganisation.

* PI_VTWEG              : Vertriebsweg.

* PI_MODE               : Download-Modus.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: read_first_record LIKE wpstruc-modus,
        h_tabix1          LIKE sy-tabix,
        h_tabix2          LIKE sy-tabix.

  STATICS: sh_counter LIKE sy-tabix.


  read_first_record = 'X'.
  REFRESH: pet_kond, pet_artsteu, pet_staffeln.
  CLEAR:   pet_kond, pet_artsteu, pet_staffeln.

* Falls Konditionsintervalle filialabhängig gepflegt sind,
* dann keine interne Pufferung der Ergebnisse.
  IF pi_filia_const-prices_siteindep IS INITIAL.
*   Einlesen der Konditionsdaten.
    CALL FUNCTION 'SALES_CONDITIONS_READ'
      EXPORTING
        pi_datab                     = pi_datab
        pi_datbi                     = pi_datbi
        pi_incfi                     = read_first_record
        pi_matnr                     = pi_artnr
        pi_vrkme                     = pi_vrkme
        pi_vkorg                     = pi_vkorg
        pi_vtweg                     = pi_vtweg
        pi_werks                     = pi_filia
        pi_scale_read                = 'X'
        pi_vorga                     = '02' " Grundpreis
        pi_direct_read               = pi_filia_const-pricing_direct
        pi_check_diff_kmein          = 'X'
      TABLES
        pe_t_saco                    = pet_kond
        pe_t_taxk                    = pet_artsteu
        pe_t_scale                   = pet_staffeln
      EXCEPTIONS
        no_bukrs_found               = 01
        plant_not_found              = 02
        material_not_found           = 03
        org_structure_not_completed  = 04
        vkorg_not_found              = 05
        no_pos_condition_types_found = 06
        no_condition_types_match     = 07
        OTHERS                       = 08.

*   Falls alle Konditionsintervalle filialunabhängig gepflegt sind,
*   dann schaue erst im internen Puffer nach.
  ELSE.  " not pi_filia_const-prices_siteindep is initial
*     Versuche zunächst die Daten aus Puffer zu entnehmenn.
    READ TABLE gt_kond_art_buf WITH KEY
         artnr     = pi_artnr
         vrkme     = pi_vrkme
         datab_sel = pi_datab
         datbi_sel = pi_datbi
         BINARY SEARCH
         TRANSPORTING NO FIELDS.

    h_tabix1 = sy-tabix.

*     Falls die gesuchten Daten bereits im Puffer sind.
    IF sy-subrc = 0.

*       Übernehme die im Puffer befindlichen Preise in Ausgabetabelle.
      LOOP AT gt_kond_art_buf FROM h_tabix1.

*         Setze Abbruchbedingung.
        IF gt_kond_art_buf-artnr     <> pi_artnr  OR
           gt_kond_art_buf-vrkme     <> pi_vrkme  OR
           gt_kond_art_buf-datab_sel <> pi_datab  OR
           gt_kond_art_buf-datbi_sel <> pi_datbi.
          EXIT.
        ENDIF.

*         Falls Preisinformationen vorhanden sind, dann übernehmen.
        IF gt_kond_art_buf-no_data IS INITIAL.
          MOVE-CORRESPONDING gt_kond_art_buf TO pet_kond.
          APPEND pet_kond.

*           Übernehme die im Puffer befindlichen Staffeln
*           in Ausgabetabelle.
          READ TABLE gt_staff_art_buf WITH KEY
               knumh = pet_kond-knumh
               kopos = pet_kond-kopos
               BINARY SEARCH
               TRANSPORTING NO FIELDS.

          h_tabix2 = sy-tabix.

*           Falls Staffeln vorhanden sind.
          IF sy-subrc = 0.
*             Übernehme die im Puffer befindlichen Staffeln in
*             Ausgabetabelle.
            LOOP AT gt_staff_art_buf FROM h_tabix2.
*               Setze Abbruchbedingung.
              IF gt_staff_art_buf-knumh <> pet_kond-knumh  OR
                 gt_staff_art_buf-kopos <> pet_kond-kopos.
                EXIT.
              ENDIF.

              MOVE-CORRESPONDING gt_staff_art_buf TO pet_staffeln.
              APPEND pet_staffeln.
            ENDLOOP. " at gt_staff_art_buf from h_tabix2.

          ENDIF. " sy-subrc = 0.
        ENDIF. " gt_kond_art_buf-no_data is initial.
      ENDLOOP. " at gt_kond_art_buf from h_tabix1.

*       Übernehme die Steuerkennzeichen aus Puffer.
      READ TABLE gt_artsteu_buf WITH KEY
           artnr     = pi_artnr
           vrkme     = pi_vrkme
           datab_sel = pi_datab
           datbi_sel = pi_datbi
           BINARY SEARCH
           TRANSPORTING NO FIELDS.

      h_tabix1 = sy-tabix.

*       Falls die gesuchten Daten im Puffer sind.
      IF sy-subrc = 0.

*         Übernehme die im Puffer befindlichen Steuerkennzeichen
*         in Ausgabetabelle.
        LOOP AT gt_artsteu_buf FROM h_tabix1.
*           Setze Abbruchbedingung.
          IF gt_artsteu_buf-artnr     <> pi_artnr  OR
             gt_artsteu_buf-vrkme     <> pi_vrkme  OR
             gt_artsteu_buf-datab_sel <> pi_datab  OR
             gt_artsteu_buf-datbi_sel <> pi_datbi.
            EXIT.
          ENDIF.

*           Falls Steuerkennzeichen vorhanden sind, dann übernehmen.
          IF gt_artsteu_buf-no_data IS INITIAL.
            MOVE-CORRESPONDING gt_artsteu_buf TO pet_artsteu.
            APPEND pet_artsteu.
          ENDIF. " gt_artsteu_buf-no_data is initial.
        ENDLOOP. " at gt_artsteu_buf from h_tabix1.
      ENDIF. " sy-subrc = 0.

*     Falls die gesuchten Daten noch nicht im Puffer sind.
    ELSE. " sy-subrc <> 0.
*       Einlesen der Konditionsdaten.
      CALL FUNCTION 'SALES_CONDITIONS_READ'
        EXPORTING
          pi_datab                     = pi_datab
          pi_datbi                     = pi_datbi
          pi_incfi                     = read_first_record
          pi_matnr                     = pi_artnr
          pi_vrkme                     = pi_vrkme
          pi_vkorg                     = pi_vkorg
          pi_vtweg                     = pi_vtweg
          pi_werks                     = pi_filia
          pi_scale_read                = 'X'
          pi_vorga                     = '02' " Grundpreis
          pi_direct_read               = pi_filia_const-pricing_direct
          pi_check_diff_kmein          = 'X'
        TABLES
          pe_t_saco                    = pet_kond
          pe_t_taxk                    = pet_artsteu
          pe_t_scale                   = pet_staffeln
        EXCEPTIONS
          no_bukrs_found               = 01
          plant_not_found              = 02
          material_not_found           = 03
          org_structure_not_completed  = 04
          vkorg_not_found              = 05
          no_pos_condition_types_found = 06
          no_condition_types_match     = 07
          OTHERS                       = 08.

*       Falls Parallelisierung aktiv, dann ist ein weiterer Ausbau des
*       Puffers unnötig.
*       Hintergrund:
*       Die erste Filiale einer Filial-Gruppe (nicht Untergruppe) wird
*       sowieso seriell verarbeitet. Hierbei wird der Puffer mit den
*       Preisinformationen gefüllt. Bei den nachfolgenden parallelen
*       Prozessen wird der Puffer nur noch gelesen aber nicht
*       mehr gefüllt.
      IF NOT g_parallel IS INITIAL.
        EXIT.
      ENDIF. " not g_parallel is initial.

*       Falls die vorgegebene Puffergrenze erreicht wurde, dann den
*       weiteren Ausbau des Puffers stoppen.
      IF sh_counter >= c_max_price_buf.
        EXIT.
      ENDIF. " sh_counter >= c_max_price_buf

*       Falls sämtliche filialabhängigen Preise in Tabelle A071
*       gespeichert sind und es auch nur wenige davon gibt, dann
*       sorge dafür, dass die diese filialabhängigen Preise nicht
*       im Konditionspuffer landen.
      IF NOT pi_filia_const-prices_in_a071 IS INITIAL.

*         Falls der Artikel filialabhängige Preise enthält, dann darf
*         er nicht in den Preispuffer übernommen werden.
        READ TABLE gt_a071_matnr WITH KEY
               matnr = pi_artnr
               BINARY SEARCH.

        IF sy-subrc = 0.
          EXIT.
        ENDIF.

      ENDIF. " not pi_filia_const-prices_in_a071 is initial.


***************************************************************
* Preiskopie aufweichen, falls nur wenige Daten in Tabelle A071
* gespeichert sind.
*    read table < MATNR'S aus A071> with key
*           matnr = pi_artnr
*           binary search.
*    if sy-subrc = 0.
*      exit.
*    endif.
****************************************************************

*       Übernehme Preisinformationen in Puffer.
      LOOP AT pet_kond
           WHERE kntyp <> c_kntyp_steuer
           AND   kntyp <> c_kntyp_agsteuer
           AND   kntyp <> c_kntyp_vsteuer.

        CLEAR: gt_kond_art_buf.
        MOVE-CORRESPONDING pet_kond TO gt_kond_art_buf.

*         Besetze Schlüsselfelder zum wiederfinden.
        gt_kond_art_buf-artnr     = pi_artnr.
        gt_kond_art_buf-vrkme     = pi_vrkme.
        gt_kond_art_buf-datab_sel = pi_datab.
        gt_kond_art_buf-datbi_sel = pi_datbi.
        INSERT gt_kond_art_buf INDEX h_tabix1.

        ADD 1 TO h_tabix1.
        ADD 1 TO sh_counter.

*         Prüfe, ob zugehörige Staffeln schon in Puffertabelle.
        READ TABLE gt_staff_art_buf WITH KEY
             knumh = pet_kond-knumh
             kopos = pet_kond-kopos
             BINARY SEARCH
             TRANSPORTING NO FIELDS.

        h_tabix2 = sy-tabix.

*         Falls Staffeln noch nicht im Puffer.
        IF sy-subrc <> 0.
*           Übernehme Staffeln.
          LOOP AT pet_staffeln
               WHERE knumh = pet_kond-knumh
               AND   kopos = pet_kond-kopos.

            CLEAR: gt_staff_art_buf.
            MOVE-CORRESPONDING pet_staffeln TO gt_staff_art_buf.
            INSERT gt_staff_art_buf INDEX h_tabix2.

            ADD 1 TO h_tabix2.

          ENDLOOP. " at pet_staffeln
        ENDIF. " sy-subrc <> 0.
      ENDLOOP.                             " AT PET_KOND

*       Falls kein Preis ermittelt wurde.
      IF sy-subrc <> 0.
*         Besetze Schlüsselfelder zum wiederfinden.
        CLEAR: gt_kond_art_buf.
        gt_kond_art_buf-artnr     = pi_artnr.
        gt_kond_art_buf-vrkme     = pi_vrkme.
        gt_kond_art_buf-datab_sel = pi_datab.
        gt_kond_art_buf-datbi_sel = pi_datbi.
        gt_kond_art_buf-no_data   = 'X'.
        INSERT gt_kond_art_buf INDEX h_tabix1.
      ENDIF. " sy-subrc <> 0.

*       Übernehme die Steuerkennzeichen aus Puffer.
      READ TABLE gt_artsteu_buf WITH KEY
           artnr     = pi_artnr
           vrkme     = pi_vrkme
           datab_sel = pi_datab
           datbi_sel = pi_datbi
           BINARY SEARCH
           TRANSPORTING NO FIELDS.

      h_tabix1 = sy-tabix.

*       Falls die gesuchten Daten noch nicht im Puffer sind.
      IF sy-subrc <> 0.
*         Übernehme die im Puffer befindlichen Steuerkennzeichen
*         in Ausgabetabelle.
        LOOP AT pet_artsteu.
          CLEAR: gt_artsteu_buf.
          MOVE-CORRESPONDING pet_artsteu TO gt_artsteu_buf.

*           Besetze Schlüsselfelder zum wiederfinden.
          gt_artsteu_buf-artnr     = pi_artnr.
          gt_artsteu_buf-vrkme     = pi_vrkme.
          gt_artsteu_buf-datab_sel = pi_datab.
          gt_artsteu_buf-datbi_sel = pi_datbi.
          INSERT gt_artsteu_buf INDEX h_tabix1.

          ADD 1 TO h_tabix1.
        ENDLOOP. " at pet_artsteu.

*         Falls keine Steuerkennzeichen ermittelt wurden.
        IF sy-subrc <> 0.
*           Besetze Schlüsselfelder zum wiederfinden.
          CLEAR: gt_artsteu_buf.
          MOVE-CORRESPONDING pet_artsteu TO gt_artsteu_buf.

*           Besetze Schlüsselfelder zum wiederfinden.
          gt_artsteu_buf-artnr     = pi_artnr.
          gt_artsteu_buf-vrkme     = pi_vrkme.
          gt_artsteu_buf-datab_sel = pi_datab.
          gt_artsteu_buf-datbi_sel = pi_datbi.
          gt_artsteu_buf-no_data   = 'X'.
          INSERT gt_artsteu_buf INDEX h_tabix1.
        ENDIF. " sy-subrc <> 0

      ENDIF. " sy-subrc <> 0.
    ENDIF. " sy-subrc = 0.
  ENDIF. " pi_filia_const-prices_siteindep is initial ...


ENDFORM. " matcond_get


* eject.
************************************************************************
FORM kondart_grundpreis_get
     TABLES pet_kondart_grund      STRUCTURE twpek
     USING  pi_filia_const         STRUCTURE wpfilconst.
************************************************************************
* FUNKTION:
* Besorge die Grund- bzw. Vergleichspreiskonditionsarten
*
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KONDART_GRUND     : Tabelle der Grundpreiskonditionsarten.

* PI_FILIA_CONST        : Filialkonstanten.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  STATICS: t_kondart LIKE twpek OCCURS 0 WITH HEADER LINE.
  DATA:    t_kondart_temp LIKE wpkartflag_v OCCURS 0 WITH HEADER LINE.

  REFRESH: pet_kondart_grund.
  CLEAR:   pet_kondart_grund.

* Prüfe, ob die Daten bereits einmal gelesen wurden.
  CLEAR: t_kondart.
  READ TABLE t_kondart INDEX 1.

* Falls die Daten bereits gelesen wurden.
  IF t_kondart-ekoar = pi_filia_const-ekoar.
    pet_kondart_grund[] = t_kondart[].

* Falls die Daten neu gelesen werden müssen.
  ELSE. " t_kondart-ekoar <> pi_filia_const-ekoar.
*   Besorge alle POS-relevanten Konditionsarten für diese Filiale
    CALL FUNCTION 'POS_CUST_ALLOWED_COND_READ'
      EXPORTING
        i_locnr               = pi_filia_const-kunnr
        i_flag_wrf1_lesen     = ' '
        i_kopro               = pi_filia_const-kopro
        i_flag_twpfi_lesen    = ' '
        i_ekoar               = pi_filia_const-ekoar
      TABLES
        o_kschl_v             = t_kondart_temp
      EXCEPTIONS
        filiale_unbekannt     = 1
        no_conditions_allowed = 2
        OTHERS                = 3.

*   Lösche alle überflüssigen Einträge.
    DELETE t_kondart_temp
           WHERE kschl3 IS INITIAL.

*   Lösche Puffertabelle.
    REFRESH: t_kondart.

*   Übernehme Konditionsarten in Ausgabetabelle.
    LOOP AT t_kondart_temp.
      MOVE-CORRESPONDING t_kondart_temp TO t_kondart.
      MOVE pi_filia_const-ekoar TO t_kondart-ekoar.
      APPEND t_kondart.

      APPEND t_kondart TO pet_kondart_grund.
    ENDLOOP.                           " AT T_KONDART_temp.

*   Falls keine Einträge gefunden wurden, dann erzeuge Dummy-Eintrag
*   im Puffer.
    IF sy-subrc <> 0.
      CLEAR: t_kondart.
      MOVE pi_filia_const-ekoar TO t_kondart-ekoar.
      APPEND t_kondart.

*     Übertrage Puffer in Ausgabetabelle.
      pet_kondart_grund[] = t_kondart[].
    ENDIF. " sy-subrc <> 0.

*   Daten sortieren.
    SORT pet_kondart_grund BY kschl3.

  ENDIF. " t_kondart-ekoar = pi_filia_const-ekoar.


ENDFORM. " kondart_grundpreis_get


* eject.
************************************************************************
FORM kondart_parallelpreis_get
     TABLES pet_kondart_parallel   STRUCTURE twpek
     USING  pi_filia_const         STRUCTURE wpfilconst.
************************************************************************
* FUNKTION:
* Besorge die Parallelpreiskonditionsarten
*
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KONDART_PARALLEL  : Tabelle der Parallelpeiskonditionsarten.

* PI_FILIA_CONST        : Filialkonstanten.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  STATICS: t_kondart LIKE twpek OCCURS 0 WITH HEADER LINE.
  DATA:    t_kondart_temp LIKE wpkartflag_v OCCURS 0 WITH HEADER LINE.

  REFRESH: pet_kondart_parallel.
  CLEAR:   pet_kondart_parallel.

* Prüfe, ob die Daten bereits einmal gelesen wurden.
  CLEAR: t_kondart.
  READ TABLE t_kondart INDEX 1.

* Falls die Daten bereits gelesen wurden.
  IF t_kondart-ekoar = pi_filia_const-ekoar.
    pet_kondart_parallel[] = t_kondart[].

* Falls die Daten neu gelesen werden müssen.
  ELSE. " t_kondart-ekoar <> pi_filia_const-ekoar.
*   Besorge alle POS-relevanten Konditionsarten für diese Filiale
    CALL FUNCTION 'POS_CUST_ALLOWED_COND_READ'
      EXPORTING
        i_locnr               = pi_filia_const-kunnr
        i_flag_wrf1_lesen     = ' '
        i_kopro               = pi_filia_const-kopro
        i_flag_twpfi_lesen    = ' '
        i_ekoar               = pi_filia_const-ekoar
      TABLES
        o_kschl_v             = t_kondart_temp
      EXCEPTIONS
        filiale_unbekannt     = 1
        no_conditions_allowed = 2
        OTHERS                = 3.

*   Lösche alle überflüssigen Einträge.
    DELETE t_kondart_temp
           WHERE kschl2 IS INITIAL.

*   Lösche Puffertabelle.
    REFRESH: t_kondart.

*   Übernehme Konditionsarten in Ausgabetabelle.
    LOOP AT t_kondart_temp.
      MOVE-CORRESPONDING t_kondart_temp TO t_kondart.
      MOVE pi_filia_const-ekoar TO t_kondart-ekoar.
      APPEND t_kondart.

      APPEND t_kondart TO pet_kondart_parallel.
    ENDLOOP.                           " AT T_KONDART_temp.

*   Falls keine Einträge gefunden wurden, dann erzeuge Dummy-Eintrag
*   im Puffer.
    IF sy-subrc <> 0.
      CLEAR: t_kondart.
      MOVE pi_filia_const-ekoar TO t_kondart-ekoar.
      APPEND t_kondart.

*     Übertrage Puffer in Ausgabetabelle.
      pet_kondart_parallel[] = t_kondart[].
    ENDIF. " sy-subrc <> 0.

*   Daten sortieren.
    SORT pet_kondart_parallel BY kschl2.

  ENDIF. " t_kondart-ekoar = pi_filia_const-ekoar.


ENDFORM. " kondart_parallelpreis_get

* eject.
************************************************************************
FORM condition_order_change
     TABLES pet_kond             STRUCTURE gt_kond_art
            pit_kondart_grund    STRUCTURE twpek
            pit_kondart_parallel STRUCTURE twpek
     USING  pi_pespr             STRUCTURE pespr.
************************************************************************
* FUNKTION:
* Ändere die Reihenfolge der Konditionen so, dass NACH jeder
* Verkaufs- oder Aktionspreiskonditionsart die zugehörigen
* Parallel- bzw. Grund-/Vergleichspreiskonditionsarten zur
* Aufbereitung gelangen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KOND              : Ergenistabelle der geänderten Kondiitonen

* PIT_KONDART_PARALLEL  : Tabelle der Parallelpeiskonditionsarten.

* PIT_KONDART_GRUND     : Tabelle der Grundpreiskonditionsarten.

* PI_PESPR              : Struktur mit Konditionsinfo
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_tabix LIKE sy-tabix.

  DATA: BEGIN OF t_kond_temp OCCURS 0.
          INCLUDE STRUCTURE gt_kond_art.
        DATA: END OF t_kond_temp.

  DATA: BEGIN OF t_kond_temp2 OCCURS 0.
          INCLUDE STRUCTURE gt_kond_art.
        DATA: END OF t_kond_temp2.

* Übernehme die Verkaufs- und Aktionspreiskonditionsart in separate
* Tabelle.
  LOOP AT pet_kond
       WHERE kschl = pi_pespr-aksch
       OR    kschl = pi_pespr-vksch.

    h_tabix = sy-tabix.
    APPEND pet_kond TO t_kond_temp.
    DELETE pet_kond INDEX h_tabix.
  ENDLOOP. " at pet_kond

* Baue neue Konditionstabelle mit geänderter Reihenfolge auf.
  LOOP AT t_kond_temp.

*   Übernehme Hauptkonditionsart
    APPEND t_kond_temp TO t_kond_temp2.

*   Besorge die zugehörige Grundpreiskonditionart
    READ TABLE pit_kondart_grund WITH KEY
         kschl = t_kond_temp-kschl.

*   Füge die zugehörige Grund-/Vergleichspreiskondarten hinzu.
    LOOP AT pet_kond
         WHERE kschl = pit_kondart_grund-kschl3
         AND   datab = t_kond_temp-datab
         AND   datbi = t_kond_temp-datbi.

      h_tabix = sy-tabix.
      APPEND pet_kond TO t_kond_temp2.
      DELETE pet_kond INDEX h_tabix.
      EXIT.
    ENDLOOP. " at pet_kond

*   Besorge die zugehörige Parallelpreiskonditionart
    READ TABLE pit_kondart_parallel WITH KEY
         kschl = t_kond_temp-kschl.

*   Füge die zugehörige Parallelpreiskonditionsarten hinzu.
    LOOP AT pet_kond
         WHERE kschl = pit_kondart_parallel-kschl2
         AND   datab = t_kond_temp-datab
         AND   datbi = t_kond_temp-datbi.

      h_tabix = sy-tabix.
      APPEND pet_kond TO t_kond_temp2.
      DELETE pet_kond INDEX h_tabix.
      EXIT.
    ENDLOOP. " at pet_kond

  ENDLOOP. " at t_kond_temp.

* Übernehme die restlichen Einträge (z.B. Zusatzkonditionen).
  LOOP AT pet_kond.
    APPEND pet_kond TO t_kond_temp2.
  ENDLOOP. " at pet_kond

* Übernehme Ergebnis in Ausgabetabelle.
  pet_kond[] = t_kond_temp2[].


ENDFORM. " condition_order_change
