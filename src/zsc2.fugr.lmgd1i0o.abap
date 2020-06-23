*-----------------------------------------------------------------------
*  Module MARA-PRDHA
*  Prüfung der Produkthierarchie auf Mandantenebene.
*  Es wird eine Warnung ausgegeben, wenn die Produkthierarchie
*  vorgegeben wird, aber bereits Detaildaten auf MVKE-Ebene
*  vorhanden sein könnten (aus Performance-Gründen wird die
*  MVKE nicht extra für diese Prüfung gelesen)
*  Diese Prüfung findet nur statt, wenn die Produkthierarchie
*  geändert wurde (on chain-request nicht möglich, wegen Vorlage-Daten)
*-----------------------------------------------------------------------
MODULE MARA-PRDHA.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
*  Prüfung für Retail nicht gültig, da Daten-Durchreichung   "BE/310796
  CHECK RMMG2-FLG_RETAIL IS INITIAL.   "BE/310796

  CALL FUNCTION 'MARA_PRDHA'
       EXPORTING
            MARA_PRDHA = MARA-PRDHA
            RET_PRDHA  = LMARA-PRDHA
            P_MESSAGE  = ' '
       TABLES
            PTAB_IN    = PTAB.

ENDMODULE.
