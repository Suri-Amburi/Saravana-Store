*---------------------------------------------------------------------*
* Module     TEXT_GEAENDERT                                           *
*---------------------------------------------------------------------*
*       Es wird überprüft, ob ein Langtext geändert wurde, hinzugefügt*
*       oder gelöscht wurde                                           *
*       Wenn ja, wird kztext_sichern gesetzt                          *
*---------------------------------------------------------------------*
MODULE TEXT_GEAENDERT.
  CALL FUNCTION 'TEXT_GEAENDERT'
       EXPORTING
            P_AKTYP          = T130M-AKTYP
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            P_KZTEXT_SICHERN = RMMG2-VB_TEXT.
ENDMODULE.
