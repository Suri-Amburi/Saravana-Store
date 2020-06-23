*--- Datenstrukturen für programmierte Hilfe ---------------------------

DATA:  H_BKLAS              LIKE MBEW-BKLAS.

DATA: KZALL         LIKE SY-MARKY,
      KZBEW_WERK    LIKE SY-MARKY.

* Spezielle Eingabehilfe für gültige Sparten --------------------------
* - Vertriebsbereiche zum Material:
DATA: BEGIN OF H_VKO_VTW OCCURS 10,
        VKORG LIKE MVKE-VKORG,
        VTWEG LIKE MVKE-VTWEG,
     END OF H_VKO_VTW.
* - Zulässige Sparten zum Material
DATA: BEGIN OF H_SPA OCCURS 10,
        SPART LIKE TSPA-SPART,
        VTEXT LIKE TSPAT-VTEXT,
     END OF H_SPA.

* Übergabeparameter für zentralen F4-Funktionsbaustein
DATA: BEGIN OF H_FIELDS OCCURS 10.       "zur Übergabe der Feldnamen
        INCLUDE STRUCTURE HELP_VALUE.
DATA: END OF H_FIELDS.

DATA: BEGIN OF H_VALUES OCCURS 10,       "zur Übergabe der Werte
        VALUE(60),
      END OF H_VALUES.

DATA: BEGIN OF DYNPFIELDS OCCURS 0. "Hilfsstruktur zum auslesen des akt.
       INCLUDE STRUCTURE DYNPREAD. "Feldwertes vom Dynpro bei >F4<
DATA: END OF   DYNPFIELDS.

DATA: SY_REPID LIKE SY-REPID,
      SY_DYNNR LIKE SY-DYNNR.

DATA: HELP_FIELD LIKE HELP_INFO-FIELDNAME,       "Name Tabellenfeld
      HELP_TAB   LIKE HELP_INFO-TABNAME,         "Name DDIC-Tabelle
      DISPLAY.                                   "F4 nur Anzeige
