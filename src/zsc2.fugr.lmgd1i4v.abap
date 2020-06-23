*------------------------------------------------------------------
*  Module MPOP-GAMMA.
* Der Gamma-Faktor muß zwischen Null und Eins liegen.
*------------------------------------------------------------------
MODULE MPOP-GAMMA.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_GAMMA'
       EXPORTING
            P_PRMOD      = MPOP-PRMOD
            P_GAMMA      = MPOP-GAMMA
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MPOP_GAMMA = 01.

ENDMODULE.
