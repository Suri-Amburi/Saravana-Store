
*------------------------------------------------------------------
*allg. Formroutinen für die spezielle Help-Module zur Eingabehilfe
*------------------------------------------------------------------

*------------------------------------------------------------------
* Setzen des Kennzeichen DISPLAY für die selbstprogrammierte Hilfe
*------------------------------------------------------------------
FORM SET_DISPLAY.

DATA: SET_DISP_FIELD LIKE T130R-FNAME.
DATA: SET_DISP_LINE  LIKE SY-TABIX.

* IF T130M-AKTYP EQ AKTYPA OR T130M-AKTYP EQ AKTYPZ.  " ausge*nt für
*   DISPLAY = X.                                      " Keyfelder
* ELSE.                                               " //br101195
    GET CURSOR FIELD SET_DISP_FIELD LINE SET_DISP_LINE.
    CLEAR DYNPFIELDS. REFRESH DYNPFIELDS.
    DYNPFIELDS-FIELDNAME = SET_DISP_FIELD.
    DYNPFIELDS-STEPL     = SET_DISP_LINE.
    APPEND DYNPFIELDS.
*   Lesen des akt. Wertes von Dynpro
    SY_REPID = SY-REPID.
    SY_DYNNR = SY-DYNNR.
    CALL FUNCTION 'DYNP_VALUES_READ'
         EXPORTING
              DYNAME               = SY_REPID
              DYNUMB               = SY_DYNNR
         TABLES
              DYNPFIELDS           = DYNPFIELDS
         EXCEPTIONS
              OTHERS               = 01.
    IF SY-SUBRC = 0.
      READ TABLE DYNPFIELDS INDEX 1.
      IF DYNPFIELDS-FIELDINP IS INITIAL.
        DISPLAY = X.
      ELSE.
        CLEAR DISPLAY.
      ENDIF.
    ELSE.
      CLEAR DISPLAY.
    ENDIF.
* ENDIF.

ENDFORM.         " SET_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  GET_VALUE_FROM_SCREEN
*&---------------------------------------------------------------------*
FORM GET_VALUE_FROM_SCREEN USING FIELD VALUE STEPL.

    CLEAR DYNPFIELDS. REFRESH DYNPFIELDS.
    DYNPFIELDS-FIELDNAME = FIELD.
    DYNPFIELDS-STEPL     = STEPL.
    APPEND DYNPFIELDS.
*   Lesen des akt. Wertes von Dynpro
    SY_REPID = SY-REPID.
    SY_DYNNR = SY-DYNNR.
    CALL FUNCTION 'DYNP_VALUES_READ'
         EXPORTING
              DYNAME               = SY_REPID
              DYNUMB               = SY_DYNNR
*             perform_conversion_exits = 'X' " geht leider (noch) nicht
         TABLES
              DYNPFIELDS           = DYNPFIELDS
         EXCEPTIONS
              OTHERS               = 01.
    IF SY-SUBRC = 0.
      READ TABLE DYNPFIELDS INDEX 1.
      VALUE = DYNPFIELDS-FIELDVALUE.
* note 331039 auch Abfrage auf MEAN-MATNR, da die Nummer im Bild
* SAPLMGD2/8025 in diesem Feld steht und der Dynprowert für Suchilfe
* der Mengeneinheit benötigt wird
*      IF FIELD EQ 'RMMW1-MATNR' OR FIELD EQ 'RMMW1-VARNR'. "//br1.2B3
      IF FIELD EQ 'RMMW1-MATNR' OR FIELD EQ 'RMMW1-VARNR'
      OR FIELD EQ 'MEAN-MATNR'.                            "//br1.2B3

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'        "
             EXPORTING                                     "
                  INPUT   = VALUE                          "
             IMPORTING                                     "
                  OUTPUT  = VALUE
             EXCEPTIONS
                  LENGTH_ERROR       = 1
                  OTHERS             = 2.
        IF SY-SUBRC <> 0.                                  "note 933591
          CLEAR VALUE.
        ENDIF.
      ENDIF.                                               "
    ENDIF.

ENDFORM.                    " GET_VALUE_FROM_SCREEN

*&---------------------------------------------------------------------*
*&      Form  SET_VALUE_ON_SCREEN
*&---------------------------------------------------------------------*
FORM SET_VALUE_ON_SCREEN USING FIELD VALUE.

   CLEAR DYNPFIELDS. REFRESH DYNPFIELDS.
   DYNPFIELDS-FIELDNAME = FIELD.
   DYNPFIELDS-FIELDVALUE = VALUE.
   APPEND DYNPFIELDS.
*   Setzen des akt. Wertes im Dynpro
    SY_REPID = SY-REPID.
    SY_DYNNR = SY-DYNNR.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
         EXPORTING
              DYNAME               = SY_REPID
              DYNUMB               = SY_DYNNR
         TABLES
              DYNPFIELDS           = DYNPFIELDS
         EXCEPTIONS
              OTHERS               = 1.

ENDFORM.                    " GET_VALUE_FROM_SCREEN

*&---------------------------------------------------------------------*
*&      Form  SET_VALUE_ON_SCREEN
*&---------------------------------------------------------------------*
FORM SET_VALUE_ON_STEPL USING FIELD VALUE STEPL.

   CLEAR DYNPFIELDS. REFRESH DYNPFIELDS.
   DYNPFIELDS-FIELDNAME  = FIELD.
   DYNPFIELDS-FIELDVALUE = VALUE.
   DYNPFIELDS-STEPL      = STEPL.
   APPEND DYNPFIELDS.
*   Setzen des akt. Wertes im Dynpro
    SY_REPID = SY-REPID.
    SY_DYNNR = SY-DYNNR.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
         EXPORTING
              DYNAME               = SY_REPID
              DYNUMB               = SY_DYNNR
         TABLES
              DYNPFIELDS           = DYNPFIELDS
         EXCEPTIONS
              OTHERS               = 1.

ENDFORM.                    " SET_VALUE_ON_SCREEN

*&---------------------------------------------------------------------*
*&      Form  SET_KZALL
*&---------------------------------------------------------------------*
FORM SET_KZALL.

*  IF T130M-AKTYP = AKTYPH OR             //br 230196 Logik umgedreht
*     T130M-AKTYP = AKTYPN OR
*     T130M-AKTYP = AKTYPC.
*     KZALL = X.
*  ELSE.
*     CLEAR KZALL.
*  ENDIF.

   IF T130M-AKTYP = AKTYPA OR
      T130M-AKTYP = AKTYPZ.
     CLEAR KZALL.
   ELSE.
     KZALL = X.
   ENDIF.

ENDFORM.                    " SET_KZALL
