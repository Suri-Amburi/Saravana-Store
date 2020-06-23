*------------------------------------------------------------------
*Module MARA-ERVOL.
*
*Prüfen des Zulässigen Verpackungsvolumens
* - Zum Verpackungsvolumen muß eine Einheit eingegeben werden, diese
*   Einheit muß eine Volumeneinheit sein
* - Zur Volumentoleranz muß auch ein Volumen eingegeben werden
*------------------------------------------------------------------
MODULE MARA-ERVOL.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_ERVOL'
       EXPORTING
            WMARA_ERVOL = MARA-ERVOL
            WMARA_ERVOE = MARA-ERVOE
            WMARA_VOLTO = MARA-VOLTO.

ENDMODULE.
