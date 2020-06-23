*-----------------------------------------------------------------------
*-- Customer-Exits in CLFM
*-- 001: Bei Anlegen Klassifizierung mit Vorlage
*-- 002: Vor dem Sichern (immer bei ON COMMIT)
*-----------------------------------------------------------------------
*-- Beschreibung/Dokumentation
*-- Dynpros allgemein:
*--  1100,500: Objekt zu KLassen
*--  1110,505/506: Klasse zu KLassen
*--  1110,510/511/512: Objekte zur Klasse
*--  Die Dynpros 510/511/512 wg. Subscreens nicht anders möglich
*--  In den Screens 501/506 und 511 wird die klastab verwendet (bereits
*--  vorhandene Objekte).
*--  In den Screens 500,505,510 und 512 wird auf
*--  die KLASTAB zugegriffen (Aufnahme neuer Objekte).
*------------------------------------------------------------------
*--
*-- Achtung KLASTAB-Handling: Um die TableControl-Steuerung zu
*-- realisieren, wird die KLASTAB mit Leerueilen (im PBO) gefüllt.
*-- Da es aber eine Reihe von Abfragen auf die KLASTAB gibt, ohne daß
*-- auch der Inhalt einer Zeile geprüft wird, werden im OK_CODE-Modul
*-- alle Leerzeilen aus der Klastab entfernt.
*--
*#####################################################################

FUNCTION-POOL ZCLFM MESSAGE-ID CL.

*-- Include wg. Tabellennamen Effectivity
include mclefto1 .

* COMMON PART für INCLUDE DYNPROS
include lclfmto1.

* Include for classification 99
include lclfmto4.

*********************************************************************

* E/A Tabellen
tables:
    rmclf,
    rmcbc,
    rmclindx,
* ATAB Tabellen
    tcla,
    tclt,
    tcltt,
    tclao,
    tclc,
    tclo,
    tcls,
    tclst,
    tfdir,
*-- OK-Code-Steuertabelle
    tclokcode,
*-- Tabelle wg. Entkopplung Incudescreens-Klassensystem
    tclfm,
* Datenbanktabellen
    klah,
    kssk,
    ksml,
    ausp,
    cabn,
    inob,
    indx.
type-pools cc01.

*-- Definition der div. Table Controls TC_...
controls tc_obj_class type tableview using screen 500 .

* Interne Tabellen fuer Mengenselect
ranges:
  ratinn     for ausp-atinn,
  merkmtab   for ausp-atinn,
  allmerktab for ksml-imerk,
  rklart     for tcla-klart,
  xklart     for tcla-klart.

*------------------------------------------------------------------
* Hilfsfelder
data:
  aedi_aennr       like rmclf-aennr1,
  aedi_datuv       like rmclf-datuv1,
*-- AENDERFLAG: Sitzt, falls bei dem aktuellen Aufruf irgendetwas
*-- geändert wurde: Wird bei jedem Aufruf neu gesetzt!!!      s
  aenderflag,
  all_multi_obj    like tcla-multobj,
*-- ALLKSSKANFANG beinhalten den Pointer auf die Tabellenzeile, ab der
*-- die neuen Einträge stehen
  allksskanfang    type i,
  altzeile         like syst-tabix,
  antwort,
*-- ANZLOOP enthält die Anzahl der Einträge auf dem Screen (SY-LOOPC)
  anzloop          like syst-tabix,

*-- ANZZEILEN beinhaltet die Anzahl der Zeilen in einer Tabelle
*-- KLASTAB oder klastab
  anzzeilen        like syst-tabix,
  back_ok          like syst-ucomm,
  by_dialog        type c,
*-- 4.0C:
*-- Flag CATTAKTIV ist nach neuer Logik nicht mehr abh. von SY-BINPT!
*-- Daher alle Abfragen ersetzt durch SY-BINPT
*+cattaktiv,
  clap_init,
*-- CLASSIF_STATUS gibt die Art der Klassifizierung an
*-- (Anzeigen, Ändern, Hinzufügen).
*-- 4.6: Wird erst gesetzt, wenn CLFM_OBJECT(S)_CLASS. aufgerufen wird.
*--      vorher ist classif_status initial und es gilt cl_status .
  classif_status,
*
*-- CN_MARK enthält die Anzahl vorhandner Markierungen
  cn_mark          type i,
*-- D5XX_DYNNR ist die Bildbausteinnummer für CL20 +
  d5xx_dynnr       like syst-dynnr,
*-- Nummer des Include-Screens auf Dynpro 511
*  d511_dynnr       like syst-dynnr,
  del_counter      type i,             "logisch geloescht
*-- Aktuelle Workareas aus KLASTAB und ALLKSSK
*-- FNAME beinhaltet den Feldnamen incl. Tabellennamen (30+30 maximal)
  fname(61),

*-- G_FLAG / G_SUBRC:  globale Flags zur allg. Verwendung
  g_flag           type sy-batch,
  g_flag2          type sy-batch,
  g_subrc          like sy-subrc,

  g_allkssk_akt_index    like sy-tabix,
  g_allkssk_found  like rmclf-kreuz,

*-- Flag, das steuert, ob die im CLFM gepufferten Daten auch mit den
*-- CLSE-Daten abgemischt werden soll
  g_buffer_clse_active  like rmclf-kreuz,

*-- Sichert den im table control neu eingegebenen Status
*   vom PAI des subscreens bis zur Prozessierung
*   im Hauptscreen.
  g_clfy_status_new     like kssk-statu,

*-- Flag, das angibt, ob der Löschbaustein einmal gerufen wurde
  g_delete_classif_flg,
*-- G_DISPLAY_VALUES wird auf X gesetzt, wenn mit Änderungsnummer
*-- eine Bewertung geändert werden müßte, jedoch auf dem Einstiegsbild
*-- keine eingegeben worden war. Nach ENTER_VALUES initialisiert
  g_display_values,
*-- G_EXITS_ACTIVE ist ein globales Flag, um CUSTOMER-EXITS global
*-- auszuschalten (z.B. für die Fehlersuche)
  g_exits_active(1)              value 'X',
*-- Global vereinbartes, lokal genutztes Flag, das einen Gruppenwechsel
*-- unterstützt
  g_first_rec,
*+first,
  g_first_chg_scr,                     "erster Aufruf Änderungs.Popup
*-- Erster Aufruf Object_classification
  g_first_call_u01,
*-- g_FORM_API wird in DDB_SAVE_CLASSIFICATION gesetzt und steuert
*-- den Aufruf von INSERT_CLASSIFICATION (Kennzeichen TRANSCL)
*-- Erweiterung ab 46a: Parameter wird gesetzt, wenn ein CLAP-Baustein
*-- gerufen wird. Zurückgesetzt, wenn ein CLFM-Baustein
*-- (~object_classification, ~class_cl..., ~objects_cl...) gerufen
*-- wird.
  g_from_api,
*-- G_APPL: Sondersteuerung : SPACE (n.relevant), "W" (WWS), "C" (CU*)
  g_appl(1),
*-- G_assgnmnt_screen: Steuert, ob das Zuordnungsbild angezeigt werden
*-- soll, wenn es keine Merkmale gibt
  g_assgnmnt_screen like rmclf-kreuz,
*-- G_AUTH_OBJ_CHK: Änderungsberechtigung in OBJECT_CHECK* abfragen
  g_auth_obj_chk like rmclf-kreuz,
*-- Globale Steuerungskennzeichen:
*-- Neben den bisher bereits vorhandenen Globalen Variablen TCD_STAT
*-- und G_ENTRIES_NEW werden hier weitere zu 4.0 eingeführt, die die
*-- Abfragen auf SY-TCODE und SY-DYNNR ablösen sollen
*-- G_CL_TA: Wird gesetzt, wenn der Aufruf aus einer CL*-TA kommt
*--          Blank sonst
  g_cl_ta(1),
*-- G_46_TA: Wird gesetzt. wenn REL. >= 4.6, Unterscheidung für
*   alte (Batch-Input) und neue CL-Transaktionen
  g_46_ta(1),
*-- G_CLINT: Sicherungsvariable um CLINT zwischenzuspeichern
  g_clint  like klah-clint,
*-- G_CONSISTENCY_CHK aktiviert innerhalb des STATUS_CHECK die Prüfung
*-- auch für den Fall, daß KLAH-PRAUS nicht entsprechend sitzt
  g_consistency_chk like rmclf-kreuz,
*-- no message in STATUS_CHECK
  gv_no_message     type rmclf-kreuz,                          "1436346
  g_cuatitle        like syst-title,
*-- Kennzeichen, dass keine Defaultwerte im API-Fall in die Bewertung
*-- eingebracht werden (wichtig z.B. bei Split/Merge CL6H)
  g_defaults_api like rmclf-kreuz,

*-- g_effectivity_used wird gesetzt, falls die Änderungsnummer
*-- in RMCLF-AENNR nach neuer Effectivity-Logik definiert ist
  g_effectivity_used like rmclf-kreuz,
  g_effectivity_date like tcla-effe_datum ,
*-- G_ENTRIES_NEW ist ein Flag, das anzeigt, ob es sich um einen Screen
*-- mit bereits vorhandenen Objekten handelt (= " ") oder einen Screen
*-- mit neuen Objekten (= X) (VORHER: DYNPRONR)
  g_entries_new,
*-- G_FBS_EXIT enthält den NAmen eines Funktionsbausteins, der durch
*-- eine andere Applikation gesetzt werden kann, um zusätzlich zum
*-- Standardablauf einen FBS zu prozessieren "APPLICATION-EXIT"
  g_fbs_exit      like  rs38l-name,
  g_inob_init     like  inob-cuobj,
  g_icon_sizeadj  like  rmclf-icon,
  g_language         like syst-langu,

*-- G_L_SUBRC: "lokales" Feld, global definiert
  g_l_subrc like sy-subrc,

  g_klastab_akt_index    like sy-tabix,
*-- g_klastab_val_idx: Indiziert in klastab die Zuordnung,
*   deren Bewertung im Bewertungssubscreen angezeigt werden.
  g_klastab_val_idx      like sy-tabix,

*-----------------------------------------------------------------------
*-- G_AKT_OBJECT = Einstiegs-Objekt oder - Klasse, je nach Transaktion
  g_akt_object    like kssk-objek,
*-- G_MAIN_OBJECT = Einstiegs-Objekt oder - Klasse, je nach Transaktion
  g_main_object   like kssk-objek,
*-----------------------------------------------------------------------

*-- G_NO_CHARS: no characteristics used in class type (CL24N)
  g_no_chars       type xfeld,
*-- G_NO_LOCK_KLART: Wenn dieses Flag gesetzt ist, wird die Klassenart
*-- nicht mehr gesperrt
  g_no_lock_klart  like rmclf-kreuz,
*-- G_NO_UPD_TASK  : Flag, das gesetzt wird, falls die Verbuchung nicht
*-- in Update-Task erfolgen soll (z.B. bei CACL wichtig)
*-- Ob Änderung bereits erfolgte, wird in G_NO_UPD_TASK_CHG festgehalten
  g_no_upd_task,
  g_no_upd_task_chg,
*-- G_NO_VALUATION : Flag, das gesetzt wird, falls es zu einer Klasse
*-- keine Merkmale zu bewerten gibt (in KLASSIFIZIEREN)
  g_no_valuation,
*-- G_BUILD_ALLAUSP: Form BUILD_ALLAUSP may  be called
  g_build_allausp like rmclf-kreuz,
*-- G_obj_not_dark wird gesetzt, falls die mitegegebene KLasse
*-- nicht in der klastab gefunden werden kann
*-- Wichtig, wenn direkt auf das Bewertungsbild der mitgegebenen Klasse
*-- gesprungen werden soll (OBJ dunkel bearbeitet werden soll)
  g_obj_not_dark   like rmclf-kreuz,

*-- G_OBJ_SCR wird auf X gesetzt, wenn in CL24 Objekte einer Klasse
*-- zugeordnet werden (Dynpro 512)
  g_obj_scr(1),
*-- G_CLS_SCR wird auf X gesetzt, wenn in CL24 Klassen einer Klasse
*-- zugeordnet werden (Dynpro 510)
  g_cls_scr(1),
*-- Kennzeichen, das eine Gültigkeitsänderung vermeidet, wenn
*-- Bewertungsbild einmal prozessiert
  g_no_validity_chg(1),
*-- G_OK_EXIT: okcode vom Typ 'exit'.
  g_ok_exit      like sy-batch,

*-- G_ONLY_NEW_ENTRIES gilt in CL24 und steuert, daß keine
*-- bestehenden Klassifizierungen nachgelesen werden (von KSSK).
*-- Darüberhinaus sind Verprobungen dann auch gegen die DB-Tabelle
*-- KSSK erforderlich
  g_only_new_entries like rmclf-kreuz,
*-- G_ONLY_CLASS: Bei den Zuordnungen werden nur
*--               Klasse-Klasse-Zuordnungen berücksichtigt !
  g_only_class,
*-- Globales Flag für OPEN-FI-Steuerung: Falls gesetzt: nicht mehr nötig
  g_open_fi_sfa(1),
*-- Effectivity Parameter existieren im Menory, setze Icon
  g_para_set like rmclf-icon,

*-- program calling subscreen 'CBCM' / 1xx
  g_prog_cbcm       like syst-repid,
*-- program calling subscreen object in dynpros 500/1101
  g_prog_object     like syst-repid,

*-- G_SAVE_CALLED: flag for user exits,
*-- user has (not) passed function CLAP_DDB_SAVE_CLASSIFICATION.
  g_save_called(1),

*-- G_SAVE_UPD: flag for user exits,                          v  2241496
*-- request processing of exit in update,
*-- e.g. in INSERT_CLASSIFICATION.
  g_exit_upd(1),                                             "^  2241496

*-- Name des subscreen nach get cursor
  g_tcname(20)      type c,
*-- Dynamisch zu setzende Spaltenüberschrift in Tablecontrols CL24
  g_tc_title        like tcltt-obtxt,

*-- G_VAL:  Daten des aktuellen Objekts im Bewertungsbild.
  begin of g_val,
    class      like rmclf-class,
    objek      like rmclf-objek,
    status     like kssk-statu,
  end   of g_val,

*-- G_VALUES:  GUI parameters in char. aasign. screen
  begin of g_val_flags,
    read_values          like sy-batch,
    langu                like sy-langu,
    set_values_from_db   type sy-batch,
    set_default_values   type sy-batch,
    load_customizing     type sy-batch,
    tabs_active          type sy-batch,
  end   of g_val_flags,

*-- G_VIEW_BUP: VOR Aufruf von Dynpro 605 zur Sicherung RMCLF-ABTEI
  g_view_bup            like rmclf-abtei,
*-- G_ZUORD: enthält die Werte SPACE (keine Zuordnung), "0" (Objekt
*-- wird Klassen zugeordnet, CL20/21), "2" (Klasse-zu-Klasse-Zuordnung)
*-- bzw. "4" (Objekte einer Klasse zuordnen).
  g_zuord(1),

*-- HZAEHL: Höchste errechnete ZAEHL in KSSK
  hzaehl           like kssk-zaehl,
  hzeile           like syst-curow,
*-- Ikonen für die Anzeige des Klassifizierungsstatus
  icon1            like rmclf-icon,    "frei
  icon2            like rmclf-icon,    "gesperrt
  icon3            like rmclf-icon,    "nicht frei - man.
  icon4            like rmclf-icon,    "nicht frei - syst.
  ieins            like kssk-zaehl     value 1,
*-- INDEX_NEU ist die oberste Zeile auf dem Screen
*-- Abh. von RCLMF-PAGPOS wird INDEX_NEU nach dem PAI-Steploop
*-- auf den Seitenanfang gesetzt
*-- INDEX_NEU läuft dann vom Seitenanfang über den angezeigten
*-- Tabellenausschnitt
  index_neu     like syst-tabix value 1,
  index_alt     like syst-tabix value 1,                    "ST 31.3.00
*-- INDEX_NEU1 ist die erste Zeile auf dem Screen zu einem best.
*-- Objekttyp (CL24!!)
  index_neu1    like syst-tabix value 1,
  init             like csdata-xfeld,  "Stücklistenrekursivität
  inkonsi,
*-- Globale INOB-CUOBJ
  inobj            like inob-cuobj,
*-- Falls Flag INTERNE_NUMMER sitzt, muß noch die Objektnummer vergeben
*-- werden
  interne_nummer,

*-- KLAS_PRUEF und G_KLAS_PRUEF dienen der Statusprüfung
  g_klas_pruef     like klah-praus,
  klas_pruef       like klah-praus,
*-- Eine Zuordnung wurde geändert
  kssk_update,
  mafid            like kssk-mafid,
*-- MARKZEILE und MARKZEILE1: Indizes auf markierte Zeilen
*-- ... MARKZEILE: Nach dem Blockmarkieren (wenn das Blockende markiert
*-- ist) den höchsten Index
  markzeile        like syst-tabix,
*-- ... MARKZEILE1: Nur bis Blockende markiert ist
  markzeile1       like syst-tabix,

*-- MULTI_CLASS: Gibt an, ob Mehrfachklassifzierung erlaubt ist
*-- Bsp: Chargen dürfen nicht mehrfachklassifiziert werden, daher BLANK
  multi_class      like tcla-mfkls,
  no_authority,
  nodisplay,                           "Stammsatzmerkmale
  nof8,                                                     "kein F8
  nof11,                                                    "kein F11
  objekt           like rmclf-objek,
  objtype          like rmclk-obtab,
  offset           type i,
  okcode           like syst-ucomm,
  only_read        type c,
  pag_page         like syst-tabix value 1,
  pag_pages        like syst-tabix value 1,
  phydel_counter   type i,             "physisch geloescht
*-- Program1 enthält den Pgm-Namen für den Include-Screen bei CL24*
*-- objektabhängig bei neuen Zuordnungen, "CLFM" bei Übersichtsbild
  program1         like syst-repid,
*>>> Was macht das Reorgflag???
  reorgflag,
  save_clint       like kssk-clint,
  save_objek       like kssk-objek,
*-- honda,
  schonda,
  sclint           like kssk-clint,
  sklart           like kssk-klart,
*-- Übernahme von Systemvariablen
  sokcode          like syst-ucomm,
  sretcode         like syst-subrc,
  ssytabix         like syst-tabix,
  ssytcode         like syst-tcode,

  stable           like tcla-obtab,
  standardclass    like klah-class,
*-- Flag zur Kennzeichnung, daß Standardklasse gesetzt ist
*-- (Werte 0 oder 1)
  standardklasse(1) type n,
*-- STEPLOOP enthält den aktuellen Index der Tabelle KLASTAB bei der
*-- Ausgabe.
  steploop         like syst-stepl,
  strlaeng(2)      type n,
  stueli           type stnum_cl,
  szaehl           like kssk-zaehl,
  szeile           like syst-curow,
*-- Unterdrücken Zuordnungsbild (500, 501 ...)
  suppressd,
*-- TCD_STAT kennzeichnet einen Aufruf von z.B. OBJECT_CLASSIFI als
*-- Anzeigen (" ") oder Ändern/Hinzuf. ("X").
  tcd_stat         like rmclm-basisd,  "Status der Transaktion
  umhaengen,
*-- VARKLART: Kennzeichen, daß aktuelle KLART nur für Varianten
  varklart         like tcla-varklart,
  view_complete,
*-- Globales Hilfsfeld
  x2               like syst-dbcnt,
  xzeile           like syst-curow,
*-- ZEILE1 dient als temporärer Index z.B. bei Blcok Markieren
  zeile1           like syst-curow,

*-- Klassifizierungsstatus
  cl_statusf       like tclc-statu,    "Status frei
  cl_statusum      like tclc-statu,    "Status manuell gesetzt
  cl_statusus      like tclc-statu,    "Status vom System gesetzt
  cl_statuslv      like tclc-statu,    "Status Löschvormerkung
  cl_statusge      like tclc-statu,    "Status gesperrt
  cl_status_neu,                       "Status neu gesetzt vom Anwender
* class type corresponding to above classification status      v 2653421
* must only be set by subroutine LESEN_TCLC
  cl_status_klart  TYPE tclc-klart,                           "^ 2653421

*-- PM (Parameter)-Variablen
*-- PM_BATCH: Keine Relevanz für CLFM*, sondern nur Kennzeichen für
*-- Aufruf aus BATCH, das an ENTER_VALUES durchgereicht wird
  pm_batch,
  pm_class         like klah-class,
*-- PM_CLINT enthält den (auf einer Liste) ausgewählten akt. Eintrag
  pm_clint         like kssk-clint,
*-- PM_CLINT1 enthält die Klasse, die zu klassifizieren ist
*-- (Bespiel: Einstiegsklasse aus CL22 bzw. die auf der Liste
*-- ausgewählte Klasse in CL24); entspricht PM_OBJEK bei CL20/24
  pm_clint1        like kssk-clint,
  pm_depart                             ,
*-- PM_INOBJ ist gesetzt, falls KSSK eine CUOBJ enthält
  pm_inobj         like inob-cuobj,
  pm_meins         like klah-meins,
  pm_objek         like kssk-objek,
*-- In G_SICHT_AKT stehen die jeweils ( ggf. zu einer Zuordnung)
*-- aktuellen Sichten. In RMCLF-ABTEI nur noch bei Dynpro-EA
  g_sicht_akt      like klah-sicht,
  pm_status        like kssk-statu,
  pm_vwstl         like klah-vwstl,
*-- Prüfen ob mindastens eine Zeile modifiert werden kann      "1772310
  g_change_item    type c,                                     "1772310
end_data.

* Begin Correction 27.01.2004 0701214 *******************
* global flag to activate the modifications
* for the module EH&S (class-type 100)
  DATA G_FLG_EHS_MOD_ACTIVE(1) TYPE C VALUE 'X'.
* End Correction 27.01.2004 0701214 *********************

*-- Hilfstabelle, um bei CLAP_DDB_UPDATE_CLASSIFICATION bei mehrmaligem
*-- Aufruf nicht wiederholt von Datenbank zu lesen
data: begin of gt_getlist occurs 5,
        objek like kssk-objek,
        klart like kssk-klart,
        mafid like kssk-mafid,
        check like sy-batch,
        aennr like kssk-aennr,
        get   like sy-batch,
      end of  gt_getlist.

data: begin of xtclc occurs 5.
        include structure tclc.
data: stattxt like rmclf-stattxt.
data: end   of xtclc.

*-- OK_CODES, die auszublenden sind
*-- Tabelle -v : Menü Bewertung ausblenden
data: begin of ex_pfstatus occurs 1,
        func    like okcode,
      end   of ex_pfstatus.

data: ex_pfstatus1  like ex_pfstatus
                    occurs 1 with header line.
data: ex_pfstatusv  like ex_pfstatus
                    occurs 1 with header line.
data: ex_pfstatus1v like ex_pfstatus
                    occurs 1 with header line.

*-- In Department werden die Sichten abgelegt und an CTMS übergeben
*-- (Wenn nicht initial: Sicht wurde bereits gesetzt (s.Klassifizieren))
data: begin of department,
        klart  like rmclf-klart,
        sicht  like g_sicht_akt.
data: end   of department.

data: begin of allkssk occurs 0.
        include structure rmclkssk.
data: end   of allkssk.

data: begin of gt_tmpkssk occurs 0.
        include structure rmclkssk.
data: end   of gt_tmpkssk.

data: begin of allausp occurs 0.
        include structure rmclausp.
data: end   of allausp.

data: begin of delcl occurs 0.
        include structure rmcldel.
data: end   of delcl.

data  : begin of delob occurs 0.
        include structure rmcldob.
data  : end   of delob.

data: begin of gt_dispo occurs 0.
        include structure clmdcp.
data: end   of gt_dispo.

data: begin of ikssk occurs 0.
        include structure kssk.
data: end   of ikssk.

data: begin of xkssk occurs 0.
        include structure kssk.
data: end   of xkssk.

*data: begin of t_ausp occurs 0.
*        include structure ausp.
*data: end   of t_ausp.

DATA: t_ausp TYPE SORTED TABLE OF ausp                          "2332497
             WITH NON-UNIQUE KEY mafid klart objek              "2332497
             WITH HEADER LINE.                                  "2332497

data: begin of itclc occurs 5,
        kreuz   like rmclf-kreuz,
        statu   like rmclf-statu,
        stattxt like rmclf-stattxt.
data: end   of itclc.

data: begin of viewk occurs 0,
        klart like klah-klart,
        class like klah-class,
        merkm like ksml-imerk,
        omerk like ksml-omerk,
        posnr like ksml-posnr,
        abtei like ksml-abtei,
        udeff like ksml-dptxt,
        loekz like kssk-lkenz,
        udefm like ksml-imerk.         "neu ab 45A: ATINN des Udefs
data: end   of viewk.

data: begin of merktab occurs 20,
        imerk      like ksml-imerk,
        omerk      like ksml-omerk,
        abtei      like ksml-abtei,
        posnr      like ksml-posnr,
      end   of merktab.

data: begin of merkmal occurs 20,
        imerk      like ksml-imerk,
        omerk      like ksml-omerk,
        abtei      like ksml-abtei,
        posnr      like ksml-posnr,
      end   of merkmal.

data: begin of sel occurs 0.
        include structure comw.
data: end   of sel.

data: begin of iksml occurs 0.
        include structure ksml.
data: end   of iksml.

*+data: begin of stpowa occurs 0.
*+        include structure stpob.
*+data: end   of stpowa.

*-- PM_HEADER ist die Übergabestruktur für das Bewertungsbild (INCLUDE)
data: begin of pm_header,
        report     like syst-repid value 'SAPLCBCM',
        dynnr      like syst-dynnr,
      end   of pm_header.

*-- GHCLI: Mehrfachbewertungen werden hier vermerkt, um sie im
*-- STRUCTURE_CLASSES berücksichtigen zu können, auch wenn sie nicht
*-- auf der Datenbank waren!
data: begin of ghcli  occurs 0,
        klart like klah-klart,
        clas2 like klah-class,
        objek like kssk-objek,
        clin2 like klah-clint,
        cltx2 like ghcl-cltx2,
        mklas like ghcl-mklas,
        delkz like rmclf-kreuz.
data: end of ghcli.

*-- GHCL wird lokal verwendet, um den STRUCTURE_CLASSES aufzurufen
data: begin of ghclh  occurs 0.
        include structure ghcl.
data: end of ghclh.

*-- GHCLH1 wird global definiert, da ggf. die Daten gepuffert werden
data: begin of ghclh1 occurs 0.
        include structure ghcl.
data: end of ghclh1.

data: begin of iatinn occurs 0.
        include structure cliausp.
data: end   of iatinn.

data: begin of laengtab occurs 10,
        l          type i,
      end   of laengtab.

data  : begin of klartinob,
          klart like kssk-klart,
          cuobj like inob-cuobj,
          table like inob-obtab,
          aeblg like tcla-aediezuord.
data  : end   of klartinob.

data: gr_ret_gen_art_badi type ref to badi_retail_generic_art_classf.

*-- Klassenart-INOB-Zuordnung für ein Objekt
data  : begin of klartino occurs 10,
          klart like kssk-klart,
          cuobj like inob-cuobj.
data  : end   of klartino.

data  : begin of redun occurs 10.
        include structure rmclobj.
data  : end   of redun.

data  : begin of redun1 occurs 10,
          index like syst-tabix.
data  : end   of redun1.

data  : begin of tabausw occurs 10,
          obtyp    like rmclf-obtyp,
          kreuz    like rmclf-kreuz,
          texto    like rmclf-texto,
          zaehl(2) type n.
data  : end   of tabausw.

data  : begin of iklart occurs 10.
        include structure rmclklart.
data  : end   of iklart.

data  : begin of relid,
          uname like syst-uname,
          klart like kssk-klart.
data  : end   of relid.

*-- g_obj_indx_tab enthält die Indizes auf die klastab innerhalb der
*-- Transaktion CL24, wenn nur Objekte eines Typs bearbeitet werden
data  : begin of g_obj_indx_tab occurs 0,
          index like syst-tabix,
          showo like rmclf-kreuz.
data  : end   of g_obj_indx_tab.

*-- interne Tabelle IKLAH zur temporären Verwendung
data  : begin of iklah  occurs 0.
        include structure klah.
data  : end   of iklah.

data  : begin of pkssk  occurs 0.
        include structure clzuord_pu.
data  : end   of pkssk.

data  : begin of pausp  occurs 0.
        include structure ausp.
data  : end   of pausp.

data: begin of auspmerk occurs 0,
        atinn like ausp-atinn.
data: end   of auspmerk.

data: begin of chars occurs 0.
        include structure api_char_i.
data: end   of chars.

data: begin of tab,
        imerk like ksml-imerk.
data: end of tab.

types satinn like tab occurs 0.

data: begin of classes occurs 0,
        uclint like kssk-clint,
        merkm  type satinn.
data: end   of classes.

data:                                                    "begin 1022419
  gt_log_allkssk type rmclkssk occurs 0,
  gt_log_allausp type rmclausp occurs 0,
  gt_log_ghcli   like ghcli occurs 0,
  gv_fill_log_tables type c.                               "end 1022419

*data: begin of gt_save_kssk occurs 0.                "2021602  2032928
*        include structure rmclkssk.                  "2021602  2032928
*data: end   of gt_save_kssk.                         "2021602  2032928

*------------------------------------------------------------------

constants:

*-- Verbuchungskennzeichen
  c_delete         like rmclkssk-vbkz         value 'D',
  c_insert         like rmclkssk-vbkz         value 'I',
  c_update         like rmclkssk-vbkz         value 'U',

  c_change                                    value '2',
  c_display                                   value '3',
  c_ok                                        value '0',
  c_continue                                  value '1',
  c_break                                     value '2',

*   c_batch:characterizes okcode form that is used in
*   batch input mode or old transactions (release >= 4.6)
  c_batch          like tclokcode-usetype     value 'B',

* names of input fields:
*   class name, change number
  c_fld_clasn(20)  type c                     value 'RMCLF-CLASN',
  c_fld_aennr(20)  type c                     value 'RMCLF-AENNR1',

*-- Tabellenkonstanten
  c_klah           like tcla-obtab            value 'KLAH',
  c_zaehl_start    like kssk-zaehl            value '10',

*-- Parameter-IDs
  c_param_aen      like usparam-parid         value 'AEN',
  c_param_aen1     like usparam-parid         value 'AEN1',
  c_param_kar      like usparam-parid         value 'KAR',  " class type
  c_param_kla      like usparam-parid         value 'KLA',
  c_param_klt      like usparam-parid         value 'KLT',  " obj. table
  c_param_view     like usparam-parid         value 'VIEW',

* acty: call transaction CL2xN skip first sreen
*       =2 : change , =3 : display
  c_param_acty     like usparam-parid         value 'CL_ACTY',


* objecttype for stack
  c_objclass(10) type c value 'OBJCLASS',

* c_save (userexit): user has passed CLAP_DDB_SAVE_CLASSIFICATION
  c_save                                      value '1',

* c_save_new (userexit): already in update processing         "  2241496
  c_save_upd                                  value '2',      "  2241496

*-- Zuordnungskennzeichnung
*-- ... CL20/21: Objekt zu Klassen zuordnen
  c_zuord_0        like g_zuord value '0',
*-- ... CL22/23: Klasse-zu-Klassenzuordnung
  c_zuord_2        like g_zuord value '2',
*-- ... CL24/25: Objekte einer Klasse zuordnen
  c_zuord_4        like g_zuord value '4',

*-- Modif-Gruppe 1 für Felder, die auf Anzeige zu schalten sind
  c_io_field   like feld-grp1   value 'IO',
  c_key        like feld-grp1   value 'KEY',

  abbr                          value 'A',
  eins         like swor-klpos  value 1,
  ein                           value 1,
  zwei                          value 2,
  drei                          value 3,
  incl     like merkmtab-sign   value 'I',
  ja                            value 'J',
  konst_c                       value 'C',
  konst_e                       value 'E',
  konst_w                       value 'W',
  konst_y                       value 'Y',
  konst_z                       value 'Z',
  tabmara(4)                    value 'MARA',
  tabmarc(4)                    value 'MARC',
  equal    like merkmtab-option value 'EQ',
*-- Modif-Gruppe 3 auf den Screens
  group3int(3)  type c          value 'INT',
  nein                          value 'N',
  pm_ident(2)   type c          value 'KL',
  on            type c          value '1',
  off           type c          value '0',

*-- STATU-Ausprägungen von SEL-STATU global
  loeschen      type c          value 'L',
  hinzu         type c          value 'H',

  mafido        like kssk-mafid value 'O',
  mafidk        like kssk-mafid value 'K',
  mode          like rmclm-basisd value 'K',
  punkt         type c          value '.',

  pfstatd500       like syst-pfkey  value 'D500',
  pfstatd500dis    like syst-pfkey  value 'D500DIS',
  pfstatd500cl     like syst-pfkey  value 'D500CL',
  pfstatd500cldis  like syst-pfkey  value 'D500CLDIS',
  pfstatd501       like syst-pfkey  value 'D501',
  pfstatd501cl     like syst-pfkey  value 'D501CL',
  pfstatd505       like syst-pfkey  value 'D505',
  pfstatd506       like syst-pfkey  value 'D506',
  pfstatd510       like syst-pfkey  value 'D510',
  pfstatd511       like syst-pfkey  value 'D511',
  pfstatd511dis    like syst-pfkey  value 'D511DIS',
  pfstatd512       like syst-pfkey  value 'D512',
  pfstatd520       like syst-pfkey  value 'D520',
  pfstatd520_rtc   like syst-pfkey  value 'D520_RTC',  " Retail Cloud Enablement
  pfstatd600       like syst-pfkey  value 'D600',
  pfstatd601       like syst-pfkey  value 'D601',
  pfstatd602       like syst-pfkey  value 'D602',
  pfstatd603       like syst-pfkey  value 'D603',
  pfstatd604       like syst-pfkey  value 'D604',
  pfstatd605       like syst-pfkey  value 'D605',
  pfstatv511       like syst-pfkey  value 'V511',
  pfstatv5xx       like syst-pfkey  value 'V5XX',

  ctstatalloc      type cua_status  value 'CT_ALLOC',

* CL20/22/24N
  pfstatd1100      like syst-pfkey value 'D1100',
  pfstatd1101      like syst-pfkey value 'D1101',
  pfstatd1102      like syst-pfkey value 'D1102',
  pfstatd1110      like syst-pfkey value 'D1110',
  pfstatd1512      like syst-pfkey value 'D1512',

  title001(3)                   value '001',
  title002(3)                   value '002',
  title003(3)                   value '003',
  title006(3)                   value '006',
  title007(3)                   value '007',
  title008(3)                   value '008',
  title010(3)                   value '010',
  title011(3)                   value '011',
  title012(3)                   value '012',
  title015(3)                   value '015',
  title016(3)                   value '016',
  title017(3)                   value '017',
  title018(3)                   value '018',
  title019(3)                   value '019',
  title020(3)                   value '020',
  title030(3)                   value '030',
  title032(3)                   value '032',
  title034(3)                   value '034',

*-- Tcode CL01 und CL03 zum Absprung in die Klassenpflege
  tcodecl01     like syst-tcode value 'CL01',
  tcodecl03     like syst-tcode value 'CL03',

*-- Transaktionen für Zuordnungen
  tcodecl20     like syst-tcode value 'CL20',
  tcodecl21     like syst-tcode value 'CL21',
  tcodecl22     like syst-tcode value 'CL22',
  tcodecl23     like syst-tcode value 'CL23',
  tcodecl24     like syst-tcode value 'CL24',
  tcodecl25     like syst-tcode value 'CL25',
  tcode_1obj    like syst-tcode value 'CL20N',
  tcode_1cls    like syst-tcode value 'CL22N',
  tcode_nobj    like syst-tcode value 'CL24N',

  tcodeclw1     like syst-tcode value 'CLW1',
  tcodeclw2     like syst-tcode value 'CLW2',

  dynp0199      like syst-dynnr value '0199',
  dynp0299      like syst-dynnr value '0299',
  dynp0399      like syst-dynnr value '0399',
  dynp0497      like syst-dynnr value '0497',
  dynp0498      like syst-dynnr value '0498',
  dynp0499      like syst-dynnr value '0499',
  dynp0599      like syst-dynnr value '0599',

  dy000         like syst-dynnr value '0000',
  dy500         like syst-dynnr value '0500',
  dy501         like syst-dynnr value '0501',
  dy505         like syst-dynnr value '0505',
  dy506         like syst-dynnr value '0506',
  dy510         like syst-dynnr value '0510',
  dy511         like syst-dynnr value '0511',
  dy512         like syst-dynnr value '0512',
  dy520         like syst-dynnr value '0520',
  dy600         like syst-dynnr value '0600',
  dy601         like syst-dynnr value '0601',
  dy602         like syst-dynnr value '0602',
  dy603         like syst-dynnr value '0603',
  dy604         like syst-dynnr value '0604',
  dy605         like syst-dynnr value '0605',

*--------------------------------------------------
* OK-Codes
  ok_al_create  like okcode     value 'AL_CREATE',
  ok_al_step_dn like okcode     value 'AL_STEP_DN',
  ok_al_step_up like okcode     value 'AL_STEP_UP',
  ok_cls_stack  like okcode     value 'CLS_STACK',
  ok_obj_disp   like okcode     value 'OBJ_DISP',
  oksave        like okcode     value 'SAVE',
  okende        like okcode     value 'ENDE',
  okleav        like okcode     value 'LEAV',
  okpara        like okcode     value 'PARA',
  okpick        like okcode     value 'PICK',
  okabbr        like okcode     value 'ABBR',
  okklas        like okcode     value 'KLAS',
  okklaa        like okcode     value 'KLAA',
  okobja        like okcode     value 'OBJA',
  okloes        like okcode     value 'LOES',
  okneuz        like okcode     value 'NEUZ',
  okausw        like okcode     value 'AUSW',
  okf21         like okcode     value 'P-- ',
  okf22         like okcode     value 'P-  ',
  okf23         like okcode     value 'P+  ',
  okf24         like okcode     value 'P++ ',
  okmark        like okcode     value 'MARK',
  okmall        like okcode     value 'MALL',
  okmade        like okcode     value 'MADE',
  okmein        like okcode     value 'MEIN',
  okvobi        like okcode     value 'VOBI',
  okwei1        like okcode     value 'WEI1',
  okweit        like okcode     value 'WEIT',
  okuebn        like okcode     value 'UEBN',
*-- Anwendungssicht wechseln
  oksich        like okcode     value 'SICH',
*-- Parameter sichern in User-Stamm
  okspar        like okcode     value 'SPAR',
  okstat        like okcode     value 'STAT',
  okstcl        like okcode     value 'STCL',
  oknezu        like okcode     value 'NEZU',
  okente        like okcode     value 'ENTE',
*-- Objektnavigation
  ok_first      like okcode     value 'FIRST',
  ok_last       like okcode     value 'LAST',
  ok_next       like okcode     value 'NEXT',
  ok_prev       like okcode     value 'PREV',
*-- Blockmarkieren
  okbloc        like okcode     value 'BLOC',
*-- Markierungen löschen
  okbloe        like okcode     value 'BLOE',
  okwech        like okcode     value 'WECH',
  okfixi        like okcode     value 'FIXI',
  okobwe        like okcode     value 'OBWE',
  okeint        like okcode     value 'EINT',
  okhcla        like okcode     value 'HCLA',
  okhclg        like okcode     value 'HCLG',
  okucla        like okcode     value 'UCLA',
  okuclg        like okcode     value 'UCLG',
  okxcla        like okcode     value 'XCLA',
  okxclg        like okcode     value 'XCLG',
  okinko        like okcode     value 'INKO',
  okfilt        like okcode     value 'FILT',
  okaedi        like okcode     value 'AEDI',
  okaeda        like okcode     value 'AEDA',
  okaebl        like okcode     value 'AEBL',
*-- Sammelfreigabe
  okrele        like okcode     value 'RELE',

*-- Merkmalbewertungen
  ok_back        like okcode     value 'BACK',
  ok_char_ausw   like okcode     value 'SELM',
  ok_acus        like okcode     value 'ACUS',
  ok_acmg        like okcode     value 'ACMG',
  ok_defv        like okcode     value 'DEFV',
  ok_doku        like okcode     value 'DOKU',
  ok_trac        like okcode     value 'TRAC',
  ok_trce        like okcode     value 'TRCE',
  ok_view        like okcode     value 'VIEW',
  ok_vsch        like okcode     value 'VSCH' .


data: begin of reject_changes occurs 0,                       "1003665
        object     like ausp-objek,                           "1003665
        class_type like klah-klart,                           "1003665
        view(1)    type c,                                    "1003665
      end of reject_changes.                                  "1003665


* >>> Retail Cloud Enablement
  DATA: gv_s4h_is_cloud TYPE boolean,
        gr_badi         TYPE REF TO badi_product_group_classfctn,
        g_platform      TYPE grafpltfm. "WEBGUI
* <<< Retail Cloud Enablement
*--------------------------------------------------------
* Feldsymbole

field-symbols:
  <cua>,
  <length>,
* fields for assigning loops
  <gf_kssk> like allkssk,
  <gf_klas> like klastab,
  <gf_ausp> like allausp.

*-----------------------------------------------------------------------

* controls partially dependency processing in CTMS             v 1026735
* via (SAPLCTMS)G_READONLY
* can be set for transactions (like MSC3N)
* that want to see the true valuations from database
data G_READONLY_CTMS type C value ' '.                        "^ 1026735

class lcl_material definition.

  public section.

    class-methods:

      has_original        returning value(rv_exists) type xfeld.

endclass.

LOAD-OF-PROGRAM.                                              "1963062
  CLEAR sy-subrc.                                             "1963062
