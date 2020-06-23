*&---------------------------------------------------------------------*
*&      Form  MEINH_FELDER_ANZEIGEN
*&---------------------------------------------------------------------*
*       Alle Felder der Mengeneinheiten werden zu Eingabe gesperrt.    *
*       EAN etc. bleiben eingabebereit.
*----------------------------------------------------------------------*
FORM MEINH_FELDER_ANZEIGEN USING KZBME.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP1 = '002' OR
       SCREEN-GROUP1 = '003' OR SCREEN-GROUP1 = '004'.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ELSEIF SCREEN-GROUP2 = '001' OR SCREEN-GROUP2 = '002' OR
           SCREEN-GROUP2 = '003' OR SCREEN-GROUP2 = '004'.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ENDIF.
* cfo/4.0-A
    IF SCREEN-GROUP2 = '005' AND KZBME IS INITIAL.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ELSEIF SCREEN-GROUP2 = '005' AND KZBME IS INITIAL.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ENDIF.
* cfo/4.0-E

  ENDLOOP.


ENDFORM.                               " MEINH_FELDER_ANZEIGEN
