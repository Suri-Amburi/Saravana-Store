*&---------------------------------------------------------------------*
*&      Module  GET_VERB_SUB  INPUT
*&---------------------------------------------------------------------*
*       Analog GET_DATEN_SUB aber speziell für Verbrauchswerte         *
*----------------------------------------------------------------------*
MODULE GET_VERB_SUB INPUT.

  CHECK NOT ANZ_SUBSCREENS IS INITIAL.

  IF NOT KZ_EIN_PROGRAMM IS INITIAL.
    IF NOT KZ_BILDBEGINN IS INITIAL.
      CALL FUNCTION 'MAIN_PARAMETER_GET_BILDPAI_SUB'
           IMPORTING
                RMMZU_OKCODE  = RMMZU-OKCODE
                BILDFLAG      = BILDFLAG
                RMMG2_VB_KLAS = RMMG2-VB_KLAS.
      CLEAR SUB_ZAEHLER.
      CLEAR KZ_BILDBEGINN.
    ENDIF.
    SUB_ZAEHLER = SUB_ZAEHLER + 1.
  ENDIF.

  IF T130M-AKTYP = AKTYPH.
    PERFORM ZUSATZDATEN_GET_SUB.
  ENDIF.

  CHECK KZ_EIN_PROGRAMM IS INITIAL.

  PERFORM ZUSATZDATEN_GET_SUB.
  CALL FUNCTION 'MVER_GET_SUB'
       TABLES
            WUNG_VERBTAB = UNG_VERBTAB
            WGES_VERBTAB = GES_VERBTAB
            XUNG_VERBTAB = DUNG_VERBTAB
            XGES_VERBTAB = DGES_VERBTAB
            YUNG_VERBTAB = LUNG_VERBTAB
            YGES_VERBTAB = LGES_VERBTAB.

ENDMODULE.                             " GET_VERB_SUB  INPUT
