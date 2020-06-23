
*------------------------------------------------------------------
*Spezielle Help-Module für Eingabehilfen für die Datenbilder Retail
*------------------------------------------------------------------

*------------------------------------------------------------------
*Module Steuer_TATYP_HELP
*
*Aufruf der speziellen Eingabehilfe für die Steuertypen
*auf dem STEP-LOOP-Bild
*------------------------------------------------------------------
MODULE STEUER_TATYP_HELP.

  PERFORM SET_DISPLAY.

*-- Ermitteln des Eintrages in der internen
*-- Steuertabelle Dynpro - Zeile ----------
  GET CURSOR FIELD CHAR LINE ZAEHLER.
  AKZEILE = ST_ERSTE_ZEILE + ZAEHLER.

  READ TABLE STEUERTAB INDEX AKZEILE.
  IF SY-SUBRC NE 0.
    CLEAR STEUERTAB.
*-- Alternativ: Holen aktuelle Daten vom Dynpro              "BE/290196
    PERFORM GET_VALUE_FROM_SCREEN USING                      "BE/290196
      'MG03STEUER-ALAND' MG03STEUER-ALAND ZAEHLER.           "BE/290196
    STEUERTAB-ALAND = MG03STEUER-ALAND.                      "BE/290196
  ENDIF.

  CALL FUNCTION 'STEUER_TATYP_HELP'
       EXPORTING
            STEUERTAB_ALAND = STEUERTAB-ALAND
            DISPLAY         = DISPLAY
       IMPORTING
            TATYP           = STEUERTAB-TATYP.

  MG03STEUER-TATYP = STEUERTAB-TATYP.

  READ TABLE STEUERTAB INDEX AKZEILE.
  IF SY-SUBRC EQ 0.
    IF DISPLAY IS INITIAL.                                   "TF 4.5B
      STEUERTAB-TATYP = MG03STEUER-TATYP.
      MODIFY STEUERTAB INDEX AKZEILE.
    ENDIF.                                                   "TF 4.5B
  ELSE.                                                      "BE/290196
*-- Alternativ: Setzen aktuelle Daten ins Dynpro             "BE/290196
    IF NOT MG03STEUER-TATYP IS INITIAL AND DISPLAY IS INITIAL.  "290196
      PERFORM SET_VALUE_ON_STEPL USING                       "BE/290196
      'MG03STEUER-TATYP' MG03STEUER-TATYP ZAEHLER.           "BE/290196
    ENDIF.                                                   "BE/290196
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
*Module Steuer_TAXKM_HELP_RT
*
*Aufruf der speziellen Eingabehilfe für die Steuerklassifikationen
*auf dem STEP-LOOP-Bild
*------------------------------------------------------------------
MODULE STEUER_TAXKM_HELP_RT.

  PERFORM SET_DISPLAY.

*- Ermitteln des Eintrages in der internen
*- Steuertabelle Dynpro - Zeile ----------
  GET CURSOR FIELD CHAR LINE ZAEHLER.
  AKZEILE = ST_ERSTE_ZEILE + ZAEHLER.

  READ TABLE STEUERTAB INDEX AKZEILE.

  IF SY-SUBRC NE 0.
    CLEAR STEUERTAB.
*-- Alternativ: Holen aktuelle Daten vom Dynpro              "BE/290196
    PERFORM GET_VALUE_FROM_SCREEN USING                      "BE/290196
      'MG03STEUER-TATYP' MG03STEUER-TATYP ZAEHLER.           "BE/290196
    STEUERTAB-TATYP = MG03STEUER-TATYP.                      "BE/290196
  ENDIF.

  MG03STEUER-TAXKM = STEUERTAB-TAXKM.                 "BK/4.6a/29.03.99
                                                      "KPr: 153196 1999
  IF STEUERTAB-TATYP IS INITIAL.
    CALL FUNCTION 'STEUER_TAXKM_HELP_RT'
         EXPORTING
              STEUERTAB_TATYP = STEUERTAB-TATYP
              DISPLAY         = DISPLAY
         IMPORTING
              TAXKM           = STEUERTAB-TAXKM.
  ELSE.
    CALL FUNCTION 'STEUER_TAXKM_HELP'
         EXPORTING
              STEUERTAB_TATYP = STEUERTAB-TATYP
              DISPLAY         = DISPLAY
         IMPORTING
              TAXKM           = STEUERTAB-TAXKM.
  ENDIF.

  IF DISPLAY NE 'X'.                                  "BK/4.6a/29.03.99
   MG03STEUER-TAXKM = STEUERTAB-TAXKM.
  ENDIF.                                              "BK/4.6a/29.03.99

  READ TABLE STEUERTAB INDEX AKZEILE.
  IF SY-SUBRC EQ 0.
    STEUERTAB-TAXKM = MG03STEUER-TAXKM.
    MODIFY STEUERTAB INDEX AKZEILE.
  ELSE.                                                      "BE/290196
*-- Alternativ: Setzen aktuelle Daten ins Dynpro             "BE/290196
    IF NOT MG03STEUER-TAXKM IS INITIAL AND DISPLAY IS INITIAL.  "290196
      PERFORM SET_VALUE_ON_STEPL USING                       "BE/290196
      'MG03STEUER-TAXKM' MG03STEUER-TAXKM ZAEHLER.           "BE/290196
    ENDIF.                                                   "BE/290196
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
*Module MAW1-WBKLA_HELP.
*Aufruf der speziellen Eingabehilfe für Bewertungsklassen
*------------------------------------------------------------------
MODULE MAW1-WBKLA_HELP.

  PERFORM SET_DISPLAY.

  GET CURSOR FIELD FELD3.

  CALL FUNCTION 'MAW1_WBKLA_HELP'
       EXPORTING
            T134_KKREF = T134-KKREF
            DISPLAY    = DISPLAY
       IMPORTING
            WBKLA      = H_BKLAS.

  CASE FELD3.
    WHEN 'MAW1-WBKLA'.
      MAW1-WBKLA =  H_BKLAS.
  ENDCASE.

ENDMODULE.

*----------------------------------------------------------------------
*Module MVKE-PMATN_HELP.                                     "BE/210696
*Aufruf der speziellen Eingabehilfe für Preismaterial
*----------------------------------------------------------------------
MODULE MVKE-PMATN_HELP.                                      "BE/210696

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MVKE_PMATN_HELP'
       EXPORTING
            SA         = RMMW2-SATNR
            MATERIAL   = RMMG1-MATNR                         "BE/101096
            DISPLAY    = DISPLAY
       IMPORTING
            VARIANTE   = MVKE-PMATN.

ENDMODULE.

*----------------------------------------------------------------------
*Module MARA-PMATA_HELP.                                     "BE/310796
*Aufruf der speziellen Eingabehilfe für Preismaterial
*----------------------------------------------------------------------
MODULE MARA-PMATA_HELP.                                      "BE/310796

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MVKE_PMATN_HELP'
       EXPORTING
            SA         = RMMW2-SATNR
            MATERIAL   = RMMG1-MATNR                         "BE/101096
            DISPLAY    = DISPLAY
       IMPORTING
            VARIANTE   = MARA-PMATA.

ENDMODULE.

*----------------------------------------------------------------------
*Module MAW1-WSTAW_HELP.                                     "BE/250696
*Aufruf der speziellen Eingabehilfe für statistische Warennr.
*----------------------------------------------------------------------
MODULE MAW1-WSTAW_HELP.                                      "BE/250696

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MAW1_WSTAW_HELP'
       EXPORTING
            DISPLAY    = DISPLAY
       IMPORTING
            WSTAW      = MAW1-WSTAW.

ENDMODULE.

*----------------------------------------------------------------------
*Module MARA-INHME_HELP.                                     "BE/250796
*Aufruf der speziellen Eingabehilfe für Inhaltsmengeneinheit
*----------------------------------------------------------------------
MODULE MARA-INHME_HELP.                                      "BE/250796

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MARA_INHME_HELP'
       EXPORTING
            DISPLAY    = DISPLAY
       IMPORTING
            INHME      = MARA-INHME.

ENDMODULE.
