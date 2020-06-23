*&---------------------------------------------------------------------*
*&      Module  ANZEIGEN_KURZTEXT  OUTPUT
*&---------------------------------------------------------------------*
*Fuellen der Loop-Zeile mit den Daten aus der internen Tabelle
*Bildschirmmodifikation:
* - im Anzeigefall sind die Felder nicht eingabebereit
* - beim Erweitern im Hinzufuegefall werden die Texte nur angezeigt
*------------------------------------------------------------------
MODULE ANZEIGEN_KURZTEXT OUTPUT.

  IF SY-STEPL = 1.
    KT_ZLEPROSEITE = SY-LOOPC.
  ENDIF.

  KT_AKT_ZEILE = KT_ERSTE_ZEILE + SY-STEPL.

*-------Anzeigen interne Tabelle---------------------------------
  READ TABLE KTEXT INDEX KT_AKT_ZEILE.

  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING KTEXT TO SKTEXT.
    IF KT_FEHLERFLG = FDSPRACH AND KTEXT-SPRAS = KT_SAVSPRAS.
      PERFORM MODIF_ZEILE.
      MOVE SY-STEPL TO KT_ZEILEN_NR.
    ENDIF.
  ELSE.
*wk/4.0
    IF SY-STEPL = 1.                   "no text jet
      SKTEXT-SPRAS = SY-LANGU.
    ENDIF.
    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
      EXIT FROM STEP-LOOP.
* Bei Erweitern Material wird Kurztexte ändern erlaubt
*    ELSE.
*       IF T130M-AKTYP = AKTYPH AND NEUFLAG = SPACE.
*          EXIT FROM STEP-LOOP.
*       ENDIF.
    ENDIF.
  ENDIF.

*-------Bildschirmmodifikationen---------------------------------
  IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
    PERFORM FELDER_ANZEIGEN.
* ELSE.
* Bei Erweitern Material wird Kurztexte ändern erlaubt
*    IF T130M-AKTYP = AKTYPH AND NEUFLAG = SPACE.
*       PERFORM FELDER_ANZEIGEN.
*    ENDIF.
  ENDIF.

ENDMODULE.                             " ANZEIGEN_KURZTEXT  OUTPUT
