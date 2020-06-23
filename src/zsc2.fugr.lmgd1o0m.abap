*&---------------------------------------------------------------------*
*&      Module  SET_VERB_SUB  OUTPUT
*&---------------------------------------------------------------------*
*       Analog SET_DATEN_SUB aber speziell für Verbrauchswerte         *
*----------------------------------------------------------------------*
MODULE SET_VERB_SUB OUTPUT.

*mk/3.0E Setzen Kz. 'Status-Update am Ende des Bildes erforderlich',
*falls auf dem Bild Felder zu statusrelevanten Tabellen vorhanden
*sind
  IF RMMZU-KZSTAT_UPD IS INITIAL.
    LOOP AT SUB_PTAB WHERE NOT KZSTA IS INITIAL.
      RMMZU-KZSTAT_UPD = X.
    ENDLOOP.
  ENDIF.
  IF ANZ_SUBSCREENS IS INITIAL.
* Keine Bildbausteine auf dem Bild vorhanden
    CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
         EXPORTING
              RMMZU_KZSTAT_UPD = RMMZU-KZSTAT_UPD
         TABLES
              REFTAB           = REFTAB.
  ELSEIF NOT KZ_EIN_PROGRAMM IS INITIAL.
* Bildbausteine auf dem Bild vorhanden, alle aus einheitlichem Programm
    CLEAR KZ_BILDBEGINN.
    SUB_ZAEHLER = SUB_ZAEHLER + 1.
    IF SUB_ZAEHLER EQ ANZ_SUBSCREENS.
      KZ_BILDBEGINN = X.               "für PAI notwendig
      CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
           EXPORTING
                RMMZU_KZSTAT_UPD = RMMZU-KZSTAT_UPD
           TABLES
                REFTAB           = REFTAB.
    ENDIF.
  ELSE.
* Bildbausteine auf dem Bild vorhanden, aus unterschiedlichen Programmen
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

    CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
         EXPORTING
              RMMZU_KZSTAT_UPD = RMMZU-KZSTAT_UPD
         TABLES
              REFTAB           = REFTAB.
  ENDIF.

  IF T130M-AKTYP = AKTYPH.
    PERFORM ZUSATZDATEN_SET_SUB.
    CALL FUNCTION 'MAIN_PARAMETER_SET_REFTAB'
      EXPORTING
           RMMZU_KZSTAT_UPD = RMMZU-KZSTAT_UPD
      TABLES
           REFTAB           = REFTAB.

  ENDIF.


ENDMODULE.                             " SET_VERB_SUB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MARD_EXTEND  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MARD_EXTEND OUTPUT.

  DATA : LT_MARD like MARD OCCURS 0 WITH HEADER LINE.

      REFRESH LT_MARD.                          "CH
      APPEND MARD TO LT_MARD.                "
      CALL FUNCTION 'MARD_EXTEND'               "
        TABLES                               "
          MARD_TAB = LT_MARD.         "
      READ TABLE LT_MARD INDEX 1 INTO MARD.  "


ENDMODULE.
