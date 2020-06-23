*------------------------------------------------------------------
*  Module MARC-KZKUP.                  "neu zu 3.0   ch/14.11.94
*  Pruefung Kennzeichen Kuppelprodukt
* - Setzten MARA-KZKUP, falls irgendein MARC-Segment dieses Kennzeichen
*   gesetzt hat
*------------------------------------------------------------------
MODULE MARC-KZKUP.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 15.03.98 - A (4.0c)
* Prüfung neues Feld MARC-FXPRU: KZ Festpreiskuppelprodukt
  CALL FUNCTION 'CK06_MARC_FXPRU_CHECK'
       EXPORTING
            I_KZKUP = MARC-KZKUP
            I_FXPRU = MARC-FXPRU.
*      TABLES
*           ET_MATMESS        =
*      EXCEPTIONS
*           FXPRU_NOT_ALLOWED = 1
*           OTHERS            = 2.
* AHE: 15.03.98 - E

  CALL FUNCTION 'MARC_KZKUP'
       EXPORTING
            P_MATNR      = MARC-MATNR
            P_WERKS      = MARC-WERKS
            P_MARC_KZKUP = MARC-KZKUP
            P_MARC_BESKZ = MARC-BESKZ
            NEUFLAG      = NEUFLAG
            P_LMARC_BESKZ = LMARC-BESKZ                     "note 876939
       CHANGING
            P_MARA_KZKUP = MARA-KZKUP
            RET_KZKUP    = LMARC-KZKUP.
*      EXCEPTIONS
*           KZKUP_NOT_ALLOWED = 1
*           OTHERS            = 2.

ENDMODULE.
