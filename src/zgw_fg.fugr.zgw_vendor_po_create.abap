FUNCTION ZGW_VENDOR_PO_CREATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_HEADER) LIKE  ZGW_PO_H_V STRUCTURE  ZGW_PO_H_V
*"  TABLES
*"      I_ITEM STRUCTURE  ZGW_PO_I_V
*"      E_RETURN TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  CHECK I_ITEM IS NOT INITIAL AND I_HEADER IS NOT INITIAL.

ENDFUNCTION.
