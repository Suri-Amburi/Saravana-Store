*------------------------------------------------------------------
*  Module Daten_Werteschl
*
* Die Daten aus dem Werteschluessel werden angezeigt
* Es erfolgt eine Warnung, wenn ein neuer Werteschlüssel eingegeben
* wurde
*------------------------------------------------------------------
MODULE DATEN_WERTESCHL.

  CHECK BILDFLAG = SPACE.              "mk/19.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.  "mk/18.04.95

  CALL FUNCTION 'DATEN_WERTESCHLUESSEL'
       EXPORTING
            MARA_IN_EKWSL = MARA-EKWSL
            RET_EKWSL     = LMARA-EKWSL
            P_MESSAGE     = ' '.

ENDMODULE.
