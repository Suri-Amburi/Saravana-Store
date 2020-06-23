interface ZIF_ZGW_PO_ITEM_DETAILS
  public .


  types:
    EBELN type C length 000010 .
  types:
    CHAR1 type C length 000001 .
  types:
    EBELP type N length 000005 .
  types:
    LIFNR type C length 000010 .
  types:
    NAME1 type C length 000030 .
  types:
    MATNR type C length 000040 .
  types:
    TXZ01 type C length 000040 .
  types:
    MENGE_D type P length 7  decimals 000003 .
  types:
    MEINS type C length 000003 .
  types:
    NETPR type P length 6  decimals 000002 .
  types:
    CHAR10 type C length 000010 .
  types:
    BAPI_MSG type C length 000220 .
  types:
    ERNAM type C length 000012 .
  types:
    NETWR type P length 8  decimals 000002 .
  types:
    ZSTYLE type C length 000040 .
  types:
    ZCOLOR type C length 000010 .
  types:
    ZREMARKS type C length 000132 .
  types:
    begin of ZGW_PO_ITEMS,
      EBELN type EBELN,
      EBELP type EBELP,
      LIFNR type LIFNR,
      NAME1 type NAME1,
      MATNR type MATNR,
      TXZ01 type CHAR80,
      MENGE type MENGE_D,
      MEINS type MEINS,
      NETPR type NETPR,
      AEDAT type CHAR10,
      BAPI_MSG type BAPI_MSG,
      ERROR_FLAG type CHAR1,
      ERNAM type ERNAM,
      DAYS type INT4,
      NETWR type NETWR,
      STYLE type ZSTYLE,
      COLOR type ZCOLOR,
      REMARKS type ZREMARKS,
    end of ZGW_PO_ITEMS .
  types:
    __ZGW_PO_ITEMS                 type standard table of ZGW_PO_ITEMS                   with non-unique default key .
  types /ACCGO/E_DELIV_DAYS type INT4 .
endinterface.
