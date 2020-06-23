*------------------------------------------------------------------
*  Module MLGN-LHME1
*------------------------------------------------------------------
MODULE MLGN-LHME1.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MLGN_LHME1_LHME2_LHME3'
       EXPORTING
            MLGN_IN_LHME_X  = MLGN-LHME1
            MARA_IN_MEINS   = MARA-MEINS
            MARC_IN_AUSME   = MARC-AUSME
            MLGN_IN_LVSME   = MLGN-LVSME
            LGNUM           = MLGN-LGNUM
            MATNR           = MLGN-MATNR
            WERKS           = MARC-WERKS.  "note 977651
*      EXCEPTIONS
*           ERROR_NACHRICHT = 01.

ENDMODULE.
