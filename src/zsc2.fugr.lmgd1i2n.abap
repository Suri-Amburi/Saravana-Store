*------------------------------------------------------------------
*  Module MARC-NFMAT.                  "neu zu 3.0   ch/04.11.94
*  Pruefung Nachfolgematerial und Auslaufdatum
* - Das Auslaufdatum darf nicht in der Vergangenheit liegen
* - Falls das Auslaufkennzeichen = 1 ist, muß ein Nachfolgematerial
*   angegeben sein.
* - Das Nachfolgematerial muß ungleich dem Auslaufmaterial sein
* - Nachfolge- und Auslaufmaterial müssen die gleiche BasisME haben
* - Rekursivitätsprüfung bezüglich Stücklisten
* - Rekursivitätsprüfung bzgl. der Kette der Nachfolgematerialien
*   Diese Prüfung wurde vorerst wieder deaktiviert, da ein
*   mehrstufiger Auslauf generell nicht erlaubt sein soll
* - Setzten MARA-KZNFM, falls irgendein MARC-Segment ein Nachfolgemat.
*   hat
* - Falls es sich um einen abhängigen Parallelausläufer (KZAUS = 3)
*   handelt, kann kein Datum und Nachfolgemat angegeben werden
* - Für die Materialart des Nachfolgematerials muß Bestandsführung
*   vorgesehen sein.  (ch/28.8.95 zu 3.0A)
*------------------------------------------------------------------
MODULE MARC-NFMAT.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_NFMAT'
       EXPORTING
            P_MARA_MATNR  = MARA-MATNR
            P_MARA_MEINS  = MARA-MEINS
            P_MARC_KZAUS  = MARC-KZAUS
            P_MARC_WERKS  = MARC-WERKS
            P_RMMG1_WERKS = RMMG1-WERKS
            NEUFLAG       = NEUFLAG
            P_MARC_SOBSL  = MARC-SOBSL                "354141
       CHANGING
            P_MARC_AUSDT  = MARC-AUSDT
            P_MARC_NFMAT  = MARC-NFMAT
            P_MARA_KZNFM  = MARA-KZNFM
            RET_AUSDT     = LMARC-AUSDT
            RET_NFMAT     = LMARC-NFMAT
            UPD_NFMAT     = RMMG2-UPD_NFMAT
            SET_CURSOR    = RMMZU-CURS_FELD
       EXCEPTIONS
            ERR_MESSAGE   = 1
            OTHERS        = 2.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    IF NOT RMMZU-CURS_FELD IS INITIAL.
      SET CURSOR FIELD RMMZU-CURS_FELD.
    ENDIF.

    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.
