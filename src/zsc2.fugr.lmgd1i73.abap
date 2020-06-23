*------------------------------------------------------------------
*Module Steuer_TAXIM_HELP
*
*Aufruf der speziellen Eingabehilfe für den Steuerindikator Einkauf
*------------------------------------------------------------------
MODULE STEUER_TAXIM_HELP.

  DATA: SY_TABIX LIKE SY-TABIX.                         "TF 4.5A H117533

  PERFORM SET_DISPLAY.

*- Ermitteln des Eintrages in der internen Steuertabelle Einkauf
* READ TABLE steummtab INDEX 1.                         "TF 4.5A H117533
  IF NOT T001W IS INITIAL.
   country = T001W-LAND1.
*  Hope that COUNTRY was set before :-)
  ENDIF.
  READ TABLE STEUMMTAB WITH KEY ALAND = COUNTRY.    "TF 4.5A H117533
  SY_TABIX = SY-TABIX.                                  "TF 4.5A H117533
  IF SY-SUBRC EQ 0.

    CALL FUNCTION 'STEUER_TAXIM_HELP'
         EXPORTING
              STEUMMTAB_ALAND = STEUMMTAB-ALAND
              DISPLAY         = DISPLAY
         IMPORTING
              TAXIM           = STEUMMTAB-TAXIM.

    IF T130M-AKTYP NE AKTYPA AND                        "3.1I BE/221097
       T130M-AKTYP NE AKTYPZ AND                        "3.1I BE/221097
       DISPLAY IS INITIAL.                              "3.1I BE/221097
*      MODIFY steummtab INDEX 1.                        "TF 4.5A H117533
       MODIFY STEUMMTAB INDEX SY_TABIX.                 "TF 4.5A H117533
      MG03STEUMM-TAXIM = STEUMMTAB-TAXIM.
    ENDIF.                                              "3.1I BE/221097

  ENDIF.

ENDMODULE.
