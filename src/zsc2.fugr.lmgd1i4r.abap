*------------------------------------------------------------------
*  Module MPOP-KZINI.
* Bei der Erstanlage muß eine Initialisierung angegeben werden.
* Bei manueller Initialisierung kommt ein Bild, auf dem bestimmte
* Prognoseparameterwerte eingegeben werden können.
*mk/06.04.95: Zusätzliche Prognoseparameter als Bildbaustein in
*Hauptbild integriert, deswegen Aufruf Zusatzbild nicht mehr nötig
*------------------------------------------------------------------
MODULE MPOP-KZINI.

* dieses Modul soll nur angesprungen werden, wenn die Prognose zum
* erstenmal angelegt wird, also beim hinzufügen ( das Prognosebild
* kann beim Hinzufügen nur einmal angesprungen werden ).

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

* lesen evtl. schon vorhandener Prognosewerte für MPOP_KZINI;
* nur relevant beim Hinzufügen (s. a. MPOP_KZINI);
  IF T130M-AKTYP = AKTYPH.
    CALL FUNCTION 'PROW_GET_BILD'
         EXPORTING
              MATNR  = MARA-MATNR
              WERKS  = MARC-WERKS
         TABLES
              WPROWM = TPROWF
              XPROWM = DTPROWF
         EXCEPTIONS
              OTHERS = 1.
  ENDIF.

  CALL FUNCTION 'MPOP_KZINI'
       EXPORTING
            P_PRMOD      = MPOP-PRMOD
            P_LPRMOD     = LMPOP-PRMOD
            P_KZINI      = MPOP-KZINI
            P_AKTYP      = T130M-AKTYP
            P_KZ_NO_WARN = ' '
       TABLES
            TPROWF_TAB   = TPROWF.
*      EXCEPTIONS
*           P_ERR_MPOP_KZINI = 01.

ENDMODULE.
