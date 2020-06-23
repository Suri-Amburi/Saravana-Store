*------------------------------------------------------------------
*  Module MPOP-GWERT.
* Der Grundwert ist nur bei bestimmten Prognosemodellen
* relevant. Ist er nicht relevant wird er mit einer
* Warnung zurückgesetzt.
*------------------------------------------------------------------
MODULE MPOP-GWERT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_GWERT'
       EXPORTING
            P_GWERT      = MPOP-GWERT
            P_VMGWE      = MPOP-VMGWE
            P_PRMOD      = MPOP-PRMOD
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_GWERT      = MPOP-GWERT
            P_VMGWE      = MPOP-VMGWE.
*      EXCEPTIONS
*           P_ERR_MPOP_GWERT = 01.

ENDMODULE.
