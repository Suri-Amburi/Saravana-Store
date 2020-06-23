*------------------------------------------------------------------
*        LHMG_CHECK
* Die Ladehilfsmittelmengen bezogen auf die Basismengeneinheit
* sollen in absteigender Reihenfolge eingegeben werden.
*------------------------------------------------------------------
MODULE LHMG_CHECK.

 CHECK BILDFLAG = SPACE.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ. "MK/19.04.95

 CALL FUNCTION 'MLGN_LHMG_CHECK'
      EXPORTING
           P_MESSAGE       = ' '
           P_MARA_MEINS    = MARA-MEINS
           P_MLGN_LHMG1    = MLGN-LHMG1
           P_MLGN_LHMG2    = MLGN-LHMG2
           P_MLGN_LHMG3    = MLGN-LHMG3
           P_MLGN_LHME1    = MLGN-LHME1
           P_MLGN_LHME2    = MLGN-LHME2
           P_MLGN_LHME3    = MLGN-LHME3
      TABLES
           MEINH           = MEINH .
*     EXCEPTIONS
*          ERROR_NACHRICHT = 01.

ENDMODULE.
