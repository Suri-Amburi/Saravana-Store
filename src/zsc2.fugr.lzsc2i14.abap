*----------------------------------------------------------------------*
***INCLUDE LMGD2I14 .
*----------------------------------------------------------------------*

*****************************
* AHE: 09.04.99  - A (4.6a) *
* komplett neues Include    *
* AHE: 09.04.99  - E        *
*****************************

*&---------------------------------------------------------------------*
*&      Module  CHECK_MEINH_SA_VA  INPUT
*&---------------------------------------------------------------------*
MODULE CHECK_MEINH_SA_VA INPUT.

  CHECK NOT SMEINH-MEINH IS INITIAL.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel

    READ TABLE MEINH_SA WITH KEY MATNR = MEAN-MATNR
                                 MEINH = SMEINH-MEINH BINARY SEARCH.
    IF SY-SUBRC NE 0.
      CLEAR RMMZU-OKCODE.
      BILDFLAG = X.
      MESSAGE E232(MH) WITH SMEINH-MEINH MEAN-MATNR.
*     Mengeneinheit & zum Material & ist nicht gepflegt
    ENDIF.

  ELSE.
* Normalfall

    READ TABLE MEINH WITH KEY SMEINH-MEINH.
    IF SY-SUBRC NE 0.
      CLEAR RMMZU-OKCODE.
      BILDFLAG = X.
      MESSAGE E758 WITH SMEINH-MEINH.
*     Mengeneinheit & zum Material ist nicht gepflegt
    ENDIF.

  ENDIF.

ENDMODULE.                             " CHECK_MEINH_SA_VA  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_EAN_ZUS_SA_VA  INPUT
*&---------------------------------------------------------------------*
MODULE CHECK_EAN_ZUS_SA_VA INPUT.

* Prüfen der Eingabe und ggf. interne Vergabe von EANs.
*
* Bemerkung zu MEAN_ME_TAB-EAN_GEPRF:
* ===================================
* In diesem Feld wird festgehalten, ob ein Eintrag bezüglich EAN und
* EAN-Typ bereits korrekt geprüft wurde. Wenn ja, darf eine solche
* Prüfung im Falle einer internen EAN-Vergabe nicht noch einmal
* ablaufen, da dann das Prüfergebnis zu einer Error-Message führt
* (EAN paßt nicht zum Typ). Die Prüfung soll nur ablaufen, wenn sich
* die Eingabe auf dem Dynpro geändert hat. Um dies festzustellen, kann
* nicht die Tabelle LMEAN_ME_TAB herangezogen werden, da sie in diesem
* speziellen Falle NICHT auf dem geforderten Stand ist (Lesen in
* GET-Bausteinen wird dann nicht durchgeführt). Deswegen muß intern
* festgehalten werden, ob sich die EAN seit dem letzen Bilddurchlauf
* auf dem Bild geändert hat.
*----------------------------------------------------------------------*

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK RMMZU-OKCODE NE FCODE_EADE.
* CHECK BILDFLAG IS INITIAL.

* Retail-Fall: EAN-Lieferantenbezug-Handling
  CLEAR: FLAG_EXIT, EAN_UPD.

* externe Vergabe der EAN und die Prüfziffer soll automatisch
* ermittelt werden.
  IF NOT RMMZU-AUTO_PRFZ IS INITIAL AND" Dynprofeld !
     NOT MEAN-EAN11 IS INITIAL.        " AND  " Dynprofeld !
*    NOT MEAN-EANTP IS INITIAL.          " Dynprofeld !

    CALL FUNCTION 'EAN_AUTO_CHECKSUM'
         EXPORTING
              P_EAN11        = MEAN-EAN11
              P_NUMTP        = MEAN-EANTP
              P_MESSAGE      = ' '
         IMPORTING
              P_EAN11        = MEAN-EAN11
         EXCEPTIONS
              EAN_PRFZ_ERROR = 1
              OTHERS         = 2.

    CLEAR RMMZU-AUTO_PRFZ.   " Bei Error oder Erfolg immer zurücksetzen

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    CLEAR RMMZU-AUTO_PRFZ.
  ENDIF.                               " Ende Prüfziffernermittlung

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_CHECK_SA_VA.

  ELSE.
* Normalfall

    CLEAR MEAN_ME_TAB.  "wegen evtl. neuer noch nicht übernommener Zeile
    READ TABLE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
*   hier kein CHECK SY-SUBRC wg. evtl. neuem Satz möglich (dann könnte
*   man zuerst die Konsistenzchecks machen, bevor z. Bsp. eine EAN int.
*   vergeben wird).

*   Es wird nur für die EANs geprüft, bei deren Eintrag sich etwas
*   verändert hat.
    IF MEAN-EAN11 = MEAN_ME_TAB-EAN11 AND
       MEAN-EANTP = MEAN_ME_TAB-NUMTP AND
       MEAN_ME_TAB-EAN_GEPRF = X.
*    Zeile unverändert
      IF MEAN-EAN11       IS INITIAL AND
         NOT MEAN-EANTP   IS INITIAL AND
         EAN_FEHLERFLG_ME IS INITIAL.
*    EAN muss noch intern ermittelt werden --> FB-Aufruf aber nur, wenn
*    die Mengeneinheit korrekt eingegeben wurde (EAN_FEHLERFLAG_ME ist
*    initial).
*    MESSAGE W069(WE).                " EAN wird intern ermittelt
*    --> Meldung aus EAN_SYSTEMATIC in MARA_EAN11
        CLEAR MEAN_ME_TAB-EAN_GEPRF.
      ENDIF.

    ELSE.
*    Zeile geändert oder neu --> ggf. Meldungen ausgeben + Prüfen
      CLEAR MEAN_ME_TAB-EAN_GEPRF.
*     Zeile geändert: -> nicht in den Zweig für den Fehlerfall
*     "M3 348" springen (in MARA_EAN11).
*     Dies gilt nur ! für dieses Modul nicht für die anderen Module,
*     die MARA_EAN11 aufrufen ! ! !
      CLEAR EAN_FEHLERFLG.

      IF MEAN-EAN11 IS INITIAL.
        IF MEAN-EANTP IS INITIAL.
          IF NOT MEAN_ME_TAB-EAN11 IS INITIAL.  " neu: 07.11.95

            IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*           Retail-Fall: EAN-Lieferantenbezug-Handling
*           ->  Abfragen (POP-UP) und Löschen von ggf. vorhandenen
*               EAN-Lieferantenbezügen
              PERFORM DEL_EAN_LIEF USING FLAG_EXIT.
              CASE FLAG_EXIT.
                WHEN 'N'.
*               "NEIN" -> nur diese Zeile nicht löschen
                  EXIT.
                WHEN 'A'.
*               "ABBRUCH" -> Löschen abbrechen
                  EXIT FROM STEP-LOOP.
              ENDCASE.
*             Beim Löschen der Zeile muß in jedem Falle RMMZU-LIEFZU und
*             MLEA-LFEAN gelöscht werden. RMMZU-LIEFZU auch deswegen,
*             damit in TMLEA keine MEAN-Sätze mit leerer (zum Löschen
*             vorgem.) EAN aufgenommen werden (in BELEGEN_MEAN_ME_TAB).
              CLEAR: RMMZU-LIEFZU, MLEA-LFEAN.   " Dynprofelder
              CLEAR: MLEA-LARTN.       " Dynprofeld
            ENDIF.
            MESSAGE W067(WE).          " bisherige EAN gelöscht
* Muß außerhalb des FBs EAN_SYSTEMATIC (MARA_EAN11) ausgegeben werden.
* Der FB darf dann nicht mehr aufgerufen werden, da ansonsten
* das POP-UP "Bitte neue Haupt-EAN auswählen" aufgerufen wird.
* Bem.: Diese Funktionalität wird an anderer Stelle (z. Bsp. Mengenein-
* heitenbild ) benötigt.

            MEAN_ME_TAB-EAN_GEPRF = X.
*           Prüfung für EAN und Typ nicht mehr ausführen
          ENDIF.
        ELSE.
          IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*           Retail-Fall: EAN-Lieferantenbezug-Handling
*           ->  Abfragen (POP-UP) und Ändern von ggf. vorhandenen
*               EAN-Lieferantenbezügen
            PERFORM UPD_EAN_LIEF USING FLAG_EXIT.
            CASE FLAG_EXIT.
              WHEN 'N'.
*               "NEIN" -> nur diese Zeile nicht Ändern
                EXIT.
              WHEN 'A'.
*               "ABBRUCH" -> Ändern abbrechen
                EXIT FROM STEP-LOOP.
            ENDCASE.
          ENDIF.
*         MESSAGE W069(WE).              " EAN wird intern ermittelt
*         Meldung aus EAN_SYSTEMATIC in MARA_EAN11
        ENDIF.
      ENDIF.

    ENDIF.

* Retail-Fall: EAN-Lieferantenbezug-Handling
* für: EAN geändert
    IF NOT RMMG2-FLG_RETAIL IS INITIAL     AND
           MEAN-EAN11 NE MEAN_ME_TAB-EAN11 AND
       NOT MEAN-EAN11 IS INITIAL.
*   -> Abfragen (POP-UP) und Ändern von ggf. vorhandenen
*      EAN-Lieferantenbezügen
      PERFORM UPD_EAN_LIEF USING FLAG_EXIT.
      CASE FLAG_EXIT.
        WHEN 'N'.
*         "NEIN" -> nur diese Zeile nicht Ändern
          EXIT.
        WHEN 'A'.
*         "ABBRUCH" -> Ändern abbrechen
          EXIT FROM STEP-LOOP.
      ENDCASE.
    ENDIF.

   IF NOT EAN_FEHLERFLG IS INITIAL. " gesetzt, wenn vorher Error ausgeg.
      CLEAR MEAN_ME_TAB-EAN_GEPRF.     " nochmal reingehen ! !
    ENDIF.

* Retail-Fall: EAN-Lieferantenbezug-Handling
    IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
       MEAN-EAN11 IS INITIAL           AND
       MEAN-EANTP IS INITIAL.
      IF NOT MLEA-LFEAN   IS INITIAL OR
         NOT RMMZU-LIEFZU IS INITIAL OR
         NOT MLEA-LARTN IS INITIAL.
        CLEAR: MLEA-LARTN.
        MEAN_ME_TAB-EAN_GEPRF = X.
        CLEAR: MLEA-LFEAN, RMMZU-LIEFZU.
*   Falls nach der Meldung M3 898 "Bitte Haupt-EAN zum Lief. angeben"
*   diese Haupt-EAN-Lief auf einer Zeile ohne Eintrag markiert wird,
*   würde als Seiteneffekt in die MEAN_ME_TAB eine leere Zeile einge-
*   tragen, da der PBO dann nochmal prozessiert wird mit dieser
*   ansonsten leeren Zeile.
*   Dasselbe gilt für RMMZU-LIEFZU.
*   Dies wird realisiert, indem das FLAG_EXIT hier dazu mißbraucht
*   wird, den Tabellenupdate zu verhindern.
        FLAG_EXIT = 'N'.
      ENDIF.
    ENDIF.

    CHECK MEAN_ME_TAB-EAN_GEPRF IS INITIAL.
* Zeile noch zu prüfen  ?

*--- Letzter geprüfter Stand von EAN und Nummerntyp ermitteln
    READ TABLE LMEAN_ME_TAB WITH KEY MEINH = MEAN_ME_TAB-MEINH
                                     EAN11 = MEAN_ME_TAB-EAN11.
    IF SY-SUBRC NE 0.
      CLEAR: LMEAN_ME_TAB-EAN11, LMEAN_ME_TAB-NUMTP.
    ENDIF.

*   note 1455075: sort table to check correctly for duplicate EANs
    GT_MEAN_ME_TAB[] = MEAN_ME_TAB[].
    SORT GT_MEAN_ME_TAB.

    CALL FUNCTION 'MARA_EAN11'
         EXPORTING
              P_MATNR         = MARA-MATNR           " Dynprofeld
              P_NUMTP         = MEAN-EANTP                  "
              P_EAN11         = MEAN-EAN11                  "
              P_MEINH         = SMEINH-MEINH                "
            RET_EAN11       = LMEAN_ME_TAB-EAN11   " letzt. geprf. Stand
              RET_NUMTP       = LMEAN_ME_TAB-NUMTP          "
              BINPT_IN        = SY-BINPT
              P_MESSAGE       = ' '
*             SPERRMODUS      = 'E'
            KZ_MEAN_TAB_UPD = X   " MEAN_ME_TAB nicht "by ref." ändern !
              ERROR_FLAG      = EAN_FEHLERFLG
              P_HERKUNFT      = 'Z'    " für zusätzl. EAN
         IMPORTING
              VB_FLAG_MEAN    = RMMG2-VB_MEAN
              P_NUMTP         = MEAN-EANTP
              P_EAN11         = MEAN-EAN11
              MSGID           = MSGID  " s. weiter unten
              MSGTY           = MSGTY
              MSGNO           = MSGNO
              MSGV1           = MSGV1
              MSGV2           = MSGV2
              MSGV3           = MSGV3
              MSGV4           = MSGV4
         TABLES
              MARM_EAN        = MARM_EAN " Benötigt zum Puffern !
              MEAN_ME_TAB     = GT_MEAN_ME_TAB             "note 1455075
              ME_TAB          = ME_TAB
*             YDMEAN          =
*             MEINH           =
         EXCEPTIONS
              EAN_ERROR       = 1
              OTHERS          = 2.

    IF SY-SUBRC NE 0.
      CLEAR MEAN_ME_TAB-EAN_GEPRF.
*     CLEAR auf MEAN_ME_TAB-GEPRF, weil dieses KZ durch die zwar
*     nicht veränderte aber in MARA_EAN11 durchgeloopte ( = veränderte
*     Kopfzeile) MEAN_ME_TAB nicht mehr richtig sitzt.
      BILDFLAG = X.
      EAN_FEHLERFLG = X.
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
*   Ausgabe der Warnungen 068 und 069 (EAN wird geändert / intern
*   vergeben) nachdem die neue EAN aufs Bild geschossen wurde.
      IF MSGNO = 069 OR MSGNO = 068.
*   neue EAN aufs Dynprofeld schieben

*   UPC-E muß konvertiert werden, da der Exit noch nicht gelaufen ist an
*   dieser Stelle
        EAN_BUFF = MEAN-EAN11.
        CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
             EXPORTING
                  INPUT   = MEAN-EAN11
                  EAN_TYP = MEAN-EANTP
             IMPORTING
                  OUTPUT  = MEAN-EAN11.
        PERFORM SET_SCREEN_FIELD_VALUE USING 'MEAN-EAN11' MEAN-EAN11.

*   jetzt erst Warnung ausgeben
        MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO
                WITH MSGV1 MSGV2 MSGV3 MSGV4.

        MEAN-EAN11 = EAN_BUFF.
      ENDIF.

      CLEAR EAN_FEHLERFLG.
      MEAN_ME_TAB-EAN_GEPRF = X.       " Zeile geprüft und O.K.
    ENDIF.

  ENDIF.

ENDMODULE.                             " CHECK_EAN_ZUS_SA_VA  INPUT


*&---------------------------------------------------------------------*
*&      Module  BELEGEN_MEAN_ME_TAB_SA_VA  INPUT
*&---------------------------------------------------------------------*
*       Übernahme Daten aus Dynpro in Step-Loop Tabelle MEAN_ME_TAB
*----------------------------------------------------------------------*
MODULE BELEGEN_MEAN_ME_TAB_SA_VA INPUT.

* Wenn ein Abfrage-Pop-UP mit "NEIN" verlassen wurde, darf die Zeile
* nicht geändert oder gelöscht werden (hier zunächst dann nur EAN
* gelöscht).
  CHECK FLAG_EXIT NE 'N'.
  CHECK RMMZU-OKCODE NE FCODE_EADE.                          " n_1845357

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM MEAN_ME_TAB_SA_AKT.        "aktualisieren der MEAN_ME_TAB_SA

*   EAN-Lieferantenbezug-Handling
    PERFORM TMLEA_SA_AKT.              "aktualisieren der TMLEA_SA


  ELSE.
* Normalfall
    PERFORM MEAN_ME_TAB_AKT.           "aktualisieren der MEAN_ME_TAB

*   EAN-Lieferantenbezug-Handling
    PERFORM TMLEA_AKT.                 "aktualisieren der TMLEA

  ENDIF.
ENDMODULE.                 " BELEGEN_MEAN_ME_TAB_SA_VA  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_MATNR_SA_VA  INPUT
*&---------------------------------------------------------------------*
MODULE CHECK_MATNR_SA_VA INPUT.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    CHECK NOT MEAN-MATNR IS INITIAL.

*   daß der SA existiert ist ja hier klar
    CHECK MEAN-MATNR <> RMMW2_SATN.

    READ TABLE MEINH_SA WITH KEY MATNR = MEAN-MATNR BINARY SEARCH.

    IF SY-SUBRC NE 0.
      CLEAR RMMZU-OKCODE.
      BILDFLAG = X.
      MESSAGE E233(MH) WITH MEAN-MATNR RMMW2_SATN.
*     Das Material &1 ist keine Variante des SAs &2
    ENDIF.

  ELSE.
* Normalfall
* hier ist nichts zu prüfen, da man ja im Einzelartikel / VA ist und
* dort die Spalte MATNR ausgeblendet wird.

  ENDIF.

ENDMODULE.                             " CHECK_MATNR_SA_VA  INPUT


*&---------------------------------------------------------------------*
*&      Module  MEAN-MATNR_HELP  INPUT
*&---------------------------------------------------------------------*
MODULE MEAN-MATNR_HELP INPUT.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'RMMW1_VARNR_HELP'
       EXPORTING
            SA       = RMMW2_SATN
            DISPLAY  = DISPLAY
       IMPORTING
            VARIANTE = MEAN-MATNR
       EXCEPTIONS
            OTHERS   = 1.

ENDMODULE.                             " MEAN-MATNR_HELP  INPUT


*&---------------------------------------------------------------------*
*&      Module  SMEINH-MEINH_HLP_EAN  INPUT
*&---------------------------------------------------------------------*
*       Aufruf F4 - Hilfe für EAN-Bild und angegebener Variante
*----------------------------------------------------------------------*
MODULE SMEINH-MEINH_HLP_EAN INPUT.

  DATA: LINE_NR LIKE SY-TABIX.

  PERFORM SET_DISPLAY.

* MATNR aus der aktuellen Zeile lesen
  GET CURSOR LINE LINE_NR.

  PERFORM GET_VALUE_FROM_SCREEN USING 'MEAN-MATNR' HMATNR LINE_NR.

  IF HMATNR IS INITIAL.                                "Note BKE 949289
    IF NOT ( RMMW1-ATTYP = '01' and RMMW1-MATNR = RMMG1-MATNR ).
       HMATNR = RMMG1-MATNR.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SMEINH_MEINH_HELP'
       EXPORTING
            DISPLAY = DISPLAY
            P_MATNR = HMATNR
       IMPORTING
            MEINH   = SMEINH-MEINH
       EXCEPTIONS
            OTHERS  = 1.

ENDMODULE.                             " SMEINH-MEINH_HLP_EAN  INPUT


*&---------------------------------------------------------------------*
*&      Module  CLEAN_MEINH_SA  INPUT
*&---------------------------------------------------------------------*
*       Löscht die Einträge zu denjenigen Mengeneinheiten, für die
*       außer der Mengeneinheit/MATNR nichts erfaßt wurde, wieder raus,
*       damit keine "leeren" Sätze auf die DB gelangen
*----------------------------------------------------------------------*
MODULE CLEAN_MEINH_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    LOOP AT MEAN_ME_TAB_SA.
      IF ( NOT MEAN_ME_TAB_SA-MATNR IS INITIAL OR
           NOT MEAN_ME_TAB_SA-MEINH IS INITIAL )  AND
*        MEAN_ME_TAB_SA-HPEAN     IS INITIAL AND
         MEAN_ME_TAB_SA-EAN11     IS INITIAL AND
         MEAN_ME_TAB_SA-NUMTP     IS INITIAL.
        DELETE MEAN_ME_TAB_SA.
      ENDIF.
    ENDLOOP.

  ELSE.
* Normalfall
    LOOP AT MEAN_ME_TAB.
      IF NOT MEAN_ME_TAB-MEINH IS INITIAL AND
*        MEAN_ME_TAB-HPEAN     IS INITIAL AND
         MEAN_ME_TAB-EAN11     IS INITIAL AND
         MEAN_ME_TAB-NUMTP     IS INITIAL.
        DELETE MEAN_ME_TAB.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                             " CLEAN_MEINH_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  INIT_EAN_SA  INPUT
*&---------------------------------------------------------------------*
*       Initialisiert diverse Flags
*----------------------------------------------------------------------*
MODULE INIT_EAN_SA INPUT.

  CLEAR: EAN_FEHLERFLG_ME,
         EAN_FEHLERFLG,
         MEAN_TAB_KEY,
         MLEA_LFEAN_KEY,
         EAN_FEHLERFLG_LFEAN,
         MEAN_TAB_KEY_SA,
         MLEA_LFEAN_KEY_SA.

* Initialisieren von Fehlerflags und Key zum merken der Zeile mit Fehler

ENDMODULE.                             " INIT_EAN_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  OKCODE_EADE_SA  INPUT
*&---------------------------------------------------------------------*
*       Bereitet Löschen EAN vor; Hier wird nur LÖSCHEN per Button
*       behandelt. Das eigentliche Löschen in der MEAN_ME_TAB
*       geschieht später.
*----------------------------------------------------------------------*
MODULE OKCODE_EADE_SA INPUT.

  CLEAR FLAG_DEL_EAN.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT EAN_BILDFLAG_OLD IS INITIAL AND
      RMMZU-OKCODE = FCODE_EADE.
    CLEAR RMMZU-OKCODE.
  ENDIF.


  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_OKCODE_SA_VA.

  ELSE.
* Normalfall

    IF RMMZU-OKCODE EQ FCODE_EADE.     " Einträge löschen
      FLAG_DEL_EAN = X.                " merken für UPDATE MEINH, MARM
      BILDFLAG = X.
      CLEAR RMMZU-OKCODE.

      GET CURSOR LINE EAN_ZEILEN_NR.   " Zeile bestimmen
      EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + EAN_ZEILEN_NR.

      READ TABLE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
      IF SY-SUBRC = 0.
*     DELETE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
*     hier kein DELETE auf Tabellensatz, da erst noch geprüft werden
*     muß, ob es der letzte Satz zu einer Mengeneinheit ist. Dieser
*     darf dann nicht gelöscht werden.

        IF NOT MEAN_ME_TAB-EAN11 IS INITIAL.
          IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*         Retail-Fall: EAN-Lieferantenbezug-Handling
*         ->  Abfragen (POP-UP) und Löschen von ggf. vorhandenen
*             EAN-Lieferantenbezügen
            PERFORM DEL_EAN_LIEF USING FLAG_EXIT.
            CHECK FLAG_EXIT IS INITIAL.
*         FLAG_EXIT initial, wenn POP-UP mit "JA" verlassen
          ENDIF.

          MESSAGE S067(WE).
*         Bisherige EAN wird gelöscht

        ENDIF.

        CLEAR: MEAN_ME_TAB-EAN11,
               MEAN_ME_TAB-NUMTP,
               MEAN_ME_TAB-HPEAN.
       MODIFY MEAN_ME_TAB INDEX EAN_AKT_ZEILE.  " zum Löschen vorgemerkt
*      dieses CLEAR entspricht dem Löschen von Hand ohne Löschbutton
        MEAN_ME_TAB_CHECK = X.   " Prüfung "Tabelle bereinigen" anstoßen

      ENDIF.
    ENDIF.

  ENDIF.                               " Normalfall

ENDMODULE.                             " OKCODE_EADE_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  SORT_SA  INPUT
*&---------------------------------------------------------------------*
MODULE SORT_SA INPUT.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    SORT MEAN_ME_TAB_SA BY MATNR MEINH EAN11.
  ELSE.
* Normalfall
    SORT MEAN_ME_TAB BY MEINH EAN11.
  ENDIF.

* Sortierung für verschiedene Konsistenzchecks benötigt

ENDMODULE.                             " SORT_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_NEW_MEINH_SA  INPUT
*&---------------------------------------------------------------------*
MODULE CHECK_NEW_MEINH_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
* CHECK BILDFLAG IS INITIAL.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_EAN ist gesetzt, wenn OKCODE mit "EADE" belegt.
* Das Module CHECK_NEW_MEINH_SA muß trotz OKCODE "EADE" ablaufen
* darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_EAN IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_CHECK_NEW_ME_SA_VA.

  ELSE.
* Normalfall

    LOOP AT MEAN_ME_TAB.
      HTABIX = SY-TABIX.
      READ TABLE MEINH WITH KEY MEAN_ME_TAB-MEINH.

      IF SY-SUBRC NE 0 AND
         NOT MEAN_ME_TAB-MEINH IS INITIAL.
        CLEAR RMMZU-OKCODE.
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          EAN_FEHLERFLG_ME = X.   " darf nur gesetzt werden, wenn die
                                       " Zeile nicht gelöscht wird
          MESSAGE S758 WITH MEAN_ME_TAB-MEINH.
*       Mengeneinheit & zum Material ist nicht gepflegt
        ENDIF.
        MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH.  " Mengeneinh. merken
        MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.

*     Wenn mit Löschbutton versucht wird, die falsche Zeile zu korr.,
*     wird sie gelöscht und das Flag wird zurückgesetzt.
        IF NOT FLAG_DEL_EAN IS INITIAL.
          CLEAR EAN_FEHLERFLG_ME.
          DELETE MEAN_ME_TAB.
        ENDIF.

        EXIT.
      ENDIF.

* wenn die Mengeneinheit noch nicht z. Material erfaßt wurde und nach
* obiger Meldung diese per Hand aus dem Feld gelöscht wird, wird die
* ganze Zeile gelöscht, allerdings nur, wenn die Zeile sonst auch leer
* ist. Wenn schon Eingaben in der Zeile vorhanden sind, wird eine
* Message ausgegeben.
      IF FLAG_DEL_EAN IS INITIAL AND
         MEAN_ME_TAB-MEINH IS INITIAL.

        IF MEAN_ME_TAB-EAN11 IS INITIAL AND
           MEAN_ME_TAB-NUMTP IS INITIAL.
          CLEAR EAN_FEHLERFLG_ME.
          DELETE MEAN_ME_TAB.
        ENDIF.

        IF NOT MEAN_ME_TAB-EAN11 IS INITIAL OR
           NOT MEAN_ME_TAB-NUMTP IS INITIAL.
          CLEAR RMMZU-OKCODE.
          IF BILDFLAG IS INITIAL.
            BILDFLAG = X.
            EAN_FEHLERFLG_ME = X.
            MESSAGE S578.
*         Bitte Mengeneinheit eingeben
          ENDIF.
          MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH.  " Mengeneinh. merken
          MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.
          EXIT.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDMODULE.                             " CHECK_NEW_MEINH_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  PREPARE_EAN_ZUS_SA  INPUT
*&---------------------------------------------------------------------*
MODULE PREPARE_EAN_ZUS_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CLEAR: HILFS_EAN, HILFS_MEEIN, HILFS_MATNR.

* Falls doppelte Einträge innerhalb einer Mengeneinheit vorkommen,
* Flag setzen, um MEAN_ME_TAB nachzubearbeiten.
* Abfrage ist korrekt, da MEAN_ME_TAB sortiert ist nach EAN.
  IF MEAN_ME_TAB_CHECK IS INITIAL.

    IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
      PERFORM EAN_PREP_SA_VA.

    ELSE.
* Normalfall

      LOOP AT MEAN_ME_TAB.
        IF  ( MEAN_ME_TAB-EAN11 = HILFS_EAN    AND
              NOT MEAN_ME_TAB-EAN11 IS INITIAL AND
              MEAN_ME_TAB-MEINH = HILFS_MEEIN ).
          MEAN_ME_TAB_CHECK = X.
        ELSE.
          HILFS_EAN   = MEAN_ME_TAB-EAN11.
          HILFS_MEEIN = MEAN_ME_TAB-MEINH.
        ENDIF.

* Wenn eine MEINH keine EAN zugeordnet hat, darf auch das KZ Haupt-EAN
* nicht gesetzt sein -> MEAN_ME_TAB wird nachbearbeitet.
* --> in Modul CLEAN_MEINH behandelt
        IF MEAN_ME_TAB-EAN11 IS INITIAL.
          "AND NOT MEAN_ME_TAB-HPEAN IS INITIAL.        "note 2015371
          MEAN_ME_TAB_CHECK = X.
        ENDIF.

* evtl. Sparen einiger redundanter Loop-Steps
        IF NOT MEAN_ME_TAB_CHECK IS INITIAL.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.                             " PREPARE_EAN_ZUS_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  DUB_DEL_EAN_ZUS_SA  INPUT
*       zu löschende und doppelt eingetragene Sätze werden aus der
*       internen Tabelle entfernt.
*       Außerdem werden die evtl. gesetzten KZ HPEAN gelöscht für die
*       Mengeneinheiten, die keine EANs zugeordnet haben.
*       Falls zu einer Mengeneinheit die letzte EAN gelöscht werden
*       soll, wird dieser Satz nicht aus der Tabelle gelöscht, sondern
*       nur die Felder für EAN und EAN-Typ initialisiert. Grund:
*       Man muß die Möglichkeit haben, auch zu einer Mengeneinheit, die
*       noch keine EAN zugeordnet hat (entweder nach Löschen der letzten
*       EAN oder sie hatte noch keine EAN), EANs zu erfassen.
*----------------------------------------------------------------------*
MODULE DUB_DEL_EAN_ZUS_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_EAN ist gesetzt, wenn OKCODE mit "EADE" belegt.
* Das Module DUB_DEL_EAN hier muß beim Löschen
* ablaufen, darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_EAN IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  CLEAR: HILFS_EAN, HILFS_MEEIN, HILFS_MATNR.

* MEAN_ME_TAB_CHECK ist nur gesetzt, wenn das BILDFLAG initial ist.
  IF NOT MEAN_ME_TAB_CHECK IS INITIAL.
*   MEAN_ME_TAB_SA ist noch zu bereinigen. D.h.: die "gelöschten"
*   (Felder EAN11 und NUMTP wurden initialisiert) oder
*   doppelt eingetragenen Sätze werden aus der Tabelle gelöscht
*   außerdem werden für MEINHs ohne EANs die KZ HPEAN gelöscht, da
*   eine nicht vorhandene EAN keine Haupt-Ean sein kann.

    IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
      PERFORM EAN_DUB_DEL_SA_VA.

    ELSE.
* Normalfall

      LOOP AT MEAN_ME_TAB.
        HTABIX  = SY-TABIX + 1.
*       Fall: Löschen
        IF MEAN_ME_TAB-EAN11 IS INITIAL.
*         wenn EAN11 hier noch initial, dann soll gelöscht werden
          IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
*         Fall: Mengeneinheit ohne EAN --> HPEAN wird zurückgesetzt
            CLEAR MEAN_ME_TAB-HPEAN.
            MODIFY MEAN_ME_TAB.
          ENDIF.
          CLEAR MEAN_ME_BUF.
          READ TABLE MEAN_ME_TAB INDEX HTABIX INTO MEAN_ME_BUF.
*       Falls ein weiterer Satz zur selben Mengeneinheit existiert, kann
*       gelöscht werden, ansonsten bleibt der Satz mit den initialen
*       Feldern EAN11 und NUMTP bestehen. Bem.: Die Einträge mit den
*       leeren EANs zu einer Mengeneinheit stehen immer VOR denjenigen
*       mit gefüllter EAN (wegen Sortierung);
          IF MEAN_ME_BUF-MEINH EQ MEAN_ME_TAB-MEINH AND
             NOT MEAN_ME_TAB-MEINH IS INITIAL.    " siehe nächstes IF
            DELETE MEAN_ME_TAB.
          ENDIF.
* Fall: Die Mengeneinheit ist leer aber die restl. Felder sollen mit
* Löschbutton gelöscht werden.
          IF MEAN_ME_TAB-MEINH IS INITIAL.
            DELETE MEAN_ME_TAB.
          ENDIF.
        ENDIF.

*     Fall: Doppelter Eintrag ( zu einer Mengeneinheit wurde die selbe
*     EAN mehrfach erfaßt);
        IF  ( MEAN_ME_TAB-EAN11 = HILFS_EAN    AND
              NOT MEAN_ME_TAB-EAN11 IS INITIAL AND
*           (die "leeren" EANs werden schon beim Löschen behandelt)
              MEAN_ME_TAB-MEINH = HILFS_MEEIN ).
          DELETE MEAN_ME_TAB.
        ELSE.
          HILFS_EAN   = MEAN_ME_TAB-EAN11.
          HILFS_MEEIN = MEAN_ME_TAB-MEINH.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.                             " DUB_DEL_EAN_ZUS_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  MARA_EAN11_EXIST_SA  INPUT
*&---------------------------------------------------------------------*
*       Prüfen, ob eine EAN zum Material vorhanden ist. Falls nicht,
*       Meldung (E, W oder keine Meldung, abhängig von Einstellung
*       Customizing)
*----------------------------------------------------------------------*
MODULE MARA_EAN11_EXIST_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
* aus dem SA heraus ist so eine Meldung nicht unbedingt sinnvoll

  ELSE.
* Normalfall
    CALL FUNCTION 'MARA_EAN11_EXIST'
         EXPORTING
              P_MATNR       = MARA-MATNR
              P_ATTYP       = MARA-ATTYP
              P_MESSAGE     = ' '
         TABLES
              MEINH         = MEINH
         EXCEPTIONS
              EAN_NOT_EXIST = 1
              OTHERS        = 2.

    IF SY-SUBRC NE 0.
*     CLEAR RMMZU-OKCODE.
      IF BILDFLAG IS INITIAL.
        BILDFLAG = X.
        MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                             " MARA_EAN11_EXIST_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_HPEAN_SA  INPUT
*&---------------------------------------------------------------------*
*       Zu einer Mengeneinheit muß genau eine Haupt-EAN vorhanden
*       sein, falls mindestens eine EAN zu einer Mengeneinheit
*       existiert.
*----------------------------------------------------------------------*
MODULE CHECK_HPEAN_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_CHECK_HP_SA_VA.

  ELSE.
* Normalfall

*  Automatisches Setzen der Haupt-EAN zu einer Mengeneinheit, wenn keine
*  EAN markiert ist.
    DO.
      CLEAR TMEAN_CORR.
      CLEAR: HILFS_MEEIN, HILFS_EAN, MEAN_TAB_KEY.

      ZAEHLER = 1.   " Zaehler für Anzahl Kz Haupt-EAN pro Mengeneinheit

*     Voraussetzung: Tabelle ist sortiert !
      LOOP AT MEAN_ME_TAB.
*     Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*     für den Fall, daß die erste MEINH untersucht wird.
        CASE ZAEHLER.
         WHEN 0.                     " evtl. Fehlerfall: keine Haupt-EAN
            IF HILFS_MEEIN NE MEAN_ME_TAB-MEINH.
*            Wechsel MEINH und bei voriger MEINH keine Haupt-EAN
              IF NOT HILFS_EAN IS INITIAL.
*               Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
*               Es kann nicht vorkommen, daß mehr als eine leere EAN
*               für eine MEINH in der Tabelle existiert.
                IF RMMZU-OKCODE NE FCODE_EAFP AND
                   RMMZU-OKCODE NE FCODE_EAPP AND
                   RMMZU-OKCODE NE FCODE_EANP AND
                   RMMZU-OKCODE NE FCODE_EALP.
*                 Blättern muß hier ausnahmsweise erlaubt werden, um den
*                 Fehler ggf. auf einer anderen Seite korr. zu können.
                  CLEAR RMMZU-OKCODE.
                ENDIF.
*              automatisches Setzen der Haupt-EAN auf den ersten Eintrag
*              zur Mengeneinheit, wenn keine EAN markiert ist anstatt
*              der Ausgabe einer Meldung
                TMEAN_CORR-MEINH = HILFS_MEEIN.
                TMEAN_CORR-EAN11 = HILFS_EAN.
                EXIT.
              ELSE.                    " Ausnahme: kein Fehlerfall
                HILFS_EAN   = MEAN_ME_TAB-EAN11.
*               Fall: keine Haupt-EAN markiert aber auch keine EAN
*             angegeben --> keine Meldung ausgeben, aber neue EAN merken
*             für evtl. spätere Meldung bzgl. der neuen MEINH.
              ENDIF.
            ELSE.
*           MEINH unverändert
              IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
                ZAEHLER = ZAEHLER + 1. " Haupt-EAN gefunden
              ENDIF.
            ENDIF.

          WHEN 1.                      " HPEAN eindeutig
            IF HILFS_MEEIN NE MEAN_ME_TAB-MEINH.
*            Wechsel MEINH und vorige MEINH O.K.
              ZAEHLER = 0.
              IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
*             schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
                ZAEHLER = ZAEHLER + 1.
              ELSE.
*             Wenn das Haupt-EAN KZ nicht gesetzt ist und die EAN ist
*             leer, ist trotzdem alles O.K. --> Zähler auf 1 setzen.
                IF MEAN_ME_TAB-EAN11 IS INITIAL.
                  ZAEHLER = 1.
                ENDIF.
              ENDIF.
              HILFS_MEEIN = MEAN_ME_TAB-MEINH.    " neue MEINH merken
             HILFS_EAN   = MEAN_ME_TAB-EAN11.    " erste neue EAN merken
            ELSE.
*           MEINH unverändert
              IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
                ZAEHLER = ZAEHLER + 1. " Haupt-EAN gefunden
              ENDIF.
            ENDIF.

          WHEN OTHERS.                 " Fehlerfall: mehrere Haupt-EAN
            IF HILFS_MEEIN NE MEAN_ME_TAB-MEINH.
*            Wechsel MEINH und bei voriger MEINH mehrere Haupt-EAN
              IF NOT HILFS_EAN IS INITIAL.
*             Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
                IF RMMZU-OKCODE NE FCODE_EAFP AND
                   RMMZU-OKCODE NE FCODE_EAPP AND
                   RMMZU-OKCODE NE FCODE_EANP AND
                   RMMZU-OKCODE NE FCODE_EALP.
*                 Blättern muß hier ausnahmsweise erlaubt werden, um den
*                 Fehler ggf. auf einer anderen Seite korr. zu können.
                  CLEAR RMMZU-OKCODE.
                ENDIF.
                IF BILDFLAG IS INITIAL.
                  BILDFLAG = X.
                  EAN_FEHLERFLG = X.
                  MESSAGE S714 WITH HILFS_MEEIN.
*                 Die Haupt-EAN zur MEINH ist nicht eindeutig
*                 MEAN_ME_TAB-Satz merken wegen Cursorpositionierung
                  MEAN_TAB_KEY-MEINH = HILFS_MEEIN.
                  MEAN_TAB_KEY-EAN11 = HILFS_EAN.
                ENDIF.
                EXIT.
              ENDIF.
            ELSE.
*             MEINH unverändert
              IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
                ZAEHLER = ZAEHLER + 1. " Haupt-EAN gefunden
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.

*     Auswertung der letzten MEINH nach dem Loop !
      IF TMEAN_CORR IS INITIAL.
        CASE ZAEHLER.
          WHEN 0.                      " Fehlerfall: keine Haupt-EAN
*           bei letzter MEINH keine Haupt-EAN
            IF NOT HILFS_EAN IS INITIAL.
*           Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
              TMEAN_CORR-MEINH = HILFS_MEEIN.
              TMEAN_CORR-EAN11 = HILFS_EAN.
            ENDIF.

          WHEN 1.                      " HPEAN eindeutig
*         letzte MEINH O.K.

          WHEN OTHERS.                 " Fehlerfall: mehrere Haupt-EAN
*           bei letzter MEINH mehrere Haupt-EAN
            IF NOT HILFS_EAN IS INITIAL.
*             Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
              IF BILDFLAG IS INITIAL.
                BILDFLAG = X.
                EAN_FEHLERFLG = X.
                MESSAGE S714 WITH HILFS_MEEIN.
*               Die Haupt-EAN zur MEINH ist nicht eindeutig
*               MEAN_ME_TAB-Satz merken wegen Cursorpositionierung
                MEAN_TAB_KEY-MEINH = HILFS_MEEIN.
                MEAN_TAB_KEY-EAN11 = HILFS_EAN.
              ENDIF.
            ENDIF.
        ENDCASE.

      ENDIF.

      IF NOT EAN_FEHLERFLG IS INITIAL.
        CLEAR TMEAN_CORR.
        EXIT.                          " raus aus DO- Schleife
      ELSE.
        IF TMEAN_CORR IS INITIAL.
          EXIT.                        " raus aus DO- Schleife
        ENDIF.
        READ TABLE MEAN_ME_TAB WITH KEY
                               MEINH = TMEAN_CORR-MEINH
                               EAN11 = TMEAN_CORR-EAN11 BINARY SEARCH.
        IF SY-SUBRC = 0.
*         sollte hier immer so sein
          MEAN_ME_TAB-HPEAN = X.
          MODIFY MEAN_ME_TAB INDEX SY-TABIX.
        ENDIF.
      ENDIF.

    ENDDO.

  ENDIF.

ENDMODULE.                             " CHECK_HPEAN_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  UPDATE_HPEAN_SA  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob sich die Haupt-EAN innerhalb einer Mengeneinheit
*       gegenüber dem MARM (MEINH) - und/oder MARA - Satz geändert hat.
*       Wenn ja, muß der MARM - Eintrag upgedatet werden, da dort
*       nur die Haupt-EAN gepflegt wird. Handelt es sich zusätzlich
*       noch um die Basismengeneinheit, muß auch der MARA - Satz
*       aktualisiert werden.
*       Dies wird für alle Mengeneinheiten durchgeführt.
*----------------------------------------------------------------------*
MODULE UPDATE_HPEAN_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_EAN ist gesetzt, wenn OKCODE mit "EADE" belegt.
* Das Module UPDATE_HPEAN hier muß beim Löschen
* ablaufen, darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_EAN IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_UPDHP_SA_VA.

  ELSE.
* Normalfall
    LOOP AT MEAN_ME_TAB.
      IF NOT MEAN_ME_TAB-HPEAN IS INITIAL OR   " Haupt-EAN gefunden
        ( MEAN_ME_TAB-HPEAN IS INITIAL   AND  " oder EAN zur Mengeneinh.
         MEAN_ME_TAB-EAN11 IS INITIAL   AND  " wurde gelöscht / ist leer
           MEAN_ME_TAB-NUMTP IS INITIAL   AND
       NOT MEAN_ME_TAB-MEINH IS INITIAL ).

        READ TABLE MEINH WITH KEY MEAN_ME_TAB-MEINH.
        IF SY-SUBRC = 0.               " sollte hier immer so sein

          HTABIX = SY-TABIX.
          IF MEINH-EAN11 NE MEAN_ME_TAB-EAN11.
*         HPEAN wurde geändert --> MARM (MEINH) - Eintrag ändern
            MEINH-EAN11 = MEAN_ME_TAB-EAN11.
            MEINH-NUMTP = MEAN_ME_TAB-NUMTP.
            MODIFY MEINH INDEX HTABIX.
*         UPDKZ in PTAB setzen (nur sicherheitshalber)
            PERFORM SET_UPDATE_TAB USING T_MARM.

            IF NOT MEINH-KZBME IS INITIAL.
*         HPEAN bei Basismengeneinheit geändert --> MARA - Eintr. ändern
              MARA-EAN11 = MEAN_ME_TAB-EAN11.
              MARA-NUMTP = MEAN_ME_TAB-NUMTP.
*           UPDKZ in PTAB setzen (nur sicherheitshalber)
              PERFORM SET_UPDATE_TAB USING T_MARA.
            ENDIF.

          ENDIF.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                             " UPDATE_HPEAN_SA  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_LFEAN_SA  INPUT
*&---------------------------------------------------------------------*
*       Zu einer Mengeneinheit muß genau eine Haupt-EAN-Lief vorhanden
*       sein, wenn es einen Lieferantenbezug gibt.
*----------------------------------------------------------------------*
MODULE CHECK_LFEAN_SA INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_CHECK_LFEA_SA_VA.

  ELSE.
* Normalfall

    READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
*                             MEINH =
                              LIFNR = RMMW2_LIEF        BINARY SEARCH.
*                             EAN11 =
    IF SY-SUBRC = 0.
*     Es existiert ein Lieferantenbezug
      SORT TMLEA BY MATNR LIFNR MEINH.
*     Umsortieren, damit erster Eintrag zum Lieferant gefunden wird.
*     Nochmal lesen zum Positionieren.
      READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
*                               MEINH =
                                LIFNR = RMMW2_LIEF        BINARY SEARCH.
*                               EAN11 =
      HTABIX = SY-TABIX.

      CLEAR: HILFS_MEEIN, HILFS_EAN, MLEA_LFEAN_KEY.

      ZAEHLER = 1.   " Zaehler für Anzahl Kz Haupt-EAN pro Mengeneinheit

*     Voraussetzung: Tabelle ist sortiert nach MATNR, LIFNR, MEINH
      LOOP AT TMLEA FROM HTABIX.
        IF TMLEA-MATNR NE RMMW1_MATN OR
           TMLEA-LIFNR NE RMMW2_LIEF.
          EXIT.
        ENDIF.

* Und nein, bei normalen Artikel erlauben wir KEINE Liferantenartikel
* nummer. Dafür gibt es den Einkaufs-Infosatz.
        IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
               mara-attyp NE '02'.
         clear TMLEA-LARTN.
         modify tmlea.
        endif.

*       Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*       für den Fall, daß die erste MEINH untersucht wird.
        CASE ZAEHLER.
         WHEN 0.                     " evtl. Fehlerfall: keine Haupt-EAN
            IF HILFS_MEEIN NE TMLEA-MEINH.
*             Wechsel MEINH und bei voriger MEINH keine Haupt-EAN
*             CLEAR RMMZU-OKCODE.

*             note 1085078: set LFEAN for single MLEA entries
              IF ZAEHLER2 = 1.
*               get previous TMLEA entry to set LFEAN
                READ TABLE TMLEA INTO LS_MLEA
                                 WITH KEY MATNR = RMMW1_MATN
                                          LIFNR = RMMW2_LIEF
                                          MEINH = HILFS_MEEIN
                                          BINARY SEARCH.
                LS_MLEA-LFEAN = 'X'.
                MODIFY TMLEA INDEX SY-TABIX FROM LS_MLEA.

*               Wechsel MEINH und vorige MEINH now O.K.
                ZAEHLER = 0.
                ZAEHLER2 = 1.

                IF NOT TMLEA-LFEAN IS INITIAL.
*               schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
                  ZAEHLER = ZAEHLER + 1.
                ENDIF.
                HILFS_MEEIN = TMLEA-MEINH. " neue MEINH merken
                HILFS_EAN   = TMLEA-EAN11. " erste neue EAN merken
                CONTINUE.
              ENDIF.

              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
              IF BILDFLAG IS INITIAL.
                BILDFLAG = X.
                EAN_FEHLERFLG_LFEAN = X.
                MESSAGE S159(MH) WITH RMMW2_LIEF HILFS_MEEIN.
*               keine Haupt-EAN-Lief gesetzt
*               TMLEA-Satz merken wegen Cursorpositionierung
                MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
                MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
              ENDIF.
              EXIT.
            ELSE.
*           MEINH unverändert
              IF NOT TMLEA-LFEAN IS INITIAL.
                ZAEHLER = ZAEHLER + 1. " Haupt-EAN gefunden
              ENDIF.
            ENDIF.

          WHEN 1.                      " LFEAN eindeutig
            IF HILFS_MEEIN NE TMLEA-MEINH.
*             Wechsel MEINH und vorige MEINH O.K.
              ZAEHLER = 0.

*             note 1085078: to set LFEAN for single MLEA entries
              ZAEHLER2 = 0.

              IF NOT TMLEA-LFEAN IS INITIAL.
*               schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
                ZAEHLER = ZAEHLER + 1.
              ENDIF.
              HILFS_MEEIN = TMLEA-MEINH. " neue MEINH merken
              HILFS_EAN   = TMLEA-EAN11. " erste neue EAN merken
            ELSE.
*             MEINH unverändert
              IF NOT TMLEA-LFEAN IS INITIAL.
                ZAEHLER = ZAEHLER + 1. " Haupt-EAN gefunden
              ENDIF.
            ENDIF.

          WHEN OTHERS.                 " Fehlerfall: mehrere Haupt-EAN
            IF HILFS_MEEIN NE TMLEA-MEINH.
*             Wechsel MEINH und bei voriger MEINH mehrere Haupt-EAN
*             CLEAR RMMZU-OKCODE.
              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
              IF BILDFLAG IS INITIAL.
                BILDFLAG = X.
                EAN_FEHLERFLG_LFEAN = X.
                MESSAGE S898 WITH RMMW2_LIEF HILFS_MEEIN.
*               Die Haupt-EAN zur MEINH ist nicht eindeutig
*               TMLEA-Satz merken wegen Cursorpositionierung
                MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
                MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
              ENDIF.
              EXIT.
            ELSE.
*             MEINH unverändert
              IF NOT TMLEA-LFEAN IS INITIAL.
                ZAEHLER = ZAEHLER + 1. " Haupt-EAN gefunden
              ENDIF.
            ENDIF.
        ENDCASE.
        ZAEHLER2 = ZAEHLER2 + 1. "note1085078: count MLEA of current uom
      ENDLOOP.

* Auswertung der letzten MEINH nach dem Loop !
      CASE ZAEHLER.
        WHEN 0.                        " Fehlerfall: keine Haupt-EAN
*         bei letzter MEINH keine Haupt-EAN
*         CLEAR RMMZU-OKCODE.

*         note 1085078: set LFEAN for single MLEA entries
          IF ZAEHLER2 = 1.
*           get previous TMLEA entry to set LFEAN
            READ TABLE TMLEA INTO LS_MLEA
                             WITH KEY MATNR = RMMW1_MATN
                                      LIFNR = RMMW2_LIEF
                                      MEINH = HILFS_MEEIN
                                      BINARY SEARCH.
            LS_MLEA-LFEAN = 'X'.
            MODIFY TMLEA INDEX SY-TABIX FROM LS_MLEA.
          ELSE.

            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*              Blättern muß hier ausnahmsweise erlaubt werden, um den
*              Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            IF BILDFLAG IS INITIAL.
              BILDFLAG = X.
              EAN_FEHLERFLG_LFEAN = X.
              MESSAGE S159(MH) WITH RMMW2_LIEF HILFS_MEEIN.
*             Bitte zuerst Haupt-EAN zur MEINH angeben
*             TMLEA-Satz merken wegen Cursorpositionierung
              MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
              MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
            ENDIF.
          ENDIF.

        WHEN 1.                        " HPEAN eindeutig
*         letzte MEINH O.K.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
*         bei letzter MEINH mehrere Haupt-EAN
*         CLEAR RMMZU-OKCODE.
          IF RMMZU-OKCODE NE FCODE_EAFP AND
             RMMZU-OKCODE NE FCODE_EAPP AND
             RMMZU-OKCODE NE FCODE_EANP AND
             RMMZU-OKCODE NE FCODE_EALP.
*           Blättern muß hier ausnahmsweise erlaubt werden, um den
*           Fehler ggf. auf einer anderen Seite korr. zu können.
            CLEAR RMMZU-OKCODE.
          ENDIF.
          IF BILDFLAG IS INITIAL.
            BILDFLAG = X.
            EAN_FEHLERFLG_LFEAN = X.
            MESSAGE S898 WITH RMMW2_LIEF HILFS_MEEIN.
*           Die Haupt-EAN zur MEINH ist nicht eindeutig
*           TMLEA-Satz merken wegen Cursorpositionierung
            MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
            MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
          ENDIF.
      ENDCASE.

*     nochmal zurücksortieren
      SORT TMLEA BY MATNR MEINH LIFNR EAN11.

    ENDIF.

  ENDIF.

ENDMODULE.                             " CHECK_LFEAN_SA  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SEGMENT  OUTPUT
*&---------------------------------------------------------------------*
* Perform below validations                                            *
* A. Segment values are allowed only if the segmentation is fixed      *
* B. Check if the segment value entered is valid                       *
* C. Set/Clear segment value change indicator (GV_SGT_CHANGE)          *
*----------------------------------------------------------------------*
MODULE VALIDATE_SEGMENT INPUT.

ENHANCEMENT-POINT LMGD2I14_01 SPOTS ES_MGD2_03 INCLUDE BOUND .

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_MEAN  INPUT
*&---------------------------------------------------------------------*
* MEAN_ME_TAB_SA and MEAN_TAB structures are modified to hold the      *
* segment values, only if the segment value is changed                 *
*----------------------------------------------------------------------*
MODULE MODIFY_MEAN INPUT.

ENHANCEMENT-POINT LMGD2I14_02 SPOTS ES_MGD2_03 INCLUDE BOUND .

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  UPDATE_MEAN  INPUT
*&---------------------------------------------------------------------*
* Update tables MEAN_ME_TAB and MEAN_TAB_SA with the changed EANS.     *
* Update the buffer tables GT_MEAN and GT_MEAN_TAB from above tables.  *
* If segment value is changed then load the buffer data into  tables   *
* MEAN_TAB_SA and MEAN_TAB                                             *
*----------------------------------------------------------------------*
MODULE UPDATE_MEAN INPUT.

ENHANCEMENT-POINT LMGD2I14_03 SPOTS ES_MGD2_03 INCLUDE BOUND .

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_MEAN  INPUT
*&---------------------------------------------------------------------*
* Perform below validations                                            *
* A. Check if the segment value entered is valid                       *
*----------------------------------------------------------------------*
MODULE validate_mean INPUT.
ENHANCEMENT-POINT LMGD2I14_04 SPOTS ES_MGD2_03 INCLUDE BOUND .

ENDMODULE.
