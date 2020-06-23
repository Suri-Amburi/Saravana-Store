class ZCL_ZGW_PO_CREATE_MPC_EXT definition
  public
  inheriting from ZCL_ZGW_PO_CREATE_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZGW_PO_CREATE_MPC_EXT IMPLEMENTATION.


  METHOD DEFINE.
    DATA:
      LO_ANNOTATION   TYPE REF TO /IWBEP/IF_MGW_ODATA_ANNOTATION,
      LO_ENTITY_TYPE  TYPE REF TO /IWBEP/IF_MGW_ODATA_ENTITY_TYP,
      LO_COMPLEX_TYPE TYPE REF TO /IWBEP/IF_MGW_ODATA_CMPLX_TYPE,
      LO_PROPERTY     TYPE REF TO /IWBEP/IF_MGW_ODATA_PROPERTY,
      LO_ENTITY_SET   TYPE REF TO /IWBEP/IF_MGW_ODATA_ENTITY_SET.

    SUPER->DEFINE( ).
    LO_ENTITY_TYPE = MODEL->GET_ENTITY_TYPE( IV_ENTITY_NAME = 'Header' ).
    LO_ENTITY_TYPE->BIND_STRUCTURE( IV_STRUCTURE_NAME  = 'ZCL_ZGW_PO_CREATE_MPC_EXT=>TS_DEEP_ENTITY' ).
  ENDMETHOD.
ENDCLASS.
