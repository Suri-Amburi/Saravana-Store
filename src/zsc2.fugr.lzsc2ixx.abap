*-------------------------------------------------------------------
***INCLUDE LMGD2IXX .
*-------------------------------------------------------------------
*------------------------------------------------------------------
*        GET_DATEN_SUB  Input
*- Falls die Bausteine zu einem einheitlichen Programm gehören,
*  holen Bildflag und Ok-Code aus dem zentralen Puffer, da diese
*  zu Beginn des PAI des Trägerbildes verändert werden konnten,
*  ansonsten holen der Materialstammdaten sowie aller Parameter
*  (incl. Bildflag und Ok-Code)
*------------------------------------------------------------------
MODULE GET_DATEN_SUB INPUT.
  CHECK NOT ANZ_SUBSCREENS IS INITIAL.
*wk/4.0
  FLG_TC = ' '.
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

  CHECK KZ_EIN_PROGRAMM IS INITIAL.

  PERFORM ZUSATZDATEN_GET_SUB.
  PERFORM MATABELLEN_GET_SUB.
  PERFORM MATABELLEN_GET_SUB_RT.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SET_DATEN_SUB  INPUT
*&---------------------------------------------------------------------*
* Zurückgeben der Daten des Bildbausteins an die U-WA´s                *
* Gehören die Bildbausteine des Bildes zu einem einheitlichen Programm,
* so werden die Daten erst beim letzten Bildbaustein an die U-WA´s
* übergeben, sonst immer.
*----------------------------------------------------------------------*
MODULE SET_DATEN_SUB INPUT.

  IF ANZ_SUBSCREENS IS INITIAL.
    PERFORM ZUSATZDATEN_SET_SUB.
    PERFORM MATABELLEN_SET_SUB_RT. " MUß vor MATABELLEN_SET_SUB laufen !
    PERFORM MATABELLEN_SET_SUB.
  ELSEIF NOT KZ_EIN_PROGRAMM IS INITIAL.
    IF SUB_ZAEHLER EQ ANZ_SUBSCREENS.
      PERFORM ZUSATZDATEN_SET_SUB.
      PERFORM MATABELLEN_SET_SUB_RT. " MUß vor MATABELLEN_SET_SUB lfn !
      PERFORM MATABELLEN_SET_SUB.
    ENDIF.
  ELSE.
    PERFORM ZUSATZDATEN_SET_SUB.
    PERFORM MATABELLEN_SET_SUB_RT. " MUß vor MATABELLEN_SET_SUB laufen !
    PERFORM MATABELLEN_SET_SUB.
  ENDIF.

* get cursor position for matrix maintenance
  IF RMMZU-OKCODE       = FCODE_CALL_MTRX AND     " JKl, 16.11.2001
    CURSOR_FIELD_MATRIX = SPACE.                  " JKl, 16.11.2001
    GET CURSOR FIELD CURSOR_FIELD_MATRIX          " JKl, 16.11.2001
                LINE  CURSOR_field_LINE.          " JKl, 16.11.2001
    CURSOR_FIELD_DYNNR = SY-DYNNR.                " JKl, 16.11.2001
    CURSOR_FIELD_REPID = SY-REPID.                " JKl, 16.11.2001
    call function 'MGW_MATRIX_SET_DATA_TO_BUFFER' " JKl, 07.01.2002
      EXPORTING                                   " JKl, 07.01.2002
        I_FIELD       = CURSOR_FIELD_MATRIX       " JKl, 07.01.2002
        I_DYNNR       = CURSOR_FIELD_DYNNR        " JKl, 07.01.2002
        I_REPID       = CURSOR_FIELD_REPID        " JKl, 07.01.2002
        I_TABIX       = CURSOR_field_LINE.        " JKl, 07.01.2002
    if cursor_field_repid <> 'SAPLMGD2'.              " JKL, 14.01.2002
      clear: CURSOR_FIELD_MATRIX, CURSOR_FIELD_LINE,  " JKL, 14.01.2002
             CURSOR_FIELD_REPID,  CURSOR_FIELD_DYNNR. " JKL, 14.01.2002
    endif.                                            " JKL, 14.01.2002
  ENDIF.                                          " JKl, 16.11.2001

ENDMODULE.                             " SET_DATEN_SUB  INPUT
