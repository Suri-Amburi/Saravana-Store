*----------------------------------------------------------------------
* Module MARA-KZGVH.                                   "4.0A  BE/130897
*
* Prüfen Kennzeichen Versandhilfsmittel
* Wenn gesetzt, dann muß das zulässige Verpackungsvolumen kleiner /
* gleich dem Eigenvolumen sein.
*----------------------------------------------------------------------
MODULE MARA-KZGVH.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_KZGVH'
       EXPORTING
            WMARA_KZGVH = MARA-KZGVH
            WMARA_ERVOL = MARA-ERVOL
            WMARA_ERVOE = MARA-ERVOE
            WMARA_VOLUM = MARA-VOLUM
            WMARA_VOLEH = MARA-VOLEH.

ENDMODULE.
