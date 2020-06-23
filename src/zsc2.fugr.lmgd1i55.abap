*-----------------------------------------------------------------------
*  Module Mvke-prodh
*  Prüfung der Produkthierarchie auf Ebene der MVKE gegen die
*  Produkthierarchie auf Mandantenebene
*  Diese Prüfung findet außer beim ersten Prozessieren des Bildes
*  in der Transaktion nur noch statt, wenn die Produkthierarchie
*  zur MVKE geändert wurde
* mk/26.05.95:
*  Diese Prüfung findet nur noch statt, wenn die Produkthierarchie in
*  der MVKE geändert wurde
*-----------------------------------------------------------------------
MODULE MVKE-PRODH.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_PRODH'
       EXPORTING
            WMARA_PRDHA  = MARA-PRDHA
            WMVKE_PRODH  = MVKE-PRODH
            LMVKE_PRODH  = LMVKE-PRODH
            P_MESSAGE    = ' '.
ENDMODULE.
