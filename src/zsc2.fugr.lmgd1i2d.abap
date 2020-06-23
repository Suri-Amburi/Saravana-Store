*------------------------------------------------------------------
*  Module MARC-MTVFP.      Mk/20.04.94 neu zu 2.2
*  Beim Ändern der Verfügbarkeitsprüfung gegenüber der Datenbank
*  erfolgt eine Warnung, wenn
*  von Einzel- auf Sammelbedarf geändert wird oder umgedreht
*  Zusätzlich statt Fremdschlüsselprüfung hier Prüfung gegen TMVF
*------------------------------------------------------------------
MODULE MARC-MTVFP.

  CHECK BILDFLAG = SPACE.
*CHECK T130M-AKTYP EQ AKTYPV.                 mk/13.06.94
*CHECK NOT *MARC-MTVFP IS INITIAL.            mk/13.06.94
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_MTVFP'
       EXPORTING
            WMARC_MTVFP = MARC-MTVFP
            OMARC_MTVFP = *MARC-MTVFP.

ENDMODULE.
