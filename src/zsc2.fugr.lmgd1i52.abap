*------------------------------------------------------------------
*  Module MVKE-VRKME
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Wird
* keine eingegeben wird die Basismengeneinheit gesetzt.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*
* ab 2.1B Prüfung, ob eine kaufmännische Einheit eingegeben wurde
*------------------------------------------------------------------
MODULE MVKE-VRKME.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MVKE_VRKME'
       EXPORTING
            WMARA_MEINS      = MARA-MEINS
* AHE: 21.02.99 - A (4.6a)
            WMARA_MATNR      = MARA-MATNR
            WMARA_ATTYP      = MARA-ATTYP
* AHE: 21.02.99 - E
            WMVKE_VRKME      = MVKE-VRKME
            WRMMG1_REF_MATNR = RMMG1_REF-MATNR
            WRMMZU           = RMMZU
            LMVKE_VRKME      = LMVKE-VRKME
            AKTYP            = T130M-AKTYP
            OK_CODE          = RMMZU-OKCODE
       IMPORTING
            WMVKE_VRKME      = MVKE-VRKME
            WRMMZU           = RMMZU
            FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
            HOKCODE          = RMMZU-HOKCODE
            OK_CODE          = RMMZU-OKCODE
       TABLES
            MEINH            = MEINH
            Z_MEINH          = RMEINH
            DMEINH           = DMEINH.

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ENDIF.

ENDMODULE.
