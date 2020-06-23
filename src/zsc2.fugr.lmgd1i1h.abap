*-----------------------------------------------------------------
* MODULE MARA-MSTDV
* Prüfen Gültigkeitsdatum zum werksspezifischen Materialstatus
*-----------------------------------------------------------------
MODULE MARC-MMSTD.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_MMSTD'
       EXPORTING
            LMARC_MMSTA = LMARC-MMSTA            "ch zu 4.0C
            LMARC_MMSTD = LMARC-MMSTD            "ch zu 4.0C
            WMARC_MMSTA = MARC-MMSTA
            WMARC_MMSTD = MARC-MMSTD.

ENDMODULE.
