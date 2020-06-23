*------------------------------------------------------------------
*  Module MPOP-GEWGR.
* Beim Prognoseverfahren 'Gewichtetes gleitendes Mittel' wird eine
* Gewichtungsgruppe benötigt, ansonsten wird das Feld zurückgesetzt.
* Das Feld wird gegen die T440G verprobt.
*------------------------------------------------------------------
MODULE MPOP-GEWGR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_GEWGR = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
* Note 316843
       ( UMPOP-GEWGR NE MPOP-GEWGR ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMPOP-MATNR NE MPOP-MATNR ) OR
       ( UMPOP-WERKS NE MPOP-WERKS ) ).
    CLEAR RMMZU-PS_GEWGR.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_GEWGR IS INITIAL.
    CALL FUNCTION 'MPOP_GEWGR'
         EXPORTING
              P_PRMOD          = MPOP-PRMOD
              P_GEWGR          = MPOP-GEWGR
              P_PROPR          = MPOP-PROPR
              P_KZRFB          = KZRFB
              P_PS_GEWGR       = RMMZU-PS_GEWGR
              P_KZ_NO_WARN     = ' '
         IMPORTING
              P_GEWGR          = MPOP-GEWGR
              P_PS_GEWGR       = RMMZU-PS_GEWGR
         EXCEPTIONS
              P_ERR_MPOP_GEWGR = 01.
* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_GEWGR NE SPACE.
      BILDFLAG = X.
      MESSAGE S463.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt).
    CALL FUNCTION 'MPOP_GEWGR'
         EXPORTING
              P_PRMOD          = MPOP-PRMOD
              P_GEWGR          = MPOP-GEWGR
              P_PROPR          = MPOP-PROPR
              P_KZRFB          = KZRFB
              P_PS_GEWGR       = RMMZU-PS_GEWGR
              P_KZ_NO_WARN     = ' '
         IMPORTING
              P_GEWGR          = MPOP-GEWGR
              P_PS_GEWGR       = RMMZU-PS_GEWGR
         EXCEPTIONS
              P_ERR_MPOP_GEWGR = 01.
* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.


ENDMODULE.
