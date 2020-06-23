*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_NEW_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

CASE ok_code.
  WHEN 'BACK'.
    LEAVE PROGRAM.
  WHEN 'CANCEL'.
    LEAVE PROGRAM.
  WHEN 'EXIT'.
    LEAVE PROGRAM.
  WHEN 'SAVE'.
DATA:lv_ans TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Warning!!'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Please check all data properly before saving!!!'
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

CHECK lv_ans = '1'.
    PERFORM save_data.
  WHEN OTHERS.

ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_chain INPUT.
DATA: lv_cursor TYPE char50.

IF lv_werks IS NOT INITIAL AND IT_ITEM IS INITIAL.
   SELECT * FROM zincentive INTO TABLE @DATA(it_ince) WHERE werks = @lv_werks AND del_ind <> 'X'.

   LOOP AT it_ince ASSIGNING FIELD-SYMBOL(<fs>).

     wa_item-ccode     = <fs>-matkl.
     wa_item-sstcode   = <fs>-matnr.
     wa_item-sstdesc   = <fs>-maktx.
     wa_item-batch     = <fs>-charg.
     wa_item-brand     = <fs>-brand.
     wa_item-group     = <fs>-group1.
     wa_item-lifnr     = <fs>-lifnr.
     wa_item-pernr     = <fs>-pernr.
     wa_item-name      = <fs>-name.
     wa_item-datef     = <fs>-datef.
     wa_item-datet     = <fs>-datet.
     wa_item-mon       = <fs>-monday.
     wa_item-tue       = <fs>-tuesday.
     wa_item-wed       = <fs>-wednesday.
     wa_item-thu       = <fs>-thursday.
     wa_item-fri       = <fs>-friday.
     wa_item-sat       = <fs>-saturday.
     wa_item-sun       = <fs>-sunday.
     wa_item-tarpc     = <fs>-tar_pc.
     wa_item-tarval    = <fs>-tar_val.
     wa_item-incepc    = <fs>-ince_pc.
     wa_item-inceval   = <fs>-ince_val.
     wa_item-docno     = <fs>-docno.

    APPEND wa_item TO it_item.
    CLEAR  wa_item.

   ENDLOOP.

ENDIF.
 CALL METHOD grid->refresh_table_display.
ENDMODULE.
