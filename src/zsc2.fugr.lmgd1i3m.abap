*------------------------------------------------------------------
*  Module MBEW-VERPR.
*
*  Bei Änderung des Verrechnungspreises im Falle von Standardpreis-
*  Steuerung (nur dann ist Verrechnungspreis eingabebereit), wird
*  der statistische Verrechnungspreis SALKV neu ermittelt.
*  Pruefung Verrechnungspreis.
*------------------------------------------------------------------
MODULE MBEW-VERPR.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_VERPR'
       EXPORTING
            WMBEW_VERPR = MBEW-VERPR
            WMBEW_LBKUM = MBEW-LBKUM
            WMBEW_VPRSV = MBEW-VPRSV
            WMBEW_PEINH = MBEW-PEINH
            LMBEW_VERPR = LMBEW-VERPR
            WMBEW_SALKV = MBEW-SALKV
            P_AKTYP     = T130M-AKTYP
            WMBEW_MATNR = MBEW-MATNR "fbo/111298 Sharedsperre
            WRMMG1_BWKEY = MBEW-BWKEY "fbo/111298 Sharedsperre
            WRMMG1_BWTAR = MBEW-BWTAR "fbo/111298 Sharedsperre
            LMBEW_PEINH = LMBEW-PEINH                 "note 1332060
       IMPORTING
            WMBEW_SALKV = MBEW-SALKV
       TABLES                                                "BE/260996
            P_PTAB      = PTAB.                              "BE/260996

ENDMODULE.
