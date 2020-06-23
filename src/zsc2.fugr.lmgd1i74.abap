*------------------------------------------------------------------
*Module Steuer_TAXKM_HELP
*
*Aufruf der speziellen Eingabehilfe für die Steuerklassifikationen
*auf dem STEP-LOOP-Bild
*------------------------------------------------------------------
MODULE STEUER_TAXKM_HELP.

  PERFORM SET_DISPLAY.

*- Ermitteln des Eintrages in der internen
*- Steuertabelle Dynpro - Zeile ----------
  GET CURSOR FIELD CHAR LINE ZAEHLER.
  AKZEILE = ST_ERSTE_ZEILE + ZAEHLER.
  READ TABLE STEUERTAB INDEX AKZEILE.
  IF SY-SUBRC EQ 0.

    CALL FUNCTION 'STEUER_TAXKM_HELP'
         EXPORTING
              STEUERTAB_TATYP = STEUERTAB-TATYP
              DISPLAY         = DISPLAY
         IMPORTING
              TAXKM           = STEUERTAB-TAXKM.

    IF T130M-AKTYP NE AKTYPA AND                        "3.1I BE/221097
       T130M-AKTYP NE AKTYPZ AND                        "3.1I BE/221097
       DISPLAY IS INITIAL.                              "3.1I BE/221097
      MODIFY STEUERTAB INDEX AKZEILE.
      MG03STEUER-TAXKM = STEUERTAB-TAXKM.
    ENDIF.                                              "3.1I BE/221097

  ENDIF.

ENDMODULE.
