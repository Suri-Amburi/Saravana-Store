*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_PO_CREATE1_O01

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
**  BREAK-POINT.
*   SORT IT_ITEM ASCENDING by sl_no .
  SET PF-STATUS 'PO_STATUS'.
  SET TITLEBAR 'PO_TITLE'.

  IF CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT CUSTOM_CONTAINER
      EXPORTING
*       PARENT         =     " Parent container
        CONTAINER_NAME = MYCONTAINER. " Name of the Screen CustCtrl Name to Link Container To

    CREATE OBJECT GRID
      EXPORTING
        I_PARENT = CUSTOM_CONTAINER. " Parent Container

  ENDIF.
  PERFORM FIELD_CATALOG .

  IF G_VERIFIER IS NOT BOUND.
    CREATE OBJECT G_VERIFIER.
  ENDIF.
  IF G_VERIFIER1 IS NOT BOUND.
    CREATE OBJECT G_VERIFIER1.
  ENDIF.
*  BREAK-POINT.
*  IF it_item is NOT INITIAL.
*   LOOP AT it_item into wa_item where matnr is NOT INITIAL .
*   IF wa_item-menge is INITIAL.
*    SET CURSOR FIELD 'MENGE' .
*      MESSAGE 'Enter Quantity' TYPE 'E' .
*   else.
*        SET HANDLER :
*   G_VERIFIER1->HANDLE_DATA_CHANGED FOR GRID.
*   ENDIF.
*
*   ENDLOOP.
*  else.
    SET HANDLER :
   G_VERIFIER1->HANDLE_DATA_CHANGED FOR GRID.
*  ENDIF.


  SET HANDLER  G_VERIFIER->ON_F4 FOR GRID.


*register the field for which custom f4h is required
  READ TABLE GT_F4  WITH KEY FIELDNAME = 'MATNR' .
  IF SY-SUBRC <> 0.
    GT_F4-FIELDNAME = 'MATNR'.
    GT_F4-REGISTER = 'X'.
*    GS_F4-GETBEFORE = SPACE.
*    GS_F4-CHNGEAFTER = SPACE.
    INSERT TABLE GT_F4.
  ENDIF.
*     INSERT TABLE gt_f4 .

  READ TABLE GT_F4  WITH KEY FIELDNAME = 'MATKL' .
  IF SY-SUBRC <> 0.
    GT_F4-FIELDNAME = 'MATKL'.
    GT_F4-REGISTER = 'X'.
*    GS_F4-GETBEFORE = SPACE.
*    GS_F4-CHNGEAFTER = SPACE.
    INSERT TABLE GT_F4.
  ENDIF.

  CALL METHOD GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4[] .


*  LOOP AT it_item into wa_item where matnr is NOT INITIAL.
*    IF wa_item-menge is INITIAL.
*      SET CURSOR FIELD 'MENGE' .
*      MESSAGE 'Enter Quantity' TYPE 'E' .
*    ENDIF.
*ENDLOOP.






  PERFORM GET_DATA.


  IF WA_HEADER-AEDAT IS INITIAL.
    WA_HEADER-AEDAT  = SY-DATUM.
  ENDIF.
  IF WA_HEADER-LGORT IS INITIAL.
    WA_HEADER-LGORT  = 'FG01'.
  ENDIF.

* PERFORM clear .
*  CLEAR : WA_HEADER-SITE , WA_HEADER-LIFNR .
**  PERFORM fill_container .
*
** PERFORM EXCLUDE_ICONS.
*
** PERFORM DISPLAY_DATA.
*
* wa_header-site = ' '.
* wa_header-lifnr = ' '.
*



ENDMODULE.
