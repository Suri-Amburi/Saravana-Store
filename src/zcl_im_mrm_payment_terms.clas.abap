class ZCL_IM_MRM_PAYMENT_TERMS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_MRM_PAYMENT_TERMS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MRM_PAYMENT_TERMS IMPLEMENTATION.


  METHOD IF_EX_MRM_PAYMENT_TERMS~PAYMENT_TERMS_SET.
*    BREAK PREDDY.
    DATA: IT_EKKO TYPE TABLE OF EKKO,
          WA_EKKO TYPE EKKO.

    IF TI_DRSEG IS NOT INITIAL.
      SELECT *
         FROM EKKO INTO TABLE IT_EKKO
         FOR ALL ENTRIES IN TI_DRSEG
          WHERE EBELN = TI_DRSEG-EBELN.
      IF SY-SUBRC = 0.
        READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
        E_ZFBDT = WA_EKKO-AEDAT.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
