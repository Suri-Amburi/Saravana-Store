
*------------------------------------------------------------------
*  Module Mlgn-bezme
*
* Die Mengeneinheit muß angegeben sein, wenn ein Kapazitätsverbrauch
* angegeben wurde.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*------------------------------------------------------------------
MODULE MLGN-BEZME.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 01.03.99 - A (4.6a)
* Test nun auch für Varianten, falls man einen SA pflegt
* (im Rahmen der Realisierung von log. Mengeneinheiten notwendig);
* --> Aufruf FB MLGN_BEZME_RETAIL

  IF RMMG2-FLG_RETAIL IS INITIAL.
* AHE: 01.03.99 - E

    CALL FUNCTION 'MLGN_BEZME'
         EXPORTING
              MLGN_IN_BEZME     = MLGN-BEZME
              RET_BEZME         = LMLGN-BEZME
              MARA_IN_MEINS     = MARA-MEINS
              P_RM03M_REF_MATNR = RMMG1_REF-MATNR
              P_AKTYP           = T130M-AKTYP
              OK_CODE           = RMMZU-OKCODE
         IMPORTING
              FLAG_BILDFOLGE    = RMMZU-BILDFOLGE
              P_RM03M_MEINH     = RMMZU-MEINH
              P_RM03M_UMREZ     = RMMZU-UMREZ
              P_RM03M_UMREN     = RMMZU-UMREN
              OK_CODE           = RMMZU-OKCODE
              HOKCODE           = RMMZU-HOKCODE
         TABLES
              MEINH             = MEINH
              Z_MEINH           = RMEINH
              DMEINH            = DMEINH.

    IF NOT RMMZU-BILDFOLGE IS INITIAL.
      BILDFLAG = X.                    "Popup 510: Umrechnungsfaktoren
    ENDIF.

* AHE: 01.03.99 - A (4.6a)
  ELSE.

    CALL FUNCTION 'MLGN_BEZME_RETAIL'
         EXPORTING
              MLGN_IN_BEZME     = MLGN-BEZME
              RET_BEZME         = LMLGN-BEZME
              MARA_IN_MEINS     = MARA-MEINS
              WMARA_ATTYP       = MARA-ATTYP
*              WMARA_SATNR       = MARA-SATNR
              WMARA_SATNR       = MARA-MATNR           "JB/206643
              P_RM03M_REF_MATNR = RMMG1_REF-MATNR
              P_AKTYP           = T130M-AKTYP
              OK_CODE           = RMMZU-OKCODE
*             FLG_UEBERNAHME    = ' '
*             FLG_PRUEFDUNKEL   = ' '
         IMPORTING
              FLAG_BILDFOLGE    = RMMZU-BILDFOLGE
              P_RM03M_MEINH     = RMMZU-MEINH
              P_RM03M_UMREZ     = RMMZU-UMREZ
              P_RM03M_UMREN     = RMMZU-UMREN
              OK_CODE           = RMMZU-OKCODE
              HOKCODE           = RMMZU-HOKCODE
         TABLES
              MEINH             = MEINH
              Z_MEINH           = RMEINH
              DMEINH            = DMEINH.
*        EXCEPTIONS
*             ERROR_NACHRICHT   = 1
*             ERROR_MEINS       = 2
*             OTHERS            = 3

    IF NOT RMMZU-BILDFOLGE IS INITIAL.
      BILDFLAG = X.                    "Popup 510: Umrechnungsfaktoren
    ENDIF.

  ENDIF.
* AHE: 01.03.99 - E

ENDMODULE.
