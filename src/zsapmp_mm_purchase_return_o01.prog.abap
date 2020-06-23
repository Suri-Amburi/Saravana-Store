*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'STATUS'.
  SET TITLEBAR 'TITLE'.
  IF LV_EBELN IS NOT INITIAL AND GV_MBLNR_N IS NOT INITIAL.

*    LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT.
*    APPEND LS_EXCLUDE TO LT_EXCLUDE.
    SET PF-STATUS 'STATUS' EXCLUDING 'SAVE' .

  ENDIF.


*  PERFORM get_data .
ENDMODULE.
