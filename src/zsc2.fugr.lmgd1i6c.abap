*&---------------------------------------------------------------------*
*&      Module  UPDATE_HPEAN  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob sich die Haupt-EAN innerhalb einer Mengeneinheit
*       gegenüber dem MARM (MEINH) - und/oder MARA - Satz geändert hat.
*       Wenn ja, muß der MARM - Eintrag upgedatet werden, da dort
*       nur die Haupt-EAN gepflegt wird. Handelt es sich zusätzlich
*       noch um die Basismengeneinheit, muß auch der MARA - Satz
*       aktualisiert werden.
*       Dies wird für alle Mengeneinheiten durchgeführt.
*----------------------------------------------------------------------*
MODULE UPDATE_HPEAN INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_EAN ist gesetzt, wenn OKCODE mit "EADE" belegt.
* Das Module UPDATE_HPEAN hier muß beim Löschen
* ablaufen, darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_EAN IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  LOOP AT MEAN_ME_TAB.
    IF NOT MEAN_ME_TAB-HPEAN IS INITIAL OR   " Haupt-EAN gefunden
       ( MEAN_ME_TAB-HPEAN IS INITIAL   AND  " oder EAN zur Mengeneinh.
         MEAN_ME_TAB-EAN11 IS INITIAL   AND  " wurde gelöscht / ist leer
         MEAN_ME_TAB-NUMTP IS INITIAL   AND
     NOT MEAN_ME_TAB-MEINH IS INITIAL ).

      READ TABLE MEINH WITH KEY MEAN_ME_TAB-MEINH.
      IF SY-SUBRC = 0.                 " sollte hier immer so sein

        HTABIX = SY-TABIX.
        IF MEINH-EAN11 NE MEAN_ME_TAB-EAN11.
*         HPEAN wurde geändert --> MARM (MEINH) - Eintrag ändern
          MEINH-EAN11 = MEAN_ME_TAB-EAN11.
          MEINH-NUMTP = MEAN_ME_TAB-NUMTP.
          MODIFY MEINH INDEX HTABIX.
*         UPDKZ in PTAB setzen (nur sicherheitshalber)
          PERFORM SET_UPDATE_TAB USING T_MARM.

          IF NOT MEINH-KZBME IS INITIAL.
*         HPEAN bei Basismengeneinheit geändert --> MARA - Eintr. ändern
            MARA-EAN11 = MEAN_ME_TAB-EAN11.
            MARA-NUMTP = MEAN_ME_TAB-NUMTP.
*           UPDKZ in PTAB setzen (nur sicherheitshalber)
            PERFORM SET_UPDATE_TAB USING T_MARA.
          ENDIF.

        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                             " UPDATE_HPEAN  INPUT
