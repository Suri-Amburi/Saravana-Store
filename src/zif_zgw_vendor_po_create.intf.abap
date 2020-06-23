interface ZIF_ZGW_VENDOR_PO_CREATE
  public .


  types:
    ZIND_NUM type C length 000010 .
  types:
    EBELN type C length 000010 .
  types:
    LIFNR type C length 000010 .
  types:
    ZTRAN_NO type C length 000020 .
  types:
    WWGHA type C length 000040 .
  types:
    ESART type C length 000004 .
  types:
    WERKS_D type C length 000004 .
  types:
    ZAGENT type C length 000030 .
  types:
    ZDATE_E type C length 000010 .
  types:
    ORT01 type C length 000025 .
  types:
    AENAM type C length 000012 .
  types:
    begin of ZGW_PO_H_V,
      INDENT_NUMBER type ZIND_NUM,
      PO_NUMBER type EBELN,
      LIFNR type LIFNR,
      ZTRANNO type ZTRAN_NO,
      GROUP_ID type WWGHA,
      DOC_TYPE type ESART,
      PLANT type WERKS_D,
      ZAGENT type ZAGENT,
      ZERDAT type ZDATE_E,
      CITY type ORT01,
      USER_NAME type AENAM,
    end of ZGW_PO_H_V .
  types:
    BAPI_MTYPE type C length 000001 .
  types:
    SYMSGID type C length 000020 .
  types:
    SYMSGNO type N length 000003 .
  types:
    BAPI_MSG type C length 000220 .
  types:
    BALOGNR type C length 000020 .
  types:
    BALMNR type N length 000006 .
  types:
    SYMSGV type C length 000050 .
  types:
    BAPI_PARAM type C length 000032 .
  types:
    BAPI_FLD type C length 000030 .
  types:
    BAPILOGSYS type C length 000010 .
  types:
    begin of BAPIRET2,
      TYPE type BAPI_MTYPE,
      ID type SYMSGID,
      NUMBER type SYMSGNO,
      MESSAGE type BAPI_MSG,
      LOG_NO type BALOGNR,
      LOG_MSG_NO type BALMNR,
      MESSAGE_V1 type SYMSGV,
      MESSAGE_V2 type SYMSGV,
      MESSAGE_V3 type SYMSGV,
      MESSAGE_V4 type SYMSGV,
      PARAMETER type BAPI_PARAM,
      ROW type INT4,
      FIELD type BAPI_FLD,
      SYSTEM type BAPILOGSYS,
    end of BAPIRET2 .
  types:
    BAPIRET2_T                     type standard table of BAPIRET2                       with non-unique default key .
  types:
    EBELP type N length 000005 .
  types:
    MATNR type C length 000040 .
  types:
    MENGE_D type P length 7  decimals 000003 .
  types:
    MEINS type C length 000003 .
  types:
    MATKL type C length 000009 .
  types:
    ZREMARKS type C length 000132 .
  types:
    EPLIF type P length 2  decimals 000000 .
  types:
    CHAR100 type C length 000100 .
  types:
    ZCOLOR type C length 000010 .
  types:
    ZSTYLE type C length 000040 .
  types:
    NETPR type P length 6  decimals 000002 .
  types:
    begin of ZGW_PO_I_V,
      INDENT_NUMBER type ZIND_NUM,
      PO_NUMBER type EBELN,
      PO_ITEM type EBELP,
      MATERIAL type MATNR,
      PLANT type WERKS_D,
      QUANTITY type MENGE_D,
      PO_UNIT type MEINS,
      MATKL type MATKL,
      REMARKS type ZREMARKS,
      PLAN_DEL type EPLIF,
      SIZE type CHAR100,
      COLOR type ZCOLOR,
      STYLE type ZSTYLE,
      NETPR type NETPR,
    end of ZGW_PO_I_V .
  types:
    __ZGW_PO_I_V                   type standard table of ZGW_PO_I_V                     with non-unique default key .
endinterface.
