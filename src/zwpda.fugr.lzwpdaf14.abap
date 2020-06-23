*----------------------------------------------------------------------*
*   INCLUDE LWPDAF14                                                   *
*----------------------------------------------------------------------*
* FORM-Routinen für Performanceoptimierung (Filiale kopieren)
************************************************************************


************************************************************************
FORM FILIA_INDEPENDENCE_CHECK
     TABLES PIT_FILIA_GROUP        STRUCTURE GT_FILIA_GROUP
            PIT_OT1_F_WRGP         STRUCTURE GT_OT1_F_WRGP
            PIT_OT2_WRGP           STRUCTURE GT_OT2_WRGP
            PIT_OT1_F_ARTSTM       STRUCTURE GT_OT1_F_ARTSTM
            PIT_OT1_F_EAN          STRUCTURE GT_OT1_F_EAN
            PIT_OT1_F_SETS         STRUCTURE GT_OT1_F_SETS
            PIT_OT1_F_NART         STRUCTURE GT_OT1_F_NART
            PIT_OT1_K_PERS         STRUCTURE GT_OT1_K_PERS
            PIT_OT2_PERS           STRUCTURE GT_OT2_PERS
            PET_INDEPENDENCE_CHECK STRUCTURE GT_INDEPENDENCE_CHECK
     USING  PI_ERSTDAT             LIKE SYST-DATUM
            PI_DATP3               LIKE SYST-DATUM
            PI_DATP4               LIKE SYST-DATUM.
************************************************************************
* FUNKTION:
* Bestimme welche IDOC-Typen für welche Filialen der Gruppe
* außschließlich filialunabhängige Änderungen enthalten.
* Das Ergebnis wird in der Tabelle PET_INDEPENDENCE_CHECK
* zurückgegeben.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILIA_GROUP       : Daten der Filialen dieser Filialgruppe.
*
* PIT_OT1_F_WRGP        : Warengruppen: Objekttabelle 1, filialabhängig.
*
* PIT_OT2_WRGP          : Warengruppen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT1_F_ARTSTM      : Artikelstamm: Objekttabelle 1, filialabhängig.
*
* PET_OT1_F_EAN         : EAN-Referenzen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT1_F_SETS        : Set-Zuordnungen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT1_F_NART        : Nachzugsartikel: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT1_K_PERS        : Personendaten: Objekttabelle 1,
*                         Kreditkontrollbereichsabhängig.
* PIT_OT2_PERS          : Personendaten: Objekttabelle 2,
*                         filialunabhängig.
* PET_INDEPENDENCE_CHECK: Ergebnistabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PI_ERSTDAT            : Datum: jetziges Versenden.
*
* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.
*
* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: H_WRF6_READ,
        H_WDAUS_CHECK.         "     'I': initial, 'X': WDAUS <> SPACE,
                                       "     ' ': WDAUS = SPACE.

  DATA: BEGIN OF T_WRF6 OCCURS 100.
          INCLUDE STRUCTURE WRF6.
  DATA: END OF T_WRF6.


* Ausgabetabelle initialisieren.
  REFRESH: PET_INDEPENDENCE_CHECK.
  CLEAR:   PET_INDEPENDENCE_CHECK.

* Die letzte Filiale der Gruppe kann nicht mehr als Kopiervorlage
* für andere Filialen dienen.
  LOOP AT PIT_FILIA_GROUP.
*   Hilfsvariablen initialisieren.
    CLEAR: H_WRF6_READ.
    H_WDAUS_CHECK = C_INIT_MODE.

    CLEAR: PET_INDEPENDENCE_CHECK.
    MOVE-CORRESPONDING PIT_FILIA_GROUP TO PET_INDEPENDENCE_CHECK.

*   Falls Warengruppen aufbereitet werden sollen.
    IF PIT_FILIA_GROUP-NPMEC IS INITIAL.
*     Prüfe, ob IDOC-Typ 'Warengruppen' filialunabhängig ist.
*     Gibt es filialabhängige Änderungen ?
      READ TABLE PIT_OT1_F_WRGP WITH KEY
           FILIA = PIT_FILIA_GROUP-FILIA
           BINARY SEARCH.

*     Falls keine filialabhängigkeit besteht, dann
*     nächster Analyseschritt.
      IF SY-SUBRC <> 0.
*       Falls der Verkauf über alle Warengruppen läuft, dann
*       vermerken in Ausgabetabelle.
        IF PIT_FILIA_GROUP-SALLMG <> SPACE.
          PET_INDEPENDENCE_CHECK-WRGP = 'X'.

*       Falls der Verkauf nicht über alle Warengruppen läuft, dann
*       nächster Analyseschritt.
        ELSE.                          " pit_filia_group-sallmg = space.
*         Besorge alle WRF6-Zuordnungen für diese Filiale
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
               EXPORTING
                    PI_FILIALE     = PIT_FILIA_GROUP-KUNNR
               TABLES
                    PE_T_WRF6      = T_WRF6
               EXCEPTIONS
                    NO_WRF6_RECORD = 01
                    NO_WRGP_FOUND  = 02.

*         Merken, daß WRF6 bereits gelesen wurde.
          H_WRF6_READ = 'X'.

*         Falls keine WRF6-Zuordnungen für diese Filiale existieren,
*         dann vermerken in Ausgabetabelle.
          IF SY-SUBRC <> 0.
            PET_INDEPENDENCE_CHECK-WRGP = 'X'.
          ENDIF."  sy-subrc <> 0.             " WRF6-select
        ENDIF. " pit_filia_group-sallmg <> space.
      ENDIF.                             " sy-subrc <> 0.

*     Falls eine potentielle Kopiermutter vorliegt.
      IF PET_INDEPENDENCE_CHECK-WRGP <> SPACE.
*       Gibt es wenigstens filialunabhängige Änderungen ?
        READ TABLE PIT_OT2_WRGP INDEX 1.

*       Falls überhaupt keine Warengruppen geändert wurden, dann werden
*       auch keine versendet und das Kopiermutter-Flag muß zurückge-
*       nommen werden.
        IF SY-SUBRC <> 0.
          CLEAR: PET_INDEPENDENCE_CHECK-WRGP.
        ENDIF. " sy-subrc <> 0.
      ENDIF. " pet_independence_check-wrgp <> space.
    ENDIF. " pit_filia_group-npmec is initial.

*   Falls Artikelstammdaten aufbereitet werden sollen.
    IF PIT_FILIA_GROUP-NPMAT IS INITIAL.
*     Prüfe, ob IDOC-Typ 'Artikelstamm' filialunabhängig ist.
      READ TABLE PIT_OT1_F_ARTSTM WITH KEY
           FILIA = PIT_FILIA_GROUP-FILIA
           BINARY SEARCH.

*     Falls keine filialabhängigkeit besteht, dann nächster
*     Analyseschritt.
      IF SY-SUBRC <> 0.
*       Falls WRF6 bereits gelesen wurde.
        IF H_WRF6_READ <> SPACE.
*         Setze SY-SUBRC auf 0.
          READ TABLE T_WRF6 INDEX 1.

*       Falls WRF6 noch nicht gelesen wurde, dann lese WRF6.
        ELSE. " H_WRF6_READ = SPACE.
*         Besorge alle WRF6-Zuordnungen für diese Filiale
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
               EXPORTING
                    PI_FILIALE     = PIT_FILIA_GROUP-KUNNR
               TABLES
                    PE_T_WRF6      = T_WRF6
               EXCEPTIONS
                    NO_WRF6_RECORD = 01
                    NO_WRGP_FOUND  = 02.

*         Merken, daß WRF6 bereits gelesen wurde.
          H_WRF6_READ = 'X'.
        ENDIF.                           " h_wrf6_read <> space.

*       Falls keine WRF6-Zuordnungen für diese Filiale existieren,
*       dann vermerken in Ausgabetabelle.
        IF SY-SUBRC <> 0.
          PET_INDEPENDENCE_CHECK-ARTSTM = 'X'.

*       Falls WRF6-Zuordnungen für diese Filiale existieren, dann
*       nächster Analyseschritt.
        ELSE.                            " sy-subrc = 0.
*         Prüfe, ob Warengruppen von der Versendung an diese Filiale
*         ausgeschlossen sind.
          LOOP AT T_WRF6
               WHERE WDAUS <> SPACE.
*           Merken, daß zumindest ein WDAUS-Eintrag <> SPACE war.
            H_WDAUS_CHECK = 'X'.
            EXIT.
          ENDLOOP.                     " at t_wrf6

*         Falls es keine Warengruppen gibt die explizit von
*         der Versendung an diese Filiale ausgeschlossen sind, dann
*         vermerken in Ausgabetabelle.
          IF SY-SUBRC <> 0.
*           Merken, daß kein WDAUS-Eintrag <> SPACE war.
            CLEAR: H_WDAUS_CHECK.
            PET_INDEPENDENCE_CHECK-ARTSTM = 'X'.
          ENDIF.                       " sy-subrc <> 0.
        ENDIF."  sy-subrc <> 0.             " WRF6-select
      ENDIF.                             " sy-subrc <> 0.


*     Prüfe, ob IDOC-Typ 'EAN-Referenzen' filialunabhängig ist.
      READ TABLE PIT_OT1_F_EAN WITH KEY
           FILIA = PIT_FILIA_GROUP-FILIA
           BINARY SEARCH.

*     Falls keine filialabhängigkeit besteht, dann nächster
*     Analyseschritt.
      IF SY-SUBRC <> 0.
*       Falls WRF6 bereits gelesen wurde.
        IF H_WRF6_READ <> SPACE.
*         Setze SY-SUBRC auf 0.
          READ TABLE T_WRF6 INDEX 1.

*       Falls WRF6 noch nicht gelesen wurde, dann lese WRF6.
        ELSE. " H_WRF6_READ = SPACE.
*         Besorge alle WRF6-Zuordnungen für diese Filiale
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
               EXPORTING
                    PI_FILIALE     = PIT_FILIA_GROUP-KUNNR
               TABLES
                    PE_T_WRF6      = T_WRF6
               EXCEPTIONS
                    NO_WRF6_RECORD = 01
                    NO_WRGP_FOUND  = 02.

*         Merken, daß WRF6 bereits gelesen wurde.
          H_WRF6_READ = 'X'.
        ENDIF.                           " h_wrf6_read <> space.

*       Falls keine WRF6-Zuordnungen für diese Filiale existieren,
*       dann vermerken in Ausgabetabelle.
        IF SY-SUBRC <> 0.
          PET_INDEPENDENCE_CHECK-EAN = 'X'.

*       Falls WRF6-Zuordnungen für diese Filiale existieren, dann
*       nächster Analyseschritt.
        ELSE.                            " sy-subrc = 0.
*         Falls noch keine WRF6-Überprüfung stattgefunden hat, dann
*         WRF6-Überprüfung.
          IF H_WDAUS_CHECK = 'I'.
*           Prüfe, ob Warengruppen von der Versendung an diese Filiale
*           ausgeschlossen sind.
            LOOP AT T_WRF6
                 WHERE WDAUS <> SPACE.
*             Merken, daß zumindest ein WDAUS-Eintrag <> SPACE war.
              H_WDAUS_CHECK = 'X'.
              EXIT.
            ENDLOOP.                     " at t_wrf6

*           Falls es keine Warengruppen gibt die explizit von
*           der Versendung an diese Filiale ausgeschlossen sind, dann
*           vermerken in Ausgabetabelle.
            IF SY-SUBRC <> 0.
*             Merken, daß kein WDAUS-Eintrag <> SPACE war.
              CLEAR: H_WDAUS_CHECK.
              PET_INDEPENDENCE_CHECK-EAN = 'X'.
            ENDIF.                       " sy-subrc <> 0.

*         Falls schon eine WRF6-Überprüfung stattgefunden hat,
*         WRF6-Überprüfung und kein WDAUS-Flag gesetzt ist, dann
*         vermerken in Ausgabetabelle.
          ELSEIF H_WDAUS_CHECK = SPACE.
            PET_INDEPENDENCE_CHECK-EAN = 'X'.
          ENDIF.                         " h_wdaus_check = 'I'.
        ENDIF."  sy-subrc <> 0.             " WRF6-select
      ENDIF.                             " sy-subrc <> 0.
    ENDIF. " pit_filia_group-npmat is initial.

*   Falls Set-Zuordnungen aufbereitet werden sollen.
    IF PIT_FILIA_GROUP-NPSET IS INITIAL.
*     Prüfe, ob IDOC-Typ 'Set-Artikel' filialunabhängig ist.
      READ TABLE PIT_OT1_F_SETS WITH KEY
           FILIA = PIT_FILIA_GROUP-FILIA
           BINARY SEARCH.

*     Falls keine filialabhängigkeit besteht, dann nächster
*     Analyseschritt.
      IF SY-SUBRC <> 0.
*       Falls WRF6 bereits gelesen wurde.
        IF H_WRF6_READ <> SPACE.
*         Setze SY-SUBRC auf 0.
          READ TABLE T_WRF6 INDEX 1.

*       Falls WRF6 noch nicht gelesen wurde, dann lese WRF6.
        ELSE. " H_WRF6_READ = SPACE.
*         Besorge alle WRF6-Zuordnungen für diese Filiale
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
               EXPORTING
                    PI_FILIALE     = PIT_FILIA_GROUP-KUNNR
               TABLES
                    PE_T_WRF6      = T_WRF6
               EXCEPTIONS
                    NO_WRF6_RECORD = 01
                    NO_WRGP_FOUND  = 02.

*         Merken, daß WRF6 bereits gelesen wurde.
          H_WRF6_READ = 'X'.
        ENDIF.                           " h_wrf6_read <> space.

*       Falls keine WRF6-Zuordnungen für diese Filiale existieren,
*       dann vermerken in Ausgabetabelle.
        IF SY-SUBRC <> 0.
          PET_INDEPENDENCE_CHECK-SETS = 'X'.

*       Falls WRF6-Zuordnungen für diese Filiale existieren, dann
*       nächster Analyseschritt.
        ELSE.                            " sy-subrc = 0.
*         Falls noch keine WRF6-Überprüfung stattgefunden hat, dann
*         WRF6-Überprüfung.
          IF H_WDAUS_CHECK = 'I'.
*           Prüfe, ob Warengruppen von der Versendung an diese Filiale
*           ausgeschlossen sind.
            LOOP AT T_WRF6
                 WHERE WDAUS <> SPACE.
*             Merken, daß zumindest ein WDAUS-Eintrag <> SPACE war.
              H_WDAUS_CHECK = 'X'.
              EXIT.
            ENDLOOP.                     " at t_wrf6

*           Falls es keine Warengruppen gibt die explizit von
*           der Versendung an diese Filiale ausgeschlossen sind, dann
*           vermerken in Ausgabetabelle.
            IF SY-SUBRC <> 0.
*             Merken, daß kein WDAUS-Eintrag <> SPACE war.
              CLEAR: H_WDAUS_CHECK.
              PET_INDEPENDENCE_CHECK-SETS = 'X'.
            ENDIF.                       " sy-subrc <> 0.

*         Falls schon eine WRF6-Überprüfung stattgefunden hat,
*         WRF6-Überprüfung und kein WDAUS-Flag gesetzt ist, dann
*         vermerken in Ausgabetabelle.
          ELSEIF H_WDAUS_CHECK = SPACE.
            PET_INDEPENDENCE_CHECK-SETS = 'X'.
          ENDIF.                         " h_wdaus_check = 'I'.
        ENDIF."  sy-subrc <> 0.             " WRF6-select
      ENDIF.                             " sy-subrc <> 0.
    ENDIF. " pit_filia_group-npset is initial.

*   Falls Nachzugsartikel aufbereitet werden sollen.
    IF PIT_FILIA_GROUP-NPFOA IS INITIAL.
*     Prüfe, ob IDOC-Typ 'Nachzugsartikel' filialunabhängig ist.
      READ TABLE PIT_OT1_F_NART WITH KEY
           FILIA = PIT_FILIA_GROUP-FILIA
           BINARY SEARCH.

*     Falls keine filialabhängigkeit besteht, dann nächster
*     Analyseschritt.
      IF SY-SUBRC <> 0.
*       Falls WRF6 bereits gelesen wurde.
        IF H_WRF6_READ <> SPACE.
*         Setze SY-SUBRC auf 0.
          READ TABLE T_WRF6 INDEX 1.

*       Falls WRF6 noch nicht gelesen wurde, dann lese WRF6.
        ELSE. " H_WRF6_READ = SPACE.
*         Besorge alle WRF6-Zuordnungen für diese Filiale
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
               EXPORTING
                    PI_FILIALE     = PIT_FILIA_GROUP-KUNNR
               TABLES
                    PE_T_WRF6      = T_WRF6
               EXCEPTIONS
                    NO_WRF6_RECORD = 01
                    NO_WRGP_FOUND  = 02.

*         Merken, daß WRF6 bereits gelesen wurde.
          H_WRF6_READ = 'X'.
        ENDIF.                           " h_wrf6_read <> space.

*       Falls keine WRF6-Zuordnungen für diese Filiale existieren,
*       dann vermerken in Ausgabetabelle.
        IF SY-SUBRC <> 0.
          PET_INDEPENDENCE_CHECK-NART = 'X'.

*       Falls WRF6-Zuordnungen für diese Filiale existieren, dann
*       nächster Analyseschritt.
        ELSE.                            " sy-subrc = 0.
*         Falls noch keine WRF6-Überprüfung stattgefunden hat, dann
*         WRF6-Überprüfung.
          IF H_WDAUS_CHECK = 'I'.
*           Prüfe, ob Warengruppen von der Versendung an diese Filiale
*           ausgeschlossen sind.
            LOOP AT T_WRF6
                 WHERE WDAUS <> SPACE.
              EXIT.
            ENDLOOP.                     " at t_wrf6

*           Falls es keine Warengruppen gibt die explizit von
*           der Versendung an diese Filiale ausgeschlossen sind, dann
*           vermerken in Ausgabetabelle.
            IF SY-SUBRC <> 0.
              PET_INDEPENDENCE_CHECK-NART = 'X'.
            ENDIF.                       " sy-subrc <> 0.

*         Falls schon eine WRF6-Überprüfung stattgefunden hat,
*         WRF6-Überprüfung und kein WDAUS-Flag gesetzt ist, dann
*         vermerken in Ausgabetabelle.
          ELSEIF H_WDAUS_CHECK = SPACE.
            PET_INDEPENDENCE_CHECK-NART = 'X'.
          ENDIF.                         " h_wdaus_check = 'I'.
        ENDIF."  sy-subrc <> 0.             " WRF6-select
      ENDIF.                             " sy-subrc <> 0.
    ENDIF. " pit_filia_group-npfoa is initial.

*   Falls Personendaten aufbereitet werden sollen.
    IF PIT_FILIA_GROUP-NPCUS IS INITIAL.
*     Prüfe, ob IDOC-Typ 'Personendaten' filialunabhängig ist.
      READ TABLE PIT_OT1_K_PERS WITH KEY
           KKBER = PIT_FILIA_GROUP-KKBER
           BINARY SEARCH.

*     Falls keine Kreditkontrollbereichsabhängigkeit besteht, dann
*     vermerken in Ausgabetabelle.
      IF SY-SUBRC <> 0.
*       Gibt es wenigstens filialunabhängige Änderungen ?
        READ TABLE PIT_OT2_PERS INDEX 1.

*       Falls Personendaten geändert wurden.
        IF SY-SUBRC = 0.
          CLEAR: PET_INDEPENDENCE_CHECK-KKBER.
          PET_INDEPENDENCE_CHECK-PERS = 'X'.
        ENDIF. " sy-subrc = 0.

*     Falls eine Kreditkontrollbereichsabhängigkeit besteht, dann
*     vermerken in Ausgabetabelle.
      ELSE.                              " sy-subrc = 0.
        PET_INDEPENDENCE_CHECK-PERS = 'X'.
      ENDIF.                             " sy-subrc <> 0.
    ENDIF. " pit_filia_group-npcus is initial.

*   Übernahme Analysesatz in Ausgabetabelle.
    APPEND PET_INDEPENDENCE_CHECK.

  ENDLOOP.                             " at pit_filia_group

* Daten sortieren.
  SORT PET_INDEPENDENCE_CHECK BY FILIA VKORG VTWEG.


ENDFORM.                               " filia_independence_check


*eject
************************************************************************
FORM KONDITION_INDEPENDENCE_CHECK
     TABLES PIT_ARTSTM             STRUCTURE GT_OT3_ARTSTM
            PXT_INDEPENDENCE_CHECK STRUCTURE GT_INDEPENDENCE_CHECK
            PIT_KONDART            STRUCTURE WPKARTFLAG
     USING  PI_FILIA_GROUP         STRUCTURE GT_FILIA_GROUP
            PI_ERSTDAT             LIKE SYST-DATUM
            PI_DATP4               LIKE SYST-DATUM.
************************************************************************
* FUNKTION:
* Prüfe alle in PIT_ARTSTM vorkommenden Artikel dieser Filiale,
* ob sie filialabhängige Konditionsintervalle innerhalb des
* Betrachtungszeitraums PI_ERSTDAT bis PI_DATP4 besitzen.
* Das Ergebnis wird durch Änderung der Tabelle PXT_INDEPENDENCE_CHECK
* vermerkt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTSTM            : Tabelle der zu überprüfenden Artikel.
*
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PIT_KONDART           : Die dieser Filiale zugeordneten
*                         Konditionsarten.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
*
* PI_ERSTDAT            : Beginn des Betrachtungszeitraums
*                         (jetziges Versenden).
* PI_DATP4              : Ende des Betrachtungszeitraums
*                         (letztes Versenden + Vorlaufzeit).
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: KEY1          LIKE MARA-MATNR,
        KEY2          LIKE MARA-MATNR,
        H_INDEX       LIKE SY-TABIX,
        PERIODS_LINES TYPE I,
        MATNR_LINES   TYPE I,
        H_COUNTER     LIKE SY-INDEX,
        H_VERWENDUNG  LIKE KONH-KVEWE,
        H_APPLIKATION LIKE KONH-KAPPL,
        H_ALREADY_READ,
        H_BEENDEN.


* Struktur für Mußfelder.
  DATA: BEGIN OF I_KOMG_MUST.
          INCLUDE STRUCTURE KOMG.
  DATA: END OF I_KOMG_MUST.

* Interner Puffer für Konditionsintervalle.
  DATA: BEGIN OF T_PERIODS_BUF OCCURS 4000.
          INCLUDE STRUCTURE WCONDINT.
  DATA: END OF T_PERIODS_BUF.

* Zwischenspeicher für Artikelnummern.
  DATA: BEGIN OF T_MATNR OCCURS 500,
          MATNR LIKE MARA-MATNR.
  DATA: END OF T_MATNR.

* Tabelle mit Konditionsarten.
  DATA: BEGIN OF T_KONDART OCCURS 10.
          INCLUDE STRUCTURE WPKSCHL.
  DATA: END OF T_KONDART.


* Besorge Referenzvertriebsweg, falls möglich.
  CALL FUNCTION 'TVKOV_SINGLE_READ'
       EXPORTING
            TVKOV_VKORG = PI_FILIA_GROUP-VKORG
            TVKOV_VTWEG = PI_FILIA_GROUP-VTWEG
       IMPORTING
            WTVKOV      = TVKOV
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2.

* Falls ein Referenzvertriebsweg gefunden wurde und dieser nicht
* auf sich selbst verweist, dann kann es keine Konditionen auf
* Filialebene geben.
  IF SY-SUBRC = 0 AND PI_FILIA_GROUP-VTWEG <> TVKOV-VTWKO.
*   Keine weitere Analyse notwendig.
    EXIT.
  ENDIF. " sy-subrc = 0 and pi_filia_group-vtweg <> tvkov-vtwko.

* Initialisiere Hilfsvariablen.
  H_COUNTER     = 2.
  H_VERWENDUNG  = C_COND_VEWE.
  H_APPLIKATION = C_COND_APPL.

* Rücksetze interne Tabellenpuffer.
  REFRESH: T_KONDART.
  CLEAR:   T_KONDART.

* Setze Mußfelder.
  I_KOMG_MUST-WERKS = 'X'.
  I_KOMG_MUST-MATNR = 'X'.

* Initialisiere Objektschlüssel.
  CLEAR: GI_KOMG.

* Ergänze Objektschlüssel
  GI_KOMG-VKORG = PI_FILIA_GROUP-VKORG.
  GI_KOMG-VTWEG = PI_FILIA_GROUP-VTWEG.
  GI_KOMG-WERKS = PI_FILIA_GROUP-FILIA.

* Sortieren der übergebenen Konditionsarten.
  SORT PIT_KONDART BY KSCHL.

* Übernehme alle Konditionsarten für diese Filiale aus PIT_KONDART
* in eine Tabelle mit anderer Struktur.
  LOOP AT PIT_KONDART.
    MOVE-CORRESPONDING PIT_KONDART TO T_KONDART.
    APPEND T_KONDART.
  ENDLOOP.                             "  PIT_KONDART

  CLEAR: H_ALREADY_READ.
  DO H_COUNTER TIMES.
*   Falls Analyse von Naturalrabattkonditionen erfolgen soll.
    IF SY-INDEX = 2.
      H_VERWENDUNG   = C_NATRAB_VEWE.
      H_APPLIKATION  = C_NATRAB_APPL.
      H_ALREADY_READ = 'X'.
    ENDIF. " sy-index = 2.

*   Besorge alle filialabhängigen Konditionsintervalle, aller Artikel
*   für diese Filiale, die im Intervall PI_ERSTDAT bis PI_DATP4
*   gültig sind.
    REFRESH: T_PERIODS_BUF.
    CALL FUNCTION 'WWS_CONDITION_INTERVALS_GET'
         EXPORTING
              KOMG_I           = GI_KOMG
              KOMG_MUST_I      = I_KOMG_MUST
              DATVO_I          = PI_ERSTDAT
              DATBI_I          = PI_DATP4
              PI_GENERIC       = 'X'
              PI_KOMG_MUST     = 'X'
              PI_KEYFIELD_MUST = 'X'
              KVEWE_I          = H_VERWENDUNG
              KAPPL_I          = H_APPLIKATION
              pi_mode          = c_pos_mode
         TABLES
              PI_T_KSCHL       = T_KONDART
              PE_T_CONDINT     = T_PERIODS_BUF.

*   Prüfe, ob Konditionen gefunden wurden.
    READ TABLE T_PERIODS_BUF INDEX 1.

*   Aufbereitung verlassen, da keine filialabhängigen Konditionen für
*   dieses Intervall vorhanden sind.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.                               " SY-SUBRC <> 0.

*   Sortieren der Daten.
    SORT T_PERIODS_BUF BY MATNR.

*   Löschen aller doppelten Materialnummern aus Konditionstabelle.
    DELETE ADJACENT DUPLICATES FROM T_PERIODS_BUF COMPARING MATNR.

*   Falls Analyse von normalen Konditionen erfolgen soll.
    IF H_ALREADY_READ IS INITIAL.
*     Übernehme alle unterschiedlichen Artikelnummern aus PIT_ARTSTM
*     in eine separate interne Tabelle.
      CLEAR: KEY1, KEY2.
      LOOP AT PIT_ARTSTM.
        KEY2 = PIT_ARTSTM-ARTNR.
        IF KEY1 <> KEY2.
          KEY1 = KEY2.
          APPEND PIT_ARTSTM-ARTNR TO T_MATNR.
        ENDIF.                             " key1 <> key2.
      ENDLOOP.                             " at pit_artstm

*     Besorge zugehörigen Satz in Filialcopy-Tabelle.
      READ TABLE PXT_INDEPENDENCE_CHECK WITH KEY
           FILIA = PI_FILIA_GROUP-FILIA
           BINARY SEARCH.

      H_INDEX = SY-TABIX.
    ENDIF. " h_already_read is initial.

*   Prüfe, welche Tabelle mehr Einträge hat, damit eine Entscheidung
*   bzgl. des Suchalgorithmus vorgenommen werden kann.
    DESCRIBE TABLE T_PERIODS_BUF LINES PERIODS_LINES.
    DESCRIBE TABLE T_MATNR       LINES MATNR_LINES.

*   Falls T_PERIODS_BUF die wenigsten Zeilen hat.
    IF PERIODS_LINES <= MATNR_LINES.
*     Prüfe, ob Artikelnummern aus T_MATNR in T_PERIODS_BUF vorkommen.
      LOOP AT T_PERIODS_BUF.
        READ TABLE T_MATNR WITH KEY
             MATNR = T_PERIODS_BUF-MATNR
             BINARY SEARCH.

        IF SY-SUBRC = 0.
*         Sorge dafür, daß diese Filiale keine weitere
*         Kopiermutter für den IDOC-Typ Artikelstamm wird.
          CLEAR: PXT_INDEPENDENCE_CHECK-ARTSTM.
          MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*         Weitere Analyse verlassen.
          H_BEENDEN = 'X'.
          EXIT.
        ENDIF.                           " sy-subrc = 0.
      ENDLOOP.                           " t_periods_buf.

*   Falls T_MATNR die wenigsten Zeilen hat.
    ELSE.                                " periods_lines > matnr_lines.
*     Prüfe, ob Artikelnummern aus T_PERIODS_BUF in T_MATNR vorkommen.
      LOOP AT T_MATNR.
        READ TABLE T_PERIODS_BUF WITH KEY
             MATNR = T_MATNR-MATNR
             BINARY SEARCH.

        IF SY-SUBRC = 0.
*         Sorge dafür, daß diese Filiale keine weitere
*         Kopiermutter für den IDOC-Typ Artikelstamm wird.
          CLEAR: PXT_INDEPENDENCE_CHECK-ARTSTM.
          MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*         Weitere Analyse verlassen.
          H_BEENDEN = 'X'.
          EXIT.
        ENDIF.                           " sy-subrc = 0.
      ENDLOOP.                           " t_matnr.

*     Falls die Aufbereitung verlassen werden soll.
      IF NOT H_BEENDEN IS INITIAL.
        EXIT.
      ENDIF. " not h_beenden is intial.
    ENDIF.                               " periods_lines <= matnr_lines
  ENDDO. " h_counter times.


ENDFORM.                               " kondition_independence_check


*eject
************************************************************************
FORM STATUS_INDEPENDENCE_CHECK
     TABLES PXT_INDEPENDENCE_CHECK STRUCTURE GT_INDEPENDENCE_CHECK
            PXT_MASTER_IDOCS       STRUCTURE GT_MASTER_IDOCS
     USING  PI_FILIA_GROUP         STRUCTURE GT_FILIA_GROUP
            PI_DLDNR               LIKE WDLS-DLDNR.
************************************************************************
* FUNKTION:
* Analysiere die Status-Einträge dieser Filiale und dieser
* Filialgruppe daraufhin, ob IDOC-Typen als Kopiermutter verwendet
* werden können.
* Das Ergebnis wird durch Änderung der Tabelle PXT_INDEPENDENCE_CHECK
* vermerkt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_MASTER_IDOCS      : Tabelle der Kopierfähigen IDOC's
*
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
*
* PI_DLDNR              : Downloadnummer für Statusverfolgung.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: H_INDEX LIKE SY-TABIX,
        H_KKBER LIKE T001-KKBER,
        KEY1    LIKE WDLSP-DOCTYP,
        KEY2    LIKE WDLSP-DOCTYP,
        H_SKIP,
        H_IDOC_TYPE_OK.

  DATA: BEGIN OF I_INDEPENDENCE_CHECK.
          INCLUDE STRUCTURE GT_INDEPENDENCE_CHECK.
  DATA: END OF I_INDEPENDENCE_CHECK.

  DATA: BEGIN OF T_WDLSP OCCURS 50.
          INCLUDE STRUCTURE WDLSP.
  DATA: END OF T_WDLSP.

* Temporärtabelle der IDOC-Nummern pro IDOC-Typ pro Filiale
  DATA: BEGIN OF T_MASTER_IDOCS_TEMP OCCURS 50.
          INCLUDE STRUCTURE GT_MASTER_IDOCS.
  DATA: END OF T_MASTER_IDOCS_TEMP.

* Bestimme die zugehörigen filialunabhängigkeitsdaten.
  READ TABLE PXT_INDEPENDENCE_CHECK WITH KEY
       FILIA = PI_FILIA_GROUP-FILIA
       BINARY SEARCH.

* Falls Filialunabhängigkeitstabelle nicht gefüllt ist, dann kein
* Filialcopy  ===> Analyse abbrechen.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.                               " sy-subrc <> 0.

  H_INDEX = SY-TABIX.
  H_KKBER = PXT_INDEPENDENCE_CHECK-KKBER.

* Zwischenspeichern dieser internen Tabellenzeile.
  I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

* Lese Status-Kopfzeile.
  SELECT SINGLE * FROM WDLS
         WHERE DLDNR = PI_DLDNR.

* lese zugehörige Status-Positionszeilen ohne Steuern und Wechselkurse.
  SELECT * FROM WDLSP INTO TABLE T_WDLSP
         WHERE DLDNR  =  PI_DLDNR
         AND   DOCTYP <> C_IDOCTYPE_CUR
         AND   DOCTYP <> C_IDOCTYPE_STEU
         AND   RFPOS  =  '000000'.

  CLEAR: KEY1, KEY2.
  LOOP AT T_WDLSP.
    CLEAR: T_MASTER_IDOCS_TEMP.

    MOVE T_WDLSP-DOCTYP TO KEY2.

    IF KEY1 = KEY2.
*     Falls bereits eine entsprechende Kopiermutter existiert,
*     dann kann dieser IDOC-Typ übersprungen werden.
      IF H_SKIP <> SPACE.
        CONTINUE.
      ENDIF.                           " h_skip <> space.

    ELSE.                              " key1 <> key2.
      KEY1 = KEY2.

      IF SY-TABIX > 1.
*       Falls alle IDOC's eines IDOC-Typs kopiert werden können.
        IF H_IDOC_TYPE_OK <> SPACE AND H_SKIP = SPACE.
*         Zwischenspeicher an IDOC-Puffer anhängen.
          LOOP AT T_MASTER_IDOCS_TEMP.
            APPEND T_MASTER_IDOCS_TEMP TO PXT_MASTER_IDOCS.
          ENDLOOP.                     " at t_master_idocs_temp.

*         Korrigieren der Filialunabhängigkeitstabelle
          PXT_INDEPENDENCE_CHECK    = I_INDEPENDENCE_CHECK.
          PXT_INDEPENDENCE_CHECK-OK = 'X'.
          MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*         Zwischenspeichern dieser internen Tabellenzeile aktualisieren.
          I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.
        ENDIF. " h_idoc_type_ok <> space and h_skip = space.
      ENDIF.                           " sy-tabix > 1.

*     Initialisieren Zwischenspeicher für nächste Analyse.
      REFRESH: T_MASTER_IDOCS_TEMP.

*     Initialisiere Hilfsvariablen.
      CLEAR: H_SKIP.
      H_IDOC_TYPE_OK = 'X'.

      CASE T_WDLSP-DOCTYP.
*       Falls es sich um Warengruppen-IDOC's handelt.
        WHEN C_IDOCTYPE_WRGP.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          IF I_INDEPENDENCE_CHECK-WRGP <> SPACE.
*           Prüfe, ob es bereits eine entsprechende Kopiermutter gibt.
            LOOP AT PXT_INDEPENDENCE_CHECK
                 WHERE FILIA <  PI_FILIA_GROUP-FILIA
                 AND   WRGP  <> SPACE
                 AND   OK    <> SPACE.
              EXIT.
            ENDLOOP.                   " at pxt_independence_check

*           Wenn es bereits eine entsprechende Kopiermutter gibt,
*           dann ist keine weitere Analyse nötig.
            IF SY-SUBRC = 0.
*             Korrigieren der Filialunabhängigkeitstabelle
              PXT_INDEPENDENCE_CHECK = I_INDEPENDENCE_CHECK.
              CLEAR: PXT_INDEPENDENCE_CHECK-WRGP.
              MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*             Zwischenspeichern dieser internen Tabellenzeile
*             aktualisieren.
              I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

*             Setze Hilfsvariable zum Überspringen der weiteren
*             Positionszeilen dieses IDOC-Typs.
              H_SKIP = 'X'.

*             Weiter zur nächsten Positionszeile.
              CONTINUE.
            ENDIF.                     " sy-subrc = 0.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          ELSE. " i_independence_check-wrgp = space.
*           Setze Hilfsvariable zum Überspringen der weiteren
*           Positionszeilen dieses IDOC-Typs.
            H_SKIP = 'X'.

*           Weiter zur nächsten Positionszeile.
            CONTINUE.
          ENDIF. " i_independence_check-wrgp <> space.

*       Falls es sich um Artikelstamm-IDOC's handelt
        WHEN C_IDOCTYPE_ARTSTM.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          IF I_INDEPENDENCE_CHECK-ARTSTM <> SPACE.
*           Prüfe, ob es bereits eine entsprechende Kopiermutter gibt.
            LOOP AT PXT_INDEPENDENCE_CHECK
                 WHERE FILIA  <  PI_FILIA_GROUP-FILIA
                 AND   ARTSTM <> SPACE
                 AND   SPRAS  =  PI_FILIA_GROUP-SPRAS
                 AND   OK     <> SPACE.
              EXIT.
            ENDLOOP.                   " at pxt_independence_check

*           Wenn es bereits eine entsprechende Kopiermutter gibt,
*           dann ist keine weitere Analyse nötig.
            IF SY-SUBRC = 0.
*             Korrigieren der Filialunabhängigkeitstabelle
              PXT_INDEPENDENCE_CHECK = I_INDEPENDENCE_CHECK.
              CLEAR: PXT_INDEPENDENCE_CHECK-ARTSTM.
              MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*             Zwischenspeichern dieser internen Tabellenzeile
*             aktualisieren.
              I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

*             Setze Hilfsvariable zum Überspringen der weiteren
*             Positionszeilen dieses IDOC-Typs.
              H_SKIP = 'X'.

*             Weiter zur nächsten Positionszeile.
              CONTINUE.
            ENDIF.                     " sy-subrc = 0.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          ELSE. " i_independence_check-artstm = space.
*           Setze Hilfsvariable zum Überspringen der weiteren
*           Positionszeilen dieses IDOC-Typs.
            H_SKIP = 'X'.

*           Weiter zur nächsten Positionszeile.
            CONTINUE.
          ENDIF. " i_independence_check-artstm <> space.

*       Falls es sich um EAN-Referenzen IDOC's handelt
        WHEN C_IDOCTYPE_EAN.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          IF I_INDEPENDENCE_CHECK-EAN <> SPACE.
*           Prüfe, ob es bereits eine entsprechende Kopiermutter gibt.
            LOOP AT PXT_INDEPENDENCE_CHECK
                 WHERE FILIA <  PI_FILIA_GROUP-FILIA
                 AND   EAN   <> SPACE
                 AND   OK    <> SPACE.
              EXIT.
            ENDLOOP.                   " at pxt_independence_check

*           Wenn es bereits eine entsprechende Kopiermutter gibt,
*           dann ist keine weitere Analyse nötig.
            IF SY-SUBRC = 0.
*             Korrigieren der Filialunabhängigkeitstabelle
              PXT_INDEPENDENCE_CHECK = I_INDEPENDENCE_CHECK.
              CLEAR: PXT_INDEPENDENCE_CHECK-EAN.
              MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*             Zwischenspeichern dieser internen Tabellenzeile
*             aktualisieren.
              I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

*             Setze Hilfsvariable zum Überspringen der weiteren
*             Positionszeilen dieses IDOC-Typs.
              H_SKIP = 'X'.

*             Weiter zur nächsten Positionszeile.
              CONTINUE.
            ENDIF.                     " sy-subrc = 0.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          ELSE. " i_independence_check-ean = space.
*           Setze Hilfsvariable zum Überspringen der weiteren
*           Positionszeilen dieses IDOC-Typs.
            H_SKIP = 'X'.

*           Weiter zur nächsten Positionszeile.
            CONTINUE.
          ENDIF. " i_independence_check-ean <> space.

*       Falls es sich um Set-Zuordnungs IDOC's handelt
        WHEN C_IDOCTYPE_SET.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          IF I_INDEPENDENCE_CHECK-SETS <> SPACE.
*           Prüfe, ob es bereits eine entsprechende Kopiermutter gibt.
            LOOP AT PXT_INDEPENDENCE_CHECK
                 WHERE FILIA <  PI_FILIA_GROUP-FILIA
                 AND   SETS  <> SPACE
                 AND   OK    <> SPACE.
              EXIT.
            ENDLOOP.                   " at pxt_independence_check

*           Wenn es bereits eine entsprechende Kopiermutter gibt,
*           dann ist keine weitere Analyse nötig.
            IF SY-SUBRC = 0.
*             Korrigieren der Filialunabhängigkeitstabelle
              PXT_INDEPENDENCE_CHECK = I_INDEPENDENCE_CHECK.
              CLEAR: PXT_INDEPENDENCE_CHECK-SETS.
              MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*             Zwischenspeichern dieser internen Tabellenzeile
*             aktualisieren.
              I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

*             Setze Hilfsvariable zum Überspringen der weiteren
*             Positionszeilen dieses IDOC-Typs.
              H_SKIP = 'X'.

*             Weiter zur nächsten Positionszeile.
              CONTINUE.
            ENDIF.                     " sy-subrc = 0.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          ELSE. " i_independence_check-sets = space.
*           Setze Hilfsvariable zum Überspringen der weiteren
*           Positionszeilen dieses IDOC-Typs.
            H_SKIP = 'X'.

*           Weiter zur nächsten Positionszeile.
            CONTINUE.
          ENDIF. " i_independence_check-sets <> space.

*       Falls es sich um Nachzugsartikel IDOC's handelt
        WHEN C_IDOCTYPE_NART.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          IF I_INDEPENDENCE_CHECK-NART <> SPACE.
*           Prüfe, ob es bereits eine entsprechende Kopiermutter gibt.
            LOOP AT PXT_INDEPENDENCE_CHECK
                 WHERE FILIA <  PI_FILIA_GROUP-FILIA
                 AND   NART  <> SPACE
                 AND   OK    <> SPACE.
              EXIT.
            ENDLOOP.                   " at pxt_independence_check

*           Wenn es bereits eine entsprechende Kopiermutter gibt,
*           dann ist keine weitere Analyse nötig.
            IF SY-SUBRC = 0.
*             Korrigieren der Filialunabhängigkeitstabelle
              PXT_INDEPENDENCE_CHECK = I_INDEPENDENCE_CHECK.
              CLEAR: PXT_INDEPENDENCE_CHECK-NART.
              MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*             Zwischenspeichern dieser internen Tabellenzeile
*             aktualisieren.
              I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

*             Setze Hilfsvariable zum Überspringen der weiteren
*             Positionszeilen dieses IDOC-Typs.
              H_SKIP = 'X'.

*             Weiter zur nächsten Positionszeile.
              CONTINUE.
            ENDIF.                     " sy-subrc = 0.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          ELSE. " i_independence_check-nart = space.
*           Setze Hilfsvariable zum Überspringen der weiteren
*           Positionszeilen dieses IDOC-Typs.
            H_SKIP = 'X'.

*           Weiter zur nächsten Positionszeile.
            CONTINUE.
          ENDIF. " i_independence_check-nart <> space.

*       Falls es sich um Personendaten IDOC's handelt
        WHEN C_IDOCTYPE_PERS.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          IF I_INDEPENDENCE_CHECK-PERS <> SPACE.
*           Prüfe, ob es bereits eine entsprechende Kopiermutter gibt.
            LOOP AT PXT_INDEPENDENCE_CHECK
                 WHERE FILIA <  PI_FILIA_GROUP-FILIA
                 AND   VKORG =  PI_FILIA_GROUP-VKORG
                 AND   VTWEG =  PI_FILIA_GROUP-VTWEG
                 AND   KKBER =  H_KKBER
                 AND   PERS  <> SPACE
                 AND   OK    <> SPACE.
              EXIT.
            ENDLOOP.                   " at pxt_independence_check

*           Wenn es bereits eine entsprechende Kopiermutter gibt,
*           dann ist keine weitere Analyse nötig.
            IF SY-SUBRC = 0.
*             Korrigieren der Filialunabhängigkeitstabelle
              PXT_INDEPENDENCE_CHECK = I_INDEPENDENCE_CHECK.
              CLEAR: PXT_INDEPENDENCE_CHECK-PERS.
              MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.

*             Zwischenspeichern dieser internen Tabellenzeile
*             aktualisieren.
              I_INDEPENDENCE_CHECK = PXT_INDEPENDENCE_CHECK.

*             Setze Hilfsvariable zum Überspringen der weiteren
*             Positionszeilen dieses IDOC-Typs.
              H_SKIP = 'X'.

*             Weiter zur nächsten Positionszeile.
              CONTINUE.
            ENDIF.                     " sy-subrc = 0.
*         Falls es sich um eine mögliche Kopiermutter handelt.
          ELSE. " i_independence_check-pers = space.
*           Setze Hilfsvariable zum Überspringen der weiteren
*           Positionszeilen dieses IDOC-Typs.
            H_SKIP = 'X'.

*           Weiter zur nächsten Positionszeile.
            CONTINUE.
          ENDIF. " i_independence_check-pers <> space.

      ENDCASE.                         " doctyp.
    ENDIF.                             " key1 = key2.

    CASE T_WDLSP-DOCTYP.
*     Falls es sich um Warengruppen-IDOC's handelt.
      WHEN C_IDOCTYPE_WRGP.
*       Falls es sich um eine mögliche Kopiermutter handelt.
        IF I_INDEPENDENCE_CHECK-WRGP <> SPACE.
*         Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
          PERFORM WDLSP_INDEPENDENCE_CHECK
                        TABLES T_MASTER_IDOCS_TEMP
                               PXT_INDEPENDENCE_CHECK
                        USING  I_INDEPENDENCE_CHECK
                               WDLS   T_WDLSP
                               H_IDOC_TYPE_OK
                               H_SKIP  H_INDEX.
        ENDIF. " i_independence_check-wrgp <> SPACE.

*     Falls es sich um Artikelstamm-IDOC's handelt
      WHEN C_IDOCTYPE_ARTSTM.
*       Falls es sich um eine mögliche Kopiermutter handelt.
        IF I_INDEPENDENCE_CHECK-ARTSTM <> SPACE.
*         Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
          PERFORM WDLSP_INDEPENDENCE_CHECK
                        TABLES T_MASTER_IDOCS_TEMP
                               PXT_INDEPENDENCE_CHECK
                        USING  I_INDEPENDENCE_CHECK
                               WDLS   T_WDLSP
                               H_IDOC_TYPE_OK
                               H_SKIP  H_INDEX.
        ENDIF. " i_independence_check-artstm <> space.

*     Falls es sich um EAN-Referenzen IDOC's handelt
      WHEN C_IDOCTYPE_EAN.
*       Falls es sich um eine mögliche Kopiermutter handelt.
        IF I_INDEPENDENCE_CHECK-EAN <> SPACE.
*         Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
          PERFORM WDLSP_INDEPENDENCE_CHECK
                        TABLES T_MASTER_IDOCS_TEMP
                               PXT_INDEPENDENCE_CHECK
                        USING  I_INDEPENDENCE_CHECK
                               WDLS   T_WDLSP
                               H_IDOC_TYPE_OK
                               H_SKIP  H_INDEX.
        ENDIF. " i_independence_check-ean <> space.

*     Falls es sich um Set-Zuordnungs IDOC's handelt
      WHEN C_IDOCTYPE_SET.
*       Falls es sich um eine mögliche Kopiermutter handelt.
        IF I_INDEPENDENCE_CHECK-SETS <> SPACE.
*         Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
          PERFORM WDLSP_INDEPENDENCE_CHECK
                        TABLES T_MASTER_IDOCS_TEMP
                               PXT_INDEPENDENCE_CHECK
                        USING  I_INDEPENDENCE_CHECK
                               WDLS   T_WDLSP
                               H_IDOC_TYPE_OK
                               H_SKIP  H_INDEX.
        ENDIF. " i_independence_check-sets <> space.

*     Falls es sich um Nachzugsartikel IDOC's handelt
      WHEN C_IDOCTYPE_NART.
*       Falls es sich um eine mögliche Kopiermutter handelt.
        IF I_INDEPENDENCE_CHECK-NART <> SPACE.
*         Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
          PERFORM WDLSP_INDEPENDENCE_CHECK
                        TABLES T_MASTER_IDOCS_TEMP
                               PXT_INDEPENDENCE_CHECK
                        USING  I_INDEPENDENCE_CHECK
                               WDLS   T_WDLSP
                               H_IDOC_TYPE_OK
                               H_SKIP  H_INDEX.
        ENDIF. " i_independence_check-nart <> space.

*     Falls es sich um Personendaten IDOC's handelt
      WHEN C_IDOCTYPE_PERS.
*       Falls es sich um eine mögliche Kopiermutter handelt.
        IF I_INDEPENDENCE_CHECK-PERS <> SPACE.
*         Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
          PERFORM WDLSP_INDEPENDENCE_CHECK
                        TABLES T_MASTER_IDOCS_TEMP
                               PXT_INDEPENDENCE_CHECK
                        USING  I_INDEPENDENCE_CHECK
                               WDLS   T_WDLSP
                               H_IDOC_TYPE_OK
                               H_SKIP  H_INDEX.
        ENDIF. " i_independence_check-pers <> space.

    ENDCASE.                           " doctyp.
  ENDLOOP.                             " at t_wdlsp.

* Übernehme die letzten Einträge aus dem Zwischenspeicher, fall. nötig.
  IF SY-SUBRC = 0.
*   Falls alle IDOC's eines IDOC-Typs kopiert werden können.
    IF H_IDOC_TYPE_OK <> SPACE AND H_SKIP = SPACE.
*     Zwischenspeicher an IDOC-Puffer anhängen.
      LOOP AT T_MASTER_IDOCS_TEMP.
        APPEND T_MASTER_IDOCS_TEMP TO PXT_MASTER_IDOCS.
      ENDLOOP.                     " at t_master_idocs_temp.

*     Korrigieren der Filialunabhängigkeitstabelle
      PXT_INDEPENDENCE_CHECK    = I_INDEPENDENCE_CHECK.
      PXT_INDEPENDENCE_CHECK-OK = 'X'.
      MODIFY PXT_INDEPENDENCE_CHECK INDEX H_INDEX.
    ENDIF. " h_idoc_type_ok <> space and h_skip = space.
  ENDIF. " sy-subrc = 0.

ENDFORM.                               " status_independence_check


*eject
************************************************************************
FORM WDLSP_INDEPENDENCE_CHECK
     TABLES PXT_MASTER_IDOCS_TEMP  STRUCTURE GT_MASTER_IDOCS
            PXT_INDEPENDENCE_CHECK STRUCTURE GT_INDEPENDENCE_CHECK
     USING  PX_INDEPENDENCE_CHECK  STRUCTURE GT_INDEPENDENCE_CHECK
            PI_WDLS                STRUCTURE WDLS
            PI_WDLSP               STRUCTURE WDLSP
            PX_IDOC_TYPE_OK        LIKE WPSTRUC-MODUS
            PX_SKIP                LIKE WPSTRUC-MODUS
            PI_INDEX               LIKE SY-TABIX.
************************************************************************
* FUNKTION:
* Ausgelagertes Coding der FORM-Routine STATUS-INDEPENDENCE_CHECK.
* Prüfe Statuskopf- und -Positionszeile auf Aufbereitungsfehler.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_MASTER_IDOCS_TEMP : Tabelle der Kopierfähigen IDOC's
*
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PX_INDEPENDENCE_CHECK : Feldleiste der filialunabhängigen
*                         Objekte dieser Filiale dieser Filialgruppe.
* PI_WDLS               : Kopfzeile der Statustabelle.
*
* PI_WDLSP              : Positionszeile der Statustabelle.
*
* PX_IDOC_TYPE_OK       : Hilfsvariable der zugehörigen FORM-Routine
*                         STATUS-INDEPENDENCE_CHECK.
* PX_SKIP               : Hilfsvariable der zugehörigen FORM-Routine
*                         STATUS-INDEPENDENCE_CHECK.
* PI_INDEX              : Zeilennummer der filialunabhängigkeits-
*                         tabelle dieser Filiale.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Falls das IDOC von der EDI-Schnittstelle erzeugt
* werden konnte.
  IF PI_WDLSP-VSEST = C_DATENUEBERGABE_OK  OR
     PI_WDLSP-VSEST = SPACE.
*   Falls keine Nachrichten im Application Log erzeugt
*   wurden, dann kopieren möglich.
    IF PI_WDLSP-ANLOZ = 0.
*     Erzeuge entsprechenden Eintrag im Zwischenspeicher.
      MOVE-CORRESPONDING PX_INDEPENDENCE_CHECK TO
                         PXT_MASTER_IDOCS_TEMP.
      MOVE-CORRESPONDING PI_WDLSP TO PXT_MASTER_IDOCS_TEMP.
      APPEND PXT_MASTER_IDOCS_TEMP.

*   Falls Nachrichten im Application Log erzeugt
*   wurden.
    ELSE.                      " pi_wdlsp-anloz > 0.
*     Falls die Nachrichten im Application Log nur aus
*     Hinweisen bestehen, dann kopieren möglich.
      IF PI_WDLS-GESST = C_STATUS_BENUTZERHINWEIS.
*       Erzeuge entsprechenden Eintrag im Zwischenspeicher.
        MOVE-CORRESPONDING PX_INDEPENDENCE_CHECK TO
                           PXT_MASTER_IDOCS_TEMP.
        MOVE-CORRESPONDING PI_WDLSP TO PXT_MASTER_IDOCS_TEMP.
        APPEND PXT_MASTER_IDOCS_TEMP.

*     Falls die Nachrichten im Application Log auch
*     Fehlernachrichten sein können.
      ELSE. " pi_wdls-gesst <> c_status_benutzerhinweis.
*       Merken das wenigstens ein IDOC Fehlerhaft war.
        CLEAR: PX_IDOC_TYPE_OK.

*       Setze Hilfsvariable zum Überspringen der weiteren
*       Positionszeilen dieses IDOC-Typs.
        PX_SKIP = 'X'.

*       Korrigieren des aktuellen Satzes der Filialunabhängigkeits-
*       tabelle.
        CASE PI_WDLSP-DOCTYP.
*         Falls es sich um Warengruppen-IDOC's handelt.
          WHEN C_IDOCTYPE_WRGP.
            CLEAR: PX_INDEPENDENCE_CHECK-WRGP.
*         Falls es sich um Artikelstamm-IDOC's handelt
          WHEN C_IDOCTYPE_ARTSTM.
              CLEAR: PX_INDEPENDENCE_CHECK-ARTSTM.
*         Falls es sich um EAN-Referenzen IDOC's handelt
          WHEN C_IDOCTYPE_EAN.
              CLEAR: PX_INDEPENDENCE_CHECK-EAN.
*         Falls es sich um Set-Zuordnungs IDOC's handelt
          WHEN C_IDOCTYPE_SET.
              CLEAR: PX_INDEPENDENCE_CHECK-SETS.
*         Falls es sich um Nachzugsartikel IDOC's handelt
          WHEN C_IDOCTYPE_NART.
              CLEAR: PX_INDEPENDENCE_CHECK-NART.
*         Falls es sich um Personendaten IDOC's handelt
          WHEN C_IDOCTYPE_PERS.
              CLEAR: PX_INDEPENDENCE_CHECK-PERS.
        ENDCASE. " pi_wdlsp-doctyp.

*       Korrigieren der Filialunabhängigkeitstabelle.
        PXT_INDEPENDENCE_CHECK = PX_INDEPENDENCE_CHECK.
        MODIFY PXT_INDEPENDENCE_CHECK INDEX PI_INDEX.
      ENDIF. " pi_wdls-gesst = c_status_benutzerhinweis.
    ENDIF.                     " pi_wdlsp-anloz = 0.

* Falls das IDOC von der EDI-Schnittstelle nicht erzeugt
* werden konnte.
  ELSE. " pi_wdlsp-vsest <> c_datenuebergabe_ok and ... <> SPACE
*   Merken das wenigstens ein IDOC Fehlerhaft war.
    CLEAR: PX_IDOC_TYPE_OK.

*   Setze Hilfsvariable zum Überspringen der weiteren
*   Positionszeilen dieses IDOC-Typs.
    PX_SKIP = 'X'.

*   Korrigieren des aktuellen Satzes der Filialunabhängigkeits-
*   tabelle.
    CASE PI_WDLSP-DOCTYP.
*     Falls es sich um Warengruppen-IDOC's handelt.
      WHEN C_IDOCTYPE_WRGP.
        CLEAR: PX_INDEPENDENCE_CHECK-WRGP.
*     Falls es sich um Artikelstamm-IDOC's handelt
      WHEN C_IDOCTYPE_ARTSTM.
          CLEAR: PX_INDEPENDENCE_CHECK-ARTSTM.
*     Falls es sich um EAN-Referenzen IDOC's handelt
      WHEN C_IDOCTYPE_EAN.
          CLEAR: PX_INDEPENDENCE_CHECK-EAN.
*     Falls es sich um Set-Zuordnungs IDOC's handelt
      WHEN C_IDOCTYPE_SET.
          CLEAR: PX_INDEPENDENCE_CHECK-SETS.
*     Falls es sich um Nachzugsartikel IDOC's handelt
      WHEN C_IDOCTYPE_NART.
          CLEAR: PX_INDEPENDENCE_CHECK-NART.
*     Falls es sich um Personendaten IDOC's handelt
      WHEN C_IDOCTYPE_PERS.
          CLEAR: PX_INDEPENDENCE_CHECK-PERS.
    ENDCASE. " pi_wdlsp-doctyp.

*   Korrigieren der Filialunabhängigkeitstabelle
    PXT_INDEPENDENCE_CHECK = PX_INDEPENDENCE_CHECK.
    MODIFY PXT_INDEPENDENCE_CHECK INDEX PI_INDEX.

  ENDIF. " pi_wdlsp-vsest = c_datenuebergabe_ok or ...


ENDFORM. " wdlsp_independence_check


*eject
************************************************************************
FORM IDOC_COPY
     TABLES PIT_MASTER_IDOCS       STRUCTURE GT_MASTER_IDOCS
     USING  PI_INDEPENDENCE_CHECK  STRUCTURE GT_INDEPENDENCE_CHECK
            PI_IDOCTYPE            LIKE EDIMSG-IDOCTYP
            PI_MESTYPE             LIKE EDIMSG-MESTYP
            PI_FILIA_GROUP         STRUCTURE GT_FILIA_GROUP
            PI_DLDNR               LIKE WDLS-DLDNR.
************************************************************************
* FUNKTION:
* Kopieren von IDOC's .
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_MASTER_IDOCS      : Tabelle der Kopierfähigen IDOC's
*
* PI_INDEPENDENCE_CHECK : Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PI_IDOCTYPE           : Name der Original Zwischenstruktur.
*
* PI_MESTYPE            : Logischer Nachrichtentyp.
*
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
*
* PI_DLDNR              : Downloadnummer
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: FEHLERCODE        LIKE SY-SUBRC.

* Feldleiste für Filialkonstanten.
  DATA: BEGIN OF I_FILIA_CONST.
          INCLUDE STRUCTURE WPFILCONST.
  DATA: END OF I_FILIA_CONST.

  data: i_short_idoc_data type pos_short_edidd.

  data: t_short_idoc_data type short_edidd.

  DATA: BEGIN OF T_IDOC_DATA OCCURS 2000.
          INCLUDE STRUCTURE EDIDD.
  DATA: END OF T_IDOC_DATA.


* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING PI_FILIA_GROUP TO I_FILIA_CONST.


* Rücksetzen Fehler-Zähler.
  CLEAR: G_ERR_COUNTER.

* Schleife über alle zu kopierenden IDOC's.
  LOOP AT PIT_MASTER_IDOCS.
*   Falls die Filiale und der IDOC-Typ nicht übereinstimmt, dann
*   nächster Satz.
    IF PIT_MASTER_IDOCS-FILIA  <> PI_INDEPENDENCE_CHECK-FILIA OR
       PIT_MASTER_IDOCS-DOCTYP <> PI_IDOCTYPE.
      CONTINUE.
    ENDIF. " pit_master_idocs-filia  <> pi_independence_check-filia or

*   Zusatzbedingungen für einige Objekte.
    CASE PI_IDOCTYPE.
*     Falls es sich um Artikelstamm-IDOC's handelt
      WHEN C_IDOCTYPE_ARTSTM.
*       Falls die Sprache nicht übereinstimmt, dann nächster Satz
        IF PIT_MASTER_IDOCS-SPRAS <> PI_INDEPENDENCE_CHECK-SPRAS.
          CONTINUE.
        ENDIF. " pit_master_idocs-filia <> pi_independence_check-spras.

*     Falls es sich um Personendaten-IDOC's handelt
      WHEN C_IDOCTYPE_PERS.
*       Falls die Vertriebslinie und der Kreditkontrollbereich
*       nicht übereinstimmt, dann nächster Satz
        IF PIT_MASTER_IDOCS-VKORG <> PI_INDEPENDENCE_CHECK-VKORG OR
           PIT_MASTER_IDOCS-VTWEG <> PI_INDEPENDENCE_CHECK-VTWEG OR
           PIT_MASTER_IDOCS-KKBER <> PI_INDEPENDENCE_CHECK-KKBER.
          CONTINUE.
        ENDIF. " pit_master_idocs-vkorg <> pit_inde. ...

    ENDCASE. " pi_idoctype

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = PI_DLDNR.
    GI_STATUS_POS-DOCTYP = PI_IDOCTYPE.

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING ' ' GI_STATUS_POS  G_DLDLFDNR
                                       G_RETURNCODE.

*   Falls ein IDOC abgespeichert wurde.
    IF NOT ( PIT_MASTER_IDOCS-DOCNUM IS INITIAL ).
*     Besorge die zu kopierenden IDOC-Daten von der Datenbank.
*     IDOC zum lesen öffnen.
      CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_READ'
           EXPORTING
                DOCUMENT_NUMBER         = PIT_MASTER_IDOCS-DOCNUM
           EXCEPTIONS
                DOCUMENT_FOREIGN_LOCK   = 01
                DOCUMENT_NOT_EXIST      = 02
                DOCUMENT_NUMBER_INVALID = 03.

*     IDOC von DB einlesen.
      CALL FUNCTION 'EDI_SEGMENTS_GET_ALL'
           EXPORTING
                DOCUMENT_NUMBER         = PIT_MASTER_IDOCS-DOCNUM
           TABLES
                IDOC_CONTAINERS         = T_IDOC_DATA
           EXCEPTIONS
                DOCUMENT_NUMBER_INVALID = 01
                END_OF_DOCUMENT         = 02.

*      IDOC nach lesen schließen.
       CALL FUNCTION 'EDI_DOCUMENT_CLOSE_READ'
            EXPORTING
                 DOCUMENT_NUMBER   = PIT_MASTER_IDOCS-DOCNUM
            EXCEPTIONS
                 DOCUMENT_NOT_OPEN = 01
                 PARAMETER_ERROR   = 02.

*     Setze globalen Merker, daß IDOC kopiert werden soll.
*     Dieser Merker wird in der Routine IDOC_CREATE dazu verwendet,
*     um im Fehlerfall die richtige RAISE-Anweisung abzusetzen.
      G_IDOC_COPY = 'X'.

*     Modifizieren der ID-Segmente auf den neuen Filialnamen.
      PERFORM IDOC_ID_SEGMENT_CHANGE
                   TABLES T_IDOC_DATA
                   USING  PI_FILIA_GROUP.

*     Übernehme IDOC-Daten aus kompatibilitätsgründen
*     in komprimierte Struktur.
      loop at t_idoc_data.
        i_short_idoc_data-segnam = t_idoc_data-segnam.
        i_short_idoc_data-sdata  = t_idoc_data-sdata.
        append i_short_idoc_data to t_short_idoc_data.
      endloop. " at t_idoc_data.

*     Kopiere IDOC und aktualisiere Statuskopf- und Positionszeilen.
      PERFORM IDOC_CREATE using  t_short_idoc_data
                                 PI_MESTYPE
                                 PI_IDOCTYPE
                                 PIT_MASTER_IDOCS-ANSEG
                                 G_ERR_COUNTER
                                 PIT_MASTER_IDOCS-STKEY
                                 PIT_MASTER_IDOCS-LTKEY
                                 PI_DLDNR
                                 G_DLDLFDNR
                                 PI_FILIA_GROUP-FILIA
                                 I_FILIA_CONST.

*     Rücksetze Kopiermerker.
      CLEAR: G_IDOC_COPY.
    ENDIF. " not ( pit_master_idocs-docnum is initial ).

  ENDLOOP. " at pit_master_idocs

* Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
* auf OK.
  IF G_STATUS = 0.
*   Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
    CLEAR: GI_STATUS_HEADER.
    GI_STATUS_HEADER-DLDNR = PI_DLDNR.
    GI_STATUS_HEADER-GESST = C_STATUS_OK.

*   Schreibe Status-Kopfzeile.
    PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER  PI_DLDNR
                                          G_RETURNCODE.
  ENDIF.                             " G_STATUS = 0.


ENDFORM. " idoc_copy


*eject
************************************************************************
FORM FILIA_WLK2_MATNR_GET
     TABLES PET_WLK2_MATNR    STRUCTURE GT_FILIA_WLK2_BUF
     USING  PI_FILIA_GROUP    STRUCTURE GT_FILIA_GROUP.
************************************************************************
* FUNKTION:
* Besorge alle filialabhängigen Bewirtschaftungen
* im Betrachtungszeitraum PI_ERSTDAT und PI_DATP4.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_WLK2_MATNR        : Tabelle der filialabhängigen Artikel
*                         aus WLK2.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle für WLK2-Sätze.
  DATA: BEGIN OF T_WLK2 OCCURS 1000.
          INCLUDE STRUCTURE WLK2.
  DATA: END OF T_WLK2.

  DATA: BEGIN OF T_WKWLK2 OCCURS 1000.
         INCLUDE STRUCTURE WKWLK2.
  DATA: END OF T_WKWLK2.

* Rücksetze interne Tabellen.
  REFRESH: PET_WLK2_MATNR.
  CLEAR:   PET_WLK2_MATNR.

* Falls sich die WLK2-Daten bereits im Puffer befinden.
  IF PI_FILIA_GROUP-VKORG = G_INDEPENDENCE_VKORG_BUF AND
     PI_FILIA_GROUP-VTWEG = G_INDEPENDENCE_VTWEG_BUF AND
     PI_FILIA_GROUP-FILIA = G_INDEPENDENCE_FILIA_BUF.

*   Übernahme der Daten aus dem Puffer in Ausgabetabelle.
    PET_WLK2_MATNR[] = GT_FILIA_WLK2_BUF[].

* Falls sich die WLK2-Daten noch nicht im Puffer befinden.
  ELSE. " pi_filia_group-vkorg <> g_independence_vkorg_buf or ...
* B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_true
     AND gs_twpa-marc_chk IS NOT INITIAL.
    CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
      EXPORTING
        ip_access_type         = '1'
        ip_vkorg               = pi_filia_group-vkorg
        ip_vtweg               = pi_filia_group-vtweg
        ip_filia               = pi_filia_group-filia
        is_filia_const         = gi_filia_const
      TABLES
        pet_wlk2               = t_wkwlk2.
      DELETE ADJACENT DUPLICATES FROM T_WKWLK2 COMPARING MATNR.
      LOOP AT T_WKWLK2.
        APPEND T_WKWLK2-MATNR TO PET_WLK2_MATNR.
      ENDLOOP. " at t_wlk2.
  ELSE.
*   Besorge alle filialabhängigen Bewirtschaftungszeiträume
*   dieser Filiale.
    CALL FUNCTION 'WLK2_FILIA_INDEPENDENCE_CHECK'
         EXPORTING
              PI_FILIA       = PI_FILIA_GROUP-FILIA
              PI_VKORG       = PI_FILIA_GROUP-VKORG
              PI_VTWEG       = PI_FILIA_GROUP-VTWEG
         TABLES
              PET_WLK2       = T_WLK2
         EXCEPTIONS
              WRONG_FILIA    = 01
              WRONG_VTLINIE  = 02
              NO_FILIA_ENTRY = 03.


*   Sortieren der Daten.
    SORT T_WLK2 BY MATNR.

*   Löschen aller doppelten Materialnummern aus PET_WLK2.
    DELETE ADJACENT DUPLICATES FROM T_WLK2 COMPARING MATNR.

*   Übernahme der Materialnummern in Ausgabetabelle.
    LOOP AT T_WLK2.
      APPEND T_WLK2-MATNR TO PET_WLK2_MATNR.
    ENDLOOP. " at t_wlk2.
   ENDIF.
*   Übernahme der Daten in den internen Puffer.
    GT_FILIA_WLK2_BUF[] = PET_WLK2_MATNR[].

    G_INDEPENDENCE_VKORG_BUF = PI_FILIA_GROUP-VKORG.
    G_INDEPENDENCE_VTWEG_BUF = PI_FILIA_GROUP-VTWEG.
    G_INDEPENDENCE_FILIA_BUF = PI_FILIA_GROUP-FILIA.
  ENDIF. " pi_filia_group-vkorg = g_independence_vkorg_buf and ...


ENDFORM.                               " filia_wlk2_matnr_get


*eject
************************************************************************
FORM FILIA_WLK2_CHECK
     TABLES PIT_WLK2_MATNR         STRUCTURE GT_FILIA_WLK2_BUF
            PIT_MATNR              STRUCTURE GT_OT3_ARTSTM
     USING  PI_FILIA_GROUP         STRUCTURE GT_FILIA_GROUP
            PE_RETURNCODE          LIKE SY-SUBRC.
************************************************************************
* FUNKTION:
* Prüfe alle in PIT_ARTSTM vorkommenden Artikel dieser Filiale,
* ob sie filialabhängige WLK2-Intervalle innerhalb des
* Betrachtungszeitraums PI_ERSTDAT bis PI_DATP4 besitzen.
* Das Ergebnis wird in PE_RETURNCODE vermerkt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WLK2_MATNR        : Tabelle der filialabhängigen Artikel aus
*                         WLK2.
* PIT_MATNR             : Tabelle der zu überprüfenden Artikel.
*
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
*
* PE_RETURNCODE         : = 1, wenn filialabhängige Daten gefunden
*                         wurden, sonst 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: KEY1          LIKE MARA-MATNR,
        KEY2          LIKE MARA-MATNR,
        WLK2_LINES    TYPE I,
        MATNR_LINES   TYPE I.

* Zwischenspeicher für Artikelnummern.
  DATA: BEGIN OF T_MATNR OCCURS 500,
          MATNR LIKE MARA-MATNR.
  DATA: END OF T_MATNR.

* Initialisiere Returncode.
  CLEAR: PE_RETURNCODE.

* Übernehme alle unterschiedlichen Artikelnummern aus PIT_ARTSTM in
* eine separate interne Tabelle.
  CLEAR: KEY1, KEY2.
  LOOP AT PIT_MATNR.
    KEY2 = PIT_MATNR-ARTNR.
    IF KEY1 <> KEY2.
      KEY1 = KEY2.
      APPEND PIT_MATNR-ARTNR TO T_MATNR.
    ENDIF.                             " key1 <> key2.
  ENDLOOP.                             " at pit_matnr

* Prüfe, welche Tabelle mehr Einträge hat, damit eine Entscheidung
* bzgl. des Suchalgorithmus vorgenommen werden kann.
  DESCRIBE TABLE PIT_WLK2_MATNR LINES WLK2_LINES.
  DESCRIBE TABLE T_MATNR        LINES MATNR_LINES.

* Falls PIT_WLK2 die wenigsten Zeilen hat.
  IF WLK2_LINES <= MATNR_LINES.
*   Prüfe, ob Artikelnummern aus T_MATNR in PIT_WLK2_MATNR vorkommen.
    LOOP AT PIT_WLK2_MATNR.
      READ TABLE T_MATNR WITH KEY
           MATNR = PIT_WLK2_MATNR-MATNR
           BINARY SEARCH.

      IF SY-SUBRC = 0.
*       Sorge dafür, daß diese Filiale keine weitere
*       Kopiermutter für den IDOC-Typ Artikelstamm wird und setze
*       den Returncode entsprechend.
        PE_RETURNCODE = 1.

*       Weitere Analyse verlassen.
        EXIT.
      ENDIF.                           " sy-subrc = 0.
    ENDLOOP.                           " t_periods_buf.

* Falls T_MATNR die wenigsten Zeilen hat.
  ELSE.                                " wlk2_lines > matnr_lines.
*   Prüfe, ob Artikelnummern aus PIT_WLK2_MATNR in T_MATNR vorkommen.
    LOOP AT T_MATNR.
      READ TABLE PIT_WLK2_MATNR WITH KEY
           MATNR = T_MATNR-MATNR
           BINARY SEARCH.

      IF SY-SUBRC = 0.
*       Sorge dafür, daß diese Filiale keine weitere
*       Kopiermutter für den IDOC-Typ Artikelstamm wird und setze
*       den Returncode entsprechend.
        PE_RETURNCODE = 1.

*       Weitere Analyse verlassen.
        EXIT.
      ENDIF.                           " sy-subrc = 0.
    ENDLOOP.                           " t_matnr.
  ENDIF.                               " wlk2_lines <= matnr_lines


ENDFORM.                               " filia_wlk2_check


*eject
************************************************************************
FORM IDOC_ID_SEGMENT_CHANGE
     TABLES PXT_IDOC_DATA    STRUCTURE GT_IDOC_DATA_temp
     USING  PI_FILIA_GROUP   STRUCTURE GT_FILIA_GROUP.
************************************************************************
* FUNKTION:
* Ändert die Filialnummer in den ID-Segmenten auf die aktuelle
* Filialnummer um.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_IDOC_DATA         : Daten des zu kopierendes IDOC's.
*
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Ersezte die Filialnummer durch die aktuelle
* Filialnummer.
  LOOP AT PXT_IDOC_DATA
    WHERE PSGNUM = 0.
    PXT_IDOC_DATA-SDATA(10) = PI_FILIA_GROUP-KUNNR.
    MODIFY PXT_IDOC_DATA.
  ENDLOOP. " at pxt_idoc_data


ENDFORM. " idoc_id_segment_change
