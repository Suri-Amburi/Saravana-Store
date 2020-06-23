*------------------------------------------------------------------
*  Module MBEW-VJVER.
*
*  Pruefung Verrechnungspreis.
*------------------------------------------------------------------
MODULE MBEW-VJVER.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_VJVER'
       EXPORTING
            WMBEW_VJVER = MBEW-VJVER
            WMBEW_VJVPR = MBEW-VJVPR
            P_AKTYP     = T130M-AKTYP
            WMBEW_MATNR = MBEW-MATNR "fbo/111298 Sharedsperre
            WRMMG1_BWKEY = MBEW-BWKEY "fbo/111298 Sharedsperre
            WRMMG1_BWTAR = MBEW-BWTAR "fbo/111298 Sharedsperre
*           LMBEW_VJVER  = MBEW-VJVER "fbo/111298 Sharedsperre
            LMBEW_VJVER  = lMBEW-VJVER    "ch/4.6b
            WMBEW_VJKUM = MBEW-VJKUM
            WMBEW_VJPEI = MBEW-VJPEI
            LMBEW_VJPEI = LMBEW-VJPEI                 "note 1332060
       TABLES                                                "BE/260996
            P_PTAB      = PTAB                               "BE/260996
       CHANGING
            WMBEW_VJSAV  = MBEW-VJSAV.
ENDMODULE.
