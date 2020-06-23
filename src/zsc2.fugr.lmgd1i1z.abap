*------------------------------------------------------------------
*  Module MARC-UEETK.
*  Pruefung der Überlieferufngstoleranz in Verbindung mit dem Überlie-
*  ferungskennzeichen für Fertigungsaufträge (aufAVO-Bild)
*------------------------------------------------------------------
MODULE MARC-UEETK.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_UEETK'
       EXPORTING
            WMARC_UEETK = MARC-UEETK
            WMARC_UEETO = MARC-UEETO.

ENDMODULE.
