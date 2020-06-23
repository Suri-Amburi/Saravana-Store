*------------------------------------------------------------------
*  Module MARC-BSTRF.
*  Beim Verfahren 'Feste Bestellmenge' sind die Felder
*  Mindestbestellmenge, Maximalbestellmenge, Rundungswert unnötig
*  Beim Verfahren 'Fix/Splitting' sind die Felder
*  Mindestbestellmenge, Maximalbestellmenge unnötig, allerdings muß
*  der Rundungswert eingegeben werden. Die Fixmenge muß dann ein
*  exaktes Vielfaches des Rundungswertes sein.
*------------------------------------------------------------------
MODULE MARC-BSTRF.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_BSTRF'
       EXPORTING
            P_BSTRF      = MARC-BSTRF
            P_RDPRF      = MARC-RDPRF
            P_BSTFE      = MARC-BSTFE
            P_BSTMA      = MARC-BSTMA
            P_BSTMI      = MARC-BSTMI
            P_DISPR      = MARC-DISPR
            P_DISLS      = MARC-DISLS
            P_WERKS      = MARC-WERKS
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_BSTMA      = MARC-BSTMA
            P_BSTMI      = MARC-BSTMI
            P_BSTRF      = MARC-BSTRF
            P_RDPRF      = MARC-RDPRF.
ENDMODULE.
