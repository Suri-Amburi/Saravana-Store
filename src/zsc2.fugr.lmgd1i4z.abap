*------------------------------------------------------------------
*  Module MPOP-ANZPR.
* Die Anzahl Prognoseperioden muß größer Null sein.
*------------------------------------------------------------------
MODULE MPOP-ANZPR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_ANZPR'
       EXPORTING
            P_PRMOD      = MPOP-PRMOD
            P_ANZPR      = MPOP-ANZPR
            P_KZ_NO_WARN = ' '.
*    EXCEPTIONS
*         P_ERR_MPOP_ANZPR = 01.

ENDMODULE.
