*------------------------------------------------------------------
*  Module Mlgn-Lvsme
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer die Unrechnung zur Basismengeneinheit eingeben
* kann.
*------------------------------------------------------------------
MODULE MLGN-LVSME.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 28.02.99 - A (4.6a)
* Test nun auch für Varianten, falls man einen SA pflegt
* (im Rahmen der Realisierung von log. Mengeneinheiten notwendig);
* --> Aufruf FB MLGN_LVSME_RETAIL

  IF RMMG2-FLG_RETAIL IS INITIAL.
* AHE: 28.02.99 - E

    CALL FUNCTION 'MLGN_LVSME'
         EXPORTING
              MLGN_IN_LVSME     = MLGN-LVSME
              RET_LVSME         = LMLGN-LVSME
              MARA_IN_MEINS     = MARA-MEINS
              WMLGN_LGNUM       = MLGN-LGNUM  "BE/030696
              WMARA_ATTYP       = MARA-ATTYP  "BE/030696
              WMARA_SATNR       = MARA-SATNR  "BE/030696
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

* AHE: 28.02.99 - A (4.6a)
  ELSE.
    CALL FUNCTION 'MLGN_LVSME_RETAIL'
         EXPORTING
              MLGN_IN_LVSME     = MLGN-LVSME
              RET_LVSME         = LMLGN-LVSME
              MARA_IN_MEINS     = MARA-MEINS
              WMLGN_LGNUM       = MLGN-LGNUM
              WMARA_ATTYP       = MARA-ATTYP
*              WMARA_SATNR       = MARA-SATNR
              WMARA_SATNR       = MARA-MATNR           "JB/206643
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

  ENDIF.
* AHE: 28.02.99 - E

ENDMODULE.
