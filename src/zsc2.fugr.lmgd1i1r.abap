*------------------------------------------------------------------
* Module MARD-DISKZ
*------------------------------------------------------------------
MODULE MARD-DISKZ.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.           "mk/21.04.95

  CALL FUNCTION 'MARD_DISKZ'
       EXPORTING
            P_DISKZ      = MARD-DISKZ
            P_LMINB      = MARD-LMINB
            P_LBSTF      = MARD-LBSTF
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MARD_DISKZ = 01.
ENDMODULE.
