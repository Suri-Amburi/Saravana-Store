*------------------------------------------------------------------
*    Module MARA-STOFF.
*Prüfen ob die Stoffnummer (irgendwo) vorgesehen ist
*------------------------------------------------------------------
MODULE MARA-STOFF.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_STOFF'
       EXPORTING
            MARA_IN_STOFF = MARA-STOFF.
*      EXCEPTIONS
*           ERROR_STOFF   = 01.

ENDMODULE.
