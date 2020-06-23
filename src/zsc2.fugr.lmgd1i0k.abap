*------------------------------------------------------------------
* Datenuebernahme_bme.
*
* Beim Anlegen mit Vorlage und Verändern der Basis-ME erfolgt eine
* Warnung, wenn EAN- bzw. Abpackungsdaten gefüllt sind, aber nicht
* verändert wurden gegenüber Vorlage
* Übernehmen der Daten zur Basis-ME in die Tabelle MEINH
*------------------------------------------------------------------
MODULE DATENUEBERNAHME_BME.

  CHECK BILDFLAG = SPACE.              "mk/19.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.  "mk/24.04.95

* note 1034796: do GTIN variant check before data transfer MARA<>MEINH
  CALL FUNCTION 'MARA_GTIN_VARIANT'
    EXPORTING
     MARA                     = MARA
   TABLES
     MEINH_TAB                 = MEINH
   CHANGING
     GTIN_VARIANT             = MARA-GTIN_VARIANT
   EXCEPTIONS
      GTIN_VARIANT_WRONG       = 2
      EAN_MISSING              = 3
           .
CASE SY-SUBRC.
    WHEN '3'.
       SET CURSOR FIELD 'MARA-EAN11'.
         MESSAGE E553(MM).
    when '2'.
      SET CURSOR FIELD 'MARA-GTIN_VARIANT'.
      MESSAGE E552(MM).
endcase.

  CALL FUNCTION 'DATENUEBERNAHME_BME'
       EXPORTING
            P_AKTYP     = T130M-AKTYP
            P_MATNR_REF = RMMG1_REF-MATNR
            WMARA       = MARA
            RMARA       = RMARA
            P_MESSAGE   = ' '
       TABLES
            MEINH       = MEINH.
*      EXCEPTIONS
*           WARNING_NACHRICHT

* IF SY-SUBRC NE 0.                     "cfo/1.4.97 sy-subrc ist ohne
*   SET CURSOR FIELD 'MARA-EAN11'.      "exeption immer 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO.
* ENDIF.

ENDMODULE.
