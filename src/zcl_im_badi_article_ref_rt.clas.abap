class ZCL_IM_BADI_ARTICLE_REF_RT definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BADI_ARTICLE_REF_RT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BADI_ARTICLE_REF_RT IMPLEMENTATION.


  method IF_EX_BADI_ARTICLE_REF_RT~ADD_INACTIVE_FIELDS.
*    BREAK breddy.
  endmethod.


  method IF_EX_BADI_ARTICLE_REF_RT~IMPORT_AT_UPDATE_TASK.
*    break breddy.
  endmethod.


  method IF_EX_BADI_ARTICLE_REF_RT~REFERENZ.

  endmethod.


  method IF_EX_BADI_ARTICLE_REF_RT~REFERENZ_AFTER.
  endmethod.


  method IF_EX_BADI_ARTICLE_REF_RT~REFERENZ_BEFORE.
  endmethod.


  method IF_EX_BADI_ARTICLE_REF_RT~TRANSPORT_TO_UPDATE_TASK.
*    BREAK breddy.
  endmethod.
ENDCLASS.
