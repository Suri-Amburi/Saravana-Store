class ZCL_ZGW_PO_CREATE_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_PO_CREATE_DPC
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
      !ER_DEEP_ENTITY type ZCL_ZGW_PO_CREATE_MPC=>TS_DEEP_ENTITY .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZGW_PO_CREATE_DPC_EXT IMPLEMENTATION.


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
*    BREAK SAMBURI.
*    TYPES : TY_PO_ITEM TYPE STANDARD TABLE OF ZCL_ZGW_PO_CREATE_MPC=>TS_PO_ITEM WITH DEFAULT KEY.
**** Represents full structure - header with one or more items
*    TYPES:
*      BEGIN OF TY_PO.
*        INCLUDE TYPE ZCL_ZGW_PO_CREATE_MPC=>TS_PO_HDR.
*        TYPES: ITEMS TYPE TY_PO_ITEM,
*      END OF TY_PO.
*
*    DATA:
*      LS_PO             TYPE TY_PO,
*      LV_COMPARE_RESULT TYPE /IWBEP/IF_MGW_ODATA_EXPAND=>TY_E_COMPARE_RESULT,
*      LV_ITEM           TYPE EBELP VALUE '00010',
*      LS_MESSAGE        TYPE SCX_T100KEY.
*
**** PO Creation Data
*    DATA:
*      GV_EBELN TYPE EBELN,
*      HEADER   TYPE BAPIMEPOHEADER,
*      HEADERX  TYPE BAPIMEPOHEADERX,
*      ITEM     TYPE TABLE OF BAPIMEPOITEM,
*      ITEMX    TYPE TABLE OF BAPIMEPOITEMX,
*      LS_ITEM  TYPE BAPIMEPOITEM,
*      LS_ITEMX TYPE BAPIMEPOITEMX,
*      RETURN   TYPE TABLE OF BAPIRET2.
**** Constants
*    CONSTANTS:
*      C_ITEMS TYPE STRING VALUE 'Items',
*      C_X(1)  VALUE 'X'.
*
**** VALIDATE WHETHER THE CURRENT REQUEST INCLUDING THE INLINE SO ITEM DATA MATCHES
*    LV_COMPARE_RESULT = IO_EXPAND->COMPARE_TO( C_ITEMS ).
*
**** Upon match, access data from IO_DATA_PROVIDER
*    IF LV_COMPARE_RESULT EQ /IWBEP/IF_MGW_ODATA_EXPAND=>GCS_COMPARE_RESULT-MATCH_EQUALS.
*      IO_DATA_PROVIDER->READ_ENTRY_DATA( IMPORTING ES_DATA = LS_PO ).
*
****   Move header PO data into BAPI structure
*      HEADER-COMP_CODE    = '1000'.
*      HEADER-CREAT_DATE   = SY-DATUM.
*      HEADER-VENDOR       = LS_PO-LIFNR.
*      HEADER-DOC_TYPE     = LS_PO-BSART.
*      HEADER-LANGU        = SY-LANGU.
*      HEADER-PURCH_ORG    = '1000'.
*      HEADER-PUR_GROUP    = 'P03'.
*
*      HEADERX-COMP_CODE   = C_X.
*      HEADERX-CREAT_DATE  = C_X.
*      HEADERX-VENDOR      = C_X.
*      HEADERX-DOC_TYPE    = C_X.
*      HEADERX-LANGU       = C_X.
*      HEADERX-PURCH_ORG   = C_X.
*      HEADERX-PUR_GROUP   = C_X.
*
*      REFRESH: ITEM , ITEMX.
****   Move PO line items into BAPI table structure
*      LOOP AT LS_PO-ITEMS ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
*        LS_ITEM-PO_ITEM   = LV_ITEM.
*        LS_ITEM-MATERIAL  = <LS_ITEM>-MATNR.
*        LS_ITEM-PLANT     = 'SSCP'.
*        LS_ITEM-QUANTITY  = <LS_ITEM>-MENGE.
*        LS_ITEM-PO_UNIT   = <LS_ITEM>-MEINS.
*        LS_ITEM-NET_PRICE = <LS_ITEM>-NETPR.
*        LS_ITEM-STGE_LOC  = 'FG01'.
*        LS_ITEM-TAX_CODE  = '1C'.
*
*        LS_ITEMX-PO_ITEM     = LV_ITEM.
*        LS_ITEMX-MATERIAL    = C_X.
*        LS_ITEMX-PLANT       = C_X.
*        LS_ITEMX-QUANTITY    = C_X.
*        LS_ITEMX-PO_UNIT     = C_X.
*        LS_ITEMX-NET_PRICE   = C_X.
*        LS_ITEMX-STGE_LOC    = C_X.
*        LS_ITEMX-TAX_CODE    = C_X.
*
*        APPEND LS_ITEM TO ITEM.
*        APPEND LS_ITEMX TO ITEMX.
*        CLEAR : LS_ITEMX , LS_ITEM.
*        LV_ITEM = LV_ITEM + 10.
*      ENDLOOP.
*
**** PO Creation
*      CALL FUNCTION 'BAPI_PO_CREATE1'
*        EXPORTING
*          POHEADER         = HEADER
*          POHEADERX        = HEADERX
*        IMPORTING
*          EXPPURCHASEORDER = GV_EBELN
*        TABLES
*          RETURN           = RETURN
*          POITEM           = ITEM
*          POITEMX          = ITEMX.
*
*      READ TABLE RETURN ASSIGNING FIELD-SYMBOL(<LS_RET>) WITH KEY TYPE = 'E'.
*      IF SY-SUBRC <> 0.
****     Commit Work
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = C_X.
*      ELSE.
****     Roll Back
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*        LS_MESSAGE-MSGID = <LS_RET>-ID.
*        LS_MESSAGE-MSGID = <LS_RET>-NUMBER.
*        LS_MESSAGE-ATTR1 = <LS_RET>-MESSAGE.
*        LS_MESSAGE-ATTR2 = <LS_RET>-MESSAGE_V2.
*        LS_MESSAGE-ATTR3 = <LS_RET>-MESSAGE_V3.
*        LS_MESSAGE-ATTR4 = <LS_RET>-MESSAGE_V4.
****     Rise Exception
*        RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
*          EXPORTING
*            TEXTID = LS_MESSAGE.
*      ENDIF.
*
*      COPY_DATA_TO_REF(
*      EXPORTING
*        IS_DATA = LS_PO
*      CHANGING
*        CR_DATA = ER_DEEP_ENTITY ).
*    ENDIF.

    DATA: IR_DEEP_ENTITY  TYPE ZCL_ZGW_PO_CREATE_MPC=>TS_DEEP_ENTITY.
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
*** TC : Suri
*** Perpous : To Create PO from Fiori
    DATA:
      IR_DEEP_ENTITY TYPE ZCL_ZGW_PO_CREATE_MPC_EXT=>TS_DEEP_ENTITY,
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
      <LS_ITEM>       TYPE ZCL_ZGW_PO_CREATE_MPC_EXT=>TS_ITEM,
      <LS_RESULT>     TYPE ZCL_ZGW_PO_CREATE_MPC_EXT=>TS_RESULT,
      <LS_RFC_RESULT> TYPE BAPIRET2.

*** Transform INPUT REQUEST FROM ODATA-SERVICE into the internal structure
    IO_DATA_PROVIDER->READ_ENTRY_DATA(
      IMPORTING
       ES_DATA = IR_DEEP_ENTITY ).

    CLEAR : LV_TOTAL.



*** Extract Item details from Entity 'Item' (tabulabr input fields)
    LOOP AT IR_DEEP_ENTITY-ITEMSET ASSIGNING <LS_ITEM>.
      MOVE-CORRESPONDING <LS_ITEM> TO LS_PO_ITEM.
      LS_PO_ITEM-EBELP  = <LS_ITEM>-PO_ITEM.
      LS_PO_ITEM-NETPR  = <LS_ITEM>-NET_PRICE.
      LS_PO_ITEM-MATNR  = <LS_ITEM>-MATERIAL.
      LS_PO_ITEM-MENGE  = <LS_ITEM>-QUANTITY.
      LS_PO_ITEM-MEINS  = <LS_ITEM>-PO_UNIT.
***   Additional Mandatory Data
      LS_PO_ITEM-WERKS  = <LS_ITEM>-PLANT.
      LS_PO_ITEM-LGORT  = 'FG01'.
      DATA(LV_MATNR) = LS_PO_ITEM-MATNR.
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
          MARA~MEINS,
          KSSK~CLINT,
          KLAH1~CLASS
          INTO @DATA(LS_HDR)
          FROM KLAH AS KLAH
          INNER JOIN MARA AS MARA ON KLAH~CLASS = MARA~MATKL
          INNER JOIN KSSK AS KSSK ON KSSK~OBJEK = KLAH~CLINT
          INNER JOIN KLAH AS KLAH1 ON KLAH1~CLINT = KSSK~CLINT
          WHERE MARA~MATNR = @LV_MATNR AND KLAH~KLART = '026'.

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
      WHEN 'VESSELS'.
        LV_GRP = 'P03'.
    ENDCASE.

*** Extract Header details from Entity 'Header'
    APPEND VALUE #( POTYPE = COND #( WHEN IR_DEEP_ENTITY-DTYPE = C_ZLOP AND LS_HDR-CLASS = 'VESSELS' THEN C_ZVLO
                                     WHEN IR_DEEP_ENTITY-DTYPE = C_ZOSP AND LS_HDR-CLASS = 'VESSELS' THEN C_ZVOS
                                     ELSE IR_DEEP_ENTITY-DTYPE )
                    LIFNR = IR_DEEP_ENTITY-VENDOR
                    EKORG = '1000' EKGRP = LV_GRP BUKRS = '1000' AEDAT = SY-DATUM
                    GROUP_ID = COND #( WHEN LS_HDR-MEINS = C_EA AND LS_HDR-CLASS = 'VESSELS'
                                       THEN LS_HDR-CLASS ELSE SPACE ) ) TO IM_HEADER.

*** Calling SAP R3's RFC via RFC Destination
*** PO Creation Function Module
    CALL FUNCTION 'ZBAPI_PO_CREATE1' "DESTINATION 'NONE'
      EXPORTING
        IM_HEADER_TT = IM_HEADER       " Po Structure
      IMPORTING
        ET_RETURN    = ET_RETURN       " Return Parameter
        EBELN        = EBELN           " Purchasing Document Number
      TABLES
        PO_ITEM      = PO_ITEM.        " Item Data

    UNASSIGN : <LS_RFC_RESULT>.
    IF EBELN IS NOT INITIAL.
***   Success : PO Created
      IR_DEEP_ENTITY-PO_NUMBER = ER_DEEP_ENTITY-PO_NUMBER = EBELN.
      ER_DEEP_ENTITY-DTYPE    = IR_DEEP_ENTITY-DTYPE.
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
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

*** EXPORTING OUTPUT TO ODATA ENTITYSET 'ResultSet'
      LOOP AT ET_RETURN ASSIGNING <LS_RFC_RESULT> WHERE TYPE = C_E.
***   Return output into Entity 'RESULT' via 'NavigationProperty=NAVRESULT'
*        APPEND VALUE #( MESSAGE = <LS_RFC_RESULT>-MESSAGE ID = <LS_RFC_RESULT>-ID ) to ER_DEEP_ENTITY-NAVRESULT.
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
      ENDLOOP.
***   Saving Error PO's in ZPO_STATUS for Reporting
      MODIFY ZPO_STATUS FROM TABLE LT_ERROR.
    ENDIF.
    COMMIT WORK.



  ENDMETHOD.
ENDCLASS.
