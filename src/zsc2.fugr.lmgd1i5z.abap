*&---------------------------------------------------------------------*
*&      Module  ME_SETZEN_NACHRICHT  INPUT
*&---------------------------------------------------------------------*
*  Pruefen der internen Tabelle auf doppelte Eintraege.
*  Setzen haengende Nachricht, falls doppelte Eintraege gefunden wurden.
*  Konsistenzprüfung durchführen (Umrechung zwischen den MEs).
*----------------------------------------------------------------------*
MODULE ME_SETZEN_NACHRICHT INPUT.

  IF T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
* Kein CHECK möglich, da noch weitere Anweisungen außerhalb der IF-Anw.!
*   CLEAR ME_FEHLERFLG.     cfo/13.2.96/ wird in smeinh-meinh zurückges.
*   CLEAR ADDKOFLG.                      weil bereits in smeinh-kzme
*   CLEAR SAVMEINH.                      benutzt
*   CLEAR SAVMEINH2.
*-----Pruefen doppelten Eintrag-------------------------------------
    IF ME_FEHLERFLG = SPACE AND BILDFLAG IS INITIAL.
      CLEAR: ME_FLG_DEL, ME_MEINH_DEL. "cfo/20.2.96/zum merken, wenn
                                       "dopp. ME gelöscht werden darf
*-----Prüfung nur durchführen, wenn Bildflag noch nicht gesetzt wurde.
      LOOP AT MEINH.
*-----Prüfung nur durchführen, wenn Eintrag noch nicht geprüft wurde.
        IF MEINH-DOPFLG NE SPACE.
          PERFORM ME_PRUEFEN_DOPEINTRAG.
        ENDIF.
      ENDLOOP.
*-----Ausgeben Fehlernachricht - doppelter Eintrag------------------
      IF ME_FEHLERFLG NE SPACE.
*       CLEAR RMMZU-OKCODE.    "cfo/13.1.97 wird nicht benötigt
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          MESSAGE S331 WITH SAVMEINH.
        ENDIF.
      ENDIF.
    ENDIF.

*-----Durchführen der Konsistenzprüfung
*-----Prüfung nur durchführen, wenn Bildflag noch nicht gesetzt wurde.
    IF ME_FEHLERFLG = SPACE AND BILDFLAG IS INITIAL.
      PERFORM KONSISTENZ_PRUEFEN.
      IF ME_FEHLERFLG NE SPACE. "Feldüberlauf bei Konsistenzprüfung
*       CLEAR RMMZU-OKCODE.       "cfo/20.1.97 wird nicht benötigt
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          MESSAGE S027 WITH SAVMEINH.
        ENDIF.
      ENDIF.
*---- Prf. ob gültige Umrechnung (d.h. ohne additive Konst.) 09.09.94/CH
      IF ADDKOFLG NE SPACE. "Feldüberlauf bei Konsistenzprüfung
*       CLEAR RMMZU-OKCODE.       "cfo/20.1.97 wird nicht benötigt
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          MESSAGE S563 WITH SAVMEINH SAVMEINH2.
        ENDIF.
      ENDIF.
    ENDIF.
*---- Prüfung, ob ME-Umrechnung geändert und ME bereits benutzt.
*---- cfo/28.10.96
    IF ME_FEHLERFLG = SPACE AND BILDFLAG IS INITIAL
       AND NOT RMMG2-FLG_RETAIL IS INITIAL.
*-----Prüfung nur durchführen, wenn Bildflag noch nicht gesetzt wurde.
      IF RET_MEINH[] IS INITIAL.
        RET_MEINH[] = LMEINH[].
      ENDIF.
      LOOP AT MEINH.
        READ TABLE RET_MEINH WITH KEY MEINH-MEINH.
        IF ( SY-SUBRC = 0 ) AND
           ( RET_MEINH-UMREN NE MEINH-UMREN OR
             RET_MEINH-UMREZ NE MEINH-UMREZ ).
          PERFORM ME_PRUEFEN_VERWENDUNG USING RET_MEINH
                                              MEINH
                                              X.            "1.2B3
        ENDIF.
      ENDLOOP.
      RET_MEINH[] = MEINH[].
    ENDIF.

  ENDIF.

* JW 21.12.98: LHM-Mengen neu berechnen
  PERFORM ME_LHMG_NEUBERECHNEN.

* jw/4.6A/03.03.99: Volumen berechnen
  perform me_volumen_berechnen.

* Anzahl Zeilen der Tabelle ermitteln, da für Blättern benötigt.
  READ TABLE MEINH INDEX 1.
*----- Eintrag vorhanden --------------------------------
  IF SY-SUBRC = 0.
    ME_LINES = SY-TFILL.
*----- Kein Eintrag vorhanden ---------------------------
  ELSE.
    ME_LINES = 0.
  ENDIF.

* AHE: 16.07.96 - A
* Umstellung auf Table-Control
  IF NOT FLG_TC IS INITIAL.
    CASE SY-DYNNR.
      WHEN DP_8020.
        TC_ME_8020-LINES = ME_LINES.

      WHEN DP_8021.
        TC_ME_8021-LINES = ME_LINES.

    WHEN DP_8022.                        "jw/20.11.98
        TC_ME_8022-LINES = ME_LINES.
    ENDCASE.
  ENDIF.
* AHE: 16.07.96 - E

ENDMODULE.                             " ME_SETZEN_NACHRICHT  INPUT
