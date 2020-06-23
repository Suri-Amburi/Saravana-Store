*&---------------------------------------------------------------------*
*& Include          ZMM_GR_TO_STO_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

SELECT SINGLE mblnr FROM zinw_t_hdr INTO p_mblnr WHERE qr_code = p_qr.

IF p_mblnr IS NOT INITIAL.
 SELECT
        matnr
        werks
        lgort
        charg
        lifnr
        ebeln
        ebelp
        menge
        meins  FROM matdoc INTO TABLE it_final WHERE mblnr = p_mblnr
                                             AND   xauto = ' '
                                             AND   cancelled =  ' '
                                             AND   bwart IN ( '101' , '109' ).

      SELECT SINGLE ebeln FROM ekko INTO @DATA(lv_ebeln) WHERE unsez = @p_mblnr.

   IF lv_ebeln IS NOT INITIAL.
     MESSAGE 'STO PO IS ALREADY CREATED ' TYPE 'E'.
   ENDIF.


        SORT it_final BY ebelp.
 ELSE.
   MESSAGE 'INVALID QR CODE' TYPE 'E'.
ENDIF.

ENDFORM.

FORM gui_set USING p_extab TYPE slis_t_extab.
  SET  PF-STATUS 'ZUD'.
ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                            rs_selfield TYPE slis_selfield.
      DATA :lv_answer TYPE c,
            lv_ucomm(6)  TYPE c.
       lv_ucomm = r_ucomm.
   rs_selfield-refresh = 'X'.
  CALL FUNCTION 'HR_ALV_LIST_REFRESH'.

  CASE r_ucomm.
    WHEN 'SALL'.
      REFRESH it_log.
      PERFORM create_po.
         IF it_log IS NOT INITIAL.
           PERFORM messages.
        ENDIF.
    WHEN 'BACK'.
      LEAVE SCREEN .
    WHEN OTHERS.
  ENDCASE.

  rs_selfield-refresh = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_po .

 REFRESH: it_return, item[] , itemx[].

  READ TABLE it_final INTO DATA(wa_fin) INDEX 1.
   SELECT SINGLE
       lfa1~regio FROM lfa1 INTO  @DATA(ls_lfa1)
                                  WHERE lifnr = @wa_fin-lifnr.

  SELECT SINGLE
    ekko~ekgrp FROM ekko INTO @DATA(lv_ekgrp)
               WHERE ebeln =  @wa_fin-ebeln .

*  SELECT
*  a792~wkreg ,
*  a792~regio ,
*  a792~steuc ,
*  a792~knumh ,
*  marc~matnr ,
*  t001w~werks
*   FROM marc AS marc
*   INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
*   INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
*   INTO TABLE @DATA(it_hsn)
*   FOR ALL ENTRIES IN @it_final
*   WHERE marc~matnr = @it_final-matnr
*   AND a792~regio   = @ls_lfa1
*   AND t001w~werks  = @it_final-werks
*   AND   a792~datab LE @sy-datum
*   AND   a792~datbi GE @sy-datum.
*
*  IF it_hsn IS NOT INITIAL .
*    SELECT
*      konp~knumh ,
*      konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp)
*                 FOR ALL ENTRIES IN @it_hsn
*                 WHERE knumh = @it_hsn-knumh .
*  ENDIF .

  DATA : lv_doc TYPE esart .
  lv_doc = 'ZUB' .
  header_no_pp      = 'X'.
  header-comp_code  = '1000'.
  header-creat_date = sy-datum .
  header-vendor     = wa_fin-lifnr.
  header-doc_type   = lv_doc .
  header-langu      = sy-langu .
  header-currency   = 'INR'.
  header-purch_org  = '1000'.
  header-pur_group  = lv_ekgrp .
  header-suppl_plnt = wa_fin-werks .
  header-currency     = header-currency_iso  = 'INR'.
  header-our_ref      = p_mblnr.

  headerx-comp_code    = 'X'.
  headerx-creat_date   = 'X'.
  headerx-vendor       = 'X'.
  headerx-doc_type     = 'X' .
  headerx-langu        = 'X' .
  headerx-purch_org    = 'X' .
  headerx-pur_group    = 'X' .
  headerx-currency     = 'X'.
  headerx-suppl_plnt   = 'X'.
  headerx-currency     = headerx-currency_iso  = 'INR'.
  headerx-our_ref      = 'X'.


  DATA : lv_poitem TYPE ebelp.
 LOOP AT it_final ASSIGNING FIELD-SYMBOL(<ls_item>).
    lv_poitem = lv_poitem + 10.
    item-po_item = itemx-po_item = lv_poitem .
*    READ TABLE it_hsn ASSIGNING FIELD-SYMBOL(<ls_hsn1>) WITH KEY matnr = <ls_item>-matnr .
*    IF sy-subrc = 0.
*      READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<ls_konp1>) WITH KEY knumh = <ls_hsn1>-knumh .
*      IF sy-subrc = 0.
*        item-tax_code = <ls_konp1>-mwsk1.
*      ENDIF.
*    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_item>-matnr
      IMPORTING
        output = <ls_item>-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = item-po_item
      IMPORTING
        output = item-po_item.

          DATA(mat_len) = strlen( <ls_item>-matnr ) .
           IF mat_len > 18.
             item-material_long = <ls_item>-matnr.
             itemx-material_long    = 'X'.
           ELSE.
             item-material = <ls_item>-matnr.
             itemx-material    = 'X'.
           ENDIF.

    item-plant     = p_werks.
    item-quantity  = <ls_item>-menge.
*    item-batch     = <ls_item>-charg.
    item-stge_loc  = 'FG01'.
    item-po_unit   = <ls_item>-meins .
    item-gi_based_gr = 'X'.


    itemx-plant       = 'X'.
    itemx-quantity    = 'X'.
    itemx-po_unit     = 'X'.
*    itemx-batch       = 'X'.
    itemx-stge_loc    = 'X'.
*    itemx-tax_code    = 'X'.
    itemx-gi_based_gr = 'X'.

    APPEND item.
    APPEND itemx.

  ENDLOOP.
*  IF it_konp IS INITIAL .
*    MESSAGE 'There is No Tax Code' TYPE 'E'  .
*  ELSE .
    CLEAR lv_ebeln.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = header
        poheaderx        = headerx
       no_price_from_po = 'X'
      IMPORTING
        exppurchaseorder = lv_ebeln
      TABLES
        return           = it_return[]
        poitem           = item
        poitemx          = itemx.
*        pocond           = it_pocond
*        pocondx          = it_pocondx   .

  READ TABLE it_return[] ASSIGNING FIELD-SYMBOL(<ret>) WITH KEY type = 'E'.
   IF  sy-subrc <> '0'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
            APPEND VALUE #( type  = 'S'
                            id    = '001'
*                            txtnr =
                            msgv1 = lv_ebeln
                            msgv2  ='PO CREATED') TO it_log.

   ELSE .
     CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          LOOP AT it_return INTO lw_return WHERE type = 'E'.

            APPEND VALUE #( type  = lw_return-type
                            id    = lw_return-id
                            txtnr = lw_return-number
                            msgv1 = lw_return-message_v1
                            msgv2 = lw_return-message_v2 ) TO it_log.

          ENDLOOP.

   ENDIF.

*ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
    wa_events-name = 'USER_COMMAND'.
    wa_events-form = 'USER_COMMAND'.
    APPEND wa_events TO it_events.


  wa_fieldcat-fieldname = 'EBELN'.
  wa_fieldcat-seltext_m = 'PO Number'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'EBELP'.
  wa_fieldcat-seltext_m = 'PO Item'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-seltext_m = 'Vendor'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-seltext_m = 'Material'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_m = 'Plant'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'LGORT'.
  wa_fieldcat-seltext_m = 'St.Loc'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'CHARG'.
  wa_fieldcat-seltext_m = 'Batch'.
  APPEND wa_fieldcat TO it_fieldcat.



  wa_fieldcat-fieldname = 'MENGE'.
  wa_fieldcat-seltext_m = 'Quantity'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MEINS'.
  wa_fieldcat-seltext_m = 'UOM'.
  APPEND wa_fieldcat TO it_fieldcat.

CLEAR: wa_fieldcat , wa_events.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
   i_callback_program                  = sy-repid
   i_callback_pf_status_set            = 'GUI_SET'
   i_callback_user_command             = 'USER_COMMAND'
   i_callback_html_top_of_page         = 'TOP-OF-PAGE'
   is_layout                           = wa_layout
   it_fieldcat                         = it_fieldcat
   i_save                              = 'X'
   it_events                           = it_events
    TABLES
      t_outtab                         = it_final
    EXCEPTIONS
      program_error                    = 1
      OTHERS                           = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM messages .

CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.


    LOOP AT it_log ASSIGNING FIELD-SYMBOL(<log>).
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb = <log>-id
*         EXCEPTION_IF_NOT_ACTIVE       = 'X'
          msgty = <log>-type
          msgv1 = <log>-msgv1
          msgv2 = <log>-msgv2
          txtnr = <log>-txtnr
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDLOOP.
    CALL FUNCTION 'MESSAGES_STOP'
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'MESSAGES_SHOW'
      EXCEPTIONS
        inconsistent_range = 1
        no_messages        = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


ENDFORM.

FORM top-of-page USING top TYPE REF TO cl_dd_document.

*ALV Header declarations
  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c.

  DATA: lv_top   TYPE sdydo_text_element,
        lv_date  TYPE sdydo_text_element,
        sep      TYPE c VALUE ' ',
        dot      TYPE c VALUE '.',
        yyyy1    TYPE char4,
        mm1      TYPE char2,
        dd1      TYPE char2,
        date1    TYPE char10,
        yyyy2    TYPE char4,
        mm2      TYPE char2,
        dd2      TYPE char2,
        date2    TYPE char10,
        lv_name1 TYPE ad_name1,
        lv_name2 TYPE ad_name2,
        lv_adrnr TYPE adrnr.



  lv_top = 'STO PO'.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'HEADING'.

  CALL METHOD top->new_line.
  CALL METHOD top->new_line.
*
  lv_top = 'Date-'.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'SUBHEADING'.

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO lv_date SEPARATED BY '.'.
  lv_top = lv_date.

  CALL METHOD top->add_text
    EXPORTING
      text      = lv_top
      sap_style = 'SUBHEADING'.


ENDFORM.
