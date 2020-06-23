*------------------------------------------------------------------
*  Module MBEW-VJSTP.
*
*  Pruefung Standardpreis.
*------------------------------------------------------------------
MODULE MBEW-VJSTP.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_VJSTP'
       EXPORTING
            WMBEW_VJSTP     = MBEW-VJSTP
            WMBEW_VJVPR     = MBEW-VJVPR
            P_AKTYP         = T130M-AKTYP
            WMBEW_MATNR     = MBEW-MATNR "fbo/111298 Sharedsperre
            WRMMG1_BWKEY    = MBEW-BWKEY "fbo/111298 Sharedsperre
            WRMMG1_BWTAR    = MBEW-BWTAR "fbo/111298 Sharedsperre
*           LMBEW_VJSTP     = MBEW-VJSTP "fbo/111298 Sharedsperre
            LMBEW_VJSTP     = lMBEW-VJSTP     "ch/4.6b
       TABLES                                                "BE/260996
            P_PTAB          = PTAB.                          "BE/260996

ENDMODULE.
