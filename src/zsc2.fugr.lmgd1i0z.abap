*------------------------------------------------------------------
*Module MARA-ERGEW.
*
*Prüfen des Zulässigen Verpackungsgewichtes
* - Zum Verpackungsgewicht muß eine Einheit eingegeben werden, diese
*   Einheit muß eine Gewichtseinheit sein
* - Zur Gewichtstoleranz muß auch ein Gewicht eingegeben werden
*------------------------------------------------------------------
MODULE MARA-ERGEW.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_ERGEW'
       EXPORTING
            WMARA_ERGEW = MARA-ERGEW
            WMARA_ERGEI = MARA-ERGEI
            WMARA_GEWTO = MARA-GEWTO.

ENDMODULE.
