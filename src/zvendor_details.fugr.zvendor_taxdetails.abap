FUNCTION ZVENDOR_TAXDETAILS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VENDOR_TT) TYPE  ZVENDOR_TT
*"  TABLES
*"      ET_ITEM STRUCTURE  ZITEM_VEN
*"----------------------------------------------------------------------

  DATA : IT_HDR  TYPE TABLE OF ZVENDOR,
         WA_HDR  TYPE ZVENDOR,
         IT_ITEM TYPE TABLE OF ZITEM_VEN,
         WA_ITEM TYPE ZITEM_VEN.
*         ls_name TYPE TABLE OF VENDOR_TT.
*         IT_A792 TYPE TABLE OF A792,
*         WA_A792 TYPE A792.


  DATA : LV_HE TYPE ZEMSG,
         LV_IE TYPE ZEMSG.
 BREAK CLIKHITHA.
  READ TABLE VENDOR_TT INTO WA_HDR INDEX 1.

  IF SY-SUBRC = 0.

    IF WA_HDR-LIFNR IS NOT INITIAL.
      SELECT
        A502~LIFNR,
        A502~MATNR,
        A502~KNUMH
        FROM A502
        INTO TABLE @DATA(IT_VENDOR)
        WHERE LIFNR = @WA_HDR-LIFNR AND KSCHL = 'PB00'.
    ENDIF .
*  ENDIF.
*  READ TABLE IT_VENDOR ASSIGNING FIELD-SYMBOL(<WA_VENDOR>) WITH KEY  LIFNR = WA_HDR-LIFNR .
*  WA_HDR-


  IF IT_VENDOR IS NOT INITIAL.
    SELECT
      LFA1~LIFNR,
      LFA1~NAME1
      FROM LFA1
      INTO TABLE @DATA(IT_VNAME)
      FOR ALL ENTRIES IN @IT_HDR
      WHERE LIFNR = @IT_HDR-LIFNR .
  ENDIF .
  READ TABLE IT_VNAME ASSIGNING FIELD-SYMBOL(<LS_V_NAME>) INDEX 1.
  IF SY-SUBRC = 0.
  wa_hdr-NAME1 = <LS_V_NAME>-name1.
    ENDIF.

  IF IT_VENDOR IS NOT INITIAL.

    SELECT
      MARA~MATNR,
      MARA~MATKL,
      MARA~BRAND_ID,
      MARA~ZZPO_ORDER_TXT,
      MARA~EANNR
      FROM MARA INTO TABLE @DATA(IT_MARA)
      FOR ALL ENTRIES IN @IT_VENDOR
      WHERE MATNR = @IT_VENDOR-MATNR .
  ENDIF.
*********          TO GET Category Description  *********************

  IF IT_MARA IS NOT INITIAL.
    SELECT
      T023T~MATKL,
      T023T~WGBEZ
      FROM T023T INTO TABLE  @DATA(IT_T023T)
      FOR ALL ENTRIES IN @IT_MARA
      WHERE MATKL = @IT_MARA-MATKL.
*      ENDIF.
    SELECT
    MARC~MATNR,
    MARC~STEUC
    FROM MARC INTO TABLE  @DATA(IT_MARC)
      FOR ALL ENTRIES IN @IT_MARA
    WHERE MATNR = @IT_MARA-MATNR.
  ENDIF.

  IF IT_MARC IS NOT INITIAL.
    SELECT
      A792~KSCHL,
      A792~STEUC,
      A792~TAXIM
      FROM A792 INTO TABLE @DATA(IT_A792)
      FOR ALL ENTRIES IN @IT_MARC
      WHERE STEUC = @IT_MARC-STEUC.
  ENDIF.

  IF IT_VENDOR IS NOT INITIAL.

    SELECT
   KONP~KNUMH,
   KONP~KBETR
   FROM KONP INTO TABLE @DATA(IT_KONP)
      FOR ALL ENTRIES IN @IT_VENDOR
   WHERE KNUMH = @IT_VENDOR-KNUMH.
  ENDIF.

   IF IT_KONP IS NOT INITIAL.
     SELECT
       PRCD_ELEMENTS~KNUMV,
       PRCD_ELEMENTS~KPOSN,
       PRCD_ELEMENTS~KBETR
       FROM PRCD_ELEMENTS
       INTO TABLE @DATA(IT_PRCD)
       FOR ALL ENTRIES IN @IT_KONP
       WHERE KNUMV = @IT_KONP-KNUMH.
       ENDIF.




   LOOP AT IT_VENDOR ASSIGNING FIELD-SYMBOL(<LS_VENDOR>).
    IF SY-SUBRC = 0.
    ENDIF.

    READ TABLE IT_VNAME ASSIGNING FIELD-SYMBOL(<WA_VNAME>) WITH KEY LIFNR = WA_HDR-LIFNR.
    IF SY-SUBRC = 0.
    ENDIF.

*  WA_ITEM-NAME1 = <WA_VNAME>-NAME1.
    READ TABLE IT_MARA ASSIGNING FIELD-SYMBOL(<WA_MARA>) WITH KEY MATNR = <LS_VENDOR>-MATNR .
    IF SY-SUBRC = 0.
      WA_ITEM-CATEGORY_CODE = <WA_MARA>-MATKL.
      WA_ITEM-BRAND_DESC = <WA_MARA>-BRAND_ID.
      WA_ITEM-ORDER_TEXT = <WA_MARA>-ZZPO_ORDER_TXT.
      WA_ITEM-EAN = <WA_MARA>-EANNR.
    ENDIF.

    READ TABLE IT_T023T ASSIGNING FIELD-SYMBOL(<WA_T023T>) WITH KEY MATKL = <WA_MARA>-MATKL.
    IF SY-SUBRC = 0.
      WA_ITEM-CATEGORY_DESC = <WA_T023T>-WGBEZ.
    ENDIF.

    READ TABLE IT_MARC ASSIGNING FIELD-SYMBOL(<WA_MARC>) WITH KEY MATNR = <WA_MARA>-MATNR.
    IF SY-SUBRC = 0.
      WA_ITEM-HSN_CODE = <WA_MARC>-STEUC.
    ENDIF.

    READ TABLE IT_A792 ASSIGNING FIELD-SYMBOL(<WA_A792>) WITH KEY STEUC = <WA_MARC>-STEUC.
    IF SY-SUBRC = 0.
      WA_ITEM-TAX = <WA_A792>-KSCHL.
    ENDIF.

    READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<WA_KONP>) WITH KEY KNUMH = <LS_VENDOR>-KNUMH.
    IF SY-SUBRC = 0.
      WA_ITEM-MRP = <WA_KONP>-KBETR.
    ENDIF.

    READ TABLE IT_PRCD ASSIGNING FIELD-SYMBOL(<wa_prcd>) with key KNUMV = <wa_KONP>-KNUMH.

    if sy-subrc = 0.
    wa_item-BILLING_RATE = <wa_prcd>-kbetr.
      ENDIF.
  APPEND : WA_ITEM TO ET_ITEM.
  CLEAR : WA_ITEM.
  ENDLOOP.


*  IF IT_ITEM IS NOT INITIAL.

*    ENDIF.
ENDIF.

ENDFUNCTION.