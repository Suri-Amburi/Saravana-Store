class ZCL_ZGW_PO_CREATE01_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_PO_CREATE01_DPC
  create public .

public section.

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
      !ER_DEEP_ENTITY type ZCL_ZGW_PO_CREATE01_MPC_EXT=>TS_DEEP_ENTITY .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZGW_PO_CREATE01_DPC_EXT IMPLEMENTATION.


  METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    IV_ENTITY_NAME          =
**    IV_ENTITY_SET_NAME      =
**    IV_SOURCE_NAME          =
*    IO_DATA_PROVIDER        =
**    IT_KEY_TAB              =
**    IT_NAVIGATION_PATH      =
*    IO_EXPAND               =
**    IO_TECH_REQUEST_CONTEXT =
**  IMPORTING
**    ER_DEEP_ENTITY          =
*    .
** CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
** CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
**ENDTRY.


    DATA: IR_DEEP_ENTITY  TYPE ZCL_ZGW_PO_CREATE01_MPC_EXT=>TS_DEEP_ENTITY.
    CASE IV_ENTITY_SET_NAME.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'HeaderSet'.
        CALL METHOD ME->CUSTOME_CREATE_DEEP_ENTITY
          EXPORTING
            IV_ENTITY_NAME          = IV_ENTITY_NAME
            IV_ENTITY_SET_NAME      = IV_ENTITY_SET_NAME
            IV_SOURCE_NAME          = IV_SOURCE_NAME
            IT_KEY_TAB              = IT_KEY_TAB
            IT_NAVIGATION_PATH      = IT_NAVIGATION_PATH
            IO_EXPAND               = IO_EXPAND
            IO_TECH_REQUEST_CONTEXT = IO_TECH_REQUEST_CONTEXT
            IO_DATA_PROVIDER        = IO_DATA_PROVIDER
          IMPORTING
            ER_DEEP_ENTITY          = IR_DEEP_ENTITY.

        COPY_DATA_TO_REF(
        EXPORTING
         IS_DATA = IR_DEEP_ENTITY
        CHANGING
         CR_DATA = ER_DEEP_ENTITY
        ).
    ENDCASE.
  ENDMETHOD.


  METHOD CUSTOME_CREATE_DEEP_ENTITY.
    DATA:
      IR_DEEP_ENTITY TYPE ZCL_ZGW_PO_CREATE01_MPC_EXT=>TS_DEEP_ENTITY,
      LS_RESULTSET   TYPE ZCL_ZGW_PO_CREATE01_MPC_EXT=>TS_RESULT,
      LS_ERROR       TYPE ZPO_STATUS,
      LT_ERROR       TYPE TABLE OF ZPO_STATUS,
      LV_NEXT_NO     TYPE ZPO_STATUS-SNO,
      LV_TOTAL       TYPE NETWR,
*** BAPI Decleration
      IM_HEADER      TYPE  ZPOHEADERTT,
      PO_ITEM	       TYPE  STANDARD TABLE OF ZPOITEM,
      LS_PO_ITEM     TYPE  ZPOITEM,
      ET_RETURN      TYPE  BAPIRET2_TT,
      EBELN          TYPE  EBELN.
    FIELD-SYMBOLS:
      <LS_ITEM>   TYPE ZCL_ZGW_PO_CREATE01_MPC_EXT=>TS_ITEM,
      <LS_RESULT> TYPE ZCL_ZGW_PO_CREATE01_MPC_EXT=>TS_RESULT.

*** Transform INPUT REQUEST FROM ODATA-SERVICE into the internal structure
    IO_DATA_PROVIDER->READ_ENTRY_DATA(
      IMPORTING
       ES_DATA = IR_DEEP_ENTITY ).

    CLEAR : LV_TOTAL.
*** Extract Item details from Entity 'Item' (tabulabr input fields)
    LOOP AT IR_DEEP_ENTITY-ITEMSET ASSIGNING <LS_ITEM>.
      LS_PO_ITEM-EBELP  = <LS_ITEM>-PO_ITEM.
      LS_PO_ITEM-NETPR  = <LS_ITEM>-NET_PRICE.
      LS_PO_ITEM-MATNR  = <LS_ITEM>-MATERIAL.
      DATA(LV_MATNR) = LS_PO_ITEM-MATNR.
      LS_PO_ITEM-MENGE  = <LS_ITEM>-QUANTITY.
      LS_PO_ITEM-MEINS  = <LS_ITEM>-PO_UNIT.
***   Additional Mandatory Data
      LS_PO_ITEM-WERKS  = 'SSWH'.
      LS_PO_ITEM-LGORT  = 'FG01'.
      APPEND LS_PO_ITEM TO PO_ITEM.
      CLEAR  LS_PO_ITEM.
      DATA(LV_NET_AMOUNT) = <LS_ITEM>-NET_PRICE * <LS_ITEM>-QUANTITY .
      ADD  LV_NET_AMOUNT TO LV_TOTAL .
    ENDLOOP.
    UNASSIGN : <LS_ITEM>.

*** Purchage Group
*** Get Group Hierarchy
    SELECT SINGLE
          MARA~MATKL,
          KSSK~CLINT,
          KLAH1~CLASS
          INTO @DATA(LS_HDR)
          FROM KLAH AS KLAH
          INNER JOIN MARA AS MARA ON KLAH~CLASS = MARA~MATKL
          INNER JOIN KSSK AS KSSK ON KSSK~OBJEK = KLAH~CLINT
          INNER JOIN KLAH AS KLAH1 ON KLAH1~CLINT = KSSK~CLINT
          WHERE MARA~MATNR = @LV_MATNR AND KLAH~KLART = '026'.

*** SAREE	- P01
*** LADIESREADYMADEN - P03
*** CHUDIMATERIAL	   - P04
*** BOYSREDYMADE     - P05
*** GIRLSREADYMADE   - P06
*** MENSREADYMADEN   - P07
*** INNERWARE	       - P08
*** JUSTBORN         - P09
*** RIDEONSANDCYCLES - P10
*** SILK             - P02
*** BAGS             - P11
*** TOYS             - P13
*** IMITATION	       - P15
*** SPORTS           - P14
*** MENSACCESSORIES	 - P17
*** FOOTWARE         - P16
*** GIFTSANDFLOWERS	 - P12
*** COSMETICS	       - P31
*** MOBILES	         - P21
*** STATIONERY  P33
*** ELECTRONICS	P22
*** PROVISIONS  P29
*** SHIRTINGANDSUITING  P19
*** WATCHES	P23
*** OPTICALS  P24


    CASE LS_HDR-CLASS.
      WHEN 'SAREE'.
        DATA(LV_GRP) = 'P03'.
      WHEN 'LADIESREADYMADEN'.
        LV_GRP = 'P04'.
      WHEN 'CHUDIMATERIAL'.
        LV_GRP = 'P05'.
      WHEN 'GIRLSREADYMADE'.
        LV_GRP = 'P06'.
      WHEN 'MENSREADYMADEN'.
        LV_GRP = 'P07'.
      WHEN 'INNERWARE'.
        LV_GRP = 'P08'.
      WHEN 'JUSTBORN'.
        LV_GRP = 'P09'.
      WHEN 'RIDEONSANDCYCLES'.
        LV_GRP = 'P10'.
      WHEN 'SILK'.
        LV_GRP = 'P02'.
      WHEN 'BAGS'.
        LV_GRP = 'P11'.
      WHEN 'TOYS'.
        LV_GRP = 'P13'.
      WHEN 'IMITATION' .
        LV_GRP = 'P15'.
      WHEN 'SPORTS'.
        LV_GRP = 'P14'.
      WHEN 'GIFTSANDFLOWERS'.
        LV_GRP = 'P12'.
      WHEN 'FOOTWARE'.
        LV_GRP = 'P16'.
      WHEN 'MENSACCESSORIES'.
        LV_GRP = 'P17'.
      WHEN 'COSMETICS'.
        LV_GRP = 'P31'.
      WHEN 'MOBILES'.
        LV_GRP = 'P21'.
      WHEN 'STATIONERY'.
        LV_GRP = 'P33'.
      WHEN 'ELECTRONICS'.
        LV_GRP = 'P22'.
      WHEN 'PROVISIONS'.
        LV_GRP = 'P29'.
      WHEN 'SHIRTINGANDSUITING'.
        LV_GRP = 'P19'.
      WHEN 'WATCHES'.
        LV_GRP = 'P23'.
      WHEN 'OPTICALS'.
        LV_GRP = 'P24'.
            WHEN 'BOYSREDYMADE'.
        LV_GRP = 'P05'.
    ENDCASE.

*** Extract Header details from Entity 'Header'
    APPEND VALUE #( POTYPE = IR_DEEP_ENTITY-DTYPE LIFNR = IR_DEEP_ENTITY-VENDOR
                    EKORG = '1000' EKGRP = LV_GRP BUKRS = '1000' AEDAT = SY-DATUM ZDAYS = 5 ) TO IM_HEADER.

*** Calling SAP R3's RFC via RFCDestination
    CALL FUNCTION 'ZBAPI_PO_CREATE1' "DESTINATION 'NONE'
      EXPORTING
        IM_HEADER_TT = IM_HEADER       " Po Structure
      IMPORTING
        ET_RETURN    = ET_RETURN       " Return Parameter
        EBELN        = EBELN           " Purchasing Document Number
      TABLES
        PO_ITEM      = PO_ITEM.        " Item Data

*    UNASSIGN : <LS_RFC_RESULT>.
    IF EBELN IS NOT INITIAL.
***   Success
      IR_DEEP_ENTITY-PONUMBER = ER_DEEP_ENTITY-PONUMBER = EBELN.
      ER_DEEP_ENTITY-DTYPE  = IR_DEEP_ENTITY-DTYPE.
      ER_DEEP_ENTITY-VENDOR   = IR_DEEP_ENTITY-VENDOR.
    ELSE.
*** Get Next Number
      CLEAR: LV_NEXT_NO.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR             = '01'
          OBJECT                  = 'ZSLNO'
          QUANTITY                = '00000000000000000001'
        IMPORTING
          NUMBER                  = LV_NEXT_NO
        EXCEPTIONS
          INTERVAL_NOT_FOUND      = 1
          NUMBER_RANGE_NOT_INTERN = 2
          OBJECT_NOT_FOUND        = 3
          QUANTITY_IS_0           = 4
          QUANTITY_IS_NOT_1       = 5
          INTERVAL_OVERFLOW       = 6
          BUFFER_OVERFLOW         = 7
          OTHERS                  = 8.

*** EXPORTING OUTPUT TO ODATA ENTITYSET 'ResultSet'
      LOOP AT ET_RETURN ASSIGNING FIELD-SYMBOL(<LS_RFC_RESULT>) WHERE TYPE = 'E'.
***   Return output into Entity 'RESULT' via 'NavigationProperty=NAVRESULT'
        LS_RESULTSET-MESSAGE = <LS_RFC_RESULT>-MESSAGE.
        LS_RESULTSET-ID      = <LS_RFC_RESULT>-ID.
        APPEND LS_RESULTSET TO ER_DEEP_ENTITY-NAVRESULT.
        CLEAR LS_RESULTSET.
        IF SY-SUBRC = 0.
*** UPDATING ERROR TABLE
          APPEND VALUE #( MANDT      = SY-MANDT
                          SNO        = LV_NEXT_NO
                          AEDAT      = SY-DATUM
                          TIME       = SY-TIMLO
                          ERROR_MSG  = <LS_RFC_RESULT>-MESSAGE
                          LIFNR      = SY-DATUM
                          NAME1      = SY-DATUM
                          GROUP_ID   = LS_HDR-CLASS
                          ERNAM      = SY-UNAME
                          NETWR      = LV_TOTAL  ) TO LT_ERROR.
        ENDIF.
      ENDLOOP.
      MODIFY ZPO_STATUS FROM TABLE LT_ERROR.
    ENDIF.
    COMMIT WORK.
  ENDMETHOD.
ENDCLASS.
