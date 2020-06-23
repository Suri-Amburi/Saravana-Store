*&---------------------------------------------------------------------*
*&      Module  CHECK_NEW_MEINH  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob die evtl. neu eingegebenen Mengeneinheiten
*       schon zum Material / Artikel erfaßt wurden. Nur dann ist
*       ein solcher neuer Eintrag erlaubt.
*----------------------------------------------------------------------*
MODULE CHECK_NEW_MEINH INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
* CHECK BILDFLAG IS INITIAL.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_EAN ist gesetzt, wenn OKCODE mit "EADE" belegt.
* Das Module CHECK_NEW_MEINH muß trotz OKCODE "EADE" ablaufen
* darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_EAN IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  LOOP AT MEAN_ME_TAB.
    HTABIX = SY-TABIX.
    READ TABLE MEINH WITH KEY MEAN_ME_TAB-MEINH.

    IF SY-SUBRC NE 0 AND
       NOT MEAN_ME_TAB-MEINH IS INITIAL.
      CLEAR RMMZU-OKCODE.
      IF BILDFLAG IS INITIAL.
        BILDFLAG = X.
        EAN_FEHLERFLG_ME = X.   " darf nur gesetzt werden, wenn die
                                       " Zeile nicht gelöscht wird
        MESSAGE S758 WITH MEAN_ME_TAB-MEINH.
*       Mengeneinheit & zum Material ist nicht gepflegt
      ENDIF.
      MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH.  " Mengeneinh. merken
      MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.  " neu ! ! ! (27.10.95)

*     Wenn mit Löschbutton versucht wird, die falsche Zeile zu korr.,
*     wird sie gelöscht und das Flag wird zurückgesetzt.
      IF NOT FLAG_DEL_EAN IS INITIAL.
        CLEAR EAN_FEHLERFLG_ME.
        DELETE MEAN_ME_TAB.
      ENDIF.

      EXIT.
    ENDIF.

* wenn die Mengeneinheit noch nicht z. Material erfaßt wurde und nach
* obiger Meldung diese per Hand aus dem Feld gelöscht wird, wird die
* ganze Zeile gelöscht, allerdings nur, wenn die Zeile sonst auch leer
* ist. Wenn schon Eingaben in der Zeile vorhanden sind, wird eine
* Message ausgegeben.
    IF FLAG_DEL_EAN IS INITIAL AND
       MEAN_ME_TAB-MEINH IS INITIAL.

      IF MEAN_ME_TAB-EAN11 IS INITIAL AND
         MEAN_ME_TAB-NUMTP IS INITIAL.
        CLEAR EAN_FEHLERFLG_ME.
        DELETE MEAN_ME_TAB.
      ENDIF.

      IF NOT MEAN_ME_TAB-EAN11 IS INITIAL OR
         NOT MEAN_ME_TAB-NUMTP IS INITIAL.
        CLEAR RMMZU-OKCODE.
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          EAN_FEHLERFLG_ME = X.
          MESSAGE S578.
*       Bitte Mengeneinheit eingeben
        ENDIF.
        MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH.  " Mengeneinh. merken
        MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.

* restliche evtl. vorhandene Einträge zur nicht erlaubten Mengeneinheit
* rauslöschen.
* IF NOT MEAN_TAB_KEY-MEINH IS INITIAL.
*   LOOP AT MEAN_ME_TAB WHERE MEINH = MEAN_TAB_KEY-MEINH.
*     DELETE MEAN_ME_TAB.
*   ENDLOOP.
* ENDIF.

ENDMODULE.                             " CHECK_NEW_MEINH  INPUT
