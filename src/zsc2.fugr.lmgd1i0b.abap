*------------------------------------------------------------------
* Module MARA-MSTDV
* Prüfen Gültigkeitsdatum zum allgemeinen Materialstatus Vertrieb
*------------------------------------------------------------------
* war vor 4.0 im LMGD2I01                                       /ch
MODULE MARA-MSTDV.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_MSTDV'
       EXPORTING
            LMARA_MSTAV = LMARA-MSTAV           "ch zu 4.0C
            LMARA_MSTDV = LMARA-MSTDV           "ch zu 4.0C
            WMARA_MSTAV = MARA-MSTAV
            WMARA_MSTDV = MARA-MSTDV.

ENDMODULE.
