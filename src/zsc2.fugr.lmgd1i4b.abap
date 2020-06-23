*------------------------------------------------------------------
*  Module MLGN-LHMG2
*------------------------------------------------------------------
MODULE MLGN-LHMG2.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MLGN_LHMG1_LHMG2_LHMG3'
       EXPORTING
            MLGN_IN_LHMG_X  = MLGN-LHMG2
            MLGN_IN_LHME_X  = MLGN-LHME2
            MLGN_IN_LETY_X  = MLGN-LETY2.
*      EXCEPTIONS
*           ERROR_NACHRICHT = 01.

ENDMODULE.
