*&---------------------------------------------------------------------*
*& Include          SAPMZHUCREATE_RF_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GLOBAL_VARIABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM global_variables .
CLEAR: lv_charg, lv_werks,gv_icon_9999, gv_icon_name,gv_text, lv_count, wa_final, wa_fin, wa_final, lv_matnr, lv_sbatch.
REFRESH: it_final, it_fin.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM close .
 CLEAR lw_head.
  IF rad1 = 'X'.
    lw_head-pack_mat = c_tray.   "PACKING MATERIAL
  ELSEIF rad2 = 'X'.
    lw_head-pack_mat = c_bundle.
  ENDIF.

    lw_head-plant         = lv_werks.
    lw_head-stge_loc      = 'FG01'.

*****************HU ITEM DATA>>>>>>>>>>
SORT it_final BY matnr charg.
DATA(it_final1) = it_final.
DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING matnr charg.
LOOP AT it_final1 ASSIGNING FIELD-SYMBOL(<fin>).
  LOOP AT it_final ASSIGNING FIELD-SYMBOL(<fin1>) WHERE matnr = <fin>-matnr AND charg = <fin>-charg.
    wa_fin-matnr = <fin1>-matnr.
    wa_fin-charg = <fin1>-charg.
    wa_fin-menge =  wa_fin-menge + <fin1>-menge.
    CLEAR: <fin1>.
  ENDLOOP.
      APPEND wa_fin TO it_fin.
      CLEAR wa_fin.
ENDLOOP.

  REFRESH: li_itemp, li_ret1.
  CLEAR: lw_itemp.
 LOOP AT it_fin INTO wa_fin.
    lw_itemp-hu_item_type = 1.
    lw_itemp-pack_qty     = wa_fin-menge.
    lw_itemp-base_unit_qty = 'EA'.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = wa_fin-matnr
      IMPORTING
        output = wa_fin-matnr.
    lw_itemp-material      = wa_fin-matnr.
    lw_itemp-batch         = wa_fin-charg.
    lw_itemp-plant         = lv_werks.
    lw_itemp-stge_loc      = 'FG01'.

    APPEND lw_itemp TO li_itemp.
    CLEAR: lw_itemp, wa_fin.
ENDLOOP.

    CALL FUNCTION 'BAPI_HU_CREATE'
      EXPORTING
        headerproposal = lw_head
      IMPORTING
        hukey          = lv_exidv
      TABLES
        itemsproposal  = li_itemp
*       ITEMSSERIALNO  =
        return         = li_ret1.
*
    IF lv_exidv IS NOT INITIAL.
      REFRESH: it_final, it_final1, it_fin, li_itemp, li_ret1.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
            CLEAR gw_mess.
            gw_mess-err   = 'S'.
            gw_mess-mess1 = lv_exidv.
            gw_mess-mess2 = 'HU'.
            gw_mess-mess3 = 'CREATED'.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.


    ELSE.
      CLEAR lv_exidv.
      READ TABLE li_ret1 ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = <ls_ret>-message_v1.
            gw_mess-mess2 = <ls_ret>-message_v2.
            gw_mess-mess3 = <ls_ret>-message_v3.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.

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

  IF lv_charg IS NOT INITIAL.

  ENDIF.

ENDFORM.
