*&---------------------------------------------------------------------*
*& Include          SAPMZUNLOAD_NC_F01
*&---------------------------------------------------------------------*

FORM read_pallet .      "added by sjena
  aexidv = |{ aexidv ALPHA = OUT }| .
  DATA(len) = strlen( aexidv ) .
  IF len > 12.
    aexidv = aexidv+0(11) .       " added by sjena .
  ELSE .
    aexidv = aexidv+0(12) .       " added by sjena .
  ENDIF.
  aexidv = |{ aexidv ALPHA = IN }| .
  SELECT SINGLE venum FROM vekp INTO @DATA(gv_venum) WHERE ( exidv = @aexidv OR exidv2 = @aexidv ) .
  IF sy-subrc IS INITIAL .
    SELECT SINGLE vbeln unvel FROM vepo INTO ( gv_vbeln,gv_unvel ) WHERE venum = gv_venum .

    IF gv_vbeln IS INITIAL.
      SELECT SINGLE vbeln FROM vepo INTO gv_vbeln WHERE venum = gv_unvel .

            IF gv_vbeln IS NOT INITIAL.
        gv_exidv = aexidv .
        CALL SCREEN '9993'.
*        PERFORM unloading .
      ELSE .
*        MESSAGE 'No Delivery Found' TYPE 'E' .
*        CALL SCREEN '9992'.
        EXIT .
      ENDIF.
    ELSE .
      SELECT SINGLE venum FROM vepo INTO @DATA(gv_venum1) WHERE unvel = @gv_venum .
      IF sy-subrc IS INITIAL .
        SELECT SINGLE exidv FROM vekp INTO gv_exidv WHERE venum = gv_venum1 .
        IF gv_exidv IS NOT INITIAL.
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
FORM unloading.
  REFRESH : i_bdcdata , it_messtab .  "added by sjena on 10.02.2019 2:38:49 PM
  CLEAR wa_messtab.
  ctu_param-dismode = ctumode .
  ctu_param-updmode = cupdate .
*  ctu_param-nobinpt = 'X' .
*  ctu_param-racommit = 'X' .
*  MESSAGE 'Ready to Unload' TYPE 'I' DISPLAY LIKE 'S' .
  PERFORM bdc_dynpro      USING 'SAPMV50A' '4004'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'LIKP-VBELN'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENT2'.
  PERFORM bdc_field       USING 'LIKP-VBELN'
                                gv_vbeln.
  PERFORM bdc_dynpro      USING 'SAPMV50A' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=VERP_T'.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=HUSUCH'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6001'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'VEKP-EXIDV'.
  PERFORM bdc_field       USING 'VEKP-EXIDV'
                                gv_exidv.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=HULEE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=HUSUCH'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6001'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'VEKP-EXIDV'.
  PERFORM bdc_field       USING 'VEKP-EXIDV'
                                gv_exidv.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=HULOE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.
  PERFORM bdc_dynpro      USING 'SAPLSPO1' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=YES'.
  PERFORM bdc_dynpro      USING 'SAPLV51G' '6000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'V51VE-VHILM(01)'.

  CALL TRANSACTION 'VL02N' USING i_bdcdata
                            OPTIONS FROM ctu_param
                            MESSAGES INTO it_messtab.

  READ TABLE it_messtab INTO wa_messtab WITH KEY msgtyp = 'E' TRANSPORTING NO FIELDS .
  IF sy-subrc IS INITIAL.
    MESSAGE 'loading Failed' TYPE 'E'.
  ELSE .
    CLEAR mark .
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
FORM bdc_dynpro USING program dynpro.
  CLEAR w_bdcdata.
  w_bdcdata-program  = program.
  w_bdcdata-dynpro   = dynpro.
  w_bdcdata-dynbegin = 'X'.
  APPEND w_bdcdata TO i_bdcdata.
ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_       text
*      -->P_       text
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR w_bdcdata.
  w_bdcdata-fnam = fnam.
  w_bdcdata-fval = fval.
  CONDENSE w_bdcdata-fval.
  APPEND w_bdcdata TO i_bdcdata.
ENDFORM.                    " BDC_FIELD

*& Form FETCH_OPEN_SHIPMENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_open_shipments.
  SELECT tknum signi FROM vttk INTO TABLE xvttk WHERE tplst EQ atplst AND stdis NE space AND stlad EQ space AND signi <> space.

  SELECT DISTINCT tknum tpnum vbeln	FROM vttp INTO TABLE gt_vttp FOR ALL ENTRIES IN xvttk WHERE tknum = xvttk-tknum .

  SELECT vbeln vstel FROM likp INTO TABLE gt_likp FOR ALL ENTRIES IN gt_vttp
    WHERE vbeln = gt_vttp-vbeln AND vstel IN ( svstel,svstel2,svstel3 ).

  LOOP AT gt_likp .
    READ TABLE gt_vttp  WITH KEY vbeln = gt_likp-vbeln.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING gt_vttp TO gt_tknum .
      APPEND gt_tknum .
    ENDIF.
  ENDLOOP.
  SORT gt_tknum BY tknum.
  REFRESH xvttk.
  SELECT tknum signi FROM vttk INTO TABLE xvttk
    FOR ALL ENTRIES IN gt_tknum WHERE tknum = gt_tknum-tknum
    AND tplst EQ atplst AND stdis NE space AND stlad EQ space
    AND signi <> space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MESSAGE_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_message_screen.

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
FORM get_tdp_parameter.

  DATA parameter_value TYPE usr05-parva.

  CALL FUNCTION 'G_GET_USER_PARAMETER'
    EXPORTING
      parameter_id    = 'TDP'   "Transportation planning point
    IMPORTING
      parameter_value = parameter_value
      rc              = asubrc.
  CHECK asubrc IS INITIAL.
  atplst = parameter_value.

  CLEAR : parameter_value .
  CALL FUNCTION 'G_GET_USER_PARAMETER'
    EXPORTING
      parameter_id    = 'VST'   "Shipping Point
    IMPORTING
      parameter_value = parameter_value
      rc              = ssubrc.
  CHECK asubrc IS INITIAL.

  SEARCH parameter_value FOR ','. "added by sjena on 27.01.2019 10:29:07
  IF  sy-subrc IS INITIAL .
    SPLIT parameter_value AT ',' INTO svstel svstel2 svstel3 .  "Multiple_shipping_point_in_user_parameter
  ELSE.
    svstel = parameter_value. "single_shipping_pt_user_parameter
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
FORM read_shipment.

  CLEAR tempa.

  READ TABLE xvttk
  INDEX gv_sel.
  IF sy-subrc EQ 0.

*  ATKNUM = <AFS>+0(10).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = xvttk-tknum
      IMPORTING
        output = atknum.

    PERFORM lock_unlock_shipment USING atknum ax
                              CHANGING asubrc.
    IF asubrc IS NOT INITIAL.
      CLEAR: aicon, mesag1, mesag2, mesag3, mesag4, mesag5, mesag6, mesag7.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO amesag.
      aicon  = icon_red_light.
      mesag1 = amesag+0(25).
      mesag2 = amesag+26(25).
      mesag3 = amesag+51(25).
      mesag4 = amesag+76(25).
      mesag5 = amesag+101(25).
      PERFORM call_message_screen.
      EXIT.
    ENDIF.

    REFRESH xvttp.
    SELECT vbeln FROM vttp INTO TABLE xvttp WHERE tknum EQ atknum.
    IF sy-subrc IS NOT INITIAL.
      CLEAR: aicon, mesag1, mesag2, mesag3, mesag4, mesag5, mesag6, mesag7.
      aicon  = icon_red_light.
      mesag1 = TEXT-003.
      mesag2 = TEXT-004.
      mesag3 = atknum.
      PERFORM call_message_screen.
      EXIT.
    ENDIF.

*****All Lower Level HU's
    SELECT venum vepos vbeln FROM vepo INTO TABLE xvepo FOR ALL ENTRIES IN xvttp WHERE vbeln EQ xvttp-vbeln.

    IF sy-subrc IS NOT INITIAL.
      CLEAR: aicon, mesag1, mesag2, mesag3, mesag4, mesag5, mesag6, mesag7.
      aicon  = icon_red_light.
      mesag1 = TEXT-005.
      PERFORM call_message_screen.
      EXIT.
    else.
      sort xvepo by venum.
      delete ADJACENT DUPLICATES FROM xvepo COMPARING venum.
    ENDIF.

*****Higher Level HU's for Lower Level HU's
    SELECT venum exidv exidv2 uevel FROM vekp INTO TABLE xvekp FOR ALL ENTRIES IN xvepo WHERE venum EQ xvepo-venum.
    SELECT venum,exidv FROM vekp INTO TABLE @DATA(spallet) FOR ALL ENTRIES IN @xvekp WHERE venum = @xvekp-uevel .
    LOOP AT spallet INTO DATA(spallet_w).
      READ TABLE xvekp WITH KEY uevel = spallet_w-venum .
      IF sy-subrc IS INITIAL.
        xvekp-pallet = spallet_w-exidv .
        MODIFY xvekp  TRANSPORTING pallet WHERE uevel = spallet_w-venum .
      ENDIF.
    ENDLOOP.
*****Total Lower level HU's
    CLEAR totall_hus.
    LOOP AT xvepo.
      totall_hus = totall_hus + 1.
      CONCATENATE 'HU' xvepo-venum INTO xvepo-objnr.
*    XVEPO-OBJNR+0(2)  = 'HU'.
*    XVEPO-OBJNR+2(10) = XVEPO-VENUM.
      MODIFY xvepo INDEX sy-tabix TRANSPORTING objnr.
    ENDLOOP.

    SELECT objnr stat inact FROM husstat INTO TABLE xlhus FOR ALL ENTRIES IN xvepo WHERE objnr EQ xvepo-objnr
        AND stat = 'I0514' AND inact EQ space. "Loading with active status

*****Total Loaded HU's
    CLEAR loaded_hus.
    LOOP AT xlhus.
      loaded_hus = loaded_hus + 1.
    ENDLOOP.

    SELECT SINGLE dalbg dalen FROM vttk INTO (adalbg, adalen) WHERE tknum = atknum.
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
FORM lock_unlock_shipment USING p_atknum TYPE vttk-tknum
                                p_lock_ind
                       CHANGING p_asubrc TYPE sysubrc.

  CLEAR p_asubrc.

  IF p_lock_ind IS NOT INITIAL.

    CALL FUNCTION 'ENQUEUE_EVVTTKE'
      EXPORTING
        mode_vttk      = 'E'
        mandt          = sy-mandt
        tknum          = p_atknum
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    p_asubrc = sy-subrc.
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
FORM hu_status_set_load USING p_aexidv TYPE exidv.

  DATA: is_status        TYPE hum_jstat,
        is_handling_unit TYPE huitem_from,
        if_activity      TYPE hu_st_activity.

  is_status-stat  = 'I0514'.
  is_status-inact = space.

  if_activity = 'HU03'.

  is_handling_unit-exidv = p_aexidv.

  CALL FUNCTION 'HU_STATUS_SET'
    EXPORTING
      if_activity      = if_activity
      if_compl_contens = space
      is_status        = is_status
      is_handling_unit = is_handling_unit
    EXCEPTIONS
      not_possible     = 1
      error            = 2
      OTHERS           = 3.

  IF sy-subrc IS NOT INITIAL.
    EXIT.
  ENDIF.

  CALL FUNCTION 'HU_POST'.
  COMMIT WORK AND WAIT.

  CLEAR sy-subrc.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form UNLOAD_HU_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM unload_hu_update.

  DATA: is_status        TYPE hum_jstat,
        is_handling_unit TYPE huitem_from.

*******Update higher level HU's with unloaded status
*  PERFORM HIGHER_HU_AS_LOADED USING AX.

  is_status-stat  = 'I0514'.
  is_status-inact = ax.

  is_handling_unit-exidv = aexidv.

  CLEAR aexidv.

  CALL FUNCTION 'HU_STATUS_SET'
    EXPORTING
      if_object        = '12'
      if_activity      = 'HU04'
      if_compl_contens = ax
      is_status        = is_status
      is_handling_unit = is_handling_unit
    EXCEPTIONS
      not_possible     = 1
      error            = 2
      OTHERS           = 3.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO amesag.
    aicon  = icon_red_light.
    mesag1 = amesag+0(25).
    mesag2 = amesag+25(25).
    mesag3 = amesag+50(25).
    mesag4 = amesag+75(25).
    mesag5 = amesag+100(25).
    CALL SCREEN 9999.
    EXIT.
  ENDIF.

  CALL FUNCTION 'HU_POST'.
  COMMIT WORK AND WAIT.

*  XLHUS-OBJNR = XVEPO-OBJNR.
  DELETE xlhus WHERE objnr = xvepo-objnr.
  loaded_hus = loaded_hus - 1.

  IF loaded_hus EQ totall_hus.
    IF adalen IS NOT INITIAL.
      PERFORM start_end_loading USING atknum
                                      space "Start/End Indicator
                                      ad.   "Change/Delete
    ENDIF.
  ENDIF.

  IF loaded_hus EQ 0.
    IF adalbg IS NOT INITIAL.
      PERFORM start_end_loading USING atknum
                                      ax    "Start/End Indicator
                                      ad.   "Change/Delete
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
FORM start_end_loading  USING    p_atknum TYPE tknum
                                 p_start                "Start/End Indicator
                                 p_indic.               "Change/Delete

  DATA: hdata    TYPE bapishipmentheader,
        hdata_ac TYPE bapishipmentheaderaction,

        return   TYPE TABLE OF bapiret2 WITH HEADER LINE.

  hdata-shipment_num      = atknum.

  IF p_start IS NOT INITIAL.
    hdata-status_load_start    = ax.
    hdata_ac-status_load_start = p_indic.
  ELSE.
    hdata-status_load_end    = ax.
    hdata_ac-status_load_end = p_indic.
  ENDIF.

  CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
    EXPORTING
      headerdata       = hdata
      headerdataaction = hdata_ac
    TABLES
      return           = return[].

  READ TABLE return WITH KEY type = ae.
  IF sy-subrc IS INITIAL.
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
FORM higher_hu_as_loaded USING p_indic.

  DATA: yvekp            LIKE TABLE OF xvekp WITH HEADER LINE,
        is_status        TYPE hum_jstat,
        is_handling_unit TYPE huitem_from,
        if_activity      TYPE hu_st_activity.

  yvekp[] = xvekp[].
  SORT yvekp BY uevel.
  DELETE ADJACENT DUPLICATES FROM yvekp COMPARING uevel.

  LOOP AT yvekp.

    is_status-stat  = 'I0514'.
    is_status-inact = p_indic.

    IF p_indic IS INITIAL.
      if_activity = 'HU03'.
    ELSE.
      if_activity = 'HU04'.
    ENDIF.

    is_handling_unit-exidv = yvekp-uevel.

    CALL FUNCTION 'HU_STATUS_SET'
      EXPORTING
        if_activity      = if_activity
        if_compl_contens = space
        is_status        = is_status
        is_handling_unit = is_handling_unit
      EXCEPTIONS
        not_possible     = 1
        error            = 2
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
FORM process_pg_dn .

  IF gv_line > gv_to.
    CLEAR : xvttk,
            gs_ship.

    gv_from = gv_from + 7.
    gv_to = gv_to + 7.

    LOOP AT xvttk
      FROM gv_from TO gv_to.
      IF sy-tabix EQ gv_from.
        gs_ship-1slnum = sy-tabix.
        gs_ship-1tknum = xvttk-tknum.
        gs_ship-1signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 1.
        gs_ship-2slnum = sy-tabix.
        gs_ship-2tknum = xvttk-tknum.
        gs_ship-2signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 2.
        gs_ship-3slnum = sy-tabix.
        gs_ship-3tknum = xvttk-tknum.
        gs_ship-3signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 3.
        gs_ship-4slnum = sy-tabix.
        gs_ship-4tknum = xvttk-tknum.
        gs_ship-4signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 4.
        gs_ship-5slnum = sy-tabix.
        gs_ship-5tknum = xvttk-tknum.
        gs_ship-5signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 5.
        gs_ship-6slnum = sy-tabix.
        gs_ship-6tknum = xvttk-tknum.
        gs_ship-6signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 6.
        gs_ship-7slnum = sy-tabix.
        gs_ship-7tknum = xvttk-tknum.
        gs_ship-7signi = xvttk-signi.
      ENDIF.
      CLEAR : xvttk.
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
FORM process_pg_up .

  IF gv_from > 1.
    CLEAR : xvttk,
            gs_ship.
    gv_from = gv_from - 7.
    gv_to = gv_to - 7.

    LOOP AT xvttk
      FROM gv_from TO gv_to.
      IF sy-tabix EQ gv_from.
        gs_ship-1slnum = sy-tabix.
        gs_ship-1tknum = xvttk-tknum.
        gs_ship-1signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 1.
        gs_ship-2slnum = sy-tabix.
        gs_ship-2tknum = xvttk-tknum.
        gs_ship-2signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 2.
        gs_ship-3slnum = sy-tabix.
        gs_ship-3tknum = xvttk-tknum.
        gs_ship-3signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 3.
        gs_ship-4slnum = sy-tabix.
        gs_ship-4tknum = xvttk-tknum.
        gs_ship-4signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 4.
        gs_ship-5slnum = sy-tabix.
        gs_ship-5tknum = xvttk-tknum.
        gs_ship-5signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 5.
        gs_ship-6slnum = sy-tabix.
        gs_ship-6tknum = xvttk-tknum.
        gs_ship-6signi = xvttk-signi.
      ENDIF.
      IF sy-tabix EQ gv_from + 6.
        gs_ship-7slnum = sy-tabix.
        gs_ship-7tknum = xvttk-tknum.
        gs_ship-7signi = xvttk-signi.
      ENDIF.
      CLEAR : xvttk.
    ENDLOOP.

  ENDIF.      "   IF gv_line > gv_to.

ENDFORM.                    " PROCESS_PG_UP
