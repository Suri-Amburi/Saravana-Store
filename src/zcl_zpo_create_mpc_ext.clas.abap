class zcl_zpo_create_mpc_ext definition
  public
  inheriting from zcl_zpo_create_mpc
  create public .

  public section.

    types:
      begin of ts_ekposet,
        ebeln type ebeln,
        ebelp type ebelp,
        matnr type matnr,
      end of ts_ekposet .
    types:
      begin of ts_navreturn,
        type    type bapi_mtype,
        message type bapi_msg,
      end of ts_navreturn .
    types:
      begin of ts_deep_entity,
        ebeln     type string,
        lifnr     type string,
        t_ekposet type standard table of ts_ekposet with default key,
        navreturn type standard table of ts_navreturn with default key,
      end of ts_deep_entity .

    methods define
        redefinition .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_ZPO_CREATE_MPC_EXT IMPLEMENTATION.


  method define.

    data:lo_annotation   type ref to /iwbep/if_mgw_odata_annotation,
         lo_entity_type  type ref to /iwbep/if_mgw_odata_entity_typ,
         lo_complex_type type ref to /iwbep/if_mgw_odata_cmplx_type,
         lo_property     type ref to /iwbep/if_mgw_odata_property,
         lo_entity_set   type ref to /iwbep/if_mgw_odata_entity_set.

    super->define( ).
    lo_entity_type = model->get_entity_type( iv_entity_name = 'Header' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZPO_CREATE_MPC_EXT=>TS_DEEP_ENTITY' ).
  endmethod.
ENDCLASS.
