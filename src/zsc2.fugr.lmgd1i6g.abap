*&---------------------------------------------------------------------*
*&      Module  DUB_DEL_EAN_ZUS  INPUT
*&---------------------------------------------------------------------*
*       zu löschende und doppelt eingetragene Sätze werden aus der
*       internen Tabelle entfernt.
*       Außerdem werden die evtl. gesetzten KZ HPEAN gelöscht für die
*       Mengeneinheiten, die keine EANs zugeordnet haben.
*       Falls zu einer Mengeneinheit die letzte EAN gelöscht werden
*       soll, wird dieser Satz nicht aus der Tabelle gelöscht, sondern
*       nur die Felder für EAN und EAN-Typ initialisiert. Grund:
*       Man muß die Möglichkeit haben, auch zu einer Mengeneinheit, die
*       noch keine EAN zugeordnet hat (entweder nach Löschen der letzten
*       EAN oder sie hatte noch keine EAN), EANs zu erfassen.
*----------------------------------------------------------------------*
MODULE DUB_DEL_EAN_ZUS INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_EAN ist gesetzt, wenn OKCODE mit "EADE" belegt.
* Das Module DUB_DEL_EAN hier muß beim Löschen
* ablaufen, darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_EAN IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  CLEAR: HILFS_EAN, HILFS_MEEIN.

* MEAN_ME_TAB_CHECK ist nur gesetzt, wenn das BILDFLAG initial ist.
  IF NOT MEAN_ME_TAB_CHECK IS INITIAL.
*   MEAN_ME_TAB ist noch zu bereinigen. D.h.: die "gelöschten"
*   (Felder EAN11 und NUMTP wurden initialisiert) oder
*   doppelt eingetragenen Sätze werden aus der Tabelle gelöscht
*   außerdem werden für MEINHs ohne EANs die KZ HPEAN gelöscht, da
*   eine nicht vorhandene EAN keine Haupt-Ean sein kann.

    LOOP AT MEAN_ME_TAB.
      HTABIX  = SY-TABIX + 1.
*     Fall: Löschen
      IF MEAN_ME_TAB-EAN11 IS INITIAL.
*       wenn EAN11 hier noch initial, dann soll gelöscht werden
        IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
*         Fall: Mengeneinheit ohne EAN --> HPEAN wird zurückgesetzt
          CLEAR MEAN_ME_TAB-HPEAN.
          MODIFY MEAN_ME_TAB.
        ENDIF.
        CLEAR MEAN_ME_BUF.
        READ TABLE MEAN_ME_TAB INDEX HTABIX INTO MEAN_ME_BUF.
*       Falls ein weiterer Satz zur selben Mengeneinheit existiert, kann
*       gelöscht werden, ansonsten bleibt der Satz mit den initialen
*       Feldern EAN11 und NUMTP bestehen. Bem.: Die Einträge mit den
*       leeren EANs zu einer Mengeneinheit stehen immer VOR denjenigen
*       mit gefüllter EAN (wegen Sortierung);
        IF MEAN_ME_BUF-MEINH EQ MEAN_ME_TAB-MEINH AND
           NOT MEAN_ME_TAB-MEINH IS INITIAL.    " siehe nächstes IF
          DELETE MEAN_ME_TAB.
        ENDIF.
* Fall: Die Mengeneinheit ist leer aber die restl. Felder sollen mit
* Löschbutton gelöscht werden.
        IF MEAN_ME_TAB-MEINH IS INITIAL.
          DELETE MEAN_ME_TAB.
        ENDIF.
      ENDIF.

*     Fall: Doppelter Eintrag ( zu einer Mengeneinheit wurde die selbe
*     EAN mehrfach erfaßt);
      IF  ( MEAN_ME_TAB-EAN11 = HILFS_EAN    AND
            NOT MEAN_ME_TAB-EAN11 IS INITIAL AND " neu ! ! ! (AHE)
*           (die "leeren" EANs werden schon beim Löschen behandelt)
            MEAN_ME_TAB-MEINH = HILFS_MEEIN ).  " neu ! ! ! (AHE)
        DELETE MEAN_ME_TAB.
      ELSE.
        HILFS_EAN   = MEAN_ME_TAB-EAN11.
        HILFS_MEEIN = MEAN_ME_TAB-MEINH.    " neu (AHE)
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDMODULE.                             " DUB_DEL_EAN_ZUS  INPUT
