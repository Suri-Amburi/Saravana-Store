*------------------------------------------------------------------
*  Module MBEW-ZKPRS.
*
* Zukuenftiger Preis und zukuenftiges Datum muessen gleichzeitig
* gesetzt werden.
* Das zukuenftige Datum darf nicht in der Vergangenheit liegen.
*------------------------------------------------------------------
MODULE MBEW-ZKPRS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_ZKPRS'
       EXPORTING
            WMBEW_ZKPRS     = MBEW-ZKPRS
            WMBEW_ZKDAT     = MBEW-ZKDAT
            WMBEW_VPRSV     = MBEW-VPRSV        "ch/4.5b
            P_AKTYP         = T130M-AKTYP
            WMBEW_MATNR     = MBEW-MATNR "fbo/111298 Sharedsperre
            WRMMG1_BWKEY    = MBEW-BWKEY "fbo/111298 Sharedsperre
            WRMMG1_BWTAR    = MBEW-BWTAR "fbo/111298 Sharedsperre
            LMBEW_ZKPRS     = LMBEW-ZKPRS "fbo/111298 Sharedsperre
            LMBEW_ZKDAT     = LMBEW-ZKDAT "fbo/111298 Sharedsperre
       IMPORTING
            WMBEW_ZKDAT     = MBEW-ZKDAT.

ENDMODULE.
