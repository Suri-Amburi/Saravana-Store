FUNCTION ZZMASTERIDOC_CREATE_DLPART.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_ARTNR) LIKE  WLK1-ARTNR
*"     VALUE(PI_DATUM_AB) LIKE  WPSTRUC-DATUM
*"     VALUE(PI_DATBI_LIST) LIKE  WPSTRUC-DATUM DEFAULT '00000000'
*"     VALUE(PI_DATUM_BIS) LIKE  WPSTRUC-DATUM
*"     VALUE(PI_DEBUG) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PX_DLDLFDNR) LIKE  WDLSP-LFDNR
*"     VALUE(PI_DLDNR) LIKE  WDLS-DLDNR
*"     VALUE(PI_EXPRESS) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_FILIA) LIKE  T001W-WERKS
*"     VALUE(PI_LOESCHEN) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_MODE) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA02) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA03) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA04) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA05) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA07) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA08) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA09) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA10) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_E1WPA11) LIKE  WPSTRUC-MODUS
*"     VALUE(PI_VKORG) LIKE  WPSTRUC-VKORG
*"     VALUE(PI_VRKME) LIKE  WLK1-VRKME
*"     VALUE(PI_VTWEG) LIKE  WPSTRUC-VTWEG
*"     VALUE(PX_SEGMENT_COUNTER) LIKE  WDLSP-ANSEG
*"     VALUE(PI_AENDTYP) LIKE  E1WPA01-AENDTYP DEFAULT ' '
*"     VALUE(PI_FILIA_CONST) LIKE  WPFILCONST STRUCTURE  WPFILCONST
*"  EXPORTING
*"     VALUE(PX_SEGMENT_COUNTER) LIKE  WDLSP-ANSEG
*"  TABLES
*"      PIT_LISTUNG STRUCTURE  WPWLK1
*"      PIT_ART_EQUAL STRUCTURE  WPART OPTIONAL
*"      PIT_OT3_ARTSTM STRUCTURE  WPAOT3 OPTIONAL
*"      PIT_WORKDAYS STRUCTURE  WPWORKDAYS
*"  CHANGING
*"     REFERENCE(PXT_IDOC_DATA) TYPE  SHORT_EDIDD
*"  EXCEPTIONS
*"      DOWNLOAD_EXIT
*"--------------------------------------------------------------------
  DATA: datab_slct    LIKE sy-datum, " Beginn List. innerhalb B.Zeitraum
        datbi_slct    LIKE sy-datum, " Ende Listung innerhalb B.Zeitraum
        vzeit_temp    LIKE sy-index, " Daraus resultierende Vorlaufzeit
        listung,                       " Listungsflag für Artikel
        geaendert,                  " ='X', wenn Artikel verändert wurde
        readindex     TYPE i,           " Indexwert zum Lesen interner Tab.
        initdat       LIKE sy-datum,      " Nur für Änd.- und Restart-Fall
        no_price_send,              " ='X', wenn kein Preis senden
        ean           LIKE marm-ean11,        " zum zwischensp. der Haupt-EAN
        pmata         LIKE mara-pmata.        " Preismaterial des Artikels.

  DATA: BEGIN OF i_key,
          matnr LIKE marm-matnr,
          vrkme LIKE marm-meinh.
  DATA: END OF i_key.

* Datümer zu denen eine Zählaufforderung stattfinden soll.
  DATA: BEGIN OF t_date_for_count OCCURS 1.
      INCLUDE STRUCTURE wpdate.
  DATA: END OF t_date_for_count.

* Initialisiere Flag, ob überhaupt ein Preis versendet werden soll.
  CLEAR: no_price_send.

* Bestimme Objektkey.
  i_key-matnr = pi_artnr.
  i_key-vrkme = pi_vrkme.

* Vorbesetzen von INITDAT.
  MOVE space TO initdat.

* Falls eine neue Status-Positionszeile geschrieben werden muß.
  IF g_new_position <> space.
    CLEAR: g_new_position.

*   Aufbereiten der Parameter zum schreiben der
*   Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-doctyp = c_idoctype_artstm.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING ' ' gi_status_pos  px_dldlfdnr
                                       g_returncode.
    g_dldlfdnr = px_dldlfdnr.

*   Merke neuen 'Firstkey'.
    g_firstkey = i_key.
  ENDIF. " g_new_position <> space.

* Initialisierungsfall, direkte Anforderung bzw. Restart-Fall.
  IF pi_mode <> c_change_mode.
*   Bestimme das Listungsintervall innerhalb des
*   Betrachtungszeitraums.
    PERFORM listing_range_get TABLES pit_listung
                              USING  pi_datum_ab  pi_datum_bis
                                     pi_vrkme     datab_slct
                                     datbi_slct.

*   Im Initialisierungsfall, direkte Anforderung und Restart ist
*   das Ende des Betrachtungszeitraums gleich dem Ende des
*   Selektionsbereichs.
    pi_datbi_list = datbi_slct.

* Falls Änderungsfall.
  ELSE. " PI_MODE = C_CHANGE_MODE
*   Sortieren der Bewirtschaftungszeiträume.
    SORT pit_listung BY vrkme datab.

    datab_slct = pi_datum_ab.
    datbi_slct = pi_datum_bis.

*   Bestimme INITDAT.
    READ TABLE pit_ot3_artstm INDEX 1.
    IF pit_ot3_artstm-init <> space.
      initdat = pit_ot3_artstm-datum.
    ENDIF. " PIT_OT3_ARTSTM-INIT <> SPACE.

  ENDIF. " pi_mode <> c_change_mode.

* Fülle Organisationstabelle mit Leerzeilen.
  PERFORM org_tab_init TABLES gt_orgtab_artstm
                       USING datab_slct  pi_datbi_list.

* Rücksetze Returncode für Datenbeschaffung.
  CLEAR: g_returncode.

* * B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
     AND gs_twpa-marc_chk IS NOT INITIAL.
    gi_filia_const = pi_filia_const.
  ENDIF.
* Besorge Stammdaten zum Artikel und fülle org.-tabelle.
* Im Änderungsfall werden auch die Tabellen PIT_LISTUNG und
* PIT_OT3_ARTSTM analysiert.
  PERFORM matdata_get_and_analyse
                      TABLES   gt_imara  gt_imarm  gt_imakt
                               gt_imamt
                               gt_orgtab_artstm
                               pit_listung
                               pit_ot3_artstm
                               gt_wlk2dat  gt_tvms    gt_t134
                               gt_wrf6
                      USING    pi_artnr    pi_vkorg   pi_vtweg
                               pi_vrkme    pi_filia_const
                               datab_slct  datbi_slct
                               pi_filia    pi_mode
                      CHANGING g_returncode
                               pi_dldnr    px_dldlfdnr
                               px_segment_counter
                               initdat     ean
                               pi_e1wpa02  pi_e1wpa03
                               pi_e1wpa04  pi_loeschen
                               no_price_send  pmata.

* Verlassen der Aufbereitung dieses Artikels, dieser
* Mengeneinheit, falls Einlesefehler aufgetreten sind.
  IF g_returncode <> 0.
    EXIT.
  ENDIF.                             " G_RETURNCODE <> 0.

* Falls Löschmodus aktiv, dann keine Konditionen erforderlich.
  IF pi_loeschen = space.
*   Nur wenn Konditionen oder Steuern übertragen werden sollen,
*   ist diesbezüglich eine Aufbereitung nötig.
    IF pi_e1wpa04 <> space OR pi_e1wpa07 <> space.
*     Besorge Konditionen und Steuern zum Artikel und
*     fülle Org.-Tabelle.
      PERFORM matcond_get_and_analyse
                          TABLES   gt_kond_art
                                   gt_staff_art
                                   gt_artsteu
                                   gt_orgtab_artstm
                                   t_date_for_count
                          USING    pi_filia_const
                                   pi_filia    pi_artnr
                                   pi_vrkme    datab_slct
                                   datbi_slct  pi_vkorg
                                   pi_vtweg    pi_mode
                          CHANGING g_returncode
                                   pi_dldnr    px_dldlfdnr
                                   px_segment_counter
                                   initdat     pi_e1wpa04
                                   pi_e1wpa05  no_price_send
                                   pmata.
    ENDIF. " pi_e1wpa04 <> space or pi_e1wpa07 <> space

*   Verlassen der Aufbereitung dieses Artikels, dieser
*   Mengeneinheit, falls Einlesefehler aufgetreten sind.
    IF g_returncode <> 0.
      EXIT.
    ENDIF.                             " G_RETURNCODE <> 0.

*   Nur wenn Naturalrabatte übertragen werden sollen,
*   ist diesbezüglich eine Aufbereitung nötig.
    IF pi_e1wpa09 <> space OR pi_e1wpa10 <> space.
*     Prüfe, ob dieses Material Naturalrabbatfähig ist. Besorge die
*     MARA-Daten.
      PERFORM mara_select
              USING  mara  pi_artnr.

*     Falls das Material Narualrabbatfähig ist.
      IF NOT mara-nrfhg IS INITIAL.
*       Besorge die Naturalrabatte zum Artikel und
*       fülle Org.-Tabelle.
        PERFORM mat_natrab_get_and_analyse
                            TABLES   gt_natrab_saco
                                     gt_kondn
                                     gt_kondns
                                     gt_natrab_ean
                                     gt_orgtab_artstm
                            USING    pi_filia_const
                                     pi_filia    pi_artnr
                                     pi_vrkme    datab_slct
                                     datbi_slct  pi_vkorg
                                     pi_vtweg    pi_mode
                                     initdat     no_price_send.

*     Falls das Material nicht Naturalrabbatfähig ist.
      ELSE. " mara-nrfhg is initial.
        REFRESH: gt_natrab_saco, gt_natrab_ean.
        CLEAR:   gt_natrab_saco, gt_natrab_ean.
      ENDIF. " not mara-nrfhg is initial.

    ENDIF. " pi_e1wpa09 <> space or pi_e1wpa10 <> space
  ENDIF. " pi_loeschen = space.
*{   INSERT         XB4K003246                                        1
* WRF_POSOUT
  PERFORM call_badi_orgtab_modify
            TABLES gt_orgtab_artstm
            USING  pi_artnr
                   pi_vkorg
                   pi_vtweg
                   pi_filia_const-mestype_plu.
* WRF_POSOUT
*}   INSERT

* Umsortieren der Organisationstabelle für spätere Datenaufbereitung.
  SORT gt_orgtab_artstm BY datum DESCENDING.

* Keine Analyse der Orgtab, falls Daten explizit gelöscht werden sollen.
  IF pi_loeschen <> space.
*   Erzeuge IDOC-Satz für Tag PI_DATUM_AB.
    PERFORM idoc_dataset_artstm_append
                       TABLES  gt_imara  gt_imarm  gt_imakt
                               gt_imamt
                               gt_wlk2dat
                               gt_orgtab_artstm
                               gt_kond_art
                               gt_staff_art
                               gt_artsteu
                               gt_tvms  gt_t134
                               gt_wrf6
                               t_date_for_count
                               gt_natrab_saco
                               gt_kondn
                               gt_kondns
                               gt_natrab_ean
                       USING   pxt_idoc_data
                               pi_datum_ab  px_segment_counter
                               pi_loeschen  pi_e1wpa02
                               pi_e1wpa03   pi_e1wpa04
                               pi_e1wpa05   pi_e1wpa07
                               pi_e1wpa09   pi_e1wpa10
                               pi_e1wpa11
                               pi_filia     g_returncode
                               pi_dldnr     px_dldlfdnr
                               pi_filia_const
                               ean  pi_mode  no_price_send
                               pi_aendtyp.

* Falls die Daten nicht explizit gelöscht werden sollen.
  ELSE.                                " PI_LOESCHEN = SPACE.
    vzeit_temp = pi_datbi_list - datab_slct.
    ADD 1 TO vzeit_temp.
    g_aktivdat = datab_slct - 1.
    CLEAR: g_n_arbtag.

*   Schleife über alle zu berücksichtigenden Tage der Vorlaufzeit.
    DO vzeit_temp TIMES.
      ADD 1 TO g_aktivdat.

*     Falls nötig, bestimme den nächsten Arbeitstag
      IF g_aktivdat > g_n_arbtag.
        PERFORM next_workday_get TABLES pit_workdays
                                 USING  g_aktivdat
                                        g_n_arbtag.
      ENDIF.                           " G_AKTIVDAT > G_N_ARBTAG.

*     Falls der gerade bearbeitete Tag ein Arbeitstag ist.
      IF g_aktivdat = g_n_arbtag.
*       Prüfe, ob der Artikel für diesen Tag gelistet ist und wenn ja,
*       ob dieser Tag der Beginn der Listung ist.
        PERFORM listing_check TABLES pit_listung
                              USING  pi_vrkme  g_aktivdat
                                     listung   pi_mode.

*       Falls der Artikel für diesen Tag gelistet ist.
        IF listung <> space.
*         Falls die Listung an diesem Tag neu beginnt.
          IF listung = c_begin.
            CLEAR: geaendert.
*           Erzeuge IDOC-Satz für diesen Tag.
            PERFORM idoc_dataset_artstm_append
                               TABLES  gt_imara  gt_imarm  gt_imakt
                                       gt_imamt
                                       gt_wlk2dat
                                       gt_orgtab_artstm
                                       gt_kond_art
                                       gt_staff_art
                                       gt_artsteu
                                       gt_tvms  gt_t134
                                       gt_wrf6
                                       t_date_for_count
                                       gt_natrab_saco
                                       gt_kondn
                                       gt_kondns
                                       gt_natrab_ean
                               USING   pxt_idoc_data
                                       g_aktivdat   px_segment_counter
                                       pi_loeschen  pi_e1wpa02
                                       pi_e1wpa03   pi_e1wpa04
                                       pi_e1wpa05   pi_e1wpa07
                                       pi_e1wpa09   pi_e1wpa10
                                       pi_e1wpa11
                                       pi_filia     g_returncode
                                       pi_dldnr     px_dldlfdnr
                                       pi_filia_const
                                       ean          pi_mode
                                       no_price_send
                                       pi_aendtyp.

*         Falls die Listung an diesem Tag nicht neu beginnt.
          ELSE.                        " LISTUNG = 'X'
*           Prüfe, ob der Artikel an diesem Tag verändert wurde.
            readindex = g_aktivdat - datab_slct.
            readindex = vzeit_temp - readindex.
            READ TABLE gt_orgtab_artstm INDEX readindex.

*           Falls der Artikel an diesem Tag verändert wurde.
            IF gt_orgtab_artstm-change <> space OR geaendert <> space.
              CLEAR: geaendert.
*             Erzeuge IDOC-Satz für diesen Tag.
              PERFORM idoc_dataset_artstm_append
                      TABLES  gt_imara  gt_imarm  gt_imakt
                              gt_imamt
                              gt_wlk2dat
                              gt_orgtab_artstm
                              gt_kond_art
                              gt_staff_art
                              gt_artsteu
                              gt_tvms  gt_t134
                              gt_wrf6
                              t_date_for_count
                              gt_natrab_saco
                              gt_kondn
                              gt_kondns
                              gt_natrab_ean
                      USING   pxt_idoc_data
                              g_aktivdat   px_segment_counter
                              pi_loeschen  pi_e1wpa02
                              pi_e1wpa03   pi_e1wpa04
                              pi_e1wpa05   pi_e1wpa07
                              pi_e1wpa09   pi_e1wpa10
                              pi_e1wpa11
                              pi_filia     g_returncode
                              pi_dldnr     px_dldlfdnr
                              pi_filia_const
                              ean  pi_mode  no_price_send
                              pi_aendtyp.

            ENDIF. " GT_ORGTAB_ARTSTM-CHANGE <> SPACE OR ...
          ENDIF.                       " LISTUNG = C_BEGIN.
        ENDIF.                         " LISTUNG <> SPACE.

*     Falls der gerade bearbeitete Tag KEIN Arbeitstag ist.
      ELSE.                            " G_AKTIVDAT <> G_N_ARBTAG.
*       Prüfe, ob der Artikel an diesem Tag verändert wurde.
        readindex = g_aktivdat - datab_slct.
        readindex = vzeit_temp - readindex.
        READ TABLE gt_orgtab_artstm INDEX readindex.

*       Der Artikel wurde an diesem Tag verändert.
        IF gt_orgtab_artstm-change <> space.
          geaendert = 'X'.
*       Der Artikel wurde an diesem Tag nicht verändert.
        ELSE. " gt_orgtab_artstm-change = space.
*         Falls Initialisierungsfall, direkte Anforderung oder Restart.
          IF pi_mode <> c_change_mode.
*           Prüfe, ob der Artikel für diesen Tag gelistet ist und
*           wenn ja, ob dieser Tag der Beginn der Listung ist.
            PERFORM listing_check TABLES pit_listung
                                  USING  pi_vrkme  g_aktivdat
                                         listung   pi_mode.

*           Falls der Artikel für diesen Tag gelistet ist und falls
*           die Listung an diesem Tag neu beginnt.
            IF listung = c_begin.
              geaendert = 'X'.
            ENDIF. " listung = c_begin.
          ENDIF. " pi_mode <> c_change_mode.
        ENDIF. " GT_ORGTAB_ARTSTM-CHANGE <> SPACE.
      ENDIF.                           " G_AKTIVDAT = G_N_ARBTAG.
    ENDDO.                             " VZEIT_TEMP TIMES.
  ENDIF.                               " PI_LOESCHEN <> SPACE.

** Mapper class for long material numbers
*  STATICS st_fnames TYPE cl_matnr_chk_mapper=>tt_matnr_idoc_fname.
*  DATA: lt_idoc_data   TYPE STANDARD TABLE OF edidd .
*  DATA: ls_edidd_short TYPE pos_short_edidd.
*  DATA: ls_idoc_data   TYPE edidd.
*
*
*  IF st_fnames IS INITIAL.
*    st_fnames = VALUE #( ( segname = 'E1WPA01' seg_fields = VALUE #( int = 'ARTIKELNR' long = 'ARTIKELNR_LONG' ) )
**                         ( segname = 'E1EDL37' seg_fields = VALUE #( int = 'VHILM' ext = 'VHILM_EXTERNAL' vers = 'VHILM_VERSION' guid = 'VHILM_GUID' long = 'VHILM_LONG' ) )
**                         ( segname = 'E1ADDI1' seg_fields = VALUE #( int = 'ADDIMATNR' ext = 'ADDIMATNR_EXTERNAL' vers = 'ADDIMATNR_VERSION' guid = 'ADDIMATNR_GUID' long = 'ADDIMATNR_LONG' ) )
*    ).
*
*  ENDIF.
*
*  LOOP AT pxt_idoc_data INTO ls_edidd_short.
*    ls_idoc_data-segnam = ls_edidd_short-segnam.
*    ls_idoc_data-sdata = ls_edidd_short-sdata.
*    APPEND ls_idoc_data TO lt_idoc_data.
*
*  ENDLOOP.
*
*  cl_matnr_chk_mapper=>idoc_tables_conv_tab(
*    EXPORTING
*      iv_int_to_external = abap_true
*      it_fnames          = st_fnames
*    CHANGING
*      ct_idoc_data       = lt_idoc_data[] ).
*
*  LOOP AT lt_idoc_data INTO ls_idoc_data.
*    ls_edidd_short-sdata = ls_idoc_data-sdata.
*    ls_edidd_short-segnam = ls_idoc_data-segnam.
*    MODIFY pxt_idoc_data from ls_edidd_short. "WHERE segnam = ls_idoc_segnam.
*  ENDLOOP.


* Aktualisiere Status-Positionszeile, falls Debug-Modus ein.
  IF pi_debug <> space.
*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-lfdnr  = px_dldlfdnr.
    gi_status_pos-stkey  = g_firstkey.
    gi_status_pos-ltkey  = i_key.
    gi_status_pos-anseg  = px_segment_counter.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  px_dldlfdnr
                                       g_returncode.

*   Schreibe DB-Änderungen fort.
    COMMIT WORK.
  ENDIF.                             " PI_DEBUG <> SPACE.

* check if IDoc must be created based on user
* specific setting
  IF px_segment_counter >= c_max_idoc_plu.
*   Erzeuge IDOC.
    PERFORM idoc_create USING  pxt_idoc_data
                               g_mestype_artstm
                               c_idoctype_artstm
                               px_segment_counter
                               g_err_counter
                               g_firstkey
                               i_key
                               pi_dldnr     px_dldlfdnr
                               pi_filia
                               pi_filia_const.

*   Merken, daß neue Positionszeile geschrieben werden muß.
    g_new_position = 'X'.
  ENDIF.


ENDFUNCTION.
