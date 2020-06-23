*----------------------------------------------------------------------*
*   INCLUDE LMGD1F2F                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ME_SUB_STRUKTUR_PRUEFEN
*&---------------------------------------------------------------------*
*       jw, rel. 4.6A
*----------------------------------------------------------------------*
FORM ME_SUB_STRUKTUR_PRUEFEN.

  DATA: WA_MEINH LIKE SMEINH.
  DATA: QUEUE_TAB LIKE TABLE OF SMEINH.
  DATA: N_MEINH LIKE SMEINH.
* sub_updateflg ist gesetzt, wenn eine ME geaendert wurde und
* uebergeordnete ME existieren, die dementsprechend geaendert werden.
  DATA: SUB_UPDATEFLG(1) TYPE C.
  DATA: DOPPELEINTRAG(1) TYPE C.
  DATA: LINE TYPE I.
  DATA: COUNTER TYPE I.
  DATA: QUOTIENT TYPE F.
* kz_small_unit ist gesetzt, wenn die BME nicht die kleinste ME ist.
* (Entwicklungsantrag 251399)
  DATA: KZ_SMALL_UNIT(1) TYPE C.
* kz_update_unit ist gesetzt, wenn die gerade betrachtete ME geaendert
* wurde (wird zur Bestimmung von kz_small_unit benoetigt).
  DATA: KZ_UPDATE_UNIT(1) TYPE C.
  DATA: BME LIKE SMEINH,               "aktuelle Basis-ME
        OLD_BMEINH LIKE SMEINH-MEINH.  "alte Basis-ME, wenn geaendert

* Durchlaufen aller ME ausgehend von der Basismengeneinheit
* (Breitensuche in hierarchischen Baum). Ueberpruefung ob alle alterna-
* tiven ME von der Basis-ME erreichbar sind.
* meinh-kzsub kennzeichnet die durchlaufenen ME

* Bei Doppeleintraegen findet keine Berechnung der Umrechnungsfaktoren
* statt, da evtl. der falsche Eintrag modifiziert wird.
* in folgenden Fällen werden Fehlermeldungen unterdrueckt:
*  - wenn ein Eintrag geloescht wird, da sonst Fehlermeldung bzgl. des
*    gerade geloeschten Satzes moeglich.
*  - bei Doppeleinträgen
*  - bei Änderung der Basismengeneinheit

* Lesen Basismengeneinheit
  IF MARA-MEINS NE ME_BME and NOT ME_BME IS INITIAL.             "380673
                                               "Basis-ME wurde geaendert
    READ TABLE MEINH WITH KEY MEINH = ME_BME INTO BME.
    CHECK SY-SUBRC = 0.

*   jw/4.6B/19.08.99-A: alte Basis-ME als mesub gleich durch neue BME
*   ersetzen und in me_umre_berechnen immer die aktuelle Basis-ME nehmen
*   (sonst werden die Umrechnungsfaktoren bei Änderung der Basis-ME
*   nicht berechnet)
*   OLD_BMEINH = MARA-MEINS.
    bme-mesub = me_bme.
    loop at meinh into wa_meinh where mesub = mara-meins.
       wa_meinh-mesub = me_bme.
       modify meinh from wa_meinh.
    endloop.
*   jw/4.6B/19.08.99-E

  ELSE.
    READ TABLE MEINH WITH KEY MEINH = MARA-MEINS INTO BME.
    CHECK SY-SUBRC = 0.
  ENDIF.
  APPEND BME TO QUEUE_TAB.

  LOOP AT QUEUE_TAB INTO WA_MEINH.
    CLEAR KZ_UPDATE_UNIT.
*   Abfrage, ob sich Umrechnungsfaktoren geaendert haben
*   if wa_meinh-azsub is initial or
*   -> funktioniert nicht, wenn
*      0 < azsub < 0,0001, da azsub dann initial ist!!
*   deswegen steht in me_updateflg, ob sich ueberhaupt ein Satz
*   geaendert hat (siehe module smeinh-meinh)
    IF ( WA_MEINH-AZSUB IS INITIAL AND NOT ME_UPDATEFLG IS INITIAL ) OR
       WA_MEINH-UMREN IS INITIAL.
      KZ_UPDATE_UNIT = X.
    ENDIF.

*   Abgeleitete ME bestimmen
    LOOP AT MEINH INTO N_MEINH WHERE MESUB = WA_MEINH-MEINH.
      CHECK N_MEINH-MEINH NE WA_MEINH-MEINH.      "bme nicht nochmal
      CHECK N_MEINH-KZSUB IS INITIAL.  " ME bereits durchlaufen
                                       " Verhindert Endlosschleife
      APPEND N_MEINH TO QUEUE_TAB.
      IF NOT KZ_UPDATE_UNIT IS INITIAL."ME wurde geaendert
        SUB_UPDATEFLG = X.      "übergeord. MEs werden evtl. angepaßt
      ENDIF.
    ENDLOOP.

*   Pruefen Doppeleintrag
    COUNTER = 0.
    LOOP AT MEINH WHERE MEINH = WA_MEINH-MEINH.
      COUNTER = COUNTER + 1.
*        Alle (doppelten) Eintraege erhalten kzsub = x, damit
*        Zyklen / Endlosschleifen ausgeschlossen werden koennen
*        Es ist zwar möglich, dass die doppelten Eintraege bereits
*        in queue_tab stehen (mit kzsub initial), sie werden aber
*        nicht nochmal nach queue_tab geschrieben, falls Zyklen ex.
      MEINH-KZSUB = X.
      MODIFY MEINH.
      LINE = SY-TABIX.
    ENDLOOP.
*   Modifizieren der Umrechnungsfaktoren:
*   nur wenn keine Doppeleintraege existieren.
    IF COUNTER = 1.
      PERFORM ME_UMRE_BERECHNEN
                                using bme-meinh      "jw/4.6B/19.08.99
                                CHANGING WA_MEINH.
      WA_MEINH-KZSUB = X.
      MODIFY MEINH FROM WA_MEINH INDEX LINE.
      IF WA_MEINH-UMREN <> 0.                               "note1094150
        QUOTIENT = WA_MEINH-UMREZ / WA_MEINH-UMREN.
      ELSE.
        CLEAR QUOTIENT.
      ENDIF.
      IF NOT KZ_UPDATE_UNIT IS INITIAL AND
        QUOTIENT < 1.
        KZ_SMALL_UNIT = X.
      ENDIF.
    ELSE.
      DOPPELEINTRAG = X.
    ENDIF.
  ENDLOOP.

*-----FEHLERMELDUNGEN----------------------------------------------

* Suche nach ME, die in der oberen Loop nicht gefunden wurden
* nur wenn keine Doppeleintraege existieren, kein Loeschen, keine
* Änderung an der Basis-ME -> Fehlermeldungen 115(mm) od. 116(mm)
  IF DOPPELEINTRAG IS INITIAL
    AND RMMZU-OKCODE NE FCODE_MEDE
    AND MARA-MEINS = ME_BME.
    LOOP AT MEINH INTO WA_MEINH.
      IF WA_MEINH-KZSUB IS INITIAL.
        IF WA_MEINH-MESUB IS INITIAL.
          " wenn BME zu Anfang dieses Bildes noch nicht bekannt war!
*          bildflag = x.                " Bild wiederholen
        ELSE.
          CHECK BILDFLAG IS INITIAL.
          BILDFLAG = X.
          READ TABLE MEINH WITH KEY MEINH = WA_MEINH-MESUB.
          IF SY-SUBRC = 0.
*           Error: Bezug zur Basismengeneinheit fehlt (Zyklen).
            SAVMEINH = WA_MEINH-MEINH.
            ME_FEHLERFLG = SBMEINH.
            MESSAGE S115(MM) WITH WA_MEINH-MEINH.
          ELSE.
*           Error: MeSub nicht als alternative Mengeneinheit definiert.
            SAVMEINH = WA_MEINH-MEINH.
            ME_FEHLERFLG = SBMEINH.
            MESSAGE S116(MM) WITH WA_MEINH-MESUB.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR WA_MEINH-KZSUB.
        MODIFY MEINH FROM WA_MEINH.
      ENDIF.
    ENDLOOP.

    IF NOT KZ_SMALL_UNIT IS INITIAL AND BILDFLAG IS INITIAL
       AND LHMG_UPDATEFLG IS INITIAL.
      BILDFLAG = X.
      MESSAGE S129(MM).
*       Die Basismengeneinheit ist nicht die kleinste ME
*       Entwicklungsantrag 251399
*       Diese Warnung erscheint nicht, wenn geänderte ME = LHME, in die-
*       sem Fall erscheint die Warnung: LHMG wurde geaendert (s119 mm).
    ENDIF.

    IF NOT SUB_UPDATEFLG IS INITIAL AND BILDFLAG IS INITIAL
       AND LHMG_UPDATEFLG IS INITIAL.  "note 132233/jw 4.1.99
      BILDFLAG = X.
      MESSAGE S118(MM).
*       Zu der geänderten Mengeneinheit existieren übergeordnete Mengen
*       Diese Warnung erscheint nicht, wenn geänderte ME = LHME, in die-
*       sem Fall erscheint die Warnung: LHMG wurde geaendert (s119 mm).
    ENDIF.

* es ex. Doppeleintrag bzw. Okcode loeschen
  ELSE.
    LOOP AT MEINH INTO WA_MEINH.
      CLEAR WA_MEINH-KZSUB.
      MODIFY MEINH FROM WA_MEINH.
    ENDLOOP.
  ENDIF.

* jw/4.6B/19.08.99-A
* Löschen MESUB, wenn mesub = Basis-ME
*  IF OLD_BMEINH IS INITIAL.
    LOOP AT MEINH INTO WA_MEINH WHERE MESUB = BME-MEINH.
      CLEAR WA_MEINH-MESUB.
      MODIFY MEINH FROM WA_MEINH.
    ENDLOOP.
* Wenn BME gerade geaendert wurde, muss noch die alte BME geloescht
* werden
*  ELSE.
*    LOOP AT MEINH INTO WA_MEINH WHERE MESUB = OLD_BMEINH.
*      CLEAR WA_MEINH-MESUB.
*      MODIFY MEINH FROM WA_MEINH.
*    ENDLOOP.
*  ENDIF.
* jw/4.6B/19.08.99-E
ENDFORM.                               " ME_SUB_STRUKTUR_PRUEFEN

*----------------------------------------------------------------------
* FORM ME_UMRE_PRUEFEN
* jw, rel. 4.6A
*----------------------------------------------------------------------

FORM ME_UMRE_BERECHNEN CHANGING
                                value(bme) like mara-meins  "jw/4.6B
                                VALUE(P_MEINH) LIKE SMEINH.
* mesub ist hier nie initial (wird durch form me_sub_struktur_pruefen
* gewaehrleistet)
  DATA: SUB_MEINH LIKE SMEINH.
  DATA: ZAEHLER LIKE T006-ZAEHL,
        NENNER LIKE T006-NENNR.
  DATA: INPUT TYPE F.


  IF P_MEINH-UMREN IS INITIAL AND
     P_MEINH-UMREZ IS INITIAL.

*    Berechnung umren und umrez

*    jw/4.6B/19.08.99-A: falsch, wenn BME geändert wurde!
*    IF P_MEINH-MESUB = MARA-MEINS.
     if p_meinh-mesub = bme.
*    jw/4.6B/19.08.99-E
      MOVE P_MEINH-AZSUB TO INPUT.
      CALL FUNCTION 'CONVERT_TO_FRACTION'
           EXPORTING
              INPUT       = INPUT
           IMPORTING
              NOMINATOR   = ZAEHLER
              DENOMINATOR = NENNER
          EXCEPTIONS
              CONVERSION_OVERFLOW = 1
              OTHERS              = 2
             .
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      MOVE ZAEHLER TO P_MEINH-UMREZ.
      MOVE NENNER TO P_MEINH-UMREN.
    ELSE.
      READ TABLE MEINH WITH KEY MEINH = P_MEINH-MESUB INTO SUB_MEINH.
      CHECK SUB_MEINH-UMREN NE 0.      "sicherheitshalber
      INPUT = P_MEINH-AZSUB * SUB_MEINH-UMREZ / SUB_MEINH-UMREN.
      CALL FUNCTION 'CONVERT_TO_FRACTION'
           EXPORTING
                INPUT               = INPUT
           IMPORTING
                NOMINATOR           = ZAEHLER
                DENOMINATOR         = NENNER
           EXCEPTIONS
                CONVERSION_OVERFLOW = 1
*                 OTHERS              = 2
                .
      IF SY-SUBRC <> 0 AND BILDFLAG IS INITIAL.
*           input zu gross,
*           d.h. die aME besteht aus mehr als 99999 Basis-ME
        BILDFLAG = X.
        ME_FEHLERFLG = SBMEINH.
        SAVMEINH = P_MEINH-MEINH.
        MESSAGE S117(MM) WITH P_MEINH-MEINH.
      ELSE.
        MOVE ZAEHLER TO P_MEINH-UMREZ.
        MOVE NENNER TO P_MEINH-UMREN.
      ENDIF.
    ENDIF.

*else.                               passiert schon im naechsten PBO!
*    azsub ist initial und wird neu berechnet
*    umren und umrez sind nicht initial (lt. module smeinh-meinh)
*   if p_meinh-mesub = mara-meins.      "mesub = Basismengeneinheit
*      p_meinh-azsub = p_meinh-umrez / p_meinh-umren.
*   else.
*      read table meinh with key meinh = p_meinh-mesub
*              into sub_meinh.
*      p_meinh-azsub = ( p_meinh-umrez * sub_meinh-umren ) /
*                       ( p_meinh-umren * sub_meinh-umrez ).
*   endif.
  ENDIF.
ENDFORM.
