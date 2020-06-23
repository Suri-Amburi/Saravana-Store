
*------------------------------------------------------------------
*           MARA-QMPUR
*Wenn KZ QMPUR (QM-AKTIV = X) sitzt, dann wird das Feld MARC-SSQSS
*zur Mußeingabe.
*
*Wenn KZ QMPUR zurückgenommen wird, obwohl noch QM-Beschaffungsdaten
*zu einem Werk vorhanden sind, erfolgt eine entsprechende Warnmeldung.
*Dies geschieht auch, wenn der QM-Steuerschlüssel für dei Beschaffung
*gepflegt wurde, ohne daß das KZ QMPUR gesetzt ist.
*------------------------------------------------------------------
MODULE MARA-QMPUR.

 CHECK BILDFLAG IS INITIAL.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CALL FUNCTION 'MARA_QMPUR'
       EXPORTING
            P_MESSAGE       = ' '
            RET_QMPUR       = LMARA-QMPUR
            RET_SSQSS       = LMARC-SSQSS
            P_MARC_SSQSS    = MARC-SSQSS
            P_MARA_QMPUR    = MARA-QMPUR
            P_MARA_MATNR    = MARA-MATNR
            P_RM03M_WERKS   = RMMG1-WERKS
       IMPORTING
            RET_QMPUR       = LMARA-QMPUR
            RET_SSQSS       = LMARC-SSQSS .
*      EXCEPTIONS
*           ERROR_NACHRICHT = 01.

ENDMODULE.
