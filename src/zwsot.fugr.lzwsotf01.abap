*----------------------------------------------------------------------*
*   INCLUDE LWSOTF01                                                   *
*----------------------------------------------------------------------*

************************************************************************
*
* Lesen KNA1
*
************************************************************************

FORM KNA1_READ USING LOCATION
                     KNA1     STRUCTURE KNA1.

  PERFORM KNA1_READ(SAPLWSOC) USING LOCATION KNA1.

ENDFORM.

************************************************************************
*
* Lesen Sortimentsdaten (ggf. incl. Werksdaten (falls vorhanden))
* (der Name der Routine ist beibehalten, da viele diese bereits benutzen
*
************************************************************************

FORM KNA1_WRF1_READ USING LOCATION LIKE WRS1-ASORT
                          SORTR    STRUCTURE WINT_CARRH.
  DATA : SUBRC LIKE SY-SUBRC.
* Konvertierung
  IF LOCATION CO ' 0123456789'.
    N_LOCNR = LOCATION.
    LOCATION = N_LOCNR.
  ENDIF.

  CLEAR : SORTR, SUBRC.
  CALL FUNCTION 'ASSORTMENT_GET_DATA_AND_USER_B'
         EXPORTING
              ASORT         = LOCATION
*             VALID_AT      = ' '
*             STATUS        = '1'
         IMPORTING
              ASORT_DATA    = WRSC
         EXCEPTIONS
              NO_DATA       = 1
              NO_VALID_DATA = 2
              OTHERS        = 3.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING WRSC TO SORTR.
    SUBRC = SY-SUBRC.
  ELSE.
    SY-SUBRC = SUBRC.
  ENDIF.
ENDFORM.

************************************************************************
*
* Lesen T001W allgemein
*
************************************************************************

FORM T001W_READ USING LOCAT_IN
                     T001W    STRUCTURE T001W.
*  COR 0004  14.04.97  PETERW
*                             complete change of FORM T001W_READ       *

  DATA : SOTR_DATA LIKE WINT_CARRH.
  DATA : INPUT_DATA LIKE T001W.
  DATA : LOC LIKE WRF1-LOCNR,
         WERKS LIKE T001W-WERKS,
         Z6 LIKE SY-TABIX.
  DATA : LOCATION LIKE KNA1-KUNNR.

* wenn Werksnummer leer ist -> abweisen *********************
  IF LOCAT_IN = SPACE.
    SY-SUBRC = 1.
    CLEAR T001W.
    EXIT.                              "from form
  ENDIF.

* Ausgangsdaten bereitstellen *******************************

  LOCATION = LOCAT_IN.

  CLEAR LOC.
  LOC = LOCATION.
  CLEAR Z6.
  ASSIGN LOC+0(1) TO <F1>.
  DO 10 TIMES.
    IF <F1> = ' '.
                                       "Leerzeichen erreicht
      EXIT.                            "from DO
    ELSE.
      Z6 = Z6 + 1.
    ENDIF.
    ASSIGN <F1>+1 TO <F1>.
  ENDDO.

* Fall 1 : Anzahl Stellen <= 4 : Werk oder sonstiger SoTr

  IF Z6 <= 4.
    WERKS = LOCATION.
    CALL FUNCTION 'LOCATION_SELECT_PLANT'
         EXPORTING
              I_WERKS         = WERKS
         IMPORTING
              O_T001W         = T001W
         EXCEPTIONS
              NO_VALID_PLANT  = 01
              PLANT_NOT_FOUND = 02.
    IF SY-SUBRC = 0.                   "es ist ein Werk
      EXIT.                            "from form
    ELSE.
      "es kann auch ein sonstiger SoTr sein

      CALL FUNCTION 'ASSORTMENT_GET_DATA_AND_USER_B'
           EXPORTING
                ASORT         = LOCATION
*               VALID_AT      = ' '
*               STATUS        = '1'
           IMPORTING
                ASORT_DATA    = SOTR_DATA
           EXCEPTIONS
                NO_DATA       = 1
                NO_VALID_DATA = 2
                OTHERS        = 3.

      IF SY-SUBRC <> 0.
        MESSAGE E035 WITH LOCATION.    "not found
      ELSE.
        IF SOTR_DATA-WERKS IS INITIAL
        AND SOTR_DATA-VLFKZ <> C_TYP_CARRIER.
          MESSAGE E066 WITH LOCATION T001W-KUNNR.  "inconsistent
        ELSE.
          MOVE-CORRESPONDING SOTR_DATA TO KNA1.
                                       "füllen T001W
          PERFORM KUNDE_ZU_T001W USING KNA1 T001W.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Fall 2 : Anzahl Stellen > 4 : es muß SoTr sein

  IF Z6 > 4.
    "es kann kein Werk sein, es muß ein (sonstiger) SoTr sein !
    CALL FUNCTION 'ASSORTMENT_GET_DATA_AND_USER_B'
         EXPORTING
              ASORT         = LOC
*               VALID_AT      = ' '
*               STATUS        = '1'
         IMPORTING
              ASORT_DATA    = SOTR_DATA
         EXCEPTIONS
              NO_DATA       = 1
              NO_VALID_DATA = 2
              OTHERS        = 3.
    IF SY-SUBRC <> 0.
      MESSAGE E035 WITH LOCATION.      "not found
    ELSE.
      IF SOTR_DATA-WERKS IS INITIAL
      AND SOTR_DATA-VLFKZ <> C_TYP_CARRIER.
        MESSAGE E066 WITH LOCATION SOTR_DATA-KUNNR.  "inconsistent
      ELSE.
                                       "füllen T001W
        MOVE-CORRESPONDING SOTR_DATA TO KNA1.
        PERFORM KUNDE_ZU_T001W USING KNA1 T001W.
        CLEAR SY-SUBRC.
        EXIT.                          "from form
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM KUNDE_ZU_T001W                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  KNA1                                                          *
*  -->  T001W                                                         *
*---------------------------------------------------------------------*
FORM KUNDE_ZU_T001W USING KNA1  STRUCTURE KNA1
                          T001W STRUCTURE T001W.
  CLEAR T001W.
  T001W-WERKS = '####'.
  T001W-NAME1 = KNA1-NAME1.
  T001W-NAME2 = KNA1-NAME2.
  T001W-KUNNR = KNA1-KUNNR.
  T001W-VLFKZ = 'C'.                   "Customer
                                       "alle anderen Felder bleiben frei

* offen : Benutzung des Listungskunden aus dem Stammsatz KNA1 / WRF1
  T001W-KUNNR = KNA1-KUNNR.
* ?????

ENDFORM.



* Gruppe : Lesen von WRFx-Daten ***************************************



************************************************************************
*
* Lesen WRF3 je Warengruppe
*----------------------------------------------------------------------*
************************************************************************
FORM WRF3_READ_MATKL TABLES I_WRF3  STRUCTURE WRF3
                     USING  LOCATION MATKL.

  DATA: H_TABIX LIKE SY-TABIX.
  DATA: H_TABIX_NOT_FOUND LIKE SY-TABIX.
  DATA: P_SUBRC LIKE SY-SUBRC.         " INSERT 4.6A

  REFRESH I_WRF3.

* Konvertierung
  IF LOCATION CO ' 0123456789'.
    N_LOCNR = LOCATION.
    LOCATION = N_LOCNR.
  ENDIF.

* neues Coding zu 4.6A
  READ TABLE LOCAL_NO_WRF3 WITH KEY LOCNR = LOCATION
                                    MATKL = MATKL
       BINARY SEARCH.
  IF SY-SUBRC = 0.
    SY-SUBRC = 4.                      " es existiert kein wrf3 Eintrag
  ELSE.
    H_TABIX_NOT_FOUND = SY-TABIX.
    READ TABLE LOCAL_WRF3 WITH KEY LOCNR = LOCATION
                                   MATKL = MATKL
         BINARY SEARCH.
    IF SY-SUBRC = 0.
      LOOP AT LOCAL_WRF3 FROM SY-TABIX.
        IF LOCAL_WRF3-LOCNR <> LOCATION
        OR LOCAL_WRF3-MATKL <> MATKL.
          EXIT.
        ELSE.
          MOVE-CORRESPONDING LOCAL_WRF3 TO I_WRF3.
          APPEND I_WRF3.
        ENDIF.
      ENDLOOP.
    ELSE.
      H_TABIX = SY-TABIX.
      SELECT * FROM WRF3 INTO TABLE I_WRF3
          WHERE LOCNR = LOCATION
            AND MATKL = MATKL.
      IF SY-SUBRC = 0.
        LOOP AT I_WRF3.
          MOVE-CORRESPONDING I_WRF3 TO LOCAL_WRF3.
          INSERT LOCAL_WRF3 INDEX H_TABIX.
          ADD 1 TO H_TABIX.
        ENDLOOP.
      ELSE.
*        LOCAL_NO_WRF3-LOCNR = LOCATION.                   " COLLETT 4.7
*        LOCAL_NO_WRF3-MATKL = MATKL.                      " COLLETT 4.7
*        INSERT LOCAL_NO_WRF3 INDEX H_TABIX_NOT_FOUND.     " COLLETT 4.7
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.

form fill_no_wrf3 using p_location type locnr
                        p_matkl type matkl.

  READ TABLE LOCAL_NO_WRF3 WITH KEY LOCNR = p_LOCATION
                                    MATKL = p_MATKL
       BINARY SEARCH.
  if sy-subrc <> 0.
    LOCAL_NO_WRF3-LOCNR = p_LOCATION.
    LOCAL_NO_WRF3-MATKL = p_MATKL.
    INSERT LOCAL_NO_WRF3 INDEX sy-tabix.
  endif.
endform.

*FORM WRF3_READ_MATKL TABLES I_WRF3  STRUCTURE WRF3
*                     USING  LOCATION MATKL.
*  DATA : BEGIN OF Z_WRF3 OCCURS 5.
*          INCLUDE STRUCTURE WRF3.
*  DATA : END OF Z_WRF3.
*
*  DATA : Z_LOCAL1 LIKE SY-TABIX.
* data: p_subrc like sy-subrc.                             " INSERT 4.6A
*
*  REFRESH I_WRF3.
*
** Konvertierung
*  IF LOCATION CO ' 0123456789'.
*    N_LOCNR = LOCATION.
*    LOCATION = N_LOCNR.
*  ENDIF.
*
** Test, ob bereits gesucht, aber nicht gefunden
*  CLEAR SY-SUBRC.
*  DESCRIBE TABLE LOCAL_NO_WRF3 LINES Z_LOCAL1.
*  IF Z_LOCAL1 <> 0.
*    LOOP AT LOCAL_NO_WRF3.
*      IF LOCAL_NO_WRF3-LOCNR = LOCATION
*      AND LOCAL_NO_WRF3-MATKL = MATKL.
**      SY-SUBRC = 4.                                      " DELETE 4.6A
*       p_SUBRC = 4.                                       " INSERT 4.6A
*        EXIT.                          "from loop
*      ENDIF.
*    ENDLOOP.
**    IF SY-SUBRC = 4.                                     " DELETE 4.6A
*   IF p_SUBRC = 4.                                        " INSERT 4.6A
*      EXIT.                            "from form
*    ENDIF.
*  ELSE.
*    CLEAR SY-SUBRC.
*  ENDIF.
*
** Test, ob bereits in lokalem Gedächtnis
*  CLEAR : WRF3, Q_WRF3, Z_WRF3.
*  REFRESH Z_WRF3.
*  DESCRIBE TABLE LOCAL_WRF3 LINES Z_WRF3.
*  LOOP AT LOCAL_WRF3.
*    IF  LOCAL_WRF3-LOCNR = LOCATION
*    AND LOCAL_WRF3-MATKL = MATKL.
*      MOVE-CORRESPONDING LOCAL_WRF3 TO I_WRF3.
*      APPEND I_WRF3.
*      Q_WRF3 = 'X'.
*    ENDIF.
*  ENDLOOP.
*  IF Q_WRF3 = ' '.                     "noch nicht gefunden
*    SELECT * FROM WRF3 INTO TABLE Z_WRF3
*        WHERE LOCNR = LOCATION
*        AND   MATKL = MATKL.
*    IF SY-SUBRC = 0.
*                                      "vorerst alle WRF3-Sätze anhängen
*      "später ggf. Anzahl begrenzen  (z.B. 100 -> siehe MWWCONST)
**     IF Z_WRF3 <= MAX_Z_WRF3.
*        LOOP AT Z_WRF3.
*          MOVE-CORRESPONDING Z_WRF3 TO LOCAL_WRF3.
*          APPEND LOCAL_WRF3.
**       ENDLOOP.
**     ENDIF.
**     LOOP AT Z_WRF3.
*        MOVE-CORRESPONDING Z_WRF3 TO I_WRF3.
*        APPEND I_WRF3.
*      ENDLOOP.
*      CLEAR SY-SUBRC.
*    ELSE.
*      "keine Eintragung in WRF3 gefunden
*      LOOP AT LOCAL_NO_WRF3
*        WHERE LOCNR = LOCATION
*        AND   MATKL = MATKL.
*      ENDLOOP.
*      IF SY-SUBRC <> 0.                "noch nicht vorhanden
** begin Performance 4.0C 18.5.98
*      LOCAL_NO_WRF3-LOCNR = LOCATION.
*      LOCAL_NO_WRF3-MATKL = MATKL.
** end Performance 4.0C 18.5.98
*        APPEND LOCAL_NO_WRF3.
*      ENDIF.
*      SY-SUBRC = 1.
*    ENDIF.
*  ELSE.
*    CLEAR SY-SUBRC.
*  ENDIF.
*ENDFORM.




* Gruppe : Lesen von WRSx-Daten ***************************************





************************************************************************
*
* Lesen wrs6
*
************************************************************************

FORM WRS6_READ USING P_ASORT LIKE WRS6-ASORT
                     P_MATKL LIKE WRS6-MATKL
                     WRS6     STRUCTURE WRS6.

  DATA : Z_LOCAL1 LIKE SY-TABIX,
         SUBRC6 LIKE SY-SUBRC.
  DATA : BEGIN OF I_WRS6_T OCCURS 10.
          INCLUDE STRUCTURE WRS6.
  DATA : END OF I_WRS6_T.
  DATA:  H_TABIX LIKE SY-TABIX.

                                       "ermitteln Transaktionsumgebung
  CALL FUNCTION 'ASS_CHECK_APPLICATION_AREA'
       IMPORTING
            TCODE = SO-TCODE
            WAPPL = SO-SUBRC.
* Zustand WAPPL:
*           assortment_maintenance = 01
*           promotion_maintenance  = 02
*           allocation_maintenance = 03
*           article_maintenance    = 04
*           general_maintain       = 05
*           general_read           = 06.
  SY-SUBRC = SO-SUBRC.

* Konvertierung
  IF P_ASORT CO ' 0123456789'.
    N_LOCNR = P_ASORT.
    P_ASORT = N_LOCNR.
  ENDIF.

  CLEAR WRS6.
  IF SO-TCODE = EP1 OR SO-TCODE = EP2
     OR SO-TCODE = ADD OR SO-TCODE = COR
     OR SO-TCODE = MM41 OR SO-TCODE = MM42.
    READ TABLE WRS6_READ WITH KEY MATKL = P_MATKL
         BINARY SEARCH.
    IF SY-SUBRC = 0.
      IF NOT WRS6_READ-DATA_EXIST IS INITIAL.
        LOOP AT LOCAL_WRS6 WHERE ASORT = P_ASORT
                           AND   MATKL = P_MATKL.
          MOVE-CORRESPONDING LOCAL_WRS6 TO WRS6.
          EXIT.
        ENDLOOP.
      ENDIF.
    ELSE.                              " es wurde noch nicht gelesen
      H_TABIX = SY-TABIX.
      SELECT * FROM WRS6 INTO TABLE I_WRS6_T
           WHERE MATKL = P_MATKL.
      IF SY-SUBRC = 0.
        LOOP AT I_WRS6_T.
          MOVE-CORRESPONDING I_WRS6_T TO LOCAL_WRS6.
          APPEND LOCAL_WRS6.
          IF LOCAL_WRS6-MATKL = P_MATKL AND
             LOCAL_WRS6-ASORT = P_ASORT.
            MOVE LOCAL_WRS6 TO WRS6.
          ENDIF.
        ENDLOOP.
        WRS6_READ-MATKL = P_MATKL.
        CLEAR WRS6_READ-LOCNR.
        WRS6_READ-DATA_EXIST = 'X'.
        INSERT WRS6_READ INDEX H_TABIX.
      ELSE.
        WRS6_READ-MATKL = P_MATKL.
        CLEAR WRS6_READ-LOCNR.
        CLEAR WRS6_READ-DATA_EXIST.
        INSERT WRS6_READ INDEX H_TABIX.
      ENDIF.
    ENDIF.
  ELSEIF SO-TCODE = ZCR.               " Daten für locnr sortiert
    READ TABLE WRS6_READ WITH KEY LOCNR = P_ASORT
         BINARY SEARCH.
    IF SY-SUBRC = 0.
      IF NOT WRS6_READ-DATA_EXIST IS INITIAL.
        LOOP AT LOCAL_WRS6 WHERE ASORT = P_ASORT
                           AND   MATKL = P_MATKL.
          MOVE-CORRESPONDING LOCAL_WRS6 TO WRS6.
          EXIT.
        ENDLOOP.
      ENDIF.
    ELSE.                              " es wurde noch nicht gelesen
      H_TABIX = SY-TABIX.
      SELECT * FROM WRS6 INTO TABLE I_WRS6_T
           WHERE ASORT = P_ASORT.
      IF SY-SUBRC = 0.
        LOOP AT I_WRS6_T.
          MOVE-CORRESPONDING I_WRS6_T TO LOCAL_WRS6.
          APPEND LOCAL_WRS6.
          IF LOCAL_WRS6-MATKL = P_MATKL AND
             LOCAL_WRS6-ASORT = P_ASORT.
            MOVE LOCAL_WRS6 TO WRS6.
          ENDIF.
        ENDLOOP.
        CLEAR WRS6_READ-MATKL.
        WRS6_READ-LOCNR = P_ASORT.
        WRS6_READ-DATA_EXIST = 'X'.
        INSERT WRS6_READ INDEX H_TABIX.
      ELSE.
        CLEAR WRS6_READ-MATKL.
        WRS6_READ-LOCNR = P_ASORT.
        CLEAR WRS6_READ-DATA_EXIST.
        INSERT WRS6_READ INDEX H_TABIX.
      ENDIF.
    ENDIF.
  ELSE.                                " Daten werden für Key gelesen !
    READ TABLE WRS6_READ WITH KEY MATKL = P_MATKL
                                  LOCNR = P_ASORT
         BINARY SEARCH.
    IF SY-SUBRC = 0.
      IF NOT WRS6_READ-DATA_EXIST IS INITIAL.
        LOOP AT LOCAL_WRS6 WHERE ASORT = P_ASORT
                           AND   MATKL = P_MATKL.
          MOVE-CORRESPONDING LOCAL_WRS6 TO WRS6.
          EXIT.
        ENDLOOP.
      ENDIF.
    ELSE.                              " es wurde noch nicht gelesen
      H_TABIX = SY-TABIX.
      SELECT SINGLE * FROM WRS6
           WHERE MATKL = P_MATKL AND
                 ASORT = P_ASORT.
      IF SY-SUBRC = 0.
        MOVE-CORRESPONDING WRS6 TO LOCAL_WRS6.
        APPEND LOCAL_WRS6.
        WRS6_READ-MATKL = P_MATKL.
        WRS6_READ-LOCNR = P_ASORT.
        WRS6_READ-DATA_EXIST = 'X'.
        INSERT WRS6_READ INDEX H_TABIX.
      ELSE.
        WRS6_READ-MATKL = P_MATKL.
        WRS6_READ-LOCNR = P_ASORT.
        CLEAR WRS6_READ-DATA_EXIST.
        INSERT WRS6_READ INDEX H_TABIX.
      ENDIF.
    ENDIF.
  ENDIF.

  IF WRS6 IS INITIAL.
    SY-SUBRC = 1.
  ENDIF.



ENDFORM.

************************************************************************
*
* Lesen WRS1
*
************************************************************************

FORM WRS1_READ USING ASORT
                     WRS1     STRUCTURE WRS1.

  CALL FUNCTION 'WRS1_SINGLE_READ'
       EXPORTING
            ASORT           = ASORT
*           SPRAS           =
       IMPORTING
            WRS1_OUT        = WRS1
*           WRST_OUT        =
       EXCEPTIONS
            NO_RECORD_FOUND = 1
            SPRAS_NOT_FOUND = 2
            OTHERS          = 3.

ENDFORM.



* Lesen Werksdaten ***************************************************





************************************************************************
*
* Lesen T001W - alle Betriebstypen je VTLinie als Liste
*
************************************************************************
*
* FORM t001w_read_vkorg_all TABLES wt001w STRUCTURE t001w
*                          USING  vkorg vtweg.
*  SELECT * FROM t001w INTO TABLE wt001w
*        WHERE vkorg = vkorg
*        AND   vtweg = vtweg
*        AND ( vlfkz = c_typ_filiale
*           OR vlfkz = c_typ_vz )
*        AND   kunnr NE space.
* ENDFORM.

************************************************************************
*
* Lesen Bewertungskreise
*
************************************************************************

FORM T001K_READ USING BWKEY
                     WT001K STRUCTURE T001K.
  CALL FUNCTION 'T001K_SINGLE_READ'
       EXPORTING
*         KZRFB      = ' '
*         MAXTZ      = 0
            BWKEY      = BWKEY
       IMPORTING
            WT001K     = WT001K
       EXCEPTIONS
            NOT_FOUND  = 1
            WRONG_CALL = 2
            OTHERS     = 3.

* SELECT SINGLE * FROM t001k INTO wt001k
*     WHERE bwkey = bwkey.
ENDFORM.

************************************************************************
*
* Lesen TVKWZ
*
************************************************************************

FORM TVKWZ_READ TABLES WTVKWZ STRUCTURE TVKWZ
                       USING  WERKS.
  SELECT * FROM TVKWZ INTO TABLE WTVKWZ
      WHERE WERKS = WERKS.
ENDFORM.
