class ZCL_IM_MRM_HEADER_CHECK definition
  public
  final
  create public .

public section.

  interfaces IF_EX_MRM_HEADER_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MRM_HEADER_CHECK IMPLEMENTATION.


  METHOD IF_EX_MRM_HEADER_CHECK~HEADERDATA_CHECK.

*    BREAK preddy.

    DATA: IT_EKKO   TYPE TABLE OF EKKO,
          WA_EKKO   TYPE EKKO.
*BREAK breddy.
    IF TI_DRSEG IS NOT INITIAL.
      SELECT *
         FROM EKKO INTO TABLE IT_EKKO
         FOR ALL ENTRIES IN TI_DRSEG
          WHERE EBELN = TI_DRSEG-EBELN.
      IF SY-SUBRC = 0.
        READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
        I_RBKPV-BLDAT = WA_EKKO-AEDAT.

***        update  set  ZFBDT = WA_EKKO-AEDAT.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
