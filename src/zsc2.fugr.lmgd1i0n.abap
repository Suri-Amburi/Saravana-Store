*-----------------------------------------------------------------------
*
* Prüfung des allgemeinen Standardprodukts
*-----------------------------------------------------------------------
MODULE MARA-SATNR.
  DATA: KZ_SMESS LIKE SY-DATAR.
  DATA: lv_VARIANTENABLED TYPE boolean.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* check if product has already variants that are used in a FIORI Matrix
  IF mara-satnr is not INITIAL
    and lmara-satnr ne mara-satnr.
    CALL FUNCTION 'VARIANT_MATRIX_ENABLED'
      EXPORTING
        IV_PRODUCT              =  MARA-SATNR
      IMPORTING
        EV_MATRIX_ENABLED       =  LV_VARIANTENABLED
          .

    IF LV_VARIANTENABLED = abap_true.
      MESSAGE E744(CI_DRAFTPRD_MESSAGE) with MARA-SATNR.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'MARA_SATNR'
       EXPORTING
            MARA_MATNR     = MARA-MATNR
            MARA_SATNR     = MARA-SATNR
            RET_SATNR      = LMARA-SATNR
            MARA_MEINS     = MARA-MEINS
            MARA_KZKFG     = MARA-KZKFG
            P_MESSAGE      = ' '
       IMPORTING
            KZ_SMESS       = KZ_SMESS
       CHANGING
            NEW_INSTANCE_A = RMMG2-NEW_INST_A
            MARA_CUOBF     = MARA-CUOBF.
*mk/3.1G fcode ist konfigurierbar - Abfrage auf zugehörige okcode-Rout.
* IF NOT KZ_SMESS  IS INITIAL   AND
*    RMMZU-OKCODE NE FCODE_KONA.
*   MESSAGE S494.                      "Bitte Bewertung durchführen
*   RMMZU-OKCODE = FCODE_KONA.
*   CLEAR KZ_SMESS .
* ENDIF.


  IF NOT KZ_SMESS  IS INITIAL.
    CALL FUNCTION 'T133D_ARRAY_READ'
         EXPORTING
              BILDSEQUENZ = BILDSEQUENZ
         TABLES
              TT133D      = TT133D
         EXCEPTIONS
              WRONG_CALL  = 01.
    CLEAR: FLAG1, HFCODE.
    LOOP AT TT133D WHERE ROUTN = FORM_KONA.
      HFCODE = TT133D-FCODE.
      IF RMMZU-OKCODE EQ TT133D-FCODE.
        FLAG1 = X.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF FLAG1 IS INITIAL.
      MESSAGE S494.                    "Bitte Bewertung durchführen
      RMMZU-OKCODE = HFCODE.
      CLEAR KZ_SMESS .
    ENDIF.
  ENDIF.

* IF  RMMG2-NEW_INST IS INITIAL AND           "ch/4.5B
  IF  RMMG2-NEW_INST_A IS INITIAL AND         "ch/4.5B
      MARA-CUOBF IS INITIAL.           " ch 25.01.96  (AHE)
    CLEAR RMMZU-XLTYF.
  ENDIF.

* Wenn Konfiguration für lagerhaltige Typen (OK-CODE = KONA)
* dann muß das Standardprodukt angegeben sein.
  CLEAR RMMZU-CURS_FELD.
* IF RMMZU-OKCODE = FCODE_KONA.
*   IF MARA-SATNR IS INITIAL.
*     RMMZU-CURS_FELD = MARA_SATNR.    " Cursor positionieren
*     MESSAGE S495.
*     BILDFLAG = X.
*     CLEAR RMMZU-OKCODE.
*   ENDIF.
*mk/3.1G fcode ist konfigurierbar - Abfrage auf zugehörige okcode-Rout.
  IF MARA-SATNR  IS INITIAL AND NOT RMMZU-OKCODE IS INITIAL.
    CALL FUNCTION 'T133D_ARRAY_READ'
         EXPORTING
              BILDSEQUENZ = BILDSEQUENZ
         TABLES
              TT133D      = TT133D
         EXCEPTIONS
              WRONG_CALL  = 01.
    CLEAR FLAG1.
    LOOP AT TT133D WHERE ROUTN = FORM_KONA.
      IF RMMZU-OKCODE EQ TT133D-FCODE.
        FLAG1 = X.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF NOT FLAG1 IS INITIAL.
      RMMZU-CURS_FELD = MARA_SATNR.    " Cursor positionieren
      MESSAGE S495.
      BILDFLAG = X.
      CLEAR RMMZU-OKCODE.
    ENDIF.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MARA-GDS_RELEVANT  INPUT
*&---------------------------------------------------------------------*
*  TF ERP 2005 GDS
*----------------------------------------------------------------------*
MODULE mara-gds_relevant INPUT.

  CALL FUNCTION 'GDS_CHECK_GDS_RELEVANT'
    EXPORTING
      is_mara        = mara
    TABLES
      it_mean_me_tab = mean_me_tab
      it_meinh       = meinh
    EXCEPTIONS
      warning        = 1
      error          = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDMODULE.                 " MARA-GDS_RELEVANT  INPUT
