FUNCTION ZZLISTING_CHECK.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_ARTICLE) LIKE  MARA-MATNR
*"     VALUE(PI_DATAB) LIKE  WLK1-DATAB DEFAULT '00000000'
*"     VALUE(PI_DATBI) LIKE  WLK1-DATBI DEFAULT '00000000'
*"     VALUE(PI_FILIA) LIKE  T001W-WERKS DEFAULT SPACE
*"     VALUE(PI_IGNORE_EXCL) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_VRKME) LIKE  WPWLK1-VRKME DEFAULT SPACE
*"     VALUE(PI_NO_EAN_CHECK) LIKE  WTDY-TYP01 OPTIONAL
*"     VALUE(PI_WLK1_READ) LIKE  WTDY-TYP01 DEFAULT SPACE
*"     VALUE(PI_VKORG) LIKE  T001W-VKORG DEFAULT SPACE
*"     VALUE(PI_VTWEG) LIKE  T001W-VTWEG DEFAULT SPACE
*"     VALUE(PI_LOCNR) LIKE  WRF1-LOCNR DEFAULT SPACE
*"     VALUE(BUFFER_WLK2_FILIA_ENTRIES) LIKE  MTCOM-KZRFB
*"         DEFAULT SPACE
*"     REFERENCE(PI_ONLY_LIST_CHECK) TYPE  CHAR1 OPTIONAL
*"     VALUE(PI_MODE) TYPE  CHAR1 DEFAULT SPACE
*"  TABLES
*"      PET_LIST_KOND STRUCTURE  WPWLK1 OPTIONAL
*"      PET_BEW_KOND STRUCTURE  WPWLK1 OPTIONAL
*"      PIT_VRKME STRUCTURE  MARM OPTIONAL
*"  EXCEPTIONS
*"      KOND_NOT_FOUND
*"      VRKME_NOT_FOUND
*"      VKDAT_NOT_FOUND
*"      ASS_OWNER_NOT_FOUND
*"--------------------------------------------------------------------
*
*  comment:
*  this function were replaced completely in release retail HPR
*


* Tabelle zum Speichern der geführten VRKME eines Artikels
  DATA: BEGIN OF t_vrkme OCCURS 0,
          vrkme LIKE marm-meinh,
          material_listing(1).
  DATA: END OF t_vrkme.


  DATA akt_vrkme LIKE wlk1-vrkme.
  DATA: tmp_bew_kond TYPE wpwlk2.

* Dabei wird grundsätzlich unterschieden, ob nur die gültigen Sätze
* nach oben gereicht werden sollen, oder ob das keine Rolle spielt
* (PI_IGNORE_EXCL = X).

  DATA z1 LIKE sy-tabix.               " Anzahl der Tabellen-Einträge

  DATA:   ht_marm LIKE marm OCCURS 0 WITH HEADER LINE.
  DATA:   ht_wlk1 TYPE wlk1 OCCURS 0
        , h_wlk1 TYPE wlk1
        , h_vlfkz LIKE t001w-vlfkz
        .


  CLEAR pet_list_kond.
  REFRESH pet_list_kond.
  CLEAR pet_list_kond_neg.
  REFRESH pet_list_kond_neg.

  CLEAR tmp_bew_kond.
  CLEAR pet_bew_kond.
  REFRESH pet_bew_kond.


************************************************************************
* read all material_units
  PERFORM read_all_marm_entries TABLES t_vrkme
                                 USING pi_article
                                       pi_no_ean_check
                                       pi_vrkme
                                       sy-subrc.
  IF sy-subrc <> 0.
    IF PI_ONLY_LIST_CHECK <> 'X'.
    " do NOT raise if only listing_check is wished
      RAISE vrkme_not_found.
    ENDIF.
  ENDIF.


************************************************************************
* read all key informations
  PERFORM read_all_key_data CHANGING pi_vkorg
                                     pi_vtweg
                                     pi_locnr
                                     h_vlfkz
                                     pi_filia.


************************************************************************
* read wlk2 data
  PERFORM read_wlk2_entry USING    pi_article
                                   pi_vkorg
                                   pi_vtweg
                                   pi_filia
                                   pi_datab
                                   pi_datbi
                                   buffer_wlk2_filia_entries
                          CHANGING tmp_bew_kond
                                   sy-subrc.
  IF  sy-subrc <> 0
  AND pi_wlk1_read IS INITIAL.
    IF PI_ONLY_LIST_CHECK <> 'X'.
    " do NOT raise if only listing_check is wished
      RAISE vkdat_not_found.
    ENDIF.
  ENDIF.


************************************************************************
* read listing conditions
  PERFORM read_listing_conditions TABLES   ht_wlk1
                                  USING    pi_article
                                           pi_locnr
                                           h_vlfkz
                                           pi_datab
                                           pi_datbi
                                  CHANGING sy-subrc.

************************************************************************
* analysis of  wlk1 results

  CASE pi_ignore_excl.
    WHEN x.
      LOOP AT t_vrkme.
        LOOP AT ht_wlk1 INTO h_wlk1.
          MOVE-CORRESPONDING h_wlk1 TO pet_list_kond.
          pet_list_kond-vrkme = t_vrkme-vrkme.
          pet_list_kond-arthier = a.
          t_vrkme-material_listing = x.                    "Note 779181
          modify t_vrkme.                                  "Note 779181
          APPEND pet_list_kond.
          IF pi_mode = 'P'. "ins note 740896
          "'P':call by POS -> One arbitrary entry of wlk1 is sufficient!
            exit.
          endif.
        ENDLOOP.
      ENDLOOP.

*-----------------------------------------------------------------------
    WHEN OTHERS.       " es werden nur gültige Sätze hochgereicht
*-----------------------------------------------------------------------

      LOOP AT ht_wlk1 INTO h_wlk1.
        IF h_wlk1-negat = x.
          DELETE ht_wlk1 INDEX sy-tabix.
          IF h_wlk1-datbi > pi_datab.
* Sammeln der Exclusionssätze in PET_LIST_KOND_NEG
            MOVE-CORRESPONDING h_wlk1 TO pet_list_kond_neg.
            APPEND pet_list_kond_neg.
          ENDIF.
        ENDIF.
      ENDLOOP.                                              "HT_WLK1

      DESCRIBE TABLE pet_list_kond_neg LINES z1.

      IF z1 = 0.
************************************************************************
* es gibt keine Exclusion -> lese alle gültigen Sätze
************************************************************************
        LOOP AT t_vrkme.
          LOOP AT ht_wlk1 INTO h_wlk1.

*            if h_wlk1-sstat = '5'.
*              exit.
*            else.

*             fill valid entries to table PET_LIST_KOND
            MOVE-CORRESPONDING h_wlk1 TO pet_list_kond.
            pet_list_kond-vrkme = t_vrkme-vrkme.
            pet_list_kond-arthier = a.

            t_vrkme-material_listing = x.
            IF pet_list_kond-datbi >= pet_list_kond-datab AND
               pi_datab <= pet_list_kond-datbi AND
               pi_datbi >= pet_list_kond-datab.

              APPEND pet_list_kond.
            ENDIF.
*          endif.                       " T_wlke_input-sstat      " 4.6C
          ENDLOOP.                                          " HT_WLK1

          IF t_vrkme-material_listing = x.
            MODIFY t_vrkme.
          ENDIF.
        ENDLOOP.                       " T_vrkme.


      ELSE.
************************************************************************
* dann ist erhöhte Vorsicht geboten!
* man muß prüfen ob gültigen WLK1-Sätze nicht durch excludierende
* Sätze ungültig werden
* -> Vorsicht mit Zeitintervall; ggf. müssen manche WLK1-Sätze
* aufgeteilt werden.
************************************************************************
        SORT pet_list_kond_neg ASCENDING BY datab.

        LOOP AT t_vrkme.
          LOOP AT ht_wlk1 INTO h_wlk1.

*            if t_wlk1_input-sstat = '5'. " 4.6C
*              exit.                    " 4.6C
*            else.                      " 4.6C

            MOVE-CORRESPONDING h_wlk1 TO pet_list_kond.
            pet_list_kond-vrkme = t_vrkme-vrkme.
            pet_list_kond-arthier = a.

            IF h_wlk1-datbi < pi_datab.
              " Satz war früher gelistet              .
              " => wlk2-satz muß zurückgeliefert werden
                t_vrkme-material_listing = x.
            ELSE.
              LOOP AT pet_list_kond_neg
                    WHERE datab <= h_wlk1-datbi AND
                          datbi >= h_wlk1-datab.

                IF h_wlk1-datab >= pet_list_kond_neg-datab
                  AND h_wlk1-datbi <= pet_list_kond_neg-datbi.
* WLK1-Eintrag ist komplett ungültig ->
* PET_LIST_KOND - Eintrag mit DATAB > DATBI (unschön, wird aber später
* wieder gelöscht)
                  pet_list_kond-datbi = pet_list_kond_neg-datbi - 1.
                  pet_list_kond-datab = pet_list_kond_neg-datbi.
                  EXIT.
                ELSEIF h_wlk1-datab < pet_list_kond_neg-datab
                  AND h_wlk1-datbi >= pet_list_kond_neg-datab
                  AND h_wlk1-datbi <= pet_list_kond_neg-datbi.
* das 'Ende' des Eintrages ist ungültig -> DATBI zurücksetzen
                  pet_list_kond-datbi = pet_list_kond_neg-datab - 1.
                  t_vrkme-material_listing = x.

                ELSEIF h_wlk1-datbi > pet_list_kond_neg-datbi
                  AND h_wlk1-datab >= pet_list_kond_neg-datab
                  AND h_wlk1-datab <= pet_list_kond_neg-datbi.
* der 'Anfang' des Eintrages ist ungültig -> DATAB hochsetzen
                  pet_list_kond-datab = pet_list_kond_neg-datbi + 1.

                ELSEIF h_wlk1-datab < pet_list_kond_neg-datab
                   AND h_wlk1-datbi > pet_list_kond_neg-datbi.
* ein 'Zwischenstück' des Eintrages ist ungültig
* -> 2 Sätze weitergeben
                  t_vrkme-material_listing = x.
                  pet_list_kond-datbi = pet_list_kond_neg-datab - 1.
                  " Es wird überprüft, ob dieses Zwischenstück noch im
                  " zu suchenden Bereich liegt.
                  IF pi_datab <= pet_list_kond-datbi AND
                     pi_datbi >= pet_list_kond-datab.
                    APPEND pet_list_kond.
                  ENDIF.

                  pet_list_kond-datab = pet_list_kond_neg-datbi + 1.
*                    PET_LIST_KOND-DATBI = T_WLK1_INPUT-DATBI.
                  pet_list_kond-datbi = h_wlk1-datbi.

                ENDIF.
              ENDLOOP.               " PET_LIST_KOND_NEG
            ENDIF.
            IF pet_list_kond-datbi >= pet_list_kond-datab AND
               pi_datab <= pet_list_kond-datbi AND
               pi_datbi >= pet_list_kond-datab.
              APPEND pet_list_kond.
              t_vrkme-material_listing = x.
            ENDIF.
*           endif.                " T_wlke_input-sstat           " 4.6C
          ENDLOOP.                                          " HT_WLK1
          IF NOT t_vrkme-material_listing IS INITIAL.
            MODIFY t_vrkme.
          ENDIF.
        ENDLOOP.                       " T_VRKME
      ENDIF.                                                " Z1 = 0
  ENDCASE.


************************************************************************
* analysis: fill output table for wlk2

  IF  NOT tmp_bew_kond-matnr IS INITIAL.
    akt_vrkme = space.
    LOOP AT t_vrkme
       WHERE material_listing = x.
      IF t_vrkme-vrkme <> akt_vrkme.
        pet_bew_kond-mandt = tmp_bew_kond-mandt.
        pet_bew_kond-artnr = tmp_bew_kond-matnr.
        pet_bew_kond-filia = tmp_bew_kond-werks.
        pet_bew_kond-vrkme = t_vrkme-vrkme.
        pet_bew_kond-datab = tmp_bew_kond-vkdab.
        pet_bew_kond-datbi = tmp_bew_kond-vkbis.
        APPEND pet_bew_kond.
        akt_vrkme = t_vrkme-vrkme.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Prüfe, ob Daten ermittelt wurden.
*  LOOP AT T_WLK1_INPUT.
*    if t_wlk1_input-sstat = '5'.
*  LOOP AT ht_WLK1 into h_wlk1.
*    if h_wlk1-sstat = '5'.
*      RAISE KOND_NOT_FOUND.
*    endif.
*  endloop.
  SORT ht_wlk1 ASCENDING BY sstat.
  READ TABLE ht_wlk1 INTO h_wlk1 INDEX 1.
  IF sy-subrc = 0.
    IF h_wlk1-sstat = '5'.        " discontinued
      IF pi_mode IS INITIAL.      " assortment list
        RAISE kond_not_found.
      ELSEIF pi_mode = 'P'.       " POS download
        REFRESH pet_bew_kond.
        refresh pet_list_kond.
        RAISE kond_not_found.
      ENDIF.
    ENDIF.
  ENDIF.

* check, if data were read
  DESCRIBE TABLE pet_list_kond LINES z1.
  IF z1 = 0.
    RAISE kond_not_found.
  ENDIF.                                                    " Z1 = 0.

  DESCRIBE TABLE pet_bew_kond LINES z1.
  IF z1 = 0.
    IF PI_ONLY_LIST_CHECK <> 'X'.
      " do NOT raise if only listing_check is wished
      RAISE VKDAT_NOT_FOUND.
    ENDIF.
  ENDIF.

ENDFUNCTION.
