CLASS zcl_zgw_vndr_po_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zgw_vndr_po_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

*  types TS_TOPURCHASEORDERITEM .
    TYPES: BEGIN OF ts_purchaseorderitemset,
             vendor      TYPE lifnr,
             category_no TYPE matkl,
             style       TYPE zstyle,
             color       TYPE zcolor,
             quantity    TYPE menge_d,
             rate        TYPE bwert,
             size_i      TYPE char100,
             remarks     TYPE zremarks,

           END OF ts_purchaseorderitemset.

    TYPES: BEGIN OF ts_topurchaseorderitem,
             type    TYPE bapi_mtype,
             message TYPE bapi_msg,

           END OF ts_topurchaseorderitem.

    TYPES: BEGIN OF ts_deep_entity,
             vendor              TYPE string,

             purchaseorderitem   TYPE STANDARD TABLE OF ts_purchaseorderitem WITH DEFAULT KEY,   "PoOrderITEM
             topurchaseorderitem TYPE STANDARD TABLE OF ts_topurchaseorderitem WITH DEFAULT KEY, "Navigation
           END OF ts_deep_entity.
    METHODS define
        REDEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZGW_VNDR_PO_MPC_EXT IMPLEMENTATION.


  METHOD define.
    DATA:lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
         lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
         lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
         lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
         lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.

    super->define( ).
*    CATCH /iwbep/cx_mgw_med_exception.
    lo_entity_type = model->get_entity_type( iv_entity_name = 'PurchaseOrder'  ).
*                     CATCH /iwbep/cx_mgw_med_exception. " Meta data exception
*                     CATCH /iwbep/cx_mgw_med_exception. " Meta data exception
*    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZPO_CREATE_MPC_EXT=>TS_DEEP_ENTITY' ).
    lo_entity_type->bind_structure( iv_structure_name   = 'ZCL_ZGW_VNDR_PO_MPC_EXT=>TS_DEEP_ENTITY'  ).
*    CATCH /iwbep/cx_mgw_med_exception. " Meta data exception
*    CATCH /iwbep/cx_mgw_med_exception. " Meta data exception

  ENDMETHOD.
ENDCLASS.
