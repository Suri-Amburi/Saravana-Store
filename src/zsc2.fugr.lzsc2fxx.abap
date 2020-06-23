*-------------------------------------------------------------------
***INCLUDE LMGD2FXX .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  Init_Baustein
* Einstieg in das Programm, dem der Bildbaustein zugeordnet ist
* - Holen der zentralen Steuerungsparameter beim 1. Aufruf des Programms
* - Holen der Steuerungsdaten für den Bildbaustein
*mk/28.11.95 Änderung Aufruf ._get_dynproparam - Aktvstatus/RMMG1/PTAB
*hier nicht geholt, da in ._get_zus_sub
*&---------------------------------------------------------------------*
FORM INIT_BAUSTEIN.

*--- Holen zentrale Programm-Parameter beim 1. Aufruf des Programms ---
  IF KZ_INIT IS INITIAL.
    PERFORM MAIN_PARAMETER_GET.
    KZ_INIT = X.
  ENDIF.
*--- Holen bildbausteinspezifische Steuerungsparameter und Zurücksetzen
*--- des Kennz. Bildbeginn im Puffer
  CALL FUNCTION 'MAIN_PARAMETER_GET_DYNPROPARAM'
       IMPORTING
            WT133A           = T133A
            KZ_EIN_PROGRAMM  = KZ_EIN_PROGRAMM
            ANZ_SUBSCREENS   = ANZ_SUBSCREENS
            KZ_BILDBEGINN    = KZ_BILDBEGINN
            BILDFLAG         = BILDFLAG
            TRAEGER_PROGRAMM = TRAEGER_PROGRAMM
            TRAEGER_DYNPRO   = TRAEGER_DYNPRO
            KZ_KTEXT_ON_DYNP = KZ_KTEXT_ON_DYNP
            BILDTAB          = BILDTAB
            CURS_FELD        = RMMZU-CURS_FELD  "CFO/271095
            BILDPROZ         = RMMZU-BILDPROZ  "CFO/271095
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE. "mk/13.08.96

* SET_CURSOR für den jeweiligen Bildbaustein.
  IF RMMZU-CURS_FELD NE SPACE.         " erweitert //br160496
    IF RMMZU-CURS_LINE NE SPACE.                            "
      SET CURSOR FIELD RMMZU-CURS_FELD LINE RMMZU-CURS_LINE."
    ELSE.                                                   "
      SET CURSOR FIELD RMMZU-CURS_FELD.                     "
    ENDIF.                                                  "
  ENDIF.                                                    "

ENDFORM.

*-----------------------------------------------------------------------
FORM MAKT_GET_SUB.

  CALL FUNCTION 'MAKT_GET_SUB'
       IMPORTING
            WMAKT  = MAKT
            XMAKT  = *MAKT
            YMAKT  = LMAKT
       TABLES
            WKTEXT = KTEXT
            XKTEXT = DKTEXT
            YKTEXT = LKTEXT.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM MARM_GET_SUB                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MARM_GET_SUB.

  CALL FUNCTION 'MARM_GET_SUB'
* AHE: 21.03.99 - A (4.6a)
       EXPORTING
            P_MATNR = MARA-MATNR
* AHE: 21.03.99 - E
       TABLES
            WMEINH  = MEINH
            XMEINH  = DMEINH
            YMEINH  = LMEINH.

* AHE: 19.10.95
* zus. EANs werden immer zusammen mit den Mengeneinheiten behandelt;
  CALL FUNCTION 'MEAN_GET_SUB'
* AHE: 08.04.99 - A (4.6a)
       EXPORTING
            P_MATNR = MARA-MATNR
* AHE: 08.04.99 - E
       TABLES
            WMEAN = MEAN_ME_TAB
            XMEAN = DMEAN_ME_TAB
            YMEAN = LMEAN_ME_TAB.

* AHE: 06.06.96
* lieferantenbezogene EANs ebenfalls
  CALL FUNCTION 'MLEA_GET_SUB'
* AHE: 08.04.99 - A (4.6a)
       EXPORTING
            P_MATNR = MARA-MATNR
* AHE: 08.04.99 - E
       TABLES
            WMLEA = TMLEA
            XMLEA = DMLEA
            YMLEA = LMLEA.


* AHE: 09.04.99 - A (4.6a)
* Pflege Varianten-EANs aus SA heraus; zusätzliche Tabellen füllen
  IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
     RMMW1-ATTYP = ATTYP_SAMM AND
     RMMW1-VARNR IS INITIAL.

* MEAN
    CALL FUNCTION 'MEAN_GET_SUB_GEN_MATNR'
         TABLES
              WMEAN_FULL = MEAN_ME_TAB_SA
              XMEAN_FULL = DMEAN_ME_TAB_SA
              YMEAN_FULL = LMEAN_ME_TAB_SA.

* MARM
    CALL FUNCTION 'MARM_GET_SUB_GEN_MATNR'
         TABLES
              WMEINH_FULL = MEINH_SA
              XMEINH_FULL = DMEINH_SA
              YMEINH_FULL = LMEINH_SA.

* MLEA
    CALL FUNCTION 'MLEA_GET_SUB_GEN_MATNR'
         TABLES
              WMLEA = TMLEA_SA
              XMLEA = DMLEA_SA
              YMLEA = LMLEA_SA.

  ENDIF.
* AHE: 09.04.99 - E

ENDFORM.

*---------------------------------------------------------------------*
*       FORM MLAN_GET_SUB                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MLAN_GET_SUB.

  CALL FUNCTION 'MLAN_GET_SUB'
       TABLES
            WSTEUERTAB = STEUERTAB
            XSTEUERTAB = DSTEUERTAB
            YSTEUERTAB = LSTEUERTAB
            WSTEUMMTAB = STEUMMTAB
            XSTEUMMTAB = DSTEUMMTAB
            YSTEUMMTAB = LSTEUMMTAB.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM MAKT_SET_SUB                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MAKT_SET_SUB.

  CALL FUNCTION 'MAKT_SET_SUB'
       EXPORTING
            WMAKT  = MAKT
            MATNR  = RMMG1-MATNR
       TABLES
            WKTEXT = KTEXT.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM MARM_SET_SUB                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MARM_SET_SUB.

  CALL FUNCTION 'MARM_SET_SUB'
       EXPORTING
            MATNR  = RMMG1-MATNR
       TABLES
            WMEINH = MEINH.

* AHE: 19.10.95
* zus. EANs werden immer zusammen mit den Mengeneinheiten behandelt;
  CALL FUNCTION 'MEAN_SET_SUB'
       EXPORTING
            MATNR = RMMG1-MATNR
       TABLES
            WMEAN = MEAN_ME_TAB.

* AHE: 06.06.96
* lieferantenbezogene EANs ebenfalls
  CALL FUNCTION 'MLEA_SET_SUB'
       EXPORTING
            MATNR = RMMG1-MATNR
       TABLES
            WMLEA = TMLEA.


* AHE: 09.04.99 - A (4.6a)
* Pflege Varianten-EANs aus SA heraus; zusätzliche Tabellen füllen
  IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
     RMMW1-ATTYP = ATTYP_SAMM AND
     RMMW1-VARNR IS INITIAL.

* MEAN_ME_TAB_SA muß an evtl. upgedatete MEAN angepaßt werden, damit der
* Puffer nicht zerschossen wird. Hier befinden wir uns in der Pflege
* des Sammelartikels selbst --> RMMW2-SATNR als Key

*   ... aber nur, wenn man nicht auf dem EAN-Bild selbst ist
    IF SY-DYNNR <> '8025'.
      LOOP AT MEAN_ME_TAB.
        READ TABLE MEAN_ME_TAB_SA
                      WITH KEY MATNR = RMMW2-SATNR
                               MEINH = MEAN_ME_TAB-MEINH
                               EAN11 = MEAN_ME_TAB-EAN11 BINARY SEARCH.
        HTABIX = SY-TABIX.
        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING MEAN_ME_TAB TO MEAN_ME_TAB_SA.
          MODIFY MEAN_ME_TAB_SA INDEX HTABIX.
        ELSE.
          MOVE-CORRESPONDING MEAN_ME_TAB TO MEAN_ME_TAB_SA.
          MEAN_ME_TAB_SA-MATNR = RMMW2-SATNR.
          INSERT MEAN_ME_TAB_SA INDEX HTABIX.
        ENDIF.
      ENDLOOP.

      READ TABLE MEAN_ME_TAB_SA WITH KEY
                                MATNR = RMMW2-SATNR BINARY SEARCH.
      HTABIX = SY-TABIX.
      LOOP AT MEAN_ME_TAB_SA FROM HTABIX.
        IF MEAN_ME_TAB_SA-MATNR <> RMMW2-SATNR.
          EXIT.
        ENDIF.
        READ TABLE MEAN_ME_TAB WITH KEY MEINH = MEAN_ME_TAB_SA-MEINH
                                        EAN11 = MEAN_ME_TAB_SA-EAN11.
        IF SY-SUBRC <> 0.
          DELETE MEAN_ME_TAB_SA.
        ENDIF.
      ENDLOOP.
    ENDIF.

* MEAN - Daten in den Puffer
    CALL FUNCTION 'MEAN_SET_SUB_GEN_MATNR'
         TABLES
              WMEAN_FULL = MEAN_ME_TAB_SA.


* TMLEA_SA muß an evtl. upgedatete TMLEA angepaßt werden, damit der
* Puffer nicht zerschossen wird. Hier befinden wir uns in der Pflege
* des Sammelartikels selbst --> RMMW2-SATNR als Key

    IF SY-DYNNR <> '8025'.
      LOOP AT TMLEA.
        READ TABLE TMLEA_SA
                      WITH KEY MATNR = RMMW2-SATNR
                               MEINH = TMLEA-MEINH
                               LIFNR = TMLEA-LIFNR
                               EAN11 = TMLEA-EAN11 BINARY SEARCH.
        HTABIX = SY-TABIX.
        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING TMLEA TO TMLEA_SA.
          MODIFY TMLEA_SA INDEX HTABIX.
        ELSE.
          MOVE-CORRESPONDING TMLEA TO TMLEA_SA.
          TMLEA_SA-MATNR = RMMW2-SATNR.
          INSERT TMLEA_SA INDEX HTABIX.
        ENDIF.
      ENDLOOP.

      READ TABLE TMLEA_SA WITH KEY MATNR = RMMW2-SATNR BINARY SEARCH.
      HTABIX = SY-TABIX.
      LOOP AT TMLEA_SA FROM HTABIX.
        IF TMLEA_SA-MATNR <> RMMW2-SATNR.
          EXIT.
        ENDIF.
        READ TABLE TMLEA WITH KEY MATNR = RMMW2-SATNR
                                  MEINH = TMLEA_SA-MEINH
                                  LIFNR = TMLEA_SA-LIFNR
                                  EAN11 = TMLEA_SA-EAN11 BINARY SEARCH.
        IF SY-SUBRC <> 0.
          DELETE TMLEA_SA.
        ENDIF.
      ENDLOOP.
    ENDIF.

* MLEA - Daten in den Puffer
    CALL FUNCTION 'MLEA_SET_SUB_GEN_MATNR'
         TABLES
              WMLEA = TMLEA_SA.


* MEINH_SA muß an evtl. upgedatete MEINH angepaßt werden, damit der
* Puffer nicht zerschossen wird. Hier befinden wir uns in der Pflege
* des Sammelartikels selbst --> RMMW2-SATNR als Key

    IF SY-DYNNR <> '8025'.
*    da in der MEINH auch doppelte Einträge vorkommen können, kann nicht
*    mit der unten beschriebenen Technik gearbeitet werden.
*    --> erst alles zum SA löschen, dann alles aus der MEINH in die
*    MEINH_SA dranhängen dann SORT --> Doppeleinträge drin und O.K. so!

      READ TABLE MEINH_SA WITH KEY MATNR = RMMW2-SATNR BINARY SEARCH.
      HTABIX = SY-TABIX.
      LOOP AT MEINH_SA FROM HTABIX.
        IF MEINH_SA-MATNR <> RMMW2-SATNR.
          EXIT.
        ENDIF.
        DELETE MEINH_SA.
      ENDLOOP.

      LOOP AT MEINH.
        MOVE-CORRESPONDING MEINH TO MEINH_SA.
        MEINH_SA-MATNR = RMMW2-SATNR.
        APPEND MEINH_SA.
      ENDLOOP.

      SORT MEINH_SA BY MATNR MEINH.

*     LOOP AT MEINH.
*       READ TABLE MEINH_SA WITH KEY MATNR = RMMW2-SATNR
*                                    MEINH = MEINH-MEINH BINARY SEARCH.
*       HTABIX = SY-TABIX.
*       IF SY-SUBRC = 0.
*         MOVE-CORRESPONDING MEINH TO MEINH_SA.
*         MODIFY MEINH_SA INDEX HTABIX.
*       ELSE.
*         MOVE-CORRESPONDING MEINH TO MEINH_SA.
*         MEINH_SA-MATNR = RMMW2-SATNR.
*         INSERT MEINH_SA INDEX HTABIX.
*       ENDIF.
*     ENDLOOP.

*     READ TABLE MEINH_SA WITH KEY MATNR = RMMW2-SATNR BINARY SEARCH.
*     HTABIX = SY-TABIX.
*     LOOP AT MEINH_SA FROM HTABIX.
*       IF MEINH_SA-MATNR <> RMMW2-SATNR.
*         EXIT.
*       ENDIF.
*       READ TABLE MEINH WITH KEY MEINH = MEINH_SA-MEINH.
*       IF SY-SUBRC <> 0.
*         DELETE MEINH_SA.
*       ENDIF.
*     ENDLOOP.
    ENDIF.

* MEINH - Daten in den Puffer
    CALL FUNCTION 'MARM_SET_SUB_GEN_MATNR'
         TABLES
              WMEINH_FULL = MEINH_SA.



* AHE: 22.10.99 - A (4.6c) HW 180283
* Für den Fall, daß EANs zur Basismengeneinheit von Varianten erfaßt
* wurden auf dem EAN - Bild, müssen die rel. Varianten-MARAs upgedatet
* werden im Puffer. Dies ist aber nur auf dem EAN-Bild notwendig.

    IF SY-DYNNR = '8025'.
* Varianten lesen
      CALL FUNCTION 'MATERIAL_READ_VAR_TAB'
           EXPORTING
                IMP_SATNR   = RMMW1-MATNR  " hier Sammelartikel
           TABLES
                EXP_VAR_TAB = HVARTAB
           EXCEPTIONS
                WRONG_SATNR = 1
                OTHERS      = 2.

      IF SY-SUBRC = 0.

* Varianten sammeln
        REFRESH IPRE03_BUF.
        LOOP AT HVARTAB.
          IPRE03_BUF-MATNR = HVARTAB-VARNR.
          APPEND IPRE03_BUF.
        ENDLOOP.

* Varianten - MARAs lesen aus dem Puffer
        CALL FUNCTION 'MARA_ARRAY_READ_MAT_ALL_BUFFER'
             TABLES
                  IPRE03   = IPRE03_BUF
                  MARA_TAB = MARA_BUF.

        REFRESH IPRE03_BUF.

* Varianten - MARAs im EAN-Feld updaten
        LOOP AT MEAN_ME_TAB_SA WHERE NOT HPEAN IS INITIAL.
* nur Haupt-EANs
          READ TABLE MARA_BUF WITH KEY MANDT = SY-MANDT
                                       MATNR = MEAN_ME_TAB_SA-MATNR
                                       BINARY SEARCH.    "#EC CI_SORTED

          HTABIX = SY-TABIX.

          IF SY-SUBRC = 0.
* und nur die zur Basismengeneinheit
            IF MEAN_ME_TAB_SA-MEINH = MARA_BUF-MEINS.
              IF MARA_BUF-EAN11 <> MEAN_ME_TAB_SA-EAN11 OR
                 MARA_BUF-NUMTP <> MEAN_ME_TAB_SA-NUMTP.
                MARA_BUF-EAN11 = MEAN_ME_TAB_SA-EAN11.
                MARA_BUF-NUMTP = MEAN_ME_TAB_SA-NUMTP.
                MODIFY MARA_BUF INDEX HTABIX.
* veränderte Varianten-MARAs merken
                IPRE03_BUF-MATNR = MARA_BUF-MATNR.
                COLLECT IPRE03_BUF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

* Haupt-EANs von Varianten gelöscht ?
        LOOP AT MARA_BUF.
          IF NOT MARA_BUF-EAN11 IS INITIAL.
            READ TABLE MEAN_ME_TAB_SA WITH KEY MATNR = MARA_BUF-MATNR
                                               MEINH = MARA_BUF-MEINS
                                               EAN11 = MARA_BUF-EAN11
                                               BINARY SEARCH.
            IF SY-SUBRC <> 0.
* kein Satz mehr im Puffer zur MATNR / MEINH --> MARA-EAN löschen
              CLEAR MARA_BUF-EAN11.
              CLEAR MARA_BUF-NUMTP.
              MODIFY MARA_BUF.
* veränderte Varianten-MARAs merken
              IPRE03_BUF-MATNR = MARA_BUF-MATNR.
              COLLECT IPRE03_BUF.
            ENDIF.
          ENDIF.
        ENDLOOP.

* geänderte Varianten - MARAs wieder in den Puffer zurück
        CALL FUNCTION 'MARA_SET_DATA_ARRAY'
             TABLES
                  MARA_TAB = MARA_BUF.


* PTAB für Varianten updaten / anlegen, da sonst EANs nicht verbucht
        CALL FUNCTION 'MATERIAL_PTAB_FULL_GET'
*            EXPORTING
*                 IRMMG1    =
             TABLES
                  PTAB_FULL = PTAB_FULL_BUF.
*                 PTAB      =

* PTAB - MARA-Einträge für relevante Varianten aufbauen, falls nicht
* vorhanden.
* Vorgehen: Es werden die (müssen da sein) zum Sammelartikel vorhandenen
* Einträge in der PTAB für MARA und MARM als Vorlage genommen, um die
* analogen Einträge für die geänderten Varianten aufzubauen.
* Die betroffenen Varianten stehen nun in IPRE03_BUF.

        SORT IPRE03_BUF.

        READ TABLE PTAB_FULL_BUF WITH KEY MATNR = RMMW1-MATNR
                                          TBNAM = T_MARA.
        IF SY-SUBRC = 0.
          PTAB_MARA_REF = PTAB_FULL_BUF.
          READ TABLE PTAB_FULL_BUF WITH KEY MATNR = RMMW1-MATNR
                                            TBNAM = T_MARM.
          IF SY-SUBRC = 0.
            PTAB_MARM_REF = PTAB_FULL_BUF.

* loop über die geänderten VAR.-MATNRs
            LOOP AT IPRE03_BUF.
             READ TABLE PTAB_FULL_BUF WITH KEY MATNR = IPRE03_BUF-MATNR
                                                 TBNAM = T_MARA.
              IF SY-SUBRC <> 0.
                PTAB_FULL_BUF = PTAB_MARA_REF.
                PTAB_FULL_BUF-MATNR = IPRE03_BUF-MATNR.
                APPEND PTAB_FULL_BUF.
              ENDIF.

             READ TABLE PTAB_FULL_BUF WITH KEY MATNR = IPRE03_BUF-MATNR
                                                 TBNAM = T_MARM.
              IF SY-SUBRC <> 0.
                PTAB_FULL_BUF = PTAB_MARM_REF.
                PTAB_FULL_BUF-MATNR = IPRE03_BUF-MATNR.
                APPEND PTAB_FULL_BUF.
              ENDIF.

            ENDLOOP.

          ENDIF.

        ENDIF.

        CALL FUNCTION 'MATERIAL_PTAB_FULL_SET'
             TABLES
                  PTAB_FULL = PTAB_FULL_BUF.

      ENDIF.

    ENDIF.
* AHE: 22.10.99 - E

  ENDIF.
* AHE: 09.04.99 - E

ENDFORM.

*---------------------------------------------------------------------*
*       FORM MLAN_SET_SUB                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MLAN_SET_SUB.

  CALL FUNCTION 'MLAN_SET_SUB'
       TABLES
            WSTEUERTAB = STEUERTAB
            WSTEUMMTAB = STEUMMTAB.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  Zusdaten_Get_SUB
*&---------------------------------------------------------------------*
* //br141195(30C) BILDFLAG ergänzt
*mk/28.11.95 zusätzliche Parameter Retail, sowie Aktvstatus/RMMG1
*mk/07.12.95 Außerdem PTAB_RT für Retail-Tabellen sowie die
*erweiterten PTAB'S (PTAB_FULL und PTAB_FULL_RT) mit vollem Key
*zu der relevanten Key-Kombination
*mk/29.04.96 PTAB muss immer zur PTAB_FULL passen, dies ist bei der
*PTAB aus dem zentralen Puffer nicht gewährleistet wegen der
*doppelten Logistikdaten. Die GET_FB's für die volle PTAB baut sowieso
*immer die richtige kurze PTAB parallel auf.
*----------------------------------------------------------------------*
FORM ZUSATZDATEN_GET_SUB.

  CALL FUNCTION 'MAIN_PARAMETER_GET_ZUS_SUB'
       IMPORTING
            WRMMZU     = RMMZU
            WRMMG2     = RMMG2
            BILDFLAG   = BILDFLAG
            WRMMW2     = RMMW2
            WRMMW3     = RMMW3
            WRMMWZ     = RMMWZ
            WRMMG1     = RMMG1
            WRMMW1     = RMMW1
            WRMMW1_BEZ = RMMW1_BEZ
            WUSRM3     = HUSRM3        "mk/17.06.96
            AKTVSTATUS = AKTVSTATUS
            WRLTEX     = RLTEX
            WCALP      = CALP.          "note 1249444
*      TABLES                                    mk/29.04.96
*          MTAB        = PTAB
*          MTAB_RT     = PTAB_RT.


* note 623656
  PERFORM ZUSATZDATEN_GET_RLTEX.

  CALL FUNCTION 'MATERIAL_PTAB_FULL_GET'
       EXPORTING
            IRMMG1    = RMMG1
       TABLES
            PTAB_FULL = PTAB_FULL
            PTAB      = PTAB           "mk/29.04.96
       EXCEPTIONS
            OTHERS    = 1.
  CALL FUNCTION 'MATERIAL_PTAB_FULL_GET_RT'
       EXPORTING
            IRMMG1       = RMMG1
            IRMMW2       = RMMW2
       TABLES
            PTAB_FULL_RT = PTAB_FULL_RT
            PTAB_RT      = PTAB_RT     "mk/29.04.96
       EXCEPTIONS
            OTHERS       = 1.

*Lesen von Daten, die im Industriefall bereits im material_read_all
*ermittelt werden
*mk/1.2A1 Lesen T001W und T001
*T001W wird für Fremdschlüsselprüfung benötigt?, T001 für die
*Anzeige der Währung sowie der Vorperiode sowie zur Ermittlung des
*Kostenrechnungskreises (s.u.)
*mk/1.2B  Ermitteln des Kostenrechnungskreises für die Prüfung
* von MBEW-HRKFT (standardmäßig noch nicht pflegbar)
*Zusätzlich Lesen Basis-ME zum Vorplanungsmaterial (nur Anzeige)
*(wäre besser analog zu Bezeichnungen gesteuert, aber Aufwärtskompatib.)
*Zusätzlich zurücksetzen der Daten, falls Werk initial ist, außerdem
*nur noch Ablauf der Logik, wenn das Werk geändert wurde (hwerk wird
*im Module Init_sub gesetzt).
* IF not RMMG1-WERKS IS INITIAL.   "mk/1.2B
  IF RMMG1-WERKS IS INITIAL.
    CLEAR: T001, T001W, RMMG2-KOKRS, RMMZU-VPBME.
  ELSE.
    IF HWERK NE RMMG1-WERKS.
      CALL FUNCTION 'ACCOUNTING_KEYS_READ_FOR_PLANT'
           EXPORTING
                KZRFB            = KZRFB
                WERKS            = RMMG1-WERKS
*               FLG_WO_MARV      = X        "ch zu 4.0C
                FLG_WO_MARV      = SPACE    "ch zu 4.0C
           IMPORTING
                WT001            = T001
                WMARV            = MARV"ch zu 4.0C
                WT001W           = T001W
           EXCEPTIONS
                OTHERS           = 1.
* Ab 4.0C: Merken der MARV-Perioden in RMMZU   /ch
      RMMZU-LFMON = MARV-LFMON.
      RMMZU-LFGJA = MARV-LFGJA.
      RMMZU-VMMON = MARV-VMMON.
      RMMZU-VMGJA = MARV-VMGJA.
      RMMZU-VJMON = MARV-VJMON.
      RMMZU-VJGJA = MARV-VJGJA.
*Ermitteln Kostenrechnungskreis
      IF NOT T001-BUKRS IS INITIAL.
        CALL FUNCTION 'RK_KOKRS_FIND'
             EXPORTING
                  BUKRS  = T001-BUKRS
             IMPORTING
                  KOKRS  = RMMG2-KOKRS
             EXCEPTIONS
                  OTHERS = 1.
      ENDIF.
      IF NOT MPGD-PRGRP IS INITIAL.
* Ermitteln Basis-ME zum Vorplanungsmaterial ------------------------
        IF MPGD-PRGRP EQ MARA-MATNR.
          RMMZU-VPBME = MARA-MEINS.
        ELSE.
*---- Lesen Vorplanungsmaterial ---------------------------------------
          CLEAR RMMZU-VPBME.
          CALL FUNCTION 'MARA_SINGLE_READ'
               EXPORTING
                    KZRFB      = KZRFB
                    MATNR      = MPGD-PRGRP
                    MAXTZ      = 0
                    SPERRMODUS = SPERRMODUS_N
               IMPORTING
                    WMARA      = HMARA
               EXCEPTIONS
                    OTHERS     = 01.
          IF SY-SUBRC EQ 0.
            RMMZU-VPBME = MARA-MEINS.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  Zusdaten_Set_BILD
*mk/28.11.95 zusätzliche Parameter Retail
*&---------------------------------------------------------------------*
FORM ZUSATZDATEN_SET_SUB.

* note 637753
  PERFORM ZUSATZDATEN_SET_RLTEX.

  CALL FUNCTION 'MAIN_PARAMETER_SET_ZUS_SUB'
       EXPORTING
            WRMMZU      = RMMZU
            WRMMG2      = RMMG2
            RMMG1_SPRAS = RMMG1-SPRAS
            BILDFLAG    = BILDFLAG
            WRMMW3      = RMMW3
            WRMMWZ      = RMMWZ
            WRMMW1      = RMMW1
            WUSRM3      = HUSRM3       "mk/17.06.96
            WRMMW1_BEZ  = RMMW1_BEZ
            WRMMG1      = RMMG1        "mk/1.2A1
            WRLTEX      = RLTEX
            WCALP       = CALP.        "note 987287

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZUSATZDATEN_GET_RLTEX
*&---------------------------------------------------------------------*
form ZUSATZDATEN_GET_RLTEX .

  LANGTEXTBILD = RLTEX-LANGTEXTBILD.
  LANGTXTVKORG = RLTEX-LANGTXTVKORG.
  LANGTXTVTWEG = RLTEX-LANGTXTVTWEG.
  LANGTEXT_MATNR_BEST = RLTEX-LANGTEXT_MATNR_BEST.
  LANGTEXT_MATNR_GRUN = RLTEX-LANGTEXT_MATNR_GRUN.
  LANGTEXT_MATNR_IVER = RLTEX-LANGTEXT_MATNR_IVER.
  LANGTEXT_MATNR_PRUE = RLTEX-LANGTEXT_MATNR_PRUE.
  LANGTEXT_MATNR_VERT = RLTEX-LANGTEXT_MATNR_VERT.
  KZ_BEST_PROZ = RLTEX-KZ_BEST_PROZ.
  KZ_GRUN_PROZ = RLTEX-KZ_GRUN_PROZ.
  KZ_IVER_PROZ = RLTEX-KZ_IVER_PROZ.
  KZ_PRUE_PROZ = RLTEX-KZ_PRUE_PROZ.
  KZ_VERT_PROZ = RLTEX-KZ_VERT_PROZ.
  longtextcontainer = RLTEX-longtextcontainer.
  refresh_textedit_control = RLTEX-refresh_textedit_control.
  desc_langu_gdtxt = RLTEX-desc_langu_gdtxt.
  desc_langu_prtxt = RLTEX-desc_langu_prtxt.
  desc_langu_iverm = RLTEX-desc_langu_iverm.
  desc_langu_bestell = RLTEX-desc_langu_bestell.
  desc_langu_vertriebs = RLTEX-desc_langu_vertriebs.
  editor_obj_gd = RLTEX-editor_obj_gd.
  editor_obj_pr = RLTEX-editor_obj_pr.
  editor_obj_iv = RLTEX-editor_obj_iv.
  editor_obj_be = RLTEX-editor_obj_be.
  editor_obj_ve = RLTEX-editor_obj_ve.
  textedit_custom_container_gd = RLTEX-textedit_custom_container_gd.
  textedit_custom_container_pr = RLTEX-textedit_custom_container_pr.
  textedit_custom_container_iv = RLTEX-textedit_custom_container_iv.
  textedit_custom_container_be = RLTEX-textedit_custom_container_be.
  textedit_custom_container_ve = RLTEX-textedit_custom_container_ve.
  rm03m_spras_grundd = RLTEX-rm03m_spras_grundd.
  rm03m_spras_pruef = RLTEX-rm03m_spras_pruef.
  rm03m_spras_vertriebs = RLTEX-rm03m_spras_vertriebs.
  rm03m_spras_bestell = RLTEX-rm03m_spras_bestell.
  rm03m_spras_iverm = RLTEX-rm03m_spras_iverm.

endform.                    " ZUSATZDATEN_GET_RLTEX

*&---------------------------------------------------------------------*
*&      Form  ZUSATZDATEN_SET_RLTEX
*&---------------------------------------------------------------------*
form ZUSATZDATEN_SET_RLTEX .

  RLTEX-LANGTEXTBILD = LANGTEXTBILD.
  RLTEX-LANGTXTVKORG = LANGTXTVKORG.
  RLTEX-LANGTXTVTWEG = LANGTXTVTWEG.
  RLTEX-LANGTEXT_MATNR_BEST = LANGTEXT_MATNR_BEST.
  RLTEX-LANGTEXT_MATNR_GRUN = LANGTEXT_MATNR_GRUN.
  RLTEX-LANGTEXT_MATNR_IVER = LANGTEXT_MATNR_IVER.
  RLTEX-LANGTEXT_MATNR_PRUE = LANGTEXT_MATNR_PRUE.
  RLTEX-LANGTEXT_MATNR_VERT = LANGTEXT_MATNR_VERT.
  RLTEX-KZ_BEST_PROZ = KZ_BEST_PROZ.
  RLTEX-KZ_GRUN_PROZ = KZ_GRUN_PROZ.
  RLTEX-KZ_IVER_PROZ = KZ_IVER_PROZ.
  RLTEX-KZ_PRUE_PROZ = KZ_PRUE_PROZ.
  RLTEX-KZ_VERT_PROZ = KZ_VERT_PROZ.
  RLTEX-longtextcontainer = longtextcontainer.
  RLTEX-refresh_textedit_control = refresh_textedit_control.
  RLTEX-desc_langu_gdtxt = desc_langu_gdtxt.
  RLTEX-desc_langu_prtxt = desc_langu_prtxt.
  RLTEX-desc_langu_iverm = desc_langu_iverm.
  RLTEX-desc_langu_bestell = desc_langu_bestell.
  RLTEX-desc_langu_vertriebs = desc_langu_vertriebs.
  RLTEX-editor_obj_gd = editor_obj_gd.
  RLTEX-editor_obj_pr = editor_obj_pr.
  RLTEX-editor_obj_iv = editor_obj_iv.
  RLTEX-editor_obj_be = editor_obj_be.
  RLTEX-editor_obj_ve = editor_obj_ve.
  RLTEX-textedit_custom_container_gd = textedit_custom_container_gd.
  RLTEX-textedit_custom_container_pr = textedit_custom_container_pr.
  RLTEX-textedit_custom_container_iv = textedit_custom_container_iv.
  RLTEX-textedit_custom_container_be = textedit_custom_container_be.
  RLTEX-textedit_custom_container_ve = textedit_custom_container_ve.
  RLTEX-rm03m_spras_grundd = rm03m_spras_grundd.
  RLTEX-rm03m_spras_pruef = rm03m_spras_pruef.
  RLTEX-rm03m_spras_vertriebs = rm03m_spras_vertriebs.
  RLTEX-rm03m_spras_bestell = rm03m_spras_bestell.
  RLTEX-rm03m_spras_iverm = rm03m_spras_iverm.

endform.                    " ZUSATZDATEN_SET_RLTEX
*&---------------------------------------------------------------------*
*&      Form  HANDLE_WM_BUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM handle_wm_button .
 DATA : lt_valid_cats   TYPE TABLE OF sgt_valcat.
 DATA : lv_catv         TYPE          sgt_catv VALUE
'XXXXXXXXXXXXXXXX'.
 DATA : lv_hide         TYPE          boolean.
 DATA : lv_cfun(3)      TYPE          c .
 data : lv_count        type          c .

 DO 2 TIMES.

  lv_count = sy-index.

   CONCATENATE 'WM' lv_count INTO lv_cfun.

*  Check whether the structure fields are SDS relevant or not
   CALL FUNCTION 'SGTV_VALID_CATS_READ'
     EXPORTING
       iv_csgr                 = mara-sgt_csgr
       iv_appl                 = 'S'
       iv_covs                 = mara-sgt_covsa
       iv_cfun                 = lv_cfun
       iv_expand_fields_wo_vlc = abap_true
     TABLES
       e_valid_cats_tab        = lt_valid_cats
     EXCEPTIONS
       invalid_key             = 1
       not_found               = 2
       OTHERS                  = 3.
   IF sy-subrc <> 0.
* Implement suitable error handling here
   ENDIF.

*  Check whether the structure fields are SDS relevant or not
   CALL FUNCTION 'SGTG_ELIMINATE_NON_RELEVANT'
     EXPORTING
      iv_csgr                         = mara-sgt_csgr
      iv_appl                         = 'S'
      iv_cfun                         = lv_cfun
     CHANGING
       cv_cat_value                   = lv_catv
    EXCEPTIONS
      no_category_structure_found     = 1
      no_relevance_info_found         = 2
      internal_error                  = 3
      OTHERS                          = 4.

* Clear the blank entry if it is not SDS relevant
   IF lv_catv EQ space.
     CLEAR lt_valid_cats.
   ENDIF.

   IF lt_valid_cats IS INITIAL.
     lv_hide = abap_true.
   ENDIF.
 ENDDO.

 IF lv_hide = abap_true.
* No Stock segments found, button and icon are not shown
   LOOP AT SCREEN.
     IF screen-name = 'SEG_PUSH_WM'.
       screen-active    = 0.
       screen-invisible = 1.
       MODIFY SCREEN.
     ENDIF.
   ENDLOOP.
 ENDIF.
ENDFORM.
