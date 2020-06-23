*------------------------------------------------------------------
*  Module MBEW-KOSGR
*  Prüfung der Gemeinkostengruppe
*------------------------------------------------------------------
MODULE MBEW-KOSGR.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_KOSGR'
       EXPORTING
            P_MBEW_KOSGR    = MBEW-KOSGR
            P_RM03M_BWKEY   = RMMG1-BWKEY.

ENDMODULE.
