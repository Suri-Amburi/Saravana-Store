
*------------------------------------------------------------------
*  Module MPOP-ALPHA.
* Der Alpha-Faktor muß zwischen Null und Eins liegen.
*------------------------------------------------------------------
MODULE MPOP-ALPHA.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_ALPHA'
       EXPORTING
            P_PRMOD      = MPOP-PRMOD
            P_ALPHA      = MPOP-ALPHA
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MPOP_ALPHA = 01.

ENDMODULE.
