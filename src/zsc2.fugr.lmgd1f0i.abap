*&---------------------------------------------------------------------*
*&      Form  ME_PRUEFEN_VERWENDUNG
*&---------------------------------------------------------------------*
*       Prüft die Verwendung einer ME im Einauf.                       *
*----------------------------------------------------------------------*
FORM ME_PRUEFEN_VERWENDUNG USING MEINH_ALT STRUCTURE SMEINH
                                 MEINH_NEU STRUCTURE SMEINH
                                 FLG_UOMFACT_CHANGED.       "cfo/1.2B3

  DATA: HSATNR LIKE MARA-MATNR,
        HATTYP LIKE MARA-ATTYP,
        HEINA_TAB LIKE EINA OCCURS 0 WITH HEADER LINE,
        HEINA_TAB_I LIKE EINA OCCURS 0 WITH HEADER LINE,
        VARIANTEN LIKE MARA OCCURS 0 WITH HEADER LINE,      "note 544669
        ANTWORT_VAR LIKE SY-DATAR,                          "note 544669
        HEINA LIKE EINA,
        O_HEINA LIKE EINA,
        HEINE LIKE EINE,                                    "cfo/4.0B
        HMGEINE_TAB_I LIKE MGEINE OCCURS 0 WITH HEADER LINE,"cfo/4.0B
*       cfo/1.2B3-A
        O_HEINE LIKE EINE,
        HEINE_TAB LIKE EINE OCCURS 0 WITH HEADER LINE,
        CHNG_EINE_TAB LIKE EINE OCCURS 0 WITH HEADER LINE,
*       cfo/1.2B3-E
        HSUBRC LIKE SY-SUBRC,
        IPRE03 LIKE PRE03 OCCURS 0 WITH HEADER LINE,
        ANTWORT_EINA LIKE SY-DATAR,
        ANTWORT_EINE LIKE SY-DATAR,                         "cfo/1.2B3
        KZ_POPUP,
        KZ_POPUP2,                                          "cfo/1.2B3
        HUMREN LIKE MEINH-UMREN,                            "cfo/1.2B3
        HUMREZ LIKE MEINH-UMREZ.                            "cfo/1.2B3

  ANTWORT_EINA = 'N'.
  CLEAR: KZ_POPUP.
  CLEAR: HEINA_TAB. REFRESH: HEINA_TAB.
* ALRK022007 begin insert
  DATA L_MATNR LIKE EINA_MATNR OCCURS 0 WITH HEADER LINE.
  REFRESH L_MATNR.
* note 544669
  IF MARA-ATTYP = ATTYP_SAMM.
    CLEAR VARIANTEN.
    CALL FUNCTION 'LESEN_VARIANTEN_ZU_SA'
      EXPORTING
        SAMMELARTIKEL = MARA-MATNR
      TABLES
        VARIANTEN     = VARIANTEN
      EXCEPTIONS
        NOT_FOUND     = 1
        OTHERS        = 2.

    IF SY-SUBRC = 2.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.
  CLEAR IPRE03.
  L_MATNR-MATNR = MARA-MATNR.
  IPRE03-MATNR = MARA-MATNR.
  APPEND L_MATNR.
  APPEND IPRE03.
  LOOP AT VARIANTEN.
    L_MATNR-MATNR = VARIANTEN-MATNR.
    IPRE03-MATNR = VARIANTEN-MATNR.
    APPEND L_MATNR.
    APPEND IPRE03.
  ENDLOOP.

  CALL FUNCTION 'ME_EINA_READ'
    TABLES
      PTI_MATNR        = L_MATNR
      PTO_EINA         = HEINA_TAB
    EXCEPTIONS
      NO_RECORDS_FOUND = 1
      OTHERS           = 2.
* ALRK022007 end insert - begin delete
* if not rmmw2_varn is initial.
*   hsatnr = rmmw2_satn.
*   hattyp = '02'.     "ATTYP_VAR ist nicht definiert
* else.
*   clear: hsatnr, hattyp.
* endif.
* call function 'ME_READ_INFORECORDS_MAT_CLIENT'
*      exporting
*           i_matnr       = mara-matnr
*           i_satnr       = hsatnr
*           i_attyp       = hattyp
*      tables
*           t_eina        = heina_tab
*      exceptions
*           nothing_found = 1
*           others        = 2.
* ALRK022007 end delete
  IF SY-SUBRC = 0.
* cfo/1.2B3-A
*   LOOP AT HEINA_TAB INTO HEINA WHERE MEINS = MEINH_ALT-MEINH
    LOOP AT HEINA_TAB WHERE MEINS = MEINH_ALT-MEINH
* cfo/1.2B3-E
                        AND UMREZ = MEINH_ALT-UMREZ
                        AND UMREN = MEINH_ALT-UMREN
                        AND LOEKZ   = SPACE.
      KZ_POPUP = X.
      EXIT.
    ENDLOOP.
  ENDIF.

* JH/20.03.02/4.7 Anpassung wg. Hinweis 428392
* Bei der Neuanlage eines Infosatzes wird eine Dummy-INFNR
* vergeben ('$MEII00000', '$MEII00001', ...) die aber nicht
* an die FORM UPDATE_INFORECORD übergeben werden darf, sonst
* kommt die Pufferverwaltung durcheinander.
  FIELD-SYMBOLS: <FS_EINA> TYPE EINA.
  LOOP AT HEINA_TAB ASSIGNING <FS_EINA>.
    IF <FS_EINA>-INFNR CS '$MEII'.
      CLEAR <FS_EINA>-INFNR.
    ENDIF.
  ENDLOOP.

* cfo/1.2B3-A
  IF NOT HEINA_TAB[] IS INITIAL AND NOT FLG_UOMFACT_CHANGED IS INITIAL.
* Holds store groups for Purchasing
    PERFORM RETAIL_REFERENCE_SITE_SELECT TABLES HEINE_TAB
                                                HEINA_TAB.
    IF SY-SUBRC <> 0.
      SELECT * FROM EINE INTO TABLE HEINE_TAB
                         FOR ALL ENTRIES IN HEINA_TAB
                         WHERE INFNR = HEINA_TAB-INFNR.
    ENDIF.
    IF SY-SUBRC = 0.
      SORT HEINA_TAB.                                     "note 2016395
      LOOP AT HEINE_TAB WHERE BPRME = MEINH_ALT-MEINH.
        READ TABLE HEINA_TAB WITH KEY INFNR = HEINE_TAB-INFNR "#EC CI_SORTED
                                      BINARY SEARCH.
        IF SY-SUBRC = 0 AND HEINA_TAB-MEINS NE MEINH_ALT-MEINH.
          KZ_POPUP2 = X.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
* cfo/1.2B3-E

* note 544668
  CLEAR:HEINA_TAB_I, HMGEINE_TAB_I.    "cfo/1.2B3 hmgeine_tab_i
  REFRESH: HEINA_TAB_I, HMGEINE_TAB_I.  "

  CALL FUNCTION 'EINA_E_ARRAY_READ_MAT_ALL_BUFF'
       TABLES
            IPRE03     = IPRE03
            EINA_TAB   = HEINA_TAB_I
            MGEINE_TAB = HMGEINE_TAB_I                 "cfo/4.0B/1.2B3
       EXCEPTIONS                                           "cfo/4.6A
            OTHERS.                                         "cfo/4.6A
  IF SY-SUBRC = 0.
*   note 544669
    LOOP AT HEINA_TAB_I WHERE MATNR = L_MATNR-MATNR
                        AND   MEINS = MEINH_ALT-MEINH
                        AND   UMREZ = MEINH_ALT-UMREZ
                        AND   UMREN = MEINH_ALT-UMREN
                        AND   LOEKZ = SPACE.
      KZ_POPUP = X.
      EXIT.
    ENDLOOP.
*   cfo/1.2B3-A
    IF NOT FLG_UOMFACT_CHANGED IS INITIAL.
      LOOP AT HMGEINE_TAB_I WHERE BPRME = MEINH_ALT-MEINH.
*       note 544669
        READ TABLE HEINA_TAB_I WITH KEY MATNR = L_MATNR-MATNR
                                            LIFNR = HMGEINE_TAB_I-LIFNR
                                            BINARY SEARCH. "#EC CI_NOORDER
        IF SY-SUBRC = 0 AND HEINA_TAB_I-MEINS NE MEINH_ALT-MEINH.
          KZ_POPUP2 = X.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
*   cfo/1.2B3-E
  ENDIF.

  IF NOT KZ_POPUP IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*             DEFAULTOPTION = 'Y'
              DIAGNOSETEXT1 = TEXT-043
              DIAGNOSETEXT2 = TEXT-044
*             DIAGNOSETEXT3 = ' '
              TEXTLINE1     = TEXT-051
              TEXTLINE2     = TEXT-052
              TITEL         = TEXT-050
*             START_COLUMN  = 25
*             START_ROW     = 6
         IMPORTING
              ANSWER        = ANTWORT_EINA
         EXCEPTIONS
              OTHERS        = 1.
    IF ANTWORT_EINA = 'N' OR ANTWORT_EINA = 'A'.
      EXIT.
    ENDIF.

*   note 544669
*   note 616854
    IF MARA-ATTYP = ATTYP_SAMM.
      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
        EXPORTING
          DIAGNOSETEXT1  = TEXT-110
          DIAGNOSETEXT2  = TEXT-111
          DIAGNOSETEXT3  = TEXT-112
          TEXTLINE1      = TEXT-114
          TEXTLINE2      = TEXT-115
          TITEL          = TEXT-113
          CANCEL_DISPLAY = ' '
        IMPORTING
          ANSWER         = ANTWORT_VAR
        EXCEPTIONS
          OTHERS         = 1.

      IF ANTWORT_VAR = 'N' OR ANTWORT_VAR = 'A'.
*   note 616854
        REFRESH L_MATNR.
        L_MATNR-MATNR = MARA-MATNR.
        APPEND L_MATNR.
      ENDIF.
    ENDIF.

  ENDIF.

  IF ANTWORT_EINA = 'J'.

*   note 544669
    LOOP AT L_MATNR.

* Prüfen, ob die ME bereits in Infosätzen als BestellME verwendet wurde.
* Nur die BestellMEs ändern, die noch die gleiche Umrechnung haben
* (beachte: die Umrechnung kann in Infosatzpflege geändert werden)

*     note 544669
      LOOP AT HEINA_TAB INTO HEINA WHERE MEINS = MEINH_ALT-MEINH
                                   AND MATNR = L_MATNR-MATNR
                                   AND UMREZ = MEINH_ALT-UMREZ
                                   AND UMREN = MEINH_ALT-UMREN
                                   AND LOEKZ   = SPACE.

        O_HEINA = HEINA.
        HEINA-MEINS = MEINH_NEU-MEINH.
        HEINA-UMREZ = MEINH_NEU-UMREZ.
        HEINA-UMREN = MEINH_NEU-UMREN.
        CLEAR HEINE.                                        "cfo/1.2B3

        PERFORM UPDATE_INFORECORD TABLES CHNG_EINE_TAB      "cfo/1.2B3
                                  USING HEINA O_HEINA
                                        HEINE HEINE         "cfo/1.2B3
                                      CHANGING HSUBRC.

        IF HSUBRC NE 0.
          ME_FEHLERFLG = KZMEINH.
          SAVMEINH = MEINH_NEU-MEINH.
          MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          EXIT.
*     cfo/1.2B3-A
** cfo/4.0B-A Die Bestellpreismengeneinheit in EINE ist unter Umständen
** geändert worden (Popup). Auf jedenfall im Puffer nachziehen.
*      ELSE.
*        READ TABLE HEINA_TAB_I WITH KEY INFNR = HEINA-INFNR
*                               BINARY SEARCH.
*        IF SY-SUBRC = 0.
*          HEINA_TAB_I-MEINS = MEINH_NEU-MEINH.
*          HEINA_TAB_I-UMREZ = MEINH_NEU-UMREZ.
*          HEINA_TAB_I-UMREN = MEINH_NEU-UMREN.
*          MODIFY HEINA_TAB_I.
*          READ TABLE HMGEINE_TAB_I WITH KEY MATNR    = HEINA-MATNR
*                                            LIFNR    = HEINA-LIFNR
*                                            EKORG_MG = HEINE-EKORG
*                                            WERKS_MG = HEINE-WERKS
*                                   BINARY SEARCH.
*          IF SY-SUBRC = 0.
*            HMGEINE_TAB_I-BPRME = HEINE-BPRME.
*            HMGEINE_TAB_I-BPUMZ = HEINE-BPUMZ.
*            HMGEINE_TAB_I-BPUMN = HEINE-BPUMN.
*          ENDIF.
*        ENDIF.
** cfo/4.0B-E
        ELSE.

          MODIFY HEINA_TAB FROM HEINA.                  "note1290530

          LOOP AT CHNG_EINE_TAB.
            READ TABLE HMGEINE_TAB_I WITH KEY
                                     MATNR = HEINA-MATNR
                                     LIFNR = HEINA-LIFNR
                                     EKORG_MG = CHNG_EINE_TAB-EKORG
                                     WERKS_MG = CHNG_EINE_TAB-WERKS
                                     BINARY SEARCH.
            IF SY-SUBRC = 0.
              MOVE-CORRESPONDING CHNG_EINE_TAB TO HMGEINE_TAB_I.
              MODIFY HMGEINE_TAB_I INDEX SY-TABIX.
              IF HMGEINE_TAB_I-MATNR = MGEINE-MATNR AND
                 HMGEINE_TAB_I-LIFNR = MGEINE-LIFNR AND
                 HMGEINE_TAB_I-EKORG_MG = MGEINE-EKORG_MG AND
                 HMGEINE_TAB_I-WERKS_MG = MGEINE-WERKS_MG.
                MOVE-CORRESPONDING CHNG_EINE_TAB TO MGEINE.
                MOVE-CORRESPONDING CHNG_EINE_TAB TO EINE.
              ENDIF.
            ENDIF.
          ENDLOOP.
*     cfo/1.2B3-E
        ENDIF.
      ENDLOOP.
      IF ME_FEHLERFLG IS INITIAL.
        LOOP AT HEINA_TAB_I WHERE MATNR = MARA-MATNR
                            AND   MEINS = MEINH_ALT-MEINH
                            AND   UMREZ = MEINH_ALT-UMREZ
                            AND   UMREN = MEINH_ALT-UMREN
                            AND   LOEKZ = SPACE.
          O_HEINA = HEINA_TAB_I.
          HEINA_TAB_I-MEINS = MEINH_NEU-MEINH.
          HEINA_TAB_I-UMREZ = MEINH_NEU-UMREZ.
          HEINA_TAB_I-UMREN = MEINH_NEU-UMREN.
*       Prüfen, ob Infosatz bereits auf DB existiert. Wenn ja, ist er
*       bereits aktialisiert.
          READ TABLE HEINA_TAB WITH KEY MATNR = HEINA_TAB_I-MATNR
                                        LIFNR = HEINA_TAB_I-LIFNR
                                        MEINS = MEINH_NEU-MEINH
                                        UMREZ = MEINH_NEU-UMREZ
                                        UMREN = MEINH_NEU-UMREN.
          IF SY-SUBRC NE 0.
            CLEAR HEINE.                                    "cfo/1.2B3
            PERFORM UPDATE_INFORECORD TABLES CHNG_EINE_TAB
                                      USING HEINA_TAB_I O_HEINA "note1476915
                                            HEINE HEINE
                                      CHANGING HSUBRC.

            IF HSUBRC NE 0.
              ME_FEHLERFLG = KZMEINH.
              SAVMEINH = MEINH_NEU-MEINH.
              MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              EXIT.
*        cfo/1.2B3-A
** cfo/4.0B-A Die Bestellpreismengeneinheit in EINE ist unter Umständen
** geändert worden (Popup). Auf jedenfall im Puffer nachziehen.
*          ELSE.
*            READ TABLE HMGEINE_TAB_I WITH KEY MATNR    = HEINA-MATNR
*                                              LIFNR    = HEINA-LIFNR
*                                              EKORG_MG = HEINE-EKORG
*                                              WERKS_MG = HEINE-WERKS
*                                     BINARY SEARCH.
*            IF SY-SUBRC = 0.
*              HMGEINE_TAB_I-BPRME = HEINE-BPRME.
*              HMGEINE_TAB_I-BPUMZ = HEINE-BPUMZ.
*              HMGEINE_TAB_I-BPUMN = HEINE-BPUMN.
*            ENDIF.
** cfo/4.0B-E
            ELSE.
              LOOP AT CHNG_EINE_TAB.
                READ TABLE HMGEINE_TAB_I WITH KEY
                                         MATNR = HEINA_TAB_I-MATNR
                                         LIFNR = HEINA_TAB_I-LIFNR
                                         EKORG_MG = CHNG_EINE_TAB-EKORG
                                         WERKS_MG = CHNG_EINE_TAB-WERKS
                                         BINARY SEARCH.
                IF SY-SUBRC = 0.
                  MOVE-CORRESPONDING CHNG_EINE_TAB TO HMGEINE_TAB_I.
                  MODIFY HMGEINE_TAB_I INDEX SY-TABIX.
                  IF HMGEINE_TAB_I-MATNR = MGEINE-MATNR AND
                     HMGEINE_TAB_I-LIFNR = MGEINE-LIFNR AND
                     HMGEINE_TAB_I-EKORG_MG = MGEINE-EKORG_MG AND
                     HMGEINE_TAB_I-WERKS_MG = MGEINE-WERKS_MG.
                    MOVE-CORRESPONDING CHNG_EINE_TAB TO MGEINE.
                    MOVE-CORRESPONDING CHNG_EINE_TAB TO EINE.
                  ENDIF.
                ENDIF.
              ENDLOOP.
*     cfo/1.2B3-E
            ENDIF.
          ENDIF.
          MODIFY HEINA_TAB_I.
*       Aktuellen Satz versorgen, wird sonst bei set_bild
*       überschrieben.
          IF HEINA_TAB_I-LIFNR = EINA-LIFNR.
            EINA-MEINS = MEINH_NEU-MEINH.
            EINA-UMREZ = MEINH_NEU-UMREZ.
            EINA-UMREN = MEINH_NEU-UMREN.
          ENDIF.
        ENDLOOP.
        IF SY-SUBRC = 0.
          CALL FUNCTION 'EINA_E_SET_DATA_ARRAY'
            TABLES
              EINA_TAB   = HEINA_TAB_I
              MGEINE_TAB = HMGEINE_TAB_I.        "cfo/4.0B/1.2B3
        ENDIF.
      ENDIF.

    ENDLOOP.                                              "note 544669
  ENDIF.

  CLEAR KZ_POPUP2.                "cfo/4.0C funktioniert noch nicht!

* cfo/1.2B3-A
  IF NOT KZ_POPUP2 IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*             DEFAULTOPTION = 'Y'
              DIAGNOSETEXT1 = TEXT-043
              DIAGNOSETEXT2 = TEXT-045
*             DIAGNOSETEXT3 = ' '
              TEXTLINE1     = TEXT-051
              TEXTLINE2     = TEXT-052
              TITEL         = TEXT-053
*             START_COLUMN  = 25
*             START_ROW     = 6
         IMPORTING
              ANSWER        = ANTWORT_EINE
         EXCEPTIONS
              OTHERS        = 1.
    IF ANTWORT_EINE = 'N' OR ANTWORT_EINE = 'A'.
      EXIT.
    ENDIF.
  ENDIF.

  IF ANTWORT_EINE = 'J'.
* Prüfen, ob die ME bereits in Infosätzen als BestellpreisME verwendet
* wurde. Nur die BestellpreisMEs ändern, die noch die gleiche Umrechnung
* haben. (beachte: die Umrechnung kann in Infosatzpflege geändert
* werden).
    SORT HEINA_TAB.                                       "note 2016395
    LOOP AT HEINE_TAB INTO HEINE WHERE BPRME = MEINH_ALT-MEINH
                                 AND LOEKZ   = SPACE.
      READ TABLE HEINA_TAB INTO HEINA "#EC CI_SORTED
                           WITH KEY INFNR = HEINE_TAB-INFNR
                                    BINARY SEARCH.
      CHECK SY-SUBRC = 0 AND HEINA-MEINS NE MEINH_ALT-MEINH.
      O_HEINE = HEINE.
      HUMREZ = HEINA-UMREZ / MEINH_ALT-UMREZ.
      HUMREN = HEINA-UMREN / MEINH_ALT-UMREN.
      CHECK HEINE-BPUMZ = HUMREZ AND HEINE-BPUMN = HUMREN.
      HEINE-BPUMZ = HEINA-UMREZ / MEINH_NEU-UMREZ.
      HEINE-BPUMN = HEINA-UMREN / MEINH_NEU-UMREN.
      PERFORM UPDATE_INFORECORD TABLES CHNG_EINE_TAB
                                USING HEINA HEINA
                                      HEINE O_HEINE
                                CHANGING HSUBRC.
      IF HSUBRC NE 0.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = MEINH_NEU-MEINH.
        MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF ME_FEHLERFLG IS INITIAL.
      LOOP AT HMGEINE_TAB_I WHERE MATNR = MARA-MATNR
                            AND   BPRME = MEINH_ALT-MEINH
                            AND   LOEKZ = SPACE.
        READ TABLE HEINA_TAB_I INTO HEINA
                               WITH KEY MATNR = MARA-MATNR
                                        LIFNR = HMGEINE_TAB_I-LIFNR
                                        BINARY SEARCH.
        CHECK SY-SUBRC = 0 AND HEINA-MEINS NE MEINH_ALT-MEINH.
        HUMREZ = HEINA-UMREZ / MEINH_ALT-UMREZ.
        HUMREN = HEINA-UMREN / MEINH_ALT-UMREN.
        CHECK HMGEINE_TAB_I-BPUMZ = HUMREZ AND
              HMGEINE_TAB_I-BPUMN = HUMREN.
        MOVE-CORRESPONDING HMGEINE_TAB_I TO O_HEINE.
        HMGEINE_TAB_I-BPUMZ = HEINA-UMREZ / MEINH_NEU-UMREZ.
        HMGEINE_TAB_I-BPUMN = HEINA-UMREN / MEINH_NEU-UMREN.
*       Prüfen, ob Infosatz bereits auf DB existiert. Wenn ja, ist er
*       bereits aktialisiert.
        IF NOT HEINA-INFNR IS INITIAL.
          READ TABLE HEINE_TAB WITH KEY INFNR = HEINA-INFNR.
        ELSE.
          SY-SUBRC = 4.
        ENDIF.
        IF SY-SUBRC NE 0.
          CLEAR: HEINE, O_HEINE.
          MOVE-CORRESPONDING HMGEINE_TAB_I TO HEINE.
          PERFORM UPDATE_INFORECORD TABLES CHNG_EINE_TAB
                                    USING HEINA HEINA
                                          HEINE O_HEINE
                                    CHANGING HSUBRC.
          IF HSUBRC NE 0.
            ME_FEHLERFLG = KZMEINH.
            SAVMEINH = MEINH_NEU-MEINH.
            MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            EXIT.
          ENDIF.
        ENDIF.
        MODIFY HMGEINE_TAB_I.
*       Aktuellen Satz versorgen, wird sonst bei set_bild
*       überschrieben.
        IF HMGEINE_TAB_I-MATNR = MGEINE-MATNR AND
           HMGEINE_TAB_I-LIFNR = MGEINE-LIFNR AND
           HMGEINE_TAB_I-EKORG_MG = MGEINE-EKORG_MG AND
           HMGEINE_TAB_I-WERKS_MG = MGEINE-WERKS_MG.
          MOVE-CORRESPONDING HMGEINE_TAB_I TO MGEINE.
          MOVE-CORRESPONDING HMGEINE_TAB_I TO EINE.
        ENDIF.
      ENDLOOP.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'EINA_E_SET_DATA_ARRAY'
          TABLES
            EINA_TAB   = HEINA_TAB_I
            MGEINE_TAB = HMGEINE_TAB_I.
      ENDIF.
    ENDIF.
  ENDIF.
* cfo/1.2B3-E

ENDFORM.                    " ME_PRUEFEN_VERWENDUNG
