*------------------------------------------------------------------
*  Module MARC-DZEIT.
*  Pruefung der Eigenfertigungszeit.
*------------------------------------------------------------------
MODULE MARC-DZEIT.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_DZEIT'
       EXPORTING
            P_DZEIT      = MARC-DZEIT
            P_RUEZT      = MARC-RUEZT
            P_BEARZ      = MARC-BEARZ
            P_TRANZ      = MARC-TRANZ
            P_DISMM      = MARC-DISMM
            P_BESKZ      = MARC-BESKZ
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_DZEIT      = MARC-DZEIT.
ENDMODULE.
