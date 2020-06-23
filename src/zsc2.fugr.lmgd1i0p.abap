*-----------------------------------------------------------------------
*  Module MARA-KZKFG              neu zu 3.0C
*  Wenn das Kennzeichen Konfigurierbares Material gesetzt wird, darf
*  in keinem MARC-Segment ein Standardprodukt angegeben sein
*  Außerdem erfolgt eine Meldung, wenn noch keine Konfigurationsbew.
*  durchgeführt wurde.
*-----------------------------------------------------------------------
MODULE MARA-KZKFG.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_KZKFG'
       EXPORTING
            RET_KZKFG  = LMARA-KZKFG
            MARA_MATNR = MARA-MATNR
            MARA_MTART = MARA-MTART
            MARC_WERKS = MARC-WERKS
            MARC_STDPD = MARC-STDPD
            MARA_SATNR = MARA-SATNR
            P_NEUFLAG  = NEUFLAG
            P_MESSAGE  = ' '
       CHANGING
            MARA_KZKFG = MARA-KZKFG
       EXCEPTIONS                               "ch zu 4.0C
            OTHERS     = 1.                     "ch zu 4.0C

  IF SY-SUBRC NE 0.                             "ch zu 4.0C
*    MESSAGE E315(MM).                           "ch zu 4.0C
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno. "note 1418325
  ENDIF.                                        "ch zu 4.0C

ENDMODULE.
