*------------------------------------------------------------------
*  Module MBEW-VPRSV.
*
*  Das Preissteuerungskz wird geprueft.
*  Die Berechnung der neuen Werte erfolgt im Modul MBEW-PEINH
*------------------------------------------------------------------
MODULE MBEW-VPRSV.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_VPRSV = X ) AND
     ( ( UMBEW-VPRSV NE MBEW-VPRSV ) OR
       ( UMBEW-VERPR NE MBEW-VERPR ) OR
* Note 316843
       ( UMBEW-STPRS NE MBEW-STPRS ) OR
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

    CALL FUNCTION 'MBEW_VPRSV'
         EXPORTING
              WMBEW_VPRSV     = MBEW-VPRSV
              WMBEW_STPRS     = MBEW-STPRS
              WMBEW_VERPR     = MBEW-VERPR
              WMBEW_BWTTY     = MBEW-BWTTY
              WMBEW_KALKL     = MBEW-KALKL
              WMBEW_SALK3     = MBEW-SALK3
              WMBEW_SALKV     = MBEW-SALKV
              WMBEW_VMSAL     = MBEW-VMSAL
              WMBEW_VMSAV     = MBEW-VMSAV
              WMBEW_MLAST     = MBEW-MLAST             "4.0A  BE/221097
              OMBEW_VPRSV     = *MBEW-VPRSV
              WRMMG1_BWKEY    = RMMG1-BWKEY
              WRMMG1_BWTAR    = RMMG1-BWTAR
              WRMMG1_MTART    = RMMG1-MTART
              P_AKTYP         = T130M-AKTYP
              P_PS_VPRSV      = RMMZU-PS_VPRSV
              WMBEW_MATNR     = MBEW-MATNR    "fbo/111298 Sharedsperre
         IMPORTING
              WMBEW_VPRSV     = MBEW-VPRSV
              P_PS_VPRSV      = RMMZU-PS_VPRSV
         EXCEPTIONS
              ERROR_VPRSV     = 01.

* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
* Preiseinheit nicht änderbar                                "BE/240297
      MOVE LMBEW-VPRSV TO MBEW-VPRSV.                        "BE/240297
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-VPRSV'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_VPRSV NE SPACE.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-VPRSV'.
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
