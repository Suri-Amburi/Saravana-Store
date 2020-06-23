class ZCL_GST definition
  public
  final
  create public .

public section.

  class-methods GET_GST_PER
    importing
      !I_MATNR type MATNR
      !I_LIFNR type LIFNR
    exporting
      !ET_TAX type ZTAX_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GST IMPLEMENTATION.


  METHOD GET_GST_PER.
    CONSTANTS : C_LAND TYPE LAND1 VALUE 'IN',
                C_TAX  TYPE KAPPL VALUE 'TX'.
    CHECK I_MATNR IS NOT INITIAL.
    SELECT SINGLE MATNR,
           WERKS,
           STEUC FROM MARC INTO @DATA(LS_MARC) WHERE MATNR = @I_MATNR.
    IF SY-SUBRC = 0 .
      SELECT SINGLE LIFNR,
              LAND1,
              NAME1,
              ADRNR,
              STCD3,
              REGIO,
              VEN_CLASS FROM LFA1 INTO @DATA(LS_LFA1) WHERE LIFNR = @I_LIFNR.
      IF SY-SUBRC = 0.
        SELECT * FROM A792 INTO TABLE @DATA(LT_A792) WHERE
        LLAND = @C_LAND
        AND KAPPL = @C_TAX
         AND REGIO = @LS_LFA1-REGIO
*         AND WKREG = WA_T001W-REGIO
         AND DATBI  > @SY-DATUM
         AND STEUC = @LS_MARC-STEUC .

        IF SY-SUBRC = 0 AND LT_A792 IS NOT INITIAL.
          SELECT KNUMH,
      KOPOS,
      KAPPL,
      KSCHL,
      KBETR,
      LOEVM_KO FROM KONP INTO TABLE @DATA(LT_KONP)
      FOR ALL ENTRIES IN @lT_A792
      WHERE KNUMH = @lT_A792-KNUMH and LOEVM_KO = ' '.
          IF SY-SUBRC = 0.
            LOOP AT LT_A792 ASSIGNING FIELD-SYMBOL(<LS_A792>) WHERE STEUC = ls_MARC-STEUC AND DATBI  > SY-DATUM
                                         AND REGIO = ls_LFA1-REGIO.

              READ TABLE LT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP>)  WITH KEY KNUMH = <LS_A792>-KNUMH KAPPL = 'TX' LOEVM_KO = ' '.
              IF SY-SUBRC = 0.
                IF <LS_KONP>-KSCHL = 'JICG' OR <LS_KONP>-KSCHL = 'JIIG' OR <LS_KONP>-KSCHL = 'JISG'.
*                LV_% = <LS_konp>-KBETR / 10 .
*                WA_ITEM-GST% = WA_ITEM-GST% + LV_% .
                  APPEND VALUE #( MATNR = LS_MARC-MATNR LIFNR = LS_LFA1-LIFNR COND_TYPE = <LS_KONP>-KSCHL TAX = <LS_KONP>-KBETR ) TO ET_TAX.
                ENDIF.
              ENDIF.

            ENDLOOP.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
