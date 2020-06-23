*&---------------------------------------------------------------------*
*&      Module  VW_INITIALISIERUNG  OUTPUT
*&---------------------------------------------------------------------*
*       Initialisieren Daten für Verbrauchswerte
*----------------------------------------------------------------------*
MODULE VW_INITIALISIERUNG OUTPUT.

* AHE: 10.09.97 - A (4.0A) HW 89207
* Spezialfeldauswahl für Felder MARC-PERKZ und MARC-PERIV, da sie
* in der allgemeinen Feldauswahl auf Eingabe geschaltet werden.
* Dies gilt für alle Bilder, außer dem Verbrauchswertebild. Hier
* dürfen die Felder nur auf Ausgabe stehen.

  LOOP AT SCREEN.
    IF SCREEN-GROUP3 = '003'.          " MARC-PERKZ und MARC-PERIV
      SCREEN-OUTPUT    = 1.
      SCREEN-INPUT     = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
* AHE: 10.09.97 - E

* erster Aufruf
  IF RMMZU-VWINIT IS INITIAL.
*   Initflag setzen
    RMMZU-VWINIT = X.
    CLEAR: VW_ERSTE_ZEILE.

*---- Beim ersten Aufruf: Tabelle T438A lesen, damit der richtige
*---- Verbrauch (ungeplant/gesamt) vorgeschlagen wird
    CALL FUNCTION 'T438A_SINGLE_READ'
         EXPORTING
              KZRFB       = KZRFB
              T438A_DISMM = MARC-DISMM
         IMPORTING
              WT438A      = T438A
         EXCEPTIONS
              NOT_FOUND   = 01.

    KZVERB = T438A-PROVB.
    MOVE TEXT-065 TO RM03M-VBTX2.

  ENDIF.

  PERKZ = MARC-PERKZ.  " Zur Aufbereitung der Periodenanzeige
  PERIV = MARC-PERIV.  " auf Subscreen notwendig ! ! (AHE: 31.05.95)

* AHE: 24.01.99 - A (4.6a)
* Damit man auch, wenn keine VB-Werte vorhanden sind (Bsp.: Anlegen
* Material), direkt eine Blätterleiste im TC hat, muß man dem TC
* mindestens 2 Zeileneinträge vorgaukeln, am besten aber so viele, wie
* im TC angezeigt werden (11), da sonst der TC Felder mit Werten
* anzeigt, die nicht belegt sind und nach mehrmaligem Blättern
* auch wieder korrekt angezeigt werden.
  DESCRIBE TABLE GES_VERBTAB LINES VW_LINES.
  IF VW_LINES IS INITIAL.
    DESCRIBE TABLE UNG_VERBTAB LINES VW_LINES.
  ENDIF.
  IF VW_LINES IS INITIAL.
    VW_LINES = 11.
    CLEAR T009B_ERROR.
    NO_T009B_ABEND = X.
    RM03M-ANTEI = 1.                   " wegen Fließkommaarithmetik
    DO VW_LINES TIMES.
      PERFORM VERBRAUCH_ERWEITERN.
    ENDDO.
    CLEAR NO_T009B_ABEND.
  ENDIF.
* AHE: 24.01.99 - E

* ------- Ermitteln aktuelle Anzahl Verbrauchseinträge
* ------- Texte für Ges. Verbrauch oder Ungepl. Verbrauch setzen
  IF KZVERB = 'U'.
    DESCRIBE TABLE UNG_VERBTAB LINES VW_LINES.
    MOVE TEXT-063 TO RM03M-VBTX1.
* AHE: 30.01.97 - A
    LOOP AT SCREEN.
*     if screen-group1 = '001'.  mk/4.0A
      IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
*     Button für ungepl. Verbrauch deaktivieren
*       SCREEN-INPUT  = 0.    " schaltet auf "nur Ausgabe"
        SCREEN-OUTPUT = 1.             " schaltet auf "nur Ausgabe"
        SCREEN-ACTIVE = 0.             " schaltet auf "unsichtbar"
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
* AHE: 30.01.97 - E
  ELSE.
    DESCRIBE TABLE GES_VERBTAB LINES VW_LINES.
    MOVE TEXT-064 TO RM03M-VBTX1.
* AHE: 30.01.97 - A
    LOOP AT SCREEN.
*     if screen-group1 = '002'.   mk/4.0A
      IF SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002'.
*     Button für Gesamtverbrauch deaktivieren
*       SCREEN-INPUT  = 0.    " schaltet auf "nur Ausgabe"
        SCREEN-OUTPUT = 1.             " schaltet auf "nur Ausgabe"
        SCREEN-ACTIVE = 0.             " schaltet auf "unsichtbar"
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
* AHE: 30.01.97 - E
  ENDIF.

"{ Begin ENHO AD_MPN_PUR2_LMGD1O0K IS-AD-MPN AD_MPN_IC }
*    A&D 3.0; MPN-Projekt; Cora Zimmermann; 24.11.1998
* Changed from Wolfgang Kalthoff as the above only works for
* SAPLMGD1 and causes Syntax errors in all other groups:
  CALL FUNCTION 'PIC_COUNT_TOTAL_LINES'
       EXPORTING
            KZVERB  = kzverb
       CHANGING
            LINES   = vw_lines.

*  perform mpn_count_total_lines(sy-repid)
*     using kzverb changing vw_lines if found.
"{ End ENHO AD_MPN_PUR2_LMGD1O0K IS-AD-MPN AD_MPN_IC }

ENHANCEMENT-POINT VW_INITIALISIERUNG_01 SPOTS ES_LMGD1O0K INCLUDE BOUND.
*wk/4.0 switch to tc.
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_VERB' FROM SCREEN SY-DYNNR.
    TC_VERB-LINES = VW_LINES.
    TC_VERB-TOP_LINE = VW_ERSTE_ZEILE + 1.
    TC_VERB_TOP_LINE_BUF = TC_VERB-TOP_LINE.
    ASSIGN TC_VERB TO <F_TC>.
  ENDIF.
ENDMODULE.                             " VW_INITIALISIERUNG  OUTPUT
