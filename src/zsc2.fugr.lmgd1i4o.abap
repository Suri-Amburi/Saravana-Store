*------------------------------------------------------------------
*  Module MPOP-OPGRA.
* Bei Parameteroptimierung ist ein Optimierungsgrad anzugeben.
*------------------------------------------------------------------
MODULE MPOP-OPGRA.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_OPGRA'
       EXPORTING
            P_KZPAR      = MPOP-KZPAR
            P_OPGRA      = MPOP-OPGRA
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MPOP_OPGRA = 01.

ENDMODULE.
