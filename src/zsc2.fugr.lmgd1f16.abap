*&---------------------------------------------------------------------*
*&      Form  ME_LOESCHUNG_PRUEFEN
*&---------------------------------------------------------------------*
* Der Eintrag für die Basis-ME darf nicht gelöscht werden
* Bei der Loeschung einer Alternativmengeneinheit erfolgen folgende
* Pruefungen:
* Bei Mengeneinheiten, die innerhalb der laufenden Transaktion
* angelegt wurden, erfolgt die Pruefung gegen die aktuelle
* Workarea.
* Erfolgte die Anlage ueber das Pop-Up-Bild wird nur das Kennzeichen
* 'KZALT' abgeprueft.
* Bei Tabellen, die nicht in der laufenden Workarea vorhanden sind
* ( nicht in der PTAB ) muß zusätzlich geprüft werden, ob dort die
* Alternativmengeneinheit vorkommt.
*----------------------------------------------------------------------*
FORM ME_LOESCHUNG_PRUEFEN CHANGING ANTWORT LIKE SY-DATAR.

  DATA: ANTWORT_EAN LIKE SY-DATAR,
        ANTWORT_MAMT LIKE SY-DATAR,
        ANTWORT_MALG LIKE SY-DATAR,
        ANTWORT_EINA LIKE SY-DATAR,
        HSATNR LIKE MARA-SATNR,
        HATTYP LIKE MARA-ATTYP,
        HEINA_TAB LIKE EINA OCCURS 0 WITH HEADER LINE,
        HMEINH LIKE SMEINH.

* jw/4.6A-A
* Daten der Varianten:
  DATA: WT130F LIKE T130F,
        VMARA   LIKE STANDARD TABLE OF MARA   WITH HEADER LINE,
        VMAW1   LIKE STANDARD TABLE OF MAW1   WITH HEADER LINE,
        VMEINH  LIKE STANDARD TABLE OF SMEINH WITH HEADER LINE,
        VMALG   LIKE STANDARD TABLE OF MALG   WITH HEADER LINE,
        VMLEA   LIKE STANDARD TABLE OF MLEA   WITH HEADER LINE,
        VMAMT   LIKE STANDARD TABLE OF MAMT   WITH HEADER LINE,
        vdmarm  like marm,                            "DB-Stand
        vdmeinh like standard table of smeinh with header line,
        VSMEINH LIKE SMEINH,
        VMEAN_ME_TAB LIKE STANDARD TABLE OF MEANI WITH HEADER LINE.
* Daten des Sammelmaterials retten (falls Fehler bei Varianten):
  DATA: RET_MALG LIKE STANDARD TABLE OF MALG WITH HEADER LINE,
        RET_MLEA LIKE STANDARD TABLE OF MLEA WITH HEADER LINE,
        RET_MAMT LIKE STANDARD TABLE OF MAMT WITH HEADER LINE,
        RET_MEAN_ME_TAB LIKE STANDARD TABLE OF MEANI WITH HEADER LINE.
* jw/4.6A-E
  DATA: LR_DELE_CHECK TYPE REF TO CL_LOGISTICAL_PROD_CONSISTENCY,
        LR_ERROR      TYPE REF TO CX_LOGISTICAL_PROD_CONSISTENCY,
        LS_MSG        TYPE BAL_S_MSG.


  ANTWORT = 'J'.
  ANTWORT_EAN = 'J'.
  ANTWORT_MAMT = 'J'.
  ANTWORT_MALG = 'J'.
  ANTWORT_EINA = 'J'.

* cfo/20.1.97 clear rmmzu-okcode rausgenommen, da der OKCODE erhalten
* bleiben soll (Bsp. Springen und Meldung -> Springen geht verloren).
* cfo/8.7.97 clear rmmzu-okcode bei Löschen wieder aufgenommen, da
* im Falle eines Fehlers und gleicher Positionierung der Fehler immer
* wieder kommt, wenn man ihne quittiert (beachte: zu 4.0 bleibt der
* Curser durch Änderungen in der Basis an der gleiche Stelle stehen).

*---- Die Basis-ME darf nicht gelöscht werden --------------------------
* dies muß vor der Löschprüfung bei doppeltem Eintrag erfolgen, da zur
* Basismengeneinheit auch ein zweiter Eintrag vorhanden sein kann,
* aber der erste Eintrag der BasisME (1. Eintrag auf Screen) nicht
* gelöscht werden darf (gibt sonst Probleme).
* Der zweite Eintrag darf natürlich gelöscht werden.
* IF NOT MEINH-KZBME IS INITIAL.
  IF MEINH-MEINH = MARA-MEINS AND ME_AKT_ZEILE = 1.
    CLEAR RMMZU-OKCODE.
    BILDFLAG = X.                      "cfo/5.8.96
    MESSAGE E837(M3) with mara-matnr.
  ENDIF.


******************************************************************************************************
* Logistical Product Handling
*   For procurement Products it is not allowed to delete any unit of measure from the UoM Hierarchy
*   For sales products unit of measure records that are not used in a sales product or not used
*   as order-, issue- or sales unit of measure.
******************************************************************************************************
  IF MARA-LOGISTICAL_MAT_CATEGORY = IF_STRUC_ART_MULTI_LVL_CONST=>CO_LOGISTICAL_MAT_CATEGORY-PROCUREMENT OR
     MARA-LOGISTICAL_MAT_CATEGORY = IF_STRUC_ART_MULTI_LVL_CONST=>CO_LOGISTICAL_MAT_CATEGORY-SALES.

    TRY.
      IF GR_DELE_CHECK IS NOT BOUND.
        GR_DELE_CHECK = CL_LOGISTICAL_PROD_CONSISTENCY=>GET_INSTANCE( MARA ).
      ENDIF.

      IF GR_DELE_CHECK IS BOUND.
        GR_DELE_CHECK->CHECK_DELETE(
          EXPORTING
            IS_MEINH_PROCESSED = MEINH ).    " Currently processed MEINH record
      ENDIF.
    CATCH CX_LOGISTICAL_PROD_CONSISTENCY INTO LR_ERROR.
        LR_ERROR->CONV_2_MSGLINE(
          CHANGING
            XS_MSG = LS_MSG ).
*       In case of issue, a deletion is not allowed,
*       stay in the same screen and raise a error message
        CLEAR RMMZU-OKCODE.
        BILDFLAG = X.
        MESSAGE
          ID LS_MSG-MSGID
          TYPE LS_MSG-MSGTY
          NUMBER LS_MSG-MSGNO
          WITH LS_MSG-MSGV1 LS_MSG-MSGV2 LS_MSG-MSGV3 LS_MSG-MSGV4.
    ENDTRY.
ENDIF.




* jhi/4.0 WS Abwicklung
* Löschen von ME mit Zuordnung Merkmal nur über Screen
*  - Anteils-/variable Mengeneinheiten -   erlaubt
  IF RMMZU-OKCODE NE FCODE_WSDE AND RMMZU-OKCODE NE FCODE_WSDC.
    IF NOT MEINH-ATINN IS INITIAL.
      CLEAR RMMZU-OKCODE.
      BILDFLAG = X.
      MESSAGE E114(LB) WITH MEINH-MEINH.
    ENDIF.
  ENDIF.

* Prüfen, ob Doppeleintrag und wenn ja, Meldung zur erfaßten EAN
* ausgeben. cfo/11.9.96
  IF NOT MEINH-EAN11 IS INITIAL AND
     ME_FLG_DEL = FDMEINH AND MEINH-MEINH = ME_MEINH_DEL.
*   Doppeleintrag
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*             DEFAULTOPTION = 'Y'
              DIAGNOSETEXT1 = TEXT-039
              DIAGNOSETEXT2 = TEXT-040
*             DIAGNOSETEXT3 = ' '
              TEXTLINE1     = TEXT-031
              TEXTLINE2     = TEXT-032
              TITEL         = TEXT-030
*             START_COLUMN  = 25
*             START_ROW     = 6
         IMPORTING
              ANSWER        = ANTWORT
         EXCEPTIONS
              OTHERS        = 1.
    IF SY-SUBRC = 0 AND ANTWORT = 'J'.
      READ TABLE MEAN_ME_TAB WITH KEY MEINH = MEINH-MEINH
                                      EAN11 = MEINH-EAN11
                                      BINARY SEARCH.
      IF SY-SUBRC = 0.
        DELETE MEAN_ME_TAB INDEX SY-TABIX.
      ENDIF.
      READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                                MEINH = MEINH-MEINH
*                               LIFNR = RMMW2_LIEF
                                EAN11 = MEINH-EAN11
                            BINARY SEARCH.
      IF SY-SUBRC = 0.
        DELETE TMLEA INDEX SY-TABIX.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

*- wenn ein doppelter Eintrag vorliegt, darf gelöscht werden
*- Theo, 19.03.'92; cfo/20.2.96/jetzt mit neuen Feldern prüfen
* IF ME_FEHLERFLG = FDMEINH AND MEINH-MEINH = SAVMEINH.
  IF ME_FLG_DEL = FDMEINH AND MEINH-MEINH = ME_MEINH_DEL.
    EXIT.
  ENDIF.

  IF MEINH-KZALT NE SPACE.
    CLEAR RMMZU-OKCODE.
    BILDFLAG = X.                      "cfo/5.8.96
    MESSAGE E342(M3) WITH MEINH-MEINH.
  ENDIF.

* jw/4.6A-A
  RET_MEAN_ME_TAB[] = MEAN_ME_TAB[].
  RET_MLEA[] = TMLEA[].
  RET_MAMT[] = TMAMT[].
  RET_MALG[] = TMALG[].
* jw/4.6A-E

* cfo/Zu 4.0 Löschprüfungen in FB gekapselt, da für Datenübernahme
* ebenfalls benötigt.
  HMEINH = MEINH.
  CALL FUNCTION 'UNIT_DELETION_CHECK'
       EXPORTING
            I_SMEINH       = HMEINH
            I_MARA         = MARA
            I_MAW1         = MAW1
            I_MARC         = MARC
            I_MLGN         = MLGN
            I_MVKE         = MVKE
            FLG_UEBERNAHME = FLG_UEBERNAHME
            FLG_RETAIL     = RMMG2-FLG_RETAIL
            NEUFLAG        = NEUFLAG
       IMPORTING
            E_ANTWORT      = ANTWORT
       TABLES
            I_MEINH        = MEINH
            I_DMEINH       = DMEINH
            I_LMEINH       = LMEINH
            I_MEAN_ME_TAB  = MEAN_ME_TAB
            I_MLEA         = TMLEA
            I_MAMT         = TMAMT
            I_MALG         = TMALG
            I_PTAB         = PTAB
       EXCEPTIONS
            ERROR          = 1
            OTHERS         = 2.
  IF SY-SUBRC NE 0.
    CLEAR RMMZU-OKCODE.
    BILDFLAG = X.
    MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSEIF NOT RMMG2-FLG_RETAIL IS INITIAL.
     PERFORM RMMW1_SET_VRKME(SAPLMGD2) USING ME_VRKME     "note 805246
*                                             MEINH-MEINH.
                                             HMEINH-MEINH. "note 1074211
  ENDIF.

* JW/4.6A-A: Pflege der ME jetzt auch für Varianten möglich
* Beim Löschen einer Mengeneinheit des SA muß diese Mengeneinheit
* auch für die Varianten überprüft werden (allerdings nur wenn
* diese Änderung auch durchgereicht wird - Kennzeichen in der t130f)

  CHECK ANTWORT = 'J'.

  IF NOT RMMG2-FLG_RETAIL IS INITIAL
    AND MARA-ATTYP = ATTYP_SAMM.

    CALL FUNCTION 'T130F_SINGLE_READ'
       EXPORTING
*           KZRFB       = ' '
            T130F_FNAME = F_MARM_MEINH
       IMPORTING
            WT130F      = WT130F
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2
            .
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CHECK NOT WT130F-KZCPY IS INITIAL  "marm-meinh wird
      AND ( WT130F-REFTY = REF_ALL     "durchgereicht.
         OR WT130F-REFTY = REF_SAVAR
         OR WT130F-REFTY = REF_VAR ).

    CALL FUNCTION 'LESEN_VARIANTEN_ZU_SA'
         EXPORTING
              SAMMELARTIKEL        = MARA-MATNR
*             KZRFB                = ' '
*             SPERRMODUS           = ' '
*             STD_SPERRMODUS       = ' '
*             CHECK_MAT_MPOI       = ' '
              LESEN_MAW1           = X
*             LESEN_MARC           = ' '
*             LESEN_MBEW           = ' '
*             LESEN_MVKE           = ' '
         TABLES
              VARIANTEN            = VMARA
              VARIANTEN_MAW1       = VMAW1
*             VARIANTEN_MARC       =
*             VARIANTEN_MBEW       =
*             VARIANTEN_MVKE       =
         EXCEPTIONS
              ENQUEUE_MODE_CHANGED = 1
              LOCK_ON_MATERIAL     = 2
              LOCK_SYSTEM_ERROR    = 3
              WRONG_CALL           = 4
              NOT_FOUND            = 5
              NO_MAW1_FOR_MARA     = 6
              LOCK_ON_MARC         = 7
              LOCK_ON_MBEW         = 8
              LOCK_ON_MVKE         = 9
              OTHERS               = 10
              .

    IF SY-SUBRC <> 0
      and sy-subrc <> 5.
*     keine Fehlermeldung, wenn keine Varianten gefunden wurden - dies
*     ist beim Anlegen der Fall - Varianten muessen nicht geprueft
*     werden.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT VMARA.

*     Mengeneinheiten der Variante lesen
      CALL FUNCTION 'MARM_GENERIC_READ_WITH_MATNR'
           EXPORTING
*                KZRFB      = ' '
                MATNR      = VMARA-MATNR
           TABLES
*                MARM_TAB   =
                MEINH      = VMEINH
           EXCEPTIONS
                WRONG_CALL = 1
                NOT_FOUND  = 2
                OTHERS     = 3
                .
      CHECK SY-SUBRC = 0.

*     note 1074211: read correctly with the delete uom
*      READ TABLE VMEINH WITH KEY MEINH = MEINH-MEINH INTO VSMEINH.
      READ TABLE VMEINH WITH KEY MEINH = HMEINH-MEINH INTO VSMEINH.
      CHECK SY-SUBRC = 0.

*     Datenbank-Stand
      CALL FUNCTION 'MARM_SINGLE_READ_AKT_DB'
           EXPORTING
                MATNR      = vmara-matnr
*                MEINH      = meinh-meinh
                MEINH      = hmeinh-meinh                  "note 1074211
           IMPORTING
                WMARM      = vdmarm
           EXCEPTIONS
                WRONG_CALL = 1
                OTHERS     = 2
                .
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      clear vdmeinh. refresh vdmeinh.
      move-corresponding vdmarm to vdmeinh.
      append vdmeinh.

*     EAN-, MAMT-, MALG-Daten lesen
      CALL FUNCTION 'MEAN_GENERIC_READ_WITH_MATNR'
           EXPORTING
*                KZRFB       = ' '
                MATNR       = VMARA-MATNR
           TABLES
*                MEAN_TAB    =
                MEAN_ME_TAB = VMEAN_ME_TAB
           EXCEPTIONS
                WRONG_CALL  = 1
                NOT_FOUND   = 2
                OTHERS      = 3
          .
      IF SY-SUBRC <> 0.
        CLEAR VMEAN_ME_TAB.
        REFRESH VMEAN_ME_TAB.
      ENDIF.

      CALL FUNCTION 'MALG_GENERIC_READ_WITH_MATNR'
           EXPORTING
*               KZRFB      = ' '
                MATNR      = VMARA-MATNR
          TABLES
                MALG_TAB   = VMALG
          EXCEPTIONS
                WRONG_CALL = 1
                NOT_FOUND  = 2
                OTHERS     = 3
                .
      IF SY-SUBRC <> 0.           "Kein Eintrag gefunden
        CLEAR VMALG.
        REFRESH VMALG.
      ENDIF.

      CALL FUNCTION 'MAMT_GENERIC_READ_WITH_MATNR'
           EXPORTING
*               KZRFB      = ' '
                MATNR      = VMARA-MATNR
           TABLES
                MAMT_TAB   = VMAMT
           EXCEPTIONS
                WRONG_CALL = 1
                NOT_FOUND  = 2
                OTHERS     = 3
                .
      IF SY-SUBRC <> 0.           "Kein Eintrag gefunden
        CLEAR VMAMT.
        REFRESH VMAMT.
      ENDIF.

      CALL FUNCTION 'MLEA_GENERIC_READ_WITH_MATNR'
           EXPORTING
*               KZRFB      = ' '
                MATNR      = VMARA-MATNR
           TABLES
                MLEA_TAB   = VMLEA
           EXCEPTIONS
                WRONG_CALL = 1
                NOT_FOUND  = 2
                OTHERS     = 3
                .
      IF SY-SUBRC <> 0.           "Kein Eintrag gefunden
        CLEAR VMLEA.
        REFRESH VMLEA.
      ENDIF.

*     Prüfungen durchführen
      CALL FUNCTION 'UNIT_DELETION_CHECK'
           EXPORTING
                I_SMEINH       = VSMEINH
                I_MARA         = VMARA
                I_MAW1         = VMAW1
*               I_MARC         = ' '
*               I_MLGN         = ' '
*               I_MVKE         = ' '
                FLG_UEBERNAHME = FLG_UEBERNAHME
                FLG_RETAIL     = RMMG2-FLG_RETAIL
                NEUFLAG        = NEUFLAG
                FLG_VARIANTE   = X
           IMPORTING
                E_ANTWORT      = ANTWORT
           TABLES
                I_MEINH        = VMEINH
                I_DMEINH       = VDMEINH
                I_LMEINH       = VMEINH
                I_MEAN_ME_TAB  = VMEAN_ME_TAB
                I_MLEA         = VMLEA
                I_MAMT         = VMAMT
                I_MALG         = VMALG
                I_PTAB         = PTAB
           EXCEPTIONS
                ERROR          = 1
                OTHERS         = 2
                .
      IF SY-SUBRC <> 0.
*       Daten des Sammelartikels widerherstellen
        MEAN_ME_TAB[] = RET_MEAN_ME_TAB[].
        TMLEA[] = RET_MLEA[].
        TMAMT[] = RET_MAMT[].
        TMALG[] = RET_MALG[].
        CLEAR RMMZU-OKCODE.
        BILDFLAG = X.
        MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

      ELSEIF NOT ANTWORT = 'J'.
*       Daten des Sammelartikels widerherstellen
        MEAN_ME_TAB[] = RET_MEAN_ME_TAB[].
        TMLEA[] = RET_MLEA[].
        TMAMT[] = RET_MAMT[].
        TMALG[] = RET_MALG[].
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
* jw/4.6A-E

** cfo/13.8.96 Löschen nur möglich, wenn nicht als ausgez. ME markiert
*  IF NOT MEINH-KZBSTME IS INITIAL.
**   CLEAR RMMZU-OKCODE.         "cfo/20.1.97 wird nicht benötigt
*    BILDFLAG = X.
*    MESSAGE E028(MM).
*  ENDIF.
*
** Prüfungen nur für Retail relevant. cfo/11.9.96
*  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
** cfo/13.8.96 Löschen nur möglich, wenn nicht als ausgez. ME markiert
*    IF NOT MEINH-KZAUSME IS INITIAL.
**     CLEAR RMMZU-OKCODE.        "cfo/20.1.97 wird nicht benötigt
*      BILDFLAG = X.
*      MESSAGE E029(MM).
*    ENDIF.
*    IF NOT MEINH-KZVRKME IS INITIAL.
**     CLEAR RMMZU-OKCODE.        "cfo/20.1.97 wird nicht benötigt
*      BILDFLAG = X.
*      MESSAGE E019(MM).
*    ENDIF.
** Prüfen, ob die Mengeneinheit gleich der Mengeneinheit zur statist.
** Warennummer ist. cfo/11.9.96
*    IF MAW1-WEXPM = MEINH-MEINH.
**     CLEAR RMMZU-OKCODE.         "cfo/20.1.97 wird nicht benötigt
*      BILDFLAG = X.
*      MESSAGE E026(MM).
*    ENDIF.
*  ENDIF.
*
** cfo/11.9.96 Meldungen präzisiert, wo die ME gegebenenfalls noch ver-
** wendet wird.
*
*  READ TABLE DMEINH WITH KEY MEINH-MEINH.
*  RET_SYSUBRC = SY-SUBRC.
*  LOOP AT PTAB.
*    HMARA-MATNR = MARA-MATNR.
*    CASE PTAB-TBNAM.
*      WHEN 'MARA'.
*        IF MARA-BSTME = MEINH-MEINH.
**         CLEAR RMMZU-OKCODE.          "cfo/20.1.97 wird nicht benötigt
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E028(MM).            "cfo/1.4.97 falsche Meldungsnr
*        ENDIF.
*      WHEN 'MARC'.
*        IF MARC-AUSME = MEINH-MEINH.
**         CLEAR RMMZU-OKCODE.          "cfo/20.1.97 wird nicht benötigt
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E021(MM) WITH MEINH-MEINH MARC-WERKS.
*        ENDIF.
*        IF MARC-EXPME = MEINH-MEINH.
**         CLEAR RMMZU-OKCODE.          "cfo/20.1.97 wird nicht benötigt
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E024(MM) WITH MEINH-MEINH MARC-WERKS.
*        ENDIF.
*        IF MARC-FRTME = MEINH-MEINH.                        "K11K077621
**         CLEAR RMMZU-OKCODE.                               "K11K077621
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E023(MM) WITH MEINH-MEINH MARC-WERKS.     "K11K077621
*        ENDIF.                                              "K11K077621
*        CHECK NEUFLAG = SPACE AND RET_SYSUBRC = 0.
*        PERFORM LESEN_MARC_SEQ1.       "andere Werke beachten
*      WHEN 'MLGN'.
*        IF MLGN-LVSME = MEINH-MEINH.
**         CLEAR RMMZU-OKCODE.          "cfo/20.1.97 wird nicht benötigt
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E024(MM) WITH MEINH-MEINH MLGN-LGNUM.
*        ENDIF.
*        CHECK NEUFLAG = SPACE AND RET_SYSUBRC = 0.
*        PERFORM LESEN_MLGN_SEQ1.       "andere MLGN-Sätze
*      WHEN 'MVKE'.
*        IF MVKE-VRKME = MEINH-MEINH.
**         CLEAR RMMZU-OKCODE.          "cfo/20.1.97 wird nicht benötigt
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E022(MM) WITH MEINH-MEINH MVKE-VKORG MVKE-VTWEG.
*        ENDIF.
*        IF MVKE-SCHME = MEINH-MEINH.
**         CLEAR RMMZU-OKCODE.          "cfo/20.1.97 wird nicht benötigt
*          BILDFLAG = X.                "cfo/5.8.96
*          MESSAGE E027(MM) WITH MEINH-MEINH MVKE-VKORG MVKE-VTWEG.
*        ENDIF.
*        CHECK NEUFLAG = SPACE AND RET_SYSUBRC = 0.
*        PERFORM LESEN_MVKE_SEQ1.       "andere Mvke-Sätze
*    ENDCASE.
*  ENDLOOP.
*
*  READ TABLE PTAB WITH KEY 'MARC'.
*  IF SY-SUBRC NE 0.
*    IF NEUFLAG = SPACE AND RET_SYSUBRC = 0.
*      PERFORM LESEN_MARC_SEQ2.         "alle Marc-Sätze
*    ENDIF.
*  ENDIF.
*
*  READ TABLE PTAB WITH KEY 'MLGN'.
*  IF SY-SUBRC NE 0.
*    IF NEUFLAG = SPACE AND RET_SYSUBRC = 0.
*      PERFORM LESEN_MLGN_SEQ2.         "alle MLGN-Sätze
*    ENDIF.
*  ENDIF.
*
*  READ TABLE PTAB WITH KEY 'MVKE'.
*  IF SY-SUBRC NE 0.
*    IF NEUFLAG = SPACE AND RET_SYSUBRC = 0.
*      PERFORM LESEN_MVKE_SEQ2.         "alle MVKE-Sätze
*    ENDIF.
*  ENDIF.
*
** cfo/9.9.96 Wenn eine EAN zur ME erfaßt wurde, Abfrage ob EAN mit-
** gelöscht werden soll.
*  IF NOT MEINH-EAN11 IS INITIAL.
**   kein Doppeleintrag
*    READ TABLE MEAN_ME_TAB WITH KEY MEINH-MEINH BINARY SEARCH.
*    IF SY-SUBRC = 0.
*      HTABIX = SY-TABIX + 1.
*      READ TABLE MEAN_ME_TAB INDEX HTABIX.
*      IF MEAN_ME_TAB-MEINH = MEINH-MEINH AND SY-SUBRC = 0.
**       Zur ME existieren mind. 2 EANs
**       Abfrage, ob alle EANs zur ME gelöscht werden sollen.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*             EXPORTING
**                 DEFAULTOPTION = 'Y'
*                  DIAGNOSETEXT1 = TEXT-037
*                  DIAGNOSETEXT2 = TEXT-038
**                 DIAGNOSETEXT3 = ' '
*                  TEXTLINE1     = TEXT-031
*                  TEXTLINE2     = TEXT-032
*                  TITEL         = TEXT-030
**                 START_COLUMN  = 25
**                 START_ROW     = 6
*             IMPORTING
*                  ANSWER        = ANTWORT_EAN
*             EXCEPTIONS
*                  OTHERS        = 1.
*        IF SY-SUBRC = 0 AND ( ANTWORT_EAN = 'N' OR ANTWORT_EAN = 'A' ).
*          ANTWORT = ANTWORT_EAN.
*          EXIT.
*        ENDIF.
*      ELSE.
**       Zur ME existiert nur eine EAN
**       Abfrage, ob EAN zur ME gelöscht werden soll.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*             EXPORTING
**                 DEFAULTOPTION = 'Y'
*                  DIAGNOSETEXT1 = TEXT-039
*                  DIAGNOSETEXT2 = TEXT-040
**                 DIAGNOSETEXT3 = ' '
*                  TEXTLINE1     = TEXT-031
*                  TEXTLINE2     = TEXT-032
*                  TITEL         = TEXT-030
**                 START_COLUMN  = 25
**                 START_ROW     = 6
*             IMPORTING
*                  ANSWER        = ANTWORT_EAN
*             EXCEPTIONS
*                  OTHERS        = 1.
*        IF SY-SUBRC = 0 AND ( ANTWORT_EAN = 'N' OR ANTWORT_EAN = 'A').
*          ANTWORT = ANTWORT_EAN.
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
** Prüfen, ob zur ME bereits Texte in MAMT erfaßt wurden. cfo/9.9.96
*    LOOP AT TMAMT WHERE MEINH = MEINH-MEINH.
*      EXIT.
*    ENDLOOP.
*    IF SY-SUBRC = 0.
*      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*           EXPORTING
**               DEFAULTOPTION = 'Y'
*                DIAGNOSETEXT1 = TEXT-033
*                DIAGNOSETEXT2 = TEXT-034
**               DIAGNOSETEXT3 = ' '
*                TEXTLINE1     = TEXT-031
*                TEXTLINE2     = TEXT-032
*                TITEL         = TEXT-030
**               START_COLUMN  = 25
**               START_ROW     = 6
*           IMPORTING
*                ANSWER        = ANTWORT_MAMT
*           EXCEPTIONS
*                OTHERS        = 1.
*      IF SY-SUBRC = 0 AND ( ANTWORT_MAMT = 'N' OR ANTWORT_MAMT = 'A' ).
*        ANTWORT = ANTWORT_MAMT.
*        EXIT.
*      ENDIF.
*    ENDIF.
*
** Prüfen, ob zur ME bereits Layoutgr. in MALG erfaßt wurden. cfo/9.9.96
*    LOOP AT TMALG WHERE MEINH = MEINH-MEINH.
*      EXIT.
*    ENDLOOP.
*    IF SY-SUBRC = 0.
*      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*           EXPORTING
**               DEFAULTOPTION = 'Y'
*                DIAGNOSETEXT1 = TEXT-035
*                DIAGNOSETEXT2 = TEXT-036
**               DIAGNOSETEXT3 = ' '
*                TEXTLINE1     = TEXT-031
*                TEXTLINE2     = TEXT-032
*                TITEL         = TEXT-030
**               START_COLUMN  = 25
**               START_ROW     = 6
*           IMPORTING
*                ANSWER        = ANTWORT_MALG
*           EXCEPTIONS
*                OTHERS        = 1.
*      IF SY-SUBRC = 0 AND ( ANTWORT_MALG = 'N' OR ANTWORT_MALG = 'A' ).
*        ANTWORT = ANTWORT_MALG.
*        EXIT.
*      ENDIF.
*    ENDIF.
*
** Prüfen, ob die ME in Infosätzen verwendet wird. cfo/22.10.94
*    IF NOT RMMW2_VARN IS INITIAL.
*      HSATNR = RMMW2_SATN.
*      HATTYP = '02'.     "ATTYP_VAR ist nicht definiert
*    ELSE.
*      CLEAR: HSATNR, HATTYP.
*    ENDIF.
*    CALL FUNCTION 'ME_READ_INFORECORDS_MAT_CLIENT'
*         EXPORTING
*              I_MATNR       = MARA-MATNR
*              I_SATNR       = HSATNR
*              I_ATTYP       = HATTYP
*         TABLES
*              T_EINA        = HEINA_TAB
*         EXCEPTIONS
*              NOTHING_FOUND = 1
*              OTHERS        = 2.
*    IF SY-SUBRC = 0.
*      LOOP AT HEINA_TAB WHERE MEINS = MEINH-MEINH.
*        EXIT.
*      ENDLOOP.
*      IF SY-SUBRC = 0.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*             EXPORTING
**                 DEFAULTOPTION = 'Y'
*                  DIAGNOSETEXT1 = TEXT-041
*                  DIAGNOSETEXT2 = TEXT-042
**                 DIAGNOSETEXT3 = ' '
*                  TEXTLINE1     = TEXT-031
*                  TEXTLINE2     = TEXT-032
*                  TITEL         = TEXT-030
**                 START_COLUMN  = 25
**                 START_ROW     = 6
*             IMPORTING
*                  ANSWER        = ANTWORT_EINA
*             EXCEPTIONS
*                  OTHERS        = 1.
*        IF SY-SUBRC = 0 AND
*           ( ANTWORT_EINA = 'N' OR ANTWORT_EINA = 'A' ).
*          ANTWORT = ANTWORT_EINA.
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*  IF ANTWORT_EAN = 'J' AND ANTWORT_MAMT = 'J' AND ANTWORT_MALG = 'J'
*     AND ANTWORT_EINA = 'J'.
**   Alle EANs zur ME löschen.
*    LOOP AT MEAN_ME_TAB WHERE MEINH = MEINH-MEINH.
*      DELETE MEAN_ME_TAB.
*    ENDLOOP.
*    LOOP AT TMLEA WHERE MEINH = MEINH-MEINH.
*      DELETE TMLEA.
*    ENDLOOP.
*    IF NOT RMMG2-FLG_RETAIL IS INITIAL.
**   Alle Texte zur ME löschen.
*      LOOP AT TMAMT WHERE MEINH = MEINH-MEINH.
*        DELETE TMAMT.
*      ENDLOOP.
**   Alle Layoutgruppen zur ME löschen.
*      LOOP AT TMALG WHERE MEINH = MEINH-MEINH.
*        DELETE TMALG.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.

ENDFORM.                               " ME_LOESCHUNG_PRUEFEN
