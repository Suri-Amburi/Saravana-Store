FUNCTION-POOL ZWPDA  MESSAGE-ID WC LINE-SIZE 100.


* Typ-Definitionen.
TYPE-POOLS: SHLP.

CONSTANTS C_GENERIC_ARTICLE TYPE ATTYP VALUE '01'.

* Tabellendeklarationen.
TABLES: TVKWZ,     " Zuordng.: VKORG <--> VTWEG <--> WERKS
        TVKOV,     " Zuordng.: VKORG <--> VTWEG
        TVTWT,     " Texte zum Vertriebsweg
        EDP13,     " Tabelle für Partnervereinbarungen
        T001,      " Tabelle der Buchungskreise
        T001K,     " Tabelle der Bewertungskreise
        EDIPOD,    " Tabelle für Portbeschreibungen
        EDIDD,     " Tabelle für IDOC-Datensätze
        EDIDC,     " Tabelle für IDOC-Statussätze
        EDI_DS,    " Struktur für IDOC-Status
        WDLS,      " Status-Kopfzeile
        WDLSP,     " Status-Positionszeile
        CDPOS,     " Änderungsbelegpositionen für sofortige Änderungen
        PCDPOS,    " Änderungsbelegpositionen für geplante Änderungen
        BDCP,      " Änderungspointer
        BDCPS,     " Änderungspointer: Status
        BDCPV,     " Änderungspointer: Pflegeview
        T023,                          " Warengruppen Basisdaten
*       klah,                          " Warengruppen als Klassen
        T023T,                         " Texte zu Warengruppen
        WRF6,      " Zuordnung: Warengruppe zur Filiale
        T001W,                         " Filialstamm
        WRF1,                          " Filialstammerweiterung
        TWRF11,
        TWPFI,     " Kommunikationsprofil der Filiale
        TWPEK,     " erlaubte Konditionsarten pro Filiale.
        T134,                          " Weitere Daten für Artikel
        TVMS,      " Prüftabelle für Verkaufssperre Artikel
        TNTP,      " Prüftabelle für Artikel, ob Waagenartikel
        MARA,                          " Artikeldaten
        MVKE,                          " Verkaufsdaten zum Artikel
        M_MAT1L,                       " View auf MARA über Warengruppe
        MARM,                          " Artikeldaten
        MEAN,                          " EAN-Referenzen
        MAKT,      " Artikeldaten     ###  später wieder löschen
        MAMT,                          " Artikeltexte
        WRSZ,      " Zuordnung: Filiale <--> Sortiment
        WLK1,      " Listungskonditionen des Artikels
        WLK2,                          " Listungsdaten des Artikels
        DWLK2,                         " Struktur für zugeh. ÄB-Objekt
        A003,                          " Umsatzsteuerkennzeichen
        A071,                          " Preise auf Filialebene
        T005,                          " Kalkulationsschemata
        T007A,                         " Steuerarten
        T007S,     " Bezeichnungen der Umsatzsteuerkennzeichen
        T683S,                         " Konditionsart für Umsatzsteuer
        KONH,                          " Konditionen (Kopf)
        KONP,                          " Konditionspositionen
*       konm,                          " Konditionsmengenstaffeln
        KONDN,                         " Naturalrabattkopf
        KONDNS,                        " Naturalrabattstaffeln
        PISPR,                         " mögliche Konditionsschlüssel
        MAST,      " Set-Artikel (Materialstücklisten)
        STKO,      " Gültigkeitsbeginn beim Anlegen einer Stückliste
        STPO,                          " Stücklisten
        STAS,                          " Stücklistenalternativen
        T415B,     " Nachzugsartikel: Verkaufsmengeneinheiten
        CSBOM,                         " Stücklisten
        KNVV,                          " Kundenstamm KKBER-Daten
        KNA1,                          " Kundenstamm (allgemeiner Teil)
        KNKA,      " Kundenstamm Kreditmanagement: Zentraldaten
        KNKK,      " Kundenstamm Kreditmanagement: Kontrollbereichsdaten
        VCKUN,     " Kundenstamm Kreditkarten: Kreditkartenschlüssel
        VCNUM,     " Kundenstamm Kreditkarten: Kreditkarten Stammdaten
        TVCIN,     " Kundenstamm Kreditkarten: Konditionsarten
        KNBK,      " Kundenstamm Bankverbindungen: Kontonummern
        BNKA,      " Kundenstamm Bankverbindungen: Name u. Sitz der Bank
        TCURR,                         " Wechselkurse
        TCURT,                         " Währungssymbole
        TCURF,     " Gewichtsfaktoren für Währungssymbol
        TCURC,     " Währungsschlüssel.
        T682I,     " Zugriffsfolge für Konditionstabellen
        T685,      " Applikation, Zugriffsf. <--> Konditionsart
        WIND,      " Konditionsbelegindex
        TWPA,      " Sortimente: Systemeinstellung (n:m-Zuordnung)
        E1WPW01,                       " Download Warengruppen
        E1WPW02,                       " Download Warengruppen
        E1WPW05,                       " Download Warengruppen
        E1WPW03,                       " Download Warengruppen
        E1WPW04,                       " Download Warengruppen
        E1WPA01,                       " Download Artikelstamm
        E1WPA02,                       " Download Artikelstamm
        E1WPA03,                       " Download Artikelstamm
        E1WPA04,                       " Download Artikelstamm
        E1WPA05,                       " Download Artikelstamm
        E1WPA07,                       " Download Artikelstamm
        E1WPA08,                       " Download Artikelstamm
        E1WPA09,                       " Download Artikelstamm
        E1WPA10,                       " Download Artikelstamm
        E1WPA11,                       " Download Artikelstamm
        E1WPC01,                       " Download Wechselkurse
        E1WPC02,                       " Download Wechselkurse
        E1WPT01,                       " Download Steuern
        E1WPT02,                       " Download Steuern
        E1WPE01,                       " Download EAN-Referenzen
        E1WPE02,                       " Download EAN-Referenzen
        E1WPN01,                       " Download Nachzugsartikel
        E1WPN02,                       " Download Nachzugsartikel
        E1WPS01,                       " Download Set-Zuordnungen
        E1WPS02,                       " Download Set-Zuordnungen
        E1WPP01,                       " Download Personendaten
        E1WPP02,                       " Download Personendaten
        E1WPP03,                       " Download Personendaten
        E1WPP04,                       " Download Personendaten
        E1WPP05,                       " Download Personendaten
        E1EDK28,                       " Download Personendaten
        E1WPP07,                       " Download Personendaten
        E1WXX01,                       " Kundeneigene Daten
        E1WPREB01,                     " Download Aktionsrabatte
        E1WPREB02,                     " Download Aktionsrabatte
        E1WPREB03,                     " Download Aktionsrabatte
        E1WPREB04,                     " Download Aktionsrabatte
        E1WPREBXX.                     " Download Aktionsrabatte

* types
TYPES:
  BEGIN OF GST_ARTICLE,
    MATNR TYPE MARA-MATNR,
  END OF GST_ARTICLE.

TYPES: GTT_ARTICLE TYPE SORTED TABLE OF GST_ARTICLE WITH UNIQUE KEY MATNR.

TYPES:
  BEGIN OF GST_ART_SITE,
    MATNR TYPE MARA-MATNR,
    WERKS TYPE T001W-WERKS,
  END OF GST_ART_SITE.

TYPES: GTT_ART_SITE TYPE SORTED TABLE OF GST_ART_SITE WITH UNIQUE KEY MATNR WERKS.

" new structure to substitute wpdel because of field extension of MARA-MATNR

TYPES: BEGIN OF ST_WPDEL_NEW,
         ARTNR TYPE MARA-MATNR,
         VRKME TYPE WPDEL-VRKME,
         EAN   TYPE WPDEL-EAN,
         DATUM TYPE WPDEL-DATUM,
       END OF ST_WPDEL_NEW.

TYPES: TT_WPDEL TYPE ST_WPDEL_NEW OCCURS 0.

* enhancement regarding IDoc sizing
DATA: C_MAX_IDOC_WGR TYPE POS_MAX_IDOC_SIZE,
      C_MAX_IDOC_EAN TYPE POS_MAX_IDOC_SIZE,
      C_MAX_IDOC_NAC TYPE POS_MAX_IDOC_SIZE,
      C_MAX_IDOC_SET TYPE POS_MAX_IDOC_SIZE,
      C_MAX_IDOC_PER TYPE POS_MAX_IDOC_SIZE,
      C_MAX_IDOC_CUR TYPE POS_MAX_IDOC_SIZE,
      C_MAX_IDOC_PLU TYPE POS_MAX_IDOC_SIZE.


************************************************************************
* Includes:
************************************************************************
* POS-relevante IDOC- und Message-Typen.
INCLUDE LWPUEECO.


************************************************************************
* Datendeklarationen zusätzlicher FB's der POS-Schnittstelle.
************************************************************************
* Für FB: POS_CONDITION_INTERVALS_MERGE.
*-----------------------------------------------------------------------
DATA: G_T685_COUNTER  TYPE I,
      G_T682I_COUNTER TYPE I.

DATA:  PE_NO_BBY TYPE WPSTRUC-MODUS.
* Tabellen der Zugriffsfolge für Konditionstabellen.
DATA: BEGIN OF GT_ORDER OCCURS 8.
        INCLUDE STRUCTURE T682I.
      DATA: END OF GT_ORDER.

* Tabellen der Zugriffsfolge für Konditionstabellen.
DATA: BEGIN OF GT_T682I_BUF OCCURS 200.
        INCLUDE STRUCTURE T682I.
      DATA: END OF GT_T682I_BUF.

* Name der Zugriffsfolge für Konditionstabellen.
DATA: BEGIN OF GT_T685_BUF OCCURS 100.
        INCLUDE STRUCTURE T685.
      DATA: END OF GT_T685_BUF.

* Für FB: POS_STORE_IDOC_FILENAMES_GET.
*-----------------------------------------------------------------------
DATA: C_EDI_DS                      LIKE EDI_DS-TABNAM VALUE 'EDI_DS',
      C_SAPLWPDA                    LIKE EDI_DS-REPID  VALUE 'SAPLWPDA',
      C_EOL(3)                      VALUE 'eol',
      C_FEHLER_BEI_UEBERGABE_AN_SCS LIKE EDI_DS-STATUS VALUE '20',
      C_PATHNAMES_GET               LIKE EDI_DS-ROUTID
                                    VALUE 'PATHNAMES_GET'.
*     c_pos_store_idoc_filenames_get like edi_ds-routid
*                      value 'POS_STORE_IDOC_FILENAMES_GET'.

* Für FB: POS_RESTART.
*-----------------------------------------------------------------------
DATA: C_KEINE_PROTOKOLLSCHREIBUNG    VALUE '1',
      C_SUBSYSTEM_NOCH_NICHT_AKTIV   VALUE '2',
      C_JUENGERER_DOWNLOAD_VORHANDEN VALUE '3',
      C_KEIN_KOMMUNIKATIONSPROFIL    VALUE '4',
      C_VORLAUFZEIT_ZU_KLEIN         VALUE '5'.

* Für FB: POS_REORG_POINTER.
*-----------------------------------------------------------------------
DATA: C_POS LIKE WDLS-SYSTP VALUE 'POS'.

DATA: G_WIND_REORGANIZED LIKE WIND-BLTYP,
      G_SYSTYPE_BUF      LIKE WDLS-SYSTP VALUE 'INI'. " nur zum initialisier.

* Tabelle der Statuskopfzeilen.
DATA: BEGIN OF GT_WDLS_REORG OCCURS 10.
        INCLUDE STRUCTURE WDLS.
      DATA: END OF GT_WDLS_REORG.

* Tabelle der Kommunikationsprofilen.
DATA: BEGIN OF GT_FILIA_CONST_REORG OCCURS 10,
        FILIA LIKE T001W-WERKS,
        KUNNR LIKE T001W-KUNNR,
        KOPRO LIKE TWPFI-KOPRO.
DATA: END OF GT_FILIA_CONST_REORG.

* Tabelle mit Filialdaten.
DATA: BEGIN OF GT_FILIA_DATA OCCURS 500,
        FILIA  LIKE T001W-WERKS,
        DATP1  LIKE SY-DATUM,
        TIMEP1 LIKE SY-UZEIT,
        DATP3  LIKE SY-DATUM.
DATA: END OF GT_FILIA_DATA.

* Tabelle der Gesamtschnittmenge aller Pointer.
DATA: BEGIN OF GT_POINTER_DELETE OCCURS 300.
        INCLUDE STRUCTURE BDICPIDENT.
      DATA: END OF GT_POINTER_DELETE.

* Für FB: POS_RATE_OF_EXCHANGE_GET.
*-----------------------------------------------------------------------
DATA: G_WAERS              LIKE KNVV-WAERS,
      G_DATAB_WAERS        LIKE WPSTRUC-DATAB,
      G_DATBI_WAERS        LIKE WPSTRUC-DATAB,
      G_KURST_WAERS        LIKE TWPFI-KURST,
      G_SPRAS_WAERS        LIKE TCURT-SPRAS,
      G_FIRST_RECORD_WAERS LIKE WPSTRUC-MODUS.

* Puffertabelle für Wechselkurse.
DATA: BEGIN OF GT_RATES_OF_EXCHANGE OCCURS 20.
        INCLUDE STRUCTURE WPEXCHG.
      DATA: END OF GT_RATES_OF_EXCHANGE.

* Für FB: POS_TAX_GET.
*-----------------------------------------------------------------------
DATA: G_LAND_TAX  LIKE T001W-LAND1,
      G_SPRAS_TAX LIKE T001W-SPRAS.

* Puffertabelle für Steuerkennzeichen.
DATA: BEGIN OF GT_SALES_TAXES OCCURS 30.
        INCLUDE STRUCTURE WPTAX.
      DATA: END OF GT_SALES_TAXES.

* Für FB: POS_CREDIT_CARD_DATA_GET.
*-----------------------------------------------------------------------
DATA: BEGIN OF GT_KUNNR_CREDIT_BUF OCCURS 300.
        INCLUDE STRUCTURE WPPDAT.
      DATA: END OF GT_KUNNR_CREDIT_BUF.

* Puffertabelle für Kreditkarteninformationen.
DATA: BEGIN OF GT_CREDIT_DATA_BUF OCCURS 600.
        INCLUDE STRUCTURE WPCREDCARD.
      DATA: END OF GT_CREDIT_DATA_BUF.

* Für FB: POS_BANK_DATA_GET.
*-----------------------------------------------------------------------
DATA: BEGIN OF GT_KUNNR_BANK_BUF OCCURS 300.
        INCLUDE STRUCTURE WPPDAT.
      DATA: END OF GT_KUNNR_BANK_BUF.

* Puffertabelle für Bankverbindungen.
DATA: BEGIN OF GT_BANK_DATA_BUF OCCURS 600.
        INCLUDE STRUCTURE WPBANKDATA.
      DATA: END OF GT_BANK_DATA_BUF.

* Für FB: POS_CONDITION_POINTER_GET.
*-----------------------------------------------------------------------
DATA: BEGIN OF GT_WIND_BUF OCCURS 0.
        INCLUDE STRUCTURE WIND.
      DATA: END OF GT_WIND_BUF.

************************************************************************
* Konstantendeklarationen.
************************************************************************
* Falls Aktionskonditionen zur Filialgruppe gefiltert werden
* sollen.
* Dieses Filtern kann nur im über die Konstante
* C_PROMOTION_CHECK = 'X' scharfgemacht werden.
* Die Filterung führt dazu, dass die Filialen bei Verwendung
* dieser speziellen Aktionskonditionen eventuell keine
* überflüssigen Daten bekommen (==> Einsparung von
* Performance in der Aufbereitung) aber dafür erhöhter
* Analyseaufwand notwendig, was die Performance wieder verschlechtert.
* Es liegt in der Verantwortung des Kunden diese zusätzliche
* Analyse zu aktivieren.

DATA: C_PROMOTION_CHECK(1) VALUE ' '.
************************************************************************

************************************************************************
* Dieses Flag steuert, ob einfaches Löschen von Konditionen bei der
* Konditionspointeranalyse berücksichtigt werden soll oder nicht.
* Damit können zumindest diejenigen Löschungen berücksichtigt werden,
* bei denen ganze Konditionssätze gelöscht wurden.
* Teilintervall-Löschungen von gesplitteten Konditionssätzen können
* damit weiterhin nicht erfaßt werden.

* Diese zusätzliche Logik führt allerdings dazu, dass hin und wieder
* Daten an die Filialen gesendet werden die sich gar nicht verändert
* haben.
* Kunden, die das auf keinen Fall wünschen (z. B. weil sie die
* POS-Ausgangsdaten für den Ausdruck von Etiketten benutzen, sollten
* dieses Flag mittels Modifikation ausschalten (auf ' ' setzen),
* sofern sie feststellen, dass in den Filialen zu viele unnötige
* Etiketten ausgedruckt werden.

DATA: C_CHECK_DELETIONS(1) VALUE 'X'.
************************************************************************

************************************************************************
* If the following flag is set then the trigger info will sent via
* remote function call to the IDOC port. This only happens if you
* you tranfer the IDOC's via logical systems.
* This scenario is usefull if you use the business connector for the
* transfer of the IDOC's to the POS-servers because the business
* connector can react to this special information.
DATA: C_TRIGGER_SEND_VIA_RFC(1) VALUE ' '.
************************************************************************

DATA: C_VORZEICHEN                VALUE '+',
      C_DELETE                    LIKE E1WPW01-AENDKENNZ    VALUE 'DELE',
      C_MODI                      LIKE E1WPW01-AENDKENNZ    VALUE 'MODI',
      C_ALL                       LIKE E1WPA01-AENDTYP      VALUE 'ALL',
      C_COND                      LIKE E1WPA01-AENDTYP      VALUE 'COND',
      C_MATR                      LIKE E1WPA01-AENDTYP      VALUE 'MATR',
      C_JA                        LIKE E1WPA02-WAAGENART    VALUE 'J',
      C_NEIN                      LIKE E1WPA02-WAAGENART    VALUE 'N',
      C_INCLUSIVE                 LIKE WPFILIASO-SIGN       VALUE 'I',
      C_BETWEEN                   LIKE WPFILIASO-OPTION     VALUE 'BT',
      C_EQUAL                     LIKE WPFILIASO-OPTION     VALUE 'EQ',
      C_MAX_IDOC                  TYPE I                    VALUE 5000,
      C_MAX_MARA_BUF              LIKE SY-TABIX         VALUE 4000,
      C_MAX_MVKE_BUF              LIKE SY-TABIX         VALUE 4000,
      C_MAX_MARM_BUF              LIKE SY-TABIX         VALUE 6000,
      C_MAX_PRICE_BUF             LIKE SY-TABIX         VALUE 10000,
      C_SECURITY_INTERVAL         TYPE I         VALUE 20, " ### Sekunden
      C_MAX_POINTER_FOR_DELE      TYPE I         VALUE 500,
      C_INIT_MODE                 VALUE 'I',
      C_DIRECT_MODE               VALUE 'A',
      C_CHANGE_MODE               VALUE 'U',
      C_RESTART_MODE              VALUE 'R',
      C_POS_SYSTEMTYP             LIKE WDLS-SYSTP      VALUE 'POS',
      C_POS_BLTYP                 LIKE WIND-BLTYP      VALUE '55',
      C_SD_VERWENDUNG             LIKE T685-KVEWE       VALUE 'A',
      C_APPLIKATION               LIKE BALHDR-OBJECT VALUE 'W ',
      C_SUBOBJECT                 LIKE BALHDR-SUBOBJECT   VALUE 'W_PDLD',
      C_DOWNLOAD                  LIKE BALHDR-SUBOBJECT   VALUE 'W_DOWNLOAD',
      C_MSGTP_ERROR               VALUE 'E',
      C_MSGTP_WARNING             VALUE 'W',
*     c_msgtp_information                   value 'I',
      C_PROBCLASS_SEHR_WICHTIG    VALUE '1',
*     c_probclass_wichtig                   value '2',
      C_PROBCLASS_WENIGER_WICHTIG VALUE '3',
*     c_probclass_zusatzinformation         value '4',
      C_INSERT                    VALUE 'I',
      C_UPDATE                    VALUE 'U',
      C_ERASE                     VALUE 'E',
      C_DEL                       VALUE 'D',
      C_BEGIN                     VALUE 'B',
      C_MESSAGE_ID(2)             VALUE 'WC',
      C_STATUS_INIT               VALUE 'I',
      C_STATUS_OK                 VALUE 'X',
      C_STATUS_BENUTZERHINWEIS    VALUE 'H',
      C_STATUS_FEHLENDE_DATEN     VALUE 'W',
      C_STATUS_FEHLENDE_IDOCS     VALUE 'E',
      C_DATENUEBERGABE_OK         LIKE WDLS-VSEST   VALUE '03',
      C_AN_SCS_UEBERGEBEN         LIKE WDLS-VSEST   VALUE '18',
      C_MAXTIME                   LIKE SY-UZEIT     VALUE '235959',
      C_KUNDE                     LIKE EDIDC-RCVPRT VALUE 'KU',
      C_PLUS                      VALUE '+',
      C_MINUS                     VALUE '-',
      C_SETTYPE                   LIKE TMGW2-STRTP  VALUE 'S',
      C_WRGP_WERTARTIKEL          LIKE MARA-ATTYP   VALUE '20',
      C_WRGP_HIER_WERTART         LIKE MARA-ATTYP   VALUE '21',
      C_WRGP_VORLAGEART           LIKE MARA-ATTYP   VALUE '30',
      C_WHOLE_IDOC                VALUE '*',
      C_ORGHIER_FILIA             VALUE 'F',
      C_NO_OBJECT_PROCESS(7)      VALUE 'XXXXXXX',
      C_SORTIMENT                 TYPE W_GROUP_TYPE        VALUE '01',
      C_FILIA_TYPE                TYPE VLFKZ               VALUE 'A'.

* Konstanten für Querverbindung zum Iventur-IDOC.
DATA: C_BASISTYP_INVENTUR LIKE EDIDC-IDOCTP    VALUE 'WVINVE',
      C_DATEIPORT         LIKE EDIPORT-PORTTYP VALUE '3'.

* Konstanten für einzelne Objekte des POS-Download
* Download Warengruppen.
DATA: C_E1WPW01_NAME   LIKE EDSVRS-SEGTYP VALUE 'E1WPW01',  " ID-Segment
      C_E1WPW02_NAME   LIKE EDSVRS-SEGTYP VALUE 'E1WPW02',  " Stammdaten
      C_E1WPW05_NAME   LIKE EDSVRS-SEGTYP VALUE 'E1WPW05',  " Steuern
      C_E1WPW03_NAME   LIKE EDSVRS-SEGTYP VALUE 'E1WPW03',  "Konditionen
      C_OBJCL_WBASISWG LIKE TCDOB-OBJECT  VALUE 'WBASISWG', " ÄB.-Objekt
      C_OBJCL_BETRIEB  LIKE TCDOB-OBJECT  VALUE 'BETRIEB',  " ÄB.-Objekt
      C_WGSTUFEN       LIKE WGHIER-STUFE  VALUE 99,  " max. Hier.-Stufe
      C_KNTYP_STEUER   LIKE T685A-KNTYP   VALUE 'D', " Kntyp: Steuer
      C_KNTYP_AGSTEUER LIKE T685A-KNTYP   VALUE 'M', " Kntyp: Ausgangsst
      C_KNTYP_VSTEUER  LIKE T685A-KNTYP   VALUE 'N'. " Kntyp: Vorsteuer


* Download Artikelstamm.
DATA: C_E1WPA01_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA01', " ID-Segment
      C_E1WPA02_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA02', " Stammdaten
      C_E1WPA03_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA03', " Texte
      C_E1WPA04_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA04', " Konditionen
      C_E1WPA05_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA05', " Kond.werte
      C_E1WPA06_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA06', " Nat.rabatte
      C_E1WPA07_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA07', " Artikelsteu.
      C_E1WPA08_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA08', " Artikelnr.
      C_E1WPA09_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA09', " NR-Kondition.
      C_E1WPA10_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA10', " NR-Staffeln
      C_E1WPA11_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPA11', " Art.staffeln
      C_ARTIKELTYP(5)    VALUE 'ART',
      C_FEHLERMELDUNG    LIKE TVMS-SPVBC    VALUE 'B',
      C_OBJCL_MAT_FULL   LIKE TCDOB-OBJECT  VALUE 'MAT_FULL',
      C_OBJCL_WRS1       LIKE TCDOB-OBJECT  VALUE 'WRS1', "n:m, HFe
      C_OBJCL_WLK1       LIKE TCDOB-OBJECT  VALUE 'WLK1',
      C_OBJCL_COND_A     LIKE TCDOB-OBJECT  VALUE 'COND_A',
      C_OBJCL_COND_N     LIKE TCDOB-OBJECT  VALUE 'COND_N',
      C_TABNAME_MARA     LIKE BDCP-TABNAME  VALUE 'MARA',
      C_TABNAME_DMARM    LIKE BDCP-TABNAME  VALUE 'DMARM',
      C_TABNAME_DMAKT    LIKE BDCP-TABNAME  VALUE 'DMAKT',
      C_TABNAME_DMEAN    LIKE BDCP-TABNAME  VALUE 'DMEAN',
      C_TABNAME_DWLK2    LIKE BDCP-TABNAME  VALUE 'DWLK2',
      C_POS_MODE         LIKE WPSTRUC-MODUS VALUE 'P',
      C_SL_MODE          LIKE WPSTRUC-MODUS VALUE 'S',
      C_ADDITIONAL_MODE  LIKE WPSTRUC-MODUS VALUE 'A',
      C_KONZERN          LIKE WPSTRUC-MODUS VALUE 'K',
      C_VERTRIEBSLINIE   LIKE WPSTRUC-MODUS VALUE 'V',
      C_FILIALE          LIKE WPSTRUC-MODUS VALUE 'F',
      C_COND_VEWE        LIKE KONH-KVEWE    VALUE 'A',
      C_NATRAB_VEWE      LIKE KONH-KVEWE    VALUE 'N',
      C_COND_APPL        LIKE KONH-KAPPL    VALUE 'V ',
      C_NATRAB_APPL      LIKE KONH-KAPPL    VALUE 'V ',
      C_SAMMELARTIKEL    LIKE MARA-ATTYP    VALUE '01',
      C_VARIANTE         LIKE MARA-ATTYP    VALUE '02',
      C_QUALARTTXT_MAKT1 LIKE E1WPA03-QUALARTTXT VALUE 'LTXT',
      C_QUALARTTXT_MAKT2 LIKE E1WPA03-QUALARTTXT VALUE 'BONT',
      C_BONTEXT          LIKE MAMT-MTXID         VALUE '02',
      C_MTXID            LIKE DD07V-DOMNAME      VALUE 'MTXID',
*     Der Sort-Index betrifft den zu versendenden Änderungstyp für
*     den Artikelstamm. Es gibt folgende Ausprägungen:
*     '1': Sowohl Material- als auch Konditionsänderungen fanden statt.
*     '2': Konditionsänderungen haben stattgefunden.
*     '3': Materialänderungen haben stattgefunden.
*     '4': Artikel soll initialisiert werden.
      C_ALL_SORT_INDEX   LIKE WPAOT2-AETYP_SORT  VALUE '1',
      C_COND_SORT_INDEX  LIKE WPAOT2-AETYP_SORT  VALUE '2',
      C_MAT_SORT_INDEX   LIKE WPAOT2-AETYP_SORT  VALUE '3',
      C_INIT_SORT_INDEX  LIKE WPAOT2-AETYP_SORT  VALUE '4',
      C_WERTSTAFFEL      VALUE 'B',
      C_MENGENSTAFFEL    VALUE 'C',
      C_VEWE_NATRAB      VALUE 'N'.

* Download EAN-Referenzen.
DATA: C_EANTYP(5)    VALUE 'EAN',
      C_E1WPE01_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPE01', " ID-Segemnt
      C_E1WPE02_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPE02'. " EAN-Ref.

* Download Nachzugsartikel.
DATA: C_E1WPN01_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPN01', " ID-Segment
      C_E1WPN02_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPN02', " N.-Artikel
      C_NART_STLAN   LIKE MAST-STLAN     VALUE '7',
      C_NARTTYP(5)   VALUE 'NART'.

* Download Set-Zuordnungen.
DATA: C_SETTYP(5)    VALUE 'SET',
      C_E1WPS01_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPS01',  " ID-Segment
      C_E1WPS02_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPS02',  " Komponenten
      C_SETARTIKEL   LIKE MARA-ATTYP     VALUE '10',    " Set-Artikeltyp
      C_OBJCL_STUE   LIKE TCDOB-OBJECT   VALUE 'STUE',
      C_OBJCL_STUE_V LIKE TCDOB-OBJECT   VALUE 'STUE_V',
      C_SET_STLAN    LIKE MAST-STLAN     VALUE '3',
      C_MAT_STLTY    LIKE STPO-STLTY     VALUE 'M'.

* Download Wechselkurse.
DATA: C_E1WPC01_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPC01', " ID-Segment
      C_E1WPC02_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPC02'. " Wechselkurs

* Download Steuern.
DATA: C_KONDART_PROZENT VALUE 'A',
      C_KAPPL(2)        VALUE 'TX',
      C_KSCHL(4)        VALUE 'MWAS',
      C_KVSL1(3)        VALUE 'MWS',
      C_E1WPT01_NAME    LIKE EDSVRS-SEGTYP  VALUE 'E1WPT01',  " ID-Segment
      C_E1WPT02_NAME    LIKE EDSVRS-SEGTYP  VALUE 'E1WPT02'.  " Stammdaten

* Download Personendaten.
DATA: C_QUALIFIER    LIKE E1WPP01-QUALIFIER  VALUE 'KUND',
      C_ID           LIKE THEAD-TDID     VALUE '0001',
      C_OBJECT       LIKE THEAD-TDOBJECT VALUE 'KNVV',
      C_OBJCL_DEBI   LIKE TCDOB-OBJECT   VALUE 'DEBI', " Kundenstamm
      C_OBJCL_KLIM   LIKE TCDOB-OBJECT   VALUE 'KLIM', " Kreditlimit
      C_OBJCL_BANK   LIKE TCDOB-OBJECT   VALUE 'BANK', " Bankverbindg.
      C_OBJCL_CREDIT LIKE TCDOB-OBJECT   VALUE 'VCNUM', " Kreditkarten
      C_GKLIM        LIKE WPSTRUC-MODUS  VALUE 'K',    " Flag f. GKlim
      C_E1WPP01_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPP01',  " ID-Segment
      C_E1WPP02_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPP02',  " Persdaten
      C_E1WPP03_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPP03',  " Adressen
      C_E1WPP04_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPP04',  " Kondit.
      C_E1WPP05_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPP05',  " Kreditkart
      C_E1EDK28_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1EDK28',  " Bankverbin
      C_E1WPP07_NAME LIKE EDSVRS-SEGTYP  VALUE 'E1WPP07'.  " Klassifiz.


* Download Aktionsrabatte.
DATA: C_OBJCL_PROMO_REBATE LIKE TCDOB-OBJECT  VALUE 'PROMO_REBATE',
      C_E1WPREB01_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPREB01', " Kopf
      C_E1WPREB02_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPREB02', " Position
      C_E1WPREB03_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPREB03', " Kondition
      C_E1WPREB04_NAME     LIKE EDSVRS-SEGTYP VALUE 'E1WPREB04'. " Kond.wert

************************************************************************
* Globale Variablendeklaration.
************************************************************************
* Feldleiste für Filialkonstanten.
DATA: BEGIN OF GI_FILIA_CONST.
        INCLUDE STRUCTURE WPFILCONST.
      DATA: END OF GI_FILIA_CONST.

* Filialabhängige Variablen.
DATA: G_MESTYPE_WRGP   LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_ARTSTM LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_BBY    LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_EAN    LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_SET    LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_NART   LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_CUR    LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_STEU   LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_PERS   LIKE EDIMSG-MESTYP, " für red. Nachrichtentyp.
      G_MESTYPE_PROM   LIKE EDIMSG-MESTYP. " für red. Nachrichtentyp.

* Filialunabhängige Variablen.
DATA: G_SEGMENT_COUNTER  LIKE WDLSP-ANSEG,  " Segmentzähler
      G_MARA_COUNT       TYPE I,            " Zähler für MARA-Puffer
      G_MVKE_COUNT       TYPE I,            " Zähler für MVKE-Puffer
      G_AKTIVDAT         LIKE SY-DATUM,     " Aktivierungsdatum
      G_N_ARBTAG         LIKE SY-DATUM,     " nächster Arbeitstag
      G_FACTORYDATE      LIKE SCAL-FACDATE, " Fabrikkalenderdatum
      G_TIME1            TYPE I,
      G_TIME2            TYPE I,
      G_DATAB            LIKE SY-DATUM,     " Beginn der Vorlaufzeit
      G_DATMIN           LIKE SY-DATUM,     " Beginn des Betrachtungszeitrms.
      G_DATBIS           LIKE SY-DATUM,     " Ende der Vorlaufzeit
      G_DATMAX           LIKE SY-DATUM,     " Ende des Betrachtungszeitraums
      G_RUNTIME_DAT1     LIKE SY-DATUM,   " Laufzeitmessung Datum 1
      G_RUNTIME_DAT2     LIKE SY-DATUM,   " Laufzeitmessung Datum 2
      G_RUNTIME_TIME1    LIKE SY-UZEIT,   " Laufzeitmessung Zeit 1
      G_RUNTIME_TIME2    LIKE SY-UZEIT,   " Laufzeitmessung Zeit 2
      G_DATUM1(10),                    " Datum für Ausgabe in Message
      G_DATUM2(10),                    " Datum für Ausgabe in Message
      G_LAST_RECORD      LIKE SY-TABIX,     " Allgemeine Index für int. Tabs
      G_DYNAME           LIKE D020S-PROG,   " Name des Dynpros
      G_DYNUMB           LIKE D020S-DNUM,   " Dynpronummer
      G_FILIA_PNAME      LIKE  SY-XFORM,    " Parametername für Filiale
      G_RETURNCODE       LIKE SY-SUBRC,     " Allgemeiner RC für FORM's
      G_LOESCH_EAN       LIKE WPDEL-EAN,    " Alter Wert der Feldänderung
      G_ERSTDAT          LIKE SY-DATUM,     " Allgemeines Erstelldatum
      G_ERSTZEIT         LIKE SY-UZEIT,     " Allgemeine Erstellzeit
      G_DLDNR            LIKE WDLS-DLDNR,   " Downloadnr.für Statusverfolgung
      G_DLDLFDNR         LIKE WDLSP-LFDNR,  " Pos-Nr. für Statusverfolgung
      G_INIT_LOG         LIKE WPSTRUC-MODUS, " ='X', Fehler-Log. initialisiert
      G_INIT_LOG_DLD     LIKE WPSTRUC-MODUS, " ='X',Fehler-Log. initialisiert
      G_SIMULATION       LIKE WPSTRUC-MODUS, " ='X',wenn keine DB-Änderungen
      G_FIRSTKEY         LIKE WDLSP-STKEY,  " Erster Key des IDOC's
      G_OBJECT_KEY       LIKE WDLSO-VAKEY,  " Allgemeiner Objektschlüssel
      G_OBJECT_DELETE,                   " 'X'= Obj. löschen, sonst ' '
      G_NEW_FIRSTKEY,                  " Flag, ob ersten Key merken
      G_NEW_POSITION,                  " Flag, ob neue Positionszeile
      G_ERR_COUNTER      TYPE I,        " Zähler für Fehlermeldungen
      G_IDOC_COUNTER     TYPE I,        " Zähler für erzeugte IDOC's
      G_STATUS           TYPE I,        " akt. Status der Aufbereitung
      " 0: Init, 1: OK, 2: Hinweis
      " 3: fehlende Daten, 4: fehl.IDOC
      G_STATUS_POS       TYPE I,        " wie G_STATUS aber auf POS-Ebene
      G_ARTNR_BUF_ARTSTM LIKE MARA-MATNR, " Puffer für Artikelnummer
      G_ARTNR_BUF_EAN    LIKE MARA-MATNR, " Puffer für Artikelnummer
      G_MATKL_BUF        LIKE MARA-MATKL, " Puffer für Warengruppe
      G_WLK2_VKORG_BUF   LIKE WLK2-VKORG, " Puffer für WLK2-Zugriffe
      G_WLK2_VTWEG_BUF   LIKE WLK2-VTWEG, " Puffer für WLK2-Zugriffe
      G_WLK2_DATAB_BUF   LIKE SY-DATUM,   " Puffer für WLK2-Zugriffe
      G_WLK2_DATBI_BUF   LIKE SY-DATUM,   " Puffer für WLK2-Zugriffe
      G_WLK2_VL_FILL,                     " Puffer für WLK2-Zugriffe
      G_MARA_BUF_FILLED,
      G_PMATA_BUF        LIKE MARA-PMATA, " Puffer für Preismaterial.
      G_VRKME_BUF        LIKE MARA-MEINS, " Puffer für VRKME.
      G_IDOC_COPY        LIKE WPSTRUC-MODUS, " 'X', IDOC wird kopiert
      G_LAST_EAN_NUMBER  TYPE I,       " # zuletzt aufber. EAN's
      G_CURR_FACTOR      TYPE P DECIMALS 3,
      G_EINHEIT          LIKE CONDSCALE-RV13AKONWA,
      G_ANZAHL_TASKS     LIKE WPSTRUC-CNT, " Anzahl paralleler Tasks
      G_CONDINT_SCANNED  LIKE WPSTRUC-MODUS. " Kond.intervalle gescannt
*     g_no_bank_data     like wpstruc-modus. "= 'X', w. k. Bankverbindg


************************************************************************
* Tabellen- und Feldleistendeklaration.
************************************************************************

* Allgemeine Datenpufferung.
*-----------------------------------------------------------------------
* Tabelle für Pufferung von MARA-Daten.
DATA: BEGIN OF GT_MARA_BUF OCCURS 0.
        INCLUDE STRUCTURE MARA.
      DATA: END OF GT_MARA_BUF.

* Tabelle für Pufferung von MVKE-Daten.
DATA: BEGIN OF GT_MVKE_BUF OCCURS 0.
        INCLUDE STRUCTURE MVKE.
      DATA: END OF GT_MVKE_BUF.

* Tabelle zur Pufferung aller Artikelnummern, die einer bestimmten
* Warengruppe zugeordnet sind. MARA-Selektion.
DATA: BEGIN OF GT_MATNR_BUF OCCURS 1000,
        MATNR LIKE MARA-MATNR.
DATA: END OF GT_MATNR_BUF.

* Tabelle zur Pufferung von Artikelnummern. MARM-Selektion.
DATA: BEGIN OF GT_MATNR_MARM_BUF OCCURS 0,
        MATNR LIKE MARM-MATNR.
DATA: END OF GT_MATNR_MARM_BUF.

* Tabelle für datenreduzierte Pufferung von MARM-Daten.
*data: begin of gt_marm_buf occurs 0,
*        matnr like marm-matnr,
*        meinh like marm-meinh,
*        ean11 like marm-ean11,
*        numtp like marm-numtp.
*data: end of gt_marm_buf.

* Tabelle zur Aufnahme von Artikelnummern. MARM-Selektion.
DATA: BEGIN OF GT_MATNR OCCURS 0,
        MATNR LIKE MARM-MATNR.
DATA: END OF GT_MATNR.

* Tabelle für Pufferung von MARM-Daten.
*types: begin of marm_struc,
*        matnr like marm-matnr,
*        meinh like marm-meinh,
*        ean11 like marm-ean11,
*        numtp like marm-numtp.
*types: end of marm_struc.
*types: marm_type type hashed table of marm_struc
*                      with unique key matnr meinh.
*data : gt_marm_buff type marm_type with header line.

* Tabelle für Pufferung von MARM-Daten.
DATA: BEGIN OF GT_MARM_BUF OCCURS 0.
        INCLUDE STRUCTURE WPOS_SHORT_MARM.
      DATA: END OF GT_MARM_BUF.

* Tabelle für Pufferung von Verkaufsmengeneinheiten.
DATA: BEGIN OF GT_VRKME_BUF OCCURS 10,
        MATNR LIKE MARM-MATNR,
        MEINH LIKE MARM-MEINH.
DATA: END OF GT_VRKME_BUF.

* Statistiktabelle zur Pufferung von fertigen Statuspositionszeilen.
DATA: BEGIN OF GT_WDLSP_BUF OCCURS 10.
        INCLUDE STRUCTURE WDLSP.
      DATA: END OF GT_WDLSP_BUF.

* Globale Struktur für Änderungszeiger.
DATA: BEGIN OF GI_POINTER.
        INCLUDE STRUCTURE BDCP.
      DATA: END OF GI_POINTER.

* Struktur mit Zählvariablen für statistische Auswertung.
DATA: BEGIN OF GI_STAT_COUNTER.
        INCLUDE STRUCTURE WPSTATCNT.
      DATA: END OF GI_STAT_COUNTER.

* Tabelle für statistische Auswertung.
DATA: BEGIN OF GT_STATISTIK OCCURS 1.
        INCLUDE STRUCTURE WPLISTDATA.
      DATA: END OF GT_STATISTIK.

* WDLSP-Daten zur statistischen Auswertung.
DATA: BEGIN OF GT_STATISTIK_WDLSP OCCURS 1.
        INCLUDE STRUCTURE WPSTATWDLSP.
      DATA: END OF GT_STATISTIK_WDLSP.

* Allgemeiner Objektschlüssel für Speicherung in WDLSO.
DATA: BEGIN OF GI_OBJECT_KEY,
        MATNR LIKE MARM-MATNR,
        VRKME LIKE MARM-MEINH,
        EAN11 LIKE MARM-EAN11.
DATA: END OF GI_OBJECT_KEY.

* Tabelle zum Zwischenspeichern von IDOC-Kontrollsätzen bei Versendung
* über das Verteilungskundenmodell
DATA: BEGIN OF GT_EDIDC OCCURS 10.
        INCLUDE STRUCTURE EDIDC.
      DATA: END OF GT_EDIDC.

* Tabelle der reorganisierbaren Pointer-ID's.
DATA: BEGIN OF GT_REORG_POINTER OCCURS 0.
        INCLUDE STRUCTURE BDICPIDENT.
      DATA: END OF GT_REORG_POINTER.


* Performance: Filialcopy.
*-----------------------------------------------------------------------
* Pufferkonstanten für Filialcopy.
DATA: G_INDEPENDENCE_VKORG_BUF LIKE KNVV-VKORG,
      G_INDEPENDENCE_VTWEG_BUF LIKE KNVV-VTWEG,
      G_INDEPENDENCE_FILIA_BUF LIKE T001W-WERKS.

* Tabelle der filialabhängigen WLK2-Daten einer Filiale.
DATA: BEGIN OF GT_FILIA_WLK2_BUF OCCURS 1000,
        MATNR LIKE WLK2-MATNR.
DATA: END OF GT_FILIA_WLK2_BUF.

* Tabelle der filialunabhängigen IDOC-Typen pro Filiale
DATA: BEGIN OF GT_INDEPENDENCE_CHECK OCCURS 100.
        INCLUDE STRUCTURE WPINDEPEND.
      DATA: END OF GT_INDEPENDENCE_CHECK.

* Tabelle der IDOC-Nummern pro IDOC-Typ pro Filiale
DATA: BEGIN OF GT_MASTER_IDOCS OCCURS 100.
        INCLUDE STRUCTURE WPMASTERIDOC.
      DATA: END OF GT_MASTER_IDOCS.


* IDOC-Reduzierung.
*-----------------------------------------------------------------------
* Feldleiste mit Informationen, welche Objekte versendet werden sollen.
DATA: BEGIN OF GI_OBJECT_NOT_PROCESS,
        NPMAT LIKE TWPFI-NPMAT,
        NPFOA LIKE TWPFI-NPFOA,
        NPSET LIKE TWPFI-NPSET,
        NPMEC LIKE TWPFI-NPMEC,
        NPCUR LIKE TWPFI-NPCUR,
        NPTAX LIKE TWPFI-NPTAX,
        NPCUS LIKE TWPFI-NPCUS.
DATA: END OF GI_OBJECT_NOT_PROCESS.

* Tabelle der zu filternden Segmente.
DATA: BEGIN OF GT_FILTER_SEGS OCCURS 10.
        INCLUDE STRUCTURE BDI_REDUCT.
      DATA: END OF GT_FILTER_SEGS.


* Statusverfolgung.
*-----------------------------------------------------------------------

* Struktur der Kopfzeile für die Statusverfolgung.
DATA: BEGIN OF GI_STATUS_HEADER.
        INCLUDE STRUCTURE WDLS.
      DATA: END OF GI_STATUS_HEADER.

* Struktur der Positionszeile für die Statusverfolgung.
DATA: BEGIN OF GI_STATUS_POS.
        INCLUDE STRUCTURE WDLSP.
      DATA: END OF GI_STATUS_POS.

* Struktur des Headers für Fehlerprotokolle.
DATA: BEGIN OF GI_ERRORMSG_HEADER.
        INCLUDE STRUCTURE BALHDRI.
      DATA: END OF GI_ERRORMSG_HEADER.

* Struktur der Nachricht für Fehlerprotokolle.
DATA: BEGIN OF GI_MESSAGE.
        INCLUDE STRUCTURE BALMI.
      DATA: END OF GI_MESSAGE.


* IDOC-Daten.
*-----------------------------------------------------------------------
* Tabelle der IDOC-Daten
DATA: GT_IDOC_DATA TYPE SHORT_EDIDD.

DATA: BEGIN OF GT_IDOC_DATA_DUMMY OCCURS 0.
        INCLUDE STRUCTURE EDIDD.
      DATA: END OF GT_IDOC_DATA_DUMMY.

* Struktur zum Zwischenspeichern des Objektschlüssels.
DATA: BEGIN OF GI_KOMG.
        INCLUDE STRUCTURE KOMG.
      DATA: END OF GI_KOMG.

* Temporärtabelle für IDOC-Daten
DATA: BEGIN OF GT_IDOC_DATA_TEMP OCCURS 0.
        INCLUDE STRUCTURE EDIDD.
      DATA: END OF GT_IDOC_DATA_TEMP.

* Filialgruppen
*-----------------------------------------------------------------------

* Tabelle für Filialgruppen.
DATA: BEGIN OF GT_FILIA_GROUP OCCURS 100.
        INCLUDE STRUCTURE WPFILIAGRP.
      DATA: END OF GT_FILIA_GROUP.

* Temporär-Tabelle für Filialgruppen.
DATA: BEGIN OF GT_FILIA_GROUP_TEMP OCCURS 20.
        INCLUDE STRUCTURE GT_FILIA_GROUP.
      DATA: END OF GT_FILIA_GROUP_TEMP.

* Temporär-Tabelle für Filialsubgruppen.
DATA: BEGIN OF GT_FILIA_SUB_GROUP OCCURS 0.
        INCLUDE STRUCTURE GT_FILIA_GROUP.
      DATA: END OF GT_FILIA_SUB_GROUP.

* Temporärtabelle für Filialen mit Referenzvertriebswegkennzeichen.
DATA: BEGIN OF GT_FILIA OCCURS 5.
        INCLUDE STRUCTURE WPFILIA_COND.
      DATA: END OF GT_FILIA.

* Temporärtabelle für Vertriebswege und Filialen.
DATA: BEGIN OF GT_FILIA_2 OCCURS 5,
        VTWEG LIKE KOMG-VTWEG,
        FILIA LIKE KOMG-WERKS.
DATA: END OF GT_FILIA_2.

* Tabelle aller Arbeitstage innerhalb des Betrachtungszeitraums.
DATA: BEGIN OF GT_WORKDAYS OCCURS 50.
        INCLUDE STRUCTURE WPWORKDAYS.
      DATA: END OF GT_WORKDAYS.

* Struktur zum Merken der letzten Arbeitstagberechnung.
DATA: BEGIN OF GI_WORKDAYS,
        DATAB LIKE SY-DATUM,
        DATBI LIKE SY-DATUM,
        FABKL LIKE GT_FILIA_GROUP-FABKL.
DATA: END OF GI_WORKDAYS.

* Änderungspointer.
*-----------------------------------------------------------------------

* Tabelle für Änderungspointer.
DATA: BEGIN OF GT_POINTER OCCURS 200.
        INCLUDE STRUCTURE BDCP.
      DATA: END OF GT_POINTER.

* Tabelle für Konditionsänderungen
DATA: BEGIN OF GT_WIND OCCURS 0.
        INCLUDE STRUCTURE WINDVB.
      DATA: END OF GT_WIND.


* Warengruppen.
*-----------------------------------------------------------------------

* Tabelle der Warengruppendaten.
DATA: BEGIN OF GT_WRGP_DATA OCCURS 100,
        MATKL      LIKE WGHIER-CLAS1,
        WGBEZ      LIKE E1WPW02-BEZEICH,
        VERKNUEPFG LIKE WGHIER-CLAS1,
        HIERARCHIE LIKE WGHIER-HSTUFE.
DATA: END OF GT_WRGP_DATA.

* Tabelle der Warengruppensteuerkennzeiche.
DATA: BEGIN OF GT_WRGP_MWSKZ OCCURS 5.
        INCLUDE STRUCTURE TAXK.
      DATA: END OF GT_WRGP_MWSKZ.

* Filialabhängige Objekttabelle für Warengruppen.
DATA: BEGIN OF GT_OT1_F_WRGP OCCURS 50.
        INCLUDE STRUCTURE WPWRGP_OT1.
      DATA: END OF GT_OT1_F_WRGP.

* Filialunabhängige Objekttabelle für Warengruppen.
DATA: BEGIN OF GT_OT2_WRGP OCCURS 50.
        INCLUDE STRUCTURE WPWRGP_OT2.
      DATA: END OF GT_OT2_WRGP.

* Objekttabelle OT3 für Warengruppen.
DATA: BEGIN OF GT_OT3_WRGP OCCURS 50.
        INCLUDE STRUCTURE WPMGOT3.
      DATA: END OF GT_OT3_WRGP.


* Artikelstamm.
*-----------------------------------------------------------------------

* Tabelle zum Zwischenspeichern alter EAN's. " ### vielleicht nicht
*                                            "     mehr nötig
DATA: BEGIN OF GT_ARTDEL OCCURS 50.
        INCLUDE STRUCTURE WPDEL.
      DATA: END OF GT_ARTDEL.

" new structure used for GT_ARTDEL to substitute wpdel because of field extension of MARA-MATNR
DATA: GS_WPDEL_NEW TYPE ST_WPDEL_NEW.

*DATA: BEGIN OF gt_artdel OCCURS 50.
*        INCLUDE STRUCTURE gs_wpdel_new.
*DATA: END OF gt_artdel.

* Tabelle zum Zwischenspeichern zusätlicher EAN's.
DATA: BEGIN OF GT_ZUS_EAN_DEL OCCURS 50.
        INCLUDE STRUCTURE WPDEL.
      DATA: END OF GT_ZUS_EAN_DEL.

* Tabelle zum Zwischenspeichern alter EAN's (für Artstm und EAN-Ref.)
DATA: BEGIN OF GT_OLD_EAN OCCURS 50.
        INCLUDE STRUCTURE WPOLDEAN.
      DATA: END OF GT_OLD_EAN.

* Tabelle der Listungskonditionen.
DATA: BEGIN OF GT_LISTUNG OCCURS 25.
        INCLUDE STRUCTURE WPWLK1.
      DATA: END OF GT_LISTUNG.

* Tabelle für Bewirtschaftungszeiträume.
DATA: BEGIN OF GT_WLK2 OCCURS 1000.
        INCLUDE STRUCTURE WKWLK2.
      DATA: END OF GT_WLK2.

* MARA-Tabelle zum Lesen der Artikelstamm-Stammdaten.
DATA: BEGIN OF GT_IMARA OCCURS 10.
        INCLUDE STRUCTURE WPMARA.
      DATA: END OF GT_IMARA.

* MARA-Tabelle zum puffern der Artikelstamm-Stammdaten.
DATA: BEGIN OF GT_IMARA_BUF OCCURS 10.
        INCLUDE STRUCTURE WPMARA.
      DATA: END OF GT_IMARA_BUF.

* MARM-Tabelle zum Lesen der Artikelstamm-Stammdaten.
DATA: BEGIN OF GT_IMARM OCCURS 10.
        INCLUDE STRUCTURE WPMARM.
      DATA: END OF GT_IMARM.

* MARM-Tabelle zum puffern der Artikelstamm-Stammdaten.
DATA: BEGIN OF GT_IMARM_BUF OCCURS 10.
        INCLUDE STRUCTURE WPMARM.
      DATA: END OF GT_IMARM_BUF.

* MAKT-Tabelle zum Lesen der Artikelstamm-Stammdaten.  ### löschen
DATA: BEGIN OF GT_IMAKT OCCURS 10.
        INCLUDE STRUCTURE WPMAKT.
      DATA: END OF GT_IMAKT.

* MAKT-Tabelle zum puffern der Artikelstamm-Stammdaten.  ### löschen
DATA: BEGIN OF GT_IMAKT_BUF OCCURS 10.
        INCLUDE STRUCTURE WPMAKT.
      DATA: END OF GT_IMAKT_BUF.

* MAMT-Tabelle zum Lesen der Artikeltexte.
DATA: BEGIN OF GT_IMAMT OCCURS 20.
        INCLUDE STRUCTURE WPMAMT.
      DATA: END OF GT_IMAMT.

* MAMT-Tabelle zum puffern der Artikeltexte.
DATA: BEGIN OF GT_IMAMT_BUF OCCURS 20.
        INCLUDE STRUCTURE WPMAMT.
      DATA: END OF GT_IMAMT_BUF.

* Tabelle der Artikelkonditionen.
DATA: BEGIN OF GT_KOND_ART OCCURS 0.
        INCLUDE STRUCTURE SACO.
      DATA: END OF GT_KOND_ART.

* Tabelle zum puffern der Artikelkonditionen.
DATA: BEGIN OF GT_KOND_ART_BUF OCCURS 0.
        INCLUDE STRUCTURE WPOS_PRICES.
      DATA: END OF GT_KOND_ART_BUF.

* Tabelle der Artikelkonditionsstaffeln.
DATA: BEGIN OF GT_STAFF_ART OCCURS 0.
        INCLUDE STRUCTURE CONDSCALE.
      DATA: END OF GT_STAFF_ART.

* Tabelle zum puffern der Artikelkonditionsstaffeln.
DATA: BEGIN OF GT_STAFF_ART_BUF OCCURS 0.
        INCLUDE STRUCTURE WPOS_CONDSCALE.
      DATA: END OF GT_STAFF_ART_BUF.

* Tabelle der Artikelsteuerkennzeichen.
DATA: BEGIN OF GT_ARTSTEU OCCURS 0.
        INCLUDE STRUCTURE TAXK.
      DATA: END OF GT_ARTSTEU.

* Tabelle zum puffern der Artikelsteuerkennzeichen.
DATA: BEGIN OF GT_ARTSTEU_BUF OCCURS 0.
        INCLUDE STRUCTURE WPOS_TAXES.
      DATA: END OF GT_ARTSTEU_BUF.

* Tabelle zum puffern von Artikelnummer aus Tabelle A071.
DATA: BEGIN OF GT_A071_MATNR OCCURS 0.
        INCLUDE STRUCTURE PRE03.
      DATA: END OF GT_A071_MATNR.

* Tabelle der SACO-Informationen zum Naturalrabatt des Artikels.
DATA: BEGIN OF GT_NATRAB_SACO OCCURS 1.
        INCLUDE STRUCTURE SACO.
      DATA: END OF GT_NATRAB_SACO.

* Tabelle der Naturalrabattkonditionen.
DATA: BEGIN OF GT_KONDN OCCURS 1.
        INCLUDE STRUCTURE KONDN.
      DATA: END OF GT_KONDN.

* Tabelle der Naturalrabattstaffeln.
DATA: BEGIN OF GT_KONDNS OCCURS 1.
        INCLUDE STRUCTURE KONDNS.
      DATA: END OF GT_KONDNS.

* Tabelle zum speichern der Haupt-EAN-Veränderungen der
* Naturalrabattstaffeln.
DATA: BEGIN OF GT_NATRAB_EAN OCCURS 30,
        DATAB LIKE SY-DATUM,
        MATNR LIKE MARM-MATNR,
        MEINH LIKE MARM-MEINH,
        EAN11 LIKE MARM-EAN11.
DATA: END OF GT_NATRAB_EAN.


* Tabelle der Artikelstamm-Stammdaten benötigten Tabellenfelder.
DATA: BEGIN OF GT_FIELD_TAB OCCURS 6.
        INCLUDE STRUCTURE WPFTAB.
      DATA: END OF GT_FIELD_TAB.

* Tabelle der WLK2-Daten.
DATA: BEGIN OF GT_WLK2DAT OCCURS 1.
        INCLUDE STRUCTURE WPWLK2.
      DATA: END OF GT_WLK2DAT.

* Tabelle der TVMS-Daten (Verkaufssperre).
DATA: BEGIN OF GT_TVMS OCCURS 1,
        DATUM LIKE SY-DATUM,
        SPVBC LIKE TVMS-SPVBC.
DATA: END OF GT_TVMS.

* Tabelle der T134-Daten (Preis drucken, Artikel anzeigen).
DATA: BEGIN OF GT_T134 OCCURS 1,
        DATUM LIKE SY-DATUM,
        PRDRU LIKE T134-PRDRU,
        ARANZ LIKE T134-ARANZ,
        WMAKG LIKE T134-WMAKG.
DATA: END OF GT_T134.

* Tabelle der WRF6-Daten (Mehrwertsteuerflag)
DATA: BEGIN OF GT_WRF6 OCCURS 5,
        DATUM LIKE SY-DATUM,
        PRIMW LIKE WRF6-PRIMW.
DATA: END OF GT_WRF6.

* Organisationstabelle für Artikel.
DATA: BEGIN OF GT_ORGTAB_ARTSTM OCCURS 30,
        DATUM   LIKE SY-DATUM,
        CHANGE,
        MARA,
        MARM,
        MAKT,
        MAMT,
        WLK2,
        KOND,
        STEUERN,
        NUMMERN.
DATA: END OF GT_ORGTAB_ARTSTM.

* Tabelle für Verkaufsmengeneinheiten.
DATA: BEGIN OF GT_VRKME OCCURS 0.
        INCLUDE STRUCTURE GT_MARM_BUF.
      DATA: END OF GT_VRKME.

* Tabelle für Gültigkeitsstände einer Konditionsnummer (Nur Beginndatum)
DATA: BEGIN OF GT_DATAB OCCURS 10.
        INCLUDE STRUCTURE WPDATE.
      DATA: END OF GT_DATAB.

* Tabelle zum Speichern von Konditionsarten einer Filiale.
DATA: BEGIN OF GT_KONDART OCCURS 30.
        INCLUDE STRUCTURE WPKONDART.
      DATA: END OF GT_KONDART.

* Tabelle der möglichen Konditionsarten für alle Filialen.
DATA: BEGIN OF GT_KONDART_GESAMT OCCURS 0.
        INCLUDE STRUCTURE TWPEK.
      DATA: END OF GT_KONDART_GESAMT.

* Tabelle zum Speichern von Konditionsarten mit Zusatzsflag für
* MERGE-Baustein.
DATA: BEGIN OF GT_KONDART_FLAG OCCURS 10.
        INCLUDE STRUCTURE WPKARTFLAG.
      DATA: END OF GT_KONDART_FLAG.

* Tabelle zum Speichern von Konditionsintervallen für Merge-FB.
DATA: BEGIN OF GT_PERIODS OCCURS 0.
        INCLUDE STRUCTURE WPPERIOD.
      DATA: END OF GT_PERIODS.

* Tabelle zum Speichern von Konditionsintervallen aus FB
* WWS_CONDITION_INTERVALS_GET.
DATA: BEGIN OF GT_CONDINT OCCURS 0.
        INCLUDE STRUCTURE WCONDINT.
        DATA:   KVEWE LIKE KONH-KVEWE,
        KAPPL LIKE KONH-KAPPL.
DATA: END OF GT_CONDINT.

* Filialabhängige Objekttabelle für Artikelstamm.
DATA: BEGIN OF GT_OT1_F_ARTSTM OCCURS 200.
        INCLUDE STRUCTURE WPARTSTM.
      DATA: END OF GT_OT1_F_ARTSTM.

* Filialunabhängige Objekttabelle für Artikelstamm.
DATA: BEGIN OF GT_OT2_ARTSTM OCCURS 200.
        INCLUDE STRUCTURE WPAOT2.
      DATA: END OF GT_OT2_ARTSTM.

* Objekttabelle OT3 für Artikelstamm.
DATA: BEGIN OF GT_OT3_ARTSTM OCCURS 200.
        INCLUDE STRUCTURE WPAOT3.
      DATA: END OF GT_OT3_ARTSTM.

* Puffertabelle für Intervallscanner.
DATA: BEGIN OF GT_OT3_ARTSTM_BUF OCCURS 0.
        INCLUDE STRUCTURE WPAOT3.
      DATA: END OF GT_OT3_ARTSTM_BUF.

* Objekttabelle für Sammelartikel.
DATA: BEGIN OF GT_OT3_PMATA OCCURS 10.
        INCLUDE STRUCTURE WPAOT3.
      DATA: END OF GT_OT3_PMATA.

* Objekttabelle OT3 für Artikelstamm.
DATA: BEGIN OF GT_PMATA_BUF OCCURS 10,
        PMATA LIKE MARA-MATNR,
        MATNR LIKE MARA-MATNR.
DATA: END OF GT_PMATA_BUF.

* Puffer für Kurztext-ID's.
DATA: BEGIN OF GT_MTXID_BUF OCCURS 1,
        MTXID LIKE MAMT-MTXID.
DATA: END OF GT_MTXID_BUF.

* Puffer für WLK2-Daten auf Vertriebslinienebene.
DATA: BEGIN OF GT_WLK2_VL_BUF OCCURS 1.
        INCLUDE STRUCTURE WLK2.
      DATA: END OF GT_WLK2_VL_BUF.

* Puffer für WLK2-Daten auf Konzernebene.
DATA: BEGIN OF GT_WLK2_KONZERN_BUF OCCURS 1.
        INCLUDE STRUCTURE WLK2.
      DATA: END OF GT_WLK2_KONZERN_BUF.

DATA: BEGIN OF GT_ASORT_FILIA OCCURS 0,
        ASORT LIKE WRSZ-ASORT,
        LOCNR LIKE WRSZ-LOCNR,
        REF   LIKE WPSTRUC-MODUS.
DATA: END OF GT_ASORT_FILIA.

DATA: BEGIN OF GT_FILIA_MATNR_BUF OCCURS 0,
        LOCNR LIKE WRSZ-LOCNR,
        MATNR LIKE MARA-MATNR.
DATA: END OF GT_FILIA_MATNR_BUF.


* EAN-Referenzen.
*-----------------------------------------------------------------------

* Tabelle zum merken von EAN-Änderungen zusätzlicher EAN's.
DATA: BEGIN OF GT_EAN_CHANGE OCCURS 0.
        INCLUDE STRUCTURE WPEANCHG.
      DATA: END OF GT_EAN_CHANGE.

* Organisationstabelle für EAN-Referenzen.
DATA: BEGIN OF GT_ORGTAB_EAN OCCURS 30,
        DATUM     LIKE SY-DATUM,
        CHANGE,
        MARM,
        MEAN,
        MEAN_CNT  TYPE I,
        VERSENDEN.
DATA: END OF GT_ORGTAB_EAN.

* MEAN-Tabelle zum Lesen der EAN-Referenzen.
DATA: BEGIN OF GT_IMEAN OCCURS 10.
        INCLUDE STRUCTURE WPMEAN.
      DATA: END OF GT_IMEAN.

* MEAN-Tabelle zum puffern der EAN-Referenzen.
DATA: BEGIN OF GT_IMEAN_BUF OCCURS 50.
        INCLUDE STRUCTURE WPMEAN.
      DATA: END OF GT_IMEAN_BUF.

* Filialabhängige Objekttabelle für EAN-Referenzen.
DATA: BEGIN OF GT_OT1_F_EAN OCCURS 200.
        INCLUDE STRUCTURE WPARTSTM.
      DATA: END OF GT_OT1_F_EAN.

* Filialunabhängige Objekttabelle für EAN-Referenzen.
DATA: BEGIN OF GT_OT2_EAN OCCURS 200.
        INCLUDE STRUCTURE WPAOT2_ALT.
      DATA: END OF GT_OT2_EAN.

* Objekttabelle OT3 für EAN-Referenzen.
DATA: BEGIN OF GT_OT3_EAN OCCURS 200.
        INCLUDE STRUCTURE WPAOT3.
      DATA: END OF GT_OT3_EAN.


* Set-Zuordnungen.
*-----------------------------------------------------------------------

* Tabelle zum Zwischenspeichern alter EAN's.
DATA: BEGIN OF GT_OLD_EAN_SET OCCURS 50.
        INCLUDE STRUCTURE WPOLDEAN.
      DATA: END OF GT_OLD_EAN_SET.

* Komponententabelle zum Lesen der Set-Komponenten.
DATA: BEGIN OF GT_SET_KOMP OCCURS 5.
        INCLUDE STRUCTURE STPOB.
      DATA: END OF GT_SET_KOMP.

* Tabelle zum speichern der Haupt-EAN-Veränderungen der Set-Komponenten.
DATA: BEGIN OF GT_SET_KOMP_EAN OCCURS 30,
        DATAB LIKE SY-DATUM,
        MATNR LIKE MARM-MATNR,
        MEINS LIKE MARM-MEINH,
        EAN11 LIKE MARM-EAN11,
        NUMTP LIKE MARM-NUMTP.
DATA: END OF GT_SET_KOMP_EAN.

* Organisationstabelle für Set-Artikel.
DATA: BEGIN OF GT_ORGTAB_SETS OCCURS 30,
        DATUM  LIKE SY-DATUM,
        CHANGE,
        MARA,
        MARM,
        STPO,
        KOND.                          " keine Unterstützung zu Rel. 3.0
DATA: END OF GT_ORGTAB_SETS.

* Filialabhängige Objekttabelle für Set-Zuordnungen.
DATA: BEGIN OF GT_OT1_F_SETS OCCURS 200.
        INCLUDE STRUCTURE WPARTSTM.
      DATA: END OF GT_OT1_F_SETS.

* Filialunabhängige Objekttabelle für Set-Zuordnungen.
DATA: BEGIN OF GT_OT2_SETS OCCURS 200.
        INCLUDE STRUCTURE WPAOT2_ALT.
      DATA: END OF GT_OT2_SETS.

* Objekttabelle OT3 für Set-Artikel.
DATA: BEGIN OF GT_OT3_SETS OCCURS 200.
        INCLUDE STRUCTURE WPAOT3.
      DATA: END OF GT_OT3_SETS.

* Tabelle zum zwischenspeichern aller Artikelnummern von Setzuordng.
DATA: BEGIN OF GT_SETS_BUF OCCURS 500,
        MATNR LIKE MARA-MATNR,
        MATKL LIKE MARA-MATKL.
DATA: END OF GT_SETS_BUF.


* Nachzugsartikel.
*-----------------------------------------------------------------------

* Tabelle zum Zwischenspeichern alter EAN's.
DATA: BEGIN OF GT_OLD_EAN_NART OCCURS 50.
        INCLUDE STRUCTURE WPOLDEAN.
      DATA: END OF GT_OLD_EAN_NART.

* Komponententabelle zum Lesen der Nachzugsartikel-Komponenten.
DATA: BEGIN OF GT_NART_KOMP OCCURS 5.
        INCLUDE STRUCTURE STPOB.
      DATA: END OF GT_NART_KOMP.

* Tabelle zum speichern der Haupt-EAN-Veränderungen der
* Nachzugsartikel-Komponenten.
DATA: BEGIN OF GT_NART_KOMP_EAN OCCURS 30,
        DATAB LIKE SY-DATUM,
        MATNR LIKE MARM-MATNR,
        MEINS LIKE MARM-MEINH,
        EAN11 LIKE MARM-EAN11,
        NUMTP LIKE MARM-NUMTP.
DATA: END OF GT_NART_KOMP_EAN.

* Organisationstabelle für Nachzugsartikel.
DATA: BEGIN OF GT_ORGTAB_NART OCCURS 30,
        DATUM  LIKE SY-DATUM,
        CHANGE,
        MARA,
        MARM,
        STPO.
DATA: END OF GT_ORGTAB_NART.

* Filialabhängige Objekttabelle für Nachzugsartikel.
DATA: BEGIN OF GT_OT1_F_NART OCCURS 200.
        INCLUDE STRUCTURE WPARTSTM.
      DATA: END OF GT_OT1_F_NART.

* Filialunabhängige Objekttabelle für Nachzugsartikel.
DATA: BEGIN OF GT_OT2_NART OCCURS 200.
        INCLUDE STRUCTURE WPAOT2_ALT.
      DATA: END OF GT_OT2_NART.

* Objekttabelle OT3 für Nachzugsartikel.
DATA: BEGIN OF GT_OT3_NART OCCURS 200.
        INCLUDE STRUCTURE WPAOT3.
      DATA: END OF GT_OT3_NART.

* Tabelle zum zwischenspeichern aller Artikelnummern von Nachzugsart.
DATA: BEGIN OF GT_NART_BUF OCCURS 500,
        MATNR LIKE MARA-MATNR,
        MATKL LIKE MARA-MATKL.
DATA: END OF GT_NART_BUF.


* Wechselkurse.
*-----------------------------------------------------------------------

* Tabelle der Wechselkursdaten.
DATA: BEGIN OF GT_WKURS_DATA OCCURS 50.
        INCLUDE STRUCTURE WPEXCHG.
      DATA: END OF GT_WKURS_DATA.

* Organisationstabelle für Wechselkurse.
DATA: BEGIN OF GT_ORGTAB_WKURS OCCURS 30,
        DATUM  LIKE SY-DATUM,
        CHANGE.
DATA: END OF GT_ORGTAB_WKURS.


* Steuern.
*-----------------------------------------------------------------------

* Tabelle der Steuern.
DATA: BEGIN OF GT_STEUERN_DATA OCCURS 50.
        INCLUDE STRUCTURE WPTAX.
      DATA: END OF GT_STEUERN_DATA.


* Personendaten.
*-----------------------------------------------------------------------

* Tabelle der Personendaten.
DATA: BEGIN OF GT_PERS_DATA OCCURS 100.
        INCLUDE STRUCTURE WPPDATA.
      DATA: END OF GT_PERS_DATA.

* Tabelle der zugehörigen Kreditkarteninformationen.
DATA: BEGIN OF GT_CREDIT_CARD_DATA OCCURS 300.
        INCLUDE STRUCTURE WPCREDCARD.
      DATA: END OF GT_CREDIT_CARD_DATA.

* Tabelle der zugehörigen Bankverbindungen.
DATA: BEGIN OF GT_BANK_DATA OCCURS 300.
        INCLUDE STRUCTURE WPBANKDATA.
      DATA: END OF GT_BANK_DATA.

* Kreditkontrollbereichsabhängige Objekttabelle für Personendaten.
DATA: BEGIN OF GT_OT1_K_PERS OCCURS 100.
        INCLUDE STRUCTURE WPPDOT1.
      DATA: END OF GT_OT1_K_PERS.

* Filialunabhängige Objekttabelle für Personendaten.
DATA: BEGIN OF GT_OT2_PERS OCCURS 100.
        INCLUDE STRUCTURE WPPDOT3.
      DATA: END OF GT_OT2_PERS.

* Objekttabelle OT3 für Personendaten.
DATA: BEGIN OF GT_OT3_PERS OCCURS 100.
        INCLUDE STRUCTURE WPPDOT3.
      DATA: END OF GT_OT3_PERS.

************************************************************************
* Datendeklaration für Parallelisierung.
* Variablen für die Aufbereitung einer Filialgruppe.
DATA: BEGIN OF GT_TASK_VARIABLES OCCURS 0,
        TASKNAME LIKE WPSTRUC-COUNTER6,
        NUMBER   LIKE GT_FILIA_GROUP-GROUP,
        MESTYPE  LIKE EDIMSG-MESTYP.
DATA: END OF GT_TASK_VARIABLES.

* Variablen für die Aufbereitung einer Filialuntergruppe.
DATA: BEGIN OF GT_TASK_VARIABLES_SUB OCCURS 0.
        INCLUDE STRUCTURE GT_TASK_VARIABLES.
      DATA: END OF GT_TASK_VARIABLES_SUB.

* Variablen für die Aufbereitung einer Filialgruppe.
DATA: BEGIN OF GT_TASK_VARIABLES_GRP OCCURS 0.
        INCLUDE STRUCTURE GT_TASK_VARIABLES.
      DATA: END OF GT_TASK_VARIABLES_GRP.

* Tabelle der fehlerhaften parallelen Tasks.
DATA: BEGIN OF GT_ERROR_TASKS OCCURS 0,
        TASKNAME LIKE WPSTRUC-COUNTER6.
DATA: END OF GT_ERROR_TASKS.

* Tabelle der fehlerhaften parallelen Tasks.
DATA: BEGIN OF GT_ERROR_TASKS_SUB OCCURS 0,
        TASKNAME LIKE WPSTRUC-COUNTER6.
DATA: END OF GT_ERROR_TASKS_SUB.

* Tabelle der fehlerhaften parallelen Tasks.
DATA: BEGIN OF GT_ERROR_TASKS_CND OCCURS 0,
        TASKNAME LIKE WPSTRUC-COUNTER6.
DATA: END OF GT_ERROR_TASKS_CND.

* Tabelle der fehlerhaften parallelen Tasks.
DATA: BEGIN OF GT_ERROR_TASKS_GRP OCCURS 0,
        TASKNAME LIKE WPSTRUC-COUNTER6.
DATA: END OF GT_ERROR_TASKS_GRP.

* Tabelle der fehlerhaften parallelen Tasks.
DATA: BEGIN OF GT_RFCDEST OCCURS 0.
        INCLUDE STRUCTURE WPRFCDEST.
      DATA: END OF GT_RFCDEST.

* Tabelle der fehlerhaften parallelen Tasks für Filialgruppen.
DATA: BEGIN OF GT_RFCDEST_GRP OCCURS 0.
        INCLUDE STRUCTURE WPRFCDEST.
      DATA: END OF GT_RFCDEST_GRP.

* Tabelle der fehlerhaften parallelen Tasks für Konditionsanalyse.
DATA: BEGIN OF GT_RFCDEST_CND OCCURS 0.
        INCLUDE STRUCTURE WPRFCDEST.
      DATA: END OF GT_RFCDEST_CND.

* Tabelle der fehlerhaften parallelen Tasks für Filialuntergruppen.
DATA: BEGIN OF GT_RFCDEST_SUB OCCURS 0.
        INCLUDE STRUCTURE WPRFCDEST.
      DATA: END OF GT_RFCDEST_SUB.

* Tabelle zum identifizieren der gestarteten Tasks.
DATA: BEGIN OF GT_RFC_INDICATOR OCCURS 0,
        TASKNAME LIKE WPSTRUC-COUNTER6,
        RFCDEST  LIKE WPRFCDEST-RFCDEST.
DATA: END OF GT_RFC_INDICATOR.

* Tabelle zum identifizieren der gestarteten Tasks.
DATA: BEGIN OF GT_RFC_INDICATOR_CND OCCURS 0.
        INCLUDE STRUCTURE GT_RFC_INDICATOR.
      DATA: END OF GT_RFC_INDICATOR_CND.

* Tabelle zum identifizieren der gestarteten Tasks.
DATA: BEGIN OF GT_RFC_INDICATOR_SUB OCCURS 0.
        INCLUDE STRUCTURE GT_RFC_INDICATOR.
      DATA: END OF GT_RFC_INDICATOR_SUB.

* Tabelle zum identifizieren der gestarteten Tasks.
DATA: BEGIN OF GT_RFC_INDICATOR_GRP OCCURS 0.
        INCLUDE STRUCTURE GT_RFC_INDICATOR.
      DATA: END OF GT_RFC_INDICATOR_GRP.

* Tabelle zum Zwischenspeichern von IDOC-Kontrollsätzen bei Versendung
* über das Verteilungskundenmodell
DATA: BEGIN OF GT_EDIDC_PARALLEL OCCURS 10.
        INCLUDE STRUCTURE EDIDC.
      DATA: END OF GT_EDIDC_PARALLEL.

* Tabelle für erzeugte Status-Positionszeilen.
DATA: BEGIN OF GT_WDLSP_PARALLEL OCCURS 0.
        INCLUDE STRUCTURE WDLSP.
      DATA: END OF GT_WDLSP_PARALLEL.

* Tabelle für erzeugte nachzubereitende Objeke.
DATA: BEGIN OF GT_WDLSO_PARALLEL OCCURS 0.
        INCLUDE STRUCTURE WPWDLSOPAR.
      DATA: END OF GT_WDLSO_PARALLEL.

* Feldleiste für Filialunabhängigkeit.
DATA: BEGIN OF GI_INDEPENDENCE_CHECK.
        INCLUDE STRUCTURE GT_INDEPENDENCE_CHECK.
      DATA: END OF GI_INDEPENDENCE_CHECK.

* Feldleiste für Statistikinformationen.
DATA: BEGIN OF GI_STAT_COUNTER2.
        INCLUDE STRUCTURE GI_STAT_COUNTER.
      DATA: END OF GI_STAT_COUNTER2.

DATA: G_SND_JOBS        LIKE WPSTRUC-COUNTER6,
      G_PARALLEL        LIKE WPSTRUC-PARALLEL,
      G_SND_JOBS_SUB    LIKE WPSTRUC-COUNTER6,
      G_SND_JOBS_SUB2   LIKE WPSTRUC-COUNTER6,
      G_SND_JOBS_CND    LIKE WPSTRUC-COUNTER6,
      G_JOBS_GESAMT_SUB LIKE WPSTRUC-COUNTER6,
      G_JOBS_GESAMT_GRP LIKE WPSTRUC-COUNTER6,
      G_JOBS_GESAMT     LIKE WPSTRUC-COUNTER6,
      G_RCV_JOBS        LIKE WPSTRUC-COUNTER6,
      G_RCV_JOBS_SUB    LIKE WPSTRUC-COUNTER6,
      G_RCV_JOBS_SUB2   LIKE WPSTRUC-COUNTER6,
      G_RCV_JOBS_CND    LIKE WPSTRUC-COUNTER6,
      G_PT_REORG        LIKE WPSTRUC-MODUS,
      G_CURRENT_DOCTYPE LIKE EDIDC-DOCTYP,
      G_FILIA           LIKE T001W-WERKS.


* Aktionsrabatte.
*-----------------------------------------------------------------------

* Tabelle für Aktionsköpfe.
DATA: BEGIN OF GT_PROMO OCCURS 0.
        INCLUDE STRUCTURE WPROMO.
      DATA: END OF GT_PROMO.

* Filialabhängige Objekttabelle für Aktionsrabatte.
DATA: BEGIN OF GT_OT1_F_PROMREB OCCURS 0.
        INCLUDE STRUCTURE WPPROMREB1.
      DATA: END OF GT_OT1_F_PROMREB.

* Filialunabhängige Objekttabelle für Aktionsrabatte.
DATA: BEGIN OF GT_OT2_PROMREB OCCURS 0.
        INCLUDE STRUCTURE WPPROMREB2.
      DATA: END OF GT_OT2_PROMREB.

* Objekttabelle OT3 für Aktionsrabatte.
DATA: BEGIN OF GT_OT3_PROMREB OCCURS 0.
        INCLUDE STRUCTURE WPPROMREB3.
      DATA: END OF GT_OT3_PROMREB.
*{   INSERT         XB4K001679                                        1
* WRF_POSOUT
DATA: G_BADI_INSTANCE   TYPE REF TO IF_EX_WPOS_X_POSOUT001_I,
      G_BADI_ACTIVE_IMP TYPE BOOLEAN.
* WRF_POSOUT
*}   INSERT


* WRSZ-Intervallscan
*-----------------------------------------------------------------------

* Pufferung: Allgemeine Retail-Einstellungen.
DATA: GS_TWPA TYPE TWPA.

* Referenz für BAdI-Instanz.
DATA: GV_WPOS_TIMEDEP_WRSZ TYPE REF TO IF_EX_WPOS_TIMEDEP_WRSZ_I.

* Global variables to control MARA and MARC buffer refresh
DATA GV_MARA_BUFFER_REFRESH      TYPE ABAP_BOOL VALUE ABAP_TRUE.
DATA GV_MARC_BUFFER_REFRESH      TYPE ABAP_BOOL VALUE ABAP_TRUE.

* Global variable to check if time_range_get and workdays_get have already been called
DATA GV_TIME_RG_WRKDAYS_GET_FLAG TYPE ABAP_BOOL VALUE ABAP_FALSE.

* Global variable which signals if there are any articles at all
DATA GV_NO_ARTICLES_FOUND        TYPE ABAP_BOOL VALUE ABAP_FALSE.

* Global type
TYPES TTH_ARTICLES TYPE HASHED TABLE OF MATNR WITH UNIQUE KEY TABLE_LINE.

************************************************************************
*Event handling regarding IDoc sizing
LOAD-OF-PROGRAM.
*** Start of Changes by Suri : 27.11.2019
*** For Idoc Segments Restrictions to 5000 to 1000
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WP_PLU'
*    IMPORTING
*      max_idoc_size = c_max_idoc_plu.
*
*
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WP_EAN'
*    IMPORTING
*      max_idoc_size = c_max_idoc_ean.
*
*
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WPDNAC'
*    IMPORTING
*      max_idoc_size = c_max_idoc_nac.
*  .
*
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WP_PER'
*    IMPORTING
*      max_idoc_size = c_max_idoc_per.
*
*
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WPDSET'
*    IMPORTING
*      max_idoc_size = c_max_idoc_set.
*
*
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WPDWGR'
*    IMPORTING
*      max_idoc_size = c_max_idoc_wgr.
*
*
*  CALL FUNCTION 'POS_IDOC_SIZE_SETTING'
*    EXPORTING
*      mestyp        = 'WPDCUR'
*    IMPORTING
*      max_idoc_size = c_max_idoc_cur.
  C_MAX_IDOC_CUR = C_MAX_IDOC_WGR = C_MAX_IDOC_SET = C_MAX_IDOC_PER = C_MAX_IDOC_NAC = C_MAX_IDOC_EAN = C_MAX_IDOC_PLU = '1000'.

*** End of Changes by Suri : 27.11.2019
*** For Idoc Segments Restrictions to 5000 to 1000

*** New structures and table types for implementing sales conditions multi access in WPMU

  DATA: GT_OT3_ARTSTM_COLLECT TYPE TT_WPAOT3.
  DATA: GT_LIST_COND_COLLECT  TYPE TT_LIST_COND.
  DATA: GV_IS_FIRST_ARTICLE_PACKAGE TYPE ABAP_BOOL VALUE ABAP_TRUE.
  DATA: GV_PROCESSED_ART_LINES TYPE I VALUE 0.

  DATA: GV_VTWEG LIKE WPSTRUC-VTWEG.
