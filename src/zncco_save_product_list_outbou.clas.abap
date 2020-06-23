class ZNCCO_SAVE_PRODUCT_LIST_OUTBOU definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods SAVE_PRODUCT_LIST_OUTBOUND
    importing
      !OUTPUT type ZNCSAVE_PRODUCT_LIST
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZNCCO_SAVE_PRODUCT_LIST_OUTBOU IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZNCCO_SAVE_PRODUCT_LIST_OUTBOU'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method SAVE_PRODUCT_LIST_OUTBOUND.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SAVE_PRODUCT_LIST_OUTBOUND'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
