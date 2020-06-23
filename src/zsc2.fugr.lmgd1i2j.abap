*------------------------------------------------------------------
*  Module MARC-FRTME
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*------------------------------------------------------------------
MODULE MARC-FRTME.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 25.03.99 - A (4.6a)
* Test nun auch für Varianten, falls man einen SA pflegt
* (im Rahmen der Realisierung von log. Mengeneinheiten notwendig);
* --> Aufruf FB MARA_FRTME_RETAIL

  IF RMMG2-FLG_RETAIL IS INITIAL.
* AHE: 25.03.99 - E

    CALL FUNCTION 'MARC_FRTME'
         EXPORTING
              WMARA_MEINS      = MARA-MEINS
              WMARC_FRTME      = MARC-FRTME
              WMARA_ATTYP      = MARA-ATTYP  "BE/050696
              WMARA_SATNR      = MARA-SATNR  "BE/050696
              WMARC_WERKS      = MARC-WERKS  "BE/050696
              WRMMG1_REF_MATNR = RMMG1_REF-MATNR
              WRMMZU           = RMMZU
              LMARC_FRTME      = LMARC-FRTME
              AKTYP            = T130M-AKTYP
              OK_CODE          = RMMZU-OKCODE
         IMPORTING
              WMARC_FRTME      = MARC-FRTME
              WRMMZU           = RMMZU
              FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
              HOKCODE          = RMMZU-HOKCODE
              OK_CODE          = RMMZU-OKCODE
         TABLES
              MEINH            = MEINH
              Z_MEINH          = RMEINH
              DMEINH           = DMEINH.

* AHE: 25.03.99 - A (4.6a)
  ELSE.

    CALL FUNCTION 'MARC_FRTME_RETAIL'
         EXPORTING
              WMARC_FRTME      = MARC-FRTME
              WMARA_MEINS      = MARA-MEINS
              WMARA_ATTYP      = MARA-ATTYP
              WMARA_SATNR      = MARA-SATNR
              WMARC_WERKS      = MARC-WERKS
              WRMMG1_REF_MATNR = RMMG1_REF-MATNR
              WRMMZU           = RMMZU
              LMARC_FRTME      = LMARC-FRTME
              AKTYP            = T130M-AKTYP
              OK_CODE          = RMMZU-OKCODE
*             FLG_UEBERNAHME   = ' '
*             FLG_PRUEFDUNKEL  = ' '
              WMARA_MATNR      = MARA-MATNR
         IMPORTING
              WMARC_FRTME      = MARC-FRTME
              WRMMZU           = RMMZU
              FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
              HOKCODE          = RMMZU-HOKCODE
              OK_CODE          = RMMZU-OKCODE
         TABLES
              MEINH            = MEINH
              Z_MEINH          = RMEINH
              DMEINH           = DMEINH.
*        EXCEPTIONS
*             ERROR_NACHRICHT  = 1
*             ERROR_MEINS      = 2
*             OTHERS           = 3

  ENDIF.
* AHE: 25.03.99 - E

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ENDIF.

ENDMODULE.
