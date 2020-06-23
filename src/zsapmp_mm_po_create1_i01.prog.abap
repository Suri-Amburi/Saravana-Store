*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_PO_CREATE1_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.


*  SORT IT_ITEM ASCENDING BY SL_NO .
  CALL METHOD GRID->REFRESH_TABLE_DISPLAY.

  PERFORM GET_ADDR .



  OK_CODE = SY-UCOMM .
  CASE OK_CODE .

    WHEN 'SAVE'.
*      PERFORM VALIDATION .
*      BREAK-POINT.
      DELETE it_item WHERE sl_no is NOT INITIAL AND MATNR IS INITIAL .
      DATA : LV_QTYM(100) TYPE C .
      IF IT_ITEM IS NOT INITIAL AND WA_HEADER-AEDAT1 IS NOT INITIAL AND WA_HEADER-EKGRP IS NOT INITIAL AND WA_HEADER-SITE IS NOT INITIAL AND WA_HEADER-LGORT IS NOT INITIAL ..
        LOOP AT IT_ITEM INTO WA_ITEM .
          IF wa_item-MENGE IS INITIAL AND wa_item-MATNR IS NOT INITIAL .
             CONCATENATE 'Enter Quantity for material ' WA_ITEM-MATNR INTO LV_QTYM SEPARATED BY ' '.
             MESSAGE LV_QTYM TYPE 'E' DISPLAY LIKE 'I' .
          ELSEIF wa_item-MAKTX IS NOT INITIAL and wa_item-MATNR is INITIAL.
             CONCATENATE 'Enter material for item ' WA_ITEM-sl_no INTO LV_QTYM SEPARATED BY ' '.
             MESSAGE LV_QTYM TYPE 'E' DISPLAY LIKE 'I' .
          ENDIF.
          clear lv_qtym.
        ENDLOOP.
*        PERFORM validation .
        PERFORM BAPI .
      ELSEIF WA_HEADER-AEDAT1 IS NOT INITIAL AND WA_HEADER-EKGRP IS NOT INITIAL AND WA_HEADER-SITE IS NOT INITIAL AND WA_HEADER-LGORT IS NOT INITIAL .
        MESSAGE 'No items to Create Purchase Order' TYPE 'I' DISPLAY LIKE 'E' .
*      else .
*         PERFORM validation .
      ENDIF.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0 .
      CLEAR WA_HEADER.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0 .
      CLEAR WA_HEADER.

    WHEN OTHERS.
  ENDCASE.
  CLEAR OK_CODE .



ENDMODULE.
