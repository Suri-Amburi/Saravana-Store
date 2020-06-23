*-------------------------------------------------------------------
***INCLUDE POSANE01 .
*-------------------------------------------------------------------

* Gemeinsame Ereignisse der Reports RWDPOSAN, RWDPOSIN und RWDPOSUP
INCLUDE dlpose01.

******************************************************************
AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_art.
* 'Materialstammdaten sollen an das POS-System versendet werden'
  MESSAGE i015.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_ean.
* 'EAN-Referenzen sollen an das POS-System versendet werden'
  MESSAGE i016.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_nart.
* 'Nachzugsartikel sollen an das POS-System versendet werden'
  MESSAGE i017.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_sets.
* 'Set-Zuordnungen sollen an das POS-System versendet werden'
  MESSAGE i018.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_pdat.
* 'Personendaten sollen an das POS-System versendet werden'
  MESSAGE i019.

* Erweiterung Bonus-Buys (GL, Release 99A)
AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_bbuy.
* 'Bonuskäufe sollen an das POS-System versendet werden'
  MESSAGE i036.
* ***

* Erweiterung Aktionsrabatte, rz 19.05.00
AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_promo.
* 'Aktionsrabatte sollen an das POS-System versendet werden'
  MESSAGE i039.
* rz

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_wrg.
* 'Warengruppen sollen an das POS-System versendet werden'
  MESSAGE i020.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_steu.
* 'Steuern sollen an das POS-System versendet werden'
  MESSAGE i021.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_wkurs.
* 'Wechselkurse sollen an das POS-System versendet werden'
  MESSAGE i022.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_datab.
* 'Datum, ab dem die Daten für das POS-System gültig werden sollen'
  MESSAGE i023.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_datbi.
* 'Datum, bis zu dem die Daten für das POS-System gültig werden sollen'
  MESSAGE i024.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_dele.
* 'Löschanforderung für das POS-System'
  MESSAGE i025.

AT SELECTION-SCREEN ON HELP-REQUEST FOR pa_debug.
* 'Fehleranalyse-Modus über die Statusverfolgung der POS-Schnitstelle'
  MESSAGE i026.

AT SELECTION-SCREEN ON BLOCK time_range.
* Beginn des Betrachtungszeitraums. Initialwerte sind dagegen erlaubt.
  IF NOT ( pa_datab IS INITIAL ) AND NOT ( pa_datbi IS INITIAL ) AND
     pa_datbi < pa_datab.
*   'Falsches Datumsintervall des Betrachtungszeitraums'
    MESSAGE e013.
  ENDIF. " not ( pa_datab is initial ) and ...

*&---------------------------------------------------------------------*
*&   Event START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Prüfe, ob überhaupt etwas versendet werden soll. Falls nein, dann
* Fehlermeldung.
  IF pa_art  = space AND pa_ean = space AND pa_nart = space AND
     pa_sets = space AND pa_wrg = space AND pa_steu = space AND
     pa_pdat = space AND pa_wkurs = space AND pa_bbuy = space AND
     pa_promo = space.
*   'Bitte wenigstens eine Auswahl ankreuzen'
    MESSAGE i014.
    EXIT.
  ENDIF. " PA_ART  = SPACE AND ...

* Falls der Dialog nicht unterdrückt werden soll.
  IF pa_nodia IS INITIAL.
*   Sicherheitsabfrage bei Löschanforderung.
    IF pa_dele <> space AND sy-batch IS INITIAL.
      g_del_line1 = 'Sollen die Daten wirklich aus dem'(001).
      g_del_line2 = 'POS-System gelöscht werden ?'(002).
      CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
        EXPORTING
          textline1 = g_del_line1
          textline2 = g_del_line2
          titel     = 'direkte Anforderung: Löschen'(003)
        IMPORTING
          answer    = g_popup_answer.

*     Falls keine Löschanforderung erwünscht, dann rücksetze
*     Löschanforderung und Rücksprung zum Programmanfang.
      IF g_popup_answer = 'N'.
        CLEAR: pa_dele.
        EXIT.
      ENDIF.                             " G_POPUP_ANSWER = 'N'.
    ENDIF.                               "PA_DELE <> SPACE.
  ENDIF. " pa_nodia is initial.

* Falls das Ende des Betrachtungszeitraums kleiner ist als der
* Initialisieren der internen Tabellen.
  REFRESH: gt_locnr, gt_article, gt_kunnr, gt_filia.

* Bestimme die Gesamtmenge der selektierten Filialen.
  PERFORM filia_get TABLES gt_locnr  gt_filia.

* Falls Artikel versendet werden sollen.
  IF pa_art <> space.
*   Bestimme die Gesamtmenge der selektierten Artikel.
    PERFORM article_get TABLES gt_article.

*   Bestimme die Gesamtmenge der, in der SELECT-OPTION mit 'EQUAL'
*   angegebenen Artikel.
    PERFORM article_equal_get TABLES gt_article_equal.
  ENDIF.                               " PA_ART <> SPACE.

* Falls EAN-Referenzen versendet werden sollen.
  IF pa_ean <> space.
*   Bestimme die Gesamtmenge der selektierten Artikel.
    PERFORM ean_get TABLES gt_article.

*   Bestimme die Gesamtmenge der, in der SELECT-OPTION mit 'EQUAL'
*   angegebenen Artikel.
    PERFORM ean_equal_get TABLES gt_article_equal.
  ENDIF.                               " PA_EAN <> SPACE.

* Falls Nachzugsartikel versendet werden sollen.
  IF pa_nart <> space.
*   Bestimme die Gesamtmenge der selektierten Set-Artikel.
    PERFORM nart_get TABLES gt_article.

*   Bestimme die Gesamtmenge der, in der SELECT-OPTION mit 'EQUAL'
*   angegebenen Nachzugsartikel.
    PERFORM nart_equal_get TABLES gt_article_equal.
  ENDIF.                               " PA_NART <> SPACE.

* Falls Set-Zuordnungen versendet werden sollen.
  IF pa_sets <> space.
*   Bestimme die Gesamtmenge der selektierten Set-Artikel.
    PERFORM sets_get TABLES gt_article.

*   Bestimme die Gesamtmenge der, in der SELECT-OPTION mit 'EQUAL'
*   angegebenen Set-Artikel.
    PERFORM set_equal_get TABLES gt_article_equal.
  ENDIF.                               " PA_SETS <> SPACE.

* Falls Personendaten versendet werden sollen.
  IF pa_pdat <> space.
*   Bestimme die Gesamtmenge der selektierten Kundennummern.
    PERFORM kunnr_get TABLES gt_kunnr.
  ENDIF.                               " PA_PDAT <> SPACE.

* Erweiterung Bonus-Buys (Release 99A, GL)
* Falls Bonus-Käufe versendet werden sollen.
  IF pa_bbuy <> space.

    pa_bbyde = pa_dele.

*   Bestimme die Gesamtmenge der selektierten Bonus-Käufe
    PERFORM bbuy_get TABLES gt_bbuy
                     USING  pa_dele
                            pa_bbyde.
  ENDIF.

* Erweiterung Aktionsrabatte.
* Falls Aktionsrabatte versendet werden sollen.
  IF pa_promo <> space.
*   Bestimme die Gesamtmenge der selektierten Aktionen
    PERFORM promotion_get TABLES gt_promo.
  ENDIF.

***> Start of Change : Suri : 04.08.2019 : 20:00:00
***  Des : For Avoiding EAN Validations
* Sprung in die ALE-Schicht zum Aufbereiten und Versenden der Daten.
*  CALL FUNCTION 'MASTERIDOC_CREATE_REQ_W_PDLD'
*    EXPORTING
*      pi_mode       = 'A'        " direkte Anforderung
*      pi_loeschen   = pa_dele
*      pi_debug      = pa_debug
*      pi_datum_ab   = pa_datab
*      pi_datum_bis  = pa_datbi
*      pi_vkorg      = pa_vkorg
*      pi_vtweg      = pa_vtweg
*      pi_art        = pa_art
*      pi_ean        = pa_ean
*      pi_nart       = pa_nart
*      pi_sets       = pa_sets
*      pi_pdat       = pa_pdat
*      pi_wrg        = pa_wrg
*      pi_steuern    = pa_steu
*      pi_wkurs      = pa_wkurs
*      pi_bbuy       = pa_bbuy
*      pi_promo      = pa_promo
*      pi_no_dialog  = pa_nodia
*      pi_no_bby     = pa_bbyde
*    TABLES
*      pit_artikel   = gt_article
*      pit_kunnr     = gt_kunnr
*      pit_locnr     = gt_locnr
*      pit_filia     = gt_filia
*      pit_art_equal = gt_article_equal
*      pit_bbuy      = gt_bbuy
*      pit_promo     = gt_promo
*    EXCEPTIONS
*      download_exit = 1.

  CALL FUNCTION 'ZZMASTERIDOC_CREATE_REQ_W_PDLD'
    EXPORTING
      pi_mode       = 'A'        " direkte Anforderung
      pi_loeschen   = pa_dele
      pi_debug      = pa_debug
      pi_datum_ab   = pa_datab
      pi_datum_bis  = pa_datbi
      pi_vkorg      = pa_vkorg
      pi_vtweg      = pa_vtweg
      pi_art        = pa_art
      pi_ean        = pa_ean
      pi_nart       = pa_nart
      pi_sets       = pa_sets
      pi_pdat       = pa_pdat
      pi_wrg        = pa_wrg
      pi_steuern    = pa_steu
      pi_wkurs      = pa_wkurs
      pi_bbuy       = pa_bbuy
      pi_promo      = pa_promo
      pi_no_dialog  = pa_nodia
      pi_no_bby     = pa_bbyde
    TABLES
      pit_artikel   = gt_article
      pit_kunnr     = gt_kunnr
      pit_locnr     = gt_locnr
      pit_filia     = gt_filia
      pit_art_equal = gt_article_equal
      pit_bbuy      = gt_bbuy
      pit_promo     = gt_promo
    EXCEPTIONS
      download_exit = 1.

*** End of Changes  : Suri : 04.08.2019  20:00:00
  IF sy-subrc = 1.
*    'Es sind Fehler beim POS-Ausgang aufgetreten'
    MESSAGE e001.
  ENDIF.                               " SY-SUBRC = 1.

* Freigabe aller Sperren.
  CALL FUNCTION 'DEQUEUE_ALL'
*      exporting
*           _SYNCHRON = ' '.
       EXCEPTIONS
            OTHERS = 1.

INITIALIZATION.
"--------------------------------------------------------
" shall not be executable as long as Retail is hidden

  cl_esr_utilities=>is_retail_in_s4h_hidden( ).
"--------------------------------------------------------
