MODULE ANZEIGEN_MEINH OUTPUT.

  IF SY-STEPL = 1.
    ME_ZLEPROSEITE = SY-LOOPC.
  ENDIF.

  ME_AKT_ZEILE = ME_ERSTE_ZEILE + SY-STEPL.

*-------Anzeigen interne Tabelle---------------------------------
  READ TABLE MEINH INDEX ME_AKT_ZEILE.
  IF SY-SUBRC = 0.
*---- Mengeneinheit ist bereits vorhanden ----------------------------
    MOVE-CORRESPONDING MEINH TO SMEINH.
    MOVE MARA-MEINS        TO RM03E-MEINS.
    MOVE T006A-MSEHT         TO RM03E-MSEHT.
* cfo/20.9.96 Nettogewicht füllen
    IF NOT MEINH-KZBME IS INITIAL.
      SMEINH-NTGEW = MARA-NTGEW.
*   cfo/4.0 Gewichtseinheit für Alternativmengeneinheiten nicht
*   vorschlagen, da bei Übernahme kein Vorschlag erfolgt und dann
*   Abweichung bei anschließender Dialogpflege.
*   ELSE.
    ELSEIF NOT MEINH-GEWEI IS INITIAL.
*     IF MEINH-GEWEI IS INITIAL.
*       SMEINH-GEWEI = MARA-GEWEI.
*     ENDIF.
      CALL FUNCTION 'MEINH_BRGEW'
           EXPORTING
                BME_NTGEW = MARA-NTGEW
                AME_BRGEW = MEINH-BRGEW
                BME_GEWEI = MARA-GEWEI
                AME_GEWEI = MEINH-GEWEI
                UMREZ     = MEINH-UMREZ
                UMREN     = MEINH-UMREN
                P_MESSAGE = 'N'
           IMPORTING
                AME_NTGEW = SMEINH-NTGEW
           EXCEPTIONS
                OTHERS    = 1.
    ENDIF.
    PERFORM LESEN_BEZ_ME USING SY-LANGU MEINH-MEINH *T006A.
*---- Fehlerhafte Zeilen hellleuchtend darstellen.
    IF ( ME_FEHLERFLG NE SPACE OR ADDKOFLG NE SPACE )
       AND MEINH-MEINH = SAVMEINH.
      PERFORM ME_MODIF_ZEILE.
    ENDIF.
    IF ME_FEHLERFLG NE SPACE AND MEINH-MEINH = SAVMEINH2.
      PERFORM ME_MODIF_ZEILE.
    ENDIF.
*---- Neu mk/16.02.93: vorher Felder_anzeigen nur ganz am Schluß
*---- cfo/20.6.96 bei Anzeigen inaktiv und dann raus (nach vorne geholt)
    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
      PERFORM FELDER_ANZEIGEN.
      EXIT.
    ENDIF.
*---- Basis-ME-Zeile ist nicht eingabebereit  mk/16.20.93---------
*---- (nur Einheiten, nicht EAN und Abmessungen) cfo/3.7.95-------
    IF ( ( NOT MEINH-KZBME IS INITIAL ) OR ( MEINH-MEINH = MARA-MEINS )
*---- note 1485795: open conversion factors for log. uoms, as usually
*     the base uom is added by hand and is not a variant specific uom
*         OR ( ME_LINES = 1 AND ME_AKT_ZEILE = 1 ) ).
         OR ( ME_LINES = 1 AND ME_AKT_ZEILE = 1 AND MEINH-BFLME_MARM IS INITIAL ) ).
*       AND ( RMMW2_VARN IS INITIAL ).         JW/4.6A: auch f. Var.
*     IF T130M-AKTYP NE AKTYPA OR T130M-AKTYP NE AKTYPZ.
      PERFORM MEINH_UMRECH_ANZEIGEN.
*     ENDIF.
*    JW/4.6A: ME auch für Varianten pflegbar.    - Anfang
*    ELSEIF NOT RMMW2_VARN IS INITIAL.
*---- Retail: MEen für Varianten nicht änderbar.
*      PERFORM MEINH_FELDER_ANZEIGEN USING MEINH-KZBME.
*    JW/4.6A: ME auch für Varianten pflegbar.    - Ende
    ELSE.
*---- cfo/3.8.95/Hinzufügen gleichbehandeln wie Ändern
*       IF  T130M-AKTYP = AKTYPH AND NEUFLAG IS INITIAL
*           AND MEINH-KZALT IS INITIAL.
*         PERFORM FELDER_ANZEIGEN.
*       ELSE.
*--- Alternative ME ist nicht eingabebereit und kann nicht als BasisME
*--- gekennzeichnet werden.
      PERFORM MEINH_ANZEIGEN.
* WS Abwicklung
* Anzeigen von UMREZ/UMREN bei ME mit Merkmalszuordnung
      IF NOT MEINH-ATINN IS INITIAL.
        PERFORM MEINH_UMRECH_ANZEIGEN.
      ENDIF.
*       ENDIF.
    ENDIF.
  ELSE.
*---- Mengeneinheit ist noch nicht vorhanden -------------------------
*---- Retail: Eingabe weiterer MEs für Varianten sperren.
    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
*      OR NOT RMMW2_VARN IS INITIAL.            JW/4.6A
      PERFORM FELDER_ANZEIGEN.
      EXIT FROM STEP-LOOP.
    ELSE.
* cfo/3.8.95/Hinzufügen gleichbehandeln wie Ändern.
*     IF T130M-AKTYP = AKTYPH AND NEUFLAG IS INITIAL.
*       PERFORM FELDER_ANZEIGEN.
*       EXIT FROM STEP-LOOP.
      IF T130M-AKTYP = AKTYPH AND ME_AKT_ZEILE = 1.
* Falls Mengeneinheiten auf Grundbild sind und Basismengeneinheit noch
* nicht eingegeben, erste Zeile zur Eingabe der BME öffnen, andernfalls
* Eingabe sperren.
* cfo/4.7.95
        IF MARA-MEINS IS INITIAL.
          PERFORM UMRECH_ANZEIGEN.
          SMEINH-UMREN = 1.
          SMEINH-UMREZ = 1.
          SMEINH-AZSUB = 1.                            "4.6A JW
          SMEINH-KZBME = X.
          SMEINH-GEWEI = MARA-GEWEI.   "cfo/1.2B2
        ELSE.
          PERFORM MEINH_UMRECH_ANZEIGEN.
        ENDIF.
      ELSE.
        MOVE MARA-MEINS  TO RM03E-MEINS.
        MOVE T006A-MSEHT TO RM03E-MSEHT.
        CLEAR *T006A-MSEHT.
        PERFORM NTGEW_ANZEIGEN.
      ENDIF.
      PERFORM RESET_REQ_FIELDS.                             "note 707765
    ENDIF.
  ENDIF.

*Vorgezogen für den Fall, daß Mengeneinheit in MEINH bereits vorhanden
*Sonst war Logik sowieso schon abgedeckt   mk/16.02.93
*    IF T130M-AKTYP = AKTYPA or t130m-aktyp = aktypz.
*       PERFORM FELDER_ANZEIGEN.
*    ELSE.
*       IF  T130M-AKTYP = AKTYPH AND NEUFLAG = SPACE
*       AND MEINH-KZALT = SPACE.
*          PERFORM FELDER_ANZEIGEN.
*       ENDIF.
*    ENDIF.

*mk/4.0A Mengeneinheiten sind für MPN-Materialien nicht pflegbar
  IF NOT RMMG2-KZMPN IS INITIAL.
    LOOP AT SCREEN.
      SCREEN-INVISIBLE = 1.
      SCREEN-ACTIVE    = 0.
      SCREEN-OUTPUT    = 0.
      SCREEN-INPUT     = 0.
      SCREEN-REQUIRED  = 0.
      MODIFY SCREEN.
    ENDLOOP.
* Falls keine Berechtigung für zentrale Felder -> anzeigen oder ausbl.
  ELSEIF RMMG2-MANBR NE SPACE.         "neu zu 3.0F /Rt 1.2
* if rmmg2-manbr ne space.             "neu zu 3.0F /Rt 1.2
    IF RMMG2-MANBR = MANBR1.
      PERFORM FELDER_ANZEIGEN.
    ELSE.
      LOOP AT SCREEN.
        SCREEN-INVISIBLE = 1.
        SCREEN-ACTIVE    = 0.
        SCREEN-OUTPUT    = 0.
        SCREEN-INPUT     = 0.
        SCREEN-REQUIRED  = 0.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.                             " ANZEIGEN_MEINH  OUTPUT
