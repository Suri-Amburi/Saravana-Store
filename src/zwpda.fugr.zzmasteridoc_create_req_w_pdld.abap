FUNCTION ZZMASTERIDOC_CREATE_REQ_W_PDLD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_ART) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_DATUM_AB) LIKE  WPSTRUC-DATUM DEFAULT '00000000'
*"     VALUE(PI_DATUM_BIS) LIKE  WPSTRUC-DATUM DEFAULT '00000000'
*"     VALUE(PI_DEBUG) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_EAN) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_EXPRESS) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_LOESCHEN) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_MODE) LIKE  WPSTRUC-MODUS DEFAULT 'I'
*"     VALUE(PI_NART) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_PDAT) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_SETS) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_STEUERN) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_VKORG) LIKE  WPSTRUC-VKORG
*"     VALUE(PI_VTWEG) LIKE  WPSTRUC-VTWEG
*"     VALUE(PI_WKURS) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_WRG) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_BBUY) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_PROMO) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_NO_DIALOG) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_NO_BBY) LIKE  WPSTRUC-MODUS DEFAULT 'X'
*"  TABLES
*"      PIT_ARTIKEL STRUCTURE  WPART OPTIONAL
*"      PIT_LOCNR STRUCTURE  WDL_KUNNR OPTIONAL
*"      PIT_FILIA STRUCTURE  WPFILIA
*"      PIT_KUNNR STRUCTURE  WPPDOT3 OPTIONAL
*"      PIT_ART_EQUAL STRUCTURE  WPART OPTIONAL
*"      PIT_BBUY STRUCTURE  WPBOBUY OPTIONAL
*"      PIT_PROMO STRUCTURE  WPROMO OPTIONAL
*"  EXCEPTIONS
*"      DOWNLOAD_EXIT
*"--------------------------------------------------------------------
  DATA: partnr     LIKE edp13-rcvprn,
        partart    LIKE edp13-rcvprt,
        fehlercode LIKE wpstruc-counter.

* Nachrichtentypen zum Triggern des Konverters
  DATA: BEGIN OF t_msg_trigger OCCURS 8.
          INCLUDE STRUCTURE wpmsgtype.
  DATA: END OF t_msg_trigger.

* Pfadnamen zum Triggern des Konverters
  DATA: BEGIN OF t_pathname OCCURS 50.
          INCLUDE STRUCTURE edi_path.
  DATA: END OF t_pathname.

* Partnernummern und -arten zum Triggern des Konverters
  DATA: BEGIN OF t_partnr OCCURS 10.
          INCLUDE STRUCTURE edidc.
  DATA: END OF t_partnr.

* Dummy für das Schreiben von Fehlermeldungen
  DATA: BEGIN OF t_number OCCURS 1.
          INCLUDE STRUCTURE balnri.
  DATA: END OF t_number.

* Dummy für Aufruf des Warengruppendownload.
  DATA: BEGIN OF t_wrgp OCCURS 1.
          INCLUDE STRUCTURE wpmgot3.
  DATA: END OF t_wrgp.

  DATA lv_must_be_called          TYPE abap_bool.
  DATA lt_wlk2_save               TYPE TABLE OF wkwlk2.
  DATA lv_last_processed_index    TYPE sy-tabix.
  DATA lv_size_gt_wlk2            TYPE i.
  DATA lv_do_pref_mara            TYPE abap_bool.
  DATA lv_filia_loop_counter      TYPE i VALUE 0.
  DATA lv_filia_counter           TYPE i.
  DATA lth_contained_articles     TYPE tth_articles.
  DATA: lr_mode                   TYPE REF TO data.

  "*** START OF SALES PRICE MULTI OPTIMIZATION
  DATA: ls_filia_group TYPE wpfiliagrp.
  DATA: lt_idoc_data TYPE short_edidd.
  DATA: lv_e1wpa01 TYPE wpstruc-modus VALUE 'X'. " Flag if segment E1WPA01 needs to be sent
  DATA: lv_e1wpa02 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa03 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa04 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa05 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa07 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa08 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa09 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa10 TYPE wpstruc-modus VALUE 'X'.
  DATA: lv_e1wpa11 TYPE wpstruc-modus VALUE 'X'.
  "*** END OF SALES PRICE MULTI OPTIMIZATION

* Begin Hide Retail Functionality in S4CORE
*DATA: lv_is_s4h TYPE abap_bool.
*
*CALL METHOD CL_COS_UTILITIES=>IS_S4H
*  RECEIVING
*    RV_IS_S4H = lv_is_s4h.
*
*IF lv_is_s4h = abap_true.
*  message 'Feature not supported' type 'E'.
*ENDIF.
* End Hide Retail Functionality in S4CORE

* Update auf BBY_USED prüfen
  pe_no_bby = pi_no_bby.

  CLEAR: g_segment_counter.

* Übernehme Löschmerker in globale Variable.
  g_object_delete = pi_loeschen.

* Setze Zeitpunkt des Downloads.
  g_erstdat  = sy-datum.
  g_erstzeit = sy-uzeit.
* B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true.
* fill gs_twpa in order to check gs_twpa-marc_chk later.
    CALL FUNCTION 'TWPA_SINGLE_READ'
      IMPORTING
        wtwpa     = gs_twpa
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
  ENDIF.
* Setzen der Spaltenzahl für Textausgabe.
  NEW-PAGE LINE-SIZE 100.

  lv_filia_counter = lines( pit_filia ).

*--- do a prefetch for T001W and WRF1 but only if more than 1 stores
*--- are in the input parameter PIT_FILIA:
  IF lv_filia_counter > 1.
    PERFORM prefetch_plant_related_data TABLES pit_filia.
  ENDIF.

* Filialabhängige Verarbeitung
  LOOP AT pit_filia.

*--- increase store counter
    lv_filia_loop_counter = lv_filia_loop_counter + 1.

*   Sorge dafür, daß die internen Matialdatenpuffer neu
*   gefüllt werden.
    CLEAR: g_artnr_buf_artstm, g_artnr_buf_ean.

*   Rücksetze Statistiktabelle für spätere Textausgabe.
    CLEAR:   gt_wdlsp_buf.
    REFRESH: gt_wdlsp_buf.

*   Rücksetze EDIDC-Puffertabelle.
    CLEAR:   gt_edidc.
    REFRESH: gt_edidc.

*   Besorge filialabhängige Konst. wie, Sprachenschl., Kundennr., ect.
    PERFORM filia_const_get USING    pit_filia-filia
                                     g_dldnr
                                     gi_filia_const
                                     g_erstdat       g_erstzeit
                                     pi_mode
                            CHANGING g_returncode.

*   Falls Fehler auftraten, dann weiter mit nächster Filiale
    IF g_returncode <> 0.
      CONTINUE.
    ENDIF. " g_returncode <> 0.

    "****START OF SALES PRICE MULTI OPTIMIZATION***
    "Pass filia const data to check class for sales price multi optimization
    cl_sls_price_mult_access_check=>set_filia_const( is_filia_const =  gi_filia_const ).
    "****END OF SALES PRICE MULTI OPTIMIZATION***

*   Besorge Referenzvertriebsweg, falls möglich.
    IF cl_sls_price_mult_access_check=>is_sales_price_multi_active( ) = abap_true.
      CLEAR: tvkov.
      CALL FUNCTION 'TVKOV_SINGLE_READ'
        EXPORTING
          tvkov_vkorg = pi_vkorg
          tvkov_vtweg = pi_vtweg
        IMPORTING
          wtvkov      = tvkov
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.

*     Setze Referenzvertriebsweg, falls vorhanden.
      IF sy-subrc = 0.
        gv_vtweg = tvkov-vtwko.
      ELSE.
        gv_vtweg = pi_vtweg.
      ENDIF. " sy-subrc = 0.
    ENDIF.

    IF gs_twpa-marc_chk IS NOT INITIAL.  " Note 1982796
      CLEAR gt_wlk2.
      REFRESH gt_wlk2.
    ENDIF.
*   Falls sämtliche filialabhängigen Preise in Tabelle A071
*   gespeichert sind und es auch nur wenige davon gibt, dann
*   bestimme alle Artikel die einen filialabhängigen Preis haben.
    IF NOT gi_filia_const-prices_in_a071 IS INITIAL.
*     Prüfe, ob bereits Einträge im Puffer existieren.
      READ TABLE gt_a071_matnr INDEX 1.

*     Falls noch keine Einträge im Puffer existieren, dann fülle
*     Puffer.
      IF sy-subrc <> 0.
        SELECT matnr FROM a071
               INTO  TABLE gt_a071_matnr
               FOR ALL ENTRIES IN pit_filia
               WHERE kappl = c_cond_appl
               AND   vkorg = pi_vkorg
               AND   vtweg = pi_vtweg
               AND   werks = pit_filia-filia.

*       Daten sortieren.
        SORT gt_a071_matnr.

*       Lösche doppelte Einträge.
        DELETE ADJACENT DUPLICATES FROM gt_a071_matnr
               COMPARING ALL FIELDS.
      ENDIF. " sy-subrc <> 0.
    ELSE. " gi_filia_const-prices_in_a071 is initial.
      REFRESH: gt_a071_matnr.
      CLEAR:   gt_a071_matnr.
    ENDIF. " not gi_filia_const-prices_in_a071 is initial.

*   Falls Daten an die Filiale verschickt werden sollen.
    IF gi_filia_const-posdex <> space.
*     Falls eine Listausgabe erfolgen soll.
      IF pi_no_dialog IS INITIAL.
*       Ausgabe zusätzlicher Anwenderinfo.
        FORMAT COLOR COL_GROUP.
        WRITE: /  'Empfänger:'(007),
                  gi_filia_const-kunnr .
        FORMAT COLOR OFF.

*       Merken aller nicht-versende-Flags.
        MOVE-CORRESPONDING gi_filia_const TO gi_object_not_process.

*       Falls laut Kommunikationsprofil überhaupt keine Objekte
*       aufbereitet werden sollen.
        IF gi_object_not_process = c_no_object_process AND
           pi_bbuy IS INITIAL.                           " note 1340867
          WRITE: /6 'Laut Kommunikationsprofil wurden alle Objekte'(039)
                     COLOR COL_NEGATIVE.
          WRITE: /6  'von der Aufbereitung ausgeschlossen'(040)
                     COLOR COL_NEGATIVE.
          SKIP.
          FORMAT COLOR OFF.

*         Aufbereitung der nächsten Filiale.
          CONTINUE.
        ENDIF. " gi_object_not_process = c_no_object_process.
      ENDIF. " pi_no_dialog is initial.

*     Aufbereiten der Parameter zum schreiben der Status-Kopfzeile.
      CLEAR: gi_status_header, g_err_counter.
      gi_status_header-empfn = gi_filia_const-kunnr.
      gi_status_header-systp = c_pos_systemtyp.
      gi_status_header-ersab = g_erstdat.
      gi_status_header-ersbi = g_erstdat.
      gi_status_header-erzab = g_erstzeit.
      gi_status_header-erzbi = g_erstzeit.
      gi_status_header-dlmod = pi_mode.
      gi_status_header-gesst = c_status_init.

*     Schreibe Status-Kopfzeile.
      PERFORM status_write_head USING  ' '  gi_status_header  g_dldnr
                                            g_returncode.

*     Vorbesetzen des Aufbereitungsstatus.
      g_status = 0.

*     Bestimme alle nicht benötigten Segmente.
      MOVE-CORRESPONDING gi_filia_const TO gt_filia_group.
      PERFORM idoc_filter TABLES gt_filter_segs
                          USING  gt_filia_group.

*     Rücksetze IDOC-Zähler.
      CLEAR: g_idoc_counter.

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Warengruppen.
      IF pi_mode = c_init_mode OR pi_wrg <> space.
*       Falls Warengruppen aufbereitet werden sollen.
        IF gi_filia_const-npmec IS INITIAL.
*         Download Warengruppen.
          PERFORM wrgp_download TABLES gt_filter_segs
                                       t_wrgp                " Dummy
                                USING  pit_filia-filia
                                       gi_filia_const
                                       pi_loeschen    pi_datum_ab
                                       pi_vkorg       pi_vtweg
                                       pi_express     pi_debug
                                       pi_mode.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-npmec is initial.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_WRG <> SPACE.

      MOVE 0 TO lv_last_processed_index.

*--- determine time range and work days table:
      PERFORM time_range_get USING pi_datum_ab   pi_datum_bis
                                   gi_filia_const-vzeit
                                   gi_filia_const-fabkl
                                   g_datab       g_datbis  g_erstdat.

      PERFORM workdays_get TABLES gt_workdays
                           USING  g_datab  g_datbis
                                  gi_filia_const-fabkl.

*--- store that the determination is done:
      MOVE abap_true TO gv_time_rg_wrkdays_get_flag.

      IF gi_filia_const-npmat IS INITIAL.
        PERFORM check_call_listed_articles_get TABLES pit_artikel
                                               USING pi_mode
                                                     pi_art
                                                     pi_ean
                                               CHANGING lv_must_be_called.

        IF lv_must_be_called = abap_true.
*---    determine all articles which are assigned to store pit_filia-filia
*---    within the given time period.
*---    set "PIV_MODE" at first because this field is needed within
*---    sub routine GET_PACKAGE_SIZE and this routine is called
*---    in "listed_articles_get_2":
          TRY.
              GET REFERENCE OF pi_mode INTO lr_mode.
              cl_wrt_form_parameter=>get_instance( iv_initialize = abap_true )->add( iv_name = 'PIV_MODE'
                                                                                     i_data  = lr_mode ).
            CATCH cx_wrt_form_parameter_error  ##no_handler.
          ENDTRY.
          PERFORM listed_articles_get_2 TABLES gt_wlk2
                                        USING  pi_vkorg  pi_vtweg
                                               pit_filia-filia  g_datab
                                               g_datbis.
          cl_wrt_form_parameter=>get_instance( )->refresh( ).

          MOVE gt_wlk2[] TO lt_wlk2_save.
          lv_size_gt_wlk2 = lines( gt_wlk2[] ).

          IF lv_size_gt_wlk2 = 0.
            MOVE abap_true TO gv_no_articles_found.
          ENDIF.

*---     switch off buffer refresh for MARA and MARC
          IF pi_mode = c_init_mode.
*--- switch off only in case of initialization:
            gv_mara_buffer_refresh = abap_false.
            gv_marc_buffer_refresh = abap_false.
          ENDIF.
        ENDIF.

*-- Now, the packaging of the articles begins:
        WHILE lv_last_processed_index < lv_size_gt_wlk2 OR
              lv_last_processed_index = 0.

          IF lv_must_be_called = abap_true.
            IF pi_mode = c_init_mode OR ( pi_mode = 'A' AND pit_artikel[] IS INITIAL ).
*--- the following subroutine may only be called in initial-mode because
*--- the prefetches are basing on GT_WLK2.
*---    set "PIV_MODE" at first because this field is needed within
*---    sub routine GET_PACKAGE_SIZE and this routine is called
*---    in "get_article_pckg_for_download":
              TRY.
                  GET REFERENCE OF pi_mode INTO lr_mode.
                  cl_wrt_form_parameter=>get_instance( iv_initialize = abap_true )->add( iv_name = 'PIV_MODE'
                                                                                         i_data  = lr_mode ).
                CATCH cx_wrt_form_parameter_error  ##no_handler.
              ENDTRY.
              PERFORM get_article_pckg_for_download TABLES   lt_wlk2_save
                                                             gt_wlk2
                                                    USING    lv_filia_counter
                                                             lv_filia_loop_counter
                                                             lv_size_gt_wlk2
                                                             pit_filia-filia
                                                    CHANGING lv_last_processed_index
                                                             lth_contained_articles.
              cl_wrt_form_parameter=>get_instance( )->refresh( ).
            ELSE.
*--- the function module was not called for initial download. Because no packaging
*--- is done, the size of GT_WLK2 must be transferred to lv_last_processed_index to
*--- avoid an possible endless loop:
              MOVE lv_size_gt_wlk2 TO lv_last_processed_index.
            ENDIF.

            IF lv_last_processed_index = 0.
*--- security code to leave the loop if no articles are listed in the store or
*--- the articles are provided in PIT_ARTIKEL explicitly:
              lv_last_processed_index = 1.
            ENDIF.

          ELSE.
*--- the loop shall only be processed one time if articles are provided via importing
*--- parameter PIT_ARTIKEL (in accordance with the old behavior before the optimization):
            MOVE 1 TO lv_last_processed_index.
          ENDIF.

*--- in case of initialization or direct request for article master data:
          IF pi_mode = c_init_mode OR pi_art <> space.

            "****START OF SALES PRICE MULTI OPTIMIZATION***
            "reset all condition buffers
            IF cl_sls_price_mult_access_check=>is_sales_price_multi_active( ) = abap_true.
              CALL FUNCTION 'SALES_CONDITIONS_PREREAD'
                EXPORTING
                  iv_incfi            = 'X'
                  iv_datbi            = sy-datum
                  iv_matnr            = 'ABCD'
                  iv_werks            = 'ABCD'
                  iv_reset            = abap_true
                  iv_exit_after_reset = abap_true.
            ENDIF.
            "****END OF SALES PRICE MULTI OPTIMIZATION***

*         Download Artikelstamm.
            PERFORM artstm_download TABLES gt_filter_segs
                                           pit_artikel
                                           pit_art_equal
                                    USING  pit_filia-filia
                                           gi_filia_const   pi_express
                                           pi_loeschen      pi_mode
                                           pi_datum_ab      pi_datum_bis
                                           pi_vkorg         pi_vtweg
                                           pi_art           pi_debug.

            "*** START OF SALES PRICE MULTI OPTIMIZATION
            IF cl_sls_price_mult_access_check=>is_sales_price_multi_active( ) = abap_true.
              "fill filia group structure (needed in ART_IDOC_DATA_CRT_MULTI_COND)
              ls_filia_group-vkorg = pi_vkorg.
              ls_filia_group-vtweg = pi_vtweg.
              ls_filia_group-filia = pit_filia.
              ls_filia_group-datab = g_datab.

              "Check which article segments must be sent
              LOOP AT gt_filter_segs.

                CASE gt_filter_segs-segtyp.
                  WHEN c_e1wpa01_name.
                    CLEAR: lv_e1wpa01.
                  WHEN c_e1wpa02_name.
                    CLEAR: lv_e1wpa02.
                  WHEN c_e1wpa03_name.
                    CLEAR: lv_e1wpa03.
                  WHEN c_e1wpa04_name.
                    CLEAR: lv_e1wpa04.
                  WHEN c_e1wpa05_name.
                    CLEAR: lv_e1wpa05.
                  WHEN c_e1wpa07_name.
                    CLEAR: lv_e1wpa07.
                  WHEN c_e1wpa08_name.
                    CLEAR: lv_e1wpa08.
                  WHEN c_e1wpa09_name.
                    CLEAR: lv_e1wpa09.
                  WHEN c_e1wpa10_name.
                    CLEAR: lv_e1wpa10.
                  WHEN c_e1wpa11_name.
                    CLEAR: lv_e1wpa11.
                ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

              ENDLOOP.                             " PIT_FILTER_SEGS

              CALL FUNCTION 'ART_IDOC_DATA_CRT_MULTI_COND_I'
                EXPORTING
                  it_ot3_artstm   = gt_ot3_artstm_collect
                  iv_vkorg        = pi_vkorg
                  iv_vtweg        = gv_vtweg
                  iv_werks        = pit_filia-filia
                  iv_dldnr        = g_dldnr
                  iv_datab        = g_datab
                  iv_datbi        = g_datbis
                  iv_mode         = pi_mode
                  iv_e1wpa02      = lv_e1wpa02
                  iv_e1wpa03      = lv_e1wpa03
                  iv_e1wpa04      = lv_e1wpa04
                  iv_e1wpa05      = lv_e1wpa05
                  iv_e1wpa07      = lv_e1wpa07
                  iv_e1wpa08      = lv_e1wpa08
                  iv_e1wpa09      = lv_e1wpa09
                  iv_e1wpa10      = lv_e1wpa10
                  iv_e1wpa11      = lv_e1wpa11
                  is_filia_const  = gi_filia_const
                  it_listing      = gt_list_cond_collect
                CHANGING
                  ct_idoc_data    = lt_idoc_data
                EXCEPTIONS
                  no_prices_found = 1
                  OTHERS          = 2.

              IF sy-subrc <> 0.
                "we have no other choice than try to continue with the next package (or store)...
                CONTINUE.
              ENDIF.

              " clear the global tables for the next package or store
              CLEAR: gt_ot3_artstm_collect.
              CLEAR: gt_list_cond_collect.
            ENDIF.
            "*** END OF SALES PRICE MULTI OPTIMIZATION

*---  do write of DB-changes.
            COMMIT WORK.
          ENDIF. " PI_MODE = C_INIT_MODE OR PI_ART <> SPACE.

*--- in case of initialization or direct request for ean references:
          IF pi_mode = c_init_mode OR pi_ean <> space.
*         Download EAN-Referenzen.
            PERFORM ean_download TABLES gt_filter_segs
                                        pit_artikel
                                        pit_art_equal
                                 USING  gi_filia_const
                                        pi_vkorg         pi_vtweg
                                        pit_filia-filia  pi_express
                                        pi_loeschen      pi_mode
                                        pi_datum_ab      pi_datum_bis
                                        pi_ean           pi_debug.

*---  do write of DB-changes.
            COMMIT WORK.
          ENDIF. " PI_MODE = C_INIT_MODE OR PI_EAN <> SPACE.

        ENDWHILE.
*--- end of articles packaging

      ENDIF.

*     switch on buffer refresh for MARA and MARC again
      gv_mara_buffer_refresh = abap_true.
      gv_marc_buffer_refresh = abap_true.
*     switch off flag to control read of time range and workdays:
      gv_time_rg_wrkdays_get_flag = abap_false.

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Set-Zuordnungen.
      IF pi_mode = c_init_mode OR pi_sets <> space.
*       Falls Set-Zuordnungen aufbereitet werden sollen.
        IF gi_filia_const-npset IS INITIAL.
*         Download Set-Zuordnungen.
          PERFORM sets_download TABLES gt_filter_segs
                                       pit_artikel
                                       pit_art_equal
                                USING  gi_filia_const
                                       pi_vkorg         pi_vtweg
                                       pit_filia-filia  pi_express
                                       pi_loeschen      pi_mode
                                       pi_datum_ab      pi_datum_bis
                                       pi_sets          pi_debug.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-npset is initial.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_SETS <> SPACE.

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Nachzugsartikel.
      IF pi_mode = c_init_mode OR pi_nart <> space.
*       Falls Nachzugsartikel aufbereitet werden sollen.
        IF gi_filia_const-npfoa IS INITIAL.
*         Download Nachzugsartikel.
          PERFORM nart_download TABLES gt_filter_segs
                                       pit_artikel
                                       pit_art_equal
                                USING  gi_filia_const
                                       pi_vkorg         pi_vtweg
                                       pit_filia-filia  pi_express
                                       pi_loeschen      pi_mode
                                       pi_datum_ab      pi_datum_bis
                                       pi_nart          pi_debug.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-npfoa is initial.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_NART <> SPACE.

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Wechselkurse.
      IF pi_mode = c_init_mode OR pi_wkurs <> space.
*       Falls Wechselkurse aufbereitet werden sollen.
        IF gi_filia_const-npcur IS INITIAL.
*         Download Wechselkurse.
          PERFORM wkurs_download TABLES gt_filter_segs
                                 USING  pit_filia-filia  pi_express
                                        pi_loeschen      pi_mode
                                        pi_datum_ab      pi_datum_bis
                                        pi_vkorg         pi_vtweg
                                        gi_filia_const
                                        g_dldnr          g_erstdat.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-npcur is initial.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_WKURS <> SPACE.

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Steuern.
      IF pi_mode = c_init_mode OR pi_steuern <> space.
*       Falls Steuern aufbereitet werden sollen.
        IF gi_filia_const-nptax IS INITIAL.
*         Download Steuern.
          PERFORM steuern_download TABLES gt_filter_segs
                                   USING  pit_filia-filia  pi_express
                                          pi_loeschen      pi_mode
                                          pi_datum_ab
                                          gi_filia_const
                                          g_dldnr          g_erstdat.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-nptax is initial.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_STEUERN <> SPACE.

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Personendaten.
      IF pi_mode = c_init_mode OR pi_pdat <> space.
*       Falls Personendaten aufbereitet werden sollen.
        IF gi_filia_const-npcus IS INITIAL.
*         Download Personendaten.
          PERFORM pers_download TABLES gt_filter_segs
                                       pit_kunnr
                                USING  gi_filia_const
                                       pit_filia-filia  pi_express
                                       pi_loeschen      pi_mode
                                       pi_datum_ab      pi_debug
                                       pi_pdat          pi_vkorg
                                       pi_vtweg.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-npcus is initial.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_PDAT <> SPACE.

*     Erweiterung Bonus-Käufe (Release 99A, GL)

*     Falls Initialisierungsfall oder direkte Anforderung
*     für Bonus-Käufe
      IF pi_bbuy <> space.
        CALL FUNCTION 'BONUSBUY_DOWNLOAD'
          EXPORTING
            pi_filia_const  = gi_filia_const
            pi_filia        = pit_filia-filia
            pi_mode         = pi_mode
            pi_loeschen     = pi_loeschen
            pi_datum_ab     = pi_datum_ab
            pi_debug        = pi_debug
            pi_bby          = pi_bbuy
            pi_vkorg        = pi_vkorg
            pi_vtweg        = pi_vtweg
            pi_mestype_bby  = g_mestype_bby
            pi_no_bby       = pe_no_bby
          TABLES
            pit_filter_segs = gt_filter_segs
            pit_bby         = pit_bbuy
            pit_wdlsp_buf   = gt_wdlsp_buf
          CHANGING
            pix_dldnr       = g_dldnr
            pix_dldlfdnr    = g_dldlfdnr.

*       Schreibe Datenbankänderungen fort
        COMMIT WORK.
      ENDIF. " PI_DAT <> SPACE.
* ***

*   Erweiterung Aktionsrabatte, rz 22.05.00
*     Falls Initialisierungsfall oder direkte Anforderung
*     für Aktionsrabatte.
      IF pi_mode = c_init_mode OR pi_promo <> space.
*       Falls Aktionsrabatte aufbereitet werden sollen.
        IF gi_filia_const-promo_rebate = 'X'.
*         Download Aktionsrabatte.
          PERFORM promreb_download TABLES pit_promo
                                   USING  gi_filia_const
                                          pit_filia-filia
                                          pi_promo
                                          pi_debug
                                          pi_express
                                          pi_loeschen
                                          pi_mode
                                          pi_vkorg
                                          pi_vtweg
                                          pi_datum_ab
                                          pi_datum_bis.

*         Schreibe DB-Änderungen fort.
          COMMIT WORK.
        ENDIF. " gi_filia_const-promo_rebate = 'X'.
      ENDIF. " PI_MODE = C_INIT_MODE OR PI_PROMO <> SPACE.

*     Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*     auf OK.
      IF g_status = 0 AND gi_status_header-gesst = c_status_init.
*       Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
        CLEAR: gi_status_header.
        gi_status_header-dldnr = g_dldnr.
        gi_status_header-gesst = c_status_ok.

*       Schreibe Status-Kopfzeile.
        PERFORM status_write_head USING  'X'  gi_status_header  g_dldnr
                                              g_returncode.
      ENDIF.                             " G_STATUS = 0.

*     Falls eine Listausgabe erfolgen soll.
      IF pi_no_dialog IS INITIAL.
*       Textausgabe der Liste der erzeugten IDOC's.
        PERFORM statistic_text_generate_idoc
                TABLES gt_wdlsp_buf.
      ENDIF. " pi_no_dialog is initial.

*     Setze Kennzeichen in WDLS zur Weitergabe ans SCS.
      SELECT SINGLE * FROM wdls
             WHERE dldnr = g_dldnr.
      wdls-vsest = c_datenuebergabe_ok.

*     Falls bei der Aufbereitung Warnungen aufgetreten sind.
      IF wdls-gesst = c_status_fehlende_daten.
*       Falls Warnungen als Hinweise deklariert werden sollen.
        IF NOT gi_filia_const-no_warnings IS INITIAL.
*         Setze Gesamtstatus auf 'Hinweis'.
          wdls-gesst = c_status_benutzerhinweis.
        ENDIF. " not gi_filia_const-no_warnings is initial.
      ENDIF. " wdls-gesst = c_status_fehlende_daten.

      UPDATE wdls.
      COMMIT WORK.

*     Besorge Paramter zum setzen des Triggers für Konverter.
      CALL FUNCTION 'POS_STORE_IDOC_FILENAMES_GET'
        EXPORTING
          pi_dldnr      = g_dldnr
          pi_no_trigger = gi_filia_const-no_trigger
        IMPORTING
          pe_fehlercode = fehlercode
          pe_wdls       = wdls
        TABLES
          pet_pathname  = t_pathname
          pet_msgtype   = t_msg_trigger
          pet_partnr    = t_partnr
          pit_edidc     = gt_edidc.

*     Falls eine Listausgabe erfolgen soll.
      IF pi_no_dialog IS INITIAL.
*       Falls kein Triggerfile erzeugt werden soll.
        IF NOT gi_filia_const-no_trigger IS INITIAL.
*         Textausgabe für Bildschirm.
          SKIP.
          WRITE: /6  'Triggerfile für Status-ID:'(001),
                     g_dldnr COLOR COL_NORMAL.

*         Falls über das Verteilungsmodell verteilt werden soll.
          IF NOT gi_filia_const-recdt IS INITIAL.
            WRITE:     'wurde nicht erzeugt, da Verteilung'(066),
                   /48 'über Verteilungsmodell erfolgt.'(067).
*         Falls nicht über das Verteilungsmodell verteilt werden soll.
          ELSE.
            WRITE:     'wurde entsprechend POS-Ausgangsprofil'(080),
                   /48 'nicht erzeugt'(081).
          ENDIF. " not gi_filia_const-recdt is initial.
          ULINE.
          CONTINUE.

        ENDIF. " not gi_filia_const-no_trigger is initial.
      ENDIF. " pi_no_dialog is initial.

*     Falls keine Fehler aufgetreten sind.
      IF fehlercode = 0.
*       Schreibe Triggerfiles für Konverter.
        CALL FUNCTION 'POS_DOWNLOAD_TRIGGER_PUT'
          EXPORTING
            pi_kunnr      = wdls-empfn
            pi_dldnr      = g_dldnr
          IMPORTING
            pe_fehlercode = fehlercode
          TABLES
            pit_msgtype   = t_msg_trigger
            pit_pathname  = t_pathname
            pit_partnr    = t_partnr.
      ENDIF. " fehlercode = 0.

*     Falls eine Listausgabe erfolgen soll.
      IF pi_no_dialog IS INITIAL.
*       Textausgabe für Bildschirm.
        SKIP.
        WRITE: /6 'Triggerfile für Status-ID:'(001),
                  g_dldnr COLOR COL_NORMAL.

        CASE fehlercode.
*         Falls keine Fehler aufgetreten sind.
          WHEN 0.
            WRITE:  'erzeugt.'(003).
*         Falls Fehler aufgetreten sind, zu denen es keine
*         Statusprotokolle gibt und die daher separat protokolliert
*         wurden.
          WHEN 1.
            WRITE: /6 'brauchte nicht erzeugt zu werden.'(004)
                       COLOR COL_NEGATIVE,
                      'Keine Nachrichten erforderlich.'(045)
                       COLOR COL_NEGATIVE.
            FORMAT COLOR OFF.
*         Falls Fehler aufgetreten sind, zu denen es
*         Statusprotokolle gibt.
          WHEN 2.
            WRITE: /6 'konnte nicht erzeugt werden'(005)
                       COLOR COL_NEGATIVE,
                      '(--> POS-Ausgangs-Protokoll).'(006)
                       COLOR COL_NEGATIVE.
            FORMAT COLOR OFF.
        ENDCASE. " fehlercode.

        ULINE.
      ENDIF. " pi_no_dialog is initial.
    ENDIF.   " gi_filia_const-posdex <> space.
  ENDLOOP.                             " AT PIT_FILIA.

* Schreibe Fehlermeldungen auf Datenbank, falls nötig.
  IF g_init_log_dld <> space.
    CALL FUNCTION 'APPL_LOG_WRITE_DB'
      EXPORTING
        object                = c_applikation
        subobject             = c_download
      TABLES
        object_with_lognumber = t_number
      EXCEPTIONS
        object_not_found      = 01
        subobject_not_found   = 02.

*     Rücksetze Merker für allgemeines Fehlerprotokoll.
    CLEAR: g_init_log_dld.
  ENDIF. " g_init_log_dld <> space.

ENDFUNCTION.
