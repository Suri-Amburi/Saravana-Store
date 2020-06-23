class ZCL_GW_VENDOR_PO_CREATE definition
  public
  final
  create public .

public section.

  methods HEADER_VALIDATE
    importing
      !I_HEADER type ZGW_PO_H_V
    exporting
      !ET_RETUEN type BAPIRET2_T .
  methods ITEM_VALIDATE
    importing
      !I_ITEM type ZGW_PO_I_V_T
    exporting
      !ET_RETUEN type BAPIRET2_T .
  methods FILL_MESSAGES
    importing
      !I_MESSAGES type BAPIRET2
    exporting
      !ET_RETURN type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GW_VENDOR_PO_CREATE IMPLEMENTATION.


  METHOD FILL_MESSAGES.
    CHECK I_MESSAGES IS NOT INITIAL.
    APPEND I_MESSAGES TO ET_RETURN.
  ENDMETHOD.


  METHOD HEADER_VALIDATE.
    CHECK I_HEADER IS NOT INITIAL.

  ENDMETHOD.


  METHOD ITEM_VALIDATE.
*    FIELD-SYMBOLS :
*     <LS_ITEM> TYPE ZGW_PO_I_V_T.

    DATA(LT_ITEM) = I_ITEM.
    CHECK LT_ITEM IS NOT INITIAL.
    LOOP AT I_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
