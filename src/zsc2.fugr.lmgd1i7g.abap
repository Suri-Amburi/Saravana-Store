*------------------------------------------------------------------
*Module MVKE_PRODH_HELP.
*Aufruf der speziellen Eingabehilfe für MVKE-PRODH
*------------------------------------------------------------------
MODULE MVKE-PRODH_HELP.

  PERFORM SET_DISPLAY.                                      "//br200896
                                                                     "
* IF T130M-AKTYP EQ AKTYPA OR T130M-AKTYP EQ AKTYPZ.                 "
  IF T130M-AKTYP EQ AKTYPA OR T130M-AKTYP EQ AKTYPZ OR DISPLAY = X.  "
    CALL FUNCTION 'RV_PRODUKTHIERARCHIE_SHOW'
        EXPORTING ROOT            = MVKE-PRODH.
  ELSE.
    CALL FUNCTION 'RV_PRODUKTHIERARCHIE_SHOW'
        EXPORTING ROOT            = MVKE-PRODH
        IMPORTING NODE_PICKED     = MVKE-PRODH.
  ENDIF.

ENDMODULE.
