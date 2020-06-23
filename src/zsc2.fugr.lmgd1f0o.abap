*&---------------------------------------------------------------------*
*&      Form  KZME_DOPPELT
*&---------------------------------------------------------------------*
* Falls ME_BME, ME_BSTME, ME_AUSME, ME_VRKME nicht initial sind,
* prüfen, ob KZBME, KZBSTME, KZAUSME, KZVRKME auf einer anderen als der
* aktuellen 'Seite' bereits gesetzt wurde (Doppeleintrag -> Fehler).
* Falls KZBSTME, KZAUSME, KZVRKME auf einer anderen Seite bei der Basis-
* ME gesetzt sind, so wird dort die kennung aufgehoben und die neue
* Kennzeichnung geht vor. Auf diese Weise ist es möglich, die spezielle
* ME umzusetzen, wenn die MEs auf unterschiedlichen Seiten liegen.
*----------------------------------------------------------------------*
FORM KZME_DOPPELT.

* cfo/6.9.96 doppelte Kennzeichen zurücksetzen, da sonst Fehler bei
* Radiobuttons.

* BasisME
  IF NOT ME_BME IS INITIAL AND ME_BME NE MARA-MEINS AND
     NOT MARA-MEINS IS INITIAL.
    READ TABLE MEINH WITH KEY MARA-MEINS.
    IF SY-SUBRC = 0 AND NOT MEINH-KZBME IS INITIAL.
      CLEAR MEINH-KZBME.
      MODIFY MEINH INDEX SY-TABIX.
    ENDIF.
  ELSEIF ME_DOPPEINTRAG_GES = X.       "cfo/6.9.96-A
    CLEAR ZAEHLER.
    LOOP AT MEINH WHERE MEINH = ME_BME.
      IF NOT MEINH-KZBME IS INITIAL.
        ZAEHLER = ZAEHLER + 1.
      ENDIF.
      IF ZAEHLER > 1.
        CLEAR MEINH-KZBME.
        MODIFY MEINH.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "cfo/6.9.96-E

* BestellME
  IF NOT ME_BSTME IS INITIAL AND ME_BSTME NE MARA-BSTME.
    IF NOT MARA-BSTME IS INITIAL.
*     Kennung bei alter BSTME löschen.
*     Falls MEs doppelt erfaßt wurden, wird die erste gelöscht.
      READ TABLE MEINH WITH KEY HMEINH.
      IF SY-SUBRC = 0 AND NOT MEINH-KZBSTME IS INITIAL.
        CLEAR MEINH-KZBSTME.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
    ELSEIF ME_BSTME NE MARA-MEINS AND NOT MARA-MEINS IS INITIAL.
*     Falls alte BSTME gleich MARA-MEINS, KZBSTME bei MARA-MEINS löschen
*     und neue BSTME übernehmen. So kann KZ auf unterschiedlichen Seiten
*     gesetzt werden.
      READ TABLE MEINH WITH KEY MARA-MEINS.
      IF SY-SUBRC = 0.
        CLEAR MEINH-KZBSTME.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ELSEIF ME_DOPPEINTRAG_GES = X.       "cfo/6.9.96-A
    CLEAR ZAEHLER.
    LOOP AT MEINH WHERE MEINH = ME_BSTME.
      IF NOT MEINH-KZBSTME IS INITIAL.
        ZAEHLER = ZAEHLER + 1.
      ENDIF.
      IF ZAEHLER > 1.
        CLEAR MEINH-KZBSTME.
        MODIFY MEINH.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "cfo/6.9.96-E

* LieferME
  IF NOT ME_AUSME IS INITIAL AND ME_AUSME NE MAW1-WAUSM.
    IF NOT MAW1-WAUSM IS INITIAL.
*     Falls AUSME ungleich MARA-MEINS, Kennung bei alter AUSME löschen.
*     Falls MEs doppelt erfaßt wurden, wird die erste gelöscht.
      READ TABLE MEINH WITH KEY MAW1-WAUSM.
      IF SY-SUBRC = 0 AND NOT MEINH-KZAUSME IS INITIAL.
        CLEAR MEINH-KZAUSME.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
    ELSEIF ME_AUSME NE MARA-MEINS AND NOT MARA-MEINS IS INITIAL.
*     Falls alte AUSME gleich MARA-MEINS, KZAUSME bei MARA-MEINS löschen
*     und neue AUSME übernehmen. So kann KZ auf unterschiedlichen Seiten
*     gesetzt werden.
      READ TABLE MEINH WITH KEY MARA-MEINS.
      IF SY-SUBRC = 0.
        CLEAR MEINH-KZAUSME.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ELSEIF ME_DOPPEINTRAG_GES = X.       "cfo/6.9.96-A
    CLEAR ZAEHLER.
    LOOP AT MEINH WHERE MEINH = ME_AUSME.
      IF NOT MEINH-KZAUSME IS INITIAL.
        ZAEHLER = ZAEHLER + 1.
      ENDIF.
      IF ZAEHLER > 1.
        CLEAR MEINH-KZAUSME.
        MODIFY MEINH.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "cfo/6.9.96-E

* VerkaufsME
  IF NOT ME_VRKME IS INITIAL AND ME_VRKME NE MAW1-WVRKM.
    IF NOT MAW1-WVRKM IS INITIAL.
*     Falls VRKME ungleich MARA-MEINS, Kennung bei alter VRKME löschen.
*     Falls MEs doppelt erfaßt wurden, wird die erste gelöscht.
      READ TABLE MEINH WITH KEY MAW1-WVRKM.
      IF SY-SUBRC = 0 AND NOT MEINH-KZVRKME IS INITIAL.
        CLEAR MEINH-KZVRKME.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
    ELSEIF ME_VRKME NE MARA-MEINS AND NOT MARA-MEINS IS INITIAL.
*     Falls alte VRKME gleich MARA-MEINS, KZVRKME bei MARA-MEINS löschen
*     und neue VRKME übernehmen. So kann KZ auf unterschiedlichen Seiten
*     gesetzt werden.
      READ TABLE MEINH WITH KEY MARA-MEINS.
      IF SY-SUBRC = 0.
        CLEAR MEINH-KZVRKME.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ELSEIF ME_DOPPEINTRAG_GES = X.       "cfo/6.9.96-A
    CLEAR ZAEHLER.
    LOOP AT MEINH WHERE MEINH = ME_VRKME.
      IF NOT MEINH-KZVRKME IS INITIAL.
        ZAEHLER = ZAEHLER + 1.
      ENDIF.
      IF ZAEHLER > 1.
        CLEAR MEINH-KZVRKME.
        MODIFY MEINH.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "cfo/6.9.96-E

ENDFORM.                               " KZME_DOPPELT
