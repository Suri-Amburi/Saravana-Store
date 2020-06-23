*&---------------------------------------------------------------------*
*& Report ZFM_PO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfm_po.
TABLES : ekko.

DATA : sebeln TYPE ebeln .  "Purchase Document No.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : lv_ebeln FOR ekko-ebeln NO INTERVALS .
PARAMETERS : reg_po RADIOBUTTON GROUP g1.
PARAMETERS : p_ret RADIOBUTTON GROUP g1.
PARAMETERS : tatkal RADIOBUTTON GROUP g1.
PARAMETERS : prev RADIOBUTTON GROUP g1.
PARAMETERS : serpo RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK a1.

CHECK lv_ebeln IS NOT INITIAL.

LOOP AT lv_ebeln .
  sebeln = lv_ebeln-low.

  CALL FUNCTION 'ZFM_PURCHASE_FORM1'
    EXPORTING
      lv_ebeln       = sebeln
      reg_po         = reg_po
      return_po      = p_ret
      tatkal_po      = tatkal
      print_prieview = prev
      service_po     = serpo.
  .
ENDLOOP.

MESSAGE 'Email Triggred Sucessfully' TYPE 'S'.
