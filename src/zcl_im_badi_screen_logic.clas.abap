class ZCL_IM_BADI_SCREEN_LOGIC definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BADI_SCREEN_LOGIC_RT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BADI_SCREEN_LOGIC IMPLEMENTATION.


  method IF_EX_BADI_SCREEN_LOGIC_RT~AREA_OF_VALIDITY_DIRECT.
  endmethod.


  method IF_EX_BADI_SCREEN_LOGIC_RT~CHANGE_SCREEN_SEQUENCE.
  endmethod.


  method IF_EX_BADI_SCREEN_LOGIC_RT~REDUCE_SCREEN_SELECTION.
*    BREAK breddy.
  endmethod.
ENDCLASS.
