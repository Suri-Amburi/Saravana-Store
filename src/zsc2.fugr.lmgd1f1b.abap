*&---------------------------------------------------------------------*
*&      Form  MEINH_ANZEIGEN
*&---------------------------------------------------------------------*
*    Im Erweiterungsfall werden die Umrechnungsfaktoren, der Mengen-   *
*    einheiten, die ueber die Eingabe einer Alternativmengeneinheit    *
*    auf den normalen Datenbildern gepflegt wurden, eingabebereit.     *
*----------------------------------------------------------------------*
FORM MEINH_ANZEIGEN.

  LOOP AT SCREEN.
*   IF SCREEN-GROUP1 = '001'.
*     Mengeneinheit, KZBME und Nettogewicht werden inaktiv gesetzt
    IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP1 = '004'
       OR SCREEN-GROUP1 = '005'.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ELSEIF SCREEN-GROUP2 = '001' OR SCREEN-GROUP2 = '004'  "mk/4.0A
           OR SCREEN-GROUP2 = '005'.
      if screen-group2 = '004' and
         mara-meins is initial.                  "BME eingabebereit
         screen-input = 1.
         screen-required = 0.
         modify screen.
      else.
         SCREEN-INPUT    = 0.
         SCREEN-REQUIRED = 0.
         MODIFY SCREEN.
      endif.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " MEINH_ANZEIGEN
