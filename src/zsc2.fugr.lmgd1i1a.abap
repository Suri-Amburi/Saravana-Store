*------------------------------------------------------------------
*  Module MARA-BSTME
*
* Die eingegebene Mengeneinheit muss gueltig sein (Tabelle 006). Sie
* muss ungleich der Basismengeneinheit sein.
* Es wird geprueft, ob die Mengeneinheit fuer dieses Material bereits
* definiert ist. Ist dies nicht der Fall wird ein Bild aufgeblendet,
* auf dem der Benutzer den Unrechnungsfaktor eingeben kann.
*
* Achtung: Im Batchinput-Fall wird ein spezielles Batch-Input-Bild
* gesendet. Dieses wird auch gesendet, wenn die Alternativ-ME bereits
* bekannt ist bzw. aus Dreiecksbeziehungen die Umrechnung herleitbar
* ist. Auf diesem Bild kann nur Datenfreigabe, Sichern und einige
* Zusatzfunktionen prozessiert werden (alte okcodes gehen verloren)
*
* Bei Änderung der Bestellmengeneinheit erfolgt eine Warnung, wenn
* eine  Bestellung oder ein Lieferplan vorhanden ist.
* Dies gilt auch, wenn die Bestell-ME vorher initial war, da dann
* statt der Bestell-ME die Basis-ME verwendet wird
*
* ab 2.1B Prüfung, ob eine kaufmännische Einheit eingegeben wurde
*------------------------------------------------------------------
MODULE MARA-BSTME.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 05.02.99 - A (4.6a)
* Test nun auch für Varianten, falls man einen SA pflegt
* (im Rahmen der Realisierung von log. Mengeneinheiten notwendig);
* --> Aufruf FB MARA_BSTME_RETAIL

  IF RMMG2-FLG_RETAIL IS INITIAL.
* AHE: 05.02.99 - E

    CALL FUNCTION 'MARA_BSTME'
         EXPORTING
              P_AKTYP           = T130M-AKTYP
              P_NEUFLAG         = NEUFLAG
              MARA_IN_MATNR     = MARA-MATNR
              MARA_IN_MEINS     = MARA-MEINS
              MARA_IN_BSTME     = MARA-BSTME
*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
*aber deaktiviert, da im Baustein auch nicht mehr benötigt
*             wmara_attyp       = mara-attyp                 "BE/030696
*             wmara_satnr       = mara-satnr                 "BE/030696
              RET_BSTME         = LMARA-BSTME
              P_RM03M_REF_MATNR = RMMG1_REF-MATNR
              P_MESSAGE         = ' '
              OK_CODE           = RMMZU-OKCODE
         IMPORTING
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
*        EXCEPTIONS
*             ERROR_NACHRICHT   = 01
*             ERROR_MEINS       = 02.

* AHE: 05.02.99 - A (4.6a)
  ELSE.
    CALL FUNCTION 'MARA_BSTME_RETAIL'
         EXPORTING
              P_AKTYP           = T130M-AKTYP
              P_NEUFLAG         = NEUFLAG
              P_MARA_MATNR      = MARA-MATNR
              P_MARA_SATNR      = MARA-SATNR
              P_MARA_MEINS      = MARA-MEINS
              P_MARA_BSTME      = MARA-BSTME
              P_RET_BSTME       = LMARA-BSTME
              P_MARA_ATTYP      = MARA-ATTYP
              P_RM03M_REF_MATNR = RMMG1_REF-MATNR
              P_OK_CODE         = RMMZU-OKCODE
*             P_FLG_UEBERNAHME  = ' '
*             P_FLG_PRUEFDUNKEL = ' '
              P_MESSAGE         = ' '
         IMPORTING
              P_RM03M_MEINH     = RMMZU-MEINH
              P_RM03M_UMREZ     = RMMZU-UMREZ
              P_RM03M_UMREN     = RMMZU-UMREN
              P_FLAG_BILDFOLGE  = RMMZU-BILDFOLGE
              P_OK_CODE         = RMMZU-OKCODE
              P_HOKCODE         = RMMZU-HOKCODE
         TABLES
              MEINH             = MEINH
              Z_MEINH           = RMEINH
              DMEINH            = DMEINH
*        EXCEPTIONS
*             ERROR_NACHRICHT   = 1
*             ERROR_MEINS       = 2
*             OTHER_ERROR       = 3
*             OTHERS            = 4
              .
  ENDIF.
* AHE: 05.02.99 - E

  IF NOT RMMZU-BILDFOLGE IS INITIAL.
    BILDFLAG = X.
  ENDIF.

ENDMODULE.
