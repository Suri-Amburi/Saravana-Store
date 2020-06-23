*&---------------------------------------------------------------------*
*&      Form  BME_GEAENDERT
*&---------------------------------------------------------------------*
*       Pruefen, ob BasisME geändert wurde. Falls kein Fehler auftrat, *
*       Daten der BasisME nach MARA übernehmen. Achtung: Daten werden  *
*       auch übernommen, wenn BME nicht geändert wurde (EAN, Abmess).  *
*----------------------------------------------------------------------*
FORM BME_GEAENDERT.

  DATA: HMEINH LIKE MARM-MEINH.        "Hilfsfeld

  CHECK ME_FEHLERFLG IS INITIAL.

  IF ME_BME IS INITIAL.
*   BasisME nicht angegeben.
*   Zum Positionieren auf erste Mengeneinheit.
    READ TABLE MEINH INDEX 1.
    IF SY-SUBRC = 0. HMEINH = MEINH-MEINH. ENDIF.
    ME_FEHLERFLG = KZMEINH.
    SAVMEINH = HMEINH.
    MESSAGE S728(M3).
  ENDIF.

  IF ME_BME NE MARA-MEINS.
*   BasisME wurde geändert.
*   Prüfung Änderung BasisME durchführen. Vorher MARA-Daten temporär
*   belegen.
    READ TABLE MEINH WITH KEY ME_BME.
    IF SY-SUBRC = 0.
      HMEINH = MARA-MEINS.             "cfo/6.9.96 retten mara-meins
      HMARA = MARA.
      HMARA-MEINS = MEINH-MEINH.
*     HMARA-EAN11 = MEINH-EAN11.       "cfo/11.6.97 es soll mit der
*     HMARA-NUMTP = MEINH-NUMTP.       "alten EAN geprüft werden
* cfo/4.0C-A Für Retail speziellen Prüfbausten verwenden.
      IF RMMG2-FLG_RETAIL IS INITIAL.
        CALL FUNCTION 'MARA_MEINS'
             EXPORTING
                  WMARA            = HMARA
                  WMARC            = MARC
*                 ret_meins        = lmara-meins        "TF 4.5B H126371
                  AKTYP            = T130M-AKTYP
                  NEUFLAG          = NEUFLAG
                  MATNR            = RMMG1-MATNR
                  ZMARA            = *MARA
                  FLG_UEBERNAHME   = ' '
                  KZ_MEINS_DIMLESS = RMMG2-MEINS_DIML
                  P_MESSAGE        = ' '
                  RMMG2_KZMPN      = RMMG2-KZMPN     "mk/4.0A
             IMPORTING
                  FLAG1            = FLAG1
                  FLAG2            = FLAG2
                  WMARA            = MARA
             TABLES
                  MEINH            = MEINH
             CHANGING                  "TF 4.5B H126371
                  RET_MEINS        = LMARA-MEINS        "TF 4.5B H126371
             EXCEPTIONS
                  ERROR_MEINH      = 01
                  ERROR_MPN        = 01
                  ERROR_NACHRICHT  = 02
                  ERROR_MATNR      = 03.
      ELSE.
        CALL FUNCTION 'MARA_MEINS_RETAIL'
             EXPORTING
                  WMARA            = HMARA
*                 ret_meins        = lmara-meins        "TF 4.5B H126371
                  AKTYP            = T130M-AKTYP
                  NEUFLAG          = NEUFLAG
                  MATNR            = RMMG1-MATNR
                  ZMARA            = *MARA
                  KZ_MEINS_DIMLESS = RMMG2-MEINS_DIML
                  P_MESSAGE        = ' '
                  FLG_UEBERNAHME   = ' '
                  RMMG2_KZMPN      = RMMG2-KZMPN
                  SPERRMODUS       = SPERRMODUS
             IMPORTING
                  FLAG1            = FLAG1
                  FLAG2            = FLAG2
                  WMARA            = MARA
             TABLES
                  MEINH            = MEINH
             CHANGING                  "TF 4.5B H126371
                  RET_MEINS        = LMARA-MEINS        "TF 4.5B H126371
             EXCEPTIONS
                  ERROR_MEINH      = 1
                  ERROR_NACHRICHT  = 2
                  ERROR_MATNR      = 3
                  OTHERS           = 4.
      ENDIF.
* cfo/4.0C-E
      IF SY-SUBRC NE 0.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = ME_BME.
        MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF NOT FLAG1 IS INITIAL AND FLAG2 IS INITIAL.
*----Basis-ME änderbar - aber abhängige Objekte sind zu prüfen ---
*       AUFRUF WARNUNGSBILD 551
        RMMZU-HOKCODE   = OK-CODE.
        RMMZU-OKCODE    = FCODE_BMEW.
        RMMZU-BILDFOLGE = X.
        BILDFLAG        = X.
      ENDIF.

      IF NOT FLAG2 IS INITIAL.
*---- Basis-ME nicht änderbar --------------------------------------
*---- Kennzeichen in MEINH zurücksetzen.
        MARA-MEINS = HMEINH.     "cfo/6.9.96 zurücksetzen mara-meins
        READ TABLE MEINH WITH KEY MARA-MEINS.
        IF SY-SUBRC = 0.
          MEINH-KZBME = X.
          MODIFY MEINH INDEX SY-TABIX.
        ENDIF.
* cfo/6.9.96 Loop statt read, damit bei Doppeleintrag auch wirklich
* gelöscht wird.
        LOOP AT MEINH WHERE MEINH = ME_BME.
          CLEAR MEINH-KZBME.
          MODIFY MEINH.                " INDEX SY-TABIX.
        ENDLOOP.
        ME_BME = MARA-MEINS.
        RMMZU-ERR_BME = X.
        RMMZU-FLG_FLISTE = X.
        CALL FUNCTION 'DEQUEUE_EMMATAE'
             EXPORTING
                  MATNR = RMMG1-MATNR.
* JH/20.03.98/4.0C Neues Sperrobj. für die Basismengeneinheit (Anfang)
        CALL FUNCTION 'DEQUEUE_EMMARME'
             EXPORTING
                  MATNR = RMMG1-MATNR. "generisch alle ME
        IF LMARA-ATTYP = ATTYP_SAMM.
          PERFORM DEQUEUE_VARIANTS USING RMMG1-MATNR.
        ENDIF.
* JH/20.03.98/4.0C Neues Sperrobj. für die Basismengeneinheit (Ende)
        MESSAGE S189(M3).              "Änderung GUI-Status
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = ME_BME.
      ENDIF.

      IF FLAG1 IS INITIAL AND FLAG2 IS INITIAL AND ME_BME NE MARA-MEINS.
*---- Basis-ME nicht änderbar --------------------------------------
*---- Kennzeichen in MEINH zurücksetzen, kein Error, da Warnung bereits
*---- ausgegeben wurde.
        MARA-MEINS = HMEINH.     "cfo/6.9.96 zurücksetzen mara-meins
        READ TABLE MEINH WITH KEY MARA-MEINS.
        IF SY-SUBRC = 0.
          MEINH-KZBME = X.
          MODIFY MEINH INDEX SY-TABIX.
        ENDIF.
* cfo/6.9.96 Loop statt read, damit bei Doppeleintrag auch wirklich
* gelöscht wird.
        LOOP AT MEINH WHERE MEINH = ME_BME.
          CLEAR MEINH-KZBME.
          MODIFY MEINH.                " INDEX SY-TABIX.
        ENDLOOP.
        ME_BME = MARA-MEINS.
      ENDIF.
    ENDIF.
  ENDIF.                               "IF ME_BME ...

  IF ME_FEHLERFLG IS INITIAL.
* Daten der BasisME nach MARA übernehmen, falls kein Fehlerfall.
    READ TABLE MEINH WITH KEY ME_BME.
    IF SY-SUBRC = 0.

* JW/23.7.99/4.6B-Anfang
* Beim Wechseln der Basismengeneinheit im Grunddatenbild wird
* das Feld MARA-GEWEI nicht neu vorgeschlagen.
* nur im RETAIL!
* siehe Km:349479/1999
      IF meinh-gewei is initial and not RMMG2-FLG_RETAIL IS INITIAL.
        tables: t006d.
        data: ttabix like sy-tabix.
        ttabix = sy-tabix.
*       Lesen Warengruppe (T023)
        IF NOT RMMW2-MATKL IS INITIAL AND T023-MATKL NE RMMW2-MATKL.
           CALL FUNCTION 'T023_SINGLE_READ'
             EXPORTING
                KZRFB      = space
                T023_MATKL = RMMW2-MATKL
             IMPORTING
                WT023      = T023
             EXCEPTIONS
                NOT_FOUND  = 1
                OTHERS     = 2.
           IF SY-SUBRC NE 0. CLEAR T023. ENDIF.
        ENDIF.

        IF T023-GEWEI NE SPACE.
          meinh-GEWEI = T023-GEWEI.
        ELSE.
          CLEAR T006D.
          CALL FUNCTION 'DIMENSION_GET'
               EXPORTING
                    MASS                = 1
               IMPORTING
                    DIMID               = T006D-DIMID
               EXCEPTIONS
                    DIMENSION_NOT_FOUND = 1
                    OTHERS              = 2.
          IF SY-SUBRC = 0.
            SELECT SINGLE * FROM T006D WHERE DIMID = T006D-DIMID.
          ENDIF.
          IF T006D-MSSIE NE SPACE.
            meinh-GEWEI = T006D-MSSIE.
          ELSE.
            meinh-GEWEI = 'KG'.
          ENDIF.
        ENDIF.
        modify meinh index ttabix.
      ENDIF.
*  JW/23.7.99/4.6B-Ende

      MOVE MEINH TO SMEINH.
      CALL FUNCTION 'DATENUEBERNAHME_EAN'
           EXPORTING
                WMARA      = MARA
                P_SMEINH   = SMEINH
                FLG_RETAIL = RMMG2-FLG_RETAIL  "mk/13.08.96
           IMPORTING
                WMARA      = MARA
           TABLES
                PTAB       = PTAB
                PTAB_FULL  = PTAB_FULL."mk/13.08.96
*            EXCEPTIONS
*                 OTHERS   = 1.
    ENDIF.
  ENDIF.

ENDFORM.                               " BME_GEAENDERT
