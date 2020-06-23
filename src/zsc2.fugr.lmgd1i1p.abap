*-----------------------------------------------------------------------
*           Module Eigenfertigungszeit
*
* Prüfungen zur Eigenfertigungszeit (auf Dynpro Arbeitsvorb. 2)
*-----------------------------------------------------------------------
MODULE EIGENFERTIGUNGSZEIT.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'EIGENFERTIGUNGSZEIT_PRUEFEN'
       CHANGING
            WMARC_DZEIT = MARC-DZEIT
            WMARC_RUEZT = MARC-RUEZT
            WMARC_BEARZ = MARC-BEARZ
            WMARC_TRANZ = MARC-TRANZ
            WMARC_BASMG = MARC-BASMG.


ENDMODULE.
