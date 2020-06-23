*----------------------------------------------------------------------*
*   INCLUDE LMGD1F2I                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ME_VOLUMEN_BERECHNEN
*&---------------------------------------------------------------------*
*       jw/4.6A Volumen automatisch berechnen
*       Entwicklungsantrag 3332512
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM ME_VOLUMEN_BERECHNEN.

* jw/HW 206748 - A
  DATA: VOLUM(16)     type p decimals 9,
        new_volum(16) type p decimals 9,
        hvolum(13)    type p decimals 3,
        volum_f       type f,
        umrez_meabm like t006-zaehl,
        umren_meabm like t006-nennr,
        exp10_meabm like t006-exp10,
        addko_meabm like t006-addko,
        umrez_voleh like t006-zaehl,
        umren_voleh like t006-nennr,
        exp10_voleh like t006-exp10,
        addko_voleh like t006-addko,
        overflow    type c,
        si_unit     type T006-MSEHI,
*  DATA: VOLUM TYPE F,
* jw/HW 206748 - E
       FLG_UPDATE_VOL(1) TYPE C.

  LOOP AT MEINH WHERE NOT LAENG IS INITIAL
                  AND NOT BREIT IS INITIAL
                  AND NOT HOEHE IS INITIAL
                  AND VOLUM IS INITIAL.

    TRY.                                                "v note 2480133
      VOLUM = MEINH-LAENG * MEINH-BREIT * MEINH-HOEHE.
    CATCH CX_SY_ARITHMETIC_OVERFLOW.
      BILDFLAG = X.
      " Field overflow occurred during conversion
      MESSAGE w106(MM).
      CONTINUE.
    ENDTRY.                                             "^ note 2480133

* jw/HW 206748 - A
    if not meinh-voleh is initial.

*     Umrechnungsfaktoren der MEABM in die SI-Einheit der Länge:
      CALL FUNCTION 'UNIT_PARAMETERS_GET'
           EXPORTING
                UNIT           = meinh-meabm
           IMPORTING
                NUMERATOR      = umrez_meabm
                DENOMINATOR    = umren_meabm
                EXPONENT       = exp10_meabm
                ADD_CONST      = addko_meabm
           EXCEPTIONS
                UNIT_NOT_FOUND = 1
                OTHERS         = 2.
      check sy-subrc = 0 and addko_meabm = 0.

*     Umrechnungsfaktoren der VOLEH in die SI-Einheit des Volumens:
      CALL FUNCTION 'UNIT_PARAMETERS_GET'
           EXPORTING
                UNIT           = meinh-voleh
           IMPORTING
                NUMERATOR      = umrez_voleh
                DENOMINATOR    = umren_voleh
                EXPONENT       = exp10_voleh
                ADD_CONST      = addko_voleh
           EXCEPTIONS
                UNIT_NOT_FOUND = 1
                OTHERS         = 2.
      check sy-subrc = 0 and addko_voleh = 0.

      check umren_meabm ne 0 and umrez_voleh ne 0.  "Div. durch 0!

*    Umrechnung des Volumens die in Volumeneinheit über die SI-Einheiten

*    Neues Volumen = in der Abmessungseinheit errechnetes Volumen *
*        (Umrechnung der Abmessungseinheit in die SI-Einheit der Länge)
*          hoch 3 *
*        Umrechnung der SI-Einheit des Volumens in die gewünschte
*          Volumeneinheit

      TRY.                                                "note 2480133
        new_volum = volum
                 * ( ( umrez_meabm * ( 10 ** exp10_meabm ) / umren_meabm
                     ) ** 3 )
                 * umren_voleh / ( umrez_voleh * ( 10 ** exp10_voleh ) )
                 .
        volum = new_volum.
      CATCH CX_SY_CONVERSION_OVERFLOW.                  "v note 2480133
        BILDFLAG = X.
        " Field overflow occurred during conversion
        MESSAGE w106(MM).
        CONTINUE.
      ENDTRY.                                           "^ note 2480133

    else.

*     Berechnung des Volumens in die SI-Einheit des Volumens
      CALL FUNCTION 'UNIT_PARAMETERS_GET'
           EXPORTING
                UNIT           = meinh-meabm
           IMPORTING
                NUMERATOR      = umrez_meabm
                DENOMINATOR    = umren_meabm
                EXPONENT       = exp10_meabm
                ADD_CONST      = addko_meabm
           EXCEPTIONS
                UNIT_NOT_FOUND = 1
                OTHERS         = 2.

      check sy-subrc = 0 and addko_meabm = 0 and umren_meabm ne 0.

      TRY.                                                "note 2480133
        new_volum = volum
                * ( ( umrez_meabm * ( 10 ** exp10_meabm ) / umren_meabm
                    ) ** 3 ).
        volum_f = new_volum.
      CATCH CX_SY_CONVERSION_OVERFLOW.                  "v note 2480133
        BILDFLAG = X.
        " Field overflow occurred during conversion
        MESSAGE w106(MM).
        CONTINUE.
      ENDTRY.                                           "^ note 2480133

      CALL FUNCTION 'SI_UNIT_GET'
           EXPORTING
                DIMENSION           = 'VOLUME'
           IMPORTING
                SI_UNIT             = si_unit
           EXCEPTIONS
                DIMENSION_NOT_FOUND = 1
                UNIT_NOT_FOUND      = 2
                OTHERS              = 3.
      check sy-subrc = 0.

*     Ermittlung der passenden Volumeneinheit:
      CALL FUNCTION 'UNIT_QUANTITY_SWITCH'
           EXPORTING
                IMP_VALUE         = volum_f
                IMP_UNIT          = si_unit
           IMPORTING
                EXP_VALUE         = hvolum
                OVERFLOW          = overflow
           CHANGING
                EXP_UNIT          = meinh-voleh
           EXCEPTIONS
                UNIT_NOT_FOUND    = 1
                OUTPUT_NOT_TYPE_P = 2
                OTHERS            = 3.

      check overflow is initial.
      volum = hvolum.
    endif.
* jw/HW 206748 - E

    IF VOLUM < 10000000000.            "Volumenfeld ist nur 10stellig
      MEINH-VOLUM = VOLUM.
      if not meinh-volum is initial.                        "HW 206748
        MODIFY MEINH.
        FLG_UPDATE_VOL = X.
      endif.                                                "HW 206748
    ENDIF.
  ENDLOOP.

  IF NOT FLG_UPDATE_VOL IS INITIAL
    AND BILDFLAG IS INITIAL.
    BILDFLAG = X.
    MESSAGE S323(MM).
  ENDIF.

ENDFORM.                               " ME_VOLUMEN_BERECHNEN
