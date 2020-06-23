*&---------------------------------------------------------------------*
*&      Form  KONSISTENZ_PRUEFEN
*&---------------------------------------------------------------------*
*  Es wird geschaut, ob eine Beziehung zur Basismengeneinheit nicht
*  aus der schon bestehenden Beziehung einer anderen Alternativmengen-
*  einheit zur Basismengeneinheit hergeleitet kann.
*  Dazu wird über die Tabelle MEINH geloopt und überprüft, ob die
*  aktuelle Beziehung trivial ist ( z.B. 1kg=1000g ) oder aus einer
*  Beziehung, die vor der aktuellen Beziehung in der MEINH liegt
*  hergeleitet werden kann.
*----------------------------------------------------------------------*
FORM KONSISTENZ_PRUEFEN.

  DATA: ZAEHLER_ALT TYPE F,
        NENNER_ALT TYPE F.

  DATA NEW_MEINH like smeinh occurs 0.                      "note 683534
  DATA CHANGED_MEINH like smeinh occurs 0 with header line. "note 822933
  LOOP AT MEINH.
    READ TABLE OLD_MEINH WITH KEY MEINH = MEINH-MEINH.      "note 700229
    IF SY-SUBRC NE 0.
      APPEND MEINH TO NEW_MEINH.
      DELETE MEINH.
    ELSEIF SY-SUBRC EQ 0 AND                                "note 822933
       ( OLD_MEINH-UMREN NE MEINH-UMREN OR
         OLD_MEINH-UMREZ NE MEINH-UMREZ ).
      APPEND MEINH TO CHANGED_MEINH.
      DELETE MEINH.
    ENDIF.
  ENDLOOP.
  sort meinh by meinh ASCENDING.                            "note 697981
  APPEND LINES OF NEW_MEINH TO MEINH.
  LOOP AT CHANGED_MEINH.                                    "note 822933
    INSERT CHANGED_MEINH INTO MEINH INDEX SY-TABIX.
  ENDLOOP.
  NOT_SET_OLD_MEINH = 'N'.                                  "note 700229

  LOOP AT MEINH.
    CHECK MEINH-KZBME IS INITIAL.      "ME ungleich Basis-ME

    ME_ZAEHLER = SY-TABIX.
*-- keine Untersuchung bei dimensionsloser Mengeneinheit
    CALL FUNCTION 'DIMENSIONCHECK_DIMENSIONLESS'
         EXPORTING
              MEINH                       = MEINH-MEINH
         EXCEPTIONS
              DIMENSION_NOT_DIMENSIONLESS = 01
              OTHERS                      = 02.
    CHECK SY-SUBRC = '01'.

*   als FBAU umgeschrieben, da mehrfach benutzt. cfo/03.07.95
    CALL FUNCTION 'DIMENSIONCHECK_CONVERTABLE'
         EXPORTING
              P_BAS_MEINH      = MARA-MEINS
              P_ALT_MEINH      = MEINH-MEINH
              P_ZAEHLER        = ME_ZAEHLER
         IMPORTING
              P_ADDKO          = HADDKO
              P_UMREZ          = Z_UMREZ
              P_UMREN          = Z_UMREN
              P_SAVMEINH       = SAVMEINH2
         TABLES
              MEINH            = MEINH
         EXCEPTIONS
              NOT_CONVERTABLE  = 01
              OVERFLOW         = 02
              UNIT_NOT_ALLOWED = 03.

    IF SY-SUBRC = 2.                   "Fehlerfall: Feldüberlauf
*-- SAVMEINH2 ist die weiter oben in der Tabelle stehende Mengeneinheit
*-- mit der die aktuelle ME kollidiert
      READ TABLE MEINH INDEX ME_ZAEHLER.
      MOVE ULMEINH     TO ME_FEHLERFLG.
      MOVE MEINH-MEINH TO SAVMEINH.
      EXIT.
    ENDIF.

* Anteils-/ProduktME mit Dimension JHI/25.09.1998
    IF SY-SUBRC = 3.
* AnteilsProduktME / AlternativME gleicher Dimension vorhanden
      BILDFLAG = X.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Anteils-/ProduktME mit Dimension JHI/25.09.1998

    IF SY-SUBRC = 0.    "Beziehung kann erfolgreich hergeleitet werden
*-- Eintrag nachlesen
      READ TABLE MEINH INDEX ME_ZAEHLER.
*      Prüfen, ob ohne additive Konstante hergeleitet werden kann
*      (nur wenn ME neu hinzugefügt wurde)        09.08.94 / CH
      READ TABLE DMEINH WITH KEY MEINH-MEINH.
      IF SY-SUBRC NE 0 AND HADDKO <> 0.
        MOVE MEINH-MEINH TO SAVMEINH.
        ADDKOFLG = X.
        EXIT.
      ENDIF.

      IF MEINH-UMREN NE Z_UMREN OR MEINH-UMREZ NE Z_UMREZ.
*       CLEAR RMMZU-OKCODE.      "cfo/20.1.97 wird nicht benötigt
        BILDFLAG = X.
        MESSAGE S028(M3).
      ENDIF.

      MEINH-UMREN = Z_UMREN. "das Ergebnis steht in Z_UMREN, Z_UMREZ
      MEINH-UMREZ = Z_UMREZ.
      MODIFY MEINH.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " KONSISTENZ_PRUEFEN
