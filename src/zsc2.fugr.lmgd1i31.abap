*------------------------------------------------------------------
*           MARC-QZGTP.
*
* Wenn Feld MARC-QZGPT initial ist, wird geprüft, ob dies aufgrund
* des QM-Steuerschlüssels für die Beschaffung zulässig ist.
*
* Falls kein Steuerschlüssel für die QM-Beschaffung eingegeben wurde,
* obwohl ein Zeugnisty eingegeben wurde, erfolgt eine entspr. Warnmeldg.
*------------------------------------------------------------------
MODULE MARC-QZGTP.

 CHECK BILDFLAG IS INITIAL.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CALL FUNCTION 'MARC_QZGTP'
      EXPORTING
           P_MARC_QZGTP    =  MARC-QZGTP
           P_MARC_SSQSS    =  MARC-SSQSS
           RET_QZGTP       =  LMARC-QZGTP
           RET_SSQSS       =  LMARC-SSQSS
           P_MESSAGE       =  ' '
      IMPORTING
           RET_QZGTP       =  LMARC-QZGTP
      EXCEPTIONS
           ERROR_NACHRICHT = 01.

 IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'MARC-QZGTP'.
    MESSAGE E869.
 ENDIF.
ENDMODULE.
