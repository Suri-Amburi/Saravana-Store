*------------------------------------------------------------------
*  Module MBEW-VMVER.
*
*  Pruefung Verrechnungspreis Vormonat
*------------------------------------------------------------------
MODULE MBEW-VMVER.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_VMVER'
       EXPORTING
            WMBEW_VMVER = MBEW-VMVER
            WMBEW_VMVPR = MBEW-VMVPR
            P_AKTYP     = T130M-AKTYP
            WMBEW_MATNR = MBEW-MATNR "fbo/111298 Sharedsperre
            WRMMG1_BWKEY = MBEW-BWKEY "fbo/111298 Sharedsperre
            WRMMG1_BWTAR = MBEW-BWTAR "fbo/111298 Sharedsperre
*           LMBEW_VMVER  = MBEW-VMVER "fbo/111298 Sharedsperre
            LMBEW_VMVER  = lMBEW-VMVER   "ch/4.6b
            WMBEW_VMKUM = MBEW-VMKUM
            WMBEW_VMPEI = MBEW-VMPEI
            LMBEW_VMPEI = LMBEW-VMPEI                 "note 1332060
       TABLES                                                "BE/260996
            P_PTAB      = PTAB                               "BE/260996
       CHANGING
            WMBEW_VMSAV  = MBEW-VMSAV.
ENDMODULE.
