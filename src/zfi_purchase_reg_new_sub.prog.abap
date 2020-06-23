*&---------------------------------------------------------------------*
*& Include          ZFI_PURCHASE_REG_NEW_SUB
*&---------------------------------------------------------------------*
IF gst_db1 IS INITIAL.
  PERFORM get_data4.
  PERFORM mov_fin4.
  PERFORM disply_data4.
  ENDIF.

  IF gst_db1 = 'X'.
  PERFORM get_data5.
  PERFORM mov_fin5.
  PERFORM disply_data5.
    ENDIF.
