*&---------------------------------------------------------------------*
*& Include          SAPMZBGRPO_RCV_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

CASE sy-ucomm.
  WHEN 'BACK'.
    LEAVE PROGRAM.
  WHEN 'EXIT'.
    LEAVE PROGRAM.
  WHEN 'CANCEL'.
    LEAVE PROGRAM.
  WHEN 'SAVE'.
   IF scrap IS INITIAL.
    REFRESH it_log.
    PERFORM save.
   ELSEIF scrap = 'X'.

 DATA:lv_ans TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Warning!!'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Please check all data properly before scrap posting!!!'
      text_button_1         = 'Confirm'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'Go Back'
      icon_button_2         = 'ICON_SYSTEM_UNDO'
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_ans
*     TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF lv_ans = '1'.
    REFRESH it_log.
    CLEAR wa_hdr-mblnr_542.
    CLEAR wa_hdr-mblnr_201.
     PERFORM do_542.
   IF wa_hdr-mblnr_542 IS NOT INITIAL.
     PERFORM do_201.
   ENDIF.
  ENDIF.
     CLEAR: it_item, wa_hdr.
     CALL METHOD grid1->refresh_table_display.
 ENDIF.

  IF it_log IS NOT INITIAL.
    PERFORM disp_msgs.
  ENDIF.

 WHEN 'PRINT'.
 IF wa_hdr-ebeln IS NOT INITIAL.  " AND gv_subrc = 0 .
*   CLEAR: lv_ans.
*    CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      titlebar              = 'Warning!!'
**     DIAGNOSE_OBJECT       = ' '
*      text_question         = 'Do you want to see the job card ?'
*      text_button_1         = 'YES'
*      icon_button_1         = 'ICON_OKAY'
*      text_button_2         = 'NO'
*      icon_button_2         = 'ICON_SYSTEM_UNDO'
**     DEFAULT_BUTTON        = '1'
*      display_cancel_button = ' '
*    IMPORTING
*      answer                = lv_ans
**     TABLES
**     PARAMETER             =
*    EXCEPTIONS
*      text_not_found        = 1
*      OTHERS                = 2.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*   IF  lv_ans = '1'.
    SUBMIT zjobcard2  WITH p_ebeln = wa_hdr-ebeln AND RETURN.

ELSE.
  MESSAGE 'ENTER PURCHASE ORDER' TYPE 'E'.
ENDIF.


  WHEN 'REFRESH'.
     CLEAR: wa_hdr.
     REFRESH : it_item,  gt_mseg, it_con , it_log.
     CALL METHOD grid1->refresh_table_display.
*
* WHEN 'PRINT'.
*    SUBMIT zjobcard2  WITH p_ebeln = wa_hdr-ebeln AND RETURN.

 ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data INPUT.

IF wa_hdr-budat IS INITIAL.
  lv_cursor = 'WA_HDR-BUDAT'.
  SET CURSOR FIELD lv_cursor.
  MESSAGE 'Enter Posting Date' TYPE 'E'.
ENDIF.


IF wa_hdr-ebeln IS INITIAL.
  lv_cursor = 'WA_HDR-EBELN'.
  SET CURSOR FIELD lv_cursor.
  MESSAGE 'Enter PO Number' TYPE 'E'.

ELSEIF wa_hdr-ebeln IS NOT INITIAL.

  SELECT SINGLE werks FROM ekpo INTO wa_hdr-werks WHERE ebeln =  wa_hdr-ebeln.

  REFRESH : it_item.
  SELECT DISTINCT
    ekpo~ebeln,
    ekpo~ebelp,
    ekpo~matnr,
    ekpo~txz01,
    ekpo~menge,
    ekpo~meins,
    mseg~charg,
    mseg~lifnr,
    mseg~werks,
    mseg~matnr AS m_matnr,
    makt~maktx,
    mseg~menge AS m_menge,
    mseg~meins AS m_meins,
*    konp~kbetr,
    mara~matkl,
    mara~ean11
    INTO TABLE @gt_mseg
    FROM ekpo AS ekpo
    INNER JOIN mseg AS mseg ON mseg~ebeln = ekpo~ebeln AND mseg~ebelp = ekpo~ebelp AND mseg~bwart = '541' AND mseg~xauto = @space
    INNER JOIN makt AS makt ON mseg~matnr = makt~matnr
    INNER JOIN mara AS mara ON ekpo~matnr = mara~matnr
*    INNER JOIN a502 AS a502 ON  a502~kschl = 'ZMKP' AND a502~matnr = mseg~matnr AND a502~datab LE @sy-datum AND a502~datbi GE @sy-datum AND a502~lifnr = mseg~lifnr
*    INNER JOIN a406 AS a406 ON  a406~kschl = 'ZEAN' AND a406~matnr = ekpo~matnr AND a406~datab LE @sy-datum AND a406~datbi GE @sy-datum
*    INNER JOIN konp AS konp ON konp~knumh = a502~knumh AND konp~loevm_ko = @space
*    INNER JOIN konp AS konp ON konp~knumh = a406~knumh AND konp~loevm_ko = @space
    WHERE mseg~ebeln = @wa_hdr-ebeln.

  IF sy-subrc = 0.
    SELECT
     ekpo~ebeln,
     ekpo~ebelp,
     ekpo~netpr,
     ekpo~matnr,
     mseg~charg,
     mseg~werks
     INTO TABLE @DATA(gt_ekpo)
     FROM ekpo AS ekpo
     INNER JOIN mseg AS mseg ON mseg~ebeln = ekpo~ebeln AND mseg~ebelp = ekpo~ebelp AND mseg~bwart = '101'
     FOR ALL ENTRIES IN @gt_mseg
     WHERE mseg~charg = @gt_mseg-charg.

*****************************************************************************************************
     SELECT ebeln ebelp bwart menge FROM ekbe INTO TABLE it_ekbe WHERE ebeln = wa_hdr-ebeln
                                                                        AND   bwart = '101'.

     SELECT ebeln ebelp bwart menge FROM ekbe INTO TABLE it_ekbe1 WHERE ebeln = wa_hdr-ebeln
                                                                         AND   bwart = '541'.

*****************************************************************************************************
     REFRESH it_con.
      SELECT matnr
        SUM( menge ) AS menge
             meins
             ebeln
             ebelp FROM mseg INTO TABLE it_con WHERE ebeln = wa_hdr-ebeln AND bwart = '543'
             GROUP BY matnr meins ebeln ebelp.


    LOOP AT gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>).
      AT FIRST.
        wa_hdr-werks = <ls_mseg>-werks.
      ENDAT.
      APPEND INITIAL LINE TO it_item ASSIGNING <gs_item>.
      <gs_item>-ebeln   = <ls_mseg>-ebeln.
      <gs_item>-ebelp   = <ls_mseg>-ebelp.
      <gs_item>-matnr   = <ls_mseg>-matnr.
      <gs_item>-maktx   = <ls_mseg>-txz01.
      <gs_item>-omenge  = <ls_mseg>-menge .
     LOOP AT it_ekbe ASSIGNING FIELD-SYMBOL(<ekbe>) WHERE ebeln = <gs_item>-ebeln AND ebelp = <gs_item>-ebelp.
      <gs_item>-omenge  = <gs_item>-omenge - <ekbe>-menge.
     ENDLOOP.
      <gs_item>-meins   = <ls_mseg>-meins.
      <gs_item>-matkl   = <ls_mseg>-matkl.
      <gs_item>-ean11   = <ls_mseg>-ean11.


      READ TABLE gt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>) WITH KEY matnr = <ls_mseg>-m_matnr charg = <ls_mseg>-charg.
      IF sy-subrc = 0.
        <gs_item>-pur_amt = <ls_ekpo>-netpr.
*        DATA(lv_margin) = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) * <ls_mseg>-kbetr ) / 1000.
*        data(lv_marin) = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) * <ls_mseg>-kbetr ) / 100.
*        <gs_item>-netpr_s = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) ) + lv_margin .
        <gs_item>-netpr_s = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) ) ."+ lv_margin .
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE 'Invalid Doc' TYPE 'E'.
  ENDIF.
*
ENDIF.

 SORT it_item BY ebelp.
 CALL METHOD grid1->refresh_table_display.


ENDMODULE.
