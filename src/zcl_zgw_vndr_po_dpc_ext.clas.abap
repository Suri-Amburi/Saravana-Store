class ZCL_ZGW_VNDR_PO_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_VNDR_PO_DPC
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
      !ER_DEEP_ENTITY type ZCL_ZGW_VNDR_PO_MPC_EXT=>TS_DEEP_ENTITY .

  methods PURCHASEORDERITE_GET_ENTITYSET
    redefinition .
  methods PURCHASEORDERSET_GET_ENTITY
    redefinition .
  methods PURCHASEORDERSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_VNDR_PO_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ir_deep_entity  TYPE zcl_zgw_vndr_po_mpc_ext=>ts_deep_entity.
*
**--------------------------------------------------------------------*
*    "When EntitySet 'HeaderSet' has been invoke via service URI
**--------------------------------------------------------------------*
CASE iv_entity_set_name.
  WHEN 'PurchaseOrderSet'.

    CALL METHOD me->custome_create_deep_entity
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        it_navigation_path      = it_navigation_path
        io_expand               = io_expand
        io_tech_request_context = io_tech_request_context
        io_data_provider        = io_data_provider
      IMPORTING
        er_deep_entity          = ir_deep_entity.



    copy_data_to_ref(
    EXPORTING
     is_data = ir_deep_entity
    CHANGING
     cr_data = er_deep_entity
    ).

ENDCASE.
*
***TRY.
**CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
**  EXPORTING
***    iv_entity_name          =
***    iv_entity_set_name      =
***    iv_source_name          =
**    IO_DATA_PROVIDER        =
***    it_key_tab              =
***    it_navigation_path      =
**    IO_EXPAND               =
***    io_tech_request_context =
***  IMPORTING
***    er_deep_entity          =
**    .
*** CATCH /iwbep/cx_mgw_busi_exception .
*** CATCH /iwbep/cx_mgw_tech_exception .
***ENDTRY.
*
*
*
**ENDMETHOD.
ENDMETHOD.


  method CUSTOME_CREATE_DEEP_ENTITY.

  endmethod.


  method PURCHASEORDERITE_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->PURCHASEORDERITE_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  METHOD purchaseorderset_get_entity.

**    DATA: LS_KEY_TAB LIKE LINE OF IT_KEY_TAB.
*    READ TABLE IT_KEY_TAB INTO DATA(LS_KEY_TAB) WITH KEY NAME = 'Vendor'.
*    ER_ENTITY-vendor = LS_KEY_TAB-value.

  ENDMETHOD.


  method PURCHASEORDERSET_GET_ENTITYSET.
*    DATA: ls_data LIKE LINE OF ZGW_VNDR_PO_H.



*---->>> ( GET HIERARCHY GROUP ) mumair <<< 29.09.2019 01:59:36
*BREAK mumair.
*   SELECT KLAH~CLASS
*          KLAH~CLINT
*          KSSK~OBJEK
*          KSSK~MAFID
*          KLAH1~CLASS AS MATKL
*          FROM KLAH AS KLAH INNER JOIN KSSK AS KSSK ON KSSK~CLINT = KLAH~CLINT
*          INNER JOIN KLAH AS KLAH1 ON KSSK~OBJEK = KLAH1~CLINT
*          INTO CORRESPONDING FIELDS OF TABLE ET_ENTITYSET WHERE KSSK~MAFID = 'K'.


















  endmethod.
ENDCLASS.
