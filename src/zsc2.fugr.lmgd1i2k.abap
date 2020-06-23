*------------------------------------------------------------------
*  Module Marc-Expme
*
* Die aus der statistischen Warennummer kommende Mengeneinheit ( T604 )
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*------------------------------------------------------------------
MODULE MARC-EXPME.

  CHECK BILDFLAG = SPACE.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 21.02.99 - A (4.6a)
* Test nun auch für Varianten, falls man einen SA pflegt
* (im Rahmen der Realisierung von log. Mengeneinheiten notwendig);
* --> Aufruf FB MARA_BSTME_RETAIL

  IF RMMG2-FLG_RETAIL IS INITIAL.
* AHE: 21.02.99 - E

    CALL FUNCTION 'MARC_EXPME'
         EXPORTING
              P_AKTYP           = T130M-AKTYP
              MARC_IN_STAWN     = MARC-STAWN
              WRMMG1_WERKS      = RMMG1-WERKS
              MARC_IN_EXPME     = MARC-EXPME
              MARA_IN_MEINS     = MARA-MEINS
              LMARC_EXPME       = LMARC-EXPME
              P_MESSAGE         = ' '
              OK_CODE           = RMMZU-OKCODE
              P_RM03M_REF_MATNR = RMMG1_REF-MATNR
         IMPORTING
              MARC_IN_EXPME     = MARC-EXPME
              P_RM03M_MEINH     = RMMZU-MEINH
              P_RM03M_UMREZ     = RMMZU-UMREZ
              P_RM03M_UMREN     = RMMZU-UMREN
              FLAG_BILDFOLGE    = RMMZU-BILDFOLGE
              OK_CODE           = RMMZU-OKCODE
              HOKCODE           = RMMZU-HOKCODE
         TABLES
              MEINH             = MEINH
              Z_MEINH           = RMEINH
              DMEINH            = DMEINH.

* AHE: 05.02.99 - A (4.6a)
  ELSE.

    CALL FUNCTION 'MARC_EXPME_RETAIL'
         EXPORTING
              P_AKTYP           = T130M-AKTYP
              MARC_IN_STAWN     = MARC-STAWN
              MARC_IN_EXPME     = MARC-EXPME
              MARA_IN_MEINS     = MARA-MEINS
              LMARC_EXPME       = LMARC-EXPME
              WMARC_WERKS       = MARC-WERKS
              OK_CODE           = RMMZU-OKCODE
              P_RM03M_REF_MATNR = RMMG1_REF-MATNR
*             FLG_UEBERNAHME    = ' '
*             FLG_PRUEFDUNKEL   = ' '
*             P_MESSAGE         = ' '
              WMARA_ATTYP       = MARA-ATTYP
              WMARA_MATNR       = MARA-MATNR
              WMARA_SATNR       = MARA-SATNR
              LMARC_IN_STAWN    = LMARC-stawn
         IMPORTING
              MARC_IN_EXPME     = MARC-EXPME
              P_RM03M_MEINH     = RMMZU-MEINH
              P_RM03M_UMREZ     = RMMZU-UMREZ
              P_RM03M_UMREN     = RMMZU-UMREN
              OK_CODE           = RMMZU-OKCODE
              HOKCODE           = RMMZU-HOKCODE
              FLAG_BILDFOLGE    = RMMZU-BILDFOLGE
         TABLES
              MEINH             = MEINH
              Z_MEINH           = RMEINH
              DMEINH            = DMEINH.
*        EXCEPTIONS
*             ERROR_NACHRICHT   = 1
*             ERROR_MEINS       = 2
*             OTHERS            = 3

  ENDIF.
* AHE: 05.02.99 - E

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.                      "Popup 510: Umrechnungsfaktoren
  ENDIF.

ENDMODULE.
