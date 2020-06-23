*&---------------------------------------------------------------------*
*& Include          SAPMZGRPO_I01
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
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'PRINT'.
      PERFORM print_form.
    WHEN 'SAVE'.
      PERFORM post.
    WHEN 'REFRESH'.
     CLEAR: gw_mblnr,gw_ebeln, gw_item1, gw_item2,gw_budat.
     REFRESH : gt_item1, gt_item2, gt_item3, gt_stpo, gt_stpo1.
     CALL METHOD grid1->refresh_table_display.
     CALL METHOD grid2->refresh_table_display.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE check_chain INPUT.

IF gw_budat IS INITIAL.
  lv_cursor = 'GW_BUDAT'.
  SET CURSOR FIELD lv_cursor.
  MESSAGE 'Enter Posting Date' TYPE 'E'.
ENDIF.

IF gw_mblnr IS INITIAL.
  lv_cursor = 'GW_MBLNR'.
  SET CURSOR FIELD lv_cursor.
  MESSAGE 'Enter GR PO Number' TYPE 'E'.

ELSEIF gw_mblnr IS NOT INITIAL.

 SELECT a~matnr
        b~maktx
        a~charg
        c~clabs AS menge
        c~clabs AS omenge
        a~meins  INTO CORRESPONDING FIELDS OF TABLE gt_item1 FROM matdoc AS a INNER JOIN makt AS b
                 ON ( a~matnr = b~matnr AND spras = sy-langu ) INNER JOIN mchb AS c
                 ON ( a~matnr = c~matnr AND a~charg = c~charg )
                                                          WHERE a~mblnr = gw_mblnr
                                                          AND   a~bwart IN ( '101' , '109' )
                                                          AND   a~xauto <> 'X'
                                                          AND   a~record_type = 'MDOC'.
     IF gt_item1 IS INITIAL.
      lv_cursor = 'GW_MBLNR'.
      SET CURSOR FIELD lv_cursor.
      MESSAGE 'Inavalid GR PO Number' TYPE 'E'.
     ELSE.
       CALL METHOD grid1->refresh_table_display.
    ENDIF.
ENDIF.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN 'CONT' OR 'EXIT'.
      CLEAR sy-ucomm.
      SET SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_EBELN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ebeln INPUT.

SELECT ebeln,aedat,ernam FROM ekko INTO TABLE @DATA(it_ekko) WHERE unsez = @gw_mblnr.

CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EBELN'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GE_EBELN'
      value_org       = 'S'
    TABLES
      value_tab       = it_ekko
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EBELN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ebeln INPUT.

 IF gw_ebeln IS NOT INITIAL.
    SUBMIT zmm_contract_po  WITH p_ebeln = gw_ebeln AND RETURN.
 ENDIF.

ENDMODULE.
