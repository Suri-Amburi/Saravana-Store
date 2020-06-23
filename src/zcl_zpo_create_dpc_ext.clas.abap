class ZCL_ZPO_CREATE_DPC_EXT definition
  public
  inheriting from ZCL_ZPO_CREATE_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CUSTOME_CREATE_DEEP_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
    exporting
      !ER_DEEP_ENTITY type ZCL_ZPO_CREATE_MPC_EXT=>TS_DEEP_ENTITY
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
private section.
ENDCLASS.



CLASS ZCL_ZPO_CREATE_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
    DATA: IR_DEEP_ENTITY  TYPE ZCL_ZPO_CREATE_MPC_EXT=>TS_DEEP_ENTITY.
CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
WHEN 'T_EKKOSet'.

CALL METHOD me->custome_create_deep_entity
  EXPORTING
    IV_ENTITY_NAME          = iv_entity_name
    IV_ENTITY_SET_NAME      = iv_entity_set_name
    IV_SOURCE_NAME          = iv_source_name
    IT_KEY_TAB              = it_key_tab
    IT_NAVIGATION_PATH      = it_navigation_path
    IO_EXPAND               = IO_EXPAND
    IO_TECH_REQUEST_CONTEXT = io_tech_request_context
    IO_DATA_PROVIDER        = io_data_provider
IMPORTING
    ER_DEEP_ENTITY          = IR_DEEP_ENTITY
.

copy_data_to_ref(
EXPORTING
 is_data = IR_DEEP_ENTITY
CHANGING
 cr_data = er_deep_entity
).

ENDCASE.

**try.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
*    IO_EXPAND               =
**    io_tech_request_context =
**  importing
**    er_deep_entity          =
*    .
** catch /iwbep/cx_mgw_busi_exception .
** catch /iwbep/cx_mgw_tech_exception .
**endtry.
  endmethod.


  method CUSTOME_CREATE_DEEP_ENTITY.
  endmethod.
ENDCLASS.
