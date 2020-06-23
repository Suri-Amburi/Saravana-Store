*-------------------------------------------------------------------
***INCLUDE LMGD1I12 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  SMEINH-MEINH  INPUT
*&---------------------------------------------------------------------*
*  Pruefen Eintrag.
*  Uebernehmen der Mengeneinheiten mit ihren Umrechnungsfaktoren in
*  die interne Tabelle MEINH.
*  Setzen Bearbeitungsflag, wenn es sich um einen neuen Eintrag handelt.
*----------------------------------------------------------------------*
MODULE SMEINH-MEINH INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  IF SY-STEPL = 1.
*-------Bildflag wir bei Blätter-Okcode außerhalb immer gesetzt, damit
*-------bei Blättern keine Warnungen kommen. Ist Blättern für diesen
*-------Subscreen bestimmt, Bildflag zurücksetzen.
    IF NOT BILDFLAG IS INITIAL AND
       ( RMMZU-OKCODE = FCODE_MEDE OR
         RMMZU-OKCODE = FCODE_MEPP OR
         RMMZU-OKCODE = FCODE_MEFP OR
         RMMZU-OKCODE = FCODE_MENP OR
         RMMZU-OKCODE = FCODE_MELP ).
      CLEAR BILDFLAG.
    ENDIF.
*-------Bildflag merken, weil Blättern nicht durchgeführt wird, wenn
*-------Bildflag außerhalb gesetzt wurde.
    ME_BILDFLAG_OLD = BILDFLAG.
*-------Flags für Fehlerbehandlung zurücksetzen
    IF ME_FEHLERFLG = FDMEINH.
      ME_FLG_DEL = ME_FEHLERFLG.
      ME_MEINH_DEL = SAVMEINH.
    ENDIF.
    CLEAR ME_FEHLERFLG.
    CLEAR ADDKOFLG.
    CLEAR SAVMEINH.
    CLEAR SAVMEINH2.
    CLEAR ME_UPDATEFLG.                "JW/4.6A
    CLEAR LHMG_UPDATEFLG.              "note 132233/jw 4.1.99
* AHE: 01.10.96 - A
*   CLEAR ME_EANERRFLG.
*   darf hier nicht initialisiert werden (Bsp.: Fehler ist in 1. Zeile)
*   --> verschoben in PBO-MODUL ME_INITIALISIERUNG
* AHE: 01.10.96 - E
    CLEAR ME_DOPPEINTRAG_GES.
  ENDIF.
  CLEAR ME_DOPPEINTRAG.                "wird je Zeile benötigt!
  ME_AKT_ZEILE = ME_ERSTE_ZEILE + SY-STEPL.

*-------Lesen aktuellen Eintrag----------------------------------
  READ TABLE MEINH INDEX ME_AKT_ZEILE.

  IF SY-SUBRC = 0.
*-------Prüfen, ob ME bereits in MEINH existiert (Doppeleintrag)
*-------Wenn ja, soll EAN-Prüfung nicht durchgeführt werden, da sonst
*-------Fehlverhalten möglich (ME_DOPPEINTRAG).
    LOOP AT MEINH.
      IF SY-TABIX GE ME_AKT_ZEILE.
        EXIT.
      ENDIF.
      IF MEINH-MEINH = SMEINH-MEINH.
        ME_DOPPEINTRAG = X.
        EXIT.
      ENDIF.
    ENDLOOP.
*-------Aktuelle Zeile nachlesen.--------------------------------
    READ TABLE MEINH INDEX ME_AKT_ZEILE.
*-------Im Falle daß BasisME von vorherigem Subscreen übernommen wurde,
*-------smeinh-meinh besetzen, damit ev. angegebene EAN übernommen wird.
    IF ME_AKT_ZEILE = 1 AND
       NOT MEINH-MEINH IS INITIAL AND
       SMEINH-MEINH IS INITIAL.
      SMEINH-MEINH = MEINH-MEINH.
    ENDIF.

*-------Umrechnung geaendert-------------------------------------
    IF SMEINH-UMREZ NE MEINH-UMREZ OR SMEINH-UMREN NE MEINH-UMREN
      OR SMEINH-AZSUB NE MEINH-AZSUB   " Rel. 4.6A JW
      OR SMEINH-MESUB NE MEINH-MESUB.  " Rel. 4.6A JW
      CLEAR MEINH-VERFLG.
      PERFORM ME_PRUEFEN_EINTRAG.

      ME_UPDATEFLG = X.          "4.6A JW: fuehrt zur Warnung, wenn
                                       "eine ME kleiner als Basis-me ist

      IF SMEINH-MEINH = MLGN-LHME1 OR  " note 132233
        SMEINH-MEINH = MLGN-LHME2 OR   " jw 04.01.99
        SMEINH-MEINH = MLGN-LHME3.     "lhmg wird geaendert
        LHMG_UPDATEFLG = X.            "Warnung ausgeben
      ENDIF.
*     Rel. 4.6A JW: sich nicht veränderte Faktoren werden geloescht und
*     in form me_sub_struktur_pruefen neu berechnet.
*     mögliche Änderungen: entweder in azsub/mesub oder in umren/umrez
      IF SMEINH-AZSUB = MEINH-AZSUB AND
        SMEINH-MESUB = MEINH-MESUB AND
        NOT ( SMEINH-UMREZ IS INITIAL OR
        SMEINH-UMREN IS INITIAL ).
        CLEAR SMEINH-AZSUB.            "azsub wird neu berechnet
      ELSEIF SMEINH-UMREZ = MEINH-UMREZ AND
        SMEINH-UMREN = MEINH-UMREN AND
        NOT SMEINH-AZSUB IS INITIAL.
        CLEAR SMEINH-UMREZ.            "umrez und umren
        CLEAR SMEINH-UMREN.            "werden neu berechnet
      ELSEIF ( SMEINH-UMREZ NE MEINH-UMREZ OR
        SMEINH-UMREN NE MEINH-UMREN ) AND     "beides geaendert
        ( SMEINH-AZSUB NE MEINH-AZSUB OR
        SMEINH-MESUB NE MEINH-MESUB ).
        IF NOT SMEINH-AZSUB IS INITIAL.
          CLEAR SMEINH-UMREZ.          "umrez und umren
          CLEAR SMEINH-UMREN.          "werden neu berechnet
        ENDIF.
      ENDIF.
      MOVE SMEINH-UMREZ TO MEINH-UMREZ.
      MOVE SMEINH-UMREN TO MEINH-UMREN.
      MOVE SMEINH-AZSUB TO MEINH-AZSUB."Rel. 4.6A JW
      MOVE SMEINH-MESUB TO MEINH-MESUB."Rel. 4.6A JW
      MODIFY MEINH INDEX ME_AKT_ZEILE.
    ELSE.

*-------Uebernahme aus Referenz ==> Eintrag pruefen--------------
      IF MEINH-VERFLG NE SPACE OR MEINH-DOPFLG NE SPACE.
        IF MEINH-VERFLG NE SPACE.      "Rel. 4.6A JW
          ME_UPDATEFLG = X.            "Rel. 4.6A JW
        ENDIF.
        CLEAR MEINH-VERFLG.
        PERFORM ME_PRUEFEN_EINTRAG.
        MOVE SMEINH-UMREZ TO MEINH-UMREZ.
        MOVE SMEINH-UMREN TO MEINH-UMREN.
        MOVE SMEINH-AZSUB TO MEINH-AZSUB.              "Rel. 4.6A JW
        MOVE SMEINH-MESUB TO MEINH-MESUB.              "Rel. 4.6A JW
        MODIFY MEINH INDEX ME_AKT_ZEILE.
      ENDIF.
    ENDIF.

*-------Neuer Eintrag aufgenommen ==> setzen Bearbeitungsflag----
  ELSE.
*-------Prüfen, ob Doppeleintrag.
*-------Wenn ja, soll EAN-Prüfung nicht durchgeführt werden, da sonst
*-------Fehlverhalten möglich (vgl. ME_DOPPEINTRAG).
    READ TABLE MEINH WITH KEY SMEINH-MEINH.
    IF SY-SUBRC = 0.
      ME_DOPPEINTRAG = X.
    ENDIF.
    CLEAR MEINH.
    PERFORM ME_PRUEFEN_EINTRAG.
    CHECK SMEINH-MEINH NE SPACE.
    ME_UPDATEFLG = X.                  "Rel. 4.6A JW
*   Rel. 4.6A JW: Wenn sowohl umren/umrez als auch azsub/mesub eigegeben
*   wurden, zieht azsub/mesub
    IF ( NOT SMEINH-UMREN IS INITIAL OR
         NOT SMEINH-UMREZ IS INITIAL ) AND
       ( NOT SMEINH-AZSUB IS INITIAL ).
      CLEAR SMEINH-UMREZ.              "umrez und umren
      CLEAR SMEINH-UMREN.              "werden neu berechnet
    ENDIF.
    MOVE SMEINH-MEINH TO MEINH-MEINH.
    MOVE SMEINH-UMREZ TO MEINH-UMREZ.
    MOVE SMEINH-UMREN TO MEINH-UMREN.
    MOVE SMEINH-AZSUB TO MEINH-AZSUB.  "Rel. 4.6A JW
    MOVE SMEINH-MESUB TO MEINH-MESUB.  "Rel. 4.6A JW
    MEINH-DOPFLG = X.
*-------Falls Basismengeneinheit im Step-Loop erfaßt wurde, wird der
*-------erste Eintrag als BasisMe interpretiert.
    IF ME_AKT_ZEILE = 1 AND MARA-MEINS IS INITIAL.
      MEINH-KZBME = X.
      MEINH-UMREZ = 1.
      MEINH-UMREN = 1.
      MEINH-AZSUB = 1.                 "Rel. 4.6A JW
      MEINH-MESUB = SMEINH-MEINH.      "Rel. 4.6A JW
      ME_BME = SMEINH-MEINH.
    ENDIF.
    APPEND MEINH.
    ME_AKT_ZEILE = SY-TABIX.   "cfo/7.1.97 falls leere Zeilen zw. den
                               "erfaßten Zeilen, akt. Zeile neu erm.
                                       "CSP-Meldung 1002027 1997
  ENDIF.
  IF NOT ME_DOPPEINTRAG IS INITIAL.
    ME_DOPPEINTRAG_GES = X.
  ENDIF.

ENDMODULE.                             " SMEINH-MEINH  INPUT
