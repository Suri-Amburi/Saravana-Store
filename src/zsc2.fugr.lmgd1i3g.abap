*------------------------------------------------------------------
*  Module MBEW-VMVPR.
*
*  Das Preissteuerungskz Vormonat wird  geprueft.
*------------------------------------------------------------------
MODULE MBEW-VMVPR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_VPRSV = X ) AND
     ( ( UMBEW-VMVPR NE MBEW-VMVPR ) OR
       ( UMBEW-VMVER NE MBEW-VMVER ) OR
* Note 316843
       ( UMBEW-VMSTP NE MBEW-VMSTP ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMBEW-MATNR NE MBEW-MATNR ) OR
       ( UMBEW-BWKEY NE MBEW-BWKEY ) OR
       ( UMBEW-BWTAR NE MBEW-BWTAR ) ).
    CLEAR RMMZU-PS_VPRSV.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_VPRSV IS INITIAL.

    CALL FUNCTION 'MBEW_VMVPR'
         EXPORTING
              WMBEW_VMVPR     = MBEW-VMVPR
              WMBEW_VMSTP     = MBEW-VMSTP
              WMBEW_VMVER     = MBEW-VMVER
              WMBEW_KALKV     = MBEW-KALKV
              WMBEW_VMSAL     = MBEW-VMSAL
              WMBEW_VMSAV     = MBEW-VMSAV
              OMBEW_VMVPR     = *MBEW-VMVPR
              P_PS_VPRSV      = RMMZU-PS_VPRSV
              WMBEW_MATNR     = MBEW-MATNR "fbo/111298 Sharedsperre
              WRMMG1_BWKEY    = MBEW-BWKEY "fbo/111298 Sharedsperre
              WRMMG1_BWTAR    = MBEW-BWTAR "fbo/111298 Sharedsperre
         IMPORTING
              WMBEW_VMVPR     = MBEW-VMVPR
              P_PS_VPRSV      = RMMZU-PS_VPRSV
         EXCEPTIONS
              ERROR_VPRSV     = 01.

* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-VMVPR'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_VPRSV NE SPACE.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-VMVPR'.
      MESSAGE S551.
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
