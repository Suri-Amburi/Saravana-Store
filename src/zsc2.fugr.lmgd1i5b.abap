MODULE SKTEXT-MAKTX INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND  T130M-AKTYP NE AKTYPZ.

  IF SY-STEPL = 1.
    BILDFLAG_OLD = BILDFLAG.
  ENDIF.

  KT_AKT_ZEILE = KT_ERSTE_ZEILE + SY-STEPL.

  IF NOT RMMZU-KT_FLAG1 IS INITIAL.  "Kurztext aus Kopfzeile übernommen
    READ TABLE KTEXT INDEX 1.
    KTEXT-DOPFLG = X.
    MODIFY KTEXT INDEX KT_AKT_ZEILE.
    KT_FLAG2 = X.
  ENDIF.

  CLEAR RMMZU-KT_FLAG1.

  IF NOT KT_FLAG2 IS INITIAL.
    KT_AKT_ZEILE = KT_AKT_ZEILE + 1.
  ENDIF.

*-------Lesen aktuellen Eintrag----------------------------------
  READ TABLE KTEXT INDEX KT_AKT_ZEILE.

  IF SY-SUBRC = 0.

*-------Pruefen Eintrag, falls der Eintrag geaendert wurde-------
*    IF SKTEXT-SPRAS NE KTEXT-SPRAS OR SKTEXT-MAKTX NE KTEXT-MAKTX.
    CLEAR KTEXT-VERFLG.
    PERFORM PRUEFEN_EINTRAG.

*-------Sprache geaendert --> Behandeln wie neuer Eintrag--------
*       IF SKTEXT-SPRAS NE KTEXT-SPRAS.
    KTEXT-DOPFLG = X.
*       ENDIF.
*JH/17.03.99/KPr127600 (Anfang)
* Kundeneigene Felder für die MAKT werden im Dialog noch nicht richtig
* von der SKTEXT in die KTEXT übertragen -> anstatt MOVEs für die
* einzelnen Felder sollte mit einem MOVE-CORRESPONDING gearbeitet
* werden, wobei über die Zwischenstruktur HMAKT gegangen wird, damit
* nur die eigentlichen MAKT-Felder von der SKTEXT in die KTEXT
* übernommen werden und nicht die Steuerungsflags.
*   KTEXT-SPRAS = SKTEXT-SPRAS.
*   KTEXT-MAKTX = SKTEXT-MAKTX.
    MOVE-CORRESPONDING SKTEXT TO HMAKT.
    MOVE-CORRESPONDING HMAKT  TO KTEXT.
*JH/17.03.99/KPr127600 (Ende)

*-------Eintrag geloescht ==> setzen deleteflag -----------------
    IF SKTEXT-SPRAS = SPACE AND SKTEXT-MAKTX = SPACE.
      MOVE X TO KTEXT-DELFLG.
    ENDIF.

*-------interne Tabelle aktualisieren ---------------------------
    MODIFY KTEXT INDEX KT_AKT_ZEILE.
*    ELSE.

*-------Eintrag aus Referenz uebernommen ==> Pruefen Eintrag-----
*       IF KTEXT-VERFLG NE SPACE.
*          CLEAR KTEXT-VERFLG.
*          PERFORM PRUEFEN_EINTRAG.
*          MODIFY KTEXT INDEX KT_AKT_ZEILE.
*       ENDIF.
*    ENDIF.

*-------Neuer Eintrag aufgenommen ==> setzen Bearbeitungsflag------
  ELSE.
    CHECK SKTEXT-SPRAS NE SPACE OR SKTEXT-MAKTX NE SPACE.
    CLEAR KTEXT.
*JH/17.03.99/KPr127600 (Anfang)
*   KTEXT-SPRAS = SKTEXT-SPRAS.
*   KTEXT-MAKTX = SKTEXT-MAKTX.
    MOVE-CORRESPONDING SKTEXT TO HMAKT.
    MOVE-CORRESPONDING HMAKT  TO KTEXT.
*JH/17.03.99/KPr127600 (Ende)
    PERFORM PRUEFEN_EINTRAG.
    KTEXT-DOPFLG = X.
    APPEND KTEXT.
  ENDIF.

ENDMODULE.                             " SKTEXT-MAKTX  INPUT

*&---------------------------------------------------------------------*
*&      Module  SET_SKTEXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SKTEXT INPUT.

  KT_AKT_ZEILE = KT_ERSTE_ZEILE + SY-STEPL.

*-------Lesen vorherige Stand ----------------------------------
  READ TABLE KTEXT INDEX KT_AKT_ZEILE.

  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING KTEXT TO HMAKT.
    MOVE-CORRESPONDING HMAKT TO SKTEXT.
  ENDIF.

ENDMODULE.                 " SET_SKTEXT  INPUT

