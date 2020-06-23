*------------------------------------------------------------------
*  Module MPOP-BETA1.
* Der Beta-Faktor muß zwischen Null und Eins liegen.
*------------------------------------------------------------------
MODULE MPOP-BETA1.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_BETA1'
       EXPORTING
            P_PRMOD      = MPOP-PRMOD
            P_BETA1      = MPOP-BETA1
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MPOP_BETA1 = 01.

ENDMODULE.
