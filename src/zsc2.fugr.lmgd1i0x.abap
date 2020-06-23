*------------------------------------------------------------------
*  Module MARA-ETIFO
*
* Prüfung Etikettenart und Etikettenformat                           .
*------------------------------------------------------------------
MODULE MARA-ETIFO.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_ETIFO'
       EXPORTING
            P_MARA_ETIAR = MARA-ETIAR
            P_MARA_ETIFO = MARA-ETIFO.
*      EXCEPTIONS
*           ERROR_NACHRICHT = 01.

ENDMODULE.
