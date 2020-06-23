*------------------------------------------------------------------
*  Module MPOP-MODAV.
* Wird Modellauswahl gewünscht, muß ein Verfahren angegeben werden.
*------------------------------------------------------------------
MODULE MPOP-MODAV.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_MODAV'
       EXPORTING
            P_MODAW      = MPOP-MODAW
            P_MODAV      = MPOP-MODAV
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MPOP_MODAV = 01.

ENDMODULE.
