*----------------------------------------------------------------------*
***INCLUDE LWPDAF17 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Aktionsrabatte.
************************************************************************


************************************************************************
FORM promreb_download TABLES   pit_promo       STRUCTURE wpromo
                      USING    pi_filia_const  STRUCTURE gi_filia_const
                               pi_filia        LIKE wpfilia-filia
                               pi_promo        LIKE wpstruc-modus
                               pi_debug        LIKE wpstruc-modus
                               pi_express      LIKE wpstruc-modus
                               pi_loeschen     LIKE wpstruc-modus
                               pi_mode         LIKE wpstruc-modus
                               pi_vkorg        LIKE wpstruc-vkorg
                               pi_vtweg        LIKE wpstruc-vtweg
                               pi_datum_ab     LIKE wpstruc-datum
                               pi_datum_bis    LIKE wpstruc-datum.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Aktionsrabatte.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_PROMO      : Liste der zu übertragenden Aktionen, falls
*                  PI_MODE = 'A' und PI_PROMO = 'X'.
* PI_FILIA_CONST : Feldleiste mit Filialkonstanten.
*
* PI_FILIA       : Filiale, an die verschickt werden soll.
*
* PI_PROMO       : = 'X', wenn Aktionsrabatte übertragen werden sollen
*                  (kann nur bei direkter Anforderung gesetzt sein).
* PI_DEBUG       : = 'X', wenn Status-Positionszeile ständig
*                         aktualisiert werden soll, sonst SPACE.
* PI_EXPRESS     : = 'X', wenn sofort versendet werden soll, sonst SPACE
*
* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                     sollen, sonst SPACE.
* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'A' = direkte
*                     Anforderung, 'R' = Restart.
* PI_VKORG       : Verkaufsorganisation.
*
* PI_VTWEG       : Vertriebsweg.
*
* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.
*
* PI_DATUM_BIS   : Ende des Betrachtungszeitraums.
*
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG), Rüdiger Zürl (SAP-R), rz 22.05.00
************************************************************************

  DATA: l_t_wakr     TYPE STANDARD TABLE OF wakr, " Rabatte einer Aktion
        wa_wakr      TYPE wakr,
        l_wakr_lines TYPE i,
        l_t_promo    LIKE gt_promo OCCURS 0 WITH HEADER LINE,
        l_wakh       TYPE wakh.

  DATA: BEGIN OF i_key,
          aktnr TYPE waktion,
          posnr TYPE reb_posnr,
        END OF i_key.

  data: h_vtweg  like gt_filia_group-vtweg.


* Besorge Referenzvertriebsweg, falls möglich.
  clear: tvkov.
  call function 'TVKOV_SINGLE_READ'
    EXPORTING
      tvkov_vkorg = pi_vkorg
      tvkov_vtweg = pi_vtweg
    IMPORTING
      wtvkov      = tvkov
    EXCEPTIONS
      not_found   = 1
      others      = 2.

* Setze Referenzvertriebsweg, falls vorhanden.
  if sy-subrc = 0.
    h_vtweg = tvkov-vtwko.
  else.
    h_vtweg = pi_vtweg.
  endif. " sy-subrc = 0.



* Rücksetze Segmentzähler und Positionszeilenmerker.
  CLEAR: g_segment_counter, g_new_position, g_status_pos.

* Merke daß 'Firstkey' gemerkt werden muß.
  g_new_firstkey = 'X'.

* Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
  PERFORM time_range_get USING pi_datum_ab          pi_datum_bis
                               pi_filia_const-vzeit
                               pi_filia_const-fabkl
                               g_datab
                               g_datbis
                               g_erstdat.

* Erzeuge Tabelle mit Arbeitstagen, falls nötig.
  PERFORM workdays_get TABLES gt_workdays
                       USING  g_datab  g_datbis
                              pi_filia_const-fabkl.

* Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
  CLEAR: gi_status_pos.
  gi_status_pos-dldnr  = g_dldnr.
  gi_status_pos-doctyp = c_idoctype_prom.

* Fall Restart-Modus.
  IF pi_mode = c_restart_mode.
    gi_status_pos-rspos  = 'X'.
  ENDIF.                               " pi_mode = c_restart_mode.

* Schreibe Status-Positionszeile.
  CLEAR g_returncode.
  PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                     g_returncode.

* Rücksetzen Fehler-Zähler.
  CLEAR: g_err_counter, g_firstkey.

* Initialisierungsfall oder direkte Anforderung oder Restart-Modus
* (alle Aktionsrabatte übertragen).
  IF pi_mode = c_init_mode OR ( pi_promo <> space AND
                                pit_promo[] IS INITIAL ).
*   Besorge alle Aktionen mit aktivierten Rabatten, die innerhalb
*   des Betrachtungszeitraums von Filiale PI_FILIA laufen.
    SELECT wakh~aktnr
      FROM wakh INNER JOIN wakr
        ON wakh~aktnr = wakr~aktnr
      INTO TABLE l_t_promo
     WHERE wakh~vkdab LE g_datbis
       AND wakh~vkdbi GE g_datab
       AND wakr~reb_status = 'B'.      " aktiviert

*   Duplikate entfernen
    SORT l_t_promo.
    DELETE ADJACENT DUPLICATES FROM l_t_promo.
  ELSE.
    l_t_promo[] = pit_promo[].
  ENDIF.                               " pi_mode = c_init_mode OR ...

* Schleife über alle selektierten Aktionen
  LOOP AT l_t_promo.

*   Besorge alle für diese Filiale im Betrachtungszeitraum laufenden
*   Rabatte der Aktion pit_promo-aktnr.
    CALL FUNCTION 'PROMOTION_REBATE_IN_SITE'
      EXPORTING
        pi_aktnr                   = l_t_promo-aktnr
        pi_kunnr                   = pi_filia_const-kunnr
        pi_vkorg                   = pi_vkorg
        pi_vtweg                   = h_vtweg
        pi_datab                   = g_datab
        pi_datbi                   = g_datbis
      IMPORTING
        pe_wakh                    = l_wakh
      TABLES
        pe_t_wakr                  = l_t_wakr
      EXCEPTIONS
        wrong_input                = 1
        promotion_not_found        = 2
        promotion_out_of_period    = 3
        no_rebate_found            = 4
        site_not_participating     = 5
        merchandise_category_error = 6
        unknown_rebate_level       = 7
        OTHERS                     = 8.

    IF sy-subrc <> 0.
*     z.B. kein Rabatt für diese Filiale in dieser Áktion
*     => prüfe nächste Aktion
      CONTINUE.
    ENDIF.

*   Merke 'Firstkey'.
    IF g_new_firstkey <> space.
      READ TABLE l_t_wakr INDEX 1 INTO wa_wakr.
      i_key-aktnr = wa_wakr-aktnr.
      i_key-posnr = wa_wakr-posnr.
      g_firstkey = i_key.
      CLEAR: g_new_firstkey.
    ENDIF.                             " G_NEW_FIRSTKEY <> SPACE.

*   Bereite IDOC auf.
    CALL FUNCTION 'MASTERIDOC_CREATE_DLPREBATES'
      EXPORTING
        pi_vkorg           = pi_vkorg
        pi_vtweg           = pi_vtweg
        pi_filia           = pi_filia
        pi_dldlfdnr        = g_dldlfdnr
        pi_dldnr           = g_dldnr
        pi_filia_const     = pi_filia_const
        pi_datum_ab        = g_datab
        pi_datum_bis       = g_datbis
        pi_loeschen        = pi_loeschen
        pi_mode            = pi_mode
        pi_wakh            = l_wakh
      TABLES
        pit_wakr           = l_t_wakr
        pit_workdays       = gt_workdays
      CHANGING
        px_segment_counter = g_segment_counter
      EXCEPTIONS
        download_exit      = 1
        OTHERS             = 2.

*   Es sind Fehler beim Download aufgetreten'
    IF sy-subrc <> 0.
      RAISE download_exit.
    ENDIF.                             " SY-SUBRC <> 0.

  ENDLOOP.                             " AT l_t_promo

* Erzeuge IDOC, falls nötig .
  IF g_segment_counter > 0.
*   Bestimme 'Lastkey'.
    DESCRIBE TABLE l_t_wakr LINES l_wakr_lines.
    READ TABLE l_t_wakr INDEX l_wakr_lines INTO wa_wakr.
    i_key-aktnr = wa_wakr-aktnr.
    i_key-posnr = wa_wakr-posnr.

    PERFORM idoc_create USING  gt_idoc_data
                               g_mestype_prom
                               c_idoctype_prom
                               g_segment_counter
                               g_err_counter
                               g_firstkey
                               i_key
                               g_dldnr
                               g_dldlfdnr
                               pi_filia
                               pi_filia_const.

  ENDIF.                               " G_SEGMENT_COUNTER > 0.

* Schreibe Fehlermeldungen auf Datenbank, falls nötig.
  IF g_init_log <> space.
    PERFORM appl_log_write_to_db.
  ENDIF.                               " G_INIT_LOG <> SPACE.

* Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
* auf OK.
  IF g_status = 0.
*   Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
    CLEAR: gi_status_header.
    gi_status_header-dldnr = g_dldnr.
    gi_status_header-gesst = c_status_ok.

*   Schreibe Status-Kopfzeile.
    PERFORM status_write_head USING  'X'  gi_status_header  g_dldnr
                                          g_returncode.
  ENDIF.                               " G_STATUS = 0.

ENDFORM.                               " promreb_download
*&---------------------------------------------------------------------*
*&      Form  idoc_data_promreb_append
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PXT_IDOC_DATA  text
*      -->P_PIT_WAKR  text
*      -->P_PI_WAKH  text
*      -->P_PI_DATUM_AB  text
*      -->P_PX_SEGMENT_COUNTER  text
*      -->P_PI_LOESCHEN  text
*      -->P_PI_FILIA  text
*      -->P_G_RETURNCODE  text
*      -->P_PI_DLDNR  text
*      -->P_PX_DLDLFDNR  text
*      -->P_PI_FILIA_CONST  text
*      -->P_PI_MODE  text
*----------------------------------------------------------------------*
FORM idoc_data_promreb_append
                  TABLES   pit_wakr       STRUCTURE wakr
                  USING    pi_wakh        STRUCTURE wakh
                           pi_datum       LIKE wpstruc-datum
                           px_segcnt      LIKE g_segment_counter
                           pi_loeschen    LIKE wpstruc-modus
                           pi_filia       LIKE t001w-werks
                           pe_fehlercode  LIKE syst-subrc
                           pi_dldnr       LIKE wdls-dldnr
                           pi_dldlfdnr    LIKE wdlsp-lfdnr
                           pi_filia_const LIKE wpfilconst
                           pi_aktiviert
                           pi_deaktiviert.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:
* pit_wakr      : Aktionsrabatt-Daten.
* pi_wakh       : Aktionskopf-Daten.
* pi_datum      : Datum für das die Daten aufbereitet werden sollen.
* px_segcnt     : Segment-Zähler.
* pi_loeschen   : = 'X', wenn Löschmodus aktiv.
* pi_filia      : Filiale, an die versendet werden soll.
* pe_fehlercode : > 0, wenn Fehler beim Umsetzen der Daten.
* pi_dldnr      : Downloadnummer für Statusverfolgung.
* pi_dldlfdnr   : Laufende Nr. der Positionszeile für Statusverfolgung.
* pi_filia_const: Filialkonstanten
* pi_aktiviert  : es gibt aktivierte Rabatte zum Versenden
* pi_deaktiviert: es gibt deaktivierte Rabatte zum Versenden
* ----------------------------------------------------------------------
* Erweiterung Aktionsrabatte, rz 25.05.00
************************************************************************

  DATA: seg_local_cnt TYPE i,
        l_isocd_curr  TYPE isocd,
        l_isocd_unit  TYPE isocd_unit,
        l_val_ex      TYPE bapicurr_d.
  DATA: BEGIN OF i_object_key,
          aktnr TYPE waktion,
        END OF i_object_key.

* Zurücksetzen Returncode
  CLEAR pe_fehlercode.

* Zurücksetzen Temporärtabelle für IDOC-Daten
  REFRESH gt_idoc_data_temp.

* Zurücksetzen lokalen Segmentzähler
  CLEAR seg_local_cnt.

********** Verschicke aktivierte Rabatte (REB_STATUS = 'B') **********
  IF NOT pi_aktiviert IS INITIAL.
*   es gibt aktivierte Rabatte zum Verschicken

*   Aufbereitung ID-Segment (Aktionsrabatt-Kopf) E1WPREB01
*   --------------------------------------------
    CLEAR e1wpreb01.
    e1wpreb01-filiale = pi_filia_const-kunnr.
    IF pi_wakh-vkdab GT sy-datum.
      e1wpreb01-aktivdatum = pi_wakh-vkdab.
    ELSE.
      e1wpreb01-aktivdatum = sy-datum.
    ENDIF.
    e1wpreb01-aenddatum = '00000000'.
    e1wpreb01-aenderer = ' '.
    e1wpreb01-aktionsnr = pi_wakh-aktnr.

    IF pi_loeschen <> space.
*     Falls Löschmodus aktiv
      e1wpreb01-aendkennz = c_delete.
    ELSE.
*     Falls Löschmodus nicht aktiv
      e1wpreb01-aendkennz = c_modi.
    ENDIF.

*   Erzeuge temporären IDOC-Segmentsatz
    gt_idoc_data_temp-segnam = c_e1wpreb01_name.
    gt_idoc_data_temp-sdata  = e1wpreb01.
    APPEND gt_idoc_data_temp.

*   Aktualisiere Segmentzähler
    ADD 1 TO seg_local_cnt.

    IF pi_loeschen = space.
*     Daten müssen übertragen werden, da Löschmodus nicht aktiv

*     Loop über alle aktiven Rabatte dieser Aktion
      LOOP AT pit_wakr WHERE reb_status = 'B'.

*       Aufbereiten Segment Aktionsrabatt-Position E1WPREB02
*       ------------------------------------------
        CLEAR e1wpreb02.
        IF pit_wakr-reb_level = '05'.  " gesamtes Sortiment
          e1wpreb02-rebate_level = '01'. " alle Materialien
        ELSEIF pit_wakr-reb_level = '04' " Warengruppenhierarchie
            OR pit_wakr-reb_level = '03'.
          e1wpreb02-rebate_level = '02'. " Warengruppe
          e1wpreb02-rebate_group = pit_wakr-wghier.
        ELSEIF pit_wakr-reb_level = '02'." Basis-Warengruppe
          e1wpreb02-rebate_level = '02'. " Warengruppe
          e1wpreb02-rebate_group = pit_wakr-matkl.
*{   INSERT         XB4K001679                                        1
* WRF_POSOUT
        ELSEIF pit_wakr-reb_level = '06'. " Artikelhierarchie
          perform call_badi_idoc_promreb_append
                       using pit_wakr
                       changing e1wpreb02.
        ELSEIF pit_wakr-reb_level = '07'. " Artikelhierarchie/Saison
          perform call_badi_idoc_promreb_append
                       using pit_wakr
                       changing e1wpreb02.
* WRF_POSOUT
*}   INSERT
        ENDIF.

*       Erzeuge temporären IDOC-Segmentsatz
        gt_idoc_data_temp-segnam = c_e1wpreb02_name.
        gt_idoc_data_temp-sdata  = e1wpreb02.
        APPEND gt_idoc_data_temp.

*       Aktualisiere Segmentzähler
        ADD 1 TO seg_local_cnt.

*       Aufbereiten Segment Aktionsrabatt-Kondition E1WPREB03
*       ------------------------------------------
        CLEAR e1wpreb03.
        IF pit_wakr-reb_value IS INITIAL.
*         prozentualer Rabatt
          e1wpreb03-kondart = pi_wakh-kschl_perc.
        ELSE.
*         albsoluter Rabatt
          e1wpreb03-kondart = pi_wakh-kschl_val.
        ENDIF.
        e1wpreb03-begindatum = pit_wakr-reb_datefr.
        e1wpreb03-beginnzeit = '000000'.
        e1wpreb03-enddatum = pit_wakr-reb_dateto.
        e1wpreb03-endzeit = '000000'.
        e1wpreb03-freiverw1 = space.

*       Erzeuge temporären IDOC-Segmentsatz
        gt_idoc_data_temp-segnam = c_e1wpreb03_name.
        gt_idoc_data_temp-sdata  = e1wpreb03.
        APPEND gt_idoc_data_temp.

*       Aktualisiere Segmentzähler
        ADD 1 TO seg_local_cnt.

*       Aufbereiten Segment Aktionsrabatt-Konditionswert E1WPREB04
*       ------------------------------------------------
        CLEAR e1wpreb04.
        e1wpreb04-vorzeichen = '-'.
        IF pit_wakr-reb_value IS INITIAL.
*         prozentualer Rabatt
          e1wpreb04-kondsatz = pit_wakr-reb_perc.
          CONDENSE e1wpreb04-kondsatz.
        ELSE.
*         albsoluter Rabatt
          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
            EXPORTING
              currency        = pit_wakr-reb_curr
              amount_internal = pit_wakr-reb_value
            IMPORTING
              amount_external = l_val_ex.
          e1wpreb04-kondwert = l_val_ex.
          CONDENSE e1wpreb04-kondwert.
          e1wpreb04-currency = pit_wakr-reb_curr.
*         besorge ISO-Code Währung
          CALL FUNCTION 'CURRENCY_CODE_SAP_TO_ISO'
            EXPORTING
              sap_code  = pit_wakr-reb_curr
            IMPORTING
              iso_code  = l_isocd_curr
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc = 0.
            e1wpreb04-currency_iso = l_isocd_curr.
          ENDIF.
          e1wpreb04-menge = '1'.
          e1wpreb04-unit = pit_wakr-reb_unit.
*         besorge ISO-Code Mengeneinheit
          CALL FUNCTION 'UNIT_OF_MEASURE_SAP_TO_ISO'
            EXPORTING
              sap_code    = pit_wakr-reb_unit
            IMPORTING
              iso_code    = l_isocd_unit
            EXCEPTIONS
              not_found   = 1
              no_iso_code = 2
              OTHERS      = 3.
          IF sy-subrc = 0.
            e1wpreb04-unit_iso = l_isocd_unit.
          ENDIF.
        ENDIF.

*       Erzeuge temporären IDOC-Segmentsatz
        gt_idoc_data_temp-segnam = c_e1wpreb04_name.
        gt_idoc_data_temp-sdata  = e1wpreb04.
        APPEND gt_idoc_data_temp.

*       Aktualisiere Segmentzähler
        ADD 1 TO seg_local_cnt.

      ENDLOOP.                         " AT pit_wakr.

    ENDIF.                             " pi_loeschen = space.

  ENDIF.

********** Verschicke deaktivierte Rabatte (REB_STATUS = 'C') **********
  IF NOT pi_deaktiviert IS INITIAL.
*   es gibt deaktivierte Rabatte zum Verschicken

* Aufbereitung ID-Segment (Aktionsrabatt-Kopf) E1WPREB01
* --------------------------------------------
    CLEAR e1wpreb01.
    e1wpreb01-filiale = pi_filia_const-kunnr.
    IF pi_wakh-vkdab GT sy-datum.
      e1wpreb01-aktivdatum = pi_wakh-vkdab.
    ELSE.
      e1wpreb01-aktivdatum = sy-datum.
    ENDIF.
    e1wpreb01-aenddatum = '00000000'.
    e1wpreb01-aenderer = ' '.
    e1wpreb01-aktionsnr = pi_wakh-aktnr.

*   Löschmodus
    e1wpreb01-aendkennz = c_delete.

*   Erzeuge temporären IDOC-Segmentsatz
    gt_idoc_data_temp-segnam = c_e1wpreb01_name.
    gt_idoc_data_temp-sdata  = e1wpreb01.
    APPEND gt_idoc_data_temp.

*   Aktualisiere Segmentzähler
    ADD 1 TO seg_local_cnt.

*   Loop über alle deaktivierten Rabatte dieser Aktion
    LOOP AT pit_wakr WHERE reb_status = 'C'.

*     Aufbereiten Segment Aktionsrabatt-Position E1WPREB02
*     ------------------------------------------
      CLEAR e1wpreb02.
      IF pit_wakr-reb_level = '05'.    " gesamtes Sortiment
        e1wpreb02-rebate_level = '01'. " alle Materialien
      ELSEIF pit_wakr-reb_level = '04' " Warengruppenhierarchie
          OR pit_wakr-reb_level = '03'.
        e1wpreb02-rebate_level = '02'. " Warengruppe
        e1wpreb02-rebate_group = pit_wakr-wghier.
      ELSEIF pit_wakr-reb_level = '02'." Basis-Warengruppe
        e1wpreb02-rebate_level = '02'. " Warengruppe
        e1wpreb02-rebate_group = pit_wakr-matkl.
* WRF_POSOUT
        ELSEIF pit_wakr-reb_level = '06'. " Artikelhierarchie
          perform call_badi_idoc_promreb_append
                       using pit_wakr
                       changing e1wpreb02.
        ELSEIF pit_wakr-reb_level = '07'. " Artikelhierarchie/Saison
          perform call_badi_idoc_promreb_append
                       using pit_wakr
                       changing e1wpreb02.
* WRF_POSOUT
      ENDIF.

*     Erzeuge temporären IDOC-Segmentsatz
      gt_idoc_data_temp-segnam = c_e1wpreb02_name.
      gt_idoc_data_temp-sdata  = e1wpreb02.
      APPEND gt_idoc_data_temp.

*     Aktualisiere Segmentzähler
      ADD 1 TO seg_local_cnt.

*     Aufbereiten Segment Aktionsrabatt-Kondition E1WPREB03
*     ------------------------------------------
      CLEAR e1wpreb03.
      IF pit_wakr-reb_value IS INITIAL.
*       prozentualer Rabatt
        e1wpreb03-kondart = pi_wakh-kschl_perc.
      ELSE.
*       albsoluter Rabatt
        e1wpreb03-kondart = pi_wakh-kschl_val.
      ENDIF.
      e1wpreb03-begindatum = pit_wakr-reb_datefr.
      e1wpreb03-beginnzeit = '000000'.
      e1wpreb03-enddatum = pit_wakr-reb_dateto.
      e1wpreb03-endzeit = '000000'.
      e1wpreb03-freiverw1 = space.

*     Erzeuge temporären IDOC-Segmentsatz
      gt_idoc_data_temp-segnam = c_e1wpreb03_name.
      gt_idoc_data_temp-sdata  = e1wpreb03.
      APPEND gt_idoc_data_temp.

*     Aktualisiere Segmentzähler
      ADD 1 TO seg_local_cnt.

*     Aufbereiten Segment Aktionsrabatt-Konditionswert E1WPREB04
*     ------------------------------------------------
      CLEAR e1wpreb04.
      e1wpreb04-vorzeichen = '-'.
      IF pit_wakr-reb_value IS INITIAL.
*       prozentualer Rabatt
        e1wpreb04-kondsatz = pit_wakr-reb_perc.
        CONDENSE e1wpreb04-kondsatz.
      ELSE.
*       albsoluter Rabatt
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
          EXPORTING
            currency        = pit_wakr-reb_curr
            amount_internal = pit_wakr-reb_value
          IMPORTING
            amount_external = l_val_ex.
        e1wpreb04-kondwert = l_val_ex.
        CONDENSE e1wpreb04-kondwert.
        e1wpreb04-currency = pit_wakr-reb_curr.
*       besorge ISO-Code Währung
        CALL FUNCTION 'CURRENCY_CODE_SAP_TO_ISO'
          EXPORTING
            sap_code  = pit_wakr-reb_curr
          IMPORTING
            iso_code  = l_isocd_curr
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc = 0.
          e1wpreb04-currency_iso = l_isocd_curr.
        ENDIF.
        e1wpreb04-menge = '1'.
        e1wpreb04-unit = pit_wakr-reb_unit.
*       besorge ISO-Code Mengeneinheit
        CALL FUNCTION 'UNIT_OF_MEASURE_SAP_TO_ISO'
          EXPORTING
            sap_code    = pit_wakr-reb_unit
          IMPORTING
            iso_code    = l_isocd_unit
          EXCEPTIONS
            not_found   = 1
            no_iso_code = 2
            OTHERS      = 3.
        IF sy-subrc = 0.
          e1wpreb04-unit_iso = l_isocd_unit.
        ENDIF.
      ENDIF.

*     Erzeuge temporären IDOC-Segmentsatz
      gt_idoc_data_temp-segnam = c_e1wpreb04_name.
      gt_idoc_data_temp-sdata  = e1wpreb04.
      APPEND gt_idoc_data_temp.

*     Aktualisiere Segmentzähler
      ADD 1 TO seg_local_cnt.

    ENDLOOP.                           " AT pit_wakr.

  ENDIF.

************************************************************************
*************************   U S E R - E X I T   ************************
  CALL CUSTOMER-FUNCTION '016'
    EXPORTING
      pi_segment_counter       = px_segcnt
      pi_dldnr                 = pi_dldnr
      pi_dldlfdnr              = pi_dldlfdnr
      pi_ermod                 = pi_filia_const-ermod
      pi_firstkey              = g_firstkey
      pi_filia_const           = pi_filia_const
      pi_promo_head            = pi_wakh
*    IMPORTING
*      pe_fehlercode            = pe_fehlercode
    TABLES
      pxt_idoc_data_temp       = gt_idoc_data_temp
      pit_idoc_data            = gt_idoc_data_dummy
      pit_reb_data             = pit_wakr
    CHANGING
      px_init_log              = g_init_log
      px_status                = g_status
      px_status_pos            = g_status_pos
      px_err_counter           = g_err_counter
      px_seg_local_cnt         = seg_local_cnt
      PIT_IDOC_DATA_new        = GT_IDOC_DATA.


* Fehlerbearbeitung bei Umsetzfehlern
  IF pe_fehlercode <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Fülle allgemeinen Objektschlüssel.
      CLEAR: i_object_key.
      i_object_key-aktnr = pi_wakh-aktnr.
      g_object_key       = i_object_key.

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
*-----------------------------------------------------------------------
* Übernahme der IDOC-Daten aus Temporärtabelle
*-----------------------------------------------------------------------
    PERFORM idoc_data_assume TABLES gt_idoc_data_temp
                             using  gt_idoc_data
                                    px_segcnt
                                    seg_local_cnt.
  ENDIF.                               " pe_fehlercode.

ENDFORM.                               " idoc_data_promreb_append


*eject
************************************************************************
FORM promreb_download_change_mode
     TABLES pit_ot3_promreb        STRUCTURE gt_ot3_promreb
     USING  pi_filia_group         STRUCTURE gt_filia_group
            pi_mode                LIKE wpstruc-modus
            pi_erstdat             LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_dldnr               LIKE wdls-dldnr.
************************************************************************
* FUNKTION:
* Bereite den Download für die einzelnen IDOC-Typen vor dieser
* Filiale vor.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT3_PROMREB       : Aktionsrabatte: Objekttabelle 3.

* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_DLDNR              : Aktuelle Downloadnummer.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: i_filia_const LIKE gi_filia_const.


* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  g_current_doctype = c_idoctype_prom.

* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING pi_filia_group TO i_filia_const.

* Rücksetze Segmentzähler und Positionszeilenmerker.
  CLEAR: g_segment_counter, g_status_pos.

* Rücksetzen Fehler-Zähler.
  CLEAR: g_err_counter, g_firstkey.

* Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
  CLEAR: gi_status_pos.
  gi_status_pos-dldnr  = g_dldnr.
  gi_status_pos-doctyp = c_idoctype_prom.

* Schreibe Status-Positionszeile.
  CLEAR g_returncode.
  PERFORM status_write_pos USING ' ' gi_status_pos  g_dldlfdnr
                                     g_returncode.

* Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
  PERFORM time_range_get USING pi_erstdat
                               pi_datp4
                               pi_filia_group-vzeit
                               pi_filia_group-fabkl
                               g_datab
                               g_datbis
                               pi_erstdat.

* Erzeuge Tabelle mit Arbeitstagen, falls nötig.
  PERFORM workdays_get TABLES gt_workdays
                       USING  g_datab  g_datbis
                              pi_filia_group-fabkl.


* IDOC-Aufbereitung
  CALL FUNCTION 'MASTERIDOC_CREATE_DLPREBATES'
    EXPORTING
      pi_vkorg       = pi_filia_group-vkorg
      pi_vtweg       = pi_filia_group-vtweg
      pi_filia       = pi_filia_group-filia
      pi_dldlfdnr    = g_dldlfdnr
      pi_dldnr       = pi_dldnr
      pi_filia_const = i_filia_const
      pi_datum_ab    = g_datab
      pi_datum_bis   = g_datbis
      pi_mode        = pi_mode
    TABLES
      pit_promrebkey = pit_ot3_promreb
      pit_workdays   = gt_workdays
    EXCEPTIONS
      download_exit  = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                               " promreb_download_change_mode
*&---------------------------------------------------------------------*
*&      Form  process_promotion
*&---------------------------------------------------------------------*
*       Aufbereitung eines IDOCs für eine Aktion anhand der
*       Änderungszeiger
*----------------------------------------------------------------------*
*      -->P_L_AKTNR  text
*      -->P_PI_FILIA_CONST  text
*      -->P_PI_VKORG  text
*      -->P_PI_VTWEG  text
*      -->P_PI_DATUM_AB  text
*      -->P_PI_DATUM_BIS  text
*      -->P_PX_SEGMENT_COUNTER  text
*      -->P_PI_FILIA  text
*      -->P_PI_DLDNR  text
*      -->P_PI_DLDLFDNR  text
*      -->P_PI_FILIA_CONST  text
*----------------------------------------------------------------------*
FORM process_promotion TABLES   pi_t_posnr         STRUCTURE wppromreb3
                       USING    pi_aktnr           TYPE waktion
                                pi_filia_const     TYPE wpfilconst
                                pi_vkorg           TYPE w_vkorg_header
                                pi_vtweg           TYPE w_vtweg_header
                                pi_datum_ab        TYPE wpstruc-datum
                                pi_datum_bis       TYPE wpstruc-datum
                                pi_segment_counter LIKE wdlsp-anseg
                                pi_filia           LIKE t001w-werks
                                pi_dldnr           LIKE wdls-dldnr
                                pi_dldlfdnr        LIKE wdlsp-lfdnr.

  DATA: BEGIN OF i_key,
          aktnr TYPE waktion,
        END OF i_key.
  DATA: l_wakh        TYPE wakh,
        wa_wakr       TYPE wakr,
        l_t_wakr      TYPE STANDARD TABLE OF wakr,
        l_posnr       TYPE wppromreb3,
        l_aktiviert,
        l_deaktiviert.

  data: h_vtweg  like gt_filia_group-vtweg.


* Besorge Referenzvertriebsweg, falls möglich.
  clear: tvkov.
  call function 'TVKOV_SINGLE_READ'
    EXPORTING
      tvkov_vkorg = pi_vkorg
      tvkov_vtweg = pi_vtweg
    IMPORTING
      wtvkov      = tvkov
    EXCEPTIONS
      not_found   = 1
      others      = 2.

* Setze Referenzvertriebsweg, falls vorhanden.
  if sy-subrc = 0.
    h_vtweg = tvkov-vtwko.
  else.
    h_vtweg = pi_vtweg.
  endif. " sy-subrc = 0.

  CALL FUNCTION 'PROMOTION_REBATE_IN_SITE'
    EXPORTING
      pi_aktnr                   = pi_aktnr
      pi_kunnr                   = pi_filia_const-kunnr
      pi_vkorg                   = pi_vkorg
      pi_vtweg                   = h_vtweg
      pi_datab                   = pi_datum_ab
      pi_datbi                   = pi_datum_bis
    IMPORTING
      pe_wakh                    = l_wakh
    TABLES
      pe_t_wakr                  = l_t_wakr
    EXCEPTIONS
      wrong_input                = 1
      promotion_not_found        = 2
      promotion_out_of_period    = 3
      no_rebate_found            = 4
      site_not_participating     = 5
      merchandise_category_error = 6
      unknown_rebate_level       = 7
      unknown_activation_level   = 8
      OTHERS                     = 9.

  IF sy-subrc = 0.
*   IDOC verarbeiten
*   bestimme zu übertragende Rabatte
    LOOP AT l_t_wakr INTO wa_wakr.
      READ TABLE pi_t_posnr INTO l_posnr
        WITH KEY aktnr = pi_aktnr
                 posnr = wa_wakr-posnr BINARY SEARCH.
      IF sy-subrc NE 0.
*       Eintrag muß nicht verschickt werden
        DELETE l_t_wakr.
      ELSE.
        IF wa_wakr-reb_status = 'B'.   " aktiviert
          l_aktiviert = 'X'.
        ELSEIF wa_wakr-reb_status = 'C'. " deaktiviert
          l_deaktiviert = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.                           " at l_t_wakr into wa_wakr.

*   zu übertragende Rabatte stehen in l_t_wakr
    PERFORM idoc_data_promreb_append TABLES l_t_wakr
                                     USING  l_wakh
                                            pi_datum_ab
                                            pi_segment_counter
                                            ' '
                                            pi_filia
                                            g_returncode
                                            pi_dldnr
                                            pi_dldlfdnr
                                            pi_filia_const
                                            l_aktiviert
                                            l_deaktiviert.
  ENDIF.

ENDFORM.                               " process_promotion
