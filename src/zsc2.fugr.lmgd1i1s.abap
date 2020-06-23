*------------------------------------------------------------------
*  Module D250_PERKZ_WARN
* Wird das gueltige Periodenkz ueberschrieben und liegen zu diesem
* Kz Verbrauchswerte vor erfolgt eine Warnung.
* Das Modul laeuft on-request ab.
*------------------------------------------------------------------
MODULE D250_PERKZ_WARN.

  CHECK BILDFLAG IS INITIAL.           "mk/18.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.  "mk/18.04.95

  CALL FUNCTION 'D_250_PERKZ_WARN'
       EXPORTING
            P_PERKZ_DB     = *MARC-PERKZ
            P_PERKZ        = MARC-PERKZ
            P_PERIV_DB     = *MARC-PERIV
            P_PERIV        = MARC-PERIV
            P_KZRFB        = KZRFB
            P_MARA_MATNR   = RMMG1-MATNR
            P_MARC_WERKS   = RMMG1-WERKS
            P_ALTPERKZ     = LMARC-PERKZ  " vorher: ALTPERKZ
            P_ALTPERIV     = LMARC-PERIV  " vorher: ALTPERIV
            P_KZ_NO_WARN   = ' '
       IMPORTING
            P_FLGMVER      = RMMG2-FLGMVER
            P_FLGPROGWERTE = RMMG2-FLGPROGW
* AHE: 28.05.98 - A (4.0c)
       TABLES
            MESSAGE_TAB    = TMESSAGE.
* AHE: 28.05.98 - E
*      EXCEPTIONS
*           P_ERR_D_250_PERKZ_WARN = 01.

* AHE: 18.06.98 - A (4.0c)
  CALL FUNCTION 'PERKZ_WARN_DIBER'
       EXPORTING
            P_PERKZ_DB   = *MARC-PERKZ
            P_PERKZ      = MARC-PERKZ
            P_PERIV_DB   = *MARC-PERIV
            P_PERIV      = MARC-PERIV
            P_KZRFB      = KZRFB
            P_MARA_MATNR = RMMG1-MATNR
            P_MARC_WERKS = RMMG1-WERKS
            P_ALTPERKZ   = LMARC-PERKZ
            P_ALTPERIV   = LMARC-PERIV
            P_KZ_NO_WARN = ' '
       TABLES
            MESSAGE_TAB  = TMESSAGE.
* AHE: 18.06.98 - E

ENDMODULE.
