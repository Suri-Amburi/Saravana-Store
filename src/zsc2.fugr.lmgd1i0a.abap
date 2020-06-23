*------------------------------------------------------------------
* Module MARA-MSTDE
* Prüfen Gültigkeitsdatum zum allgemeinen Materialstatus Einkauf
*------------------------------------------------------------------
* war vor 4.0 im LMGD2I01                                       /ch
MODULE MARA-MSTDE.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_MSTDE'
       EXPORTING
            LMARA_MSTAE = LMARA-MSTAE           "ch zu 4.0C
            LMARA_MSTDE = LMARA-MSTDE           "ch zu 4.0C
            WMARA_MSTAE = MARA-MSTAE
            WMARA_MSTDE = MARA-MSTDE.

ENDMODULE.
