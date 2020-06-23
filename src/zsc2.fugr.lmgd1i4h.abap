*------------------------------------------------------------------
*  Module MPOP-TWERT.
* Der Trendwert ist nur bei bestimmten Prognosemodellen
* relevant. Ist er nicht relevant wird er mit einer
* Warnung zurückgesetzt.
*------------------------------------------------------------------
MODULE MPOP-TWERT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_TWERT'
       EXPORTING
            P_TWERT      = MPOP-TWERT
            P_VMTWE      = MPOP-VMTWE
            P_PRMOD      = MPOP-PRMOD
            P_MODAW      = MPOP-MODAW
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_TWERT      = MPOP-TWERT
            P_VMTWE      = MPOP-VMTWE.
*      EXCEPTIONS
*           P_ERR_MPOP_TWERT = 01.

ENDMODULE.
