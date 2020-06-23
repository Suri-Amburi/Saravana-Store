*&---------------------------------------------------------------------*
*&      Form  PRUEFEN_KZME
*&---------------------------------------------------------------------*
*       Prüft, ob die Kennzeichen KZBME, KZBSTME, KZAUSME und KZVRKME  *
*       richtig gesetzt wurden.
*----------------------------------------------------------------------*
FORM PRUEFEN_KZME.

* Falls ME_BME, ME_BSTME, ME_AUSME, ME_VRKME noch initial sind,
* prüfen, ob KZBME, KZBSTME, KZAUSME, KZVRKME auf einer anderen als der
* aktuellen 'Seite' bereits gesetzt wurde.
  PERFORM KZME_GESETZT.

* Falls ME_BME, ME_BSTME, ME_AUSME, ME_VRKME nicht initial sind,
* prüfen, ob KZBME, KZBSTME, KZAUSME, KZVRKME auf einer anderen als der
* aktuellen 'Seite' bereits gesetzt wurde (Doppeleintrag -> Fehler).
  PERFORM KZME_DOPPELT.

* Vor Aufruf der nachfolgenden Prüfungen MEINH in Puffer setzen, weil
* in den Prüfungen aus Puffer gelesen wird.
  CALL FUNCTION 'MARM_SET_SUB'
       EXPORTING
            MATNR  = MARA-MATNR
       TABLES
            WMEINH = MEINH
       EXCEPTIONS
            OTHERS = 1.

* Prüfen, ob eine spezielle ME geändert wurde. Nach erfolgreicher
* Prüfung Daten nach MARA bzw. MAW1 übernehmen.
  PERFORM BME_GEAENDERT.
  PERFORM BSTME_GEAENDERT.
  PERFORM AUSME_GEAENDERT.
  PERFORM VRKME_GEAENDERT.

ENDFORM.                               " PRUEFEN_KZME
