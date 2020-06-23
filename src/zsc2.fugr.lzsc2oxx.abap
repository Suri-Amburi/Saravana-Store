*-------------------------------------------------------------------
***INCLUDE LMGD2OXX .
***zentrale PBO-Module für alle Bildbausteine
*-------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Module  BEZEICHNUNGEN_LESEN  OUTPUT
*&---------------------------------------------------------------------*
* Lesen aller Bezeichnungen zum jeweiligen Bild                        *
* Durch die Übergabe der FELDBEZTAB wird sichergestellt, daß nur für   *
* die sichtbaren Felder auf dem jeweiligen Bild, für die Bezeichnungen
* ausgegeben werden sollen, die Bezeichnungen gelesen werden
* Zusätzlich wird sichergestellt, daß pro Bild eine Bezeichnung nur
* einmal ermittelt wird.
*----------------------------------------------------------------------*
MODULE bezeichnungen_lesen OUTPUT.
  DESCRIBE TABLE feldbeztab LINES zaehler.
  CHECK NOT zaehler IS INITIAL.

* Basismengeneinheit als Infotext zu Mengenfeldern, z.B. MARC-VBAMB
  IF NOT mara-meins IS INITIAL.
    rm03m-meins = mara-meins.
    rm03m-meinh = mara-meins.
* cfo/25.7.96 Lesen der Bezeichnung zur Basismengeneinheit muß ebenfalls
* hier erfolgen (z.B. für Mengeneinheitenbild).
    IF t006a-spras NE sy-langu OR t006a-msehi NE mara-meins.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = mara-meins
          language       = sy-langu
        IMPORTING
          long_text      = t006a-msehl
          output         = t006a-mseh3
          short_text     = t006a-mseht
        EXCEPTIONS
          unit_not_found = 01.
      t006a-msehi = mara-meins.
    ELSE.
      sy-subrc = 0.
    ENDIF.
    IF sy-subrc NE 0.
      CLEAR t006a.
    ENDIF.
  ELSE.
    CLEAR mara-meins.
  ENDIF.

*mk/30.08.95 Ermitteln Periode/Vorperiode - obwohl logisch zur MARC
*gehörend bereits hier, da sub_ptab und sub_status für Bestandsbild
*leer ist
  IF aktvstatus CA status_x OR aktvstatus CA status_z.
* MARC_X wird bei Status Z benutzt für Periodenermittlung
*   READ TABLE FELDBEZTAB WITH KEY T_RMMG3.                       "4.0A
    READ TABLE feldbeztab WITH KEY name(5) = t_rmmg3 BINARY SEARCH.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'MARC_X_READ_DESCRIPTION'
           EXPORTING
                matnr       = rmmg1-matnr
                werks       = rmmg1-werks
                wmard       = mard
                wt001_periv = t001-periv
                kzrfb       = kzrfb
            IMPORTING
                 wrmmg3      = rmmg3
*                flgperiode  = flgperiode   vorest nicht benutzt
           TABLES
                feldbeztab  = feldbeztab.
    ENDIF.
  ENDIF.

* cfo/24.7.96
* Statt Loop über SUB_PTAB, Loop über PTAB, weil SUB_PTAB für Zusatz-
* Bilder nicht aufgebaut wird (Modul Bildstatus läuft nicht) und dann
* Bezeichnungen auf Zusatzbildern nicht gelesen werden.
* Analog statt SUB_STATUS den AKTVSTATUS gesetzt.
* SUB_PTAB und SUB_STATUS waren reines Performance-Tuning.

  LOOP AT ptab.
    CASE ptab-tbnam.
      WHEN t_mara.
*       READ TABLE FELDBEZTAB WITH KEY T_MARA.                    "4.0A
        READ TABLE feldbeztab WITH KEY name(4) = t_mara BINARY SEARCH.
        CHECK sy-subrc EQ 0.

        CALL FUNCTION 'MARA_READ_DESCRIPTION'
          EXPORTING
            wmara            = mara
          IMPORTING
            wt006a           = t006a
            wt023t           = t023t
            wtspat           = tspat
            wtptmt           = tptmt  " AHE: 07.05.98 (4.0c)
            wtcscp_comp_lvlt = tcscp_comp_lvlt
          TABLES
            feldbeztab       = feldbeztab. " AHE: 11.05.98 (4.0c)

* AHE: 07.05.98 - A (4.0c)
* Sondercoding wegen Feld MARA-MTPOS_MARA und MVKE-MTPOS
        tptmt_bezei_mara = tptmt-bezei.
* AHE: 07.05.98 - E

        IF aktvstatus CA status_q.
          CALL FUNCTION 'MARA_Q_READ_DESCRIPTION'
            EXPORTING
              wmara_rbnrm = mara-rbnrm
              kzrfb       = kzrfb
            IMPORTING
              wt352b_t    = t352b_t
            TABLES
              feldbeztab  = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_e.
          CALL FUNCTION 'MARA_E_READ_DESCRIPTION'
            EXPORTING
              wmara      = mara
              kzrfb      = kzrfb
            IMPORTING
              wt405      = t405
            TABLES
              feldbeztab = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_v.
          CALL FUNCTION 'MARA_V_READ_DESCRIPTION'
            EXPORTING
              wmara       = mara
            IMPORTING
              wv_kna1wett = v_kna1wett
              wttgrt      = ttgrt
            TABLES
              feldbeztab  = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_k.
          CALL FUNCTION 'MARA_K_READ_DESCRIPTION'
            EXPORTING
              wmara       = mara
            IMPORTING
              wv_kna1wett = v_kna1wett
            TABLES
              feldbeztab  = feldbeztab.
        ENDIF.

      WHEN t_mfhm.
*       READ TABLE FELDBEZTAB WITH KEY T_MFHM.                    "4.0A
        READ TABLE feldbeztab WITH KEY name(4) = t_mfhm BINARY SEARCH.
        CHECK sy-subrc EQ 0.

        IF aktvstatus CA status_f.
          CALL FUNCTION 'MFHM_F_READ_DESCRIPTION'
            EXPORTING
              wmfhm      = mfhm
              kzrfb      = kzrfb
            IMPORTING
              wtc23t     = tc23t
              wtcf13     = tcf13
              otcf13     = *tcf13
              wtcf11     = tcf11
              wt435t     = t435t
              wtc25t     = tc25t
              otc25t     = *tc25t
              wtca55     = tca55
              otca55     = *tca55
            TABLES
              feldbeztab = feldbeztab.
        ENDIF.

      WHEN t_mvke.
*       READ TABLE FELDBEZTAB WITH KEY T_MVKE.                    "4.0A
        READ TABLE feldbeztab WITH KEY name(4) = t_mvke BINARY SEARCH.
        CHECK sy-subrc EQ 0.

        IF aktvstatus CA status_v.
          CALL FUNCTION 'MVKE_V_READ_DESCRIPTION'
            EXPORTING
              wmvke        = mvke
            IMPORTING
              wrm03m_name1 = rm03m-name1
              wtvsmt       = tvsmt
              wtvbot       = tvbot
              wtvkmt       = tvkmt
              wt178t       = t178t
              wtvprt       = tvprt
              wrm03m_texpr = rm03m-texpr
              wt179t       = t179t
              wtptmt       = tptmt
            TABLES
              feldbeztab   = feldbeztab.
        ENDIF.

      WHEN t_marc.
*       read table feldbeztab with key t_marc.     mk/4.0A
        READ TABLE feldbeztab WITH KEY name(4) = t_marc BINARY SEARCH.
        IF sy-subrc NE 0.
*         READ TABLE FELDBEZTAB WITH KEY T_MPGD.                  "4.0A
          READ TABLE feldbeztab WITH KEY name(4) = t_mpgd BINARY SEARCH.
* MPGD-Felder gehören logisch zur MARC
*         if sy-subrc ne 0.   mk/30.08.95 vorgezogen
* RMMG3-Felder gehören logisch zur MARC (Werksbestand + Periodenfelder)
*           read table feldbeztab with key t_rmmg3.
*         endif.
        ENDIF.
        CHECK sy-subrc EQ 0.

* AHE: 11.05.98 - A (4.0c)
        CALL FUNCTION 'MARC_READ_DESCRIPTION'
          EXPORTING
            wmarc      = marc
            kzrfb      = kzrfb
          IMPORTING
            wtmfpft    = tmfpft
          TABLES
            feldbeztab = feldbeztab.
* AHE: 11.05.98 - E

        IF aktvstatus CA status_d.
          CALL FUNCTION 'MARC_D_READ_DESCRIPTION'
               EXPORTING
                    wmarc      = marc
                    kzrfb      = kzrfb
               IMPORTING
                    wt438t     = t438t
                    wt439t     = t439t
                    wt438w     = t438w " AHE: 15.03.98 (4.0c)
*                    WT461X     = T461X "ch zu 3.0C -> IPr. 382656
               TABLES
                    feldbeztab = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_e.                          "ch zu 3.0D
          CALL FUNCTION 'MARC_VE_READ_DESCRIPTION'
            EXPORTING
              wmarc      = marc
              kzrfb      = kzrfb
            IMPORTING
              wt604t     = t604t
              wt005t     = t005t
              wt005u     = t005u
              wtvfmt     = tvfmt
              wt610ct    = t610ct"4.0A BE/130897
              wt609gp    = t609gp"4.0A BE/130897
              wt618mt    = t618mt"4.0A BE/130897
              wt618gt    = t618gt"4.0A BE/130897
              wt604n     = t604n "4.0A BE/130897
            TABLES
              feldbeztab = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_g.
          CALL FUNCTION 'MARC_G_READ_DESCRIPTION'
            EXPORTING
              kzrfb        = kzrfb
              wmarc_mmsta  = marc-mmsta
            IMPORTING
              wrm03m_kalst = rm03m-kalst
            TABLES
              feldbeztab   = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_q.
          CALL FUNCTION 'MARC_Q_READ_DESCRIPTION'
            EXPORTING
              kzrfb       = kzrfb
              wmarc_ssqss = marc-ssqss
              wmarc_qzgtp = marc-qzgtp
              wmarc_qssys = marc-qssys
            IMPORTING
              wtq02t      = tq02t
              wtq05t      = tq05t
              wtq08t      = tq08t
            TABLES
              feldbeztab  = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_v.
          CALL FUNCTION 'MARC_V_READ_DESCRIPTION'
            EXPORTING
              wmarc      = marc
              kzrfb      = kzrfb
            IMPORTING
              wtmvft     = tmvft
              wtlgrt     = tlgrt
              wt604t     = t604t
              wt005t     = t005t
              wt005u     = t005u
              wtvfmt     = tvfmt
              wt610ct    = t610ct"4.0A BE/130897
              wt609gp    = t609gp"4.0A BE/130897
              wt618mt    = t618mt"4.0A BE/130897
              wt618gt    = t618gt"4.0A BE/130897
              wt604n     = t604n "4.0A BE/130897
            TABLES
              feldbeztab = feldbeztab.
        ENDIF.

        IF aktvstatus CA status_a.
          CALL FUNCTION 'MARC_A_READ_DESCRIPTION'
               EXPORTING
                    wmarc      = marc
                    kzrfb      = kzrfb
               IMPORTING
                    wt024f     = t024f
                    wtco43t    = tco43t
* AHE: 30.06.98 - A (4.0C)
*                   WTCO47T    = TCO47T  " AHE: 11.05.98 (4.0c)
                    wtco48t    = tco48t
* AHE: 30.06.98 - E
               TABLES
                    feldbeztab = feldbeztab.
        ENDIF.
*mk/30.08.95 vorgezogen
*       IF SUB_STATUS CA STATUS_X OR SUB_STATUS CA STATUS_Z.
* MARC_X wird bei Status Z benutzt für Periodenermittlung
      WHEN t_mbew.
*       READ TABLE FELDBEZTAB WITH KEY T_MBEW.                    "4.0A
        READ TABLE feldbeztab WITH KEY name(4) = t_mbew BINARY SEARCH.
        CHECK sy-subrc EQ 0.

        IF aktvstatus CA status_b.
*        Wird zu 4.0C nicht mehr benötigt, da die Perioden im
*        Einstiegsbereich (BWKEY_INITIAL_CHECK) ermittelt werden
*         CALL FUNCTION 'MBEW_B_READ_DESCRIPTION'
*              EXPORTING
*                   WMBEW        = MBEW
*                   WT001_PERIV  = T001-PERIV
*              IMPORTING
*                   WRMMZU_VMGJA = RMMZU-VMGJA
*                   WRMMZU_VMMON = RMMZU-VMMON
*                   WRMMZU_VJGJA = RMMZU-VJGJA
*                   WRMMZU_VJMON = RMMZU-VJMON
*              TABLES
*                   FELDBEZTAB   = FELDBEZTAB.
        ENDIF.

* mk/27.02.95 aktuell nicht generierbar
* erweitern um weitere Pflegestatus             <<<<<<<<<<<<<<<<<<<
* erweitern um weitere Tabellen                 <<<<<<<<<<<<<<<<<<<

    ENDCASE.
  ENDLOOP.

ENDMODULE.                             " BEZEICHNUNGEN_LESEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  BEZEICHNUNGEN_LESEN_RT   OUTPUT
*&---------------------------------------------------------------------*
* Lesen aller Bezeichnungen zum jeweiligen Bild                        *
* Durch die Übergabe der FELDBEZTAB wird sichergestellt, daß nur für   *
* die sichtbaren Felder auf dem jeweiligen Bild, für die Bezeichnungen
* ausgegeben werden sollen, die Bezeichnungen gelesen werden
* Zusätzlich wird sichergestellt, daß pro Bild eine Bezeichnung nur
* einmal ermittelt wird.
*----------------------------------------------------------------------*
MODULE bezeichnungen_lesen_rt  OUTPUT.
  DESCRIBE TABLE feldbeztab LINES zaehler.
  CHECK NOT zaehler IS INITIAL.
*---------------------------------------------------------------------
  IF NOT mwli-lstfl IS INITIAL.
    READ TABLE feldbeztab WITH KEY mwli_lstfl.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      twlvt_key-mandt = sy-mandt.
      twlvt_key-lstfl = mwli-lstfl.
      twlvt_key-spras = sy-langu.
      READ TABLE twlvt WITH KEY twlvt_key.
    ENDIF.
  ELSE.
    CLEAR twlvt-vtext.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT mwli-lstvz IS INITIAL.
    READ TABLE feldbeztab WITH KEY mwli_lstvz.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      twlvt_key-mandt = sy-mandt.
      twlvt_key-lstfl = mwli-lstvz.
      twlvt_key-spras = sy-langu.
      READ TABLE *twlvt WITH KEY twlvt_key.
    ENDIF.
  ELSE.
    CLEAR *twlvt-vtext.
  ENDIF.
*---------------------------------------------------------------------
  CLEAR rm06i.
  IF NOT eine-waers IS INITIAL.
    READ TABLE feldbeztab WITH KEY eine_waers.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      rm06i-waer2 = eine-waers.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT eina-meins IS INITIAL.                             "cfo/1.2B
    READ TABLE feldbeztab WITH KEY eine_bstma.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      rm06i-mein3 = eina-meins.
      rm06i-mein7 = eina-meins.        " RWA 13.7.98
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT eine-bprme IS INITIAL.
    READ TABLE feldbeztab WITH KEY eine_bprme.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      rm06i-mein5 = eine-bprme.
      rm06i-mein4 = eine-bprme.
*      RM06I-MEIN3 = EINA-MEINS.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT eine-peinh IS INITIAL.
    READ TABLE feldbeztab WITH KEY eine_peinh.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      rm06i-peinh = eine-peinh.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT mara-pmata IS INITIAL.
    READ TABLE feldbeztab WITH KEY mara_pmata.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      SELECT SINGLE * FROM makt INTO pmata_makt
                                WHERE matnr = mara-pmata AND
                                      spras = sy-langu.
      IF sy-subrc = 0.
        rm03m-texpr = pmata_makt-maktx.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR rm03m-texpr.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT mara-tragr IS INITIAL.
    READ TABLE feldbeztab WITH KEY mara_tragr.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      SELECT SINGLE * FROM ttgrt
                           WHERE  spras = sy-langu AND
                                  tragr = mara-tragr.
    ENDIF.
  ELSE.
    CLEAR ttgrt-vtext.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT maw1-wladg IS INITIAL.
    READ TABLE feldbeztab WITH KEY maw1_wladg.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      SELECT SINGLE * FROM tlgrt
                           WHERE spras = sy-langu    AND
                                 ladgr = maw1-wladg.
    ENDIF.
  ELSE.
    CLEAR tlgrt-vtext.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT malg-laygr IS INITIAL.
    READ TABLE feldbeztab WITH KEY malg_laygr.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      SELECT SINGLE * FROM twmlt
                           WHERE laygr = malg-laygr   AND
                                 spras = sy-langu.
    ENDIF.
  ELSE.
    CLEAR twmlt-ltext.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT calp-kwaer IS INITIAL.        "cfo/17.2.97
    rmmwt-kwaer1 = calp-kwaer.
    rmmwt-kwaer2 = calp-kwaer.
  ELSE.
    CLEAR: rmmwt-kwaer1, rmmwt-kwaer2.
  ENDIF.
  IF NOT calp-vwaer IS INITIAL.                             "cfo/4.5B
    rmmwt-vwaer1 = calp-vwaer.                              "
  ELSE.                                                     "
    CLEAR rmmwt-vwaer1.                                     "
  ENDIF.                                                    "cfo/4.5B
*---------------------------------------------------------------------
  IF NOT rmmw3-ekkalsm IS INITIAL.                          "cfo/1.2B2
    t005-kalsm = rmmw3-ekkalsm.
  ENDIF.
*---------------------------------------------------------------------
  IF NOT maw1-cnpro IS INITIAL.                             "sde/2.2.99
    READ TABLE feldbeztab WITH KEY maw1_cnpro.
    IF sy-subrc EQ 0 AND feldbeztab-kzread IS INITIAL.
      feldbeztab-kzread = x.
      MODIFY feldbeztab INDEX sy-tabix.
      SELECT SINGLE * FROM twcpt
                           WHERE langu = sy-langu    AND
                                 cnpro = maw1-cnpro.
    ENDIF.
  ELSE.
    CLEAR twcpt-descr.
  ENDIF.


ENDMODULE.                             "BEZEICHNUNGEN_LESEN_RT OUTPUT



*&---------------------------------------------------------------------*
*&      Module  BILDSTATUS  OUTPUT
*&---------------------------------------------------------------------*
* Ermitteln Pflegestatus und PTAB zum Bild(baustein) für das Vorlage-
* handling/Handling Bezeichnungen gemäß dem AKTVSTATUS.
* Außerdem wird überprüft, daß die Pflegestatus aller Felder auf
* dem kompletten Bild zum Bildstatus gemäß T133A passen.
*mk/07.12.95 Das Vorlagehandling läuft zentral für das komplette
*Bild,deswegen werden die Baustein-spezifische PTAB sowie Pflegestatus
*nicht benötigt.
*Die Überprüfung, ob alle Felder zum Bild-Pflegestatus passen, wird
*jetzt direkt im Module ausgeführt
*----------------------------------------------------------------------*
MODULE bildstatus OUTPUT.

  CLEAR kz_status_abw.
  TRANSLATE t133a-pstat USING ' $'.
  LOOP AT fauswtab WHERE NOT pstat IS INITIAL.
    CHECK fauswtab-kzinv = '0'.                             "BE/231096
    IF fauswtab-pstat NA t133a-pstat.
      kz_status_abw = x.
      fname_abw     = fauswtab-fname.
      EXIT.
    ENDIF.
  ENDLOOP.
  TRANSLATE t133a-pstat USING '$ '.

  IF NOT kz_status_abw IS INITIAL.
* Bild enthält Feld, dessen Status nicht im Bildstatus vorkommt
* Customizing muß angepaßt werden
    MESSAGE a826 WITH fname_abw t133a-pstat.

  ENDIF.

ENDMODULE.                             " BILDSTATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FAUSW_BEZEICHNUNGEN  OUTPUT
*&---------------------------------------------------------------------*
* Ausblenden der Texte zu den unsichtbaren Feldern                     *
* insbesondere auch die Daten zum Einkaufswerteschlüssel, falls dieser
* ausgeblendet ist
*----------------------------------------------------------------------*
MODULE fausw_bezeichnungen OUTPUT.

  DATA: hgroup1 LIKE screen-group1.

  hgroup1(1) = 'F'.
  LOOP AT SCREEN.
    IF screen-group1(1) EQ 'T' AND screen-input EQ 0.
      hgroup1+1 = screen-group1+1.
      READ TABLE feldbeztab WITH KEY group1 = hgroup1.
      IF sy-subrc NE 0.
        screen-invisible = 1.
        screen-output    = 0.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
*   note 1611251: extend the logic also for SCREEN-GROUP2
    IF SCREEN-GROUP2(1) EQ 'T'.
      HGROUP1+1 = SCREEN-GROUP2+1.
      READ TABLE FELDBEZTAB2 WITH KEY GROUP1 = HGROUP1.
      IF SY-SUBRC NE 0.
        SCREEN-INVISIBLE = 1.
        SCREEN-OUTPUT    = 0.
        SCREEN-INPUT     = 0.     "mk/4.0A
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                             " FAUSW_BEZEICHNUNGEN  OUTPUT


*------------------------------------------------------------------
*           Feldauswahl
*
*Die Feldauswahlleiste wird im Modul VERK_FELDAUSWAHL erstellt.
*mk/12.07.95 Lesen T130F vorgezogen aus FB incl. Fauswtab ergänzen
*mk/04.12.95 ungefüllte OrgEbenen müssen im Retail offen bleiben
*mk/05.12.95 KZINI wird nur im Erweiterungsfall benötigt bzw.
*für den Kurtext im Anlegefall (Sonfausw_in_fgruppen)
*------------------------------------------------------------------
MODULE feldauswahl OUTPUT.

* (del) TRANSLATE AKTVSTATUS USING ' $'.                     "BE/070597

*-------- Aufbauen Feldauswahl-Tabelle --------------------------------

  PERFORM t130f_lesen_komplett.

  REFRESH fauswtab.   CLEAR fauswtab.

  LOOP AT SCREEN.

    CLEAR kz_field_initial.
*mk/05.12.95 nur beim Erweitern sowie für Kurztext und Kopffelder
*wird die Information benötigt, ob Feld initial ist
    IF screen-name CA '-'.             "mk/4.0A sonst Dump
      IF ( t130m-aktyp = aktyph AND neuflag IS INITIAL )        OR
         ( t130m-aktyp = aktyph  AND screen-name = makt_maktx ).
*   ASSIGN (SCREEN-NAME) TO <F>.     mk/05.12.95
        ASSIGN TABLE FIELD (screen-name) TO <f>.
*       if <f> is initial.                        "mk/4.0A
        IF sy-subrc EQ 0 AND <f> IS INITIAL.                "mk/4.0A
          kz_field_initial = x.        "Übergabe Kennung Feld initial
* Bestimmte ungefüllte OrgEbenenfelder werden ausgeblendet     ch/4.0C
          IF screen-name = rmmw1_lgtyp
          OR screen-name = rmmg1_lgtyp
          OR screen-name = rmmw1_vzbwtar
          OR screen-name = rmmw1_fibwtar.
            screen-invisible = 1.
            screen-active    = 0.
            screen-output    = 0.
            screen-input     = 0.
            screen-required  = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.                                                  "mk/4.0A

*   note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
    IF SCREEN-NAME = 'MEAN-EAN11'.
      SCREEN-NAME = 'SMEINH-EAN11'.
    ENDIF.
    IF SCREEN-NAME = 'MEAN-EANTP'.
      SCREEN-NAME = 'SMEINH-NUMTP'.
    ENDIF.

*   note 2389622
*   T130F uses EINE fields, screen uses MMPUR_INCOTERMS_INFORECORDS fields
    IF SCREEN-NAME CS 'MMPUR_INCOTERMS_INFORECORDS'.
      REPLACE 'MMPUR_INCOTERMS_INFORECORDS' IN SCREEN-NAME WITH 'EINE'.
    ENDIF.

*   note 1358288: override invisible flag set by table control to
*   enable correct execution of field selection
    IF <F_TC> IS ASSIGNED.
      READ TABLE <F_TC>-COLS INTO TC_COL WITH KEY SCREEN-NAME = SCREEN-NAME.
      IF sy-subrc = 0 AND SCREEN-INVISIBLE = 1.
        SCREEN-INVISIBLE = 0.
      ENDIF.
    ENDIF.

    fauswtab-fname = screen-name.
    fauswtab-kzini = kz_field_initial.
    fauswtab-kzact = screen-active.
    fauswtab-kzinp = screen-input.
    fauswtab-kzint = screen-intensified.
    fauswtab-kzinv = screen-invisible.
    fauswtab-kzout = screen-output.
    fauswtab-kzreq = screen-required.
    READ TABLE it130f WITH KEY fname = fauswtab-fname BINARY SEARCH.
    IF sy-subrc NE 0.
      CLEAR it130f.
*mk/4.0A Sonderlogik für Pushbuttons etc.
      SPLIT screen-name AT '-' INTO it130f-tbnam it130f-fieldname.
      IF it130f-fieldname IS INITIAL.
        SPLIT screen-name AT '_' INTO it130f-tbnam it130f-fieldname.
      ENDIF.
    ENDIF.
    fauswtab-pstat = it130f-pstat.
    fauswtab-kzref = it130f-kzref.
    fauswtab-kzkey = it130f-kzkey.
    fauswtab-sfgru = it130f-sfgru.
    fauswtab-kzkma = it130f-kzkma.
    fauswtab-fgrup = it130f-fgrup.
    fauswtab-tbnam = it130f-tbnam.                          "mk/4.0A
    fauswtab-fieldname  = it130f-fieldname.                 "mk/4.0A
    fauswtab-fgrou = it130f-fgrou.     "4.0A  BE/190997
    fauswtab-fixre = it130f-fixre.     "TF 4.6C Materialfixierung
    APPEND fauswtab.

  ENDLOOP.

*---------Feldauswahl Langtexte TF 4.6A--------------------------------
* Note 615893
* Documentdata will be handels with one entry in T130F.
* The internal FAUSWTAB will be expanded with document data entry
* and evaluated with standard fieldselection
* then entry will be removed again.

  IF NOT dokumente_feldauswahl IS INITIAL.
    CASE dokumente_feldauswahl.
      WHEN dokumente_bild.
        fauswtab-fname = 'DOKUMENTE'.
    ENDCASE.


    fauswtab-kzact = 1.
    fauswtab-kzinp = 1.
    fauswtab-kzint = 0.
    fauswtab-kzinv = 0.
    fauswtab-kzout = 1.
    fauswtab-kzreq = 0.

    READ TABLE it130f WITH KEY fname = fauswtab-fname BINARY SEARCH.

    fauswtab-pstat = it130f-pstat.
    fauswtab-kzref = it130f-kzref.
    fauswtab-kzkey = it130f-kzkey.
    fauswtab-sfgru = it130f-sfgru.
    fauswtab-kzkma = it130f-kzkma.
    fauswtab-fgrup = it130f-fgrup.
    fauswtab-tbnam = it130f-tbnam.     "mk/4.0A
    fauswtab-fieldname  = it130f-fieldname.        "mk/4.0A
    fauswtab-fgrou = it130f-fgrou.     "4.0A  BE/190997
    APPEND fauswtab.
  ENDIF.

* Langtextbilder werden als Ganzes über einen einzigen Eintrag in der
* T130F verwaltet. In der Langtextpflege wird fauswtab um den ent-
* sprechenden Eintrag erweitert, welcher der standardmäßigen Feldauswahl
* unterzogen wird. Abhängig vom Ergebnis werden die Parameter ltext_*
* gesetzt und danach der Eintrag aus der fauswtab wieder entfernt.

  IF NOT langtextbild_feldauswahl IS INITIAL.
    CASE langtextbild_feldauswahl.
      WHEN grunddtext_bild.
        fauswtab-fname = ltext_grun.
      WHEN bestelltext_bild.
        fauswtab-fname = ltext_best.
      WHEN vertriebstext_bild.
        fauswtab-fname = ltext_vert.
      WHEN ivermtext_bild.
        fauswtab-fname = ltext_iver.
      WHEN prueftext_bild.
        fauswtab-fname = ltext_prue.
    ENDCASE.
    IF anz_sprachen > 0.               "TF 4.6C Materialfixierung
      fauswtab-kzini = ' '.
    ELSE.                              "TF 4.6C Materialfixierung
      fauswtab-kzini = 'X'.            "TF 4.6C Materialfixierung
    ENDIF.                             "TF 4.6C Materialfixierung
    fauswtab-kzact = 1.
    fauswtab-kzinp = 1.
    fauswtab-kzint = 0.
    fauswtab-kzinv = 0.
    fauswtab-kzout = 1.
    fauswtab-kzreq = 0.
    READ TABLE it130f WITH KEY fname = fauswtab-fname BINARY SEARCH.
    IF sy-subrc NE 0.
      CLEAR it130f.
*mk/4.0A Sonderlogik für Pushbuttons etc.
      SPLIT screen-name AT '-' INTO it130f-tbnam it130f-fieldname.
      IF it130f-fieldname IS INITIAL.
        SPLIT screen-name AT '_' INTO it130f-tbnam it130f-fieldname.
      ENDIF.
    ENDIF.
    fauswtab-pstat = it130f-pstat.
    fauswtab-kzref = it130f-kzref.
    fauswtab-kzkey = it130f-kzkey.
    fauswtab-sfgru = it130f-sfgru.
    fauswtab-kzkma = it130f-kzkma.
    fauswtab-fgrup = it130f-fgrup.
    fauswtab-tbnam = it130f-tbnam.                          "mk/4.0A
    fauswtab-fieldname  = it130f-fieldname.                 "mk/4.0A
    fauswtab-fgrou = it130f-fgrou.     "4.0A  BE/190997
    fauswtab-fixre = it130f-fixre.     "TF 4.6C Materialfixierung
    APPEND fauswtab.
  ENDIF.
*---------Feldauswahl Langtexte TF 4.6A--------------------------------

  SORT fauswtab BY fname.

*-------- Aufrufen FB für Feldauswahl ---------------------------------

* Vereinigung der Feldauswahl-FB's Industrie und Retail      "BE/130197
* CALL FUNCTION 'MATERIAL_FIELD_SELECTION_RT'                "BE/130197
  CALL FUNCTION 'MATERIAL_FIELD_SELECTION_NEW'              "BE/130197
       EXPORTING
            aktvstatus       = aktvstatus
            it130m           = t130m
            neuflag          = neuflag
            irmmg1           = rmmg1
            irmmg2           = rmmg2                                    " n_2307549
            irmmw2           = rmmw2
            rmmg2_flg_retail = rmmg2-flg_retail             "BE/130197
            rmmg2_kzkfg      = mara-kzkfg
            it134_wmakg      = t134-wmakg              "4.0A  BE/050697
            imarc_dispr      = marc-dispr
            imarc_pstat      = marc-pstat
            impop_propr      = mpop-propr
            imvke_pmatn      = mvke-pmatn
            imbew_bwtty      = mbew-bwtty              "4.0A  BE/150897
            rmmg2_kzmpn      = rmmg2-kzmpn "mk/4.0A  MPN
            imara_mstae      = mara-mstae              "4.0A  BE/071097
            it133a_pstat     = t133a-pstat             "RWA Hinw. 127870
            iv_matfi         = mara-matfi     "TF 4.6C Materialfixierung
            imara_pmata      = mara-pmata              "note 1023329
       TABLES
            fauswtab         = fauswtab
            ptab             = ptab
            ptab_rt          = ptab_rt
            ptab_full        = ptab_full
            ptab_full_rt     = ptab_full_rt.

*---------Feldauswahl Langtexte TF 4.6A--------------------------------

  IF NOT langtextbild_feldauswahl IS INITIAL.
    CASE langtextbild_feldauswahl.
      WHEN grunddtext_bild.
        fauswtab-fname = ltext_grun.
      WHEN bestelltext_bild.
        fauswtab-fname = ltext_best.
      WHEN vertriebstext_bild.
        fauswtab-fname = ltext_vert.
      WHEN ivermtext_bild.
        fauswtab-fname = ltext_iver.
      WHEN prueftext_bild.
        fauswtab-fname = ltext_prue.
    ENDCASE.
    READ TABLE fauswtab WITH KEY fname = fauswtab-fname.
    ltext_invisible = fauswtab-kzinv.
    ltext_input = fauswtab-kzinp.
    ltext_required = fauswtab-kzreq.
    DELETE fauswtab INDEX sy-tabix.
* siehe Hinweis 516883 wg02.05.02
   IF ( t130m-aktyp = aktypa OR t130m-aktyp = aktypz ).
     READ TABLE fauswtab WITH KEY fname = 'DESC_LANGU_GDTXT'.
       if sy-subrc = 0.
         fauswtab-kzinp = '0'.
         modify fauswtab index sy-tabix.
       endif.
   endif.
  ENDIF.
*---------Feldauswahl Langtexte TF 4.6A--------------------------------
*-------- Modifizieren Screen über Feldauswahl-Tabelle ----------------

* Feldauswahl Dokumentdaten ( * Note 615893 )
* The display property support only display. Hide or required
* field entry cannot be supported.

  IF NOT dokumente_feldauswahl IS INITIAL.
    CASE dokumente_feldauswahl.
      WHEN dokumente_bild.
        fauswtab-fname = 'DOKUMENTE'.
    ENDCASE.
    READ TABLE fauswtab WITH KEY fname = fauswtab-fname.
    dokumente_input = fauswtab-kzinp.
    DELETE fauswtab INDEX sy-tabix.
  ENDIF.

*         Feldauswahl Dokumentdaten  ( * Note 615893 )

  LOOP AT SCREEN.

*   read table fauswtab with key screen-name binary search.  mk/4.0A
    READ TABLE fauswtab WITH KEY fname = screen-name BINARY SEARCH.

    screen-active      = fauswtab-kzact.
    screen-input       = fauswtab-kzinp.
    screen-intensified = fauswtab-kzint.
    screen-invisible   = fauswtab-kzinv.
    screen-output      = fauswtab-kzout.
    screen-required    = fauswtab-kzreq.

*   note 1358288: override columns set by TC_VIEW customizing
    IF <F_TC> IS ASSIGNED.
      READ TABLE <F_TC>-COLS INTO TC_COL WITH KEY SCREEN-NAME = SCREEN-NAME.
      IF sy-subrc = 0.
*       If field is set by table control to invisible and it is not
*       required due to material field selection, then hide the field.
*       Otherwise make sure, that the field is not hidden.
        IF TC_COL-INVISIBLE = CX_TRUE AND SCREEN-REQUIRED = 0.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE    = 1.                          "note 1575018
          SCREEN-OUTPUT    = 1.                          "note 1575018
          SCREEN-INPUT     = 0.
        ELSEIF SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE    = 1.                          "note 1575018
          SCREEN-OUTPUT    = 1.                          "note 1575018
          TC_COL-INVISIBLE = CX_TRUE.
        ELSE.
          TC_COL-INVISIBLE = CX_FALSE.
        ENDIF.
        TC_COL-SCREEN = SCREEN.
        MODIFY <F_TC>-COLS FROM TC_COL INDEX sy-tabix.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

* (del) TRANSLATE AKTVSTATUS USING '$ '.                     "BE/070597

ENDMODULE.                    "feldauswahl OUTPUT


*------------------------------------------------------------------
*        GET_DATEN_SUB
*
*- Holen der Materialstammdaten aus den U-WA´s in den Bildbaustein
* Falls keine Subscreens vorhanden sind, ist dies bereits schon im
* Modul get_daten_bild ausgeführt
* Die Daten werden nur beschafft, wenn das Bild nicht wiederholt
* wird oder das Bild bereits vollständig prozessiert wurde
*------------------------------------------------------------------
MODULE get_daten_sub OUTPUT.

  CHECK NOT anz_subscreens IS INITIAL.
*wk/4.0
  flg_tc = ' '.

*
*mk/1.2B Die temporären Daten müssen unabhängig vom Bildflag aus
*den Puffern geholt werden, damit z.B. nach einem Wechsel auf
*das ME-Popup die dortigen temporären Änderungen berücksichtigt werden
*
  IF NOT kz_ein_programm IS INITIAL.
    IF NOT kz_bildbeginn IS INITIAL.
      CLEAR sub_zaehler.
*     IF BILDFLAG IS INITIAL OR NOT BILDTAB-KZPRO IS INITIAL
*        OR NOT RMMZU-BILDPROZ IS INITIAL.   mk/07.02.96
*mk/07.02.96 bildtab-kzpro darf nicht mehr benutzt werden
*     IF BILDFLAG IS INITIAL OR NOT RMMZU-BILDPROZ IS INITIAL.   mk/1.2B
      PERFORM zusatzdaten_get_sub.
      PERFORM matabellen_get_sub.
      PERFORM matabellen_get_sub_rt.
*     ENDIF.
    ENDIF.
  ELSE.
*   IF BILDFLAG IS INITIAL OR NOT BILDTAB-KZPRO IS INITIAL
*      OR NOT RMMZU-BILDPROZ IS INITIAL.
*   IF BILDFLAG IS INITIAL OR NOT RMMZU-BILDPROZ IS INITIAL.     mk/1.2B
    PERFORM zusatzdaten_get_sub.
    PERFORM matabellen_get_sub.
    PERFORM matabellen_get_sub_rt.
*   ENDIF.
  ENDIF.

ENDMODULE.                    "get_daten_sub OUTPUT


*------------------------------------------------------------------
* INIT_SUB
*
*Es werden die zentralen Steuerungsdaten für die Bildbausteine geholt.
*------------------------------------------------------------------
MODULE init_sub OUTPUT.

  DATA: init_progn_fb  LIKE t133d-routn VALUE 'INIT_'.

  hwerk = rmmg1-werks.                                      "mk/1.2B
*TF 4.0C================================================================
** INIT_PROGN_FB+5(4) = SY-REPID+4.  "//br40
*  init_progn_fb+5    = sy-repid+4.     " Namensraumverlängerung
*
*  call function init_progn_fb.
** CALL FUNCTION 'INIT_MGD2'.   "Aufruf jeweiliges Bildbausteinprogramm
*TF 4.0C================================================================

  PERFORM init_baustein.

ENDMODULE.                    "init_sub OUTPUT

*------------------------------------------------------------------
*           Referenzdaten vorschlagen
*
* Felder, die referenziert werden sollen, muessen in der Tabelle T130F
* als solche gekennzeichnet werden.
* Die Feldinhalte dieser Felder werden vorgeschlagen, falls das Feld
* auf dem Bildschirm eingabebereit ist.
* Eingabebereit ist das Feld nur, wenn der entsprechende Status des
* Feldes gepflegt wird, wenn das Feld nicht bereits durch einen
* vorhergehenden Vorgang haette gepflegt werden koennen und falls
* die entsprechende Tabelle angefordert wurde.
* Die Referenz darf bei mehrmaligem prozessieren eines Bildes nur
* einmal durchgefuehrt werden. Dazu wird das Kennzeichen, Bild bereits
* prozessiert (Kennzeichen wird im Modul Dynpro_prozessiert gesetzt)
* abgefragt.
* Felder, die auf mehreren Bildern eingebbar sind, duerfen auch nur
* einmal referenziert werden. Dazu wird das referenzierte Feld nach
* der Uebernahme in die Referenztabelle geschrieben. Eine Uebernahme
* erfolgt nur, wenn das Feld noch nicht in der Referenztabelle steht.
* mk/16.02.95  Jetzt auch beim Dunkel-Prozessieren  Vorlagehandling
* mk/16.02.95: Sonderregel für Vorplanungsmaterial geändert, da
* RM03M-Felder ersetzt durch MPGD-Felder.
* mk/22.03.95: Umrechnung Währungsfelder funktioniert nur, wenn
* Buchungskreis-Daten gelesen wurden, also aktuell nur, wenn
* der AKTVSTATUS B oder G enthält oder wenigstens ein Werk vorgegeben
* wurde (in diesem Fall wird T001 und *T001 nachgelesen)
* mk/29.03.95: Tabelle REFERENZ notwendig, da Vorlagewerte
* auf Bild1 absichtlich zurückgesetzt werden können, dann natürlich
* auf Bild2 nicht mehr mit Vorlagedaten überschrieben werden sollen
* Außerdem benutzt, damit Daten, die aus einem Profil vorgeschlagen
* mit Initialwert vorgeschlagen wurden, nicht mit dem Vorlagedaten
* überschrieben werden.
* br/06.04.95 die Vorlage für die Kurztexte wird über das Kennzeichen
* FLGKTEXTREF gesteuert
*-------------------------------------------------------------------
MODULE refdaten_vorschlagen OUTPUT.

  CHECK NOT rmmg1_ref-matnr IS INITIAL AND
            t130m-aktyp = aktyph.
  CHECK bildflag IS INITIAL.

*----Pruefen, ob Bild bereits prozessiert wurde-----------------
  CHECK bildtab-kzpro IS INITIAL.

  CALL FUNCTION 'MATERIAL_REFERENCE_GEN'
    EXPORTING
      flgktextref = rmmg2-flgktref
      flgmeinref  = rmmg2-flgmeinref
      kzrfb       = kzrfb
      wmakt       = makt
      wmara       = mara
      wmarc       = marc
      wmpgd       = mpgd
      wmard       = mard
      wmbew       = mbew
      wmfhm       = mfhm
      wmlgn       = mlgn
      wmlgt       = mlgt
      wmpop       = mpop
      wmvke       = mvke
      wmyms       = myms
      rmakt       = rmakt
      rmara       = rmara
      rmarc       = rmarc
      rmpgd       = rmpgd
      rvpbme      = rvpbme
      rmard       = rmard
      rmbew       = rmbew
      rmfhm       = rmfhm
      rmlgn       = rmlgn
      rmlgt       = rmlgt
      rmpop       = rmpop
      rmvke       = rmvke
      rmyms       = rmyms
      t001_waers  = t001-waers
      rt001_waers = *t001-waers
      werks       = rmmg1-werks
      ref_werks   = rmmg1_ref-werks
      manbr       = rmmg2-manbr                      "cfo/4.5B
    IMPORTING
      flgktextref = rmmg2-flgktref
      flgmeinref  = rmmg2-flgmeinref
      wmakt       = makt
      wmara       = mara
      wmarc       = marc
      wmpgd       = mpgd
      vpbme       = rmmzu-vpbme
      wmard       = mard
      wmbew       = mbew
      wmfhm       = mfhm
      wmlgn       = mlgn
      wmlgt       = mlgt
      wmpop       = mpop
      wmvke       = mvke
      wmyms       = myms
    TABLES
      fauswtab    = fauswtab
      ptab        = ptab
      rptab       = rptab
      ktext       = ktext
      rktext      = rktext
      meinh       = meinh
      rmeinh      = rmeinh
      steuertab   = steuertab
      rsteuertab  = rsteuertab
      steummtab   = steummtab
      rsteummtab  = rsteummtab.

ENDMODULE.                    "refdaten_vorschlagen OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_DATEN_SUB
*&---------------------------------------------------------------------*
* Zurückgeben der Daten des Bildbausteins an die U-WA´s, falls         *
* nicht alle Bildbausteine des Bildes zu einem einheitlichen Programm
* gehören
* Festhalten der aktuellen REFTAB (zusätzliches Vorlagehandling)
*----------------------------------------------------------------------*
MODULE set_daten_sub OUTPUT.

*mk/3.0E Setzen Kz. 'Status-Update am Ende des Bildes erforderlich',
*falls auf dem Bild Felder zu statusrelevanten Tabellen vorhanden
*sind
  IF rmmzu-kzstat_upd IS INITIAL.
    LOOP AT sub_ptab WHERE NOT kzsta IS INITIAL.
      rmmzu-kzstat_upd = x.
    ENDLOOP.
  ENDIF.

  IF anz_subscreens IS INITIAL.
* Keine Bildbausteine auf dem Bild vorhanden
    CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
      EXPORTING
        rmmzu_kzstat_upd = rmmzu-kzstat_upd
      TABLES
        reftab           = reftab.
  ELSEIF NOT kz_ein_programm IS INITIAL.
* Bildbausteine auf dem Bild vorhanden, alle aus einheitlichem Programm
    CLEAR kz_bildbeginn.
    sub_zaehler = sub_zaehler + 1.
    IF sub_zaehler EQ anz_subscreens.
      kz_bildbeginn = x.               "für PAI notwendig
      CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
        EXPORTING
          rmmzu_kzstat_upd = rmmzu-kzstat_upd
        TABLES
          reftab           = reftab.
    ENDIF.
  ELSE.
* Bildbausteine auf dem Bild vorhanden, aus unterschiedlichen Programmen
    PERFORM zusatzdaten_set_sub.
    PERFORM matabellen_set_sub_rt. " MUß vor MATABELLEN_SET_SUB laufen !
    PERFORM matabellen_set_sub.
    CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
      EXPORTING
        rmmzu_kzstat_upd = rmmzu-kzstat_upd
      TABLES
        reftab           = reftab.
  ENDIF.

ENDMODULE.                             " SET_DATEN_SUB  OUTPUT

*------------------------------------------------------------------
*  Module SONFAUSW_IN_FGUPPEN.
*------------------------------------------------------------------
* Felder ,die in T130F zu einer Sonderfeldauswahlgruppe zusammenge-
* fasst wurden, werden in Abhaengigkeit von der Gruppennummer einer
* Sonderbehandlung unterzogen.
* Sonderregel 010 neu für Änderungsdienst                 QHBADIK001125
* mk/27.02.95: Festhalten der ausgeblendeten Felder, denen reine
* Anzeigetexte zugeordnet sind (Screen-Group1 gefüllt) in der
* internen Tabelle feldbeztab
*mk/1995: Feldauswahl für KMAT wird hier ebenfalls ausgeführt
*------------------------------------------------------------------
MODULE sonfausw_in_fgruppen OUTPUT.

*-------- Aufbauen Feldauswahl-Tabelle --------------------------------

* Tabelle FAUSWTAB wird in Module FELDAUSWAHL/ANF_FELDAUSWAHL aufgebaut

*mk/12.07.95 Aufbauen Fauswtab_Sond gemäß Fauswtab
  REFRESH fauswtab_sond.
*mk/3.1G/1.2B Tuning: fauswtab ist in der Regel kleiner als ftab_sfgrup
*(ftab_sfgrup ist sortiert)
* LOOP AT FTAB_SFGRUP.
*   READ TABLE FAUSWTAB WITH KEY FTAB_SFGRUP-FNAME BINARY SEARCH.
*   IF SY-SUBRC EQ 0.
*     FAUSWTAB_SOND = FAUSWTAB.
*     APPEND FAUSWTAB_SOND.
*   ENDIF.
* ENDLOOP.
  LOOP AT fauswtab.
    READ TABLE ftab_sfgrup WITH KEY fauswtab-fname BINARY SEARCH.
    IF sy-subrc EQ 0.
      fauswtab_sond = fauswtab.
      APPEND fauswtab_sond.
    ENDIF.
  ENDLOOP.

*-------- Aufrufen FB für Feldauswahl ---------------------------------

* Vereinigung der Sonderfeldauswahl-FB's Retail + Industrie  "BE/100197
* CALL FUNCTION 'MATERIAL_FIELD_SPECIAL_SEL_RT'              "BE/100197
  CALL FUNCTION 'MATERIAL_FIELD_SPECIAL_SEL_NEW'            "BE/100197
       EXPORTING
            kzrfb               = kzrfb
            alt_standardprodukt = *marc-stdpd
            flgsteuer_muss      = rmmg2-steuermuss
*           flg_cad_aktiv       = flg_cad_aktiv   mk/4.0A in RMMG2 integ
            mtart_beskz         = rmmg2-beskz
            imara               = mara                      "ch zu 3.0C
            imarc               = marc
            impop               = mpop
            mpop_prdat_db       = *mpop-prdat
            imyms               = myms
            imbew               = mbew
            imlgt               = mlgt "4.0A  BE/140897
            irmmg1              = rmmg1
            irmmg2              = rmmg2
            irmmw2              = rmmw2                     "cfo/4.6A
            irmmzu              = rmmzu
            irmmw3              = rmmw3
            imgeine             = mgeine
            it130m              = t130m
            it134_wmakg         = t134-wmakg
            it134_vprsv         = t134-vprsv
            it134_kzvpr         = t134-kzvpr
            it134_kzprc         = t134-kzprc
            it134_kzkfg         = t134-kzkfg                "ch zu 3.0C
            omara_kzkfg         = *mara-kzkfg               "ch zu 3.0C
            langtextbild        = langtextbild
            neuflag             = neuflag
            qm_pruefdaten       = marc-qmatv
            aktvstatus          = aktvstatus
            kz_ktext_on_dynp    = kz_ktext_on_dynp
            it133a_pstat        = t133a-pstat               "BE/020896
            it133a_rpsta        = t133a-rpsta               "BE/240297
            p_rmmw2_btwrk       = rmmw2-btwrk               "MK/060996
       IMPORTING
            flgsteuer_muss      = rmmg2-steuermuss
            imbew               = mbew
       TABLES
            fauswtab            = fauswtab_sond
            ptab                = ptab
            ptab_rt             = ptab_rt
            ptab_full           = ptab_full
            steuertab           = steuertab
            steummtab           = steummtab.

*-------- Modifizieren Screen über Feldauswahl-Tabelle ----------------
  CLEAR feldbeztab. REFRESH feldbeztab.
  CLEAR FELDBEZTAB2. REFRESH FELDBEZTAB2.                 "note 1611251

  LOOP AT SCREEN.
*   read table fauswtab_sond with key screen-name binary search. mk/4.0A
    READ TABLE fauswtab_sond WITH KEY fname = screen-name BINARY SEARCH.
    IF sy-subrc EQ 0.
*     read table fauswtab with key screen-name binary search. mk/4.0A
      READ TABLE fauswtab WITH KEY fname = screen-name BINARY SEARCH.
      IF sy-subrc EQ 0.
        fauswtab = fauswtab_sond.
        MODIFY fauswtab INDEX sy-tabix.
      ENDIF.
      screen-active      = fauswtab_sond-kzact.
      screen-input       = fauswtab_sond-kzinp.
      screen-intensified = fauswtab_sond-kzint.
      screen-invisible   = fauswtab_sond-kzinv.
      screen-output      = fauswtab_sond-kzout.
      screen-required    = fauswtab_sond-kzreq.

*     note 1358288: override columns set by TC_VIEW customizing
      IF <F_TC> IS ASSIGNED.
        READ TABLE <F_TC>-COLS INTO TC_COL WITH KEY SCREEN-NAME = SCREEN-NAME.
        IF sy-subrc = 0.
*         If field is set by table control to invisible and it is not
*         required due to material field selection, then hide the field.
*         Otherwise make sure, that the field is not hidden.
          IF TC_COL-INVISIBLE = CX_TRUE AND SCREEN-REQUIRED = 0.
            SCREEN-INVISIBLE = 1.
            SCREEN-ACTIVE    = 1.                          "note 1575018
            SCREEN-OUTPUT    = 1.                          "note 1575018
            SCREEN-INPUT     = 0.
          ELSEIF SCREEN-INVISIBLE = 1.
            SCREEN-ACTIVE    = 1.                          "note 1575018
            SCREEN-OUTPUT    = 1.                          "note 1575018
            TC_COL-INVISIBLE = CX_TRUE.
          ELSE.
            TC_COL-INVISIBLE = CX_FALSE.
          ENDIF.
          TC_COL-SCREEN = SCREEN.
          MODIFY <F_TC>-COLS FROM TC_COL INDEX sy-tabix.
        ENDIF.
      ENDIF.

      MODIFY SCREEN.

*mk/4.0A wieder in FB integriert
*mk/3.0F Butttons Prognose-/Verbrauchswerte ausblenden (keine
*SFGRUP in T130F) beim Planen von Änderungen
*     if screen-name = marc_verb or screen-name = mpop_prgw.
*..............
*     endif.
    ENDIF.
* Festhalten der nicht ausgeblendeten Felder, denen Bezeichnungen
* zugeordnet sind
    IF ( screen-invisible = 0 OR screen-output = 1 ) AND NOT
       screen-group1 IS INITIAL.
      feldbeztab-name   = screen-name.
      feldbeztab-group1 = screen-group1.
      APPEND feldbeztab.
    ENDIF.
*   note 1611251: extend the logic also for SCREEN-GROUP2
    IF ( SCREEN-INVISIBLE = 0 OR SCREEN-OUTPUT = 1 ) AND NOT
       SCREEN-GROUP2 IS INITIAL.
      FELDBEZTAB2-NAME   = SCREEN-NAME.
      FELDBEZTAB2-GROUP1 = SCREEN-GROUP2.
      APPEND FELDBEZTAB2.
    ENDIF.

  ENDLOOP.
  SORT feldbeztab.
  SORT FELDBEZTAB2.                                       "note 1611251

  IF t130m-aktyp EQ aktyph AND NOT rmmg1_ref-matnr IS INITIAL.
*  Prüfen, ob Feld ein für das Vorlagematerial relevantes Währungsfeld
*  ist. In diesem Fall wird das  KZCURR in der Fauswtab gesetzt
    CALL FUNCTION 'MATERIAL_CURRFIELD_REF'
      TABLES
        rptab    = rptab
        fauswtab = fauswtab.
  ENDIF.

ENDMODULE.                    "sonfausw_in_fgruppen OUTPUT


*&---------------------------------------------------------------------*
*&      Module  ZUSREF_VORSCHLAGEN_B  OUTPUT
*&---------------------------------------------------------------------*
*       Vorlagenhandling VOR dem Modul REFDATEN_VORSCHLAGEN            *
*       War ursprünglich in allen PBO Modulen verteilt und wird        *
*       hier zusammengefaßt.
*----------------------------------------------------------------------*
MODULE zusref_vorschlagen_b OUTPUT.

  CHECK t130m-aktyp EQ aktyph.
  CHECK bildflag IS INITIAL.

*--- Pruefen, ob Bild bereits prozessiert wurde ----------------
  CHECK bildtab-kzpro IS INITIAL.

  ref_matnr     = rmmg1_ref-matnr.

*--- Aufrufe der Vorlagehandling - FB's BEFORE -----------------
  PERFORM zusref_vorschlagen_before_d.

ENDMODULE.                             " ZUSREF_VORSCHLAGEN_B  OUTPUT

*------------------------------------------------------------------
*           Sonderregel
*   Bild dunkel prozessieren, wenn FLGDARK sitzt
*mk/30.03.95 Sonderlogik für MARC-STDPD hierher verlagert - war
* bisher im separaten Module STDPD_SONDERHANDLING, das speziell auf
* demjenigen Dispobild ablief, auf dem MARC-STDPD vorhanden ist:
* Falls das Bild zur Konfigurationsbewertung mit F15=Beenden verlassen
* wird, wird das aktuelle Bild (vom dem die Konfigurationsbewertung
* aufgerufen wurd) dunkel prozessiert und der Fcode 'Ende' gesetzt.
* Falls außerdem ein Error innerhalb der Konfigurationsbewertung
* festgestellt wurde, wird der Cursor auf das Feld MARC-STDPD gesetzt
* (Set Cursor ist wirkungslos, wenn Feld nicht auf dem Bild vorhanden -
* ohne Fehler)
*------------------------------------------------------------------
MODULE sonderfaus OUTPUT.

  IF NOT flgdark IS INITIAL.
    ok-code = t130m-fcode.
    SUPPRESS DIALOG.
  ENDIF.
* Sonderhandling für Standardprodukt ----------------------------------
  IF cfcode = fcode_15.
    CLEAR cfcode.
    ok-code = fcode_ende.
    SUPPRESS DIALOG.
  ENDIF.

  IF NOT error_konf IS INITIAL.
    CLEAR error_konf.
    SET CURSOR FIELD 'MARC-STDPD'.
  ENDIF.

ENDMODULE.                    "sonderfaus OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ORG_BEZEICHNUNGEN_LESEN  OUTPUT
*&---------------------------------------------------------------------*
* Nachlesen Texte zu den Org-Ebenen aus zentralem Puffer               *
*mk/28.11.95 Berücksichtigen Retail-Strukturen
*----------------------------------------------------------------------*
MODULE org_bezeichnungen_lesen OUTPUT.

  CALL FUNCTION 'MAIN_PARAMETER_GET_ORG_TEXTE'
    IMPORTING
      wrmmg1_bez = rmmg1_bez
      wrmmw1_bez = rmmw1_bez
      wrmmw1     = rmmw1.
*mk/1.2A1 Bezeichnung zu Lagernr und Lagertyp lesen - diese sind
*noch nicht im Puffer, insbesondere dann nicht, wenn die Werte für
*Lagernr und Lagertyp selbst erst auf dem Bild ermittelt wurden.
  CLEAR rmmg1_bez-lgnum_bez.
  CLEAR rmmg1_bez-lgtyp_bez.
  IF NOT rmmg1-lgnum  IS INITIAL.
    CALL FUNCTION 'T300T_SINGLE_READ'
         EXPORTING
              kzrfb     = kzrfb
*             spras     = sy-langu
*             lgnum     = rmmg1-lgnum
              t300t_spras = sy-langu
              t300t_lgnum = rmmg1-lgnum
         IMPORTING
              wt300t    = t300t
         EXCEPTIONS
              not_found = 01.
    rmmg1_bez-lgnum_bez = t300t-lnumt.
    IF NOT rmmg1-lgtyp IS INITIAL.
      CALL FUNCTION 'T301T_SINGLE_READ'
           EXPORTING
                kzrfb     = kzrfb
*               spras     = sy-langu
*               lgnum     = rmmg1-lgnum
*               lgtyp     = rmmg1-lgtyp
                t301t_spras     = sy-langu
                t301t_lgnum     = rmmg1-lgnum
                t301t_lgtyp     = rmmg1-lgtyp
           IMPORTING
                wt301t    = t301t
           EXCEPTIONS
                not_found = 01.
      rmmg1_bez-lgtyp_bez = t301t-ltypt.
    ENDIF.
  ENDIF.

ENDMODULE.                             " ORG_BEZEICHNUNGEN_LESEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  REFDATEN_VORSCHLAGEN_RT  OUTPUT
*&---------------------------------------------------------------------*
*       Vorlagehandling für Retail.                                    *
*----------------------------------------------------------------------*
MODULE refdaten_vorschlagen_rt OUTPUT.

* variantenbildende Merkmale auf inaktiv setzen, da nicht pflegbar.
* cfo/12.8.96 neu an dieser Stelle, damit inaktiv setzen immer läuft.
  IF t133a-rpsta CA rt_status_c.
    CALL FUNCTION 'MATERIAL_SET_CHAR_VARI_INAKTIV'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

  CHECK ( t130m-aktyp = aktypn OR t130m-aktyp = aktypc
          OR t130m-aktyp = aktyph OR t130m-aktyp = aktypv ).
  CHECK bildflag IS INITIAL OR ( NOT rmmzu-bildproz IS INITIAL ).
  "cfo/20.6.96 bei andere Orgeben sitzt Bildflag!
  "testweise
* CHECK BILDFLAG IS INITIAL.             "kann wegen mehreren OrgEbenen
  "nicht verwendet werden
*----Pruefen, ob Bild bereits prozessiert wurde-----------------
* CHECK BILDTAB-KZPRO IS INITIAL.        "kann wegen mehreren OrgEbenen
  "nicht verwendet werden

* jw/4.6A-A: der Status t133a-pstat enthält auch die Status, die laut
*            Materialart nicht relevant sind. Diese müssen rausgenommen
*            werden -> Schnittmenge t133a-pstat und Aktivstatus

* note 514508
* Status C aktiv und es handelt sich um einen SA -> alten AUSP-Stand
* retten
* note 1601091: set old AUSP values only, if set_data in previos screen
* was done and here also the reference handling is called. Before the
* fm to set the old AUSP values was always called and so contained
* maybe new values (e.g. after scrolling on the char subscreen).
  IF t133a-rpsta CA rt_status_c AND RMMW2-ATTYP = ATTYP_SAMM AND
     RMMW2-VARNR IS INITIAL.
    CALL FUNCTION 'MATERIAL_BUFFER_VALUATION_026'
      EXPORTING
        P_DIALOG_MODE = 'X'
        P_SATNR       = RMMG1-MATNR.
  ENDIF.

  CALL FUNCTION 'SCHNITTMENGE'
    EXPORTING
      status_in1 = aktvstatus
      status_in2 = t133a-pstat
    IMPORTING
      status_out = red_pstat.

* jw/4.6A-E

* cfo/4.0 Erweiterung der Logik:
* Je relevante Tabelle werden Referenzdaten vorgeschlagen oder falls
* Tabelle bereits referenziert wurde, werden Daten von der Vorlage
* Durchgereicht.
  CALL FUNCTION 'MATERIAL_REFERENCE_RT'
       EXPORTING
            p_herkunft    = herkunft_dial
            p_rmmg1       = rmmg1
            p_rmmw2       = rmmw2
            p_kzpro       = rmmzu-bildproz
            p_mtart_beskz = rmmg2-beskz
*            p_status      = t133a-pstat          jw/4.6A
            p_status      = red_pstat                       "jw/4.6A
            p_rtstatus    = t133a-rpsta
            p_aktvstatus  = aktvstatus                      "jw/4.6A
            kzrfb         = kzrfb
            maxtz         = maxtz
            sperrmodus    = sperrmodus
            p_bildflag    = bildflag
            p_buchen      = flg_pruefdunkel       "cfo/11.2.97
            p_neuflag     = neuflag                         "cfo/4.0C
            p_t130m       = t130m                           "cfo/4.6A
            p_call_mode2  = rmmg2-call_mode2                "vst/4.6A
       TABLES
            wktext        = ktext
            wmeinh        = meinh
            wsteuertab    = steuertab
            wsteummtab    = steummtab
            wmamt         = tmamt
            wmalg         = tmalg
       CHANGING
            wmara         = mara
            wmaw1         = maw1
            wmakt         = makt
            wmarc         = marc
            wmard         = mard
            wmvke         = mvke
            wmlgn         = mlgn
            wmlgt         = mlgt
            wmpop         = mpop
            wmpgd         = mpgd
            wmfhm         = mfhm
            wmbew         = mbew
            wmyms         = myms
            weina         = eina
            weine         = eine
            wwlk2         = wlk2
            p_lmara       = lmara                           "cfo/4.0
            p_lmaw1       = lmaw1                           "cfo/4.0
       EXCEPTIONS
            OTHERS        = 1.

* Falls Verkaufsstatus relevant, VerkaufsME füllen falls leer
* cfo/12.9.96 Füllen der VerkaufsME auch bei Industriestatus V, da
* bei Springen auf VK-Bild der Key-Umsetzer nicht läuft, wenn der
* Industriestatus V bereits im AKTVSTATUS enthalten ist.

* note 838638 einmal neu setzen, wenn Vertriebslinie sich ändert,
* aber nicht auf Verkaufsicht, da dort von Gültigkeitspopup vorgegeben
  IF ( rmmg1-vkorg <> GV_LAST_VKORG OR rmmg1-vtweg <> GV_LAST_VTWEG )
  AND t133a-rpsta NA rt_status_v.
    CLEAR first_vk.
    GV_LAST_VKORG = rmmg1-vkorg.
    GV_LAST_VTWEG = rmmg1-vtweg.
  ENDIF.

*note 610925
*  IF ( t133a-rpsta CA rt_status_v OR t133a-pstat CA status_v )
*     AND rmmw2-vrkme IS INITIAL.
  IF ( t133a-rpsta CA rt_status_v OR t133a-pstat CA status_v )
       and first_VK is initial.
* note 1800255
*  note 678913
*      if not rmmw2-vrkme is initial.
*         first_vk = 'X'.
*      endif.

    IF NOT rmmg1-vkorg IS INITIAL.
      IF NOT mvke-vrkme IS INITIAL.
        rmmw2-vrkme = mvke-vrkme.
      ELSE.
        rmmw2-vrkme = mara-meins.
      ENDIF.
    ELSE.                              "cfo/12.9.96
      IF NOT maw1-wvrkm IS INITIAL.
        rmmw2-vrkme = maw1-wvrkm.
      ELSE.
        rmmw2-vrkme = mara-meins.
      ENDIF.
    ENDIF.
    rmmw1-vrkme = rmmw2-vrkme.
* note 1800255
    IF NOT rmmw2-vrkme IS INITIAL AND t133a-rpsta CA rt_status_v.
      first_vk = 'X'.
    ENDIF.
*mk/17.06.96 zusätzlich Bezeichnung ermitteln und alles in den Puffer
*setzen (normalerweise werden Keys auf Datenbildern nicht verändert)
    IF t006a-spras NE sy-langu OR t006a-msehi NE rmmw1-vrkme.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = rmmw1-vrkme
          language       = sy-langu
        IMPORTING
          long_text      = t006a-msehl
          output         = t006a-mseh3
          short_text     = t006a-mseht
        EXCEPTIONS
          unit_not_found = 01.
    ELSE.
      sy-subrc = 0.
    ENDIF.
    IF sy-subrc NE 0.
      CLEAR t006a.
    ENDIF.
    rmmw1_bez-vrkme_bez  = t006a-mseht.
    CALL FUNCTION 'MAIN_PARAMETER_SET_KEYS_SUB'
      EXPORTING
        wrmmw2     = rmmw2
        wrmmw1     = rmmw1
        wrmmw1_bez = rmmw1_bez
        wusrm3     = husrm3      "mk/17.06.96
      EXCEPTIONS
        OTHERS     = 1.
  ENDIF.

* Durchreichen Änderungen an dazugelesene Sätze.
* cfo/4.0 Wird jetzt im FB MATERIAL_REFRENCE_RT gemacht.
*  CALL FUNCTION 'MATERIAL_REFCHANGE_RT_PBO'
*       EXPORTING
*            P_RMMG1       = RMMG1
*            P_RMMW2       = RMMW2
*            P_MTART_BESKZ = RMMG2-BESKZ
*            P_STATUS      = T133A-PSTAT
*            P_RTSTATUS    = T133A-RPSTA
*            KZRFB         = KZRFB
*            MAXTZ         = MAXTZ
*            SPERRMODUS    = SPERRMODUS
*       TABLES
*            WMEINH        = MEINH
*            WMALG         = TMALG
*            WSTEUERTAB    = STEUERTAB
*            WSTEUMMTAB    = STEUMMTAB
*       CHANGING
*            WMARA         = MARA
*            WMARC         = MARC
*            DMARC         = *MARC
*            WMBEW         = MBEW
*            DMBEW         = *MBEW
*            WMARD         = MARD
*            WMPOP         = MPOP
*            WMPGD         = MPGD
*            WMFHM         = MFHM
*            WMLGN         = MLGN
*            WMLGT         = MLGT
*            WMVKE         = MVKE
*            WWLK2         = WLK2
*       EXCEPTIONS
*            OTHERS        = 1.

  IF t133a-rpsta CA rt_status_l.
    CALL FUNCTION 'MWLI_GET_BILD'
      EXPORTING
        matnr  = rmmg1-matnr
        vkorg  = rmmg1-vkorg
        vtweg  = rmmg1-vtweg
        wmvke  = mvke
        omvke  = *mvke
        wmaw1  = maw1
        omaw1  = *maw1
      IMPORTING
        wmwli  = mwli
        xmwli  = *mwli
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.
*mk/12.09.96 Setzen der allgemeinen Daten in den Puffer für die
*Varianten, damit bei Zugriffen der externen Anwendungen (insbesondere
*VKP-Kalkulation) die logisch erzeugten Daten auch vorhanden sind
*(MAKT und MARM sind bereits erzeugt)
*                                                note 587500

*  IF RMMW2-ATTYP = ATTYP_SAMM.
*    CALL FUNCTION 'MARA_SET_DATA'
*         EXPORTING
*              WMARA  = MARA
*         EXCEPTIONS
*              OTHERS = 1.
*    CALL FUNCTION 'MAW1_SET_DATA'
*         EXPORTING
*              WMAW1  = MAW1
*         EXCEPTIONS
*              OTHERS = 1.
*    CALL FUNCTION 'MLAN_SET_DATA'
*         EXPORTING
*              MATNR      = RMMG1-MATNR
*              VKORG      = SPACE
*              VTWEG      = SPACE
*              WERKS      = SPACE
*         TABLES
*              WSTEUERTAB = STEUERTAB
*              WSTEUMMTAB = STEUMMTAB
*         EXCEPTIONS
*              OTHERS     = 1.
*  ENDIF.
*                                                note 587500
  IF rmmw2-attyp = attyp_samm.

    CALL FUNCTION 'MARA_SET_DATA'
         EXPORTING
              wmara  = mara
         EXCEPTIONS
              OTHERS = 1.

    CALL FUNCTION 'MAW1_SET_DATA'
         EXPORTING
              wmaw1  = maw1
         EXCEPTIONS
              OTHERS = 1.

    CALL FUNCTION 'MLAN_SET_DATA'
         EXPORTING
              matnr      = rmmg1-matnr
              vkorg      = space
              vtweg      = space
              werks      = space
         TABLES
              wsteuertab = steuertab
              wsteummtab = steummtab
         EXCEPTIONS
              OTHERS     = 1.

ELSE.
    IF T133A-RPSTA = RT_STATUS_V.
    CALL FUNCTION 'MLAN_SET_DATA'
         EXPORTING
              matnr      = rmmg1-matnr
              vkorg      = space
              vtweg      = space
              werks      = space
         TABLES
              wsteuertab = steuertab
              wsteummtab = steummtab
         EXCEPTIONS
              OTHERS     = 1.
    ENDIF.
  ENDIF.

ENDMODULE.                             " REFDATEN_VORSCHLAGEN_RT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FELDHISTORIE  OUTPUT
*&---------------------------------------------------------------------*
*  noch nicht benutzt                                                  *
*----------------------------------------------------------------------*
MODULE feldhistorie OUTPUT.

ENDMODULE.                             " FELDHISTORIE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SGT_HANDLE_WM_BUTTON  OUTPUT
*&---------------------------------------------------------------------*
*     Handling the "Segmentation in Warehouse" button
*----------------------------------------------------------------------*
MODULE sgt_handle_wm_button OUTPUT.

PERFORM handle_wm_button.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_BATCH OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_batch OUTPUT.
  IF mara-xchpf = 'X' AND mara-sgt_covsa IS NOT INITIAL
     AND mara-sgt_scope = '1' AND marc-xchpf IS INITIAL.
    marc-xchpf = 'X'.
   ELSEIF mara-xchpf = 'X' AND mara-sgt_covsa IS INITIAL
           AND marc-xchpf IS INITIAL.
    marc-xchpf = 'X'.
  ENDIF.
ENDMODULE.
