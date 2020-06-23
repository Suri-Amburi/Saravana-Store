
*------------------------------------------------------------------
*Spezielle Help-Module für Eingabehilfen für die Datenbilder
*------------------------------------------------------------------
*------------------------------------------------------------------
*Module mara-prdha_help.
*Aufruf der speziellen Eingabehilfe für Mara-PRdha
*------------------------------------------------------------------
MODULE MARA-PRDHA_HELP.

  PERFORM SET_DISPLAY.                                      "//br200896
                                                                     "
* IF T130M-AKTYP EQ AKTYPA OR T130M-AKTYP EQ AKTYPZ.                 "
  IF T130M-AKTYP EQ AKTYPA OR T130M-AKTYP EQ AKTYPZ OR DISPLAY = X.  "
    CALL FUNCTION 'RV_PRODUKTHIERARCHIE_SHOW'
        EXPORTING ROOT            = MARA-PRDHA.
  ELSE.
    CALL FUNCTION 'RV_PRODUKTHIERARCHIE_SHOW'
        EXPORTING ROOT            = MARA-PRDHA
        IMPORTING NODE_PICKED     = MARA-PRDHA.
  ENDIF.

ENDMODULE.
