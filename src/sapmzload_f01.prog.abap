*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save .

  DATA: lw_head TYPE bapi2017_gm_head_01,
        lw_item TYPE bapi2017_gm_item_create,
        li_item TYPE STANDARD TABLE OF bapi2017_gm_item_create,
        lw_code TYPE bapi2017_gm_code,
        li_ret  TYPE STANDARD TABLE OF bapiret2,
        lw_ret  TYPE bapiret2,
        lw_vekp TYPE ty_vekp.

  CONSTANTS: c_01   TYPE char2 VALUE '01',
             c_fg01 TYPE char4 VALUE 'FG01',
             c_101  TYPE char3 VALUE '101',
             c_b    TYPE char1 VALUE 'B'.

  IF gi_temp IS NOT INITIAL.

    SELECT *
      FROM vepo
      INTO TABLE gi_vepo
      FOR ALL ENTRIES IN gi_temp
      WHERE venum = gi_temp-venum.

    IF gi_vepo IS NOT INITIAL.

      SELECT tknum
             tpnum
             vbeln FROM vttp INTO TABLE it_vttp FOR ALL ENTRIES IN gi_vepo
             WHERE vbeln = gi_vepo-vbeln.
    ENDIF.
    IF it_vttp IS NOT INITIAL.

      SELECT vbeln
             posnr
             vgbel
             vgpos
             matnr
             lfimg
             werks
             charg
             meins
             pstyv
        FROM lips
        INTO TABLE gi_lips
        FOR ALL ENTRIES IN it_vttp
        WHERE vbeln = it_vttp-vbeln.
    ENDIF.
  ENDIF.



  IF gi_lips IS NOT INITIAL.
    SELECT
      vbeln
      kunnr FROM likp INTO TABLE it_likp
            FOR ALL ENTRIES IN gi_lips
           WHERE vbeln = gi_lips-vbeln.
  ENDIF.

  IF gi_lips IS NOT INITIAL.
***    Fill Header for BAPI

    lw_head-pstng_date = sy-datum.
    lw_head-doc_date = sy-datum.
    lw_head-ref_doc_no = gv_vbeln.
    lw_head-ref_doc_no_long = gv_vbeln.

***    Fill Goods Movement Code

    lw_code-gm_code = c_01.

    gi_lips1[] = gi_lips[].
    SORT gi_lips1 BY vbeln posnr.
    DELETE gi_lips1 WHERE pstyv NE 'NLN'.
*    LOOP AT gi_lips1 INTO gw_lips1.
*      LOOP AT gi_lips INTO gw_lips WHERE vbeln = gw_lips1-vbeln AND matnr = gw_lips1-matnr AND pstyv NE 'NLN'.
     CLEAR: wa_final.
    LOOP AT it_fin3 INTO wa_final.
      READ TABLE gi_lips INTO gw_lips WITH KEY charg = wa_final-charg  .
       IF sy-subrc = 0.
        lw_item-po_number       =     gw_lips-vgbel.
        lw_item-po_item         =     gw_lips-vgpos.
        READ TABLE it_likp INTO gw_likp WITH KEY vbeln = gw_lips-vbeln.
        IF sy-subrc = 0.
          lw_item-plant         =   gw_likp-kunnr.
        ENDIF.
        ""GW_VEPO-WERKS.
        lw_item-stge_loc          =     c_fg01.
        lw_item-batch             =     gw_lips-charg.
        lw_item-val_type          =     gw_lips-charg.
        lw_item-move_type         =     c_101.
*        lw_item-entry_qnt         =     gw_lips-lfimg.
        lw_item-entry_qnt         =     wa_final-menge.
        lw_item-entry_uom         =     gw_lips-meins.
*        lw_item-ref_doc           =     gw_lips-vbeln.
*        lw_item-ref_doc_it        =     gw_lips-posnr.
*      lw_item-entry_uom_iso     =     gw_vepo-vemeh.
*      lw_item-po_pr_qnt         =     gw_vepo-vemng.
*      lw_item-orderpr_un        =     gw_vepo-vemeh.
*      lw_item-orderpr_un_iso    =     gw_vepo-vemeh.
*      READ TABLE GI_LIPS INTO GW_LIPS WITH KEY VBELN = GW_VEPO-VBELN
*                                               POSNR = GW_VEPO-POSNR.
*      IF SY-SUBRC = 0.
*        LW_ITEM-PO_NUMBER       =     GW_LIPS-VGBEL.
*        LW_ITEM-PO_ITEM         =     GW_LIPS-VGPOS.
*      ENDIF.
        lw_item-mvt_ind           =     c_b.
        lw_item-deliv_numb        =     gw_lips-vbeln.
        lw_item-deliv_item        =     gw_lips-posnr.
        lw_item-quantity          =     gw_lips-lfimg.
        lw_item-base_uom          =     gw_lips-meins.
        lw_item-material_long     =     gw_lips-matnr.
*        lw_item-line_id           =     '00001'.

        APPEND lw_item TO li_item.
        CLEAR lw_item.
        ENDIF.
      ENDLOOP.
*    ENDLOOP.

 BREAK snahak.

    IF lw_head IS NOT INITIAL AND li_item IS NOT INITIAL.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = lw_head
          goodsmvt_code    = lw_code
*         TESTRUN          = ' '
*         GOODSMVT_REF_EWM =
*         GOODSMVT_PRINT_CTRL           =
        IMPORTING
*         GOODSMVT_HEADRET =
          materialdocument = gv_matdoc
*         matdocumentyear  =
        TABLES
          goodsmvt_item    = li_item
*         GOODSMVT_SERIALNUMBER         =
          return           = li_ret
*         GOODSMVT_SERV_PART_DATA       =
*         EXTENSIONIN      =
*         GOODSMVT_ITEM_CWM             =
        .

      IF gv_matdoc IS NOT INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        LOOP AT gi_vekp INTO lw_vekp WHERE exidv = gv_exidv.
          UPDATE vekp SET zzmblnr = gv_matdoc
                          zzdate = sy-datum
                          zztime = sy-uzeit
                          WHERE venum = lw_vekp-venum .
        ENDLOOP.

        CLEAR gw_mess.
        gw_mess-err = 'S'.
        gw_mess-mess1 = ' Unloading '.
        gw_mess-mess2 = ' Complete !! '.
        gw_mess-mess2 = gv_matdoc.
        SET SCREEN 0.
        CALL SCREEN '9999'.
        EXIT.
      ELSE.
        READ TABLE li_ret INTO lw_ret WITH KEY type = 'E'.
        IF sy-subrc = 0.
          CLEAR gw_mess.
          gw_mess-err = 'E'.
          gw_mess-mess1 = lw_ret-message+0(20).
          gw_mess-mess2 = lw_ret-message+21(20).
          gw_mess-mess3 = lw_ret-message+41(20).
          gw_mess-mess4 = lw_ret-message+61(20).
          gw_mess-mess5 = lw_ret-message+81(20).

          SET SCREEN 0.
          CALL SCREEN '9999'.
          EXIT.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM enter .

  IF gv_exidv IS NOT INITIAL.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GLOBAL_VARIABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM global_variables .

  CLEAR: gv_ebeln, gv_exidv,gv_icon_9999,gv_icon_name,gv_matdoc,gv_pen,gv_scn,gv_text,
         gv_tot, gv_vbeln, gv_veh,gv_total,gv_rem, gv_totno, gv_x , gv_totqty.

  CLEAR: gi_lips, gi_temp, gi_vekp, gi_vepo , it_vepo , it_final .

  CLEAR: gw_lips, gw_mess, gw_vepo.

ENDFORM.

*  IF GI_TEMP IS NOT INITIAL.
*
*    SELECT *
*      FROM VEPO
*      INTO TABLE GI_VEPO
*      FOR ALL ENTRIES IN GI_TEMP
*      WHERE VENUM = GI_TEMP-VENUM.
*
*    IF GI_VEPO IS NOT INITIAL.
*
*      SELECT TKNUM
*             TPNUM
*             VBELN FROM VTTP INTO TABLE IT_VTTP FOR ALL ENTRIES IN GI_VEPO
*             WHERE VBELN = GI_VEPO-VBELN.
*    ENDIF.
*    IF IT_VTTP IS NOT INITIAL.
*
*      SELECT VBELN
*             POSNR
*             VGBEL
*             VGPOS
*             MATNR
*             LFIMG
*             WERKS
*             CHARG
*             MEINS
*             PSTYV
*        FROM LIPS
*        INTO TABLE GI_LIPS
*        FOR ALL ENTRIES IN IT_VTTP
*        WHERE VBELN = IT_VTTP-VBELN.
*    ENDIF.
*  ENDIF.
