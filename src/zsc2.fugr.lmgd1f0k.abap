*&---------------------------------------------------------------------*
*&      Form  VRKME_GEAENDERT
*&---------------------------------------------------------------------*
*       Prüfen, ob VerkaufsME geändert wurde. Falls kein Fehler vor-   *
*       liegt, VerkaufsME nach MAW1 übernehmen.                        *
*       Achtung: Prüfung wird nur durchgeführt, wenn MAW1 gepflegt ist *
*       (Retail).                                                      *
*----------------------------------------------------------------------*
FORM VRKME_GEAENDERT.
  DATA: LV_MEINH_KEY TYPE LRMEI.

  CHECK ME_FEHLERFLG IS INITIAL AND NOT MAW1-MATNR IS INITIAL.

  IF ME_VRKME IS INITIAL.
*   BasisME wird als VerkaufsME interpretiert.
    READ TABLE MEINH WITH KEY ME_BME.
    IF SY-SUBRC = 0.
      MEINH-KZVRKME = X.
      MODIFY MEINH INDEX SY-TABIX.
    ENDIF.
  ELSEIF ME_VRKME NE MAW1-WVRKM AND ME_VRKME = MARA-MEINS.
    CLEAR ME_VRKME.
  ENDIF.

  IF ( ME_VRKME NE MAW1-WVRKM AND
       NOT ( MAW1-WVRKM IS INITIAL AND ME_VRKME = MARA-MEINS ) ).
*   VerkaufsME wurde geändert oder BasisME wurde geändert.
    IF BILDFLAG IS INITIAL.    "cfo/10.8.96 falls BasisME geändert

*  *****************************************************************************************************
*     Logistical Product Handling
*     For logistical Products (sales and procurement product) it is not allowed to change the fields
*       - Order Unit (MARA-BSTME)
*       - Issue Unit (MAW1-WAUSM)
*       - Sales Unit (MAW1-WVRKM)
*  *****************************************************************************************************
      IF MARA-LOGISTICAL_MAT_CATEGORY = IF_STRUC_ART_MULTI_LVL_CONST=>CO_LOGISTICAL_MAT_CATEGORY-PROCUREMENT OR
         MARA-LOGISTICAL_MAT_CATEGORY = IF_STRUC_ART_MULTI_LVL_CONST=>CO_LOGISTICAL_MAT_CATEGORY-SALES.
          ME_FEHLERFLG = KZMEINH.
          SAVMEINH = ME_AUSME.
          MESSAGE ID 'MU' TYPE 'S' NUMBER '115'
          WITH MARA-MATNR.

*  **************************************************************************
*       Reset the sales unit data to the original before the change happened
*  **************************************************************************
*       1. Restore the source record which was marked as sales UOM
        IF MAW1-WVRKM IS NOT INITIAL.
          LV_MEINH_KEY = MAW1-WVRKM.
        ELSE.
*         the sales Unit is the Base Unit of Measure
          LV_MEINH_KEY = MARA-MEINS.
        ENDIF.
        READ TABLE MEINH WITH KEY MEINH = LV_MEINH_KEY.
        IF SY-SUBRC = 0.
          MEINH-KZVRKME = X.
          MODIFY MEINH INDEX SY-TABIX.
        ENDIF.
*       2. Restore the (wrong) target record (clear Flag)
        IF ME_VRKME IS INITIAL.
          LV_MEINH_KEY = MARA-MEINS.
        ELSE.
          LV_MEINH_KEY = ME_VRKME.
        ENDIF.
        LOOP AT MEINH WHERE MEINH = LV_MEINH_KEY.
          CLEAR MEINH-KZVRKME.
          MODIFY MEINH.
        ENDLOOP.
*       3. Reset the UI value
        IF MAW1-WVRKM IS INITIAL.
          ME_VRKME = MARA-MEINS.
        ELSE.
          ME_VRKME = MAW1-WVRKM.
        ENDIF.

*       Finally leave the processing
        EXIT.
      ENDIF.

*    Prüfungen durchführen, wenn Bildflag nicht gesetzt.
      CALL FUNCTION 'MAW1_WVRKM'
           EXPORTING
                WMARA_MATNR      = MARA-MATNR
                WMARA_ATTYP      = MARA-ATTYP
                WMAW1_WVRKM      = ME_VRKME
                WMARA_MEINS      = MARA-MEINS
                WMARA_SATNR      = MARA-SATNR                 "BE/030696
                WRMMG1_REF_MATNR = RMMG1_REF-MATNR
*               WRMMZU           =
                LMAW1_WVRKM      = LMAW1-WVRKM
                OMAW1_WVRKM      = *MAW1-WVRKM
                AKTYP            = T130M-AKTYP
                NEUFLAG          = NEUFLAG
                OK_CODE          = RMMZU-OKCODE  "cfo/7.8.96 war space
*               FLG_UEBERNAHME   = ' '
                P_MESSAGE        = ' '
           IMPORTING
*               WMAW1_WVRKM      = ME_VRKME
*               WRMMZU           =
                FLAG_BILDFOLGE   = RMMZU-BILDFOLGE
                HOKCODE          = RMMZU-HOKCODE
                OK_CODE          = RMMZU-OKCODE
           TABLES
                MEINH            = MEINH
                Z_MEINH          = RMEINH
                DMEINH           = DMEINH
           EXCEPTIONS
                ERROR_NACHRICHT  = 1
                ERROR_MEINS      = 2
                OTHERS           = 3.
      IF SY-SUBRC NE 0.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = ME_AUSME.
        MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
*   Daten der VerkaufsME nach MAW1 übernehmen. Daten werden auch bei
*   gesetztem Bildflag übernommen, damit es beim Setzen der Markierungen
*   nicht zu Inkonsistenzen kommt.
    IF ME_FEHLERFLG IS INITIAL.
      CALL FUNCTION 'DATENUEBERNAHME_VRKME'
           EXPORTING
                WMAW1   = MAW1
                P_VRKME = ME_VRKME
           IMPORTING
                WMAW1   = MAW1
           TABLES
                PTAB    = PTAB.
*          EXCEPTIONS
*               OTHERS   = 1.
    ELSE.
*---- Verkaufs-ME nicht änderbar --------------------------------------
*---- Kennzeichen in MEINH zurücksetzen. cfo/6.9.96
      READ TABLE MEINH WITH KEY MAW1-WVRKM.
      IF SY-SUBRC = 0.
        MEINH-KZVRKME = X.
        MODIFY MEINH INDEX SY-TABIX.
      ENDIF.
* cfo/6.9.96 Loop statt read, damit bei Doppeleintrag auch wirklich
* gelöscht wird.
*     Verkaufsmengeneinheit wieder zurücksetzen. cfo/11.10.96
      IF ME_VRKME IS INITIAL.
        ME_VRKME = MARA-MEINS.
      ENDIF.
      LOOP AT MEINH WHERE MEINH = ME_VRKME.
        CLEAR MEINH-KZVRKME.
        MODIFY MEINH.
      ENDLOOP.
      ME_VRKME = MAW1-WVRKM.
    ENDIF.

*   Verkaufsmengeneinheit wieder zurücksetzen.
    IF ME_VRKME IS INITIAL.
      ME_VRKME = MARA-MEINS.
    ENDIF.

  ENDIF.                               "IF ME_VRKME ...

ENDFORM.                               " VRKME_GEAENDERT
