*&---------------------------------------------------------------------*
*&      Form  KZME_GESETZT
*&---------------------------------------------------------------------*
* Falls ME_BME, ME_BSTME, ME_AUSME, ME_VRKME noch initial sind,
* prüfen, ob KZBME, KZBSTME, KZAUSME, KZVRKME auf einer anderen als der
* aktuellen 'Seite' bereits gesetzt wurde.
*----------------------------------------------------------------------*
FORM KZME_GESETZT.

* BasisME
  IF ME_BME IS INITIAL AND NOT MARA-MEINS IS INITIAL.
    READ TABLE MEINH WITH KEY MARA-MEINS.
    IF SY-SUBRC = 0 AND NOT MEINH-KZBME IS INITIAL.
      ME_BME = MARA-MEINS.
    ENDIF.
  ENDIF.

* BestellME
  IF ME_BSTME IS INITIAL AND NOT MARA-BSTME IS INITIAL.
    READ TABLE MEINH WITH KEY MARA-BSTME.
    IF SY-SUBRC = 0 AND NOT MEINH-KZBSTME IS INITIAL.
      ME_BSTME = MARA-BSTME.
    ENDIF.
  ENDIF.

* LieferME
  IF ME_AUSME IS INITIAL AND NOT MAW1-WAUSM IS INITIAL.
    READ TABLE MEINH WITH KEY MAW1-WAUSM.
    IF SY-SUBRC = 0 AND NOT MEINH-KZAUSME IS INITIAL.
      ME_AUSME = MAW1-WAUSM.
    ENDIF.
  ENDIF.

* VerkaufsME
  IF ME_VRKME IS INITIAL AND NOT MAW1-WVRKM IS INITIAL.
    READ TABLE MEINH WITH KEY MAW1-WVRKM.
    IF SY-SUBRC = 0 AND NOT MEINH-KZVRKME IS INITIAL.
      ME_VRKME = MAW1-WVRKM.
    ENDIF.
  ENDIF.

ENDFORM.                               " KZME_GESETZT
