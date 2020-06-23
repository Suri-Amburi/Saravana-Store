
*------------------------------------------------------------------
* Module MAW1-WBKLA
*
* Prüfung der Bewertungsklasse (Retail-Vorschlagsfeld)
*
* Die Prüfung muß durchgeführt werden für alle MBEW-Sätze,
* auf welche die Änderung durchgereicht wird, d.h. die nicht
* abweichend gepflegt sind.
* Dazu wird ein Funktionsbaustein aufgerufen, welcher eine
* Tabelle mit allen relevanten MBEW-Sätzen zur Verfügung stellt.
* Über diese MBEW-Tabelle wird einzeln der normale FB zum Prüfen
* der Bewertungsklasse aufgerufen.
*------------------------------------------------------------------
MODULE MAW1-WBKLA.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_BKLAS = X ) AND
     ( UMAW1-WBKLA NE MAW1-WBKLA ).
    CLEAR RMMZU-PS_BKLAS.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_BKLAS IS INITIAL.

    CALL FUNCTION 'MAW1_WBKLA'
         EXPORTING
              WMARA_MATNR     = MARA-MATNR
              WMARA_ATTYP     = MARA-ATTYP
              WMAW1_WBKLA     = MAW1-WBKLA
              LMAW1_WBKLA     = LMAW1-WBKLA
              OMAW1_WBKLA     = *MAW1-WBKLA
              WRMMG1_MTART    = RMMG1-MTART
              P_AKTYP         = T130M-AKTYP
              NEUFLAG         = NEUFLAG
              P_PS_BKLAS      = RMMZU-PS_BKLAS
         IMPORTING
              WMAW1_WBKLA     = MAW1-WBKLA
              P_PS_BKLAS      = RMMZU-PS_BKLAS
         EXCEPTIONS
              NO_BKLAS        = 01
              ERROR_BKLAS     = 02
              ERROR_NACHRICHT = 03.

* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MAW1-WBKLA'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_BKLAS NE SPACE.
      BILDFLAG = X.
      RMMZU-FLG_FLISTE = 'X'.                               "note 865189
      RMMZU-CURS_FELD = 'MAW1-WBKLA'.
      MESSAGE S368.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMAW1 = MAW1.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
* Module MAW1-WSTAW
*
* Prüfen der statistischen Warennummer (Retail-Vorschlagsfeld)
*
* Die aus der statistischen Warennummer kommende Mengeneinheit ( T604 )
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*------------------------------------------------------------------
MODULE MAW1-WSTAW.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MAW1_WSTAW'
       EXPORTING
            WMAW1_WSTAW      = MAW1-WSTAW
            WMARA_MEINS      = MARA-MEINS
            WMARA_MATNR      = MARA-MATNR  " AHE: 21.02.99 (4.6a)
            WMARA_ATTYP      = MARA-ATTYP  "BE/050696
            WMARA_SATNR      = MARA-SATNR  "BE/050696
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            P_AKTYP          = T130M-AKTYP
            OK_CODE          = RMMZU-OKCODE
            LMAW1_WSTAW      = LMAW1-WSTAW
            WMAW1_WEXPM      = MAW1-WEXPM           "note 1696765
       IMPORTING
            WRMMZU           = RMMZU
            OK_CODE          = RMMZU-OKCODE
            HOKCODE          = RMMZU-HOKCODE
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
            WMAW1_WEXPM      = MAW1-WEXPM                 "note 1281354
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ENDIF.

ENDMODULE.


*------------------------------------------------------------------
* Module INHALTE
* Der Nettoinhalt wird in der Regel nicht größer sein als der
* Bruttoinhalt.
*------------------------------------------------------------------
MODULE INHALTE.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'INHALTE_PRUEFUNG'
       EXPORTING
*     WMARA_INHAL = MARA-INHAL     "JH/4.7
*     WMARA_INHBR = MARA-INHBR.    "JH/4.7
            WMARA_INHBR = MARA-INHBR     "JH/4.7
       CHANGING                          "JH/4.7
            WMARA_INHAL = MARA-INHAL.    "JH/4.7

ENDMODULE.

*------------------------------------------------------------------
* Module MARA-INHME
* Prüfen ob eine ( richtige ) Gewichtseinheit angegeben wurde.
* Wenn Inhalts-ME muß auch Vergleichs-Preiseinheit angegeben sein.
*------------------------------------------------------------------
MODULE MARA-INHME.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_INHME'
       EXPORTING
            WMARA_INHAL = MARA-INHAL
            WMARA_INHBR = MARA-INHBR
            WMARA_INHME = MARA-INHME
            WMARA_VPREH = MARA-VPREH.

ENDMODULE.

*------------------------------------------------------------------
* Module MARA-DATAB
* Prüfen des Verwendbarkeitszeitraumes
*------------------------------------------------------------------
MODULE MARA-DATAB.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_DATAB'
       EXPORTING
            WMARA_DATAB = MARA-DATAB
            WMARA_LIQDT = MARA-LIQDT.

ENDMODULE.

*------------------------------------------------------------------
* Module MARA-MSTDE
* Prüfen Gültigkeitsdatum zum allgemeinen Materialstatus Einkauf
*------------------------------------------------------------------
*Verlagert in LMGD1I01, da jetzt auch für Industrie-St. relevant  ch/4.0
*ODULE MARA-MSTDE.
*
* CHECK BILDFLAG = SPACE.
* CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*
* CALL FUNCTION 'MARA_MSTDE'
*      EXPORTING
*           WMARA_MSTAE = MARA-MSTAE
*           WMARA_MSTDE = MARA-MSTDE.
*
*NDMODULE.

*------------------------------------------------------------------
* Module MARA-MSTDV
* Prüfen Gültigkeitsdatum zum allgemeinen Materialstatus Vertrieb
*------------------------------------------------------------------
*Verlagert in LMGD1I01, da jetzt auch für Industrie-St. relevant  ch/4.0
*ODULE MARA-MSTDV.
*
* CHECK BILDFLAG = SPACE.
* CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*
* CALL FUNCTION 'MARA_MSTDV'
*      EXPORTING
*           WMARA_MSTAV = MARA-MSTAV
*           WMARA_MSTDV = MARA-MSTDV.
*
*NDMODULE.

*------------------------------------------------------------------
* Module SAISON
* Prüfen Saisonkennung und Saisonjahr
*------------------------------------------------------------------
MODULE SAISON.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'SAISON_PRUEFEN'
       EXPORTING
            WMARA_SAISO  = MARA-SAISO
            WMARA_SAISJ  = MARA-SAISJ
            WMARA_SAITY  = MARA-SAITY            " 4.7 COLLETT
            WRMMG1_VKORG = SPACE
            WRMMG1_VTWEG = SPACE.

ENDMODULE.

*------------------------------------------------------------------
* Module LISTUNG_FILIALE
* Prüfen Listungszeitraum Filiale
*------------------------------------------------------------------
MODULE LISTUNG_FILIALE.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'LISTUNG_FILIALE'
       EXPORTING
            WMARA_DATAB = MARA-DATAB
            WMARA_LIQDT = MARA-LIQDT
            WMWLI_LDVFL = MWLI-LDVFL
            WMWLI_LDBFL = MWLI-LDBFL.

ENDMODULE.

*------------------------------------------------------------------
* Module VERKAUF_FILIALE
* Prüfen Verkaufszeitraum Filiale
*------------------------------------------------------------------
MODULE VERKAUF_FILIALE.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'VERKAUF_FILIALE'
       EXPORTING
            WMARA_DATAB  = MARA-DATAB
            WMARA_LIQDT  = MARA-LIQDT
            WMWLI_LDVFL  = MWLI-LDVFL
            WMWLI_LDBFL  = MWLI-LDBFL
            WMWLI_VDVFL  = MWLI-VDVFL
            WMWLI_VDBFL  = MWLI-VDBFL
* AHE: 15.01.99 - A (4.5b)
            P_KZ_NO_WARN = NORMAL_WARNING
* AHE: 15.01.99 - E
            .
ENDMODULE.

*------------------------------------------------------------------
* Module LISTUNG_ZENTRALE
* Prüfen Listungszeitraum Zentrale
*------------------------------------------------------------------
MODULE LISTUNG_ZENTRALE.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'LISTUNG_ZENTRALE'
       EXPORTING
            WMARA_DATAB = MARA-DATAB
            WMARA_LIQDT = MARA-LIQDT
            WMWLI_LDVZL = MWLI-LDVZL
            WMWLI_LDBZL = MWLI-LDBZL
            WMWLI_LSTFL = MWLI-LSTFL
            WMWLI_LSTVZ = MWLI-LSTVZ
       IMPORTING
            WMWLI_LSTVZ = MWLI-LSTVZ.

ENDMODULE.

*------------------------------------------------------------------
* Module VERKAUF_ZENTRALE
* Prüfen Verkaufszeitraum Zentrale
*------------------------------------------------------------------
MODULE VERKAUF_ZENTRALE.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'VERKAUF_ZENTRALE'
       EXPORTING
            WMARA_DATAB = MARA-DATAB
            WMARA_LIQDT = MARA-LIQDT
            WMWLI_LDVZL = MWLI-LDVZL
            WMWLI_LDBZL = MWLI-LDBZL
            WMWLI_VDVZL = MWLI-VDVZL
            WMWLI_VDBZL = MWLI-VDBZL
* AHE: 15.01.99 - A (4.5b)
            P_KZ_NO_WARN = NORMAL_WARNING
* AHE: 15.01.99 - E
            .
ENDMODULE.

*------------------------------------------------------------------
* Module MAW1-WVRKM
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Wird
* keine eingegeben wird die Basismengeneinheit gesetzt.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*
* ab 2.1B Prüfung, ob eine kaufmännische Einheit eingegeben wurde
*------------------------------------------------------------------
MODULE MAW1-WVRKM.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MAW1_WVRKM'
       EXPORTING
            WMARA_MATNR      = MARA-MATNR
            WMARA_ATTYP      = MARA-ATTYP
            WMAW1_WVRKM      = MAW1-WVRKM
            WMARA_MEINS      = MARA-MEINS
            WMARA_SATNR      = MARA-SATNR  "BE/030696
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            LMAW1_WVRKM      = LMAW1-WVRKM
            OMAW1_WVRKM      = *MAW1-WVRKM
            AKTYP            = T130M-AKTYP
            NEUFLAG          = NEUFLAG
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WMAW1_WVRKM      = MAW1-WVRKM
            WRMMZU           = RMMZU
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
            HOKCODE          = RMMZU-HOKCODE
            OK_CODE          = RMMZU-OKCODE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
* Module MAW1-WAUSM
*
* Prüfung der Ausgabemengeneinheit (Retail-Vorschlagsfeld)
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Umrechnungsfaktor eingeben kann.
*
* ab 2.1B Prüfung, ob eine kaufmännische Einheit eingegeben wurde
*------------------------------------------------------------------
MODULE MAW1-WAUSM.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MAW1_WAUSM'
       EXPORTING
            WMARA_MATNR      = MARA-MATNR
            WMARA_ATTYP      = MARA-ATTYP
            WMAW1_WAUSM      = MAW1-WAUSM
            WMARA_MEINS      = MARA-MEINS
            WMARA_SATNR      = MARA-SATNR  "BE/030696
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            LMAW1_WAUSM      = LMAW1-WAUSM
            OMAW1_WAUSM      = *MAW1-WAUSM
            AKTYP            = T130M-AKTYP
            NEUFLAG          = NEUFLAG
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WMAW1_WAUSM      = MAW1-WAUSM
            WRMMZU           = RMMZU
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
            HOKCODE          = RMMZU-HOKCODE
            OK_CODE          = RMMZU-OKCODE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
* Module MARA-TAKLV
*
* Übernehmen der Vorschlags-Steuerklassifikation in interne
* Steuertabelle und prüfen auf Zulässigkeit. Bei Fehler wird
* der entsprechende Funktionscode gesetzt und auf das Zusatz-
* steuerbild verzweigt.
*
*------------------------------------------------------------------
MODULE MARA-TAKLV.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_TAKLV'
       EXPORTING
            WMARA_TAKLV    = MARA-TAKLV
            LMARA_TAKLV    = RETT_TAKLV
            FLGSTEUER_MUSS = RMMG2-STEUERMUSS
            P_BILDS        = BILDSEQUENZ  "mk/4.0
       TABLES
            STEUERTAB      = STEUERTAB
       CHANGING
            OK_CODE        = RMMZU-OKCODE.

ENDMODULE.

*------------------------------------------------------------------
* Module MARA-XCHPF
*
* Beim Ändern des Kennzeichens Chargenpflicht wird geprüft, ob
* diese Änderung erlaubt ist.  (Retail -> Vorschlagsfeld)
*
* Die Prüfung muß durchgeführt werden für alle MARC-Sätze,
* auf welche die Änderung durchgereicht wird, d.h. die nicht
* abweichend gepflegt sind.
* Dazu wird ein Funktionsbaustein aufgerufen, welcher eine
* Tabelle mit allen relevanten MARC-Sätzen zur Verfügung stellt.
* Über diese MARC-Tabelle wird einzeln der normale FB zum Prüfen
* der Chargenpflicht aufgerufen.
*
*------------------------------------------------------------------
MODULE MARA-XCHPF.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

ENHANCEMENT-SECTION     LMGD2I01_01 SPOTS ES_LMGD2I01 INCLUDE BOUND.
  CALL FUNCTION 'MARA_XCHPF'
       EXPORTING
            NEUFLAG           = NEUFLAG
            CHARGEN_EBENE     = RMMG2-CHARGEBENE
            MARA_IN_MATNR     = RMMG1-MATNR
            WMARA_XCHPF       = MARA-XCHPF
            RET_XCHPF         = LMARA-XCHPF
            WMARA_ATTYP       = MARA-ATTYP
            WMARA_MTART       = MARA-MTART  "ch zu 4.0
            WMARA_KZWSM       = MARA-KZWSM  "ch zu 4.0
            WMARA_VPSTA       = MARA-VPSTA  "ch zu 4.5b
            P_MESSAGE         = SPACE  "ch/24.10.96
* Mill 0024 Single Unit Batch SW            "/SAPMP/PIECEBATCH "{ ENHO /SAPMP/PIECEBATCH_LMGD2I01 IS-MP-MM /SAPMP/SINGLE_UNIT_BATCH }
            WMARA_DPCBT       = MARA-DPCBT  "/SAPMP/PIECEBATCH "{ ENHO /SAPMP/PIECEBATCH_LMGD2I01 IS-MP-MM /SAPMP/SINGLE_UNIT_BATCH }
       IMPORTING
            WMARA_XCHPF       = MARA-XCHPF
       EXCEPTIONS
            ERROR_NACHRICHT   = 01
            ERROR_CALL_SCREEN = 02.
END-ENHANCEMENT-SECTION.

  IF SY-SUBRC NE 0.                    "Zurücksetzen der Chargenebene
    IF RMMG2-CHARGEBENE NE CHARGEN_EBENE_A.
      IF MARA-XCHPF = SPACE.
        MARA-XCHPF = X.
      ELSE.
        MARA-XCHPF = SPACE.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE SY-SUBRC.
    WHEN '1'.
*---- Chargenpflicht nicht änderbar --------------------------------
      RMMZU-FLG_FLISTE = X.
      RMMZU-ERR_CHPF   = X.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      BILDFLAG = X.
    WHEN '2'.
*---- Chargenpflicht nicht änderbar --------------------------------
      RMMZU-FLG_FLISTE = X.
      RMMZU-ERR_CHPF   = X.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      BILDFLAG = X.
  ENDCASE.

 IF RMMG2-CHARGEBENE NE CHARGEN_EBENE_A.
  if mara-sgt_covsa is NOT INITIAL and mara-sgt_scope eq '1' and mara-xchpf is INITIAL.
    mara-xchpf = X.
    MESSAGE w126(sgt_01).
*   Batch management is mandatory when scope of segmentation strategy is 1
  endif.
 ENDIF.
ENDMODULE.

*------------------------------------------------------------------
* Module MARA-XCHAR
*
* Setzen des Kz. 'Chargenführung prüfen / aktualisieren'
*  - falls beim Anlegen Chargenpflicht nicht gesetzt ist
*  - falls beim Ändern die Chargenpflicht zurückgenommen wurde
*  (im Verbucher wird in Abhängigkeit, ob getrennte Bewertung
*  vereinbart ist oder nicht, das Kz. Chargenführung gesetzt bzw.
*  zurückgenommen).
* Setzen des Kz. 'Chargenpflicht hat sich geändert'
*
*------------------------------------------------------------------
MODULE MARA-XCHAR.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CALL FUNCTION 'MARA_XCHAR'
       EXPORTING
            WMARA_XCHPF = MARA-XCHPF
            OMARA_XCHPF = *MARA-XCHPF
            NEUFLAG     = NEUFLAG.
* (del)CHANGING                                              "BE/081196
* (del)     FLGXCHAR_CHPF    = RMMG2-XCHAR_CHPF              "BE/071196
* (del)     KZMARA_XCHPF     = RMMG2-KZ_XCHPF_A.             "BE/081196

ENDMODULE.

*----------------------------------------------------------------------
* Module MVKE-PMATN                                          "BE/210696
*
* Prüfen Preismaterial gegen Artikelnummern im Puffer.
* (Problem Neuanlage: Fremdschlüsselprüfung eigener Artikel).
* moved to industry standard lmgd1i08 to 4.0 (wk)
*----------------------------------------------------------------------
*MODULE MVKE-PMATN2.
*  "BE/210696
*
*  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*  CHECK BILDFLAG IS INITIAL.
*
*  CALL FUNCTION 'MVKE_PMATN'
*       EXPORTING
*            WMVKE_PMATN = MVKE-PMATN
*            LMVKE_PMATN = LMVKE-PMATN
*            WMARA_MATNR = MARA-MATNR
*            WMVKE_VKORG = MVKE-VKORG
*            WMVKE_VTWEG = MVKE-VTWEG
*            WMARA_ATTYP = MARA-ATTYP
*            WMARA_SATNR = MARA-SATNR
*            FLG_RETAIL = 'X'.
*ENDMODULE.

*----------------------------------------------------------------------
* Module MARA-PMATA                                          "BE/310796
*
* Prüfen Preismaterial gegen Artikelnummern im Puffer.
* (Problem Neuanlage: Fremdschlüsselprüfung eigener Artikel).
*
*----------------------------------------------------------------------
MODULE MARA-PMATA.                     "BE/310796

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CALL FUNCTION 'MARA_PMATA'
       EXPORTING
            WMARA_MATNR = MARA-MATNR
            WMARA_PMATA = MARA-PMATA
            LMARA_PMATA = LMARA-PMATA
            WMARA_ATTYP = MARA-ATTYP
            WMARA_SATNR = MARA-SATNR
            FLG_RETAIL  = 'X'.
* cfo/4.0C sonst keine Ausgabe der Meldung
*      EXCEPTIONS
*           ERROR_PMATA = 1
*           OTHERS      = 2.

ENDMODULE.

*----------------------------------------------------------------------
* Module MARA-SPROF                                          "BE/310796
*
* Prüfen VKP-Kalkulationsprofil (mögliche Warnung bei Änderung)
*----------------------------------------------------------------------
MODULE MARA-SPROF.                     "BE/310796

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CALL FUNCTION 'MARA_SPROF'
       EXPORTING
            WMARA_SPROF = MARA-SPROF
            LMARA_SPROF = LMARA-SPROF
            WMARA_ATTYP = MARA-ATTYP
            NEUFLAG     = NEUFLAG.

ENDMODULE.

*------------------------------------------------------------------
* Module EINA-MEINS
*
* Prüfen der Bestellmengeneinheit Einkaufsinfosatz
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Umrechnungsfaktor eingeben kann.
* Zusatz-Prüfung, ob eine kaufmännische Einheit eingegeben wurde.
*
*------------------------------------------------------------------

MODULE EINA-MEINS.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'EINA_E_MEINS'
       EXPORTING
            WEINA_MEINS      = EINA-MEINS
            WMARA_MEINS      = MARA-MEINS
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            P_AKTYP          = T130M-AKTYP
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WRMMZU           = RMMZU
            OK_CODE          = RMMZU-OKCODE
            HOKCODE          = RMMZU-HOKCODE
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ELSE.
    If LEINA-MEINS NE EINA-MEINS.                   "BKE 639816
    LOOP AT MEINH WHERE MEINH = EINA-MEINS.        "Versorgen EINA
      EINA-UMREZ = MEINH-UMREZ.        "im Ok-Durchgang
      EINA-UMREN = MEINH-UMREN.
      EXIT.
    ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
* Module EINE-BPRME
*
* Prüfen der Preismengeneinheit Einkaufsinfosatz
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Umrechnungsfaktor eingeben kann.
* Zusatz-Prüfung, ob eine kaufmännische Einheit eingegeben wurde.
*
*------------------------------------------------------------------

MODULE EINE-BPRME.

  DATA: HUMREN1 TYPE F,
        HUMREZ1 TYPE F,
        HUMREN2 TYPE F,
        HUMREZ2 TYPE F.

  data: humren_p type p,        "note 202653
        humrez_p type p.        "note 202653

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'EINE_E_BPRME'
       EXPORTING
            WEINE_BPRME      = EINE-BPRME
            WMARA_MEINS      = MARA-MEINS
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            P_AKTYP          = T130M-AKTYP
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WRMMZU           = RMMZU
            OK_CODE          = RMMZU-OKCODE
            HOKCODE          = RMMZU-HOKCODE
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ELSE.
    LOOP AT MEINH WHERE MEINH = EINE-BPRME.        "Versorgen EINE
                                       "im Ok-Durchgang
      IF EINE-BPRME NE EINA-MEINS.
        "cfo/11.6.96/Umrechnungen der BestellpreisME beziehen
                                       "sich auf die BestellME!
        "cfo/23.7.96/Es muß noch gekürzt werden! Bei gleicher Einheit
                                       "sind Umrechnungsfaktoren immer 1
*       EINE-BPUMZ = MEINH-UMREN * EINA-UMREZ."note 202653
*       EINE-BPUMN = MEINH-UMREZ * EINA-UMREN."
*       HUMREZ1 = EINE-BPUMZ.                 "
*       HUMREN1 = EINE-BPUMN.                 "
        HUMREZ_P = MEINH-UMREN * EINA-UMREZ.  "
        HUMREN_P = MEINH-UMREZ * EINA-UMREN.  "
        HUMREZ1 = HUMREZ_P.                   "
        HUMREN1 = HUMREN_P.                   "

        CALL FUNCTION 'GGT'
             EXPORTING
                  Z                         = HUMREZ1
                  N                         = HUMREN1
             IMPORTING
*           GGT                       =
                  Z_NEU                     = HUMREZ2
                  N_NEU                     = HUMREN2
             EXCEPTIONS
                  KEINE_NEGAT_WERTE_ERLAUBT = 1
                  NULL_NICHT_ERLAUBT        = 2
                  OTHERS                    = 3.
        IF SY-SUBRC = 0.
* note 202653 - begin: Umwandlung in 5stellige Umrechnungsfaktoren
          if humrez2 > 99999 or humren2 > 99999.
            CALL FUNCTION 'CONVERT_TO_FRACT5'
              EXPORTING
                NOMIN                     = humrez1
                DENOMIN                   = humren1
              IMPORTING
                NOMOUT                    = eine-bpumz
                DENOMOUT                  = eine-bpumn
              EXCEPTIONS
                CONVERSION_OVERFLOW       = 1
                OTHERS              = 2.
            IF SY-SUBRC <> 0.
              message e329(mh).
            ENDIF.
          else.
            EINE-BPUMZ = HUMREZ2.
            EINE-BPUMN = HUMREN2.
          endif.
* note 202653 - end
        ENDIF.
      ELSE.
        EINE-BPUMZ = 1.
        EINE-BPUMN = 1.
      ENDIF.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  mwli-lstvz  INPUT
*&---------------------------------------------------------------------*
*       Einlesen Text zum Listungsverfahren --Filiale--                *
*----------------------------------------------------------------------*
MODULE MWLI-LSTVZ INPUT.
  CALL FUNCTION 'TWLVT_SINGLE_READ'
       EXPORTING
            TWLVT_LSTFL = MWLI-LSTVZ
            TWLVT_SPRAS = SY-LANGU
       IMPORTING
            WTWLVT      = *TWLVT
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  mwli-lstfl  INPUT
*&---------------------------------------------------------------------*
*       Einlesen Text zum Listungsverfahren  --VZ/ZL--                 *
*----------------------------------------------------------------------*
MODULE MWLI-LSTFL INPUT.
  CALL FUNCTION 'TWLVT_SINGLE_READ'
       EXPORTING
            TWLVT_LSTFL = MWLI-LSTFL
            TWLVT_SPRAS = SY-LANGU
       IMPORTING
            WTWLVT      = TWLVT
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MARC-LGFSB  INPUT     Neu/MK24.05.96
*&---------------------------------------------------------------------*
MODULE MARC-LGFSB INPUT.

  DATA: HREFERENCE,                    "cfo/4.0C
        HRMMW2 LIKE RMMW2,             "cfo/4.0C
        HPTAB LIKE SPTAP OCCURS 0 WITH HEADER LINE.          "cfo/4.0C
  DATA: HMARD_PAI TYPE MARD.
  refresh hptab.                                             "jw/4.6A

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CLEAR HREFERENCE.                    "cfo/4.0C

* note 1345281: avoid overwriting of manually changed MARD data for a
* new storage location by execution of 2nd reference handling! Because
* the result will be the same as the first execution in the PBO without
* to care for manual changes. But due to this call at first RMMG1 and
* PTAB_FULL will be correctly set for the current LGORT value.
  CLEAR HMARD_PAI.
  IF MARC-LGFSB = MARD-LGORT AND
     RMMG1-LGORT IS INITIAL AND LMARC-LGFSB IS INITIAL.
    HMARD_PAI = MARD.
  ENDIF.

  CALL FUNCTION 'MARC_LGFSB'
       EXPORTING
            MARC_LGFSB   = MARC-LGFSB
            LMARC_LGFSB  = LMARC-LGFSB
            P_KZ_NO_WARN = SPACE
            P_KZRFB      = KZRFB
            P_SPERRMODUS = SPERRMODUS
            MATNR        = RMMG1-MATNR
            WERKS        = RMMG1-WERKS
            OMARD        = *MARD       "mk/1.2A1
            OMLGN        = *MLGN       "mk/1.2A1
            OMLGT        = *MLGT       "mk/1.2A1
            P_NEUFLAG    = NEUFLAG     "mk/1.2A1
            P_AKTYP      = T130M-AKTYP "mk/1.2A1
       TABLES
            MPTAB        = PTAB        "mk/1.2A1
            PTAB_FULL    = PTAB_FULL   "mk/1.2A1
       CHANGING
            LGNUM        = RMMG1-LGNUM "mk/1.2A1
            LGTYP        = RMMG1-LGTYP ""
            LGORT        = RMMG1-LGORT ""
            WMARD        = MARD        ""
            WMLGN        = MLGN        ""
            WMLGT        = MLGT        ""
            P_REFERENCE  = HREFERENCE. "cfo/4.0C
*Aktualisieren RMMG1 im  PUffer -  erfolgt nicht im set_daten_sub
*mk/1.2A1 jetzt doch - und zwar in temporärer RMMG1
* CALL FUNCTION 'MAIN_PARAMETER_SET_RMMG1'
*      EXPORTING
*           WRMMG1  = RMMG1
*      EXCEPTIONS
*           OTHERS  = 1.
*mk/1.2A1 arbeiten mit LMARC-LGFSB und MARC-LGFSB bzw. RMMG1-Feldern
*Achtung: In set_daten_sub werden Keys aus RMMG1 gefüllt!
* RMMWZ-LGFSB_OLD = LMARC-LGFSB.
* RMMWZ-LGFSB_NEW = MARC-LGFSB.

* cfo/4.0C-A
  IF NOT HREFERENCE IS INITIAL.
*   In RMMG1 steht der aktuelle Stand
    HRMMW2 = RMMW2.
    MOVE-CORRESPONDING RMMG1 TO HRMMW2.
    CALL FUNCTION 'REF_MATERIAL_READ_ALL'
         EXPORTING
              HERKUNFT                     = HERKUNFT_DIAL
              AKTYP                        = T130M-AKTYP
              KZ_DIREKT                    = 'X'
              P_RMMG1                      = RMMG1
              P_RMMW2                      = HRMMW2
              SELSTATUS_RT                 = RMMW3-SELSTAT_RT
              TRANSSTATUS_RT               = RMMW3-TRANSTA_RT
              DIREKTSTATUS_RT              = RMMW3-DIRKSTA_RT
              MAW1_WPSTA                   = MAW1-WPSTA
              SPERRMODUS                   = SPERRMODUS
              KZRFB                        = KZRFB
              MAXTZ                        = MAXTZ
              P_KZ_NO_WARN                 = NORMAL_WARNING
              NEUFLAG                      = NEUFLAG
              MARA_REF                     = RMARA
              MAW1_REF                     = RMAW1
         EXCEPTIONS
              MARA_INP_REF_MISSING         = 1
              SELSTATUS_RT_MISSING_FOR_REF = 2
              OTHERS                       = 3.
    READ TABLE PTAB INTO HPTAB
                    WITH KEY TBNAM = T_MARD BINARY SEARCH.
    APPEND HPTAB.

* jw/4.6A: zum Referenzieren reduzierten Bildstatus verwenden
    call function 'SCHNITTMENGE'
        exporting
            status_in1 = t133a-pstat
            status_in2 = aktvstatus
        IMPORTING
        status_out = red_pstat.
* jw/4.6A-E

    CALL FUNCTION 'MATERIAL_REFERENCE_RT'
         EXPORTING
              P_HERKUNFT    = HERKUNFT_DIAL
              P_RMMG1       = RMMG1
              P_RMMW2       = RMMW2
              P_KZPRO       = RMMZU-BILDPROZ
              P_MTART_BESKZ = RMMG2-BESKZ
*       p_status            = t133a-pstat     jw/4.6A
              p_status      = red_pstat       "jw/4.6A
              p_rtstatus    = t133a-rpsta
              p_aktvstatus  = aktvstatus       "jw/4.6A
              KZRFB         = KZRFB
              MAXTZ         = MAXTZ
              SPERRMODUS    = SPERRMODUS
              P_BILDFLAG    = BILDFLAG
              P_NO_PTAB_READ = X
              P_NO_PTAB_FULL_READ = X
              P_BUCHEN      = FLG_PRUEFDUNKEL
              P_NEUFLAG     = NEUFLAG
              P_T130M       = T130M                 "cfo/4.6A
              P_CALL_MODE2  = RMMG2-CALL_MODE2      "vst/4.6A
         TABLES
              WKTEXT        = KTEXT
              WMEINH        = MEINH
              WSTEUERTAB    = STEUERTAB
              WSTEUMMTAB    = STEUMMTAB
              WMAMT         = TMAMT
              WMALG         = TMALG
              P_PTAB        = HPTAB
              P_PTAB_FULL   = PTAB_FULL
         CHANGING
              WMARA         = MARA
              WMAW1         = MAW1
              WMAKT         = MAKT
              WMARC         = MARC
              WMARD         = MARD
              WMVKE         = MVKE
              WMLGN         = MLGN
              WMLGT         = MLGT
              WMPOP         = MPOP
              WMPGD         = MPGD
              WMFHM         = MFHM
              WMBEW         = MBEW
              WMYMS         = MYMS
              WEINA         = EINA
              WEINE         = EINE
              WWLK2         = WLK2
              P_LMARA       = LMARA
              P_LMAW1       = LMAW1
         EXCEPTIONS
              OTHERS        = 1.
*   note 1345281: reset MARD back to maintained dynpro values
    IF HMARD_PAI IS NOT INITIAL.
      MARD = HMARD_PAI.
    ENDIF.
  ENDIF.
* cfo/4.0C-E

ENDMODULE.                             " MARC-LGFSB  INPUT

*&---------------------------------------------------------------------*
*&      Module  MARD-LGPBE  INPUT     Neu/MK24.05.96
*&---------------------------------------------------------------------*
MODULE MARD-LGPBE INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'LGORT_INITIAL'
       EXPORTING
            LAGERORT     = MARC-LGFSB
            LAGERORT_OLD = LMARC-LGFSB
            OMARD        = *MARD
            OMLGN        = *MLGN       "mk/1.2A1
            OMLGT        = *MLGT       "mk/1.2A1
            P_KZ_NO_WARN = SPACE
       CHANGING
            WMARD        = MARD
            WMLGN        = MLGN        "mk/1.2A1
            WMLGT        = MLGT.       "mk/1.2A1

ENDMODULE.                             " MARD-LGPBE  INPUT

*&---------------------------------------------------------------------*
*&      Module  EINE-MINBM-NORBM  INPUT
*&---------------------------------------------------------------------*
*       Vorbelegung der Normbestellmenge aus der Mindestbestellmenge.  *
*----------------------------------------------------------------------*
MODULE EINE-MINBM-NORBM INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'EINE_MINBM_NORBM'
       EXPORTING
            WEINE_MINBM = EINE-MINBM
       CHANGING
            WEINE_NORBM = EINE-NORBM
       EXCEPTIONS
            OTHERS      = 1.

ENDMODULE.                             " EINE-MINBM-NORBM  INPUT

*&---------------------------------------------------------------------*
*&      Module  WLK2-VMSTD  INPUT
*&---------------------------------------------------------------------*
*       Analog zu MVKE-VMSTA                                           *
*----------------------------------------------------------------------*
MODULE WLK2-VMSTD INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_VMSTD'
       EXPORTING
            LMVKE_VMSTA = LWLK2-MSTAV  "ch zu 4.5b
            LMVKE_VMSTD = LWLK2-MSTDV  "ch zu 4.5b
            WMVKE_VMSTA = WLK2-MSTAV
            WMVKE_VMSTD = WLK2-MSTDV.

ENDMODULE.                             " WLK2-VMSTD  INPUT

*&---------------------------------------------------------------------*
*&      Module  MVKE-VMSTA  INPUT
*&---------------------------------------------------------------------*
MODULE MVKE-VMSTA INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_VMSTD'
       EXPORTING
            LMVKE_VMSTA = LMVKE-VMSTA  "ch zu 4.5b
            LMVKE_VMSTD = LMVKE-VMSTD  "ch zu 4.5b
            WMVKE_VMSTA = MVKE-VMSTA
            WMVKE_VMSTD = MVKE-VMSTD.

ENDMODULE.                             " MVKE-VMSTA INPUT

*&---------------------------------------------------------------------*
*&      Module  WLK2-VKZEITRAUM  INPUT
*&---------------------------------------------------------------------*
*       Prüfen Verkaufszeitraum                                        *
*----------------------------------------------------------------------*
MODULE WLK2-VKZEITRAUM INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'TVKOV_SINGLE_READ'
       EXPORTING
            TVKOV_VKORG = WLK2-VKORG
            TVKOV_VTWEG = WLK2-VTWEG
*     KZRFB       = ' '
       IMPORTING
            WTVKOV      = TVKOV
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2.
  IF NOT TVKOV-VLTYP = VLTYP_FI.
    CALL FUNCTION 'VERKAUF_ZENTRALE'
         EXPORTING
              WMARA_DATAB = MARA-DATAB
              WMARA_LIQDT = MARA-LIQDT
              WMWLI_LDVZL = MVKE-LDVZL
              WMWLI_LDBZL = MVKE-LDBZL
              WMWLI_VDVZL = WLK2-VKDAB
              WMWLI_VDBZL = WLK2-VKBIS
* AHE: 15.01.99 - A (4.5b)
              P_KZ_NO_WARN = NORMAL_WARNING.
* AHE: 15.01.99 - E
*        EXCEPTIONS                                "cfo/4.0
*             ERROR_VALIDITY = 1                   "
*             OTHERS         = 2.                  "
  ELSE.
    CALL FUNCTION 'VERKAUF_FILIALE'
         EXPORTING
              WMARA_DATAB = MARA-DATAB
              WMARA_LIQDT = MARA-LIQDT
              WMWLI_LDVFL = MVKE-LDVFL
              WMWLI_LDBFL = MVKE-LDBFL
              WMWLI_VDVFL = WLK2-VKDAB
              WMWLI_VDBFL = WLK2-VKBIS
* AHE: 15.01.99 - A (4.5b)
              P_KZ_NO_WARN = NORMAL_WARNING
* AHE: 15.01.99 - E
              .
  ENDIF.

ENDMODULE.                             " WLK2-VKZEITRAUM  INPUT

*&---------------------------------------------------------------------*
*&      Module  MVKE-VKZEITRAUM  INPUT
*&---------------------------------------------------------------------*
*       Prüfen Verkaufszeitraum                                        *
*----------------------------------------------------------------------*
MODULE MVKE-VKZEITRAUM INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'TVKOV_SINGLE_READ'
       EXPORTING
            TVKOV_VKORG = MVKE-VKORG
            TVKOV_VTWEG = MVKE-VTWEG
*     KZRFB       = ' '
       IMPORTING
            WTVKOV      = TVKOV
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2.
  IF NOT TVKOV-VLTYP = VLTYP_FI.
    CALL FUNCTION 'VERKAUF_ZENTRALE'
         EXPORTING
              WMARA_DATAB = MARA-DATAB
              WMARA_LIQDT = MARA-LIQDT
              WMWLI_LDVZL = MVKE-LDVZL
              WMWLI_LDBZL = MVKE-LDBZL
              WMWLI_VDVZL = MVKE-VDVZL
              WMWLI_VDBZL = MVKE-VDBZL
* AHE: 15.01.99 - A (4.5b)
              P_KZ_NO_WARN = NORMAL_WARNING.
* AHE: 15.01.99 - E
*        EXCEPTIONS                                  "cfo/4.0
*             ERROR_VALIDITY = 1                     "
*             OTHERS         = 2.                    "
  ELSE.
    CALL FUNCTION 'VERKAUF_FILIALE'
         EXPORTING
              WMARA_DATAB = MARA-DATAB
              WMARA_LIQDT = MARA-LIQDT
              WMWLI_LDVFL = MVKE-LDVFL
              WMWLI_LDBFL = MVKE-LDBFL
              WMWLI_VDVFL = MVKE-VDVFL
              WMWLI_VDBFL = MVKE-VDBFL
* AHE: 15.01.99 - A (4.5b)
              P_KZ_NO_WARN = NORMAL_WARNING
* AHE: 15.01.99 - E
              .
  ENDIF.

ENDMODULE.                             " MVKE-VKZEITRAUM  INPUT

*-----------------------------------------------------------------------
* Module MVKE-LFMAX                                          "BE/130896
*
* Die Mindestliefermenge sollte nicht größer als die maximale
* Liefermenge sein.
*
*-----------------------------------------------------------------------
MODULE MVKE-LFMAX.                     "BE/130896

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_LFMAX'
       EXPORTING
            WMVKE_LFMAX = MVKE-LFMAX
            WMVKE_LFMNG = MVKE-LFMNG.

ENDMODULE.

*-----------------------------------------------------------------------
* Module MVKE-AUMNG                                          "BE/130896
*
* Die Mindestauftragsmenge wird gleich der Mindestliefermenge gesetzt.
*
*-----------------------------------------------------------------------
MODULE MVKE-AUMNG.                     "BE/130896

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 15.09.98 - A (Rel. 99)
* von Usability her völlig verkehrt --> s. auch K.-Meldung: 285125 1998
* daher rausgenommen
* MVKE-AUMNG = MVKE-LFMNG.
* AHE: 15.09.98 - E

ENDMODULE.

*------------------------------------------------------------------
* Module MBEW-BWTTY_RETAIL
*
* Prüfung des  Bewertungstyps Retail-spezifisch
*
* Die Prüfung muß durchgeführt werden für alle MBEW-Sätze,
* auf welche die Änderung durchgereicht wird, d.h. die nicht
* abweichend gepflegt sind.
* Dazu wird ein Funktionsbaustein aufgerufen, welcher eine
* Tabelle mit allen relevanten MBEW-Sätzen zur Verfügung stellt.
* Über diese MBEW-Tabelle wird einzeln der normale FB zum Prüfen
* des Bewertungstyp's aufgerufen.
*------------------------------------------------------------------
MODULE MBEW-BWTTY_RETAIL.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_BWTTY_RETAIL'
       EXPORTING
            WMBEW_BWTTY     = MBEW-BWTTY
            WRMMG1_WERKS    = RMMG1-WERKS
            WMARA_XCHPF     = MARA-XCHPF
            WRMMG1_MATNR    = RMMG1-MATNR
* (del)     FLGBWTTY        = RMMG2-FLGBWTTY                 "BE/081196
* (del)     FLGXCHAR_BEW    = RMMG2-XCHAR_BEW                "BE/081196
* (del)     FLGXCHPF_HART   = RMMG2-XCHPF_HART               "BE/301096
            NEUFLAG         = NEUFLAG
            P_AKTYP         = T130M-AKTYP
            CHARGEN_EBENE   = RMMG2-CHARGEBENE
            WMARA_ATTYP     = MARA-ATTYP
       IMPORTING
            WMBEW_BWTTY     = MBEW-BWTTY
            WMARA_XCHPF     = MARA-XCHPF
* (del)     FLGBWTTY        = RMMG2-FLGBWTTY                 "BE/081196
* (del)     FLGXCHAR_BEW    = RMMG2-XCHAR_BEW                "BE/081196
* (del)     FLGXCHPF_HART   = RMMG2-XCHPF_HART               "BE/301096
       TABLES
            P_PTAB          = PTAB
       EXCEPTIONS
            ERROR_BWTTY     = 1
            SET_ERROR_BWTTY = 2.

  CASE SY-SUBRC.
    WHEN '1'.
*---- Bewertungstyp nicht änderbar ---------------------------------
      MOVE *MBEW-BWTTY TO MBEW-BWTTY.
      RMMZU-FLG_FLISTE = X.
      RMMZU-ERR_BWTTY  = X.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      BILDFLAG = X.
    WHEN '2'.
*---- Bewertungstyp nicht änderbar ---------------------------------
      MOVE *MBEW-BWTTY TO MBEW-BWTTY.
      RMMZU-FLG_FLISTE = X.
      RMMZU-ERR_BWTTY  = X.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      BILDFLAG = X.
  ENDCASE.

ENDMODULE.

*------------------------------------------------------------------
*  Module MARC-XCHPF_RETAIL
*
* Prüfung der Chargenpflicht Retail-spezifisch
*
* Die Prüfung muß durchgeführt werden für alle MARA-/MARC-Sätze,
* auf welche die Änderung durchgereicht wird (Varianten, Vorlagewerke)
* und die nicht abweichend gepflegt sind (kein MPOI vorhanden).
* Dazu wird ein Funktionsbaustein aufgerufen, welcher Tabellen
* mit allen relevanten MARA-/MARC-Sätzen zur Verfügung stellt.
* Darüber wird einzeln der normale FB zum Prüfen der Chargenpflicht
* aufgerufen.
*
*------------------------------------------------------------------
MODULE MARC-XCHPF_RETAIL.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF RMMG2-CHARGEBENE = CHARGEN_EBENE_0.
    HXCHPF = LMARC-XCHPF.
  ELSE.
    HXCHPF = LMARA-XCHPF.
  ENDIF.

  CALL FUNCTION 'MARC_XCHPF_RETAIL'
       EXPORTING
            WMARC_XCHPF       = MARC-XCHPF
            WMARC_WERKS       = MARC-WERKS
            WMARA_XCHPF       = MARA-XCHPF
            CHARGEN_EBENE     = RMMG2-CHARGEBENE
            NEUFLAG           = NEUFLAG
            MARA_IN_MATNR     = RMMG1-MATNR
            RET_XCHPF         = HXCHPF
            WMARA_ATTYP       = MARA-ATTYP
            WMARA_MTART       = MARA-MTART  "ch zu 4.0
            WMARA_KZWSM       = MARA-KZWSM  "ch zu 4.0
            WMARA_VPSTA       = MARA-VPSTA  "ch zu 4.5b
            P_MESSAGE         = SPACE  "ch/24.10.96
       IMPORTING
            WMARC_XCHPF       = MARC-XCHPF
            WMARA_XCHPF       = MARA-XCHPF
       EXCEPTIONS
            ERROR_NACHRICHT   = 01
            ERROR_CALL_SCREEN = 02.

  IF SY-SUBRC NE 0.                    "Zurücksetzen der Chargenebene
    IF RMMG2-CHARGEBENE NE CHARGEN_EBENE_A.
      IF MARA-XCHPF = SPACE.
        MARA-XCHPF = X.
      ELSE.
        MARA-XCHPF = SPACE.
      ENDIF.
      MARC-XCHPF = MARA-XCHPF.
    ELSE.
      IF MARC-XCHPF = SPACE.
        MARC-XCHPF = X.
      ELSE.
        MARC-XCHPF = SPACE.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE SY-SUBRC.
    WHEN '1'.
*---- Chargenpflicht nicht änderbar --------------------------------
      MOVE LMARC-XCHPF TO MARC-XCHPF.
      RMMZU-FLG_FLISTE = X.
      RMMZU-ERR_CHPF   = X.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      BILDFLAG = X.
    WHEN '2'.
*---- Chargenpflicht nicht änderbar --------------------------------
      MOVE LMARC-XCHPF TO MARC-XCHPF.
      RMMZU-FLG_FLISTE = X.
      RMMZU-ERR_CHPF   = X.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      BILDFLAG = X.
  ENDCASE.
    IF RMMG2-CHARGEBENE NE CHARGEN_EBENE_A.
      if mara-xchpf is INITIAL AND mara-sgt_covsa is NOT INITIAL and mara-sgt_scope eq '1'.
        mara-xchpf = X.
         MESSAGE w126(sgt_01).
*   Batch management is mandatory when scope of segmentation strategy is 1
       elseif mara-xchpf is NOT INITIAL AND marc-xchpf IS INITIAL
              AND mara-sgt_covsa is NOT INITIAL and mara-sgt_scope eq '1'.
        marc-xchpf = X.
         MESSAGE w126(sgt_01).
*   Batch management is mandatory when scope of segmentation strategy is 1
      endif.
    else.
      if marc-xchpf is INITIAL and marc-sgt_covs is NOT INITIAL and marc-sgt_scope eq '1'.
        marc-xchpf = X.
        MESSAGE w126(sgt_01).
*   Batch management is mandatory when scope of segmentation strategy is 1
      endif.
    endif.

ENDMODULE.

*------------------------------------------------------------------
* Module MARC-AUSME_RETAIL
*
* Prüfung der Ausgabemengeneinheit Retail-spezifisch
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Umrechnungsfaktor eingeben kann.
*
* ab 2.1B Prüfung, ob eine kaufmännische Einheit eingegeben wurde
*------------------------------------------------------------------
MODULE MARC-AUSME_RETAIL.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_AUSME_RETAIL'
       EXPORTING
            WMARC_AUSME      = MARC-AUSME
            WMARC_WERKS      = MARC-WERKS
            WMARA_MATNR      = MARA-MATNR
            WMARA_ATTYP      = MARA-ATTYP
            WMARA_MEINS      = MARA-MEINS
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            LMARC_AUSME      = LMARC-AUSME
            OMARC_AUSME      = *MARC-AUSME
            AKTYP            = T130M-AKTYP
            NEUFLAG          = NEUFLAG
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WMARC_AUSME      = MARC-AUSME
            WRMMZU           = RMMZU
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
            HOKCODE          = RMMZU-HOKCODE
            OK_CODE          = RMMZU-OKCODE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
* Module MBEW-BKLAS_RETAIL
*
* Prüfung der Bewertungsklasse Retail-spezifisch
*
* Die Prüfung muß durchgeführt werden für alle MBEW-Sätze,
* auf welche die Änderung durchgereicht wird, d.h. die nicht
* abweichend gepflegt sind.
* Dazu wird ein Funktionsbaustein aufgerufen, welcher eine
* Tabelle mit allen relevanten MBEW-Sätzen zur Verfügung stellt.
* Über diese MBEW-Tabelle wird einzeln der normale FB zum Prüfen
* der Bewertungsklasse aufgerufen.
*------------------------------------------------------------------
MODULE MBEW-BKLAS_RETAIL.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CHECK AKTVSTATUS CA STATUS_B.

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_BKLAS = X ) AND
* Note 316843
     ( ( UMBEW-BKLAS NE MBEW-BKLAS ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMBEW-MATNR NE MBEW-MATNR ) OR
       ( UMBEW-BWKEY NE MBEW-BWKEY ) OR
       ( UMBEW-BWTAR NE MBEW-BWTAR ) ).
    CLEAR RMMZU-PS_BKLAS.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_BKLAS IS INITIAL.

    CALL FUNCTION 'MBEW_BKLAS_RETAIL'
         EXPORTING
              WMBEW_BKLAS     = MBEW-BKLAS
              WMBEW_BWKEY     = MBEW-BWKEY
              WMBEW_BWTAR     = MBEW-BWTAR  "ch /4.0c
              WMBEW_BWTTY     = MBEW-BWTTY  "ch /4.0c
              WMARA_MATNR     = MARA-MATNR
              WMARA_ATTYP     = MARA-ATTYP
              LMBEW_BKLAS     = LMBEW-BKLAS
              OMBEW_BKLAS     = *MBEW-BKLAS
              WRMMG1_MTART    = RMMG1-MTART
              P_AKTYP         = T130M-AKTYP
              NEUFLAG         = NEUFLAG
              P_PS_BKLAS      = RMMZU-PS_BKLAS
         IMPORTING
              WMBEW_BKLAS     = MBEW-BKLAS
              P_PS_BKLAS      = RMMZU-PS_BKLAS
         EXCEPTIONS
              NO_BKLAS        = 01
              ERROR_BKLAS     = 02
              ERROR_NACHRICHT = 03.

* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-BKLAS'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_BKLAS NE SPACE.
      BILDFLAG = X.
      RMMZU-FLG_FLISTE = 'X'.                               "note 865189
      RMMZU-CURS_FELD = 'MBEW-BKLAS'.
      MESSAGE S368.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMBEW = MBEW.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.

*----------------------------------------------------------------------
* Module EINA-RELIF                                          "BE/181096
*
* Prüfen Regellieferant Einkaufsinfosatz
* Wenn für einen Lieferanten das Kennzeichen Regellieferant gesetzt
* wird, muß geprüft werden, ob das Kennzeichen für irgendeinen anderen
* Lieferanten im Puffer bereits sitzt. Wenn ja, wird das Kennzeichen
* im Puffer zurückgenommen.
*
*----------------------------------------------------------------------

MODULE EINA-RELIF.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'EINA_E_RELIF'
       EXPORTING
            WMARA_MATNR = MARA-MATNR
            WEINA_RELIF = EINA-RELIF
            LEINA_RELIF = LEINA-RELIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EINE-RDPRF  INPUT                         "cfo/17.2.97
*&---------------------------------------------------------------------*
*       Prüfung des Rundungsprofils:                                   *
*       EINE ohne Werk -> nur Rundungsprofile ohne Werk erlaubt.
*       EINE mit Werk  -> Rundungsprofile für das Werk und ohne Werk
*                         erlaubt
*----------------------------------------------------------------------*
MODULE EINE-RDPRF INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'EINE_RDPRF'
       EXPORTING
            WEINE_RDPRF = EINE-RDPRF
            WEINE_WERKS = EINE-WERKS.

ENDMODULE.                             " EINE-RDPRF  INPUT
*&---------------------------------------------------------------------*
*&      Module  MARA-MLGUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MARA-MLGUT INPUT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
* Nur im Dialog wird geprüft, ob das Feld Leergutstückliste
* überhaupt sinnvoll gesetzt ist
  data: tmlgut like mara-mlgut.

  CALL FUNCTION 'MGW1_EMPTIES_BOM_CHECK'
    EXPORTING
      IV_MATNR            = mara-matnr
    IMPORTING
      ev_mara_mlgut = tmlgut.
  if mara-mlgut is initial and not tmlgut is initial.
   MESSAGE W080(MU) WITH mara-matnr.
*   Zum Material &1 existiert bereits eine Leergutstückl.
   mara-mlgut = 'X'.
   bildflag = 'X'.
  endif.



ENDMODULE.                 " MARA-MLGUT  INPUT
*&---------------------------------------------------------------------*
*&      Module  bom_check  INPUT
*&---------------------------------------------------------------------*
* Check if
* o  components exist for the structured material
* o  an empties bom exists for the full product
*
* Bildflag has to be set in case of error to make sure that the screen
* is processed again.
* The check if bildflag is initial is dangerous. It might lead to the
* situation that some checks get lost because other messages have been
* sent before. On the other hand, if this check is omitted, messages
* that have been sent before might be "overwritten" by this check.
* The check is not performed when the button "components" has been
* pushed. Otherwise, the user would get a warning message even though
* she/he is just about to create components.
*----------------------------------------------------------------------*
module bom_check input.

  check bildflag is initial.
  check t130m-aktyp ne aktypa and t130m-aktyp ne aktypz.

*--- button "components" corresponds with okcode PB47.
  if rmmzu-okcode <> 'PB47' AND
*    note  1076015: no message if you scroll in the classification
*    subscreen to allow maintenance of required characteristics
     rmmzu-okcode <> FCODE_PAGN AND
     rmmzu-okcode <> FCODE_PAGP AND
     rmmzu-okcode <> FCODE_PAG1 AND
     rmmzu-okcode <> FCODE_PAGL.

    call function 'MGW0_HAS_COMPONENTS'
      exporting
        is_mara            = mara
      exceptions
       no_components_exist = 1
       others              = 2.

    if sy-subrc = 1.
      if sy-msgty = 'E'.
        sy-msgty = 'W'.
        bildflag = 'X'.
      endif.

      message id     sy-msgid
              type   sy-msgty
              number sy-msgno
              with   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

endmodule.                 " bom_check  INPUT
*------------------------------------------------------------------
* Module EINE-NETPR
*
* note 880134
* Prüfen der Nettopreises Einkaufsinfosatz
* Wenn der Nettopreis als Mußfeld eingestellt ist, so soll es bei
* Angabe des Wertes 0 oder 0,00 auch einen Mußfeldfehler geben,
* analog zu ME11 oder ME12
*
*------------------------------------------------------------------

MODULE EINE-NETPR.

  LOOP AT SCREEN.
    CHECK screen-name = 'EINE-NETPR'.
    CHECK screen-required = 1.
    CHECK screen-input = 1.
    ASSIGN (screen-name) TO <f1>.
    CHECK <f1> IS INITIAL.
    SET CURSOR FIELD screen-name.
    MESSAGE e055(00).
  ENDLOOP.


ENDMODULE.
