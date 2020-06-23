*&---------------------------------------------------------------------*
*&      Form  ME_PRUEFEN_EINTRAG
*&---------------------------------------------------------------------*
*  - Wurde eine gueltige Mengeneinheit eingegeben
*  - Alternativmengeneinheit muss ungleich der Basismengeneinheit sein
*  - Ist Mengeneinheit gesetzt, so muss auch ein Umrechnungsfaktor
*    gesetzt werden.
*  - Wird nur der Zaehler oder Nenner der Umrechnung gesetzt, so wird
*    der nicht angegebene Teil auf 1 gesetzt.
*----------------------------------------------------------------------*
FORM ME_PRUEFEN_EINTRAG.

  DATA: HMEINH LIKE SMEINH.

  IF SMEINH-UMREZ = 0 AND SMEINH-UMREN NE 0.
    SMEINH-UMREZ = '1'.
  ELSE.
    IF SMEINH-UMREN = 0 AND SMEINH-UMREZ NE 0.
      SMEINH-UMREN = '1'.
    ENDIF.
  ENDIF.

  MEINH-VERFLG = AKTYPR.
  CHECK RMMZU-OKCODE NE FCODE_MEDE.
  CLEAR MEINH-VERFLG.

*------Prüfung, ob andere Werte gefüllt aber ME nicht.------------------
  IF SMEINH-MEINH IS INITIAL AND
     ( NOT SMEINH-UMREZ IS INITIAL OR
     NOT SMEINH-UMREN IS INITIAL OR
     NOT SMEINH-EAN11 IS INITIAL OR
     NOT SMEINH-NUMTP IS INITIAL OR
     NOT SMEINH-AZSUB IS INITIAL OR    "Rel. 4.6A JW
     NOT SMEINH-MESUB IS INITIAL ).    "Rel. 4.6A JW
* Restliche Felder können hier nicht geprüft werden, da nicht auf
* Kurzbild enthalten.
*   CLEAR RMMZU-OKCODE.      "cfo/20.1.97 wird nicht benötigt
    CHECK BILDFLAG IS INITIAL.
* Hier einfacher mit E-Meldung (Zeilen ohne Schlüssel in MEINH
* machen Probleme). Nachteil: Fehlerhafte Zeile kann nicht gelöscht
* werden.
    MESSAGE E578(M3).
  ENDIF.

*------Umrechnungsfaktoren gesetzt------------------------------------
  CHECK SMEINH-MEINH NE SPACE.
  IF SMEINH-UMREZ = 0 AND SMEINH-UMREN = 0
     AND SMEINH-AZSUB = 0              "Rel. 4.6A JW
*     AND SMEINH-KZBME IS INITIAL.      "JW/4.6A
     and mara-meins ne smeinh-meinh.       "jw/5.0/26.09.00/note 335937
*   CLEAR RMMZU-OKCODE.      "cfo/20.1.97 wird nicht benötigt
    CHECK BILDFLAG IS INITIAL.
* Hier einfacher mit E-Meldung. Nachteil: Fehlerhafte Zeile kann
* nicht gelöscht werden.
    MESSAGE E333(M3) WITH SMEINH-MEINH.
  ENDIF.

*-----Submengeneinheit setzen----------------------------------------
*     Erw. zu Rel.4.6A JW
  IF SMEINH-AZSUB IS INITIAL AND SMEINH-MESUB IS INITIAL.
    IF NOT MARA-MEINS IS INITIAL.
      SMEINH-MESUB = MARA-MEINS.
    ELSEIF NOT ME_BME IS INITIAL.      "Basis-Me wurde in diesem Loop
      SMEINH-MESUB = ME_BME.           "erfasst.
    ENDIF.
  ENDIF.

*-----Submengeneinheit gesetzt?---------------------------------------
*     Erw. zu Rel.4.6A JW

  IF SMEINH-AZSUB NE 0 AND SMEINH-MESUB IS INITIAL
     AND ME_AKT_ZEILE <> 1.
    MESSAGE E114(MM) WITH SMEINH-MEINH.
  ENDIF.


*-----Chargenspez. ME sind als Submengeneinheit nicht erlaubt-------
*     Erw. zu Rel.4.6A JW
  CHECK NOT SMEINH-MESUB IS INITIAL.
  READ TABLE MEINH WITH KEY MEINH = SMEINH-MESUB INTO HMEINH.
  IF SY-SUBRC = 0
    AND NOT HMEINH-KZWSO IS INITIAL.
    MESSAGE E322(MM) WITH SMEINH-MESUB.
  ENDIF.

ENDFORM.                               " ME_PRUEFEN_EINTRAG
