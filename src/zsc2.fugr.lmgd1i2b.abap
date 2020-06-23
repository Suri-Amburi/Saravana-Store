*------------------------------------------------------------------
*  Module MARC-PRCTR.
*  Pruefung der Profitcenters
*------------------------------------------------------------------
MODULE MARC-PRCTR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_PRCTR'
       EXPORTING
            WMARC_PRCTR  = MARC-PRCTR
            LMARC_PRCTR  = LMARC-PRCTR                "note 1106510
            WRMMG1_BWKEY = RMMG1-BWKEY
            WRMMG1_WERKS = RMMG1-WERKS                "note 978218
            WRMMG1_MATNR = RMMG1-MATNR                "note 1057674
            DB_MARC_PRCTR = *MARC-PRCTR.              "note 1079803

ENDMODULE.
