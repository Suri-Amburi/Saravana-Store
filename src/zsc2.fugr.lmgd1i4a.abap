*------------------------------------------------------------------
*  Module MLGN-LHMG3
*------------------------------------------------------------------
MODULE MLGN-LHMG3.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MLGN_LHMG1_LHMG2_LHMG3'
       EXPORTING
            MLGN_IN_LHMG_X  = MLGN-LHMG3
            MLGN_IN_LHME_X  = MLGN-LHME3
            MLGN_IN_LETY_X  = MLGN-LETY3 .
*      EXCEPTIONS
*           ERROR_NACHRICHT = 01.

ENDMODULE.
