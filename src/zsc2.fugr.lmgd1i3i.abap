*------------------------------------------------------------------
*  Module MBEW-VMSTP.
*
*  Pruefung Standardpreis Vormonat
*------------------------------------------------------------------
MODULE MBEW-VMSTP.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG = SPACE.

  CALL FUNCTION 'MBEW_VMSTP'
       EXPORTING
            WMBEW_VMSTP     = MBEW-VMSTP
            WMBEW_VMVPR     = MBEW-VMVPR
            P_AKTYP         = T130M-AKTYP
            WMBEW_MATNR     = MBEW-MATNR "fbo/111298 Sharedsperre
            WRMMG1_BWKEY    = MBEW-BWKEY "fbo/111298 Sharedsperre
            WRMMG1_BWTAR    = MBEW-BWTAR "fbo/111298 Sharedsperre
*           LMBEW_VMSTP     = MBEW-VMSTP "fbo/111298 Sharedsperre
            LMBEW_VMSTP     = lMBEW-VMSTP   "ch/4.6b
       TABLES                                                "BE/260996
            P_PTAB          = PTAB.                          "BE/260996

ENDMODULE.
