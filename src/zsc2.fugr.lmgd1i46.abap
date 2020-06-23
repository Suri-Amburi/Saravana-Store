*----------------------------------------------------------------------
* Module MLGN-VOMEM                                    "4.0A  BE/010897
*
* Anhand der Ausprägung der Vorschlagsmengeneinheit wird auf das
* Vorhandensein der entsprechenden Mengeneinheit geprüft und eine
* Warnmeldung ausgegeben, wenn diese noch nicht gepflegt ist.
*----------------------------------------------------------------------
MODULE MLGN-VOMEM.                                     "4.0A  BE/010897

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MLGN_VOMEM'
       EXPORTING
            WMLGN_VOMEM       = MLGN-VOMEM
            WMLGN_LVSME       = MLGN-LVSME
            WMARA_MEINS       = MARA-MEINS
            WMARA_BSTME       = MARA-BSTME
            WMARC_AUSME       = MARC-AUSME.

ENDMODULE.
