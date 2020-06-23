*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_I01
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


IF lv_werks IS INITIAL.
  lv_cursor = 'LV_WERKS'.
  SET CURSOR FIELD lv_cursor.
  MESSAGE 'Enter Store' TYPE 'E'.

ELSEIF lv_werks IS NOT INITIAL.
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

    APPEND wa_item TO it_item.
    CLEAR  wa_item.

   ENDLOOP.

ENDIF.
ENDMODULE.
