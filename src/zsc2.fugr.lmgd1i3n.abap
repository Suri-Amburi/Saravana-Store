*------------------------------------------------------------------
*  Module MBEW-STPRS.
*
*  Pruefung Standardpreis - bei Preissteuerung S darf er nicht Null sein
*------------------------------------------------------------------
MODULE MBEW-STPRS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
ENHANCEMENT-POINT LMGD1I3N_01 SPOTS ES_LMGD1I3N INCLUDE BOUND.

  CALL FUNCTION 'MBEW_GET_ML_BUFFER'                    "note 1347054
       IMPORTING
            MLMBEW = UMBEW.

* note 1347054: do check in case of previous warning message for
* price unit only, if relevant fields were changed on the screen
  gv_do_stprs_check = 'X'.
  IF ( RMMZU-PS_PEINH = X ) AND
     ( ( UMBEW-VPRSV EQ MBEW-VPRSV ) AND
       ( UMBEW-VERPR EQ MBEW-VERPR ) AND
       ( UMBEW-STPRS EQ MBEW-STPRS ) AND
       ( UMBEW-PEINH EQ MBEW-PEINH ) AND
       ( UMBEW-MATNR EQ MBEW-MATNR ) AND
       ( UMBEW-BWKEY EQ MBEW-BWKEY ) AND
       ( UMBEW-BWTAR EQ MBEW-BWTAR ) AND
       ( UMBEW-BKLAS EQ MBEW-BKLAS ) ).                   "note 1749907
    CLEAR gv_do_stprs_check.
  ENDIF.

  IF gv_do_stprs_check IS NOT INITIAL.

* Initialisierung UMBEW -> wird jetzt anstelle LMBEW übergeben
    IF UMBEW-MATNR NE LMBEW-MATNR OR
       UMBEW-BWKEY NE LMBEW-BWKEY OR
       UMBEW-BWTAR NE LMBEW-BWTAR.
      UMBEW = LMBEW.
    ENDIF.

    CALL FUNCTION 'MBEW_STPRS'
         EXPORTING
              WMBEW_VPRSV = MBEW-VPRSV
              WMBEW_STPRS = MBEW-STPRS
              LMBEW_STPRS = UMBEW-STPRS                     "note 1347054
*             WMBEW_peinh = MBEW-peinh            "ch/4.6  /deakt 4.6C
              LMBEW_peinh = UMBEW-peinh                     "note 1347054
              WMBEW_KALKL = MBEW-KALKL                   "4.0A  BE/061197
              WMBEW_LFMON = MBEW-LFMON                   "4.0A  BE/061197
              WMBEW_LFGJA = MBEW-LFGJA                   "4.0A  BE/061197
              P_AKTYP     = T130M-AKTYP
              WMBEW_MATNR = MBEW-MATNR "fbo/111298 Sharedsperre
              WRMMG1_BWKEY = MBEW-BWKEY "fbo/111298 Sharedsperre
              WRMMG1_BWTAR = MBEW-BWTAR "fbo/111298 Sharedsperre
         TABLES                                                "BE/260996
              P_PTAB      = PTAB                               "BE/260996
         CHANGING
              WMBEW_peinh = MBEW-peinh.           "ch/4.6c
  ENDIF.
ENDMODULE.
