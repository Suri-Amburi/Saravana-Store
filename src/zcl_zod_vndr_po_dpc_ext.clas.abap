class ZCL_ZOD_VNDR_PO_DPC_EXT definition
  public
  inheriting from ZCL_ZOD_VNDR_PO_DPC
  create public .

public section.

  constants C_E type CHAR1 value 'E' ##NO_TEXT.
  constants C_EA type MEINS value 'EA' ##NO_TEXT.
  constants C_X type CHAR1 value 'X' ##NO_TEXT.
  constants C_ZLOP type BSART value 'ZLOP' ##NO_TEXT.
  constants C_ZOSP type BSART value 'ZOSP' ##NO_TEXT.
  constants C_ZVLO type BSART value 'ZVLO' ##NO_TEXT.
  constants C_ZVOS type BSART value 'ZVOS' ##NO_TEXT.

  methods CUSTOME_CREATE_DEEP_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
    exporting
      !ER_DEEP_ENTITY type ZCL_ZOD_VNDR_PO_MPC_EXT=>TS_PO_CREATE_H .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY
    redefinition .
protected section.

  methods CATIDSET_GET_ENTITYSET
    redefinition .
  methods GROUPF4SET_GET_ENTITY
    redefinition .
  methods GROUPF4SET_GET_ENTITYSET
    redefinition .
  methods MATERIALSET_GET_ENTITYSET
    redefinition .
  methods PLANTF4SET_GET_ENTITYSET
    redefinition .
  methods MATERIALSET_GET_ENTITY
    redefinition .
private section.

  types : BEGIN OF TS_DEEP_ENTITY ,
             PO_NUMBER     TYPE  EBELN,
             VENDOR        TYPE  LIFNR,
             DOC_TYPE      TYPE  ESART,
             DTYPE         TYPE  CHAR4,
             BUKRS         TYPE  BUKRS,
             AEDAT         TYPE  ZDATE_E,
*             LIFNR         TYPE  ELIFN,
             LANGU         TYPE  SPRAS,
             EKGRP         TYPE  BKGRP,
             EKORG         TYPE  EKORG,
*             AEDAT1        TYPE  ZDATE_E,
*             AD_NAME       TYPE  AD_NAME1,
*             TOTAL         TYPE  ZNETPR,
*             DEL_BY        TYPE  EINDT,
*             REF_PO        TYPE  EBELN,
*             BILL_TAT      TYPE  ZBILL_DAT,
*             ERNAME        TYPE  ERNAM,
*             INWD_DOC      TYPE  ZINWD_DOC,
*             TEXT          TYPE  CHAR20,
*             GSTINP        TYPE  STCD3,
*             BILL_TEXT     TYPE  CHAR20,
*             BILL_NUM      TYPE  ZBILL_NUM,
*             TOT_QTY       TYPE  ZBSTMG,
*             GROUP_ID      TYPE  WWGHA,
*             BSART         TYPE  ESART,
*             ZTRANNO       TYPE  ZTRANNO,
*             APPROVER2     TYPE  ZPPROVER2,
*             APPROVER2_DT  TYPE ZDATE_E,
*             USER_NAME     TYPE ZUNAM,
*             ITEMSET       TYPE TABLE OF ZCL_ZOD_VNDR_PO_MPC=>ts_po_create_i WITH DEFAULT KEY,
*             RESULTset     TYPE STANDARD TABLE OF ZCL_ZOD_VNDR_PO_MPC=>TS_RESULT WITH DEFAULT KEY,
           END OF TS_DEEP_ENTITY.
ENDCLASS.



CLASS ZCL_ZOD_VNDR_PO_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    DATA: ir_deep_entity  TYPE zcl_zod_vndr_po_mpc_ext=>ts_po_create_h.
    CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'PO_Create_HSet'.
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

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.


    TYPES: cx_mgw_busi_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    DATA: BEGIN OF ty_po_header_expand.
            INCLUDE TYPE zcl_zod_vndr_po_mpc_ext=>ts_po_header.
            DATA: headtoitemnav TYPE TABLE OF zcl_zod_vndr_po_mpc_ext=>ts_po_item,  "Use the name of navigation property
          END OF ty_po_header_expand.

    DATA: ls_po_header_expand LIKE ty_po_header_expand.

    DATA: lo_meco     TYPE REF TO /iwbep/if_message_container,
          lx_busi_exc TYPE cx_mgw_busi_exception,
          lt_return   TYPE STANDARD TABLE OF bapiret2.

    DATA: lv_compare_result  TYPE /iwbep/if_mgw_odata_expand=>ty_e_compare_result,
          lv_navigation      TYPE string,
          lv_expand          TYPE string,
          lt_navigation_path TYPE /iwbep/t_mgw_tech_navi.

    DATA: lt_children TYPE /iwbep/if_mgw_odata_expand=>ty_t_node_children,
          ls_children LIKE LINE OF lt_children.

    DATA: lo_navigation TYPE REF TO /iwbep/cl_mgw_expand_node.

    DATA: lt_keys    TYPE /iwbep/t_mgw_tech_pairs,
          ls_keys    TYPE /iwbep/s_mgw_tech_pair,
          ls_key_tab TYPE /iwbep/s_mgw_name_value_pair.

    DATA: lv_source TYPE bapimepoheader-po_number.

    DATA: ls_gr4po_header TYPE mmim_gr4po_dl_header,
          lt_gr4po_item   TYPE mmim_gr4po_dl_item_tt,
          ls_gr4po_item   TYPE mmim_gr4po_dl_item,
          lt_stocktype    TYPE STANDARD TABLE OF mmim_gr4po_dl_stocktype,
          ls_stocktype    TYPE mmim_gr4po_dl_stocktype.

    DATA: myobject TYPE REF TO if_mmim_gr4po_dl_bl.

    lt_navigation_path = io_tech_request_context->get_navigation_path( ).

* Get navigate property
    lt_children = io_expand->get_children( ).

    READ TABLE lt_children INTO ls_children
                           INDEX 1.
    IF sy-subrc = 0.
      lo_navigation ?= ls_children-node.
      lv_navigation = lo_navigation->get_nav_prop_name( ).
      lv_expand  = lo_navigation->get_expand( ).
    ELSE.
      RETURN.
    ENDIF.

    IF NOT lv_expand IS INITIAL.
      lv_navigation = 'HEADTOITEMNAV'.
    ENDIF.

* Check navigation property
    lv_compare_result = io_expand->compare_to( lv_navigation ).

    IF lv_compare_result EQ /iwbep/if_mgw_odata_expand=>gcs_compare_result-match_equals.
* Get Keys
      lt_keys = io_tech_request_context->get_keys( ).

* Get Purchasing Document
      READ TABLE lt_keys INTO ls_keys WITH KEY name = 'PURCHASEORDER'.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'CONVERSION_EXIT_ME_EN_INPUT'
          EXPORTING
            input  = ls_keys-value
          IMPORTING
            output = lv_source.
      ELSE.
        RETURN.
      ENDIF.

      CASE lv_navigation.
        WHEN 'HEADTOITEMNAV'.
          DATA : ls_po_item TYPE zcl_zod_vndr_po_mpc_ext=>ts_po_item.

          DATA : poheader TYPE bapimepoheader.
          DATA : poitem TYPE TABLE OF bapimepoitem.

          CALL FUNCTION 'BAPI_PO_GETDETAIL1'
            EXPORTING
              purchaseorder = lv_source "PO Number
            IMPORTING
              poheader      = poheader
            TABLES
              return        = lt_return
              poitem        = poitem.
      ENDCASE.

      IF sy-subrc EQ 0.
* Write data for output
        MOVE-CORRESPONDING poheader TO ls_po_header_expand.
        ls_po_header_expand-purchaseorder = lv_source.
        LOOP AT poitem INTO DATA(ls_poitem).
          MOVE-CORRESPONDING ls_poitem TO ls_po_item.
          APPEND ls_po_item TO ls_po_header_expand-headtoitemnav ."TO ls_po_header_expand-header2items.
          CLEAR: ls_poitem , ls_po_item.
        ENDLOOP.
        copy_data_to_ref(
             EXPORTING is_data = ls_po_header_expand
             CHANGING  cr_data = er_entity ).

      ELSE.
        copy_data_to_ref(
            EXPORTING is_data = ls_po_header_expand
            CHANGING  cr_data = er_entity ).

        lo_meco = mo_context->get_message_container( ).
        lo_meco->add_messages_from_bapi(
          it_bapi_messages = lt_return
          iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first
          iv_add_to_response_header = abap_true ).
      ENDIF.

* Set Expanded Clauses
      INSERT lv_navigation INTO TABLE et_expanded_tech_clauses.
    ENDIF.

  ENDMETHOD.


  method CATIDSET_GET_ENTITYSET.
    SELECT "matnr
           zzstyle
           zzcolor
           FROM mara INTO CORRESPONDING FIELDS OF TABLE et_entityset.

      sort et_entityset by zzstyle zzcolor.

      DELETE  ADJACENT DUPLICATES FROM et_entityset COMPARING zzstyle zzcolor.
  endmethod.


  METHOD custome_create_deep_entity.


    DATA: BEGIN OF ty_po_header_expand.
            INCLUDE TYPE zcl_zod_vndr_po_mpc_ext=>ts_po_create_h.
    DATA: itemset TYPE TABLE OF zcl_zod_vndr_po_mpc_ext=>ts_po_create_i,  "Use the name of navigation property
          END OF ty_po_header_expand.



    DATA:
      ir_deep_entity like ty_po_header_expand, " zcl_zod_vndr_po_mpc_ext=>ts_deep_entity,
      lt_error       TYPE TABLE OF zpo_status,
      lv_next_no     TYPE zpo_status-sno,
      lv_total       TYPE netwr,
*** BAPI Decleration
      im_header      TYPE  zpoheadertt,
      po_item         TYPE  STANDARD TABLE OF zpoitem,
      ls_po_item     TYPE  zpoitem,
      et_return      TYPE  bapiret2_tt,
      ebeln          TYPE  ebeln.
    FIELD-SYMBOLS:
      <ls_item>       TYPE      zcl_zod_vndr_po_mpc=>ts_po_create_i,
*      <ls_result>     TYPE      zcl_zod_vndr_po_mpc=>ts_result,
      <ls_rfc_result> TYPE bapiret2.

*** Transform INPUT REQUEST FROM ODATA-SERVICE into the internal structure
    io_data_provider->read_entry_data(
      IMPORTING
       es_data = ir_deep_entity ).

    CLEAR : lv_total.



*** Extract Item details from Entity 'Item' (tabulabr input fields)
    LOOP AT ir_deep_entity-itemset ASSIGNING <ls_item>.
      MOVE-CORRESPONDING <ls_item> TO ls_po_item.
      ls_po_item-ebelp  = <ls_item>-ebelp.
      ls_po_item-netpr  = <ls_item>-netpr.
      ls_po_item-matnr  = <ls_item>-matnr.
      ls_po_item-menge  = <ls_item>-menge.
      ls_po_item-meins  = <ls_item>-meins.
***   Additional Mandatory Data
      ls_po_item-werks  = <ls_item>-werks.
      ls_po_item-lgort  = 'FG01'.
      DATA(lv_matnr) = ls_po_item-matnr.
      APPEND ls_po_item TO po_item.
      CLEAR  ls_po_item.
      DATA(lv_net_amount) = <ls_item>-netpr * <ls_item>-menge .
      ADD  lv_net_amount TO lv_total .
    ENDLOOP.
    UNASSIGN : <ls_item>.

*** Purchage Group
*** Get Group Hierarchy
    SELECT SINGLE
          mara~matkl,
          mara~meins,
          kssk~clint,
          klah1~class
          INTO @DATA(ls_hdr)
          FROM klah AS klah
          INNER JOIN mara AS mara ON klah~class = mara~matkl
          INNER JOIN kssk AS kssk ON kssk~objek = klah~clint
          INNER JOIN klah AS klah1 ON klah1~clint = kssk~clint
          WHERE mara~matnr = @lv_matnr AND klah~klart = '026'.

    CASE ls_hdr-class.
      WHEN 'SAREE'.
        DATA(lv_grp) = 'P03'.
      WHEN 'LADIESREADYMADEN'.
        lv_grp = 'P04'.
      WHEN 'CHUDIMATERIAL'.
        lv_grp = 'P05'.
      WHEN 'GIRLSREADYMADE'.
        lv_grp = 'P06'.
      WHEN 'MENSREADYMADEN'.
        lv_grp = 'P07'.
      WHEN 'INNERWARE'.
        lv_grp = 'P08'.
      WHEN 'JUSTBORN'.
        lv_grp = 'P09'.
      WHEN 'RIDEONSANDCYCLES'.
        lv_grp = 'P10'.
      WHEN 'SILK'.
        lv_grp = 'P02'.
      WHEN 'BAGS'.
        lv_grp = 'P11'.
      WHEN 'TOYS'.
        lv_grp = 'P13'.
      WHEN 'IMITATION' .
        lv_grp = 'P15'.
      WHEN 'SPORTS'.
        lv_grp = 'P14'.
      WHEN 'GIFTSANDFLOWERS'.
        lv_grp = 'P12'.
      WHEN 'FOOTWARE'.
        lv_grp = 'P16'.
      WHEN 'MENSACCESSORIES'.
        lv_grp = 'P17'.
      WHEN 'COSMETICS'.
        lv_grp = 'P31'.
      WHEN 'MOBILES'.
        lv_grp = 'P21'.
      WHEN 'STATIONERY'.
        lv_grp = 'P33'.
      WHEN 'ELECTRONICS'.
        lv_grp = 'P22'.
      WHEN 'PROVISIONS'.
        lv_grp = 'P29'.
      WHEN 'SHIRTINGANDSUITING'.
        lv_grp = 'P19'.
      WHEN 'WATCHES'.
        lv_grp = 'P23'.
      WHEN 'OPTICALS'.
        lv_grp = 'P24'.
      WHEN 'BOYSREDYMADE'.
        lv_grp = 'P05'.
      WHEN 'VESSELS'.
        lv_grp = 'P03'.
    ENDCASE.

*** Extract Header details from Entity 'Header'
    APPEND VALUE #( potype = COND #( WHEN ir_deep_entity-potype = c_zlop AND ls_hdr-class = 'VESSELS' THEN c_zvlo
                                     WHEN ir_deep_entity-potype = c_zosp AND ls_hdr-class = 'VESSELS' THEN c_zvos
                                     ELSE ir_deep_entity-potype )
                    lifnr = ir_deep_entity-lifnr
                    ekorg = '1000' ekgrp = lv_grp bukrs = '1000' aedat = sy-datum
                    group_id = COND #( WHEN ls_hdr-meins = c_ea AND ls_hdr-class = 'VESSELS'
                                       THEN ls_hdr-class ELSE space ) ) TO im_header.

*** Calling SAP R3's RFC via RFC Destination
*** PO Creation Function Module
    CALL FUNCTION 'ZBAPI_PO_CREATE1' "DESTINATION 'NONE'
      EXPORTING
        im_header_tt = im_header       " Po Structure
      IMPORTING
        et_return    = et_return       " Return Parameter
        ebeln        = ebeln           " Purchasing Document Number
      TABLES
        po_item      = po_item.        " Item Data

    UNASSIGN : <ls_rfc_result>.
    IF ebeln IS NOT INITIAL.
***   Success : PO Created
      ir_deep_entity-ebeln = er_deep_entity-ebeln = ebeln.
      er_deep_entity-ekgrp    = ir_deep_entity-potype.
      er_deep_entity-lifnr   = ir_deep_entity-lifnr.
    ELSE.
*** Get Next Number
      CLEAR: lv_next_no.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZSLNO'
          quantity                = '00000000000000000001'
        IMPORTING
          number                  = lv_next_no
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*** EXPORTING OUTPUT TO ODATA ENTITYSET 'ResultSet'
      LOOP AT et_return ASSIGNING <ls_rfc_result> WHERE type = c_e.
***   Return output into Entity 'RESULT' via 'NavigationProperty=NAVRESULT'
*        APPEND VALUE #( MESSAGE = <LS_RFC_RESULT>-MESSAGE ID = <LS_RFC_RESULT>-ID ) to ER_DEEP_ENTITY-NAVRESULT.
*** UPDATING ERROR TABLE
        APPEND VALUE #( mandt      = sy-mandt
                        sno        = lv_next_no
                        aedat      = sy-datum
                        time       = sy-timlo
                        error_msg  = <ls_rfc_result>-message
                        lifnr      = sy-datum
                        name1      = sy-datum
                        group_id   = ls_hdr-class
                        ernam      = sy-uname
                        netwr      = lv_total  ) TO lt_error.
      ENDLOOP.
      MODIFY zpo_status FROM TABLE lt_error.
    ENDIF.
    COMMIT WORK.



  ENDMETHOD.


  METHOD groupf4set_get_entity.

    DATA : ls_key    TYPE /iwbep/s_mgw_name_value_pair,
           lv_source TYPE lifnr.

    READ TABLE it_key_tab WITH KEY name = 'VendorCode' INTO ls_key.
    IF sy-subrc = 0.
      lv_source = ls_key-value.
    ENDIF.

    lv_source = |{ lv_source  ALPHA = IN }|.

    SELECT a502~lifnr,
           a502~matnr,
           mara~matkl
           FROM mara AS mara INNER JOIN a502 AS a502 ON a502~matnr = mara~matnr
           INTO TABLE @DATA(lt_data) WHERE a502~lifnr = @lv_source.

    SELECT SINGLE  name1 FROM lfa1 INTO @DATA(lv_name) WHERE lifnr = @lv_source .

    READ TABLE lt_data ASSIGNING  FIELD-SYMBOL(<fs_data>) INDEX  1 .

*exporting  values
    IF <fs_data>  IS ASSIGNED .
      er_entity-lifnr = lv_source.
      er_entity-class = <fs_data>-matkl.
      er_entity-name1 = lv_name.
    ENDIF.
  ENDMETHOD.


  METHOD groupf4set_get_entityset.

    BREAK MUMAIR.
    SELECT klah~class
*         klah~clint
*         kssk~objek
         klah1~class AS matkl INTO CORRESPONDING FIELDS OF TABLE et_entityset
         FROM klah AS klah INNER JOIN kssk AS kssk ON kssk~clint = klah~clint
         INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
         WHERE klah~klart = '026' AND klah~wwskz = '0'. " AND kssk~MAFID = 'K'.

    SORT et_entityset BY class.
    DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING class.
  ENDMETHOD.


  METHOD materialset_get_entity.
    DATA : ls_key_tab TYPE /iwbep/s_mgw_name_value_pair.

    DATA : ls_lifnr TYPE lifnr.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'VendorCode'.
    IF sy-subrc = 0.
      ls_lifnr = ls_key_tab-value.

    ENDIF.

    SELECT SINGLE a502~lifnr,
           a502~matnr
          " mara~matkl
           FROM mara AS mara INNER JOIN a502 AS a502 ON a502~matnr = mara~matnr
           INTO CORRESPONDING FIELDS OF @er_entity WHERE a502~lifnr = @ls_lifnr.


  ENDMETHOD.


  METHOD materialset_get_entityset.
    DATA: ls_filter_options TYPE /iwbep/s_mgw_select_option,
          ls_select_option  TYPE /iwbep/s_cod_select_option,
          lv_source         TYPE lifnr.
* Read Plant

    READ TABLE it_filter_select_options INTO ls_filter_options
                                            WITH KEY property = 'VendorCode'.
    IF sy-subrc = 0.
      READ TABLE ls_filter_options-select_options INTO ls_select_option INDEX 1.
      IF ls_select_option-sign = 'I' AND ls_select_option-option = 'EQ'.
        lv_source = ls_select_option-low.
      ELSE.
        RETURN.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.

    lv_source = |{ lv_source  ALPHA = IN }|.


    SELECT a502~lifnr,
           a502~matnr
          " mara~matkl
           FROM mara AS mara INNER JOIN a502 AS a502 ON a502~matnr = mara~matnr
           INTO CORRESPONDING FIELDS OF TABLE @et_entityset WHERE a502~lifnr = @lv_source.


*    READ TABLE lt_data ASSIGNING  FIELD-SYMBOL(<fs_data>) INDEX  1 .

**exporting  values
*    IF <fs_data>  IS ASSIGNED .
**        er_entity-lifnr = lv_ebeln.
*      er_entity-class = <fs_data>-matkl.
**        er_entity-name1 = sy-datum.
*    ENDIF.
  ENDMETHOD.


  method PLANTF4SET_GET_ENTITYSET.
  select werks name1 from t001w INTO TABLE ET_ENTITYSET.
  endmethod.
ENDCLASS.
