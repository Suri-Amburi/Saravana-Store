*&---------------------------------------------------------------------*
*&      Form  BSTME_GEAENDERT
*&---------------------------------------------------------------------*
*       Prüfen, ob BestellME geändert wurde. Falls kein Fehler vor-    *
*       liegt, BSTME nach MARA übernehmen.
*----------------------------------------------------------------------*
FORM BSTME_GEAENDERT.

  DATA: MEINH_OLD LIKE SMEINH,
        MEINH_NEW LIKE SMEINH,
        ME_BSTME_ALT LIKE MARM-MEINH,
        HSUBRC LIKE SY-SUBRC.
  DATA: LV_MEINH_KEY TYPE LRMEI.

  CHECK ME_FEHLERFLG IS INITIAL.

  IF ME_BSTME IS INITIAL.
*   BasisME wird als BestellME interpretiert.
    READ TABLE MEINH WITH KEY ME_BME.
    IF SY-SUBRC = 0.
      MEINH-KZBSTME = X.
      MODIFY MEINH INDEX SY-TABIX.
    ENDIF.
  ELSEIF ME_BSTME NE MARA-BSTME AND ME_BSTME = MARA-MEINS.
    CLEAR ME_BSTME.
  ENDIF.

  IF ( ME_BSTME NE MARA-BSTME AND
       NOT ( MARA-BSTME IS INITIAL AND ME_BSTME = MARA-MEINS ) ).
*   BestellME wurde geändert.
    IF BILDFLAG IS INITIAL.    "cfo/10.8.96 falls BasisME geändert
*    Prüfungen durchführen, wenn Bildflag nicht gesetzt.


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
                MARA_IN_BSTME     = ME_BSTME
                RET_BSTME         = LMARA-BSTME
                WMARA_ATTYP       = MARA-ATTYP  "BE/030696
                WMARA_SATNR       = MARA-SATNR  "BE/030696
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
                DMEINH            = DMEINH
           EXCEPTIONS
                ERROR_NACHRICHT   = 01
                ERROR_MEINS       = 02.

* AHE: 05.02.99 - A (4.6a)
  ELSE.
******************************************************************************************************
*   Logistical Product Handling
*   For logistical Products (sales and procurement product) it is not allowed to change the fields
*     - Order Unit (MARA-BSTME)
*     - Issue Unit (MAW1-WAUSM)
*     - Sales Unit (MAW1-WVRKM)
******************************************************************************************************
    IF MARA-LOGISTICAL_MAT_CATEGORY = IF_STRUC_ART_MULTI_LVL_CONST=>CO_LOGISTICAL_MAT_CATEGORY-PROCUREMENT OR
       MARA-LOGISTICAL_MAT_CATEGORY = IF_STRUC_ART_MULTI_LVL_CONST=>CO_LOGISTICAL_MAT_CATEGORY-SALES.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = ME_BSTME.
        MESSAGE ID 'MU' TYPE 'S' NUMBER '115'
        WITH MARA-MATNR.

***************************************************************************
*     Reset the order unit data to the original before the change happened
***************************************************************************
*     1. Restore the source record which was marked as order UOM
      IF MARA-BSTME IS NOT INITIAL.
        LV_MEINH_KEY = MARA-BSTME.
      ELSE.
*       the order Unit is the Base Unit of Measure
        LV_MEINH_KEY = MARA-MEINS.
      ENDIF.

      READ TABLE MEINH WITH KEY MEINH = LV_MEINH_KEY.
      IF SY-SUBRC = 0.
        MEINH-KZBSTME = X.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
*     2. Restore the (wrong) target record (clear Flag)
      IF ME_BSTME IS INITIAL.
        LV_MEINH_KEY = MARA-MEINS.
      ELSE.
        LV_MEINH_KEY = ME_BSTME.
      ENDIF.
      LOOP AT MEINH WHERE MEINH = LV_MEINH_KEY.
        CLEAR MEINH-KZBSTME.
        MODIFY MEINH.
      ENDLOOP.
*     3. Reset the UI value
      IF MARA-BSTME IS INITIAL.
        ME_BSTME = MARA-MEINS.
      ELSE.
        ME_BSTME = MARA-BSTME.
      ENDIF.

*     Finally leave the processing
      EXIT.
    ENDIF.

    CALL FUNCTION 'MARA_BSTME_RETAIL'
         EXPORTING
              P_AKTYP           = T130M-AKTYP
              P_NEUFLAG         = NEUFLAG
              P_MARA_MATNR      = MARA-MATNR
              P_MARA_SATNR      = MARA-SATNR
              P_MARA_MEINS      = MARA-MEINS
              P_MARA_BSTME      = ME_BSTME
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
         EXCEPTIONS
              ERROR_NACHRICHT   = 1
              ERROR_MEINS       = 2
              OTHER_ERROR       = 3
              OTHERS            = 4.

  ENDIF.
* AHE: 05.02.99 - E

      IF SY-SUBRC NE 0.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = ME_BSTME.
        MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSEIF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Prüfen, ob die BestellME in Infosätzen verwendet wird. cfo/22.10.94
* (nur Retail).
*       alte Bestellmengeneinheit setzen
        ME_BSTME_ALT = MARA-BSTME.
        IF ME_BSTME_ALT IS INITIAL.
          ME_BSTME_ALT = MARA-MEINS.
        ENDIF.
*       neue BestellME ev. temporär setzen
        IF ME_BSTME IS INITIAL.                           "cfo/1.2B3
          ME_BSTME = MARA-MEINS.                          "
        ENDIF.                                            "cfo/1.2B3
*       positionieren auf alte BestellME
        READ TABLE LMEINH INTO MEINH_OLD WITH KEY ME_BSTME_ALT.
        IF SY-SUBRC NE 0.
          READ TABLE MEINH INTO MEINH_OLD WITH KEY ME_BSTME_ALT.
        ENDIF.
*       positionieren auf neue BestellME
        READ TABLE MEINH INTO MEINH_NEW WITH KEY ME_BSTME.
        IF SY-SUBRC = 0 AND
           ( NOT MEINH_OLD IS INITIAL AND NOT MEINH_NEW IS INITIAL ).
          PERFORM ME_PRUEFEN_VERWENDUNG USING MEINH_OLD
                                              MEINH_NEW
                                              SPACE.      "cfo/1.2B3
        ENDIF.
        IF ME_BSTME = MARA-MEINS.                         "cfo/1.2B3
          CLEAR ME_BSTME.                                 "
        ENDIF.                                            "cfo/1.2B3
      ENDIF.
    ENDIF.
*   Daten der BestellME nach MARA übernehmen.
    IF ME_FEHLERFLG IS INITIAL.
      CALL FUNCTION 'DATENUEBERNAHME_BSTME'
           EXPORTING
                WMARA   = MARA
                P_BSTME = ME_BSTME
           IMPORTING
                WMARA   = MARA
           TABLES
                PTAB    = PTAB.
*          EXCEPTIONS
*               OTHERS   = 1.
    ELSE.
*---- Bestell-ME nicht änderbar --------------------------------------
*---- Kennzeichen in MEINH zurücksetzen. cfo/6.9.96
      READ TABLE MEINH WITH KEY MARA-BSTME.
      IF SY-SUBRC = 0.
        MEINH-KZBSTME = X.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
* cfo/6.9.96 Loop statt read, damit bei Doppeleintrag auch wirklich
* gelöscht wird.
*   Bestellmengeneinheit wieder zurücksetzen. cfo/11.10.96
      IF ME_BSTME IS INITIAL.
        ME_BSTME = MARA-MEINS.
      ENDIF.
      LOOP AT MEINH WHERE MEINH = ME_BSTME.
        CLEAR MEINH-KZBSTME.
        MODIFY MEINH.
      ENDLOOP.
      ME_BSTME = MARA-BSTME.
    ENDIF.

*   Bestellmengeneinheit wieder zurücksetzen.
    IF ME_BSTME IS INITIAL.
      ME_BSTME = MARA-MEINS.
    ENDIF.

  ENDIF.                               "IF ME_BSTME ...

ENDFORM.                               " BSTME_GEAENDERT
