*&---------------------------------------------------------------------*
*&      Module  SET_VERB_SUB  INPUT
*&---------------------------------------------------------------------*
*       Analog SET_DATEN_SUB aber speziell für Verbrauchswerte         *
*----------------------------------------------------------------------*
MODULE SET_VERB_SUB INPUT.

  IF ANZ_SUBSCREENS IS INITIAL.
    PERFORM ZUSATZDATEN_SET_SUB.
    CALL FUNCTION 'MVER_SET_SUB'
         EXPORTING
              MATNR        = RMMG1-MATNR
              WERKS        = RMMG1-WERKS
              PERKZ        = PERKZ
              PERIV        = PERIV
         TABLES
              WUNG_VERBTAB = UNG_VERBTAB
              WGES_VERBTAB = GES_VERBTAB.
  ELSEIF NOT KZ_EIN_PROGRAMM IS INITIAL.
    IF SUB_ZAEHLER EQ ANZ_SUBSCREENS.
      PERFORM ZUSATZDATEN_SET_SUB.
      CALL FUNCTION 'MVER_SET_SUB'
           EXPORTING
                MATNR        = RMMG1-MATNR
                WERKS        = RMMG1-WERKS
                PERKZ        = PERKZ
                PERIV        = PERIV
           TABLES
                WUNG_VERBTAB = UNG_VERBTAB
                WGES_VERBTAB = GES_VERBTAB.
    ENDIF.
  ELSE.
    PERFORM ZUSATZDATEN_SET_SUB.
    CALL FUNCTION 'MVER_SET_SUB'
         EXPORTING
              MATNR        = RMMG1-MATNR
              WERKS        = RMMG1-WERKS
              PERKZ        = PERKZ
              PERIV        = PERIV
         TABLES
              WUNG_VERBTAB = UNG_VERBTAB
              WGES_VERBTAB = GES_VERBTAB.
  ENDIF.
  IF T130M-AKTYP = AKTYPH.
    PERFORM ZUSATZDATEN_SET_SUB.
  ENDIF.


ENDMODULE.                             " SET_VERB_SUB  INPUT
