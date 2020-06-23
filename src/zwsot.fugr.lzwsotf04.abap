*&---------------------------------------------------------------------*
*&  Include           LWSOTF04                                         *
*&---------------------------------------------------------------------*

FORM READ_ALL_MARM_ENTRIES TABLES   PT_VRKME STRUCTURE T_VRKME
                           USING    P_MATNR LIKE MARA-MATNR
                                    P_NO_EAN_CHECK LIKE WTDY-TYP01
                                    P_VRKME LIKE MARM-MEINH
                                    P_SUBRC LIKE SY-SUBRC.

  DATA:   HT_MARM TYPE MARM OCCURS 0 WITH HEADER LINE
        , H_MARM TYPE MARM
        , H_MARA TYPE MARA
        .

  DATA: READ_MARA_UNIT(1) VALUE SPACE.

  CLEAR SUBRC.
  IF P_VRKME IS INITIAL.
    REFRESH HT_MARM.
    CALL FUNCTION 'MARM_GENERIC_READ_WITH_MATNR'
      EXPORTING
        MATNR      = P_MATNR
      TABLES
        MARM_TAB   = HT_MARM
      EXCEPTIONS
        WRONG_CALL = 1
        NOT_FOUND  = 2
        OTHERS     = 3.
    IF SY-SUBRC <> 0.
      P_SUBRC = 4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'MARM_SINGLE_READ'
      EXPORTING
        MATNR      = P_MATNR
        MEINH      = P_VRKME
      IMPORTING
        WMARM      = H_MARM
      EXCEPTIONS
        WRONG_CALL = 1
        NOT_FOUND  = 2
        OTHERS     = 3.
    IF SY-SUBRC <> 0.
      SUBRC = 4.
    ELSE.
      APPEND H_MARM TO HT_MARM.
    ENDIF.
  ENDIF.

  IF NOT READ_MARA_UNIT IS INITIAL.
    CALL FUNCTION 'MARA_SINGLE_READ'
      EXPORTING
        MATNR             = P_MATNR
      IMPORTING
        WMARA             = H_MARA
      EXCEPTIONS
        LOCK_ON_MATERIAL  = 1
        LOCK_SYSTEM_ERROR = 2
        WRONG_CALL        = 3
        NOT_FOUND         = 4
        OTHERS            = 5.
    IF SY-SUBRC = 0.
      READ TABLE HT_MARM INTO H_MARM
           WITH KEY MATNR = P_MATNR
                    MEINH = H_MARA-MEINS.
      IF SY-SUBRC <> 0.
        H_MARM-MATNR = P_MATNR.
        H_MARM-MEINH = H_MARA-MEINS.
        H_MARM-EAN11 = H_MARA-EAN11.
        APPEND H_MARM TO HT_MARM.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT HT_MARM INTO H_MARM.
*    if ( not ht_marm-ean11 is initial )
***> Start of change : Suri : 02.08.2019 : 16:00:00
*    Descrption : removing the EAN validation to Create IDoc in WPMA tcode
*    if ( not h_marm-ean11 is initial )
*    or ( not P_NO_EAN_CHECK is initial ).
    PT_VRKME-VRKME = H_MARM-MEINH.
    CLEAR PT_VRKME-MATERIAL_LISTING.
    APPEND PT_VRKME TO PT_VRKME.
*    endif.
***> End of Change : Suri : 02.08.2019 : 16:00:00
ENDLOOP.

    READ TABLE PT_VRKME INDEX 1.
    IF SY-SUBRC <> 0.
      P_SUBRC = 4.
    ENDIF.


ENDFORM.                               " read_all_marm_entries



*---------------------------------------------------------------------*
*  FORM read_all_key_data
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  P_VKORG
*  -->  P_VTWEG
*  -->  P_LOCNR
*  -->  P_VLFKZ
*  -->  P_WERKS
*---------------------------------------------------------------------*
FORM READ_ALL_KEY_DATA CHANGING P_VKORG LIKE T001W-VKORG
                                P_VTWEG LIKE T001W-VTWEG
                                P_LOCNR LIKE T001W-KUNNR
                                P_VLFKZ LIKE T001W-VLFKZ
                                P_WERKS LIKE T001W-WERKS.

  STATICS: H_T001W TYPE T001W.

  IF P_LOCNR IS INITIAL.
    IF H_T001W-WERKS <> P_WERKS.
      CALL FUNCTION 'T001W_READ'
        EXPORTING
          WERKS    = P_WERKS
        IMPORTING
          STRUCT   = H_T001W
        EXCEPTIONS
          NO_ENTRY = 1
          OTHERS   = 2.
    ENDIF.

    P_VKORG = H_T001W-VKORG.
    P_VTWEG = H_T001W-VTWEG.
    P_LOCNR = H_T001W-KUNNR.
    P_VLFKZ = H_T001W-VLFKZ.

  ELSE.

    IF H_T001W-KUNNR <> P_LOCNR.
      SELECT SINGLE * FROM T001W INTO H_T001W WHERE KUNNR = P_LOCNR.
      ENDIF.

      P_VKORG = H_T001W-VKORG.
      P_VTWEG = H_T001W-VTWEG.
      P_WERKS = H_T001W-WERKS.
      P_VLFKZ = H_T001W-VLFKZ.

    ENDIF.

ENDFORM.                               " read_all_key_data


*---------------------------------------------------------------------*
*       FORM read_wlk2_entry                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT_BEW_KOND                                                   *
*  -->  P_MATNR                                                       *
*  -->  P_VKORG                                                       *
*  -->  P_VTWEG                                                       *
*  -->  P_WERKS                                                       *
*  -->  P_DATAB                                                       *
*  -->  P_DATBI                                                       *
*  -->  P_BUFFER_WLK2_FILIA_ENTRIES                                   *
*  -->  P_SUBRC                                                       *
*---------------------------------------------------------------------*
FORM READ_WLK2_ENTRY
     USING    P_MATNR LIKE MARA-MATNR
              P_VKORG LIKE T001W-VKORG
              P_VTWEG LIKE T001W-VTWEG
              P_WERKS LIKE T001W-WERKS
              P_DATAB LIKE WLK1-DATAB
              P_DATBI LIKE WLK1-DATBI
              P_BUFFER_WLK2_FILIA_ENTRIES LIKE  MTCOM-KZRFB
     CHANGING P_BEW_KOND STRUCTURE WPWLK2
              P_SUBRC LIKE SY-SUBRC.

  STATICS:   H_WLK2 TYPE WLK2
         ,   WLK2_ENTRY TYPE WLK2
         ,   G_MATNR LIKE MARA-MATNR
         ,   G_WERKS LIKE T001W-WERKS
         .

  IF  WLK2_ENTRY-MATNR IS INITIAL
  OR  NOT ( G_WERKS = P_WERKS  AND
            G_MATNR = P_MATNR    ).

* Lesen des Verkaufszeitraumes für den Artikel und die Filiale aus WLK2
* Dieses Lesen ist unabhängig von der VRKME
    H_WLK2-MATNR = P_MATNR.
    H_WLK2-VKORG = P_VKORG.
    H_WLK2-VTWEG = P_VTWEG.
    H_WLK2-WERKS = P_WERKS.
    CALL FUNCTION 'WLK2_READ'
      EXPORTING
        WLK2                      = H_WLK2
        BUFFER_WLK2_FILIA_ENTRIES = P_BUFFER_WLK2_FILIA_ENTRIES
      IMPORTING
        WLK2_OUT                  = WLK2_ENTRY
      EXCEPTIONS
        NO_REC_FOUND              = 1
        KEY_NOT_COMPLETE          = 2
        WERKS_NOT_FOUND           = 3
        OTHERS                    = 4.
    IF SY-SUBRC <> 0.
      P_SUBRC = 4.
      EXIT.
    ENDIF.

  ENDIF.

  IF  P_DATAB <= WLK2_ENTRY-VKBIS AND
      P_DATBI >= WLK2_ENTRY-VKDAB.
* Es liegt eine Überschneidung vor. Der Satz ist relevant.
    MOVE-CORRESPONDING WLK2_ENTRY TO P_BEW_KOND.
    P_BEW_KOND-ARTHIER = 'V'.
    IF NOT T_WLK2_INPUT-WERKS IS INITIAL.
      P_BEW_KOND-ORGHIER = 'F'.        "Filialebene
    ELSEIF NOT WLK2_ENTRY-VKORG IS INITIAL
       AND NOT WLK2_ENTRY-VTWEG IS INITIAL.
      P_BEW_KOND-ORGHIER = 'V'.        "VTschienen-Ebene
    ELSE.
      P_BEW_KOND-ORGHIER = 'K'.        "Konzernebene
    ENDIF.
    P_BEW_KOND-DATUM = P_DATAB.
  ENDIF.

ENDFORM.                               " read_wlk2_entry

*---------------------------------------------------------------------*
*  FORM read_listing_conditions
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  PT_WLK1
*  -->  P_MATNR
*  -->  P_LOCNR
*  -->  P_VLFKZ
*  -->  P_DATAB
*  -->  P_DATBI
*  -->  P_SUBRC
*---------------------------------------------------------------------*
FORM READ_LISTING_CONDITIONS TABLES   PT_WLK1 STRUCTURE WLK1
                             USING    P_MATNR LIKE MARA-MATNR
                                      P_LOCNR LIKE T001W-KUNNR
                                      P_VLFKZ LIKE T001W-VLFKZ
                                      P_DATAB LIKE WLK1-DATAB
                                      P_DATBI LIKE WLK1-DATBI
                             CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA:  HT_WLK1 TYPE WLK1 OCCURS 0 WITH HEADER LINE
       , HT_WRS1 TYPE WRS1 OCCURS 0
       , H_WRS1 TYPE WRS1
       , H_WLK1 TYPE WLK1.
  DATA: NUMBER_OF_ENTRIES LIKE SY-TABIX.


  REFRESH PT_WLK1.

  CALL FUNCTION 'ASSORTMENT_GET_ASORT_OF_USER'
    EXPORTING
      VALID_PER_DATE  = P_DATAB                 " note 640416
      DATE_TO         = P_DATBI                 " note 640416
      USER            = P_LOCNR
      USER_TYPE       = P_VLFKZ
    TABLES
      ASSORTMENT_DATA = HT_WRS1
*     ASSORTMENT_CONNECTS        =
    EXCEPTIONS
      NO_ASORT_FOUND  = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    P_SUBRC = 4.
  ENDIF.

  LOOP AT HT_WRS1 INTO H_WRS1.
    H_WLK1-FILIA = H_WRS1-ASORT.
    H_WLK1-ARTNR = P_MATNR.
    CLEAR H_WLK1-DATAB.
    CLEAR H_WLK1-DATBI.

    CALL FUNCTION 'WLK1_READ_MULTIPLE_FUNCTIONS'
      EXPORTING
*       BUFFERS_READ       = ' '
        WLK1_SINGLE_SELECT = H_WLK1
        FUNCTION           = 'H'
*       ATTYP              = ' '
*       SELECT_ASSORTMENT  = ' '
*       KZRFB              = ' '
*       SORT_DIRECTION     = ' '
*       SELECT_WHOLE_ARTICLE       = 'X'
*  IMPORTING
*       WLK1_OUTPUT        =
      TABLES
*       WLK1_ARRAY_SELECT  =
        WLK1_RESULTS       = HT_WLK1
*       SAMMEL_ITEM        =
*       PLANT_LIST         =
*       MATNR_ME_ONLY      =
      EXCEPTIONS
        NO_REC_FOUND       = 1
        OTHERS             = 2.
    IF SY-SUBRC = 0.
      APPEND LINES OF HT_WLK1 TO PT_WLK1.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE PT_WLK1 LINES NUMBER_OF_ENTRIES.
  IF NUMBER_OF_ENTRIES = 0.
    P_SUBRC = 4.
  ELSE.
    SORT PT_WLK1 DESCENDING BY DATBI.
    READ TABLE PT_WLK1 INDEX 1.
    IF PT_WLK1-SSTAT = '5'.
      P_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.                               " read_listing_conditions


*&---------------------------------------------------------------------*
*&      Form  check_input_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_ASORT  text
*      -->P_PI_VKORG  text
*      -->P_PI_VTWEG  text
*      -->P_PI_WERKS  text
*      <--P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_DATA CHANGING P_ASORT
                               P_VKORG
                               P_VTWEG
                               P_WERKS
                               P_DATAB LIKE SY-DATUM       " note 640416
                               P_DATBI LIKE SY-DATUM       " note 640416
                               P_SUBRC.

  DATA:   H_T001W TYPE T001W
        , H_WRS1 TYPE WRS1
        , HT_WRS1 TYPE WRS1 OCCURS 0
        , Z1 LIKE SY-TABIX
        , HT_WRSZ TYPE WRSZ OCCURS 0
        , H_WRSZ TYPE WRSZ
        .

  CLEAR P_SUBRC.
  CHECK    P_ASORT IS INITIAL
        OR P_VKORG IS INITIAL
        OR P_VTWEG IS INITIAL
        OR P_WERKS IS INITIAL .

  IF P_ASORT IS INITIAL
  AND P_WERKS IS INITIAL.
    P_SUBRC = 4.
  ENDIF.

  IF P_VKORG IS INITIAL.
    IF NOT P_WERKS IS INITIAL.
      CALL FUNCTION 'T001W_SINGLE_READ'
        EXPORTING
          T001W_WERKS = P_WERKS
        IMPORTING
          WT001W      = H_T001W
        EXCEPTIONS
          NOT_FOUND   = 1
          OTHERS      = 2.
      IF SY-SUBRC = 0.
        P_VKORG = H_T001W-VKORG.
        P_VTWEG = H_T001W-VTWEG.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRS1_SINGLE_READ'
        EXPORTING
          ASORT           = P_ASORT
        IMPORTING
          WRS1_OUT        = H_WRS1
        EXCEPTIONS
          NO_RECORD_FOUND = 1
          SPRAS_NOT_FOUND = 2
          OTHERS          = 3.
      IF SY-SUBRC = 0.
        P_VKORG = H_WRS1-VKORG.
        P_VTWEG = H_WRS1-VTWEG.
      ENDIF.
    ENDIF.
  ENDIF.

  IF P_ASORT IS INITIAL.
    CALL FUNCTION 'ASSORTMENT_GET_ASORT_OF_USER'
      EXPORTING
        VALID_PER_DATE  = P_DATAB                  " note 640416
        DATE_TO         = P_DATBI                  " note 640416
        USER            = H_T001W-KUNNR
        USER_TYPE       = H_T001W-VLFKZ
      TABLES
        ASSORTMENT_DATA = HT_WRS1
      EXCEPTIONS
        NO_ASORT_FOUND  = 1
        OTHERS          = 2.
    DESCRIBE TABLE HT_WRS1 LINES Z1.
    IF Z1 = 1.
      READ TABLE HT_WRS1 INTO H_WRS1 INDEX 1.
      P_ASORT = H_WRS1-ASORT.
    ELSE.

    ENDIF.

  ELSE.                                " p_werks is initial.
    CALL FUNCTION 'ASSORTMENT_GET_USERS_OF_1ASORT'
      EXPORTING
        ASORT              = P_ASORT
        VALID_PER_DATE     = P_DATAB                 " note 640416
        DATE_TO            = P_DATBI                 " note 640416
      TABLES
        ASSORTMENT_USERS   = HT_WRSZ
      EXCEPTIONS
        NO_ASORT_TO_SELECT = 1
        NO_USER_FOUND      = 2
        OTHERS             = 3.
    IF SY-SUBRC = 0.
      LOOP AT HT_WRSZ INTO H_WRSZ.
        IF NOT H_WRSZ-LOCNR IS INITIAL.
          SELECT SINGLE * FROM T001W INTO H_T001W
                 WHERE KUNNR = H_WRSZ-LOCNR.
            IF SY-SUBRC = 0.
              P_WERKS = H_T001W-WERKS.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.                               "   if p_asort is initial.
    CLEAR SY-SUBRC.
ENDFORM.                               " check_input_data
