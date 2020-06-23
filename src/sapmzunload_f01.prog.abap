*&---------------------------------------------------------------------*
*& Include          SAPMZUNLOAD_F01
*&---------------------------------------------------------------------*
FORM READ_PALLET .      "added by sjena
  AEXIDV = |{ AEXIDV ALPHA = OUT }| .
  DATA(LEN) = STRLEN( AEXIDV ) .
  IF LEN > 12.
    AEXIDV = AEXIDV+0(11) .       " added by sjena .
  ELSE .
    AEXIDV = AEXIDV+0(12) .       " added by sjena .
  ENDIF.
  AEXIDV = |{ AEXIDV ALPHA = IN }| .
  SELECT SINGLE VENUM FROM VEKP INTO @DATA(GV_VENUM) WHERE EXIDV = @AEXIDV ."OR EXIDV2 = @AEXIDV ) .
  IF SY-SUBRC IS INITIAL .
    SELECT SINGLE VBELN UNVEL FROM VEPO INTO ( GV_VBELN,GV_UNVEL ) WHERE VENUM = GV_VENUM .

    IF GV_VBELN IS INITIAL.
      SELECT SINGLE VBELN FROM VEPO INTO GV_VBELN WHERE VENUM = GV_UNVEL .

      IF GV_VBELN IS NOT INITIAL.
        GV_EXIDV = AEXIDV .
        CALL SCREEN '9993'.
*        PERFORM unloading .
      ELSE .
*        MESSAGE 'No Delivery Found' TYPE 'E' .
*        CALL SCREEN '9992'.
        EXIT .
      ENDIF.
    ELSE .
      SELECT SINGLE VENUM FROM VEPO INTO @DATA(GV_VENUM1) WHERE UNVEL = @GV_VENUM .
      IF SY-SUBRC IS INITIAL .
        SELECT SINGLE EXIDV FROM VEKP INTO GV_EXIDV WHERE VENUM = GV_VENUM1 .
        IF GV_EXIDV IS NOT INITIAL.
          CALL SCREEN '9993'.
*          PERFORM unloading .
        ENDIF.
      ELSE .
        EXIT .
*        CALL SCREEN '9992' .
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM .

*&---------------------------------------------------------------------*
*& Form UNLOADING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UNLOADING.
  REFRESH : I_BDCDATA , IT_MESSTAB .  "added by sjena on 10.02.2019 2:38:49 PM
  CLEAR WA_MESSTAB.
  CTU_PARAM-DISMODE = CTUMODE .
  CTU_PARAM-UPDMODE = CUPDATE .
*  ctu_param-nobinpt = 'X' .
*  ctu_param-racommit = 'X' .
*  MESSAGE 'Ready to Unload' TYPE 'I' DISPLAY LIKE 'S' .
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '4004'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-VBELN'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENT2'.
  PERFORM BDC_FIELD       USING 'LIKP-VBELN'
                                GV_VBELN.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VERP_T'.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=HUSUCH'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'VEKP-EXIDV'.
  PERFORM BDC_FIELD       USING 'VEKP-EXIDV'
                                GV_EXIDV.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=HULEE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=HUSUCH'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'VEKP-EXIDV'.
  PERFORM BDC_FIELD       USING 'VEKP-EXIDV'
                                GV_EXIDV.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=HULOE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=YES'.
  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.

  CALL TRANSACTION 'VL02N' USING I_BDCDATA
                            OPTIONS FROM CTU_PARAM
                            MESSAGES INTO IT_MESSTAB.

  READ TABLE IT_MESSTAB INTO WA_MESSTAB WITH KEY MSGTYP = 'E' TRANSPORTING NO FIELDS .
  IF SY-SUBRC IS INITIAL.
    MESSAGE 'loading Failed' TYPE 'E'.
  ELSE .
    CLEAR MARK .
    SET SCREEN 0 .
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM .


*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_       text
*      -->P_       text
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR W_BDCDATA.
  W_BDCDATA-PROGRAM  = PROGRAM.
  W_BDCDATA-DYNPRO   = DYNPRO.
  W_BDCDATA-DYNBEGIN = 'X'.
  APPEND W_BDCDATA TO I_BDCDATA.
ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_       text
*      -->P_       text
*&---------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR W_BDCDATA.
  W_BDCDATA-FNAM = FNAM.
  W_BDCDATA-FVAL = FVAL.
  CONDENSE W_BDCDATA-FVAL.
  APPEND W_BDCDATA TO I_BDCDATA.
ENDFORM.                    " BDC_FIELD

*& Form FETCH_OPEN_SHIPMENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FETCH_OPEN_SHIPMENTS.
*  BREAK BREDDY.
  SELECT TKNUM SIGNI STLAD FROM VTTK INTO TABLE XVTTK WHERE
     STDIS NE SPACE AND STLAD EQ SPACE AND SIGNI <> SPACE.      "TPLST EQ ATPLST AND
  IF XVTTK[] IS NOT INITIAL.

    SELECT DISTINCT TKNUM TPNUM VBELN	FROM VTTP INTO TABLE GT_VTTP FOR ALL ENTRIES IN XVTTK WHERE TKNUM = XVTTK-TKNUM .

  ENDIF.
  IF GT_VTTP[] IS NOT INITIAL.

    SELECT VBELN VSTEL FROM LIKP INTO TABLE GT_LIKP FOR ALL ENTRIES IN GT_VTTP
      WHERE VBELN = GT_VTTP-VBELN ."AND VSTEL IN ( SVSTEL,SVSTEL2,SVSTEL3 ).

    LOOP AT GT_LIKP .
      READ TABLE GT_VTTP  WITH KEY VBELN = GT_LIKP-VBELN.
      IF SY-SUBRC IS INITIAL.
        MOVE-CORRESPONDING GT_VTTP TO GT_TKNUM .
        APPEND GT_TKNUM .
      ENDIF.
    ENDLOOP.

    SORT GT_TKNUM BY TKNUM.
  ENDIF.
  REFRESH XVTTK.
*  break breddy.
  IF GT_TKNUM IS NOT INITIAL.

    SELECT TKNUM SIGNI STLAD FROM VTTK INTO TABLE XVTTK
      FOR ALL ENTRIES IN GT_TKNUM WHERE TKNUM = GT_TKNUM-TKNUM
     AND STDIS NE SPACE AND STLAD EQ SPACE
      AND SIGNI <> SPACE.       "" AND TPLST EQ ATPLST
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MESSAGE_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MESSAGE_SCREEN.

  CALL SCREEN 9999.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TDP_PARAMETER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TDP_PARAMETER.

  DATA PARAMETER_VALUE TYPE USR05-PARVA.

  CALL FUNCTION 'G_GET_USER_PARAMETER'
    EXPORTING
      PARAMETER_ID    = 'TDP'   "Transportation planning point
    IMPORTING
      PARAMETER_VALUE = PARAMETER_VALUE
      RC              = ASUBRC.
  CHECK ASUBRC IS INITIAL.
  ATPLST = PARAMETER_VALUE.

  CLEAR : PARAMETER_VALUE .
  CALL FUNCTION 'G_GET_USER_PARAMETER'
    EXPORTING
      PARAMETER_ID    = 'VST'   "Shipping Point
    IMPORTING
      PARAMETER_VALUE = PARAMETER_VALUE
      RC              = SSUBRC.
  CHECK ASUBRC IS INITIAL.

  SEARCH PARAMETER_VALUE FOR ','. "added by sjena on 27.01.2019 10:29:07
  IF  SY-SUBRC IS INITIAL .
    SPLIT PARAMETER_VALUE AT ',' INTO SVSTEL SVSTEL2 SVSTEL3 .  "Multiple_shipping_point_in_user_parameter
  ELSE.
    SVSTEL = PARAMETER_VALUE. "single_shipping_pt_user_parameter
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form READ_SHIPMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM READ_SHIPMENT.

  CLEAR TEMPA.

  READ TABLE XVTTK
  INDEX GV_SEL.
  IF SY-SUBRC EQ 0.

*  ATKNUM = <AFS>+0(10).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = XVTTK-TKNUM
      IMPORTING
        OUTPUT = ATKNUM.

    PERFORM LOCK_UNLOCK_SHIPMENT USING ATKNUM AX
                              CHANGING ASUBRC.
    IF ASUBRC IS NOT INITIAL.
      CLEAR: AICON, MESAG1, MESAG2, MESAG3, MESAG4, MESAG5, MESAG6, MESAG7.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO AMESAG.
      AICON  = ICON_RED_LIGHT.
      MESAG1 = AMESAG+0(25).
      MESAG2 = AMESAG+26(25).
      MESAG3 = AMESAG+51(25).
      MESAG4 = AMESAG+76(25).
      MESAG5 = AMESAG+101(25).
      PERFORM CALL_MESSAGE_SCREEN.
      EXIT.
    ENDIF.

    REFRESH XVTTP.
    SELECT VBELN FROM VTTP INTO TABLE XVTTP WHERE TKNUM EQ ATKNUM.
    IF SY-SUBRC IS NOT INITIAL.
      CLEAR: AICON, MESAG1, MESAG2, MESAG3, MESAG4, MESAG5, MESAG6, MESAG7.
      AICON  = ICON_RED_LIGHT.
      MESAG1 = TEXT-003.
      MESAG2 = TEXT-004.
      MESAG3 = ATKNUM.
      PERFORM CALL_MESSAGE_SCREEN.
      EXIT.
    ENDIF.

*****All Lower Level HU's
    SELECT VENUM VEPOS VBELN FROM VEPO INTO TABLE XVEPO FOR ALL ENTRIES IN XVTTP WHERE VBELN EQ XVTTP-VBELN.

    IF SY-SUBRC IS NOT INITIAL.
      CLEAR: AICON, MESAG1, MESAG2, MESAG3, MESAG4, MESAG5, MESAG6, MESAG7.
      AICON  = ICON_RED_LIGHT.
      MESAG1 = TEXT-005.
      PERFORM CALL_MESSAGE_SCREEN.
      EXIT.
    ELSE.
      SORT XVEPO BY VENUM.
      DELETE ADJACENT DUPLICATES FROM XVEPO COMPARING VENUM.
    ENDIF.

*****Higher Level HU's for Lower Level HU's
    SELECT VENUM EXIDV EXIDV2 UEVEL FROM VEKP INTO TABLE XVEKP FOR ALL ENTRIES IN XVEPO WHERE VENUM EQ XVEPO-VENUM.
    SELECT VENUM,EXIDV FROM VEKP INTO TABLE @DATA(SPALLET) FOR ALL ENTRIES IN @XVEKP WHERE VENUM = @XVEKP-UEVEL .
    LOOP AT SPALLET INTO DATA(SPALLET_W).
      READ TABLE XVEKP WITH KEY UEVEL = SPALLET_W-VENUM .
      IF SY-SUBRC IS INITIAL.
        XVEKP-PALLET = SPALLET_W-EXIDV .
        MODIFY XVEKP  TRANSPORTING PALLET WHERE UEVEL = SPALLET_W-VENUM .
      ENDIF.
    ENDLOOP.
*****Total Lower level HU's
    CLEAR TOTALL_HUS.
    LOOP AT XVEPO.
      TOTALL_HUS = TOTALL_HUS + 1.
      CONCATENATE 'HU' XVEPO-VENUM INTO XVEPO-OBJNR.
*    XVEPO-OBJNR+0(2)  = 'HU'.
*    XVEPO-OBJNR+2(10) = XVEPO-VENUM.
      MODIFY XVEPO INDEX SY-TABIX TRANSPORTING OBJNR.
    ENDLOOP.

    SELECT OBJNR STAT INACT FROM HUSSTAT INTO TABLE XLHUS FOR ALL ENTRIES IN XVEPO WHERE OBJNR EQ XVEPO-OBJNR
        AND STAT = 'I0514' AND INACT EQ SPACE. "Loading with active status

*****Total Loaded HU's
    CLEAR LOADED_HUS.
    LOOP AT XLHUS.
      LOADED_HUS = LOADED_HUS + 1.
    ENDLOOP.

    SELECT SINGLE DALBG DALEN FROM VTTK INTO (ADALBG, ADALEN) WHERE TKNUM = ATKNUM.
    CALL SCREEN '9992' .
  ENDIF .
*  CALL SCREEN 9992.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form LOCK_UNLOCK_SHIPMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_ATKNUM  text
*      -->P_AX  text
*&---------------------------------------------------------------------*
FORM LOCK_UNLOCK_SHIPMENT USING P_ATKNUM TYPE VTTK-TKNUM
                                P_LOCK_IND
                       CHANGING P_ASUBRC TYPE SYSUBRC.

  CLEAR P_ASUBRC.

  IF P_LOCK_IND IS NOT INITIAL.

    CALL FUNCTION 'ENQUEUE_EVVTTKE'
      EXPORTING
        MODE_VTTK      = 'E'
        MANDT          = SY-MANDT
        TKNUM          = P_ATKNUM
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    P_ASUBRC = SY-SUBRC.
    EXIT.

  ELSE.

    CALL FUNCTION 'DEQUEUE_ALL'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form HU_STATUS_SET_LOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM HU_STATUS_SET_LOAD USING P_AEXIDV TYPE EXIDV.


  DATA: IS_STATUS        TYPE HUM_JSTAT,
        IS_HANDLING_UNIT TYPE HUITEM_FROM,
        IF_ACTIVITY      TYPE HU_ST_ACTIVITY.

  IS_STATUS-STAT  = 'I0514'.
  IS_STATUS-INACT = SPACE.

  IF_ACTIVITY = 'HU03'.

  IS_HANDLING_UNIT-EXIDV = P_AEXIDV.

  CALL FUNCTION 'HU_STATUS_SET'
    EXPORTING
      IF_ACTIVITY      = IF_ACTIVITY
      IF_COMPL_CONTENS = SPACE
      IS_STATUS        = IS_STATUS
      IS_HANDLING_UNIT = IS_HANDLING_UNIT
    EXCEPTIONS
      NOT_POSSIBLE     = 1
      ERROR            = 2
      OTHERS           = 3.

  IF SY-SUBRC IS NOT INITIAL.
    EXIT.
  ENDIF.

  CALL FUNCTION 'HU_POST'.
  COMMIT WORK AND WAIT.

  CLEAR SY-SUBRC.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form UNLOAD_HU_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UNLOAD_HU_UPDATE.

  DATA: IS_STATUS        TYPE HUM_JSTAT,
        IS_HANDLING_UNIT TYPE HUITEM_FROM.

*******Update higher level HU's with unloaded status
*  PERFORM HIGHER_HU_AS_LOADED USING AX.

  IS_STATUS-STAT  = 'I0514'.
  IS_STATUS-INACT = AX.

  IS_HANDLING_UNIT-EXIDV = AEXIDV.

  CLEAR AEXIDV.

  CALL FUNCTION 'HU_STATUS_SET'
    EXPORTING
      IF_OBJECT        = '12'
      IF_ACTIVITY      = 'HU04'
      IF_COMPL_CONTENS = AX
      IS_STATUS        = IS_STATUS
      IS_HANDLING_UNIT = IS_HANDLING_UNIT
    EXCEPTIONS
      NOT_POSSIBLE     = 1
      ERROR            = 2
      OTHERS           = 3.

  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO AMESAG.
    AICON  = ICON_RED_LIGHT.
    MESAG1 = AMESAG+0(25).
    MESAG2 = AMESAG+25(25).
    MESAG3 = AMESAG+50(25).
    MESAG4 = AMESAG+75(25).
    MESAG5 = AMESAG+100(25).
    CALL SCREEN 9999.
    EXIT.
  ENDIF.

  CALL FUNCTION 'HU_POST'.
  COMMIT WORK AND WAIT.

*  XLHUS-OBJNR = XVEPO-OBJNR.
  DELETE XLHUS WHERE OBJNR = XVEPO-OBJNR.
  LOADED_HUS = LOADED_HUS - 1.

  IF LOADED_HUS EQ TOTALL_HUS.
    IF ADALEN IS NOT INITIAL.
      PERFORM START_END_LOADING USING ATKNUM
                                      SPACE "Start/End Indicator
                                      AD.   "Change/Delete
    ENDIF.
  ENDIF.

  IF LOADED_HUS EQ 0.
    IF ADALBG IS NOT INITIAL.
      PERFORM START_END_LOADING USING ATKNUM
                                      AX    "Start/End Indicator
                                      AD.   "Change/Delete
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form START_END_LOADING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_ATKNUM  text
*      -->P_AX  text
*      -->P_AC  text
*&---------------------------------------------------------------------*
FORM START_END_LOADING  USING    P_ATKNUM TYPE TKNUM
                                 P_START                "Start/End Indicator
                                 P_INDIC.               "Change/Delete

  DATA: HDATA    TYPE BAPISHIPMENTHEADER,
        HDATA_AC TYPE BAPISHIPMENTHEADERACTION,

        RETURN   TYPE TABLE OF BAPIRET2 WITH HEADER LINE.

  HDATA-SHIPMENT_NUM      = ATKNUM.

  IF P_START IS NOT INITIAL.
    HDATA-STATUS_LOAD_START    = AX.
    HDATA_AC-STATUS_LOAD_START = P_INDIC.
  ELSE.
    HDATA-STATUS_LOAD_END    = AX.
    HDATA_AC-STATUS_LOAD_END = P_INDIC.
  ENDIF.

  CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
    EXPORTING
      HEADERDATA       = HDATA
      HEADERDATAACTION = HDATA_AC
    TABLES
      RETURN           = RETURN[].

  READ TABLE RETURN WITH KEY TYPE = AE.
  IF SY-SUBRC IS INITIAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HIGHER_HU_AS_LOADED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM HIGHER_HU_AS_LOADED USING P_INDIC.

  DATA: YVEKP            LIKE TABLE OF XVEKP WITH HEADER LINE,
        IS_STATUS        TYPE HUM_JSTAT,
        IS_HANDLING_UNIT TYPE HUITEM_FROM,
        IF_ACTIVITY      TYPE HU_ST_ACTIVITY.

  YVEKP[] = XVEKP[].
  SORT YVEKP BY UEVEL.
  DELETE ADJACENT DUPLICATES FROM YVEKP COMPARING UEVEL.

  LOOP AT YVEKP.

    IS_STATUS-STAT  = 'I0514'.
    IS_STATUS-INACT = P_INDIC.

    IF P_INDIC IS INITIAL.
      IF_ACTIVITY = 'HU03'.
    ELSE.
      IF_ACTIVITY = 'HU04'.
    ENDIF.

    IS_HANDLING_UNIT-EXIDV = YVEKP-UEVEL.

    CALL FUNCTION 'HU_STATUS_SET'
      EXPORTING
        IF_ACTIVITY      = IF_ACTIVITY
        IF_COMPL_CONTENS = SPACE
        IS_STATUS        = IS_STATUS
        IS_HANDLING_UNIT = IS_HANDLING_UNIT
      EXCEPTIONS
        NOT_POSSIBLE     = 1
        ERROR            = 2
        OTHERS           = 3.

    CALL FUNCTION 'HU_POST'.
    COMMIT WORK AND WAIT.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_PG_DN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_PG_DN .

  IF GV_LINE > GV_TO.
    CLEAR : XVTTK,
            GS_SHIP.

    GV_FROM = GV_FROM + 7.
    GV_TO = GV_TO + 7.

    LOOP AT XVTTK
      FROM GV_FROM TO GV_TO.
      IF SY-TABIX EQ GV_FROM.
        GS_SHIP-1SLNUM = SY-TABIX.
        GS_SHIP-1TKNUM = XVTTK-TKNUM.
        GS_SHIP-1SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 1.
        GS_SHIP-2SLNUM = SY-TABIX.
        GS_SHIP-2TKNUM = XVTTK-TKNUM.
        GS_SHIP-2SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 2.
        GS_SHIP-3SLNUM = SY-TABIX.
        GS_SHIP-3TKNUM = XVTTK-TKNUM.
        GS_SHIP-3SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 3.
        GS_SHIP-4SLNUM = SY-TABIX.
        GS_SHIP-4TKNUM = XVTTK-TKNUM.
        GS_SHIP-4SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 4.
        GS_SHIP-5SLNUM = SY-TABIX.
        GS_SHIP-5TKNUM = XVTTK-TKNUM.
        GS_SHIP-5SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 5.
        GS_SHIP-6SLNUM = SY-TABIX.
        GS_SHIP-6TKNUM = XVTTK-TKNUM.
        GS_SHIP-6SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 6.
        GS_SHIP-7SLNUM = SY-TABIX.
        GS_SHIP-7TKNUM = XVTTK-TKNUM.
        GS_SHIP-7SIGNI = XVTTK-SIGNI.
      ENDIF.
      CLEAR : XVTTK.
    ENDLOOP.

  ENDIF.      "   IF gv_line > gv_to.

ENDFORM.                    " PROCESS_PG_DN
*&---------------------------------------------------------------------*
*&      Form  PROCESS_PG_UP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_PG_UP .

  IF GV_FROM > 1.
    CLEAR : XVTTK,
            GS_SHIP.
    GV_FROM = GV_FROM - 7.
    GV_TO = GV_TO - 7.

    LOOP AT XVTTK
      FROM GV_FROM TO GV_TO.
      IF SY-TABIX EQ GV_FROM.
        GS_SHIP-1SLNUM = SY-TABIX.
        GS_SHIP-1TKNUM = XVTTK-TKNUM.
        GS_SHIP-1SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 1.
        GS_SHIP-2SLNUM = SY-TABIX.
        GS_SHIP-2TKNUM = XVTTK-TKNUM.
        GS_SHIP-2SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 2.
        GS_SHIP-3SLNUM = SY-TABIX.
        GS_SHIP-3TKNUM = XVTTK-TKNUM.
        GS_SHIP-3SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 3.
        GS_SHIP-4SLNUM = SY-TABIX.
        GS_SHIP-4TKNUM = XVTTK-TKNUM.
        GS_SHIP-4SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 4.
        GS_SHIP-5SLNUM = SY-TABIX.
        GS_SHIP-5TKNUM = XVTTK-TKNUM.
        GS_SHIP-5SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 5.
        GS_SHIP-6SLNUM = SY-TABIX.
        GS_SHIP-6TKNUM = XVTTK-TKNUM.
        GS_SHIP-6SIGNI = XVTTK-SIGNI.
      ENDIF.
      IF SY-TABIX EQ GV_FROM + 6.
        GS_SHIP-7SLNUM = SY-TABIX.
        GS_SHIP-7TKNUM = XVTTK-TKNUM.
        GS_SHIP-7SIGNI = XVTTK-SIGNI.
      ENDIF.
      CLEAR : XVTTK.
    ENDLOOP.

  ENDIF.      "   IF gv_line > gv_to.

ENDFORM.                    " PROCESS_PG_UP
*&---------------------------------------------------------------------*
*& Form HU_STATS_REFR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM HU_STATS_REFR .
  """ HU Status refresh needed after object status change
  CALL FUNCTION 'HU_PACKING_REFRESH'.
  CALL FUNCTION 'SERIAL_INTTAB_REFRESH'
    EXPORTING
      OBJECTS_STATUS_REFRESH = 'X'.

  CALL FUNCTION 'V51G_REFRESH'.
  WAIT UP TO '0.110' SECONDS.
ENDFORM.
